#!/usr/bin/env python3
"""Exercise the mutation runner's CLI against real temporary Lean computations.

No subprocess is mocked. The temporary repository links installed dependency packages
and has its own isolated git metadata. All fixtures/logs stay outside the
source repository. Exit 0 means every nonempty control has the expected classification;
exit 1 means an observed classification differs; exit 3 means the harness could not run.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


INPUT_MODULE = 'DefiKernel.Typed.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Typed.RunnerAudit'
INPUT = '''import Mathlib.Data.Nat.Basic

namespace DefiKernel.Typed

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Typed
'''
AUDIT = '''import DefiKernel.Typed.RunnerInput

namespace DefiKernel.Typed

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Typed runtime comparisons failed: {failures}"

end DefiKernel.Typed
'''
CHECKS = '''if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(value, message):
    if not value:
        raise RuntimeError(message)


def mutation(needle='n ≤ 4', replacement='n ≤ 5', required=None):
    return {'name': 'probe', 'module': INPUT_MODULE, 'needle': needle,
            'replacement': replacement,
            'required_false': ['runner_sensitivity'] if required is None else required}


def specification(change=None):
    return {'schema_version': 1, 'modules': [INPUT_MODULE, AUDIT_MODULE],
            'mutations': [mutation() if change is None else change],
            'positive_checks': ['runner_positive']}


def cases():
    """Expected classifications are fixed independently of the runner implementation."""
    return [
        {'name': 'live-discriminating-mutant', 'exit': 0,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'all-true-mutant', 'exit': 1, 'spec': specification(mutation(replacement='n ≤ 3')),
         'message': 'all comparisons still pass under mutation'},
        {'name': 'required-observation-stays-true', 'exit': 1,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'positive-control-flipped', 'exit': 1,
         'spec': specification(mutation(replacement='n == 5')),
         'message': 'positive control failed'},
        {'name': 'compilation-only-failure', 'exit': 3,
         'spec': specification(mutation('-- compiler-control', '#check runnerUndefinedConstant')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'compiler-error-with-runtime-failure', 'exit': 3,
         'spec': specification(mutation('n ≤ 4\ndef runnerIncludeSensitivity : Bool := true',
                                        'n ≤ 5\n#check runnerUndefinedConstant\n'
                                        'def runnerIncludeSensitivity : Bool := true')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'empty-observations', 'exit': 3, 'checks': '[]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'duplicate-observations', 'exit': 3,
         'checks': '[("runner_positive", true), ("runner_positive", true), '
                   '("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'missing-positive-observation', 'exit': 3,
         'checks': '[("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: missing positive controls'},
        {'name': 'missing-required-observation', 'exit': 3,
         'spec': specification(mutation(required=['runner_absent'])),
         'message': 'probe: missing required observation in control'},
        {'name': 'partial-mutant-observations', 'exit': 3,
         'spec': specification(mutation('runnerIncludeSensitivity : Bool := true',
                                        'runnerIncludeSensitivity : Bool := false')),
         'message': 'probe: partial execution'},
        {'name': 'no-op-mutation', 'exit': 3,
         'spec': specification(mutation(replacement='n ≤ 4')),
         'message': 'mutation must actually change the source'},
        {'name': 'missing-mutation-needle', 'exit': 3,
         'spec': specification(mutation('runnerNeedleDoesNotExist', 'false')),
         'message': 'mutation did not apply exactly once'},
        {'name': 'missing-source-setup', 'exit': 3, 'missing_source': True,
         'message': 'FileNotFoundError'},
        {'name': 'missing-manifest-setup', 'exit': 3, 'missing_manifest': True,
         'message': 'FileNotFoundError'},
        {'name': 'existing-output-setup', 'exit': 3, 'existing_output': True,
         'message': 'output already exists'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_typed_kernel_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    started = datetime.now(timezone.utc).isoformat()
    identity = []

    def identify(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', text=True, capture_output=True, timeout=60)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        identity.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                         'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        require(proc.returncode == 0, f'{label} unavailable: {log}')
        return proc.stdout.strip()

    lean_version = identify('lean-version', ['lake', 'env', 'lean', '--version'])
    lean_path = Path(identify('lean-path', ['lake', 'env', 'which', 'lean']))
    git_head = identify('git-head', ['git', 'rev-parse', 'HEAD'])
    fake = out / 'fixture-repo'
    lean = fake / 'lean'
    typed = lean / 'DefiKernel/Typed'
    typed.mkdir(parents=True)
    # Independent metadata prevents even optional index refreshes in the source repo.
    for command in [
        ['git', 'init', '--quiet', str(fake)],
        ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
         '-c', 'user.email=fixture@invalid', 'commit', '--allow-empty', '--quiet',
         '-m', 'Initialize isolated mutation-runner fixture'],
    ]:
        proc = subprocess.run(command, text=True, capture_output=True, timeout=60)
        require(proc.returncode == 0, f'isolated fixture git setup failed: {proc.stderr}')
    (lean / '.lake').mkdir()
    # Reuse dependency packages, never the source project's .lake/build directory.
    (lean / '.lake/packages').symlink_to(repo / 'lean/.lake/packages', target_is_directory=True)
    for name in ('lean-toolchain', 'lake-manifest.json', 'lakefile.toml'):
        shutil.copyfile(repo / 'lean' / name, lean / name)
    manifest = (lean / 'lake-manifest.json').read_bytes()
    records = []
    for case in cases():
        (typed / 'RunnerInput.lean').write_text(INPUT)
        (typed / 'RunnerAudit.lean').write_text(AUDIT.replace('CHECKS', case.get('checks', CHECKS)))
        (lean / 'lake-manifest.json').write_bytes(manifest)
        if case.get('missing_source'):
            (typed / 'RunnerInput.lean').unlink()
        if case.get('missing_manifest'):
            (lean / 'lake-manifest.json').unlink()
        spec = case.get('spec', specification())
        spec_path = out / (case['name'] + '-spec.json')
        spec_path.write_text(json.dumps(spec, indent=2) + '\n')
        result_path = out / 'runs' / case['name']
        if case.get('existing_output'):
            result_path.mkdir(parents=True)
        command = [sys.executable, str(runner), '--repo', str(fake), '--spec', str(spec_path),
                   '--out', str(result_path)]
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo, text=True, capture_output=True, timeout=300)
        elapsed = time.monotonic() - tick
        log = proc.stdout + proc.stderr
        log_path = out / (case['name'] + '.log')
        log_path.write_text(log)
        matched = proc.returncode == case['exit'] and case['message'] in log
        runtime = {}
        results_file = result_path / 'results.json'
        if results_file.exists():
            runtime = json.loads(results_file.read_text())
        # Accepted discrimination additionally requires exact real Lean observations.
        if case['name'] == 'live-discriminating-mutant':
            measured = runtime.get('results', {})
            matched = matched and measured.get('control', {}).get('checks') == {
                'runner_positive': 'true', 'runner_sensitivity': 'true'}
            matched = matched and measured.get('probe', {}).get('checks') == {
                'runner_positive': 'true', 'runner_sensitivity': 'false'}
        observations = {}
        for variant in ('control', 'probe'):
            variant_log = result_path / (variant + '.log')
            if variant_log.exists():
                raw = variant_log.read_text()
                observations[variant] = {
                    'lines': re.findall(r'^([a-z][a-z0-9_]*): (true|false)$', raw, re.MULTILINE),
                    'errors': [line for line in raw.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)],
                    'log_sha256': sha(raw.encode())}
        record = {'name': case['name'], 'command': command, 'cwd': str(repo),
                  'expected_exit': case['exit'], 'actual_exit': proc.returncode,
                  'expected_message': case['message'], 'passed': matched,
                  'elapsed_seconds': round(elapsed, 6), 'log': str(log_path),
                  'log_sha256': sha(log.encode()), 'cli_output': log,
                  'spec_sha256': sha(spec_path.read_bytes()),
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': sha(Path(__file__).read_bytes()),
               'lean_version': lean_version, 'lean_executable_sha256': sha(lean_path.read_bytes()),
               'python_version': sys.version, 'tool_identity_commands': identity,
               'fixture_scope': 'Synthetic development Lean computations; actual CLI and installed '
                                'Lean/mathlib. No subprocess mocks; no production theorem claim.',
               'fixture_input_sha256': sha(INPUT.encode()),
               'fixture_audit_template_sha256': sha(AUDIT.encode()),
               'total': len(records), 'passed': sum(r['passed'] for r in records),
               'cases': records}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f'CONTROLS: {summary["passed"]}/{summary["total"]} passed', flush=True)
    return 0 if all(r['passed'] for r in records) else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)
