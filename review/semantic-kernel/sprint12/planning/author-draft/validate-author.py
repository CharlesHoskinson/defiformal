#!/usr/bin/env python3
"""Planning consistency and source bindings only; no kernel execution or audit verdict."""
from pathlib import Path
import datetime, hashlib, itertools, json, re, shutil, subprocess, sys, time
B=Path(__file__).resolve().parent
R=B.parents[4]
C=R/'openspec/changes/operational-tree-regrouping'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(name,data):(B/name).write_text(json.dumps(data,indent=2)+'\n')
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run(name,cmd):
    tick=time.monotonic();start=utc();p=subprocess.run(cmd,cwd=R,capture_output=True,timeout=60)
    (B/(name+'.stdout')).write_bytes(p.stdout);(B/(name+'.stderr')).write_bytes(p.stderr)
    return {'name':name,'command':cmd,'cwd':str(R),'started_utc':start,'ended_utc':utc(),'wall_seconds':time.monotonic()-tick,'returncode':p.returncode,'stdout_sha256':sha(B/(name+'.stdout')),'stderr_sha256':sha(B/(name+'.stderr'))}
commands=[run('strict-final',['openspec','validate','operational-tree-regrouping','--strict','--no-interactive']),
          run('status',['openspec','status','--change','operational-tree-regrouping','--json']),
          run('graph-query',['graphify','query','operational metatheory finite participants tree regrouping associativity','--budget','1200']),
          run('diff-check',['git','diff','--check','--',str(C.relative_to(R)),'wiki-llm/operational-tree-regrouping-plan.md',str(B.relative_to(R))])]
write('commands.json',commands)
checks=[]
def check(name,value):
    checks.append({'name':name,'passed':bool(value)})
    assert value,name
for c in commands:check('command:'+c['name'],c['returncode']==0)
before=json.loads((B/'protected-before.json').read_text())
for f in before['files']:check('protected:'+f['path'],sha(R/f['path'])==f['sha256'])
mapped=json.loads((B/'scenario-map.json').read_text());fixtures=json.loads((B/'fixtures.json').read_text())['fixtures'];mutants=json.loads((B/'planned-mutations.json').read_text())['mutations']
tasktext=(C/'tasks.md').read_text();tasks=re.findall(r'^- \[ \] (\d+\.\d+) ',tasktext,re.M)
check('all-tasks-unchecked','- [x]' not in tasktext.lower() and bool(tasks))
check('tasks-unique',len(tasks)==len(set(tasks)))
requirements=[];scenarios=[];caps=[]
for p in sorted((C/'specs').glob('*/spec.md')):
    text=p.read_text();caps.append(p.parent.name)
    requirements+=re.findall(r'^### Requirement: (R\d+) ',text,re.M)
    scenarios+=re.findall(r'^#### Scenario: (S\d+) ',text,re.M)
    check('purpose:'+p.parent.name,text.startswith('## Purpose\n') and '## ADDED Requirements' in text)
check('nonempty-required-artifacts',len(caps)>0 and len(requirements)>0 and len(scenarios)>0)
check('exact-requirement-map',set(requirements)=={x['id'] for x in mapped['requirements']} and len(requirements)==len(mapped['requirements']))
check('exact-scenario-map',set(scenarios)=={x['id'] for x in mapped['scenarios']} and len(scenarios)==len(mapped['scenarios']))
fids={x['id'] for x in fixtures};used=set();mappedtasks=set()
for s in mapped['scenarios']:
    check('scenario-has-known-fixtures:'+s['id'],bool(s['fixtures']) and set(s['fixtures'])<=fids)
    check('scenario-has-known-tasks:'+s['id'],bool(s['tasks']) and set(s['tasks'])<=set(tasks))
    used.update(s['fixtures']);mappedtasks.update(s['tasks'])
check('every-fixture-covered',used==fids)
check('every-task-covered',mappedtasks==set(tasks))
check('mutation-nonempty-unique',bool(mutants) and len({x['id'] for x in mutants})==len(mutants))
for m in mutants:check('mutation-oracle:'+m['id'],m['fixture'] in fids and bool(m['replacement']) and bool(m['intended_false_oracle']) and bool(m['protected_positive']))
# Pure planning arithmetic: no invocation of proposed or existing financial runners.
orders=set(itertools.permutations([0,0,1,1,2,2]));funded=set(itertools.permutations([0,0,1,2]))
check('independent-schedule-count-90',len(orders)==90)
check('independent-funded-count-12',len(funded)==12)
check('paired-prefix-arithmetic',[(5-i,5-i,2*i) for i in (1,2,3)]==[(4,4,2),(3,3,4),(2,2,6)])
check('competing-withdrawal-arithmetic',10-7==3 and 10-6==4 and 3<6 and 4<7)
check('canonical-source-not-created',not (R/'lean/DefiKernel/Nary/Tree').exists())
context=['AGENTS.md','roadmap.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','docs/research/semantic-kernel-progress.md','wiki-llm/operational-metatheory-planning-draft.md','lean/DefiKernel/Metatheory/SequentialGroups.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Parallel/Compatibility.lean','lean/DefiKernel/Parallel/Execution.lean','lean/DefiKernel/Parallel/Observation.lean','lean/DefiKernel/Parallel/Dependency/Adapter.lean','lean/DefiKernel/Interleaving/Recovery.lean','lean/DefiKernel/Interleaving/Interference.lean']
context += [str(p.relative_to(R)) for p in sorted((R/'openspec/changes/finite-participant-causal-composition').rglob('*')) if p.is_file()]
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();bindings=[]
for name in context:
    p=R/name;obj=subprocess.run(['git','rev-parse',f'{head}:{name}'],cwd=R,text=True,capture_output=True)
    bindings.append({'path':name,'bytes':p.stat().st_size,'sha256':sha(p),'git_blob':obj.stdout.strip() if obj.returncode==0 else None})
write('context-inputs.json',{'head':head,'inputs':bindings,'graph_limit':'Historical graph query only; current kernel claims require directly inspected source. No graph rebuild or provider call.'})
toolpaths=[Path(sys.executable),Path(shutil.which('openspec')).resolve(),Path(shutil.which('graphify')).resolve()]
write('tools.json',{'python_version':sys.version,'tools':[{'path':str(p),'sha256':sha(p)} for p in toolpaths]})
write('dependency-refresh.json',{'status':'required_before_official_freeze','accepted_m1_source':'eec499d613688137a341f3556cd80ca461dd2ee9','M2_accepted_delivery':'PENDING','M3_accepted_delivery':'PENDING','required':['Actual accepted source/evidence/remote archive IDs for M2 and M3','Actual roster/local-state/attempt/admission/continuation and monitor signatures','Actual M2 full-binding/accounting local premises and concrete fixture constructors','Final predecessor runtime/import/proof-strip/CLI-control mapping and counts','Accepted baseline execution revisions with exact dependency-byte binding','Fresh strict author validation and nonauthor GPT-6/native Fable5.1 medium planning verdicts'],'planning_gate_passed':False,'implementation_authorized_by_this_draft':False})
result={'status':'PASS_AUTHOR_CONSISTENCY_ONLY','utc':utc(),'head_before':before['head'],'head_after':head,'counts':{'capabilities':len(caps),'requirements':len(requirements),'scenarios':len(scenarios),'unchecked_tasks':len(tasks),'fixtures':len(fixtures),'planned_mutations':len(mutants),'checks':len(checks),'protected_files':len(before['files']),'S10_bound_inputs':88,'corpus_bound_inputs':93},'checks':checks,'independent_review_performed':False,'native_calls':0,'implementation_started':False,'source_mutations_executed':0,'financial_runtime_checks_executed':0,'limits':'Pure planning arithmetic and artifact/source consistency do not prove the proposed Lean statements or instantiate future APIs.'}
write('author-validation.json',result)
print(json.dumps({k:v for k,v in result.items() if k!='checks'},indent=2))
