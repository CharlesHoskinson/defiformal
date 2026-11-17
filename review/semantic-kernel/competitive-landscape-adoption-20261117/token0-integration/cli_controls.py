from pathlib import Path
import copy,datetime,hashlib,json,subprocess,sys,tempfile,time
root=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal');e=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal/review/semantic-kernel/competitive-landscape-adoption-20261117/token0-integration');checker=root/'docs/correspondence/token0/verify.py';original=json.loads(checker.with_name('differential-observations.json').read_text());runs=[]
with tempfile.TemporaryDirectory(prefix='token0-cli-controls-') as tmp:
 tmp=Path(tmp)
 def run(name,manifest,expected,diagnostic):
  argv=[sys.executable,str(checker),'--manifest',str(manifest)];start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.monotonic();p=subprocess.run(argv,cwd=tmp,stdout=subprocess.PIPE,stderr=subprocess.PIPE);stdout=p.stdout.decode();stderr=p.stderr.decode();assert p.returncode==expected,(name,p.returncode,stderr);assert diagnostic in stdout+stderr,(name,stdout,stderr);runs.append(dict(name=name,argv=argv,cwd=str(tmp),started_utc=start,wall_seconds=time.monotonic()-t,exit=p.returncode,expected_exit=expected,required_diagnostic=diagnostic,stdout=stdout,stderr=stderr));print(name,'exit',p.returncode,diagnostic)
 run('intact',checker.with_name('differential-observations.json'),0,'"status": "PASS"')
 run('missing manifest',tmp/'missing.json',3,'BLOCKED:')
 empty=tmp/'empty.json';empty.write_bytes(b'');run('empty manifest',empty,3,'BLOCKED: empty manifest')
 mutations=[
 ('missing pinned artifact',3,'BLOCKED:',lambda m:m['bound_files'][0].update(path='docs/correspondence/token0/THIS-FILE-DOES-NOT-EXIST')),
 ('empty pinned artifact',3,'BLOCKED: empty artifact:',lambda m:next(x for x in m['bound_files'] if x['bytes']==0).pop('allow_empty')),
 ('empty source denominator',3,'BLOCKED: empty source denominator',lambda m:m.update(source_invocations=[])),
 ('changed expected bytes',1,'FAIL: drift:',lambda m:m['bound_files'][0].update(sha256='0'*64)),
 ('wrong source outcome',1,'FAIL: observation class/data',lambda m:m['source_invocations'][0].update(semantic_class='evm_revert')),
 ('wrong model value',1,'FAIL: actual model observation',lambda m:m['source_invocations'][0].update(model_result='ok:1'))]
 for i,(name,code,diagnostic,mutate) in enumerate(mutations):
  candidate=copy.deepcopy(original);mutate(candidate);manifest=tmp/(str(i)+'.json');manifest.write_text(json.dumps(candidate));run(name,manifest,code,diagnostic)
record=dict(schema='defiformal-token0-cli-controls/v1',python=sys.version,checker_sha256=hashlib.sha256(checker.read_bytes()).hexdigest(),controls=runs,status='PASS',scope='Actual final CLI subprocess controls; no Solidity/EVM execution or refinement proof.')
(e/'cli-controls-r2.json').write_text(json.dumps(record,indent=2)+'\n');print('PASS',len(runs),'actual CLI subprocess controls')
