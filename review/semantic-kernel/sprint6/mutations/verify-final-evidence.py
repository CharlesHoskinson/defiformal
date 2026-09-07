#!/usr/bin/env python3
"""Supplementary verification of saved Sprint 6 evidence; no Lean command is run.

This is a new reproducible checker, not the source of the historical 160/470
assertion reports. It checks captured records, log contents, source projections,
and committed Git bytes; it does not independently re-attest historical processes.
Exit 0 verifies a nonempty inventory, 1 finds disagreement, 3 cannot check inputs.
"""
import argparse
from datetime import datetime, timezone
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

REVISION = 'fae07caa2620c7a1d4ba1a39cb9a9be171ff137d'
NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'
DIAGNOSTIC_SUFFIX = '''
#eval do
  match DefiKernel.Parallel.Tests.routeForeign with
  | .refused _ _ => IO.println "DIAGNOSTIC admission-refused"
  | .executed joined =>
    IO.println s!"DIAGNOSTIC peer-only left_failure={joined.left.failure.isSome} next_index={joined.left.nextIndex} alice_usd={joined.world.state.balance (.main, .alice, .usd)} bob_usd={joined.world.state.balance (.main, .bob, .usd)}"
'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


class Verifier:
    def __init__(self, repo):
        self.repo = repo
        self.checks = []
        self.inputs = {}
        self.git_bindings = []
        self.git_cache = {}

    def check(self, value, message):
        if not value:
            raise AssertionError(message)
        self.checks.append(message)

    def raw(self, path):
        raw = path.read_bytes()
        self.inputs[str(path)] = sha(raw)
        return raw

    def data(self, path):
        def unique(items):
            result = {}
            for key, value in items:
                if key in result:
                    raise AssertionError(f'{path.name}: duplicate JSON key {key}')
                result[key] = value
            return result
        return json.loads(self.raw(path), object_pairs_hook=unique)

    def hashed(self, path, expected):
        raw = self.raw(path)
        self.check(sha(raw) == expected, f'{path}: artifact hash')
        return raw

    def git(self, relative, expected):
        self.check(not Path(relative).is_absolute() and '..' not in Path(relative).parts,
                   f'{relative}: safe Git path')
        if relative not in self.git_cache:
            command = ['git', 'show', f'{REVISION}:{relative}']
            proc = subprocess.run(command, cwd=self.repo, capture_output=True, timeout=60)
            self.check(proc.returncode == 0, f'{relative}: Git object available')
            self.git_cache[relative] = proc.stdout
        raw = self.git_cache[relative]
        self.check(sha(raw) == expected, f'{relative}: Git object matches captured bytes')
        self.git_bindings.append({'path': relative, 'revision': REVISION, 'sha256': expected})
        return raw

    def observations(self, raw, label):
        text = raw.decode()
        pairs = re.findall(rf'^({NAME}): (true|false)$', text, re.MULTILINE)
        self.check(bool(pairs) and len(dict(pairs)) == len(pairs), f'{label}: unique nonempty observations')
        return dict(pairs)

    def runs(self, base, records):
        labels = [r['label'] for r in records]
        self.check(len(labels) == len(set(labels)), f'{base.name}: unique run labels')
        for r in records:
            self.hashed(base / (r['label'] + '.log'), r['log_sha256'])
        return {r['label']: r for r in records}

    def runtime(self, base, label, result, inventory=None):
        source = self.hashed(base / (label + '.lean'), result['fixture_sha256'])
        log = self.raw(base / (label + '.log'))
        observed = self.observations(log, label)
        if inventory is not None:
            self.check(set(observed) == set(inventory), f'{label}: complete inventory')
        self.check(observed == result['checks'], f'{label}: raw observations match result record')
        false = sorted(k for k, v in observed.items() if v == 'false')
        self.check(false == result['false_comparisons'], f'{label}: exact false inventory')
        errors = [line for line in log.decode().splitlines() if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            self.check(result['exit'] == 0 and not false and not errors, 'unchanged control true with no compiler errors')
        else:
            self.check(result['exit'] == 1 and len(errors) == 1 and
                       errors[0].endswith(f'error: Parallel runtime comparisons failed: {len(false)}'),
                       f'{label}: sole expected runtime failure')
        return source, observed

    def projection(self, base, manifest):
        ordered = manifest['projection_order']
        self.check(len(ordered) == len(set(ordered)) == 24, '24 unique source modules')
        imports, parts = [], {}
        for module in ordered:
            source = self.raw(base / 'inputs' / ('lean/' + module.replace('.', '/') + '.lean')).decode()
            marker = '\n-- BEGIN PROOFS\n'
            if module.startswith('DefiKernel.Parallel.') and marker in source:
                self.check(source.count(marker) == 1, module + ': one proof boundary')
                prefix, suffix = source.split(marker)
                closure = re.search(r'\n(end DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
                self.check(closure is not None, module + ': exact closing namespace')
                source = prefix + '\n\n' + closure.group(1) + '\n'
            lines = []
            for line in source.splitlines():
                if line.startswith('import '):
                    imported = line[7:].strip()
                    self.check(not imported.startswith('DefiKernel.') or imported in ordered,
                               module + ': local import captured')
                    if imported not in ordered and line not in imports:
                        imports.append(line)
                else:
                    lines.append(line)
            parts[module] = '\n'.join(lines) + '\n'
        def render(values):
            return ('\n'.join(imports) + '\n\n' + '\n'.join(values[m] for m in ordered)).encode()
        return parts, render

    def production(self, base):
        summary = self.data(base / 'summary.json')
        self.check(summary['git_head'] == REVISION and summary['exit'] == 0, 'production frozen candidate and exit')
        for name, field in [('source-manifest.json', 'source_manifest_sha256'),
                            ('results.json', 'results_sha256'), ('cli.log', 'cli_log_sha256')]:
            self.hashed(base / name, summary[field])
        manifest = self.data(base / 'source-manifest.json')
        spec = self.data(base / 'mutation-spec.json')
        results = self.data(base / 'results.json')
        self.check(manifest['git_head'] == REVISION and manifest['input_status'] == '', 'production clean committed input paths')
        self.check(manifest['sources'] == manifest['sources_after'] and
                   all(manifest[k] is True for k in ('input_sources_unchanged', 'specification_unchanged', 'runner_unchanged')),
                   'production before/after identities agree')
        self.check(len(manifest['sources']) == 27, '27 captured local/config inputs')
        for path, digest in manifest['sources'].items():
            self.hashed(base / 'inputs' / path, digest)
            self.git(path, digest)
        self.hashed(base / 'mutation-spec.json', manifest['spec_sha256'])
        self.git('review/semantic-kernel/sprint6/mutation-spec.json', manifest['spec_sha256'])
        self.hashed(base / 'source-snapshot/check_parallel_mutations.py', manifest['script_sha256'])
        self.git('scripts/check_parallel_mutations.py', manifest['script_sha256'])
        names = [m['name'] for m in spec['mutations']]
        positives = spec['positive_checks']
        self.check(len(names) == len(set(names)) == 14, '14 unique actual mutations')
        self.check(len(positives) == len(set(positives)) == 5, 'five unique protected comparisons')
        self.check(set(results['results']) == {'control', *names}, 'exact production variant inventory')
        records = self.runs(base, results['runs'])
        self.check(set(records) == {'lean-version', 'lean-path', 'git-head', 'git-root-input-status', 'control', *names},
                   'complete tool/variant command inventory')
        inventory = results['results']['control']['checks']
        self.check(len(inventory) == 131, '131 comparison control inventory')
        parts, render = self.projection(base, manifest)
        control_source = render(parts)
        for label, result in results['results'].items():
            source, observed = self.runtime(base, label, result, inventory)
            self.check(records[label]['exit'] == result['exit'], label + ': actual command exit agrees')
            self.check(all(observed[p] == 'true' for p in positives), label + ': five protected positives true')
            if label == 'control':
                expected = control_source
            else:
                m = next(m for m in spec['mutations'] if m['name'] == label)
                prefix = parts[m['module']]
                self.check(prefix.count(m['needle']) == 1 and m['needle'] != m['replacement'],
                           label + ': unique real edit on proof-stripped projection')
                changed = {**parts, m['module']: prefix.replace(m['needle'], m['replacement'], 1)}
                expected = render(changed)
                self.check(m['required_false'] and all(observed[k] == 'false' for k in m['required_false']),
                           label + ': all designated comparisons false')
            self.check(source == expected, label + ': generated bytes equal captured-source projection/edit')
        self.check(summary['mutations'] == summary['detected'] == 14 and
                   summary['comparisons_per_mutant'] == summary['control_comparisons'] == 131 and
                   summary['protected_comparisons_per_mutant'] == 5, 'production summary counts independently agree')
        return results['results']

    def controls(self, base):
        invocation = self.data(base / 'invocation.json')
        self.hashed(base / 'summary.json', invocation['summary_sha256'])
        self.hashed(base / 'cli.log', invocation['cli_log_sha256'])
        summary = self.data(base / 'summary.json')
        self.check(summary['git_head'] == REVISION and invocation['exit'] == 0, 'controls frozen revision and successful harness exit')
        for field, name in [('runner_sha256', 'check_parallel_mutations.py'), ('harness_sha256', 'test_parallel_mutation_runner.py')]:
            raw = self.hashed(base / 'source-snapshot' / name, summary[field])
            self.git('scripts/' + name, sha(raw))
        # Evaluate only the definition list in the already Git-verified harness.
        # Its __main__ guard is false; no harness main or Lean subprocess runs.
        namespace = {'__name__': 'verified_evidence_harness'}
        exec(compile(raw, str(base / 'source-snapshot/test_parallel_mutation_runner.py'), 'exec'), namespace)
        expected = {c['name']: c for c in namespace['cases']()}
        cases = summary['cases']
        self.check(cases == self.data(base / 'cases.json'), 'control case records agree')
        self.check(len(cases) == len({c['name'] for c in cases}) == len(expected) == 45,
                   '45 unique actual CLI cases')
        self.check({c['name'] for c in cases} == set(expected), 'exact committed harness case inventory')
        for c in cases:
            name = c['name']
            known = expected[name]
            self.check(c['actual_exit'] == c['expected_exit'] == known['exit'], name + ': expected exit from committed harness')
            log = self.hashed(base / (name + '.log'), c['log_sha256']).decode()
            self.check(c['passed'] and c['expected_message'] == known['message'] and known['message'] in log and c['cli_output'] == log,
                       name + ': actual CLI log supports classification')
            self.hashed(base / (name + '-spec.json'), c['spec_sha256'])
            run = base / 'runs' / name
            self.runs(run, c['runner_records'])
            mp = run / 'source-manifest.json'
            if mp.exists():
                m = self.data(mp)
                self.check(m['script_sha256'] == summary['runner_sha256'] and m['spec_sha256'] == c['spec_sha256'], name + ': executed runner/spec identities')
                for path, digest in m['sources'].items():
                    self.hashed(run / 'inputs' / path, digest)
                r = self.data(run / 'results.json')
                self.check(r['runs'] == c['runner_records'], name + ': saved command records agree')
                for label, result in r['results'].items():
                    self.runtime(run, label, result)
                if known['exit'] == 0:
                    self.check(m['sources'] == m['sources_after'] and m['input_sources_unchanged'], name + ': accepted toy source unchanged')
                    test_spec = self.data(run / 'mutation-spec.json')
                    positive, sensitive = test_spec['positive_checks'][0], test_spec['mutations'][0]['required_false'][0]
                    self.check(r['results']['control']['checks'] == {positive: 'true', sensitive: 'true'} and
                               r['results']['probe']['checks'] == {positive: 'true', sensitive: 'false'},
                               name + ': exact accepted toy runtime observations')
            for setup in c['setup_records']:
                self.hashed(base / 'stale-dependency-setup.log', setup['log_sha256'])
                self.check(setup['exit'] == 0, 'actual stale-cache setup recorded successful')
        self.check(summary['total'] == summary['passed'] == 45, 'control summary agrees with all 45 outcomes')

    def history(self, base, production):
        records = self.data(base / 'results.json')
        self.check(len(records) == 2 and {r['variant'] for r in records} == {'control', 'leak-peer-output-history'}, 'two unique history diagnostics')
        expected = {'control': ('true', 1, Fraction(7), Fraction(3)),
                    'leak-peer-output-history': ('false', 2, Fraction(2), Fraction(8))}
        for r in records:
            label = r['variant']
            self.check(r['base_fixture_sha256'] == production[label]['fixture_sha256'], label + ': history base source hash is final actual variant')
            source = self.hashed(base / (label + '.lean'), r['fixture_sha256'])
            self.check(source.endswith(DIAGNOSTIC_SUFFIX.encode()) and
                       sha(source[:-len(DIAGNOSTIC_SUFFIX.encode())]) == r['base_fixture_sha256'],
                       label + ': exact actual base plus field-reading diagnostic source')
            log = self.hashed(base / (label + '.log'), r['log_sha256'])
            self.check(self.observations(log, label) == production[label]['checks'], label + ': history retained full actual runtime observations')
            lines = [line for line in log.decode().splitlines() if line.startswith('DIAGNOSTIC ')]
            self.check(len(lines) == 1 and lines == r['diagnostic_lines'], label + ': one captured history diagnostic')
            match = re.fullmatch(r'DIAGNOSTIC peer-only left_failure=(true|false) next_index=(\d+) alice_usd=([^ ]+) bob_usd=([^ ]+)', lines[0])
            self.check(match is not None, label + ': parsed history diagnostic')
            actual = (match[1], int(match[2]), Fraction(match[3]), Fraction(match[4]))
            self.check(actual == expected[label], label + ': history funded values show actual USD5 transfer')
            self.check(r['exit'] == r['expected_exit'] == production[label]['exit'] and r['passed'], label + ': diagnostic captured exit')
        self.check(expected['control'][2] >= 5 and expected['control'][2] - expected['leak-peer-output-history'][2] == 5 and
                   expected['leak-peer-output-history'][3] - expected['control'][3] == 5,
                   'history funded values preserve USD while transferring five')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo', type=Path, required=True)
    p.add_argument('--production', type=Path)
    p.add_argument('--controls', type=Path)
    p.add_argument('--history', type=Path)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    if out.is_relative_to(repo) or args.out.exists() or args.out.is_symlink():
        raise RuntimeError('output must be new and outside repository')
    root = repo / 'review/semantic-kernel/sprint6'
    out.mkdir(parents=True)
    v = Verifier(repo)
    started = datetime.now(timezone.utc).isoformat()
    source_hash = sha(Path(__file__).read_bytes())
    results = v.production(args.production or root / 'mutations/final-fae07ca')
    v.controls(args.controls or root / 'runner-controls/final-fae07ca')
    v.history(args.history or root / 'mutations/history-diagnostics', results)
    v.check(sha(Path(__file__).read_bytes()) == source_hash, 'supplementary verifier source unchanged')
    report = {'kind': 'supplementary-saved-evidence-verification', 'status': 'verified',
              'revision': REVISION, 'verifier_sha256': source_hash,
              'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
              'assertions': len(v.checks), 'failures': 0, 'mutations': 14, 'comparisons_per_variant': 131,
              'protected_positives': 5, 'actual_cli_controls': 45, 'history_diagnostics': 2,
              'input_sha256': v.inputs, 'git_bindings': v.git_bindings, 'checks': v.checks,
              'scope': 'Supplementary checker of saved artifacts and committed source identities. No Lean command run. This code did not generate the original 160/470 assertion reports.'}
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    (out / 'history-diagnostic-suffix.lean').write_text(DIAGNOSTIC_SUFFIX)
    print(f'VERIFIED: 14 mutants; 131 comparisons per variant; 5 positives; 45 CLI controls; 2 history diagnostics; {len(v.checks)} supplementary assertions')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)
