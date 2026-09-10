from pathlib import Path
import datetime, hashlib, json, urllib.request, shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
O=B/'p27-gmx-source-discovery'; O.mkdir(exist_ok=False)
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def fetch(name,url):
 start=now()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence','Accept':'application/vnd.github+json'}),timeout=50) as r:
  body=r.read();status=r.status;headers=dict(r.headers);final=r.url
 (O/(name+'.json')).write_bytes(body)
 (O/(name+'-http.json')).write_text(json.dumps({'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)},indent=2)+'\n')
 assert status==200
 return json.loads(body)
c=fetch('commit','https://api.github.com/repos/gmx-io/gmx-synthetics/commits/main')
t=fetch('tree','https://api.github.com/repos/gmx-io/gmx-synthetics/git/trees/'+c['commit']['tree']['sha']+'?recursive=1')
assert t['sha']==c['commit']['tree']['sha'] and not t['truncated']
paths=[r['path'] for r in t['tree'] if r['type']=='blob']
shutil.copy2(__file__,O/'discover.py')
print(json.dumps({'commit':c['sha'],'tree':t['sha'],'files':len(paths),'selected_navigation':[p for p in paths if any(x in p for x in ['PositionUtils.sol','PositionCollateralUtils.sol','PositionPricingUtils.sol','LiquidationUtils.sol','MarketUtils.sol'])],'root_build_files':[p for p in paths if '/' not in p]},indent=2))
