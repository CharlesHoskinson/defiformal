#!/usr/bin/env python3
"""Reconcile reviewed evidence without changing historical captures or Lean source."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT/'review/semantic-kernel/sprint10'
OUT = BASE/'acceptance'
OLD = 'eec499d613688137a341f3556cd80ca461dd2ee9'
NEW = 'b165bc586080d668f689fbc18dfa09eb8739d688'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return json.loads(path.read_text())
def git(*args): return subprocess.check_output(['git', *args], cwd=ROOT)
def save(name, value): (OUT/name).write_text(json.dumps(value, indent=2)+'\n')
manifest = read(BASE/'native-review-r1/candidate.json')
assert sha((BASE/'native-review-r1/bundle.md').read_bytes()) == manifest['bundle_sha256']
for row in manifest['inputs']:
    assert sha((ROOT/row['path']).read_bytes()) == row['sha256'], row['path']
reviews = []
for provider in ['grok', 'fable']:
    path = BASE/f'native-review-r1/review-{provider}.invocation.json'
    meta = read(path)
    assert meta['exit_code'] == 0 and not meta['is_error']
    assert meta['inputs_unchanged'] and meta['bundle_unchanged']
    assert meta['bundle_sha256'] == manifest['bundle_sha256']
    report = BASE/f'native-review-r1/review-{provider}.md'
    assert 'VERDICT: ACCEPT WITH LIMITATIONS' in report.read_text()
    reviews.append({'provider': provider, 'requested_model': meta['requested_model'],
        'reported_models': meta['reported_models'], 'effort': 'medium',
        'report': str(report.relative_to(ROOT)), 'report_sha256': sha(report.read_bytes()),
        'invocation_sha256': sha(path.read_bytes()), 'verdict': 'ACCEPT WITH LIMITATIONS'})
sibling = read(BASE/'mutations-r1/sibling-matrix.json')
results = read(BASE/'mutations-r1/results.json')['results']
for row in sibling['rows']:
    assert row['measured_outcome'] == results[row['name']]['checks'][row['sibling']] == 'true'
    row['historical_status'] = row['status']
    row['status'] = 'ACTUAL_SOURCE_BOUND_EXECUTION_MEASURED_AND_RECONCILED'
sibling['original_record'] = {'path': 'review/semantic-kernel/sprint10/mutations-r1/sibling-matrix.json',
    'sha256': sha((BASE/'mutations-r1/sibling-matrix.json').read_bytes())}
sibling['record_correction_only'] = True
save('sibling-matrix.json', sibling)
prior = ROOT/'review/semantic-kernel/sprint9'
mut = read(prior/'mutations-r2/source-manifest.json')
inv = read(prior/'mutations-r2/invocation.json')
controls = read(prior/'implementation/runner-controls-r2/summary.json')
assert mut['git_head'] == controls['git_head'] == inv['frozen_source'] == OLD
assert mut['input_sources_unchanged'] and inv['actual_exit'] == 0
assert controls['total'] == controls['passed'] == 65
paths = set(mut['sources']) | set(inv['input_bindings'])
bindings = {}
for path in sorted(paths):
    old = git('show', f'{OLD}:{path}'); new = git('show', f'{NEW}:{path}')
    assert old == new == (ROOT/path).read_bytes(), path
    expected = mut['sources'].get(path, inv['input_bindings'].get(path, {}).get('sha256'))
    assert sha(old) == expected
    bindings[path] = {'sha256': sha(old), 'bytes': len(old),
        'original_git_blob': git('rev-parse', f'{OLD}:{path}').decode().strip(),
        'candidate_git_blob': git('rev-parse', f'{NEW}:{path}').decode().strip(), 'equal': True}
lean = Path(subprocess.check_output(['elan', 'which', 'lean'], cwd=ROOT/'lean', text=True).strip())
assert sha(lean.read_bytes()) == mut['lean_executable_sha256'] == controls['lean_executable_sha256']
legacy_tools = read(BASE/'implementation/legacy-dependency-equivalence.json')['tools']
for item in legacy_tools.values(): assert sha(Path(item['path']).read_bytes()) == item['sha256']
save('sprint9-regression-carry.json', {
    'status': 'PASS', 'actual_execution_candidate': OLD, 'interface_candidate': NEW,
    'mutations': 14, 'controls': 65, 'not_new_executions': True,
    'source_bindings': bindings, 'lean_binary': {'path': str(lean), 'sha256': sha(lean.read_bytes())},
    'additional_tool_identity': legacy_tools,
    'rationale': 'Actual production transitive closure plus both drivers, mutation specification and three pinned Lake files are byte-identical. The synthetic control fixture bodies are defined by the unchanged harness. Root DefiKernel.lean is outside both closures.',
    'evidence': {str(path.relative_to(ROOT)): sha(path.read_bytes()) for path in [
        prior/'mutations-r2/source-manifest.json', prior/'mutations-r2/invocation.json',
        prior/'mutations-r2/artifact-crosscheck.json',
        prior/'implementation/runner-controls-r2/summary.json',
        prior/'implementation/runner-controls-r2/artifact-crosscheck.json']}})
save('review-disposition.json', {
    'candidate': NEW, 'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'bundle_sha256': manifest['bundle_sha256'], 'inputs_rechecked': len(manifest['inputs']),
    'reviews': reviews, 'status': 'ACCEPTED_WITH_LIMITATIONS_DELIVERY_PENDING',
    'required_findings': [
        {'id': 'FABLE-1', 'resolution': 'Corrected current sibling status in acceptance/sibling-matrix.json; original reviewed record preserved.'},
        {'id': 'FABLE-2', 'resolution': 'Explicit actual-eec499d Metatheory14/65 carry in acceptance/sprint9-regression-carry.json, checked against actual source manifest, harness, spec, Git objects and Lean binary.'},
        {'id': 'FABLE-3', 'resolution': 'EVIDENCE.md documents interface.catalog.private-total and interface.catalog.valid as an intentional same-expression alias; 99 labels are not99 independent semantic cases.'}],
    'source_changed': False, 'measurement_changed': False,
    'limits': ['Incremental Lake build, not from-clean proof rebuild.',
        'Local rules require initialization and explicit inductive premises; total preservation requires confinement, neutrality, value support and write exclusion.',
        'Success algebra does not preserve ordered diagnostic payloads.',
        'Query mutation detection is not executor mutation or unique fault identification.',
        'Exact rational model, trusted configuration/store/boundary; no deployed fidelity, untouched cases, liveness or unconditional solvency.'],
    'archive_and_delivery': 'pending actual actions'})
print('PASS native input integrity,14 siblings,Sprint9 exact relevant carry and3 record dispositions')
