#!/usr/bin/env python3
"""Create the finite research plan and local provenance before acquisition."""
import datetime,hashlib,json,pathlib,subprocess,sys
B=pathlib.Path(__file__).resolve().parent; R=B.parents[4]
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def out(name,x):
 with (B/name).open('x') as f:json.dump(x,f,indent=2);f.write('\n')
def git(*a):return subprocess.run(['git',*a],cwd=R,capture_output=True,text=True).stdout.strip()
qpath='review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json'
q=json.loads((R/qpath).read_text()); selected=q['remaining'][16:32]; assert len(selected)==16
c=json.loads((R/'corpus/normalized/generated/corpus.json').read_text())
units=[]
for n,item in enumerate(selected,17):
 unit=next(x for x in c['units'] if x['unit_id']==item['unit_id'])
 row=c['source_records'][int(item['source_row']['pointer'].split('/')[-1])]
 units.append({'queue_position_1based':n,'queue_item':item,'canonical_unit':unit,'exact_source_record':row})
out('selected-units.json',{'status':'unaccepted_research_only','queue_path':qpath,'queue_sha256':sha(R/qpath),'slice':[16,32],'units':units})
paths=set()
for folder in ['corpus','corpus50','review/semantic-kernel/corpus-provenance-adjudication/source-research','review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-03','review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure']:
 for p in (R/folder).rglob('*'):
  if p.is_file() and not p.is_symlink() and '__pycache__' not in p.parts:paths.add(str(p.relative_to(R)))
for x in json.loads((R/'review/semantic-kernel/sprint10/planning/r2-candidate.json').read_text())['inputs']:paths.add(x['path'])
paths.update(['AGENTS.md',qpath,'review/semantic-kernel/sprint10/planning/r2-candidate.json','review/semantic-kernel/sprint10/planning/r2-bundle.md'])
head=git('rev-parse','HEAD')
out('protection-before.json',{'utc':utc(),'head':head,'head_equality_required':False,'scope':'Existing canonical corpus, S10 88 inputs and stable source-research/refresh03/exposure bytes; excludes concurrent identity batches.','paths':[{'path':p,'bytes':(R/p).stat().st_size,'sha256':sha(R/p),'git_blob_at_head':git('rev-parse',f'{head}:{p}') or None} for p in sorted(paths)]})
out('tools-before.json',{'utc':utc(),'python':sys.version,'curl':subprocess.check_output(['/usr/bin/curl','--version'],text=True),'capture_script_sha256':sha(B/'capture.py'),'prepare_script_sha256':sha(B/'prepare.py'),'discovery_tool':'web.run search_query; snippets are discovery only, not retained primary-body support'})
urls=[
['https://docs.asterdex.com/','https://docs.asterdex.com/product/aster-pro'],
['https://api.github.com/repos/gmx-io/gmx-synthetics/commits?per_page=1'],
['https://docs.convexfinance.com/convexfinance/general-information/why-convex/understanding-cvxcrv','https://docs.convexfinance.com/convexfinanceintegration'],
['https://docs.cian.app/yieldlayer/for-users-quick-start/yield-layer-value-proposition','https://docs.cian.app/resources/contracts/yield-layer'],
['https://docs.yearn.fi/developers/v3/overview','https://api.github.com/repos/yearn/yearn-vaults-v3/commits?per_page=1'],
['https://docs.beefy.finance/beefy-products/vaults'],
['https://www.steakhouse.financial/docs'],
['https://docs.layerzero.network/v2/concepts/protocol/protocol-overview'],
['https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/bridge2','https://api.github.com/repos/hyperliquid-dex/contracts/commits/master'],
['https://developers.circle.com/cctp','https://developers.circle.com/cctp/v1'],
['https://docs.across.to/guides/concepts'],
['https://docs.liquidmesh.io/docs/getting-started','https://docs.liquidmesh.io/docs/quote-api'],
['https://www.binance.com/en-AE/support/faq/detail/7ebe19e8ff884cc09a9dbb064aff131f'],
['https://www.okx.com/en-gb/help/okx-dex-faqs','https://www.okx.com/en-gb/help/dex-aggregator-and-intent-conflict-of-interest-policies'],
['https://dev.jup.ag/get-started'],
['https://docs.kyberswap.com/kyberswap-solutions/kyberswap-aggregator','https://docs.kyberswap.com/kyberswap-solutions/kyberswap-aggregator/developer-guides']]
targets=[]
for n,(u,us) in enumerate(zip(selected,urls),17):
 for i,url in enumerate(us,1):targets.append({'id':f'u{n:02d}-s{i}','unit_id':u['unit_id'],'label':u['label'],'pass':'01','url':url,'purpose':'Product/version identity and source or deployment lead; provisional documentary support only'})
out('pass01-plan.json',{'created_utc':utc(),'origin_kind':'bounded_identity_research','limits':{'distinct_primary_url_targets_per_original_unit':3,'attempts_per_target':2,'seconds_per_attempt':30,'redirects':5,'bytes_per_body':5242880},'remaining_target_capacity_reserved_for':'Exact commit-pinned source or source-gap follow-up; write continuation plan before fetching.','targets':targets})
print(len(units),'units',len(paths),'protected paths',len(targets),'initial targets')
