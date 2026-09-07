#!/usr/bin/env python3
"""Build source locators and a draft decision from retained bodies, without fetching."""
from pathlib import Path
import bs4,datetime,hashlib,json,re
OUT=Path(__file__).resolve().parent
ROOT=next(p for p in OUT.parents if (p/'AGENTS.md').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
def read(p):return json.loads(p.read_text())
def write(name,d):(OUT/name).write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
records=sum([read(OUT/name)['records'] for name in ['retrievals.json','retrievals-repay.json']],[])
sources={r['source_id']:r for r in records}
locators=[]
def sol(ident,symbol):
 r=sources[ident];a=r['attempts'][-1];raw=(OUT/a['capture_path']).read_bytes();assert sha(raw)==a['body_sha256']
 match=re.search(rb'    function '+re.escape(symbol.encode())+rb'\s*\(',raw);assert match,symbol
 start=match.start();body=raw.index(b'{',match.end());depth=0;end=None
 for i in range(body,len(raw)):
  if raw[i:i+1]==b'{':depth+=1
  elif raw[i:i+1]==b'}':
   depth-=1
   if depth==0:end=i+1;break
 assert end is not None
 row={'id':ident+':'+symbol,'source_id':ident,'symbol':symbol,'capture_path':a['capture_path'],'capture_sha256':a['body_sha256'],'byte_start':start,'byte_end_exclusive':end,'line_start':raw[:start].count(b'\n')+1,'line_end':raw[:end].count(b'\n')+1,'span_sha256':sha(raw[start:end]),'extraction':'ASCII function signature and balanced braces; exact retained source bytes; not a Solidity parser or proof','source_url':a['requested_url'],'source_revision':r['source_revision']}
 locators.append(row)
for symbol in ['liquidate','_liquidateNormalMode','_liquidateRecoveryMode','_getOffsetAndRedistributionVals','_getCappedOffsetVals','batchLiquidateTroves','_getTotalsFromBatchLiquidate_NormalMode','_redistributeDebtAndColl','_closeTrove','redeemCollateral']:
 sol('trove-manager',symbol)
for symbol in ['getMaxAmountToOffset','offset','_moveOffsetCollAndDebt']:
 sol('stability-pool',symbol)
for symbol in ['repayLUSD','_adjustTrove','closeTrove','_repayLUSD']:
 sol('borrower-operations',symbol)
faq=sources['v1-liquidation-faq']['attempts'][-1];raw=(OUT/faq['capture_path']).read_bytes();soup=bs4.BeautifulSoup(raw,'html.parser');assert 'Docs V1' in soup.title.get_text()
for ident,text in [('v1-title','Stability Pool and Liquidations | Docs V1 | Liquity Docs'),('liquidation-eligibility','To ensure that the entire stablecoin supply remains fully backed by collateral,'),('redistribution','If the Stability Pool is empty, the system uses a secondary liquidation mechanism called redistribution.')]:
 needle=text.encode();start=raw.index(needle)
 locators.append({'id':'faq:'+ident,'source_id':'v1-liquidation-faq','capture_path':faq['capture_path'],'capture_sha256':faq['body_sha256'],'byte_start':start,'byte_end_exclusive':start+len(needle),'span_sha256':sha(needle),'extraction':'Exact raw HTML byte substring; surrounding paragraph inspected with BeautifulSoup '+bs4.__version__+' html.parser','source_url':faq['requested_url'],'source_revision':None})
write('evidence-locators.json',{'schema_version':1,'locators':locators})
unit='unit:lane1:c2:p4:v1';annotations=[]
for annotator in ['a','b']:
 path=ROOT/'corpus/normalized/annotations'/f'{annotator}.json';data=read(path)
 index,row=next((i,r) for i,r in enumerate(data['annotations']) if r['unit_id']==unit)
 assert 'liquidation' in row['facets']['mechanisms']
 annotations.append({'annotator_id':annotator,'path':str(path.relative_to(ROOT)),'sha256':sha(path.read_bytes()),'pointer':f'/annotations/{index}','unchanged_record':row})
corpuspath=ROOT/'corpus/normalized/generated/corpus.json';corpus=read(corpuspath)
index,facet=next((i,r) for i,r in enumerate(corpus['adjudications']) if r['unit_id']==unit and r['facet']=='mechanisms')
assert facet['rule']=='INTERSECTION_UNRESOLVED' and facet['unresolved_labels']==['redemption'] and 'liquidation' in facet['retained']
challengepath=ROOT/'review/semantic-kernel/sprint3/open-semantic-challenges.json';challenge=read(challengepath)['items'][0]
assert challenge['id']=='SPRINT3-LIQUITY-V1-LIQUIDATION' and challenge['unit_id']==unit
planpath=ROOT/'openspec/changes/corpus-provenance-adjudication/design.md';plan=planpath.read_text();rule=next(line for line in plan.splitlines() if line.startswith('| `R-liquidation`'))
report={'schema_version':1,'kind':'proposed-source-adjudication-not-accepted-overlay','created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'challenge_id':challenge['id'],'unit_id':unit,'facet':'mechanisms','label':'liquidation','author_identity':'GPT-6 stock Codex harness; no provider telemetry inferred','process_status':'draft_review_pending','proposed_disposition':'supported','original_stored_status_unchanged':challenge['status'],'exact_original_challenge':{'path':str(challengepath.relative_to(ROOT)),'sha256':sha(challengepath.read_bytes()),'pointer':'/items/0','record':challenge},'observations':{'raw_annotations':annotations,'agreed_label_membership':True,'historical_facet_record':{'path':str(corpuspath.relative_to(ROOT)),'sha256':sha(corpuspath.read_bytes()),'pointer':f'/adjudications/{index}','record':facet},'precision_note':'AGREE in the separate challenge inventory denotes shared liquidation label membership. The actual whole mechanisms facet is INTERSECTION_UNRESOLVED because redemption differs. No AGREE mechanisms-facet record is invented.'},'rule':{'id':'R-liquidation','version':'proposed evidence-adjudication/1','path':str(planpath.relative_to(ROOT)),'sha256':sha(planpath.read_bytes()),'line':plan.splitlines().index(rule)+1,'exact_rule_row':rule,'acceptance_status':'proposed plan; this research does not approve or implement the rule'},'scoped_proposition':'The captured V1 documentation and inspected ETH/LUSD source at commit 3e64ee1b52c50d51587c64c1cf75e0ba82934979 describe a collateral-ratio-triggered Trove closure mechanism with specified debt and collateral consequences.','evidence':{'version_specific_documentation':['faq:v1-title','faq:liquidation-eligibility','faq:redistribution'],'rule_trigger_and_closure':['trove-manager:liquidate','trove-manager:_getTotalsFromBatchLiquidate_NormalMode','trove-manager:_liquidateRecoveryMode','trove-manager:_closeTrove'],'debt_collateral_paths':['trove-manager:_getOffsetAndRedistributionVals','trove-manager:_getCappedOffsetVals','trove-manager:_redistributeDebtAndColl','stability-pool:offset','stability-pool:_moveOffsetCollAndDebt'],'repayment_distinction':['borrower-operations:repayLUSD','borrower-operations:_adjustTrove','borrower-operations:closeTrove','borrower-operations:_repayLUSD'],'pin_specific_offset_budget':['stability-pool:getMaxAmountToOffset']},'path_classification':{'ordinary_repayment':'Owner-requested debt reduction uses borrower LUSD; owner closure is a separate guarded path.','offset':'Cancels liquidated debt against Stability Pool LUSD, burns pool tokens and routes collateral into that pool.','redistribution':'Transfers debt and collateral into DefaultPool accounting for surviving Troves; redistributed debt remains an obligation rather than disappearing.','recovery':'Branches include pure redistribution, offset plus possible redistribution, and capped full offset with borrower surplus.','redemption':'Separate TroveManager entry point; inspected only to distinguish operation families. The existing redemption disagreement is not adjudicated by this task.'},'residue':[{'kind':'scope','claim':'Pin versus deployment','status':'unresolved','reason':'Commit-addressed source is retained; no chain address, block, bytecode/build comparison or historical-state binding was acquired.'},{'kind':'scope','claim':'Documentation simplification versus exact pin','status':'recorded','reason':'The pinned StabilityPool reserves MIN_LUSD_IN_SP and bounds offset liquidity; do not substitute total deposits for its returned budget or treat the FAQ full-collateral prose as an exact universal transfer formula.'},{'kind':'provenance','claim':'Original missing citation and attachments','status':'unresolved_original','reason':'Fresh captures are reconstructed support only; none is claimed to recover a missing original response, citation mapping or attachment.'}], 'fidelity_status':'source_inspected','deployment_status':'unresolved','exposure':'development; existing design-used candidate','not_claimed':['Liquity V2 or BOLD behavior','Solidity execution or build success','Lean refinement or financial invariant','Historical deployed fidelity','Adjudication acceptance or corpus mutation','Resolution of redemption or other corpus disputes','Untouched evaluation or synthetic recovery'], 'required_next_step':'Independent review of this exact captured package and proposed scope/rule application before a separately versioned accepted overlay can close the stored challenge.'}
write('proposed-adjudication.json',report)
print('20 source locators; raw observation pointers and draft decision written')
