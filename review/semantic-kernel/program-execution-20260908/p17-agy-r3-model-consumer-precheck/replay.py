from pathlib import Path
import sys,json,copy
HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
ENGINE=HERE.parent/'p17-agy-r3-final-protocol-precheck/engine'
sys.path.insert(0,str(ENGINE))
import common,vault_exec,token0_campaign
common.ROOT=Path('/home/charl/defiformal')
common.RECORDER=common.ROOT/'scripts/token0_p16/record_cmd.py'
vault_exec.FIXTURES=HERE.parent/'p17-agy-r3-final-protocol-precheck/fixtures.json'
addresses=json.loads((HERE/'addresses.json').read_text());summary=json.loads((HERE/'vault-model.json').read_text());intact=summary['parsed'];results=[]
for name,modify,expected in [('intact',lambda x:x,0),('missing-all-cells',lambda x:(x['P17-DEP-D0'].pop('cells'),x)[1],3),('missing-one-cell',lambda x:(x['P17-DEP-D0']['cells'].pop('susds.totalSupply'),x)[1],3),('missing-model-row',lambda x:{},3)]:
 rows=modify(copy.deepcopy(intact));out=HERE/'execution'/name;out.mkdir(parents=True)
 got=vault_exec.run_fixtures(out,addresses,HERE/'genesis.json',fixture_ids=['P17-DEP-D0'],lean_rows=rows)
 results.append({'id':name,'kind':'actual EVM public consumer with supplied recorded/modified model rows','expected_consumer_exit':expected,'actual_score':got,'matched':got.get('exit')==expected})
for module,filename,prefix in [(vault_exec,'vault','vault'),(token0_campaign,'token0','token0')]:
 for name,changes,expect_block in [('intact-receipt',{},False),('nonzero-receipt',{'exit':1,'classification':'nonzero'},True),('blocked-receipt-zero-exit',{'exit':0,'classification':'timeout_blocked','valid':False,'timeout':True},True)]:
  receipt=copy.deepcopy(json.loads((HERE/(filename+'-model.json')).read_text())['receipt']);receipt.update(changes);receipt['_wrapper']['stdout_path']=str(HERE/(filename+'.stdout'))
  # Only the model recorder is substituted; no fresh Lean or Solidity mutant credit.
  module.record_cmd=lambda *args,_rec=receipt,**kwargs:copy.deepcopy(_rec)
  func=module.run_lean_vault_bindings if prefix=='vault' else module.run_lean_token0_bindings
  error=None;parsed={}
  try:parsed=func(HERE/'parser-execution'/(prefix+'-'+name))
  except Exception as exc:error=str(exc)
  blocked=error is not None or not parsed
  results.append({'id':prefix+'-'+name,'kind':'unmodified frozen model parser with disclosed recorder substitution','expected_blocked':expect_block,'actual_blocked':blocked,'rows_returned':len(parsed),'exception':error,'matched':blocked==expect_block})
report={'scope':'Frozen final R3 consumer diagnostic, not full acceptance, not fresh Lean or compiled production mutants','checks':len(results),'matched':sum(x['matched'] for x in results),'results':results};(HERE/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'checks':report['checks'],'matched':report['matched'],'failed_ids':[x['id'] for x in results if not x['matched']]}));raise SystemExit(0 if report['matched']==report['checks'] else 1)
