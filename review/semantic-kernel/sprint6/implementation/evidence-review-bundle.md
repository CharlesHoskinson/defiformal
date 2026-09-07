You are an independent native evidence reviewer. Reply directly with a complete plain Markdown verdict ACCEPT, ACCEPT WITH LIMITATIONS, or REQUEST CHANGES and concrete severity-tagged findings (about1200words). Tools are disabled for this request; do not emit tool markup, requests or unfinished narration. Do not claim independent execution. No Foreman.

Review the FINAL Sprint6 mutation runner, actual production results, fail-closed controls, historical regressions, axiom-audit implementation and source/tool/Git bindings. Source candidate fae07caa2620c7a1d4ba1a39cb9a9be171ff137d. Lean is byte-identical to candidate7cb4807d1ff22c5ac804b03feb4a2530c46146f2, already acceptedwithlimitations by both native Grok4.6 and Fable5.1 in separate substantive Lean audits. This is the remaining evidence audit; it does not replace those proof reviews.

Final production14/14detected, control131/131true, eachmutant131completecomparisons andfiveprotectedpositives. FinalCLIcontrols45/45:5acceptedtoy runs,4expectedexit1failures,36expectedexit3blocks. Verify counts against actualedits/results, including whether peer-history mutant genuinely causes a fundedUSD5transfer rather than only an outputlistdifference. Replays cover the SAME14mutants, not additional independentdetections. Proof suffixes are stripped ONLY from newParallel scratchprobes; acceptedsource retainsproofs. Bounded mutation sensitivity is not proof/holdout/deployedfidelity.

First productionattempt was BLOCKED because malformed-label guard caught legitimate Lean Hint:/Note: diagnosticcontinuations. It contributes zeroacceptedmutations. Finalparser narrowly exempts knownprefixes; a realcompilerwarningpositive was added beside malformeduppercase-refusal controls. Assess maskedcompilererrors, empty/duplicate/unknown/partialinventories, unapplied/nonunique/noop edits, survivors, protectedpositive failures, stale.olean dependence andsource/spec/runnerdrift.

Historicalall7commands pass at7cb4807,106scopedtrackedGitinputs unchanged: typed24mutants,composition12mutants,composition36runnercontrols,typed17runnercontrols,99axiomassertions,1positive+3expectedtypeerrors,20corpus tests/76realCLIcalls. Finalfae07ca onlyadds3newrunner/specfiles. All10integratedLeancommands pass: Parallel131runtime,388theorems+419supplementalaxiomchecks forbidden0.126explicit theorems=88generic+35referenceinstances+3counterexamples, plus262generated; do not countgenerateddeclarations as independentresults.

Explicitly address earlier Fable evidence-visibility findings: separate administrativeissue/revoke compilercontrols existed but were omittedfromtheLeanbundle; their positiveandactualtypeerror logs are suppliedhere. ActualAxiomAudit.lean source is alsohere. Check composites: requiredStateReads ANDdeclaredstateReads removed bymutant2; sharedtargetlist removedfrom BOTHwrites andreads bymutant4. Keep limits: admission-gatedserialreferences; LocalPreservation quantifies over invariant-satisfying worlds/StepSoundtransitions; trustedboundary/environment/store and deployedfidelity remainassumptions. No finaldelivery/archive has yetbeenclaimed.


### SOURCE scripts/check_parallel_mutations.py
SHA256 415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0
```
#!/usr/bin/env python3
"""Replay the actual parallel Lean implementation under explicit source mutations.

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


CHECK_NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def check(value, message):
    if not value:
        raise AssertionError(message)


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
    parser.add_argument('--repo', type=Path, required=True)
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
    require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                for name in positives), 'invalid positive check name')
    require('DefiKernel.Parallel.Audit' in modules, 'missing Parallel audit root')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] not in {'control', 'lean-version', 'lean-path', 'git-head',
                                  'git-root-input-status'}, 'reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
        require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                    for name in m['required_false']), 'invalid required check name')
        require(len(set(m['required_false'])) == len(m['required_false']),
                'duplicate required check')
    # Discover and inline every local import, including split Parallel modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'DefiKernel\.[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
                f'invalid scoped module: {module}')
        require(module not in visiting, f'cyclic local dependency: {module}')
        if module in ordered:
            return
        visiting.add(module)
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        raw = read(path)
        blobs[relative] = raw
        for line in raw.decode().splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported.startswith('DefiKernel.'):
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    script_sha256 = sha(read(Path(__file__)))
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Parallel.'):
            source, suffix = source.split(marker)
            closure = re.search(r'\n(end DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
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
                if imported not in ordered and line not in imports:
                    require(not imported.startswith('DefiKernel.'),
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
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
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
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Parallel proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Parallel.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(rf'^({CHECK_NAME}): (true|false)$', log, re.MULTILINE)
        # Lean's unused-variable diagnostics contain standalone Hint:/Note:
        # continuation lines. These exact diagnostic prefixes are not observations.
        diagnostic_prefixes = ('Hint: The binding can be removed (if unused) or named ',
                               'Note: This linter can be disabled with ')
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[A-Za-z0-9_.-]+:', line)
                      and not line.startswith(diagnostic_prefixes)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
    require(manifest['sources_after'] == sources, 'input sources changed during replay')
    require(sha(read(args.spec)) == sha(spec_raw), 'specification changed during replay')
    require(sha(read(Path(__file__))) == script_sha256, 'runner changed during replay')
    manifest['input_sources_unchanged'] = True
    manifest['specification_unchanged'] = True
    manifest['runner_unchanged'] = True
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

```

### SOURCE scripts/test_parallel_mutation_runner.py
SHA256 14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79
```
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


INPUT_MODULE = 'DefiKernel.Parallel.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Parallel.Audit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Typed
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Typed
'''
INPUT = '''import DefiKernel.Typed.RunnerDependency

namespace DefiKernel.Parallel

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Parallel
'''
AUDIT = '''import DefiKernel.Parallel.RunnerInput

namespace DefiKernel.Parallel

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Parallel runtime comparisons failed: {failures}"

end DefiKernel.Parallel
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
        {'name': 'dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.sensitivity'])),
                  'positive_checks': ['runner.positive']},
         'checks': CHECKS.replace('runner_positive', 'runner.positive').replace(
             'runner_sensitivity', 'runner.sensitivity'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'hyphenated-dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.expected-failure'])),
                  'positive_checks': ['runner.permitted-sibling']},
         'checks': CHECKS.replace('runner_positive', 'runner.permitted-sibling').replace(
             'runner_sensitivity', 'runner.expected-failure'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-dot-segment-spec', 'exit': 3,
         'spec': specification(mutation(required=['runner..sensitivity'])),
         'message': 'invalid required check name'},
        {'name': 'trailing-dot-spec', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner.']},
         'message': 'invalid positive check name'},
        {'name': 'leading-dot-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println ".runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'empty-dot-segment-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner..bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unused-variable-warning', 'exit': 0,
         'spec': specification(mutation(replacement='true')),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'uppercase-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "Runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unknown-mutant-observation', 'exit': 3,
         'extra_audit': '  if runnerAllows 5 then\n'
                        '    liftIO <| IO.println "runner_unknown: true"\n',
         'message': 'probe: partial execution'},
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
        {'name': 'reserved-mutation-name', 'exit': 3,
         'spec': specification({**mutation(), 'name': 'lean-version'}),
         'message': 'reserved variant name'},
        {'name': 'empty-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': []}, 'message': 'empty module inventory'},
        {'name': 'empty-positive-inventory', 'exit': 3,
         'spec': {**specification(), 'positive_checks': []}, 'message': 'empty positive-control inventory'},
        {'name': 'duplicate-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, INPUT_MODULE, AUDIT_MODULE]},
         'message': 'duplicate source module'},
        {'name': 'duplicate-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': [mutation(), mutation()]}, 'message': 'duplicate mutation name'},
        {'name': 'duplicate-positive-check', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner_positive', 'runner_positive']},
         'message': 'duplicate positive control'},
        {'name': 'duplicate-required-check', 'exit': 3,
         'spec': specification(mutation(required=['runner_sensitivity', 'runner_sensitivity'])),
         'message': 'duplicate required check'},
        {'name': 'nonunique-mutation-needle', 'exit': 3,
         'spec': specification(mutation('def ', 'private def ')), 'message': 'mutation did not apply exactly once'},
        {'name': 'malformed-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner_bad: truth"\n', 'message': 'malformed observation'},
        {'name': 'malformed-json', 'exit': 3, 'raw_spec': '{', 'message': 'JSONDecodeError'},
        {'name': 'duplicate-json-key', 'exit': 3,
         'raw_spec': '{"schema_version": 1, "schema_version": 1}', 'message': 'duplicate JSON key'},
        {'name': 'output-inside-repository', 'exit': 3, 'inside_output': True,
         'message': 'evidence output must be outside the repository'},
        {'name': 'output-symlink', 'exit': 3, 'symlink_output': True, 'message': 'output already exists'},
        {'name': 'discovered-parallel-dependency', 'exit': 0, 'extra_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'fresh-dependency-source-failure', 'exit': 3, 'changed_dependency': True,
         'message': 'control compilation/execution failed'},
        {'name': 'missing-audit-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE]},
         'message': 'missing Parallel audit root'},
        {'name': 'foreign-module-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, AUDIT_MODULE,
                                              'DefiKernel.Composition.RunnerInput']},
         'message': 'invalid scoped module'},
        {'name': 'mutation-module-outside-inventory', 'exit': 3,
         'spec': specification({**mutation(), 'module': 'DefiKernel.Parallel.Absent'}),
         'message': 'mutation module outside inventory'},
        {'name': 'unchanged-control-failed', 'exit': 1,
         'checks': '[("runner_positive", true), ("runner_sensitivity", false)]',
         'message': 'unchanged control has failing comparisons'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_parallel_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    harness_before = sha(Path(__file__).read_bytes())
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
    typed = lean / 'DefiKernel/Parallel'
    typed.mkdir(parents=True)
    dependency = lean / 'DefiKernel/Typed/RunnerDependency.lean'
    dependency.parent.mkdir(parents=True)
    dependency.write_text(DEPENDENCY)
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
        dependency.write_text(DEPENDENCY)
        (lean / 'lake-manifest.json').write_bytes(manifest)
        setup_records = []
        (typed / 'RunnerInput.lean').write_text(INPUT)
        if case.get('extra_dependency'):
            extra = typed / 'SplitComputation.lean'
            extra.write_text('import DefiKernel.Typed.RunnerDependency\n'
                             'namespace DefiKernel.Parallel\n'
                             'def splitLimit : Nat := 4\n'
                             '-- BEGIN PROOFS\n'
                             'theorem splitLimit_value : splitLimit = 4 := rfl\n'
                             'end DefiKernel.Parallel\n')
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'import DefiKernel.Typed.RunnerDependency',
                'import DefiKernel.Parallel.SplitComputation').replace(
                    'n ≤ 4', 'n ≤ 4 + (splitLimit - 4)'))
        if case.get('changed_dependency'):
            # Compile the old source, then change only the .lean file. A fresh
            # source projection must see 5 and fail the importing = 4 example.
            olean = lean / '.lake/build/lib/lean/DefiKernel/Typed/RunnerDependency.olean'
            olean.parent.mkdir(parents=True, exist_ok=True)
            setup_command = ['lake', 'env', 'lean', '-o', str(olean), str(dependency)]
            setup = subprocess.run(setup_command, cwd=lean, text=True, capture_output=True, timeout=240)
            setup_log = setup.stdout + setup.stderr
            (out / 'stale-dependency-setup.log').write_text(setup_log)
            require(setup.returncode == 0 and olean.is_file(), 'stale dependency control setup failed')
            setup_records.append({'command': setup_command, 'cwd': str(lean),
                                  'exit': setup.returncode, 'log_sha256': sha(setup_log.encode()),
                                  'source_sha256': sha(dependency.read_bytes()),
                                  'olean_sha256': sha(olean.read_bytes())})
            dependency.write_text(DEPENDENCY.replace(':= 4', ':= 5').replace('= 4', '= 5'))
        (typed / 'Audit.lean').write_text(AUDIT.replace('CHECKS', case.get('checks', CHECKS)).replace(
            '  let failures :=', case.get('extra_audit', '') + '  let failures :='))
        (lean / 'lake-manifest.json').write_bytes(manifest)
        if case.get('missing_source'):
            (typed / 'RunnerInput.lean').unlink()
        if case.get('missing_manifest'):
            (lean / 'lake-manifest.json').unlink()
        spec = case.get('spec', specification())
        spec_path = out / (case['name'] + '-spec.json')
        spec_path.write_text(case.get('raw_spec', json.dumps(spec, indent=2) + '\n'))
        result_path = out / 'runs' / case['name']
        if case.get('inside_output'):
            result_path = fake / 'forbidden-output'
        if case.get('symlink_output'):
            result_path.parent.mkdir(parents=True, exist_ok=True)
            result_path.symlink_to(out / 'nonexistent-output', target_is_directory=True)
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
        if case['name'] in ('live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-parallel-dependency', 'unused-variable-warning'):
            measured = runtime.get('results', {})
            separator = '.' if case['name'] == 'dotted-comparisons' else '_'
            expected_positive = 'runner' + separator + 'positive'
            expected_sensitivity = 'runner' + separator + 'sensitivity'
            if case['name'] == 'hyphenated-dotted-comparisons':
                expected_positive, expected_sensitivity = 'runner.permitted-sibling', 'runner.expected-failure'
            matched = matched and measured.get('control', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'true'}
            matched = matched and measured.get('probe', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'false'}
        if case['name'] == 'unused-variable-warning':
            warning_log = result_path / 'probe.log'
            warning = warning_log.read_text() if warning_log.exists() else ''
            matched = matched and 'warning: Variable name `n` is not explicitly referenced.' in warning
            matched = matched and 'Hint: The binding can be removed' in warning
            matched = matched and 'Note: This linter can be disabled with ' in warning
        source_manifest = result_path / 'source-manifest.json'
        if case.get('extra_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'DefiKernel.Parallel.SplitComputation' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/DefiKernel/Parallel/SplitComputation.lean') == sha(extra.read_bytes())
            matched = matched and captured.get('input_sources_unchanged') is True
        observations = {}
        for variant in ('control', 'probe'):
            variant_log = result_path / (variant + '.log')
            if variant_log.exists():
                raw = variant_log.read_text()
                observations[variant] = {
                    'lines': re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', raw, re.MULTILINE),
                    'errors': [line for line in raw.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)],
                    'log_sha256': sha(raw.encode())}
        record = {'name': case['name'], 'command': command, 'cwd': str(repo),
                  'expected_exit': case['exit'], 'actual_exit': proc.returncode,
                  'expected_message': case['message'], 'passed': matched,
                  'elapsed_seconds': round(elapsed, 6), 'log': str(log_path),
                  'log_sha256': sha(log.encode()), 'cli_output': log,
                  'spec_sha256': sha(spec_path.read_bytes()), 'setup_records': setup_records,
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    require(harness_before == sha(Path(__file__).read_bytes()), 'harness changed during controls')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': harness_before,
               'lean_version': lean_version, 'lean_executable_sha256': sha(lean_path.read_bytes()),
               'python_version': sys.version, 'tool_identity_commands': identity,
               'fixture_scope': 'Synthetic development Lean computations; actual CLI and installed '
                                'Lean/mathlib. No subprocess mocks; no production theorem claim.',
               'fixture_dependency_sha256': sha(DEPENDENCY.encode()),
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

```

### SOURCE review/semantic-kernel/sprint6/mutation-spec.json
SHA256 5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35
```
{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Parallel.Compatibility",
    "DefiKernel.Parallel.Observation",
    "DefiKernel.Parallel.Execution",
    "DefiKernel.Parallel.Preservation",
    "DefiKernel.Parallel.Audit"
  ],
  "mutations": [
    {
      "name": "bypass-write-write-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "  match firstOverlap left.writes right.writes with\n  | some c => .error (.conflict .writeWrite c)\n  | none => match firstOverlap left.writes right.reads with\n    | some c => .error (.conflict .leftWriteRightRead c)\n    | none => match firstOverlap right.writes left.reads with\n      | some c => .error (.conflict .rightWriteLeftRead c)\n      | none => .ok ⟨⟩",
      "replacement": "  .ok ⟨⟩",
      "required_false": [
        "parallel.compat.write-write-witness"
      ]
    },
    {
      "name": "omit-expression-reads-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "(template.requiredStateReads ++ template.stateReads)",
      "replacement": "([] : List (PackedCellRef P A D))",
      "required_false": [
        "parallel.compat.hidden-inactive-guard",
        "parallel.compat.hidden-delta",
        "parallel.compat.hidden-supply"
      ]
    },
    {
      "name": "omit-output-dependency",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "reads ++ writes ++ iface.outputs.map OutputPort.cell",
      "replacement": "reads ++ writes",
      "required_false": [
        "parallel.compat.output-dependency"
      ]
    },
    {
      "name": "omit-zero-delta-target",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "(template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))",
      "replacement": "template.writes",
      "required_false": [
        "parallel.compat.zero-target",
        "parallel.compat.zero-target-exact"
      ]
    },
    {
      "name": "omit-reverse-conflict",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "firstOverlap right.writes left.reads",
      "replacement": "firstOverlap ([] : List (Cell P A D)) left.reads",
      "required_false": [
        "parallel.compat.reverse-read"
      ]
    },
    {
      "name": "cancel-peer-after-refusal",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial (if l.failure.isSome then [] else right)",
      "required_false": [
        "parallel.fixture.refusal.peer-runs"
      ]
    },
    {
      "name": "rollback-refused-prefix-at-join",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "mergeWorld leftFootprint rightFootprint initial l.world r.world",
      "replacement": "mergeWorld leftFootprint rightFootprint initial (if l.failure.isSome then initial else l.world) r.world",
      "required_false": [
        "parallel.fixture.refusal.prefix-kept"
      ]
    },
    {
      "name": "replace-merge-with-left-world",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c\n      else if c ∈ rightFootprint.writes then right.state.balance c\n      else initial.state.balance c,\n    fun c ↦ by\n      split\n      · exact left.state.nonneg c\n      · split\n        · exact right.state.nonneg c\n        · exact initial.state.nonneg c⟩,\n    initial.capabilities⟩",
      "replacement": "  left",
      "required_false": [
        "parallel.fixture.basic.complete"
      ]
    },
    {
      "name": "double-initial-balances",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c\n      else if c ∈ rightFootprint.writes then right.state.balance c\n      else initial.state.balance c,\n    fun c ↦ by\n      split\n      · exact left.state.nonneg c\n      · split\n        · exact right.state.nonneg c\n        · exact initial.state.nonneg c⟩,\n    initial.capabilities⟩",
      "replacement": "  ⟨⟨fun c ↦ left.state.balance c + right.state.balance c,\n    fun c ↦ add_nonneg (left.state.nonneg c) (right.state.nonneg c)⟩,\n    initial.capabilities⟩",
      "required_false": [
        "parallel.fixture.basic.complete"
      ]
    },
    {
      "name": "leak-peer-output-history",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let r := runBranch cfg (boundaries .right) initial right\n    let l := continueRun cfg (boundaries .left)\n      { (startCursor cfg initial) with outputs := r.outputs } (left.map Step.invoke)",
      "required_false": [
        "parallel.fixture.routing.peer-only"
      ]
    },
    {
      "name": "reuse-left-trusted-boundary",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .left) initial right",
      "required_false": [
        "parallel.fixture.boundary.local-identity"
      ]
    },
    {
      "name": "drop-peer-supply-receipts",
      "module": "DefiKernel.Parallel.Preservation",
      "needle": "traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset",
      "replacement": "traceSupply joined.left.events domain asset",
      "required_false": [
        "parallel.fixture.supply.both-receipts"
      ]
    },
    {
      "name": "reuse-live-capability-store",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let stale : World P A D := { initial with capabilities :=\n      ⟨initial.capabilities.entries.map (fun cap ↦ { cap with live := true })⟩ }\n    let r := runBranch cfg (boundaries .right) stale right",
      "required_false": [
        "parallel.fixture.capability.revoked"
      ]
    },
    {
      "name": "stale-intra-branch-evaluation",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "Composition.run cfg boundary initial (branch.map Step.invoke)",
      "replacement": "(branch.map Step.invoke).foldl\n    (fun cursor step ↦ advance cfg boundary { cursor with world := initial } step)\n    (startCursor cfg initial)",
      "required_false": [
        "parallel.fixture.stateful.prefix"
      ]
    }
  ],
  "positive_checks": [
    "parallel.compat.catalog-positive",
    "parallel.compat.funded-left-complete",
    "parallel.compat.funded-right-complete",
    "parallel.compat.zero-target-funded",
    "parallel.compat.hidden-inactive-guard-funded"
  ]
}

```

### SOURCE lean/DefiKernel/AxiomAudit.lean
SHA256 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524
```
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit

```

### SOURCE lean/DefiKernel/Parallel/Audit.lean
SHA256 d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9
```
import DefiKernel.Parallel.CompatibilityTests
import DefiKernel.Parallel.ObservationTests
import DefiKernel.Parallel.ExecutionTests
import DefiKernel.Parallel.Tests

/-! Complete named runtime inventory. Source mutation projections execute this same driver. -/
namespace DefiKernel.Parallel

def runtimeChecks : List (String × Bool) :=
  CompatibilityTests.checks ++ ObservationTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty parallel runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate parallel runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Parallel runtime comparisons failed: {failed}")

end DefiKernel.Parallel

```

### SOURCE lean/DefiKernel/Parallel/Compatibility.lean
SHA256 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243
```
import DefiKernel.Composition.Execution

/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel

```

### SOURCE lean/DefiKernel/Parallel/Execution.lean
SHA256 a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089
```
import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Observation

/-! Binary fork/join over invocation-only branches. Each branch retains its own successful
prefix and refusal. Serial references rerun the existing executor with fresh local histories. -/
namespace DefiKernel.Parallel
open Typed Composition

structure Joined (P A D : Type) where
  world : World P A D
  left : Cursor P A D
  right : Cursor P A D

inductive Result (P A D : Type) where
  | refused (reason : AdmissionFailure P A D) (world : World P A D)
  | executed (joined : Joined P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- An admitted region chooses one complete balance, never a sum of branch base balances. -/
def mergeWorld (leftFootprint rightFootprint : Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c
      else if c ∈ rightFootprint.writes then right.state.balance c
      else initial.state.balance c,
    fun c ↦ by
      split
      · exact left.state.nonneg c
      · split
        · exact right.state.nonneg c
        · exact initial.state.nonneg c⟩,
    initial.capabilities⟩

def runBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) : Cursor P A D :=
  Composition.run cfg boundary initial (branch.map Step.invoke)

def runParallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok (leftFootprint, rightFootprint) =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    .executed ⟨mergeWorld leftFootprint rightFootprint initial l.world r.world, l, r⟩

/-- Right always runs after left's retained prefix, including when left has refused. -/
def runSerialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) l.world right
    .executed ⟨r.world, l, r⟩

/-- Evaluation order changes; branch labels, local history and trusted positions do not. -/
def runSerialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let r := runBranch cfg (boundaries .right) initial right
    let l := runBranch cfg (boundaries .left) r.world left
    .executed ⟨l.world, l, r⟩

/-- Pointwise full-ledger equality plus exact capability-store equality. -/
def WorldEquivalent (left right : World P A D) : Prop :=
  (∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities

/-- Raw event worlds are omitted, but every financial and local refusal observation is kept. -/
def ObservationallyEquivalent (left right : Result P A D) : Prop :=
  match left, right with
  | .refused le lw, .refused re rw => le = re ∧ WorldEquivalent lw rw
  | .executed l, .executed r => WorldEquivalent l.world r.world ∧
      observeBranch l.left = observeBranch r.left ∧
      observeBranch l.right = observeBranch r.right
  | _, _ => False

def worldEq (left right : World P A D) : Bool :=
  decide ((∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities)

def observationsEqual (left right : Result P A D) : Bool :=
  match left, right with
  | .refused le lw, .refused re rw => decide (le = re) && worldEq lw rw
  | .executed l, .executed r => worldEq l.world r.world &&
      decide (observeBranch l.left = observeBranch r.left) &&
      decide (observeBranch l.right = observeBranch r.right)
  | _, _ => false

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_store (lf rf : Footprint P A D) (initial left right : World P A D) :
    (mergeWorld lf rf initial left right).capabilities = initial.capabilities := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_nonnegative (lf rf : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ (mergeWorld lf rf initial left right).state.balance c :=
  (mergeWorld lf rf initial left right).state.nonneg c

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_outside (lf rf : Footprint P A D) (initial left right : World P A D)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (mergeWorld lf rf initial left right).state.balance c = initial.state.balance c := by
  simp [mergeWorld, hl, hr]

theorem worldEq_iff (left right : World P A D) :
    worldEq left right = true ↔ WorldEquivalent left right := by simp [worldEq, WorldEquivalent]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ ObservationallyEquivalent left right := by
  cases left <;> cases right <;>
    simp [observationsEqual, ObservationallyEquivalent, worldEq, WorldEquivalent, and_assoc]

theorem runParallel_refuses (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (reason : AdmissionFailure P A D)
    (h : admit cfg boundaries left right = .error reason) :
    runParallel cfg boundaries initial left right = .refused reason initial := by
  simp [runParallel, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.refl (world : World P A D) : WorldEquivalent world world :=
  ⟨fun _ ↦ rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.symm {left right : World P A D} (h : WorldEquivalent left right) :
    WorldEquivalent right left := ⟨fun c ↦ (h.1 c).symm, h.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.trans {first middle last : World P A D}
    (h : WorldEquivalent first middle) (g : WorldEquivalent middle last) :
    WorldEquivalent first last := ⟨fun c ↦ (h.1 c).trans (g.1 c), h.2.trans g.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.refl (result : Result P A D) :
    ObservationallyEquivalent result result := by
  cases result with
  | refused reason world => exact ⟨rfl, .refl world⟩
  | executed joined => exact ⟨.refl joined.world, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.symm {left right : Result P A D}
    (h : ObservationallyEquivalent left right) : ObservationallyEquivalent right left := by
  cases left <;> cases right
  · exact ⟨h.1.symm, h.2.symm⟩
  · exact h.elim
  · exact h.elim
  · exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.trans {first middle last : Result P A D}
    (h : ObservationallyEquivalent first middle) (g : ObservationallyEquivalent middle last) :
    ObservationallyEquivalent first last := by
  cases first <;> cases middle <;> cases last
  · exact ⟨h.1.trans g.1, h.2.trans g.2⟩
  · exact g.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact g.elim
  · exact ⟨h.1.trans g.1, h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

end DefiKernel.Parallel

```

### SOURCE lean/DefiKernel/Parallel/Preservation.lean
SHA256 faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10
```
import DefiKernel.Parallel.Commutation
import DefiKernel.Composition.Preservation

/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset

-- BEGIN PROOFS

theorem mergeWorld_balance_sum (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (c : Cell P A D) :
    (mergeWorld lf rf initial left right).state.balance c =
      left.state.balance c + right.state.balance c - initial.state.balance c := by
  by_cases hcl : c ∈ lf.writes
  · simp [mergeWorld, hcl, hr c (hd c hcl)]
  · by_cases hcr : c ∈ rf.writes
    · simp [mergeWorld, hcl, hcr, hl c hcl]
    · simp [mergeWorld, hcl, hcr, hl c hcl, hr c hcr]

theorem mergeWorld_accounting (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (d : D) (a : A) :
    total (mergeWorld lf rf initial left right).state d a =
      total left.state d a + total right.state d a - total initial.state d a := by
  simp only [total, mergeWorld_balance_sum lf rf initial left right hd hl hr,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]

theorem runBranch_accounting (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (d : D) (a : A) :
    total (runBranch cfg boundary initial branch).world.state d a =
      total initial.state d a + traceSupply (runBranch cfg boundary initial branch).events d a :=
  run_accounting cfg boundary initial (branch.map Step.invoke) d a

/-- Actual successful receipt supplies from both independent runs determine joined accounting. -/
theorem runParallel_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf)) (d : D) (a : A) :
    total (mergeWorld lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state d a =
      total initial.state d a +
        traceSupply (runBranch cfg (boundaries .left) initial left).events d a +
        traceSupply (runBranch cfg (boundaries .right) initial right).events d a := by
  obtain ⟨hv, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf hadmit
  rw [mergeWorld_accounting lf rf initial _ _ hc.1
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1]
  rw [runBranch_accounting, runBranch_accounting]
  linarith

theorem runBranch_events_invoke (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv ∈ branch, event.step = .invoke inv := by
  obtain ⟨accepted, remaining, hs, he⟩ :=
    run_order cfg boundary initial (branch.map Step.invoke)
  intro event hm
  have hstep : event.step ∈ accepted := he ▸ List.mem_map.mpr ⟨event, hm, rfl⟩
  have hall : event.step ∈ branch.map Step.invoke := by
    rw [hs]
    exact List.mem_append_left _ hstep
  obtain ⟨inv, hi, hh⟩ := List.mem_map.mp hall
  exact ⟨inv, hi, hh.symm⟩

theorem trace_invoke_stores {cfg : Config P A D} {boundary : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundary initial events final history index)
    (hi : ∀ event ∈ events, ∃ inv, event.step = .invoke inv) :
    final.capabilities = initial.capabilities ∧
      ∀ event ∈ events, event.before.capabilities = initial.capabilities ∧
        event.result.world.capabilities = initial.capabilities := by
  induction h with
  | nil => exact ⟨rfl, by simp⟩
  | @snoc events pre history index previous step result sound ih =>
    obtain ⟨hp, he⟩ := ih (by
      intro event hm
      exact hi event (List.mem_append_left _ hm))
    obtain ⟨inv, hstep⟩ := hi ⟨index, step, pre, result⟩ (by simp)
    change step = .invoke inv at hstep
    have hcap : result.world.capabilities = pre.capabilities := by
      rw [hstep] at sound
      exact sound.invoke_preserves_capabilities
    refine ⟨hcap.trans hp, ?_⟩
    intro event hm
    rcases List.mem_append.mp hm with hm | hm
    · exact he event hm
    · have eq := List.mem_singleton.mp hm
      subst event
      exact ⟨hp, hcap.trans hp⟩

/-- Every successful invocation uses authority from the initial fixed store, including prefixes
whose later invocation refuses. The actual local boundary remains attached to each event. -/
theorem runBranch_authority (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ReceiptAuthorized initial (boundary event.index) event.result.receipt := by
  have ht := run_trace_sound cfg boundary initial (branch.map Step.invoke)
  have hi : ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv, event.step = .invoke inv := by
    intro event hm
    obtain ⟨inv, _, he⟩ := runBranch_events_invoke cfg boundary initial branch event hm
    exact ⟨inv, he⟩
  have hs := trace_invoke_stores ht hi
  intro event hm
  have ha := ht.authority event hm
  have hc := (hs.2 event hm).1
  cases hr : event.result.receipt <;> simp only [hr, ReceiptAuthorized] at ha ⊢
  simpa only [hc] using ha

theorem runBranch_prefix_nonnegative (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c :=
  run_prefix_nonnegative cfg boundary initial (branch.map Step.invoke)

/-- The join frames every predicate whose explicit support avoids both write regions. -/
theorem mergeWorld_supported_frame (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate (mergeWorld lf rf initial left right).state := by
  apply supported_frame support
  intro c hc
  exact (mergeWorld_outside lf rf initial left right c
    (untouched c hc).1 (untouched c hc).2).symm

theorem mergeWorld_agrees_left (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ rf.writes) :
    AgreeOn region left.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ lf.writes
  · simp [mergeWorld, hw]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_agrees_right (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ lf.writes) :
    AgreeOn region right.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ rf.writes
  · simp [mergeWorld, hw, peer c hc]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_two_invariants (lf rf : Footprint P A D)
    (initial left right : World P A D) (ls rs : Set (Cell P A D))
    (lp rp : State P A D → Prop) (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp left.state) (ri : rp right.state) :
    lp (mergeWorld lf rf initial left right).state ∧
      rp (mergeWorld lf rf initial left right).state :=
  ⟨(supported_frame lSupport (mergeWorld_agrees_left lf rf initial left right ls hl lpeer)).mp li,
    (supported_frame rSupport (mergeWorld_agrees_right lf rf initial left right rs hr rpeer)).mp ri⟩

/-- Non-circular initialized induction obligations for a branch's own ledger predicate. -/
def LocalPreservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (predicate : State P A D → Prop) : Prop :=
  ∀ n outputs step pre result, StepSound cfg (boundary n) n outputs step pre result →
    predicate pre.state → predicate result.world.state

theorem runBranch_invariant (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (predicate : State P A D → Prop)
    (initialized : predicate initial.state) (preserves : LocalPreservation cfg boundary predicate) :
    predicate (runBranch cfg boundary initial branch).world.state :=
  (run_trace_sound cfg boundary initial (branch.map Step.invoke)).invariant
    (fun w ↦ predicate w.state) initialized preserves

theorem evaluated_supplies_empty (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (hn : template.supplyDeltas = []) (he : template.evaluate ctx = .ok e) :
    e.supplies = [] := by
  unfold Template.evaluate at he
  rw [hn] at he
  simp only [List.mapM_nil, bind, Except.bind, pure, Except.pure] at he
  repeat' first | split at he | contradiction
  cases he
  rfl

theorem extractReceipt_supplies_empty (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) (e : Evaluated P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (he : extractReceipt cfg boundary request pre = .ok e) : e.supplies = [] := by
  unfold extractReceipt at he
  cases hs : cfg.registry request.operation with
  | none => simp [hs, bind, Except.bind] at he
  | some template =>
    simp only [hs, bind, Except.bind] at he
    cases ha : Args.check template.signature request.arguments with
    | error reason => simp [ha, Except.mapError] at he
    | ok args =>
      simp only [ha, Except.mapError, bind, Except.bind] at he
      cases hv : template.evaluate
          ⟨pre.state, boundary.env, boundary.ctx.principal, request.parties, args, boundary.now⟩
          <;> simp only [hv, Except.mapError] at he
      · contradiction
      · cases he
        exact evaluated_supplies_empty template _ _ (hn _ _ hs) hv

theorem step_no_supply {cfg : Config P A D} {boundary : Boundary P A D}
    {n : Nat} {outputs : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (hs : StepSound cfg boundary n outputs step pre result) (d : D) (a : A) :
    result.receipt.supply d a = 0 := by
  cases hs with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have he := extractReceipt_supplies_empty cfg boundary request pre e hn extracted
    simp [Receipt.supply, Evaluated.supply, he]
  | issue => rfl
  | revoke => rfl

theorem local_total_preservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (d : D) (a : A) (amount : ℚ) :
    LocalPreservation cfg boundary (fun s ↦ total s d a = amount) := by
  intro n outputs step pre result hs hi
  rw [hs.accounting d a, step_no_supply hn hs d a, add_zero]
  exact hi

theorem supports_total (d : D) (a : A) (predicate : ℚ → Prop) :
    Supports {c : Cell P A D | c.1 = d ∧ c.2.2 = a}
      (fun s ↦ predicate (total s d a)) := by
  intro pre post h
  have ht : total pre d a = total post d a := by
    apply Finset.sum_congr rfl
    intro party hp
    exact h (d, party, a) ⟨rfl, rfl⟩
  change predicate (total pre d a) ↔ predicate (total post d a)
  rw [ht]

/-- Both branch invariants are initialized and preserved individually before supported join. -/
theorem runParallel_two_invariants (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state ∧
    rp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state := by
  obtain ⟨_, hl, hr, _⟩ := admit_ok cfg boundaries left right lf rf hadmit
  exact mergeWorld_two_invariants lf rf initial _ _ ls rs lp rp lSupport rSupport
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1 lpeer rpeer
    (runBranch_invariant cfg (boundaries .left) initial left lp li lPreserves)
    (runBranch_invariant cfg (boundaries .right) initial right rp ri rPreserves)

/-- Accounting binds the public executed result to both of its actual receipt sequences. -/
theorem runParallel_executed_accounting (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) (d : D) (a : A) :
    total joined.world.state d a = total initial.state d a + joined.supply d a := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    simpa only [Joined.supply, add_assoc] using
      runParallel_accounting cfg boundaries initial left right lf rf hadmit d a

theorem runParallel_executed_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundaries .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundaries .right event.index) event.result.receipt) := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    exact ⟨runBranch_authority cfg (boundaries .left) initial left,
      runBranch_authority cfg (boundaries .right) initial right⟩

theorem runParallel_executed_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, c ∉ lf.writes → c ∉ rf.writes →
      joined.world.state.balance c = initial.state.balance c) ∧
      joined.world.capabilities = initial.capabilities := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact ⟨mergeWorld_outside lf rf initial _ _, rfl⟩

theorem runParallel_executed_nonnegative (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, 0 ≤ joined.world.state.balance c) ∧
    (∀ event ∈ joined.left.events ++ joined.right.events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c) := by
  exact ⟨joined.world.state.nonneg,
    fun event _ c ↦ ⟨event.before.state.nonneg c, event.result.world.state.nonneg c⟩⟩

theorem runParallel_executed_supported_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate joined.world.state := by
  apply supported_frame support
  intro c hc
  exact ((runParallel_executed_frame cfg boundaries initial left right lf rf joined hadmit hx).1
    c (untouched c hc).1 (untouched c hc).2).symm

theorem runParallel_executed_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp joined.world.state ∧ rp joined.world.state := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact runParallel_two_invariants cfg boundaries initial left right lf rf hadmit
    ls rs lp rp lSupport rSupport lpeer rpeer li ri lPreserves rPreserves

end DefiKernel.Parallel

```

### SOURCE lean/DefiKernel/Parallel/Examples.lean
SHA256 d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd
```
import DefiKernel.Parallel.Execution
import DefiKernel.Typed.Examples

/-! Independent financial fixtures for binary parallel composition. Expected receipts and complete
ledger tables are written directly, without evaluating templates or selecting executor results. -/
namespace DefiKernel.Parallel.Examples
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev I := Invocation Party Asset Domain
abbrev B := Branch Party Asset Domain
abbrev Evt := EventObservation Party Asset Domain
abbrev Obs := BranchObservation Party Asset Domain
abbrev R := Parallel.Result Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultUSD : C := (.main, .vault, .usd)
def poolUSD : C := (.main, .pool, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def protectedCell : C := (.main, .alice, .collateral)
def cells : List C := [Domain.main, .other].flatMap fun d ↦
  [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩

/-- Both numerical ports are zero, but their components differ. The provider grants exact
access to every cell so access checks cannot mask the intended compatibility controls. -/
def config (lt rt : Op) (lo ro : List C := []) : Config Party Asset Domain where
  registry id := if id = ⟨10⟩ then some lt else if id = ⟨11⟩ then some rt else none
  domainAdmin := domainAdmin
  catalog := [
    ⟨⟨0⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨10⟩, lt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        lo.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨1⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨11⟩, rt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        ro.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨2⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

def transferTemplate (a : Asset) (sender recipient : PartyRef Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, ref a sender, negate a (.arg .here)⟩,
    ⟨a, ref a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a sender, packedRef a recipient]
def usdTransfer := transferTemplate .usd (.literal .alice) (.literal .bob)
def shareTransfer := transferTemplate .share (.literal .vault) (.literal .alice)
def peerUSDTransfer := transferTemplate .usd (.literal .vault) (.literal .pool)
def cfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def sameAssetCfg := config usdTransfer peerUSDTransfer [bobUSD] [poolUSD]

def store : Store := ⟨[
  ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .debit bobUSD⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit vaultUSD⟩, true⟩]⟩
def caps : List CapabilityId := (List.range 12).map CapabilityId.mk

def balanceTable (au bu vs ash : ℚ) (vu : ℚ := 20) (pu : ℚ := 1) : C → ℚ := fun c ↦
  if c = aliceUSD then au else if c = bobUSD then bu else if c = vaultShare then vs
  else if c = aliceShare then ash else if c = vaultUSD then vu else if c = poolUSD then pu
  else if c = protectedCell then 9 else 0

def initial : W := ⟨⟨balanceTable 10 0 20 0, by
  intro c
  simp only [balanceTable]
  repeat' split
  all_goals decide⟩, store⟩
def boundaries (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩

def invoke (component op : Nat) (a : Asset) (q : ℚ) : I :=
  ⟨⟨component⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], caps, none⟩
def usd (q : ℚ) := invoke 0 10 .usd q
def shares (q : ℚ) := invoke 1 11 .share q
def peerUSD (q : ℚ) := invoke 1 11 .usd q

def source (inv : I) (component : Nat) : I :=
  { inv with inputs := [.priorOutput 0 ⟨⟨component⟩, ⟨0⟩⟩] }

def output (index component : Nat) (a : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨0⟩⟩, ⟨.amount a, q⟩⟩

def evaluatedTransfer (sender recipient : C) (q : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [(sender, -q), (recipient, q)], [], [], [], [], [], [sender, recipient]⟩
def event (index : Nat) (inv : I) (args : List (PackedValue Asset))
    (evaluated : Evaluated Party Asset Domain) (outputs : List (OutputObservation Asset)) : Evt :=
  ⟨index, .invoke inv,
    .invoked ⟨inv.operation, inv.parties, args, inv.capabilityIds, inv.claimedActor⟩ evaluated,
    outputs⟩
def transferEvent (index : Nat) (inv : I) (sender recipient : C) (q : ℚ)
    (outputs : List (OutputObservation Asset)) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩] (evaluatedTransfer sender recipient q) outputs

def observed (events : List Evt)
    (failure : Option (LocatedFailure Party Asset Domain) := none) : Obs :=
  ⟨events, events.flatMap EventObservation.outputs, events.length, failure⟩
def failure (index : Nat) (inv : I) (reason : Composition.Failure) :
    Option (LocatedFailure Party Asset Domain) := some ⟨index, some (.invoke inv), reason⟩
def leftEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (usd q) aliceUSD bobUSD q [output index 0 .usd after]
def rightEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (shares q) vaultShare aliceShare q [output index 1 .share after]
def peerEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (peerUSD q) vaultUSD poolUSD q [output index 1 .usd after]

def matchesExpected (actual : R) (balance : C → ℚ) (expectedLeft expectedRight : Obs)
    (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed result =>
    decide ((∀ c, result.world.state.balance c = balance c) ∧
      result.world.capabilities = expectedStore ∧
      result.left.world.capabilities = expectedStore ∧
      result.right.world.capabilities = expectedStore ∧
      observeBranch result.left = expectedLeft ∧ observeBranch result.right = expectedRight)

def basicLeft : Obs := observed [leftEvent 0 3 3]
def basicRight : Obs := observed [rightEvent 0 4 4]

def supplyTemplate (a : Asset) (owner : Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal owner), .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal owner)]
def supplyCfg := config (supplyTemplate .usd .alice) (supplyTemplate .share .vault)
  [aliceUSD] [vaultShare]
def supplyEvent (index : Nat) (inv : I) (cell : C) (q post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, q⟩]
    ⟨true, [(cell, q)], [((cell.1, cell.2.2), q)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]

def statefulTransfer : Op := { usdTransfer with
  guard := .binary (.le (.amount .usd)) (.lit 4) (.balance (cellRef aliceUSD))
  deltas := [⟨.usd, cellRef aliceUSD, .binary (.scale (.amount Asset.usd))
    (.lit (-1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩,
    ⟨.usd, cellRef bobUSD, .binary (.scale (.amount Asset.usd))
      (.lit (1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def statefulCfg := config statefulTransfer shareTransfer [bobUSD] [aliceShare]
def statefulEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (usd 0) [⟨.amount .usd, 0⟩]
    { evaluatedTransfer aliceUSD bobUSD amount with
      requiredStateReads := [aliceUSD, aliceUSD, aliceUSD]
      declaredStateReads := [aliceUSD] }
    [output index 0 .usd post]

/-- State-dependent mint amount appears independently in both delta and supply evaluation. -/
def statefulSupply : Op := { supplyTemplate .share .vault with
  deltas := [⟨.share, cellRef vaultShare,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  supplyDeltas := [⟨.main, .share,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  stateReads := [packed vaultShare] }
def statefulSupplyEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (shares 0) [⟨.amount .share, 0⟩]
    ⟨true, [(vaultShare, amount)], [((.main, .share), amount)],
      [vaultShare, vaultShare], [], [vaultShare], [], [vaultShare]⟩
    [output index 1 .share post]

/-- Temporal values constrain the trusted invocation boundary; they do not set a price. -/
def timedTemplate (a : Asset) : Op where
  signature := [.amount a, .scalar]
  domain := .main
  partyArity := 1
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨a, ref a .caller, negate a (.arg .here)⟩,
    ⟨a, ref a (.argument 0), .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedRef a .caller, packedRef a (.argument 0)]
def timedCfg := config (timedTemplate .usd) (timedTemplate .share) [bobUSD] [aliceShare]
def timedBoundaries (branch : BranchId) (index : Nat) : Boundary Party Asset Domain :=
  match branch with
  | .left => ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100 + index⟩
  | .right => ⟨⟨.vault, .main⟩, fresh, 200 + index⟩
def timedInvocation (component op : Nat) (a : Asset) (q time : ℚ) (recipient : Party) : I :=
  ⟨⟨component⟩, ⟨op⟩, [recipient],
    [.literal ⟨.amount a, q⟩, .literal ⟨.scalar, time⟩], caps, none⟩
def timedLeft : B := [timedInvocation 0 10 .usd 3 100 .bob,
  timedInvocation 0 10 .usd 1 101 .alice]
def timedRight : B := [timedInvocation 1 11 .share 4 200 .alice,
  timedInvocation 1 11 .share 2 201 .alice]
def timedEvent (index : Nat) (inv : I) (sender recipient : C) (q time post : ℚ) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩, ⟨.scalar, time⟩]
    { evaluatedTransfer sender recipient q with
      requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] }
    [output index inv.component.value sender.2.2 post]
def timedExpectedLeft := observed [
  timedEvent 0 (timedInvocation 0 10 .usd 3 100 .bob) aliceUSD bobUSD 3 100 3,
  timedEvent 1 (timedInvocation 0 10 .usd 1 101 .alice) bobUSD aliceUSD 1 101 2]
def timedExpectedRight := observed [
  timedEvent 0 (timedInvocation 1 11 .share 4 200 .alice) vaultShare aliceShare 4 200 4,
  timedEvent 1 (timedInvocation 1 11 .share 2 201 .alice) vaultShare aliceShare 2 201 6]


def noOp : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []
def noOpInvocation : I := { usd 0 with inputs := [] }
def noOpEvaluated : Evaluated Party Asset Domain := ⟨true, [], [], [], [], [], [], []⟩
def sharedReadCfg := config noOp noOp [protectedCell] []
def sharedReadExpected := observed [event 0 noOpInvocation [] noOpEvaluated
  [output 0 0 .collateral 9]]
def paramTemplate : Op := { transferTemplate .usd (.argument 0) (.argument 1) with
  partyArity := 2 }
def reusableCfg := config paramTemplate shareTransfer

def revokedStore : Store := ⟨store.entries.set 2 ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, false⟩⟩
def revokedInitial : W := ⟨initial.state, revokedStore⟩

def cancelling : Op := { noOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 1⟩, ⟨.usd, cellRef aliceUSD, .lit (-1)⟩] }
def cancellingInvocation : I := { shares 0 with inputs := [] }
def cancellingExpected : Obs := observed [event 0 cancellingInvocation []
  ⟨true, [(aliceUSD, 1), (aliceUSD, -1)], [], [], [], [], [], []⟩ []]

end DefiKernel.Parallel.Examples

```

### SOURCE lean/DefiKernel/Parallel/Tests.lean
SHA256 626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725
```
import DefiKernel.Parallel.Examples
import DefiKernel.Parallel.Preservation

/-! Named bounded comparisons against direct complete ledger, capability, receipt and output
expectations. Equality between implementations is supplementary to the independent oracles. -/
namespace DefiKernel.Parallel.Tests
open Typed Composition Typed.Examples Parallel.Examples

def basic := runParallel cfg boundaries initial [usd 3] [shares 4]
def peerRuns := runParallel cfg boundaries initial [usd 11] [shares 4]
def prefixKept := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4]
def dualRefusal := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
def routingForeign := source (usd 0) 1
def routingOwn := source (usd 0) 0
def routingRightOwn := source (shares 0) 1

def routeExpected (consumer : I) (q finalBob : ℚ) : Obs := observed [leftEvent 0 3 3,
  transferEvent 1 consumer aliceUSD bobUSD q [output 1 0 .usd finalBob]]
def rightRouteExpected : Obs := observed [rightEvent 0 4 4,
  transferEvent 1 routingRightOwn vaultShare aliceShare 4 [output 1 1 .share 8]]
def routeForeignExpected : Obs := observed [leftEvent 0 3 3]
  (failure 1 routingForeign (.interface .unavailableOutput))
def routeForeign := runParallel sameAssetCfg boundaries initial [usd 3, routingForeign] [peerUSD 4]

def supplyRun := runParallel supplyCfg boundaries initial [usd 2] [shares (-3)]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]
def statefulRun := runParallel statefulCfg boundaries initial [usd 0, usd 0, usd 0] [shares 4]
def statefulExpected := observed [statefulEvent 0 5 5, statefulEvent 1 (5 / 2) (15 / 2)]
  (failure 2 (usd 0) (.kernel .guard))
def stateSupplyCfg := config usdTransfer statefulSupply [bobUSD] [vaultShare]
def stateSupplyExpected := observed [statefulSupplyEvent 0 10 30, statefulSupplyEvent 1 15 45]

def admissionRefused (actual : R) (reason : AdmissionFailure Party Asset Domain)
    (expected : W := initial) : Bool :=
  match actual with
  | .refused actualReason actualWorld =>
    decide (actualReason = reason) && worldEq actualWorld expected
  | .executed _ => false

def serialChecks (label : String) (config : Config Party Asset Domain)
    (binding : ParallelBoundary Party Asset Domain) (world : W) (left right : B)
    (balance : C → ℚ) (expectedLeft expectedRight : Obs) (expectedStore : Store := store) :
    List (String × Bool) := [
  (label ++ ".lr.complete", matchesExpected (runSerialLR config binding world left right)
    balance expectedLeft expectedRight expectedStore),
  (label ++ ".rl.complete", matchesExpected (runSerialRL config binding world left right)
    balance expectedLeft expectedRight expectedStore)]

def checks : List (String × Bool) := [
  ("parallel.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("parallel.fixture.basic.complete", matchesExpected basic (balanceTable 7 3 16 4)
    basicLeft basicRight),
  ("parallel.fixture.same-asset.complete", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3] [peerUSD 4])
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5])),
  ("parallel.fixture.refusal.peer-runs", matchesExpected peerRuns (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.prefix-kept", matchesExpected prefixKept (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.dual", matchesExpected dualRefusal (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds)))),
  ("parallel.fixture.refusal.guard", matchesExpected
    (runParallel cfg boundaries initial [usd (-1)] [shares 4]) (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd (-1)) (.kernel .guard))) basicRight),
  ("parallel.fixture.refusal.input-unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    matchesExpected (runParallel cfg boundaries initial [wrong] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight),
  ("parallel.fixture.refusal.missing-capability", let missing := {usd 3 with capabilityIds := []}
    matchesExpected (runParallel cfg boundaries initial [missing] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight),
  ("parallel.fixture.empty.right", matchesExpected
    (runParallel cfg boundaries initial [usd 3] []) (balanceTable 7 3 20 0)
      basicLeft (observed [])),
  ("parallel.fixture.empty.left", matchesExpected
    (runParallel cfg boundaries initial [] [shares 4]) (balanceTable 10 0 16 4)
      (observed []) basicRight),
  ("parallel.fixture.empty.both", matchesExpected
    (runParallel cfg boundaries initial [] []) (balanceTable 10 0 20 0)
      (observed []) (observed [])),
  ("parallel.fixture.routing.peer-only", matchesExpected routeForeign
    (balanceTable 7 3 20 0 16 5) routeForeignExpected (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.funded-literal", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4])
    (balanceTable 2 8 20 0 16 5) (observed [leftEvent 0 3 3, leftEvent 1 5 8])
      (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.own-history", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, routingOwn] [peerUSD 4])
    (balanceTable 4 6 20 0 16 5) (routeExpected routingOwn 3 6) (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.both-own-history", matchesExpected
    (runParallel cfg boundaries initial [usd 3, routingOwn] [shares 4, routingRightOwn])
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected),
  ("parallel.fixture.routing.shared-qualified-key", matchesExpected
    (runParallel sharedReadCfg boundaries initial [noOpInvocation] [noOpInvocation])
    (balanceTable 10 0 20 0) sharedReadExpected sharedReadExpected),
  ("parallel.fixture.boundary.local-identity", matchesExpected
    (runParallel timedCfg timedBoundaries initial timedLeft timedRight)
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight),
  ("parallel.fixture.capability.revoked", matchesExpected
    (runParallel cfg boundaries revokedInitial [usd 3] [shares 4])
    (balanceTable 7 3 20 0) basicLeft
      (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore),
  ("parallel.fixture.capability.actual-revoke", decide
    (revokeCapability cfg.authority adminContext store ⟨2⟩ = .ok revokedStore)),
  ("parallel.fixture.capability.reusable-shared-grant",
    let l := {usd 3 with parties := [.alice, .bob]}
    let r := {usd 4 with parties := [.vault, .pool]}
    matchesExpected (runParallel reusableCfg boundaries initial [l] [r])
      (balanceTable 7 3 20 0 16 5)
      (observed [transferEvent 0 l aliceUSD bobUSD 3 []])
      (observed [transferEvent 0 r vaultUSD poolUSD 4 []])),
  ("parallel.fixture.supply.complete", matchesExpected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight),
  ("parallel.fixture.supply.both-receipts", match supplyRun with
    | .refused _ _ => false
    | .executed result => decide (∀ d a, result.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("parallel.fixture.supply.prefix-refusal", matchesExpected
    (runParallel supplyCfg boundaries initial [usd 2, usd (-13)] [shares (-3)])
    (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight),
  ("parallel.fixture.stateful.prefix", matchesExpected statefulRun
    (balanceTable (5 / 2) (15 / 2) 16 4)
    statefulExpected basicRight),
  ("parallel.fixture.stateful.supply", matchesExpected
    (runParallel stateSupplyCfg boundaries initial [usd 3] [shares 0, shares 0])
    (balanceTable 7 3 45 0) basicLeft stateSupplyExpected),
  ("parallel.fixture.cancelling.admission", admissionRefused
    (runParallel (config usdTransfer cancelling) boundaries initial [usd 3] [cancellingInvocation])
    (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.cancelling.funded", matchesExpected
    (runParallel (config usdTransfer cancelling) boundaries initial [] [cancellingInvocation])
    (balanceTable 10 0 20 0) (observed []) cancellingExpected),
  ("parallel.fixture.refusal.world-preserved", admissionRefused
    (runParallel cfg boundaries initial [usd 3] [usd 3]) (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.refusal.suffix-world-preserved", let unknown := {usd 0 with operation := ⟨99⟩}
    admissionRefused (runParallel cfg boundaries initial [usd 3, unknown] [shares 4])
      (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("parallel.fixture.raw-context-differs", match basic,
      runSerialLR cfg boundaries initial [usd 3] [shares 4] with
    | .executed p, .executed s =>
      observationsEqual basic (runSerialLR cfg boundaries initial [usd 3] [shares 4]) &&
      match p.right.events, s.right.events with
      | pe :: _, se :: _ => !worldEq pe.before se.before
      | _, _ => false
    | _, _ => false)
  ] ++
  serialChecks "parallel.fixture.basic" cfg boundaries initial [usd 3] [shares 4]
    (balanceTable 7 3 16 4) basicLeft basicRight ++
  serialChecks "parallel.fixture.prefix" cfg boundaries initial [usd 3, usd 8] [shares 4]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.routing" sameAssetCfg boundaries initial
    [usd 3, routingForeign] [peerUSD 4] (balanceTable 7 3 20 0 16 5)
    routeForeignExpected (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.boundary" timedCfg timedBoundaries initial timedLeft timedRight
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight ++
  serialChecks "parallel.fixture.supply" supplyCfg boundaries initial [usd 2] [shares (-3)]
    (balanceTable 12 0 17 0) supplyLeft supplyRight ++
  serialChecks "parallel.fixture.stateful" statefulCfg boundaries initial [usd 0, usd 0, usd 0]
    [shares 4] (balanceTable (5 / 2) (15 / 2) 16 4) statefulExpected basicRight ++
  serialChecks "parallel.fixture.revoked" cfg boundaries revokedInitial [usd 3] [shares 4]
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore ++
  serialChecks "parallel.fixture.same-asset" sameAssetCfg boundaries initial [usd 3] [peerUSD 4]
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.peer-runs" cfg boundaries initial [usd 11] [shares 4]
    (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.dual" cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds))) ++
  serialChecks "parallel.fixture.both-own-history" cfg boundaries initial
    [usd 3, routingOwn] [shares 4, routingRightOwn]
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected ++
  serialChecks "parallel.fixture.stateful-supply" stateSupplyCfg boundaries initial
    [usd 3] [shares 0, shares 0] (balanceTable 7 3 45 0) basicLeft stateSupplyExpected ++
  serialChecks "parallel.fixture.shared-qualified-key" sharedReadCfg boundaries initial
    [noOpInvocation] [noOpInvocation] (balanceTable 10 0 20 0)
    sharedReadExpected sharedReadExpected ++
  serialChecks "parallel.fixture.supply-prefix" supplyCfg boundaries initial
    [usd 2, usd (-13)] [shares (-3)] (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight

end DefiKernel.Parallel.Tests

```

### SOURCE lean/DefiKernel/Parallel/CompatibilityTests.lean
SHA256 d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379
```
import DefiKernel.Parallel.Compatibility
import DefiKernel.Composition.Examples

/-! Bounded admission controls with independently specified footprint lists and financial siblings.
These are development fixtures; generic proof obligations are in Compatibility. -/
namespace DefiKernel.Parallel.CompatibilityTests
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev F := Footprint Party Asset Domain
abbrev I := Invocation Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def common : C := (.main, .alice, .collateral)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩
def transferOp (a : Asset) (sender recipient : Party) (q : ℚ) : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal sender), .lit (-q)⟩,
    ⟨a, ref a (.literal recipient), .lit q⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal sender), packedRef a (.literal recipient)]
def usdOp := transferOp .usd .alice .bob 3
def shareOp := transferOp .share .vault .alice 4
def readOnly (c : C) : Op := { usdOp with
  guard := .binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c))
  deltas := [], writes := [], stateReads := [packed c] }
def hidden (t : Op) (c : C) : Op := { t with
  guard := .ite (.lit true) t.guard
    (.binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c)))
  stateReads := [packed c] }
def cfg (left : Op := usdOp) (right : Op := shareOp)
    (leftOutput : List C := []) (rightOutput : List C := []) : Config Party Asset Domain where
  registry op := if op = ⟨10⟩ then some left else if op = ⟨11⟩ then some right else none
  domainAdmin := domainAdmin
  catalog := [⟨⟨0⟩, ([Domain.main, .other].flatMap fun d ↦
    [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
      [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)), [], [],
    [⟨⟨10⟩, [], leftOutput.map (fun c ↦ ⟨⟨0⟩, c⟩)⟩,
     ⟨⟨11⟩, [], rightOutput.map (fun c ↦ ⟨⟨1⟩, c⟩)⟩]⟩]
def boundary (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩
def left : I := ⟨⟨0⟩, ⟨10⟩, [], [], [⟨0⟩, ⟨1⟩], none⟩
def right : I := ⟨⟨0⟩, ⟨11⟩, [], [], [⟨2⟩, ⟨3⟩], none⟩
def leftFP : F := ⟨[aliceUSD, bobUSD, aliceUSD, bobUSD],
  [aliceUSD, bobUSD, aliceUSD, bobUSD]⟩
def rightFP : F := ⟨[vaultShare, aliceShare, vaultShare, aliceShare],
  [vaultShare, aliceShare, vaultShare, aliceShare]⟩
def initial : World Party Asset Domain := ⟨⟨fun c ↦
  if c = aliceUSD then 10 else if c = vaultShare then 20 else 0,
  by
    intro c
    split
    · decide
    · split <;> decide⟩,
  ⟨[⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩]⟩⟩
def accepted {E X : Type} : Except E X → Bool
  | .ok _ => true
  | .error _ => false
def resultEq {E X : Type} [DecidableEq E] [DecidableEq X]
    (actual expected : Except E X) : Bool := decide (actual = expected)
def funded (config : Config Party Asset Domain) (inv : I) : Bool :=
  accepted (executeStep config (boundary .left 0) 0 [] (.invoke inv) initial)
def fundedExact (inv : I) (expected : C → ℚ) : Bool :=
  match executeStep cfg (boundary .left 0) 0 [] (.invoke inv) initial with
  | .error _ => false
  | .ok result => decide ((∀ c, result.world.state.balance c = expected c) ∧
      result.world.capabilities = initial.capabilities)
def overlap (kind : ConflictKind) (cell : C) :
    Except (AdmissionFailure Party Asset Domain) (F × F) :=
  .error (.conflict kind cell)
def zeroTarget : Op := { (readOnly common) with
  guard := .lit true
  stateReads := []
  deltas := [⟨.usd, cellRef aliceUSD, .lit 0⟩] }
def hiddenDelta : Op := { shareOp with
  deltas := shareOp.deltas.map (fun d ↦ { d with
    amount := .ite (.lit true) d.amount
      (.binary (.unconvert d.asset .usd) (.balance (cellRef aliceUSD)) (.lit 1)) })
  stateReads := [packed aliceUSD] }
def hiddenSupply : Op := { shareOp with
  supplyDeltas := [⟨.main, .usd,
    .ite (.lit true) (.lit 0) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def malformed : Op := { usdOp with stateReads := [packedRef .usd (.argument 3)] }
def deniedCfg : Config Party Asset Domain := { cfg with
  catalog := (cfg.catalog.map fun c ↦ { c with privateCells := [vaultShare, aliceShare] }) }
def checks : List (String × Bool) := [
  ("parallel.compat.catalog-positive", validateCatalog cfg.registry cfg.catalog),
  ("parallel.compat.invocation-exact-left", resultEq
    (analyzeInvocation cfg (boundary .left 0) left) (.ok leftFP)),
  ("parallel.compat.invocation-exact-right", resultEq
    (analyzeInvocation cfg (boundary .right 0) right) (.ok rightFP)),
  ("parallel.compat.funded-left-complete", fundedExact left
    (fun c ↦ if c = aliceUSD then 7 else if c = bobUSD then 3 else initial.state.balance c)),
  ("parallel.compat.funded-right-complete", fundedExact right
    (fun c ↦ if c = vaultShare then 16 else if c = aliceShare then 4 else initial.state.balance c)),
  ("parallel.compat.independent", resultEq (admit cfg boundary [left] [right])
    (.ok (leftFP, rightFP))),
  ("parallel.compat.empty", resultEq (admit cfg boundary [] []) (.ok (.empty, .empty))),
  ("parallel.compat.left-empty", resultEq (admit cfg boundary [] [right])
    (.ok (.empty, rightFP))),
  ("parallel.compat.common-read", accepted
    (admit (cfg (hidden usdOp common) (hidden shareOp common)) boundary [left] [right])),
  ("parallel.compat.write-write-witness", resultEq (admit cfg boundary [left] [left])
    (overlap .writeWrite aliceUSD)),
  ("parallel.compat.forward-read", resultEq
    (admit (cfg usdOp (readOnly aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.reverse-read", resultEq
    (admit (cfg (readOnly vaultShare) shareOp) boundary [left] [right])
    (overlap .rightWriteLeftRead vaultShare)),
  ("parallel.compat.hidden-inactive-guard", resultEq
    (admit (cfg usdOp (hidden shareOp aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-inactive-guard-funded",
    funded (cfg usdOp (hidden shareOp aliceUSD)) right),
  ("parallel.compat.hidden-delta", resultEq
    (admit (cfg usdOp hiddenDelta) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-delta-funded", funded (cfg usdOp hiddenDelta) right),
  ("parallel.compat.hidden-supply", resultEq
    (admit (cfg usdOp hiddenSupply) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-supply-funded", funded (cfg usdOp hiddenSupply) right),
  ("parallel.compat.output-dependency", resultEq
    (admit (cfg usdOp shareOp [] [aliceUSD]) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.output-exact", resultEq
    (analyzeInvocation (cfg usdOp shareOp [] [aliceUSD]) (boundary .right 0) right)
    (.ok ⟨rightFP.reads ++ [aliceUSD], rightFP.writes⟩)),
  ("parallel.compat.zero-target", resultEq
    (admit (cfg usdOp zeroTarget) boundary [left] [right]) (overlap .writeWrite aliceUSD)),
  ("parallel.compat.zero-target-funded", funded (cfg usdOp zeroTarget) right),
  ("parallel.compat.zero-target-exact", resultEq
    (analyzeInvocation (cfg usdOp zeroTarget) (boundary .right 0) right)
    (.ok ⟨[aliceUSD], [aliceUSD]⟩)),
  ("parallel.compat.unreachable-suffix", resultEq
    (admit cfg boundary [{left with capabilityIds := []}, right] [right])
    (overlap .writeWrite vaultShare)),
  ("parallel.compat.numeric-input-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.literal ⟨.amount .usd, -500⟩]}) (.ok leftFP)),
  ("parallel.compat.prior-output-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.priorOutput 9 ⟨⟨99⟩, ⟨99⟩⟩]}) (.ok leftFP)),
  ("parallel.compat.capability-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0) {left with capabilityIds := []}) (.ok leftFP)),
  ("parallel.compat.catalog-first", resultEq
    (admit {cfg with catalog := cfg.catalog ++ cfg.catalog} boundary
      [{left with operation := ⟨99⟩}] []) (.error .configuration)),
  ("parallel.compat.left-before-right", resultEq
    (admit cfg boundary [{left with operation := ⟨99⟩}] [{right with operation := ⟨98⟩}])
    (.error (.structural .left ⟨0, .interface .unknownOperation⟩))),
  ("parallel.compat.local-order", resultEq
    (admit cfg boundary [left, {left with operation := ⟨99⟩}, {left with operation := ⟨98⟩}] [])
    (.error (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.structural-before-conflict", resultEq
    (admit cfg boundary [left] [left, {right with operation := ⟨99⟩}])
    (.error (.structural .right ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.malformed-reference", resultEq
    (admit (cfg malformed shareOp) boundary [left] [right])
    (.error (.structural .left ⟨0, .interface (.resolution .partyArgument)⟩))),
  ("parallel.compat.access-check", resultEq
    (admit deniedCfg boundary [left] [right])
    (.error (.structural .left ⟨0, .interface .writeAccess⟩))),
  ("parallel.compat.forward-funded", funded (cfg usdOp (readOnly aliceUSD)) right),
  ("parallel.compat.reverse-funded", funded (cfg (readOnly vaultShare) shareOp) left),
  ("parallel.compat.output-funded", funded (cfg usdOp shareOp [] [aliceUSD]) right),
  ("parallel.compat.guard-read-exact", resultEq
    (analyzeInvocation (cfg usdOp (hidden shareOp aliceUSD)) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.delta-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenDelta) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.supply-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenSupply) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.forward-before-reverse", resultEq
    (checkCompatibility (⟨[bobUSD], [aliceUSD]⟩ : F) ⟨[aliceUSD], [bobUSD]⟩)
    (.error (.conflict .leftWriteRightRead aliceUSD))),
  ("parallel.compat.common-read-no-writes", resultEq
    (admit (cfg (readOnly common) (readOnly common)) boundary [left] [right])
    (.ok (⟨[common, common], []⟩, ⟨[common, common], []⟩))),
  ("parallel.compat.first-list-witness", resultEq
    (checkCompatibility (⟨[bobUSD, aliceUSD], [bobUSD, aliceUSD]⟩ : F) leftFP)
    (.error (.conflict .writeWrite bobUSD))) ]

end DefiKernel.Parallel.CompatibilityTests

```

### SOURCE lean/DefiKernel/Parallel/ObservationTests.lean
SHA256 227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e
```
import DefiKernel.Parallel.Execution
import DefiKernel.Composition.Examples

namespace DefiKernel.Parallel.ObservationTests
open Typed Typed.Examples Composition Composition.Examples

def emptyCursor : Cursor Party Asset Domain := startCursor cfg initialWorld

def refusal (index : Nat) (reason : Failure) : Cursor Party Asset Domain :=
  { emptyCursor with failure := some ⟨index, none, reason⟩ }

def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def request : Request Party Asset Domain :=
  ⟨transferId, [.bob], [⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def evaluated : Evaluated Party Asset Domain :=
  ⟨true, [(aliceUsd, -3), (bobUsd, 3)], [], [], [], [], [], [aliceUsd, bobUsd]⟩

def output : OutputObservation Asset := ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩

def event : Event Party Asset Domain :=
  ⟨0, .invoke invocation, initialWorld, ⟨initialWorld, .invoked request evaluated, [output]⟩⟩

def changedWorld : World Party Asset Domain := ⟨transferred, expectedStore⟩

def receiptChanges : List (String × Receipt Party Asset Domain) := [
  ("kind", .issued ⟨0⟩),
  ("request", .invoked { request with claimedActor := some .bob } evaluated),
  ("guard", .invoked request { evaluated with guard := false }),
  ("deltas", .invoked request { evaluated with deltas := [(aliceUsd, -4), (bobUsd, 4)] }),
  ("supplies", .invoked request { evaluated with supplies := [((.main, .usd), 1)] }),
  ("required-state", .invoked request { evaluated with requiredStateReads := [aliceUsd] }),
  ("required-env", .invoked request { evaluated with requiredEnvReads := [.currentTime] }),
  ("declared-state", .invoked request { evaluated with declaredStateReads := [aliceUsd] }),
  ("declared-env", .invoked request { evaluated with declaredEnvReads := [.currentTime] }),
  ("writes", .invoked request { evaluated with writes := [aliceUsd] })]

def checks : List (String × Bool) := [
  ("parallel.observe.empty", decide (observeBranch emptyCursor = ⟨[], [], 0, none⟩)),
  ("parallel.observe.refusal-reason", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 0 (.kernel .insufficientFunds)))),
  ("parallel.observe.refusal-index", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 1 (.kernel .guard)))),
  ("parallel.observe.refusal-step", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch { emptyCursor with failure := some ⟨0, some (.invoke invocation),
        .kernel .guard⟩ })),
  ("parallel.observe.local-index", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with nextIndex := 1 })),
  ("parallel.observe.history", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with outputs := [output] })),
  ("parallel.observe.event-index", decide
    (observeEvent event ≠ observeEvent { event with index := 1 })),
  ("parallel.observe.event-step", decide
    (observeEvent event ≠ observeEvent { event with step :=
      (.invoke { invocation with parties := [.vault] }) })),
  ("parallel.observe.event-outputs", decide
    (observeEvent event ≠ observeEvent
      { event with result := { event.result with outputs := [] } })),
  ("parallel.observe.output-unit", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .share, 7⟩ }] } })),
  ("parallel.observe.output-value", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .usd, 8⟩ }] } })),
  ("parallel.observe.raw-world-context", decide
    (observeEvent event = observeEvent { event with
      before := changedWorld
      result := { event.result with world := changedWorld } })),
  ("parallel.observe.final-ledger", !(worldEq initialWorld changedWorld)),
  ("parallel.observe.final-store", !(worldEq initialWorld
    { initialWorld with capabilities := ⟨[]⟩ }))] ++
  receiptChanges.map fun (label, receipt) ↦
    ("parallel.observe.receipt." ++ label, decide
      (observeEvent event ≠ observeEvent { event with result := { event.result with receipt } }))

end DefiKernel.Parallel.ObservationTests

```

### SOURCE openspec/changes/disjoint-parallel-composition/specs/parallel-regression-evidence/spec.md
SHA256 93c30bb6e8d985f4320a3d776a9e49a3e6976dc0d79b3fdeb8b1b3e80ab41074
```
## Purpose

Make parallel composition claims reviewable through complete scenario coverage, discriminating source mutations, exact proof scope and independently audited candidates.

## ADDED Requirements

### Requirement: Planning approval before implementation
The OpenSpec candidate SHALL receive independent Fable and GPT-6 audits before implementation begins. Both final verdicts SHALL cover the same committed candidate and be explicit passes with no blocking finding unresolved. Unavailable, timeout, malformed or error responses SHALL NOT count as passes. Advisory limitations SHALL NOT waive a normative requirement.

#### Scenario: Planning candidate passes
- **WHEN** both named reviewers pass the same candidate and all blocking findings are resolved
- **THEN** implementation may begin under the existing user authorization

#### Scenario: Reviewer unavailable or candidate revised
- **WHEN** a required planning reviewer is unavailable or the candidate changes substantively after its verdict
- **THEN** implementation remains gated until the missing or affected candidate audit passes

### Requirement: Complete reference comparisons
The sprint SHALL map every requirement/scenario to named proofs, full finite-world comparisons, compiler controls, or actual acceptance evidence. Financial and isolation negatives SHALL have funded/authorized compatible siblings. Counts SHALL distinguish mathematical proofs from bounded comparisons, counterexamples and measurements.

#### Scenario: Negative targets interference
- **WHEN** a fixture rejects a conflicting branch pair
- **THEN** a funded authorized underlying-executor control and compatible pair show rejection is caused by the intended compatibility condition

#### Scenario: Branch behavior inventory
- **WHEN** the suite runs
- **THEN** it compares complete ledgers/stores and all required canonical observation fields for success, independent refusal, output routing, boundary identity and supply scenarios

### Requirement: Real source mutations and robust controls
Required mutation classes SHALL cover conflict directions, hidden/output/target dependencies, peer cancellation, prefix rollback, lost/doubled merge state, output-history leakage, boundary-index misuse, omitted supplies, stale capability use, and incorrect state-dependent evaluation. Each counted detection SHALL apply a real implementation-source edit, compile and run the full nonempty named inventory, fail designated comparisons, and retain specified unrelated positive controls.

#### Scenario: Semantic detection
- **WHEN** a required mutant compiles and changes observable behavior
- **THEN** saved execution identifies its designated false comparison and surviving positives

#### Scenario: Invalid or vacuous run
- **WHEN** a mutant is missing, unapplied, noncompiling, surviving, or its check inventory is empty/partial/duplicated/malformed
- **THEN** the runner reports failure or blocked execution and never a semantic detection

#### Scenario: Redundant conflict guards
- **WHEN** one guard removal is masked by another required guard
- **THEN** the manifest explicitly uses a justified composite mutation or reports survival; a compile error is not substituted for detection

### Requirement: Integrated proof and regression audit
The sprint SHALL run the full Lean build, new runtime/imported-axiom audit, all existing kernel runtime and imported-axiom drivers, typed/compiler/mutation/runner/axiom controls and corpus regressions. Accepted imported proof code SHALL contain no sorry, custom axiom or native_decide. Original proof and corpus files SHALL remain byte-identical apart from explicitly authorized new import wiring.

#### Scenario: New proof enters import closure
- **WHEN** a new named theorem is counted
- **THEN** its statement and premises appear in the inventory and its declaration is covered by the fresh built imported axiom audit

#### Scenario: Historical regression or drift
- **WHEN** an existing test fails or a preserved file changes
- **THEN** acceptance is blocked until the cause is resolved and affected checks pass

### Requirement: Independent implementation review and delivery
The implemented source/evidence candidate SHALL receive native Grok/Fable review with exact requested/reported model identity and preserved findings. Executed inputs, reviewed bytes, tool versions and Git objects SHALL be bound by verifiable manifests. Delivery SHALL update the roadmap, verify the authorized branch push, archive this accepted OpenSpec change, and validate its synchronized main specs.

#### Scenario: Reviewed source changes
- **WHEN** implementation changes after review or execution began on a dirty predecessor
- **THEN** affected validation/review is refreshed and exact executed/reviewed bytes are compared to committed objects without relabeling original run heads

#### Scenario: Verified branch and archive
- **WHEN** all implementation acceptance checks pass
- **THEN** source/evidence and archive metadata are pushed to the authorized branch with verified remote heads; broader roadmap work stays open

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/summary.json
SHA256 493ea2952e7e4b554f3495f2ef066509b6b37095445154bf5f374f405e04e48a
```
{
  "schema_version": 1,
  "kind": "executed-production-parallel-source-mutations",
  "command": [
    "python3",
    "scripts/check_parallel_mutations.py",
    "--repo",
    ".",
    "--spec",
    "review/semantic-kernel/sprint6/mutation-spec.json",
    "--out",
    "/tmp/sprint6-production-final-fae07ca"
  ],
  "cwd": "/home/charl/defiformal",
  "exit": 0,
  "git_head": "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d",
  "runner_sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
  "spec_sha256": "5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35",
  "source_manifest_sha256": "54d87df502ac76a4175d11da3ce6b290e884afd53c1f9e6a990f071f52c56856",
  "results_sha256": "d74aab4ef5fb6bad25f22b3916a7995b7c453472082bdd16efef5b68a29fd03e",
  "cli_log_sha256": "bf64f0ef129c6c012aee0da0243ff00bdd1feab3b308d489353e66cf696332e2",
  "control_comparisons": 131,
  "mutations": 14,
  "detected": 14,
  "comparisons_per_mutant": 131,
  "total_runtime_comparisons": 1965,
  "protected_comparisons_per_mutant": 5,
  "input_sources_unchanged": true,
  "specification_unchanged": true,
  "runner_unchanged": true,
  "source_file_count": 27,
  "projected_local_modules": 24,
  "all_captured_inputs_match_git_objects": true,
  "git_object_bindings": 30,
  "development_replay_same_sources_and_results": true,
  "outcomes": [
    {
      "name": "bypass-write-write-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "comparisons": 131,
      "false_count": 14,
      "required_false": [
        "parallel.compat.write-write-witness"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "9c0a8a430e6b2e77c70e870b186348b7a55e0aab0158465e8cf8f8d6e5495978"
    },
    {
      "name": "omit-expression-reads-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "comparisons": 131,
      "false_count": 9,
      "required_false": [
        "parallel.compat.hidden-inactive-guard",
        "parallel.compat.hidden-delta",
        "parallel.compat.hidden-supply"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "903a11b4585757e0e6a9a48a95b79a46eebb858ec06624cd0ed8c94d783c2dcf"
    },
    {
      "name": "omit-output-dependency",
      "module": "DefiKernel.Parallel.Compatibility",
      "comparisons": 131,
      "false_count": 2,
      "required_false": [
        "parallel.compat.output-dependency"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "a3a5abf4a9051049d5b19eb99ce331da2bc2ed725523f3f585b37ba7fde3aa4b"
    },
    {
      "name": "omit-zero-delta-target",
      "module": "DefiKernel.Parallel.Compatibility",
      "comparisons": 131,
      "false_count": 14,
      "required_false": [
        "parallel.compat.zero-target",
        "parallel.compat.zero-target-exact"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "82dbad9b7bbdb5c0c95a5fd8b6c14aa9c84b6a17aa8118a3c7df8383191bde43"
    },
    {
      "name": "omit-reverse-conflict",
      "module": "DefiKernel.Parallel.Compatibility",
      "comparisons": 131,
      "false_count": 1,
      "required_false": [
        "parallel.compat.reverse-read"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "46ef8f24d7d88f418c0e670466f6de0ead9ca98f1cd6521e7f4679a3be59e83b"
    },
    {
      "name": "cancel-peer-after-refusal",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 9,
      "required_false": [
        "parallel.fixture.refusal.peer-runs"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "ac34a3b9f2c68897eb1dc5f25fd3e39fa4c59d6e0c459824ad80baf98460dcf7"
    },
    {
      "name": "rollback-refused-prefix-at-join",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 5,
      "required_false": [
        "parallel.fixture.refusal.prefix-kept"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "85f9873b2cf149abb58e7c4961190c1b5cd94e096ffdfbcd10e91974567382a8"
    },
    {
      "name": "replace-merge-with-left-world",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 20,
      "required_false": [
        "parallel.fixture.basic.complete"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "db6360220957a489bcb6fed3f601e2e5f4b62e80edb146a83486ca32cf58fc2f"
    },
    {
      "name": "double-initial-balances",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 28,
      "required_false": [
        "parallel.fixture.basic.complete"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "8f849b8d4fdd5f72e1c1e3fdbe49b0f4c7cb6dbe1c0ab7c0d79608fb9f6f6786"
    },
    {
      "name": "leak-peer-output-history",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 20,
      "required_false": [
        "parallel.fixture.routing.peer-only"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "6b5656fe4dea05185b541dbb96ddfbe292854e61718aa5c594d59cdaf8153bc1"
    },
    {
      "name": "reuse-left-trusted-boundary",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 1,
      "required_false": [
        "parallel.fixture.boundary.local-identity"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "e0f01a88d72f323b857c4799450db86a4b39c9513c74295030cb0833ecccd1b5"
    },
    {
      "name": "drop-peer-supply-receipts",
      "module": "DefiKernel.Parallel.Preservation",
      "comparisons": 131,
      "false_count": 1,
      "required_false": [
        "parallel.fixture.supply.both-receipts"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "ca591ebe7d3bd0bf7f25eeeca11c1c196a14932a5c7eeff8406b4e9bd76a5eaa"
    },
    {
      "name": "reuse-live-capability-store",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 1,
      "required_false": [
        "parallel.fixture.capability.revoked"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "f531d922a6d7fa5be0fc8d44062fe06a2f92f30d4a2b0c7c23a5aed7c9456fe0"
    },
    {
      "name": "stale-intra-branch-evaluation",
      "module": "DefiKernel.Parallel.Execution",
      "comparisons": 131,
      "false_count": 26,
      "required_false": [
        "parallel.fixture.stateful.prefix"
      ],
      "protected_true": [
        "parallel.compat.catalog-positive",
        "parallel.compat.funded-left-complete",
        "parallel.compat.funded-right-complete",
        "parallel.compat.zero-target-funded",
        "parallel.compat.hidden-inactive-guard-funded"
      ],
      "exit": 1,
      "fixture_sha256": "1f61f48079726517b916931adff33ed3658e38e29ea8d0c029b12f47a6d6c0cf"
    }
  ],
  "scope": "Actual new Parallel implementation source edits; proof tails excluded only from scratch execution. Bounded sensitivity evidence, not proofs or deployed fidelity. Earlier passed and blocked attempts remain separate development evidence."
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/source-manifest.json
SHA256 54d87df502ac76a4175d11da3ce6b290e884afd53c1f9e6a990f071f52c56856
```
{
  "sources": {
    "lean/DefiKernel/Parallel/Compatibility.lean": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Parallel/Observation.lean": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Parallel/Execution.lean": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "lean/DefiKernel/Parallel/Preservation.lean": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "lean/DefiKernel/Parallel/Commutation.lean": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "lean/DefiKernel/Parallel/Dependency.lean": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Parallel/Audit.lean": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Parallel/ObservationTests.lean": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "lean/DefiKernel/Parallel/ExecutionTests.lean": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
    "lean/DefiKernel/Parallel/Tests.lean": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
    "lean/DefiKernel/Parallel/Examples.lean": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "script_sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
  "spec_sha256": "5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35",
  "git_head": "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d",
  "input_status": "",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "scope": "Fresh local dependency source closure; Parallel proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.",
  "projection_order": [
    "DefiKernel.Typed.Types",
    "DefiKernel.Typed.Expr",
    "DefiKernel.Typed.Authority",
    "DefiKernel.Typed.Transition",
    "DefiKernel.Composition.Interfaces",
    "DefiKernel.Composition.Contracts",
    "DefiKernel.Composition.Execution",
    "DefiKernel.Parallel.Compatibility",
    "DefiKernel.Composition.Sequence",
    "DefiKernel.Parallel.Observation",
    "DefiKernel.Parallel.Execution",
    "DefiKernel.Parallel.Dependency",
    "DefiKernel.Parallel.Dependency.Adapter",
    "DefiKernel.Parallel.Commutation",
    "DefiKernel.Composition.Preservation",
    "DefiKernel.Parallel.Preservation",
    "DefiKernel.Typed.Examples",
    "DefiKernel.Composition.Examples",
    "DefiKernel.Parallel.CompatibilityTests",
    "DefiKernel.Parallel.ObservationTests",
    "DefiKernel.Parallel.ExecutionTests",
    "DefiKernel.Parallel.Examples",
    "DefiKernel.Parallel.Tests",
    "DefiKernel.Parallel.Audit"
  ],
  "module_roots": [
    "DefiKernel.Parallel.Compatibility",
    "DefiKernel.Parallel.Observation",
    "DefiKernel.Parallel.Execution",
    "DefiKernel.Parallel.Preservation",
    "DefiKernel.Parallel.Audit"
  ],
  "audit_root": "DefiKernel.Parallel.Audit",
  "python_version": "3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]",
  "sources_after": {
    "lean/DefiKernel/Parallel/Compatibility.lean": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Parallel/Observation.lean": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Parallel/Execution.lean": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "lean/DefiKernel/Parallel/Preservation.lean": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "lean/DefiKernel/Parallel/Commutation.lean": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "lean/DefiKernel/Parallel/Dependency.lean": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Parallel/Audit.lean": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Parallel/ObservationTests.lean": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "lean/DefiKernel/Parallel/ExecutionTests.lean": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
    "lean/DefiKernel/Parallel/Tests.lean": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
    "lean/DefiKernel/Parallel/Examples.lean": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "input_sources_unchanged": true,
  "specification_unchanged": true,
  "runner_unchanged": true
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/results.json
SHA256 d74aab4ef5fb6bad25f22b3916a7995b7c453472082bdd16efef5b68a29fd03e
```
{
  "runs": [
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
      "log_sha256": "38d197852c858d322d65d4cdba4ba17d72b666a05e05e685649f0f160fde4ef5"
    },
    {
      "label": "git-root-input-status",
      "command": [
        "git",
        "-C",
        "/home/charl/defiformal",
        "status",
        "--porcelain",
        "--untracked-files=all",
        "--",
        "lean/DefiKernel/Parallel/Compatibility.lean",
        "lean/DefiKernel/Composition/Execution.lean",
        "lean/DefiKernel/Composition/Interfaces.lean",
        "lean/DefiKernel/Typed/Transition.lean",
        "lean/DefiKernel/Typed/Expr.lean",
        "lean/DefiKernel/Typed/Types.lean",
        "lean/DefiKernel/Typed/Authority.lean",
        "lean/DefiKernel/Composition/Contracts.lean",
        "lean/DefiKernel/Parallel/Observation.lean",
        "lean/DefiKernel/Composition/Sequence.lean",
        "lean/DefiKernel/Parallel/Execution.lean",
        "lean/DefiKernel/Parallel/Preservation.lean",
        "lean/DefiKernel/Parallel/Commutation.lean",
        "lean/DefiKernel/Parallel/Dependency/Adapter.lean",
        "lean/DefiKernel/Parallel/Dependency.lean",
        "lean/DefiKernel/Composition/Preservation.lean",
        "lean/DefiKernel/Parallel/Audit.lean",
        "lean/DefiKernel/Parallel/CompatibilityTests.lean",
        "lean/DefiKernel/Composition/Examples.lean",
        "lean/DefiKernel/Typed/Examples.lean",
        "lean/DefiKernel/Parallel/ObservationTests.lean",
        "lean/DefiKernel/Parallel/ExecutionTests.lean",
        "lean/DefiKernel/Parallel/Tests.lean",
        "lean/DefiKernel/Parallel/Examples.lean",
        "lean/lean-toolchain",
        "lean/lake-manifest.json",
        "lean/lakefile.toml"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    },
    {
      "label": "control",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/control.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9"
    },
    {
      "label": "bypass-write-write-composite",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/bypass-write-write-composite.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "afd0416dbac388f3ca83e6f17684e52a7a27f9611de4e7216a26f9d615050b16"
    },
    {
      "label": "omit-expression-reads-composite",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/omit-expression-reads-composite.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "8c0b41772277eb03ca661fab759b52a5cf0c659d6e5da72a0fc6c8940a901b54"
    },
    {
      "label": "omit-output-dependency",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/omit-output-dependency.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "55389c1f4a397b244af56ef4f1e770df2714df5a661cf3ac1990e27b79d49847"
    },
    {
      "label": "omit-zero-delta-target",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/omit-zero-delta-target.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "0556f6b0e91649f89d7efab3a52a8354092cea115ac4ae7c42c0da8184abb253"
    },
    {
      "label": "omit-reverse-conflict",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/omit-reverse-conflict.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "49c1f2517fbff9c526689ee993c94b7d99fcd450dc7546998d8cede4283868b5"
    },
    {
      "label": "cancel-peer-after-refusal",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/cancel-peer-after-refusal.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "d6a7906d0d1d2e3373dc9debf94697dbdfb993c0e2201cd3dff0cb6d5d7a39d7"
    },
    {
      "label": "rollback-refused-prefix-at-join",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/rollback-refused-prefix-at-join.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "177edf2c20c6516947076d8e9e72cd9c2a0dac08108e75f929d7b3829a143426"
    },
    {
      "label": "replace-merge-with-left-world",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/replace-merge-with-left-world.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "18498874ac215664d41eb993ed79af37e807dc33a7e661ddc32823761f2e83d0"
    },
    {
      "label": "double-initial-balances",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/double-initial-balances.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "4c34031701f0ac214da855b39f66da2ef385ad170039a4e9aa261ad3db046df8"
    },
    {
      "label": "leak-peer-output-history",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/leak-peer-output-history.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "4182da9cd05b895869e6fed1a356289ff88d8b2c08eb79a5636627bee737b91b"
    },
    {
      "label": "reuse-left-trusted-boundary",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/reuse-left-trusted-boundary.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "19b94e83540e2ffacc5d095e64d48e7e427700f5b4135dd91a389c825023fd1f"
    },
    {
      "label": "drop-peer-supply-receipts",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/drop-peer-supply-receipts.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "b872be57ff439871aef56bf9d420476d0535af94d69f9fc3c59e734571540f8e"
    },
    {
      "label": "reuse-live-capability-store",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/reuse-live-capability-store.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "0cde90fba6ae0611f8407575d380bb750f643de9f0a7bd0d189ecd02e1cf6b1e"
    },
    {
      "label": "stale-intra-branch-evaluation",
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/sprint6-production-final-fae07ca/stale-intra-branch-evaluation.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 1,
      "log_sha256": "21528d5b2da60b5bc8fe701847858fab2f8f65acdb40b358f9367826ea675717"
    }
  ],
  "results": {
    "control": {
      "exit": 0,
      "fixture_sha256": "050277c93b4e6176f6fc6945cec018be28c55ddcc3f5c7c14fd6e675cf03cbdc",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": []
    },
    "bypass-write-write-composite": {
      "exit": 1,
      "fixture_sha256": "9c0a8a430e6b2e77c70e870b186348b7a55e0aab0158465e8cf8f8d6e5495978",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "false",
        "parallel.compat.forward-read": "false",
        "parallel.compat.reverse-read": "false",
        "parallel.compat.hidden-inactive-guard": "false",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "false",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "false",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "false",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "false",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "false",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "false",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "false",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "false",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "false",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "false",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.compat.first-list-witness",
        "parallel.compat.forward-before-reverse",
        "parallel.compat.forward-read",
        "parallel.compat.hidden-delta",
        "parallel.compat.hidden-inactive-guard",
        "parallel.compat.hidden-supply",
        "parallel.compat.output-dependency",
        "parallel.compat.reverse-read",
        "parallel.compat.unreachable-suffix",
        "parallel.compat.write-write-witness",
        "parallel.compat.zero-target",
        "parallel.fixture.cancelling.admission",
        "parallel.fixture.refusal.world-preserved",
        "parallel.refused.conflict-unchanged"
      ]
    },
    "omit-expression-reads-composite": {
      "exit": 1,
      "fixture_sha256": "903a11b4585757e0e6a9a48a95b79a46eebb858ec06624cd0ed8c94d783c2dcf",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "false",
        "parallel.compat.reverse-read": "false",
        "parallel.compat.hidden-inactive-guard": "false",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "false",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "false",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "false",
        "parallel.compat.delta-read-exact": "false",
        "parallel.compat.supply-read-exact": "false",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "false",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.compat.common-read-no-writes",
        "parallel.compat.delta-read-exact",
        "parallel.compat.forward-read",
        "parallel.compat.guard-read-exact",
        "parallel.compat.hidden-delta",
        "parallel.compat.hidden-inactive-guard",
        "parallel.compat.hidden-supply",
        "parallel.compat.reverse-read",
        "parallel.compat.supply-read-exact"
      ]
    },
    "omit-output-dependency": {
      "exit": 1,
      "fixture_sha256": "a3a5abf4a9051049d5b19eb99ce331da2bc2ed725523f3f585b37ba7fde3aa4b",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "false",
        "parallel.compat.output-exact": "false",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.compat.output-dependency",
        "parallel.compat.output-exact"
      ]
    },
    "omit-zero-delta-target": {
      "exit": 1,
      "fixture_sha256": "82dbad9b7bbdb5c0c95a5fd8b6c14aa9c84b6a17aa8118a3c7df8383191bde43",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "false",
        "parallel.compat.invocation-exact-right": "false",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "false",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "false",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "false",
        "parallel.compat.zero-target": "false",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "false",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "false",
        "parallel.compat.prior-output-not-evaluated": "false",
        "parallel.compat.capability-not-evaluated": "false",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "false",
        "parallel.compat.delta-read-exact": "false",
        "parallel.compat.supply-read-exact": "false",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "false",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.compat.capability-not-evaluated",
        "parallel.compat.delta-read-exact",
        "parallel.compat.guard-read-exact",
        "parallel.compat.independent",
        "parallel.compat.invocation-exact-left",
        "parallel.compat.invocation-exact-right",
        "parallel.compat.left-empty",
        "parallel.compat.numeric-input-not-evaluated",
        "parallel.compat.output-exact",
        "parallel.compat.prior-output-not-evaluated",
        "parallel.compat.supply-read-exact",
        "parallel.compat.zero-target",
        "parallel.compat.zero-target-exact",
        "parallel.fixture.cancelling.admission"
      ]
    },
    "omit-reverse-conflict": {
      "exit": 1,
      "fixture_sha256": "46ef8f24d7d88f418c0e670466f6de0ead9ca98f1cd6521e7f4679a3be59e83b",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "false",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.compat.reverse-read"
      ]
    },
    "cancel-peer-after-refusal": {
      "exit": 1,
      "fixture_sha256": "ac34a3b9f2c68897eb1dc5f25fd3e39fa4c59d6e0c459824ad80baf98460dcf7",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "false",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "false",
        "parallel.fixture.refusal.input-unit": "false",
        "parallel.fixture.refusal.missing-capability": "false",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.guard",
        "parallel.fixture.refusal.input-unit",
        "parallel.fixture.refusal.missing-capability",
        "parallel.fixture.refusal.peer-runs",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.supply.prefix-refusal"
      ]
    },
    "rollback-refused-prefix-at-join": {
      "exit": 1,
      "fixture_sha256": "85f9873b2cf149abb58e7c4961190c1b5cd94e096ffdfbcd10e91974567382a8",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.supply.prefix-refusal"
      ]
    },
    "replace-merge-with-left-world": {
      "exit": 1,
      "fixture_sha256": "db6360220957a489bcb6fed3f601e2e5f4b62e80edb146a83486ca32cf58fc2f",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "false",
        "parallel.fixture.same-asset.complete": "false",
        "parallel.fixture.refusal.peer-runs": "false",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "false",
        "parallel.fixture.refusal.input-unit": "false",
        "parallel.fixture.refusal.missing-capability": "false",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "false",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "false",
        "parallel.fixture.routing.own-history": "false",
        "parallel.fixture.routing.both-own-history": "false",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "false",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "false",
        "parallel.fixture.supply.complete": "false",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "false",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "false",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.basic.complete",
        "parallel.fixture.boundary.local-identity",
        "parallel.fixture.capability.reusable-shared-grant",
        "parallel.fixture.empty.left",
        "parallel.fixture.raw-context-differs",
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.guard",
        "parallel.fixture.refusal.input-unit",
        "parallel.fixture.refusal.missing-capability",
        "parallel.fixture.refusal.peer-runs",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.both-own-history",
        "parallel.fixture.routing.funded-literal",
        "parallel.fixture.routing.own-history",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.same-asset.complete",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.stateful.supply",
        "parallel.fixture.supply.complete",
        "parallel.fixture.supply.prefix-refusal"
      ]
    },
    "double-initial-balances": {
      "exit": 1,
      "fixture_sha256": "8f849b8d4fdd5f72e1c1e3fdbe49b0f4c7cb6dbe1c0ab7c0d79608fb9f6f6786",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "false",
        "parallel.empty.lr": "false",
        "parallel.empty.rl": "false",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "false",
        "parallel.fixture.same-asset.complete": "false",
        "parallel.fixture.refusal.peer-runs": "false",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "false",
        "parallel.fixture.refusal.input-unit": "false",
        "parallel.fixture.refusal.missing-capability": "false",
        "parallel.fixture.empty.right": "false",
        "parallel.fixture.empty.left": "false",
        "parallel.fixture.empty.both": "false",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "false",
        "parallel.fixture.routing.own-history": "false",
        "parallel.fixture.routing.both-own-history": "false",
        "parallel.fixture.routing.shared-qualified-key": "false",
        "parallel.fixture.boundary.local-identity": "false",
        "parallel.fixture.capability.revoked": "false",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "false",
        "parallel.fixture.supply.complete": "false",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "false",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "false",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "false",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.empty",
        "parallel.empty.lr",
        "parallel.empty.rl",
        "parallel.fixture.basic.complete",
        "parallel.fixture.boundary.local-identity",
        "parallel.fixture.cancelling.funded",
        "parallel.fixture.capability.reusable-shared-grant",
        "parallel.fixture.capability.revoked",
        "parallel.fixture.empty.both",
        "parallel.fixture.empty.left",
        "parallel.fixture.empty.right",
        "parallel.fixture.raw-context-differs",
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.guard",
        "parallel.fixture.refusal.input-unit",
        "parallel.fixture.refusal.missing-capability",
        "parallel.fixture.refusal.peer-runs",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.both-own-history",
        "parallel.fixture.routing.funded-literal",
        "parallel.fixture.routing.own-history",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.routing.shared-qualified-key",
        "parallel.fixture.same-asset.complete",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.stateful.supply",
        "parallel.fixture.supply.complete",
        "parallel.fixture.supply.prefix-refusal"
      ]
    },
    "leak-peer-output-history": {
      "exit": 1,
      "fixture_sha256": "6b5656fe4dea05185b541dbb96ddfbe292854e61718aa5c594d59cdaf8153bc1",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "false",
        "parallel.fixture.same-asset.complete": "false",
        "parallel.fixture.refusal.peer-runs": "false",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "false",
        "parallel.fixture.refusal.input-unit": "false",
        "parallel.fixture.refusal.missing-capability": "false",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "false",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "false",
        "parallel.fixture.routing.own-history": "false",
        "parallel.fixture.routing.both-own-history": "false",
        "parallel.fixture.routing.shared-qualified-key": "false",
        "parallel.fixture.boundary.local-identity": "false",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "false",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "false",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "false",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.basic.complete",
        "parallel.fixture.boundary.local-identity",
        "parallel.fixture.empty.left",
        "parallel.fixture.raw-context-differs",
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.guard",
        "parallel.fixture.refusal.input-unit",
        "parallel.fixture.refusal.missing-capability",
        "parallel.fixture.refusal.peer-runs",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.both-own-history",
        "parallel.fixture.routing.funded-literal",
        "parallel.fixture.routing.own-history",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.routing.shared-qualified-key",
        "parallel.fixture.same-asset.complete",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.stateful.supply",
        "parallel.fixture.supply.complete",
        "parallel.fixture.supply.prefix-refusal"
      ]
    },
    "reuse-left-trusted-boundary": {
      "exit": 1,
      "fixture_sha256": "e0f01a88d72f323b857c4799450db86a4b39c9513c74295030cb0833ecccd1b5",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "false",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.boundary.local-identity"
      ]
    },
    "drop-peer-supply-receipts": {
      "exit": 1,
      "fixture_sha256": "ca591ebe7d3bd0bf7f25eeeca11c1c196a14932a5c7eeff8406b4e9bd76a5eaa",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "false",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.supply.both-receipts"
      ]
    },
    "reuse-live-capability-store": {
      "exit": 1,
      "fixture_sha256": "f531d922a6d7fa5be0fc8d44062fe06a2f92f30d4a2b0c7c23a5aed7c9456fe0",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "true",
        "parallel.fixture.refusal.dual": "true",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "true",
        "parallel.fixture.routing.funded-literal": "true",
        "parallel.fixture.routing.own-history": "true",
        "parallel.fixture.routing.both-own-history": "true",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "true",
        "parallel.fixture.capability.revoked": "false",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "true",
        "parallel.fixture.stateful.prefix": "true",
        "parallel.fixture.stateful.supply": "true",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "true",
        "parallel.fixture.prefix.rl.complete": "true",
        "parallel.fixture.routing.lr.complete": "true",
        "parallel.fixture.routing.rl.complete": "true",
        "parallel.fixture.boundary.lr.complete": "true",
        "parallel.fixture.boundary.rl.complete": "true",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "true",
        "parallel.fixture.stateful.rl.complete": "true",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "true",
        "parallel.fixture.dual.rl.complete": "true",
        "parallel.fixture.both-own-history.lr.complete": "true",
        "parallel.fixture.both-own-history.rl.complete": "true",
        "parallel.fixture.stateful-supply.lr.complete": "true",
        "parallel.fixture.stateful-supply.rl.complete": "true",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "true",
        "parallel.fixture.supply-prefix.rl.complete": "true"
      },
      "false_comparisons": [
        "parallel.fixture.capability.revoked"
      ]
    },
    "stale-intra-branch-evaluation": {
      "exit": 1,
      "fixture_sha256": "1f61f48079726517b916931adff33ed3658e38e29ea8d0c029b12f47a6d6c0cf",
      "checks": {
        "parallel.compat.catalog-positive": "true",
        "parallel.compat.invocation-exact-left": "true",
        "parallel.compat.invocation-exact-right": "true",
        "parallel.compat.funded-left-complete": "true",
        "parallel.compat.funded-right-complete": "true",
        "parallel.compat.independent": "true",
        "parallel.compat.empty": "true",
        "parallel.compat.left-empty": "true",
        "parallel.compat.common-read": "true",
        "parallel.compat.write-write-witness": "true",
        "parallel.compat.forward-read": "true",
        "parallel.compat.reverse-read": "true",
        "parallel.compat.hidden-inactive-guard": "true",
        "parallel.compat.hidden-inactive-guard-funded": "true",
        "parallel.compat.hidden-delta": "true",
        "parallel.compat.hidden-delta-funded": "true",
        "parallel.compat.hidden-supply": "true",
        "parallel.compat.hidden-supply-funded": "true",
        "parallel.compat.output-dependency": "true",
        "parallel.compat.output-exact": "true",
        "parallel.compat.zero-target": "true",
        "parallel.compat.zero-target-funded": "true",
        "parallel.compat.zero-target-exact": "true",
        "parallel.compat.unreachable-suffix": "true",
        "parallel.compat.numeric-input-not-evaluated": "true",
        "parallel.compat.prior-output-not-evaluated": "true",
        "parallel.compat.capability-not-evaluated": "true",
        "parallel.compat.catalog-first": "true",
        "parallel.compat.left-before-right": "true",
        "parallel.compat.local-order": "true",
        "parallel.compat.structural-before-conflict": "true",
        "parallel.compat.malformed-reference": "true",
        "parallel.compat.access-check": "true",
        "parallel.compat.forward-funded": "true",
        "parallel.compat.reverse-funded": "true",
        "parallel.compat.output-funded": "true",
        "parallel.compat.guard-read-exact": "true",
        "parallel.compat.delta-read-exact": "true",
        "parallel.compat.supply-read-exact": "true",
        "parallel.compat.forward-before-reverse": "true",
        "parallel.compat.common-read-no-writes": "true",
        "parallel.compat.first-list-witness": "true",
        "parallel.observe.empty": "true",
        "parallel.observe.refusal-reason": "true",
        "parallel.observe.refusal-index": "true",
        "parallel.observe.refusal-step": "true",
        "parallel.observe.local-index": "true",
        "parallel.observe.history": "true",
        "parallel.observe.event-index": "true",
        "parallel.observe.event-step": "true",
        "parallel.observe.event-outputs": "true",
        "parallel.observe.output-unit": "true",
        "parallel.observe.output-value": "true",
        "parallel.observe.raw-world-context": "true",
        "parallel.observe.final-ledger": "true",
        "parallel.observe.final-store": "true",
        "parallel.observe.receipt.kind": "true",
        "parallel.observe.receipt.request": "true",
        "parallel.observe.receipt.guard": "true",
        "parallel.observe.receipt.deltas": "true",
        "parallel.observe.receipt.supplies": "true",
        "parallel.observe.receipt.required-state": "true",
        "parallel.observe.receipt.required-env": "true",
        "parallel.observe.receipt.declared-state": "true",
        "parallel.observe.receipt.declared-env": "true",
        "parallel.observe.receipt.writes": "true",
        "parallel.empty": "true",
        "parallel.empty.lr": "true",
        "parallel.empty.rl": "true",
        "parallel.refused.catalog-unchanged": "true",
        "parallel.refused.conflict-unchanged": "true",
        "parallel.refused.structural-unchanged": "true",
        "parallel.fixture.catalog": "true",
        "parallel.fixture.basic.complete": "true",
        "parallel.fixture.same-asset.complete": "true",
        "parallel.fixture.refusal.peer-runs": "true",
        "parallel.fixture.refusal.prefix-kept": "false",
        "parallel.fixture.refusal.dual": "false",
        "parallel.fixture.refusal.guard": "true",
        "parallel.fixture.refusal.input-unit": "true",
        "parallel.fixture.refusal.missing-capability": "true",
        "parallel.fixture.empty.right": "true",
        "parallel.fixture.empty.left": "true",
        "parallel.fixture.empty.both": "true",
        "parallel.fixture.routing.peer-only": "false",
        "parallel.fixture.routing.funded-literal": "false",
        "parallel.fixture.routing.own-history": "false",
        "parallel.fixture.routing.both-own-history": "false",
        "parallel.fixture.routing.shared-qualified-key": "true",
        "parallel.fixture.boundary.local-identity": "false",
        "parallel.fixture.capability.revoked": "true",
        "parallel.fixture.capability.actual-revoke": "true",
        "parallel.fixture.capability.reusable-shared-grant": "true",
        "parallel.fixture.supply.complete": "true",
        "parallel.fixture.supply.both-receipts": "true",
        "parallel.fixture.supply.prefix-refusal": "false",
        "parallel.fixture.stateful.prefix": "false",
        "parallel.fixture.stateful.supply": "false",
        "parallel.fixture.cancelling.admission": "true",
        "parallel.fixture.cancelling.funded": "true",
        "parallel.fixture.refusal.world-preserved": "true",
        "parallel.fixture.refusal.suffix-world-preserved": "true",
        "parallel.fixture.raw-context-differs": "true",
        "parallel.fixture.basic.lr.complete": "true",
        "parallel.fixture.basic.rl.complete": "true",
        "parallel.fixture.prefix.lr.complete": "false",
        "parallel.fixture.prefix.rl.complete": "false",
        "parallel.fixture.routing.lr.complete": "false",
        "parallel.fixture.routing.rl.complete": "false",
        "parallel.fixture.boundary.lr.complete": "false",
        "parallel.fixture.boundary.rl.complete": "false",
        "parallel.fixture.supply.lr.complete": "true",
        "parallel.fixture.supply.rl.complete": "true",
        "parallel.fixture.stateful.lr.complete": "false",
        "parallel.fixture.stateful.rl.complete": "false",
        "parallel.fixture.revoked.lr.complete": "true",
        "parallel.fixture.revoked.rl.complete": "true",
        "parallel.fixture.same-asset.lr.complete": "true",
        "parallel.fixture.same-asset.rl.complete": "true",
        "parallel.fixture.peer-runs.lr.complete": "true",
        "parallel.fixture.peer-runs.rl.complete": "true",
        "parallel.fixture.dual.lr.complete": "false",
        "parallel.fixture.dual.rl.complete": "false",
        "parallel.fixture.both-own-history.lr.complete": "false",
        "parallel.fixture.both-own-history.rl.complete": "false",
        "parallel.fixture.stateful-supply.lr.complete": "false",
        "parallel.fixture.stateful-supply.rl.complete": "false",
        "parallel.fixture.shared-qualified-key.lr.complete": "true",
        "parallel.fixture.shared-qualified-key.rl.complete": "true",
        "parallel.fixture.supply-prefix.lr.complete": "false",
        "parallel.fixture.supply-prefix.rl.complete": "false"
      },
      "false_comparisons": [
        "parallel.fixture.both-own-history.lr.complete",
        "parallel.fixture.both-own-history.rl.complete",
        "parallel.fixture.boundary.local-identity",
        "parallel.fixture.boundary.lr.complete",
        "parallel.fixture.boundary.rl.complete",
        "parallel.fixture.dual.lr.complete",
        "parallel.fixture.dual.rl.complete",
        "parallel.fixture.prefix.lr.complete",
        "parallel.fixture.prefix.rl.complete",
        "parallel.fixture.refusal.dual",
        "parallel.fixture.refusal.prefix-kept",
        "parallel.fixture.routing.both-own-history",
        "parallel.fixture.routing.funded-literal",
        "parallel.fixture.routing.lr.complete",
        "parallel.fixture.routing.own-history",
        "parallel.fixture.routing.peer-only",
        "parallel.fixture.routing.rl.complete",
        "parallel.fixture.stateful-supply.lr.complete",
        "parallel.fixture.stateful-supply.rl.complete",
        "parallel.fixture.stateful.lr.complete",
        "parallel.fixture.stateful.prefix",
        "parallel.fixture.stateful.rl.complete",
        "parallel.fixture.stateful.supply",
        "parallel.fixture.supply-prefix.lr.complete",
        "parallel.fixture.supply-prefix.rl.complete",
        "parallel.fixture.supply.prefix-refusal"
      ]
    }
  }
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/artifact-integrity.json
SHA256 2d283b9f77e84929dedbc989af28d9b5ab98efc1a6c96dcdf3f42105015d4347
```
{
  "kind": "production-mutation-artifact-integrity",
  "assertions": 160,
  "failures": 0,
  "checks": [
    "14 required source mutants",
    "exact variant inventory",
    "131 true unchanged control comparisons",
    "lean-version log hash",
    "lean-path log hash",
    "git-head log hash",
    "git-root-input-status log hash",
    "control log hash",
    "bypass-write-write-composite log hash",
    "omit-expression-reads-composite log hash",
    "omit-output-dependency log hash",
    "omit-zero-delta-target log hash",
    "omit-reverse-conflict log hash",
    "cancel-peer-after-refusal log hash",
    "rollback-refused-prefix-at-join log hash",
    "replace-merge-with-left-world log hash",
    "double-initial-balances log hash",
    "leak-peer-output-history log hash",
    "reuse-left-trusted-boundary log hash",
    "drop-peer-supply-receipts log hash",
    "reuse-live-capability-store log hash",
    "stale-intra-branch-evaluation log hash",
    "lean/DefiKernel/Parallel/Compatibility.lean input hash",
    "lean/DefiKernel/Composition/Execution.lean input hash",
    "lean/DefiKernel/Composition/Interfaces.lean input hash",
    "lean/DefiKernel/Typed/Transition.lean input hash",
    "lean/DefiKernel/Typed/Expr.lean input hash",
    "lean/DefiKernel/Typed/Types.lean input hash",
    "lean/DefiKernel/Typed/Authority.lean input hash",
    "lean/DefiKernel/Composition/Contracts.lean input hash",
    "lean/DefiKernel/Parallel/Observation.lean input hash",
    "lean/DefiKernel/Composition/Sequence.lean input hash",
    "lean/DefiKernel/Parallel/Execution.lean input hash",
    "lean/DefiKernel/Parallel/Preservation.lean input hash",
    "lean/DefiKernel/Parallel/Commutation.lean input hash",
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean input hash",
    "lean/DefiKernel/Parallel/Dependency.lean input hash",
    "lean/DefiKernel/Composition/Preservation.lean input hash",
    "lean/DefiKernel/Parallel/Audit.lean input hash",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean input hash",
    "lean/DefiKernel/Composition/Examples.lean input hash",
    "lean/DefiKernel/Typed/Examples.lean input hash",
    "lean/DefiKernel/Parallel/ObservationTests.lean input hash",
    "lean/DefiKernel/Parallel/ExecutionTests.lean input hash",
    "lean/DefiKernel/Parallel/Tests.lean input hash",
    "lean/DefiKernel/Parallel/Examples.lean input hash",
    "lean/lean-toolchain input hash",
    "lean/lake-manifest.json input hash",
    "lean/lakefile.toml input hash",
    "all source hashes unchanged",
    "all replay unchanged flags",
    "current runner source binding",
    "runner snapshot source binding",
    "canonical/captured spec binding",
    "committed input paths clean at run start",
    "control generated source hash",
    "bypass-write-write-composite generated source hash",
    "bypass-write-write-composite failed runtime exit",
    "bypass-write-write-composite complete131 inventory",
    "bypass-write-write-composite designated false comparisons",
    "bypass-write-write-composite protected5true",
    "omit-expression-reads-composite generated source hash",
    "omit-expression-reads-composite failed runtime exit",
    "omit-expression-reads-composite complete131 inventory",
    "omit-expression-reads-composite designated false comparisons",
    "omit-expression-reads-composite protected5true",
    "omit-output-dependency generated source hash",
    "omit-output-dependency failed runtime exit",
    "omit-output-dependency complete131 inventory",
    "omit-output-dependency designated false comparisons",
    "omit-output-dependency protected5true",
    "omit-zero-delta-target generated source hash",
    "omit-zero-delta-target failed runtime exit",
    "omit-zero-delta-target complete131 inventory",
    "omit-zero-delta-target designated false comparisons",
    "omit-zero-delta-target protected5true",
    "omit-reverse-conflict generated source hash",
    "omit-reverse-conflict failed runtime exit",
    "omit-reverse-conflict complete131 inventory",
    "omit-reverse-conflict designated false comparisons",
    "omit-reverse-conflict protected5true",
    "cancel-peer-after-refusal generated source hash",
    "cancel-peer-after-refusal failed runtime exit",
    "cancel-peer-after-refusal complete131 inventory",
    "cancel-peer-after-refusal designated false comparisons",
    "cancel-peer-after-refusal protected5true",
    "rollback-refused-prefix-at-join generated source hash",
    "rollback-refused-prefix-at-join failed runtime exit",
    "rollback-refused-prefix-at-join complete131 inventory",
    "rollback-refused-prefix-at-join designated false comparisons",
    "rollback-refused-prefix-at-join protected5true",
    "replace-merge-with-left-world generated source hash",
    "replace-merge-with-left-world failed runtime exit",
    "replace-merge-with-left-world complete131 inventory",
    "replace-merge-with-left-world designated false comparisons",
    "replace-merge-with-left-world protected5true",
    "double-initial-balances generated source hash",
    "double-initial-balances failed runtime exit",
    "double-initial-balances complete131 inventory",
    "double-initial-balances designated false comparisons",
    "double-initial-balances protected5true",
    "leak-peer-output-history generated source hash",
    "leak-peer-output-history failed runtime exit",
    "leak-peer-output-history complete131 inventory",
    "leak-peer-output-history designated false comparisons",
    "leak-peer-output-history protected5true",
    "reuse-left-trusted-boundary generated source hash",
    "reuse-left-trusted-boundary failed runtime exit",
    "reuse-left-trusted-boundary complete131 inventory",
    "reuse-left-trusted-boundary designated false comparisons",
    "reuse-left-trusted-boundary protected5true",
    "drop-peer-supply-receipts generated source hash",
    "drop-peer-supply-receipts failed runtime exit",
    "drop-peer-supply-receipts complete131 inventory",
    "drop-peer-supply-receipts designated false comparisons",
    "drop-peer-supply-receipts protected5true",
    "reuse-live-capability-store generated source hash",
    "reuse-live-capability-store failed runtime exit",
    "reuse-live-capability-store complete131 inventory",
    "reuse-live-capability-store designated false comparisons",
    "reuse-live-capability-store protected5true",
    "stale-intra-branch-evaluation generated source hash",
    "stale-intra-branch-evaluation failed runtime exit",
    "stale-intra-branch-evaluation complete131 inventory",
    "stale-intra-branch-evaluation designated false comparisons",
    "stale-intra-branch-evaluation protected5true",
    "earlier passed replay same source bytes",
    "earlier passed replay same generated sources/check results",
    "control supplemental diagnostic exact final source binding",
    "leak-peer-output-history supplemental diagnostic exact final source binding",
    "lean/DefiKernel/Parallel/Compatibility.lean committed Git object binding",
    "lean/DefiKernel/Composition/Execution.lean committed Git object binding",
    "lean/DefiKernel/Composition/Interfaces.lean committed Git object binding",
    "lean/DefiKernel/Typed/Transition.lean committed Git object binding",
    "lean/DefiKernel/Typed/Expr.lean committed Git object binding",
    "lean/DefiKernel/Typed/Types.lean committed Git object binding",
    "lean/DefiKernel/Typed/Authority.lean committed Git object binding",
    "lean/DefiKernel/Composition/Contracts.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Observation.lean committed Git object binding",
    "lean/DefiKernel/Composition/Sequence.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Execution.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Preservation.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Commutation.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Dependency.lean committed Git object binding",
    "lean/DefiKernel/Composition/Preservation.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Audit.lean committed Git object binding",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean committed Git object binding",
    "lean/DefiKernel/Composition/Examples.lean committed Git object binding",
    "lean/DefiKernel/Typed/Examples.lean committed Git object binding",
    "lean/DefiKernel/Parallel/ObservationTests.lean committed Git object binding",
    "lean/DefiKernel/Parallel/ExecutionTests.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Tests.lean committed Git object binding",
    "lean/DefiKernel/Parallel/Examples.lean committed Git object binding",
    "lean/lean-toolchain committed Git object binding",
    "lean/lake-manifest.json committed Git object binding",
    "lean/lakefile.toml committed Git object binding",
    "scripts/check_parallel_mutations.py committed Git object binding",
    "review/semantic-kernel/sprint6/mutation-spec.json committed Git object binding",
    "scripts/test_parallel_mutation_runner.py committed Git object binding"
  ]
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/git-object-binding.json
SHA256 8232eae2426308edc8cdcc4150e3d16f60977ad3fd29d969f307f0cd46445274
```
{
  "git_head": "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d",
  "files": 30,
  "all_match": true,
  "bindings": [
    {
      "path": "lean/DefiKernel/Parallel/Compatibility.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Compatibility.lean"
      ],
      "exit": 0,
      "sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
      "matched_executed_sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243"
    },
    {
      "path": "lean/DefiKernel/Composition/Execution.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Execution.lean"
      ],
      "exit": 0,
      "sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "matched_executed_sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602"
    },
    {
      "path": "lean/DefiKernel/Composition/Interfaces.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Interfaces.lean"
      ],
      "exit": 0,
      "sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "matched_executed_sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe"
    },
    {
      "path": "lean/DefiKernel/Typed/Transition.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Typed/Transition.lean"
      ],
      "exit": 0,
      "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "matched_executed_sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"
    },
    {
      "path": "lean/DefiKernel/Typed/Expr.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Typed/Expr.lean"
      ],
      "exit": 0,
      "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "matched_executed_sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"
    },
    {
      "path": "lean/DefiKernel/Typed/Types.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Typed/Types.lean"
      ],
      "exit": 0,
      "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "matched_executed_sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"
    },
    {
      "path": "lean/DefiKernel/Typed/Authority.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Typed/Authority.lean"
      ],
      "exit": 0,
      "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "matched_executed_sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"
    },
    {
      "path": "lean/DefiKernel/Composition/Contracts.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Contracts.lean"
      ],
      "exit": 0,
      "sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
      "matched_executed_sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c"
    },
    {
      "path": "lean/DefiKernel/Parallel/Observation.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Observation.lean"
      ],
      "exit": 0,
      "sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
      "matched_executed_sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f"
    },
    {
      "path": "lean/DefiKernel/Composition/Sequence.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Sequence.lean"
      ],
      "exit": 0,
      "sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "matched_executed_sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729"
    },
    {
      "path": "lean/DefiKernel/Parallel/Execution.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Execution.lean"
      ],
      "exit": 0,
      "sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
      "matched_executed_sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089"
    },
    {
      "path": "lean/DefiKernel/Parallel/Preservation.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Preservation.lean"
      ],
      "exit": 0,
      "sha256": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
      "matched_executed_sha256": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10"
    },
    {
      "path": "lean/DefiKernel/Parallel/Commutation.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Commutation.lean"
      ],
      "exit": 0,
      "sha256": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
      "matched_executed_sha256": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef"
    },
    {
      "path": "lean/DefiKernel/Parallel/Dependency/Adapter.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Dependency/Adapter.lean"
      ],
      "exit": 0,
      "sha256": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
      "matched_executed_sha256": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c"
    },
    {
      "path": "lean/DefiKernel/Parallel/Dependency.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Dependency.lean"
      ],
      "exit": 0,
      "sha256": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
      "matched_executed_sha256": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245"
    },
    {
      "path": "lean/DefiKernel/Composition/Preservation.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Preservation.lean"
      ],
      "exit": 0,
      "sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
      "matched_executed_sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709"
    },
    {
      "path": "lean/DefiKernel/Parallel/Audit.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Audit.lean"
      ],
      "exit": 0,
      "sha256": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
      "matched_executed_sha256": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9"
    },
    {
      "path": "lean/DefiKernel/Parallel/CompatibilityTests.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/CompatibilityTests.lean"
      ],
      "exit": 0,
      "sha256": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
      "matched_executed_sha256": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379"
    },
    {
      "path": "lean/DefiKernel/Composition/Examples.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Composition/Examples.lean"
      ],
      "exit": 0,
      "sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
      "matched_executed_sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064"
    },
    {
      "path": "lean/DefiKernel/Typed/Examples.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Typed/Examples.lean"
      ],
      "exit": 0,
      "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
      "matched_executed_sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41"
    },
    {
      "path": "lean/DefiKernel/Parallel/ObservationTests.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/ObservationTests.lean"
      ],
      "exit": 0,
      "sha256": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
      "matched_executed_sha256": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e"
    },
    {
      "path": "lean/DefiKernel/Parallel/ExecutionTests.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/ExecutionTests.lean"
      ],
      "exit": 0,
      "sha256": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
      "matched_executed_sha256": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99"
    },
    {
      "path": "lean/DefiKernel/Parallel/Tests.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Tests.lean"
      ],
      "exit": 0,
      "sha256": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
      "matched_executed_sha256": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725"
    },
    {
      "path": "lean/DefiKernel/Parallel/Examples.lean",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/DefiKernel/Parallel/Examples.lean"
      ],
      "exit": 0,
      "sha256": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
      "matched_executed_sha256": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd"
    },
    {
      "path": "lean/lean-toolchain",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/lean-toolchain"
      ],
      "exit": 0,
      "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "matched_executed_sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"
    },
    {
      "path": "lean/lake-manifest.json",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/lake-manifest.json"
      ],
      "exit": 0,
      "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "matched_executed_sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"
    },
    {
      "path": "lean/lakefile.toml",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:lean/lakefile.toml"
      ],
      "exit": 0,
      "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "matched_executed_sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
    },
    {
      "path": "scripts/check_parallel_mutations.py",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:scripts/check_parallel_mutations.py"
      ],
      "exit": 0,
      "sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
      "matched_executed_sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0"
    },
    {
      "path": "review/semantic-kernel/sprint6/mutation-spec.json",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:review/semantic-kernel/sprint6/mutation-spec.json"
      ],
      "exit": 0,
      "sha256": "5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35",
      "matched_executed_sha256": "5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35"
    },
    {
      "path": "scripts/test_parallel_mutation_runner.py",
      "command": [
        "git",
        "show",
        "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d:scripts/test_parallel_mutation_runner.py"
      ],
      "exit": 0,
      "sha256": "14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79",
      "matched_executed_sha256": "14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79"
    }
  ]
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/final-fae07ca/cli.log
SHA256 bf64f0ef129c6c012aee0da0243ff00bdd1feab3b308d489353e66cf696332e2
```
control: exit=0; comparisons=131; false=[]
bypass-write-write-composite: exit=1; comparisons=131; false=['parallel.compat.first-list-witness', 'parallel.compat.forward-before-reverse', 'parallel.compat.forward-read', 'parallel.compat.hidden-delta', 'parallel.compat.hidden-inactive-guard', 'parallel.compat.hidden-supply', 'parallel.compat.output-dependency', 'parallel.compat.reverse-read', 'parallel.compat.unreachable-suffix', 'parallel.compat.write-write-witness', 'parallel.compat.zero-target', 'parallel.fixture.cancelling.admission', 'parallel.fixture.refusal.world-preserved', 'parallel.refused.conflict-unchanged']
omit-expression-reads-composite: exit=1; comparisons=131; false=['parallel.compat.common-read-no-writes', 'parallel.compat.delta-read-exact', 'parallel.compat.forward-read', 'parallel.compat.guard-read-exact', 'parallel.compat.hidden-delta', 'parallel.compat.hidden-inactive-guard', 'parallel.compat.hidden-supply', 'parallel.compat.reverse-read', 'parallel.compat.supply-read-exact']
omit-output-dependency: exit=1; comparisons=131; false=['parallel.compat.output-dependency', 'parallel.compat.output-exact']
omit-zero-delta-target: exit=1; comparisons=131; false=['parallel.compat.capability-not-evaluated', 'parallel.compat.delta-read-exact', 'parallel.compat.guard-read-exact', 'parallel.compat.independent', 'parallel.compat.invocation-exact-left', 'parallel.compat.invocation-exact-right', 'parallel.compat.left-empty', 'parallel.compat.numeric-input-not-evaluated', 'parallel.compat.output-exact', 'parallel.compat.prior-output-not-evaluated', 'parallel.compat.supply-read-exact', 'parallel.compat.zero-target', 'parallel.compat.zero-target-exact', 'parallel.fixture.cancelling.admission']
omit-reverse-conflict: exit=1; comparisons=131; false=['parallel.compat.reverse-read']
cancel-peer-after-refusal: exit=1; comparisons=131; false=['parallel.fixture.refusal.dual', 'parallel.fixture.refusal.guard', 'parallel.fixture.refusal.input-unit', 'parallel.fixture.refusal.missing-capability', 'parallel.fixture.refusal.peer-runs', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.peer-only', 'parallel.fixture.stateful.prefix', 'parallel.fixture.supply.prefix-refusal']
rollback-refused-prefix-at-join: exit=1; comparisons=131; false=['parallel.fixture.refusal.dual', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.peer-only', 'parallel.fixture.stateful.prefix', 'parallel.fixture.supply.prefix-refusal']
replace-merge-with-left-world: exit=1; comparisons=131; false=['parallel.fixture.basic.complete', 'parallel.fixture.boundary.local-identity', 'parallel.fixture.capability.reusable-shared-grant', 'parallel.fixture.empty.left', 'parallel.fixture.raw-context-differs', 'parallel.fixture.refusal.dual', 'parallel.fixture.refusal.guard', 'parallel.fixture.refusal.input-unit', 'parallel.fixture.refusal.missing-capability', 'parallel.fixture.refusal.peer-runs', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.both-own-history', 'parallel.fixture.routing.funded-literal', 'parallel.fixture.routing.own-history', 'parallel.fixture.routing.peer-only', 'parallel.fixture.same-asset.complete', 'parallel.fixture.stateful.prefix', 'parallel.fixture.stateful.supply', 'parallel.fixture.supply.complete', 'parallel.fixture.supply.prefix-refusal']
double-initial-balances: exit=1; comparisons=131; false=['parallel.empty', 'parallel.empty.lr', 'parallel.empty.rl', 'parallel.fixture.basic.complete', 'parallel.fixture.boundary.local-identity', 'parallel.fixture.cancelling.funded', 'parallel.fixture.capability.reusable-shared-grant', 'parallel.fixture.capability.revoked', 'parallel.fixture.empty.both', 'parallel.fixture.empty.left', 'parallel.fixture.empty.right', 'parallel.fixture.raw-context-differs', 'parallel.fixture.refusal.dual', 'parallel.fixture.refusal.guard', 'parallel.fixture.refusal.input-unit', 'parallel.fixture.refusal.missing-capability', 'parallel.fixture.refusal.peer-runs', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.both-own-history', 'parallel.fixture.routing.funded-literal', 'parallel.fixture.routing.own-history', 'parallel.fixture.routing.peer-only', 'parallel.fixture.routing.shared-qualified-key', 'parallel.fixture.same-asset.complete', 'parallel.fixture.stateful.prefix', 'parallel.fixture.stateful.supply', 'parallel.fixture.supply.complete', 'parallel.fixture.supply.prefix-refusal']
leak-peer-output-history: exit=1; comparisons=131; false=['parallel.fixture.basic.complete', 'parallel.fixture.boundary.local-identity', 'parallel.fixture.empty.left', 'parallel.fixture.raw-context-differs', 'parallel.fixture.refusal.dual', 'parallel.fixture.refusal.guard', 'parallel.fixture.refusal.input-unit', 'parallel.fixture.refusal.missing-capability', 'parallel.fixture.refusal.peer-runs', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.both-own-history', 'parallel.fixture.routing.funded-literal', 'parallel.fixture.routing.own-history', 'parallel.fixture.routing.peer-only', 'parallel.fixture.routing.shared-qualified-key', 'parallel.fixture.same-asset.complete', 'parallel.fixture.stateful.prefix', 'parallel.fixture.stateful.supply', 'parallel.fixture.supply.complete', 'parallel.fixture.supply.prefix-refusal']
reuse-left-trusted-boundary: exit=1; comparisons=131; false=['parallel.fixture.boundary.local-identity']
drop-peer-supply-receipts: exit=1; comparisons=131; false=['parallel.fixture.supply.both-receipts']
reuse-live-capability-store: exit=1; comparisons=131; false=['parallel.fixture.capability.revoked']
stale-intra-branch-evaluation: exit=1; comparisons=131; false=['parallel.fixture.both-own-history.lr.complete', 'parallel.fixture.both-own-history.rl.complete', 'parallel.fixture.boundary.local-identity', 'parallel.fixture.boundary.lr.complete', 'parallel.fixture.boundary.rl.complete', 'parallel.fixture.dual.lr.complete', 'parallel.fixture.dual.rl.complete', 'parallel.fixture.prefix.lr.complete', 'parallel.fixture.prefix.rl.complete', 'parallel.fixture.refusal.dual', 'parallel.fixture.refusal.prefix-kept', 'parallel.fixture.routing.both-own-history', 'parallel.fixture.routing.funded-literal', 'parallel.fixture.routing.lr.complete', 'parallel.fixture.routing.own-history', 'parallel.fixture.routing.peer-only', 'parallel.fixture.routing.rl.complete', 'parallel.fixture.stateful-supply.lr.complete', 'parallel.fixture.stateful-supply.rl.complete', 'parallel.fixture.stateful.lr.complete', 'parallel.fixture.stateful.prefix', 'parallel.fixture.stateful.rl.complete', 'parallel.fixture.stateful.supply', 'parallel.fixture.supply-prefix.lr.complete', 'parallel.fixture.supply-prefix.rl.complete', 'parallel.fixture.supply.prefix-refusal']
DISCRIMINATES: 14 mutants and one nonempty unchanged control

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/report.md
SHA256 2c472e82bef6192ee95d90d45ce7b85f37271a05fbf4104eb57392ad47b56f83
```
Final production replay at `fae07caa2620c7a1d4ba1a39cb9a9be171ff137d` passed: **14 of 14 actual
source mutants detected**, with 131 true comparisons in the unchanged control,
131 comparisons in every mutant, and all five protected comparisons true in every
variant. The accepted main replay executed 1,965 named comparisons across its
control and 14 mutants. These counts describe bounded execution sensitivity;
they are not counts of mathematical proofs or deployed-contract validation.

The accepted command ran from `/home/charl/defiformal` and exited 0:

```sh
python3 scripts/check_parallel_mutations.py --repo . --spec review/semantic-kernel/sprint6/mutation-spec.json --out /tmp/sprint6-production-final-fae07ca
```

The [final summary](final-fae07ca/summary.json),
[complete command log](final-fae07ca/cli.log),
[per-variant results](final-fae07ca/results.json), and
[source manifest](final-fae07ca/source-manifest.json) retain the actual command,
exit, generated source hashes, all named observations, required false comparisons,
protected positives, input status, and tool identity. Each counted mutation applied
exactly once to the actual new implementation source, compiled and executed the
complete unique inventory, and produced only the expected runtime-comparison
failure. No compile-only failure, survivor, partial inventory, or failed protected
positive is counted as a detection.

The [canonical specification](../mutation-spec.json) has SHA-256
`5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35`. The executed runner has SHA-256
`415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0`. Lean reported `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`;
its executable SHA-256 is `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.
The capture contains 24 local source modules and three Lake/toolchain inputs.
All captured source, specification, and runner bytes remained unchanged throughout
replay. The scoped Git input status was empty at run start.

The [Git object binding](final-fae07ca/git-object-binding.json) independently
checks all 30 source/specification/script bindings against the observed committed
candidate. The [artifact integrity check](final-fae07ca/artifact-integrity.json)
passed 160 assertions with zero failures, including full log/input/generated-source
hashes, complete inventories, required false/protected true comparisons, and equality
with the earlier successful development replay's captured sources and results.

| Mutation | False comparisons | Required oracle observed false |
| --- | --- | --- |
| `bypass-write-write-composite` | 14 | `parallel.compat.write-write-witness` |
| `omit-expression-reads-composite` | 9 | `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-supply` |
| `omit-output-dependency` | 2 | `parallel.compat.output-dependency` |
| `omit-zero-delta-target` | 14 | `parallel.compat.zero-target`, `parallel.compat.zero-target-exact` |
| `omit-reverse-conflict` | 1 | `parallel.compat.reverse-read` |
| `cancel-peer-after-refusal` | 9 | `parallel.fixture.refusal.peer-runs` |
| `rollback-refused-prefix-at-join` | 5 | `parallel.fixture.refusal.prefix-kept` |
| `replace-merge-with-left-world` | 20 | `parallel.fixture.basic.complete` |
| `double-initial-balances` | 28 | `parallel.fixture.basic.complete` |
| `leak-peer-output-history` | 20 | `parallel.fixture.routing.peer-only` |
| `reuse-left-trusted-boundary` | 1 | `parallel.fixture.boundary.local-identity` |
| `drop-peer-supply-receipts` | 1 | `parallel.fixture.supply.both-receipts` |
| `reuse-live-capability-store` | 1 | `parallel.fixture.capability.revoked` |
| `stale-intra-branch-evaluation` | 26 | `parallel.fixture.stateful.prefix` |

The [mutation design record](mutation-design.md) documents the actual edit and
independent oracle for each of the 14 planned classes. The write/write bypass
is explicitly composite: writes also contribute to reads, so all three conflict
guards are removed together. The expression-read omission is also composite:
the admission collector loses syntactic and redundant declared reads, while the
registered template retains its valid declarations and successful underlying
executor controls. The target omission uses a zero delta absent from declared
writes; its funded underlying-kernel comparison remains protected and true.

The history mutant seeds the left consumer from right-branch outputs. A
[supplemental captured-source diagnostic](history-diagnostics/results.json)
confirms the intended behavioral distinction. In the control, the left branch
refuses at local index 1 with Alice/Bob USD balances 7/3. Under the mutation, the
same consumer succeeds, reaches local index 2, and leaves balances 2/8 after using
the peer's USD5 output. This rules out relying only on an incidental extra-output
mismatch. The diagnostic base hashes match the final accepted control and mutant
source hashes; the supplemental runs add no counted mutation detections.

The stateful mutant changes intra-branch evaluation to use the original world at
every step. Its designated oracle checks independently expected state-dependent
effects, accepted prefix, exact refusal, receipts, outputs and complete final
world. It does not substitute a cached serial result for actual branch execution.
The boundary, dropped-peer-supply and stale-capability mutants each fail exactly
one designated comparison. Their bounded fixtures use distinct trusted boundaries,
independent USD2/share-3 receipt totals, and an actually revoked right-side grant.

The final [runner CLI controls](../runner-controls/final-fae07ca/summary.json)
passed 45 of 45 cases at the same commit: five accepted toy runs, four expected
assertion failures, and 36 expected blocked cases. Their
[integrity check](../runner-controls/final-fae07ca/artifact-integrity.json) passed
470 assertions, including exact committed runner/harness bytes. The
[runner report](../mutation-runner-report.md) records malformed/empty/duplicate/
partial inventory, real stale-cache, edit, compile, survivor, positive-control,
output-location, and compiler-warning controls.

The first production attempt remains under
[development-blocked-r1](development-blocked-r1/cli.log). Its control passed, but
the runner mistook Lean unused-variable diagnostic continuations for observation
labels and blocked the first mutant. It contributes zero accepted detections.
A real warning-producing toy test reproduced the problem; the corrected runner
passes that control while continuing to reject malformed uppercase labels.
The earlier successful development replay remains in this directory's root files;
`final-fae07ca/` is the final committed-candidate acceptance bundle. Raw earlier
logs/manifests were retained without rewriting their original heads or paths.

Accepted financial and proof source files were never edited by the mutations.
The runner captures fresh local dependency source and excludes only new Parallel
proof suffixes from temporary executable projections. Full kernel proofs, imported
axiom coverage, scenario completeness and native review are separate acceptance
evidence. The probes establish sensitivity of these exact rational reference
examples and checks, not maximal parallelism, liveness, generic solvency, machine
arithmetic, or deployed protocol fidelity.

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/mutation-design.md
SHA256 96f8cb302bbfd70b5892fcf6bfef3793e329c8fda5587076121e710ed1f44990
```
This document records the intended mechanism and oracle for each actual source edit in
[the canonical manifest](../mutation-spec.json). It is a mutation design record, not
an execution verdict. Accepted production results require the complete runner artifacts.

| Plan class | Mutation | Source module | Required false comparisons |
| --- | --- | --- | --- |
| 1 | `bypass-write-write-composite` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.write-write-witness` |
| 2 | `omit-expression-reads-composite` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-supply` |
| 3 | `omit-output-dependency` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.output-dependency` |
| 4 | `omit-zero-delta-target` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.zero-target`, `parallel.compat.zero-target-exact` |
| 5 | `omit-reverse-conflict` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.reverse-read` |
| 6 | `cancel-peer-after-refusal` | `DefiKernel.Parallel.Execution` | `parallel.fixture.refusal.peer-runs` |
| 7 | `rollback-refused-prefix-at-join` | `DefiKernel.Parallel.Execution` | `parallel.fixture.refusal.prefix-kept` |
| 8 | `replace-merge-with-left-world` | `DefiKernel.Parallel.Execution` | `parallel.fixture.basic.complete` |
| 9 | `double-initial-balances` | `DefiKernel.Parallel.Execution` | `parallel.fixture.basic.complete` |
| 10 | `leak-peer-output-history` | `DefiKernel.Parallel.Execution` | `parallel.fixture.routing.peer-only` |
| 11 | `reuse-left-trusted-boundary` | `DefiKernel.Parallel.Execution` | `parallel.fixture.boundary.local-identity` |
| 12 | `drop-peer-supply-receipts` | `DefiKernel.Parallel.Preservation` | `parallel.fixture.supply.both-receipts` |
| 13 | `reuse-live-capability-store` | `DefiKernel.Parallel.Execution` | `parallel.fixture.capability.revoked` |
| 14 | `stale-intra-branch-evaluation` | `DefiKernel.Parallel.Execution` | `parallel.fixture.stateful.prefix` |

All variants protect the following actual underlying-executor or catalog checks:

- `parallel.compat.catalog-positive`
- `parallel.compat.funded-left-complete`
- `parallel.compat.funded-right-complete`
- `parallel.compat.zero-target-funded`
- `parallel.compat.hidden-inactive-guard-funded`

1. Composite admission weakening: replace all three ordered conflict guards with acceptance. Writes are also reads, so deleting only the write/write guard would leave both cross-read guards. The oracle still names the required write/write witness; unrelated funded execution controls remain protected.

2. Composite read-collector omission: replace requiredStateReads plus declared stateReads with an empty resolved read list. The registered template retains valid declared reads and the old kernel still checks them; only new admission loses both redundant sources. Three independent negatives cover hidden guard, delta, and supply reads, with successful underlying-kernel siblings.

3. Remove selected output cells from admission reads. The output snapshot is an implicit dependency even when the financial expression does not read that cell. The underlying output-producing operation remains funded and authorized.

4. Remove delta targets from prospective writes, which also removes their contribution to target-balance reads through the shared writes list. The designated fixture has a literal zero delta at Alice USD and no declared writes or reads. Its underlying kernel execution succeeds; no malformed-footprint refusal is counted as the oracle.

5. Remove only the reverse-direction overlap test. The fixture has a left reader and right writer with disjoint writes, so neither prior ordered guard masks this error.

6. After a left branch refusal, replace the right invocation list with the empty branch. The independent oracle requires the peer to run and preserve its real outcome.

7. At join only, replace a refused left branch world with the initial world. The independent oracle requires a successful prefix to remain committed even when its following invocation refuses.

8. Replace the region-based merged world with the entire left world. The full finite-world oracle includes independent nonzero right-side effects.

9. Add the two entire nonnegative branch ledgers, retaining the initial store. Both ledgers include the common base, so the complete-world oracle detects doubled initial balances. The replacement includes an ordinary sum-nonnegativity proof and must compile before counting.

10. Execute the right branch first and seed the left branch cursor with right outputs while retaining left local positions and boundaries. The left consumer can now use the peer-only qualified key and complete a funded transfer instead of its required unavailable-output refusal. The peer-only-history fixture needs an absent own-history key; equal-valued shared keys alone cannot justify detection.

11. Execute the right branch with the left trusted boundary function. Admission remains unchanged; the independent fixture must distinguish branch principals/time at local positions.

12. Drop the right traceSupply term from the actual Joined.supply runtime aggregate. The designated oracle compares both asset-indexed supplies with independent expected amounts.

13. Run the right branch with the same capability entries and IDs but revive every live flag. This represents a stale live store before revocation; the designated right-revoked oracle must observe refusal using the actual initial store.

14. Change runBranch to advance each invocation against the original branch world, while retaining its accumulated cursor metadata. A second state-dependent step therefore evaluates stale balances rather than its successful prefix. The designated oracle is the independently expected intra-branch stateful result, not equality of cached serial executions.

The threat model is implementation mistakes in the new Parallel computation. Mutation
edits are applied only to captured scratch source; historical implementation and accepted
proof files remain unchanged. Proof suffixes are omitted from these executable probes,
so a detected mutant is bounded sensitivity evidence, not a proof of the mutated program
or the full serial correspondence law. Compile-only failures, missing edits, survivors,
incomplete inventories and failed protected positives cannot be counted as detections.

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/history-diagnostics/results.json
SHA256 f1d4e28a9662876f7226fd69f233b5ba6e4f20079b7697f1d356e9bb2c8610f8
```
[
  {
    "variant": "control",
    "command": [
      "lake",
      "env",
      "lean",
      "/tmp/sprint6-history-diagnostics-20260906/control.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 0,
    "expected_exit": 0,
    "expected_diagnostic": "DIAGNOSTIC peer-only left_failure=true next_index=1 alice_usd=7 bob_usd=3",
    "diagnostic_lines": [
      "DIAGNOSTIC peer-only left_failure=true next_index=1 alice_usd=7 bob_usd=3"
    ],
    "passed": true,
    "base_fixture_sha256": "050277c93b4e6176f6fc6945cec018be28c55ddcc3f5c7c14fd6e675cf03cbdc",
    "fixture_sha256": "bf41e112e385df0e3291de9d20dde092b261100dcc8dfb547c0fd7f826d656d9",
    "log_sha256": "738a48295d6099bab33768540371cb10b7b8431b9c38fdb0f8bdcad27eedad44"
  },
  {
    "variant": "leak-peer-output-history",
    "command": [
      "lake",
      "env",
      "lean",
      "/tmp/sprint6-history-diagnostics-20260906/leak-peer-output-history.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 1,
    "expected_exit": 1,
    "expected_diagnostic": "DIAGNOSTIC peer-only left_failure=false next_index=2 alice_usd=2 bob_usd=8",
    "diagnostic_lines": [
      "DIAGNOSTIC peer-only left_failure=false next_index=2 alice_usd=2 bob_usd=8"
    ],
    "passed": true,
    "base_fixture_sha256": "6b5656fe4dea05185b541dbb96ddfbe292854e61718aa5c594d59cdaf8153bc1",
    "fixture_sha256": "a07b0a6d1f9be75242a57f2d0800aa2f266844158a0133e3dcbbdbbe261e889a",
    "log_sha256": "06d2113663492b9dcd43e058d6f17945edae05d2f8a4a56826718aeb4f9e2ea8"
  }
]

```

### EVIDENCE review/semantic-kernel/sprint6/mutations/history-diagnostics/scope.json
SHA256 52d5499c925991f14cfb6549f3f6d4448d002a444733e49b12dc746bfdde6f5c
```
{
  "kind": "supplemental-captured-source-history-diagnostic",
  "accepted_mutation_count_contribution": 0,
  "base_fixture_hashes_match_production_results": true,
  "purpose": "Distinguish the intended peer-only history refusal bypass from an incidental extra-output mismatch. Sources append a diagnostic to exact captured control/mutant source; original full131comparison audit still executes.",
  "observed_control": "left failure true, next local index1, AliceUSD7/BobUSD3",
  "observed_mutant": "left failure false, next local index2, AliceUSD2/BobUSD8"
}

```

### EVIDENCE review/semantic-kernel/sprint6/runner-controls/final-fae07ca/summary.json
SHA256 20c2f8cf95edc22334a71394f496a4d9c2a2d80df3a78d97a196913e4c36f79a
```
{
  "schema_version": 1,
  "kind": "executed-cli-runner-controls",
  "started_utc": "2026-09-07T05:43:13.634305+00:00",
  "finished_utc": "2026-09-07T05:44:17.578462+00:00",
  "source_repo": "/home/charl/defiformal",
  "git_head": "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d",
  "runner_source": "/home/charl/defiformal/scripts/check_parallel_mutations.py",
  "runner_sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
  "harness_source": "/home/charl/defiformal/scripts/test_parallel_mutation_runner.py",
  "harness_sha256": "14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79",
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
      "log_sha256": "38d197852c858d322d65d4cdba4ba17d72b666a05e05e685649f0f160fde4ef5"
    }
  ],
  "fixture_scope": "Synthetic development Lean computations; actual CLI and installed Lean/mathlib. No subprocess mocks; no production theorem claim.",
  "fixture_dependency_sha256": "a55de86192462c1deab9d024b263dac81a527439579ee78b076627b0ee26b425",
  "fixture_input_sha256": "54538f3189277219aab03291fb7db5c83865cc2f46dea6018be48ac6e1d3dd44",
  "fixture_audit_template_sha256": "531102a4fdd7fbe89b5a6dd12ab233bda76a31e13585b47c6a5c918b59dad237",
  "total": 45,
  "passed": 45,
  "cases": [
    {
      "name": "live-discriminating-mutant",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/live-discriminating-mutant-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/live-discriminating-mutant"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 4.036887,
      "log": "/tmp/sprint6-controls-final-fae07ca/live-discriminating-mutant.log",
      "log_sha256": "a105fea8d0e70f6920274a051b99f157115a6e0de8763d1530ef79b3560dd925",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/live-discriminating-mutant/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "e89cdb7da07ce9d404521fa0c66cdda269c50b0aefe66762ae32e23c50e6a87a"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/live-discriminating-mutant/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/live-discriminating-mutant/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "e89cdb7da07ce9d404521fa0c66cdda269c50b0aefe66762ae32e23c50e6a87a"
        }
      ]
    },
    {
      "name": "dotted-comparisons",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/dotted-comparisons-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/dotted-comparisons"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 2.960405,
      "log": "/tmp/sprint6-controls-final-fae07ca/dotted-comparisons.log",
      "log_sha256": "aff5df5522e4898e50d0182aa13fcfe14632674d598a71c7d4483891a1c52f05",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner.sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "04bd1e587db6aa0f15d8be004df599fd8c9e60bb7d567378a6977a321ae187cc",
      "setup_records": [],
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner.positive",
              "true"
            ],
            [
              "runner.sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "03c63a1d6b37ea96123ccaaf4116f25c7b3aa603e7b568cb723cf843ed374254"
        },
        "probe": {
          "lines": [
            [
              "runner.positive",
              "true"
            ],
            [
              "runner.sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/sprint6-controls-final-fae07ca/runs/dotted-comparisons/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "92c80ba433e2f136fbd1c221d38664820d117fb067a637d3cfe54bab49d94bea"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/dotted-comparisons/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "03c63a1d6b37ea96123ccaaf4116f25c7b3aa603e7b568cb723cf843ed374254"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/dotted-comparisons/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "92c80ba433e2f136fbd1c221d38664820d117fb067a637d3cfe54bab49d94bea"
        }
      ]
    },
    {
      "name": "hyphenated-dotted-comparisons",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/hyphenated-dotted-comparisons-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/hyphenated-dotted-comparisons"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 2.982785,
      "log": "/tmp/sprint6-controls-final-fae07ca/hyphenated-dotted-comparisons.log",
      "log_sha256": "1b896f87e1124b9e3b492b536e3efc13ca59d01c8b51701004525efa8e394c1a",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner.expected-failure']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "89ada708b7c2c9e810cd3ff109b664b61a518cf9cfb59bf6a549bc5632444c19",
      "setup_records": [],
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner.permitted-sibling",
              "true"
            ],
            [
              "runner.expected-failure",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "f60b9e6dc95fab3863fbd6a121fc795303dab293e384b11f168690139c62c008"
        },
        "probe": {
          "lines": [
            [
              "runner.permitted-sibling",
              "true"
            ],
            [
              "runner.expected-failure",
              "false"
            ]
          ],
          "errors": [
            "/tmp/sprint6-controls-final-fae07ca/runs/hyphenated-dotted-comparisons/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "f1e0c71ddd51382f4a78cc5dfd52899f9fc004e2f43a5a1be381d6ea85c65c75"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/hyphenated-dotted-comparisons/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "f60b9e6dc95fab3863fbd6a121fc795303dab293e384b11f168690139c62c008"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/hyphenated-dotted-comparisons/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "f1e0c71ddd51382f4a78cc5dfd52899f9fc004e2f43a5a1be381d6ea85c65c75"
        }
      ]
    },
    {
      "name": "empty-dot-segment-spec",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-dot-segment-spec-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-dot-segment-spec"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "invalid required check name",
      "passed": true,
      "elapsed_seconds": 0.054079,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-dot-segment-spec.log",
      "log_sha256": "966e944844462cbddf65d33d74cbadbbea4e3bc6ac1a80cbeb3ad2ce24a11e29",
      "cli_output": "BLOCKED: Blocked: invalid required check name\n",
      "spec_sha256": "a0c6c8e2a68e1e40659589f33f4b0b880b6ad3fd720b52fad9080041b0394bc0",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "trailing-dot-spec",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/trailing-dot-spec-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/trailing-dot-spec"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "invalid positive check name",
      "passed": true,
      "elapsed_seconds": 0.04483,
      "log": "/tmp/sprint6-controls-final-fae07ca/trailing-dot-spec.log",
      "log_sha256": "ef5aa9c54b3ed78a1b22014172138d894d5e9a4623c258e9e28f171d2b1b3395",
      "cli_output": "BLOCKED: Blocked: invalid positive check name\n",
      "spec_sha256": "41175ba61145e414ba348874328bf22264690b1d6f31462b84babd02e88472ef",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "leading-dot-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/leading-dot-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/leading-dot-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.437183,
      "log": "/tmp/sprint6-controls-final-fae07ca/leading-dot-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
          "log_sha256": "06f628fa0b931d1743b0ab456ab9aba890f8635d5e5277579e9ece68d2ab16fb"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/leading-dot-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "06f628fa0b931d1743b0ab456ab9aba890f8635d5e5277579e9ece68d2ab16fb"
        }
      ]
    },
    {
      "name": "empty-dot-segment-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-dot-segment-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-dot-segment-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.251161,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-dot-segment-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
          "log_sha256": "72bd1fedda0267be138240cb6585d909d4b7fc84067ab70a7c289e63a5b4dde8"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/empty-dot-segment-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "72bd1fedda0267be138240cb6585d909d4b7fc84067ab70a7c289e63a5b4dde8"
        }
      ]
    },
    {
      "name": "unused-variable-warning",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/unused-variable-warning-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/unused-variable-warning"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 3.170517,
      "log": "/tmp/sprint6-controls-final-fae07ca/unused-variable-warning.log",
      "log_sha256": "a105fea8d0e70f6920274a051b99f157115a6e0de8763d1530ef79b3560dd925",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "c7e94652aff7a0c8dc9ce31d1924fa2dfacfce810b2646cfe0a55766d0e9c183",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/unused-variable-warning/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "29de12a797f8173e99846a06ba5659226a9653372d25660f23ffe5f676eb0638"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/unused-variable-warning/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/unused-variable-warning/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "29de12a797f8173e99846a06ba5659226a9653372d25660f23ffe5f676eb0638"
        }
      ]
    },
    {
      "name": "uppercase-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/uppercase-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/uppercase-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.079833,
      "log": "/tmp/sprint6-controls-final-fae07ca/uppercase-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
          "log_sha256": "472467c0907ec8f6488b030157c21d6ab3d215bdf4089242da5d01757b42ebbc"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/uppercase-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "472467c0907ec8f6488b030157c21d6ab3d215bdf4089242da5d01757b42ebbc"
        }
      ]
    },
    {
      "name": "unknown-mutant-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/unknown-mutant-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/unknown-mutant-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "probe: partial execution",
      "passed": true,
      "elapsed_seconds": 3.271049,
      "log": "/tmp/sprint6-controls-final-fae07ca/unknown-mutant-observation.log",
      "log_sha256": "1b2f26f08958c0b94053bdcb2cac66d567c5f5ecd0d216175e35322af7bda456",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: partial execution\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
            ],
            [
              "runner_unknown",
              "true"
            ]
          ],
          "errors": [
            "/tmp/sprint6-controls-final-fae07ca/runs/unknown-mutant-observation/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "afb1e4e7d61ded33234b6ece847b51266a0bfe7dfd82d250e58280363a5c1df8"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/unknown-mutant-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/unknown-mutant-observation/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "afb1e4e7d61ded33234b6ece847b51266a0bfe7dfd82d250e58280363a5c1df8"
        }
      ]
    },
    {
      "name": "all-true-mutant",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/all-true-mutant-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/all-true-mutant"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "all comparisons still pass under mutation",
      "passed": true,
      "elapsed_seconds": 3.306679,
      "log": "/tmp/sprint6-controls-final-fae07ca/all-true-mutant.log",
      "log_sha256": "38f8e08aef294af4760b9555d61e5392846217162b0507fa1beae247ea37597e",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: all comparisons still pass under mutation\n",
      "spec_sha256": "22c986396edaa315ef461dcdf330845ce322cef892ef1c2306522b37c32e6a59",
      "setup_records": [],
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
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/all-true-mutant/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/all-true-mutant/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      ]
    },
    {
      "name": "required-observation-stays-true",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/required-observation-stays-true-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/required-observation-stays-true"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "required mutation not detected",
      "passed": true,
      "elapsed_seconds": 3.194684,
      "log": "/tmp/sprint6-controls-final-fae07ca/required-observation-stays-true.log",
      "log_sha256": "975e9350bce0153613f1588eb93b769a55756f271b64776b70b976ed8ef426e7",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: required mutation not detected\n",
      "spec_sha256": "bf2a8ab3c5f75fe1cbc6f385b4ccf3e11f6657bb9c424d22b8d761b45e918313",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/required-observation-stays-true/probe.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "901eed519c2913e8ffb4da4edb6cef4e0bded2b831f3a21fdbd18cd3b2c4f23a"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/required-observation-stays-true/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/required-observation-stays-true/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "901eed519c2913e8ffb4da4edb6cef4e0bded2b831f3a21fdbd18cd3b2c4f23a"
        }
      ]
    },
    {
      "name": "positive-control-flipped",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/positive-control-flipped-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/positive-control-flipped"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "positive control failed",
      "passed": true,
      "elapsed_seconds": 3.10855,
      "log": "/tmp/sprint6-controls-final-fae07ca/positive-control-flipped.log",
      "log_sha256": "da9befd494cab4f16f1f7c58114b37154bb033c544638a08afa1b5a27acf6c9a",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: positive control failed\n",
      "spec_sha256": "1b04cb0d56b807d3f9b75cf10e3ff378be7cb6612c9ad2e2ec02e25ee2a6ef25",
      "setup_records": [],
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
              "false"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/sprint6-controls-final-fae07ca/runs/positive-control-flipped/probe.lean:25:0: error: Parallel runtime comparisons failed: 2"
          ],
          "log_sha256": "66afce0471f4b87273297db03d322c87b1a9967042628d3dd8635c02055f9680"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/positive-control-flipped/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/positive-control-flipped/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "66afce0471f4b87273297db03d322c87b1a9967042628d3dd8635c02055f9680"
        }
      ]
    },
    {
      "name": "compilation-only-failure",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/compilation-only-failure-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/compilation-only-failure"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "failure is not solely the expected runtime comparison failure",
      "passed": true,
      "elapsed_seconds": 3.183467,
      "log": "/tmp/sprint6-controls-final-fae07ca/compilation-only-failure.log",
      "log_sha256": "ecc57092d68314b15394738f38d9c11dcf28542813ecba2db179f8fa3a9b9b97",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "spec_sha256": "35d5680761d8120a7af72be97fe2bf358bca433d1e5beda2cfd8408a40fa5e1c",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/compilation-only-failure/probe.lean:16:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`"
          ],
          "log_sha256": "0210a0e13e68329fca267c80646da0f54c73946b1b3f4a5f5869a5435dfe53e9"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/compilation-only-failure/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/compilation-only-failure/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "0210a0e13e68329fca267c80646da0f54c73946b1b3f4a5f5869a5435dfe53e9"
        }
      ]
    },
    {
      "name": "compiler-error-with-runtime-failure",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/compiler-error-with-runtime-failure-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/compiler-error-with-runtime-failure"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "failure is not solely the expected runtime comparison failure",
      "passed": true,
      "elapsed_seconds": 3.16643,
      "log": "/tmp/sprint6-controls-final-fae07ca/compiler-error-with-runtime-failure.log",
      "log_sha256": "ecc57092d68314b15394738f38d9c11dcf28542813ecba2db179f8fa3a9b9b97",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "spec_sha256": "8a72aa72b7f83fe489900937fdf121cbeb862db688d1a281245f947a1d5ab94d",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/compiler-error-with-runtime-failure/probe.lean:15:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`",
            "/tmp/sprint6-controls-final-fae07ca/runs/compiler-error-with-runtime-failure/probe.lean:26:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "6bdf9e2acf45fd994d1c1f2f8f717c631f08cb8086a004dde5f79f486a9f8332"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/compiler-error-with-runtime-failure/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/compiler-error-with-runtime-failure/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "6bdf9e2acf45fd994d1c1f2f8f717c631f08cb8086a004dde5f79f486a9f8332"
        }
      ]
    },
    {
      "name": "empty-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-observations-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: empty/duplicate observations",
      "passed": true,
      "elapsed_seconds": 2.162635,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-observations.log",
      "log_sha256": "fe24a498c94498911224a24b9bb556b5a975532fafc964f9e6aa4e6239e3e450",
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {
        "control": {
          "lines": [],
          "errors": [],
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/empty-observations/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
      ]
    },
    {
      "name": "duplicate-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-observations-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: empty/duplicate observations",
      "passed": true,
      "elapsed_seconds": 2.24798,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-observations.log",
      "log_sha256": "fe24a498c94498911224a24b9bb556b5a975532fafc964f9e6aa4e6239e3e450",
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-observations/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "641cc4bc3b894387e2dfab29ebeaca6646c337e912c0d89fced1e75d0864839c"
        }
      ]
    },
    {
      "name": "missing-positive-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-positive-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-positive-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: missing positive controls",
      "passed": true,
      "elapsed_seconds": 2.137034,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-positive-observation.log",
      "log_sha256": "3902aedfb8fa72bd61830a36294e361ef9b3733549da73bc3fd30bbc11d13e47",
      "cli_output": "BLOCKED: Blocked: control: missing positive controls\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/missing-positive-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "f1686d9b5d9174cd8c12ad7952022571dab902d541e6f3de5a0e5ef9a17f1302"
        }
      ]
    },
    {
      "name": "missing-required-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-required-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-required-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "probe: missing required observation in control",
      "passed": true,
      "elapsed_seconds": 2.172254,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-required-observation.log",
      "log_sha256": "97f7140dd95345df37e622d410d5e9ee924436af377e8f9ea8ef143ace1f8944",
      "cli_output": "BLOCKED: Blocked: probe: missing required observation in control\n",
      "spec_sha256": "2dd635ec423b4c8ee8bf38332e071e8b699e81e46170cf59cbd0a342277b7706",
      "setup_records": [],
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
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/missing-required-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      ]
    },
    {
      "name": "partial-mutant-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/partial-mutant-observations-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/partial-mutant-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "probe: partial execution",
      "passed": true,
      "elapsed_seconds": 3.185177,
      "log": "/tmp/sprint6-controls-final-fae07ca/partial-mutant-observations.log",
      "log_sha256": "1b2f26f08958c0b94053bdcb2cac66d567c5f5ecd0d216175e35322af7bda456",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: partial execution\n",
      "spec_sha256": "ccbd4fd08a855dff3b9083c268f082c1d56fb3e2cd8a710c1ffdd389922fde42",
      "setup_records": [],
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
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/partial-mutant-observations/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/partial-mutant-observations/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "bc6e74ae5ad02a8118ad7c0d5f482af8085a7229355f13d6173f86d60683772d"
        }
      ]
    },
    {
      "name": "no-op-mutation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/no-op-mutation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/no-op-mutation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation must actually change the source",
      "passed": true,
      "elapsed_seconds": 0.043411,
      "log": "/tmp/sprint6-controls-final-fae07ca/no-op-mutation.log",
      "log_sha256": "b17005f70eaf2c952f34332c6115135580b3c72b3d4414ebf4a29af62ffb97dd",
      "cli_output": "BLOCKED: Blocked: mutation must actually change the source\n",
      "spec_sha256": "19038ea65a0e2ad5b3f9ec2bc1d56a970e99e1ebbd1c58bcedc6f2fabf876f99",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-mutation-needle",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-mutation-needle-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-mutation-needle"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation did not apply exactly once",
      "passed": true,
      "elapsed_seconds": 0.043835,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-mutation-needle.log",
      "log_sha256": "6f90bdc0ec4157b596cb33422a789e4b0779aecb3867970c8d92c6fc17300def",
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n",
      "spec_sha256": "c67e6e0e6fd2990e0e0799e29cdbe1d5267c65e4a114fe0f3f4617acce22b577",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-source-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-source-setup-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-source-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "FileNotFoundError",
      "passed": true,
      "elapsed_seconds": 0.043676,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-source-setup.log",
      "log_sha256": "564196e4360fed81576eb36dee657d684e7df653a6385bb7414d733018b9dafa",
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean/DefiKernel/Parallel/RunnerInput.lean'\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-manifest-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-manifest-setup-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-manifest-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "FileNotFoundError",
      "passed": true,
      "elapsed_seconds": 0.041883,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-manifest-setup.log",
      "log_sha256": "709b873252ff31c720bb37f787fd9d15cfe93f042608c3faf241536229edd061",
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean/lake-manifest.json'\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "existing-output-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/existing-output-setup-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/existing-output-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "output already exists",
      "passed": true,
      "elapsed_seconds": 0.04268,
      "log": "/tmp/sprint6-controls-final-fae07ca/existing-output-setup.log",
      "log_sha256": "ccb397a7b400740970066a75dcb697d410732428a72ee25b78bd5fd711437d87",
      "cli_output": "BLOCKED: Blocked: output already exists\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "reserved-mutation-name",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/reserved-mutation-name-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/reserved-mutation-name"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "reserved variant name",
      "passed": true,
      "elapsed_seconds": 0.04048,
      "log": "/tmp/sprint6-controls-final-fae07ca/reserved-mutation-name.log",
      "log_sha256": "68ca99d80f5e9e2c8ec51b16310399b3bc37cbbbdfbf3dae0309ec4056a6dfa7",
      "cli_output": "BLOCKED: Blocked: reserved variant name\n",
      "spec_sha256": "a971e5041c5512cb05dad40340c2a640aef9ead95ff9eab3648f220f8f27556d",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "empty-module-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-module-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-module-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty module inventory",
      "passed": true,
      "elapsed_seconds": 0.043176,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-module-inventory.log",
      "log_sha256": "420d91bd881136c8edb9404a23f978230b022f8bec33d07f2305f2cf26c11d25",
      "cli_output": "BLOCKED: Blocked: empty module inventory\n",
      "spec_sha256": "b788fc66cacf2687ee9a9bee753443b3170c4aa0b3ccb615af425bb43d549658",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "empty-positive-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-positive-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-positive-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty positive-control inventory",
      "passed": true,
      "elapsed_seconds": 0.048662,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-positive-inventory.log",
      "log_sha256": "1380baf49bc7e439f004bd37ea939223bda2e943ae240d4f3f01e16be068e61c",
      "cli_output": "BLOCKED: Blocked: empty positive-control inventory\n",
      "spec_sha256": "157d3205d49fae70797c726a1a00732e9af99a90678253dde76fd15fe7478dee",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-module-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-module-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-module-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate source module",
      "passed": true,
      "elapsed_seconds": 0.043942,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-module-inventory.log",
      "log_sha256": "d4608a413da337306c20737630210431d7187ce266f1bd286f26160c32038453",
      "cli_output": "BLOCKED: Blocked: duplicate source module\n",
      "spec_sha256": "d8f6a4c049763e6417d8903a057d1d2021bf79c852bcf136ceca0b0fa32f78b7",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-mutation-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-mutation-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-mutation-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate mutation name",
      "passed": true,
      "elapsed_seconds": 0.044427,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-mutation-inventory.log",
      "log_sha256": "d80a2df2959221fed547d3199e12efa18e1c3e251e894ae052b508f104fab8f3",
      "cli_output": "BLOCKED: Blocked: duplicate mutation name\n",
      "spec_sha256": "945311ba954dea24e23376c6ae072686dfc772df6953a58e12aa44636d6bfa8c",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-positive-check",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-positive-check-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-positive-check"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate positive control",
      "passed": true,
      "elapsed_seconds": 0.04265,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-positive-check.log",
      "log_sha256": "97e937f830586a63e44b6ae14d91ee9c854034adc40dda6203402630085f2226",
      "cli_output": "BLOCKED: Blocked: duplicate positive control\n",
      "spec_sha256": "a15234422f7cee0713707468eccaf92516bd8fad6f4062f75aec374f214a7bb1",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-required-check",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-required-check-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-required-check"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate required check",
      "passed": true,
      "elapsed_seconds": 0.043643,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-required-check.log",
      "log_sha256": "a2c8000fdab76596b59060aca02c3955e3277842cd4e277b364645dd334c514a",
      "cli_output": "BLOCKED: Blocked: duplicate required check\n",
      "spec_sha256": "b254ac016d5a54f82ff62f79204509014404e01a2d4200344c6a4ea218c5acda",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "nonunique-mutation-needle",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/nonunique-mutation-needle-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/nonunique-mutation-needle"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation did not apply exactly once",
      "passed": true,
      "elapsed_seconds": 0.042248,
      "log": "/tmp/sprint6-controls-final-fae07ca/nonunique-mutation-needle.log",
      "log_sha256": "6f90bdc0ec4157b596cb33422a789e4b0779aecb3867970c8d92c6fc17300def",
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n",
      "spec_sha256": "30711d9d8940d46b9dd5372897d5ffad6a774028c3f22ff7dda2e6aca6cad2ca",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "malformed-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/malformed-observation-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/malformed-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.20846,
      "log": "/tmp/sprint6-controls-final-fae07ca/malformed-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
          "log_sha256": "41a398d927a319a363b4a2747adff5d227b7970bbfd8e118f93b847464247209"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/malformed-observation/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "41a398d927a319a363b4a2747adff5d227b7970bbfd8e118f93b847464247209"
        }
      ]
    },
    {
      "name": "malformed-json",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/malformed-json-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/malformed-json"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "JSONDecodeError",
      "passed": true,
      "elapsed_seconds": 0.042202,
      "log": "/tmp/sprint6-controls-final-fae07ca/malformed-json.log",
      "log_sha256": "bb288e0effc1922ff3c3292e12ff5e685ed35c7c95eba14587814071c7bb5d83",
      "cli_output": "BLOCKED: JSONDecodeError: Expecting property name enclosed in double quotes: line 1 column 2 (char 1)\n",
      "spec_sha256": "021fb596db81e6d02bf3d2586ee3981fe519f275c0ac9ca76bbcf2ebb4097d96",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-json-key",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/duplicate-json-key-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/duplicate-json-key"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate JSON key",
      "passed": true,
      "elapsed_seconds": 0.043394,
      "log": "/tmp/sprint6-controls-final-fae07ca/duplicate-json-key.log",
      "log_sha256": "0f1dea503e7da8a04bca31c98ae7829025e625df5937d9464229ffce02c5091f",
      "cli_output": "BLOCKED: Blocked: duplicate JSON key: schema_version\n",
      "spec_sha256": "0da553ad4d76ac11a13925a107f1de186487f10e748d11f17130cb8b136e7c45",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "output-inside-repository",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/output-inside-repository-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo/forbidden-output"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "evidence output must be outside the repository",
      "passed": true,
      "elapsed_seconds": 0.042932,
      "log": "/tmp/sprint6-controls-final-fae07ca/output-inside-repository.log",
      "log_sha256": "afab9aeb87fc6254658f5f349e1367967b0d6e45d8ea7e56fe69b6049a402228",
      "cli_output": "BLOCKED: Blocked: evidence output must be outside the repository\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "output-symlink",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/output-symlink-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/output-symlink"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "output already exists",
      "passed": true,
      "elapsed_seconds": 0.044312,
      "log": "/tmp/sprint6-controls-final-fae07ca/output-symlink.log",
      "log_sha256": "ccb397a7b400740970066a75dcb697d410732428a72ee25b78bd5fd711437d87",
      "cli_output": "BLOCKED: Blocked: output already exists\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "discovered-parallel-dependency",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/discovered-parallel-dependency-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/discovered-parallel-dependency"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 3.334566,
      "log": "/tmp/sprint6-controls-final-fae07ca/discovered-parallel-dependency.log",
      "log_sha256": "a105fea8d0e70f6920274a051b99f157115a6e0de8763d1530ef79b3560dd925",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
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
            "/tmp/sprint6-controls-final-fae07ca/runs/discovered-parallel-dependency/probe.lean:30:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "fc59f68d614d4a4c300ccb7a870961439ccaf1a45ea897d54f37a65488ad2536"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Parallel/SplitComputation.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "b6d42bef8f9f6a4aa462963cd0fe4ea6057ebf175b5ee629bdb9de262c0b8a30"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/discovered-parallel-dependency/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/discovered-parallel-dependency/probe.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "fc59f68d614d4a4c300ccb7a870961439ccaf1a45ea897d54f37a65488ad2536"
        }
      ]
    },
    {
      "name": "fresh-dependency-source-failure",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/fresh-dependency-source-failure-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/fresh-dependency-source-failure"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control compilation/execution failed",
      "passed": true,
      "elapsed_seconds": 2.218844,
      "log": "/tmp/sprint6-controls-final-fae07ca/fresh-dependency-source-failure.log",
      "log_sha256": "0454f66f0357aa3eb1315fb02f3a3adae4be79fa75387467f3c689db7a4cf150",
      "cli_output": "BLOCKED: Blocked: control compilation/execution failed\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [
        {
          "command": [
            "lake",
            "env",
            "lean",
            "-o",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean/.lake/build/lib/lean/DefiKernel/Typed/RunnerDependency.olean",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean/DefiKernel/Typed/RunnerDependency.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
          "source_sha256": "a55de86192462c1deab9d024b263dac81a527439579ee78b076627b0ee26b425",
          "olean_sha256": "b1c8738a34c426a06a824dc289e25436bdb7fa0c05bb4f8f63d290d4b33ab07d"
        }
      ],
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
          "errors": [
            "/tmp/sprint6-controls-final-fae07ca/runs/fresh-dependency-source-failure/control.lean:12:51: error: Type mismatch"
          ],
          "log_sha256": "281d6ce066e3fd4962f082d259cb577407744b72f4e71b480507f95c51a7382c"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/fresh-dependency-source-failure/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "281d6ce066e3fd4962f082d259cb577407744b72f4e71b480507f95c51a7382c"
        }
      ]
    },
    {
      "name": "missing-audit-root",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/missing-audit-root-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/missing-audit-root"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "missing Parallel audit root",
      "passed": true,
      "elapsed_seconds": 0.040143,
      "log": "/tmp/sprint6-controls-final-fae07ca/missing-audit-root.log",
      "log_sha256": "8d9b78ae11068e468e6849ced7800986a6bb7fddce1010e52223cf952ff7edf1",
      "cli_output": "BLOCKED: Blocked: missing Parallel audit root\n",
      "spec_sha256": "693478ad0181ac60a400ee4f53a29ad99b10afdaff054c574b5f57122c2b2c17",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "foreign-module-root",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/foreign-module-root-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/foreign-module-root"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "invalid scoped module",
      "passed": true,
      "elapsed_seconds": 0.041394,
      "log": "/tmp/sprint6-controls-final-fae07ca/foreign-module-root.log",
      "log_sha256": "4bdcf5d8decbdbdac62c05ae197cedb7b3db17edb2b7003f038eee9cd495543c",
      "cli_output": "BLOCKED: Blocked: invalid scoped module: DefiKernel.Composition.RunnerInput\n",
      "spec_sha256": "df311c18d428224b7f30aa3fd62372f127659889fdcb85494717424e6487c00b",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "mutation-module-outside-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/mutation-module-outside-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/mutation-module-outside-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation module outside inventory",
      "passed": true,
      "elapsed_seconds": 0.041358,
      "log": "/tmp/sprint6-controls-final-fae07ca/mutation-module-outside-inventory.log",
      "log_sha256": "c0b494e990010bcb188f85260633643a17ea3e6d22616aba137ea6af47fa89fa",
      "cli_output": "BLOCKED: Blocked: mutation module outside inventory\n",
      "spec_sha256": "7a9c47317b8f39a4ef49a342684343db21874f2d1e4f62f230391dbc2ebfc0ef",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "unchanged-control-failed",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/unchanged-control-failed-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/unchanged-control-failed"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "unchanged control has failing comparisons",
      "passed": true,
      "elapsed_seconds": 2.046201,
      "log": "/tmp/sprint6-controls-final-fae07ca/unchanged-control-failed.log",
      "log_sha256": "c714eab6786c789095e7a59b14b927d6e66357183551d3aeb8f3fb2df945dcce",
      "cli_output": "FAIL: unchanged control has failing comparisons\n",
      "spec_sha256": "6e63ba8c4c5d429081023a58de8c3de8731879ea836ace6dc1f750727a4f8708",
      "setup_records": [],
      "lean_observations": {
        "control": {
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
            "/tmp/sprint6-controls-final-fae07ca/runs/unchanged-control-failed/control.lean:25:0: error: Parallel runtime comparisons failed: 1"
          ],
          "log_sha256": "59ca774bca4db510396c35a243684f63164e76e3fbc4db2c7fd15b81d1613e46"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
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
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "670b8f6c1e79783ba2676fe3852180d04eff0cfdbe526c9ec0389ff0acada03a"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Parallel/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Parallel/Audit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "7bf81639e2d589bbb64126da183b0b497a301f0d2ab3ec15c9a991be8a2f6664"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/sprint6-controls-final-fae07ca/runs/unchanged-control-failed/control.lean"
          ],
          "cwd": "/tmp/sprint6-controls-final-fae07ca/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "59ca774bca4db510396c35a243684f63164e76e3fbc4db2c7fd15b81d1613e46"
        }
      ]
    },
    {
      "name": "empty-mutation-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_parallel_mutations.py",
        "--repo",
        "/tmp/sprint6-controls-final-fae07ca/fixture-repo",
        "--spec",
        "/tmp/sprint6-controls-final-fae07ca/empty-mutation-inventory-spec.json",
        "--out",
        "/tmp/sprint6-controls-final-fae07ca/runs/empty-mutation-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty mutation inventory",
      "passed": true,
      "elapsed_seconds": 0.044535,
      "log": "/tmp/sprint6-controls-final-fae07ca/empty-mutation-inventory.log",
      "log_sha256": "c4467212b8bbf24a3f24e88e5eaa617a4333a70d5b2b1ef7613128095819e8b8",
      "cli_output": "BLOCKED: Blocked: empty mutation inventory\n",
      "spec_sha256": "74dbde94c0f05b93f7e24e5e97b0c12026381e7a6f4d4e5125efc21bff20a7dd",
      "setup_records": [],
      "lean_observations": {},
      "runner_records": []
    }
  ]
}

```

### EVIDENCE review/semantic-kernel/sprint6/runner-controls/final-fae07ca/artifact-integrity.json
SHA256 bba49bbf5d4ca412a90b9c6ccd4f5e188ba603037d58e8e31cda6c2075f1468c
```
{
  "kind": "runner-control-artifact-integrity",
  "assertions": 470,
  "failures": 0,
  "git_head": "fae07caa2620c7a1d4ba1a39cb9a9be171ff137d",
  "runner_sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
  "harness_sha256": "14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79",
  "checks": [
    "45 controls pass",
    "check_parallel_mutations.py current source hash",
    "check_parallel_mutations.py snapshot hash",
    "check_parallel_mutations.py committed Git object hash",
    "test_parallel_mutation_runner.py current source hash",
    "test_parallel_mutation_runner.py snapshot hash",
    "test_parallel_mutation_runner.py committed Git object hash",
    "live-discriminating-mutant classification",
    "live-discriminating-mutant CLI log",
    "live-discriminating-mutant spec",
    "live-discriminating-mutant lean-version log",
    "live-discriminating-mutant lean-path log",
    "live-discriminating-mutant git-head log",
    "live-discriminating-mutant git-root-input-status log",
    "live-discriminating-mutant control log",
    "live-discriminating-mutant probe log",
    "live-discriminating-mutant runner binding",
    "live-discriminating-mutant spec binding",
    "live-discriminating-mutant lean/DefiKernel/Parallel/RunnerInput.lean source",
    "live-discriminating-mutant lean/DefiKernel/Typed/RunnerDependency.lean source",
    "live-discriminating-mutant lean/DefiKernel/Parallel/Audit.lean source",
    "live-discriminating-mutant lean/lean-toolchain source",
    "live-discriminating-mutant lean/lake-manifest.json source",
    "live-discriminating-mutant lean/lakefile.toml source",
    "live-discriminating-mutant control generated source",
    "live-discriminating-mutant probe generated source",
    "live-discriminating-mutant unchanged sources",
    "live-discriminating-mutant unchanged flags",
    "dotted-comparisons classification",
    "dotted-comparisons CLI log",
    "dotted-comparisons spec",
    "dotted-comparisons lean-version log",
    "dotted-comparisons lean-path log",
    "dotted-comparisons git-head log",
    "dotted-comparisons git-root-input-status log",
    "dotted-comparisons control log",
    "dotted-comparisons probe log",
    "dotted-comparisons runner binding",
    "dotted-comparisons spec binding",
    "dotted-comparisons lean/DefiKernel/Parallel/RunnerInput.lean source",
    "dotted-comparisons lean/DefiKernel/Typed/RunnerDependency.lean source",
    "dotted-comparisons lean/DefiKernel/Parallel/Audit.lean source",
    "dotted-comparisons lean/lean-toolchain source",
    "dotted-comparisons lean/lake-manifest.json source",
    "dotted-comparisons lean/lakefile.toml source",
    "dotted-comparisons control generated source",
    "dotted-comparisons probe generated source",
    "dotted-comparisons unchanged sources",
    "dotted-comparisons unchanged flags",
    "hyphenated-dotted-comparisons classification",
    "hyphenated-dotted-comparisons CLI log",
    "hyphenated-dotted-comparisons spec",
    "hyphenated-dotted-comparisons lean-version log",
    "hyphenated-dotted-comparisons lean-path log",
    "hyphenated-dotted-comparisons git-head log",
    "hyphenated-dotted-comparisons git-root-input-status log",
    "hyphenated-dotted-comparisons control log",
    "hyphenated-dotted-comparisons probe log",
    "hyphenated-dotted-comparisons runner binding",
    "hyphenated-dotted-comparisons spec binding",
    "hyphenated-dotted-comparisons lean/DefiKernel/Parallel/RunnerInput.lean source",
    "hyphenated-dotted-comparisons lean/DefiKernel/Typed/RunnerDependency.lean source",
    "hyphenated-dotted-comparisons lean/DefiKernel/Parallel/Audit.lean source",
    "hyphenated-dotted-comparisons lean/lean-toolchain source",
    "hyphenated-dotted-comparisons lean/lake-manifest.json source",
    "hyphenated-dotted-comparisons lean/lakefile.toml source",
    "hyphenated-dotted-comparisons control generated source",
    "hyphenated-dotted-comparisons probe generated source",
    "hyphenated-dotted-comparisons unchanged sources",
    "hyphenated-dotted-comparisons unchanged flags",
    "empty-dot-segment-spec classification",
    "empty-dot-segment-spec CLI log",
    "empty-dot-segment-spec spec",
    "trailing-dot-spec classification",
    "trailing-dot-spec CLI log",
    "trailing-dot-spec spec",
    "leading-dot-observation classification",
    "leading-dot-observation CLI log",
    "leading-dot-observation spec",
    "leading-dot-observation lean-version log",
    "leading-dot-observation lean-path log",
    "leading-dot-observation git-head log",
    "leading-dot-observation git-root-input-status log",
    "leading-dot-observation control log",
    "leading-dot-observation runner binding",
    "leading-dot-observation spec binding",
    "leading-dot-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "leading-dot-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "leading-dot-observation lean/DefiKernel/Parallel/Audit.lean source",
    "leading-dot-observation lean/lean-toolchain source",
    "leading-dot-observation lean/lake-manifest.json source",
    "leading-dot-observation lean/lakefile.toml source",
    "empty-dot-segment-observation classification",
    "empty-dot-segment-observation CLI log",
    "empty-dot-segment-observation spec",
    "empty-dot-segment-observation lean-version log",
    "empty-dot-segment-observation lean-path log",
    "empty-dot-segment-observation git-head log",
    "empty-dot-segment-observation git-root-input-status log",
    "empty-dot-segment-observation control log",
    "empty-dot-segment-observation runner binding",
    "empty-dot-segment-observation spec binding",
    "empty-dot-segment-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "empty-dot-segment-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "empty-dot-segment-observation lean/DefiKernel/Parallel/Audit.lean source",
    "empty-dot-segment-observation lean/lean-toolchain source",
    "empty-dot-segment-observation lean/lake-manifest.json source",
    "empty-dot-segment-observation lean/lakefile.toml source",
    "unused-variable-warning classification",
    "unused-variable-warning CLI log",
    "unused-variable-warning spec",
    "unused-variable-warning lean-version log",
    "unused-variable-warning lean-path log",
    "unused-variable-warning git-head log",
    "unused-variable-warning git-root-input-status log",
    "unused-variable-warning control log",
    "unused-variable-warning probe log",
    "unused-variable-warning runner binding",
    "unused-variable-warning spec binding",
    "unused-variable-warning lean/DefiKernel/Parallel/RunnerInput.lean source",
    "unused-variable-warning lean/DefiKernel/Typed/RunnerDependency.lean source",
    "unused-variable-warning lean/DefiKernel/Parallel/Audit.lean source",
    "unused-variable-warning lean/lean-toolchain source",
    "unused-variable-warning lean/lake-manifest.json source",
    "unused-variable-warning lean/lakefile.toml source",
    "unused-variable-warning control generated source",
    "unused-variable-warning probe generated source",
    "unused-variable-warning unchanged sources",
    "unused-variable-warning unchanged flags",
    "uppercase-observation classification",
    "uppercase-observation CLI log",
    "uppercase-observation spec",
    "uppercase-observation lean-version log",
    "uppercase-observation lean-path log",
    "uppercase-observation git-head log",
    "uppercase-observation git-root-input-status log",
    "uppercase-observation control log",
    "uppercase-observation runner binding",
    "uppercase-observation spec binding",
    "uppercase-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "uppercase-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "uppercase-observation lean/DefiKernel/Parallel/Audit.lean source",
    "uppercase-observation lean/lean-toolchain source",
    "uppercase-observation lean/lake-manifest.json source",
    "uppercase-observation lean/lakefile.toml source",
    "unknown-mutant-observation classification",
    "unknown-mutant-observation CLI log",
    "unknown-mutant-observation spec",
    "unknown-mutant-observation lean-version log",
    "unknown-mutant-observation lean-path log",
    "unknown-mutant-observation git-head log",
    "unknown-mutant-observation git-root-input-status log",
    "unknown-mutant-observation control log",
    "unknown-mutant-observation probe log",
    "unknown-mutant-observation runner binding",
    "unknown-mutant-observation spec binding",
    "unknown-mutant-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "unknown-mutant-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "unknown-mutant-observation lean/DefiKernel/Parallel/Audit.lean source",
    "unknown-mutant-observation lean/lean-toolchain source",
    "unknown-mutant-observation lean/lake-manifest.json source",
    "unknown-mutant-observation lean/lakefile.toml source",
    "unknown-mutant-observation control generated source",
    "all-true-mutant classification",
    "all-true-mutant CLI log",
    "all-true-mutant spec",
    "all-true-mutant lean-version log",
    "all-true-mutant lean-path log",
    "all-true-mutant git-head log",
    "all-true-mutant git-root-input-status log",
    "all-true-mutant control log",
    "all-true-mutant probe log",
    "all-true-mutant runner binding",
    "all-true-mutant spec binding",
    "all-true-mutant lean/DefiKernel/Parallel/RunnerInput.lean source",
    "all-true-mutant lean/DefiKernel/Typed/RunnerDependency.lean source",
    "all-true-mutant lean/DefiKernel/Parallel/Audit.lean source",
    "all-true-mutant lean/lean-toolchain source",
    "all-true-mutant lean/lake-manifest.json source",
    "all-true-mutant lean/lakefile.toml source",
    "all-true-mutant control generated source",
    "required-observation-stays-true classification",
    "required-observation-stays-true CLI log",
    "required-observation-stays-true spec",
    "required-observation-stays-true lean-version log",
    "required-observation-stays-true lean-path log",
    "required-observation-stays-true git-head log",
    "required-observation-stays-true git-root-input-status log",
    "required-observation-stays-true control log",
    "required-observation-stays-true probe log",
    "required-observation-stays-true runner binding",
    "required-observation-stays-true spec binding",
    "required-observation-stays-true lean/DefiKernel/Parallel/RunnerInput.lean source",
    "required-observation-stays-true lean/DefiKernel/Typed/RunnerDependency.lean source",
    "required-observation-stays-true lean/DefiKernel/Parallel/Audit.lean source",
    "required-observation-stays-true lean/lean-toolchain source",
    "required-observation-stays-true lean/lake-manifest.json source",
    "required-observation-stays-true lean/lakefile.toml source",
    "required-observation-stays-true control generated source",
    "positive-control-flipped classification",
    "positive-control-flipped CLI log",
    "positive-control-flipped spec",
    "positive-control-flipped lean-version log",
    "positive-control-flipped lean-path log",
    "positive-control-flipped git-head log",
    "positive-control-flipped git-root-input-status log",
    "positive-control-flipped control log",
    "positive-control-flipped probe log",
    "positive-control-flipped runner binding",
    "positive-control-flipped spec binding",
    "positive-control-flipped lean/DefiKernel/Parallel/RunnerInput.lean source",
    "positive-control-flipped lean/DefiKernel/Typed/RunnerDependency.lean source",
    "positive-control-flipped lean/DefiKernel/Parallel/Audit.lean source",
    "positive-control-flipped lean/lean-toolchain source",
    "positive-control-flipped lean/lake-manifest.json source",
    "positive-control-flipped lean/lakefile.toml source",
    "positive-control-flipped control generated source",
    "compilation-only-failure classification",
    "compilation-only-failure CLI log",
    "compilation-only-failure spec",
    "compilation-only-failure lean-version log",
    "compilation-only-failure lean-path log",
    "compilation-only-failure git-head log",
    "compilation-only-failure git-root-input-status log",
    "compilation-only-failure control log",
    "compilation-only-failure probe log",
    "compilation-only-failure runner binding",
    "compilation-only-failure spec binding",
    "compilation-only-failure lean/DefiKernel/Parallel/RunnerInput.lean source",
    "compilation-only-failure lean/DefiKernel/Typed/RunnerDependency.lean source",
    "compilation-only-failure lean/DefiKernel/Parallel/Audit.lean source",
    "compilation-only-failure lean/lean-toolchain source",
    "compilation-only-failure lean/lake-manifest.json source",
    "compilation-only-failure lean/lakefile.toml source",
    "compilation-only-failure control generated source",
    "compiler-error-with-runtime-failure classification",
    "compiler-error-with-runtime-failure CLI log",
    "compiler-error-with-runtime-failure spec",
    "compiler-error-with-runtime-failure lean-version log",
    "compiler-error-with-runtime-failure lean-path log",
    "compiler-error-with-runtime-failure git-head log",
    "compiler-error-with-runtime-failure git-root-input-status log",
    "compiler-error-with-runtime-failure control log",
    "compiler-error-with-runtime-failure probe log",
    "compiler-error-with-runtime-failure runner binding",
    "compiler-error-with-runtime-failure spec binding",
    "compiler-error-with-runtime-failure lean/DefiKernel/Parallel/RunnerInput.lean source",
    "compiler-error-with-runtime-failure lean/DefiKernel/Typed/RunnerDependency.lean source",
    "compiler-error-with-runtime-failure lean/DefiKernel/Parallel/Audit.lean source",
    "compiler-error-with-runtime-failure lean/lean-toolchain source",
    "compiler-error-with-runtime-failure lean/lake-manifest.json source",
    "compiler-error-with-runtime-failure lean/lakefile.toml source",
    "compiler-error-with-runtime-failure control generated source",
    "empty-observations classification",
    "empty-observations CLI log",
    "empty-observations spec",
    "empty-observations lean-version log",
    "empty-observations lean-path log",
    "empty-observations git-head log",
    "empty-observations git-root-input-status log",
    "empty-observations control log",
    "empty-observations runner binding",
    "empty-observations spec binding",
    "empty-observations lean/DefiKernel/Parallel/RunnerInput.lean source",
    "empty-observations lean/DefiKernel/Typed/RunnerDependency.lean source",
    "empty-observations lean/DefiKernel/Parallel/Audit.lean source",
    "empty-observations lean/lean-toolchain source",
    "empty-observations lean/lake-manifest.json source",
    "empty-observations lean/lakefile.toml source",
    "duplicate-observations classification",
    "duplicate-observations CLI log",
    "duplicate-observations spec",
    "duplicate-observations lean-version log",
    "duplicate-observations lean-path log",
    "duplicate-observations git-head log",
    "duplicate-observations git-root-input-status log",
    "duplicate-observations control log",
    "duplicate-observations runner binding",
    "duplicate-observations spec binding",
    "duplicate-observations lean/DefiKernel/Parallel/RunnerInput.lean source",
    "duplicate-observations lean/DefiKernel/Typed/RunnerDependency.lean source",
    "duplicate-observations lean/DefiKernel/Parallel/Audit.lean source",
    "duplicate-observations lean/lean-toolchain source",
    "duplicate-observations lean/lake-manifest.json source",
    "duplicate-observations lean/lakefile.toml source",
    "missing-positive-observation classification",
    "missing-positive-observation CLI log",
    "missing-positive-observation spec",
    "missing-positive-observation lean-version log",
    "missing-positive-observation lean-path log",
    "missing-positive-observation git-head log",
    "missing-positive-observation git-root-input-status log",
    "missing-positive-observation control log",
    "missing-positive-observation runner binding",
    "missing-positive-observation spec binding",
    "missing-positive-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "missing-positive-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "missing-positive-observation lean/DefiKernel/Parallel/Audit.lean source",
    "missing-positive-observation lean/lean-toolchain source",
    "missing-positive-observation lean/lake-manifest.json source",
    "missing-positive-observation lean/lakefile.toml source",
    "missing-required-observation classification",
    "missing-required-observation CLI log",
    "missing-required-observation spec",
    "missing-required-observation lean-version log",
    "missing-required-observation lean-path log",
    "missing-required-observation git-head log",
    "missing-required-observation git-root-input-status log",
    "missing-required-observation control log",
    "missing-required-observation runner binding",
    "missing-required-observation spec binding",
    "missing-required-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "missing-required-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "missing-required-observation lean/DefiKernel/Parallel/Audit.lean source",
    "missing-required-observation lean/lean-toolchain source",
    "missing-required-observation lean/lake-manifest.json source",
    "missing-required-observation lean/lakefile.toml source",
    "partial-mutant-observations classification",
    "partial-mutant-observations CLI log",
    "partial-mutant-observations spec",
    "partial-mutant-observations lean-version log",
    "partial-mutant-observations lean-path log",
    "partial-mutant-observations git-head log",
    "partial-mutant-observations git-root-input-status log",
    "partial-mutant-observations control log",
    "partial-mutant-observations probe log",
    "partial-mutant-observations runner binding",
    "partial-mutant-observations spec binding",
    "partial-mutant-observations lean/DefiKernel/Parallel/RunnerInput.lean source",
    "partial-mutant-observations lean/DefiKernel/Typed/RunnerDependency.lean source",
    "partial-mutant-observations lean/DefiKernel/Parallel/Audit.lean source",
    "partial-mutant-observations lean/lean-toolchain source",
    "partial-mutant-observations lean/lake-manifest.json source",
    "partial-mutant-observations lean/lakefile.toml source",
    "partial-mutant-observations control generated source",
    "no-op-mutation classification",
    "no-op-mutation CLI log",
    "no-op-mutation spec",
    "missing-mutation-needle classification",
    "missing-mutation-needle CLI log",
    "missing-mutation-needle spec",
    "missing-source-setup classification",
    "missing-source-setup CLI log",
    "missing-source-setup spec",
    "missing-manifest-setup classification",
    "missing-manifest-setup CLI log",
    "missing-manifest-setup spec",
    "existing-output-setup classification",
    "existing-output-setup CLI log",
    "existing-output-setup spec",
    "reserved-mutation-name classification",
    "reserved-mutation-name CLI log",
    "reserved-mutation-name spec",
    "empty-module-inventory classification",
    "empty-module-inventory CLI log",
    "empty-module-inventory spec",
    "empty-positive-inventory classification",
    "empty-positive-inventory CLI log",
    "empty-positive-inventory spec",
    "duplicate-module-inventory classification",
    "duplicate-module-inventory CLI log",
    "duplicate-module-inventory spec",
    "duplicate-mutation-inventory classification",
    "duplicate-mutation-inventory CLI log",
    "duplicate-mutation-inventory spec",
    "duplicate-positive-check classification",
    "duplicate-positive-check CLI log",
    "duplicate-positive-check spec",
    "duplicate-required-check classification",
    "duplicate-required-check CLI log",
    "duplicate-required-check spec",
    "nonunique-mutation-needle classification",
    "nonunique-mutation-needle CLI log",
    "nonunique-mutation-needle spec",
    "malformed-observation classification",
    "malformed-observation CLI log",
    "malformed-observation spec",
    "malformed-observation lean-version log",
    "malformed-observation lean-path log",
    "malformed-observation git-head log",
    "malformed-observation git-root-input-status log",
    "malformed-observation control log",
    "malformed-observation runner binding",
    "malformed-observation spec binding",
    "malformed-observation lean/DefiKernel/Parallel/RunnerInput.lean source",
    "malformed-observation lean/DefiKernel/Typed/RunnerDependency.lean source",
    "malformed-observation lean/DefiKernel/Parallel/Audit.lean source",
    "malformed-observation lean/lean-toolchain source",
    "malformed-observation lean/lake-manifest.json source",
    "malformed-observation lean/lakefile.toml source",
    "malformed-json classification",
    "malformed-json CLI log",
    "malformed-json spec",
    "duplicate-json-key classification",
    "duplicate-json-key CLI log",
    "duplicate-json-key spec",
    "output-inside-repository classification",
    "output-inside-repository CLI log",
    "output-inside-repository spec",
    "output-symlink classification",
    "output-symlink CLI log",
    "output-symlink spec",
    "discovered-parallel-dependency classification",
    "discovered-parallel-dependency CLI log",
    "discovered-parallel-dependency spec",
    "discovered-parallel-dependency lean-version log",
    "discovered-parallel-dependency lean-path log",
    "discovered-parallel-dependency git-head log",
    "discovered-parallel-dependency git-root-input-status log",
    "discovered-parallel-dependency control log",
    "discovered-parallel-dependency probe log",
    "discovered-parallel-dependency runner binding",
    "discovered-parallel-dependency spec binding",
    "discovered-parallel-dependency lean/DefiKernel/Parallel/RunnerInput.lean source",
    "discovered-parallel-dependency lean/DefiKernel/Parallel/SplitComputation.lean source",
    "discovered-parallel-dependency lean/DefiKernel/Typed/RunnerDependency.lean source",
    "discovered-parallel-dependency lean/DefiKernel/Parallel/Audit.lean source",
    "discovered-parallel-dependency lean/lean-toolchain source",
    "discovered-parallel-dependency lean/lake-manifest.json source",
    "discovered-parallel-dependency lean/lakefile.toml source",
    "discovered-parallel-dependency control generated source",
    "discovered-parallel-dependency probe generated source",
    "discovered-parallel-dependency unchanged sources",
    "discovered-parallel-dependency unchanged flags",
    "fresh-dependency-source-failure classification",
    "fresh-dependency-source-failure CLI log",
    "fresh-dependency-source-failure spec",
    "fresh-dependency-source-failure lean-version log",
    "fresh-dependency-source-failure lean-path log",
    "fresh-dependency-source-failure git-head log",
    "fresh-dependency-source-failure git-root-input-status log",
    "fresh-dependency-source-failure control log",
    "fresh-dependency-source-failure runner binding",
    "fresh-dependency-source-failure spec binding",
    "fresh-dependency-source-failure lean/DefiKernel/Parallel/RunnerInput.lean source",
    "fresh-dependency-source-failure lean/DefiKernel/Typed/RunnerDependency.lean source",
    "fresh-dependency-source-failure lean/DefiKernel/Parallel/Audit.lean source",
    "fresh-dependency-source-failure lean/lean-toolchain source",
    "fresh-dependency-source-failure lean/lake-manifest.json source",
    "fresh-dependency-source-failure lean/lakefile.toml source",
    "stale cache setup log",
    "stale cache compiled",
    "missing-audit-root classification",
    "missing-audit-root CLI log",
    "missing-audit-root spec",
    "foreign-module-root classification",
    "foreign-module-root CLI log",
    "foreign-module-root spec",
    "mutation-module-outside-inventory classification",
    "mutation-module-outside-inventory CLI log",
    "mutation-module-outside-inventory spec",
    "unchanged-control-failed classification",
    "unchanged-control-failed CLI log",
    "unchanged-control-failed spec",
    "unchanged-control-failed lean-version log",
    "unchanged-control-failed lean-path log",
    "unchanged-control-failed git-head log",
    "unchanged-control-failed git-root-input-status log",
    "unchanged-control-failed control log",
    "unchanged-control-failed runner binding",
    "unchanged-control-failed spec binding",
    "unchanged-control-failed lean/DefiKernel/Parallel/RunnerInput.lean source",
    "unchanged-control-failed lean/DefiKernel/Typed/RunnerDependency.lean source",
    "unchanged-control-failed lean/DefiKernel/Parallel/Audit.lean source",
    "unchanged-control-failed lean/lean-toolchain source",
    "unchanged-control-failed lean/lake-manifest.json source",
    "unchanged-control-failed lean/lakefile.toml source",
    "empty-mutation-inventory classification",
    "empty-mutation-inventory CLI log",
    "empty-mutation-inventory spec"
  ]
}

```

### EVIDENCE review/semantic-kernel/sprint6/mutation-runner-report.md
SHA256 52f98ad0e655f92cdd0285d220e0ad3dea272bddc907825463e7c5222169dc3b
```
The new Parallel mutation runner and its synthetic CLI harness are implemented.
The final harness executed **45 cases: 45 passed**, with five accepted toy
mutation runs, four expected assertion failures (exit 1), and 36 expected blocked
runs (exit 3). This is runner infrastructure evidence. Production financial source mutation results are recorded separately under
`mutations/`; this report counts only synthetic runner controls.

The actual command was:

```sh
python3 scripts/test_parallel_mutation_runner.py --repo . --out /tmp/sprint6-controls-final-fae07ca
```

It ran from `/home/charl/defiformal` and exited 0. The repository head observed
was `fae07caa2620c7a1d4ba1a39cb9a9be171ff137d`. The executed runner and harness bytes match their
Git objects at that commit. Exact executed script snapshots and hashes are saved
with the [final summary](runner-controls/final-fae07ca/summary.json) and
[invocation record](runner-controls/final-fae07ca/invocation.json).

| Input or tool | SHA-256 |
| --- | --- |
| `scripts/check_parallel_mutations.py` | `415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0` |
| `scripts/test_parallel_mutation_runner.py` | `14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79` |
| Lean executable | `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` |

Lean reported version `4.33.0-rc2`, commit
`d8b18978322de05a8f3dba51ef03cf5461676c17`. Each executed variant retains
its generated Lean source, complete log, actual exit, source/specification hashes,
projection order, and tool identity. The accepted cases additionally verify that
captured local source, specification, and runner bytes did not change during
replay. The [artifact integrity check](runner-controls/final-fae07ca/artifact-integrity.json)
passed 470 assertions, including exact source snapshot, specification, generated
fixture and log hashes. Python parsed both final scripts successfully.

The runner requires explicit `--repo`, `--spec`, and `--out`. Output must be a
new location outside the input repository. Module roots must be scoped to
`DefiKernel.Parallel` and include `DefiKernel.Parallel.Audit`. Its manifest
records the complete discovered `DefiKernel` source import closure. A new
Parallel module imported by a listed root is discovered and inlined even if it
is absent from the mutation-site inventory. Mutation targets still must appear
in that inventory. Cached local `.olean` files are not imported by the flattened
execution source. Only new Parallel proof suffixes following `-- BEGIN PROOFS`
are excluded; dependency proof code is retained. The projection expects the
established one-module-per-import-line syntax and exact namespace closure.

Each unchanged control must execute a nonempty, unique, well-formed named
inventory with every comparison true. Each mutation must change exactly one
source occurrence, execute exactly the same inventory, fail every designated
comparison, and retain all protected positive comparisons. Only the expected
`Parallel runtime comparisons failed: N` runtime error is allowed for a counted
mutation. Compile-only errors, compiler errors alongside false comparisons,
unapplied/nonunique/no-op edits, surviving mutations, and incomplete execution
cannot produce acceptance. The supported observation grammar remains lowercase
dotted segments with hyphens or underscores within segments.

All five accepted synthetic cases execute two comparisons. The unchanged control
prints its protected positive and sensitivity comparison as `true`; the mutation
prints the same protected positive as `true` and the sensitivity comparison as
`false`. The extra-module case also checks that the unlisted split module and
its exact bytes appear in the captured closure. These are observations of small
natural-number computations, not financial semantics or new mathematical proofs.

The stale dependency control first compiles an actual local dependency `.olean`
with value 4, then changes that dependency source and its theorem to value 5.
The importing source still requires value 4. The runner sees the changed source,
reports the resulting compilation failure, and exits 3 despite the available
old cache. Its setup command, source/cache hashes, and compiler log are saved in
[the case records](runner-controls/final-fae07ca/cases.json).

The controls cover empty, duplicate, missing and unknown observations/inventories;
partial or extra mutant observations; malformed labels/JSON; source/setup failures;
missing or foreign audit roots; invalid output paths; and mutation/positive-control
failures. Every rejection family is exercised beside a valid accepted sibling.
The initial test-first run against the unchanged Composition runner failed the
new Parallel positive controls because that runner correctly rejects Parallel
scope. A later control exposed an inherited parsing gap: an uppercase malformed
observation was silently ignored and the old parser returned 0. The new parser
blocks it. Those development failures are preserved separately under
[development-red](runner-controls/development-red/uppercase-parser-run.json)
and are excluded from the 45 accepted final control assertions.

This work added only the two new scripts and focused Sprint 6 runner evidence.
It did not edit old runners, Lean source, task checkboxes, or Git commits.
Production financial mutation results, native implementation review, and final
frozen-candidate acceptance are separate integration evidence.

The first production replay passed its unchanged 131-comparison control, then
blocked on the first mutant because Lean unused-variable `Hint:`/`Note:` text
was mistaken for an uppercase malformed observation. A real warning-producing
toy mutation reproduced that block. The revised runner excludes only the two
observed diagnostic prefixes and continues to reject malformed uppercase labels.
The added positive control asserts the actual compiler warning and both
continuation messages, as well as exact runtime comparisons. Its test-first
failure is retained under [revised development evidence](runner-controls/revised-45/development-red/summary.json).
The earlier 44-case bundle remains unchanged at `runner-controls/`; the current
45-case development bundle is at `runner-controls/revised-45/`. The final
postcommit acceptance bundle is at `runner-controls/final-fae07ca/`.

```

### EVIDENCE review/semantic-kernel/sprint6/regression-runs.json
SHA256 b73ffc2b439a42b95763af7abc6be68bcdee27cfc7811c154bafb0f84897a55d
```
{
  "source_revision": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
  "started_utc": "2026-09-07T05:36:20.328028+00:00",
  "scratch_root": "/tmp/defiformal-sprint6-regressions-x57cveb4",
  "max_parallel_subprocesses": 3,
  "source_binding": "regressions/source-binding.json",
  "source_binding_sha256": "4e89dbdebe00fde17b1a92343dc7b28e8e162203011230d2e6b55cec0477d4e2",
  "tools": {
    "python_version": "3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]",
    "python_executable": "/usr/bin/python3",
    "python_executable_sha256": "b8d8288faefdd300201f43fcf00f6f539a27218eeed3a3dff5ab10b9c4c99700",
    "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
    "lean_executable": "/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lean",
    "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
    "git_version": "git version 2.53.0",
    "harness_sha256": "fda55b6c215ae0e2bb0307dba2319550982a6c878b4857694f62c0317dd19d3d"
  },
  "runs": [
    {
      "label": "typed-mutations",
      "command": [
        "python3",
        "scripts/check_typed_kernel_mutations.py",
        "--repo",
        "/home/charl/defiformal",
        "--spec",
        "review/semantic-kernel/sprint4/mutation-spec.json",
        "--out",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/typed-mutations"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:36:21.474559+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
      "help_command": [
        "python3",
        "scripts/check_typed_kernel_mutations.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/typed-mutations.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:39:03.920739+00:00",
      "elapsed_seconds": 162.444,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "2d56d604d6d4df57392c00a8cd6535667055f5c7c35d7975eb66f40f94f5835d",
      "artifact_directory": "regressions/typed-mutations"
    },
    {
      "label": "composition-mutations",
      "command": [
        "python3",
        "scripts/check_composition_mutations.py",
        "--repo",
        "/home/charl/defiformal",
        "--spec",
        "review/semantic-kernel/sprint5/mutation-spec.json",
        "--out",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/composition-mutations"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:36:21.477184+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
      "help_command": [
        "python3",
        "scripts/check_composition_mutations.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/composition-mutations.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:39:59.316489+00:00",
      "elapsed_seconds": 217.828,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "6fa309f13e98c7abe744ac6277949144edbf5bad002feeba52330501c27dfc52",
      "artifact_directory": "regressions/composition-mutations"
    },
    {
      "label": "composition-runner-controls",
      "command": [
        "python3",
        "scripts/test_composition_mutation_runner.py",
        "--repo",
        "/home/charl/defiformal",
        "--out",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/composition-runner-controls"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:36:21.479626+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
      "help_command": [
        "python3",
        "scripts/test_composition_mutation_runner.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/composition-runner-controls.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:37:30.718911+00:00",
      "elapsed_seconds": 69.23,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "b44578903f555fd4ee6aac4c653c74b754e6ab3beae1f2a4b93853794a78c91a",
      "artifact_directory": "regressions/composition-runner-controls"
    },
    {
      "label": "typed-runner-controls",
      "command": [
        "python3",
        "scripts/test_typed_kernel_mutation_runner.py",
        "--repo",
        "/home/charl/defiformal",
        "--out",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/typed-runner-controls"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:37:30.827552+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93",
      "help_command": [
        "python3",
        "scripts/test_typed_kernel_mutation_runner.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/typed-runner-controls.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:38:19.742672+00:00",
      "elapsed_seconds": 48.912,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "a4530380c6358f479458f4ffe7ddfd8397bb71467ea15d738d5473012318951e",
      "artifact_directory": "regressions/typed-runner-controls"
    },
    {
      "label": "axiom-controls",
      "command": [
        "python3",
        "scripts/test_kernel_axiom_audit.py",
        "--output",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/axiom-controls"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:38:19.838493+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b",
      "help_command": [
        "python3",
        "scripts/test_kernel_axiom_audit.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/axiom-controls.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:38:36.685276+00:00",
      "elapsed_seconds": 16.844,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "b20ca340f3259fa328eed724dbe56900f6272f1e4908038a56a98af70866fd5e",
      "artifact_directory": "regressions/axiom-controls"
    },
    {
      "label": "typing-controls",
      "command": [
        "python3",
        "scripts/check_typed_kernel_typing.py",
        "--repo",
        "/home/charl/defiformal",
        "--out",
        "/tmp/defiformal-sprint6-regressions-x57cveb4/typing-controls"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:38:36.747293+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6",
      "help_command": [
        "python3",
        "scripts/check_typed_kernel_typing.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/typing-controls.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:38:45.526367+00:00",
      "elapsed_seconds": 8.777,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "2027d5c02b996a23b761513b8878236da2d276437870bc5b15f84fb1f1dbc02e",
      "artifact_directory": "regressions/typing-controls"
    },
    {
      "label": "corpus-controls",
      "command": [
        "python3",
        "scripts/test_corpus_normalize.py"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T05:38:45.608156+00:00",
      "head_at_start": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "script_sha256": "0c3ef8580a44b81b9d55cd2e9cd03d74580d2ee722d5acd57609f0a94faf278f",
      "help_command": [
        "python3",
        "scripts/test_corpus_normalize.py",
        "--help"
      ],
      "help_exit": 0,
      "log": "regressions/corpus-controls.log",
      "status": "complete",
      "exit": 0,
      "finished_utc": "2026-09-07T05:39:03.495605+00:00",
      "elapsed_seconds": 17.885,
      "head_at_end": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
      "log_sha256": "9139af9a59a89bc85046d1c9550ee6d642f5f2d9f7537e083eeeeff527330820"
    }
  ],
  "sources_unchanged": true,
  "finished_utc": "2026-09-07T05:39:59.333927+00:00",
  "all_commands_exit_zero": true,
  "artifact_manifest_sha256": "004ee5796c22ac2da9fcf30d2bae4f3c3366628fac55c6ab6dedf0a3bebd3098",
  "verified_outcomes": "regressions/verified-outcomes.json",
  "post_verification_command": [
    "python3",
    "review/semantic-kernel/sprint6/regressions/verify-results.py"
  ],
  "post_verification_exit": 0,
  "post_verification_assertions": 93,
  "git_metadata_packaging": "regressions/git-metadata-archives.json"
}

```

### EVIDENCE review/semantic-kernel/sprint6/regressions/source-binding.json
SHA256 4e89dbdebe00fde17b1a92343dc7b28e8e162203011230d2e6b55cec0477d4e2
```
{
  "corpus/CAKEClaude.md": {
    "sha256": "a744c703de81664406c50701bca6d237ad13ed2242dd9baa9367f2efb1220244",
    "git_blob": "fd026d16623d3d19204de37795dcfc16999a4bce",
    "observed_git_blob": "fd026d16623d3d19204de37795dcfc16999a4bce",
    "matches_candidate": true
  },
  "corpus/CAKEGPT.md": {
    "sha256": "5bb985721b0e42c312469332d2388f5a38145dd7e633b28ff244f2d8a1bdff60",
    "git_blob": "432c100ea8c596c6b028a548718e02ea432dd26c",
    "observed_git_blob": "432c100ea8c596c6b028a548718e02ea432dd26c",
    "matches_candidate": true
  },
  "corpus/elementsdefi.md": {
    "sha256": "cc5c807c7232553e8f9fc28fed341b1ff93d3d5033412df0bffb469a2a59e113",
    "git_blob": "d071648e3f6ba864e487be3d8ac579c15188b8a2",
    "observed_git_blob": "d071648e3f6ba864e487be3d8ac579c15188b8a2",
    "matches_candidate": true
  },
  "corpus/elementsdefiGPT.md": {
    "sha256": "3ae40c440bfee5ccd89a2e6e2434163f9cfa1dc31468a24fc30e6d5ef8389798",
    "git_blob": "cd950e64518ef3179db6b28c75fc612e890bbf03",
    "observed_git_blob": "cd950e64518ef3179db6b28c75fc612e890bbf03",
    "matches_candidate": true
  },
  "corpus/normalized/README.md": {
    "sha256": "087276ef81f2ff901ab7e1c32920ba4898ca482f00f8a6e16940cac52c295073",
    "git_blob": "0b6fe082037350d9097c14dc3c4bc2d518ff9b83",
    "observed_git_blob": "0b6fe082037350d9097c14dc3c4bc2d518ff9b83",
    "matches_candidate": true
  },
  "corpus/normalized/annotations/a.json": {
    "sha256": "bef2613e0d4a1b88fcd179a5b051e8eb942610a6299d15e553187705890bc007",
    "git_blob": "9038ea5f78eff5004af4dfba9cab9cca15a428b2",
    "observed_git_blob": "9038ea5f78eff5004af4dfba9cab9cca15a428b2",
    "matches_candidate": true
  },
  "corpus/normalized/annotations/b.json": {
    "sha256": "b2d30c390da953c464169f805aef1e4bcfaeeec076bc6c235cc6872536a47022",
    "git_blob": "7e0358cf742c815de118df5177d61e7c3af60bc5",
    "observed_git_blob": "7e0358cf742c815de118df5177d61e7c3af60bc5",
    "matches_candidate": true
  },
  "corpus/normalized/corpus.schema.json": {
    "sha256": "2b7e2fb94db8247293bb974465204ba9ed7d8359560238c26ce3ca0dbd860fab",
    "git_blob": "5e9eff680c24815e09295ccf2fe825150808f3e0",
    "observed_git_blob": "5e9eff680c24815e09295ccf2fe825150808f3e0",
    "matches_candidate": true
  },
  "corpus/normalized/generated/corpus.json": {
    "sha256": "43455c0a4bd490eea9f723a93ca18df10f79741f96ab16f73ef301cf919c0c90",
    "git_blob": "39750b4ddb4b61a4b2688a89a4fe63c749b9717f",
    "observed_git_blob": "39750b4ddb4b61a4b2688a89a4fe63c749b9717f",
    "matches_candidate": true
  },
  "corpus/normalized/generated/coverage.json": {
    "sha256": "e199548b467ef919b1e5600d7be3675c2ff3672800f5619912204434534895fe",
    "git_blob": "218e831af90aa3911b81b062cfdc3beb5329e7a2",
    "observed_git_blob": "218e831af90aa3911b81b062cfdc3beb5329e7a2",
    "matches_candidate": true
  },
  "corpus/normalized/generated/crosswalk.csv": {
    "sha256": "d842ad3111b3449b6b90c1824c0b4e988ba56b3eceee1b4aafd554adb52f48c3",
    "git_blob": "85318b86beff92c9ae09bcd5a553cb98d0cda11d",
    "observed_git_blob": "85318b86beff92c9ae09bcd5a553cb98d0cda11d",
    "matches_candidate": true
  },
  "corpus/normalized/inputs/annotation-input.json": {
    "sha256": "dc36166d26447203ba5af7f12db14f53d4ab1865dcace85955b58e026f3ef8e2",
    "git_blob": "563b4ea5065b2e5a7ad470dd89eba2af37647df8",
    "observed_git_blob": "563b4ea5065b2e5a7ad470dd89eba2af37647df8",
    "matches_candidate": true
  },
  "corpus/normalized/inputs/identity-map.json": {
    "sha256": "6cda8464f7b2effbec57cd6c1a88bb25b9d32a236a38d86707b5518f1e2eecb0",
    "git_blob": "87622d5af2e96b4e38786f0c275da1ecab4abb7e",
    "observed_git_blob": "87622d5af2e96b4e38786f0c275da1ecab4abb7e",
    "matches_candidate": true
  },
  "corpus/normalized/inputs/source-manifest.json": {
    "sha256": "2d9b70729adf7743f0376893220afdc78277f08611f08fa2c2e3170a0b7d3c48",
    "git_blob": "504fe6fc6a1b4cba286b429d678a8cdf91c7d19b",
    "observed_git_blob": "504fe6fc6a1b4cba286b429d678a8cdf91c7d19b",
    "matches_candidate": true
  },
  "corpus/normalized/inputs/taxonomy.json": {
    "sha256": "8f854470619216917fef489bb93c62afa8e56da6d1cfc8dd68afc7a46beed681",
    "git_blob": "e81d3c7a318d05698610b09f57858677c3854b10",
    "observed_git_blob": "e81d3c7a318d05698610b09f57858677c3854b10",
    "matches_candidate": true
  },
  "corpus/normalized/requirements.txt": {
    "sha256": "49026b67905a6c42bd426e6f8b3d2d08dc24ec6fe51cb2f706aea0a3fb5f8e08",
    "git_blob": "b026b2a92ab72df4a0e0b23c134cd95ae25f27d3",
    "observed_git_blob": "b026b2a92ab72df4a0e0b23c134cd95ae25f27d3",
    "matches_candidate": true
  },
  "corpus/normalized/sources/README.md": {
    "sha256": "0f6d62798fb351a5c8ac3cb524394f5abdef1adebf281867c34139438d2e714c",
    "git_blob": "1b41740705a4673a3b8f6207795649ed297e84e9",
    "observed_git_blob": "1b41740705a4673a3b8f6207795649ed297e84e9",
    "matches_candidate": true
  },
  "corpus/normalized/sources/primary-excerpts.json": {
    "sha256": "f408fa630e27e207d60c6b93fca6c36037dc1b4fb3a3391a82664b86361cd794",
    "git_blob": "06f3ab951a8a998f1a84b7a685239f0285577f5b",
    "observed_git_blob": "06f3ab951a8a998f1a84b7a685239f0285577f5b",
    "matches_candidate": true
  },
  "corpus50/VERDICT.md": {
    "sha256": "fde37d3dd500af81505146334f94469d5cc594157d6baecc55600822ca2077b6",
    "git_blob": "67d513798f0ae3781ad9215ee82fbc78a111ef8c",
    "observed_git_blob": "67d513798f0ae3781ad9215ee82fbc78a111ef8c",
    "matches_candidate": true
  },
  "corpus50/decomp-contract.md": {
    "sha256": "9c4470458b11ae43a50579e4ab0400825063c665cd476ff3e829d9ca1f80ade1",
    "git_blob": "200d34ab211c352bf954f3004bff68285c278f3e",
    "observed_git_blob": "200d34ab211c352bf954f3004bff68285c278f3e",
    "matches_candidate": true
  },
  "corpus50/lanes/lane1-dex-lending-cdp-lsd.json": {
    "sha256": "afaf18d717dbd0ccc4e2909c146943e37ed3dff3c982bcfbc9b4f71f26c23369",
    "git_blob": "de4e27d3fc50114bf7d16bacc0f786af5ff1abc5",
    "observed_git_blob": "de4e27d3fc50114bf7d16bacc0f786af5ff1abc5",
    "matches_candidate": true
  },
  "corpus50/lanes/lane2-perps-yield-bridges-intents.json": {
    "sha256": "cca6b4cccd9e75cf70a1e4dcb291562810a7ab22b52071295ce2479af03364f6",
    "git_blob": "c11924fa55eb3c314c2f71c2b8ad04d27c935ae0",
    "observed_git_blob": "c11924fa55eb3c314c2f71c2b8ad04d27c935ae0",
    "matches_candidate": true
  },
  "corpus50/lanes/lane3-rwa-options-stables-prediction.json": {
    "sha256": "94195e7144eb707a7cbe34e4adcbaeeb234a572d7ac485e89ed2636059452820",
    "git_blob": "8527be71915ccaf19d3a95ffbb39d9b7e62ee362",
    "observed_git_blob": "8527be71915ccaf19d3a95ffbb39d9b7e62ee362",
    "matches_candidate": true
  },
  "corpus50/vocab.md": {
    "sha256": "71a7f00494280e3ebb70953fea4a8ac96ef11cc25dbb4c117206079bc88ef138",
    "git_blob": "c5b7c62231c58c32b758d90f9509efd83898e276",
    "observed_git_blob": "c5b7c62231c58c32b758d90f9509efd83898e276",
    "matches_candidate": true
  },
  "docs/research/2026-09-06-defi-source-plan.md": {
    "sha256": "c458c6c9e32675afe6a6aa44e6f1a6767d3963accb6d291ec24e6212ecac9975",
    "git_blob": "adece413f5254e445fb67c63a2a91a2ffae93b6c",
    "observed_git_blob": "adece413f5254e445fb67c63a2a91a2ffae93b6c",
    "matches_candidate": true
  },
  "lean/.github/workflows/create-release.yml": {
    "sha256": "491f1c02bb31774c3f711155a4cc24da5923dc8ba7016e9aaff13969e2ea49ca",
    "git_blob": "6dacf77ca24a1a2a99dc974d16c53408e8b32058",
    "observed_git_blob": "6dacf77ca24a1a2a99dc974d16c53408e8b32058",
    "matches_candidate": true
  },
  "lean/.github/workflows/lean_action_ci.yml": {
    "sha256": "3b0d49449c2e6d4ee04ce6e57c23dde1a836314b502351f1f6203477e2aafe8f",
    "git_blob": "db09247d95896bc768f71e39b47b2e2f192c5cdd",
    "observed_git_blob": "db09247d95896bc768f71e39b47b2e2f192c5cdd",
    "matches_candidate": true
  },
  "lean/.github/workflows/update.yml": {
    "sha256": "608304be502130030682762aa4a9bbec3e127d6b1eb2acf054818b84b6c81a4f",
    "git_blob": "96b7622a72a1c6d92e3927a2f494656c0797fc00",
    "observed_git_blob": "96b7622a72a1c6d92e3927a2f494656c0797fc00",
    "matches_candidate": true
  },
  "lean/.gitignore": {
    "sha256": "b3ad09fc93f83fdbd0bee771258dd4a58d3798fd7e6048611dde5a804bb43f1e",
    "git_blob": "bfb30ec8c762cc74d4ee1593ab48fc091d04ca4c",
    "observed_git_blob": "bfb30ec8c762cc74d4ee1593ab48fc091d04ca4c",
    "matches_candidate": true
  },
  "lean/Axioms.lean": {
    "sha256": "9760f52b1b2ce51df70abd6010b30cf1be6c761ffcdb5192b6eacdb810c02b52",
    "git_blob": "e31c78aa4279eef5cd7dac3e79322f0bfdb0a280",
    "observed_git_blob": "e31c78aa4279eef5cd7dac3e79322f0bfdb0a280",
    "matches_candidate": true
  },
  "lean/DefiKernel.lean": {
    "sha256": "ffa25f35c430bef69e654d18e2d907895aa0c8e7681dada4d61edb858c3f10bb",
    "git_blob": "39aa140070d99657bc311079eed3338454f3ed50",
    "observed_git_blob": "39aa140070d99657bc311079eed3338454f3ed50",
    "matches_candidate": true
  },
  "lean/DefiKernel/Acceptance.lean": {
    "sha256": "9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11",
    "git_blob": "978ef09075c68a44c1ccbc06c3634372e0dfbbf4",
    "observed_git_blob": "978ef09075c68a44c1ccbc06c3634372e0dfbbf4",
    "matches_candidate": true
  },
  "lean/DefiKernel/Audit.lean": {
    "sha256": "7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400",
    "git_blob": "bff33183a90008697f35dd1636ccaa8382c35004",
    "observed_git_blob": "bff33183a90008697f35dd1636ccaa8382c35004",
    "matches_candidate": true
  },
  "lean/DefiKernel/AxiomAudit.lean": {
    "sha256": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
    "git_blob": "32032f9638d0f934ebfa9b4b6de6c475d8b4237d",
    "observed_git_blob": "32032f9638d0f934ebfa9b4b6de6c475d8b4237d",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Audit.lean": {
    "sha256": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "git_blob": "7f350e3b451bda3bb0ed5b1daafb02cd727318fe",
    "observed_git_blob": "7f350e3b451bda3bb0ed5b1daafb02cd727318fe",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Contracts.lean": {
    "sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "git_blob": "a1f8cf7753180fdea9ae0f8095fae1e0d2ec792e",
    "observed_git_blob": "a1f8cf7753180fdea9ae0f8095fae1e0d2ec792e",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Examples.lean": {
    "sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "git_blob": "4b4cefb9a7cd81d906d668d69ef63501715abe65",
    "observed_git_blob": "4b4cefb9a7cd81d906d668d69ef63501715abe65",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Execution.lean": {
    "sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "git_blob": "f94f22503551dc7cbc965459626a33435ac512cc",
    "observed_git_blob": "f94f22503551dc7cbc965459626a33435ac512cc",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/ExecutionTests.lean": {
    "sha256": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "git_blob": "7b0110bfc51e21d232cf5fe0f2e7512a7cd2447e",
    "observed_git_blob": "7b0110bfc51e21d232cf5fe0f2e7512a7cd2447e",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/InterfaceTests.lean": {
    "sha256": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "git_blob": "1e0965bb3e7c1f72274fba529cc93bec5cb770e5",
    "observed_git_blob": "1e0965bb3e7c1f72274fba529cc93bec5cb770e5",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Interfaces.lean": {
    "sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "git_blob": "a45abc9035cd5882f58814c089ce151f0f2bbc51",
    "observed_git_blob": "a45abc9035cd5882f58814c089ce151f0f2bbc51",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Preservation.lean": {
    "sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "git_blob": "21eb3370867603b6d58c247f78840984dca0dbc6",
    "observed_git_blob": "21eb3370867603b6d58c247f78840984dca0dbc6",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Sequence.lean": {
    "sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "git_blob": "ffdfd5b29d8123c2f49cc2262fc199100794074f",
    "observed_git_blob": "ffdfd5b29d8123c2f49cc2262fc199100794074f",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Tests.lean": {
    "sha256": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "git_blob": "4eb52aa5c35b8c721c4794dd0a1fef468dd8d337",
    "observed_git_blob": "4eb52aa5c35b8c721c4794dd0a1fef468dd8d337",
    "matches_candidate": true
  },
  "lean/DefiKernel/Composition/Verify.lean": {
    "sha256": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
    "git_blob": "ec4088ec49455959ad1e2604467f226e69e25998",
    "observed_git_blob": "ec4088ec49455959ad1e2604467f226e69e25998",
    "matches_candidate": true
  },
  "lean/DefiKernel/ContractAcceptance.lean": {
    "sha256": "a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f",
    "git_blob": "43f6c23dd54e31ec1b5d9507e602925a47f9f495",
    "observed_git_blob": "43f6c23dd54e31ec1b5d9507e602925a47f9f495",
    "matches_candidate": true
  },
  "lean/DefiKernel/ContractAudit.lean": {
    "sha256": "600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9",
    "git_blob": "6e5dea522b2ccb085224c97c28a9d69bccb384fc",
    "observed_git_blob": "6e5dea522b2ccb085224c97c28a9d69bccb384fc",
    "matches_candidate": true
  },
  "lean/DefiKernel/ContractExamples.lean": {
    "sha256": "4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b",
    "git_blob": "ff27352bdc1474f7011eaed4a3e42d6510417a6d",
    "observed_git_blob": "ff27352bdc1474f7011eaed4a3e42d6510417a6d",
    "matches_candidate": true
  },
  "lean/DefiKernel/Contracts.lean": {
    "sha256": "22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2",
    "git_blob": "34b7ee3c5947b497803cc5e1e1b3898c4f33ace0",
    "observed_git_blob": "34b7ee3c5947b497803cc5e1e1b3898c4f33ace0",
    "matches_candidate": true
  },
  "lean/DefiKernel/Core.lean": {
    "sha256": "767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d",
    "git_blob": "c3d3c6d6e4ef9c24416e47928088a1889cf66e76",
    "observed_git_blob": "c3d3c6d6e4ef9c24416e47928088a1889cf66e76",
    "matches_candidate": true
  },
  "lean/DefiKernel/Examples.lean": {
    "sha256": "3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28",
    "git_blob": "6e9aa73f63e9b360e322a2760cdabbc2689e74d2",
    "observed_git_blob": "6e9aa73f63e9b360e322a2760cdabbc2689e74d2",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Audit.lean": {
    "sha256": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
    "git_blob": "80aa6163078b0e09428e58defd550c0caad3354e",
    "observed_git_blob": "80aa6163078b0e09428e58defd550c0caad3354e",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Commutation.lean": {
    "sha256": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "git_blob": "515d2bfcb0e68d260400e4fde3b25e6d31c09bea",
    "observed_git_blob": "515d2bfcb0e68d260400e4fde3b25e6d31c09bea",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Compatibility.lean": {
    "sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "git_blob": "db305a859e7cf155b991f20915051f41e289a2fc",
    "observed_git_blob": "db305a859e7cf155b991f20915051f41e289a2fc",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/CompatibilityTests.lean": {
    "sha256": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "git_blob": "df6ee4ee99d81efaad2746d4eaf4570653020f98",
    "observed_git_blob": "df6ee4ee99d81efaad2746d4eaf4570653020f98",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Dependency.lean": {
    "sha256": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "git_blob": "c913104b1cee20f63fa347a7c53e234e7271df4b",
    "observed_git_blob": "c913104b1cee20f63fa347a7c53e234e7271df4b",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Dependency/Adapter.lean": {
    "sha256": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "git_blob": "d82321a5b05e3a7a6dcc9249a990b636ccd1bc6d",
    "observed_git_blob": "d82321a5b05e3a7a6dcc9249a990b636ccd1bc6d",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Dependency/Fixtures.lean": {
    "sha256": "14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45",
    "git_blob": "e3f985049d367769d135cb4b03afa2632a09bc15",
    "observed_git_blob": "e3f985049d367769d135cb4b03afa2632a09bc15",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Examples.lean": {
    "sha256": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "git_blob": "93ad131ab148ede868ba9f56fd73b3c073552895",
    "observed_git_blob": "93ad131ab148ede868ba9f56fd73b3c073552895",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Execution.lean": {
    "sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "git_blob": "0ae8a088d63ff32b788df65b8d50717662528dfc",
    "observed_git_blob": "0ae8a088d63ff32b788df65b8d50717662528dfc",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/ExecutionTests.lean": {
    "sha256": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
    "git_blob": "d1fc9c96e9707f33e8fc6c787c1115f3a151a76f",
    "observed_git_blob": "d1fc9c96e9707f33e8fc6c787c1115f3a151a76f",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Observation.lean": {
    "sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "git_blob": "015857c7ac8c13af445adbc5145e0ab7f932b4fb",
    "observed_git_blob": "015857c7ac8c13af445adbc5145e0ab7f932b4fb",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/ObservationTests.lean": {
    "sha256": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "git_blob": "442558ad9e474da0a2ec08112a44595c5a9f1e66",
    "observed_git_blob": "442558ad9e474da0a2ec08112a44595c5a9f1e66",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Preservation.lean": {
    "sha256": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "git_blob": "23c60c62f05c7ff24b0073ce24e78165f375219d",
    "observed_git_blob": "23c60c62f05c7ff24b0073ce24e78165f375219d",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/PreservationFixtures.lean": {
    "sha256": "0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7",
    "git_blob": "e763240a95c7630de32250b1d69b7f39f01cf39a",
    "observed_git_blob": "e763240a95c7630de32250b1d69b7f39f01cf39a",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Tests.lean": {
    "sha256": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
    "git_blob": "93c8f51468943b77e47dc063192e1ec078bbf386",
    "observed_git_blob": "93c8f51468943b77e47dc063192e1ec078bbf386",
    "matches_candidate": true
  },
  "lean/DefiKernel/Parallel/Verify.lean": {
    "sha256": "ff25ad430ff36275ecaf7ccfab8a55f2e853cbd9381a739163f81bd3d7bbd3ab",
    "git_blob": "6ecd693d75c241fe8ca2239917f67de87f07f636",
    "observed_git_blob": "6ecd693d75c241fe8ca2239917f67de87f07f636",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Acceptance.lean": {
    "sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "git_blob": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
    "observed_git_blob": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Audit.lean": {
    "sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "git_blob": "c9e2a259936ed139599b35d4ed1467a54f67e460",
    "observed_git_blob": "c9e2a259936ed139599b35d4ed1467a54f67e460",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Authority.lean": {
    "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
    "observed_git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/AuthorityTests.lean": {
    "sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "git_blob": "0565fc81a0625e064ee560613408356bac7c4cda",
    "observed_git_blob": "0565fc81a0625e064ee560613408356bac7c4cda",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Examples.lean": {
    "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "git_blob": "5094c617948dc2955e6662009fe621b47edc6417",
    "observed_git_blob": "5094c617948dc2955e6662009fe621b47edc6417",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Expr.lean": {
    "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
    "observed_git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/ExprTests.lean": {
    "sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "git_blob": "f101da3b78d9cdf473377b406cac58bc836a4588",
    "observed_git_blob": "f101da3b78d9cdf473377b406cac58bc836a4588",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Transition.lean": {
    "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
    "observed_git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/TransitionTests.lean": {
    "sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "git_blob": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
    "observed_git_blob": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Types.lean": {
    "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
    "observed_git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
    "matches_candidate": true
  },
  "lean/DefiKernel/Typed/Verify.lean": {
    "sha256": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
    "git_blob": "c0bc41f3703eb6e26ef62c9da6b0282166e19504",
    "observed_git_blob": "c0bc41f3703eb6e26ef62c9da6b0282166e19504",
    "matches_candidate": true
  },
  "lean/DefiKernel/VerifyAxioms.lean": {
    "sha256": "da8c2b3fd23780417c717a39b3eacbc06e611dfa6b76a576c9f6bd0b0398482e",
    "git_blob": "8f0820b4953382bcaf3f7eb67b212d99ea31caa2",
    "observed_git_blob": "8f0820b4953382bcaf3f7eb67b212d99ea31caa2",
    "matches_candidate": true
  },
  "lean/Defialgebra.lean": {
    "sha256": "4f59f8498127bc11294f4af6846ba11cd5b51ac9be14ef38d130e58943383f8c",
    "git_blob": "aa8771436ccb388bac15701ede0ab2e3ae496c34",
    "observed_git_blob": "aa8771436ccb388bac15701ede0ab2e3ae496c34",
    "matches_candidate": true
  },
  "lean/Defialgebra/Basic.lean": {
    "sha256": "a88fef4d3efa63c9f9f5c948dd5ba1de3ea09d828ce8388ee83fa3d039e734a4",
    "git_blob": "99415d9d9fc72e540b7fc4f2e1242b9cfd06814d",
    "observed_git_blob": "99415d9d9fc72e540b7fc4f2e1242b9cfd06814d",
    "matches_candidate": true
  },
  "lean/Defialgebra/ConvexGeometry.lean": {
    "sha256": "3b301a6b0179c36b9936c923805a37938a0127f17121a4140929c980819fbca4",
    "git_blob": "e78cd3a9e86aa5afc8ce9d4cb04f670070e160a1",
    "observed_git_blob": "e78cd3a9e86aa5afc8ce9d4cb04f670070e160a1",
    "matches_candidate": true
  },
  "lean/Defialgebra/Discharge.lean": {
    "sha256": "405d38c11a64aebe6964793140f2a7ca557b77e6592975f3e561953d545aa963",
    "git_blob": "97a5e426932e06a9165f10ab938ddfcc52e3bcb4",
    "observed_git_blob": "97a5e426932e06a9165f10ab938ddfcc52e3bcb4",
    "matches_candidate": true
  },
  "lean/Defialgebra/Extremal.lean": {
    "sha256": "971391a3f4e733f935d5cba957a41c1c9e5db63748dd64db444267481e47b163",
    "git_blob": "36c1f63265b432a7460238cbb15b71b38fb69679",
    "observed_git_blob": "36c1f63265b432a7460238cbb15b71b38fb69679",
    "matches_candidate": true
  },
  "lean/Defialgebra/FlowPolarity.lean": {
    "sha256": "50903678a5684b4d10af3be3233356447574b964cbbb5e3d969fc7d6d56db7c6",
    "git_blob": "b6331d8b302e8b5a5fc9427386badb612b181e6a",
    "observed_git_blob": "b6331d8b302e8b5a5fc9427386badb612b181e6a",
    "matches_candidate": true
  },
  "lean/Defialgebra/Independence.lean": {
    "sha256": "831c297df2df0fe71220014ae9bc169e283834c6574c95b5d3fafa615d45e67c",
    "git_blob": "c61d9ef57575a22b4bf39a8d19c9a5c76beadd05",
    "observed_git_blob": "c61d9ef57575a22b4bf39a8d19c9a5c76beadd05",
    "matches_candidate": true
  },
  "lean/Defialgebra/Interface.lean": {
    "sha256": "e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8",
    "git_blob": "9e929cba38ef372286b54b2c3fb3fd538e8a23bc",
    "observed_git_blob": "9e929cba38ef372286b54b2c3fb3fd538e8a23bc",
    "matches_candidate": true
  },
  "lean/Defialgebra/Lattice.lean": {
    "sha256": "97f6dcda33de19f12f5971798e5745ace09ca66ee91f9c43c1d18030e6122eb4",
    "git_blob": "f1b7c97fbf4236e502d5c3aedce4b55e6222df7b",
    "observed_git_blob": "f1b7c97fbf4236e502d5c3aedce4b55e6222df7b",
    "matches_candidate": true
  },
  "lean/Defialgebra/Nary.lean": {
    "sha256": "31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680",
    "git_blob": "cddfae4195564e9cfca9b26a8b407b89fc89e4b5",
    "observed_git_blob": "cddfae4195564e9cfca9b26a8b407b89fc89e4b5",
    "matches_candidate": true
  },
  "lean/Defialgebra/Obstruction.lean": {
    "sha256": "095c3c21c905985676fdd3fefaf23f2a8d2bb72f29b4dd874cd5c7ed3726375d",
    "git_blob": "a856ddc9ae3027f4ea23fec14d4cb263aa8a17a3",
    "observed_git_blob": "a856ddc9ae3027f4ea23fec14d4cb263aa8a17a3",
    "matches_candidate": true
  },
  "lean/Defialgebra/Permission.lean": {
    "sha256": "cde935d39e0b9f4dfa92eaa7907096face5fb5403d8b1e53b80b3982283b7ed6",
    "git_blob": "3aa6d490c89e6a3e46594b6ac3adf8715d9c57da",
    "observed_git_blob": "3aa6d490c89e6a3e46594b6ac3adf8715d9c57da",
    "matches_candidate": true
  },
  "lean/Defialgebra/Polarity.lean": {
    "sha256": "3c0d18247d5df39c1f37f6a2adfb50cd304ecb3f6c7543da1f23bb8b53f203d3",
    "git_blob": "832cea5767c712e034071e348a5876623e9578db",
    "observed_git_blob": "832cea5767c712e034071e348a5876623e9578db",
    "matches_candidate": true
  },
  "lean/README.md": {
    "sha256": "e0385ee6346564bda844f47f58c99fbbbed97038ccc7bcaa693fda8a99250670",
    "git_blob": "d07426c593fecbac17b30496532190ad287b20b7",
    "observed_git_blob": "d07426c593fecbac17b30496532190ad287b20b7",
    "matches_candidate": true
  },
  "lean/lake-manifest.json": {
    "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "git_blob": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
    "observed_git_blob": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
    "matches_candidate": true
  },
  "lean/lakefile.toml": {
    "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "git_blob": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
    "observed_git_blob": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
    "matches_candidate": true
  },
  "lean/lean-toolchain": {
    "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "git_blob": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
    "observed_git_blob": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
    "matches_candidate": true
  },
  "review/semantic-kernel/sprint4/mutation-spec.json": {
    "sha256": "be5083e3292646426cc7a4ebd556421e363fd43aa856ddea5263c9d534c4c8eb",
    "git_blob": "78581f66f7a454cba4e815ca07954d02d6092ceb",
    "observed_git_blob": "78581f66f7a454cba4e815ca07954d02d6092ceb",
    "matches_candidate": true
  },
  "review/semantic-kernel/sprint5/mutation-spec.json": {
    "sha256": "b91a3e491bbd2ddeb3e0e72ee23622a3923db33aa0db5952b14e2831f78d5cb1",
    "git_blob": "4850c814acd162add4f454fe920c5e9d47945300",
    "observed_git_blob": "4850c814acd162add4f454fe920c5e9d47945300",
    "matches_candidate": true
  },
  "scripts/check_composition_mutations.py": {
    "sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
    "git_blob": "b86644fbdb49fdbcb8ade27e1b97c7715c22aa3b",
    "observed_git_blob": "b86644fbdb49fdbcb8ade27e1b97c7715c22aa3b",
    "matches_candidate": true
  },
  "scripts/check_typed_kernel_mutations.py": {
    "sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
    "git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
    "observed_git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
    "matches_candidate": true
  },
  "scripts/check_typed_kernel_typing.py": {
    "sha256": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6",
    "git_blob": "16e167b5d1d230bd004d8152552c239d7f00bc1d",
    "observed_git_blob": "16e167b5d1d230bd004d8152552c239d7f00bc1d",
    "matches_candidate": true
  },
  "scripts/corpus_normalize.py": {
    "sha256": "f7f00d7c80ba11ef80d268910066a47896538c223511f5588009487ecf3f9ecc",
    "git_blob": "176fa2e0f6548299cc19bcce390539ccf5db7dfa",
    "observed_git_blob": "176fa2e0f6548299cc19bcce390539ccf5db7dfa",
    "matches_candidate": true
  },
  "scripts/test_composition_mutation_runner.py": {
    "sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
    "git_blob": "19c780e4fe776f4d6f93581405230b4fb48d7fdf",
    "observed_git_blob": "19c780e4fe776f4d6f93581405230b4fb48d7fdf",
    "matches_candidate": true
  },
  "scripts/test_corpus_normalize.py": {
    "sha256": "0c3ef8580a44b81b9d55cd2e9cd03d74580d2ee722d5acd57609f0a94faf278f",
    "git_blob": "611d4d83677bd0569f3034087b12af13e0e59a2c",
    "observed_git_blob": "611d4d83677bd0569f3034087b12af13e0e59a2c",
    "matches_candidate": true
  },
  "scripts/test_kernel_axiom_audit.py": {
    "sha256": "b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b",
    "git_blob": "84d1bebfd92bec4c804fe3e7a2fe9f54650bfa1b",
    "observed_git_blob": "84d1bebfd92bec4c804fe3e7a2fe9f54650bfa1b",
    "matches_candidate": true
  },
  "scripts/test_typed_kernel_mutation_runner.py": {
    "sha256": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93",
    "git_blob": "a215b9cc55c2ee2ca3d0fd72385bfebda7ea435b",
    "observed_git_blob": "a215b9cc55c2ee2ca3d0fd72385bfebda7ea435b",
    "matches_candidate": true
  }
}

```

### EVIDENCE review/semantic-kernel/sprint6/regressions/verified-outcomes.json
SHA256 07a220c94dd5d2513255f79efced9250ff2e22ca4aba121ea72f0eb23844b9b7
```
{
  "checks": [
    {
      "label": "all seven required commands completed successfully",
      "passed": true
    },
    {
      "label": "source bytes unchanged during all regressions",
      "passed": true
    },
    {
      "label": "all 106 scoped inputs match the frozen Git objects",
      "passed": true
    },
    {
      "label": "typed-mutations full log hash matches",
      "passed": true
    },
    {
      "label": "composition-mutations full log hash matches",
      "passed": true
    },
    {
      "label": "composition-runner-controls full log hash matches",
      "passed": true
    },
    {
      "label": "typed-runner-controls full log hash matches",
      "passed": true
    },
    {
      "label": "axiom-controls full log hash matches",
      "passed": true
    },
    {
      "label": "typing-controls full log hash matches",
      "passed": true
    },
    {
      "label": "corpus-controls full log hash matches",
      "passed": true
    },
    {
      "label": "typed-mutations exact nonempty mutation inventory",
      "passed": true
    },
    {
      "label": "typed-mutations unchanged control all true",
      "passed": true
    },
    {
      "label": "typed-mutations/admin-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/admin-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/holder-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/holder-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/live-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/live-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-domain-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-domain-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-operation-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-operation-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-resource-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/cap-resource-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/revoke-noop full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/revoke-noop exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/invoke-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/invoke-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/guard-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/guard-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/state-read-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/state-read-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/env-read-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/env-read-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/domain-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/domain-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/debit-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/debit-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/supply-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/supply-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/accounting-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/accounting-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/write-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/write-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/registry-selection full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/registry-selection exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/zero-division-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/zero-division-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/inactive-state-read-omission full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/inactive-state-read-omission exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/supply-first-only full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/supply-first-only exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-freshness-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-freshness-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-future-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-future-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-positive-price-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/oracle-positive-price-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "typed-mutations/collateral-factor-weakened full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "typed-mutations/collateral-factor-weakened exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations exact nonempty mutation inventory",
      "passed": true
    },
    {
      "label": "composition-mutations unchanged control all true",
      "passed": true
    },
    {
      "label": "composition-mutations/reverse-order full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/reverse-order exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/drop-first-step full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/drop-first-step exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/continue-after-refusal full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/continue-after-refusal exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-ledger full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-ledger exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-capability-store full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-capability-store exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/omit-revocation-propagation full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/omit-revocation-propagation exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/interface-write-bypass full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/interface-write-bypass exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-output-index full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-output-index exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-output-unit full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-output-unit exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/drop-supply-receipt full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/drop-supply-receipt exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-continuation-index full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/reset-continuation-index exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-snapshot-index full inventory and semantic detection",
      "passed": true
    },
    {
      "label": "composition-mutations/wrong-snapshot-index exact executed generated source",
      "passed": true
    },
    {
      "label": "composition-runner-controls all actual classifications match",
      "passed": true
    },
    {
      "label": "typed-runner-controls all actual classifications match",
      "passed": true
    },
    {
      "label": "99 actual axiom-audit behavioral assertions pass",
      "passed": true
    },
    {
      "label": "axiom-audit copied source bytes unchanged",
      "passed": true
    },
    {
      "label": "one positive and three expected typing refusals",
      "passed": true
    },
    {
      "label": "typing source bytes unchanged",
      "passed": true
    },
    {
      "label": "20 corpus tests passed",
      "passed": true
    }
  ],
  "outcomes": {
    "typed-mutations": {
      "mutants_detected": 24,
      "comparisons_each": 189,
      "positive_controls_each": 3
    },
    "composition-mutations": {
      "mutants_detected": 12,
      "comparisons_each": 93,
      "positive_controls_each": 6
    },
    "composition-runner-controls": {
      "passed": 36,
      "total": 36
    },
    "typed-runner-controls": {
      "passed": 17,
      "total": 17
    },
    "axiom-controls": {
      "passed": 99,
      "total": 99
    },
    "typing-controls": {
      "positive": 1,
      "expected_type_errors": 3
    },
    "corpus-controls": {
      "tests_passed": 20,
      "observed_cli_invocations": 76
    }
  }
}

```

### EVIDENCE review/semantic-kernel/sprint6/regressions/REPORT.md
SHA256 02f8a0a13d8551e9c136b4a92e654aa4bf437a7bd1a04e9498cde981d50da88b
```
# Existing regression replay at Sprint 6 source freeze

All seven existing regression commands passed against frozen source candidate
`7cb4807d1ff22c5ac804b03feb4a2530c46146f2`.
No source edits or new Parallel regression commands were performed by this task.

| Existing suite | Observed result |
| --- | --- |
| Sprint 4 typed source mutations | 24/24 detected; 189 complete comparisons per control/mutant; 3 protected positives per mutant |
| Sprint 5 composition source mutations | 12/12 detected; 93 complete comparisons per control/mutant; 6 protected positives per mutant |
| Composition runner controls | 36/36 actual CLI classifications passed |
| Typed runner controls | 17/17 actual CLI classifications passed |
| Kernel axiom-audit controls | 99/99 assertions passed |
| Typed compiler controls | One executed positive and three expected unit type errors |
| Corpus normalization controls | 20/20 tests; 76 real CLI invocations recorded |

These are bounded sensitivity and regression results. A compiler refusal in the
typing suite is classified as a type error, not a financial semantic detection.
Expected failure/setup cases in runner and corpus controls are retained in their
full logs; the encompassing harnesses verified their intended classifications.
The axiom-audit controls deliberately introduce forbidden dependencies in isolated
fixtures; those fixtures are outside the accepted Lean import closure.

## Identity and execution

`../regression-runs.json` records each exact command, working directory, start/end
UTC timestamp, observed Git HEAD, exit, duration, script hash and complete log hash.
All seven commands reported the frozen candidate HEAD at start and finish.
Each script's `--help` was executed and retained before its suite.
The existing Sprint 5 saved command arrays were reused with freshly allocated
outside output paths. At most three independent harnesses ran concurrently.

`source-binding.json` binds 106 tracked inputs to both SHA-256 and their exact
Git blob objects in the candidate. This scope includes tracked Lean/scripts,
corpus inputs and preserved lanes, the source plan, and both historical mutation
specifications. Before/after snapshots matched exactly. Tool identity includes
the actual Lean and Python versions, executable paths and executable SHA-256,
plus Git version. The individual suites also retain their own input/tool records.

The final independent saved-evidence inspection passed 93 assertions, including
exact mutation inventories, full unchanged/mutant comparison inventories,
designated false checks, protected positives, generated source fingerprints,
runner classification counts, axiom assertion outcomes, and typing/corpus results.
See `verify-results.py` and `verified-outcomes.json`.

## Artifact preservation

Full generated mutation sources, compiler fixtures, isolated runner fixtures,
individual stdout/stderr logs, source manifests and suite result records were
copied from the fresh external run directories into their corresponding folders.
The corpus suite deletes its own temporary fixture directories as part of normal
unittest teardown; its complete 76-invocation output and source bindings remain.

Two synthetic fixture repositories created by the historical runner-control
scripts contained nested `.git` directories. Their copied metadata was archived
as `fixture-repo/git-metadata.tar` before removing the copied nested `.git`
directories, to avoid adding embedded Git repositories to the evidence commit.
Every archived member's bytes were compared to the copied original first.
`git-metadata-archives.json` records archive and member hashes. Original external
run directories remain intact. Dependency-package and deliberate control symlinks
are preserved as links; their targets are recorded without traversing them.

`artifact-manifest.json` inventories the final browsable/archived evidence bytes
and symlink targets. Its hash is recorded in `../regression-runs.json`.
The replay harness source is retained as `run-all.py`; it is an execution record,
and its fixed destination should not be reused over accepted evidence.

Full Lean builds, new Parallel mutations and native acceptance review are separate
parent tasks. This report does not claim those gates passed.

```

### EVIDENCE review/semantic-kernel/sprint6/integration/lean-runs.json
SHA256 7d838b42518f0ee63ab10d3eac5785a08fddbbe6336c60237a54d1258a62a7d3
```
{
  "source_revision": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
  "runs": [
    {
      "label": "build",
      "command": [
        "lake",
        "build"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.157795+00:00",
      "finished_utc": "2026-09-07T05:34:52.829580+00:00",
      "exit": 0,
      "log": "build.log",
      "log_sha256": "adeab4dd0170fbb929186c5568b59c601819b284154e94085a0dd568d4255764"
    },
    {
      "label": "parallel-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Parallel/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.833189+00:00",
      "finished_utc": "2026-09-07T05:34:54.577568+00:00",
      "exit": 0,
      "log": "parallel-audit.log",
      "log_sha256": "b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9"
    },
    {
      "label": "parallel-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Parallel/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.833555+00:00",
      "finished_utc": "2026-09-07T05:34:56.979265+00:00",
      "exit": 0,
      "log": "parallel-verify.log",
      "log_sha256": "82e4c2c957323dde95640e783c7306a124e9627f96a97a1785ccc9c1fe2c9eaf"
    },
    {
      "label": "composition-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.834103+00:00",
      "finished_utc": "2026-09-07T05:34:54.314266+00:00",
      "exit": 0,
      "log": "composition-audit.log",
      "log_sha256": "9173b87109f8c6c3f6afae01958f1480d84a8ec42cd34429f56aa077b1a89368"
    },
    {
      "label": "composition-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:54.314362+00:00",
      "finished_utc": "2026-09-07T05:34:59.056427+00:00",
      "exit": 0,
      "log": "composition-verify.log",
      "log_sha256": "56e39dbb1623f32c71599b0a70c3a9b7752319ccacadac71b2ac95565ef31fe0"
    },
    {
      "label": "typed-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:54.577704+00:00",
      "finished_utc": "2026-09-07T05:34:56.128775+00:00",
      "exit": 0,
      "log": "typed-audit.log",
      "log_sha256": "19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"
    },
    {
      "label": "typed-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:56.128916+00:00",
      "finished_utc": "2026-09-07T05:35:01.954985+00:00",
      "exit": 0,
      "log": "typed-verify.log",
      "log_sha256": "0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"
    },
    {
      "label": "audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:56.979517+00:00",
      "finished_utc": "2026-09-07T05:34:58.821822+00:00",
      "exit": 0,
      "log": "audit.log",
      "log_sha256": "61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63"
    },
    {
      "label": "contractaudit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/ContractAudit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:58.822384+00:00",
      "finished_utc": "2026-09-07T05:35:00.781051+00:00",
      "exit": 0,
      "log": "contractaudit.log",
      "log_sha256": "660f556e96037016023e457e37f692acf9e3ff0f16072fcc271511537494e438"
    },
    {
      "label": "verifyaxioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/VerifyAxioms.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:59.057109+00:00",
      "finished_utc": "2026-09-07T05:35:03.850883+00:00",
      "exit": 0,
      "log": "verifyaxioms.log",
      "log_sha256": "4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"
    }
  ],
  "sources": {
    "lean/DefiKernel/ContractExamples.lean": "4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b",
    "lean/DefiKernel/Core.lean": "767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d",
    "lean/DefiKernel/Examples.lean": "3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28",
    "lean/DefiKernel/ContractAcceptance.lean": "a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f",
    "lean/DefiKernel/Acceptance.lean": "9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11",
    "lean/DefiKernel/AxiomAudit.lean": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
    "lean/DefiKernel/Contracts.lean": "22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2",
    "lean/DefiKernel/Audit.lean": "7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400",
    "lean/DefiKernel/ContractAudit.lean": "600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9",
    "lean/DefiKernel/VerifyAxioms.lean": "da8c2b3fd23780417c717a39b3eacbc06e611dfa6b76a576c9f6bd0b0398482e",
    "lean/DefiKernel/Parallel/Dependency.lean": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "lean/DefiKernel/Parallel/Tests.lean": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
    "lean/DefiKernel/Parallel/Execution.lean": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "lean/DefiKernel/Parallel/Compatibility.lean": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "lean/DefiKernel/Parallel/Observation.lean": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "lean/DefiKernel/Parallel/Examples.lean": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "lean/DefiKernel/Parallel/ExecutionTests.lean": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
    "lean/DefiKernel/Parallel/Preservation.lean": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "lean/DefiKernel/Parallel/PreservationFixtures.lean": "0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7",
    "lean/DefiKernel/Parallel/Commutation.lean": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "lean/DefiKernel/Parallel/ObservationTests.lean": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "lean/DefiKernel/Parallel/Audit.lean": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
    "lean/DefiKernel/Parallel/Verify.lean": "ff25ad430ff36275ecaf7ccfab8a55f2e853cbd9381a739163f81bd3d7bbd3ab",
    "lean/DefiKernel/Typed/ExprTests.lean": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "lean/DefiKernel/Typed/TransitionTests.lean": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
    "lean/DefiKernel/Composition/Tests.lean": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/InterfaceTests.lean": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Composition/ExecutionTests.lean": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Composition/Audit.lean": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "lean/DefiKernel/Composition/Verify.lean": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "lean/DefiKernel/Parallel/Dependency/Fixtures.lean": "14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45",
    "lean/DefiKernel.lean": "ffa25f35c430bef69e654d18e2d907895aa0c8e7681dada4d61edb858c3f10bb"
  },
  "source_drift": [],
  "git_object_mismatches": [],
  "all_passed": true
}

```

### EVIDENCE review/semantic-kernel/sprint6/integration/parallel-audit.log
SHA256 b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9
```
parallel.compat.catalog-positive: true
parallel.compat.invocation-exact-left: true
parallel.compat.invocation-exact-right: true
parallel.compat.funded-left-complete: true
parallel.compat.funded-right-complete: true
parallel.compat.independent: true
parallel.compat.empty: true
parallel.compat.left-empty: true
parallel.compat.common-read: true
parallel.compat.write-write-witness: true
parallel.compat.forward-read: true
parallel.compat.reverse-read: true
parallel.compat.hidden-inactive-guard: true
parallel.compat.hidden-inactive-guard-funded: true
parallel.compat.hidden-delta: true
parallel.compat.hidden-delta-funded: true
parallel.compat.hidden-supply: true
parallel.compat.hidden-supply-funded: true
parallel.compat.output-dependency: true
parallel.compat.output-exact: true
parallel.compat.zero-target: true
parallel.compat.zero-target-funded: true
parallel.compat.zero-target-exact: true
parallel.compat.unreachable-suffix: true
parallel.compat.numeric-input-not-evaluated: true
parallel.compat.prior-output-not-evaluated: true
parallel.compat.capability-not-evaluated: true
parallel.compat.catalog-first: true
parallel.compat.left-before-right: true
parallel.compat.local-order: true
parallel.compat.structural-before-conflict: true
parallel.compat.malformed-reference: true
parallel.compat.access-check: true
parallel.compat.forward-funded: true
parallel.compat.reverse-funded: true
parallel.compat.output-funded: true
parallel.compat.guard-read-exact: true
parallel.compat.delta-read-exact: true
parallel.compat.supply-read-exact: true
parallel.compat.forward-before-reverse: true
parallel.compat.common-read-no-writes: true
parallel.compat.first-list-witness: true
parallel.observe.empty: true
parallel.observe.refusal-reason: true
parallel.observe.refusal-index: true
parallel.observe.refusal-step: true
parallel.observe.local-index: true
parallel.observe.history: true
parallel.observe.event-index: true
parallel.observe.event-step: true
parallel.observe.event-outputs: true
parallel.observe.output-unit: true
parallel.observe.output-value: true
parallel.observe.raw-world-context: true
parallel.observe.final-ledger: true
parallel.observe.final-store: true
parallel.observe.receipt.kind: true
parallel.observe.receipt.request: true
parallel.observe.receipt.guard: true
parallel.observe.receipt.deltas: true
parallel.observe.receipt.supplies: true
parallel.observe.receipt.required-state: true
parallel.observe.receipt.required-env: true
parallel.observe.receipt.declared-state: true
parallel.observe.receipt.declared-env: true
parallel.observe.receipt.writes: true
parallel.empty: true
parallel.empty.lr: true
parallel.empty.rl: true
parallel.refused.catalog-unchanged: true
parallel.refused.conflict-unchanged: true
parallel.refused.structural-unchanged: true
parallel.fixture.catalog: true
parallel.fixture.basic.complete: true
parallel.fixture.same-asset.complete: true
parallel.fixture.refusal.peer-runs: true
parallel.fixture.refusal.prefix-kept: true
parallel.fixture.refusal.dual: true
parallel.fixture.refusal.guard: true
parallel.fixture.refusal.input-unit: true
parallel.fixture.refusal.missing-capability: true
parallel.fixture.empty.right: true
parallel.fixture.empty.left: true
parallel.fixture.empty.both: true
parallel.fixture.routing.peer-only: true
parallel.fixture.routing.funded-literal: true
parallel.fixture.routing.own-history: true
parallel.fixture.routing.both-own-history: true
parallel.fixture.routing.shared-qualified-key: true
parallel.fixture.boundary.local-identity: true
parallel.fixture.capability.revoked: true
parallel.fixture.capability.actual-revoke: true
parallel.fixture.capability.reusable-shared-grant: true
parallel.fixture.supply.complete: true
parallel.fixture.supply.both-receipts: true
parallel.fixture.supply.prefix-refusal: true
parallel.fixture.stateful.prefix: true
parallel.fixture.stateful.supply: true
parallel.fixture.cancelling.admission: true
parallel.fixture.cancelling.funded: true
parallel.fixture.refusal.world-preserved: true
parallel.fixture.refusal.suffix-world-preserved: true
parallel.fixture.raw-context-differs: true
parallel.fixture.basic.lr.complete: true
parallel.fixture.basic.rl.complete: true
parallel.fixture.prefix.lr.complete: true
parallel.fixture.prefix.rl.complete: true
parallel.fixture.routing.lr.complete: true
parallel.fixture.routing.rl.complete: true
parallel.fixture.boundary.lr.complete: true
parallel.fixture.boundary.rl.complete: true
parallel.fixture.supply.lr.complete: true
parallel.fixture.supply.rl.complete: true
parallel.fixture.stateful.lr.complete: true
parallel.fixture.stateful.rl.complete: true
parallel.fixture.revoked.lr.complete: true
parallel.fixture.revoked.rl.complete: true
parallel.fixture.same-asset.lr.complete: true
parallel.fixture.same-asset.rl.complete: true
parallel.fixture.peer-runs.lr.complete: true
parallel.fixture.peer-runs.rl.complete: true
parallel.fixture.dual.lr.complete: true
parallel.fixture.dual.rl.complete: true
parallel.fixture.both-own-history.lr.complete: true
parallel.fixture.both-own-history.rl.complete: true
parallel.fixture.stateful-supply.lr.complete: true
parallel.fixture.stateful-supply.rl.complete: true
parallel.fixture.shared-qualified-key.lr.complete: true
parallel.fixture.shared-qualified-key.rl.complete: true
parallel.fixture.supply-prefix.lr.complete: true
parallel.fixture.supply-prefix.rl.complete: true

```

### EVIDENCE review/semantic-kernel/sprint6/integration/parallel-verify.log
SHA256 82e4c2c957323dde95640e783c7306a124e9627f96a97a1785ccc9c1fe2c9eaf
```
AXIOM AUDIT scope: imported module prefix DefiKernel.Parallel; modules=[DefiKernel.Parallel.Compatibility,
 DefiKernel.Parallel.CompatibilityTests,
 DefiKernel.Parallel.Observation,
 DefiKernel.Parallel.Execution,
 DefiKernel.Parallel.ObservationTests,
 DefiKernel.Parallel.ExecutionTests,
 DefiKernel.Parallel.Examples,
 DefiKernel.Parallel.Dependency,
 DefiKernel.Parallel.Dependency.Adapter,
 DefiKernel.Parallel.Commutation,
 DefiKernel.Parallel.Preservation,
 DefiKernel.Parallel.Tests,
 DefiKernel.Parallel.Audit,
 DefiKernel.Parallel.Dependency.Fixtures,
 DefiKernel.Parallel.PreservationFixtures]
AXIOM AUDIT theorem: DefiKernel.Parallel.admit_compatible; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.admit_ok; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom_cons; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom_member; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom_writes_read; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeInvocation_coverage; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeInvocation_ok; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeInvocation_writes_read; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzed_dependencies; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzed_outputs; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.applyEvaluated_congr; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.checkCompatibility_ok_iff; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.compatible_symm; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.continueRun_congr; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.continueRun_frame; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluate_congr; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluated_effect_zero_outside; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluated_supplies_empty; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluated_targets; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.executeStep_congr; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.executeStep_refusal_iff; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.executeStep_target_frame; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.execute_congr; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.execute_refusal_iff; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.execute_success_congr; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.execute_target_frame; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.expression_congr_of_region; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.extractReceipt_congr; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.extractReceipt_supplies_empty; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.firstOverlap_none_iff; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.funds_iff; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.local_total_preservation; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mapM_congr_on; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mapM_ok_mem; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_accounting; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_agrees_left; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_agrees_right; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_balance_sum; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_nonnegative; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_outside; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_store; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_supported_frame; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_swap; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld_two_invariants; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.merge_serialLR; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual_iff; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observeBranch_failure; module=DefiKernel.Parallel.Observation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observeBranch_outputs; module=DefiKernel.Parallel.Observation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.prepareInvocation_shape; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.rerun_after_peer; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.resolveRefs_append_ok; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.resolveRefs_mem_of_resolve; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.resolveRefs_member; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_accounting; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_authority; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_congr; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_empty; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_events_invoke; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_frame; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_invariant; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch_prefix_nonnegative; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_accounting; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_empty_left; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_empty_right; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_accounting; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_authority; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_frame; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_nonnegative; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_supported_frame; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_executed_two_invariants; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_refuses; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_serialLR; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_serialRL; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel_two_invariants; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.serial_orders_equivalent; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.singleton_commutation; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.snapshots_congr; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.step_no_supply; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.supports_total; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.trace_invoke_stores; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.worldEq_iff; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.congr_simp; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.eq_1; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.eq_2; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.traceSupply.congr_simp; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchId.ofNat_ctorIdx; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.ConflictKind.ofNat_ctorIdx; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.capabilities; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.events; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.failure; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.nextIndex; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.observation; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.outputs; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CursorAgrees.state; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.accounting_refusal; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.division_evaluation; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.division_execution; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_agrees; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_differs; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_funds_iff; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_malformed_refusal; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_success; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.funded_malformed_refusal; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.inactive_evaluation_congr; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed_effect_outside; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed_evaluates; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed_targets; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed_writes_fail; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.observation_error; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.poor_malformed_refusal; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.refused_iff; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.target_balance_is_needed; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ExecutionAgrees.eq_1; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ExecutionAgrees.eq_2; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ExecutionAgrees.eq_3; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.eq_2; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.eq_3; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.refl; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.symm; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent.trans; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.admitted; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.executed; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.initial_totals; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.initialized_two_invariants; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.joined_authority; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.joined_nonnegative; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_accounting; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_admitted; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_authority; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_executed; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_refusal_receipts; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.protected_collateral; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_admitted; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_executed; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_free; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_receipts; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_totals; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.unsupported_counterexample; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.unsupported_is_not_supported; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.written_support_counterexample; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ResolvedReadsAgree.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.StepAgrees.eq_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.StepAgrees.eq_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.StepAgrees.eq_3; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.WorldEquivalent.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.WorldEquivalent.refl; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.WorldEquivalent.symm; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.WorldEquivalent.trans; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom.eq_2; module=DefiKernel.Parallel.Commutation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranchFrom.eq_def; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeInvocation_coverage._simp_1_1; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeInvocation_coverage._simp_1_2; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzed_outputs._simp_1_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzed_outputs._simp_1_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.checkCompatibility_ok_iff._simp_1_1; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluate_congr._simp_1_2; module=DefiKernel.Parallel.Dependency; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.evaluate_congr._simp_1_3; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.firstOverlap._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.firstOverlap.eq_1; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.firstOverlap_none_iff._simp_1_2; module=DefiKernel.Parallel.Compatibility; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchId._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchId._proof_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqConflictKind._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqConflictKind._proof_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld._proof_1; module=DefiKernel.Parallel.Execution; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld._proof_2; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.mergeWorld.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual.congr_simp; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual.eq_2; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual.eq_3; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observationsEqual_iff._simp_1_11; module=DefiKernel.Parallel.Execution; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.observeBranch.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.observeEvent.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runParallel.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runSerialLR.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.runSerialRL.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.worldEq.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.Except.map.match_1.eq_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.Except.map.match_1.eq_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.0.Except.map.match_1.eq_1; module=DefiKernel.Parallel.Dependency; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.0.Except.map.match_1.eq_2; module=DefiKernel.Parallel.Dependency; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Preservation.0.Except.map.match_1.eq_1; module=DefiKernel.Parallel.Preservation; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Preservation.0.Except.map.match_1.eq_2; module=DefiKernel.Parallel.Preservation; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.Except.map.match_1.eq_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.Except.map.match_1.eq_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.configuration.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.conflict.inj; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.conflict.injEq; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.conflict.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.structural.inj; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.structural.injEq; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.AdmissionFailure.structural.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchId.left.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchId.right.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchObservation.mk.inj; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchObservation.mk.injEq; module=DefiKernel.Parallel.Observation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.BranchObservation.mk.sizeOf_spec; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.CompatibilityTests.initial._proof_1; module=DefiKernel.Parallel.CompatibilityTests; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.CompatibilityTests.leftFP.eq_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.CompatibilityTests.rightFP.eq_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.ConflictKind.leftWriteRightRead.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.ConflictKind.rightWriteLeftRead.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.ConflictKind.writeWrite.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.accounting_refusal._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.division_execution._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreignState._proof_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.foreign_success._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.funded_malformed_refusal._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.inactiveReads.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.malformed_writes_fail._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.poorState._proof_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.poor_malformed_refusal._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.refused_iff._simp_1_4; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.targetRegion.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.DependencyFixtures.target_balance_is_needed._proof_1_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.EventObservation.mk.inj; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.EventObservation.mk.injEq; module=DefiKernel.Parallel.Observation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.EventObservation.mk.sizeOf_spec; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.Examples.balanceTable.eq_1; module=DefiKernel.Parallel.Examples; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Examples.initial._proof_1; module=DefiKernel.Parallel.Examples; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ExecutionAgrees._sparseCasesOn_1.else_eq; module=DefiKernel.Parallel.Dependency; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.ExecutionAgrees._sparseCasesOn_2.else_eq; module=DefiKernel.Parallel.Dependency; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.Footprint.append.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.Footprint.empty.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.Footprint.mk.inj; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.Footprint.mk.injEq; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.Footprint.mk.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.Joined.mk.inj; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Joined.mk.injEq; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Joined.mk.sizeOf_spec; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Joined.supply.eq_1; module=DefiKernel.Parallel.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.LocalFailure.mk.inj; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.LocalFailure.mk.injEq; module=DefiKernel.Parallel.Compatibility; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.LocalFailure.mk.sizeOf_spec; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent._sparseCasesOn_1.else_eq; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.ObservationallyEquivalent._sparseCasesOn_2.else_eq; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.admitted._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.initial_totals._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.initialized_two_invariants._simp_1_2; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.initialized_two_invariants._simp_1_3; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_admitted._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.prefix_refusal_receipts._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.protected_collateral._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_admitted._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.supply_receipts._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.unsupported_counterexample._proof_1_1; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.PreservationFixtures.unsupported_counterexample._proof_1_2; module=DefiKernel.Parallel.PreservationFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.executed.inj; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.executed.injEq; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.executed.sizeOf_spec; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.refused.inj; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.refused.injEq; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.Result.refused.sizeOf_spec; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.StepAgrees._sparseCasesOn_1.else_eq; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.StepAgrees._sparseCasesOn_2.else_eq; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_10; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_11; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_12; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_13; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_3; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_4; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_5; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_6; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_7; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_8; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq._proof_9; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_7; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_8; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEvaluated.decEq._proof_9; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEventObservation.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEventObservation.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEventObservation.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEventObservation.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqEventObservation.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqFootprint.decEq._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqFootprint.decEq._proof_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqFootprint.decEq._proof_3; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInputSource.decEq._proof_7; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqInvocation.decEq._proof_7; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocalFailure.decEq._proof_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocalFailure.decEq._proof_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocalFailure.decEq._proof_3; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_10; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_11; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_12; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_13; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_7; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_8; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqReceipt.decEq._proof_9; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqRequest.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_1; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_10; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_11; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_12; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_2; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_3; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_4; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_5; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_6; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_7; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_8; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Parallel.instDecidableEqStep.decEq._proof_9; module=DefiKernel.Parallel.Observation; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Typed.CellRef.resolve.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Typed.PartyRef.resolve.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Typed.PartyRef.resolve.eq_2; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Typed.PartyRef.resolve.eq_3; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Typed.Template.requiredStateReads.eq_1; module=DefiKernel.Parallel.Dependency; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Typed.TransitionTests.alice.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Typed.TransitionTests.bob.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Typed.TransitionTests.refused.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Typed.TransitionTests.refused.eq_2; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Typed.TransitionTests.transfer.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Commutation.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.eq_1; module=DefiKernel.Parallel.Commutation; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Commutation.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.eq_2; module=DefiKernel.Parallel.Commutation; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.eq_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.eq_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_1.eq_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_1.eq_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_3.eq_1; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_3.eq_2; module=DefiKernel.Parallel.Compatibility; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.0.DefiKernel.Parallel.ExecutionAgrees.match_1.eq_1; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.0.DefiKernel.Parallel.ExecutionAgrees.match_1.eq_2; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.0.DefiKernel.Parallel.ExecutionAgrees.match_1.eq_3; module=DefiKernel.Parallel.Dependency; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Execution.0.DefiKernel.Parallel.ObservationallyEquivalent.match_1.eq_1; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Execution.0.DefiKernel.Parallel.ObservationallyEquivalent.match_1.eq_2; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Execution.0.DefiKernel.Parallel.ObservationallyEquivalent.match_1.eq_3; module=DefiKernel.Parallel.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_1.eq_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_1.eq_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_3.eq_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_3.eq_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Parallel.StepAgrees.match_1.eq_1; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Parallel.StepAgrees.match_1.eq_2; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Parallel.StepAgrees.match_1.eq_3; module=DefiKernel.Parallel.Dependency.Adapter; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.eq_1; module=DefiKernel.Parallel.Preservation; axioms=[propext]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.eq_2; module=DefiKernel.Parallel.Preservation; axioms=[propext]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.TransitionTests.refused.match_1.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.TransitionTests.refused.match_1.eq_2; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.instReprPartyRef.repr.match_1.eq_1; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.instReprPartyRef.repr.match_1.eq_2; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.instReprPartyRef.repr.match_1.eq_3; module=DefiKernel.Parallel.Dependency.Fixtures; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Branch; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Compatible; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionAgrees; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalPreservation; module=DefiKernel.Parallel.Preservation; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationallyEquivalent; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ParallelBoundary; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ResolvedReadsAgree; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.StepAgrees; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.TargetsWithin; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.WorldEquivalent; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.admit; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranch; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranchFrom; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeInvocation; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.checkCompatibility; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.firstOverlap; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqAdmissionFailure; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqBranchId; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqBranchObservation; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqConflictKind; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEvaluated; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEventObservation; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqFootprint; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInputSource; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInvocation; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocalFailure; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocatedFailure; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqOutputObservation; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqReceipt; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqRequest; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqStep; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprAdmissionFailure; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprBranchId; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprConflictKind; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprFootprint; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprLocalFailure; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.mergeWorld; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.observationsEqual; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.observeBranch; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.observeEvent; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.runBranch; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.runParallel; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.runSerialLR; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.runSerialRL; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.runtimeChecks; module=DefiKernel.Parallel.Audit; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.worldEq; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure._sizeOf_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure._sizeOf_inst; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.casesOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.ctorElim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.ctorElimType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.ctorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.noConfusionType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.recOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId._sizeOf_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId._sizeOf_inst; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.casesOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.ctorElim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.ctorElimType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.ctorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.noConfusionType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.ofNat; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.recOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.toCtorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation._sizeOf_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation._sizeOf_inst; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.casesOn; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.ctorIdx; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.events; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.failure; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.nextIndex; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.noConfusion; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.noConfusionType; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.outputs; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.recOn; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.C; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.F; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.I; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.accepted; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.aliceShare; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.aliceUSD; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.bobUSD; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.boundary; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.cellRef; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.cfg; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.checks; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.common; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.deniedCfg; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.funded; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.fundedExact; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.hidden; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.hiddenDelta; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.hiddenSupply; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.initial; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.left; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.leftFP; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.malformed; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.overlap; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.packed; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.readOnly; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.resultEq; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.right; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.rightFP; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.shareOp; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.transferOp; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.usdOp; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.vaultShare; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.zeroTarget; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind._sizeOf_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind._sizeOf_inst; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.casesOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.ctorElim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.ctorElimType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.ctorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.noConfusionType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.ofNat; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.recOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.toCtorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CursorAgrees.casesOn; module=DefiKernel.Parallel.Commutation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.CursorAgrees.recOn; module=DefiKernel.Parallel.Commutation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.dividing; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.evaluated; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.exec; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.foreignState; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.inactiveReads; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.malformed; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.missingObservation; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.poorState; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.targetRegion; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.DependencyFixtures.unbalanced; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation._sizeOf_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation._sizeOf_inst; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.casesOn; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.ctorIdx; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.index; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.noConfusion; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.noConfusionType; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.outputs; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.recOn; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.receipt; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.step; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.B; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.C; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.Evt; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.I; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.Obs; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.R; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.W; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.aliceShare; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.aliceUSD; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.balanceTable; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.basicLeft; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.basicRight; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.bobUSD; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.boundaries; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cancelling; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cancellingExpected; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cancellingInvocation; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.caps; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cellRef; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cells; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.cfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.config; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.evaluatedTransfer; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.event; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.failure; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.initial; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.invoke; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.leftEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.matchesExpected; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.noOp; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.noOpEvaluated; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.noOpInvocation; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.observed; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.output; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.packed; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.paramTemplate; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.peerEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.peerUSD; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.peerUSDTransfer; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.poolUSD; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.protectedCell; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.reusableCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.revokedInitial; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.revokedStore; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.rightEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.sameAssetCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.shareTransfer; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.sharedReadCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.sharedReadExpected; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.shares; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.source; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.statefulCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.statefulEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.statefulSupply; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.statefulSupplyEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.statefulTransfer; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.store; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.supplyCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.supplyEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.supplyTemplate; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedBoundaries; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedCfg; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedExpectedLeft; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedExpectedRight; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedInvocation; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedLeft; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedRight; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedTemplate; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.transferEvent; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.transferTemplate; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.usd; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.usdTransfer; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.vaultShare; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.vaultUSD; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionAgrees._sparseCasesOn_1; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionAgrees._sparseCasesOn_2; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionAgrees.match_1; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionTests.boundaries; module=DefiKernel.Parallel.ExecutionTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionTests.checks; module=DefiKernel.Parallel.ExecutionTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionTests.emptyExpected; module=DefiKernel.Parallel.ExecutionTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionTests.refusedUnchanged; module=DefiKernel.Parallel.ExecutionTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint._sizeOf_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint._sizeOf_inst; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.append; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.casesOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.ctorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.empty; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.noConfusionType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.reads; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.recOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.writes; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined._sizeOf_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined._sizeOf_inst; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.casesOn; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.ctorIdx; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.left; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.noConfusion; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.noConfusionType; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.recOn; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.right; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.supply; module=DefiKernel.Parallel.Preservation; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.world; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure._sizeOf_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure._sizeOf_inst; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.casesOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.ctorIdx; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.index; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.noConfusionType; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.reason; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.recOn; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.changedWorld; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.checks; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.emptyCursor; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.evaluated; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.event; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.invocation; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.output; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.receiptChanges; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.refusal; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.request; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationallyEquivalent._sparseCasesOn_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationallyEquivalent._sparseCasesOn_2; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationallyEquivalent.match_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.burn; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.burnFP; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.burnInv; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.collateralPredicate; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.joined; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.mint; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.mintFP; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.mintInv; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.prefixJoined; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.refusedMint; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.shareRegion; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.supplyCfg; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.supplyInitial; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.supplyJoined; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.PreservationFixtures.usdRegion; module=DefiKernel.Parallel.PreservationFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result._sizeOf_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result._sizeOf_inst; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.casesOn; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.ctorElim; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.ctorElimType; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.ctorIdx; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.noConfusion; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.noConfusionType; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.recOn; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.StepAgrees._sparseCasesOn_1; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.StepAgrees._sparseCasesOn_2; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.StepAgrees.match_1; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.admissionRefused; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.basic; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.dualRefusal; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.peerRuns; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.prefixKept; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.rightRouteExpected; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routeExpected; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routeForeign; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routeForeignExpected; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routingForeign; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routingOwn; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.routingRightOwn; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.serialChecks; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.stateSupplyCfg; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.stateSupplyExpected; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.statefulExpected; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.statefulRun; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.supplyLeft; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.supplyRight; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.supplyRun; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranchFrom._f; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranchFrom._sunfold; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranchFrom._unsafe_rec; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeBranchFrom.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeInvocation.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeInvocation.match_3; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.analyzeInvocation.match_5; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.checkCompatibility.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEvaluated.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEventObservation.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqFootprint.decEq; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInputSource.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInvocation.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocalFailure.decEq; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqReceipt.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqRequest.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqStep.decEq; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprAdmissionFailure.repr; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprBranchId.repr; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprConflictKind.repr; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprFootprint.repr; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprLocalFailure.repr; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.runParallel.match_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.runParallel_serialRL.match_1_2; module=DefiKernel.Parallel.Commutation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.runSerialLR.match_1; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Compatibility.0.Except.map.match_1.splitter; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.0.Except.map.match_1.splitter; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Preservation.0.Except.map.match_1.splitter; module=DefiKernel.Parallel.Preservation; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Adapter.0.Except.map.match_1.splitter; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.configuration.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.conflict.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.conflict.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.structural.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.AdmissionFailure.structural.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.left.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchId.right.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.mk._flat_ctor; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.BranchObservation.mk.noConfusion; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.accepted.match_1; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CompatibilityTests.fundedExact.match_1; module=DefiKernel.Parallel.CompatibilityTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.leftWriteRightRead.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.rightWriteLeftRead.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ConflictKind.writeWrite.elim; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.CursorAgrees.mk._flat_ctor; module=DefiKernel.Parallel.Commutation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.mk._flat_ctor; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.EventObservation.mk.noConfusion; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.config.match_1; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.config.match_3; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.matchesExpected.match_1; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Examples.timedBoundaries.match_1; module=DefiKernel.Parallel.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ExecutionTests.refusedUnchanged.match_1; module=DefiKernel.Parallel.ExecutionTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.mk._flat_ctor; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Footprint.mk.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.mk._flat_ctor; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Joined.mk.noConfusion; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.mk._flat_ctor; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.LocalFailure.mk.noConfusion; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.ObservationTests.checks.match_1; module=DefiKernel.Parallel.ObservationTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.executed.elim; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.executed.noConfusion; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.refused.elim; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Result.refused.noConfusion; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.admissionRefused.match_1; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks._sparseCasesOn_3; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks._sparseCasesOn_6; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks.match_1; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks.match_3; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.Tests.checks.match_6; module=DefiKernel.Parallel.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqAdmissionFailure.decEq.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqBranchObservation.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEvaluated.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqEventObservation.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqFootprint.decEq.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInputSource.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqInvocation.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocalFailure.decEq.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqLocatedFailure.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqOutputObservation.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqReceipt.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqRequest.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instDecidableEqStep.decEq.match_1; module=DefiKernel.Parallel.Observation; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprAdmissionFailure.repr.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprBranchId.repr.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Parallel.instReprConflictKind.repr.match_1; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Commutation.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.splitter; module=DefiKernel.Parallel.Commutation; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeBranchFrom.match_1.splitter; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_1.splitter; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Compatibility.0.DefiKernel.Parallel.analyzeInvocation.match_3.splitter; module=DefiKernel.Parallel.Compatibility; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.0.DefiKernel.Parallel.ExecutionAgrees.match_1.splitter; module=DefiKernel.Parallel.Dependency; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Execution.0.DefiKernel.Parallel.ObservationallyEquivalent.match_1.splitter; module=DefiKernel.Parallel.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_1.splitter; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Composition.prepareInvocation.match_3.splitter; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Adapter.0.DefiKernel.Parallel.StepAgrees.match_1.splitter; module=DefiKernel.Parallel.Dependency.Adapter; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.splitter; module=DefiKernel.Parallel.Preservation; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.TransitionTests.refused.match_1.splitter; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Dependency.Fixtures.0.DefiKernel.Typed.instReprPartyRef.repr.match_1.splitter; module=DefiKernel.Parallel.Dependency.Fixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Parallel.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.splitter._sparseCasesOn_2; module=DefiKernel.Parallel.Preservation; kind=definition; axioms=[propext]
AXIOM AUDIT DECLARATIONS PASSED: 419/419 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 388/388 theorems; forbidden=0

```

### EVIDENCE review/semantic-kernel/sprint6/preservation.json
SHA256 8d10c6d7c5edd651dfcc15353293c3eba98fcfe35199ea35ece5a36fdd006056
```
{
  "checked_utc": "2026-09-07T05:36:45.543012+00:00",
  "baseline_commit": "cd3187534f91f2a0f25e65722652d948ff178f39",
  "source_candidate": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
  "checks": {
    "preserved_files": {
      "checked": 165,
      "mismatches": []
    },
    "protected_kernel_sources": {
      "checked": 32,
      "mismatches": []
    },
    "tracked_lean_files": {
      "checked": 435,
      "mismatches": []
    },
    "import_root_only_adds_parallel_verify": true
  },
  "baseline_manifest_sha256": "38bec6049d75919b99097db5e654e9b421791c8f754805cd53262366c95eb551"
}

```

### EVIDENCE review/semantic-kernel/sprint6/proof-inventory-driver.lean
SHA256 a59abeced191d4e4743b8353ee77cde2c45a3a755ecdf310b08c643daa2907aa
```
import DefiKernel.Parallel.Verify

open Lean Elab Command DefiKernel.AxiomAudit

elab "#parallel_proof_types" : command => do
  let env ← getEnv
  for (name, moduleName) in importedTheorems env `DefiKernel.Parallel do
    let some info := env.find? name | throwError "Missing discovered theorem {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    let row := Json.mkObj [
      ("name", toJson name.toString),
      ("module", toJson moduleName.toString),
      ("statement", toJson type.pretty),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"PARALLEL_PROOF_JSON {row.compress}"

set_option pp.universes true in
set_option pp.explicit true in
#parallel_proof_types

```

### EVIDENCE review/semantic-kernel/sprint6/coverage.md
SHA256 7da91f48c704c4d76b360183b156ad3e05f0700c160afdb7e48e0777bf62b8f5
```
# Sprint 6 scenario coverage

All 47 approved scenarios and all 48 tasks are mapped below to actual existing declarations,
check IDs, compiler fixtures, or recorded process artifacts. The four specs contain 17 requirements.
This is an integrated Lean and evidence snapshot, not a claim of final sprint acceptance.
The machine-readable [scenario map](scenario-map.json) contains exact WHEN/THEN criteria,
task criteria, evidence classes, source lines, paths, hashes, and explicit pending obligations.

Evidence classes distinguish generic kernel proofs, concrete reference proof instances,
counterexamples, bounded runtime comparisons, compiler controls, actual runner controls,
advisory planning reviews, source inspection, pending semantic mutants, integrated audits and
delivery obligations. Financial fixtures are development cases. Model-check counts, compiler
refusals and test results are not relabeled mathematical theorems.

Verified focused inventories: 42 compatibility comparisons, 59 complete financial comparisons,
24 observation sensitivity comparisons and 6 executor controls. Each selected runtime identifier
is present with a true result in its full saved log; generated LR/RL and receipt labels are
resolved through their actual source generators. Every cited theorem exists in source and its
named axiom log. Every evidence path exists. No new financial scenario/oracle gap was found.

The 10 integrated Lean commands passed on source revision `7cb4807d1ff22c5ac804b03feb4a2530c46146f2`,
with no source drift or Git-object mismatch: 131/131 runtime comparisons and 388/388 theorem plus
419/419 supplemental axiom checks, zero forbidden dependencies. The proof inventory separately
records 126 explicit theorems (88 generic, 35 reference, 3 counterexamples) and 262 generated theorems.
The revised 45/45 actual runner controls match current runner/harness hashes; the initial 44-run
and observed diagnostic-parser failure remain historical evidence. Production mutation evidence,
historical Python regressions, native Grok/Fable implementation review, and delivery/archive
remain pending.
Planning's earlier unavailable/incomplete reviewer records remain non-passes in historical order;
the final gate explicitly records separate GPT-6 ACCEPT and Fable ACCEPT WITH LIMITATIONS.

| ID | Capability / scenario | Existing evidence identifiers | Evidence status | Tasks |
| --- | --- | --- | --- | --- |
| S01 | parallel-compatibility / Hidden reads | `DefiKernel.Parallel.analyzeInvocation_coverage`, `DefiKernel.Parallel.expression_congr_of_region`, `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-inactive-guard-funded`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-delta-funded`, `parallel.compat.hidden-supply`, `parallel.compat.hidden-supply-funded`, `parallel.compat.guard-read-exact`, `parallel.compat.delta-read-exact`, `parallel.compat.supply-read-exact` | focused-evidence-verified | 2.2, 2.3, 2.5, 3.1, 6.3 |
| S02 | parallel-compatibility / Balance and output dependencies | `DefiKernel.Parallel.analyzed_dependencies`, `DefiKernel.Parallel.analyzed_outputs`, `DefiKernel.Parallel.funds_iff`, `parallel.compat.zero-target`, `parallel.compat.zero-target-funded`, `parallel.compat.zero-target-exact`, `parallel.compat.output-dependency`, `parallel.compat.output-funded`, `parallel.compat.output-exact` | focused-evidence-verified | 2.2, 2.3, 2.5, 3.3, 3.4, 3.6, 6.3 |
| S03 | parallel-compatibility / No financial evaluation during admission | `parallel.compat.numeric-input-not-evaluated`, `parallel.compat.prior-output-not-evaluated`, `parallel.compat.capability-not-evaluated`, `DefiKernel.Parallel.analyzeInvocation` | focused-evidence-verified | 2.2, 2.4, 6.3 |
| S04 | parallel-compatibility / Both conflict directions | `DefiKernel.Parallel.checkCompatibility_ok_iff`, `DefiKernel.Parallel.compatible_symm`, `parallel.compat.forward-read`, `parallel.compat.reverse-read`, `parallel.compat.forward-funded`, `parallel.compat.reverse-funded`, `parallel.compat.write-write-witness`, `parallel.compat.independent` | focused-evidence-verified | 2.3, 2.4, 2.5, 6.3 |
| S05 | parallel-compatibility / Compatible common reads | `parallel.compat.common-read`, `parallel.compat.common-read-no-writes`, `parallel.fixture.routing.shared-qualified-key` | focused-evidence-verified | 2.3, 6.3 |
| S06 | parallel-compatibility / Unreachable conflicting suffix | `DefiKernel.Parallel.analyzeBranchFrom_member`, `parallel.compat.unreachable-suffix`, `parallel.compat.structural-before-conflict`, `parallel.fixture.refusal.suffix-world-preserved` | focused-evidence-verified | 2.3, 6.3 |
| S07 | parallel-compatibility / Branch-local boundaries | `DefiKernel.Parallel.analyzeBranchFrom_member`, `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL`, `parallel.fixture.boundary.local-identity`, `parallel.fixture.boundary.lr.complete`, `parallel.fixture.boundary.rl.complete` | focused-evidence-verified | 2.1, 4.1, 4.6, 5.1, 6.4 |
| S08 | parallel-compatibility / Prior revocation | `DefiKernel.Parallel.runBranch_authority`, `parallel.fixture.capability.revoked`, `parallel.fixture.capability.actual-revoke`, `parallel.fixture.revoked.lr.complete`, `parallel.fixture.revoked.rl.complete`, `parallel.fixture.basic.complete` | focused-evidence-verified | 2.1, 4.3, 5.5, 6.3 |
| S09 | parallel-compatibility / Administrative input excluded | `PositiveBranch.lean`, `IssueRefusal.lean`, `RevokeRefusal.lean` | focused-evidence-verified | 2.1 |
| S10 | parallel-compatibility / Reusable shared grant | `parallel.fixture.capability.reusable-shared-grant` | focused-evidence-verified | 2.1, 5.5, 6.3 |
| S11 | parallel-compatibility / Malformed local reference | `parallel.compat.malformed-reference`, `parallel.compat.local-order`, `parallel.refused.structural-unchanged`, `DefiKernel.Parallel.runParallel_refuses` | focused-evidence-verified | 2.2, 2.4, 6.3 |
| S12 | parallel-compatibility / Multiple admission failures | `parallel.compat.catalog-first`, `parallel.compat.left-before-right`, `parallel.compat.local-order`, `parallel.compat.structural-before-conflict`, `parallel.compat.forward-before-reverse`, `parallel.compat.first-list-witness`, `parallel.refused.catalog-unchanged`, `DefiKernel.Parallel.admit_ok` | focused-evidence-verified | 2.4, 6.3 |
| S13 | parallel-compatibility / Financial refusal kept local | `parallel.fixture.refusal.peer-runs`, `parallel.fixture.refusal.input-unit`, `parallel.fixture.refusal.missing-capability`, `parallel.fixture.routing.peer-only`, `parallel.fixture.capability.revoked` | focused-evidence-verified | 2.4, 4.3, 6.3 |
| S14 | parallel-preservation / Expression failure framing | `DefiKernel.Parallel.expression_congr_of_region`, `DefiKernel.Parallel.evaluate_congr`, `DefiKernel.Parallel.execute_refusal_iff`, `DefiKernel.Parallel.DependencyFixtures.division_evaluation`, `DefiKernel.Parallel.DependencyFixtures.division_execution`, `DefiKernel.Parallel.DependencyFixtures.observation_error`, `DefiKernel.Parallel.DependencyFixtures.inactive_evaluation_congr` | focused-evidence-verified | 3.1, 3.2, 3.5 |
| S15 | parallel-preservation / Implicit balance dependency | `DefiKernel.Parallel.evaluated_targets`, `DefiKernel.Parallel.evaluated_effect_zero_outside`, `DefiKernel.Parallel.funds_iff`, `DefiKernel.Parallel.DependencyFixtures.malformed_evaluates`, `DefiKernel.Parallel.DependencyFixtures.malformed_effect_outside`, `DefiKernel.Parallel.DependencyFixtures.malformed_writes_fail`, `DefiKernel.Parallel.DependencyFixtures.foreign_funds_iff`, `DefiKernel.Parallel.DependencyFixtures.funded_malformed_refusal`, `DefiKernel.Parallel.DependencyFixtures.poor_malformed_refusal`, `DefiKernel.Parallel.DependencyFixtures.target_balance_is_needed` | focused-evidence-verified | 3.3, 3.4, 3.5 |
| S16 | parallel-preservation / Foreign state changes | `DefiKernel.Parallel.execute_congr`, `DefiKernel.Parallel.executeStep_congr`, `DefiKernel.Parallel.executeStep_refusal_iff`, `DefiKernel.Parallel.executeStep_target_frame`, `DefiKernel.Parallel.runBranch_congr`, `DefiKernel.Parallel.runBranch_frame`, `DefiKernel.Parallel.DependencyFixtures.foreign_agrees`, `DefiKernel.Parallel.DependencyFixtures.foreign_differs`, `DefiKernel.Parallel.DependencyFixtures.foreign_malformed_refusal`, `DefiKernel.Parallel.DependencyFixtures.foreign_success` | focused-evidence-verified | 3.1, 3.2, 3.5, 3.6, 5.1, 5.2 |
| S17 | parallel-preservation / State-dependent re-execution | `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL`, `parallel.fixture.stateful.prefix`, `parallel.fixture.stateful.lr.complete`, `parallel.fixture.stateful.rl.complete`, `parallel.fixture.stateful.supply`, `parallel.fixture.stateful-supply.lr.complete`, `parallel.fixture.stateful-supply.rl.complete` | focused-evidence-verified | 3.1, 3.2, 5.1, 5.3, 6.2 |
| S18 | parallel-preservation / Refused first branch | `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL`, `parallel.fixture.refusal.peer-runs`, `parallel.fixture.prefix.lr.complete`, `parallel.fixture.prefix.rl.complete`, `parallel.fixture.dual.lr.complete`, `parallel.fixture.dual.rl.complete`, `parallel.fixture.peer-runs.lr.complete`, `parallel.fixture.peer-runs.rl.complete` | focused-evidence-verified | 4.3, 4.6, 5.1, 5.3, 6.4 |
| S19 | parallel-preservation / Independent single steps commute | `DefiKernel.Parallel.singleton_commutation`, `DefiKernel.Parallel.serial_orders_equivalent`, `parallel.fixture.basic.complete`, `parallel.fixture.basic.lr.complete`, `parallel.fixture.basic.rl.complete`, `parallel.fixture.same-asset.complete`, `parallel.fixture.same-asset.lr.complete`, `parallel.fixture.same-asset.rl.complete` | focused-evidence-verified | 5.3, 5.4, 6.1 |
| S20 | parallel-preservation / Supply-changing peers | `DefiKernel.Parallel.runParallel_executed_accounting`, `DefiKernel.Parallel.runParallel_executed_authority`, `DefiKernel.Parallel.runParallel_executed_nonnegative`, `DefiKernel.Parallel.PreservationFixtures.supply_receipts`, `DefiKernel.Parallel.PreservationFixtures.supply_totals`, `parallel.fixture.supply.complete`, `parallel.fixture.supply.both-receipts`, `parallel.fixture.supply.lr.complete`, `parallel.fixture.supply.rl.complete` | focused-evidence-verified | 5.5, 6.2 |
| S21 | parallel-preservation / Successful use with refused suffix | `DefiKernel.Parallel.runBranch_authority`, `DefiKernel.Parallel.runBranch_prefix_nonnegative`, `DefiKernel.Parallel.runParallel_executed_accounting`, `DefiKernel.Parallel.PreservationFixtures.prefix_refusal_receipts`, `DefiKernel.Parallel.PreservationFixtures.prefix_authority`, `DefiKernel.Parallel.PreservationFixtures.prefix_accounting`, `parallel.fixture.supply.prefix-refusal`, `parallel.fixture.supply-prefix.lr.complete`, `parallel.fixture.supply-prefix.rl.complete` | focused-evidence-verified | 4.3, 5.5, 6.2 |
| S22 | parallel-preservation / Protected collateral predicate | `DefiKernel.Parallel.runParallel_executed_supported_frame`, `DefiKernel.Parallel.PreservationFixtures.protected_collateral`, `parallel.fixture.basic.complete` | focused-evidence-verified | 5.6 |
| S23 | parallel-preservation / Necessary frame premises | `DefiKernel.Parallel.runParallel_executed_supported_frame`, `DefiKernel.Parallel.PreservationFixtures.unsupported_counterexample`, `DefiKernel.Parallel.PreservationFixtures.unsupported_is_not_supported`, `DefiKernel.Parallel.PreservationFixtures.written_support_counterexample` | focused-evidence-verified | 5.6 |
| S24 | parallel-preservation / Two local invariants | `DefiKernel.Parallel.runParallel_executed_two_invariants`, `DefiKernel.Parallel.local_total_preservation`, `DefiKernel.Parallel.supports_total`, `DefiKernel.Parallel.PreservationFixtures.initialized_two_invariants` | focused-evidence-verified | 5.7 |
| S25 | parallel-regression-evidence / Planning candidate passes | `planning.gate`, `planning.ADJUDICATION` | planning-gate-passed | 1.1, 1.2, 1.3 |
| S26 | parallel-regression-evidence / Reviewer unavailable or candidate revised | `planning.ADJUDICATION`, `planning.r1-fable`, `planning.r1-gpt6`, `planning.gate` | planning-history-verified | 1.2, 1.3 |
| S27 | parallel-regression-evidence / Negative targets interference | `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-inactive-guard-funded`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-delta-funded`, `parallel.compat.hidden-supply`, `parallel.compat.hidden-supply-funded`, `parallel.compat.output-dependency`, `parallel.compat.output-funded`, `parallel.compat.reverse-read`, `parallel.compat.reverse-funded`, `parallel.compat.forward-read`, `parallel.compat.forward-funded`, `parallel.compat.zero-target`, `parallel.compat.zero-target-funded`, `parallel.compat.funded-left-complete`, `parallel.compat.independent`, `parallel.fixture.cancelling.admission`, `parallel.fixture.cancelling.funded` | focused-evidence-verified | 2.3, 6.1, 6.3 |
| S28 | parallel-regression-evidence / Branch behavior inventory | `parallel.fixture.basic.complete`, `parallel.fixture.refusal.dual`, `parallel.fixture.routing.peer-only`, `parallel.fixture.routing.both-own-history`, `parallel.fixture.boundary.local-identity`, `parallel.fixture.supply.complete`, `parallel.fixture.capability.revoked`, `parallel.observe.output-value`, `parallel.observe.receipt.supplies`, `parallel.observe.refusal-index`, `DefiKernel.Parallel.runtimeChecks`, `integrated.Lean10` | integrated-runtime-verified | 6.1, 6.2, 6.3, 6.4, 6.5, 6.6 |
| S29 | parallel-regression-evidence / Semantic detection | `bypass-write-write-composite`, `omit-expression-reads-composite`, `omit-output-dependency`, `omit-zero-delta-target`, `omit-reverse-conflict`, `cancel-peer-after-refusal`, `rollback-refused-prefix-at-join`, `replace-merge-with-left-world`, `double-initial-balances`, `leak-peer-output-history`, `reuse-left-trusted-boundary`, `drop-peer-supply-receipts`, `reuse-live-capability-store`, `stale-intra-branch-evaluation` | pending-production-mutation-evidence | 7.1, 7.2, 7.3, 7.4, 7.6 |
| S30 | parallel-regression-evidence / Invalid or vacuous run | `unused-variable-warning`, `live-discriminating-mutant`, `all-true-mutant`, `required-observation-stays-true`, `positive-control-flipped`, `compilation-only-failure`, `compiler-error-with-runtime-failure`, `empty-observations`, `duplicate-observations`, `partial-mutant-observations`, `unknown-mutant-observation`, `no-op-mutation`, `missing-mutation-needle`, `nonunique-mutation-needle`, `malformed-json`, `output-inside-repository`, `output-symlink`, `empty-module-inventory`, `empty-mutation-inventory`, `unchanged-control-failed`, `fresh-dependency-source-failure` | runner-controls-verified | 7.1, 7.5 |
| S31 | parallel-regression-evidence / Redundant conflict guards | `bypass-write-write-composite`, `omit-expression-reads-composite`, `omit-zero-delta-target`, `mutations.mutation-design`, `parallel.compat.zero-target-funded`, `parallel.compat.zero-target-exact`, `parallel.compat.hidden-inactive-guard-funded` | pending-production-mutation-evidence | 7.2, 7.6 |
| S32 | parallel-regression-evidence / New proof enters import closure | `DefiKernel.Parallel.Verify`, `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_executed_two_invariants`, `integrated.Lean10`, `integrated.proof-inventory` | integrated-lean-verified | 6.5, 6.6, 8.1, 8.2 |
| S33 | parallel-regression-evidence / Historical regression or drift | `baseline`, `integrated.Lean10` | pending-integrated-acceptance | 1.4, 8.1, 8.2 |
| S34 | parallel-regression-evidence / Reviewed source changes | `financial.source-inputs` | pending-native-implementation-review | 8.2, 8.3, 8.4 |
| S35 | parallel-regression-evidence / Verified branch and archive | `disjoint-parallel-composition.delivery-obligation` | pending-delivery | 9.1, 9.2, 9.3, 9.4 |
| S36 | parallel-workflow-execution / One branch refuses immediately | `parallel.fixture.refusal.peer-runs`, `parallel.fixture.peer-runs.lr.complete`, `parallel.fixture.peer-runs.rl.complete`, `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL` | focused-evidence-verified | 4.1, 4.3, 6.4 |
| S37 | parallel-workflow-execution / Middle and dual refusal | `parallel.fixture.refusal.prefix-kept`, `parallel.fixture.refusal.dual`, `parallel.fixture.dual.lr.complete`, `parallel.fixture.dual.rl.complete`, `DefiKernel.Parallel.continueRun_congr`, `DefiKernel.Parallel.continueRun_frame` | focused-evidence-verified | 4.3, 5.1, 6.4 |
| S38 | parallel-workflow-execution / Empty branch identity | `DefiKernel.Parallel.runParallel_empty_left`, `DefiKernel.Parallel.runParallel_empty_right`, `DefiKernel.Parallel.runBranch_empty`, `parallel.fixture.empty.left`, `parallel.fixture.empty.right`, `parallel.fixture.empty.both`, `parallel.empty.lr`, `parallel.empty.rl` | focused-evidence-verified | 4.1, 5.4 |
| S39 | parallel-workflow-execution / Two funded disjoint branches | `parallel.fixture.basic.complete`, `parallel.fixture.basic.lr.complete`, `parallel.fixture.basic.rl.complete`, `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL` | focused-evidence-verified | 4.1, 4.2, 6.1 |
| S40 | parallel-workflow-execution / Common initial balance | `DefiKernel.Parallel.mergeWorld_outside`, `DefiKernel.Parallel.runParallel_executed_frame`, `parallel.fixture.basic.complete`, `parallel.fixture.same-asset.complete` | focused-evidence-verified | 4.2, 5.6, 6.1 |
| S41 | parallel-workflow-execution / Refused branch prefix | `parallel.fixture.refusal.prefix-kept`, `parallel.fixture.prefix.lr.complete`, `parallel.fixture.prefix.rl.complete`, `DefiKernel.Parallel.runBranch_frame` | focused-evidence-verified | 4.2, 4.3, 5.1, 6.4 |
| S42 | parallel-workflow-execution / Qualified output identities | `parallel.fixture.same-asset.complete`, `parallel.fixture.routing.shared-qualified-key`, `parallel.fixture.shared-qualified-key.lr.complete`, `parallel.fixture.shared-qualified-key.rl.complete` | focused-evidence-verified | 4.4, 6.4 |
| S43 | parallel-workflow-execution / Snapshot after later writes | `parallel.fixture.routing.both-own-history`, `parallel.fixture.both-own-history.lr.complete`, `parallel.fixture.both-own-history.rl.complete` | focused-evidence-verified | 4.4, 6.2, 6.4 |
| S44 | parallel-workflow-execution / Unavailable or foreign output | `parallel.fixture.routing.peer-only`, `parallel.fixture.routing.funded-literal`, `parallel.fixture.routing.own-history`, `parallel.fixture.routing.lr.complete`, `parallel.fixture.routing.rl.complete` | focused-evidence-verified | 4.4, 6.4 |
| S45 | parallel-workflow-execution / Swapped completion order | `DefiKernel.Parallel.serial_orders_equivalent`, `DefiKernel.Parallel.runParallel_serialLR`, `DefiKernel.Parallel.runParallel_serialRL`, `parallel.fixture.basic.lr.complete`, `parallel.fixture.basic.rl.complete`, `parallel.fixture.boundary.lr.complete`, `parallel.fixture.boundary.rl.complete` | focused-evidence-verified | 4.5, 4.6, 5.3 |
| S46 | parallel-workflow-execution / Distinct refusal evidence | `parallel.observe.refusal-reason`, `parallel.observe.refusal-index`, `parallel.observe.refusal-step`, `parallel.observe.local-index`, `parallel.observe.output-unit`, `parallel.observe.output-value`, `parallel.observe.receipt.supplies`, `parallel.observe.receipt.deltas`, `parallel.observe.receipt.request`, `parallel.observe.final-ledger`, `parallel.observe.final-store`, `DefiKernel.Parallel.observationsEqual_iff` | focused-evidence-verified | 4.5 |
| S47 | parallel-workflow-execution / Raw trace context | `parallel.fixture.raw-context-differs`, `parallel.observe.raw-world-context`, `DefiKernel.Parallel.runParallel_serialLR` | focused-evidence-verified | 4.5, 5.3 |

## Evidence locations

- [Compatibility commands and compiler controls](compatibility-evidence/runs.json), [runtime](compatibility-evidence/Runtime.log), [axioms](compatibility-evidence/Axioms.log).
- [Dependency statements](dependency-proof-inventory.json), [checks](dependency-verification.json).
- [Root execution/commutation checks](execution/root-core/verification.json), [runtime](execution/root-core/audit.log), [axioms](execution/root-core/axioms.log).
- [Integrated 10 Lean runs](integration/lean-runs.json), [full imported proof inventory](proof-inventory.json), [imported axiom audit](integration/parallel-verify.log).
- [Preservation statements](preservation-proof-inventory.json), [checks](preservation-verification.json).
- [Financial commands](financial-evidence/runs.json), [complete runtime](financial-evidence/runtime.log), [fixture explanation](financial-report.md).
- [Current 45 runner controls](runner-controls/revised-45/summary.json), [production mutation definitions](mutation-spec.json), [composite mutation design](mutations/mutation-design.md).
- [Planning gate](planning/gate.json), [ordered adjudication history](planning/ADJUDICATION.md), [preimplementation baseline](baseline.json).

## Task criterion coverage

Each criterion below is the approved task text. Status denotes available evidence scope and does
not change the OpenSpec task checkboxes. Final acceptance steps are deliberately left pending.

| Task | Approved criterion | Scenarios | Evidence status |
| --- | --- | --- | --- |
| 1.1 | Freeze proposal, design, four specs and this checklist in a concrete commit; record source-context hashes and a scenario/task map in `review/semantic-kernel/sprint6/`; verify strict OpenSpec validation and every local link before review. | S25 | planning-gate-passed |
| 1.2 | Obtain independent Fable and GPT-6 planning audits of that same candidate; save prompts, raw results, requested/reported identities and verdicts; verify neither required review is unavailable or unresolved before any implementation. | S25, S26 | planning-gate-passed |
| 1.3 | Resolve blocking planning findings in a revised candidate and refresh affected audits; save `planning/ADJUDICATION.md` and verify both passing verdicts cover final planning bytes without waiving a requirement. | S25, S26 | planning-gate-passed |
| 1.4 | Capture the clean implementation starting revision, tools and baseline hashes; run the existing full Lean build and composition/typed/legacy runtime and axiom drivers below; verify all pass and preserved original proof/corpus manifests resolve to actual files before new modules are added. | S33 | baseline-passed |
| 2.1 | Create `lean/DefiKernel/Parallel/Compatibility.lean` with closed left/right identities, invocation-only `Branch`, fixed branch/local-index boundaries and a finite `Footprint`; compile a positive invocation branch and a separate expected type-error control showing issue/revoke cannot inhabit the public branch input. | S07, S08, S09, S10 | focused-evidence-verified |
| 2.2 | Implement per-invocation footprint resolution from actual registered templates/operation interfaces, fixed parties and trusted caller; verify concrete expected lists contain declared writes, delta targets, both-arm guard/delta/supply reads, declared reads, output cells and balance dependencies, without evaluating numeric expressions. | S01, S02, S03, S11 | focused-evidence-verified |
| 2.3 | Aggregate the whole branch and implement symmetric write/write and write/read disjointness; verify funded same-domain independent pairs and common-read siblings pass while both conflict directions, zero-effect targets and unreachable conflicting suffixes reject. | S01, S02, S04, S05, S06, S27 | focused-evidence-verified |
| 2.4 | Implement catalog-first, left-before-right, local-order admission errors and deterministic first conflict witnesses; verify multiple simultaneous errors choose the documented reason and every refusal leaves initial world/output/receipt inventories unchanged. | S03, S04, S11, S12, S13 | focused-evidence-verified |
| 2.5 | Prove accepted-analysis membership facts for all required reads, output cells and delta targets, and compatibility disjointness lemmas in the new module; verify the proof statements are generic over the existing finite identity types and do not assume invocation success. | S01, S02, S04 | focused-evidence-verified |
| 3.1 | Create `Dependency.lean`; derive analyzed-region expression congruence using existing `Expr.eval_congr_of_resolved` and discharge its agreement premises for identical non-state inputs; verify both conditional arms, balance reads, rational arithmetic, observation errors and zero division are covered for complete Except results. | S01, S14, S16, S17 | focused-evidence-verified |
| 3.2 | Lift dependency congruence to actual `Template.evaluate`, including target/reference resolution, guards, effects, supplies and all evaluation errors; verify equal evaluated receipt data follows from analyzed-region agreement rather than an unchecked evaluator-framing premise. | S14, S16, S17 | focused-evidence-verified |
| 3.3 | Prove actual evaluated effects vanish outside resolved delta targets; verify the lemma does not assume declared writes or `writesOK`, and instantiate a malformed undeclared-target fixture to demonstrate why the distinction matters. | S02, S15 | focused-evidence-verified |
| 3.4 | Prove equivalence of the global sufficient-funds checks from target-region balance agreement and proof-carrying nonnegativity elsewhere; verify an insufficient-balance sibling and a nonzero untouched-cell sibling establish the implicit dependency scope. | S02, S15 | focused-evidence-verified |
| 3.5 | Prove registered execution congruence for exact refusal and, on success, identical receipt effects plus agreement on the dependency region and framing outside writes; verify the proof follows real check precedence and includes failed accounting/write-footprint and evaluation paths. | S14, S15, S16 | focused-evidence-verified |
| 3.6 | Lift the dependency result through `Composition.executeStep` for invocations and selected snapshots with fixed local history; verify snapshot equality uses analyzed output reads and neither proof assumes whole-world equality or already-proved commutation. | S02, S16 | focused-evidence-verified |
| 4.1 | Create `Execution.lean` with admission refusal versus executed-pair result types; call existing `Composition.run` separately from the common initial world using stable local boundaries; verify empty/empty, one-empty, and funded two-branch results. | S07, S36, S38, S39 | focused-evidence-verified |
| 4.2 | Implement region-selective merge and construct nonnegativity by cases, retaining initial capabilities; verify the USD/share fixture has Alice USD7/Bob USD3/vault shares16/Alice shares4 with every other cell and complete store unchanged. | S39, S40, S41 | focused-evidence-verified |
| 4.3 | Preserve each branch's own first refusal and successful prefix while always executing its peer; verify immediate, middle and dual refusals, with an independently funded peer and exact reasons/indices. | S08, S13, S18, S21, S36, S37, S41 | focused-evidence-verified |
| 4.4 | Expose branch-qualified output snapshots and keep local histories isolated; verify equal numeric port IDs from distinct components retain distinct values, a shared fully qualified read-only key retains both branch labels, peer-only step-0 output lookup at local index 1 refuses despite a correct-unit funded peer value (with an equivalent-literal or own-history successful sibling), and own snapshots remain stable after later writes. | S42, S43, S44 | focused-evidence-verified |
| 4.5 | Define canonical branch and parallel observations with complete financial fields from design section 4 and an extensional equivalence relation; verify controls distinguish changes to each refusal/index/output/receipt/final-ledger field while tolerating only completion order and raw foreign-world event context. | S45, S46, S47 | focused-evidence-verified |
| 4.6 | Implement LR and RL reference evaluators using fresh real sequential runs of the second branch on the first final world, with original local boundaries and no cross-branch history; verify neither reference caches receipts or globally cancels on first-branch refusal. | S07, S18, S45 | focused-evidence-verified |
| 5.1 | Create `Commutation.lean`; prove branch observation congruence and final-region agreement by induction over the existing runner with stable local histories/boundaries; verify the statement covers first/middle refusal and state-dependent prefix effects. | S07, S16, S17, S18, S37, S41 | focused-evidence-verified |
| 5.2 | Prove every successful branch effect is confined to its analyzed writes and the entire branch frames its starting ledger elsewhere, with fixed capability store; verify this establishes the premise required for sound region merge. | S16 | focused-evidence-verified |
| 5.3 | Prove admitted parallel observation equals actual LR and RL observations for all well-typed initial worlds, discharging cross-branch dependency premises with compatibility; verify no supplied equality/commutation oracle or success-only premise replaces the required refused behavior. | S17, S18, S19, S45, S47 | focused-evidence-verified |
| 5.4 | Derive singleton invocation commutation and empty-branch laws with exact branch-qualified observations; verify raw full event worlds are not equated and no arbitrary nested associativity claim is added. | S19, S38 | focused-evidence-verified |
| 5.5 | Create `Preservation.lean`; lift exact per-domain/asset accounting using both real receipt supply sums and prove invocation/debit/supply authority under the fixed store; verify independent mint/burn fixtures and successful prefixes ending in refusal instantiate the results. | S08, S10, S20, S21 | focused-evidence-verified |
| 5.6 | Prove every branch prefix and joined ledger is nonnegative and establish union-write locality and supported-predicate framing; verify concrete protected collateral and counterexamples to omitting support/disjointness. | S22, S23, S40 | focused-evidence-verified |
| 5.7 | Prove composition of two initialized supported ledger invariants from explicit individual preservation and peer-disjoint support; verify an instantiated pair and record every remaining contract/environment premise without circular assumptions. | S24 | focused-evidence-verified |
| 6.1 | Create `Examples.lean` and `Tests.lean` with independently specified complete worlds/stores/receipts for the USD/share fixture and same-asset disjoint-party pairs; verify both serial references and parallel observations against those independent expected values. | S19, S27, S28, S39, S40 | focused-evidence-verified |
| 6.2 | Add nontrivial multi-invocation branches, state-dependent guard/effect/supply examples, independent supply changes and both local output consumers; verify exact amounts, receipt order, output units and complete branch observations, not merely equality among three implementations. | S17, S20, S21, S28, S43 | focused-evidence-verified |
| 6.3 | Add funded/authorized conflict negatives for both directions, hidden/inactive-arm reads, target balances, shared outputs, malformed suffixes, and live/revoked capability siblings; verify each intended failure is discriminated from missing funds or unrelated authority. | S01, S02, S03, S04, S05, S06, S08, S10, S11, S12, S13, S27, S28 | focused-evidence-verified |
| 6.4 | Add boundary-sensitive local-index, qualified-port and peer-only-history fixtures, immediate/middle/dual refusal fixtures, and identity/frame controls; verify changing branch order preserves local principal/time binding without treating time as a price. | S07, S18, S28, S36, S37, S41, S42, S43, S44 | focused-evidence-verified |
| 6.5 | Add `Audit.lean` with a nonempty unique named runtime inventory and `Verify.lean` with imported theorem/supplemental axiom coverage; import the new verification root from `lean/DefiKernel.lean` and verify full compilation, runtime pass and zero forbidden dependencies. | S28, S32 | integrated-lean-and-inventory-verified |
| 6.6 | Save named proof statements, quantification, premises and limits in `proof-inventory.json` and map all 47 planned scenarios to actual proof/check IDs; verify the inventory distinguishes generic results, reference instances, counterexamples, bounded comparisons and imported generated declarations. | S28, S32 | integrated-lean-and-inventory-verified |
| 7.1 | Add `scripts/check_parallel_mutations.py` with explicit repo/spec/out inputs, fresh local source projection, exact manifests and nonempty complete inventory checks, reusing established machinery only with explicit Parallel scope; verify an unchanged execution control compiles and all comparisons pass in a new external scratch directory. | S29, S30 | pending-production-mutations |
| 7.2 | Add actual source mutants for write/write bypass, hidden-expression/output/target dependency omission, and reverse conflict direction in `review/semantic-kernel/sprint6/mutation-spec.json`; verify each compiles and triggers its designated independent oracle, documenting composite collector omissions for redundant declared reads/writes and using a zero/cancelling undeclared target for its successful underlying-kernel control. | S29, S31 | pending-production-mutations |
| 7.3 | Add peer cancellation, prefix rollback, whole-world replacement and doubled-initial-balance mutants; verify exact branch outcomes and complete-world expected fixtures detect each while unrelated positives remain true. | S29 | pending-production-mutations |
| 7.4 | Add local-history leakage/port misqualification, boundary-position misuse, dropped-peer-supply, stale capability store and incorrect state-dependent evaluation mutants; verify every required mutant changes actual implementation source and fails its designated runtime comparison. | S29 | pending-production-mutations |
| 7.5 | Add `scripts/test_parallel_mutation_runner.py` actual CLI controls for empty/duplicate/unknown/partial inventories, malformed evidence, absent/nonunique/no-op edits, compile-only failure, surviving mutants, failed positives and invalid output locations; verify each fails or blocks for its intended cause beside a valid accepted sibling. | S30 | current-runner-controls-verified |
| 7.6 | Freeze mutation inputs and run all 14 required semantic mutants and runner controls; save full logs, generated sources, expected false labels, protected positives, tool versions and hashes; verify no source drift, masked survivor or noncompiled case is counted as a detection. | S29, S31 | pending-production-mutations |
| 8.1 | Commit frozen source and run the full new and existing Lean/runtime/axiom commands below plus existing typed/composition mutations, compiler controls, runner controls, axiom controls and corpus tests; save actual commands, exits and full logs and verify required checks pass without changing preserved files. | S32, S33 | pending-integrated-acceptance-and-native-review |
| 8.2 | Finish the scenario map and proof/source/tool manifests with actual outcomes; verify every scenario has nonvacuous evidence, each counted proof belongs to the fresh import closure, and executed bytes match Git objects of the reviewed source candidate. | S32, S33, S34 | pending-integrated-acceptance-and-native-review |
| 8.3 | Obtain independent native Grok/Fable review of substantive compatibility/dependency proofs, execution/commutation and regression/evidence scopes; retain raw requests/responses and verify exact requested/reported identities and candidate hashes. | S34 | pending-integrated-acceptance-and-native-review |
| 8.4 | Resolve blocking findings and refresh affected validation/review on the revised candidate; save implementation `ADJUDICATION.md`, preserved dissent and scope limits; verify no required review or normative obligation remains open. | S34 | pending-integrated-acceptance-and-native-review |
| 9.1 | Update roadmap/progress/tasks from accepted evidence; verify shared-state interleaving, atomic synchronization, broader associativity, claims/provenance and deployed fidelity remain open. | S35 | pending-delivery |
| 9.2 | Run strict OpenSpec validation and editorial whitespace/local-link checks; verify all current referenced evidence exists without rewriting hash-bound raw bundles/logs. | S35 | pending-delivery |
| 9.3 | Commit/push source and evidence to `semantic-kernel-pivot`; verify remote head equals intended local head and save delivery metadata with actual commit/source identities and explained worktree state. | S35 | pending-delivery |
| 9.4 | Archive only `disjoint-parallel-composition` through OpenSpec, validate all four synchronized main specs, update archive links and deliver metadata; verify final remote head, all task states and a clean worktree. | S35 | pending-delivery |

## Scope limits

The generic executor and serial laws retain fixed config, trusted boundaries, local histories,
capability store authenticity and syntactic dependency premises that admission discharges.
Initialization/contract composition retains explicit supported predicates, individual preservation,
and peer-disjoint supports. Environmental truth and deployed fidelity are not proved. Raw full
worlds attached to events are evidence with foreign context, not one shared interleaved trace.
Nonnegativity is a checked state-construction invariant, not discovered solvency.

Do not mark pending entries accepted until the exact final logs, source and reviewed revision
are available and bound. Update this map from those artifacts without rewriting prior raw logs.

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/PositiveBranch.lean
SHA256 d47eb715fd03e2abf5ebdd41b8003c1d750e0a5c0914eff3fa79e80b59438d33
```
import DefiKernel.Parallel.CompatibilityTests
open DefiKernel DefiKernel.Typed.Examples DefiKernel.Parallel
example : Branch Party Asset Domain := [CompatibilityTests.left, CompatibilityTests.right]

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/PositiveBranch.log
SHA256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/IssueRefusal.lean
SHA256 b1c41440ce4d6f70052b030c368d903c1218e25a0abc48995c88a6b288b08430
```
import DefiKernel.Parallel.CompatibilityTests
open DefiKernel DefiKernel.Typed.Examples DefiKernel.Parallel
example (grant : Typed.Grant Party Asset Domain) : Branch Party Asset Domain :=
  [Composition.Step.issue grant]

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/IssueRefusal.log
SHA256 17c42092fb514952dc35978a2f32532b95b41353fd29f5f3b02994800178bc4d
```
/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/IssueRefusal.lean:4:3: error: Application type mismatch: The argument
  Composition.Step.issue grant
has type
  Composition.Step Party Asset Domain
but is expected to have type
  Composition.Invocation Party Asset Domain
in the application
  List.cons (Composition.Step.issue grant)

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/RevokeRefusal.lean
SHA256 bcd433b4f8f15f95471fba3b386b5e2c8a54983bca2b08cd781d3af48d720072
```
import DefiKernel.Parallel.CompatibilityTests
open DefiKernel DefiKernel.Typed.Examples DefiKernel.Parallel
example : Branch Party Asset Domain := [Composition.Step.revoke ⟨0⟩]

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/RevokeRefusal.log
SHA256 f5318949ebf6e69596dc4780455ee82266526cc2c5abf2571918a7e9afea0987
```
/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/RevokeRefusal.lean:3:40: error: Application type mismatch: The argument
  Composition.Step.revoke { value := 0 }
has type
  Composition.Step ?m.2 ?m.3 ?m.4
but is expected to have type
  Composition.Invocation Party Asset Domain
in the application
  List.cons (Composition.Step.revoke { value := 0 })

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/runs.json
SHA256 0503949c4be38b24dcedc1ef22319ce2d12000bb87c7cf85d8c417874aa725ff
```
[
  {
    "command": [
      "lake",
      "build",
      "DefiKernel.Parallel.Compatibility",
      "DefiKernel.Parallel.CompatibilityTests"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 0,
    "log": "Build.log"
  },
  {
    "command": [
      "lake",
      "env",
      "lean",
      "/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/Runtime.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 0,
    "log": "Runtime.log"
  },
  {
    "command": [
      "lake",
      "env",
      "lean",
      "/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/PositiveBranch.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 0,
    "log": "PositiveBranch.log"
  },
  {
    "command": [
      "lake",
      "env",
      "lean",
      "/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/RevokeRefusal.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 1,
    "log": "RevokeRefusal.log"
  },
  {
    "command": [
      "lake",
      "env",
      "lean",
      "/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/IssueRefusal.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 1,
    "log": "IssueRefusal.log"
  },
  {
    "command": [
      "lake",
      "env",
      "lean",
      "/home/charl/defiformal/review/semantic-kernel/sprint6/compatibility-evidence/Axioms.lean"
    ],
    "cwd": "/home/charl/defiformal/lean",
    "exit": 0,
    "log": "Axioms.log"
  }
]

```

### EVIDENCE review/semantic-kernel/sprint6/compatibility-evidence/sources.json
SHA256 bffe90bb7ab7d9ea8971dbcca83010f09516a8db1a78ee52b9e0c87c8ecc6d29
```
{
  "head": "2267e005d988f0e32d014f2d76d98a9410360187",
  "scope": "uncommitted new sources; head is baseline, not source identity",
  "sha256": {
    "lean/DefiKernel/Parallel/Compatibility.lean": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "review/semantic-kernel/sprint6/compatibility-evidence/Axioms.lean": "693c9a114a0e78566fb5f68371792dd201da2ce510d192d5fc1639d27c20ff32",
    "review/semantic-kernel/sprint6/compatibility-evidence/IssueRefusal.lean": "b1c41440ce4d6f70052b030c368d903c1218e25a0abc48995c88a6b288b08430",
    "review/semantic-kernel/sprint6/compatibility-evidence/PositiveBranch.lean": "d47eb715fd03e2abf5ebdd41b8003c1d750e0a5c0914eff3fa79e80b59438d33",
    "review/semantic-kernel/sprint6/compatibility-evidence/RevokeRefusal.lean": "bcd433b4f8f15f95471fba3b386b5e2c8a54983bca2b08cd781d3af48d720072",
    "review/semantic-kernel/sprint6/compatibility-evidence/Runtime.lean": "2c066f38c85f4578aa9230acab322f710cbad750c1563300be0672e839cb320e"
  },
  "proofs": [
    "DefiKernel.Parallel.firstOverlap_none_iff",
    "DefiKernel.Parallel.checkCompatibility_ok_iff",
    "DefiKernel.Parallel.compatible_symm",
    "DefiKernel.Parallel.analyzeInvocation_ok",
    "DefiKernel.Parallel.resolveRefs_member",
    "DefiKernel.Parallel.analyzeBranchFrom_cons",
    "DefiKernel.Parallel.admit_ok",
    "DefiKernel.Parallel.admit_compatible",
    "DefiKernel.Parallel.resolveRefs_mem_of_resolve",
    "DefiKernel.Parallel.resolveRefs_append_ok",
    "DefiKernel.Parallel.analyzeInvocation_coverage",
    "DefiKernel.Parallel.analyzeInvocation_writes_read",
    "DefiKernel.Parallel.analyzeBranchFrom_member"
  ]
}

```
