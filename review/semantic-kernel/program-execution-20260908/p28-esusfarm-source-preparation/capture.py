from pathlib import Path
import concurrent.futures,datetime,hashlib,json,urllib.request,urllib.parse,shutil,re,posixpath
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');D=B/'p28-insurance-source-discovery/esusfarm';O=B/'p28-esusfarm-source-preparation'
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda x:hashlib.sha256(x).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
c=json.loads((D/'commit.json').read_text());tree=json.loads((D/'tree.json').read_text());assert not tree['truncated'] and tree['sha']==c['commit']['tree']['sha'];blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'};pin=c['sha']
seeds=['src/CropProduct.sol','src/AccountingToken.sol','src/Types.sol']
aux=['README.MD','LICENSE','foundry.toml','.gitmodules','pyproject.toml','uv.lock','test/CropProduct.t.sol','test/AccountingToken.t.sol','script/MockSetup.s.sol']
assert all(p in blobs for p in seeds+aux);O.mkdir(exist_ok=False);shutil.copytree(D,O/'discovery')
def fetch(path):
 url='https://raw.githubusercontent.com/etherisc/esusfarm/'+pin+'/'+urllib.parse.quote(path,safe='/');start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=50) as r:
  body=r.read(8*1024*1024+1);status=r.status;headers=dict(r.headers);final=r.url
 assert status==200 and len(body)<=8*1024*1024,path
 blob=hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest();assert blob==blobs[path]['sha'],path
 p=O/'source'/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(body)
 receipt=O/'http'/(path+'.json');receipt.parent.mkdir(parents=True,exist_ok=True);put(receipt,{'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'bytes':len(body),'sha256':sha(body),'git_blob_sha1':blob})
 return path,body
content={};queue=seeds[:];seen=set();local=[];external=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
 while queue:
  batch=sorted(set(queue)-seen);queue=[]
  if not batch:break
  results=list(pool.map(fetch,batch))
  for path,body in results:
   seen.add(path);content[path]=body;text=body.decode()
   for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
    spec=match.group(1);target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)) if spec.startswith('.') else spec
    row={'from':path,'import':spec,'line':text[:match.start()].count('\n')+1,'resolved':target if target in blobs else None}
    if target in blobs:local.append(row);queue.append(target)
    else:external.append(row)
 for path,body in pool.map(fetch,sorted(set(aux)-seen)):content[path]=body
records=[]
for path,body in sorted(content.items()):
 records.append({'path':'source/'+path,'upstream_path':path,'sha256':sha(body),'git_blob_sha1':blobs[path]['sha'],'bytes':len(body),'http_receipt':'http/'+path+'.json','role':'selected_import_source' if path in seen else ('unexecuted_reference_test' if (path.startswith('test/') or path.startswith('script/')) else 'configuration_or_documentation'),'url':'https://github.com/etherisc/esusfarm/blob/'+pin+'/'+path})
put(O/'source-manifest.json',{'schema':'defiformal-p28-source-candidate/v1','utc':now(),'repository':'https://github.com/etherisc/esusfarm','commit':pin,'tree':tree['sha'],'selection':'Observed official main HEAD; individually fetched pinned raw files checked against Git blob identities. Not deployed identity or accepted source-entry contract.','files':records,'file_count':len(records),'seeds':seeds,'traversed_source_files':len(seen),'local_import_edges':local,'unresolved_external_imports':external,'source_bytes':sum(r['bytes'] for r in records),'candidate_selection':'Etherisc crop-insurance product with explicit off-chain role and lifecycle; evaluate actual source before entry acceptance.','complete_archive_claimed':False,'compiler_import_closure_claimed':False,'test_import_closure_claimed':False,'source_execution':False,'P28_accepted':False})
shutil.copy2(__file__,O/'capture.py');print(json.dumps({'commit':pin,'source_files':len(records),'traversed_source_files':len(seen),'local_import_edges':len(local),'external_import_occurrences':len(external),'source_bytes':sum(r['bytes'] for r in records),'acceptance':False}))
