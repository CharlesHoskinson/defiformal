from pathlib import Path
import datetime,hashlib,json,urllib.request,shutil,concurrent.futures
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p28-insurance-source-discovery';O.mkdir(exist_ok=False);now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def fetch(folder,name,url):
 start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence','Accept':'application/vnd.github+json'}),timeout=50) as r:
  body=r.read(15*1024*1024+1);status=r.status;headers=dict(r.headers);final=r.url
 assert len(body)<=15*1024*1024 and status==200
 (folder/(name+'.json')).write_bytes(body);(folder/(name+'-http.json')).write_text(json.dumps({'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)},indent=2)+'\n');return json.loads(body)
def discover(repo):
 d=O/repo.split('/')[1];d.mkdir();meta=fetch(d,'repository','https://api.github.com/repos/'+repo);c=fetch(d,'commit','https://api.github.com/repos/'+repo+'/commits/'+meta['default_branch']);t=fetch(d,'tree','https://api.github.com/repos/'+repo+'/git/trees/'+c['commit']['tree']['sha']+'?recursive=1');assert not t['truncated'] and t['sha']==c['commit']['tree']['sha'];paths=[x['path'] for x in t['tree'] if x['type']=='blob'];return {'repository':repo,'default_branch':meta['default_branch'],'commit':c['sha'],'tree':t['sha'],'file_count':len(paths),'contract_paths':[p for p in paths if p.endswith('.sol')],'root_configuration':[p for p in paths if '/' not in p]}
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:rows=list(pool.map(discover,['etherisc/esusfarm','etherisc/depeg-contracts']))
(O/'candidates.json').write_text(json.dumps(rows,indent=2)+'\n');shutil.copy2(__file__,O/'discover.py');print(json.dumps(rows,indent=2))
