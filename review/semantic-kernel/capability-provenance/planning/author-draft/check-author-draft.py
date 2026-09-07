#!/usr/bin/env python3
"""Read-only author readiness checks; outputs are new planning evidence, never proof acceptance."""
import datetime,hashlib,json,pathlib,re,subprocess
H=pathlib.Path(__file__).resolve().parent;R=H.parents[4];C=R/'openspec/changes/capability-provenance-isolation'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(*a):
 p=subprocess.run(['git',*a],cwd=R,text=True,capture_output=True);return p.stdout.strip() if p.returncode==0 else None
def dump(name,obj):
 with (H/name).open('x') as f:json.dump(obj,f,indent=2);f.write('\n')
checks=[]
def check(n,v):
 checks.append({'name':n,'passed':bool(v)})
 if not v:raise AssertionError(n)
old=json.loads((H/'protected-before.json').read_text());current=git('rev-parse','HEAD')
for r in old['files']:
 p=R/r['path'];check('protected bytes '+r['path'],p.stat().st_size==r['bytes'] and sha(p)==r['sha256']);check('protected old Git '+r['path'],git('rev-parse',old['head']+':'+r['path'])==r['git_blob_at_head'])
for mp,count in old['input_set_counts'].items():
 x=json.loads((R/mp).read_text());check('held manifest count '+mp,len(x['inputs'])==count)
 for y in x['inputs']:check('held candidate sha '+y['path'],sha(R/y['path'])==y['sha256'])
specs=sorted((C/'specs').glob('*/spec.md'));sc=[];reqs=[]
for p in specs:
 lines=p.read_text().splitlines();req=None
 for n,l in enumerate(lines,1):
  if l.startswith('### Requirement: '):req=l.split(': ',1)[1];reqs.append({'capability':p.parent.name,'title':req,'path':str(p.relative_to(R)),'line':n})
  if l.startswith('#### Scenario: '):
   title=l.split(': ',1)[1];sid=title.split()[0];body=lines[n:n+3];check('scenario GIVEN WHEN THEN '+sid,len(body)==3 and body[0].startswith('- **GIVEN**') and body[1].startswith('- **WHEN**') and body[2].startswith('- **THEN**'))
   sc.append({'id':sid,'title':title,'requirement':req,'capability':p.parent.name,'path':str(p.relative_to(R)),'line':n,'status':'planned_unimplemented_no_evidence','evidence_hash':None})
check('3 capabilities',len(specs)==3);check('15 requirements',len(reqs)==15);check('45 unique scenarios',len(sc)==len({x['id'] for x in sc})==45)
tasks=(C/'tasks.md').read_text();rows=re.findall(r'^- \[ \] (\d+\.\d+) (.+)$',tasks,re.M);check('27 unique unchecked tasks',len(rows)==len({n for n,_ in rows})==27 and '[x]' not in tasks.lower());check('every task has verification',all('Verification:' in s for _,s in rows))
design=(C/'design.md').read_text();check('20 fixture families',len(re.findall(r'^\| F\d\d \|',design,re.M))==20);check('14 mutation definitions',len(re.findall(r'^\| M\d\d \|',design,re.M))==14);check('all65 controls stated','65 actual inherited CLI controls' in design or '65 actual CLI controls' in design)
check('no new Lean implementation',(R/'lean/DefiKernel/CapabilityProvenance').exists() is False);check('no native review claim','author draft' in design.lower() and 'not implementation or planning acceptance' in design)
api={
'lean/DefiKernel/Typed/Authority.lean':['Grant','Capability','CapabilityStore','issueCapability','revokeCapability','authorizesId','hasAuthority','issueCapability_ok_iff','issueCapability_fresh','issueCapability_preserves_other','revokeCapability_tombstone','revokeCapability_preserves_other','authorizesId_iff','issueCapability_keeps_revoked'],
'lean/DefiKernel/Typed/Transition.lean':['registryAuthorityConfig','Template.requiredStateReads','execute_preserves_capabilities','execute_invocation_authority','execute_debit_authority','execute_supply_authority'],
'lean/DefiKernel/Composition/Execution.lean':['executeStep','StepSound','StepSound.authorized','StepSound.component_locality','StepSound.invoke_preserves_capabilities','ReceiptAuthorized'],
'lean/DefiKernel/Composition/Sequence.lean':['startCursor','advance','TraceSound','run_trace_sound','continueRun_failed','run_refusal_sound'],
'lean/DefiKernel/Composition/Contracts.lean':['AgreeOn','Supports','supported_frame'],
'lean/DefiKernel/Composition/Interfaces.lean':['Component.canRead','Component.canWrite','validateCatalog','checkAccess','resolveSource','snapshots'],
'lean/DefiKernel/Parallel/Compatibility.lean':['Branch'],
'lean/DefiKernel/Parallel/Preservation.lean':['trace_invoke_stores'],
'lean/DefiKernel/Interleaving/Preservation.lean':['runPrefix_store'],
'lean/DefiKernel/Metatheory/SequentialGroups.lean':['runGroup_eq_continueRun'],
'lean/DefiKernel/Metatheory/Observation.lean':['CursorEquivalent','cursorEq']}
refs=[]
for p,names in api.items():
 text=(R/p).read_text()
 for name in names:
  matches=list(re.finditer(r'^(?:def|theorem|structure|inductive|abbrev) '+re.escape(name)+r'(?=\s|\()',text,re.M));check('existing API '+name+' '+p,len(matches)==1);m=matches[0];refs.append({'path':p,'declaration':name,'line':text[:m.start()].count('\n')+1,'source_sha256':sha(R/p),'git_blob_at_author_head':git('rev-parse',current+':'+p),'status':'existing_inspected_API_not_new_claim'})
# Explicit semantic group mapping, not title-keyword similarity.
groups=[('P',1,3,['2.1'],['F01','F02','F11'],'Origins/Trace: trusted roots and initialized trace'),('P',4,6,['2.2'],['F02','F03','F04'],'Trace: causal origins and grant scope'),('P',7,9,['2.3','2.4'],['F05'],'Trace: lifetime/count induction'),('P',10,12,['2.4','2.5'],['F08','F09','F10'],'Trace: current pre-store authority'),('P',13,15,['2.6'],['F06','F07'],'Trace: exact refusal prefix'),('P',16,18,['3.1','3.2'],['F01','F02','F04','F09','F18'],'Origins: read-only query iff and delegation'),('I',1,3,['4.1','4.2'],['F14','F17'],'Observation: explicit policy and exact equality'),('I',4,6,['4.3'],['F13','F14','F15'],'Isolation: actual-effect frame'),('I',7,9,['4.4'],['F16'],'Isolation: direct private access and owner positive'),('I',10,12,['4.5'],['F12','F15','F16'],'Examples: disclosure/missing-premise counterexamples'),('I',13,15,['4.6'],['F19','F20'],'Trace/Isolation: bounded operator applicability'),('E',1,3,['5.1'],[f'F{i:02}' for i in range(1,21)],'Tests/Audit: full independent observations'),('E',4,6,['5.2','6.3'],[f'M{i:02}' for i in range(1,15)],'Actual new query/observer mutation evidence'),('E',7,9,['5.3','6.3','6.4'],['65 actual inherited CLI cases'],'Source closure/bindings/defensive controls'),('E',10,12,['1.1','1.2','6.2','6.5','6.6','6.7'],[],'Independent planning/source/evidence/delivery gates')]
for s in sc:
 prefix=s['id'][0];n=int(s['id'][1:]);matches=[g for g in groups if g[0]==prefix and g[1]<=n<=g[2]];check('single scenario mapping '+s['id'],len(matches)==1);g=matches[0];s.update(tasks=g[3],planned_fixtures_or_controls=g[4],planned_evidence=g[5]);check('mapped task exists '+s['id'],all(t in dict(rows) for t in g[3]))
validation=json.loads((H/'strict-validation.json').read_text());check('strict OpenSpec validation',validation['summary']['totals']['failed']==0 and validation['summary']['totals']['passed']==1)
outputs=[p for p in C.rglob('*') if p.is_file()]+[R/'wiki-llm/capability-provenance-isolation-plan.md'];sources=[R/p for p in api]
dump('source-api-map.json',{'status':'author-inspected existing APIs; planned theorems not implemented','declarations':refs});dump('scenario-map.json',{'status':'all45 pending implementation and package gate','requirements':reqs,'scenarios':sc});dump('context-files.json',{'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':current,'existing_sources':[{'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size} for p in sources],'normative_and_wiki_outputs':[{'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size} for p in outputs],'future_refresh_required':'Freeze all actual imports, drivers, proposed needles and accepted dependency/held-gate status again before independent planning review.'})
r={'status':'PASS_AUTHOR_DRAFT_ONLY','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head_before':old['head'],'head_after':current,'head_changed':old['head']!=current,'all_protected_bytes_unchanged':True,'protected_file_count':len(old['files']),'held_input_counts':old['input_set_counts'],'counts':{'capabilities':3,'requirements':15,'scenarios':45,'unchecked_tasks':27,'fixture_families':20,'planned_mutants':14,'inherited_cli_cases':65,'existing_API_references':len(refs)},'checks_passed':len(checks),'checks':checks,'source_implementation':False,'native_reviews_invoked':False,'planning_accepted':False,'author_is_original_corpus_plan_author':True,'requires_nonauthor_review':True,'helper_sha256':sha(pathlib.Path(__file__))};dump('readiness-checks.json',r);print(json.dumps({k:v for k,v in r.items() if k!='checks'},indent=2))
