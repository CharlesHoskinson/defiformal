from pathlib import Path
import concurrent.futures,datetime,hashlib,json,urllib.request,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p28-depeg-dependency-discovery';O.mkdir(exist_ok=False);now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def fetch(d,name,url):
 start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence','Accept':'application/vnd.github+json'}),timeout=60) as r:
  body=r.read(25*1024*1024+1);status=r.status;headers=dict(r.headers);final=r.url
 (d/(name+'.json')).write_bytes(body);(d/(name+'-http.json')).write_text(json.dumps({'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'bytes':len(body),'sha256':hashlib.sha256(body).hexdigest()},indent=2)+'\n');assert status==200 and len(body)<=25*1024*1024;return json.loads(body)
def run(row):
 alias,repo,ref,ident=row;d=O/ident;d.mkdir();c=fetch(d,'commit','https://api.github.com/repos/'+repo+'/commits/'+ref);t=fetch(d,'tree','https://api.github.com/repos/'+repo+'/git/trees/'+c['commit']['tree']['sha']+'?recursive=1');assert not t['truncated'] and t['sha']==c['commit']['tree']['sha'];paths=[x['path'] for x in t['tree'] if x['type']=='blob'];return {'alias':alias,'repository':repo,'configuration_ref':ref,'commit':c['sha'],'tree':t['sha'],'directory':ident,'blob_files':len(paths),'relevant_core_paths':[p for p in paths if any(x in p for x in ['PolicyDefaultFlow.sol','ProductService.sol','PolicyController.sol','PolicyModule.sol','TreasuryModule.sol'])]}
rows=[('@openzeppelin','OpenZeppelin/openzeppelin-contracts','v4.7.3','openzeppelin'),('@chainlink','smartcontractkit/chainlink','v1.10.0','chainlink'),('@etherisc/gif-interface','etherisc/gif-interface','3b0002a','gif-interface'),('@etherisc/gif-contracts','etherisc/gif-contracts','b58fd27','gif-contracts')]
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:result=list(pool.map(run,rows))
(O/'pins.json').write_text(json.dumps(result,indent=2)+'\n');shutil.copy2(__file__,O/'discover.py');print(json.dumps(result,indent=2))
