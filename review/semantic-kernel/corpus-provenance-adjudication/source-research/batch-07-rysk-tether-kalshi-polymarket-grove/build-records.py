import json,hashlib,re,subprocess,sys
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');base=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';batch=base/'batch-07-rysk-tether-kalshi-polymarket-grove'
now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def js(p):return json.loads(p.read_text())
def bind(p):return dict(path=str(p.relative_to(R)),sha256=h(p.read_bytes()),bytes=p.stat().st_size)
def write(p,d):
 with p.open('x') as f:json.dump(d,f,indent=2,ensure_ascii=False);f.write('\n')
def resolve(ref):
 d=js(R/ref['path'])
 for x in ref['pointer'].strip('/').split('/'):d=d[int(x)] if isinstance(d,list) else d[x]
 return d
configs=js(batch/'configuration.json')['units'];triage=js(base/'disagreement-triage.json');design=R/'openspec/changes/corpus-provenance-adjudication/design.md';rules={}
for i,line in enumerate(design.read_text().splitlines(),1):
 m=re.match(r'\| `(R-[^`]+)` / ([^|]+) \| ([^|]+) \| ([^|]+) \|',line)
 if m:rules[m[1]]=dict(id=m[1],facet=m[2].strip(),predicate=m[3].strip(),insufficient_alone=m[4].strip(),literal_row=line,source={**bind(design),'line':i},status='proposed reusable rule, not accepted by this research')
# Validate all chosen source spans before creating any packet conclusions.
prepared=[]
for cfg in configs:
 p=base/cfg['folder'];manifests=[p/'retrievals.json'];extra=p/'retrievals-pass2.json'
 if extra.exists():manifests.append(extra)
 records=[r for f in manifests for r in js(f)['records']];retained={r['source_id']:r for r in records if r['status']=='retained'};bodies={sid:(R/r['attempts'][-1]['capture_path']).read_bytes() for sid,r in retained.items()};assert 0<len(bodies)<=3
 loc=[]
 for sid,lid,needle in cfg['spans']:
  b=bodies[sid];n=needle.encode();start=b.find(n);assert start>=0,(cfg['folder'],sid,lid,needle)
  # Exact literal bytes plus fixed bounded context; no DOM or decoded-offset approximation.
  a=max(0,start-120);z=min(len(b),start+len(n)+160)
  loc.append(dict(id=sid+':'+lid,source_id=sid,capture=bind(R/retained[sid]['attempts'][-1]['capture_path']),byte_start=a,byte_end_exclusive=z,needle_start=start,needle_end_exclusive=start+len(n),needle=needle,span_sha256=h(b[a:z]),line_start=b[:a].count(b'\n')+1,line_end=b[:z].count(b'\n')+1,method=('literal UTF8 in JSON-encoded React flight response, inspected through JSON decoding; no JS executed' if sid=='grove-jaaa' else 'literal original HTML byte span with bounded surrounding context')))
 prepared.append((cfg,p,manifests,records,retained,bodies,loc))
outcomes=[]
for cfg,p,manifests,records,retained,bodies,loc in prepared:
 write(p/'evidence-locators.json',{'locators':loc})
 obs=[];decisions=[]
 for row in [x for x in triage['disagreements'] if x['id'] in cfg['ids']]:
  a=resolve(row['raw_a']['record']);b=resolve(row['raw_b']['record']);g=resolve(row['generated']['pointer']);assert g['rule']=='INTERSECTION_UNRESOLVED';assert set(a['facets'][row['facet']])^set(b['facets'][row['facet']])=={cfg['label']}
  obs.append(dict(triage_record=row,raw_a=a,raw_b=b,actual_generated_facet=g))
  decisions.append(dict(dispute_id=row['id'],facet=row['facet'],label=cfg['label'],proposed_disposition=cfg['disposition'],accepted_disposition=None,scope=cfg['scope'],rule=rules['R-'+cfg['label']]))
 assert len(obs)==len(cfg['ids'])
 write(p/'selection-and-observations.json',dict(unit_id=cfg['unit'],selection='Parent-authorized bounded batch07 disputes25–29; draft not independent adjudication',triage=bind(base/'disagreement-triage.json'),dispute_ids=cfg['ids'],observations=obs))
 ids={x['id'] for x in loc};claims=[dict(id=f'C{i+1}',label=cfg['label'],kind=k,claim=c,evidence=ev) for i,(k,c,ev) in enumerate(cfg['claims'])];assert all(set(x['evidence'])<=ids for x in claims)
 sources=[]
 for sid,r in retained.items():
  b=bodies[sid];redirect=sid in ['chain-swaps','issuance-primer'];sources.append(dict(source_id=sid,capture=bind(R/r['attempts'][-1]['capture_path']),transport_status='HTTP200_retained',content_status='redirect_wrapper_no_article' if redirect else 'substantive_primary_body',used_as_claim_evidence=not redirect,inspection=('No visible article text; meta-refresh destination only, scripts not executed' if redirect else 'JSON flight content decoded, no JS execution' if sid=='grove-jaaa' else 'HTML text inspected'),source_revision=r.get('revision'),version_scope=cfg['scope']))
 write(p/'extraction.json',dict(status='offline_content_inspection',sources=sources,notes='Text files are inspectable derived views only; all claim locators point to original bytes. Empty first-pass Grove visible-main extraction is preserved alongside decoded RSC view.'))
 usable=sum(x['content_status']=='substantive_primary_body' for x in sources)
 proposal=dict(kind='bounded-single-unit-source-research',created_utc=now(),author='GPT-6 stock Codex harness; not an independent adjudication reviewer',unit_id=cfg['unit'],dispute_ids=cfg['ids'],process_status='draft_review_pending',scope=cfg['scope'],dispositions=decisions,observations=bind(p/'selection-and-observations.json'),claims=claims,qualifications=cfg['limits'],next_step=cfg['next'],source_provenance=dict(retrieval_manifests=[bind(f) for f in manifests],locators=bind(p/'evidence-locators.json'),content_inspection=bind(p/'extraction.json'),retained_response_bodies=len(bodies),substantive_primary_bodies=usable,non_substantive_redirect_bodies=len(bodies)-usable,retained_bytes=sum(map(len,bodies.values())),http_failure_attempts=[a for r in records for a in r['attempts'] if a['status']=='failed'],publisher_groups=sorted({r['independence_key'] for r in retained.values()}),original_reference_status='Reconstructed supporting sources; missing original attachments not recovered'),overlay_applied=False,semantic_closure=False,limits=['No accepted corpus labels, deployed code/transaction correspondence, legal/financial guarantee, historical-source equivalence, Lean refinement, fidelity or holdout claim.','Raw corpus, generated labels, prior research packets and frozen S10 inputs remain protected.','not_evidenced is a bounded missing-predicate/scope result, not a refutation or not_applicable finding.','HTTP200 alone is not usable evidence; search snippets, secondary discovery and redirect wrappers earn no primary-claim credit.'])
 write(p/'proposed-adjudication.json',proposal)
 lines=[f"# {cfg['name']} — draft source research",'',f"`{cfg['ids'][0]}` / `{cfg['unit']}` / `{cfg['label']}`: proposed **{cfg['disposition']}**. Unaccepted; independent review pending.",'',cfg['scope'],'']
 for c in claims:
  links=', '.join(f"[{sid}]({retained[sid]['url']})" for sid in sorted({x.split(':')[0] for x in c['evidence']}));lines += [c['kind'].replace('_',' ')+': '+c['claim']+' '+links,'']
 lines+=['Qualifications:', '']+['- '+x for x in cfg['limits']]+['',f"Retained {len(bodies)} response bodies, of which {usable} are substantive primary sources, totaling {sum(map(len,bodies.values()))} bytes; {len(loc)} exact original-byte locators. HTTP failure attempts: {sum(a['status']=='failed' for r in records for a in r['attempts'])}. Retrieval times, headers, content qualification and hashes remain in the packet.",'','[Original A/B/generated observations](selection-and-observations.json) preserve the unresolved facet; the [proposal](proposed-adjudication.json) binds the actual proposed rule predicate and scoped reasoning. No canonical corpus edit, missing-attachment recovery or deployment-fidelity claim is made.','',cfg['next'],'','Author: GPT-6 stock Codex harness. Native review and acceptance have not been performed.']
 with (p/'REPORT.md').open('x') as f:f.write('\n'.join(lines)+'\n')
 outcomes.append(dict(folder=cfg['folder'],unit_id=cfg['unit'],dispute_ids=cfg['ids'],label=cfg['label'],proposed_disposition=cfg['disposition'],accepted=0,response_bodies=len(bodies),substantive_bodies=usable,redirect_bodies=len(bodies)-usable,bytes=sum(map(len,bodies.values())),locators=len(loc)))
write(batch/'outcomes.json',dict(created_utc=now(),units=outcomes,scope='Draft proposals; no independent acceptance or corpus mutation'))
print(json.dumps(outcomes,indent=2))
