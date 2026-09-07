import json,hashlib,re,subprocess
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');rel='review/semantic-kernel/corpus-provenance-adjudication/source-research/justlend-v1-collateralization';out=R/rel
h=lambda b:hashlib.sha256(b).hexdigest();now=lambda:datetime.now(timezone.utc).isoformat()
def js(p):return json.loads((R/p).read_text())
def bind(p,pointer=None):
 b=(R/p).read_bytes();r={'path':p,'sha256':h(b),'bytes':len(b)}
 if pointer is not None:r['pointer']=pointer
 return r
def write(name,value):
 with (out/name).open('x') as f:json.dump(value,f,indent=2,ensure_ascii=False);f.write('\n')
triagepath='review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json';triage=js(triagepath)
selected=next(x for x in triage['disagreements'] if x['research_status']=='not_yet_source_researched_in_declared_catalog' and x['unit_id']!='unit:lane1:c2:p4:v1')
assert selected['id']=='dispute-01';write('selection-and-observations.json',{'selection_rule':'First still-unresearched unit in immutable deterministic triage order, excluding Liquity V1','triage':bind(triagepath,'/disagreements/0'),'raw_triage_record':selected,'raw_a':js(selected['raw_a']['record']['path'])['annotations'][8],'raw_b':js(selected['raw_b']['record']['path'])['annotations'][8],'generated':js(selected['generated']['pointer']['path'])['adjudications'][42],'neutral_identity':js(selected['neutral_context']['path'])['units'][8]['identity']})
retrievals=js(rel+'/retrievals.json');sources={r['source_id']:r for r in retrievals['records']};bodies={k:(R/v['attempts'][-1]['capture_path']).read_bytes() for k,v in sources.items()}
loc=[]
def span(sid,name,a,b,method):
 body=bodies[sid];loc.append({'id':sid+':'+name,'source_id':sid,'capture':bind(sources[sid]['attempts'][-1]['capture_path']),'byte_start':a,'byte_end_exclusive':b,'line_start':body[:a].count(b'\n')+1,'line_end':body[:b].count(b'\n')+1,'span_sha256':h(body[a:b]),'method':method})
def function(sid,name):
 body=bodies[sid];matches=list(re.finditer(rb'function '+name.encode()+rb'\(',body));assert len(matches)==1
 a=matches[0].start();i=body.index(b'{',a)+1;depth=1
 while depth:
  if body[i]==123:depth+=1
  elif body[i]==125:depth-=1
  i+=1
 span(sid,name,a,i,'Exact unique function signature with balanced braces; manually inspected span; no Solidity parser or execution')
for name in ['borrowAllowed','getHypotheticalAccountLiquidityInternal','redeemAllowed','redeemAllowedInternal','transferAllowed','exitMarket','addToMarketInternal']:function('comptroller',name)
for name in ['borrowFresh','transferTokens','redeemFresh','getAccountSnapshot']:function('ctoken',name)
body=bodies['version-scope'];i=body.index(b'V1 remains');a=body.rfind(b'<p>',0,i);b=body.index(b'</p>',i)+4;span('version-scope','v1-v2-distinction',a,b,'Literal HTML paragraph boundaries')
i=body.index(b'V1 vs V2 at a glance');a=body.index(b'<table>',i);b=body.index(b'</table>',a)+8;span('version-scope','comparison-table',a,b,'Literal HTML table including V1/V2 column headers')
needle=b'https://github.com/justlend/justlend-protocol';a=body.index(needle);span('version-scope','official-repository-link',a,a+len(needle),'Exact URL in official documentation structured metadata; provenance corroboration only')
write('evidence-locators.json',{'schema_version':1,'locators':loc})
designpath='openspec/changes/corpus-provenance-adjudication/design.md';design=(R/designpath).read_text();lineno,line=next((i,s) for i,s in enumerate(design.splitlines(),1) if s.startswith('| `R-collateralization` /'))
rule={'id':'R-collateralization','version':'proposed evidence-adjudication/1','source':{**bind(designpath),'line':lineno},'literal_table_row':line,'required_predicate':'Identified assets are encumbered or checked to secure a scoped obligation','insufficient_alone':'A product merely holds assets','status':'proposed reusable rule; not accepted by this packet'}
qualifications=['Official current documentation supplies the V1-versus-V2 architecture distinction. The captured repository is linked by that documentation, but no deployment address, proxy implementation at a block, or historical source-code binding is established.','The source is pinned at f28f3b462a4f281761e23423554563e15fc9f028, selected from actual Git ref metadata. This is not a claim that that revision is the sole or current live V1 implementation.','Only selected market membership contributes to the collateral calculation. Nonmember redemption can bypass that liquidity check, so holding jTokens alone is not always encumbered collateral.','Borrow permission also depends on listing, pause state, prices and successful snapshot/math checks. Token borrowing separately checks freshness and cash; satisfying collateral alone is not sufficient for success.','The snapshot uses stored debt/exchange-rate calculations, risk parameters and oracle prices. No oracle correctness, parameter adequacy, contract execution, formal safety proof or all-call-path completeness was established.','Current docs and source belong to the same JustLend publication family. They are not independent-provider corroboration. Documentation publication metadata is not proof of historical deployment state.','No inference is made from generic Compound source, V2 isolated markets, energy rental, the old symbol list or A/B agreement. Original missing citations remain unresolved.']
claims=[{'id':'C1','type':'source_statement','claim':'Official documentation explicitly distinguishes V1 pooled jToken markets and their Comptroller cross-collateral model from V2 isolated markets.','evidence':['version-scope:v1-v2-distinction','version-scope:comparison-table']},{'id':'C2','type':'source_inspection','claim':'The pinned liquidity routine obtains balances, debt and exchange rate for account-entered markets, applies collateral factors and oracle prices, adds hypothetical borrow/redemption effects and reports shortfall.','evidence':['comptroller:getHypotheticalAccountLiquidityInternal','ctoken:getAccountSnapshot','comptroller:addToMarketInternal']},{'id':'C3','type':'source_inspection','claim':'The pinned token borrow path calls borrowAllowed before transfer/debt updates; borrowAllowed rejects positive hypothetical shortfall.','evidence':['ctoken:borrowFresh','comptroller:borrowAllowed']},{'id':'C4','type':'source_inspection','claim':'The pinned redemption and token-transfer paths invoke liquidity permission checks, while market exit rejects outstanding market debt and disallowed full redemption.','evidence':['comptroller:redeemAllowed','comptroller:redeemAllowedInternal','comptroller:transferAllowed','comptroller:exitMarket','ctoken:redeemFresh','ctoken:transferTokens']},{'id':'C5','type':'inference_under_proposed_rule','claim':'These asset/debt checks secure a borrowing obligation, satisfying the proposed collateralization predicate for this scoped V1 pooled lending architecture; mere custody is not the supporting premise.','evidence':['comptroller:getHypotheticalAccountLiquidityInternal','comptroller:borrowAllowed','ctoken:borrowFresh','version-scope:comparison-table']}]
proposal={'schema_version':1,'kind':'single-disagreement-source-research','created_utc':now(),'author_identity':'GPT-6 through stock Codex harness; no invented native provider telemetry','unit_id':selected['unit_id'],'dispute_id':selected['id'],'facet':'mechanisms','label':'collateralization','process_status':'draft_review_pending','proposed_disposition':'supported','accepted_disposition':None,'scoped_proposition':'JustLend V1 pooled jToken lending includes collateralization as evidenced by official architecture documentation and the identified pinned source routines; this proposition does not bind deployed or historical code.','observations':bind(rel+'/selection-and-observations.json'),'actual_inventory_record':js(selected['inventory']['path'])['disagreements'][0],'rule':rule,'claims':claims,'material_qualifications':qualifications,'source_provenance':{'retrievals':bind(rel+'/retrievals.json'),'revision_metadata':bind(rel+'/revision-discovery.json'),'locators':bind(rel+'/evidence-locators.json'),'primary_sources':3,'independence_groups':1,'source_status':'fresh actual bytes retained; reconstructed support, not recovered original citations'},'contrary_reading_considered':'Raw B omits collateralization; this is missing support, not an explicit assertion of uncollateralized lending. Generic fork lineage and asset custody would not establish the predicate; the actual checks provide a narrower source-grounded reason. Nonmember redemption remains an explicit qualification.','hypothetical_overlay_if_later_accepted':{'old_retained_mechanisms':['liquidation'],'newly_supported_label':'collateralization','possible_effective_mechanisms':['collateralization','liquidation'],'liquidation_status':'Preserved historical retained label, not re-reviewed or promoted by this packet','applied':False},'limits':['No corpus annotation, normalization, schema, tooling or previous evidence package changed.','No accepted label, deployment identity, contract execution, Lean refinement, fidelity or holdout claim.','Three primary bodies exhausted this acquisition budget; imported contract dependencies were not fetched or compiled.'],'required_next_step':'Independent source/rule review may accept, revise or leave unresolved the proposed scoped label. A deployment or historical claim requires a separate bounded source/address/revision/time binding.'}
write('proposed-adjudication.json',proposal)
revision='f28f3b462a4f281761e23423554563e15fc9f028'
report=f'''# JustLend V1 collateralization — proposed disposition

**Draft: supported for the scoped source-level architecture; independent review pending.** No corpus labels were changed.

The deterministic triage selects `dispute-01`, `unit:lane1:c1:p3`, mechanisms/collateralization. Raw A lists collateralization and liquidation; B lists liquidation. The generated record retains liquidation and leaves collateralization unresolved. Exact original observations and JSON pointers are in [selection-and-observations.json](selection-and-observations.json).

The proposed `R-collateralization` requires identified assets to secure an obligation through encumbrance or checks. Asset custody and Compound lineage alone are insufficient. The captured source provides the missing operational link:

- The official documentation distinguishes V1 pooled jToken markets from V2 isolated markets and places V1 risk checks in the Comptroller. Its repository link supplies provenance context. [Official architecture documentation](https://docs.justlend.org/developers/justlend_v2/)
- `getHypotheticalAccountLiquidityInternal` weights entered-market balances by collateral factors, exchange rates and oracle prices, compares them with debt plus hypothetical effects, and returns a shortfall. `borrowAllowed` refuses a positive shortfall. Redemption, transfer and market exit also constrain removal of assets used by these checks. [Pinned Comptroller](https://github.com/justlend/justlend-protocol/blob/{revision}/contracts/Comptroller.sol#L322)
- `borrowFresh` invokes that permission check before transferring funds and updating debt. The token’s redemption and transfer routines similarly invoke controller permissions. [Pinned CToken](https://github.com/justlend/justlend-protocol/blob/{revision}/contracts/CToken.sol#L751)

The inference under the proposed rule is collateralization of the borrowing obligation, with the actual checks as evidence. This is a new proposed source-grounded reason, not a vote for annotator A.

Scope matters: membership selects the collateral set; nonmember redemption may bypass the liquidity test. Listing, pauses, prices, arithmetic, freshness and available cash also constrain operations. Collateral sufficiency alone does not guarantee successful borrowing. The full qualifications and claim-to-locator map are in [proposed-adjudication.json](proposed-adjudication.json).

Exactly three primary bodies were retrieved and retained: one current official documentation page and two source files pinned at `{revision}`. They total {sum(len(x) for x in bodies.values())} bytes. All belong to the same publisher family. [retrievals.json](retrievals.json) preserves exact requested/final URLs, UTC timestamps, headers, hashes and attempts; [evidence-locators.json](evidence-locators.json) binds 14 exact byte/line spans. Git ref discovery is separately recorded metadata, not an extra contract body. Two search rounds located the official sources; search snippets are discovery only and are not accepted evidence.

The documentation supports V1 architecture scope, but neither it nor this source selection establishes a deployed implementation, proxy state, address binding or behavior on the corpus’s historical date. No dependency compilation, Solidity execution, security proof, deployment fidelity, synthetic recovery or holdout evaluation occurred. Original missing citations remain missing. Energy rental and all other unit/facet labels are outside this packet.

Next: independently review the proposed rule application. Keep the old raw/generated observations and triage immutable even if a future overlay accepts this new evidence.
'''
with (out/'REPORT.md').open('x') as f:f.write(report)
# Validate offline records, source spans and all underlying protections.
checks=[]
def check(name,v):checks.append({'name':name,'pass':bool(v)});assert v,name
check('exact-selected-unit',selected['id']=='dispute-01' and selected['unit_id']=='unit:lane1:c1:p3')
check('three-bodies',len(sources)==3 and all(r['status']=='retained' for r in sources.values()))
check('one-request-each',all(len(r['attempts'])==1 for r in sources.values()))
for sid,r in sources.items():
 a=r['attempts'][-1];check('body-'+sid,h(bodies[sid])==a['body_sha256'] and len(bodies[sid])==a['body_bytes'])
for l in loc:
 body=(R/l['capture']['path']).read_bytes();check('span-'+l['id'],h(body[l['byte_start']:l['byte_end_exclusive']])==l['span_sha256'])
ids={l['id'] for l in loc};check('unique-locators',len(ids)==len(loc)==14)
for c in claims:check('claim-refs-'+c['id'],set(c['evidence'])<=ids)
check('pending-not-accepted',proposal['process_status']=='draft_review_pending' and proposal['accepted_disposition'] is None and not proposal['hypothetical_overlay_if_later_accepted']['applied'])
before=js(rel+'/input-protection-before.json');drift=[]
for p,digest in before['files'].items():
 actual=h((R/p).read_bytes())
 if actual!=digest:drift.append({'path':p,'before_sha256':digest,'after_sha256':actual})
 check('protected-'+p,actual==digest)
write('verification.json',{'created_utc':now(),'git_head_before':before['git_head'],'git_head_after':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'checks':checks,'check_count':len(checks),'all_passed':all(c['pass'] for c in checks),'protected_files':len(before['files']),'protected_drift':drift,'scope':'Offline source-byte/locator/record checks; not contract execution or independent semantic acceptance','source_bytes':sum(len(x) for x in bodies.values()),'source_bodies':3})
files=[bind(str(p.relative_to(R))) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json'];write('artifact-manifest.json',{'schema_version':1,'created_utc':now(),'scope':'Immutable draft one-unit research packet; no accepted corpus overlay','files':files})
print(json.dumps({'checks':len(checks),'protected_files':len(before['files']),'locators':len(loc),'files':len(files),'manifest':bind(rel+'/artifact-manifest.json'),'report':bind(rel+'/REPORT.md'),'proposal':bind(rel+'/proposed-adjudication.json')},indent=2))
