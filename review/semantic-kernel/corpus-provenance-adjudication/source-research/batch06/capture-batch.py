"""Bounded batch06 capture: three distinct primary targets per unit, no corpus writes."""
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime,timezone
import hashlib,json,subprocess,urllib.request,urllib.error
from pathlib import Path
OUT=Path(__file__).resolve().parent; ROOT=OUT.parents[4]; BASE=OUT.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
now=lambda:datetime.now(timezone.utc).isoformat()
def write(p,x):
 with p.open('x') as f:json.dump(x,f,indent=2);f.write('\n')
CONFIG={
 'coinbase-cbbtc':{'unit':'unit:lane2:c2:p2','disputes':[21,22],'targets':[
 ('whitepaper','https://coinbase.bynder.com/m/1303c2f4d78fc966/original/cbBTC-White-Paper.pdf'),
 ('help','https://help.coinbase.com/en/coinbase/trading-and-funding/sending-or-receiving-cryptocurrency/coinbase-wrapped-btc'),
 ('terms','https://www.coinbase.com/legal/user_agreement/united_states')]},
 'btcb-cross-domain':{'unit':'unit:lane2:c2:p4','disputes':[23],'targets':[
 ('btcb','https://www.binance.com/en/blog/ecosystem/421499824684901264'),
 ('withdraw','https://www.binance.com/en-IN/support/faq/detail/c47822d9bcc343b9a96601e9cc54b002'),
 ('confirmations','https://www.binance.com/en/support/faq/detail/a6f58adc6f5640f8af08aa70a55760f7')]},
 'cow-solver-collateral':{'unit':'unit:lane2:c3:p7','disputes':[24],'targets':[
 ('bonding','https://docs.cow.fi/cow-protocol/reference/core/auctions/bonding_pools'),
 ('rules','https://docs.cow.fi/cow-protocol/reference/core/auctions/competition_rules'),
 ('enforcement','https://docs.cow.fi/cow-protocol/reference/core/auctions/ebbo_specifics')]},
}
class Redirects(urllib.request.HTTPRedirectHandler):max_redirections=5;max_repeats=2

def capture(name,cfg):
 out=BASE/name;out.mkdir();(out/'captures').mkdir();(out/'failed-responses').mkdir()
 records=[]
 for sid,url in cfg['targets']:
  row={'source_id':sid,'requested_url':url,'attempts':[]}
  for attempt in range(1,3):
   a={'attempt':attempt,'started_utc':now()}
   try:
    req=urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-research/1.0','Accept-Encoding':'identity'})
    with urllib.request.build_opener(Redirects()).open(req,timeout=30) as r:
     body=r.read(5242881)
     if len(body)>5242880:raise ValueError('body exceeds 5 MiB')
     path=out/'captures'/sha(body)
     if not path.exists():path.write_bytes(body)
     a.update(status='retained',http_status=r.status,final_url=r.url,headers=dict(r.headers),body_bytes=len(body),body_sha256=sha(body),capture_path=str(path.relative_to(ROOT)))
   except Exception as e:
    a.update(status='failed',error_type=type(e).__name__,error=str(e))
    if isinstance(e,urllib.error.HTTPError):
     body=e.read(5242880);path=out/'failed-responses'/sha(body)
     if not path.exists():path.write_bytes(body)
     a.update(http_status=e.code,final_url=e.url,headers=dict(e.headers),error_body_bytes=len(body),error_body_sha256=sha(body),error_capture_path=str(path.relative_to(ROOT)),support_credit=False)
   a['finished_utc']=now();row['attempts'].append(a)
   if a['status']=='retained':break
  row['status']=row['attempts'][-1]['status'];records.append(row)
 write(out/'retrievals.json',{'unit_id':cfg['unit'],'dispute_ids':['dispute-%02d'%n for n in cfg['disputes']],'status':'draft_capture_not_accepted','bounds':{'distinct_primary_targets':3,'max_attempts_per_target':2,'timeout_seconds':30,'max_redirects':5,'max_body_bytes':5242880},'hash_scope':'Exact response body bytes; identity encoding requested; response headers separate','records':records})
 return {'packet':name,'results':[{k:r[k] for k in ['source_id','status']} for r in records]}

if __name__=='__main__':
 paths=set()
 for directory in ['corpus/normalized','corpus50']:
  paths.update(p for p in (ROOT/directory).rglob('*') if p.is_file())
 candidate=json.loads((ROOT/'review/semantic-kernel/sprint10/planning/r2-candidate.json').read_text())
 assert len(candidate['inputs'])==88
 paths.update(ROOT/r['path'] for r in candidate['inputs'])
 paths.update(ROOT/p for p in ['openspec/changes/corpus-provenance-adjudication/design.md','openspec/changes/corpus-provenance-adjudication/dispute-inventory.json','review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json'])
 protected={str(p.relative_to(ROOT)):sha(p.read_bytes()) for p in sorted(paths)}
 write(OUT/'input-protection-before.json',{'utc':now(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'files':protected,'s10_input_count':88})
 write(OUT/'target-plan.json',CONFIG)
 with ThreadPoolExecutor(max_workers=3) as pool:result=list(pool.map(lambda x:capture(*x),CONFIG.items()))
 write(OUT/'capture-results.json',result)
 assert all(sha((ROOT/p).read_bytes())==h for p,h in protected.items())
 print(json.dumps(result,indent=2))
