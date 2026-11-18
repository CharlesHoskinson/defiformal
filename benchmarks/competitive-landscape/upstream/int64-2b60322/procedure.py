"""Frozen ordinary Lean invocation; target selection changes paths only."""
import hashlib,json,pathlib,subprocess,sys
import setup
HERE=pathlib.Path(__file__).resolve().parent
def invoke(source,directory):
 source=pathlib.Path(source).resolve();directory=pathlib.Path(directory).resolve();directory.mkdir(parents=True,exist_ok=True)
 target=directory/(source.stem+'.olean');target.unlink(missing_ok=True)
 command=[str(setup.lean()),'-j1','-o',str(target),str(source)]
 p=subprocess.run(command,cwd=source.parent,env=setup.environment(directory),capture_output=True,text=True,timeout=580)
 return dict(returncode=p.returncode,stdout=p.stdout,stderr=p.stderr,verification_executed=True,command=command,artifact_exists=target.is_file(),artifact_sha256=setup.digest(target) if target.is_file() else None)
if __name__=='__main__':
 if sys.argv[1:] == ['--select']:
  setup.install();directory=setup.runtime()/'selection'
  first=invoke(HERE/'Procedure.lean',directory);second=invoke(HERE/'Selection.lean',directory) if first['returncode']==0 else None
  if second is None or second['returncode'] or not second['artifact_exists']:raise RuntimeError(json.dumps(dict(first=first,second=second)))
  print(json.dumps(dict(status='passed',selection=second,procedure=first)))
 else:
  print(json.dumps(invoke(sys.argv[1],sys.argv[2])))
