from pathlib import Path
import concurrent.futures,datetime,hashlib,json,re,subprocess,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');W=Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909');O=B/'p19-r22-root-probe-recovery';O.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
m=json.loads((B/'p19-roundtrip-proof-agy-r22-terminal-manifest.json').read_text());frozen={r['path']:r for r in m['files']};assert not Path('/proc/2205554').exists()
tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')
e='review/semantic-kernel/certificates/p19/implementation/agy-r22-proof/probes/'
for row in m['files']:assert h(W/row['path'])==row['sha256']
selected=['test_typed_roundtrip.lean','test_all_structures.lean','test_template_fix.lean']
def run_probe(name):
 path=W/e/name;assert h(path)==frozen[e+name]['sha256'];out=O/name.removesuffix('.lean');out.mkdir();shutil.copy2(path,out/name)
 argv=[str(tool/'lake'),'env',str(tool/'lean'),str(path)];start=now();timed_out=False
 try:
  p=subprocess.run(argv,cwd=W/'lean',capture_output=True,timeout=90);stdout,stderr,code=p.stdout,p.stderr,p.returncode
 except subprocess.TimeoutExpired as err:
  stdout,stderr,code=err.stdout or b'',err.stderr or b'',None;timed_out=True
 end=now();(out/'stdout').write_bytes(stdout);(out/'stderr').write_bytes(stderr)
 errors=[line for line in stdout.decode(errors='replace').splitlines() if ': error:' in line or 'error:' in line]
 d={'argv':argv,'cwd':str(W/'lean'),'started_utc':start,'finished_utc':end,'exit':code,'timed_out':timed_out,'probe_sha256':h(path),'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),'stdout_sha256':h(out/'stdout'),'stderr_sha256':h(out/'stderr'),'error_count':len(errors),'error_headers':errors,'scope':'New root execution of exact frozen R22 author scratch proof. No author execution credit or production proof integration.','P19_accepted':False};put(out/'command.json',d)
 return {'probe':name,'exit':code,'timed_out':timed_out,'error_count':len(errors),'error_headers':errors}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:results=list(pool.map(run_probe,selected))
for row in m['files']:assert h(W/row['path'])==row['sha256']
put(O/'assessment.json',{'utc':now(),'candidate_archive_sha256':m['sha256'],'probes':results,'root_runs_not_author_runs':True,'production_source_changed':False,'P19_accepted':False});shutil.copy2(__file__,O/'verify.py');files={str(p.relative_to(O)):h(p) for p in O.rglob('*') if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'P19_accepted':False});print(json.dumps(results))
