"""Offline packet, original span, extraction, corpus and protected-input verification. No network."""
import hashlib,json,re,subprocess,sys
from pathlib import Path
from datetime import datetime,timezone
from bs4 import BeautifulSoup
R=Path('/home/charl/defiformal');base=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';batch=base/'batch-07-rysk-tether-kalshi-polymarket-grove'
now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def js(p):return json.loads(p.read_text())
def bind(p):return dict(path=str(p.relative_to(R)),sha256=h(p.read_bytes()),bytes=p.stat().st_size)
def write(p,obj):
 with p.open('x') as f:json.dump(obj,f,indent=2,ensure_ascii=False);f.write('\n')
checks=[]
def check(n,b):checks.append(dict(name=n,passed=bool(b)));assert b,n
def bound(ref):return h((R/ref['path']).read_bytes())==ref['sha256'] and (R/ref['path']).stat().st_size==ref['bytes']
before=js(batch/'input-protection-before.json');units=js(batch/'outcomes.json')['units']
for path,digest in before['files'].items():check('protected:'+path,h((R/path).read_bytes())==digest)
freeze=js(R/before['s10_manifest']);check('s10-input-count',len(freeze['inputs'])==88)
for x in freeze['inputs']:check('s10-current:'+x['path'],h((R/x['path']).read_bytes())==x['sha256'])
for u in units:
 p=base/u['folder'];prop=js(p/'proposed-adjudication.json');check(u['folder']+':unaccepted',prop['process_status']=='draft_review_pending' and not prop['overlay_applied'] and not prop['semantic_closure'] and all(d['accepted_disposition'] is None for d in prop['dispositions']))
 check(u['folder']+':observation-binding',bound(prop['observations']))
 for ref in prop['source_provenance']['retrieval_manifests']+[prop['source_provenance']['locators'],prop['source_provenance']['content_inspection']]:check(u['folder']+':binding:'+ref['path'],bound(ref))
 records=[r for ref in prop['source_provenance']['retrieval_manifests'] for r in js(R/ref['path'])['records']];bodies={}
 for rec in records:
  for index,a in enumerate(rec['attempts']):
   if a['status']!='retained':continue
   raw=(R/a['capture_path']).read_bytes();sid=rec['source_id'];bodies[sid]=raw
   check(u['folder']+':body:'+sid,h(raw)==a['body_sha256'] and len(raw)==a['body_bytes']);check(u['folder']+':nonempty:'+sid,len(raw)>0)
   soup=BeautifulSoup(raw.decode(),'html.parser');main=soup.find('main') or soup.find('article') or soup
   for el in main.find_all(['script','style','nav']):el.decompose()
   text=main.get_text(' ',strip=True)+'\n';derived=p/(sid+'.txt');check(u['folder']+':text-replay:'+sid,derived.read_text()==text)
 check(u['folder']+':body-cap',0<len(bodies)<=3)
 check(u['folder']+':body-count',len(bodies)==u['response_bodies'])
 loc=js(p/'evidence-locators.json')['locators'];ids={x['id'] for x in loc};check(u['folder']+':unique-locators',len(ids)==len(loc))
 for x in loc:
  raw=bodies[x['source_id']];check(u['folder']+':locator:'+x['id'],bound(x['capture']) and h(raw[x['byte_start']:x['byte_end_exclusive']])==x['span_sha256'] and raw[x['needle_start']:x['needle_end_exclusive']]==x['needle'].encode() and x['byte_start']<=x['needle_start']<x['needle_end_exclusive']<=x['byte_end_exclusive'])
 for c in prop['claims']:check(u['folder']+':claim-links:'+c['id'],bool(c['evidence']) and set(c['evidence'])<=ids)
 for d in prop['dispositions']:
  src=d['rule']['source'];check(u['folder']+':rule-binding',bound(src));check(u['folder']+':rule-row',(R/src['path']).read_text().splitlines()[src['line']-1]==d['rule']['literal_row'])
 obs=js(p/'selection-and-observations.json')
 for row in obs['observations']:check(u['folder']+':still-unresolved',row['actual_generated_facet']['rule']=='INTERSECTION_UNRESOLVED')
 if u['folder']=='tether-chain-swap':
  check('tether:redirect-classified',prop['source_provenance']['non_substantive_redirect_bodies']==2)
  for sid in ['chain-swaps','issuance-primer']:check('tether:not-evidence:'+sid,not any(x['source_id']==sid for x in loc))
 if u['folder']=='grove-fund-share':
  raw=bodies['grove-jaaa'].decode();texts=[]
  for s in BeautifulSoup(raw,'html.parser').find_all('script'):
   m=re.fullmatch(r'self\.__next_f\.push\((\[.*\])\)',s.string or '',re.S)
   if m:
    data=json.loads(m[1])
    if len(data)>1 and isinstance(data[1],str):texts.append(data[1])
  check('grove:json-only-flight-replay',(p/'grove-jaaa-rsc.txt').read_text()=='\n'.join(texts))
check('supported-count',sum(u['proposed_disposition']=='supported' for u in units)==4)
check('not-evidenced-count',sum(u['proposed_disposition']=='not_evidenced' for u in units)==1)
check('http-failure-count-is-zero',all(a['status']!='failed' for u in units for ref in js(base/u['folder']/'proposed-adjudication.json')['source_provenance']['retrieval_manifests'] for r in js(R/ref['path'])['records'] for a in r['attempts']))
check('prior-failed-build-retained',js(batch/'development-attempt-1/build-execution.json')['exit_code']==1)
check('current-build-passed',js(batch/'build-execution.json')['exit_code']==0)
# M3 draft was explicitly held stable as a separate task.
for x in js(R/'review/semantic-kernel/sprint11/planning/author-draft/artifacts.json')['artifacts']:check('m3-stable:'+x['path'],bound(x))
result=dict(kind='offline_artifact_and_input_verification_not_adjudication',created_utc=now(),command=[sys.executable,str(Path(__file__))],cwd=str(R),python_path=str(Path(sys.executable).resolve()),python_sha256=h(Path(sys.executable).resolve().read_bytes()),verifier=bind(Path(__file__)),git_head_before=before['git_head'],git_head_after=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),protected_files=len(before['files']),s10_bound_inputs=88,all_protected_unchanged=True,all_passed=True,check_count=len(checks),checks=checks,units=units,proposed_supported=4,proposed_not_evidenced=1,accepted=0,response_bodies=sum(u['response_bodies'] for u in units),substantive_primary_bodies=sum(u['substantive_bodies'] for u in units),redirect_bodies=2,retained_bytes=sum(u['bytes'] for u in units),locators=sum(u['locators'] for u in units),http_failures=0,failed_content_retrievals=2,failed_author_builds_preserved=1)
write(batch/'verification.json',result)
for u in units:
 p=base/u['folder'];write(p/'verification.json',dict(batch_verification=bind(batch/'verification.json'),protection_before=bind(batch/'input-protection-before.json'),unit=u,all_checks_passed=True));write(p/'artifact-manifest.json',dict(status='stable draft unaccepted research packet',files=[bind(x) for x in sorted(p.rglob('*')) if x.is_file()]))
write(batch/'artifact-manifest.json',dict(status='stable draft unaccepted batch',files=[bind(x) for x in sorted(batch.rglob('*')) if x.is_file()],unit_manifests=[bind(base/u['folder']/'artifact-manifest.json') for u in units]))
print(json.dumps({k:v for k,v in result.items() if k not in ['checks','units']},indent=2))
