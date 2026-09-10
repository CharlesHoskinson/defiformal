from pathlib import Path
import concurrent.futures,datetime,hashlib,json,posixpath,re,shutil,urllib.request,urllib.parse
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p28-depeg-source-preparation';D=B/'p28-depeg-dependency-discovery';O=B/'p28-depeg-dependency-preparation';O.mkdir(exist_ok=False);shutil.copytree(D,O/'discovery');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda b:hashlib.sha256(b).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
pins=json.loads((D/'pins.json').read_text());blobs={}
for pin in pins:
 t=json.loads((D/pin['directory']/'tree.json').read_text());assert not t['truncated'] and t['sha']==pin['tree'];blobs[pin['alias']]={r['path']:r['sha'] for r in t['tree'] if r['type']=='blob'}
def locate(name):
 for pin in pins:
  if name.startswith(pin['alias']+'/'):
   path=name[len(pin['alias'])+1:]
   if path in blobs[pin['alias']]:return pin,path
 return None
records=[]
def fetch(name):
 pin,path=locate(name);url='https://raw.githubusercontent.com/'+pin['repository']+'/'+pin['commit']+'/'+urllib.parse.quote(path,safe='/');start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=60) as r:
  body=r.read(8*1024*1024+1);status=r.status;headers=dict(r.headers);final=r.url
 assert status==200 and len(body)<=8*1024*1024
 blob=hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest();assert blob==blobs[pin['alias']][path]
 p=O/'source'/pin['directory']/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(body);http=O/'http'/pin['directory']/(path+'.json');http.parent.mkdir(parents=True,exist_ok=True);put(http,{'started_utc':start,'finished_utc':now(),'url':url,'final_url':final,'status':status,'headers':headers,'sha256':sha(body),'git_blob_sha1':blob,'bytes':len(body)})
 return name,body,{'compiler_path':name,'path':str(p.relative_to(O)),'upstream_path':path,'alias':pin['alias'],'repository':pin['repository'],'commit':pin['commit'],'sha256':sha(body),'git_blob_sha1':blob,'bytes':len(body),'http_receipt':str(http.relative_to(O))}
m=json.loads((P/'source-manifest.json').read_text());content={r['upstream_path']:(P/r['path']).read_bytes() for r in m['files'] if r['role']=='selected_import_source'};locations={p:str((P/'source'/p).relative_to(B)) for p in content};extra=['@etherisc/gif-contracts/contracts/flows/PolicyDefaultFlow.sol','@etherisc/gif-contracts/contracts/services/ProductService.sol','@etherisc/gif-contracts/contracts/modules/PolicyController.sol'];queue=list(content)+extra;seen=set();edges=[];unresolved=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
 while queue:
  batch=sorted(set(queue)-seen);queue=[]
  if not batch:break
  missing=[p for p in batch if p not in content];assert all(locate(p) for p in missing),missing
  for name,body,r in pool.map(fetch,missing):content[name]=body;locations[name]=str((O/r['path']).relative_to(B));records.append(r)
  for path in batch:
   seen.add(path);text=content[path].decode()
   for mt in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
    spec=mt.group(1);target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)) if spec.startswith('.') else spec;resolved=target if target in content or locate(target) else None;row={'from':path,'import':spec,'line':text[:mt.start()].count('\n')+1,'resolved':resolved};(edges if resolved else unresolved).append(row)
    if resolved:queue.append(resolved)
 aux=[]
 for pin in pins:
  for name in ['LICENSE','LICENSE.txt','README.md','README.MD','brownie-config.yaml','package.json']:
   if name in blobs[pin['alias']]:aux.append(pin['alias']+'/'+name)
 for name,body,r in pool.map(fetch,aux):r['role']='configuration_or_license';records.append(r)
assert not unresolved,unresolved
result={'schema':'defiformal-p28-dependency-source/v1','utc':now(),'depeg_commit':m['commit'],'root_config_path':'../p28-depeg-source-preparation/source/brownie-config.yaml','root_config_sha256':sha((P/'source/brownie-config.yaml').read_bytes()),'configuration_route':'Brownie declared Git dependency refs; not npm package-lock route','pins':pins,'additional_workflow_seeds':extra,'selected_dependency_files':records,'dependency_solidity_count':len(content)-13,'compiler_source_count':len(content),'source_locations':locations,'source_hashes':{p:sha(data) for p,data in content.items()},'lexical_import_edges':edges,'unresolved_imports':unresolved,'compiler_executed':False,'dependency_install_executed':False,'full_runtime_workflow_proved':False,'P28_accepted':False};put(O/'identity.json',result);shutil.copy2(__file__,O/'capture.py');put(O/'root-seal.json',{'utc':now(),'files':{str(p.relative_to(O)):sha(p.read_bytes()) for p in O.rglob('*') if p.is_file()},'P28_accepted':False});print(json.dumps({'compiler_sources':len(content),'dependency_solidity_sources':len(content)-13,'auxiliary_files':len(aux),'dependency_captured_files':len(records),'lexical_import_edges':len(edges),'unresolved':len(unresolved),'acceptance':False}))
