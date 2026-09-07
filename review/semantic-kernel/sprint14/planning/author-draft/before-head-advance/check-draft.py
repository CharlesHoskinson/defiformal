#!/usr/bin/env python3
"""Static author-draft checker; does not run Lean, financial tests, mutants or reviewers."""
import hashlib,json,re,subprocess
from pathlib import Path
from datetime import datetime,timezone
R=Path(__file__).resolve().parents[5];O=Path(__file__).resolve().parent;B=R/'openspec/changes/atomic-metatheory-transfer'
def js(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def ck(n,v):
 checks.append({'name':n,'passed':bool(v)})
 if not v:raise AssertionError(n)
initial=js(O/'preservation-before.json');head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();ck('actual_start_end_HEAD_equal',head==initial['head'])
for row in initial['inputs']:ck('held:'+row['path'],sha(R/row['path'])==row['sha256'])
prior=R/'review/semantic-kernel/sprint13/planning/author-draft/artifact-manifest.json'
for row in js(prior)['artifacts']:ck('sealed_M5:'+row['path'],sha(R/row['path'])==row['sha256'])
sm=js(B/'scenario-map.json');fs=js(B/'fixtures.json');ms=js(B/'planned-mutations.json');api=js(B/'api-refresh.json');reqs=[];ids=[]
for p in sorted((B/'specs').glob('*/spec.md')):
 txt=p.read_text();reqs+=re.findall(r'^### Requirement: (\w+) ',txt,re.M);ids+=re.findall(r'^#### Scenario: (\w+) ',txt,re.M)
ck('4cap14req37scenario',len(list((B/'specs').glob('*/spec.md')))==4 and len(reqs)==len(set(reqs))==14 and len(ids)==len(set(ids))==37)
ck('scenario_map_exact',set(ids)=={r['id'] for r in sm['scenarios']})
for r in sm['scenarios']:
 ck('scenario_pending:'+r['id'],r['status']=='pending_implementation' and not r['actual_evidence'])
 ck('scenario_requirement:'+r['id'],r['requirement'] in reqs)
 ck('scenario_fixtures_exist:'+r['id'],set(r['planned_fixtures'])<={f['id'] for f in fs['fixtures']})
ck('20_fixtures',[f['id'] for f in fs['fixtures']]==[f'F{i:02d}' for i in range(1,21)])
for f in fs['fixtures']:ck('fixture_pending:'+f['id'],f['status']=='planned_not_implemented' and set(f['scenarios'])<=set(ids))
ck('18_mutations',[m['id'] for m in ms['mutations']]==[f'M{i:02d}' for i in range(1,19)])
ck('unique_mutation_labels',len({m['designated_check'] for m in ms['mutations']})==18)
for m in ms['mutations']:ck('mutation_pending:'+m['id'],m['status']=='planned_not_executed' and m['fixture'] in {f['id'] for f in fs['fixtures']})
ck('two_nonempty_positive_contracts',len(ms['global_positive_checks'])==2)
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) ',(B/'tasks.md').read_text(),re.M);ck('25_unchecked_tasks',len(tasks)==len({n for _,n in tasks})==25 and all(s==' ' for s,_ in tasks))
ck('refresh_gate_blocked',api['status']=='BLOCKED_BEFORE_OFFICIAL_FREEZE' and not api['accepted_refresh_complete'] and not api['planning_accepted'] and not api['implementation_authorized'])
for r in api['rows']:
 if r['path']:ck('actual_API_binding:'+r['symbol'],sha(R/r['path'])==r['sha256'])
 else:ck('provisional_API_blocked:'+r['symbol'],r['status']=='blocked_missing_accepted_dependency')
context=['AGENTS.md','roadmap.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md','wiki-llm/operational-metatheory-planning-draft.md','lean/DefiKernel/Atomic/InvariantFixtures.lean','lean/DefiKernel/Atomic/PolicyProofs.lean','lean/DefiKernel/Atomic/Admission.lean','lean/DefiKernel/Atomic/Preservation.lean']+[r['path'] for r in api['rows'] if r['path']]
inputs=[{'path':p,'bytes':(R/p).stat().st_size,'sha256':sha(R/p)} for p in sorted(set(context))]
provisional=[]
for p in sorted((O/'provisional-context').rglob('design.md')):
 live=str(p.relative_to(O/'provisional-context'));provisional.append({'path':live,'snapshot':str(p.relative_to(R)),'snapshot_sha256':sha(p),'live_sha256_at_final':sha(R/live),'concurrent_live_change':sha(p)!=sha(R/live),'status':'provisional_not_accepted_dependency'})
(O/'input-manifest.json').write_text(json.dumps({'head':head,'created_utc':datetime.now(timezone.utc).isoformat(),'actual_context':inputs,'provisional_context':provisional,'sealed_M5_manifest_sha256':sha(prior),'source_identity_limit':'Actual start/end HEAD records are distinct from historical accepted source/review candidates.'},indent=2)+'\n')
v=subprocess.run(['openspec','validate','atomic-metatheory-transfer','--strict'],cwd=R,text=True,capture_output=True);(O/'openspec.stdout.log').write_text(v.stdout);(O/'openspec.stderr.log').write_text(v.stderr);ck('openspec_strict',v.returncode==0)
d={'status':'AUTHOR_DRAFT_STATIC_CHECKS_PASS','actual_start_HEAD':initial['head'],'actual_end_HEAD':head,'official_freeze_status':'blocked_missing_accepted_dependencies','counts':{'capabilities':4,'requirements':14,'scenarios':37,'tasks_unchecked':25,'fixtures_planned':20,'mutations_planned':18,'existing_API_rows':9,'future_refresh_rows':5,'held_S10':88,'held_corpus':93,'held_unique':len(initial['inputs'])},'check_count':len(checks),'checks':checks,'implementation':False,'fresh_Lean_runtime_mutation_or_native_execution':False,'commits':False,'model_requested':'GPT-6 stock Codex harness','provider_telemetry':'unavailable','authorship':'Author of this draft, not eligible as its nonauthor planning reviewer.'}
(O/'checks.json').write_text(json.dumps(d,indent=2)+'\n');print(json.dumps({'checks':len(checks),'start_HEAD':initial['head'],'end_HEAD':head,'counts':d['counts']}))
