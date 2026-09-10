from pathlib import Path
import urllib.request,json,hashlib,datetime,subprocess,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p25-balancer-compiler-preparation';C=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p25-solc');O.mkdir(exist_ok=False);C.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def get(url,path,limit):
 start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=60) as r:
  data=r.read(limit+1);assert len(data)<=limit;status=r.status;headers=dict(r.headers);final=r.url
 path.write_bytes(data);put(O/(path.name+'.http.json'),{'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'bytes':len(data),'sha256':h(path)});assert status==200;return data
lst=json.loads(get('https://binaries.soliditylang.org/linux-amd64/list.json',O/'list.json',2000000));name=lst['releases']['0.8.27'];build=next(x for x in lst['builds'] if x['path']==name);binary=C/name;get('https://binaries.soliditylang.org/linux-amd64/'+name,binary,50000000);assert h(binary)==build['sha256'].removeprefix('0x');binary.chmod(0o755)
start=now();cmd=[str(binary),'--version'];p=subprocess.run(cmd,capture_output=True,timeout=20);(O/'version.stdout').write_bytes(p.stdout);(O/'version.stderr').write_bytes(p.stderr);put(O/'version-command.json',{'argv':cmd,'cwd':str(Path.cwd()),'started_utc':start,'finished_utc':now(),'exit':p.returncode,'binary_sha256':h(binary),'stdout_sha256':h(O/'version.stdout'),'stderr_sha256':h(O/'version.stderr')});assert p.returncode==0 and build['longVersion'] in p.stdout.decode()
put(O/'compiler.json',{'utc':now(),'binary_path':str(binary),'binary_sha256':h(binary),'official_build':build,'reported_version':p.stdout.decode().strip(),'source_compilation':False,'acceptance':False});shutil.copy2(__file__,O/'capture.py');files={p.name:h(p) for p in O.iterdir() if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'binary_sha256':h(binary),'version':p.stdout.decode().strip(),'source_compilation':False}))
