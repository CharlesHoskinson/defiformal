#!/usr/bin/env python3
"""Copy successful frozen evidence byte-exactly and reconcile its saved records."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import itertools
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[5]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return json.loads(path.read_text())


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--external', type=Path, required=True)
    parser.add_argument('--dest', type=Path, required=True)
    args = parser.parse_args()
    external, dest = args.external.resolve(), args.dest.resolve()
    assert not external.is_relative_to(ROOT) and dest.is_relative_to(ROOT)
    assert not dest.exists()
    invocation = read(external / 'invocation.json')
    assert invocation['status'] == 'FINISHED' and invocation['actual_exit'] == 0
    assert invocation['git_head_unchanged'] and all(invocation['inputs_unchanged'].values())
    candidate = invocation['frozen_source']
    assert git('rev-parse', 'HEAD').decode().strip() == candidate
    for path, binding in invocation['input_bindings'].items():
        raw = (ROOT / path).read_bytes()
        assert sha(raw) == binding['sha256'] and raw == git('show', f'{candidate}:{path}')
        assert git('rev-parse', f'{candidate}:{path}').decode().strip() == binding['git_blob']
    for label in ('stdout', 'stderr'):
        assert sha((external / (label + '.log')).read_bytes()) == invocation[label + '_sha256']
    copied, excluded = [], []
    dest.mkdir(parents=True)
    def copy_file(old, new):
        raw = old.read_bytes()
        new.parent.mkdir(parents=True, exist_ok=True)
        new.write_bytes(raw)
        assert new.read_bytes() == raw
        copied.append({'path': str(new.relative_to(dest)), 'original_path': str(old),
                       'sha256': sha(raw), 'bytes': len(raw)})
    for base, dirs, names in os.walk(external / 'run', followlinks=False):
        base = Path(base)
        for name in list(dirs):
            path = base / name
            if name == '.git' or path.is_symlink():
                excluded.append({'path': str(path), 'reason': 'nested Git metadata' if name == '.git'
                                 else 'symlink not followed',
                                 'target': os.readlink(path) if path.is_symlink() else None})
                dirs.remove(name)
        for name in names:
            old = base / name
            if old.is_symlink():
                excluded.append({'path': str(old), 'reason': 'symlink not followed', 'target': os.readlink(old)})
                continue
            copy_file(old, dest / old.relative_to(external / 'run'))
    copy_file(external / 'invocation.json', dest / 'invocation.json')
    for label in ('stdout', 'stderr'):
        copy_file(external / (label + '.log'), dest / ('suite.' + label + '.log'))
    crosscheck = {'candidate': candidate, 'checked_utc': datetime.now(timezone.utc).isoformat(),
                  'scope': 'Author mechanical reconciliation of actual saved artifacts, not independent/native review.',
                  'kind': invocation['kind'], 'copied_raw_artifacts': len(copied),
                  'outer_input_git_bindings': len(invocation['input_bindings'])}
    if invocation['kind'] == 'production':
        source = read(dest / 'source-manifest.json')
        results = read(dest / 'results.json')
        spec = read(dest / 'mutation-spec.json')
        expected = read(ROOT / 'review/semantic-kernel/sprint9/implementation/financial/runtime-inventory-148.json')['runtime_inventory']
        assert len(expected) == len(set(expected)) == 148
        assert source['git_head'] == candidate and source['git_head_after'] == candidate
        for flag in ('input_sources_unchanged', 'specification_unchanged', 'runner_unchanged', 'git_head_unchanged'):
            assert source[flag]
        assert source['timeout_seconds_per_command'] == 600
        for path, digest in source['sources'].items():
            raw = (dest / 'inputs' / path).read_bytes()
            assert sha(raw) == digest == source['sources_after'][path]
            bound = source['git_input_bindings'][path]
            assert raw == git('cat-file', 'blob', bound['git_object'])
            assert bound['sha256'] == digest
        assert sha((dest / 'mutation-spec.json').read_bytes()) == source['spec_sha256']
        assert source['script_sha256'] == invocation['input_bindings']['scripts/check_metatheory_mutations.py']['sha256']
        names = ['control'] + [m['name'] for m in spec['mutations']]
        assert len(names) == len(set(names)) == len(results['results']) == 15
        assert set(results['results']) == set(names)
        sibling_plan = read(ROOT / 'review/semantic-kernel/sprint9/implementation/runner-development/planned-sibling-matrix.json')
        assert sibling_plan['spec_sha256'] == source['spec_sha256']
        sibling_by_name = {row['mutant']: row for row in sibling_plan['rows']}
        measured, sibling_rows = [], []
        for name in names:
            row = results['results'][name]
            raw = (dest / (name + '.lean')).read_bytes()
            log = (dest / (name + '.log')).read_text()
            assert sha(raw) == row['fixture_sha256']
            observations = re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', log, re.M)
            assert len(observations) == len(dict(observations)) == 148
            assert set(dict(observations)) == set(expected) and dict(observations) == row['checks']
            false = sorted(k for k, v in observations if v == 'false')
            assert false == row['false_comparisons']
            assert all(row['checks'][p] == 'true' for p in spec['positive_checks'])
            errors = [line for line in log.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)]
            if name == 'control':
                assert row['exit'] == 0 and not false and not errors
                continue
            mutation = next(m for m in spec['mutations'] if m['name'] == name)
            control = (dest / 'control.lean').read_text()
            assert control.count(mutation['needle']) == 1
            assert raw.decode() == control.replace(mutation['needle'], mutation['replacement'], 1)
            assert row['exit'] != 0 and set(mutation['required_false']) <= set(false)
            assert len(errors) == 1 and errors[0].endswith(f'error: Metatheory runtime comparisons failed: {len(false)}')
            sibling = sibling_by_name[name]
            value = row['checks'][sibling['supplemental_positive']]
            assert value == 'true', (name, sibling['supplemental_positive'], value)
            sibling_rows.append({**sibling, 'measured_outcome': value})
            measured.append({'name': name, 'required_false': mutation['required_false'],
                             'false_count': len(false), 'false_comparisons': false,
                             'evidence_class': 'executor-routing' if len(measured) < 8 else 'synthetic-observer-sensitivity'})
        for record in results['runs']:
            label = record['label']
            assert sha((dest / (label + '.log')).read_bytes()) == record['log_sha256']
        overlap = [{'left': a['name'], 'right': b['name'],
                    'shared_false': sorted(set(a['false_comparisons']) & set(b['false_comparisons'])),
                    'identical_false_inventory': a['false_comparisons'] == b['false_comparisons']}
                   for a, b in itertools.combinations(measured, 2)]
        save(dest / 'summary.json', {'candidate': candidate, 'mutants': measured,
                                    'pairwise_oracle_overlap': overlap,
                                    'limits': 'Eight routing and six synthetic observer sensitivity interventions; overlap is not independent diagnostic isolation.'})
        save(dest / 'sibling-matrix.json', {'candidate': candidate, 'global_positives': spec['positive_checks'],
                                          'supplemental_only_no_runner_behavior_change': True, 'rows': sibling_rows})
        crosscheck.update(source_git_sha_bindings=len(source['sources']), exact_single_edit_projections=14,
                          unique_complete_inventories=15, comparisons=15 * 148,
                          designated_false=14, protected_true=15 * len(spec['positive_checks']),
                          supplemental_siblings=14, log_hashes=len(results['runs']))
        report = f'All 14 production mutants compiled and were discriminated at `{candidate}`. The unchanged control had 148/148 true comparisons. Each variant emitted the same 148 unique names, made its designated observation false and retained both global positives. Runner exit 0.\n\n'
        report += 'Eight mutations change actual recursive execution; six change the production comparator on explicitly synthetic observer pairs. These are separate evidence classes. All imported proof suffixes remain intact; only Metatheory proof tails are projected away.\n\n'
        report += '| Mutation | Designated false | False count |\n|---|---|---:|\n'
        for row in measured:
            report += f'| {row["name"]} | {", ".join(row["required_false"])} | {row["false_count"]} |\n'
        identical = [row for row in overlap if row['identical_false_inventory']]
        report += '\nBoth global positives are `metatheory.positive.single-leaf` and `metatheory.positive.equal-observation`. All 14 supplemental sibling observations passed; six overlap the global equal-observation control, as explicitly recorded. This adds no new runner schema or behavior.\n\n'
        report += 'All 91 pairwise false-inventory overlaps are recorded in summary.json. Identical inventories: '
        report += '; '.join(f'{r["left"]} / {r["right"]}' for r in identical) if identical else 'none'
        report += '. Overlap can prevent identification of a particular fault from the false labels alone.\n\n'
        report += 'Exact command, Git/source/spec/driver/harness hashes, complete source inputs/projections and raw logs are preserved. The production command explicitly uses a 600-second command timeout. Run UTC and inherited labeled-command/variant elapsed fields are retained; no per-command UTC or binding-call timing is claimed.\n'
    else:
        summary = read(dest / 'summary.json')
        assert summary['total'] == summary['passed'] == len(summary['cases']) == 65
        assert summary['git_head'] == candidate
        assert summary['runner_sha256'] == invocation['input_bindings']['scripts/check_metatheory_mutations.py']['sha256']
        assert summary['harness_sha256'] == invocation['input_bindings']['scripts/test_metatheory_mutation_runner.py']['sha256']
        planned_cases = read(ROOT / 'review/semantic-kernel/sprint9/planning/runner-literal-adaptation-map.json')['control_inventory']['planned']
        assert len({case['name'] for case in summary['cases']}) == 65
        assert {case['name']: case['expected_exit'] for case in summary['cases']} == {case['name']: case['exit'] for case in planned_cases}
        for identity in summary['tool_identity_commands']:
            assert sha((dest / (identity['label'] + '.log')).read_bytes()) == identity['log_sha256']
        counts = Counter()
        for case in summary['cases']:
            assert case['passed'] and case['expected_exit'] == case['actual_exit']
            counts[case['actual_exit']] += 1
            original = Path(case['log'])
            assert original.is_relative_to(external / 'run')
            raw = (dest / original.relative_to(external / 'run')).read_bytes()
            assert sha(raw) == case['log_sha256'] and raw.decode() == case['cli_output']
            assert sha((dest / (case['name'] + '-spec.json')).read_bytes()) == case['spec_sha256']
            for variant, observation in case['lean_observations'].items():
                log = dest / 'runs' / case['name'] / (variant + '.log')
                assert sha(log.read_bytes()) == observation['log_sha256']
            for run_record in case['runner_records']:
                log = dest / 'runs' / case['name'] / (run_record['label'] + '.log')
                assert sha(log.read_bytes()) == run_record['log_sha256']
        assert counts == {0: 10, 1: 5, 3: 50}
        crosscheck.update(cases=65, exact_cli_log_paths_hashes_and_output=65,
                          actual_exit_counts=dict(counts), production_form_cases=2)
        report = f'All 65 actual CLI controls passed at `{candidate}`: 10 exit 0, 5 exit 1 and 50 exit 3. The inherited inventory contains 52 original cases, 11 added proof-tail cases and two production-form Audit cases.\n\n'
        report += 'These synthetic Lean fixtures exercise the actual driver and subprocess behavior. They are compiler/runner controls, not production financial mutation evidence. Every case retains its exact expected classification and CLI output/log path/hash binding, including both production-form cases and the inherited lean_log_path fix.\n\n'
        report += 'Runner commands use the unchanged 600-second default; the harness outer per-case limit remains 1500 seconds. Run UTC and inherited elapsed fields are retained. Nested Git databases and symlinks are excluded from the copy and individually listed; original evidence bytes remain unchanged.\n'
    crosscheck['passed'] = True
    save(dest / 'artifact-crosscheck.json', crosscheck)
    save(dest / 'final-manifest.json', {'candidate': candidate, 'invocation': invocation,
                                       'copy_source': str(external), 'raw_artifacts': copied,
                                       'excluded': excluded,
                                       'finalizer_sha256': sha(Path(__file__).read_bytes()),
                                       'acceptance_scope': 'Mechanical evidence qualification only; independent/native final review and delivery are not claimed.'})
    (dest / 'REPORT.md').write_text(report)
    inventory = [{'path': str(p.relative_to(dest)), 'bytes': p.stat().st_size,
                  'sha256': sha(p.read_bytes())} for p in sorted(dest.rglob('*'))
                 if p.is_file() and p.name != 'artifact-inventory.json']
    save(dest / 'artifact-inventory.json', inventory)
    for row in inventory:
        assert sha((dest / row['path']).read_bytes()) == row['sha256']
    print(json.dumps({'kind': invocation['kind'], 'passed': True, 'artifacts': len(inventory),
                      'excluded': len(excluded), 'crosscheck': crosscheck, 'output': str(dest)}))


if __name__ == '__main__':
    main()
