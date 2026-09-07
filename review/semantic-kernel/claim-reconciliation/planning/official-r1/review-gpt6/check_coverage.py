from pathlib import Path
import json,re,subprocess,hashlib,datetime
R=Path('/home/charl/defiformal');O=Path(__file__).resolve().parent;C=R/'openspec/changes/historical-claim-reconciliation';m=json.loads((C/'claim-disposition-map.json').read_text());s=json.loads((C/'scenario-map.json').read_text());old=json.loads((R/'review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json').read_text());checks=[];excerpts=[]
def ck(n,v):checks.append({'check':n,'passed':bool(v)})
print(m.keys())
rows=next(v for v in m.values() if isinstance(v,list) and len(v)==18);regs=next(v for v in m.values() if isinstance(v,list) and len(v)==10)
ck('18 exact ordered original CL IDs',[x['id'] for x in rows]==[x['id'] for x in old['entries']]==[f'CL{i:02d}' for i in range(1,19)])
for i,(a,b) in enumerate(zip(rows,old['entries'])):
 ck(a['id']+' original JSON pointer',a['original_pointer']==f'/entries/{i}')
 ck(a['id']+' exact original sites',a['original_sites']==b['sites'])
 for site in b['sites']:
  p=site['path'];data=(R/p).read_bytes();prior=subprocess.check_output(['git','show','4d42600082d4213d34ac5ab4b0dfc3eefde23d5e:'+p],cwd=R)
  lines=data.decode().splitlines(keepends=True);q=''.join(lines[site['start_line']-1:site['end_line']]).encode();oldq=b''.join(prior.splitlines(keepends=True)[site['start_line']-1:site['end_line']])
  ck(a['id']+' original span nonempty and old-revision equal '+p+':'+str(site['start_line']),bool(q) and q==oldq)
  excerpts.append({'claim':a['id'],**site,'source_sha256':hashlib.sha256(data).hexdigest(),'excerpt_sha256':hashlib.sha256(q).hexdigest(),'quote':q.decode()})
ck('63 excerpts / 22 files',len(excerpts)==63 and len({x['path'] for x in excerpts})==22)
covered={c for r in regs for c in r['mapped_claim_ids']};ck('ten real register rows cover17 with separateCL09',len(regs)==10 and covered=={x['id'] for x in rows}-{'CL09'})
actual={}
for p in (C/'specs').glob('*/spec.md'):
 req=None
 for line in p.read_text().splitlines():
  if line.startswith('### Requirement:'):req=line.split()[2]
  if line.startswith('#### Scenario:'):actual[line.split()[2]]=(p.parent.name,req,str(p.relative_to(R)))
ck('scenario-map exact once all45',len(s['scenarios'])==len(actual)==45 and {x['id'] for x in s['scenarios']}==set(actual))
for x in s['scenarios']:
 ck(x['id']+' normative mapping',(x['capability'],x['requirement'],x['path'])==actual[x['id']])
 ck(x['id']+' pending evidence no false completion',x['evidence_status']=='pending_implementation' and x['acceptance_evidence']==[])
ck('18 claim H scenario references',all(any(x['id']==r['scenario'] and r['id'] in x['claims'] for x in s['scenarios']) for r in rows))
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'excerpts':excerpts,'passed':all(x['passed'] for x in checks)};(O/'coverage-checks.json').write_text(json.dumps(result,indent=2)+'\n');print('checks',len(checks),'passed',result['passed']);assert result['passed']
