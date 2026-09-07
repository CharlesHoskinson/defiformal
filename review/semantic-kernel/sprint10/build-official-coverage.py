#!/usr/bin/env python3
"""Bind the preserved author map to measured frozen evidence; no acceptance inference."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / 'review/semantic-kernel/sprint10'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return json.loads(path.read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(BASE)
    paths = {
        'author_map': BASE / 'coverage-draft-r1/scenario-map.json',
        'proof_inventory': BASE / 'proof-inventory-r1/proof-inventory.json',
        'integration': BASE / 'integration-r1/lean-runs.json',
        'integration_verification': BASE / 'integration-r1/verification.json',
        'legacy_equivalence': BASE / 'implementation/legacy-dependency-equivalence.json',
        'mutations': BASE / 'mutations-r1/results.json',
        'mutation_summary': BASE / 'mutations-r1/summary.json',
        'mutation_crosscheck': BASE / 'mutations-r1/artifact-crosscheck.json',
        'siblings': BASE / 'mutations-r1/sibling-matrix.json',
        'controls': BASE / 'implementation/runner-controls-r1/summary.json',
        'control_crosscheck': BASE / 'implementation/runner-controls-r1/artifact-crosscheck.json',
    }
    inputs = {key: read(path) for key, path in paths.items()}
    bindings = {key: {'path': str(path.relative_to(ROOT)), 'sha256': sha(path.read_bytes()),
                      'bytes': path.stat().st_size} for key, path in paths.items()}
    candidate = inputs['proof_inventory']['candidate']
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == candidate
    for key in ['integration', 'mutation_summary', 'mutation_crosscheck', 'siblings', 'control_crosscheck']:
        assert inputs[key]['candidate'] == candidate
    assert inputs['controls']['git_head'] == candidate
    assert inputs['mutation_crosscheck']['passed'] and inputs['control_crosscheck']['passed']
    proofs = inputs['proof_inventory']
    assert proofs['execution']['status'] == 'PASS' and proofs['validation']['forbidden_axioms'] == 0
    for binding in inputs['author_map']['source_bindings'] + inputs['author_map']['spec_bindings']:
        raw = (ROOT / binding['path']).read_bytes()
        assert sha(raw) == binding['sha256']
        assert raw == subprocess.check_output(['git', 'show', f"{candidate}:{binding['path']}"], cwd=ROOT)
    legacy = inputs['legacy_equivalence']
    assert legacy['status'] == 'PASS' and legacy['all_relevant_inputs_equal']
    assert legacy['revised_candidate'] == candidate and legacy['original_suite_count'] == 13
    assert inputs['integration_verification']['source_unchanged']
    predecessor = 'eec499d613688137a341f3556cd80ca461dd2ee9'
    old_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', predecessor, '--', 'lean', 'scripts', 'corpus'], cwd=ROOT, text=True).splitlines()
    preserved = []
    for path in old_paths:
        old = subprocess.check_output(['git', 'show', f'{predecessor}:{path}'], cwd=ROOT)
        new = subprocess.check_output(['git', 'show', f'{candidate}:{path}'], cwd=ROOT)
        equal = old == new
        if path == 'lean/DefiKernel.lean':
            assert new.replace(b'import DefiKernel.Interface.Verify\n', b'', 1) == old
        else:
            assert equal, path
        preserved.append({'path': path, 'predecessor_sha256': sha(old), 'candidate_sha256': sha(new), 'equal': equal, 'allowed_change': 'single Interface.Verify import' if not equal else None})
    declarations = {r['name']: r for r in proofs['theorems'] + proofs['supplemental']}
    control = inputs['mutations']['results']['control']
    assert len(control['checks']) == 99 and set(control['checks'].values()) == {'true'}
    assert len(inputs['mutation_summary']['mutants']) == 14
    assert inputs['controls']['total'] == inputs['controls']['passed'] == 65
    integration = inputs['integration']
    assert len(integration['runs']) == 18
    for run in integration['runs']:
        assert run['exit_code'] == 0 and not run['timed_out']
        for log in run['logs'].values():
            assert sha((paths['integration'].parent / log['path']).read_bytes()) == log['sha256']
    audit_runs = [r for r in integration['runs'] if r['argv'][-1] == 'DefiKernel/Interface/Audit.lean']
    assert len(audit_runs) == 1
    log = audit_runs[0]['logs']['stdout']
    observed = re.findall(r'^(interface\.[a-z0-9_.-]+): (true|false)$',
                          (paths['integration'].parent / log['path']).read_text(), re.M)
    assert len(observed) == len(dict(observed)) == 99 and dict(observed) == control['checks']
    mutant_rows = {f'M{i:02}': row for i, row in enumerate(inputs['mutation_summary']['mutants'], 1)}
    siblings = {row['id']: row for row in inputs['siblings']['rows']}
    rows = deepcopy(inputs['author_map']['rows'])
    for row in rows:
        assert not row['missing_source_refs']
        row['compiled_declarations'] = []
        for ref in row['proof_source_refs']:
            declaration = declarations[ref['name']]
            row['compiled_declarations'].append({'name': ref['name'], 'module': declaration['module'],
                'statement': declaration['statement'], 'axioms': declaration['axioms'],
                'category': declaration.get('category', 'supplemental'),
                'source_category': ref['category'], 'inventory': bindings['proof_inventory']})
        for ref in row['runtime_refs']:
            assert control['checks'][ref['name']] == 'true'
            ref['official_frozen_evidence'] = {'candidate': candidate, 'observed': 'true',
                'inventory': bindings['mutations'], 'fresh_audit': bindings['integration']}
        row['measured_mutations'] = [{**mutant_rows[mid], 'id': mid,
            'sibling': siblings[mid]['sibling'], 'sibling_observed': siblings[mid]['measured_outcome'],
            'source': bindings['mutation_summary']} for mid in row['mutants']]
        row['pending_evidence'] = ['native_final_reviews', 'delivery']
        row['status'] = 'MEASURED_IMPLEMENTATION_EVIDENCE_NOT_FINAL_ACCEPTANCE'
        if row['id'] in ['RE05', 'RE06', 'RE07']:
            row['actual_cli_control_evidence'] = bindings['controls']
        if row['id'] == 'RE08':
            row['complete_proof_inventory'] = bindings['proof_inventory']
        if row['id'] == 'RE09':
            row['legacy_regression_evidence'] = {'binding': bindings['legacy_equivalence'], 'actual_execution_candidate': legacy['actual_execution_candidate'], 'revised_candidate': candidate, 'suites': 13, 'fresh_rerun_claimed': False}
        if row['id'] == 'RE10':
            row['protected_source_preservation'] = {'predecessor': predecessor, 'candidate': candidate, 'files': len(preserved), 'allowed_change': 'single Interface.Verify root import', 'record': 'preservation.json'}
        # Keep initial notes immutable in their source artifact, not stale present-tense statements.
        row['author_snapshot_notes'] = row.pop('notes')
    result = {'kind': 'immutable_measured_scenario_coverage', 'candidate': candidate,
        'utc': datetime.now(timezone.utc).isoformat(), 'input_bindings': bindings,
        'builder_sha256': sha(Path(__file__).read_bytes()), 'scenario_count': len(rows),
        'evidence_counts': {'runtime': 99, 'mutants': 14, 'cli_controls': 65,
            'integration_commands': 18, 'proofs': proofs['counts']},
        'scope': 'Author evidence reconciliation. Generic proofs, finite instances, counterexamples, '
            'runtime comparisons and synthetic CLI controls retain distinct categories. '
            'Native source/evidence acceptance and delivery remain pending.', 'rows': rows}
    assert len(rows) == len({r['id'] for r in rows}) == 57
    out.mkdir(parents=True)
    (out / 'preservation.json').write_text(json.dumps({'predecessor': predecessor, 'candidate': candidate, 'files': preserved}, indent=2)+'\n')
    (out / 'scenario-map.json').write_text(json.dumps(result, indent=2)+'\n')
    report = '# Sprint10 measured scenario coverage\n\n'
    report += f'Frozen source `{candidate}` has 57 mapped scenarios, 99 passing runtime comparisons, '
    report += '14 compiling discriminated mutations, 65 passing CLI controls and 18 passing integration commands. '
    report += f"The imported inventory contains {proofs['counts']['theorems']} theorems and {proofs['counts']['supplemental']} supplemental declarations; forbidden axioms: 0.\n\n"
    report += 'This is author evidence reconciliation. Thirteen legacy suites retain their actual historical execution revision with exact relevant dependency equivalence. All tracked predecessor Lean, scripts and corpus files are unchanged except the authorized root import. Native final review and delivery remain pending. The initial source map is preserved unchanged.\n\n'
    report += '| Scenario | Compiled declarations | Runtime observations | Mutations |\n|---|---:|---:|---:|\n'
    for row in rows:
        report += f"| {row['id']} {row['title']} | {len(row['compiled_declarations'])} | {len(row['runtime_refs'])} | {len(row['measured_mutations'])} |\n"
    (out / 'coverage.md').write_text(report)
    manifest = [{'path': p.name, 'sha256': sha(p.read_bytes()), 'bytes': p.stat().st_size}
                for p in sorted(out.iterdir())]
    (out / 'artifact-inventory.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps({'status': 'MEASURED_NOT_FINAL_ACCEPTANCE', 'rows': len(rows), 'out': str(out)}))


if __name__ == '__main__':
    main()
