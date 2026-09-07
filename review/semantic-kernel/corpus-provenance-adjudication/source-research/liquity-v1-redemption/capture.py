#!/usr/bin/env python3
"""Bounded fresh primary retrieval for the existing V1 redemption disagreement."""
from pathlib import Path
import datetime,hashlib,json,time,urllib.request,urllib.error
OUT=Path(__file__).resolve().parent
PIN='3e64ee1b52c50d51587c64c1cf75e0ba82934979'
URLS=[('v1-redemption-faq','https://docs.liquity.org/liquity-v1/faq/lusd-redemptions',None)]
MAX=20*1024*1024
class Redirects(urllib.request.HTTPRedirectHandler):
 max_redirections=5
 max_repeats=5
opener=urllib.request.build_opener(Redirects())
records=[]
for ident,url,revision in URLS:
 attempts=[]
 for attempt in range(1,4):
  start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic()
  row={'attempt':attempt,'requested_url':url,'started_utc':start}
  try:
   request=urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-bounded-source-research/1','Accept-Encoding':'identity'})
   with opener.open(request,timeout=30) as response:
    body=response.read(MAX+1)
    if len(body)>MAX:raise ValueError('20 MiB body limit exceeded')
    h=hashlib.sha256(body).hexdigest();path=OUT/'captures'/h
    path.parent.mkdir(exist_ok=True)
    if path.exists():assert path.read_bytes()==body
    else:path.write_bytes(body)
    row.update({'final_url':response.geturl(),'http_status':response.status,'headers':dict(response.headers.items()),'content_type':response.headers.get('Content-Type'),'body_sha256':h,'body_bytes':len(body),'capture_path':str(path.relative_to(OUT)),'capture_status':'retained','git_blob_sha1':hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest() if revision else None})
  except Exception as error:
   row.update({'capture_status':'unavailable','error_type':type(error).__name__,'error':str(error)})
  row.update({'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':round(time.monotonic()-tick,6)})
  attempts.append(row)
  if row['capture_status']=='retained':break
 record={'source_id':ident,'product':'Liquity V1 ETH/LUSD','repository':'https://github.com/liquity/dev' if revision else None,'source_revision':revision,'time_scope':'exact source at named commit' if revision else 'mutable V1 documentation at actual retrieval time','original_reference_status':'reconstructed_support; no original citation token or attachment recovered','exposure':'existing development case; not holdout','attempts':attempts,'status':attempts[-1]['capture_status']}
 records.append(record)
 (OUT/'retrievals.json').write_text(json.dumps({'schema_version':1,'challenge_id':'dispute-04','scope':'Fresh source research only, no implemented collector or accepted corpus overlay.','limits':{'distinct_urls':1,'max_attempts_per_url':3,'socket_timeout_seconds':30,'max_redirects':5,'max_body_bytes':MAX},'hash_scope':'Exact HTTP response-body bytes as returned with Accept-Encoding identity; headers excluded, no text normalization.','records':records},indent=2)+'\n')
 print(ident,attempts[-1]['capture_status'],attempts[-1].get('body_bytes'),attempts[-1].get('body_sha256'))
assert len(records)==1 and all(r['status']=='retained' for r in records)
