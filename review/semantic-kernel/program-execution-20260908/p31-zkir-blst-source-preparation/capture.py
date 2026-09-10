from pathlib import Path,PurePosixPath
import datetime,hashlib,json,shutil,tarfile,tomllib,urllib.request,urllib.error
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p31-zkir-blst-source-preparation';O.mkdir(exist_ok=False)
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');start=now();shutil.copy2(__file__,O/'capture.py')
lockpath=B/'p31-zkir-dependency-source-preparation/inputs/Cargo.lock';lock=tomllib.loads(lockpath.read_text());pkgs=[p for p in lock['package'] if p['name']=='blst'];assert len(pkgs)==1;p=pkgs[0];assert p['version']=='0.3.16';shutil.copy2(lockpath,O/'Cargo.lock');n,v=p['name'],p['version']
def fetch(url,dst):
 rec={'started_utc':now(),'url':url,'request_headers':{'User-Agent':'DeFiFormal-source-evidence/1.0'}}
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers=rec['request_headers']),timeout=60) as response:
   rec.update(status=response.status,final_url=response.url,response_headers=list(response.headers.items()));data=response.read(60*1024*1024+1);assert len(data)<=60*1024*1024;dst.write_bytes(data);rec.update(bytes=len(data),sha256=sha(dst));assert response.status==200
 except Exception as e:
  rec['error']=repr(e)
  if isinstance(e,urllib.error.HTTPError):dst.with_suffix(dst.suffix+'.http-error').write_bytes(e.read());rec['status']=e.code
  raise
 finally:rec['finished_utc']=now();put(dst.with_suffix(dst.suffix+'.http.json'),rec)
try:
 fetch(f'https://crates.io/api/v1/crates/{n}/{v}',O/'registry.json');reg=json.loads((O/'registry.json').read_text())['version'];archive=O/f'{n}-{v}.crate';fetch(f'https://static.crates.io/crates/{n}/{n}-{v}.crate',archive);assert sha(archive)==reg['checksum']==p['checksum'];assert archive.stat().st_size==reg['crate_size'];assert reg['num']==v and reg['crate']==n
 files=[];seen=set();total=0
 with tarfile.open(archive) as t:
  members=t.getmembers();assert len(members)<20000
  for m in members:
   q=PurePosixPath(m.name);assert not q.is_absolute() and '..' not in q.parts and q.parts[0]==f'{n}-{v}';assert m.isdir() or m.isfile(),m.name
   if m.isdir():continue
   assert m.name not in seen;seen.add(m.name);total+=m.size;assert total<200*1024*1024;dst=O/'source'/str(q);dst.parent.mkdir(parents=True,exist_ok=True);data=t.extractfile(m).read();assert len(data)==m.size;dst.write_bytes(data);files.append({'path':str(dst.relative_to(O)),'tar_member':m.name,'bytes':m.size,'tar_mode':m.mode,'sha256':sha(dst)})
 root=O/'source'/f'{n}-{v}';cargo=tomllib.loads((root/'Cargo.toml').read_text());assert cargo['package']['name']==n and cargo['package']['version']==v;vcs=root/'.cargo_vcs_info.json'
 put(O/'receipt.json',{'schema':'defiformal-locked-field-dependency-source/v1','started_utc':start,'finished_utc':now(),'package':n,'version':v,'lock_path':str(lockpath),'lock_sha256':sha(lockpath),'archive':archive.name,'archive_sha256':sha(archive),'archive_bytes':archive.stat().st_size,'lock_checksum':p['checksum'],'registry_checksum':reg['checksum'],'checksum_matches_both':True,'license':cargo['package'].get('license'),'repository':cargo['package'].get('repository'),'published_vcs_metadata':json.loads(vcs.read_text()) if vcs.exists() else None,'source_files':files,'file_count':len(files),'uncompressed_bytes':total,'dependencies_from_frozen_root_lock':p['dependencies'],'reason':'Captured midnight-curves Fq source calls blst_fr_add and related operations; this captures the exact locked implementation source.','build_script_execution':False,'downloaded_source_execution':False,'complete_build_closure':False,'acceptance':False})
 (O/'README.md').write_text('# P31 locked blst source\n\nThe exact ZKIR2.1.0 lock selects blst0.3.16. Its archive matches both the lock and registry checksums. This packet retains the published source, native implementation, assembly, build script, license, VCS metadata and HTTP receipts. No downloaded code or build script was executed.\n\nThis closes the source-acquisition gap for the named field-arithmetic dependency identified in the root navigation packet. It does not prove arithmetic correctness, circuit correspondence, source-to-installed-binary correspondence or adapter acceptance. Platform-specific implementation selection and the remaining external dependencies remain explicit assumptions/obligations.\n')
 put(O/'root-seal.json',{'utc':now(),'files':{str(q.relative_to(O)):sha(q) for q in sorted(O.rglob('*')) if q.is_file()},'acceptance':False});print(json.dumps({'package':n,'version':v,'files':len(files),'archive_bytes':archive.stat().st_size,'uncompressed_bytes':total,'checksum_matches_both':True,'acceptance':False}))
except Exception as e:
 put(O/'failure.json',{'observed_utc':now(),'error':repr(e),'acceptance':False});raise
