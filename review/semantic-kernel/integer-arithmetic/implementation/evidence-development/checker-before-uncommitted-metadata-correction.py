#!/usr/bin/env python3
"""Reconcile saved arithmetic source, observations and CLI artifacts without executing Lean."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


class Blocked(Exception):
    pass


class SemanticFailure(Exception):
    pass


class Audit:
    def __init__(self, repo):
        self.repo = repo
        self.assertions = 0

    def require(self, condition, reason):
        self.assertions += 1
        if not condition:
            raise Blocked(reason)

    def raw(self, root, relative):
        path = root / relative
        self.require(not path.is_symlink() and path.resolve().is_relative_to(root.resolve()),
                     f'unsafe artifact path: {relative}')
        self.require(path.is_file(), f'missing artifact: {relative}')
        return path.read_bytes()

    def json(self, root, relative):
        return json.loads(self.raw(root, relative))

    def git(self, *args):
        return subprocess.check_output(['git', *args], cwd=self.repo, stderr=subprocess.PIPE)

    def invocation(self, root, kind):
        inv = self.json(root, 'invocation.json')
        self.require(inv['kind'] == kind and inv['status'] == 'FINISHED', 'unfinished invocation')
        self.require(inv['actual_exit'] == 0, 'saved suite did not qualify')
        candidate = inv['frozen_source']
        self.require(re.fullmatch('[0-9a-f]{40}', candidate), 'invalid execution revision')
        self.require(inv['git_head_after'] == candidate and inv['git_head_unchanged'] and
                     all(inv['inputs_unchanged'].values()), 'invocation source drift')
        names = {'scripts/check_integer_arithmetic_mutations.py',
                 'scripts/test_integer_arithmetic_runner.py', 'lean/lean-toolchain',
                 'lean/lakefile.toml', 'lean/lake-manifest.json'}
        if kind == 'production':
            names.add('mutations/integer-arithmetic.json')
        self.require(set(inv['input_bindings']) == names, 'incomplete invocation bindings')
        for path, binding in inv['input_bindings'].items():
            raw = self.git('show', f'{candidate}:{path}')
            self.require(sha(raw) == binding['sha256'] and len(raw) == binding['bytes'],
                         f'invocation Git bytes mismatch: {path}')
            self.require(self.git('rev-parse', f'{candidate}:{path}').decode().strip() ==
                         binding['git_blob'], f'invocation Git object mismatch: {path}')
        for label in ['stdout', 'stderr']:
            self.require(sha(self.raw(root, 'suite.' + label + '.log')) == inv[label + '_sha256'],
                         f'suite {label} hash mismatch')
        return inv

    def tool(self, root, records, version, executable_sha):
        by_name = {row['label']: row for row in records}
        for name in ['lean-version', 'lean-path', 'git-head']:
            row = by_name[name]
            self.require(row['exit'] == 0 and sha(self.raw(root, name + '.log')) ==
                         row['log_sha256'], f'tool log mismatch: {name}')
        self.require(self.raw(root, 'lean-version.log').decode().strip() == version,
                     'Lean version mismatch')
        executable = Path(self.raw(root, 'lean-path.log').decode().strip())
        self.require(executable.is_absolute() and executable.is_file(), 'Lean bytes unavailable')
        self.require(sha(executable.read_bytes()) == executable_sha, 'Lean executable hash mismatch')

    def production(self, root, fixture_names):
        inv = self.invocation(root, 'production')
        candidate = inv['frozen_source']
        source = self.json(root, 'source-manifest.json')
        spec_raw = self.raw(root, 'mutation-spec.json')
        spec = json.loads(spec_raw)
        self.require(spec_raw == self.git('show', f'{candidate}:mutations/integer-arithmetic.json'),
                     'mutation specification Git mismatch')
        self.require(sha(spec_raw) == source['spec_sha256'], 'mutation specification hash mismatch')
        self.require(source['git_head'] == source['git_head_after'] == candidate,
                     'production revision mismatch')
        for key in ['input_sources_unchanged', 'specification_unchanged', 'runner_unchanged',
                    'git_head_unchanged']:
            self.require(source[key] is True, 'production drift flag: ' + key)
        self.require(source['script_sha256'] ==
                     inv['input_bindings']['scripts/check_integer_arithmetic_mutations.py']['sha256'],
                     'production driver mismatch')
        self.require(source['timeout_seconds_per_command'] == 600, 'production timeout mismatch')
        self.require(source['audit_root'] == 'DefiKernel.Arithmetic.RuntimeAudit', 'wrong audit root')
        self.require(len(spec['modules']) == len(set(spec['modules'])) == 9, 'runtime root count')
        self.require(source['module_roots'] == spec['modules'], 'runtime roots mismatch')
        self.require(len(spec['mutations']) == 12, 'mutation count')
        self.require(spec['positive_checks'] == ['arithmetic.fixture.f01', 'arithmetic.fixture.f03'],
                     'protected positive inventory mismatch')
        ordered, visiting = [], set()
        def capture(module):
            if module in ordered:
                return
            self.require(module not in visiting, 'cyclic source closure')
            visiting.add(module)
            relative = 'lean/' + module.replace('.', '/') + '.lean'
            text = self.raw(root, 'inputs/' + relative).decode()
            for imported in re.findall(r'^import (\S+)$', text, re.M):
                if imported.startswith('DefiKernel.'):
                    capture(imported)
            visiting.remove(module)
            ordered.append(module)
        for module in spec['modules']:
            capture(module)
        self.require(ordered == source['projection_order'] and len(ordered) == 13,
                     'actual local import closure mismatch')
        self.require(set(ordered) - set(spec['modules']) ==
                     {f'DefiKernel.Typed.{n}' for n in ['Types', 'Expr', 'Authority', 'Transition']},
                     'unexpected retained local dependency')
        relative_sources = {'lean/' + m.replace('.', '/') + '.lean' for m in ordered}
        relative_sources |= {'lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'}
        self.require(set(source['sources']) == set(source['sources_after']) ==
                     set(source['git_input_bindings']) == relative_sources, 'source inventory mismatch')
        imports, parts = [], []
        for path in sorted(relative_sources):
            raw = self.raw(root, 'inputs/' + path)
            digest = sha(raw)
            binding = source['git_input_bindings'][path]
            self.require(digest == source['sources'][path] == source['sources_after'][path] ==
                         binding['sha256'], f'captured source hash mismatch: {path}')
            self.require(raw == self.git('show', f'{candidate}:{path}') ==
                         self.git('cat-file', 'blob', binding['git_object']),
                         f'captured source Git mismatch: {path}')
        for module in ordered:
            text = self.raw(root, 'inputs/lean/' + module.replace('.', '/') + '.lean').decode()
            if module in spec['modules']:
                self.require(text.count('\n-- BEGIN PROOFS\n') == 1, 'missing exact proof boundary')
                prefix, suffix = text.split('\n-- BEGIN PROOFS\n')
                closure = re.search(r'\n(end DefiKernel\.Arithmetic(?:\.[A-Za-z0-9]+)*)\s*$', suffix)
                self.require(closure is not None, 'invalid namespace closure')
                text = prefix + '\n\n' + closure.group(1) + '\n'
            lines = []
            for line in text.splitlines():
                if line.startswith('import '):
                    if line[7:] not in ordered and line not in imports:
                        imports.append(line)
                else:
                    lines.append(line)
            parts.append('\n'.join(lines) + '\n')
        control = '\n'.join(imports) + '\n\n' + '\n'.join(parts)
        self.require(self.raw(root, 'control.lean').decode() == control,
                     'control projection differs from captured production source')
        result = self.json(root, 'results.json')
        names = ['control'] + [m['name'] for m in spec['mutations']]
        self.require(len(set(names)) == len(names) == 13 and set(result['results']) == set(names),
                     'variant inventory incomplete')
        runs = {row['label']: row for row in result['runs']}
        self.require(len(runs) == len(result['runs']) == 17 and set(runs) ==
                     set(names) | {'lean-version', 'lean-path', 'git-head', 'git-root-input-status'},
                     'production command inventory mismatch')
        self.tool(root, result['runs'], source['lean_version'], source['lean_executable_sha256'])
        self.require(self.raw(root, 'git-head.log').decode().strip() == candidate, 'Git log mismatch')
        status_run = runs['git-root-input-status']
        self.require(status_run['exit'] == 0 and
                     sha(self.raw(root, 'git-root-input-status.log')) == status_run['log_sha256'] and
                     not source['input_status'].strip(), 'input status log mismatch or dirty source')
        sibling_path = ('review/semantic-kernel/integer-arithmetic/implementation/'
                        'runner-development/mutation-sites-development.json')
        siblings = json.loads(self.git('show', f'{candidate}:{sibling_path}'))
        self.require(len(siblings) == 12, 'sibling inventory mismatch')
        measured = []
        sibling_rebindings = []
        for index, name in enumerate(names):
            row, run = result['results'][name], runs[name]
            raw = self.raw(root, name + '.log')
            self.require(sha(raw) == run['log_sha256'], 'variant log hash mismatch: ' + name)
            observations = re.findall(r'^(arithmetic\.fixture\.f[0-9]+): (true|false)$',
                                      raw.decode(), re.M)
            self.require([k for k, _ in observations] == fixture_names and
                         len(dict(observations)) == 45, 'variant observation inventory incomplete')
            checks = dict(observations)
            self.require(checks == row['checks'], 'saved observations differ from raw log: ' + name)
            false = sorted(k for k, value in checks.items() if value == 'false')
            self.require(false == row['false_comparisons'], 'saved false inventory mismatch')
            self.require(row['exit'] == run['exit'] and run['timeout_seconds'] == 600,
                         'variant exit/timeout mismatch')
            fixture = self.raw(root, name + '.lean')
            self.require(sha(fixture) == row['fixture_sha256'], 'variant source hash mismatch')
            errors = re.findall(r'^.*: error(?:\([^)]*\))?:.*$', raw.decode(), re.M)
            if index == 0:
                self.require(run['exit'] == 0 and not errors and not false, 'unchanged control failed')
                continue
            mutation, sibling = spec['mutations'][index - 1], siblings[index - 1]
            self.require(control.count(mutation['needle']) == 1 and fixture.decode() ==
                         control.replace(mutation['needle'], mutation['replacement'], 1),
                         'variant is not the exact single source edit')
            self.require(sibling['name'] == name and sibling['module'] == mutation['module'],
                         'sibling source/site identity mismatch')
            target_path = 'lean/' + mutation['module'].replace('.', '/') + '.lean'
            target_sha = source['sources'][target_path]
            if sibling['source_sha256'] != target_sha:
                historical_path = ('review/semantic-kernel/integer-arithmetic/implementation/'
                                   'financial/full-development-r1/inputs/' + target_path)
                historical = self.raw(self.repo, historical_path)
                current = self.raw(root, 'inputs/' + target_path)
                self.require(sha(historical) == sibling['source_sha256'],
                             'stale sibling source lacks exact historical bytes')
                self.require(historical.split(b'\n-- BEGIN PROOFS\n')[0] ==
                             current.split(b'\n-- BEGIN PROOFS\n')[0],
                             'stale sibling source runtime prefix changed')
                sibling_rebindings.append({'id': sibling['id'], 'historical_path': historical_path,
                    'historical_sha256': sha(historical), 'frozen_sha256': target_sha,
                    'runtime_prefix_equal': True,
                    'scope': 'Proof-tail-only source update; original site record retained'})
            self.require(run['exit'] != 0 and len(errors) == 1 and errors[0].endswith(
                f'error: Arithmetic runtime comparisons failed: {len(false)}'),
                'mutant lacks exact numeric semantic failure protocol')
            if not set(mutation['required_false']) <= set(false):
                raise SemanticFailure('designated observation stayed true: ' + name)
            if any(checks[k] != 'true' for k in spec['positive_checks'] + [sibling['sibling']]):
                raise SemanticFailure('protected or sibling observation became false: ' + name)
            measured.append({'name': name, 'id': sibling['id'], 'required_false': mutation['required_false'],
                             'false': false, 'sibling': sibling['sibling'], 'sibling_value': 'true'})
        return {'actual_execution_candidate': candidate, 'comparisons': 585,
                'variants': 13, 'mutations': measured, 'source_files': len(relative_sources),
                'runtime_roots': 9, 'local_modules': 13, 'sibling_rebindings': sibling_rebindings,
                'control_command': runs['control']}

    def controls(self, root, expected):
        inv = self.invocation(root, 'controls')
        summary = self.json(root, 'summary.json')
        self.require(summary['git_head'] == inv['frozen_source'], 'CLI execution revision mismatch')
        cases = summary['cases']
        self.require(summary['total'] == summary['passed'] == len(cases) == 65 and
                     len({c['name'] for c in cases}) == 65 and
                     [c['name'] for c in cases] == [c['name'] for c in expected],
                     'CLI case inventory incomplete')
        for key, path in [('runner', 'scripts/check_integer_arithmetic_mutations.py'),
                          ('harness', 'scripts/test_integer_arithmetic_runner.py')]:
            self.require(summary[key + '_sha256'] == inv['input_bindings'][path]['sha256'],
                         'CLI ' + key + ' identity mismatch')
        self.tool(root, summary['tool_identity_commands'], summary['lean_version'],
                  summary['lean_executable_sha256'])
        origin = Path(self.json(root, 'import-manifest.json')['original_run_root'])
        counts = Counter()
        for case, contract in zip(cases, expected):
            self.require(case['expected_exit'] == contract['exit'] and case['passed'] and
                         case['actual_exit'] == contract['exit'], 'CLI classification mismatch')
            self.require(case['expected_message'] == contract['message'], 'CLI message contract mismatch')
            counts[case['actual_exit']] += 1
            self.require(Path(case['log']) == origin / (case['name'] + '.log'),
                         'CLI log path is not its top-level case log')
            raw = self.raw(root, case['name'] + '.log')
            self.require(sha(raw) == case['log_sha256'] and raw.decode() == case['cli_output'],
                         'CLI log bytes/hash/output mismatch')
            self.require(case['expected_message'] in raw.decode(), 'CLI expected message absent')
            self.require(sha(self.raw(root, case['name'] + '-spec.json')) == case['spec_sha256'],
                         'CLI specification hash mismatch')
            for variant, observation in case['lean_observations'].items():
                log = self.raw(root, f"runs/{case['name']}/{variant}.log")
                self.require(sha(log) == observation['log_sha256'], 'CLI Lean observation hash mismatch')
                parsed = re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$',
                                    log.decode(), re.M)
                self.require([list(pair) for pair in parsed] == observation['lines'],
                             'CLI Lean observation parse mismatch')
            for run in case['runner_records']:
                self.require(sha(self.raw(root, f"runs/{case['name']}/{run['label']}.log")) ==
                             run['log_sha256'], 'CLI labelled command log mismatch')
        self.require(counts == {0: 10, 1: 5, 3: 50}, 'CLI classification totals mismatch')
        return {'actual_execution_candidate': inv['frozen_source'], 'cases': 65,
                'exit_counts': dict(counts), 'exact_cli_log_paths': 65}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--production', type=Path, required=True)
    parser.add_argument('--controls', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    audit = Audit(args.repo.resolve())
    result = {'scope': 'Saved-artifact consistency and Git-source reconciliation; no new Lean execution, '
                        'cryptographic execution attestation or independent/native acceptance.',
              'started_utc': datetime.now(timezone.utc).isoformat(),
              'checker_sha256': sha(Path(__file__).read_bytes())}
    code = 3
    try:
        audit.require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
        fixtures = json.loads((audit.repo / 'openspec/changes/checked-integer-financial-arithmetic/'
                               'fixture-inventory.json').read_text())['fixtures']
        contract = json.loads((audit.repo / 'openspec/changes/checked-integer-financial-arithmetic/'
                               'runner-contract.json').read_text())
        expected = [f['label'] for f in fixtures]
        audit.require(len(expected) == len(set(expected)) == 45, 'expected fixture inventory')
        result['production'] = audit.production(args.production.resolve(), expected)
        result['controls'] = audit.controls(args.controls.resolve(), contract['cases'])
        candidate = result['production']['actual_execution_candidate']
        paths = ['openspec/changes/checked-integer-financial-arithmetic/fixture-inventory.json',
                 'openspec/changes/checked-integer-financial-arithmetic/runner-contract.json']
        result['contract_bindings'] = {}
        for path in paths:
            raw = audit.raw(audit.repo, path)
            audit.require(raw == audit.git('show', f'{candidate}:{path}'),
                          'current evidence contract differs from production candidate')
            result['contract_bindings'][path] = sha(raw)
        prod_source = audit.json(args.production, 'source-manifest.json')
        controls = audit.json(args.controls, 'summary.json')
        audit.require(prod_source['script_sha256'] == controls['runner_sha256'] and
                      prod_source['lean_executable_sha256'] == controls['lean_executable_sha256'],
                      'production and retained controls use different driver or Lean bytes')
        result['status'], code = 'PASS', 0
    except SemanticFailure as exc:
        result['status'], result['reason'], code = 'FAIL', str(exc), 1
    except (Blocked, KeyError, ValueError, TypeError, IndexError, AttributeError,
            OSError, subprocess.SubprocessError) as exc:
        result['status'], result['reason'] = 'BLOCKED', str(exc)
    result['assertions'] = audit.assertions
    result['finished_utc'] = datetime.now(timezone.utc).isoformat()
    if not args.out.exists() and not args.out.is_symlink():
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
    return code


if __name__ == '__main__':
    raise SystemExit(main())
