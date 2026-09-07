#!/usr/bin/env python3
"""Read-only author planning coverage; writes only Sprint9 planning evidence."""
import datetime,hashlib,json,pathlib,re,runpy,shutil,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[4]
OUT=ROOT/'review/semantic-kernel/sprint9/planning'
CHANGE=ROOT/'openspec/changes/operational-continuation-congruence'
WIKI=ROOT/'wiki-llm/sprint-9-operational-continuation-congruence.md'
CONTEXT='88aa4906102f2e304d1039d2e70942503ec9b341'
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rel(p):return p.relative_to(ROOT).as_posix()
def save(n,v):(OUT/n).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
plans=[CHANGE/'proposal.md',CHANGE/'design.md',CHANGE/'tasks.md',*sorted(CHANGE.glob('specs/*/spec.md')),WIKI]
before={rel(p):{'sha256':sha(p),'bytes':p.stat().st_size} for p in plans}
started=now();commands=[];cli=pathlib.Path(shutil.which('openspec')).resolve()
for name,args in [('strict-validation',['validate','operational-continuation-congruence','--strict']),('status',['status','--change','operational-continuation-congruence','--json'])]:
 cmd=[str(cli),*args];t=now();p=subprocess.run(cmd,cwd=ROOT,capture_output=True)
 a=OUT/(name+'.stdout');b=OUT/(name+'.stderr');a.write_bytes(p.stdout);b.write_bytes(p.stderr)
 commands.append({'argv':cmd,'cwd':str(ROOT),'started_utc':t,'finished_utc':now(),'exit':p.returncode,'stdout':a.name,'stdout_sha256':sha(a),'stderr':b.name,'stderr_sha256':sha(b)})
 assert p.returncode==0,name
mapping={
'Recursive ordered execution':['2.1','2.2','6.1'],
'Refusal and absolute continuation':['2.1','2.4','6.1'],
'Actual flattening correspondence':['2.3','6.1'],
'Sequential associativity scope':['2.4','6.4'],
'Exact cursor observations':['3.1','6.3'],
'Observation equivalence laws':['3.2','6.3'],
'Restricted contextual substitution':['3.3','3.4'],
'Necessary continuation premises':['3.5','6.4'],
'Explicit configuration agreement':['4.1','4.3','6.2'],
'Exact single-step congruence':['4.2','4.3'],
'Supported execution lifting':['4.4','5.1','5.2','5.3','5.4','6.2'],
'Configuration counterexamples':['4.5','6.2','6.4'],
'Planning and baseline gates':['1.1','1.2','1.3'],
'Independent operational evidence':['2.2','6.1','6.2','6.3','6.4'],
'Fourteen production mutations':['7.2','7.3','7.5'],
'Defensive runner controls':['7.1','7.4','7.5'],
'Imported audits and accepted delivery':['6.5','8.1','8.2','8.3','8.4']}
files={
'sequential-group-execution':['SequentialGroups.lean','Examples.lean','Tests.lean'],
'continuation-observation':['Observation.lean','Contexts.lean','Examples.lean','Tests.lean'],
'configuration-congruence':['Configuration.lean','ConfigurationGroups.lean','OperatorLifting.lean','Examples.lean','Tests.lean'],
'metatheory-regression-evidence':['Audit.lean','Verify.lean','Examples.lean','Tests.lean']}
text=(CHANGE/'tasks.md').read_text();tasks=re.findall(r'^- \[([ xX])\] (\d+\.\d+) (.+)$',text,re.M)
assert tasks and all(state==' ' for state,_,_ in tasks);ids={id for _,id,_ in tasks};assert len(ids)==len(tasks)
requirements=[];scenarios=[];names=set();seenreq=set()
for p in sorted(CHANGE.glob('specs/*/spec.md')):
 cap=p.parent.name;t=p.read_text();assert len(t.split('## Purpose\n',1)[1].split('## ADDED',1)[0].strip())>=50
 for block in t.split('### Requirement: ')[1:]:
  title=block.splitlines()[0];seenreq.add(title);assert title in mapping
  requirement={'capability':cap,'name':title,'source':rel(p),'tasks':mapping[title]};requirements.append(requirement)
  assert re.search(r'\b(SHALL|MUST)\b',block.split('#### Scenario:')[0])
  parts=block.split('#### Scenario: ')[1:];assert parts,title
  for part in parts:
   name=part.splitlines()[0];key=(cap,name);assert key not in names;names.add(key)
   when=re.search(r'^- \*\*WHEN\*\* (.+)$',part,re.M);then=re.search(r'^- \*\*THEN\*\* (.+)$',part,re.M);assert when and then,name
   scenarios.append({'id':f'S9-{len(scenarios)+1:03d}','capability':cap,'requirement':title,'scenario':name,
    'when':when.group(1),'then':then.group(1),'source':rel(p),'line':t[:t.index('#### Scenario: '+name)].count('\n')+1,
    'planned_tasks':mapping[title],'planned_modules':['lean/DefiKernel/Metatheory/'+f for f in files[cap]],
    'status':'planned-not-implemented','evidence_limits':'Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts.'})
assert seenreq==set(mapping)
assert {i for r in requirements for i in r['tasks']}==ids
for state,id,desc in tasks:assert any(word in desc.lower() for word in ['verify','record','capture']),id
mutants=[]
for line in (CHANGE/'design.md').read_text().splitlines():
 if re.match(r'^\| M\d\d \|',line):
  row=[x.strip() for x in line.strip('|').split('|')]
  mutants.append(dict(zip(['id','actual_runtime_edit','designated_oracle','protected_positive'],row)))
assert len(mutants)==14 and len({x['id'] for x in mutants})==14
runner=ROOT/'scripts/test_atomic_mutation_runner.py';controls=runpy.run_path(str(runner),run_name='planning_inspection')['cases']()
assert len(controls)==65 and len({x['name'] for x in controls})==65
controlmap=[{'source_name':c['name'],'planned_name':c['name'].replace('atomic','metatheory'),'expected_runner_exit':c['exit'],'status':'catalog-inspected-not-executed-for-sprint9'} for c in controls]
contextpaths=[ROOT/p for p in ['lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Composition/Interfaces.lean','lean/DefiKernel/Typed/Authority.lean','lean/DefiKernel/Typed/Transition.lean','lean/DefiKernel/Parallel/Compatibility.lean','lean/DefiKernel/Parallel/Observation.lean','lean/DefiKernel/Parallel/Execution.lean','lean/DefiKernel/Interleaving/Execution.lean','lean/DefiKernel/Atomic/Execution.lean','lean/DefiKernel/Atomic/Policy.lean','lean/DefiKernel/Atomic/Observation.lean']]
context=[]
for p in contextpaths:
 frozen=subprocess.check_output(['git','show',f'{CONTEXT}:{rel(p)}'],cwd=ROOT)
 context.append({'path':rel(p),'sha256':sha(p),'provisional_git_blob':subprocess.check_output(['git','rev-parse',f'{CONTEXT}:{rel(p)}'],cwd=ROOT,text=True).strip(),'current_bytes_equal_provisional_candidate':frozen==p.read_bytes()})
 assert frozen==p.read_bytes(),p
assert not (ROOT/'lean/DefiKernel/Metatheory').exists(),'Implementation already exists; planning-only assertion invalid'
after={rel(p):{'sha256':sha(p),'bytes':p.stat().st_size} for p in plans};assert before==after
counts={'capabilities':len(files),'requirements':len(requirements),'scenarios':len(scenarios),'tasks':len(tasks),'unchecked_tasks':len(tasks),'planned_mutants':len(mutants),'inspected_cli_controls':len(controls)}
gates={'sprint8_final_accepted_delivery':'pending; refresh candidate/source/evidence binding before Sprint9 planning freeze','independent_gpt6_planning':'not performed; must use a non-author agent','native_fable_planning':'not performed','fresh_implementation_baseline':'not performed','implementation':'not started','production_mutations_and_cli_controls':'not run for Sprint9','native_result_and_evidence_audits':'not performed','delivery':'not performed'}
save('scenario-planning-map.json',{'schema_version':1,'kind':'author-planning-map','counts':counts,'requirements':requirements,'scenarios':scenarios,'tasks':[{'id':i,'description':d,'status':'unchecked'} for _,i,d in tasks],'mutants':mutants,'controls':controlmap,'gates':gates})
save('author-validation.json',{'status':'author-planning-validation-passed-independent-gates-pending','started_utc':started,'finished_utc':now(),'counts':counts,'checks':{'strict_openspec_exit_zero':True,'all_task_checkboxes_unchecked':True,'every_requirement_has_scenarios':True,'every_scenario_has_when_then':True,'every_scenario_has_planned_task_and_module':True,'every_task_is_covered':True,'fourteen_concrete_runtime_mutants':True,'actual_current_control_catalog_has65':True,'metatheory_source_absent':True,'planning_inputs_unchanged_during_validation':True},'commands':commands,'plan_bindings':before,'provisional_source_candidate':CONTEXT,'source_refresh_required':True,'inspected_semantic_source_bindings':context,'inherited_control_source':{'path':rel(runner),'sha256':sha(runner),'count':len(controls),'status':'current working source inspected; final accepted Sprint8 binding still required'},'tools':[{'path':str(cli),'sha256':sha(cli)},{'path':str(pathlib.Path(sys.executable).resolve()),'sha256':sha(pathlib.Path(sys.executable).resolve())}],'gates':gates,'authorship':'Requested GPT-6 stock harness, author planning only; independent model/build telemetry unavailable. No provider, Foreman, implementation or mutation calls.'})
print(json.dumps(counts,indent=2))
