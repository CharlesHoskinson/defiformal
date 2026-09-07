#!/usr/bin/env python3
"""Read-only source/plan validation; writes only this author-draft evidence directory."""
import hashlib,json,re,subprocess
from datetime import datetime,timezone
from pathlib import Path
R=Path(__file__).resolve().parents[5]
O=Path(__file__).resolve().parent
C=R/'openspec/changes/historical-claim-reconciliation'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
checks=[]
def ck(name,ok):
 checks.append({'name':name,'passed':bool(ok)})
 if not ok:raise AssertionError(name)
before=read(O/'preservation-before.json')
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
ck('head_unchanged',head==before['head'])
for row in before['inputs']:ck('protected:'+row['path'],sha(R/row['path'])==row['sha256'])
claims=read(R/'review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json')['entries']
cm=read(C/'claim-disposition-map.json');sm=read(C/'scenario-map.json');controls=read(C/'control-inventory.json')
ck('18_claim_ids',[r['id'] for r in cm['entries']]==[f'CL{i:02d}' for i in range(1,19)])
ck('10_original_register_rows',len(cm['register_rows'])==10)
ck('register_plus_additional_preparation_covers18',set(sum([r['mapped_claim_ids'] for r in cm['register_rows']],[])) | {r['id'] for r in cm['additional_preparation_findings']} == {r['id'] for r in claims})
for old,new in zip(claims,cm['entries']):
 ck('originalsites:'+old['id'],old['sites']==new['original_sites'])
 ck('originaldisposition:'+old['id'],old['disposition']==new['original_disposition'])
 ck('originallimit:'+old['id'],old['limit']==new['limit'])
specs=sorted((C/'specs').glob('*/spec.md'));ids=[];reqs=[]
for p in specs:
 t=p.read_text();reqs+=re.findall(r'^### Requirement: (\w+) ',t,re.M);ids+=re.findall(r'^#### Scenario: (\w+) ',t,re.M)
 ck('purpose:'+str(p.relative_to(C)),'## Purpose' in t)
ck('4_capabilities',len(specs)==4)
ck('18_requirements_unique',len(reqs)==len(set(reqs))==18)
ck('45_scenarios_exact',len(ids)==len(set(ids))==45 and set(ids)=={r['id'] for r in sm['scenarios']})
for r in sm['scenarios']:
 ck('pending:'+r['id'],r['evidence_status']=='pending_implementation' and r['acceptance_evidence']==[])
 ck('requirement:'+r['id'],r['requirement'] in reqs)
 ck('claimlinks:'+r['id'],set(r['claims'])<={x['id'] for x in claims})
tasks=re.findall(r'^- \[([ x])\] ([0-9]+\.[0-9]+) ',(C/'tasks.md').read_text(),re.M)
ck('27_unchecked_unique_tasks',len(tasks)==27 and all(x==' ' for x,_ in tasks) and len({i for _,i in tasks})==27)
ck('22_planned_controls',controls['count']==len(controls['controls'])==22)
for c in controls['controls']:
 ck('control:'+c['id'],c['status']=='planned_not_executed' and c['scenario'] in ids and bool(c['successful_sibling']))
ctx=['AGENTS.md','roadmap.md','docs/research/semantic-kernel-claim-disposition.md','docs/research/semantic-kernel-progress.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','formal/v3/m5-convex.mjs','formal/v3/lib.mjs','formal/v2/tables.mjs','formal/v2/f8.mjs','viz/src/laws.ts','wiki-llm/operational-metatheory-planning-draft.md','wiki-llm/sprint-11-finite-participants-causal-outline.md','review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json','review/semantic-kernel/claim-reconciliation/preparation-r2/REPORT.md','review/semantic-kernel/claim-reconciliation/preparation-r2/r1-resolution.json','review/semantic-kernel/claim-reconciliation/preparation-r2/artifact-manifest.json','review/semantic-kernel/historical-instance-audit/REPORT.md','review/semantic-kernel/historical-instance-audit/audit.json','review/semantic-kernel/historical-instance-audit/execution.json','review/semantic-kernel/historical-instance-audit/stdout.log','review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/REPORT.md','review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/assessment.json','review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/manifest.json','review/semantic-kernel/sprint10/planning/r2-candidate.json']
ctx+= [s['path'] for c in claims for s in c['sites']]
inputs=[]
for path in sorted(set(ctx)):
 p=R/path;ck('context_exists:'+path,p.is_file());inputs.append({'path':path,'bytes':p.stat().st_size,'sha256':sha(p),'git_blob':subprocess.check_output(['git','hash-object',str(p)],cwd=R,text=True).strip()})
validation=subprocess.run(['openspec','validate','historical-claim-reconciliation','--strict'],cwd=R,capture_output=True,text=True)
(O/'openspec-validation.stdout.log').write_text(validation.stdout);(O/'openspec-validation.stderr.log').write_text(validation.stderr)
ck('openspec_strict',validation.returncode==0)
(O/'input-manifest.json').write_text(json.dumps({'kind':'author_draft_context_not_official_gate','head':head,'created_utc':datetime.now(timezone.utc).isoformat(),'inputs':inputs},indent=2)+'\n')
report={'status':'AUTHOR_DRAFT_STATIC_CHECKS_PASS_NOT_ACCEPTED','head':head,'counts':{'capabilities':4,'requirements':18,'scenarios':45,'tasks_unchecked':27,'controls_planned_not_executed':22,'original_claims':18,'original_register_rows':10,'protected_s10':88,'protected_corpus':93,'protected_unique':len(before['inputs'])},'check_count':len(checks),'checks':checks,'implementation_performed':False,'fresh_lean_or_numerical_execution':False,'native_reviews_invoked':False,'planning_accepted':False,'model_requested':'GPT-6 stock Codex harness','provider_telemetry':'unavailable','author_disclosure':'Author of this new normative draft and portions of historical audit/corpus research; not eligible as its nonauthor planning reviewer.','openspec_exit':validation.returncode,'graphify_navigation':'Existing814-node index query was truncated and returned neighboring historical solver nodes; no mathematical claim uses graph output. No graph rebuild/model invocation; no model token usage reported.'}
(O/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'checks':len(checks),'counts':report['counts'],'head':head}))
