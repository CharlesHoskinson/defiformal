#!/usr/bin/env python3
"""Produce a draft redemption record from retained local sources; no network or corpus edits."""
from pathlib import Path
import datetime,hashlib,json,re,bs4
OUT=Path(__file__).resolve().parent
ROOT=next(p for p in OUT.parents if (p/'AGENTS.md').exists())
OLD=OUT.parent/'liquity-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
def load(p):return json.loads(p.read_text())
def write(name,obj):(OUT/name).write_text(json.dumps(obj,indent=2,ensure_ascii=False)+'\n')
source_map={}
for folder,filename,ident in [(OLD,'retrievals.json','trove-manager'),(OLD,'retrievals-repay.json','borrower-operations'),(OUT,'retrievals.json','v1-redemption-faq'),(OUT,'retrievals-base.json','liquity-base')]:
 manifest=folder/filename;record=next(r for r in load(manifest)['records'] if r['source_id']==ident);a=record['attempts'][-1];capture=folder/a['capture_path'];assert sha(capture.read_bytes())==a['body_sha256']
 source_map[ident]={'source_id':ident,'acquisition':'shared immutable capture; not fetched again' if folder==OLD else 'fresh retained response','source_manifest':str(manifest.relative_to(ROOT)),'source_manifest_sha256':sha(manifest.read_bytes()),'capture_path':str(capture.relative_to(ROOT)),'capture_sha256':a['body_sha256'],'capture_bytes':a['body_bytes'],'original_retrieval_record':record}
write('source-provenance.json',{'schema_version':1,'sources':source_map,'shared_package_manifest':{'path':str((OLD/'artifact-manifest.json').relative_to(ROOT)),'sha256':sha((OLD/'artifact-manifest.json').read_bytes())},'scope':'No original source capture was recopied or relabelled as a fresh retrieval.'})
locators=[]
def span(ident,label,start,end,method):
 src=source_map[ident];raw=(ROOT/src['capture_path']).read_bytes();b=raw[start:end];assert b
 row={'id':ident+':'+label,'source_id':ident,'capture_path':src['capture_path'],'capture_sha256':src['capture_sha256'],'byte_start':start,'byte_end_exclusive':end,'line_start':raw[:start].count(b'\n')+1,'line_end':raw[:end].count(b'\n')+1,'span_sha256':sha(b),'method':method};locators.append(row)
def sol(ident,symbol):
 raw=(ROOT/source_map[ident]['capture_path']).read_bytes();m=re.search(rb'    function '+re.escape(symbol.encode())+rb'\s*\(',raw);assert m
 body=raw.index(b'{',m.end());depth=0
 for i in range(body,len(raw)):
  if raw[i:i+1]==b'{':depth+=1
  elif raw[i:i+1]==b'}':
   depth-=1
   if depth==0:span(ident,symbol,m.start(),i+1,'Exact signature and balanced-brace source span; not a Solidity parser or execution');return
 raise AssertionError(symbol)
for f in ['redeemCollateral','_redeemCollateralFromTrove','_redeemCloseTrove','_isValidFirstRedemptionHint','_requireAfterBootstrapPeriod','_requireLUSDBalanceCoversRedemption','_requireAmountGreaterThanZero','_requireTCRoverMCR','_requireValidMaxFeePercentage','_calcRedemptionFee','_closeTrove','_requireMoreThanOneTroveInSystem']:
 sol('trove-manager',f)
for f in ['repayLUSD','_repayLUSD']:sol('borrower-operations',f)
sol('liquity-base','_requireUserAcceptsFee')
for ident,label,text in [('trove-manager','bootstrap-constant','uint constant public BOOTSTRAP_PERIOD = 14 days;'),('liquity-base','MCR-constant','uint constant public MCR = 1100000000000000000;')]:
 raw=(ROOT/source_map[ident]['capture_path']).read_bytes();start=raw.index(text.encode());span(ident,label,start,start+len(text.encode()),'Exact retained source substring')
raw=(ROOT/source_map['v1-redemption-faq']['capture_path']).read_bytes();soup=bs4.BeautifulSoup(raw,'html.parser');assert 'Docs V1' in soup.title.get_text()
for label,text in [('v1-title',soup.title.get_text()),('holder-redemption','A redemption is the process of exchanging LUSD for ETH at face value'),('repayment-distinction','No, redemptions are a completely separate mechanism.'),('documentation-qualification','Users can redeem their LUSD for ETH at any time without limitations.')]:
 start=raw.index(text.encode());span('v1-redemption-faq',label,start,start+len(text.encode()),'Exact raw HTML substring; page inspected with BeautifulSoup '+bs4.__version__+' html.parser')
write('evidence-locators.json',{'schema_version':1,'locators':locators})
unit='unit:lane1:c2:p4:v1';obs=[]
for a in ['a','b']:
 p=ROOT/'corpus/normalized/annotations'/f'{a}.json';d=load(p);i,row=next((i,r) for i,r in enumerate(d['annotations']) if r['unit_id']==unit)
 obs.append({'annotator_id':a,'path':str(p.relative_to(ROOT)),'sha256':sha(p.read_bytes()),'pointer':f'/annotations/{i}','raw_record':row})
assert 'redemption' not in obs[0]['raw_record']['facets']['mechanisms'] and 'redemption' in obs[1]['raw_record']['facets']['mechanisms']
p=ROOT/'corpus/normalized/generated/corpus.json';d=load(p);i,row=next((i,r) for i,r in enumerate(d['adjudications']) if r['unit_id']==unit and r['facet']=='mechanisms');facet={'path':str(p.relative_to(ROOT)),'sha256':sha(p.read_bytes()),'pointer':f'/adjudications/{i}','raw_record':row};assert row['rule']=='INTERSECTION_UNRESOLVED' and row['unresolved_labels']==['redemption']
p=ROOT/'openspec/changes/corpus-provenance-adjudication/dispute-inventory.json';inventory=load(p);dispute=next(r for r in inventory['disagreements'] if r['id']=='dispute-04');assert dispute['disputed_labels']==['redemption']
p=ROOT/'openspec/changes/corpus-provenance-adjudication/design.md';lines=p.read_text().splitlines();rule=next(line for line in lines if line.startswith('| `R-redemption`'))
report={'schema_version':1,'kind':'single-disagreement-source-research','created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'author_identity':'GPT-6 stock Codex harness; no provider telemetry inferred','unit_id':unit,'dispute_id':'dispute-04','facet':'mechanisms','label':'redemption','process_status':'draft_review_pending','proposed_disposition':'supported','actual_inventory_record':dispute,'raw_annotations':obs,'actual_facet_decision':facet,'rule':{'id':'R-redemption','version':'proposed evidence-adjudication/1','status':'existing proposed rule applied; not accepted by this research','path':str(p.relative_to(ROOT)),'sha256':sha(p.read_bytes()),'line':lines.index(rule)+1,'exact_rule_row':rule},'scoped_proposition':'Liquity V1 documentation and ETH/LUSD source at commit 3e64ee1b52c50d51587c64c1cf75e0ba82934979 provide holder-submitted LUSD redemption against Trove collateral, subject to the inspected conditions.','rule_application':{'holder_submission':['v1-redemption-faq:holder-redemption','trove-manager:redeemCollateral'],'backing_settlement':['trove-manager:_redeemCollateralFromTrove','trove-manager:_redeemCloseTrove'],'stated_conditions':['trove-manager:_requireAfterBootstrapPeriod','trove-manager:_requireLUSDBalanceCoversRedemption','trove-manager:_requireAmountGreaterThanZero','trove-manager:_requireTCRoverMCR','trove-manager:_requireValidMaxFeePercentage','trove-manager:_isValidFirstRedemptionHint','trove-manager:_calcRedemptionFee','liquity-base:_requireUserAcceptsFee'],'borrower_repayment_is_insufficient':['v1-redemption-faq:repayment-distinction','borrower-operations:repayLUSD','borrower-operations:_repayLUSD']},'material_qualifications':['TroveManager reduces selected Trove debt/collateral, burns the amount actually redeemed from the caller, and pays net ETH after fees. This is neither a market-sale label nor evidence based only on borrower repayment.','Requested amount need not equal executed amount: the iteration limit and cancelled partial redemption may stop progress. No positive ETH drawn causes refusal.','The FAQ unconditional-time wording is not accepted as an execution guarantee: bootstrap, collateral-ratio, balance/amount, fees, hints, minimum remaining debt, last-Trove and other execution conditions remain.','An omission under the original SOURCE_ONLY annotation protocol is not evidence of protocol absence. Fresh primary support does not rewrite the annotator history.'],'proposed_overlay_effect_if_later_accepted':{'effective_mechanisms':['collateralization','liquidation','redemption'],'scope':'Resolve only the disputed redemption member; collateralization and liquidation retain their pre-existing provisional provenance. The separate liquidation challenge retains its own process status.','current_changes_applied':False},'provenance_status':{'source_revision':'3e64ee1b52c50d51587c64c1cf75e0ba82934979','source_inspection':'performed on retained bytes; no Solidity execution','deployment':'unresolved','model_fidelity':'not_evaluated','original_reference_recovery':'none; current evidence is reconstructed support','exposure':'existing development case, not holdout'},'limits':['No Liquity V2/BOLD, historical deployment or bytecode/build correspondence claim.','Only one of29 facet disagreements researched; none marked accepted or mutated.','No corpus tooling implementation, rule change, annotation replacement, synthetic recovery or untouched evaluation.','Code imports are not fully closed or executed; source inspection does not certify success, arithmetic or financial invariants.'],'required_next_step':'Independent review of exact source/rule/observation bindings before appending a separately accepted versioned adjudication.'}
write('proposed-adjudication.json',report)
print(len(locators),'locators; four sources (two shared, two fresh); one draft disputed-label decision')
