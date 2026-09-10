from pathlib import Path
import json,hashlib,base64,tarfile,datetime,sys,shutil,re,posixpath
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p25-balancer-dependency-preparation';S=B/'p25-balancer-source-preparation';O=B/'p25-balancer-dependency-root-verification';O.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();start=now()
seal=read(P/'root-seal.json')
for n,digest in seal['files'].items():assert h(P/n)==digest,n
for f in P.rglob('*.http.json'):
 body=f.with_name(f.name[:-len('.http.json')]);rec=read(f);assert h(body)==rec['sha256'] and body.stat().st_size==rec['bytes'] and rec['status']==200
registry=read(P/'openzeppelin/registry.json');oz=(P/'openzeppelin/archive.tgz').read_bytes();assert registry['version']=='5.4.0';assert registry['dist']['integrity']=='sha512-'+base64.b64encode(hashlib.sha512(oz).digest()).decode();assert registry['dist']['shasum']==hashlib.sha1(oz).hexdigest()
commit=read(P/'permit2/commit.json');tree=read(P/'permit2/tree.json');assert commit['sha']=='cc56ad0f3439c502c246fc5cfcc3db92bb8b7219';assert tree['sha']==commit['commit']['tree']['sha'] and not tree['truncated'];blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'}
archives={}
for package,name in [('openzeppelin','archive.tgz'),('permit2','archive.tar.gz')]:
 with tarfile.open(P/package/name) as tar:
  entries={}
  for member in tar.getmembers():
   parts=Path(member.name).parts;assert parts and not Path(member.name).is_absolute() and '..' not in parts
   if not member.isfile():continue
   body=tar.extractfile(member).read();path='/'.join(parts[1:]);entries[path]=body
   if package=='permit2':assert hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest()==blobs[path]['sha'],path
  archives[package]=entries
m=read(P/'imports.json');assert m['lock_sha256']==h(S/'source/yarn.lock');assert m['balancer_commit']==read(S/'source-manifest.json')['commit'];selected={(x['package'],x['path']):x for x in m['files']};assert len(selected)==len(m['files'])==98
for key,row in selected.items():
 p=Path(row['stored_path']);assert h(p)==row['sha256'];assert p.stat().st_size==row['bytes']
 if key[0]!='balancer':assert p.read_bytes()==archives[key[0]][key[1]]
 else:
  old=next(x for x in read(S/'source-manifest.json')['files'] if x['upstream_path']==key[1]);assert row['sha256']==old['sha256']
aliases=read(S/'source-manifest.json')['package_aliases'];actual_edges=[]
for (package,path),row in selected.items():
 text=Path(row['stored_path']).read_text()
 for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
  spec=match.group(1)
  if spec.startswith('.'):target=(package,posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)))
  elif spec.startswith('@openzeppelin/contracts/'):target=('openzeppelin',spec.removeprefix('@openzeppelin/contracts/'))
  elif spec.startswith('permit2/'):target=('permit2',spec.removeprefix('permit2/'))
  else:
   matches=[(alias,base) for alias,base in aliases.items() if spec.startswith(alias+'/')];assert len(matches)==1,spec;alias,base=matches[0];target=('balancer',base+spec[len(alias):])
  assert target in selected,target;actual_edges.append((package,path,text[:match.start()].count('\n')+1,spec,*target))
reported=[(e['from_package'],e['from'],e['line'],e['import'],e['target_package'],e['target_path']) for e in m['edges']];assert sorted(actual_edges)==sorted(reported);assert len(reported)==m['edge_count']==308 and not m['unresolved']
result={'started_utc':start,'finished_utc':now(),'argv':[str(Path(sys.executable).resolve()),str(Path(__file__).resolve())],'cwd':str(Path.cwd()),'python_sha256':h(Path(sys.executable).resolve()),'sealed_files_verified':len(seal['files']),'source_files_verified':len(selected),'import_edges_verified':len(reported),'npm_sha512_and_sha1_verified':True,'permit2_archive_git_blob_members_verified':len(archives['permit2']),'counts':m['counts'],'source_import_paths_unresolved':0,'compiler_resolution_verified':False,'test_import_closure_verified':False,'source_execution':False,'network_requests':0,'P25_accepted':False}
put(O/'result.json',result);shutil.copy2(__file__,O/'verify.py');files={p.name:h(p) for p in O.iterdir() if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps(result))
