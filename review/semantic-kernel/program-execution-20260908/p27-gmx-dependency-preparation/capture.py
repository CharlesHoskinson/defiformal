from pathlib import Path,PurePosixPath
import base64,datetime,hashlib,io,json,posixpath,re,shutil,tarfile,urllib.request
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p27-gmx-source-preparation-attempt2';O=B/'p27-gmx-dependency-preparation';now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda b:hashlib.sha256(b).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
O.mkdir(exist_ok=False);shutil.copy2(__file__,O/'capture.py');lock=(P/'source/yarn.lock').read_text();sm=json.loads((P/'source-manifest.json').read_text());package_all={};packages=[]
for name,version,ident in [('@openzeppelin/contracts','4.9.3','openzeppelin'),('prb-math','2.4.3','prb-math')]:
 key=name+'@'+version;mt=re.search(r'^"?'+re.escape(key)+r'"?:\n((?:[ \t].*\n)+)',lock,re.M);assert mt,key;entry=mt.group(0);url=re.search(r'  resolved "([^"]+)"',entry).group(1);integrity=re.search(r'  integrity (\S+)',entry).group(1);download,expected_sha1=url.split('#');assert download.startswith('https://registry.yarnpkg.com/')
 start=now()
 with urllib.request.urlopen(urllib.request.Request(download,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=60) as r:
  data=r.read(20*1024*1024+1);status=r.status;headers=dict(r.headers);final=r.url
 assert status==200 and len(data)<=20*1024*1024
 assert hashlib.sha1(data).hexdigest()==expected_sha1
 assert integrity=='sha512-'+base64.b64encode(hashlib.sha512(data).digest()).decode()
 d=O/ident;d.mkdir();(d/'archive.tgz').write_bytes(data);(d/'lock-entry.txt').write_text(entry)
 put(d/'http.json',{'started_utc':start,'finished_utc':now(),'url':download,'final_url':final,'status':status,'headers':headers,'sha256':sha(data),'bytes':len(data)})
 members={};records=[]
 with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as t:
  for item in t.getmembers():
   pp=PurePosixPath(item.name);assert not pp.is_absolute() and '..' not in pp.parts and pp.parts[0]=='package'
   if item.isdir():continue
   assert item.isfile(),item.name
   assert item.name not in members
   body=t.extractfile(item).read();members[item.name]=body;records.append({'path':item.name,'sha256':sha(body),'bytes':len(body)})
 pkg=json.loads(members['package/package.json']);assert pkg['name']==name and pkg['version']==version
 package_all[name]=(ident,members);packages.append({'name':name,'version':version,'archive':ident+'/archive.tgz','archive_sha256':sha(data),'lock_integrity_sha512':integrity,'lock_sha1':expected_sha1,'lock_file_sha256':sha((P/'source/yarn.lock').read_bytes()),'members':records,'regular_members':len(records),'selected_files':[]})
content={r['upstream_path']:(P/r['path']).read_bytes() for r in sm['files'] if r['role']=='selected_import_source'};locations={p:str((P/'source'/p).relative_to(B)) for p in content};queue=list(content);seen=set();edges=[];unresolved=[]
while queue:
 path=queue.pop()
 if path in seen:continue
 seen.add(path);body=content[path];text=body.decode()
 for mt in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
  spec=mt.group(1);target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)) if spec.startswith('.') else spec
  if target not in content:
   for name,(ident,members) in package_all.items():
    if not target.startswith(name+'/'):continue
    member='package/'+target[len(name)+1:]
    if member not in members:continue
    data=members[member];content[target]=data;p=O/ident/'source'/target[len(name)+1:];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data);locations[target]=str(p.relative_to(B))
    pack=next(x for x in packages if x['name']==name);pack['selected_files'].append({'compiler_path':target,'archive_member':member,'path':str(p.relative_to(O)),'sha256':sha(data),'bytes':len(data)})
  row={'from':path,'import':spec,'line':text[:mt.start()].count('\n')+1,'resolved':target if target in content else None}
  (edges if target in content else unresolved).append(row)
  if target in content:queue.append(target)
assert not unresolved,unresolved
identity={'schema':'defiformal-p27-selected-source-dependencies/v1','utc':now(),'gmx_commit':sm['commit'],'source_packet_seal_sha256':sha((P/'root-seal.json').read_bytes()),'lock_path':'../p27-gmx-source-preparation-attempt2/source/yarn.lock','lock_sha256':sha((P/'source/yarn.lock').read_bytes()),'packages':packages,'compiler_source_count':len(content),'source_locations':locations,'source_hashes':{p:sha(data) for p,data in content.items()},'lexical_import_edges':edges,'unresolved_imports':unresolved,'compiler_executed':False,'package_scripts_executed':False,'test_closure_claimed':False,'P27_accepted':False}
put(O/'identity.json',identity)
(O/'README.md').write_text(f'''# Selected GMX source dependency capture

Root acquired OpenZeppelin Contracts4.9.3 and prb-math2.4.3 from exact GMX Yarn lock entries. Both complete package archives match the lock's SHA-512 integrity and SHA-1 URL fragments. No package installation or scripts ran. Safe regular archive members have explicit byte hashes; only reachable Solidity sources were copied for source inspection.

The78 selected GMX sources plus{len(content)-78} selected dependency sources form a lexical import closure of{len(content)} files and{len(edges)} import occurrences, with zero unresolved targets under this scanner. This does not establish Solidity compiler resolution, compile success, full repository/test dependency closure, EVM execution, deployed identity, mathematical validity or P27 acceptance. Configuration/compiler/runtime checks remain separate. Package archive contents are versioned upstream evidence, not root-authored implementation.
''')
put(O/'root-seal.json',{'utc':now(),'files':{str(p.relative_to(O)):sha(p.read_bytes()) for p in O.rglob('*') if p.is_file()},'P27_accepted':False});print(json.dumps({'sources':len(content),'edges':len(edges),'selected_deps':[(p['name'],len(p['selected_files']),p['regular_members']) for p in packages],'unresolved':0,'acceptance':False}))
