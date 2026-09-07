import json,hashlib,subprocess,time,urllib.request,urllib.error
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');base=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';out=base/'justlend-v1-collateralization'
now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def write(name,value):
 p=out/name
 with p.open('x') as f:json.dump(value,f,indent=2);f.write('\n')
protected={str(p.relative_to(R)):h(p.read_bytes()) for root in [R/'corpus/normalized',R/'corpus50',base/'liquity-v1',base/'liquity-v1-redemption'] for p in root.rglob('*') if p.is_file()}
for p in [base/'disagreement-triage.json',base/'disagreement-triage.md',R/'openspec/changes/corpus-provenance-adjudication/dispute-inventory.json',R/'openspec/changes/corpus-provenance-adjudication/design.md']:protected[str(p.relative_to(R))]=h(p.read_bytes())
write('input-protection-before.json',{'created_utc':now(),'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'files':protected})
t=now();cmd=['git','ls-remote','https://github.com/justlend/justlend-protocol.git','HEAD','refs/heads/main'];result=subprocess.run(cmd,text=True,capture_output=True,timeout=30);rev=result.stdout.split()[0];assert len(rev)==40
write('revision-discovery.json',{'command':cmd,'started_utc':t,'finished_utc':now(),'returncode':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'selected_revision':rev,'scope':'Git ref metadata, not downloaded contract bodies or a verified deployment binding'})
targets=[('version-scope','https://docs.justlend.org/developers/justlend_v2/',None),('comptroller',f'https://raw.githubusercontent.com/justlend/justlend-protocol/{rev}/contracts/Comptroller.sol',rev),('ctoken',f'https://raw.githubusercontent.com/justlend/justlend-protocol/{rev}/contracts/CToken.sol',rev)]
records=[];(out/'captures').mkdir(exist_ok=True)
for sid,url,pin in targets:
 r={'source_id':sid,'requested_url':url,'source_revision':pin,'started_utc':now(),'independence_key':'justlend-official','scope':'JustLend pooled jToken architecture; corpus V1 applicability assessed separately','attempts':[]}
 for attempt in range(1,3):
  rec={'attempt':attempt,'started_utc':now()};start=time.monotonic()
  try:
   req=urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-research/1.0','Accept-Encoding':'identity'})
   with urllib.request.urlopen(req,timeout=30) as response:
    body=response.read(5*1024*1024+1);assert len(body)<=5*1024*1024
    digest=h(body);p=out/'captures'/digest
    if not p.exists():p.write_bytes(body)
    rec.update({'http_status':response.status,'final_url':response.url,'headers':dict(response.headers),'body_bytes':len(body),'body_sha256':digest,'capture_path':str(p.relative_to(R)),'status':'retained'})
  except Exception as e:rec.update({'status':'failed','error_type':type(e).__name__,'error':str(e)})
  rec['finished_utc']=now();rec['elapsed_seconds']=time.monotonic()-start;r['attempts'].append(rec)
  if rec['status']=='retained':break
 r['status']=r['attempts'][-1]['status'];records.append(r)
write('retrievals.json',{'schema_version':1,'unit_id':'unit:lane1:c1:p3','dispute_id':'dispute-01','scope':'One-unit primary source acquisition; no corpus edits or accepted disposition','bounds':{'primary_body_cap':3,'distinct_target_urls':3,'max_attempts_per_url':2,'timeout_seconds':30,'max_body_bytes':5*1024*1024},'hash_scope':'Exact response.read() body bytes, Accept-Encoding identity, headers excluded; no text normalization','records':records})
print(json.dumps([{'source_id':r['source_id'],'status':r['status'],'last_attempt':{k:v for k,v in r['attempts'][-1].items() if k!='headers'}} for r in records],indent=2))
