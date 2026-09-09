from pathlib import Path
import json,hashlib,re
X=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');R=X/'p16-source-r6-review';W=R/'candidate';a=W/'review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6';f=R/'execution/intact';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();j=lambda p:json.loads(p.read_text());fixtures=j(R/'inputs/openspec/changes/uniswap-token0-p16/fixtures.json')['fixtures'];ids=[x['id'] for x in fixtures];summary={'fixture_ids':ids,'compiles':[],'bindings':[]}
base=a/'compiler/baseline';names=['Token0Probe.sol','FullMath.sol','UnsafeMath.sol','LowGasSafeMath.sol','SafeCast.sol','FixedPoint96.sol','SqrtPriceMath.sol']
for ca,cf in [(base,f/'compiler/baseline')]+[(a/'compiler/mutants'/mid/'compile',f/'compiler/mutants'/mid/'compile') for mid in ['T0-ID-SKIP','T0-WRAP-SKIP','T0-PROD-SKIP','T0-REQ-SKIP','T0-FLOOR','T0-CHECKED-ADD']]:
 aa=j(ca/'compile.json');ff=j(cf/'compile.json')
 for key in ['solc_sha256','settings','source_hashes','creation_bytecode_sha256','runtime_bytecode_sha256','probe_selector']:assert aa[key]==ff[key],(ca,key)
 for key,file in [('runtime_bytecode_sha256','runtime.hex'),('creation_bytecode_sha256','creation.hex')]:assert hashlib.sha256(bytes.fromhex((cf/file).read_text().strip())).hexdigest()==ff[key]
 overlay=ca/'overlay' if ca==base else ca.parent/'overlay';changed=[name for name in names if h(overlay/name)!=h(base/'overlay'/name)]
 if ca!=base:
  assert changed==['SqrtPriceMath.sol'];edit=j(ca.parent/'edit.json');original=(base/'overlay/SqrtPriceMath.sol').read_text();assert original.count(edit['find'])==1;assert original.replace(edit['find'],edit['replace'],1)==(overlay/'SqrtPriceMath.sol').read_text()
 summary['compiles'].append({'path':str(ca.relative_to(a)),'runtime_sha256':ff['runtime_bytecode_sha256'],'creation_sha256':ff['creation_bytecode_sha256'],'changed_sources':changed})
rows=j(f/'evm/baseline/rows.json');assert [r['id'] for r in rows]==ids
for fix,row in zip(fixtures,rows):
 vals=[int(fix['inputs'][k]) for k in ['sqrtPX96','liquidity','amount']]+[int(fix['inputs']['add'])];expected='6c84a8a2'+''.join(v.to_bytes(32,'big').hex() for v in vals);assert row['calldata_hex']==expected;assert row['comparison']['match'];assert row['process_exit']==row['wrapper_exit']==0
text=(f/'lean/bindings/stdout.bin').read_text();parsed={m[0]:m[1:] for m in re.findall(r'^(P16-\S+) sqrtP=(\d+) L=(\d+) amount=(\d+) add=(true|false) model=(\S+) match=(true|false)$',text,re.M)};assert set(parsed)==set(ids)
for fix in fixtures:
 p,l,amount,add,model,truth=parsed[fix['id']];assert [p,l,amount,add]==[str(fix['inputs'][k]) for k in ['sqrtPX96','liquidity','amount']]+[str(fix['inputs']['add']).lower()];exp=fix['expected'];label=exp.get('model_label',{'require':'subUnderflow'}.get(exp.get('error'),exp.get('error')));want='ok:'+str(exp['ok']) if 'ok' in exp else 'error:'+label;assert model==want and truth=='true';summary['bindings'].append({'id':fix['id'],'model':model,'matched_stored_inputs_expected':True})
summary['model_label_mapping_note']='require maps to the accepted Lean subUnderflow constructor for REQ/REQ-STRICT; source payload is independently retained and is not that label.'
summary['frozen_score_reconciliation']={'frozen_final_score':j(a/'campaign-score.json'),'frozen_bindings_summary':j(a/'lean/bindings-summary.json'),'fresh_actual_campaign_exit':j(R/'execution/commands.json')[0]['exit']}
manifest=j(a/'manifest.json');bad=[v['path'] for v in manifest['files'] if h(W/v['path'])!=v['sha256']];assert not bad;summary['author_manifest_verified']=len(manifest['files']);summary['tools_and_genesis']=j(f/'logs/tool-rehash.json')
(R/'logs/independent-positive-bindings.json').write_text(json.dumps(summary,indent=2)+'\n');print('Verified',len(summary['compiles']),'compiles',len(summary['bindings']),'direct bindings',summary['author_manifest_verified'],'author manifest rows')
