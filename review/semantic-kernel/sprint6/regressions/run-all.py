#!/usr/bin/env python3
"""Run the seven existing regression commands with frozen source identity and full artifacts."""
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading
import time

ROOT = Path('/home/charl/defiformal')
OUT = ROOT / 'review/semantic-kernel/sprint6/regressions'
RECORD = ROOT / 'review/semantic-kernel/sprint6/regression-runs.json'
CANDIDATE = '7cb4807d1ff22c5ac804b03feb4a2530c46146f2'
SCRATCH = Path(tempfile.mkdtemp(prefix='defiformal-sprint6-regressions-'))


def utc():
    return datetime.now(timezone.utc).isoformat()


def command_output(command, cwd=ROOT):
    return subprocess.check_output(command, cwd=cwd, text=True).strip()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sources():
    paths = command_output(['git', 'ls-files', 'lean', 'scripts', 'corpus', 'corpus50',
                            'docs/research/2026-09-06-defi-source-plan.md']).splitlines()
    paths += ['review/semantic-kernel/sprint4/mutation-spec.json',
              'review/semantic-kernel/sprint5/mutation-spec.json']
    tree = subprocess.check_output(['git', 'ls-tree', '-rz', CANDIDATE], cwd=ROOT)
    objects = {}
    for row in tree.split(b'\0'):
        if row:
            metadata, path = row.split(b'\t', 1)
            objects[path.decode()] = metadata.split()[2].decode()
    rows = {}
    for relative in sorted(set(paths)):
        raw = (ROOT / relative).read_bytes()
        oid = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
        rows[relative] = {'sha256': hashlib.sha256(raw).hexdigest(),
                          'git_blob': objects.get(relative), 'observed_git_blob': oid,
                          'matches_candidate': oid == objects.get(relative)}
    if not rows or not all(row['matches_candidate'] for row in rows.values()):
        raise RuntimeError('Source input does not match frozen candidate')
    return rows


started = utc()
before = sources()
(OUT / 'source-binding.json').write_text(json.dumps(before, indent=2) + '\n')
lean_path = Path(command_output(['lake', 'env', 'which', 'lean'], ROOT / 'lean'))
identity = {'python_version': sys.version, 'python_executable': sys.executable,
            'python_executable_sha256': sha(Path(sys.executable)),
            'lean_version': command_output(['lake', 'env', 'lean', '--version'], ROOT / 'lean'),
            'lean_executable': str(lean_path), 'lean_executable_sha256': sha(lean_path),
            'git_version': command_output(['git', '--version']),
            'harness_sha256': sha(Path(__file__))}
jobs = [
    ('typed-mutations', 'check_typed_kernel_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint4/mutation-spec.json'], '--out'),
    ('composition-mutations', 'check_composition_mutations.py',
     ['--repo', str(ROOT), '--spec', 'review/semantic-kernel/sprint5/mutation-spec.json'], '--out'),
    ('composition-runner-controls', 'test_composition_mutation_runner.py',
     ['--repo', str(ROOT)], '--out'),
    ('typed-runner-controls', 'test_typed_kernel_mutation_runner.py',
     ['--repo', str(ROOT)], '--out'),
    ('axiom-controls', 'test_kernel_axiom_audit.py', [], '--output'),
    ('typing-controls', 'check_typed_kernel_typing.py', ['--repo', str(ROOT)], '--out'),
    ('corpus-controls', 'test_corpus_normalize.py', [], None),
]
state = {'source_revision': CANDIDATE, 'started_utc': started,
         'scratch_root': str(SCRATCH), 'max_parallel_subprocesses': 3,
         'source_binding': 'regressions/source-binding.json',
         'source_binding_sha256': sha(OUT / 'source-binding.json'),
         'tools': identity, 'runs': []}
lock = threading.Lock()


def save():
    RECORD.write_text(json.dumps(state, indent=2) + '\n')


def run_job(job):
    label, script, args, outflag = job
    command = ['python3', 'scripts/' + script] + args
    scratch = SCRATCH / label
    if outflag:
        command += [outflag, str(scratch)]
    help_command = ['python3', 'scripts/' + script, '--help']
    help_run = subprocess.run(help_command, cwd=ROOT, capture_output=True, text=True)
    (OUT / (label + '-help.log')).write_text(help_run.stdout + help_run.stderr)
    if help_run.returncode:
        raise RuntimeError('Help invocation failed: ' + label)
    row = {'label': label, 'command': command, 'cwd': str(ROOT), 'started_utc': utc(),
           'head_at_start': command_output(['git', 'rev-parse', 'HEAD']),
           'script_sha256': sha(ROOT / 'scripts' / script),
           'help_command': help_command, 'help_exit': help_run.returncode,
           'log': 'regressions/' + label + '.log', 'status': 'running'}
    with lock:
        state['runs'].append(row)
        save()
    print('START ' + label, flush=True)
    tick = time.monotonic()
    with (OUT / (label + '.log')).open('w') as log:
        result = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    row.update({'exit': result.returncode, 'status': 'complete', 'finished_utc': utc(),
                'elapsed_seconds': round(time.monotonic() - tick, 3),
                'head_at_end': command_output(['git', 'rev-parse', 'HEAD']),
                'log_sha256': sha(OUT / (label + '.log'))})
    if scratch.exists():
        shutil.copytree(scratch, OUT / label, symlinks=True)
        row['artifact_directory'] = 'regressions/' + label
    with lock:
        save()
    print('END ' + label + ' exit=' + str(result.returncode), flush=True)
    return row


save()
with ThreadPoolExecutor(max_workers=3) as pool:
    for future in as_completed([pool.submit(run_job, job) for job in jobs]):
        future.result()
after = sources()
state['sources_unchanged'] = before == after
state['finished_utc'] = utc()
state['all_commands_exit_zero'] = all(row['exit'] == 0 for row in state['runs'])
manifest = {}
for path in sorted(OUT.rglob('*')):
    if path.is_symlink():
        manifest[str(path.relative_to(OUT))] = {'symlink': str(path.readlink())}
    elif path.is_file() and path.name != 'artifact-manifest.json':
        manifest[str(path.relative_to(OUT))] = {'sha256': sha(path)}
(OUT / 'artifact-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
state['artifact_manifest_sha256'] = sha(OUT / 'artifact-manifest.json')
save()
print('ALL COMPLETE: ' + str(state['all_commands_exit_zero']) +
      '; sources unchanged: ' + str(state['sources_unchanged']), flush=True)
sys.exit(0 if state['all_commands_exit_zero'] and state['sources_unchanged'] else 1)
