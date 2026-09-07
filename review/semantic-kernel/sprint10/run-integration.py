#!/usr/bin/env python3
"""Execute pinned Lean integration against a committed, byte-bound source candidate."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def utc():
    return datetime.now(timezone.utc).isoformat()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--candidate', required=True)
    parser.add_argument('--runtime-count', type=int, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.runtime_count <= 0:
        parser.error('runtime count must be positive')
    def git(*argv):
        return subprocess.check_output(['git', *argv], cwd=ROOT)
    if git('rev-parse', 'HEAD').decode().strip() != args.candidate:
        raise RuntimeError('HEAD differs from candidate')
    args.out.mkdir(parents=True, exist_ok=False)
    def save(name, value):
        (args.out / name).write_text(json.dumps(value, indent=2) + '\n')
    paths = git('ls-files', '-z', 'lean').decode().strip('\0').split('\0')
    before = {}
    for path in paths:
        raw = (ROOT / path).read_bytes()
        if raw != git('show', f'{args.candidate}:{path}'):
            raise RuntimeError('Source differs from Git: ' + path)
        before[path] = {'sha256': sha(raw), 'bytes': len(raw)}
    if not before:
        raise RuntimeError('No Lean sources')
    save('source-before.json', before)
    modules = ['Interface/Audit', 'Interface/Verify', 'Metatheory/Audit', 'Metatheory/Verify', 'Atomic/Audit', 'Atomic/Verify',
               'Interleaving/Audit', 'Interleaving/Verify', 'Parallel/Audit', 'Parallel/Verify',
               'Composition/Audit', 'Composition/Verify', 'Typed/Audit', 'Typed/Verify',
               'Audit', 'ContractAudit', 'VerifyAxioms']
    commands = [['lake', 'build']] + [
        ['lake', 'env', 'lean', f'DefiKernel/{module}.lean'] for module in modules]
    records = []
    tools = {}
    for name in ('lean', 'lake'):
        executable = Path(subprocess.check_output(['lake', 'env', 'which', name],
                          cwd=ROOT / 'lean', text=True).strip()).resolve()
        tools[name] = {'path': str(executable), 'sha256': sha(executable.read_bytes()),
                       'version': subprocess.check_output([str(executable), '--version'],
                       cwd=ROOT / 'lean', text=True).strip()}
    for index, argv in enumerate(commands):
        started = utc()
        tick = time.monotonic()
        timed_out = False
        try:
            proc = subprocess.run(argv, cwd=ROOT / 'lean', capture_output=True, timeout=600)
        except subprocess.TimeoutExpired as error:
            timed_out = True
            proc = subprocess.CompletedProcess(argv, 124, error.stdout or b'', error.stderr or b'')
        logs = {}
        for suffix, data in [('stdout', proc.stdout), ('stderr', proc.stderr)]:
            name = f'{index:02d}.{suffix}.log'
            (args.out / name).write_bytes(data)
            logs[suffix] = {'path': name, 'sha256': sha(data), 'bytes': len(data)}
        records.append({'argv': argv, 'cwd': str(ROOT / 'lean'), 'started_utc': started,
                        'finished_utc': utc(), 'elapsed_seconds': round(time.monotonic()-tick, 3),
                        'exit_code': proc.returncode, 'timeout_seconds': 600, 'timed_out': timed_out, 'logs': logs})
        save('lean-runs.json', {'candidate': args.candidate, 'tools': tools, 'runs': records})
        print(' '.join(argv), proc.returncode, flush=True)
        if proc.returncode:
            break
    expected = {1: args.runtime_count, 3: 148, 5: 135, 7: 116, 9: 131, 11: 93, 13: 189, 15: 33, 16: 43}
    counts = []
    for index, count in expected.items():
        rows = []
        if index < len(records):
            log = (args.out / records[index]['logs']['stdout']['path']).read_text()
            rows = re.findall(r'^([^:\n]+): (true|false)$', log, re.M)
        counts.append({'command_index': index, 'expected': count, 'observed': len(rows),
                       'passed': len(rows) == count and len(dict(rows)) == count
                       and all(value == 'true' for _, value in rows)})
    after = {path: {'sha256': sha((ROOT/path).read_bytes()), 'bytes': (ROOT/path).stat().st_size}
             for path in before}
    save('source-after.json', after)
    passed = len(records) == len(commands) and all(r['exit_code'] == 0 for r in records)
    summary = {'candidate': args.candidate, 'commands_expected': len(commands),
               'commands_run': len(records), 'all_commands_passed': passed,
               'source_files': len(before), 'source_unchanged': before == after,
               'head_unchanged': git('rev-parse', 'HEAD').decode().strip() == args.candidate,
               'runtime_extraction_checks': counts, 'tools': tools,
               'runner_sha256': sha(Path(__file__).read_bytes())}
    save('verification.json', summary)
    okay = passed and before == after and summary['head_unchanged'] and all(r['passed'] for r in counts)
    print('INTEGRATION', 'PASS' if okay else 'FAIL', flush=True)
    return 0 if okay else 1

if __name__ == '__main__':
    raise SystemExit(main())
