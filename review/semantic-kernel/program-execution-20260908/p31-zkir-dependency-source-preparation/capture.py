from pathlib import Path, PurePosixPath
import concurrent.futures,datetime,hashlib,json,shutil,tarfile,tomllib,urllib.request,urllib.error
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p31-zkir-dependency-source-preparation';O.mkdir(exist_ok=False)
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
start=now();shutil.copy2(__file__,O/'capture.py');(O/'inputs').mkdir()
source=B/'p31-zkir-source-preparation/crate/midnight-zkir-2.1.0'
for n in ['Cargo.lock','Cargo.toml','Cargo.toml.orig','.cargo_vcs_info.json']:shutil.copy2(source/n,O/'inputs'/n)
lock=tomllib.loads((O/'inputs/Cargo.lock').read_text());pkgs=[p for p in lock['package'] if p['name'].startswith('midnight-') and p['name']!='midnight-zkir'];assert len(pkgs)==12
put(O/'scope.json',{'started_utc':start,'input_source':str(source),'input_bindings':{str(p.relative_to(O)):sha(p) for p in (O/'inputs').iterdir()},'selection':'Every midnight-* package in exact captured midnight-zkir2.1.0 Cargo.lock, excluding already captured root midnight-zkir. Source acquisition only.','selected_packages':pkgs,'lock_packages':len(lock['package']),'external_boundary':[{'name':p['name'],'version':p['version'],'source':p.get('source'),'checksum':p.get('checksum')} for p in lock['package'] if not p['name'].startswith('midnight-')],'network_sources':['https://crates.io/api/v1/crates/<name>/<version>','https://static.crates.io/crates/<name>/<name>-<version>.crate'],'build_or_downloaded_source_execution':False,'acceptance':False})
def fetch(url,dst):
 t=now();rec={'url':url,'started_utc':t,'request_headers':{'User-Agent':'DeFiFormal-source-evidence/1.0','Accept':'application/json' if url.startswith('https://crates.io/api') else 'application/octet-stream'}}
 try:
  req=urllib.request.Request(url,headers=rec['request_headers'])
  with urllib.request.urlopen(req,timeout=60) as response:
   rec.update(status=response.status,final_url=response.url,response_headers=list(response.headers.items()))
   data=response.read(60*1024*1024+1);assert len(data)<=60*1024*1024,'Response exceeds bounded60MiB'
   dst.write_bytes(data);rec.update(bytes=len(data),sha256=sha(dst));assert response.status==200
 except Exception as e:
  rec['error']=repr(e)
  if isinstance(e,urllib.error.HTTPError):
   dst.with_suffix(dst.suffix+'.http-error').write_bytes(e.read());rec['status']=e.code
  raise
 finally:
  rec['finished_utc']=now();put(dst.with_suffix(dst.suffix+'.http.json'),rec)
def capture(p):
 n,v=p['name'],p['version'];d=O/(n+'-'+v);d.mkdir();err=None
 try:
  meta=d/'registry.json';fetch(f'https://crates.io/api/v1/crates/{n}/{v}',meta);version=json.loads(meta.read_text())['version'];assert version['num']==v and version['crate']==n
  archive=d/(n+'-'+v+'.crate');fetch(f'https://static.crates.io/crates/{n}/{n}-{v}.crate',archive)
  digest=sha(archive);assert digest==p['checksum']==version['checksum'];assert archive.stat().st_size==version['crate_size']
  files=[];seen=set();total=0
  with tarfile.open(archive,'r:gz') as t:
   members=t.getmembers();assert len(members)<=20000
   for m in members:
    path=PurePosixPath(m.name);assert not path.is_absolute() and '..' not in path.parts and path.parts[0]==n+'-'+v
    assert m.isdir() or m.isfile(), 'Non-regular tar member refused: '+m.name
    if m.isdir():continue
    assert m.name not in seen;seen.add(m.name);total+=m.size;assert total<=200*1024*1024
    dest=d/'source'/str(path);dest.parent.mkdir(parents=True,exist_ok=True);data=t.extractfile(m).read();assert len(data)==m.size;dest.write_bytes(data)
    files.append({'path':str(dest.relative_to(O)),'tar_member':m.name,'bytes':m.size,'tar_mode':m.mode,'sha256':sha(dest)})
  crate_root=d/'source'/(n+'-'+v);vcs=crate_root/'.cargo_vcs_info.json';cargo=tomllib.loads((crate_root/'Cargo.toml').read_text())
  assert cargo['package']['name']==n and cargo['package']['version']==v
  receipt={'package':n,'version':v,'archive':str(archive.relative_to(O)),'archive_sha256':digest,'archive_bytes':archive.stat().st_size,'lock_checksum':p['checksum'],'registry_checksum':version['checksum'],'checksum_matches_both':True,'registry_repository':version.get('repository'),'license':cargo['package'].get('license'),'vcs':json.loads(vcs.read_text()) if vcs.exists() else None,'source_files':files,'file_count':len(files),'uncompressed_bytes':total,'build_or_execution':False,'acceptance':False}
  put(d/'receipt.json',receipt);print(json.dumps({'package':n,'version':v,'files':len(files),'bytes':total,'checksum_matches_both':True}),flush=True);return receipt
 except Exception as e:
  put(d/'failure.json',{'observed_utc':now(),'error':repr(e),'acceptance':False});return {'package':n,'version':v,'error':repr(e)}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:results=list(pool.map(capture,pkgs))
failures=[p for p in results if 'error' in p];put(O/'acquisition.json',{'started_utc':start,'finished_utc':now(),'packages':[{k:v for k,v in p.items() if k!='source_files'} for p in results],'failure_count':len(failures),'source_files':sum(p.get('file_count',0) for p in results),'acceptance':False,'semantic_contract_accepted':False,'whole_dependency_build_closure':False})
(O/'README.md').write_text('# P31 locked Midnight dependency sources\n\nThis packet captures the twelve `midnight-*` dependencies selected from the published ZKIR2.1.0 Cargo.lock. Each successful source archive is checked against both that lock checksum and the registry version metadata, then extracted as regular files with original paths and hashes. HTTP request/response receipts, package licenses and published VCS metadata are retained.\n\nThis is source acquisition evidence. It does not establish the semantic interface, source-to-installed-binary correspondence, proof soundness, a reproducible build, or adapter acceptance. Non-Midnight dependencies in the lock remain an explicit uncaptured boundary in scope.json. No downloaded source, build script, compiler, circuit or proof was executed.\n')
put(O/'root-seal.json',{'schema':'defiformal-source-acquisition-seal/v1','utc':now(),'files':{str(p.relative_to(O)):sha(p) for p in sorted(O.rglob('*')) if p.is_file()},'acceptance':False})
print(json.dumps({'packages':len(results),'failures':failures,'source_files':sum(p.get('file_count',0) for p in results),'sealed':True}),flush=True)
if failures:raise SystemExit(1)
