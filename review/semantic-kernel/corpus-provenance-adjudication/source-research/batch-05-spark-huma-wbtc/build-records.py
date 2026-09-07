import json,hashlib,re,subprocess
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');base=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';batch=base/'batch-05-spark-huma-wbtc';now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def js(p):return json.loads(p.read_text())
def bind(p,pointer=None):
 b=p.read_bytes();d={'path':str(p.relative_to(R)),'sha256':h(b),'bytes':len(b)}
 if pointer is not None:d['pointer']=pointer
 return d
def write(p,d):
 if p.exists():
  old=js(p); new=dict(d)
  if 'created_utc' in old and 'created_utc' in new:new['created_utc']=old['created_utc']
  assert old==new,('existing record differs',p)
  return
 with p.open('x') as f:json.dump(d,f,indent=2,ensure_ascii=False);f.write('\n')
triage=js(base/'disagreement-triage.json');before=js(batch/'input-protection-before.json');designpath=R/'openspec/changes/corpus-provenance-adjudication/design.md';rules={}
for i,s in enumerate(designpath.read_text().splitlines(),1):
 m=re.match(r'\| `(R-[^`]+)` / ([^|]+) \| ([^|]+) \| ([^|]+) \|',s)
 if m:rules[m[1]]={'id':m[1],'facet':m[2].strip(),'predicate':m[3].strip(),'insufficient_alone':m[4].strip(),'literal_row':s,'source':{**bind(designpath),'line':i},'status':'proposed reusable rule; not accepted in this research'}
configs=js(batch/'fixture-config.json')
checks=[];outcomes=[]
def check(n,v):checks.append({'name':n,'pass':bool(v)});assert v,n
def resolve(ref):
 check('input-hash:'+ref['path']+ref['pointer'],h((R/ref['path']).read_bytes())==ref['sha256'])
 d=js(R/ref['path'])
 for x in ref['pointer'].strip('/').split('/'):d=d[int(x)] if isinstance(d,list) else d[x]
 return d
for cfg in configs:
 p=base/cfg['folder'];manifests=[p/'retrievals.json']

 records=[r for f in manifests for r in js(f)['records']];retained={r['source_id']:r for r in records if r['status']=='retained'};bodies={sid:(R/r['attempts'][-1]['capture_path']).read_bytes() for sid,r in retained.items()};locators=[]
 for sid,lid,needle,tag in cfg['spans']:
  b=bodies[sid];start=max(0,b.find(b'<main'));i=b.index(needle.encode(),start)
  if tag=='line':
   a=b.rfind(b'\n',0,i)+1;z=b.find(b'\n',i)
   if z<0:z=len(b)
  elif tag=='mdsection':
   a=i;z=b.index(b'\n# ',i)
  else:
   ms=list(re.finditer(rb'<'+tag.encode()+rb'(?:\s[^>]*|)>',b[:i+1]));assert ms,(sid,lid)
   a=ms[-1].start();z=b.index(b'</'+tag.encode()+b'>',i)+len(tag)+3
  locators.append({'id':sid+':'+lid,'source_id':sid,'capture':bind(R/retained[sid]['attempts'][-1]['capture_path']),'byte_start':a,'byte_end_exclusive':z,'line_start':b[:a].count(b'\n')+1,'line_end':b[:z].count(b'\n')+1,'span_sha256':h(b[a:z]),'needle':needle,'method':'Exact '+tag+' span from retained bytes; manually inspected, no normalization'})
 write(p/'evidence-locators.json',{'locators':locators});rows=[x for x in triage['disagreements'] if x['id'] in cfg['ids']];obs=[];decisions=[]
 for row in rows:
  a=resolve(row['raw_a']['record']);b=resolve(row['raw_b']['record']);g=resolve(row['generated']['pointer']);obs.append({'triage_record':row,'raw_a':a,'raw_b':b,'actual_generated_facet':g});check(row['id']+'-unresolved',g['rule']=='INTERSECTION_UNRESOLVED');delta=set(a['facets'][row['facet']])^set(b['facets'][row['facet']]);check(row['id']+'-labels',delta==set(row['label_claims'][i]['label'] for i in range(len(row['label_claims']))))
  for label in sorted(delta):decisions.append({'dispute_id':row['id'],'facet':row['facet'],'label':label,'proposed_disposition':cfg['dispositions'][label],'accepted_disposition':None,'rule':rules['R-'+label]})
 write(p/'selection-and-observations.json',{'unit_id':cfg['unit'],'selection':'Parent-authorized batch05: Spark Savings dispute15, Huma disputes16/17/18, WBTC disputes19/20; each multi-facet unit is one body-capped packet','triage':bind(base/'disagreement-triage.json'),'dispute_ids':cfg['ids'],'observations':obs})
 ids={x['id'] for x in locators};claims=[{'id':'C'+str(i+1),'label':label,'kind':kind,'claim':claim,'evidence':ev} for i,(label,kind,claim,ev) in enumerate(cfg['claims'])]
 for c in claims:check(cfg['folder']+'-'+c['id'],set(c['evidence'])<=ids)
 for sid,r in retained.items():last=r['attempts'][-1];check(cfg['folder']+'-body-'+sid,h(bodies[sid])==last['body_sha256'] and len(bodies[sid])==last['body_bytes'])
 for l in locators:check(cfg['folder']+'-span-'+l['id'],h(bodies[l['source_id']][l['byte_start']:l['byte_end_exclusive']])==l['span_sha256'])
 check(cfg['folder']+'-body-cap',0<len(bodies)<=3)
 authors=sorted({r['independence_key'] for r in retained.values()});proposal={'kind':'bounded-single-unit-source-research','created_utc':now(),'author':'GPT-6 stock Codex harness; no independent review performed','unit_id':cfg['unit'],'dispute_ids':cfg['ids'],'process_status':'draft_review_pending','dispositions':decisions,'observations':bind(p/'selection-and-observations.json'),'claims':claims,'qualifications':cfg['limits'],'next_step':cfg['next'],'source_provenance':{'retrieval_manifests':[bind(f) for f in manifests],'locators':bind(p/'evidence-locators.json'),'retained_primary_bodies':len(bodies),'retained_primary_bytes':sum(map(len,bodies.values())),'failed_targets':[r for r in records if r['status']!='retained'],'retained_source_publisher_groups':authors,'independence_limit':'Sources from one publisher are not independent corroboration; a dependency publisher does not bind the consuming product.','original_reference_status':'Reconstructed supporting sources; original missing citations not recovered'},'overlay_applied':False,'semantic_closure':False,'limits':['No accepted corpus labels, deployment identity, historical equivalence, contract execution, Lean refinement, fidelity or holdout claim.','Existing raw annotations, generated decisions, prior research packages and frozen Sprint10 inputs remain unchanged.','not_evidenced is a bounded missing-predicate/scope result, not refuted or not_applicable.','All findings use retained bodies; failed requests and search snippets receive no primary-evidence credit. A retained HTML body is not automatically substantive evidence for its search rendering.']}
 write(p/'proposed-adjudication.json',proposal)
 lines=[f"# {cfg['name']} — draft source research",'', '; '.join(f"{d['dispute_id']}/{d['label']}: proposed **{d['proposed_disposition']}**" for d in decisions)+'. All remain unaccepted.','',f"Unit `{cfg['unit']}`; disputed facets {', '.join(cfg['ids'])}. [Exact raw A/B/generated observations](selection-and-observations.json) preserve each facet separately; all actual generated rules remain `INTERSECTION_UNRESOLVED`.",'']
 for c in claims:
  links=', '.join(f"[{sid}]({retained[sid]['url']})" for sid in sorted({x.split(':')[0] for x in c['evidence']}));lines += [c['kind'].replace('_',' ')+': '+c['claim']+' '+links,'']
 lines+=['Qualifications:', '']+['- '+x for x in cfg['limits']]+['',f"Retained {len(bodies)} primary bodies ({sum(map(len,bodies.values()))} bytes) from {len(records)} target URLs. Failed attempts and exact source URLs/times/hashes remain in the retrieval manifests. No more than three bodies were retained for this unit. {len(locators)} source locators bind exact original bytes.",'','The [proposed disposition record](proposed-adjudication.json) binds the current proposed rule, per-label reasoning and full source provenance. No deployment/fidelity or canonical corpus acceptance is claimed.','',cfg['next'],'','Author: GPT-6 stock Codex harness. Independent review remains pending.']
 report='\n'.join(lines)+'\n'
 if (p/'REPORT.md').exists():assert (p/'REPORT.md').read_text()==report
 else:
  with (p/'REPORT.md').open('x') as f:f.write(report)
 outcomes.append({'folder':cfg['folder'],'unit_id':cfg['unit'],'dispute_ids':cfg['ids'],'dispositions':cfg['dispositions'],'bodies':len(bodies),'bytes':sum(map(len,bodies.values())),'locators':len(locators),'targets':len(records),'attempts':sum(len(r['attempts']) for r in records)})
for path,digest in before['files'].items():check('protected:'+path,h((R/path).read_bytes())==digest)
verify={'created_utc':now(),'git_head_before':before['git_head'],'git_head_after':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'s10_frozen_candidate':before['s10_frozen_candidate'],'s10_protected_inputs':88,'protected_files':len(before['files']),'all_protected_unchanged':True,'checks':checks,'check_count':len(checks),'all_passed':all(x['pass'] for x in checks),'units':outcomes,'unit_count':3,'facet_count':6,'label_claim_count':6,'proposed_supported':1,'proposed_not_evidenced':5,'accepted':0,'retained_bodies':sum(x['bodies'] for x in outcomes),'retained_bytes':sum(x['bytes'] for x in outcomes),'scope':'Offline input/body/span/record checks only, not semantic acceptance'}
write(batch/'verification.json',verify)
for cfg in configs:
 p=base/cfg['folder'];write(p/'verification.json',{'batch_verification':bind(batch/'verification.json'),'protected_inputs':bind(batch/'input-protection-before.json'),'unit':next(x for x in outcomes if x['folder']==cfg['folder']),'all_checks_passed':True});write(p/'artifact-manifest.json',{'status':'immutable draft research packet','files':[bind(x) for x in sorted(p.rglob('*')) if x.is_file()]})
summary=['# Batch 05 — draft source research','', 'Three units; six disputed facets; six separate label claims. One proposed supported claim and five not_evidenced; none accepted.', '', 'WBTC async_cross_domain is supported only for the documented merchant BTC/Ethereum workflow. Huma Institutional management and allocation have separate scoped positive predicates, but applicability to the corpus Solana V2 unit remains unresolved. Spark cross-domain, Huma attester and WBTC holder legal obligation remain unestablished.', '', f"Retained {verify['retained_bodies']} primary bodies totaling {verify['retained_bytes']} bytes. {sum(x['locators'] for x in outcomes)} exact source locators. {len(checks)} offline checks pass; {len(before['files'])} protected inputs remain unchanged, including all88 frozen Sprint10 inputs.", '', 'Unavailable evidence: Spark savings page failed404 twice. The retained Huma FAQ is only a dApp pointer; stale search-rendered FAQ prose is excluded. No applicable WBTC holder agreement was obtained; website terms remain separately scoped.', '', 'See verification.json for exact checks, input-protection-before.json for source protection, and each unit REPORT.md/proposed-adjudication.json for raw observations, current rule binding, source provenance and limits. No canonical corpus edits, accepted labels, deployment/fidelity claims or independent review occurred.']
with (batch/'REPORT.md').open('x') as f:f.write('\n'.join(summary)+'\n')
write(batch/'artifact-manifest.json' ,{'files':[bind(x) for x in sorted(batch.iterdir()) if x.is_file()],'unit_manifests':[bind(base/cfg['folder']/'artifact-manifest.json') for cfg in configs]})
print(json.dumps({'checks':len(checks),'protected':len(before['files']),'outcomes':outcomes,'manifest':bind(batch/'artifact-manifest.json')},indent=2))
