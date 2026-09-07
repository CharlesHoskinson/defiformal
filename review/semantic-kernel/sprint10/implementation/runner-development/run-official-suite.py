#!/usr/bin/env python3
"""Capture an authorized frozen suite without changing its inherited behavior."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frozen', required=True)
    parser.add_argument('--kind', choices=['production', 'controls'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert git('rev-parse', 'HEAD').decode().strip() == args.frozen
    out = args.out.absolute()
    assert not out.exists() and not out.is_symlink() and not out.is_relative_to(ROOT)
    paths = ['scripts/run_interface_mutations.py', 'scripts/test_interface_mutation_runner.py',
             'mutations/interface.json', 'lean/lean-toolchain',
             'lean/lake-manifest.json', 'lean/lakefile.toml']
    bindings = {}
    for path in paths:
        raw = (ROOT / path).read_bytes()
        committed = git('show', f'{args.frozen}:{path}')
        assert raw == committed, path
        bindings[path] = {'sha256': sha(raw), 'bytes': len(raw),
                          'git_blob': git('rev-parse', f'{args.frozen}:{path}').decode().strip(),
                          'git_bytes_equal': True}
    if args.kind == 'production':
        command = [sys.executable, 'scripts/run_interface_mutations.py', '--repo', str(ROOT),
                   '--spec', str(ROOT / 'mutations/interface.json'), '--out', str(out / 'run'),
                   '--timeout-seconds', '600']
    else:
        command = [sys.executable, 'scripts/test_interface_mutation_runner.py',
                   '--repo', str(ROOT), '--out', str(out / 'run')]
    out.mkdir(parents=True)
    record = {'kind': args.kind, 'frozen_source': args.frozen,
              'command': command, 'cwd': str(ROOT), 'input_bindings': bindings,
              'started_utc': datetime.now(timezone.utc).isoformat(),
              'status': 'RUNNING', 'wrapper_sha256': sha(Path(__file__).read_bytes()),
              'timing_scope': 'Outer run UTC/elapsed only; inherited runner records own labeled-command, variant and case elapsed. No added per-command UTC or binding timings.'}
    metadata = out / 'invocation.json'
    metadata.write_text(json.dumps(record, indent=2) + '\n')
    tick = time.monotonic()
    with (out / 'stdout.log').open('wb') as stdout, (out / 'stderr.log').open('wb') as stderr:
        proc = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
    unchanged = {path: sha((ROOT / path).read_bytes()) == binding['sha256']
                 for path, binding in bindings.items()}
    head_after = git('rev-parse', 'HEAD').decode().strip()
    record.update({'finished_utc': datetime.now(timezone.utc).isoformat(),
                   'elapsed_seconds': round(time.monotonic() - tick, 6),
                   'actual_exit': proc.returncode, 'status': 'FINISHED',
                   'inputs_unchanged': unchanged, 'git_head_after': head_after,
                   'git_head_unchanged': head_after == args.frozen,
                   'stdout_sha256': sha((out / 'stdout.log').read_bytes()),
                   'stderr_sha256': sha((out / 'stderr.log').read_bytes())})
    metadata.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'kind': args.kind, 'actual_exit': proc.returncode,
                      'elapsed_seconds': record['elapsed_seconds'],
                      'inputs_unchanged': all(unchanged.values()),
                      'git_head_unchanged': record['git_head_unchanged'], 'output': str(out)}))
    if not all(unchanged.values()) or not record['git_head_unchanged']:
        return 3
    return proc.returncode


if __name__ == '__main__':
    raise SystemExit(main())
