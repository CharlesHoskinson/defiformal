from pathlib import Path
import json,hashlib,gzip,datetime,re
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p28-public-processor-diagnostic';v=b/'p28-public-processor-root-verification';v.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
seal=read(o/'root-seal.json')
for n,d in seal['files'].items():assert h(o/n)==d,n
cmds=read(o/'commands.json');assert len(cmds)==6
for c in cmds:
 assert c['exit']==0 and c['actor']=='root' and c['started_utc']<=c['finished_utc']
 for stream in ['stdout','stderr']:assert h(o/(c['id']+'.'+stream))==c[stream+'_sha256']
 assert h(Path(c['argv'][0]))==c['tool_sha256']
old=json.loads(gzip.decompress((b/'p28-depeg-compiler-baseline/input.json.gz').read_bytes()));new=read(o/'input.json');assert len(old['sources'])==71 and len(new['sources'])==72
for n,d in old['sources'].items():assert new['sources'][n]==d,n
assert new['sources']['LifecycleProbe.sol']['content']==(o/'LifecycleProbe.sol').read_text()
out=read(o/'compile.stdout');oldout=json.loads(gzip.decompress((b/'p28-depeg-compiler-baseline/stdout.json.gz').read_bytes()));ncontracts=0
for source,contracts in oldout['contracts'].items():
 for n,c in contracts.items():
  for k in ['bytecode','deployedBytecode']:assert c['evm'][k]['object']==out['contracts'][source][n]['evm'][k]['object'],(source,n,k)
  ncontracts+=1
assert ncontracts==71
result=read(o/'result.json');expected=[[0,0,100,1,1,20,1,1,20,2,1,150],[1,1,0,0,0,0,0,0,0,1,1,0],[1,0,0,0,0,0,0,0,0,0,0,0]]
assert read(o/'expected.json')==expected
for i,e in enumerate(expected):
 raw=(o/f'scenario-{i}.stdout').read_text().strip();assert re.fullmatch('0x[0-9a-fA-F]{768}',raw)
 values=[int(raw[2+64*j:2+64*(j+1)],16) for j in range(12)];assert values==e
 c=next(c for c in cmds if c['id']==f'scenario-{i}');payload=c['argv'][c['argv'].index('--input')+1];assert int(payload[8:],16)==i+11
 assert result['scenario_results'][i]=={'scenario':i+11,'observed':e,'expected':e}
assert result['harness_runtime_bytes']==57236 and result['P28_accepted']==False
# The actual executed harness checks caller distinction and exact error bytes.
s=(o/'LifecycleProbe.sol').read_text();assert 's.product.owner()==address(this) && address(actor)!=address(this)' in s
assert 'function process(DepegProduct p,bytes32 id) external { p.processPolicy(id); }' in s
assert 'expectFailure(ok,raw,scenario==12 ? "ERROR:DP-043:DEPEG_BALANCE_MISSING" : "ERROR:DP-042:NOT_IN_PROCESS_SET")' in s
# Negative verification control uses the same equality predicate as observed vector verification.
def verify_vector(actual,expected):
 if actual!=expected:raise ValueError('unexpected observed vector')
changed=list(expected[0]);changed[5]=21
try:verify_vector(changed,expected[0])
except ValueError:rejected=True
else:rejected=False
assert rejected
put(v/'result.json',{'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'diagnostic_root_seal_sha256':h(o/'root-seal.json'),'diagnostic_sealed_files':len(seal['files']),'command_receipts':6,'raw_streams':12,'actual_scenarios':[11,12,13],'upstream_source_strings_unchanged':71,'upstream_creation_runtime_objects_unchanged':71,'raw_vectors_match':True,'altered_paid_amount_negative_rejected':True,'public_processor_case':'A distinct nonowner/noninsured contract invokes actual processPolicy; queued attested case succeeds, missing-attestation and unqueued cases return exact checked refusals','harness_runtime_injected_bytes':57236,'actor':'root','scope':'Bounded EVM verification only; fixture policy, treasury, pool, license, oracle and registry. No actual tokens/controller accounting/universal financial proof. Review pending.','P28_accepted':False})
(v/'verify.py').write_bytes(Path(__file__).read_bytes());put(v/'root-seal.json',{'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{p.name:h(p) for p in v.iterdir()},'file_count':2,'acceptance':False});print(json.dumps({'scenarios':3,'bindings':len(seal['files']),'commands':6,'sources':71,'contracts':71,'negative_rejected':True,'P28_accepted':False}))
