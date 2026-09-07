import json,hashlib,subprocess,urllib.request,time,concurrent.futures
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');base=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';out=base/'batch-02-maple-lista-lido'
now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def write(p,d):
 with p.open('x') as f:json.dump(d,f,indent=2);f.write('\n')
freeze=R/'review/semantic-kernel/sprint10/planning/r2-candidate.json';frozen=json.loads(freeze.read_text());protected={x['path']:x['sha256'] for x in frozen['inputs']}
for root in [R/'corpus/normalized',R/'corpus50',base]:
 for p in root.rglob('*'):
  if p.is_file() and out not in p.parents:protected[str(p.relative_to(R))]=h(p.read_bytes())
for f in ['design.md','dispute-inventory.json']:
 p=R/'openspec/changes/corpus-provenance-adjudication'/f;protected[str(p.relative_to(R))]=h(p.read_bytes())
assert all(h((R/p).read_bytes())==digest for p,digest in protected.items())
write(out/'input-protection-before.json',{'created_utc':now(),'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'s10_frozen_candidate':frozen['candidate'],'s10_manifest':str(freeze.relative_to(R)),'s10_manifest_sha256':h(freeze.read_bytes()),'s10_bound_input_count':len(frozen['inputs']),'files':protected})
cmd=['git','ls-remote','https://github.com/lista-dao/gitbook.git','HEAD','refs/heads/main'];t=now();result=subprocess.run(cmd,text=True,capture_output=True,timeout=30);rev=result.stdout.split()[0];assert len(rev)==40
write(out/'lista-revision-discovery.json',{'command':cmd,'started_utc':t,'finished_utc':now(),'returncode':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'selected_revision':rev,'scope':'Source-repository ref metadata; not deployed code binding'})
units=[('maple-allocation','unit:lane1:c1:p4','dispute-02',[
 ('actors','https://docs.maple.finance/technical-resources/protocol-overview/protocol-actors',None),('pool-manager','https://docs.maple.finance/technical-resources/pools/pool-manager',None),('open-loan-manager','https://docs.maple.finance/technical-resources/loan-managers/open-term-loan-manager',None)]),
 ('lista-cdp-roles','unit:lane1:c2:p3','dispute-03',[
 ('cdp-scope','https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd',None),('faq',f'https://raw.githubusercontent.com/lista-dao/gitbook/{rev}/faq.md',rev),('liquidation',f'https://raw.githubusercontent.com/lista-dao/gitbook/{rev}/protocol/loan-liquidation.md',rev)]),
 ('lido-curator','unit:lane1:c3:p0','dispute-05',[
 ('staking-router','https://docs.lido.fi/contracts/staking-router/',None),('node-operators','https://docs.lido.fi/contracts/node-operators-registry/',None),('protocol-levers','https://docs.lido.fi/guides/protocol-levers/',None)])]
def capture(unit):
 folder,uid,did,targets=unit;p=base/folder;p.mkdir();(p/'captures').mkdir();records=[]
 for sid,url,rev in targets:
  r={'source_id':sid,'url':url,'revision':rev,'independence_key':folder.split('-')[0]+'-official','attempts':[]}
  for n in range(1,3):
   attempt={'attempt':n,'started_utc':now(),'requested_url':url};t=time.monotonic()
   try:
    with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-research/1.0','Accept-Encoding':'identity'}),timeout=30) as resp:
     body=resp.read(5*1024*1024+1);assert len(body)<=5*1024*1024;digest=h(body);dest=p/'captures'/digest
     if not dest.exists():dest.write_bytes(body)
     attempt.update({'status':'retained','http_status':resp.status,'final_url':resp.url,'headers':dict(resp.headers),'capture_path':str(dest.relative_to(R)),'body_sha256':digest,'body_bytes':len(body)})
   except Exception as e:attempt.update({'status':'failed','error_type':type(e).__name__,'error':str(e)})
   attempt.update({'finished_utc':now(),'elapsed_seconds':time.monotonic()-t});r['attempts'].append(attempt)
   if attempt['status']=='retained':break
  r['status']=r['attempts'][-1]['status'];records.append(r)
 write(p/'retrievals.json',{'schema_version':1,'unit_id':uid,'dispute_id':did,'scope':'One unit, three primary body maximum; source research, no accepted corpus label','bounds':{'max_primary_bodies':3,'max_target_urls':3,'max_attempts_per_url':2,'timeout_seconds':30,'max_body_bytes':5*1024*1024},'hash_scope':'Actual response body bytes with Accept-Encoding identity; headers excluded; no text normalization','records':records})
 return {'folder':folder,'unit_id':uid,'dispute_id':did,'sources':[{'id':r['source_id'],'status':r['status'],'bytes':r['attempts'][-1].get('body_bytes')} for r in records]}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:results=list(executor.map(capture,units))
write(out/'capture-outcomes.json',{'created_utc':now(),'units':results});print(json.dumps(results,indent=2))
