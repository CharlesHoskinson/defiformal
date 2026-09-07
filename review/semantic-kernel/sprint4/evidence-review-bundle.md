Independently review DeFiFormal Sprint4 FINAL EVIDENCE/VERIFICATION scope at source revision 1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f. Use only supplied bundle; do not load skills, tools, other files or web sources. If prompt offloaded read only prompt file. Return <=900 words: ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES, severity-ranked concrete findings and exact code/evidence. Source review by native CLI only; do not claim to rerun any command.

This scope covers new mutation/typing verification tools, integrated driver/imported audit binding and resulting evidence. Foundation and executor reviewed separately by both providers accepted with limitations; reference libraries+remediation currently undergoing separate native review. Only final review acceptance remains pending; all computational evidence here was actually executed on source hashes matching 1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f. Supplied controls are synthetic but REAL Lean executions through real CLI (not mocks); source mutations are actual changed computational Lean definitions, not modeled Python substitutes. Central189-check runtime inventory:34Expr+37Authority+48Transition+70reference. Each mutant uses exact unique needle in temporary source copies, removing proof-only suffixes and imports while concatenating ordered internal computational modules. All comparison definitions remain; individual test #eval drivers are below markers and stripped; central Audit sole driver is above/no marker. Original accepted proof files never change. Fintype/State proof fields needed for executable data remain. No custom axioms/sorry/native_decide in accepted proofs. Nonnegativity guard cannot simply be bypassed while constructing State witness, so no fake nonneg mutation is claimed.

One control189/189 true. All24 mutants compile and execute all189 comparisons, then have solely expected runtime comparison error and their required_false observations false;3 common positive siblings remain true in all25runs. No compiler-only failure counted as sensitivity. Source snapshots/toolchain/Lean executable hash and fixture/log hashes saved; complete fixture bytes archived. Final source commit happened during replay but no source bytes changed; before/after hashes match candidate. The Git execution_start_revision is accurately retained, with content binding to final commit separately. No source/deployment fidelity claim. Historical original tracked files unchanged except root Lean import and progress ledger.

Fifteen real CLI runner controls test discriminating0/alltrue1/compiler-only3/compiler-plus-runtime3/empty3/duplicate3/missing positive3/missing required3/partial3/no-op3/missing needle3/missing source3/missing manifest3/existing output3/empty mutation3. During self-test we found tagged Lean error(lean.unknownIdentifier) could escape old ': error:' filter. Actual pre-fix runner SHA matched reconstructed previous source; tagged compile error+runtime false wrongly returned0. Fixed regex recognizes tagged error diagnostics; identical regression now returns3. Also missing required label now rejected against unchanged inventory before mutations. Evidence records prior defect and fixed classification rather than hiding it.

Fresh full lake build exit0,1005jobs. Actual direct Typed/Audit command189unique alltrue; direct Typed/Verify524theorem+978supplemental declarations forbidden0. Existing old imported audit278+234forbidden0; old33+43runtime and99audit-control assertions pass. Axiom allowlist only propext,Classical.choice,Quot.sound; imported declarations only, current-module declarations after audit excluded by scope. Verify contains no declaration after command. No change to the existing audited AxiomAudit implementation. Type test compiles/executes positive and separately compiles three negative files with actual Type mismatch exit1; these are type refusals, not financial counterexamples.


Exact new source SHA256
{
  "scripts/check_typed_kernel_mutations.py": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
  "scripts/test_typed_kernel_mutation_runner.py": "fa82c057ec746a28ffa3eb4be907823f39c81def38261e7db55068b3f50a4f06",
  "scripts/check_typed_kernel_typing.py": "98392920c32379721b56aee8ddb57313e5ef87fee76f76bf4c4c077cf74e2edc",
  "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
  "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
  "lean/DefiKernel.lean": "0ff4580a1bf16942c351d170d5322f7e9c65790dc5cd1978282b40b5268835c2"
}

===== source scripts/check_typed_kernel_mutations.py =====
#!/usr/bin/env python3
"""Replay the actual typed Lean implementation under explicit source mutations.

The specification names an ordered, nonempty list of source modules, mutation
sites, required false observations and protected positive controls. Proof-only
suffixes are excluded from temporary execution copies, never from accepted files.
Exit 0: nonempty control and all sensitivity assertions pass; 1: failed assertion;
3: unavailable evidence, malformed specification or compilation/setup failure.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = path.read_bytes()
    require(raw.strip(), f'empty required input: {path}')
    return raw


def parse(raw):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key: {key}')
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    require(not out.is_relative_to(repo), 'evidence output must be outside the repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
    spec_raw = read(args.spec)
    spec = parse(spec_raw)
    require(isinstance(spec, dict) and set(spec) ==
            {'schema_version', 'modules', 'mutations', 'positive_checks'},
            'invalid mutation specification fields')
    require(type(spec['schema_version']) is int and spec['schema_version'] == 1,
            'unsupported mutation specification version')
    modules, mutations, positives = spec['modules'], spec['mutations'], spec['positive_checks']
    require(isinstance(modules, list) and modules, 'empty module inventory')
    require(isinstance(mutations, list) and mutations, 'empty mutation inventory')
    require(isinstance(positives, list) and positives, 'empty positive-control inventory')
    require(len(set(modules)) == len(modules), 'duplicate source module')
    require(len(set(positives)) == len(positives), 'duplicate positive control')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] != 'control', 'control is a reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
    blobs = {}
    for module in modules:
        require(re.fullmatch(r'DefiKernel\.Typed(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
                f'invalid scoped module: {module}')
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        blobs[relative] = read(path)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    imports, prefixes = [], {}
    for module in modules:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source:
            source, suffix = source.split(marker)
            closure = re.search(r'\n(end DefiKernel\.Typed(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
            require(closure, f'{module}: proof suffix lacks exact namespace closure')
            namespace = closure.group(1)[4:]
            require(f'namespace {namespace}\n' in source, f'{module}: unmatched namespace')
            source += '\n\n' + closure.group(1) + '\n'
        lines = []
        for line in source.splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported not in modules and line not in imports:
                    require(not imported.startswith('DefiKernel.Typed.'),
                            f'{module}: omitted internal dependency {imported}')
                    imports.append(line)
            else:
                lines.append(line)
        prefixes[module] = '\n'.join(lines) + '\n'
    require(imports, 'no external dependency imports captured')
    variants = {'control': dict(prefixes)}
    for m in mutations:
        source = prefixes[m['module']]
        require(source.count(m['needle']) == 1, f'{m["name"]}: mutation did not apply exactly once')
        variants[m['name']] = {**prefixes, m['module']: source.replace(m['needle'], m['replacement'], 1)}
    out.mkdir(parents=True, exist_ok=False)
    records, results = [], {}

    def run(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True, timeout=240)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        return proc.returncode, log

    status, version = run('lean-version', ['lake', 'env', 'lean', '--version'])
    require(status == 0, 'Lean tool identity unavailable')
    status, executable = run('lean-path', ['lake', 'env', 'which', 'lean'])
    require(status == 0, 'Lean executable path unavailable')
    executable_sha = sha(read(Path(executable.strip())))
    status, head = run('git-head', ['git', 'rev-parse', 'HEAD'])
    require(status == 0, 'Git revision unavailable')
    status, dirty = run('git-root-input-status', ['git', '-C', str(repo), 'status', '--porcelain',
                                                '--untracked-files=all', '--', *blobs])
    require(status == 0, 'Git source status unavailable')
    manifest = {'sources': sources, 'script_sha256': sha(read(Path(__file__))),
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Temporary executable source projections; accepted proof files unchanged.'}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in modules)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(r'^([a-z][a-z0-9_]*): (true|false)$', log, re.MULTILINE)
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            require(not errors, 'control compilation/execution failed')
            assert code == 0 and not false, 'unchanged control has failing comparisons'
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            assert code != 0 or false, f'{label}: all comparisons still pass under mutation'
            expected_error = f'error: Typed runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            assert code != 0 and set(required) <= set(false), f'{label}: required mutation not detected'
        assert all(checks[name] == 'true' for name in positives), f'{label}: positive control failed'
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
    require(manifest['sources_after'] == sources, 'input sources changed during replay')
    manifest['input_sources_unchanged'] = True
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'DISCRIMINATES: {len(mutations)} mutants and one nonempty unchanged control')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


===== source scripts/test_typed_kernel_mutation_runner.py =====
#!/usr/bin/env python3
"""Exercise the mutation runner's CLI against real temporary Lean computations.

No subprocess is mocked. The temporary repository links installed dependency packages
and reads the source repository's git metadata. All fixtures/logs stay outside the
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
    git_dir = Path(identify('git-directory', ['git', 'rev-parse', '--absolute-git-dir']))
    fake = out / 'fixture-repo'
    lean = fake / 'lean'
    typed = lean / 'DefiKernel/Typed'
    typed.mkdir(parents=True)
    (fake / '.git').write_text(f'gitdir: {git_dir}\n')
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


===== source scripts/check_typed_kernel_typing.py =====
#!/usr/bin/env python3
"""Compile one positive and three deliberately ill-typed expressions with real Lean.

These are typing refusals, not executed financial counterexamples. Exit 0 means
all four expected outcomes were observed; 1 means a negative term was accepted;
3 means evidence was unavailable or failed for another reason.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    if out.is_relative_to(repo) or out.exists():
        raise RuntimeError('output must be new and outside the repository')
    prefix = '''import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
'''
    fixtures = {
        'positive': '''def accepted : E (.amount false) :=
  .binary (.convert true false) (.lit 3) (.lit 2)
#eval IO.println (if accepted.eval ⟨⟨fun _ => 0, by intro c; decide⟩,
  (fun _ => none), false, [], .nil, 0⟩ == .ok 6 then "typing_positive: true"
  else "typing_positive: false")
''',
        'mixed-assets': '''def rejected : E (.amount false) :=
  .binary (.add (.amount false)) (.lit 1)
    (.lit 2 : E (.amount true))
''',
        'reversed-price': '''def rejected : E (.amount false) :=
  .binary (.convert true false) (.lit 3)
    (.lit 2 : E (.price false true))
''',
        'implicit-debt-conversion': '''def rejected : E (.amount false) :=
  .binary (.scale (.amount true)) (.lit 1) (.lit 2)
''',
    }
    out.mkdir(parents=True)
    def digest(path):
        return hashlib.sha256(path.read_bytes()).hexdigest()
    paths = [repo / ('lean/DefiKernel/Typed/' + n + '.lean') for n in ['Types', 'Expr']]
    paths += [repo / ('lean/' + n) for n in ['lean-toolchain', 'lakefile.toml', 'lake-manifest.json']]
    before = {str(p.relative_to(repo)): digest(p) for p in paths}
    results = {'script_sha256': digest(Path(__file__)), 'sources': before, 'runs': {}}
    results['git_head'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repo, text=True).strip()
    results['lean_version'] = subprocess.check_output(['lake', 'env', 'lean', '--version'],
                                                     cwd=repo / 'lean', text=True).strip()
    executable = subprocess.check_output(['lake', 'env', 'which', 'lean'], cwd=repo / 'lean', text=True).strip()
    results['lean_executable_sha256'] = digest(Path(executable))
    for name, body in fixtures.items():
        path = out / (name + '.lean')
        path.write_text(prefix + body)
        command = ['lake', 'env', 'lean', str(path)]
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True, timeout=120)
        log = proc.stdout + proc.stderr
        (out / (name + '.log')).write_text(log)
        results['runs'][name] = {'command': command, 'exit': proc.returncode,
                                'fixture_sha256': digest(path),
                                'log_sha256': digest(out / (name + '.log'))}
        (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
        if name == 'positive':
            if proc.returncode != 0 or 'typing_positive: true' not in log or ': error:' in log:
                raise RuntimeError('positive typing control failed')
        else:
            assert proc.returncode != 0, f'{name}: deliberately ill-typed expression accepted'
            if proc.returncode != 1 or not any(x in log.lower() for x in
                                             ['type mismatch', 'application type mismatch']):
                raise RuntimeError(f'{name}: failure was not the expected typing refusal')
        print(f'{name}: expected outcome observed (exit {proc.returncode})')
    after = {str(p.relative_to(repo)): digest(p) for p in paths}
    if after != before:
        raise RuntimeError('source changed during typing checks')
    results['input_sources_unchanged'] = True
    results['scope'] = 'One executed positive and three compiler-rejected unit mismatches; no financial counterexample claim.'
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


===== source lean/DefiKernel/Typed/Audit.lean =====
import DefiKernel.Typed.ExprTests
import DefiKernel.Typed.AuthorityTests
import DefiKernel.Typed.TransitionTests
import DefiKernel.Typed.Acceptance

/-! One named, nonempty runtime inventory for the typed kernel and reference libraries.
Source mutation replay uses this same driver with proof-only suffixes removed from
temporary dependency copies. Accepted sources retain all proofs. -/
namespace DefiKernel.Typed

def runtimeChecks : List (String × Bool) :=
  ExprTests.checks ++ AuthorityTests.checks ++ TransitionTests.checks ++ Acceptance.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty typed runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate typed runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

end DefiKernel.Typed


===== source lean/DefiKernel/Typed/Verify.lean =====
import DefiKernel.Typed.Audit
import DefiKernel.AxiomAudit

/-! Audit the actual imported Typed closure: theorem declarations and supplemental
definitions, opaque constants and axioms. This is distinct from bounded runtime
checks and does not cover declarations added after this command. -/
#audit_axioms DefiKernel.Typed


===== source lean/DefiKernel.lean =====
import DefiKernel.VerifyAxioms
import DefiKernel.Typed.Verify

/-! Entry point for the pilot, typed kernel, regressions and imported axiom audits. -/


===== recorded evidence mutations/summary.json =====
{
  "source_revision": "1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f",
  "execution_start_revision": "3a44e4ea57003a93df74f112bf1b9243b2938e24",
  "revision_binding": "Source SHA256 match final revision; commit occurred during replay, without source edits.",
  "input_sources_unchanged": true,
  "comparisons": 189,
  "mutants": 24,
  "positive_checks": [
    "expr_exact_price_conversion",
    "authority_issue_succeeds_with_id_zero",
    "transition_transfer_exact"
  ],
  "results": {
    "control": {
      "exit": 0,
      "fixture_sha256": "1aeabb53afaeb623c39d67da58be5ecb2a9b8f9858f2a4c3bedec1545c4a2977",
      "false_comparisons": []
    },
    "admin-bypass": {
      "exit": 1,
      "fixture_sha256": "6017484493a876b91b496d8982fac9b3cdbf3ac8016d91ff923f336d5641592a",
      "false_comparisons": [
        "authority_issuer_wrong_authenticated_domain",
        "authority_revoker_wrong_authenticated_domain",
        "authority_unauthorized_issuer",
        "authority_unauthorized_revoker",
        "reference_unauthorized_issue",
        "reference_unauthorized_revoke"
      ]
    },
    "holder-bypass": {
      "exit": 1,
      "fixture_sha256": "2b2b8bad3ad46f5f6bee30934b6eb7561da6980a4abdf6e401faf369aa737840",
      "false_comparisons": [
        "authority_wrong_holder",
        "reference_wrong_holder",
        "transition_wrong_cap_holder"
      ]
    },
    "live-bypass": {
      "exit": 1,
      "fixture_sha256": "f47de99d1d781d7aaf1bf835ef24af2edecb2dd703b3eecac2da77873b2ce399",
      "false_comparisons": [
        "authority_old_revoked_id_remains_unusable",
        "authority_same_request_after_revoke",
        "reference_issue_use_revoke_same_request",
        "reference_old_id_stays_revoked",
        "reference_resource_revoked_same_request",
        "reference_revoked_invocation",
        "transition_revoked_debit"
      ]
    },
    "cap-domain-bypass": {
      "exit": 1,
      "fixture_sha256": "d09e33f497cc6982438deb7d7a1828949eecbf8f60108aa3cf2ddb556652c9bc",
      "false_comparisons": [
        "authority_foreign_grant_cannot_authorize_local_context",
        "authority_wrong_authenticated_domain"
      ]
    },
    "cap-operation-bypass": {
      "exit": 1,
      "fixture_sha256": "d9e4c138ea3c5d4e02c728eecbf5096983133a49ceb284b1e4ebb511753797a4",
      "false_comparisons": [
        "authority_other_operation_cannot_authorize_original",
        "authority_wrong_operation",
        "reference_issue_use_revoke_same_request",
        "reference_resource_revoked_same_request",
        "reference_revoked_invocation",
        "reference_wrong_operation_capabilities"
      ]
    },
    "cap-resource-bypass": {
      "exit": 1,
      "fixture_sha256": "b712410c08fb1282d37fa0b9d2dc6c324ba625f36b996290a9b7957ae7d68d3b",
      "false_comparisons": [
        "authority_duplicates_add_no_right",
        "authority_right_kind_mismatch",
        "authority_same_request_after_revoke",
        "authority_wrong_debit_asset",
        "authority_wrong_debit_owner",
        "authority_wrong_supply_asset",
        "reference_issue_use_revoke_same_request",
        "reference_missing_debit",
        "reference_missing_debt_supply",
        "reference_missing_share_supply",
        "reference_resource_revoked_same_request",
        "reference_revoked_invocation",
        "transition_debit_required",
        "transition_invoke_required",
        "transition_revoked_debit",
        "transition_supply_required"
      ]
    },
    "revoke-noop": {
      "exit": 1,
      "fixture_sha256": "2d2d8059b238c54ef9b6f6c41284f8129402791327888f849c826511fca0d244",
      "false_comparisons": [
        "authority_old_revoked_id_remains_unusable",
        "authority_revoke_accepted",
        "authority_same_request_after_revoke",
        "reference_issue_use_revoke_same_request",
        "reference_old_id_stays_revoked",
        "reference_resource_revoked_same_request",
        "reference_revocation_tombstone",
        "reference_revoked_invocation",
        "transition_revoked_debit",
        "transition_revoked_tombstone_exact"
      ]
    },
    "invoke-bypass": {
      "exit": 1,
      "fixture_sha256": "694c75e2b02b3484ab1b771a629f63cfcf34d775a485e1c57c62af96245f8fbe",
      "false_comparisons": [
        "reference_issue_use_revoke_same_request",
        "reference_revoked_invocation",
        "reference_unknown_capability",
        "reference_wrong_holder",
        "reference_wrong_operation_capabilities",
        "transition_invoke_required",
        "transition_wrong_cap_holder"
      ]
    },
    "guard-bypass": {
      "exit": 1,
      "fixture_sha256": "690d50f722ec58658e5490bd1f19785f327524f1df66dab2359ad49ebb8add69",
      "false_comparisons": [
        "reference_collateral_exceeded",
        "reference_negative_borrow",
        "reference_negative_deposit",
        "reference_negative_transfer",
        "reference_negative_withdraw",
        "reference_oracle_future",
        "reference_oracle_negative",
        "reference_oracle_negative_independent",
        "reference_oracle_stale",
        "reference_oracle_zero",
        "reference_oracle_zero_independent",
        "transition_false_guard_missing_read_precedence",
        "transition_guard_false"
      ]
    },
    "state-read-bypass": {
      "exit": 1,
      "fixture_sha256": "4700f9655bb44db06393f5a19a21415c82dd25006cbea751c987bd29543aaca5",
      "false_comparisons": [
        "reference_missing_effect_read",
        "reference_missing_guard_state_read",
        "transition_effect_read_missing",
        "transition_guard_read_missing",
        "transition_inactive_read_missing",
        "transition_supply_only_read_missing"
      ]
    },
    "env-read-bypass": {
      "exit": 1,
      "fixture_sha256": "b1e899a5696b9ead65969aa21d30d928425801bdf5e61b98a20c8433fc85928a",
      "false_comparisons": [
        "reference_missing_guard_env_read",
        "transition_env_read_missing",
        "transition_now_read_missing",
        "transition_timestamp_read_missing"
      ]
    },
    "domain-bypass": {
      "exit": 1,
      "fixture_sha256": "5336aebe2e162779d789218d4d43d5a7f604750d83a9557c71328638fddeb646",
      "false_comparisons": [
        "transition_foreign_effect",
        "transition_foreign_state_read",
        "transition_foreign_supply"
      ]
    },
    "debit-bypass": {
      "exit": 1,
      "fixture_sha256": "8f102df843c570cc63f035fd8d712e4ee971d9bf1692542eeea9cd4d5dba6711",
      "false_comparisons": [
        "reference_missing_debit",
        "reference_resource_revoked_same_request",
        "transition_debit_required",
        "transition_revoked_debit"
      ]
    },
    "supply-bypass": {
      "exit": 1,
      "fixture_sha256": "4ca0c5d91f7f6ab822b19fdb79e60671b2d1d4c71a46f8bfee3e7636656265ab",
      "false_comparisons": [
        "reference_missing_debt_supply",
        "reference_missing_share_supply",
        "transition_supply_required"
      ]
    },
    "accounting-bypass": {
      "exit": 1,
      "fixture_sha256": "163d50fe812d4b49f0345382ea9274a4446817cdcb88c05914a02a8ad6fc53a8",
      "false_comparisons": [
        "reference_unbalanced",
        "reference_wrong_asset_accounting",
        "transition_mismatched_supply",
        "transition_unbalanced",
        "transition_wrong_asset_accounting"
      ]
    },
    "write-bypass": {
      "exit": 1,
      "fixture_sha256": "180adfa870d2c4fcd9550da2a95ab9c8d354819b0e731c128c4a468a50988a2d",
      "false_comparisons": [
        "reference_missing_write",
        "transition_missing_write"
      ]
    },
    "registry-selection": {
      "exit": 1,
      "fixture_sha256": "6cc153b7abdedae17247936a11716ee78c441295f5137f0605d88c30011c5db1",
      "false_comparisons": [
        "reference_borrow_capabilities_preserved",
        "reference_borrow_full_post",
        "reference_collateral_boundary_accept",
        "reference_collateral_exceeded",
        "reference_deposit_capabilities_preserved",
        "reference_deposit_full_post",
        "reference_deposit_insufficient",
        "reference_fractional_deposit",
        "reference_missing_debt_supply",
        "reference_missing_guard_env_read",
        "reference_missing_guard_state_read",
        "reference_missing_share_supply",
        "reference_negative_borrow",
        "reference_negative_deposit",
        "reference_negative_withdraw",
        "reference_oracle_age_boundary_accept",
        "reference_oracle_future",
        "reference_oracle_missing",
        "reference_oracle_negative",
        "reference_oracle_negative_independent",
        "reference_oracle_positive_zero_exposure",
        "reference_oracle_stale",
        "reference_oracle_wrong_dimension",
        "reference_oracle_wrong_feed",
        "reference_oracle_zero",
        "reference_oracle_zero_independent",
        "reference_pool_illiquid",
        "reference_unknown_operation",
        "reference_withdraw_capabilities_preserved",
        "reference_withdraw_full_post",
        "reference_withdraw_insufficient",
        "reference_wrong_argument_dimension",
        "reference_wrong_operation_capabilities",
        "reference_zero_borrow",
        "reference_zero_deposit",
        "reference_zero_divisor",
        "reference_zero_withdraw",
        "transition_unknown_operation"
      ]
    },
    "zero-division-bypass": {
      "exit": 1,
      "fixture_sha256": "aadc4eda18d5f67dc87f0106841353b415b310c14ad0cac7525e2a8147781fae",
      "false_comparisons": [
        "expr_zero_scalar_division_refused",
        "transition_false_guard_failing_effect_precedence"
      ]
    },
    "inactive-state-read-omission": {
      "exit": 1,
      "fixture_sha256": "3a9518c9e6cdad47716b4a91d74214e538bc2f293e2c5bd4751d1d3a3e613642",
      "false_comparisons": [
        "expr_inactive_state_branch_tracked",
        "transition_inactive_read_missing",
        "transition_supply_only_read_missing"
      ]
    },
    "supply-first-only": {
      "exit": 1,
      "fixture_sha256": "0caa3c84d979c6ce4dad9c63d842a1261a1e68497e57f31632b968c626d1e2bd",
      "false_comparisons": [
        "transition_repeated_supply_sum"
      ]
    },
    "oracle-freshness-bypass": {
      "exit": 1,
      "fixture_sha256": "7bd38000606d02bdd56b608680091016e60f145208365f148735a446c349aefc",
      "false_comparisons": [
        "reference_oracle_stale"
      ]
    },
    "oracle-future-bypass": {
      "exit": 1,
      "fixture_sha256": "68f931928042dbc8255fd7b5efc7a503358362d520ea6873c216e5283b800ac5",
      "false_comparisons": [
        "reference_oracle_future"
      ]
    },
    "oracle-positive-price-bypass": {
      "exit": 1,
      "fixture_sha256": "4f18f789f112035ffbd1d56c11eed391f480532b3696a3bf14196e8c8ab2bb70",
      "false_comparisons": [
        "reference_oracle_negative_independent",
        "reference_oracle_zero_independent"
      ]
    },
    "collateral-factor-weakened": {
      "exit": 1,
      "fixture_sha256": "7b9c4570097486dc7b2d4c4835b7d669d8c47c6ff555c1f10cec5f24d37f6e49",
      "false_comparisons": [
        "reference_collateral_exceeded"
      ]
    }
  },
  "sources": {
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/ExprTests.lean": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "lean/DefiKernel/Typed/TransitionTests.lean": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "script_sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
  "spec_sha256": "be5083e3292646426cc7a4ebd556421e363fd43aa856ddea5263c9d534c4c8eb"
}


===== recorded evidence mutation-spec.json =====
{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Typed.Types",
    "DefiKernel.Typed.Expr",
    "DefiKernel.Typed.Authority",
    "DefiKernel.Typed.Transition",
    "DefiKernel.Typed.ExprTests",
    "DefiKernel.Typed.AuthorityTests",
    "DefiKernel.Typed.TransitionTests",
    "DefiKernel.Typed.Examples",
    "DefiKernel.Typed.Acceptance",
    "DefiKernel.Typed.Audit"
  ],
  "mutations": [
    {
      "name": "admin-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "decide (ctx.domain = domain \u2227 ctx.principal = config.domainAdmin domain)",
      "replacement": "true",
      "required_false": [
        "authority_unauthorized_issuer",
        "authority_unauthorized_revoker"
      ]
    },
    {
      "name": "holder-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "cap.holder = ctx.principal \u2227",
      "replacement": "True \u2227",
      "required_false": [
        "authority_wrong_holder",
        "transition_wrong_cap_holder"
      ]
    },
    {
      "name": "live-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "cap.live = true \u2227 cap.holder",
      "replacement": "True \u2227 cap.holder",
      "required_false": [
        "authority_same_request_after_revoke",
        "transition_revoked_debit"
      ]
    },
    {
      "name": "cap-domain-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "cap.domain = ctx.domain \u2227",
      "replacement": "True \u2227",
      "required_false": [
        "authority_wrong_authenticated_domain"
      ]
    },
    {
      "name": "cap-operation-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "cap.operation = operation \u2227",
      "replacement": "True \u2227",
      "required_false": [
        "authority_wrong_operation"
      ]
    },
    {
      "name": "cap-resource-bypass",
      "module": "DefiKernel.Typed.Authority",
      "needle": "cap.right = right \u2227",
      "replacement": "True \u2227",
      "required_false": [
        "authority_wrong_debit_owner",
        "authority_wrong_debit_asset",
        "authority_right_kind_mismatch"
      ]
    },
    {
      "name": "revoke-noop",
      "module": "DefiKernel.Typed.Authority",
      "needle": "{ cap with live := false }",
      "replacement": "{ cap with live := true }",
      "required_false": [
        "authority_revoke_accepted",
        "authority_old_revoked_id_remains_unusable",
        "transition_revoked_debit"
      ]
    },
    {
      "name": "invoke-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "if !hasAuthority store request.capabilityIds ctx request.operation .invoke then",
      "replacement": "if false then",
      "required_false": [
        "transition_invoke_required",
        "transition_wrong_cap_holder"
      ]
    },
    {
      "name": "guard-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "if !e.guard then .error .guard",
      "replacement": "if false then .error .guard",
      "required_false": [
        "transition_guard_false"
      ]
    },
    {
      "name": "state-read-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.stateReadsOK then",
      "replacement": "else if false then",
      "required_false": [
        "transition_guard_read_missing",
        "transition_effect_read_missing",
        "transition_supply_only_read_missing",
        "transition_inactive_read_missing"
      ]
    },
    {
      "name": "env-read-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.envReadsOK then",
      "replacement": "else if false then",
      "required_false": [
        "transition_env_read_missing"
      ]
    },
    {
      "name": "domain-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.domainOK ctx.domain then",
      "replacement": "else if false then",
      "required_false": [
        "transition_foreign_state_read"
      ]
    },
    {
      "name": "debit-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.debitsOK store request ctx then",
      "replacement": "else if false then",
      "required_false": [
        "transition_debit_required",
        "transition_revoked_debit"
      ]
    },
    {
      "name": "supply-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.suppliesOK store request ctx then",
      "replacement": "else if false then",
      "required_false": [
        "transition_supply_required"
      ]
    },
    {
      "name": "accounting-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "if !e.accountingOK then",
      "replacement": "if false then",
      "required_false": [
        "transition_unbalanced",
        "transition_mismatched_supply",
        "transition_wrong_asset_accounting"
      ]
    },
    {
      "name": "write-bypass",
      "module": "DefiKernel.Typed.Transition",
      "needle": "else if !e.writesOK then",
      "replacement": "else if false then",
      "required_false": [
        "transition_missing_write"
      ]
    },
    {
      "name": "registry-selection",
      "module": "DefiKernel.Typed.Transition",
      "needle": "let template \u2190 match registry request.operation with",
      "replacement": "let template \u2190 match registry \u27e80\u27e9 with",
      "required_false": [
        "transition_unknown_operation"
      ]
    },
    {
      "name": "zero-division-bypass",
      "module": "DefiKernel.Typed.Expr",
      "needle": "if y = 0 then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))",
      "replacement": "if false then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))",
      "required_false": [
        "expr_zero_scalar_division_refused"
      ]
    },
    {
      "name": "inactive-state-read-omission",
      "module": "DefiKernel.Typed.Expr",
      "needle": "condition.stateReads ++ yes.stateReads ++ no.stateReads",
      "replacement": "condition.stateReads ++ yes.stateReads",
      "required_false": [
        "expr_inactive_state_branch_tracked",
        "transition_inactive_read_missing",
        "transition_supply_only_read_missing"
      ]
    },
    {
      "name": "supply-first-only",
      "module": "DefiKernel.Typed.Transition",
      "needle": "(evaluated.supplies.map (fun d \u21a6 if d.1 = (domain, asset) then d.2 else 0)).sum",
      "replacement": "((evaluated.supplies.take 1).map (fun d \u21a6 if d.1 = (domain, asset) then d.2 else 0)).sum",
      "required_false": [
        "transition_repeated_supply_sum"
      ]
    },
    {
      "name": "oracle-freshness-bypass",
      "module": "DefiKernel.Typed.Examples",
      "needle": ".binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp priceKey) (.lit 5))",
      "replacement": ".lit true",
      "required_false": [
        "reference_oracle_stale"
      ]
    },
    {
      "name": "oracle-future-bypass",
      "module": "DefiKernel.Typed.Examples",
      "needle": ".binary (.le .scalar) (.timestamp priceKey) .now",
      "replacement": ".lit true",
      "required_false": [
        "reference_oracle_future"
      ]
    },
    {
      "name": "oracle-positive-price-bypass",
      "module": "DefiKernel.Typed.Examples",
      "needle": ".binary (.lt (.price Asset.collateral Asset.usd)) (.lit 0) collateralPrice",
      "replacement": ".lit true",
      "required_false": [
        "reference_oracle_zero_independent",
        "reference_oracle_negative_independent"
      ]
    },
    {
      "name": "collateral-factor-weakened",
      "module": "DefiKernel.Typed.Examples",
      "needle": "(.binary (.scale (.amount Asset.usd)) (.lit 2) debtValue) collateralValue",
      "replacement": "(.binary (.scale (.amount Asset.usd)) (.lit 1) debtValue) collateralValue",
      "required_false": [
        "reference_collateral_exceeded"
      ]
    }
  ],
  "positive_checks": [
    "expr_exact_price_conversion",
    "authority_issue_succeeds_with_id_zero",
    "transition_transfer_exact"
  ]
}


===== recorded evidence build-verification.json =====
{
  "source_revision": "3a44e4ea57003a93df74f112bf1b9243b2938e24",
  "sources": {
    "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/ExprTests.lean": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/TransitionTests.lean": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
    "lean/DefiKernel.lean": "0ff4580a1bf16942c351d170d5322f7e9c65790dc5cd1978282b40b5268835c2",
    "scripts/check_typed_kernel_mutations.py": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
    "scripts/check_typed_kernel_typing.py": "98392920c32379721b56aee8ddb57313e5ef87fee76f76bf4c4c077cf74e2edc",
    "scripts/test_typed_kernel_mutation_runner.py": "fa82c057ec746a28ffa3eb4be907823f39c81def38261e7db55068b3f50a4f06"
  },
  "input_sources_unchanged": true,
  "runs": [
    {
      "label": "final-build",
      "command": [
        "lake",
        "build"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "seconds": 18.33,
      "log_sha256": "61e837919f1bbc6d7f3fbb89b49ddd8c60e41c1587278e23d1d7e8c4171e2dae"
    },
    {
      "label": "final-runtime",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "seconds": 1.747,
      "log_sha256": "19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"
    },
    {
      "label": "final-axioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "seconds": 4.502,
      "log_sha256": "0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"
    },
    {
      "label": "final-legacy-axioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/VerifyAxioms.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "seconds": 4.476,
      "log_sha256": "4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"
    }
  ]
}


===== recorded evidence typing/results.json =====
{
  "script_sha256": "98392920c32379721b56aee8ddb57313e5ef87fee76f76bf4c4c077cf74e2edc",
  "sources": {
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"
  },
  "runs": {
    "positive": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-final/positive.lean"
      ],
      "exit": 0,
      "fixture_sha256": "8d95cce34f1284e5c2c8738d19a5420c817ea1bce797b2fff9fbaedf3d9803d9",
      "log_sha256": "0cfef97bedf053589888697fd2c37f8fbe8d614aaa3f01545d7ef5f29e7e8c4e"
    },
    "mixed-assets": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-final/mixed-assets.lean"
      ],
      "exit": 1,
      "fixture_sha256": "b673901f3e58e781085d4205c464f975d00464a2762b96867ae4196c238ae031",
      "log_sha256": "849c698c6f39ffbf15a8c651d77229a874fbc1a9d0900b431db649f6caae7629"
    },
    "reversed-price": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-final/reversed-price.lean"
      ],
      "exit": 1,
      "fixture_sha256": "8234c91c69c89f689b3f8fbcb295d98d4b4d89f59fea2c893bc39851cfe5e616",
      "log_sha256": "2d26004e186e57264d3ec0bff47f0c4db63d61f9641ac77e7b6c2e68b1022e03"
    },
    "implicit-debt-conversion": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-final/implicit-debt-conversion.lean"
      ],
      "exit": 1,
      "fixture_sha256": "33bc7d8d5aeb997b541cfd472dcb28414071acc40bd7ccab1b0b6a1db4b89aea",
      "log_sha256": "28ea43f9600ce3ad803e3d81637b94e0e91e4b88d5afa1748fb8d01890a86017"
    }
  },
  "git_head": "3a44e4ea57003a93df74f112bf1b9243b2938e24",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "input_sources_unchanged": true,
  "scope": "One executed positive and three compiler-rejected unit mismatches; no financial counterexample claim."
}


===== recorded evidence preservation.json =====
{
  "base": "77462b61f5f537eb29b2cf162ead6567e7151ace",
  "candidate": "1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f",
  "original_tracked_file_count": 1358,
  "changed_original_paths": [
    "docs/research/semantic-kernel-progress.md",
    "lean/DefiKernel.lean"
  ],
  "allowed_original_edits": [
    "docs/research/semantic-kernel-progress.md",
    "lean/DefiKernel.lean"
  ],
  "all_other_original_tracked_files_unchanged": true,
  "scope": "Git comparison against Sprint4 base includes working-tree tracked edits; no historical theorem/corpus files changed."
}


===== actual CLI control evidence (selected fields) =====
{
  "schema_version": 1,
  "kind": "executed-cli-runner-controls",
  "started_utc": "2026-09-07T02:29:23.786342+00:00",
  "finished_utc": "2026-09-07T02:29:48.817241+00:00",
  "source_repo": "/home/charl/defiformal",
  "git_head": "3a44e4ea57003a93df74f112bf1b9243b2938e24",
  "runner_source": "/home/charl/defiformal/scripts/check_typed_kernel_mutations.py",
  "runner_sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
  "harness_source": "/home/charl/defiformal/scripts/test_typed_kernel_mutation_runner.py",
  "harness_sha256": "fa82c057ec746a28ffa3eb4be907823f39c81def38261e7db55068b3f50a4f06",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "python_version": "3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]",
  "tool_identity_commands": [
    {
      "label": "lean-version",
      "command": [
        "lake",
        "env",
        "lean",
        "--version"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
    },
    {
      "label": "lean-path",
      "command": [
        "lake",
        "env",
        "which",
        "lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
    },
    {
      "label": "git-head",
      "command": [
        "git",
        "rev-parse",
        "HEAD"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "5322b1f0599f27d0a7b40a170d6153cf5bba9a46dd365b9c34f40b98a92206db"
    },
    {
      "label": "git-directory",
      "command": [
        "git",
        "rev-parse",
        "--absolute-git-dir"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "07cd7854ce1d7fea37db47ecd2aa29e04a70b5a1c932391cf15b3bb0d6b41173"
    }
  ],
  "fixture_scope": "Synthetic development Lean computations; actual CLI and installed Lean/mathlib. No subprocess mocks; no production theorem claim.",
  "fixture_input_sha256": "00c3f29a8e0c2d42079eb0ea14456b3123cf4005ba5825198a2510a1bf40e929",
  "fixture_audit_template_sha256": "a3650a4d0e049a899e61bd241a75539e2f33061d7ea67683534d6aec1e7253eb",
  "total": 15,
  "passed": 15,
  "additional_regression_evidence": {
    "old_runner_sha256": "8e535deb655695b4f4cdb0ff73d847c732d77855c9172cb4588ef7ddc8833f64",
    "command": [
      "python3",
      "/tmp/defiformal-sprint4-runner-error-regression/runner-before-tagged-error-fix.py",
      "--repo",
      "/tmp/defiformal-sprint4-runner-error-regression/fixture-repo",
      "--spec",
      "/tmp/defiformal-sprint4-runner-controls-mixed-error/compiler-error-with-runtime-failure-spec.json",
      "--out",
      "/tmp/defiformal-sprint4-runner-error-regression/old-run"
    ],
    "exit": 0,
    "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
    "kind": "observed-pre-fix-classifier-failure",
    "description": "Pre-fix runner accepted a tagged Lean compiler error when the same mutant also emitted its required runtime comparison failure. Parent expanded compiler-error recognition to include error(tag) diagnostics.",
    "old_source_reconstruction": "A temporary copy reverted only the diagnostic filter. Its SHA256 exactly matched the previous tested runner bytes; the live runner was not edited by the control author.",
    "old_diagnostic_filter": "': error:' in line",
    "new_diagnostic_filter": "re.search(r': error(?:\\([^)]*\\))?:', line)",
    "probe_log": "/tmp/defiformal-sprint4-runner-error-regression/old-run/probe.lean:7:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`\nrunner_positive: true\nrunner_sensitivity: false\n/tmp/defiformal-sprint4-runner-error-regression/old-run/probe.lean:18:0: error: Typed runtime comparisons failed: 1\n",
    "probe_log_sha256": "2de3b6b0ee13a5076a323f891242fb2b67652d29a9d78cf70f7f5524938e6d07",
    "old_source_path": "/tmp/defiformal-sprint4-runner-error-regression/runner-before-tagged-error-fix.py",
    "fixed_case": "compiler-error-with-runtime-failure",
    "fixed_expected_exit": 3,
    "fixed_actual_exit": 3
  },
  "intermediate_blocked_run": {
    "path": "/tmp/defiformal-sprint4-runner-controls-mixed-error",
    "exit": 3,
    "reason": "Runner source changed during controls while the parent applied the tagged-error fix. This run was superseded by the final unchanged-source 15/15 run."
  },
  "harness_invocation": {
    "command": [
      "python3",
      "/home/charl/defiformal/scripts/test_typed_kernel_mutation_runner.py",
      "--out",
      "/tmp/defiformal-sprint4-runner-controls-final-15"
    ],
    "cwd": "/home/charl",
    "exit": 0
  },
  "resolved_findings": [
    {
      "finding": "required_false labels were not checked against the unchanged observation inventory",
      "evidence": "Code inspection followed by parent fix; final missing-required-observation CLI control observes BLOCKED3. No pre-fix execution claim.",
      "parent_fix": "Validate each required label against control observation keys before mutants run."
    },
    {
      "finding": "Tagged Lean compiler errors were ignored by the error filter",
      "evidence": "Actual pre-fix byte-matched CLI returns 0 for combined compiler/runtime failure; final fixed runner returns 3. See additional_regression_evidence.",
      "parent_fix": "Recognize both error: and error(tag): diagnostics."
    }
  ],
  "cases": [
    {
      "name": "live-discriminating-mutant",
      "expected_exit": 0,
      "actual_exit": 0,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint4-runner-controls-final-15/runs/live-discriminating-mutant/probe.lean:17:0: error: Typed runtime comparisons failed: 1"
          ],
          "log_sha256": "2797cab0496e656de819060688aee195810bcd7a5b1908fb244325487c74bafc"
        }
      }
    },
    {
      "name": "all-true-mutant",
      "expected_exit": 1,
      "actual_exit": 1,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: all comparisons still pass under mutation\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      }
    },
    {
      "name": "compilation-only-failure",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint4-runner-controls-final-15/runs/compilation-only-failure/probe.lean:8:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`"
          ],
          "log_sha256": "986cdb4ff1a100a181c7e4c990e406a7f8a4117d8dca9b4581e56a8f4af0c352"
        }
      }
    },
    {
      "name": "compiler-error-with-runtime-failure",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint4-runner-controls-final-15/runs/compiler-error-with-runtime-failure/probe.lean:7:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`",
            "/tmp/defiformal-sprint4-runner-controls-final-15/runs/compiler-error-with-runtime-failure/probe.lean:18:0: error: Typed runtime comparisons failed: 1"
          ],
          "log_sha256": "5d62d18682b52e3de96a3006e58722699f5b4154176ac0ce9faececf93206c11"
        }
      }
    },
    {
      "name": "empty-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "lean_observations": {
        "control": {
          "lines": [],
          "errors": [],
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
      }
    },
    {
      "name": "duplicate-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "641cc4bc3b894387e2dfab29ebeaca6646c337e912c0d89fced1e75d0864839c"
        }
      }
    },
    {
      "name": "missing-positive-observation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: missing positive controls\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "f1686d9b5d9174cd8c12ad7952022571dab902d541e6f3de5a0e5ef9a17f1302"
        }
      }
    },
    {
      "name": "missing-required-observation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: probe: missing required observation in control\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      }
    },
    {
      "name": "partial-mutant-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: partial execution\n",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "bc6e74ae5ad02a8118ad7c0d5f482af8085a7229355f13d6173f86d60683772d"
        }
      }
    },
    {
      "name": "no-op-mutation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: mutation must actually change the source\n",
      "lean_observations": {}
    },
    {
      "name": "missing-mutation-needle",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n",
      "lean_observations": {}
    },
    {
      "name": "missing-source-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint4-runner-controls-final-15/fixture-repo/lean/DefiKernel/Typed/RunnerInput.lean'\n",
      "lean_observations": {}
    },
    {
      "name": "missing-manifest-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint4-runner-controls-final-15/fixture-repo/lean/lake-manifest.json'\n",
      "lean_observations": {}
    },
    {
      "name": "existing-output-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: output already exists\n",
      "lean_observations": {}
    },
    {
      "name": "empty-mutation-inventory",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: empty mutation inventory\n",
      "lean_observations": {}
    }
  ]
}

===== actual axiom scope and summary =====
AXIOM AUDIT scope: imported module prefix DefiKernel.Typed; modules=[DefiKernel.Typed.Types,
 DefiKernel.Typed.Expr,
 DefiKernel.Typed.ExprTests,
 DefiKernel.Typed.Authority,
 DefiKernel.Typed.AuthorityTests,
 DefiKernel.Typed.Transition,
 DefiKernel.Typed.TransitionTests,
 DefiKernel.Typed.Examples,
 DefiKernel.Typed.Acceptance,
 DefiKernel.Typed.Audit]
AXIOM AUDIT DECLARATIONS PASSED: 978/978 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 524/524 theorems; forbidden=0