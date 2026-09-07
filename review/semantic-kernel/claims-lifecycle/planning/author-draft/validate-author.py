from pathlib import Path
import hashlib,json,re,subprocess,datetime,time,shutil,sys
R=Path('/home/charl/defiformal');O=Path(__file__).resolve().parent;C=R/'openspec/changes/claims-liability-lifecycle';sha=lambda b:hashlib.sha256(b).hexdigest();checks=[]
def ck(n,v):checks.append({'check':n,'passed':bool(v)})
def write(n,v):(O/n).write_text(json.dumps(v,indent=2)+'\n')
sp=sorted((C/'specs').glob('*/spec.md'));req=[];sc=[]
for p in sp:
 t=p.read_text();req+=re.findall(r'^### Requirement: (\S+)',t,re.M);sc+=re.findall(r'^#### Scenario: (\S+)',t,re.M)
tasks=re.findall(r'^- \[ \] (\d+\.\d+)',(C/'tasks.md').read_text(),re.M);f=json.loads((O/'fixtures.json').read_text());m=json.loads((O/'planned-mutations.json').read_text());sm=json.loads((O/'scenario-map.json').read_text())
counts=dict(zip(['capabilities','requirements','scenarios','unchecked_tasks','fixtures','mutants'],map(len,[sp,req,sc,tasks,f['fixtures'],m['mutants']])));ck('exact scope',list(counts.values())==[5,18,41,30,24,20])
for name,ids in [('req',req),('scenario',sc),('task',tasks),('fixture',[x['id'] for x in f['fixtures']]),('mutant',[x['id'] for x in m['mutants']])]:ck(name+' unique nonempty',bool(ids) and len(set(ids))==len(ids))
ck('no checked task',not re.search(r'^- \[[xX]\]',(C/'tasks.md').read_text(),re.M))
ck('scenario-map exact',set(sc)=={x['id'] for x in sm['scenarios']} and len(sc)==len(sm['scenarios']))
for x in f['fixtures']:
 ck(x['id']+' has independent expected contract',bool(x['initial']) and bool(x['commands']) and bool(x['expected']))
 ck(x['id']+' known scenario links',bool(x['scenarios']) and all(s in sc for s in x['scenarios']))
for x in m['mutants']:
 ck(x['id']+' actual source contract/oracle',bool(x['actual_source_change']) and x['oracle_fixture'] in {q['id'] for q in f['fixtures']})
 ck(x['id']+' unexecuted',x['status']=='planned_not_executed')
# Basic independent rational fixture arithmetic; no financial program execution.
from fractions import Fraction as Q
ck('loan10 cash/claim',20-10==10 and 0+10==10)
ck('repay4 and6',10-4-6==0 and 10+4+6==20 and 10==4+6)
ck('fraction1/2',Q(10)-Q(1,2)==Q(19,2) and Q(10)+Q(1,2)==Q(21,2))
ck('transfer thenpay4',10-4==6 and 10+4==14)
ck('default waiver decomposition',10==4+6 and 11>10 and not 10>10)
ck('overpayment nonmasking fixture','aliceUSD12' in next(x['initial'] for x in f['fixtures'] if x['id']=='F11'))
ck('actual snapshot API fixture','OutputPort balance snapshot' in f['full_state_convention'])
ck('supply redundant-guard boundary','supply omission alone is redundant' in m['limits'])
before=json.loads((O/'protected-before.json').read_text())
for x in before['files']:ck('protected '+x['path'],sha((R/x['path']).read_bytes())==x['sha256'])
paths=['AGENTS.md','.claude/skills/defi-footguns/SKILL.md','formal/v3/GATE-REGISTER.md','roadmap.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md','docs/research/2026-09-06-defi-source-plan.md','lean/DefiKernel/Typed/Types.lean','lean/DefiKernel/Typed/Expr.lean','lean/DefiKernel/Typed/Authority.lean','lean/DefiKernel/Typed/Transition.lean','lean/DefiKernel/Typed/Examples.lean','lean/DefiKernel/Composition/Contracts.lean','lean/DefiKernel/Composition/Interfaces.lean','lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Atomic/Execution.lean','lean/DefiKernel/Atomic/Observation.lean','lean/DefiKernel/Atomic/Settlement.lean','lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json'];head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();sources=[]
for p in paths:
 b=(R/p).read_bytes();g=subprocess.check_output(['git','show',head+':'+p],cwd=R);sources.append({'path':p,'sha256':sha(b),'bytes':len(b),'git_blob':subprocess.check_output(['git','rev-parse',head+':'+p],cwd=R,text=True).strip(),'matches_observed_HEAD':b==g});ck('source Git '+p,b==g)
write('source-context.json',{'observed_head':head,'source_inputs':sources,'official_accepted_api_refresh_required':True})
commands=[]
for name,args in [('strict',['openspec','validate','claims-liability-lifecycle','--strict']),('status',['openspec','status','--change','claims-liability-lifecycle','--json']),('diff-check',['git','diff','--check','--','openspec/changes/claims-liability-lifecycle','review/semantic-kernel/claims-lifecycle/planning/author-draft','wiki-llm/claims-liability-lifecycle-plan.md'])]:
 args[0]=shutil.which(args[0]);t=time.monotonic();p=subprocess.run(args,cwd=R,capture_output=True);elapsed=time.monotonic()-t
 (O/(name+'.stdout')).write_bytes(p.stdout);(O/(name+'.stderr')).write_bytes(p.stderr);commands.append({'name':name,'argv':args,'cwd':str(R),'exit':p.returncode,'elapsed_seconds':elapsed,'stdout_sha256':sha(p.stdout),'stderr_sha256':sha(p.stderr)});ck(name+' actual exit0',p.returncode==0)
taskmap={'S':['2.1','4.3','4.4','4.6'],'L':['2.2','2.3','2.4','2.5','4.3','4.5'],'P':['3.1','3.2','3.3','3.4','4.2'],'T':['3.5','3.6','4.1','4.3','4.4','4.5','4.6','4.7','4.8'],'E':['1.1','1.2','1.3','5.1','5.2','5.3','5.4','5.5','5.6','5.7','5.8']}
for x in sm['scenarios']:x['task_ids']=taskmap[x['id'][0]];x['fixture_ids']=[q['id'] for q in f['fixtures'] if x['id'] in q['scenarios']];x['coverage_kind']='planned executable/proof fixture' if x['fixture_ids'] else 'planned generic proof, scope or evidence gate';ck(x['id']+' mapped tasks',all(t in tasks for t in x['task_ids']))
write('scenario-map.json',sm);write('commands.json',commands)
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'status':'author_draft_only','counts':counts,'head_before':before['head'],'head_after':head,'protected_unique_files':len(before['files']),'passed':all(x['passed'] for x in checks),'checks':checks,'implementation_started':False,'independent_review_performed':False,'native_invoked':False,'limits':'Static author validation plus basic rational arithmetic only. No Claims source, Lean build, runtime fixtures, production mutations or corpus changes. Historical missing Quantity.lean and misplaced source-plan path lookups were corrected by locating the actual Types.lean and docs/research paths; no API was inferred from the failed lookups.'}
write('author-validation.json',result);print(json.dumps({k:v for k,v in result.items() if k!='checks'}));print('checks',len(checks));assert result['passed']
