import json,urllib.request,time,hashlib
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');p=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research/jupiter-jlp';now=lambda:datetime.now(timezone.utc).isoformat();records=[]
for sid,url,discovery in [('jlp-guide-current','https://docs.jup.ag/perps/jlp','Bounded fallback after old hub JLP guide404; still only2retained primary bodies before this request; validity determined by actual response')]:
 r={'source_id':sid,'url':url,'revision':None,'independence_key':'jupiter-official','discovery':discovery,'attempts':[]}
 a={'attempt':1,'requested_url':url,'started_utc':now()};t=time.monotonic()
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-research/1.0','Accept-Encoding':'identity'}),timeout=30) as resp:
   body=resp.read(5*1024*1024+1);assert len(body)<=5*1024*1024;digest=hashlib.sha256(body).hexdigest();f=p/'captures'/digest
   if not f.exists():f.write_bytes(body)
   a.update({'status':'retained' if resp.status==200 and body else 'retained_unusable','http_status':resp.status,'final_url':resp.url,'headers':dict(resp.headers),'capture_path':str(f.relative_to(R)),'body_sha256':digest,'body_bytes':len(body)})
 except Exception as e:a.update({'status':'failed','error_type':type(e).__name__,'error':str(e)})
 a.update({'finished_utc':now(),'elapsed_seconds':time.monotonic()-t});r['attempts'].append(a);r['status']=a['status'];records.append(r)
with (p/'retrievals-pass3.json').open('x') as f:json.dump({'scope':'One remaining primarybody slot after two retained developer documents and one failed old guide URL; explicitly separate fallback pass; same unit and unchanged3body cap','max_combined_retained_bodies':3,'records':records},f,indent=2);f.write('\n')
print(json.dumps([{'id':r['source_id'],'attempt':{k:v for k,v in r['attempts'][0].items() if k!='headers'}} for r in records],indent=2))
