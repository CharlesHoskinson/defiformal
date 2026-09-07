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
import tarfile

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
    parser.add_argument('--financial-inventory', type=Path)
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
                archive = None
                if name == '.git' and not path.is_symlink():
                    archive = str(path.relative_to(external / 'run')).replace('/', '-') + '.tar.gz'
                    with tarfile.open(dest / archive, 'w:gz') as output:
                        output.add(path, arcname='fixture-git')
                excluded.append({'path': str(path), 'reason': 'nested Git metadata archived' if name == '.git'
                                 else 'symlink not followed', 'archive': archive,
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
        assert args.financial_inventory is not None
        financial_path = args.financial_inventory.resolve()
        financial = read(financial_path)
        expected = financial['runtime_inventory']
        for path, bound in financial['sources'].items():
            assert sha((dest / 'inputs' / path).read_bytes()) == (bound if isinstance(bound, str) else bound['sha256'])
        crosscheck['financial_inventory_path'] = str(financial_path.relative_to(ROOT))
        crosscheck['financial_inventory_sha256'] = sha(financial_path.read_bytes())
        assert expected and len(expected) == len(set(expected))
        assert source['git_head'] == candidate and source['git_head_after'] == candidate
        for flag in ('input_sources_unchanged', 'specification_unchanged', 'runner_unchanged', 'git_head_unchanged'):
            assert source[flag]
        assert source['timeout_seconds_per_command'] == 600
        for path, digest in source['sources'].items():
            raw = (dest / 'inputs' / path).read_bytes()
            assert sha(raw) == digest == source['sources_after'][path]
            bound = source['git_input_bindings'][path]
            assert raw == git('cat-file', 'blob', bound['git_object'])
            assert (bound if isinstance(bound, str) else bound['sha256']) == digest
        assert sha((dest / 'mutation-spec.json').read_bytes()) == source['spec_sha256']
        assert source['script_sha256'] == invocation['input_bindings']['scripts/run_interface_mutations.py']['sha256']
        names = ['control'] + [m['name'] for m in spec['mutations']]
        assert len(names) == len(set(names)) == len(results['results']) == 15
        assert set(results['results']) == set(names)
        sibling_plan = read(ROOT / 'review/semantic-kernel/sprint10/implementation/runner-development/mutation-sites-development.json')
        assert sibling_plan['spec_sha256'] == source['spec_sha256']
        sibling_by_name = {row['name']: row for row in sibling_plan['mutations']}
        measured, sibling_rows = [], []
        for name in names:
            row = results['results'][name]
            raw = (dest / (name + '.lean')).read_bytes()
            log = (dest / (name + '.log')).read_text()
            assert sha(raw) == row['fixture_sha256']
            observations = re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', log, re.M)
            assert len(observations) == len(dict(observations)) == len(expected)
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
            assert len(errors) == 1 and errors[0].endswith(f'error: Interface runtime comparisons failed: {len(false)}')
            sibling = sibling_by_name[name]
            value = row['checks'][sibling['sibling']]
            assert value == 'true', (name, sibling['sibling'], value)
            sibling_rows.append({**sibling, 'measured_outcome': value})
            measured.append({'name': name, 'required_false': mutation['required_false'],
                             'false_count': len(false), 'false_comparisons': false,
                             'evidence_class': ('typed-binding-validation' if len(measured) + 1 in [8, 9] else 'ordered-diagnostic' if len(measured) + 1 == 12 else 'structural-resolution-validation' if len(measured) + 1 in [11, 13] else 'accounting-balance-query')})
        for record in results['runs']:
            label = record['label']
            assert sha((dest / (label + '.log')).read_bytes()) == record['log_sha256']
        overlap = [{'left': a['name'], 'right': b['name'],
                    'shared_false': sorted(set(a['false_comparisons']) & set(b['false_comparisons'])),
                    'identical_false_inventory': a['false_comparisons'] == b['false_comparisons']}
                   for a, b in itertools.combinations(measured, 2)]
        save(dest / 'summary.json', {'candidate': candidate, 'mutants': measured,
                                    'pairwise_oracle_overlap': overlap,
                                    'limits': 'Read-only Interface accounting/binding queries over actual financial fixtures; overlap is not independent fault identification.'})
        save(dest / 'sibling-matrix.json', {'candidate': candidate, 'global_positives': spec['positive_checks'],
                                          'supplemental_only_no_runner_behavior_change': True, 'rows': sibling_rows})
        crosscheck.update(source_git_sha_bindings=len(source['sources']), exact_single_edit_projections=14,
                          unique_complete_inventories=15, comparisons=15 * len(expected),
                          designated_false=14, protected_true=15 * len(spec['positive_checks']),
                          supplemental_siblings=14, log_hashes=len(results['runs']))
        report = f'All14 production runtime mutations compiled and were discriminated at `{candidate}`. The unchanged control had{len(expected)}/{len(expected)} true comparisons. Every variant emitted the identical complete unique inventory, its designated observation was false and both global positives remained true. Runner exit0.\n\n'
        report += 'These mutations change read-only Interface region/receipt/binding query computations. Financial fixtures execute the actual existing kernel; no mutation changes its executor, authority guards or transitions. Typed, structural and diagnostic checks are classified separately in summary.json. Only new Interface proof suffixes are stripped; imported old proofs remain exact.\n\n'
        report += '| Mutation | Designated false | False count |\n|---|---|---:|\n'
        for row in measured:
            report += f'| {row["name"]} | {", ".join(row["required_false"])} | {row["false_count"]} |\n'
        report += '\nGlobal positives are interface.positive.transfer and interface.positive.empty-query. The transfer checks full actual execution and invokes receiptDelta on its neutral region; all measured variants retain it. All14 row-specific sibling observations also pass, enforced by this separate source-bound reconciliation rather than the global runner schema.\n\n'
        report += 'All91 pairwise false-inventory overlaps are saved. Detection does not imply unique fault identification. Exact source/tool/Git/spec/driver/harness identities, all source projections and raw logs are retained. Production commands use600 seconds; control compilation time is reported from the actual unchanged-control command record. UTC is outer run scope; inherited labelled-command/variant elapsed is retained, with no unlogged binding-call timing claim.\n'
        control_record = next(r for r in results['runs'] if r['label'] == 'control')
        crosscheck['unchanged_control_command_record'] = control_record
    else:
        summary = read(dest / 'summary.json')
        assert summary['total'] == summary['passed'] == len(summary['cases']) == 65
        assert summary['git_head'] == candidate
        assert summary['runner_sha256'] == invocation['input_bindings']['scripts/run_interface_mutations.py']['sha256']
        assert summary['harness_sha256'] == invocation['input_bindings']['scripts/test_interface_mutation_runner.py']['sha256']
        planned_cases = [c['new_case'] for c in read(ROOT / 'review/semantic-kernel/sprint10/planning/r2-preparation/runner-adaptation.json')['controls']]
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
        report += 'Runner commands use the unchanged 600-second default; the harness outer per-case limit remains 1500 seconds. Run UTC and inherited elapsed fields are retained. Nested Git databases are archived; symlinks are excluded and individually listed; original evidence bytes remain unchanged.\n'
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
