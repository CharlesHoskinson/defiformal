import json,hashlib,urllib.request,time
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');p=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research/tether-chain-swap'
now=lambda:datetime.now(timezone.utc).isoformat()
url='https://tether.io/news/explained-chain-swaps';rec={'source_id':'chain-swaps-destination','url':url,'revision':None,'independence_key':'tether-official','reason':'Explicit meta-refresh destination in retained official tether.to response; no script executed.','attempts':[]}
for n in range(1,3):
 a={'attempt':n,'started_utc':now(),'requested_url':url};t=time.monotonic()
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-research/1.0','Accept-Encoding':'identity'}),timeout=30) as r:
   body=r.read(5*1024*1024+1);assert len(body)<=5*1024*1024;h=hashlib.sha256(body).hexdigest();dest=p/'captures'/h
   if not dest.exists():dest.write_bytes(body)
   a.update(status='retained',http_status=r.status,final_url=r.url,headers=dict(r.headers),capture_path=str(dest.relative_to(R)),body_sha256=h,body_bytes=len(body))
 except Exception as e:a.update(status='failed',error_type=type(e).__name__,error=str(e))
 a.update(finished_utc=now(),elapsed_seconds=time.monotonic()-t);rec['attempts'].append(a)
 if a['status']=='retained':break
rec['status']=rec['attempts'][-1]['status']
with (p/'retrievals-pass2.json').open('x') as f:json.dump({'schema_version':1,'unit_id':'unit:lane3:c2:p0','dispute_id':'dispute-26','bounds':{'max_total_retained_bodies_including_redirects':3,'timeout_seconds':30,'max_attempts':2},'records':[rec]},f,indent=2);f.write('\n')
print(json.dumps(rec,indent=2))
