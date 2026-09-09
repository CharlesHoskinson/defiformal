#!/usr/bin/env python3
"""Bounded independent planning checks; no production or Lean execution credit."""
from pathlib import Path
import hashlib,json,re,subprocess,shutil,os
R=Path('/home/charl/defiformal')
O=Path(__file__).resolve().parent
C=O/'candidate'
P=C/'openspec/changes/vault-platform-reuse-p17'
E=O/'execution'
rows=[]
def record(name,ok,details):
 rows.append({'name':name,'ok':bool(ok),'details':details})
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((R/'review/semantic-kernel/program-execution-20260908/p17-planning-candidate-r1-manifest.json').read_text())
record('frozen_42_files_match',len(manifest['files'])==42 and all(sha(C/f['path'])==f['sha256'] for f in manifest['files']),len(manifest['files']))
src=R/'review/semantic-kernel/program-execution-20260908/p17-source-acquisition'
pin=json.loads((P/'source-pin.json').read_text())
record('ten_source_keys_match',len(pin['compiler_source_keys'])==10 and all(sha(src/'compile-source-closure'/f['key'])==f['sha256'] for f in pin['compiler_source_keys']),10)
record('three_mock_pins_match',len(pin['captured_mocks_test_harness_only'])==3 and all(sha(src/f['rel'])==f['sha256'] for f in pin['captured_mocks_test_harness_only']),3)
api=json.loads((P/'proposed-api.json').read_text())['reuses']
record('delivered_api_hashes_match',all(sha(R/v['path'])==v['sha256'] for v in api.values() if 'sha256' in v),len([v for v in api.values() if 'sha256' in v]))
fixture=json.loads((P/'fixtures.json').read_text()); fs={x['id']:x for x in fixture['fixtures']}
ray=10**27; wad=10**18; chi=ray+1
calc={'P17-DEP-D1':('ok_shares',wad*ray//chi),'P17-MINT-D1':('ok_assets',(wad*chi+ray-1)//ray),'P17-RED-D1':('ok_assets',wad*chi//ray),'P17-WD-D1':('ok_shares',(wad*ray+chi-1)//chi)}
record('four_d1_literals_correct',all(int(fs[k]['expected'][field])==v for k,(field,v) in calc.items()),calc)
x=int(fs['P17-DEP-MUL-OVF']['inputs']['assets'])
record('overflow_boundary_correct',x*ray>=2**256 and (x-1)*ray<2**256,x)
record('source_mutant_sites_unique',(src/'capture/src/SUsds.sol').read_text().count('usds.transferFrom(msg.sender, address(this), assets);')==1 and (src/'capture/src/SUsds.sol').read_text().count('shares = assets * RAY / drip();')==1,2)
transition=(R/'lean/DefiKernel/Typed/Transition.lean').read_text()
valid=transition.split('def Evaluated.Valid',1)[1].split('\nvariable (registry',1)[0]
record('valid_has_no_poststate_argument','post' not in valid,valid)
no_credit={'USDS':{'party_effect_sum':0,'supply_delta':0},'sUSDS':{'party_effect_sum':wad,'supply_delta':wad}}
record('share_only_issuance_satisfies_per_asset_accounting',all(v['party_effect_sum']==v['supply_delta'] for v in no_credit.values()),{'diagnostic_only':True,'not_Lean_execution':True,'effects':no_credit})
record('two_success_fixtures_have_no_prestate','pre' not in fs['P17-MINT-D0'] and 'pre' not in fs['P17-WD-D0'],['P17-MINT-D0','P17-WD-D0'])
record('d1_mint_needs_more_assets_than_d0_sender',int(fs['P17-MINT-D1']['expected']['ok_assets'])>int(fs['P17-DEP-D0']['pre']['usds.S']),{'mint_required':fs['P17-MINT-D1']['expected']['ok_assets'],'d0_sender':fs['P17-DEP-D0']['pre']['usds.S']})
obs=json.loads((P/'observation-contract.json').read_text())['vault_stateful']
record('underlying_allowance_not_in_observation','USDS allowance' not in json.dumps(obs) and 'USDS allowances' not in json.dumps(obs),obs)
mock=(src/'capture/test/mocks/UsdsMock.sol').read_text()
record('underlying_transfer_emits_log','emit Transfer(from, to, value);' in mock,{'underlying_log':'USDS.Transfer(sender,vault,assets)','fixture_events':fs['P17-DEP-D0']['events']})
# Actual structural false control, only the review-owned execution copy changes.
fp=E/'openspec/changes/vault-platform-reuse-p17/fixtures.json'; original=fp.read_bytes()
try:
 bad=json.loads(original); next(f for f in bad['fixtures'] if f['id']=='P17-DEP-D1')['expected']['ok_shares']='1000000000000000000'; fp.write_text(json.dumps(bad))
 argv=['python3','review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r1/diagnose.py']; p=subprocess.run(argv,cwd=E,capture_output=True,timeout=30)
 (O/'diagnose-false.stdout').write_bytes(p.stdout); (O/'diagnose-false.stderr').write_bytes(p.stderr)
 result=json.loads(p.stdout)
 record('author_diagnostic_rejects_wrong_d1_literal',p.returncode==1 and 'independent_P17-DEP-D1' in result['failures'],{'argv':argv,'cwd':str(E),'exit':p.returncode,'failures':result['failures'],'production_mutation_credit':result['production_mutation_credit']})
finally: fp.write_bytes(original)
record('candidate_preserved_after_checks',all(sha(C/f['path'])==f['sha256'] for f in manifest['files']),42)
(O/'checks.json').write_text(json.dumps({'scope':'planning and source inspection; positive finding probes are not acceptance','checks':rows,'count':len(rows),'failed':sum(not v['ok'] for v in rows),'production_mutation_credit':0,'lean_executions':0,'solidity_executions':0},indent=2)+'\n')
print(json.dumps({'checks':len(rows),'failed':sum(not v['ok'] for v in rows)},indent=2))
