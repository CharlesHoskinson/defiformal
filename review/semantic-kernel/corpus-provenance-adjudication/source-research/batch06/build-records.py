"""Offline batch06 assessment builder and byte/locator verifier. No network or corpus mutation."""
import sys
sys.dont_write_bytecode=True
from datetime import datetime,timezone
import hashlib,importlib.util,json,subprocess
from pathlib import Path
OUT=Path(__file__).resolve().parent;BASE=OUT.parent;ROOT=OUT.parents[4]
sha=lambda b:hashlib.sha256(b).hexdigest()
def read(p):return json.loads((ROOT/p).read_text())
def bind(p,pointer=None):
 b=(ROOT/p).read_bytes();r={'path':p,'sha256':sha(b),'bytes':len(b)}
 if pointer is not None:r['pointer']=pointer
 return r
def write(out,n,v):
 with (out/n).open('x') as f:
  if isinstance(v,str):f.write(v)
  else:json.dump(v,f,indent=2,ensure_ascii=False);f.write('\n')
def resolve(p,pointer):
 v=read(p)
 for k in pointer.strip('/').split('/'):v=v[int(k)] if isinstance(v,list) else v[k]
 return v
CONFIG={
'coinbase-cbbtc':{'disputes':[21,22],'scope':'cbBTC on Base/Ethereum only; documentary minting in September2024 and current Coinbase account transfer terms for eligible US customers; no other bundled wrapped product inference',
'locators':[('help','identity',2,10),('help','transfer-credit',34,68),('issuance','date',160,160),('issuance','minting',310,323),('terms','date',172,172),('terms','transfer-finality',320,343),('terms','wrapping-authority',1141,1159),('terms','redemption-liability',1178,1193),('terms','complaint',419,436),('terms','disputes',1447,1476)],
'claims':[
 ('dispute-21','mint_burn','supported','Coinbase describes customer-directed cbBTC minting to Base/Ethereum; the proposed rule is disjunctive (creates OR destroys supply). This supports documentary issuance, with Coinbase executing customer-directed outbound wrapping. Burn implementation and deployed role authorization remain unverified.',['issuance:minting','terms:wrapping-authority','help:identity']),
 ('dispute-22','async_cross_domain','supported','The cbBTC workflow causally connects the Coinbase account ledger with an external Base/Ethereum wallet: sending wraps and delivers; receiving unwraps and credits BTC. The agreement states network-pending transfers are incomplete until confirmation and wrapping requests need not be immediate. This is a custodial ledger/on-chain boundary, not a verified atomic Bitcoin-to-Base bridge.',['help:transfer-credit','terms:transfer-finality','terms:wrapping-authority','terms:redemption-liability']),
 ('dispute-22','offchain_legal_settlement','supported','For customers subject to the US agreement, wrapped-token redemption/shortfall obligations are stated alongside formal complaints and arbitration/court routes for agreement disputes. The proposed classification concerns contractual enforcement of those scoped obligations, not a claim that routine redemptions require litigation or that every holder in every jurisdiction has the same remedy.',['terms:redemption-liability','terms:complaint','terms:disputes','help:identity'])],
'limits':['The September25 2024 newsletter is historical. Its then-current supported chains, proof-of-reserves plans and promotional claims are not current operational facts. Its /en-ca URL is not evidence of present Canadian eligibility; current Help lists Canada among excluded cbBTC regions.',
'The US terms body is dated July22 2026. Apply its wrapped-token Appendix4 section8, not cbETH staking terms or section13 custom stablecoin terms. General transfer and dispute clauses are connected through this agreement and the cbBTC identity link; this is a proposed source interpretation, not a legal enforceability opinion.',
'Appchain consensus, trustless bridging, guaranteed finality, fixed confirmation count, universal redemption access and absence of pauses are not established. A successful outbound request is not yet a completed network transfer.',
'Coinbase controls the described account service; no mint/burn role address or bytecode was pinned. The failed whitepaper host supplies no support. No documentary issuance claim implies an audited total-supply invariant.',
'Only cbBTC is assessed. The parent bundle remains bundled; no result is inherited by cbETH or other Coinbase wrapped assets.']},
'btcb-cross-domain':{'disputes':[23],'scope':'BTCB as described in the BNB publisher blog dated November24 2020; exchange/bridge context only',
'locators':[('btcb-blog','publication-date',123,123),('btcb-blog','wrapped-transfer-context',132,139)],
'claims':[('dispute-23','async_cross_domain','not_evidenced','The retained historical publisher article identifies BTCB and withdrawal/bridge availability, but supplies no explicit causal delivery/finality boundary for BTC, exchange-ledger and BNB transitions. The three Binance responses are empty. Therefore the full positive predicate is not established; this is not refutation.',['btcb-blog:wrapped-transfer-context'])],
'limits':['Do not infer an asynchronous protocol from multi-chain availability, a token address, or the publisher calling a bridge decentralized. No bridge finality or BTCB minting workflow is verified.',
'The article is dated November24 2020 and cannot establish current availability, current reserve sufficiency or current deployment state. Do not inherit lending/minting mechanisms from its descriptions of third-party DeFi uses.',
'Binance HTTP202 zero-byte responses were marked retained by the transport script, but are explicitly empty/unusable here and receive zero source support. Search snippets were discovery only.',
'Next bounded retrieval would need an applicable BTCB transfer state machine or official workflow with source confirmation and destination-delivery conditions. Failed/empty acquisition does not mean such evidence does not exist.']},
'cow-solver-collateral':{'disputes':[24],'scope':'CoW Protocol standard/reduced solver bonding and EBBO reimbursement as described in current official docs; not all authenticated contracts or all historical solvers',
'locators':[('bonding','funded-safe',37,48),('bonding','vouch-and-release',49,80),('rules','enforcement-classes',36,48),('rules','social-slashing',135,139),('enforcement','loss-and-reimbursement',43,55),('enforcement','vote-conditioned-slash',56,63)],
'claims':[('dispute-24','collateralization','supported','Documented stablecoin/COW (and reduced-pool ETH) assets are placed in DAO-controlled Safes to back solver behavior. EBBO loss creates a reimbursement obligation; failed reimbursement can escalate to a vote that slashes the bond to repay the user. Bond dissolution requires unvouching and a governance process. This meets encumbered assets securing a scoped performance obligation without requiring a credit loan.',['bonding:funded-safe','bonding:vouch-and-release','enforcement:loss-and-reimbursement','enforcement:vote-conditioned-slash','rules:social-slashing'])],
'limits':['Slashing is governance-conditioned and discretionary, not an automatic smart-contract consequence of every bad settlement. The documentation distinguishes contract, off-chain and social enforcement.',
'Funding thresholds are stated in the captured docs only; no claim all governance revisions have been reconciled or that these values are current deployed parameters. A discovered newer draft proposing threshold changes is not adopted as current state.',
'The claim concerns standard/reduced bonded solver arrangements. Do not generalize to every address carrying a solver role, including governance-approved wrapper exceptions, or infer a direct retail lending/insurance/staking service.',
'No Safe ownership at a block, balance, vote execution, deployed contract revision, actual slashing transaction or release transaction was verified. Documentation supports the proposed rule application; it is not contract execution evidence.',
'The official llms index had stale underscore routes; both those404s and a failed ebbo-specifics guess are retained. The final ebbo-rules URL came from the bonding page link.']}
}
COMMON=['Unaccepted source-research draft; no canonical corpus overlay, no semantic-closure declaration and no untouched evaluation.', 'Original A/B records, generated intersections, citations and missing original references remain unchanged. New captures do not recover missing original artifacts.', 'Each unit uses one publisher family. Multiple pages are not independent-provider corroboration. No formal proof, runtime test or deployed fidelity is claimed.']
checks=[]
def check(n,v):
 checks.append({'name':n,'pass':bool(v)})
 if not v:raise AssertionError(n)
protected=read(str((OUT/'input-protection-before.json').relative_to(ROOT)))
for p,h in protected['files'].items():check('protected-before:'+p,bind(p)['sha256']==h)
candidate=read('review/semantic-kernel/sprint10/planning/r2-candidate.json')
check('exact-s10-input-count',len(candidate['inputs'])==88)
for row in candidate['inputs']:check('frozen-s10:'+row['path'],bind(row['path'])['sha256']==row['sha256'])
triagepath='review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json';triage=read(triagepath)
designpath='openspec/changes/corpus-provenance-adjudication/design.md';lines=(ROOT/designpath).read_text().splitlines()
s=importlib.util.spec_from_file_location('extract_batch06',OUT/'extract.py');ext=importlib.util.module_from_spec(s);s.loader.exec_module(ext)
verify='--verify-only' in sys.argv
summaries=[]
for name,cfg in CONFIG.items():
 out=BASE/name;rel=str(out.relative_to(ROOT));start_checks=len(checks)
 exfile=out/('extraction-final.json' if (out/'extraction-final.json').exists() else 'extraction.json')
 extraction=json.loads(exfile.read_text());sources={x['source_id']:x for x in extraction}
 statuses=[]
 for rp in sorted(out.rglob('retrievals.json')):
  for row in json.loads(rp.read_text())['records']:
   for a in row['attempts']:
    if a['status']=='retained':
     b=(ROOT/a['capture_path']).read_bytes();check('capture:'+a['capture_path'],sha(b)==a['body_sha256'] and len(b)==a['body_bytes'])
     status='substantive_body_retained' if b else 'empty_transport_response_no_support'
    else:
     status='failed_no_support'
     if 'error_capture_path' in a:
      b=(ROOT/a['error_capture_path']).read_bytes();check('error-body:'+a['error_capture_path'],sha(b)==a['error_body_sha256'] and len(b)==a['error_body_bytes'])
    statuses.append({'retrieval_record':bind(str(rp.relative_to(ROOT))),'source_id':row['source_id'],'attempt':a['attempt'],'status':status,'support_credit':status=='substantive_body_retained','http_status':a.get('http_status'),'body_bytes':a.get('body_bytes',0),'requested_url':row['requested_url'],'final_url':a.get('final_url'),'capture_path':a.get('capture_path'),'error':a.get('error')})
 check('primary-body-budget:'+name,0<len(sources)<=3)
 for sid,e in sources.items():
  b=(ROOT/e['capture_path']).read_bytes();derived=(ROOT/e['output_path']).read_bytes();p=ext.Text();p.feed(b.decode());actual=('\n'.join(p.nodes)+'\n').encode()
  check('extraction:'+name+':'+sid,sha(b)==e['capture_sha256'] and sha(derived)==e['output_sha256'] and actual==derived and bind(e['extractor_path'])['sha256']==e['extractor_sha256'])
 locators=[]
 for sid,label,first,last in cfg['locators']:
  e=sources[sid];data=(ROOT/e['output_path']).read_bytes();ls=data.splitlines(keepends=True);a=sum(map(len,ls[:first-1]));b=sum(map(len,ls[:last]));check('nonempty-span:'+name+':'+label,a<b<=len(data))
  locators.append({'id':sid+':'+label,'source_id':sid,'original_capture':bind(e['capture_path']),'derived_text':bind(e['output_path']),'extraction_record':bind(str(exfile.relative_to(ROOT))),'coordinate_space':'Derived UTF-8 text bytes, not HTML response offsets','byte_start':a,'byte_end_exclusive':b,'line_start':first,'line_end':last,'span_sha256':sha(data[a:b])})
 ids={l['id'] for l in locators};check('unique-locators:'+name,len(ids)==len(locators))
 selected=[r for r in triage['disagreements'] if int(r['id'].split('-')[1]) in cfg['disputes']]
 obs=[];claims=[]
 for r in selected:
  item={'triage':bind(triagepath,'/disagreements/'+str(int(r['id'].split('-')[1])-1)),'raw_triage_record':r,'records':{},'current_inventory':{'binding':bind(r['inventory']['path'],r['inventory']['pointer']),'value':resolve(r['inventory']['path'],r['inventory']['pointer'])}}
  for key,binding in [('raw_a',r['raw_a']['record']),('raw_b',r['raw_b']['record']),('generated',r['generated']['pointer']),('neutral_context',r['neutral_context']),('original_context',r['original_context'])]:
   check('observation-binding:'+name+':'+r['id']+':'+key,bind(binding['path'],binding['pointer'])==binding)
   item['records'][key]={'source':binding,'value':resolve(binding['path'],binding['pointer'])}
  check('generated-preserved:'+r['id'],item['records']['generated']['value']==r['generated']['record']);obs.append(item)
 for dispute,label,status,reason,evidence in cfg['claims']:
  row=next(r for r in selected if r['id']==dispute);rule=next(c['rule_id'] for c in row['label_claims'] if c['label']==label)
  line_no,literal=next((i,l) for i,l in enumerate(lines,1) if l.startswith('| `'+rule+'` /'))
  check('claim-locators:'+name+':'+label,set(evidence)<=ids)
  claims.append({'dispute_id':dispute,'facet':row['facet'],'label':label,'rule':{'id':rule,'source':{**bind(designpath),'line':line_no},'literal_table_row':literal,'version':'proposed evidence-adjudication/1'},'proposed_disposition':status,'accepted_disposition':None,'reason_type':'source-scoped inference from the bound publisher descriptions','reason':reason,'evidence':evidence})
 check('complete-disputed-labels:'+name,{(c['dispute_id'],c['label']) for c in claims}=={(r['id'],c['label']) for r in selected for c in r['label_claims']})
 summary={'packet':name,'unit_id':selected[0]['unit_id'],'disputes':[r['id'] for r in selected],'source_bodies':len(sources),'source_bytes':sum((ROOT/e['capture_path']).stat().st_size for e in extraction),'locators':len(locators),'proposals':[{k:c[k] for k in ['dispute_id','label','proposed_disposition']} for c in claims]}
 if verify:
  for item in read(rel+'/artifact-manifest.json')['files']:check('manifest:'+item['path'],bind(item['path'])==item)
 else:
  write(out,'selection-and-observations.json',{'records':obs,'scope':cfg['scope'],'inventory_note':'Historical triage whole-file hash is preserved. Current post-CP01 inventory binding is separate; no original triage repair is implied.'})
  write(out,'evidence-locators.json',{'locators':locators,'method':'Exact LF line ranges and derived UTF-8 bytes; original capture and reproducibly extracted text hashes bound separately. Source bodies contain navigation; only designated ranges support claims.'})
  write(out,'proposed-adjudication.json',{'process_status':'draft_review_pending','unit_id':selected[0]['unit_id'],'scope':cfg['scope'],'claims':claims,'qualifications':cfg['limits']+COMMON,'accepted_disposition':None,'overlay_applied':False,'semantic_closure':False,'deployed_fidelity_status':'unresolved','original_reference_recovery_status':'unresolved','source_independence_group':name.split('-')[0]+'-publisher','source_assessment':statuses})
  report='# '+name+' — draft source assessment\n\n**Independent review pending. No corpus labels changed.**\n\nScope: '+cfg['scope']+'.\n\n'
  for c in claims:report+='- `'+c['dispute_id']+'` / `'+c['label']+'`: proposed **'+c['proposed_disposition']+'**. '+c['reason']+'\n'
  report+='\nThe following limits govern these proposals:\n\n'+'\n'.join('- '+q for q in cfg['limits']+COMMON)+'\n\nRetained substantive sources ('+str(len(sources))+', '+str(summary['source_bytes'])+' bytes), retrieved 2026-09-07:\n\n'
  for sid,e in sources.items():
   rr=next(r for r in read(e['retrieval_record'])['records'] if r['source_id']==sid);a=rr['attempts'][-1];report+='- ['+sid+']('+a['final_url']+'): '+a['body_sha256']+'; '+a['finished_utc']+'.\n'
  report+='\n[Exact observations](selection-and-observations.json), [locators](evidence-locators.json) and [proposals with transport assessment](proposed-adjudication.json) preserve the evidence/inference boundary. Failed routes and empty transport captures receive no support. All sources for this unit belong to one publisher family. Search results only located sources; their snippets were not evidence. The bounded stop is source sufficiency for the stated proposal or a remaining retrieval gap, not proof of source absence.\n\nOffline checks use `python3 '+str((OUT/'build-records.py').relative_to(ROOT))+' --verify-only`. [Verification](verification.json) and [manifest](artifact-manifest.json) bind this packet and the shared batch helpers. No protocol or contract execution occurred.\n'
  write(out,'REPORT.md',report)
  for p,h in protected['files'].items():check('protected-after:'+name+':'+p,bind(p)['sha256']==h)
  write(out,'verification.json',{'created_utc':datetime.now(timezone.utc).isoformat(),'checks':checks[start_checks:],'check_count':len(checks)-start_checks,'all_passed':True,'input_protection':bind(str((OUT/'input-protection-before.json').relative_to(ROOT))),'protected_files':len(protected['files']),'protected_drift':[],'summary':summary,'scope':'Byte/extraction/locator/original-record integrity, not semantic acceptance or deployed fidelity'})
  helpers=[bind(str(p.relative_to(ROOT))) for p in sorted(OUT.glob('*.py'))]
  files=[bind(str(p.relative_to(ROOT))) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json']
  write(out,'artifact-manifest.json',{'files':files+helpers,'excludes':'manifest self; shared helpers included by exact hash'})
 summaries.append(summary)
for p,h in protected['files'].items():check('batch-final-protected:'+p,bind(p)['sha256']==h)
if not verify:
 write(OUT,'batch-report.json',{'status':'three_unaccepted_draft_packets','packets':summaries,'all_passed':True,'check_count':len(checks),'checks':checks,'protected_files':len(protected['files']),'s10_inputs':88,'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'model_identity':'Requested stock GPT-6; no independent model telemetry available inside this worker','review_status':'not_independently_reviewed','retrieval_qualification':'Initial three targets per unit; failed routes and empty responses preserved. Corrected/fallback routes were bounded to ≤3 substantive bodies per unit, not ≤3 lifetime URLs.'})
 files=[bind(str(p.relative_to(ROOT))) for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json' and '__pycache__' not in p.parts]
 for name in CONFIG:files.append(bind(str((BASE/name/'artifact-manifest.json').relative_to(ROOT))))
 write(OUT,'artifact-manifest.json',{'scope':'Batch06 helper/input/result bytes plus each complete packet manifest; manifest self excluded','files':files})
else:
 for item in read(str((OUT/'artifact-manifest.json').relative_to(ROOT)))['files']:check('batch-manifest:'+item['path'],bind(item['path'])==item)
print(json.dumps({'all_passed':True,'checks':len(checks),'packets':summaries,'manifest':bind(str((OUT/'artifact-manifest.json').relative_to(ROOT)))},indent=2))
