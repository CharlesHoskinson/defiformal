#!/usr/bin/env python3
"""Reconcile accepted predecessor evidence; does not rerun or relabel prior executions."""
from pathlib import Path
import datetime,hashlib,json,subprocess
R=Path(__file__).resolve().parents[5];E=Path(__file__).resolve().parent;S=R/'review/semantic-kernel/sprint9'
SRC='eec499d613688137a341f3556cd80ca461dd2ee9';LEG='c880acf62944746ff9a376afc0c0050702f037f7';ARCH='9908d9b56be2d5ed2b58a16fa8d28b23f33733ff'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
load=lambda p:json.loads(p.read_text())
checks=[];refs={}
def ck(n,v):checks.append({'label':n,'passed':bool(v)});assert v,n
def artifact(p):
 rel=str(p.relative_to(R));refs[rel]={'sha256':sha(p),'bytes':p.stat().st_size};return refs[rel]
def read(p):artifact(p);return load(p)
def gbytes(rev,p):return subprocess.check_output(['git','show',rev+':'+p],cwd=R)
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
delivery=read(S/'archive-delivery.json');accept=read(S/'acceptance/final-acceptance.json');read(S/'acceptance/final-scenarios.json');checkpoint=read(R/'review/semantic-kernel/sprint10/planning/sprint9-checkpoint-remote.json')
ck('accepted source and delivered archive identities',delivery['source_candidate']==SRC and delivery['archive_commit']==ARCH and delivery['remote_matches']and accept['substantive_source_and_evidence_accepted']and accept['delivery_complete'])
for v in accept['reviews']:
 ck('accepted review candidate/'+v['provider'],v['candidate']==SRC and v['verdict']=='ACCEPT WITH LIMITATIONS')
 for p,h in [(v['report'],v['report_sha256']),(v['invocation'],v['invocation_sha256'])]:ck('accepted review hash/'+p,sha(R/p)==h);artifact(R/p)
# Full predecessor Lean package baseline binding, source-equal through accepted delivery/current tree.
lean=read(S/'integration-final-r2/lean-runs.json');valid=read(S/'integration-final-r2/verification.json');pre=read(S/'integration-final-r2/source-before.json');post=read(S/'integration-final-r2/source-after.json')
ck('16 actual Lean commands at eec all passed',lean['candidate']==SRC and len(lean['runs'])==16 and all(x['exit_code']==0 for x in lean['runs'])and valid['all_commands_passed'])
ck('original before/after source inventories equal',pre==post)
source=[]
for p,v in pre.items():
 b=(R/p).read_bytes();ck('integrated source/'+p,hashlib.sha256(b).hexdigest()==v['sha256']and b==gbytes(SRC,p)==gbytes(ARCH,p)==gbytes(head,p));source.append({'path':p,'sha256':sha(R/p),'bytes':len(b),'git_blob':subprocess.check_output(['git','rev-parse',SRC+':'+p],cwd=R,text=True).strip(),'equal_at':[SRC,ARCH,head]})
for run in lean['runs']:
 for v in run['logs'].values():p=S/'integration-final-r2'/v['path'];ck('Lean log/'+str(p.relative_to(R)),sha(p)==v['sha256']);artifact(p)
# Actual14 mutations, and actual65 controls; preserve all raw observations in originals.
prod=read(S/'mutations-r2/results.json');summary=read(S/'mutations-r2/summary.json');pm=read(S/'mutations-r2/final-manifest.json');siblings=read(S/'mutations-r2/sibling-matrix.json');control=read(S/'implementation/runner-controls-r2/summary.json')
ck('14 production cases at accepted source',pm['candidate']==SRC and summary['candidate']==SRC and len(summary['mutants'])==14 and len(prod['results'])==15)
mutation_rows=[]
for row in summary['mutants']:
 actual=prod['results'][row['name']];ck('actual designated mutation/'+row['name'],all(actual['checks'][n]=='false'for n in row['required_false']));mutation_rows.append({'name':row['name'],'required_false':row['required_false'],'actual_exit':actual['exit'],'observed':{n:actual['checks'][n]for n in row['required_false']}})
ck('65 actual CLI cases at accepted source',control['git_head']==SRC and len(control['cases'])==control['total']==control['passed']==65 and all(x['passed']and x['actual_exit']==x['expected_exit']for x in control['cases']))
for p,v in pm['invocation']['input_bindings'].items():ck('production input/'+p,sha(R/p)==v['sha256']and(R/p).read_bytes()==gbytes(SRC,p)==gbytes(ARCH,p));source.append({'path':p,**v,'equal_at':[SRC,ARCH,head]})
for p,h in [(control['runner_source'],control['runner_sha256']),(control['harness_source'],control['harness_sha256'])]:
 path=Path(p)if Path(p).is_absolute()else R/p;ck('control source/'+p,sha(path)==h)
# Actual c880 legacy executions; independently recheck each declared closure, preserving its scope.
legacy=read(S/'regressions/regression-runs.json');outcomes=read(S/'regressions/verified-outcomes.json');eq=read(S/'implementation/legacy-dependency-equivalence.json');ck('13 recorded legacy suites at c880',legacy['source_revision']==LEG and len(legacy['runs'])==13 and all(x['exit']==0 for x in legacy['runs'])and outcomes['all_passed'])
legacy_rows=[];legacydeps={}
for suite in eq['suites']:
 for p,v in suite['source_closure'].items():
  if p not in legacydeps:
   b=(R/p).read_bytes();ck('legacy dependency/'+p,b==gbytes(LEG,p)==gbytes(SRC,p)==gbytes(ARCH,p)and sha(R/p)==v['original']['sha256']);legacydeps[p]=sha(R/p)
 for p,h in suite.get('evidence_inputs',{}).items():
  # Retain author-scoped auxiliary evidence; reconcile shape without extending source closure.
  artifact(R/p)
 row=next(x for x in legacy['runs']if x['label']==suite['label'])
 for k,hk in [('stdout_log','stdout_sha256'),('stderr_log','stderr_sha256'),('log','log_sha256')]:p=S/'regressions'/row[k];ck('legacy log/'+row[k],sha(p)==row[hk]);artifact(p)
 legacy_rows.append({'label':suite['label'],'actual_execution_candidate':LEG,'command':row['command'],'cwd':row['cwd'],'started_utc':row['started_utc'],'finished_utc':row['finished_utc'],'elapsed_seconds':row['elapsed_seconds'],'exit':row['exit'],'outcome':outcomes['outcomes'][suite['label']],'closure_basis':suite['closure_basis'],'dependency_paths':sorted(suite['source_closure'])})
for name,v in eq['tools'].items():ck('recorded tool unchanged/'+name,sha(Path(v['path']))==v['sha256'])
for x in load(E/'before-manifest.json'):ck('prior author evidence unchanged/'+x['path'],sha(R/x['path'])==x['sha256'])
ck('new Interface implementation absent',not(R/'lean/DefiKernel/Interface').exists())
record={'status':'ACCEPTED_DEPENDENCY_BOUND_S10_PLANNING_GATE_PENDING','captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'observed_head':head,'authoritative_delivery':delivery,'later_checkpoint_remote':checkpoint,'source_bindings':source,'source_equivalence_note':'Accepted source bytes equal archive/current bytes; metadata revisions do not create new executions.','actual_Lean':{'candidate':SRC,'commands':lean['runs'],'tools':lean['tools'],'source_count':len(pre)},'actual_mutations':{'candidate':SRC,'count':len(mutation_rows),'cases':mutation_rows,'command':pm['invocation']['command'],'invocation':pm['invocation'],'siblings_scope':'Per-mutant siblings were measured separately; only two global positives are production runner-enforced. See accepted final-acceptance finding R2 and sibling-matrix.json.'},'actual_controls':{'candidate':SRC,'total':65,'passed':65,'cases':[{'name':x['name'],'expected_exit':x['expected_exit'],'actual_exit':x['actual_exit'],'passed':x['passed'],'elapsed_seconds':x['elapsed_seconds']}for x in control['cases']]},'actual_legacy':{'candidate':LEG,'suites':legacy_rows,'unique_dependency_hashes':legacydeps,'equivalence_source':str((S/'implementation/legacy-dependency-equivalence.json').relative_to(R)),'scope':'Rechecked declared repository/tool closures. No new legacy execution or deployment/financial truth claim; original suite limitations remain.'},'reference_artifacts':refs,'checks':checks,'all_checks_passed':all(x['passed']for x in checks),'no_M2_implementation_or_native_review':True}
(E/'dependency-baseline.json').write_text(json.dumps(record,indent=2)+'\n');print('PASS accepted dependency:',len(checks),'checks;16Lean/14mutations/65controls/13legacy; source unchanged through',head)
