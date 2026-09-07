#!/usr/bin/env python3
"""Rerun thirteen established suites at frozen Sprint 9 implementation inputs; retain source-bound artifacts."""
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
import threading
import time

ROOT = Path('/home/charl/defiformal')
OUT = ROOT / 'review/semantic-kernel/sprint9/regressions'
RECORD = OUT / 'regression-runs.json'
CANDIDATE = sys.argv[1]
SCRATCH = Path(tempfile.mkdtemp(prefix='defiformal-sprint9-regressions-'))
LOCK = threading.Lock()


def utc():
    return datetime.now(timezone.utc).isoformat()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def output(command, cwd=ROOT):
    return subprocess.check_output(command, cwd=cwd, text=True).strip()


def sources():
    paths = output(['git', 'ls-files', 'lean', 'scripts', 'corpus', 'corpus50',
                    'docs/research/2026-09-06-defi-source-plan.md', 'mutations/metatheory.json']).splitlines()
    paths += [f'review/semantic-kernel/sprint{s}/mutation-spec.json' for s in (4, 5, 6, 7, 8)]
    objects = {}
    for row in subprocess.check_output(['git', 'ls-tree', '-rz', CANDIDATE], cwd=ROOT).split(b'\0'):
        if row:
            meta, name = row.split(b'\t', 1)
            objects[name.decode()] = meta.split()[2].decode()
    rows = {}
    for name in sorted(set(paths)):
        raw = (ROOT / name).read_bytes()
        oid = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
        rows[name] = {'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw),
                      'git_blob': objects.get(name), 'observed_git_blob': oid,
                      'matches_candidate': oid == objects.get(name)}
    if not rows or not all(r['matches_candidate'] for r in rows.values()):
        raise RuntimeError('Inputs differ from frozen Git objects')
    return rows


def archive_outputs(source, destination):
    """Preserve bytes/symlinks; package nested metadata without adding embedded repos."""
    shutil.copytree(source, destination, symlinks=True,
                    ignore=lambda path, names: ['.git'] if '.git' in names else [])
    archives = []
    for directory, dirs, _ in os.walk(source, followlinks=False):
        if '.git' not in dirs:
            continue
        dirs.remove('.git')
        gitdir = Path(directory) / '.git'
        relative = gitdir.relative_to(source)
        archive = destination / relative.parent / 'git-metadata.tar'
        inputs = {str(p.relative_to(gitdir)): sha(p) for p in gitdir.rglob('*')
                  if p.is_file() and not p.is_symlink()}
        with tarfile.open(archive, 'w', dereference=False) as tar:
            tar.add(gitdir, arcname='.git')
        with tarfile.open(archive, 'r') as tar:
            observed = {m.name.removeprefix('.git/'): hashlib.sha256(tar.extractfile(m).read()).hexdigest()
                        for m in tar.getmembers() if m.isfile()}
        if not inputs or observed != inputs:
            raise RuntimeError('Nested Git archive member mismatch')
        archives.append({'original_path': str(relative),
                         'archive': str(archive.relative_to(OUT)), 'sha256': sha(archive),
                         'file_sha256': inputs, 'archive_members_verified': True})
    copied = {}
    for path in source.rglob('*'):
        relative = path.relative_to(source)
        if '.git' in relative.parts:
            continue
        target = destination / relative
        if path.is_symlink():
            good = target.is_symlink() and path.readlink() == target.readlink()
            copied[str(relative)] = {'symlink': str(path.readlink()), 'matches': good}
        elif path.is_file():
            good = target.is_file() and sha(path) == sha(target)
            copied[str(relative)] = {'sha256': sha(path), 'matches': good}
        else:
            continue
        if not good:
            raise RuntimeError('Copied artifact mismatch: ' + str(relative))
    return {'files_and_links': copied, 'nested_git_archives': archives}


JOBS = [
    ('atomic-mutations', 'check_atomic_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint8/mutation-spec.json'], '--out'),
    ('atomic-runner-controls', 'test_atomic_mutation_runner.py', ['--repo', str(ROOT)], '--out'),
    ('interleaving-mutations', 'check_interleaving_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint7/mutation-spec.json'], '--out'),
    ('typed-mutations', 'check_typed_kernel_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint4/mutation-spec.json'], '--out'),
    ('composition-mutations', 'check_composition_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint5/mutation-spec.json'], '--out'),
    ('parallel-mutations', 'check_parallel_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint6/mutation-spec.json'], '--out'),
    ('composition-runner-controls', 'test_composition_mutation_runner.py', ['--repo', str(ROOT)], '--out'),
    ('typed-runner-controls', 'test_typed_kernel_mutation_runner.py', ['--repo', str(ROOT)], '--out'),
    ('parallel-runner-controls', 'test_parallel_mutation_runner.py', ['--repo', str(ROOT)], '--out'),
    ('interleaving-runner-controls', 'test_interleaving_mutation_runner.py',
     ['--repo', str(ROOT)], '--out'),
    ('axiom-controls', 'test_kernel_axiom_audit.py', [], '--output'),
    ('typing-controls', 'check_typed_kernel_typing.py', ['--repo', str(ROOT)], '--out'),
    ('corpus-controls', 'test_corpus_normalize.py', [], None),
]


def main():
    if output(['git', 'rev-parse', 'HEAD']) != CANDIDATE:
        raise RuntimeError('HEAD differs from candidate')
    if RECORD.exists():
        raise RuntimeError('Refusing to replace existing regression evidence')
    before = sources()
    (OUT / 'source-binding.json').write_text(json.dumps(before, indent=2) + '\n')
    lean = Path(output(['lake', 'env', 'which', 'lean'], ROOT / 'lean'))
    lake = Path(output(['lake', 'env', 'which', 'lake'], ROOT / 'lean'))
    git = Path(shutil.which('git'))
    tools = {'python_version': sys.version, 'python_executable': sys.executable,
             'python_executable_sha256': sha(Path(sys.executable)),
             'lean_version': output(['lake', 'env', 'lean', '--version'], ROOT / 'lean'),
             'lean_executable': str(lean), 'lean_executable_sha256': sha(lean),
             'lake_version': output(['lake', '--version'], ROOT / 'lean'),
             'lake_executable': str(lake), 'lake_executable_sha256': sha(lake),
             'git_version': output(['git', '--version']), 'git_executable': str(git),
             'git_executable_sha256': sha(git), 'harness_sha256': sha(Path(__file__))}
    state = {'source_revision': CANDIDATE, 'started_utc': utc(), 'scratch_root': str(SCRATCH),
             'max_parallel_subprocesses': 3, 'required_suite_count': len(JOBS),
             'source_binding': 'source-binding.json',
             'source_binding_sha256': sha(OUT / 'source-binding.json'),
             'input_count': len(before), 'tools': tools, 'runs': []}

    def save():
        RECORD.write_text(json.dumps(state, indent=2) + '\n')

    def run_job(job):
        label, script, args, flag = job
        command = [sys.executable, 'scripts/' + script] + args
        scratch = SCRATCH / label
        if flag:
            command += [flag, str(scratch)]
        help_command = [sys.executable, 'scripts/' + script, '--help']
        help_run = subprocess.run(help_command, cwd=ROOT, capture_output=True, text=True)
        help_path = OUT / (label + '-help.log')
        help_path.write_text(help_run.stdout + help_run.stderr)
        if help_run.returncode:
            raise RuntimeError('Help failed: ' + label)
        row = {'label': label, 'command': command, 'cwd': str(ROOT), 'started_utc': utc(),
               'head_at_start': output(['git', 'rev-parse', 'HEAD']),
               'script_sha256': sha(ROOT / 'scripts' / script), 'help_command': help_command,
               'help_exit': help_run.returncode, 'help_log_sha256': sha(help_path),
               'status': 'running', 'log': label + '.log'}
        with LOCK:
            state['runs'].append(row)
            save()
        print('START ' + label, flush=True)
        started = time.monotonic()
        stdout = OUT / (label + '.stdout.log')
        stderr = OUT / (label + '.stderr.log')
        with stdout.open('wb') as so, stderr.open('wb') as se:
            proc = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se)
        combined = OUT / (label + '.log')
        combined.write_bytes(stdout.read_bytes() + stderr.read_bytes())
        row.update({'exit': proc.returncode, 'finished_utc': utc(),
                    'elapsed_seconds': round(time.monotonic() - started, 3),
                    'head_at_end': output(['git', 'rev-parse', 'HEAD']),
                    'stdout_log': str(stdout.relative_to(OUT)), 'stdout_sha256': sha(stdout),
                    'stderr_log': str(stderr.relative_to(OUT)), 'stderr_sha256': sha(stderr),
                    'log_sha256': sha(combined), 'combined_order': 'stdout then stderr',
                    'script_unchanged': sha(ROOT / 'scripts' / script) == row['script_sha256']})
        if scratch.exists():
            copied = archive_outputs(scratch, OUT / label)
            copy_path = OUT / (label + '-copy-integrity.json')
            copy_path.write_text(json.dumps(copied, indent=2) + '\n')
            row['artifact_directory'] = label
            row['copy_integrity_sha256'] = sha(copy_path)
        row['status'] = 'complete'
        with LOCK:
            save()
        print(f'END {label} exit={proc.returncode}', flush=True)

    save()
    with ThreadPoolExecutor(max_workers=3) as pool:
        for future in as_completed([pool.submit(run_job, job) for job in JOBS]):
            try:
                future.result()
            except Exception as error:
                with LOCK:
                    state.setdefault('harness_errors', []).append(repr(error))
                    save()
                print('BLOCKED: ' + repr(error), flush=True)
    after = sources()
    (OUT / 'source-binding-after.json').write_text(json.dumps(after, indent=2) + '\n')
    state.update({'sources_unchanged': before == after, 'finished_utc': utc(),
                  'source_binding_after_sha256': sha(OUT / 'source-binding-after.json'),
                  'all_commands_exit_zero': len(state['runs']) == len(JOBS) and
                  all(r.get('exit') == 0 and r.get('status') == 'complete' for r in state['runs']) and
                  not state.get('harness_errors'),
                  'harness_unchanged': sha(Path(__file__)) == tools['harness_sha256']})
    manifest = {}
    for p in sorted(OUT.rglob('*')):
        if p.is_symlink():
            manifest[str(p.relative_to(OUT))] = {'symlink': str(p.readlink())}
        elif p.is_file() and p.name not in ['artifact-manifest.json','regression-runs.json']:
            manifest[str(p.relative_to(OUT))] = {'sha256': sha(p)}
    (OUT / 'artifact-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    state['artifact_manifest_sha256'] = sha(OUT / 'artifact-manifest.json')
    save()
    print('ALL COMPLETE: ' + str(state['all_commands_exit_zero']) +
          '; sources unchanged: ' + str(state['sources_unchanged']), flush=True)
    return 0 if state['all_commands_exit_zero'] and state['sources_unchanged'] else 1


if __name__ == '__main__':
    sys.exit(main())
