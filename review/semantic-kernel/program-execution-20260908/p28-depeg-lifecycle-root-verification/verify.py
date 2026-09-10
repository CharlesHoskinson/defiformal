from pathlib import Path
import json,gzip,hashlib,datetime,shutil,re
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p28-depeg-lifecycle-diagnostic';V=B/'p28-depeg-lifecycle-root-verification'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');seal=read(O/'root-seal.json')
for p,d in seal['files'].items():assert h(O/p)==d,p
inp=read(O/'input.json');out=read(O/'compile.stdout');original=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/input.json.gz').read_bytes()));oldout=json.loads(gzip.decompress((B/'p28-depeg-compiler-baseline/stdout.json.gz').read_bytes()))
assert len(original['sources'])==71 and len(inp['sources'])==72
for n,v in original['sources'].items():assert inp['sources'][n]==v,n
assert inp['sources']['LifecycleProbe.sol']['content']==(O/'LifecycleProbe.sol').read_text()
settings=json.loads(json.dumps(inp['settings']));settings['outputSelection']['*']['*'].remove('evm.methodIdentifiers');assert settings==original['settings']
objects=[]
for n,cs in oldout['contracts'].items():
 for name,c in cs.items():
  for k in ['bytecode','deployedBytecode']:assert out['contracts'][n][name]['evm'][k]['object']==c['evm'][k]['object']
  objects.append(n+':'+name)
assert len(objects)==71
commands=read(O/'commands.json');assert len(commands)==14
for c in commands:
 assert c['exit']==0 and c['finished_utc']>=c['started_utc']
 assert c['tool_sha256']==h(Path(c['argv'][0]))
 for k in ['stdout','stderr']:assert h(O/(c['id']+'.'+k))==c[k+'_sha256']
assert commands[2]['stdin_sha256']==h(O/'input.json')
probe=out['contracts']['LifecycleProbe.sol']['LifecycleProbe']['evm'];assert (O/'runtime.hex').read_text()==probe['deployedBytecode']['object']
selector=probe['methodIdentifiers']['probe(uint256)'];expected=read(O/'expected.json');r=read(O/'result.json');assert len(expected)==len(r['scenario_results'])==11
rows=[]
for i,c in enumerate(commands[3:]):
 assert c['id']=='scenario-'+str(i)
 argv=c['argv'];assert argv[argv.index('--input')+1]==selector+format(i,'064x');assert argv[argv.index('--codefile')+1]==str(O/'runtime.hex');assert argv[argv.index('--prestate')+1]==str(O/'paris-genesis.json')
 raw=(O/(c['id']+'.stdout')).read_text().strip();assert re.fullmatch('0x[0-9a-fA-F]{768}',raw)
 row=[int(raw[2+64*j:2+64*(j+1)],16) for j in range(12)]
 assert row==expected[i]==r['scenario_results'][i]['observed']==r['scenario_results'][i]['expected'];rows.append(row)
# Scope assertions use the concrete fixture arithmetic and state observations.
assert rows[0][2]==100 and rows[0][5]==100*(100-80)//100 and rows[0][1]==0 and rows[0][9]==2
assert rows[5][2]==150 and rows[5][5]==100*20//100+50*20//100 and rows[5][1]==1
for i in [1,2,7]:assert rows[i][1]==1 and rows[i][2:9]==[0]*7 and rows[i][9]==1
assert rows[8][1]==2 and rows[8][2:9]==[0]*7 and rows[8][9]==1
assert rows[6][0]==17 and rows[6][2]==100 and rows[6][11]==50 and rows[6][1]==1
for i in [3,4,9]:assert rows[i][1:]==[0]*11
assert rows[10][0]==102 and rows[10][11]==150
altered=json.loads(json.dumps(expected));altered[0][5]=0
try:
 assert rows==altered
except AssertionError:negative=True
else:raise AssertionError('Corrupted payout expectation accepted')
assert h(O/'paris-genesis.json')==h(B/'p24-public-call-diagnostic/paris-genesis.json')
lengths={}
for source,name in [('contracts/DepegProduct.sol','DepegProduct'),('@etherisc/gif-contracts/contracts/services/ProductService.sol','ProductService'),('@etherisc/gif-contracts/contracts/flows/PolicyDefaultFlow.sol','PolicyDefaultFlow')]:
 if source not in out['contracts']:
  found=[s for s in out['contracts'] if s.endswith(source.split('/contracts/')[-1]) and name in out['contracts'][s]];assert len(found)==1;source=found[0]
 lengths[name]=len(out['contracts'][source][name]['evm']['deployedBytecode']['object'])//2
assert all(v<=24576 for v in lengths.values())
result={'utc':now(),'status':'root_verified_bounded_diagnostic','source_seal_sha256':h(O/'root-seal.json'),'source_sealed_files':len(seal['files']),'upstream_sources_unchanged':71,'upstream_contract_creation_and_runtime_objects_unchanged':71,'actual_commands':14,'raw_streams_verified':28,'scenarios':11,'observation_words_per_scenario':12,'negative_control_altered_payout_rejected':negative,'actual_contract_runtime_bytes':lengths,'injected_harness_runtime_bytes':len(probe['deployedBytecode']['object'])//2,'harness_exceeds_EIP170':True,'scope':'Actual DepegProduct public claim creation/processing, ProductService dispatch, PolicyDefaultFlow routing; explicit mock external state and services. Exact refusal/panic bytes checked inside executed harness.','not_covered':r['not_covered'],'P28_accepted':False,'independent_Grok_review':False};put(V/'result.json',result);put(V/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in V.iterdir() if p.is_file()},'acceptance':False});print(json.dumps(result))
