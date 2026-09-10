from pathlib import Path
import json,gzip,hashlib,datetime,subprocess,re,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p28-depeg-lifecycle-diagnostic'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
solc=Path(read(B/'p28-depeg-compiler-preparation/compiler.json')['binary_path']);evm=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools/evm')
assert h(solc)=='b6b9429d71d4395901795936a0aaee0b23082fcaee10d563d87b42e69c0e68c2';assert h(evm)=='d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c'
assert not (O/'commands.json').exists()
commands=[]
def run(name,argv,stdin=None):
 start=now();p=subprocess.run(argv,cwd=O,input=stdin,capture_output=True,timeout=180)
 (O/(name+'.stdout')).write_bytes(p.stdout);(O/(name+'.stderr')).write_bytes(p.stderr)
 commands.append({'id':name,'argv':argv,'cwd':str(O),'started_utc':start,'finished_utc':now(),'exit':p.returncode,'actor':'root','tool_sha256':h(Path(argv[0])),'stdin_sha256':hashlib.sha256(stdin).hexdigest() if stdin is not None else None,'stdout_sha256':h(O/(name+'.stdout')),'stderr_sha256':h(O/(name+'.stderr'))});put(O/'commands.json',commands);return p
shutil.copy2(__file__,O/'run.py')
run('solc-version',[str(solc),'--version']);run('evm-version',[str(evm),'--version'])
d=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/input.json.gz').read_bytes()));source_hashes={n:hashlib.sha256(v['content'].encode()).hexdigest() for n,v in d['sources'].items()};d['sources']['LifecycleProbe.sol']={'content':(O/'LifecycleProbe.sol').read_text()};d['settings']['outputSelection']['*']['*'].append('evm.methodIdentifiers');put(O/'input.json',d)
p=run('compile',[str(solc),'--standard-json'],(O/'input.json').read_bytes());assert p.returncode==0;out=json.loads(p.stdout);put(O/'diagnostics.json',out.get('errors',[]));errors=[e for e in out.get('errors',[]) if e['severity']=='error'];assert not errors,errors
old=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/stdout.json.gz').read_bytes()));unchanged=[]
for source,contracts in old['contracts'].items():
 for name,c in contracts.items():
  for kind in ['bytecode','deployedBytecode']:assert out['contracts'][source][name]['evm'][kind]['object']==c['evm'][kind]['object'],(source,name,kind)
  unchanged.append({'source':source,'contract':name})
probe=out['contracts']['LifecycleProbe.sol']['LifecycleProbe']['evm'];(O/'runtime.hex').write_text(probe['deployedBytecode']['object']);selector=probe['methodIdentifiers']['probe(uint256)'];gen=B/'p24-public-call-diagnostic/paris-genesis.json';assert h(gen)==read(B/'p24-public-call-diagnostic/manifest.json')['files']['paris-genesis.json'];shutil.copy2(gen,O/'paris-genesis.json')
# Independent concrete expected observations, not values extracted from actual execution.
expected=[
 [0,0,100,1,1,20,1,1,20,2,1,150],
 [1,1,0,0,0,0,0,0,0,1,1,0],
 [1,1,0,0,0,0,0,0,0,1,1,0],
 [1,0,0,0,0,0,0,0,0,0,0,0],
 [1,0,0,0,0,0,0,0,0,0,0,0],
 [1,1,150,2,2,30,2,2,30,2,1,150],
 [17,1,100,1,1,20,1,1,20,2,1,50],
 [1,1,0,0,0,0,0,0,0,1,1,150],
 [1,2,0,0,0,0,0,0,0,1,1,100],
 [1,0,0,0,0,0,0,0,0,0,0,0],
 [102,0,0,0,0,0,0,0,0,0,0,150]]
put(O/'expected.json',expected);values=[]
for i in range(len(expected)):
 p=run('scenario-'+str(i),[str(evm),'run','--prestate',str(O/'paris-genesis.json'),'--codefile',str(O/'runtime.hex'),'--input',selector+format(i,'064x'),'--sender','0x0000000000000000000000000000000000000100','--receiver','0x0000000000000000000000000000000000000200']);raw=p.stdout.decode().strip();assert p.returncode==0 and re.fullmatch('0x[0-9a-fA-F]{768}',raw),(i,p.returncode,raw,p.stderr.decode());v=[int(raw[2+64*j:2+64*(j+1)],16) for j in range(12)];assert v==expected[i],(i,v,expected[i]);values.append({'scenario':i,'observed':v,'expected':expected[i]});print(i,v,flush=True)
result={'utc':now(),'actor':'root','scope':'Bounded public DepegProduct claim creation/processing with actual ProductService and PolicyDefaultFlow. Explicit fixture registry, component/license, policy/instance service, price provider, treasury, pool. No real token or policy-controller accounting.','upstream_compiler_source_text_bindings':source_hashes,'unchanged_contracts':unchanged,'source_count':len(d['sources']),'compiler_sha256':h(solc),'evm_sha256':h(evm),'input_sha256':h(O/'input.json'),'runtime_sha256':h(O/'runtime.hex'),'genesis_sha256':h(O/'paris-genesis.json'),'scenario_results':values,'observation_columns':['result_marker','queued_claims','processed_token_amount','mock_confirmations','mock_payouts_created','mock_paid_amount','mock_treasury_calls','mock_pool_calls','mock_pool_amount','first_mock_policy_state','first_mock_claim_count','owner_attested_balance'],'actual_source_contracts_constructed':['DepegProduct','ProductService','PolicyDefaultFlow'],'harness_runtime_injected':True,'harness_runtime_bytes':len(probe['deployedBytecode']['object'])//2,'compiler_errors':0,'compiler_warnings':len([e for e in out.get('errors',[]) if e['severity']=='warning']),'P28_accepted':False,'independent_review_pending':True,'not_covered':['real token transfers','actual PolicyController/TreasuryModule/PoolController state','real oracle or historical balances','deployed identity','premium/underwriting/application creation','universal financial or rollback proof']};put(O/'result.json',result)
files={p.name:h(p) for p in O.iterdir() if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'scenarios':len(values),'unchanged_contracts':len(unchanged),'harness_runtime_bytes':result['harness_runtime_bytes'],'P28_accepted':False}))
