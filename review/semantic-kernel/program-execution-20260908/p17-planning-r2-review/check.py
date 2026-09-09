#!/usr/bin/env python3
"""Independent planning-only witness arithmetic and frame/log inspection; not source execution."""
from pathlib import Path
import json,copy,hashlib
O=Path(__file__).resolve().parent;C=O/'candidate';P=C/'openspec/changes/vault-platform-reuse-p17';RAY=10**27;W=2**256
D=json.loads((P/'fixtures.json').read_text())
def witness(f):
 pre=f['pre'];inp=f['inputs'];op=f['operation'];chi=int(pre['chi']);sender=inp['msg.sender'];recv=inp['receiver'];owner=inp.get('owner',sender)
 assert pre['initialized'] and pre['rho']==pre['timestamp'] and chi>0
 x=int(inp.get('assets',inp.get('shares')))
 product=x*(RAY if op in ['deposit','withdraw'] else chi)
 divisor=chi if op in ['deposit','withdraw'] else RAY
 q=(product+divisor-1)//divisor if op in ['mint','withdraw'] else product//divisor
 assets,shares=(x,q) if op in ['deposit','withdraw'] else (q,x)
 err=None
 if product>=W:err='Panic(0x11)'
 elif op in ['deposit','mint']:
  if recv in ['ZERO','vault']:err='SUsds/invalid-address'
  elif int(pre['usds.balance.'+sender])<assets:err='Usds/insufficient-balance'
  elif int(pre['usds.allowance.'+sender+'.vault'])<assets:err='Usds/insufficient-allowance'
 else:
  if int(pre['susds.balance.'+owner])<shares:err='SUsds/insufficient-balance'
  elif owner!=sender and int(pre['susds.allowance.'+owner+'.'+sender])<shares:err='SUsds/insufficient-allowance'
  elif int(pre['usds.balance.vault'])<assets:err='Usds/insufficient-balance'
 if err:return {'status':'revert','error':err,'post':'omitted','full_logs':[]}
 post=copy.deepcopy(pre)
 def change(k,delta):
  n=int(post[k])+delta;assert 0<=n<W,(f['id'],k,n);post[k]=str(n)
 def tx(emitter,fr,to,val):return {'emitter':emitter,'name':'Transfer','from':fr,'to':to,'value':str(val)}
 logs=[{'emitter':'vault','name':'Drip','chi':str(chi),'diff':'0'}]
 if op in ['deposit','mint']:
  change('usds.balance.'+sender,-assets);change('usds.balance.vault',assets)
  if int(post['usds.allowance.'+sender+'.vault'])!=W-1:change('usds.allowance.'+sender+'.vault',-assets)
  change('susds.balance.'+recv,shares);change('susds.totalSupply',shares)
  logs += [tx('usds',sender,'vault',assets),{'emitter':'vault','name':'Deposit','sender':sender,'owner':recv,'assets':str(assets),'shares':str(shares)},tx('vault','ZERO',recv,shares)]
 else:
  change('susds.balance.'+owner,-shares);change('susds.totalSupply',-shares)
  if owner!=sender and int(post['susds.allowance.'+owner+'.'+sender])!=W-1:change('susds.allowance.'+owner+'.'+sender,-shares)
  change('usds.balance.vault',-assets);change('usds.balance.'+recv,assets)
  logs += [tx('usds','vault',recv,assets),tx('vault',owner,'ZERO',shares),{'emitter':'vault','name':'Withdraw','sender':sender,'receiver':recv,'owner':owner,'assets':str(assets),'shares':str(shares)}]
 return {'status':'success','assets':str(assets),'shares':str(shares),'post':post,'full_logs':logs,'vault_projection':[e for e in logs if e['emitter']=='vault']}
def compare(f,out):
 e=f['expected'];fails=[]
 if e['status']!=out['status']:fails.append('status')
 if out['status']=='revert':
  if e.get('error')!=out['error']:fails.append('error')
  if e.get('post')!='omitted':fails.append('refusal_post')
  if e.get('pre_retained') is not True or e.get('rollback_verification') is not False:fails.append('refusal_shape')
 else:
  for k in ['assets','shares']:
   if 'ok_'+k in e and e['ok_'+k]!=out[k]:fails.append('return_'+k)
  for k,v in e['post'].items():
   if out['post'].get(k)!=v:fails.append('post:'+k)
  if e['full_logs']!=out['full_logs']:fails.append('full_logs')
 return fails
rows=[]
for f in D['fixtures']:
 if not f.get('scored_source'):continue
 pre={**D['construction']['defaults'],**D['construction']['domain_overlay'][f['domain']],**f['pre_overrides']}
 assert pre==f['pre']
 out=witness(f);fail=compare(f,out)
 rows.append({'id':f['id'],'ok':not fail,'failures':fail,'independent_expected':out,'post_interpretation':'copy pre, apply the selected source/mock deltas, all other observed cells unchanged; expected.post is a sparse assertion projection'})
assert len(rows)==16
controls=[]
f=copy.deepcopy(next(f for f in D['fixtures'] if f['id']=='P17-DEP-D0'));out=witness(f)
for label,mut in [('wrong_asset_credit',lambda x:x['expected']['post'].__setitem__('usds.balance.vault','0')),('wrong_transfer_emitter',lambda x:x['expected']['full_logs'][1].__setitem__('emitter','vault'))]:
 b=copy.deepcopy(f);mut(b);fails=compare(b,out);controls.append({'id':label,'ok':bool(fails),'failures':fails,'comparison_rejected':True})
# The mathematical positive/negative use the same fixed effects; only the proposed observation differs.
by={f['id']:f for f in D['fixtures']};pos=by['P17-POS-DEPOSIT-CREDIT'];neg=by['P17-NEG-MINT-NO-CREDIT']
assert pos['effects']==neg['effects'] and pos['assets']==neg['assets'] and int(pos['assets'])>0
assert int(pos['effects']['USDS.S'])+int(pos['effects']['USDS.vault'])==int(pos['effects']['USDS.supply'])
assert int(pos['effects']['sUSDS.R'])==int(pos['effects']['sUSDS.supply'])
assert neg['executor_refusal'] is False and neg['not_predicate']=='Evaluated.Valid'
result={'scope':'independent finite planning diagnostics, not Solidity/EVM or Lean execution','source_rows':rows,'source_row_count':len(rows),'failed_rows':sum(not x['ok'] for x in rows),'negative_controls':controls,'positive_negative_same_effects':True,'input_fixtures_sha256':hashlib.sha256((P/'fixtures.json').read_bytes()).hexdigest(),'production_mutation_credit':0}
(O/'source-witness-review.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'rows':len(rows),'failed_rows':result['failed_rows'],'controls':controls},indent=2))
assert result['failed_rows']==0 and all(x['ok'] for x in controls)
