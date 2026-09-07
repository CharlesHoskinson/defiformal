#!/usr/bin/env python3
"""Read-only source checks and regenerated M3 author maps; no Nary execution."""
from pathlib import Path
import hashlib, itertools, json, re, shutil, subprocess, sys, time
from datetime import datetime, timezone
R=Path(__file__).resolve().parents[5]
C=R/'openspec/changes/finite-participant-causal-composition'; E=Path(__file__).resolve().parent
assert (R/'AGENTS.md').is_file(),R
load=lambda p:json.loads(p.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save(name,data): (E/name).write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n')
def git(*args): return subprocess.check_output(['git',*args],cwd=R).decode().strip()
def utc(): return datetime.now(timezone.utc).isoformat()
checks=[]
def check(name,ok,detail=None):
 checks.append({'name':name,'passed':bool(ok),'detail':detail})
def verify_rows(rows,label,pathkey='path'):
 for x in rows: check(label+':'+x[pathkey],sha(R/x[pathkey])==x['sha256'])
start=utc();head=git('rev-parse','HEAD'); candidate='b165bc586080d668f689fbc18dfa09eb8739d688'
owned_before={str(p.relative_to(R)):sha(p) for p in C.rglob('*') if p.is_file()}
before=load(E/'before.json');verify_rows(before['files'],'original_snapshot','snapshot')
verify_rows(load(E/'prior-author-evidence.json')['files'],'original_author_evidence')
held=load(R/'review/semantic-kernel/claim-reconciliation/planning/official-r3/manifest.json')
verify_rows(held['inputs'],'historical_r3_before')
api=load(C/'accepted-api.json');closure=load(E/'accepted-runtime-closure.json');baseline=load(C/'dependency-baseline.json')
for x in api['source_files']+closure['modules']:
 path=x['path'];cur=(R/path).read_bytes();old=subprocess.check_output(['git','show',candidate+':'+path],cwd=R)
 check('accepted_source:'+path,cur==old and sha(R/path)==x['sha256'])
for x in api['declarations']:
 check('actual_API:'+x['name'],x['source_signature'] in (R/x['path']).read_text() and sha(R/x['path'])==x['source_sha256'])
verify_rows(baseline['baseline_references'],'retained_baseline')
check('runtime_closure_record',sha(E/'accepted-runtime-closure.json')==baseline['accepted_runtime_closure']['sha256'])
fixtures=load(C/'fixtures.json'); mutations=load(C/'planned-mutations.json');runner=load(C/'runner-adaptation.json')
fids=[x['id'] for x in fixtures['fixtures']];mids=[x['id'] for x in mutations['mutations']]
check('nineteen_fixture_IDs',fids==[f'F{i:02}' for i in range(1,20)])
check('sixteen_mutant_IDs',mids==[f'M{i:02}' for i in range(1,17)])
for m in mutations['mutations']:
 check('literal_mutation:'+m['id'],m['fixture'] in fids and bool(m['needle']) and m['needle']!=m['replacement'] and m['expected_needle_count']==1 and bool(m['oracle_label']) and bool(m['expected_protected_check']))
controls=runner['controls'];check('65_distinct_controls',len(controls)==len({x['id'] for x in controls})==65)
for x in controls:
 check('inherited_control:'+x['id'],x['predecessor_passed'] and x['actual_predecessor_exit']==x['expected_exit'] and bool(x['successor_command']))
 if x.get('predecessor_spec'):
  q=x['predecessor_spec']; check('control_original_bytes:'+x['id'],sha(R/q['path'])==q['sha256'])
  check('literal_control_mapping:'+x['id'],x['successor_spec_text']==(R/q['path']).read_text().replace('Interface','Nary').replace('interface','nary'))
for d in runner['driver_mappings']:
 check('inherited_driver:'+d['old'],sha(R/d['old'])==d['sha256'])
 lines=(R/d['old']).read_text().splitlines()
 for x in d['edits']:check('driver_line:'+d['old']+':'+str(x['line']),lines[x['line']-1]==x['old'] and x['new']==x['old'].replace('Interface','Nary').replace('interface','nary'))
check('timeout_contract',runner['runtime_timeout_seconds']==600 and runner['harness_timeout_seconds']==1500)
f10=fixtures['fixtures'][9]['twelve_literal_schedule_oracles']
check('F10_all_twelve_schedules',{tuple(x['schedule']) for x in f10}==set(itertools.permutations([0,0,1,2])) and len(f10)==12)
for i,x in enumerate(f10):
 balances=[10,2,3,0,6,0];counts=[0,0,0];phase='Awaiting'
 check(f'F10_prefix_length:{i}',len(x['independent_prefix_expectations'])==4)
 for j,(b,p) in enumerate(zip(x['schedule'],x['independent_prefix_expectations'])):
  idx=counts[b];op=200+idx if b==0 else 201+b;pre=balances.copy()
  if op==200:phase='Ready6';deltas=[];outputs=[{'index':0,'component':0,'port':7,'amount_usd':6}]
  elif op==201:balances[0]-=6;balances[3]+=6;phase='Consumed';deltas=[['vault',-6],['recipient',6]];outputs=[]
  elif op==202:balances[0]+=1;balances[1]-=1;deltas=[['donor1',-1],['vault',1]];outputs=[]
  else:balances[0]+=2;balances[2]-=2;deltas=[['donor2',-2],['vault',2]];outputs=[]
  counts[b]+=1
  check(f'F10_literal_prefix:{i}:{j}',p['participant']==b and p['own_index']==idx and p['operation']==op and p['before_main_usd']==pre and p['after_main_usd']==balances and p['receipt_deltas']==deltas and p['outputs']==outputs and p['monitor']==phase and p['locals_nextIndex_and_consumed']==counts and p['failure']=='none' and balances[0]>=4 and sum(balances)==21)
 check(f'F10_final:{i}',balances==[7,1,1,6,6,0])
f18=fixtures['fixtures'][17];check('F18_all_six_schedules',len(f18['complete_schedules'])==6 and {tuple(s) for s in f18['complete_schedules']}==set(itertools.permutations([0,1,2])))
old=load(E/'scenario-coverage.json');lookup={(x['capability'],x['requirement'],x['scenario']):x for x in old['mapping']};mapping=[];reqs=[]
for p in sorted((C/'specs').glob('*/spec.md')):
 text=p.read_text();cap=p.parent.name
 for r in re.finditer(r'^### Requirement: ([^\n]+)\n(.*?)(?=^### Requirement:|\Z)',text,re.M|re.S):
  req=r.group(1);reqs.append((cap,req))
  for s in re.finditer(r'^#### Scenario: ([^\n]+)\n(.*?)(?=^#### Scenario:|\Z)',r.group(2),re.M|re.S):
   key=(cap,req,s.group(1));check('mapped_scenario:'+str(key),key in lookup)
   row=dict(lookup[key]);row['normative_text']=s.group(2).strip();row['spec_path']=str(p.relative_to(R));row['spec_sha256']=sha(p);mapping.append(row)
check('fixed_normative_scope',len(reqs)==19 and len(mapping)==52 and len({x['capability'] for x in mapping})==5)
check('one_mapping_each',len(mapping)==len(lookup)==len({x['id'] for x in mapping}))
save('scenario-coverage.json',{'status':'accepted_M2_refreshed_author_map_no_independent_gate','capabilities':5,'requirements':len(reqs),'scenarios':len(mapping),'mapping':mapping})
oldtasks={x['id']:x for x in load(E/'task-coverage.json')['tasks']};tasks=[]
for m in re.finditer(r'^- \[([ x])\] (\d+\.\d+) (.+)$',(C/'tasks.md').read_text(),re.M):
 check('unchecked_task:'+m[2],m[1]==' '); row=dict(oldtasks[m[2]]);row['text']=m[3];tasks.append(row)
check('task_coverage_exact',len(tasks)==len(oldtasks) and {x['id'] for x in tasks}==set(oldtasks))
save('task-coverage.json',{'status':'all_unchecked_author_plan','count':len(tasks),'tasks':tasks})
save('fixtures.json',fixtures);save('planned-mutations.json',mutations)
labels={}
for m in mutations['mutations']:
 labels.setdefault(m['oracle_label'],{'fixtures':set(),'role':set()});labels[m['oracle_label']]['fixtures'].add(m['fixture']);labels[m['oracle_label']]['role'].add('intended_false_for_'+m['id'])
 labels.setdefault(m['expected_protected_check'],{'fixtures':set(),'role':set()});labels[m['expected_protected_check']]['role'].add('protected_true_for_'+m['id'])
for k,v in labels.items():
 if k=='nary.empty.exact':v['fixtures'].add('F04')
 if k=='nary.no_failure.exact':v['fixtures'].add('F02')
 if k=='nary.monitor.actual_producer':v['fixtures'].add('F10')
save('planned-oracle-labels.json',{'status':'minimum_planned_labels_not_implemented_or_total_runtime_count','labels':[{'id':k,**{f:sorted(vv) for f,vv in v.items()}} for k,v in sorted(labels.items())]})
commands=[]
for label,args in [('strict',['openspec','validate',C.name,'--strict','--no-interactive']),('diff',['git','diff','--check','--',str(C.relative_to(R))])]:
 exe=shutil.which(args[0]); t=time.monotonic();u=utc();cp=subprocess.run(args,cwd=R,capture_output=True)
 (E/f'{label}.stdout.log').write_bytes(cp.stdout);(E/f'{label}.stderr.log').write_bytes(cp.stderr)
 row={'command':args,'cwd':str(R),'utc':u,'duration_seconds':time.monotonic()-t,'exit':cp.returncode,'executable':exe,'executable_sha256':sha(Path(exe)),'stdout_sha256':sha(E/f'{label}.stdout.log'),'stderr_sha256':sha(E/f'{label}.stderr.log')};commands.append(row);check(label,cp.returncode==0)
verify_rows(held['inputs'],'historical_r3_after')
check('owned_normative_bytes_unchanged_during_checks',owned_before=={str(p.relative_to(R)):sha(p) for p in C.rglob('*') if p.is_file()})
failed=[x for x in checks if not x['passed']]
result={'status':'PASS' if not failed else 'FAIL','kind':'author_planning_consistency_not_independent_acceptance','utc_before':start,'utc_after':utc(),'head_before':head,'head_after':git('rev-parse','HEAD'),'source_candidate':candidate,'counts':{'capabilities':5,'requirements':len(reqs),'scenarios':len(mapping),'tasks':len(tasks),'fixtures':len(fids),'planned_mutants':len(mids),'inherited_controls':len(controls),'new_controls':0,'accepted_API_declarations':len(api['declarations']),'accepted_runtime_modules':len(closure['modules'])},'checks':checks,'passed':len(checks)-len(failed),'failed':failed,'commands':commands,'python':{'executable':sys.executable,'sha256':sha(Path(sys.executable)),'version':sys.version},'script_sha256':sha(Path(__file__)),'limits':['No Nary Lean declarations, proofs, runtime checks or source mutants exist or ran in this task.','Literal expected arithmetic tables checked by independent Python arithmetic; this does not establish executeStep correspondence.','Retained baseline evidence keeps its actual execution candidate.','No independent planning review, native provider invocation or commit.']}
save('author-validation.json',result)
print(json.dumps({k:result[k] for k in ['status','counts','passed','failed']},indent=2))
sys.exit(bool(failed))
