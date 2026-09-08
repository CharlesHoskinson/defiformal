import pathlib,json,hashlib,subprocess,tarfile,datetime,os,shutil,time,signal
P=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p13-review')
W=pathlib.Path('/home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate')
PRIMARY=pathlib.Path('/home/charl/defiformal')
ARCHIVE=pathlib.Path('/home/charl/defiformal-wt-honest-gate-grok-gpt6-20260908/review/semantic-kernel/program-loop-20260908/native-worker/honest-gate-clean-closeout-r2-stage.tar.gz')
PREFIX='review/semantic-kernel/honest-gate/implementation/grok-clean-closeout-r2/'
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
def git(cwd,*args):return subprocess.check_output(['git',*args],cwd=cwd,text=True)
def write(name,value):(P/name).write_text(json.dumps(value,indent=2)+'\n')
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
P.mkdir(exist_ok=True);(P/'logs').mkdir(exist_ok=True)
assert not os.path.lexists('/tmp/negtest-reporting'),'BLOCKED unknown preexisting /tmp/negtest-reporting (not removed)'
assert git(W,'status','--porcelain','-uall')=='','BLOCKED candidate is dirty'
assert git(W,'rev-parse','HEAD').strip()=='89486bae7b4a99d6d3881fd2fb50ab61dea1fc43'
assert sha(ARCHIVE)=='6e2a7315945080c021c84b19a25a996991d77bfa547b3e48ef1a2901a6c45f07'
current=json.loads((PRIMARY/'review/semantic-kernel/strategy-audit-20260908/CURRENT.json').read_text())
def walk(x):
 if isinstance(x,dict):
  if x.get('id')=='reporting_gate':return x
  for y in x.values():
   r=walk(y)
   if r:return r
 if isinstance(x,list):
  for y in x:
   r=walk(y)
   if r:return r
lane=walk(current);assert lane['candidate']['sha256']==sha(ARCHIVE)
tar=tarfile.open(ARCHIVE);restore=json.loads(tar.extractfile(PREFIX+'execution/harness/restore.json').read());generated=[x['rel'] for x in restore['restored']];assert len(generated)==16
paths=['formal/v2','formal/v3','paper','expansion','corpus50','research/positive-program/sigma']
tracked=git(W,'ls-files','-z','--',*paths).split('\0');tracked=[f for f in tracked if f]
source_sha=sha(W/'formal/v3/negtest-reporting.sh');assert source_sha=='36c7c7b03fdb9f68d51f277ee6daa621f9a6d599b573babe7ccc1037be4e98b9'
snapshots={}
for f in generated:
 src=W/f;dest=P/'snapshots'/f;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dest);snapshots[f]={'sha256':sha(src),'mode':src.stat().st_mode & 0o7777,'bytes':src.stat().st_size}
candidate_files={f:sha(W/f) for f in tracked};primary_files={f:sha(PRIMARY/f) for f in tracked if (PRIMARY/f).is_file()}
pre={'utc':now(),'candidate':str(W),'head':git(W,'rev-parse','HEAD').strip(),'tree':git(W,'rev-parse','HEAD^{tree}').strip(),'parent':git(W,'rev-parse','HEAD^').strip(),'candidate_status':git(W,'status','--porcelain','-uall'),'primary_head':git(PRIMARY,'rev-parse','HEAD').strip(),'archive_sha256':sha(ARCHIVE),'current_reporting_gate':lane,'candidate_files':candidate_files,'primary_files':primary_files,'primary_candidate_differences':[f for f in candidate_files if primary_files.get(f)!=candidate_files[f]],'generated_files':snapshots,'tmp_absent_before':True,'uid':os.getuid()};write('before.json',pre)
assert os.getuid()!=0,'BLOCKED chmod refusal requires unprivileged user'
probe=P/'permission-probe';probe.mkdir(exist_ok=True);probe.chmod(0)
try:
 try:list(probe.iterdir());raise AssertionError('chmod000 readable: blocked EACCES control')
 except PermissionError:pass
finally:probe.chmod(0o755);probe.rmdir()
env=os.environ.copy()
for k in ['DEFIFORMAL_ROOT','GEN_IR']:env.pop(k,None)
cmd=['/usr/bin/bash',str(W/'formal/v3/negtest-reporting.sh')];receipt={'argv':cmd,'cwd':str(W),'start_utc':now(),'uid':os.getuid(),'DEFIFORMAL_ROOT':None,'GEN_IR':None};write('harness-command.json',receipt);t=time.time();print('PREFLIGHT OK; starting one reporting harness',flush=True)
try:
 with (P/'logs/harness.stdout').open('w') as out,(P/'logs/harness.stderr').open('w') as err:
  proc=subprocess.Popen(cmd,cwd=W,env=env,stdout=out,stderr=err,start_new_session=True)
  try:rc=proc.wait(timeout=600)
  except subprocess.TimeoutExpired:
   os.killpg(proc.pid,signal.SIGTERM);proc.wait(timeout=20);rc=124
 receipt.update({'end_utc':now(),'exit':rc,'seconds':round(time.time()-t,3)});write('harness-command.json',receipt)
finally:
 postharness={f:sha(W/f) for f in generated};status=git(W,'status','--porcelain','-uall')
 for f in generated:shutil.copy2(P/'snapshots'/f,W/f)
 candidate_after={f:sha(W/f) for f in tracked};primary_after={f:sha(PRIMARY/f) for f in primary_files};after={'utc':now(),'candidate_status_after_harness':status,'generated_after_harness':postharness,'generated_after_restore':{f:sha(W/f) for f in generated},'candidate_status_after_restore':git(W,'status','--porcelain','-uall'),'candidate_changed_files':[f for f in tracked if candidate_after[f]!=candidate_files[f]],'primary_changed_files':[f for f in primary_files if primary_after[f]!=primary_files[f]],'candidate_files':candidate_after,'primary_files':primary_after,'tmp_exists_after':os.path.lexists('/tmp/negtest-reporting'),'head_after':git(W,'rev-parse','HEAD').strip()};write('after.json',after)
print(json.dumps(receipt),flush=True);print(json.dumps({k:v for k,v in after.items() if k in ['candidate_status_after_harness','candidate_status_after_restore','candidate_changed_files','primary_changed_files','tmp_exists_after']}),flush=True)
