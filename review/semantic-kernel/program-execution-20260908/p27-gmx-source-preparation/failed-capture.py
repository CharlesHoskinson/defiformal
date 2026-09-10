from pathlib import Path,PurePosixPath
import datetime,hashlib,json,urllib.request,tarfile,shutil,re,posixpath
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');D=B/'p27-gmx-source-discovery';O=B/'p27-gmx-source-preparation';C=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p27-gmx-source')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda x:hashlib.sha256(x).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
c=json.loads((D/'commit.json').read_text());tree=json.loads((D/'tree.json').read_text());assert not tree['truncated'] and tree['sha']==c['commit']['tree']['sha'];blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'}
seeds=['contracts/liquidation/LiquidationUtils.sol','contracts/market/MarketUtils.sol','contracts/position/DecreasePositionCollateralUtils.sol','contracts/position/DecreasePositionUtils.sol','contracts/position/IncreasePositionUtils.sol','contracts/position/PositionUtils.sol','contracts/pricing/PositionPricingUtils.sol']
aux=['LICENSE','README.md','package.json','yarn.lock','hardhat.config.ts','foundry.toml','.gitmodules','.nvmrc','test/exchange/FundingFees/AdaptiveFunding.ts','test/exchange/FundingFees/PairMarket.ts','test/exchange/LiquidationOrder.ts']
assert all(p in blobs for p in seeds+aux)
O.mkdir(exist_ok=False);C.mkdir(exist_ok=False);shutil.copytree(D,O/'discovery');pin=c['sha'];arc=C/(pin+'.tar.gz');url='https://codeload.github.com/gmx-io/gmx-synthetics/tar.gz/'+pin;start=now();size=0
with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=50) as response:
 status=response.status;headers=dict(response.headers);final=response.url
 with arc.open('xb') as out:
  while data:=response.read(1024*1024):
   size+=len(data);assert size<=100*1024*1024;out.write(data)
put(O/'archive-http.json',{'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'sha256':sha(arc.read_bytes()),'bytes':size,'archive_cache_path':str(arc),'archive_published':False});assert status==200
with tarfile.open(arc) as tar:
 members={};links=[]
 for member in tar.getmembers():
  parts=PurePosixPath(member.name).parts;assert parts and '..' not in parts and not member.name.startswith('/')
  if member.isfile():
   path='/'.join(parts[1:]);assert path not in members;members[path]=member
  elif member.issym() or member.islnk():links.append({'path':member.name,'target':member.linkname,'extracted':False})
 def get(path):
  data=tar.extractfile(members[path]).read();blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest();assert blob==blobs[path]['sha'],path;return data
 queue=seeds[:];seen=set();local=[];external=[]
 while queue:
  path=queue.pop(0)
  if path in seen:continue
  seen.add(path);data=get(path);text=data.decode()
  for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
   spec=match.group(1);target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)) if spec.startswith('.') else spec
   row={'from':path,'import':spec,'line':text[:match.start()].count('\n')+1,'resolved':target if target in blobs else None}
   if target in blobs:local.append(row);queue.append(target)
   else:external.append(row)
 records=[]
 for path in sorted(seen|set(aux)):
  data=get(path);q=O/'source'/path;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(data);records.append({'path':'source/'+path,'upstream_path':path,'sha256':sha(data),'git_blob_sha1':blobs[path]['sha'],'bytes':len(data),'role':'selected_import_source' if path in seen else ('unexecuted_reference_test' if path.startswith('test/') else 'configuration_or_documentation'),'url':'https://github.com/gmx-io/gmx-synthetics/blob/'+pin+'/'+path})
put(O/'source-manifest.json',{'schema':'defiformal-p27-source-candidate/v1','utc':now(),'repository':'https://github.com/gmx-io/gmx-synthetics','commit':pin,'tree':tree['sha'],'selection':'Observed official main HEAD; source candidate, not deployed contract identity or accepted P27 source-entry contract.','seeds':seeds,'files':records,'file_count':len(records),'traversed_source_files':len(seen),'local_import_edges':local,'unresolved_external_imports':external,'archive_regular_members':len(members),'archive_links_not_extracted':links,'compiler_import_closure_claimed':False,'test_import_closure_claimed':False,'source_execution':False,'P27_accepted':False})
shutil.copy2(__file__,O/'capture.py');print(json.dumps({'commit':pin,'source_files':len(records),'traversed_source_files':len(seen),'local_import_edges':len(local),'external_import_occurrences':len(external),'archive_bytes':size,'archive_regular_members':len(members),'acceptance':False}))
