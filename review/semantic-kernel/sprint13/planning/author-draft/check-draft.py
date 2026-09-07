#!/usr/bin/env python3
"""Static draft validation only; no Lean, runtime mutation, native review or implementation."""
import hashlib,json,re,subprocess
from pathlib import Path
from datetime import datetime,timezone
R=Path(__file__).resolve().parents[5];O=Path(__file__).resolve().parent;B=R/'openspec/changes/operational-active-extension'
def js(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def ck(n,v):
 checks.append({'check':n,'passed':bool(v)})
 if not v:raise AssertionError(n)
start=js(O/'preservation-before.json');head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();ck('head',head==start['head'])
for row in start['inputs']:ck('held:'+row['path'],sha(R/row['path'])==row['sha256'])
prev=R/'review/semantic-kernel/claim-reconciliation/planning/author-draft/artifact-manifest.json'
for row in js(prev)['artifacts']:ck('prior_claim_draft_stable:'+row['path'],sha(R/row['path'])==row['sha256'])
sm=js(B/'scenario-map.json');fs=js(B/'fixtures.json');ms=js(B/'planned-mutations.json');api=js(B/'api-refresh.json')
reqs=[];ids=[]
for p in sorted((B/'specs').glob('*/spec.md')):
 t=p.read_text();reqs+=re.findall(r'^### Requirement: (\w+) ',t,re.M);ids+=re.findall(r'^#### Scenario: (\w+) ',t,re.M)
ck('4cap14req39scen',len(list((B/'specs').glob('*/spec.md')))==4 and len(set(reqs))==len(reqs)==14 and len(set(ids))==len(ids)==39)
ck('scenario_map_exact',set(ids)=={r['id'] for r in sm['scenarios']})
for row in sm['scenarios']:
 ck('scenario_pending:'+row['id'],row['status']=='pending_implementation' and not row['actual_evidence'])
 ck('scenario_req:'+row['id'],row['requirement'] in reqs)
 ck('scenario_target:'+row['id'],bool(row['planned_fixtures']) or row['id'].startswith('E'))
ck('20_fixtures',[r['id'] for r in fs['fixtures']]==[f'F{i:02d}' for i in range(1,21)])
for row in fs['fixtures']:ck('fixture_pending:'+row['id'],row['status']=='planned_not_implemented' and set(row['scenarios'])<=set(ids))
ck('16_mutations',[r['id'] for r in ms['mutations']]==[f'M{i:02d}' for i in range(1,17)])
ck('mutation_labels_unique',len({r['designated_check'] for r in ms['mutations']})==16)
for row in ms['mutations']:ck('mutation_pending:'+row['id'],row['status']=='planned_not_executed' and row['fixture'] in {f['id'] for f in fs['fixtures']})
ck('two_global_positives',ms['global_positive_checks']==['extension.positive.old-transfer','extension.positive.equal-projection'])
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) ',(B/'tasks.md').read_text(),re.M);ck('25_unchecked_tasks',len(tasks)==len({i for _,i in tasks})==25 and all(s==' ' for s,_ in tasks))
ck('API_gate_blocked',not api['accepted_dependency_refresh_complete'] and not api['planning_accepted'] and not api['implementation_authorized'])
for row in api['rows']:
 if row['path']:ck('actual_API_hash:'+row['symbol'],sha(R/row['path'])==row['sha256'])
 else:ck('proposed_API_blocked:'+row['symbol'],row['status']=='blocked_missing_accepted_dependency' and row['refresh_required'])
ctx=['AGENTS.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md','roadmap.md','wiki-llm/operational-metatheory-planning-draft.md','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Atomic/Execution.lean']+[r['path'] for r in api['rows'] if r['path']]
rows=[]
for path in sorted(set(ctx)):
 p=R/path;rows.append({'path':path,'bytes':p.stat().st_size,'sha256':sha(p)})
provisional=[]
for p in sorted((O/'provisional-context').rglob('design.md')):
 live=str(p.relative_to(O/'provisional-context'));provisional.append({'path':live,'snapshot':str(p.relative_to(R)),'snapshot_sha256':sha(p),'live_sha256_at_final':sha(R/live),'classification':'observed_provisional_only_not_accepted_API','concurrent_live_change':sha(p)!=sha(R/live)})
# Live M4 evolution is expected concurrent work, not protected-input corruption.
(O/'input-manifest.json').write_text(json.dumps({'head':head,'created_utc':datetime.now(timezone.utc).isoformat(),'actual_context':rows,'provisional_context':provisional,'held_sources':'preservation-before.json','prior_claim_plan_manifest_sha256':sha(prev)},indent=2)+'\n')
p=subprocess.run(['openspec','validate','operational-active-extension','--strict'],cwd=R,text=True,capture_output=True);(O/'openspec.stdout.log').write_text(p.stdout);(O/'openspec.stderr.log').write_text(p.stderr);ck('openspec_strict',p.returncode==0)
result={'status':'AUTHOR_DRAFT_STATIC_CHECKS_PASS','official_freeze_status':'blocked_missing_accepted_dependencies','head':head,'check_count':len(checks),'counts':{'capabilities':4,'requirements':14,'scenarios':39,'tasks_unchecked':25,'fixtures_planned':20,'mutations_planned':16,'actual_API_rows':12,'provisional_refresh_rows':8,'held_S10':88,'held_corpus':93,'held_unique':len(start['inputs'])},'checks':checks,'execution_claims':{'implementation':False,'Lean_build':False,'mutations':False,'regressions':False,'native_reviews':False,'commits':False},'model_requested':'GPT-6 stock Codex harness','provider_telemetry':'unavailable','author_role':'Author of this provisional plan; not eligible as its nonauthor planning reviewer.'}
(O/'checks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'checks':len(checks),'counts':result['counts'],'provisional_context':provisional}))
