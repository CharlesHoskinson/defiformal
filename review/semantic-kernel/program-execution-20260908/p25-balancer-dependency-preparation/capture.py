from pathlib import Path, PurePosixPath
import json,hashlib,datetime,urllib.request,tarfile,base64,re,posixpath,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p25-balancer-source-preparation';O=B/'p25-balancer-dependency-preparation';O.mkdir(exist_ok=False)
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda d:hashlib.sha256(d).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
lock=(P/'source/yarn.lock').read_text();assert 'resolution: "@openzeppelin/contracts@npm:5.4.0"' in lock;pin='cc56ad0f3439c502c246fc5cfcc3db92bb8b7219';assert 'resolution: "permit2@https://github.com/Uniswap/permit2.git#commit='+pin+'"' in lock
for name in ['openzeppelin','permit2']:(O/name).mkdir()
def get(url,path):
 start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=60) as r:
  data=r.read(32*1024*1024+1);assert len(data)<=32*1024*1024;status=r.status;headers=dict(r.headers);final=r.url
 path.write_bytes(data);put(path.with_name(path.name+'.http.json'),{'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'sha256':sha(data),'bytes':len(data)});assert status==200;return data
registry=json.loads(get('https://registry.npmjs.org/@openzeppelin%2fcontracts/5.4.0',O/'openzeppelin/registry.json'));assert registry['name']=='@openzeppelin/contracts' and registry['version']=='5.4.0';oz=get(registry['dist']['tarball'],O/'openzeppelin/archive.tgz');sri=registry['dist']['integrity'];algorithm,want=sri.split('-',1);assert algorithm=='sha512' and base64.b64encode(hashlib.sha512(oz).digest()).decode()==want;assert hashlib.sha1(oz).hexdigest()==registry['dist']['shasum']
commit=json.loads(get('https://api.github.com/repos/Uniswap/permit2/commits/'+pin,O/'permit2/commit.json'));assert commit['sha']==pin
tree=json.loads(get(commit['commit']['tree']['url']+'?recursive=1',O/'permit2/tree.json'));assert tree['sha']==commit['commit']['tree']['sha'] and not tree['truncated'];get('https://codeload.github.com/Uniswap/permit2/tar.gz/'+pin,O/'permit2/archive.tar.gz');blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'}
archives={};metadata=[]
for name,file in [('openzeppelin','archive.tgz'),('permit2','archive.tar.gz')]:
 tar=tarfile.open(O/name/file);data={}
 for item in tar.getmembers():
  parts=PurePosixPath(item.name).parts;assert parts and not item.name.startswith('/') and '..' not in parts
  if item.isfile():
   assert item.size<=8*1024*1024;path='/'.join(parts[1:]);body=tar.extractfile(item).read()
   if name=='permit2':assert hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest()==blobs[path]['sha'],path
   data[path]=body
 archives[name]=data;tar.close()
 for path in ['LICENSE','LICENSE.md','package.json']:
  if path in data:
   dest=O/name/'metadata'/path;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data[path]);metadata.append(str(dest.relative_to(O)))
m=json.loads((P/'source-manifest.json').read_text());aliases=m['package_aliases'];selected={};queue=[('balancer',x) for x in m['seeds']];edges=[];unresolved=[]
def data_for(package,path):
 return (P/'source'/path).read_bytes() if package=='balancer' else archives[package][path]
while queue:
 package,path=queue.pop(0);key=(package,path)
 if key in selected:continue
 data=data_for(package,path);selected[key]=data;text=data.decode()
 for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
  spec=match.group(1);target=None
  if spec.startswith('.'):target=(package,posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)))
  elif spec.startswith('@openzeppelin/contracts/'):target=('openzeppelin',spec[len('@openzeppelin/contracts/'):])
  elif spec.startswith('permit2/'):target=('permit2',spec[len('permit2/'):])
  else:
   for alias,base in aliases.items():
    if spec.startswith(alias+'/'):target=('balancer',base+spec[len(alias):]);break
  exists=target and ((P/'source'/target[1]).is_file() if target[0]=='balancer' else target[1] in archives[target[0]])
  row={'from_package':package,'from':path,'line':text[:match.start()].count('\n')+1,'import':spec,'target_package':target[0] if exists else None,'target_path':target[1] if exists else None}
  if exists:edges.append(row);queue.append(target)
  else:unresolved.append(row)
assert not unresolved,unresolved
records=[]
for (package,path),data in sorted(selected.items()):
 if package=='balancer':dest=P/'source'/path
 else:dest=O/package/'source'/path;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
 records.append({'package':package,'path':path,'stored_path':str(dest),'sha256':sha(data),'bytes':len(data),'git_blob_sha1':blobs[path]['sha'] if package=='permit2' else None})
counts={k:sum(r['package']==k for r in records) for k in ['balancer','openzeppelin','permit2']}
put(O/'imports.json',{'utc':now(),'balancer_commit':m['commit'],'permit2_commit':pin,'openzeppelin_version':'5.4.0','lock_sha256':sha((P/'source/yarn.lock').read_bytes()),'seeds':m['seeds'],'files':records,'counts':counts,'edges':edges,'edge_count':len(edges),'unresolved':unresolved,'scope':'Lexical source import traversal from seven production/router/mock seeds; excludes reference test closure and compiler resolution.','source_execution':False,'acceptance':False})
put(O/'identity.json',{'utc':now(),'npm_integrity':sri,'npm_shasum':registry['dist']['shasum'],'npm_archive_sha256':sha(oz),'permit2_commit':pin,'permit2_archive_sha256':sha((O/'permit2/archive.tar.gz').read_bytes()),'permit2_all_archive_file_git_blobs_verified':len(archives['permit2']),'yarn_checksums':'Yarn cache-container checksums retained in upstream lock; not equated to downloaded archive integrity.','package_install':False,'compiler_build':False,'test_execution':False,'acceptance':False})
shutil.copy2(__file__,O/'capture.py');(O/'README.md').write_text(f'''# P25 locked dependency sources\n\nOpenZeppelin Contracts 5.4.0 and Permit2 `{pin}` come from the captured Balancer lock. The npm archive matches registry SHA-512 integrity and SHA-1 shasum. Permit2 archive members match the explicit commit tree's Git blob identities. Yarn cache checksums are not raw archive digests.\n\nSource traversal from seven vault/router/mock seeds resolves {len(edges)} imports across {counts['balancer']} Balancer, {counts['openzeppelin']} OpenZeppelin, and {counts['permit2']} Permit2 files, with zero unresolved lexical paths. The reference Foundry tests are outside this import closure. This is not compiler import resolution, a package install, an executed Solidity test, a Lean proof, source-to-deployment fidelity, or P25 acceptance. Token and Permit2 implementation behavior and actual compiler/runtime identities still need the later contract and execution work.\n''')
files={str(p.relative_to(O)):sha(p.read_bytes()) for p in O.rglob('*') if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'counts':counts,'edges':len(edges),'unresolved':len(unresolved),'sealed_files':len(files),'acceptance':False}))
