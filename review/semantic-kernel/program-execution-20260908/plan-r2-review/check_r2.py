"""Bounded, read-only r2 plan checks. Prose semantics require independent review."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import subprocess
import tarfile

OUT = Path(__file__).resolve().parent
RUN = OUT.parent
ROOT = Path('/home/charl/defiformal')
M = json.loads((RUN / 'repair-candidate-r2-manifest.json').read_text())
C = Path(M['program'])
WT = Path(M['worktree'])
sha = lambda b: hashlib.sha256(b).hexdigest()
checks = []
def check(name, condition, details=None):
    checks.append({'name': name, 'pass': bool(condition), 'details': details})
def cmd(argv, cwd=WT):
    p = subprocess.run(argv, cwd=cwd, text=True, capture_output=True)
    return {'argv': argv, 'cwd': str(cwd), 'exit': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr}
def files():
    return {str(p.relative_to(C)): sha(p.read_bytes()) for p in C.rglob('*') if p.is_file()}
def archive_members(path):
    result = {}
    with tarfile.open(path) as tar:
        for m in tar.getmembers():
            if not m.isfile(): continue
            for rel in M['files']:
                if m.name == rel or m.name.endswith('/' + rel):
                    result[rel] = tar.extractfile(m).read()
    return result
before = files()
r1archive = RUN / 'repair-candidate-r1.tar.gz'
r2archive = Path(M['archive'])
archive_hashes = {str(p): sha(p.read_bytes()) for p in [r1archive, r2archive]}
check('r2_exact_archive_hash', archive_hashes[str(r2archive)] == M['archive_sha256'] == '8f03081d362cd0630a1e56822826e45ce53c97baa96bb1da6beb194e8a740e33')
check('r1_archive_preserved', archive_hashes[str(r1archive)] == 'f4162b193aa0ad2b0884c93652cc6bb4507f443ee96318d96c687199f13f35a2')
check('all15_live_files_match_manifest_before_review_checks', before == M['files'] and len(before) == 15)
r1 = archive_members(r1archive)
r2 = archive_members(r2archive)
check('all15_archive_members_match_live', len(r2) == 15 and {k: sha(v) for k,v in r2.items()} == before)
changed = sorted(k for k in r1 if r1[k] != r2[k])
check('exactly11_declared_changed_files', changed == sorted(M['changed_files']) and len(changed) == 11)
J = lambda f: json.loads((C / f).read_text())
oldindex = json.loads(r1['sprint-index.json'])
index = J('sprint-index.json')
s = {v['id']: v for v in index['sprints']}
old_s = {v['id']: v for v in oldindex['sprints']}
check('all37_sprints_and_hard_edges_preserved', len(s) == len(index['sprints']) == 37 and {k:v['dependencies'] for k,v in s.items()} == {k:v['dependencies'] for k,v in old_s.items()})
order = index['recommended_order']
check('recommended_order_unchanged_and_topological', order == oldindex['recommended_order'] and all(order.index(d) < order.index(k) for k,v in s.items() for d in v['dependencies']))
check('P17_full_reuse_gate_and_resource_bindings_unchanged', s['P17'] == old_s['P17'] and index['resource_gates'] == oldindex['resource_gates'] and all(s[f'P{i:02}']['resource_gate'] == 'P17' for i in range(21,30)))
legacy = J('legacy-task-disposition.json')['tasks']
oldlegacy = json.loads(r1['legacy-task-disposition.json'])['tasks']
projection = lambda rows: {(v['package'],v['task_id']):(v['path'],v['historically_checked']) for v in rows}
check('339_legacy_ID_path_historical_mark_tuples_preserved', len(legacy) == len(projection(legacy)) == 339 and projection(legacy) == projection(oldlegacy), {'historically_checked':sum(r['historically_checked'] for r in legacy)})
lookup = {(r['package'],r['task_id']):r for r in legacy}
oldlookup = {(r['package'],r['task_id']):r for r in oldlegacy}
owner_changes = [k for k,v in lookup.items() if (v['owner_sprint'],v['disposition']) != (oldlookup[k]['owner_sprint'],oldlookup[k]['disposition'])]
check('only_corpus5_5_changes_owner_disposition', owner_changes == [('corpus-provenance-adjudication','5.5')], owner_changes)
split = [r for r in legacy if r['disposition'] == 'split']
check('35_splits_have_owned_contributions_and_all_closer', len(split) == 35 and all(r.get('whole_task_closure') == 'all_contributions' and {v['sprint'] for v in r['contributions']} == set(r['owner_sprint'].split('+')) and all(v['scope'] and v['sprint'] in s for v in r['contributions']) for r in split))
rows = re.findall(r'^- \[([ x])\] (\d+\.\d+) (.*)$', (C/'tasks.md').read_text(), re.M)
tasks = {i: text for _,i,text in rows}
old_task_ids = re.findall(r'^- \[[ x]\] (\d+\.\d+) ', r1['tasks.md'].decode(), re.M)
check('179_unique_unchecked_tasks_same_ids_as_r1', len(rows) == len(tasks) == 179 and all(m==' ' for m,_,_ in rows) and list(tasks) == old_task_ids)
liquidity12 = lookup['concentrated-liquidity-library','1.2']
scopes12 = {v['sprint']:v['scope'] for v in liquidity12['contributions']}
check('PR1_both_scopes_require_exact_independent_planning_review', set(scopes12) == {'P16','P21'} and all(all(t in text for t in ['independent GPT-6 planning review','exact repaired','recorded verdict','requested/reported model identity','input hashes','gate accepted remains false']) for text in scopes12.values()))
check('PR1_original1_2_requires_both_accepted_scoped_outcomes', 'both applicable independently accepted planning-slice outcomes' in liquidity12['note'] and 'both applicable independently accepted planning-slice outcomes' in tasks['22.8'] and liquidity12['whole_task_closure']=='all_contributions')
check('PR1_reviews_in_actual_tasks_and_entries', all('independent GPT-6 planning review' in s[k]['entry'] for k in ['P16','P21']) and all('independent GPT-6 planning review' in tasks[k] for k in ['17.1','22.1']))
check('PR1_no_P21_wait_for_P16_implementation', s['P16']['dependencies'] == ['P15'] and 'MUST NOT wait on the `P21` residual planning review' in tasks['17.1'] and 'MUST NOT be a `P16` implementation prerequisite' in tasks['22.1'])
scopes63 = {v['sprint']:v['scope'] for v in lookup['concentrated-liquidity-library','6.3']['contributions']}
check('PR2_P16_diagnostic_plan_plus_token0_mutants', all(x in scopes63['P16'] for x in ['Token0 production mutants','diagnostic/control-plan correction','Not compiled M09 SwapMath execution','preserve the failed original plan']))
check('PR2_P21_actual_compiled_M09_with_control_exception', all(x in scopes63['P21'] for x in ['Actual compiled M09 SwapMath.computeSwapStep execution belongs here','M09 MUST exclude or replace F28','sibling named by the P16 control-plan correction','Compile failures blocked']))
check('PR2_tasks_preserve_same_separation', 'not compiled M09 SwapMath execution' in tasks['17.3'] and 'Actual compiled M09 SwapMath.computeSwapStep execution belongs to this campaign' in tasks['22.5'] and 'M09 MUST exclude or replace F28' in tasks['22.5'])
corpus55 = lookup['corpus-provenance-adjudication','5.5']
scopes55 = {v['sprint']:v['scope'] for v in corpus55['contributions']}
check('PR3_29facet_and_challenge_split_with_same_rule', set(scopes55) == {'P09','P10'} and '29 disputed-label facet records' in scopes55['P09'] and 'same reviewed rule version' in scopes55['P10'] and 'separate Liquity challenge adjudication record' in scopes55['P10'] and corpus55['whole_task_closure']=='all_contributions')
check('PR3_actual_checklists_and_index_use_split5_5', 'MUST NOT close whole original 5.5' in tasks['10.2'] and 'Whole original 5.5 closes only after' in tasks['11.1'] and all('5.5' in s[k]['legacy_mapping']['split_contributions'] for k in ['P09','P10']))
check('PR3_P09_no_complete169_or_whole5_5_exit', all('Original 7.1–8.3 and complete 169-item accounting are not this sprint\'s successful_exit.' in s['P09'][k] and 'Original 5.5 whole-task closure waits on P10' in s['P09'][k] and 'remaining 169-work dispositions' not in s['P09'][k] for k in ['exit','successful_exit']))
check('PR3_early6_1_to2_4_preserved', s['P10']['conditional_dependencies']['collect_task_2.4'] == ['P09.6.1'] and s['P09']['legacy_mapping']['sub_delivery']['original_task'] == '6.1' and tasks['11.4'] == dict((i,t) for _,i,t in re.findall(r'^- \[([ x])\] (\d+\.\d+) (.*)$',r1['tasks.md'].decode(),re.M))['11.4'])
check('PR3_join_still_requires_P09_and_P10_and169', s['P10']['conditional_dependencies']['whole_package_acceptance_7_8'] == ['P09'] and 'including complete 169-item accounting' in tasks['11.5'] and all(lookup['corpus-provenance-adjudication',i]['owner_sprint']=='P09+P10' for i in ['7.1','7.2','7.3','7.4','8.1','8.2','8.3']))
check('PR3_no_corpus_hard_cycle_or_P16_barrier', s['P09']['dependencies'] == s['P10']['dependencies'] == ['P08'] and s['P16']['dependencies'] == ['P15'])
counts = {}
new_scenarios = []
for p in C.glob('specs/*/spec.md'):
    text=p.read_text();rel=str(p.relative_to(C))
    counts[p.parent.name]=[len(re.findall(r'^### Requirement:',text,re.M)),len(re.findall(r'^#### Scenario:',text,re.M))]
    oldnames=set(re.findall(r'^#### Scenario: (.*)$',r1[rel].decode(),re.M))
    new_scenarios.extend(x for x in re.findall(r'^#### Scenario: (.*)$',text,re.M) if x not in oldnames)
check('55_requirements102_scenarios', len(counts)==6 and [sum(c[i] for c in counts.values()) for i in (0,1)] == [55,102],counts)
coverage=(C/'coverage.md').read_text()
check('all6_coverage_count_rows_match_headings', all(f'| {k} | {v[0]} | {v[1]} |' in coverage for k,v in counts.items()))
check('exactly2_new_repair_scenarios', set(new_scenarios)=={'Facet records do not close original 5.5','Compiled M09 uses the repaired control set'},new_scenarios)
check('R32_P21_contribution_matches_index', 'R32' in s['P21']['roadmap_ids'] and re.search(r'^\| R32 .*P16, P21, P30, P14',coverage,re.M))
check('no_candidate_self_acceptance', index['schema']['revision']['sets_review_gate_accepted'] is False and M['independent_acceptance'] is False)
source_hashes={}
for package in ['concentrated-liquidity-library','corpus-provenance-adjudication']:
    path=ROOT/next(r['path'] for r in legacy if r['package']==package)
    source_hashes[str(path)]=sha(path.read_bytes())
    actual={(i,m=='x') for m,i in re.findall(r'^- \[([ x])\] (\d+\.\d+)',path.read_text(),re.M)}
    mapped={(r['task_id'],r['historically_checked']) for r in legacy if r['package']==package}
    check('original_source_ID_mark_match:'+package, actual==mapped,len(actual))
before_status=cmd(['git','status','--porcelain','-uall'])
strict=cmd(['openspec','validate','reusable-verification-platform-program','--strict'])
after_status=cmd(['git','status','--porcelain','-uall'])
check('fresh_OpenSpec_strict',strict['exit']==0,strict)
check('validation_worktree_status_unchanged',before_status['stdout']==after_status['stdout'])
after=files()
check('all15_hashes_unchanged_after_checks',after==before)
check('both_archives_unchanged_after_checks',all(sha(Path(k).read_bytes())==v for k,v in archive_hashes.items()))
advisory={'R11_table_index_agreement':{'table_row':next(x for x in coverage.splitlines() if x.startswith('| R11 |')),'index_P10_roadmap_ids':s['P10']['roadmap_ids'],'agrees':'R11' in s['P10']['roadmap_ids']},'P16_entry_inverted_wording':s['P16']['entry']}
report={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Targeted PR1–PR3 planning rereview only; structural checks do not accept implementation.','manifest_sha256':sha((RUN/'repair-candidate-r2-manifest.json').read_bytes()),'archive_hashes':archive_hashes,'before_files':before,'after_files':after,'candidate_head':cmd(['git','rev-parse','HEAD']),'primary_head':cmd(['git','rev-parse','HEAD'],ROOT),'tools':[cmd(['python3','--version']),cmd(['openspec','--version'])],'source_hashes':source_hashes,'checks':checks,'pass_count':sum(c['pass'] for c in checks),'fail_count':sum(not c['pass'] for c in checks),'advisory_observations':advisory}
(OUT/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
(OUT/'openspec-strict.log').write_text(json.dumps(strict,indent=2)+'\n')
print(json.dumps({'pass':report['pass_count'],'fail':report['fail_count'],'failed':[c for c in checks if not c['pass']]},indent=2))
raise SystemExit(1 if report['fail_count'] else 0)
