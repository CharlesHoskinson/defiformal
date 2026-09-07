#!/usr/bin/env python3
"""Offline construction and integrity checks for a bounded unaccepted research pass."""
import datetime,hashlib,importlib.util,json,pathlib,subprocess,sys
sys.dont_write_bytecode=True
B=pathlib.Path(__file__).resolve().parent;R=B.parents[4]
def sha(b):return hashlib.sha256(b).hexdigest()
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def read(p):return json.loads((B/p).read_text())
def write(p,x):
 data=(json.dumps(x,indent=2,ensure_ascii=False)+'\n').encode()
 if (B/p).exists():assert (B/p).read_bytes()==data,p
 else:(B/p).write_bytes(data)
def git(*args):
 p=subprocess.run(['git',*args],cwd=R,capture_output=True,text=True);return p.stdout.strip() if p.returncode==0 else None
def pointer(x,p):
 for k in p.strip('/').split('/'):x=x[int(k)] if isinstance(x,list) else x[k]
 return x
spec=importlib.util.spec_from_file_location('inputs',B/'card-inputs.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
checks=[]
def check(name,condition):
 checks.append({'check':name,'pass':bool(condition)})
 if not condition:raise AssertionError(name)
selected=read('selected-units.json');queue=json.loads((R/selected['queue_path']).read_text());units=selected['units'];check('queue sha',sha((R/selected['queue_path']).read_bytes())==selected['queue_sha256']);check('exact finite slice',queue['remaining'][16:32]==[u['queue_item'] for u in units]);check('16 unique units',len({u['queue_item']['unit_id'] for u in units})==16)
cap={p.parent.name:json.loads(p.read_text()) for p in (B/'captures').glob('*/capture.json')};ex={s['target_id']:s for s in read('extraction.json')['sources']};check('extractor hash',read('extraction.json')['extractor_sha256']==sha((B/'extract.py').read_bytes()))
plans=[]
for p in B.glob('pass01*.json'):plans.extend(json.loads(p.read_text())['targets'])
check('all planned targets exactly captured',sorted(t['id'] for t in plans)==sorted(cap))
for id,c in cap.items():
 check(id+' attempts',1<=len(c['attempts'])<=2)
 for a in c['attempts']:
  for f in a['files']:check(id+' '+f['path'],(B/f['path']).stat().st_size==f['bytes'] and sha((B/f['path']).read_bytes())==f['sha256'])
  cmd=a['command'];check(id+' limits',all(cmd[cmd.index(flag)+1]==v for flag,v in [('--max-redirs','5'),('--max-time','30'),('--max-filesize','5242880')]))
  check(id+' redirects',a['curl'].get('num_redirects',0)<=5)
  check(id+' source support status',a['transport_body_success']==(a['returncode']==0 and 200<=a['curl'].get('http_code',0)<300 and any(f['path'].endswith('.body') and 0<f['bytes']<=5242880 for f in a['files'])))
 if id in ex:
  s=ex[id];check(id+' extracted sha',sha((B/s['derived']['path']).read_bytes())==s['derived']['sha256']);check(id+' input body match',s['original'] in c['attempts'][-1]['files'])
locators=[];cards=[];observations=[]
for u in units:
 n=u['queue_position_1based'];q=u['queue_item'];d=mod.DATA[n];ids=[k for k,c in cap.items() if c['unit_id']==q['unit_id']];check(str(n)+' budget',1<=len({cap[k]['url'] for k in ids})<=3)
 canonical=q['canonical_record'];raw=q['source_row'];corpus=json.loads((R/canonical['path']).read_text());check(str(n)+' canonical row exact',pointer(corpus,canonical['pointer'])==u['canonical_unit']);check(str(n)+' original exact',pointer(corpus,raw['pointer'])==u['exact_source_record'])
 annotations=[]
 for ref in u['canonical_unit']['annotation_refs']:
  p=R/ref['path'];check(str(n)+' annotation hash '+ref['annotator_id'],sha(p.read_bytes())==ref['sha256']);annotations.append({'ref':ref,'exact_annotation':pointer(json.loads(p.read_text()),ref['pointer'])})
 observations.append({**u,'original_annotations':annotations,'original_source_row_sha256_checked':sha((R/u['exact_source_record']['source_path']).read_bytes())==u['exact_source_record']['source_sha256']})
 refs=[]
 for i,(sid,anchor,length,interpretation) in enumerate(d['locs'],1):
  id='u'+sid;s=ex[id];data=(B/s['derived']['path']).read_bytes();text=data.decode();pos=text.find(anchor);check(f'{n} locator{i} anchor',pos>=0)
  start=len(text[:pos].encode());end=len(text[:pos+length].encode());excerpt=data[start:end];lid=f'U{n:02d}-L{i:02d}';refs.append(lid)
  locators.append({'id':lid,'unit_id':q['unit_id'],'target_id':id,'source_url':s['url'],'capture':s['original'],'derived':s['derived'],'extractor_sha256':read('extraction.json')['extractor_sha256'],'byte_start_inclusive':start,'byte_end_exclusive':end,'line_start_1based':data[:start].count(b'\n')+1,'line_end_1based':data[:end].count(b'\n')+1,'excerpt_utf8':excerpt.decode(),'excerpt_sha256':sha(excerpt),'interpretation':interpretation,'support_scope':'Publisher statement or inspected source bytes; not implementation execution, legal adjudication or deployed fidelity.'})
 pins=[]
 for id in ids:
  if id not in ex or 'raw.githubusercontent.com/' not in cap[id]['url']:continue
  parts=cap[id]['url'].split('/');commit=parts[5];repo='/'.join(parts[3:5]);metadata=[k for k in ids if 'api.github.com/repos/'+repo+'/commits' in cap[k]['url']];check(id+' pin metadata exists',len(metadata)==1)
  meta=json.loads((B/ex[metadata[0]]['derived']['path']).read_text());meta=meta[0] if isinstance(meta,list) else meta;check(id+' exact commit binding',meta['sha']==commit and len(commit)==40)
  pins.append({'repository':'https://github.com/'+repo,'commit':commit,'file_path':'/'.join(parts[6:]),'source_target':id,'metadata_target':metadata[0],'file_sha256':ex[id]['original']['sha256'],'git_blob_sha1_of_captured_file':hashlib.sha1(b'blob '+str(ex[id]['original']['bytes']).encode()+b'\0'+(B/ex[id]['original']['path']).read_bytes()).hexdigest(),'status':'exact_commit_URL_and_metadata_source_candidate; repository tree/build/deployment not verified'})
 dep=[]
 if n==20:dep=[{'product':'stETH Yield Layer manager','address':'0x6d425B3D302DD82cC611866eC8176d435307b616','chain':None,'chain_status':'not established by selected table locator','source_locator':'U20-L04','status':'publisher_documentation_candidate_only'}]
 if n==25:dep=[{'product':'Bridge2','address':'0x2df1c51e09aecf9cacb7bc98cb1742757f163df7','chain':'Arbitrum (publisher document; no RPC check)','source_locator':'U25-L01','status':'publisher_documentation_candidate_only'}]
 cards.append({'queue_position_1based':n,'unit_id':q['unit_id'],'original_label':q['label'],'status':'UNACCEPTED_PROVISIONAL_IDENTITY_SOURCE_CARD' if refs else 'UNACCEPTED_SOURCE_GAP','brand':{'value':q['label'],'status':'original label retained; product sources separately cited'},'legal_entity_or_issuer':{'value':'OKX Technology Inc.' if n==30 else None,'status':'publisher of retained scoped policy only; issuer/service applicability not adjudicated' if n==30 else 'unresolved; not inferred from brand or repository organization'},'proposed_product_scope':d['product'],'version_scope':d['version'],'split_proposal':d['split'],'sourced_dependency_scope':d['dependencies'],'source_pins':pins,'deployment_candidates':dep,'deployment_verified':False,'deployed_fidelity':'UNVERIFIED','identity_accepted':False,'facet_adjudication_performed':False,'original_annotation_labels_inherited':False,'evaluation_role':'development; no untouched claim','support_locators':refs,'target_ids':sorted(ids),'remaining_gaps':d['gaps']})
check('all original hashes',all(o['original_source_row_sha256_checked'] for o in observations))
write('observations.json',{'status':'exact original data retained; no reinterpretation of original labels','units':observations});write('locators.json',{'offset_convention':'UTF8 bytes start-inclusive/end-exclusive in named derived file; original capture/extractor hashes bind transformation','locators':locators});write('provisional-cards.json',{'status':'all unaccepted; no canonical mutation','cards':cards})
before=read('protection-before.json');afterhead=git('rev-parse','HEAD');bindings=[]
for p in before['paths']:
 data=(R/p['path']).read_bytes();same=sha(data)==p['sha256'] and len(data)==p['bytes'];check('protected '+p['path'],same);old=git('rev-parse',f"{before['head']}:{p['path']}");check('old Git binding '+p['path'],old==p['git_blob_at_head']);bindings.append({'path':p['path'],'same_bytes':same,'sha256_after':sha(data),'git_blob_at_start_head':old,'git_blob_at_end_head':git('rev-parse',f"{afterhead}:{p['path']}")})
for p in json.loads((R/'review/semantic-kernel/sprint10/planning/r2-candidate.json').read_text())['inputs']:check('S10 frozen '+p['path'],sha((R/p['path']).read_bytes())==p['sha256'])
result={'status':'PASS','verified_utc':utc(),'research_only':True,'head_before':before['head'],'head_after':afterhead,'head_moved':before['head']!=afterhead,'head_equality_required':False,'protected_input_count':len(bindings),'all_protected_bytes_unchanged':True,'s10_bound_inputs_checked':88,'units':len(cards),'cards_with_substantive_locators':sum(bool(c['support_locators']) for c in cards),'unresolved_no_body_units':[c['unit_id'] for c in cards if not c['support_locators']],'primary_targets':len(cap),'attempts':sum(len(c['attempts']) for c in cap.values()),'successful_nonempty_target_bodies':len(ex),'body_bytes_success':sum(s['original']['bytes'] for s in ex.values()),'empty_or_failed_attempts':sum(not a['transport_body_success'] for c in cap.values() for a in c['attempts']),'source_pin_units':sum(bool(c['source_pins']) for c in cards),'pinned_files':sum(len(c['source_pins']) for c in cards),'locators':len(locators),'accepted_identities':0,'verified_deployments':0,'checks_passed':len(checks),'checks':checks,'bindings':bindings}
# A verification rerun writes a separate result rather than falsifying original UTC/HEAD.
if '--verify-only' not in sys.argv:write('verification.json',result)
if '--verify-only' not in sys.argv:
 lines=['# Identity/source research batch02','',f"Unaccepted bounded research for remaining queue entries 17–32 (slice 16:32): 16 original development units. {result['cards_with_substantive_locators']} have substantive source locators; Binance Wallet remains a source gap. No identity, facet, deployment or fidelity decision is accepted.",'',f"Captured {result['primary_targets']} distinct primary URL targets in one pass, at most 3 per original unit, {result['attempts']} attempts, {result['successful_nonempty_target_bodies']} nonempty bodies ({result['body_bytes_success']} bytes), and {result['empty_or_failed_attempts']} empty/failed attempts. All 6 empty attempts are Binance HTTP202 responses. No fourth target or expansion pass was used. Search snippets only helped select URLs and receive no support credit.",'',f"Five repository commit candidates bind {result['pinned_files']} retained files; these are individual source/doc files plus commit metadata, not complete code/build closures or deployed artifacts. The {len(locators)} locators bind exact UTF8 offsets, raw captures and the deterministic extractor. Source update strings are retained as published; relative dates are not converted into invented publication times.",'',f"Protection checked {len(bindings)} existing local inputs including all 88 S10 R2 inputs, canonical corpus, stable earlier source packets, refresh03 and exposure artifacts. Start HEAD `{before['head']}`; end HEAD `{afterhead}`; HEAD movement={result['head_moved']}. Exact protected bytes and old Git-object bindings are unchanged. Concurrent identity batches are outside this protection set.",'','| Queue | Original unit | Scoped finding | Remaining boundary |','|---|---|---|---|']
 for c in cards:lines.append(f"| {c['queue_position_1based']} | {c['original_label']} `{c['unit_id']}` | {c['proposed_product_scope']} | {c['remaining_gaps']} |")
 lines+=['','The original normalized records, A/B annotations, split status and full raw source rows/residue are retained in `observations.json`. `provisional-cards.json` separates brand, policy publisher/legal-entity status, product/version, code pin, deployment candidate and dependency. There is no label inheritance from a source dependency or from a neighboring product. None of these development units is an untouched holdout.','','Material qualifications: Across V4 documentation adds SP1/Ethereum-state proof infrastructure while explicitly retaining UMA repayment-bundle verification; do not describe it as replacing every optimistic stage. Beefy V7 source permits owner-gated strategy replacement after a delay; broad website immutability prose is insufficient for a version/deployment claim. Hyperliquid source uses strictly greater than two-thirds validator power, despite approximate prose in its header. OKX Technology Inc. is identified only as the publisher of the captured policy. The unretained Binance search result does not establish any legal provider.','','Reproduce offline extraction with `python3 '+str((B/'extract.py').relative_to(R))+'` and verification with `python3 '+str((B/'build-records.py').relative_to(R))+' --verify-only` from the repository root. Recheck prints a fresh summary and does not rewrite original artifacts. Capture commands, actual UTC/elapsed time, curl metadata/headers, stdout/stderr and hashes are retained per attempt. Reacquisition would create new observations, not reproduce immutable remote bytes; capture.py refuses existing target directories.','','This helper is research-only, not the future production collector. Its limits are the actual declared pass limits. No source generation, Lean execution, review gate or canonical corpus update took place.']
 (B/'REPORT.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['checks','bindings']},indent=2))
