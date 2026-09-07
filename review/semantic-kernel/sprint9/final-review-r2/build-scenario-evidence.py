#!/usr/bin/env python3
"""Read-only reconciliation of existing S9 evidence; writes only final-review outputs.
Missing optional completed evidence stays pending. Existing malformed evidence fails closed.
This does not execute Lean, mutations, CLI controls, regressions or native reviews.
"""
import collections
import copy
import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'review/semantic-kernel/sprint9'
OUT = Path(__file__).resolve().parent
PROOFS = BASE / 'proof-inventory-r2'
OLD = 'c880acf62944746ff9a376afc0c0050702f037f7'
CANDIDATE = 'eec499d613688137a341f3556cd80ca461dd2ee9'
BASE_HASH = 'a5cc7601606c6bfc95c6d9c0f35e1b1fc3b38636e9e398e21598e5d22b7c0dc2'
CHECKS, INPUTS, FROZEN = [], {}, {}

def check(label, condition):
    CHECKS.append({'label': label, 'passed': bool(condition)})
    if not condition:
        raise AssertionError(label)

def digest(data):
    return hashlib.sha256(data).hexdigest()

def read(path):
    path = Path(path)
    if not path.is_absolute():
        path = ROOT / path
    data = path.read_bytes()
    INPUTS[str(path.relative_to(ROOT))] = {'sha256': digest(data), 'bytes': len(data)}
    return data

def load(path):
    return json.loads(read(path))

def binding(path, expected=None):
    data = read(path)
    if expected is not None:
        check(f'hash {path}', digest(data) == expected['sha256'])
        if 'bytes' in expected:
            check(f'length {path}', len(data) == expected['bytes'])
    return INPUTS[str(Path(path).relative_to(ROOT)) if Path(path).is_absolute() else str(path)]

def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])

def frozen(path, expected=None):
    data = read(path)
    old = git('show', f'{CANDIDATE}:{path}')
    check(f'frozen bytes {path}', old == data)
    if expected is not None:
        check(f'bound source hash {path}', digest(data) == expected['sha256'])
    row = {**binding(path), 'git_blob': git('rev-parse', f'{CANDIDATE}:{path}').decode().strip()}
    if expected and 'git_blob' in expected:
        check(f'bound git object {path}', row['git_blob'] == expected['git_blob'])
    FROZEN[path] = row
    return row

def write(name, value):
    path = OUT / name
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')

def audit_lines(data):
    pairs = re.findall(r'^([^:\n]+):[ \t]*(true|false)$', data.decode(), re.M)
    check('nonempty unique comparison labels', bool(pairs) and len(dict(pairs)) == len(pairs))
    return dict(pairs)

def completed_runner(folder, kind):
    final = folder / 'final-manifest.json'
    if not final.exists():
        return {'status': 'pending', 'reason': f'Completed {kind} final-manifest.json absent.'}
    m = load(final)
    inv = m['invocation']
    check(f'{kind} candidate', m['candidate'] == CANDIDATE == inv['frozen_source'])
    check(f'{kind} complete actual command', inv['status'] == 'FINISHED' and inv['actual_exit'] == 0)
    check(f'{kind} source unchanged', all(inv['inputs_unchanged'].values()) and inv['git_head_unchanged'] and inv['git_head_after'] == CANDIDATE)
    for path, row in inv['input_bindings'].items():
        frozen(path, row)
    for row in m['raw_artifacts']:
        binding(folder / row['path'], row)
    for row in load(folder / 'artifact-inventory.json'):
        binding(folder / row['path'], row)
    cross = load(folder / 'artifact-crosscheck.json')
    check(f'{kind} artifact reconciliation', cross['candidate'] == CANDIDATE and cross['passed'])
    return {'status': 'verified_existing_execution', 'manifest': str(final.relative_to(ROOT)),
            'manifest_binding': binding(final), 'invocation': inv, 'artifact_crosscheck': cross,
            'summary': load(folder / 'summary.json'), '_manifest': m}

def main():
    check('HEAD at candidate before', git('rev-parse', 'HEAD').decode().strip() == CANDIDATE)
    basepath = BASE / 'coverage-development-r2/coverage.json'
    originalpath = BASE / 'coverage-development/coverage.json'
    original = load(originalpath)
    check('immutable original development base', digest(read(originalpath)) == BASE_HASH)
    base = load(basepath)
    check('successor development hash', digest(read(basepath)) == '56facc83f8d16a48ce2ae4c2912818b1cd029f63d1e373052827081699626814')
    fields = ('id','capability','requirement','scenario','when','then','source','line','normative_source_sha256')
    check('all55 normative claims exactly preserved', [{k:r[k] for k in fields} for r in original['scenarios']] == [{k:r[k] for k in fields} for r in base['scenarios']])
    check('55 distinct normative scenarios', len(base['scenarios']) == 55 and len({r['id'] for r in base['scenarios']}) == 55)
    task = 'openspec/changes/operational-continuation-congruence/tasks.md'
    taskrow = next(r for r in original['inputs'] if r['path'] == task)
    current = read(task)
    reconstructed = re.sub(rb'(?m)^(- )\[x\]( \d+\.\d+ )', rb'\1[ ]\2', current)
    reconstructed = re.sub(rb'(?m)^(- )\[ \]( 1\.[123] )', rb'\1[x]\2', reconstructed)
    check('reconstructed development task exact hash preimage', digest(reconstructed) == taskrow['sha256'])
    normalize = lambda data: re.sub(rb'(?m)^(- )\[[ x]\]( \d+\.\d+ )', rb'\1[ ]\2', data)
    check('only task checkbox differences', normalize(current) == normalize(reconstructed))
    oldlines, newlines = reconstructed.decode().splitlines(), current.decode().splitlines()
    changed = [{'line': i + 1, 'old': a, 'new': b} for i, (a,b) in enumerate(zip(oldlines,newlines)) if a != b]
    check('23 checked task changes from 3 to 26', len(changed) == 23 and reconstructed.count(b'- [x]') == 3 and current.count(b'- [x]') == 26)
    (OUT / 'tasks-development-reconstructed.md').write_bytes(reconstructed)
    task_equivalence = {'candidate': CANDIDATE, 'path': task, 'development_binding': taskrow,
                   'frozen_binding': frozen(task), 'reconstruction': 'Clear every frozen checked task flag, then check precisely 1.1, 1.2 and 1.3. Reconstructed bytes match the immutable development SHA256; this is not a claim of retrieving an original saved file.',
                   'reconstructed_sha256': digest(reconstructed), 'normalized_sha256': digest(normalize(current)),
                   'changed_lines': changed, 'checkbox_only': True, 'old_checked': 3, 'new_checked': 26}
    write('tasks-checkbox-equivalence.json', task_equivalence)
    original_deltas = []
    permitted = {'lean/DefiKernel/Metatheory/Examples.lean', 'lean/DefiKernel/Metatheory/Tests.lean', 'lean/DefiKernel/Metatheory/SequentialGroups.lean'}
    import difflib
    for item in original['inputs']:
        path = item['path']
        old = git('show', f'{OLD}:{path}')
        if path != task:
            check('original development source matches c880 ' + path, digest(old) == item['sha256'])
        new = read(path)
        if old != new:
            check('review-authorized successor source delta ' + path, path in permitted)
            original_deltas.append({'path':path, 'original_candidate':OLD, 'original_sha256':digest(old), 'successor_candidate':CANDIDATE, 'successor_sha256':digest(new), 'unified_diff': ''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile=OLD+'/'+path,tofile=CANDIDATE+'/'+path))})
    check('exact three reviewed source changes', {r['path'] for r in original_deltas} == permitted)
    for row in base['inputs']:
        frozen(row['path'], None if row['path'] == task else row)

    proofs = load(PROOFS / 'proof-inventory.json')
    pm = load(PROOFS / 'proof-inventory-artifacts.json')
    check('full proof inventory candidate and status', proofs['candidate'] == CANDIDATE == pm['candidate'] and pm['status'] == 'PASS')
    for path, row in pm['files'].items():
        binding(path, row)
    for path, row in proofs['source_bindings'].items():
        frozen(path, row)
    check('nonempty actual theorem and supplemental inventories', len(proofs['theorems']) == proofs['counts']['theorems'] > 0 and len(proofs['supplemental']) == proofs['counts']['supplemental'] > 0)
    check('all explicit imported and source-stable', proofs['validation']['all_explicit_source_theorems_imported'] and proofs['validation']['all_source_bytes_match_candidate_before_and_after'])
    check('full theorem and supplemental verification matches', proofs['validation']['theorem_names_modules_axioms_exactly_match_fresh_verify'] and proofs['validation']['supplemental_names_modules_axioms_exactly_match_fresh_verify'])
    for p in proofs['theorems'] + proofs['supplemental']:
        check('standard axioms ' + p['name'], set(p['axioms']) <= {'propext', 'Classical.choice', 'Quot.sound'})
        check('full statement ' + p['name'], bool(p['statement']) and '⋯' not in p['statement'])
    byname = {p['name']: p for p in proofs['theorems']}
    check('unique theorem names', len(byname) == len(proofs['theorems']))
    check('109 unchanged explicit theorem inventory', sum(p['declaration_origin'] == 'explicit' for p in proofs['theorems']) == 109)

    integ = BASE / 'integration-final-r2'
    verification = load(integ / 'verification.json')
    runs = load(integ / 'lean-runs.json')
    check('16 complete integration commands', verification['candidate'] == CANDIDATE == runs['candidate'] and len(runs['runs']) == 16 and verification['all_commands_passed'])
    integration_before, integration_after = load(integ / 'source-before.json'), load(integ / 'source-after.json')
    check('integration source manifests identical', integration_before == integration_after)
    for path, row in integration_before.items():
        frozen(path, row)
    for i, run in enumerate(runs['runs']):
        check(f'integration exit {i}', run['exit_code'] == 0)
        for row in run['logs'].values():
            binding(integ / row['path'], row)
    for row in verification['runtime_extraction_checks']:
        run = runs['runs'][row['command_index']]
        comparisons = audit_lines(read(integ / run['logs']['stdout']['path']))
        check('integration runtime count and all true ' + str(row['command_index']), len(comparisons) == row['expected'] and set(comparisons.values()) == {'true'})
    runtimepath = integ / runs['runs'][1]['logs']['stdout']['path']
    runtime = audit_lines(read(runtimepath))
    check('148 exact development runtime comparison results', runtime == base['execution']['results'] and len(runtime) == 148)

    controls = completed_runner(BASE / 'implementation/runner-controls-r2', 'controls')
    if controls['status'].startswith('verified'):
        summary = controls['summary']
        check('65 actual CLI controls', summary['git_head'] == CANDIDATE and summary['total'] == summary['passed'] == len(summary['cases']) == 65)
        planned = load(BASE / 'planning/runner-literal-adaptation-map.json')['control_inventory']['planned']
        check('65 exact accepted planned classifications', {c['name']: c['expected_exit'] for c in summary['cases']} == {c['name']: c['exit'] for c in planned})
        check('control runner and harness input hashes', summary['runner_sha256'] == controls['invocation']['input_bindings']['scripts/check_metatheory_mutations.py']['sha256'] and summary['harness_sha256'] == controls['invocation']['input_bindings']['scripts/test_metatheory_mutation_runner.py']['sha256'])
        paths = {row['original_path']: row for row in controls['_manifest']['raw_artifacts']}
        for case in summary['cases']:
            check('control actual expected exit ' + case['name'], case['passed'] and case['actual_exit'] == case['expected_exit'])
            saved = paths[case['log']]
            log = read(BASE / 'implementation/runner-controls-r2' / saved['path'])
            check('control exact CLI log ' + case['name'], digest(log) == case['log_sha256'] and log.decode() == case['cli_output'])
            binding(BASE / 'implementation/runner-controls-r2' / (case['name'] + '-spec.json'), {'sha256': case['spec_sha256']})
            for rec in case['runner_records']:
                path = BASE / 'implementation/runner-controls-r2/runs' / case['name'] / (rec['label'] + '.log')
                binding(path, {'sha256': rec['log_sha256']})
            for variant, observation in case['lean_observations'].items():
                path = BASE / 'implementation/runner-controls-r2/runs' / case['name'] / (variant + '.log')
                binding(path, {'sha256': observation['log_sha256']})
        check('65 unique controls', len({c['name'] for c in summary['cases']}) == 65)
        controls.pop('_manifest')

    production = completed_runner(BASE / 'mutations-r2', 'production')
    if production['status'].startswith('verified'):
        folder = BASE / 'mutations-r2'
        result = load(folder / 'results.json')
        spec = load(ROOT / 'mutations/metatheory.json')
        check('14 mutants and one control', len(spec['mutations']) == 14 and len(result['results']) == 15)
        source = load(folder / 'source-manifest.json')
        check('production exact source HEAD and unchanged input flags', source['git_head'] == source['git_head_after'] == CANDIDATE and all(source[k] for k in ('input_sources_unchanged', 'specification_unchanged', 'runner_unchanged', 'git_head_unchanged')))
        check('production inherited timeout explicitly 600', source['timeout_seconds_per_command'] == 600 and '--timeout-seconds' in production['invocation']['command'])
        for path, sha in source['sources'].items():
            frozen(path, {'sha256': sha})
            binding(folder / 'inputs' / path, {'sha256': sha})
            check('production before after source ' + path, source['sources_after'][path] == sha)
        binding(folder / 'mutation-spec.json', {'sha256': source['spec_sha256']})
        check('production frozen spec identity', digest(read(ROOT / 'mutations/metatheory.json')) == source['spec_sha256'])
        control = read(folder / 'control.lean')
        check('control projected source hash', digest(control) == result['results']['control']['fixture_sha256'])
        check('control actual log matches all true', audit_lines(read(folder / 'control.log')) == runtime)
        check('control contains no compiler errors', not re.search(r': error(?:\([^)]*\))?:', read(folder / 'control.log').decode()))
        check('production control 148 true', result['results']['control']['checks'] == runtime and result['results']['control']['exit'] == 0)
        for mutation in spec['mutations']:
            name = mutation['name']
            row = result['results'][name]
            actual = read(folder / f'{name}.lean')
            check('mutant projected source hash ' + name, digest(actual) == row['fixture_sha256'])
            check('single literal mutation ' + name, control.count(mutation['needle'].encode()) == 1 and actual == control.replace(mutation['needle'].encode(), mutation['replacement'].encode(), 1))
            check('exact mutant comparison inventory ' + name, set(row['checks']) == set(runtime))
            check('designated mutant false ' + name, all(row['checks'][k] == 'false' for k in mutation['required_false']))
            check('mutant protected positives ' + name, all(row['checks'][k] == 'true' for k in spec['positive_checks']))
            check('mutant actual runtime failure ' + name, row['exit'] == 1 and bool(row['false_comparisons']))
            log = read(folder / f'{name}.log').decode()
            check('mutant log comparison equality ' + name, audit_lines(log.encode()) == row['checks'])
            false = sorted(k for k, value in row['checks'].items() if value == 'false')
            errors = [line for line in log.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)]
            check('mutant exact false inventory ' + name, false == row['false_comparisons'])
            check('compiler errors receive no detection credit ' + name, len(errors) == 1 and errors[0].endswith(f'error: Metatheory runtime comparisons failed: {len(false)}'))
        for rec in result['runs']:
            binding(folder / (rec['label'] + '.log'), {'sha256': rec['log_sha256']})
        production['actual_results'] = result
        production['sibling_matrix'] = load(folder / 'sibling-matrix.json')
        check('14 actual supplemental siblings', len(production['sibling_matrix']['rows']) == 14 and all(r['measured_outcome'] == 'true' for r in production['sibling_matrix']['rows']))
        production.pop('_manifest')

    legacyfile = BASE / 'regressions/verified-outcomes.json'
    legacy = {'status': 'pending', 'reason': 'Original verified outcomes or successor relevant-dependency equivalence report absent.'}
    if legacyfile.exists() and (BASE / 'implementation/legacy-dependency-equivalence.json').exists():
        verified = load(legacyfile)
        records = load(BASE / 'regressions/regression-runs.json')
        check('legacy actual frozen candidate', verified['source_revision'] == records['source_revision'] == OLD)
        check('13 legacy suite outcomes verified', verified['all_passed'] and len(verified['outcomes']) == len(records['runs']) == 13 and all(c['passed'] for c in verified['checks']))
        check('legacy sources unchanged', records['sources_unchanged'])
        legacy_before = load(BASE / 'regressions/source-binding.json')
        legacy_after = load(BASE / 'regressions/source-binding-after.json')
        check('legacy 163 before after input bindings', legacy_before == legacy_after and len(legacy_before) == records['input_count'] == 163)
        legacy_equivalence = load(BASE / 'implementation/legacy-dependency-equivalence.json')
        check('legacy exact successor legacy_equivalence', legacy_equivalence['status'] == 'PASS' and legacy_equivalence['actual_execution_candidate'] == OLD and legacy_equivalence['revised_candidate'] == CANDIDATE and legacy_equivalence['all_relevant_inputs_equal'] and legacy_equivalence['no_rerun_required'])
        for path, sha in legacy_equivalence['input_artifacts'].items():
            binding(path, {'sha256':sha})
        check('legacy baseline binding inventory', set(legacy_equivalence['baseline_bindings']) == set(legacy_before))
        for path, b in legacy_equivalence['baseline_bindings'].items():
            old = git('show', f'{OLD}:{path}')
            new = git('show', f'{CANDIDATE}:{path}')
            check('legacy baseline old/new SHA and Git objects ' + path,
                  digest(old) == b['original']['sha256'] and digest(new) == b['revised']['sha256']
                  and git('rev-parse', f'{OLD}:{path}').decode().strip() == b['original']['git_blob']
                  and git('rev-parse', f'{CANDIDATE}:{path}').decode().strip() == b['revised']['git_blob']
                  and b['equal'] == (old == new))
        check('legacy thirteen exact suite closures', len(legacy_equivalence['suites']) == 13 and {s['label'] for s in legacy_equivalence['suites']} == {r['label'] for r in records['runs']})
        for suite in legacy_equivalence['suites']:
            check('legacy no changed relevant input ' + suite['label'], suite['relevant_inputs_equal'] and not suite['rerun_required'] and bool(suite['source_closure']))
            for path, b in suite['source_closure'].items():
                check('legacy old/new exact closure ' + suite['label'] + '/' + path, b['equal'] and b['original']['sha256'] == b['revised']['sha256'])
                frozen(path, b['revised'])
        for path, row in legacy_before.items():
            check('legacy exact original input ' + path, digest(git('show', f'{OLD}:{path}')) == row['sha256'])
            check('legacy candidate identity ' + path, row['matches_candidate'])
        for run in records['runs']:
            check('legacy actual completed command ' + run['label'], run['exit'] == 0 and run['status'] == 'complete' and run['head_at_start'] == run['head_at_end'] == OLD and run['script_unchanged'])
            for pathkey, hashkey in [('log', 'log_sha256'), ('stdout_log', 'stdout_sha256'), ('stderr_log', 'stderr_sha256')]:
                binding(BASE / 'regressions' / run[pathkey], {'sha256': run[hashkey]})
        binding(BASE / 'regressions/artifact-manifest.json', {'sha256': records['artifact_manifest_sha256']})
        manifest = load(BASE / 'regressions/artifact-manifest.json')
        for path, value in manifest.items():
            target = BASE / 'regressions' / path
            if isinstance(value, str):
                check('legacy artifact ' + path, digest(read(target)) == value)
            elif isinstance(value, dict) and 'sha256' in value:
                binding(target, value)
            else:
                check('legacy declared symlink ' + path, target.is_symlink() and str(target.readlink()) == value['symlink'])
        legacy = {'status': 'verified_existing_execution', 'verified_outcomes': verified, 'actual_runs': records,
                  'manifest_binding': binding(BASE / 'regressions/artifact-manifest.json'), 'relevant_dependency_equivalence': legacy_equivalence}

    rows = copy.deepcopy(base['scenarios'])
    for row in rows:
        row['development_status'] = row['status']
        row['development_pending_text'] = row['pending']
        row['full_proof_inventory_entries'] = []
        for t in row['theorems']:
            p = byname[t['name']]
            check('mapped theorem exact source ' + t['name'], p['source'] == t['path'] and p['source_sha256'] == t['source_sha256'])
            row['full_proof_inventory_entries'].append(p)
        for c in row['runtime_checks']:
            check('mapped actual comparison ' + c['id'], runtime[c['id']] == 'true')
            c['runtime_log'] = str(runtimepath.relative_to(ROOT))
            c['runtime_log_sha256'] = digest(read(runtimepath))
            c['execution_candidate'] = CANDIDATE
        if row['status'] == 'implemented_development_verified':
            row['status'] = 'frozen_implementation_verified'
            row['pending'] = 'Sprint-wide native acceptance and delivery remain separately pending.'
        key = row['id']
        evidence = None
        if key in ('S9-037', 'S9-038'): evidence = production
        if key in ('S9-039', 'S9-040', 'S9-041'): evidence = controls
        if key == 'S9-042': evidence = {'status': 'verified_existing_execution', 'artifact': str((PROOFS / 'proof-inventory.json').relative_to(ROOT)), 'binding': binding(PROOFS / 'proof-inventory.json'), 'counts': proofs['counts']}
        if key == 'S9-043': evidence = legacy
        if evidence:
            row['official_evidence_key'] = {'S9-037':'production', 'S9-038':'production', 'S9-039':'controls', 'S9-040':'controls', 'S9-041':'controls', 'S9-042':'proof_inventory', 'S9-043':'legacy'}[key]
            row['status'] = 'official_evidence_verified' if evidence['status'].startswith('verified') else 'pending_official_evidence'
            row['pending'] = '' if row['status'] == 'official_evidence_verified' else evidence['reason']
        if key == 'S9-043': row['integration_evidence_key'] = 'integration'
        if key == 'S9-044':
            row['status'] = 'pending_acceptance_and_delivery'
            row['pending'] = 'Actual same-candidate required native evidence verdicts, adjudication, and delivery/archive evidence must be attached by the final acceptance owner; this generator does not infer them from source audits or elapsed time.'
    check('HEAD at candidate after', git('rev-parse', 'HEAD').decode().strip() == CANDIDATE)
    for path, row in list(INPUTS.items()):
        check('input unchanged after ' + path, digest((ROOT / path).read_bytes()) == row['sha256'])
    result = {'schema_version': 1, 'kind': 'final_scenario_evidence_reconciliation', 'candidate': CANDIDATE,
              'captured_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'authorship': 'GPT-6 stock Codex harness subagent; author of financial fixtures and development coverage. This is evidence reconciliation, not independent acceptance or a fresh execution.',
              'development_base': {'path': str(basepath.relative_to(ROOT)), 'sha256': digest(read(basepath)), 'original_path': str(originalpath.relative_to(ROOT)), 'original_sha256': BASE_HASH},
              'reviewed_source_deltas': original_deltas,
              'development_to_frozen_tasks': task_equivalence, 'frozen_source_bindings': FROZEN,
              'counts': {'scenarios': 55, 'requirements': 17, 'runtime_comparisons': 148, **dict(collections.Counter(r['status'] for r in rows))},
              'evidence': {'proof_inventory': {'path': str((PROOFS / 'proof-inventory.json').relative_to(ROOT)), 'binding': binding(PROOFS / 'proof-inventory.json'), 'counts': proofs['counts'], 'scope_limits': proofs['premise_and_scope_limits']},
                           'integration': {'verification': verification, 'actual_runs': runs},
                           'controls': controls, 'production': production, 'legacy': legacy},
              'scenarios': rows, 'inputs': INPUTS,
              'limits': base['global_limits'] + ['No native acceptance or delivery claimed.', 'No old execution is relabelled as a new run. All attached actual execution records retain their measured candidate and commands.']}
    check('final task metadata exact checkbox record', result['development_to_frozen_tasks'] == json.loads((OUT / 'tasks-checkbox-equivalence.json').read_text()) and result['development_to_frozen_tasks']['path'] == task and result['development_to_frozen_tasks']['checkbox_only'] is True and result['development_to_frozen_tasks']['development_binding']['sha256'] == '344c3e352c1b8cb4acceaaa4f9d94119344d2fc0484fc51a685a17882710176b')
    if legacy['status'].startswith('verified'):
        check('final legacy metadata kept separate', result['evidence']['legacy']['relevant_dependency_equivalence']['kind'] == 'legacy-suite-relevant-dependency-equivalence' and result['evidence']['legacy']['relevant_dependency_equivalence']['actual_execution_candidate'] == OLD and result['evidence']['legacy']['relevant_dependency_equivalence']['revised_candidate'] == CANDIDATE)
    write('scenario-map.json', result)
    lines = ['# Sprint 9 final scenario evidence preparation', '',
             'This generated map preserves all 55 normative scenarios and the immutable development record. It reconciles existing execution evidence; it is not an independent audit or final acceptance.', '',
             f'Frozen candidate: `{CANDIDATE}`. Full inventory: {proofs['counts']['theorems']} theorems (109 explicit), {proofs['counts']['supplemental']} supplemental declarations. Fresh integration: 16 commands and 148 Metatheory runtime comparisons. This generator edits no source or normative input.', '',
             'The development checklist snapshot is reconstructed and verified against its original SHA256. Its only differences from frozen tasks.md are 23 checkbox advances, from 3 checked tasks to 26. The original c880 source inputs are preserved and three reviewed successor source deltas are recorded exactly. The refreshed development map binds the successor sources.', '',
             'Run `python3 review/semantic-kernel/sprint9/final-review-r2/build-scenario-evidence.py` from the repository root to refresh after completed optional reports arrive. Missing final manifests remain pending; invalid present evidence fails the generator. Native acceptance and archive/delivery closure stay pending for the parent acceptance owner.', '',
             '| Scenario | Requirement scenario | Status |', '|---|---|---|']
    lines += [f"| {r['id']} | {r['scenario']} | {r['status']} |" for r in rows]
    (OUT / 'scenario-map.md').write_text('\n'.join(lines) + '\n')
    compact = {'schema_version':1, 'kind':'compact_scenario_evidence_projection', 'candidate':CANDIDATE,
               'full_map': {'path':str((OUT/'scenario-map.json').relative_to(ROOT)), **binding(OUT/'scenario-map.json')},
               'counts':result['counts'], 'limits':result['limits'], 'authorship':result['authorship'],
               'reviewed_source_delta_bindings':[{k:r[k] for k in ('path','original_candidate','original_sha256','successor_candidate','successor_sha256')} for r in original_deltas],
               'scenarios':[]}
    for row in rows:
        c = {k:v for k,v in row.items() if k not in ('full_proof_inventory_entries','theorems','runtime_checks','declarations')}
        c['theorems'] = [{k:t[k] for k in ('name','path','line','source_sha256','evidence_class')} for t in row['theorems']]
        c['declarations'] = [{k:d[k] for k in ('name','kind','path','line','source_sha256')} for d in row['declarations']]
        c['runtime_checks'] = [{k:r[k] for k in ('id','path','line','source_sha256','actual_result','runtime_log','runtime_log_sha256','execution_candidate')} for r in row['runtime_checks']]
        compact['scenarios'].append(c)
    check('55 exact compact projection claims and statuses', len(compact['scenarios']) == 55 and all(c['id'] == r['id'] and c['status'] == r['status'] and c['then'] == r['then'] for c,r in zip(compact['scenarios'],rows)))
    write('scenario-map-review.json',compact)
    write('scenario-map-checks.json', {'candidate': CANDIDATE, 'all_passed': True, 'assertion_count': len(CHECKS), 'checks': CHECKS, 'generator': binding(Path(__file__)), 'output': binding(OUT / 'scenario-map.json')})
    print(json.dumps({'counts': result['counts'], 'assertions': len(CHECKS), 'output': str(OUT / 'scenario-map.json')}))

if __name__ == '__main__':
    main()
