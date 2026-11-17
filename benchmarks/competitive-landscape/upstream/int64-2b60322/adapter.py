"""Real Lean replay adapter; result parsing never promotes failures or cached work."""
import json,os,pathlib,re,shutil,subprocess,sys
import setup,procedure
HERE=pathlib.Path(__file__).resolve().parent
CASES=('P1','P2','P3-N4','P3-N16')
def classify(value,target_name="Benchmark.established"):
 if not isinstance(value,dict) or type(value.get('returncode')) is not int:return 'malformed'
 if value.get('verification_executed') is False:return 'cached_skip'
 if value.get('verification_executed') is not True:return 'malformed'
 if value['returncode']==124:return 'timeout'
 if not isinstance(value.get('stdout'),str) or not isinstance(value.get('stderr'),str):return 'malformed'
 if value['returncode']:return 'failed_obligations' if 'error:' in value['stdout']+value['stderr'] else 'incomplete'
 if not value.get('artifact_exists') or not re.fullmatch('[0-9a-f]{64}',str(value.get('artifact_sha256',''))):return 'incomplete'
 text=value['stdout']+value['stderr'];match=re.search("'"+re.escape(target_name)+r"' depends on axioms:\s*\[([^]]*)\]",text,re.S)
 if match:
  axioms={x.strip() for x in match.group(1).split(',') if x.strip()}
  return 'success' if axioms<={'propext','Classical.choice','Quot.sound'} else 'incomplete'
 if "'"+target_name+"' does not depend on any axioms" in text:return 'success'
 return 'incomplete'
def directory(case,stage):return setup.runtime()/'benchmark'/(case+'-'+stage)
def target(case,stage):return case.replace('-','_')+'_'+stage

def prepare(case,stage):
 dest=directory(case,stage)
 if dest.exists():shutil.rmtree(dest)
 dest.mkdir(parents=True)
 files=['Procedure.lean','Model.lean']
 runs=[]
 for name in files:
  result=procedure.invoke(HERE/name,dest);runs.append(result)
  if result['returncode'] or not result['artifact_exists']:raise RuntimeError(json.dumps(result))
 return runs

def replay(case,stage,retain=None):
 dest=directory(case,stage)
 helpers=['NativeHelper.lean'] if stage=='assisted' else []
 if stage=='assisted' and case!='P2':helpers+=['TransferHelper.lean']
 if stage=='assisted' and case.startswith('P3'):helpers+=['SequenceHelper.lean']
 helper_runs=[]
 try:
  for name in helpers:
   check=procedure.invoke(HERE/name,dest);helper_runs.append(check)
   if check['returncode'] or not check['artifact_exists']:
    return dict(check,helper_replays=helper_runs)
  result=procedure.invoke(HERE/(target(case,stage)+'.lean'),dest)
 except subprocess.TimeoutExpired as exc:
  return dict(returncode=124,stdout=(exc.stdout or b'').decode() if isinstance(exc.stdout,bytes) else (exc.stdout or ''),stderr='',verification_executed=True,artifact_exists=False)
 result['classification']=classify(result)
 result['helper_replays']=helper_runs
 if retain and result['classification']=='success':
  retain=pathlib.Path(retain);retain.mkdir(parents=True,exist_ok=True)
  for name in [target(case,stage)]+[pathlib.Path(h).stem for h in helpers]:
   for p in dest.glob(name+'.olean*'):shutil.copy2(p,retain/p.name)
 return result

def check_proof(case):
 dest=directory(case,'assisted')
 modules=['Procedure','Model','NativeHelper']+(['TransferHelper'] if case!='P2' else [])+(['SequenceHelper'] if case.startswith('P3') else [])+[target(case,'assisted')]
 paths=[p for name in modules for p in dest.glob(name+'.olean*')]
 before={p.name:setup.digest(p) for p in paths}
 env=setup.environment(dest);env['PATH']=str(setup.lean().parent)+os.pathsep+env['PATH'];env['LEAN_NUM_THREADS']='1'
 runs=[]
 for name in modules:
  command=[str(setup.lean().parent/'leanchecker'),'-v',name]
  p=subprocess.run(command,env=env,capture_output=True,text=True,timeout=110)
  runs.append(dict(command=command,returncode=p.returncode,stdout=p.stdout,stderr=p.stderr))
  if p.returncode or p.stdout.splitlines().count('replaying '+name)!=1:raise RuntimeError(json.dumps(runs))
 if before!={p.name:setup.digest(p) for p in paths}:raise RuntimeError('Proof artifacts changed during independent check')
 return dict(outcome='success',verification_executed=True,checked_modules=modules,runs=runs,artifact_sha256=before,boundary='Kernel replay of every new model/procedure/helper/target module from existing .olean files. Imported pinned library modules remain trusted; --fresh is not used. No tactic/source recompilation in this command.')

def benchmark_build():
 dest=setup.runtime()/'benchmark-clean-build';dest.mkdir(parents=True,exist_ok=True)
 runs=[]
 for name in ['Procedure','Model','NativeHelper','TransferHelper','SequenceHelper']+[target(c,'assisted') for c in CASES]:
  result=procedure.invoke(HERE/(name+'.lean'),dest);runs.append(result)
  if result['returncode'] or not result['artifact_exists']:raise RuntimeError(json.dumps(runs))
 return dict(outcome='success',verification_executed=True,runs=runs)

def exported_artifacts(case,stage,action):
 output=pathlib.Path(os.environ['MEASUREMENT_OUTPUT'])
 dest=output/'proofs'/(case+'-'+stage+'-'+action+'-'+os.environ.get('MEASUREMENT_RUN_INDEX','unknown'))
 dest.mkdir(parents=True,exist_ok=True)
 names=[target(case,stage)]+(['NativeHelper'] if stage=='assisted' else [])+(['TransferHelper'] if stage=='assisted' and case!='P2' else [])+(['SequenceHelper'] if stage=='assisted' and case.startswith('P3') else [])
 entries=[]
 for name in names:
  for source in directory(case,stage).glob(name+'.olean*'):
   copied=dest/source.name;shutil.copy2(source,copied)
   entries.append(dict(path=str(copied.relative_to(output)),format='Lean 4.33 compiled module with theorem proof term',root='results',role='target' if name==target(case,stage) else 'shared_helper'))
 return entries

def main():
 if sys.argv[1]=='build-prepare':
  dest=setup.runtime()/'benchmark-clean-build'
  if dest.exists():shutil.rmtree(dest)
  dest.mkdir(parents=True);return
 if sys.argv[1]=='build':
  payload=benchmark_build()
  pathlib.Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload));print(json.dumps(payload));return
 action,case,stage=sys.argv[1:4]
 if case not in CASES or stage not in ('automatic','assisted'):raise ValueError('Unknown case/stage')
 if action=='prepare':
  print(json.dumps({'prepared':True,'runs':prepare(case,stage)}));return
 if action=='check-prepare':
  prep=prepare(case,'assisted');result=replay(case,'assisted')
  if classify(result)!='success':raise RuntimeError(json.dumps(result))
  print(json.dumps({'prepared':True,'runs':prep,'proof':result}));return
 if action=='check':
  payload=check_proof(case)
  if os.environ.get('MEASUREMENT_OUTPUT'):payload['proof_artifacts']=exported_artifacts(case,'assisted','check')
  pathlib.Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload));print(json.dumps(payload));return
 result=replay(case,stage)
 cls=classify(result);outcome='success' if cls=='success' else 'timeout' if cls=='timeout' else 'inconclusive' if cls in ('failed_obligations','incomplete') else 'error'
 payload=dict(outcome=outcome,verification_executed=result.get('verification_executed') is True,observation=result)
 if outcome=='success' and os.environ.get('MEASUREMENT_OUTPUT'):
  payload['proof_artifacts']=exported_artifacts(case,stage,'replay')
 if os.environ.get('MEASUREMENT_RESULT'):
  pathlib.Path(os.environ['MEASUREMENT_RESULT']).write_text(json.dumps(payload))
 print(json.dumps(payload))
if __name__=='__main__':main()
