from pathlib import Path
import json,gzip,hashlib,datetime,shutil,re
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');V=B/'p28-payout-abi-root-verification';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');base_input=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/input.json.gz').read_bytes()));base_output=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/stdout.json.gz').read_bytes()));packets=[]
for name in ['p28-payout-abi-diagnostic','p28-payout-abi-diagnostic-attempt2']:
 o=B/name;seal=read(o/'root-seal.json')
 for p,d in seal['files'].items():assert h(o/p)==d,p
 inp=read(o/'input.json');out=read(o/'compile.stdout');assert len(inp['sources'])==72
 for source,record in base_input['sources'].items():assert inp['sources'][source]==record,source
 assert inp['sources']['PayoutAbiProbe.sol']['content']==(o/'PayoutAbiProbe.sol').read_text()
 assert not [e for e in out.get('errors',[]) if e['severity']=='error']
 count=0
 for source,contracts in base_output['contracts'].items():
  for contract,rec in contracts.items():
   for kind in ['bytecode','deployedBytecode']:assert out['contracts'][source][contract]['evm'][kind]['object']==rec['evm'][kind]['object']
   count+=1
 assert count==71
 cmds=read(o/'commands.json');assert len(cmds)==8
 for row in cmds:
  assert row['exit']==0 and row['finished_utc']>=row['started_utc'];assert h(Path(row['argv'][0]))==row['tool_sha256']
  for k in ['stdout','stderr']:assert h(o/(row['id']+'.'+k))==row[k+'_sha256']
  if row['id']=='compile':assert h(o/'input.json')==row['stdin_sha256']
 expected=[[0,7,93,96,1,1,1,100],[0,7,0,64,1,1,1,100],[42,0,0,0,1,1,1,100],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0]]
 actual=[]
 for i in range(5):
  raw=(o/f'scenario-{i}.stdout').read_text().strip();assert re.fullmatch(r'0x[0-9a-fA-F]{512}',raw)
  actual.append([int(raw[2+64*j:2+64*(j+1)],16) for j in range(8)])
 assert actual==expected
 assert read(o/'result.json')['scenario_results']==[{'scenario':i,'observed':v,'expected':expected[i]} for i,v in enumerate(actual)]
 packets.append({'packet':name,'bindings':len(seal['files']),'commands':8,'scenarios':5,'unchanged_upstream_sources':71,'unchanged_prior_contract_objects':71,'seal_sha256':h(o/'root-seal.json')})
a=(B/'p28-payout-abi-diagnostic/PayoutAbiProbe.sol').read_text();b=(B/'p28-payout-abi-diagnostic-attempt2/PayoutAbiProbe.sol').read_text();assert 'observed[3] = 64;' in a and 'observed[3] = 64;' not in b and b.count('observed[3] = raw.length;')==2
# One altered result must fail the same equality comparison used for intact arrays.
intact=actual==expected;bad=[row[:] for row in actual];bad[1][0]=7;rejected=bad!=expected;assert intact and rejected
result={'utc':now(),'packets':packets,'current_diagnostic':'p28-payout-abi-diagnostic-attempt2','attempt1_limit':'Scenario1 assigned a constant64 marker, so it did not measure Product returndata length. Attempt2 obtains raw bytes from a low-level Product wrapper call and measures actual64bytes. Original attempt remains immutable.','reported_tool_versions':{'solc':(B/'p28-payout-abi-diagnostic-attempt2/solc-version.stdout').read_text().strip(),'evm':(B/'p28-payout-abi-diagnostic-attempt2/evm-version.stdout').read_text().strip()},'source_and_runtime_findings':['Actual pinned ProductService delegates to actual pinned PolicyDefaultFlow, which returns default false plus mock treasury fee7/net93; raw returned bytes96.','Actual unchanged inherited Product._processPayout reads first two words as uint256s and returns(0,7), raw Product returndata64bytes; no implicit ABI rejection of trailing word.','Ignoring the Product return values reaches marker42, while each mock treasury/policy/pool call executes once and mock pool records100.','Exact source authorization and responsible-product error bytes are checked in two negative cases with all mock effect counterszero.'],'comparison_control':{'intact_results_accepted':intact,'altered_product_return_rejected':rejected,'source_files_mutated':False},'assumptions':['Mock registry routing/license authorization/component id and policy metadata.','Mock treasury return7/93 and counters; no token movement, fees charged, real payout or real policy/pool bookkeeping.','Harness runtime injected by evm run; actual upstream service and flow constructors invoked from diagnostic.','Compiler defaultIstanbul, executionParis block0timestamp1; no chain deployment/state or full DepegProduct.processPolicy path.'],'full_P28_entry_contract_open':True,'P28_accepted':False,'independent_review_pending':True};put(V/'result.json',result);put(V/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in V.iterdir() if p.is_file()},'acceptance':False});print(json.dumps({'packets':len(packets),'commands_verified':16,'bounded_scenarios_per_attempt':5,'source_bindings_per_attempt':71,'altered_result_rejected':rejected,'P28_accepted':False}))
