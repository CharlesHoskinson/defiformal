"""Offline consolidated author research index; no old artifact writes or network access."""
import collections,datetime,hashlib,json,re,subprocess,sys
from pathlib import Path
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';O=B/'consolidated-01'
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def js(p):return json.loads(p.read_text())
def bind(p,pointer=None):
 x=dict(path=str(p.relative_to(R)),sha256=sha(p),bytes=p.stat().st_size)
 if pointer is not None:x['pointer']=pointer
 return x
def write(n,x):(O/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
def resolve(ref):
 v=js(R/ref['path'])
 for k in ref.get('pointer','').strip('/').split('/'):
  if k:v=v[int(k)] if isinstance(v,list) else v[k.replace('~1','/').replace('~0','~')]
 return v
def walk(x,ptr=''):
 yield ptr,x
 if isinstance(x,dict):
  for k,v in x.items():yield from walk(v,ptr+'/'+str(k).replace('~','~0').replace('/','~1'))
 elif isinstance(x,list):
  for k,v in enumerate(x):yield from walk(v,ptr+'/'+str(k))
def sourcepath(p,s):
 return R/s if s.startswith(('review/','corpus/','openspec/','lean/')) else p/s
checks=[]
def ck(n,b):checks.append(dict(name=n,passed=bool(b)));assert b,n
before=js(O/'protection-before.json');invfile=O/'context-before/openspec/changes/corpus-provenance-adjudication/dispute-inventory.json';inv=js(invfile);corpusfile=R/'corpus/normalized/generated/corpus.json';corpus=js(corpusfile)
ck('canonical75',len(corpus['units'])==75)
expected={(d['id'],label):d for d in inv['disagreements'] for label in d['disputed_labels']};ck('expected32',len(expected)==32)
# Original immutable packet and batch artifact-manifest entries, regardless of schema.
manifestchecks=[]
for m in sorted(B.glob('*/artifact-manifest.json')):
 if O in m.parents:continue
 d=js(m);files=d.get('files',d.get('artifacts',[]))
 if isinstance(files,dict):files=[dict(path=str((m.parent/k).relative_to(R)),**v) for k,v in files.items()]
 for i,ref in enumerate(files+d.get('unit_manifests',[])):
  p=R/ref['path'];ok=p.is_file() and sha(p)==ref['sha256'] and ('bytes' not in ref or p.stat().st_size==ref['bytes']);ck('original-manifest:'+str(m.relative_to(R))+':'+str(i),ok);manifestchecks.append(dict(manifest=bind(m),artifact=ref,verified=True))
write('original-manifest-verification.json',dict(checks=manifestchecks,count=len(manifestchecks),all_passed=True,scope='Original artifact manifest entries only; historical contextual references inside proposals retain their original identity even when current author drafts changed.'))
scope_fallback={
'apex-omni-attester':'ApeX Omni FAQ plus zkLink infrastructure; optional infrastructure attestation not bound to an active Omni deployment.',
'babylon-spot-asset':'Pinned native BTC staking documentation; direct instrument rights unresolved, distinct from redirected Trustless Bitcoin Vault/Aave homepage.',
'edgex-attester':'Generic StarkEx committee path only; no usable product-specific edgeX binding.',
'huma-v2-roles':'Huma Institutional source paths; relationship to the V2/Solana named corpus unit unresolved.',
'hyperliquid-allocation':'Leader-managed legacy HyperCore vault path; current HyperEVM/CoreWriter overview is a distinct product generation.',
'jupiter-jlp':'Documented JLP managed pool/custody path, not every Jupiter venue; allocation action and holder settlement remain unestablished.',
'lido-curator':'DAO selection/module allocation and Curated module across explicitly qualified V2/V3 documentation; no single deployed configuration asserted.',
'lista-cdp-roles':'Pinned CDP/lisUSD liquidation initiation/restart role; issuance authority remains unestablished.',
'maple-allocation':'Current documented Pool Delegate and open-term institutional loan funding path, no resolved historical pool.',
'pendle-spot-asset':'Pendle V2 PT/YT/SY architecture; the direct spot instrument boundary remains unresolved.',
'spark-savings-cross-domain':'Pinned local Ethereum savings/non-Ethereum PSM documentation; no linked two-domain savings delivery path established.',
'wbtc-cross-domain-obligor':'Whitepaper Bitcoin/Ethereum merchant-custodian workflow; ordinary-holder legal obligation is not supplied by informational website terms.'}
packets=[];mapping=[];challenge=[];capture_by_hash=collections.defaultdict(set)
for pp in sorted(B.glob('*/proposed-adjudication.json')):
 p=pp.parent;name=p.name;d=js(pp);report=p/'REPORT.md';reporttext=report.read_text();manifest=p/'artifact-manifest.json';_ = js(manifest)
 scope=d.get('scope',d.get('scoped_proposition',d.get('support_scope',scope_fallback.get(name,''))));ck(name+':scope',bool(scope))
 qualifications=d.get('material_qualifications',d.get('qualifications',d.get('not_claimed',[])))
 rowlist=[]
 if 'dispositions' in d:
  for i,decision in enumerate(d['dispositions']):
   did=decision.get('dispute_id',d.get('dispute_id'));ck(name+':dispute-found:'+str(i),did is not None)
   rowlist.append((did,decision['label'],decision['proposed_disposition'],f'/dispositions/{i}/proposed_disposition'))
 elif 'claims' in d and any('proposed_disposition' in c for c in d['claims']):
  for i,c in enumerate(d['claims']):rowlist.append((c['dispute_id'],c['label'],c['proposed_disposition'],f'/claims/{i}/proposed_disposition'))
 elif 'dispute_id' in d:
  field='unit_wide_disposition' if name=='wbeth-offchain-claims' else 'proposed_disposition'
  rowlist.append((d['dispute_id'],d.get('label',d.get('disputed_label')),d[field],'/'+field))
 elif 'challenge_id' in d:
  challenge.append(dict(challenge_id=d['challenge_id'],unit_id=d['unit_id'],label=d['label'],packet=bind(pp),decision=bind(pp,'/proposed_disposition'),proposed_disposition=d['proposed_disposition'],scope=scope,accepted=False,canonical_changed=False,note='Separate challenge, not one of29 disputed facets. Liquidation membership agreement is not whole-facet AGREE; that facet remains INTERSECTION_UNRESOLVED due to redemption.'))
 else:raise AssertionError(name)
 for did,label,disp,ptr in rowlist:
  key=(did,label);ck(name+':inventory:'+str(key),key in expected);item=expected[key];ck(name+':unit-match:'+did,d['unit_id']==item['unit_id']);ck(name+':unaccepted',d.get('accepted_disposition') is None and not d.get('overlay_applied',False))
  reading='supported_only_within_packet_scope' if disp=='supported' else 'predicate_or_identity_not_established_in_bounded_packet'
  if name=='wbeth-offchain-claims':reading='ADGM service terms source reading supported; explicit unit-wide proposal not_evidenced'
  if name=='huma-v2-roles' and label in ['asset_management','allocation']:reading='Documented Institutional path supports predicate; V2/Solana unit binding unresolved, unit proposal not_evidenced'
  if name=='lighter-appchain':reading='Conditional support only if independent taxonomy review accepts application-specific rollups under R-appchain'
  mapping.append(dict(dispute_id=did,unit_id=item['unit_id'],unit_label=item['label'],facet=item['facet'],label=label,inventory_record=bind(invfile,'/disagreements/'+str(inv['disagreements'].index(item))),packet_folder=name,proposal=bind(pp),decision=bind(pp,ptr),packet_proposed_disposition=disp,source_scoped_reading=reading,scope=scope,scope_qualifications_ref=bind(pp,('/material_qualifications' if 'material_qualifications' in d else '/qualifications' if 'qualifications' in d else '/not_claimed')),broad_unit_applicability='Not an accepted all-product/all-version conclusion; apply the packet scope and remaining identity/taxonomy conditions.',accepted=False,effective_label=None,canonical_changed=False))
 # Exact source retrieval records are listed per packet. Their native statuses are not recounted as evidence.
 retrievals=[];capture_refs={};versions=[]
 supporting=[pp,*sorted(p.rglob('retrievals*.json'))]
 for f in ['source-provenance.json','extraction.json','evidence-locators.json']:
  if (p/f).exists():supporting.append(p/f)
 for f in supporting:
  doc=js(f)
  if f.name.startswith('retrievals'):
   for i,rec in enumerate(doc.get('records',[])):
    retrievals.append(dict(record=bind(f,'/records/'+str(i)),source_id=rec.get('source_id'),requested_url=rec.get('requested_url',rec.get('url')),source_revision=rec.get('source_revision',rec.get('revision')),time_scope=rec.get('time_scope',rec.get('scope')),recorded_status=rec.get('status'),attempts=[dict(pointer=bind(f,f'/records/{i}/attempts/{j}'),status=a.get('status'),http_status=a.get('http_status'),body_bytes=a.get('body_bytes'),final_url=a.get('final_url'),started_utc=a.get('started_utc'),finished_utc=a.get('finished_utc'),error=a.get('error')) for j,a in enumerate(rec.get('attempts',[]))]))
  for ptr,v in walk(doc):
   key=ptr.rsplit('/',1)[-1]
   if isinstance(v,(str,int,float)) and re.search(r'(revision|version|time_scope|effective_date|publication)',key,re.I):versions.append(dict(source=bind(f,ptr),value=v))
   if isinstance(v,str) and '/captures/' in v or isinstance(v,str) and v.startswith('captures/'):
    cp=sourcepath(p,v)
    if cp.is_file():capture_refs[str(cp.relative_to(R))]=bind(cp);capture_by_hash[sha(cp)].add(str(cp.relative_to(R)))
 locfile=p/'evidence-locators.json';locs=js(locfile)['locators'];coordinates=[]
 for i,l in enumerate(locs):
  key='derived_text' if 'derived_text' in l else 'extracted_text' if 'extracted_text' in l else 'capture' if 'capture' in l else 'capture_path'
  target=l[key];targetpath=sourcepath(p,target['path'] if isinstance(target,dict) else target);raw=targetpath.read_bytes();ck(name+':span:'+str(i),hashlib.sha256(raw[l['byte_start']:l['byte_end_exclusive']]).hexdigest()==l['span_sha256'])
  coordinates.append(dict(locator=bind(locfile,'/locators/'+str(i)),id=l['id'],coordinate_space='derived_extracted_text' if key in ['derived_text','extracted_text'] else 'original_capture_bytes',coordinate_file=bind(targetpath),byte_start=l['byte_start'],byte_end_exclusive=l['byte_end_exclusive'],span_sha256=l['span_sha256'],verified=True))
 owncaptures=[bind(x) for x in sorted(p.rglob('*')) if x.is_file() and x.parent.name=='captures']
 for x in owncaptures:capture_by_hash[x['sha256']].add(x['path'])
 provenancekeys=[k for k in ['source_provenance','provenance','provenance_status','source_assessment','source_scope','source_independence_groups','evidence'] if k in d]
 # Preserve every field that supplies original contextual identity, including now-stale draft hashes.
 contextrefs=[]
 for ptr,v in walk(d):
  if isinstance(v,dict) and isinstance(v.get('path'),str) and v['path'].startswith(('openspec/','wiki-llm/')):
   current=R/v['path'];contextrefs.append(dict(proposal_pointer=bind(pp,ptr),original_reference=v,current_exists=current.exists(),current_sha256=sha(current) if current.is_file() else None,current_matches_original=(sha(current)==v.get('sha256') if current.is_file() else False),interpretation='Historical packet context preserved; concurrent author refresh is not evidence corruption or retroactive endorsement.'))
 packets.append(dict(folder=name,unit_id=d['unit_id'],proposal=bind(pp),report=bind(report),manifest=bind(manifest),scope=scope,qualifications=qualifications,report_inspected=True,proposal_inspected=True,manifest_verified=True,version_records=versions,provenance_references=[bind(pp,'/'+k) for k in provenancekeys],historical_context_references=contextrefs,source_scoped_support=d.get('scoped_source_reading'),explicit_unit_wide_disposition=d.get('unit_wide_disposition'),body_accounting=dict(policy='No global response/substantive sum inferred from mixed packet schemas; see exact retrieval and content-assessment pointers.',retrieval_records=retrievals,own_stored_capture_files=owncaptures,referenced_capture_files=list(capture_refs.values()),reused_capture_paths_outside_packet=[x for x in capture_refs if not x.startswith(str(p.relative_to(R))+'/')],assessment_references=[bind(pp,'/'+k) for k in ['source_assessment','source_provenance','provenance'] if k in d]+([bind(p/'extraction.json')] if (p/'extraction.json').exists() else []),limitations='HTTP status, retained file count, source ID count and locator count are different measures. Empty bodies, shells, redirects, irrelevant redirected pages and failed attempts earn no relevant support. Multiple references to identical bytes are not fresh acquisitions.'),locators=coordinates,accepted=False))
ck('one-mapping-per-label',len(mapping)==len(expected)==len({(x['dispute_id'],x['label']) for x in mapping}))
ck('exact-inventory-coverage',{(x['dispute_id'],x['label']) for x in mapping}==set(expected))
ck('29facet-coverage',len({x['dispute_id'] for x in mapping})==29)
ck('one-separate-challenge',len(challenge)==len(inv['separate_challenges'])==1)
# Match the separate challenge by its actual stored identifier.
challenge[0]['inventory_record']=bind(invfile,'/separate_challenges/0');challenge[0]['inventory_original']=inv['separate_challenges'][0]
covered={p['unit_id'] for p in packets};ck('24-covered-unit-ids',len(covered)==24)
queue=[];allunits=[];source_rows={x['legacy_id']:(i,x) for i,x in enumerate(corpus['source_records'])}
for i,u in enumerate(corpus['units']):
 rowindex,row=source_rows[u['legacy_id']]
 entry=dict(unit_id=u['unit_id'],label=u['label'],legacy_id=u['legacy_id'],canonical_record=bind(corpusfile,'/units/'+str(i)),organization=u['organization'],product=u['product'],version=u['version'],deployment=u['deployment'],split_rule=u['split_rule'],evaluation_role=u['evaluation_role'],normalization_status=u['normalization_status'],uncertainty=u['uncertainty'],source_row=bind(corpusfile,'/source_records/'+str(rowindex)),source_row_metadata={k:v for k,v in row.items() if k!='original'},original_source_label=row['original'].get('name'),packet_folders=[p['folder'] for p in packets if p['unit_id']==u['unit_id']],accepted_source_adjudication=False,identity_resolved=False,queue_reason='no_unit_bound_new_source_packet' if u['unit_id'] not in covered else 'draft_packet_scope_or_identity_still_requires_independent_review')
 allunits.append(entry)
 if u['unit_id'] not in covered:queue.append(entry)
ck('75-unit-partition',len(queue)+len(covered)==len(corpus['units']))
ck('queue51',len(queue)==51);ck('all-development',all(x['evaluation_role']=='development' for x in allunits))
write('coverage.json',dict(status='author_research_readiness_not_accepted_adjudication',inventory_snapshot=bind(invfile),counts=dict(dispute_facets=29,disputed_label_rows=len(mapping),unit_ids=len(covered),packet_count=len(packets),separate_challenges=len(challenge),accepted=0),label_mapping=sorted(mapping,key=lambda x:(int(x['dispute_id'].split('-')[1]),x['label'])),separate_challenges=challenge))
write('packets.json',dict(status='Original packet conclusions and qualifications preserved; no new source acquisition',packets=packets))
write('remaining-research-queue.json',dict(status='author_identity_source_research_queue_not_missing_evidence_refutation',canonical_source=bind(corpusfile),canonical_development_units=len(allunits),units_with_any_exact_id_packet=len(covered),units_without_any_exact_id_packet=len(queue),remaining=queue,covered_but_unaccepted=[x for x in allunits if x['unit_id'] in covered],policy='Exact original unit ID matching only; parent/child, aliases, versions and bundled products do not inherit another packet. Agreement in annotations is not source evidence. No URL or deployment identity is invented.'))
write('capture-reuse.json',dict(status='content_addressed_file_references_not_acquisition_or_substantive_body_counts',duplicates=[dict(sha256=k,locations=sorted(v)) for k,v in sorted(capture_by_hash.items()) if len(v)>1],explicit_reuse=[dict(packet=p['folder'],paths=p['body_accounting']['reused_capture_paths_outside_packet']) for p in packets if p['body_accounting']['reused_capture_paths_outside_packet']],limits='Identical files and repeated references do not add independent evidence; zero-byte captures share the empty digest. No aggregate body or byte total is claimed.'))
# Observe evolving author context after reads, without requiring it to match historical packet context.
aftercontext=[]
for p in sorted((R/'openspec/changes/corpus-provenance-adjudication').rglob('*')):
 if p.is_file():
  dest=O/'context-after'/p.relative_to(R);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(p.read_bytes());aftercontext.append(dict(**bind(p),snapshot=str(dest.relative_to(R))))
old={x['path']:x['sha256'] for x in js(O/'context-before.json')['files']};changes=[x['path'] for x in aftercontext if old.get(x['path'])!=x['sha256']]
write('context-after.json',dict(utc=now(),files=aftercontext,changed_since_before=changes,known_author_refresh=True,scope='Observed current draft only; no immutable packet context rewritten.'))
for name,digest in before['protected'].items():ck('protected:'+name,sha(R/name)==digest)
write('verification.json',dict(status='offline_integrity_and_coverage_only',utc=now(),command=[sys.executable,str(Path(__file__))],cwd=str(R),python=bind(Path(sys.executable).resolve()) if Path(sys.executable).resolve().is_relative_to(R) else dict(path=str(Path(sys.executable).resolve()),sha256=sha(Path(sys.executable).resolve())),head_before=before['head'],head_after=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),checks=checks,check_count=len(checks),all_passed=True,protected_count=len(before['protected']),s10_protected_inputs=88,source_acquisitions=0,canonical_edits=0,accepted=0,context_changes_observed=changes))
lines=['# Consolidated draft source-research index','',f'{len(mapping)} label proposals cover all29 dispute facets across24 exact canonical unit IDs. A separate Liquity V1 liquidation packet addresses its challenge. All25 packets remain draft and unaccepted. This is research readiness, not29 accepted resolutions or deployment fidelity.','', 'The [exact coverage map](coverage.json) binds original inventory and proposal JSON pointers. [Packet records](packets.json) retain scopes, source versions, historical context hashes, retrieval/assessment references and verified locator coordinate spaces. The [remaining queue](remaining-research-queue.json) contains51 of75 canonical development units with no exact-unit new source packet; the other24 still require scope/identity review. Annotation agreement supplies no new source evidence.','', '| Dispute | Unit | Label | Packet proposal | Scope qualification |','|---|---|---|---|---|']
for x in sorted(mapping,key=lambda x:(int(x['dispute_id'].split('-')[1]),x['label'])):lines.append(f"| {x['dispute_id']} | {x['unit_label']} | {x['label']} | [{x['packet_proposed_disposition']}](../{x['packet_folder']}/REPORT.md) | {x['scope'].replace('|','/')} |")
lines+=['','WBETH’s source-scoped ADGM reading is supported, but its unit-wide proposal is not_evidenced. Huma Institutional supports two predicates at source scope while the V2/Solana unit remains unbound. Lighter support is explicitly conditional on a rollup-inclusive taxonomy reading. These are preserved distinctions, not automatic promotions.','', 'The [separate Liquity liquidation challenge](../liquity-v1/REPORT.md) remains a supported source-scoped proposal. Shared liquidation membership in A/B is not a whole-facet AGREE result: the mechanisms facet remains INTERSECTION_UNRESOLVED because redemption differs.','', 'Body counts are deliberately not summed. Liquity redemption references two existing liquidation captures plus its own acquisitions; the liquidation packet has four bodies from separately authorized passes. BTCB/WBETH include repeated empty HTTP202 responses; Tether has two HTTP200 redirect wrappers; ApeX/Huma include unusable shells or pointers. Lighter/WBETH and batch06 locators use extracted-text coordinates, while other packets bind original bytes. Exact assessment, capture reuse and coordinate records remain linked. Failed, empty, redirected-irrelevant and unusable content receives no claim support.','', 'All original packet/batch artifact manifests and every locator span were checked offline. Canonical corpus, original research files and all88 S10 R2 inputs remain unchanged. Concurrent corpus OpenSpec author refresh is recorded in before/after snapshots; differing current draft hashes do not rewrite historical packet context or validate its rule interpretation.','', 'No source acquisition, canonical edit, native review, commit, deployed-code verification, recovered original attachment, accepted identity or holdout evidence is produced by this index. The author wrote some packets and edited corpus planning context, so this is not its independent planning verdict.']
(O/'INDEX.md').write_text('\n'.join(lines)+'\n')
write('artifact-manifest.json',dict(status='consolidated author readiness snapshot',files=[bind(x) for x in sorted(O.rglob('*')) if x.is_file() and x.name!='artifact-manifest.json']))
print(json.dumps({'packets':len(packets),'facets':29,'label_rows':len(mapping),'covered_units':len(covered),'remaining_units':len(queue),'checks':len(checks),'context_changes':changes,'accepted':0}))
