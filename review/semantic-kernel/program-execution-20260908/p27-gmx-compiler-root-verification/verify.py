from pathlib import Path
import collections,datetime,gzip,hashlib,json,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p27-gmx-compiler-root-verification';now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest();read=lambda p:json.loads(p.read_text())
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
O.mkdir(exist_ok=False);start=now();bound=0
for name in ['p27-gmx-compiler-preparation','p27-gmx-compiler-baseline']:
 p=B/name;s=read(p/'root-seal.json');assert len(s['files'])>0
 for n,d in s['files'].items():assert h((p/n).read_bytes())==d,n;bound+=1
p=B/'p27-gmx-compiler-baseline';cmd=read(p/'command.json');r=read(p/'result.json');compiler=read(B/'p27-gmx-compiler-preparation/compiler.json');assert h(Path(compiler['binary_path']).read_bytes())==compiler['binary_sha256']==cmd['compiler_sha256']==compiler['official_build']['sha256'].removeprefix('0x')
raw={}
for n in ['input.json','stdout.json','stderr.txt']:
 raw[n]=gzip.decompress((p/(n+'.gz')).read_bytes());assert h(raw[n])==cmd['raw_files'][n]['sha256'];assert len(raw[n])==cmd['raw_files'][n]['bytes']
assert cmd['exit']==0 and not cmd['timed_out'];inp=json.loads(raw['input.json']);out=json.loads(raw['stdout.json']);assert len(inp['sources'])==91
for row in r['source_bindings']:
 data=Path(row['path']).read_bytes();assert h(data)==row['sha256'];assert data.decode()==inp['sources'][row['source_name']]['content']
assert len(r['source_bindings'])==91 and inp['settings']==r['settings'];assert inp['settings']['optimizer']=={'enabled':True,'runs':10,'details':{'constantOptimizer':True}}
assert out.get('errors',[])==[];contracts=[];unlinked=[];evms=collections.Counter()
for source,cs in out['contracts'].items():
 for name,obj in cs.items():
  md=json.loads(obj['metadata']);evms[md['settings']['evmVersion']]+=1
  assert md['compiler']['version']=='0.8.29+commit.ab55807c'
  creation=obj.get('evm',{}).get('bytecode',{}).get('object','');runtime=obj.get('evm',{}).get('deployedBytecode',{}).get('object','')
  if '__$' in creation:unlinked.append(source+':'+name)
  contracts.append({'source':source,'contract':name,'creation_bytes':len(creation)//2,'runtime_bytes':len(runtime)//2,'metadata_sha256':h(obj['metadata'].encode())})
assert contracts==r['contracts'] and len(contracts)==91 and sum(x['creation_bytes']>0 for x in contracts)==72 and len(unlinked)==10
result={'started_utc':start,'finished_utc':now(),'sealed_artifact_bindings':bound,'compiler_sha256':compiler['binary_sha256'],'raw_command':str((p/'command.json').relative_to(B)),'command_started_utc':cmd['started_utc'],'command_finished_utc':cmd['finished_utc'],'source_bindings':91,'contracts':91,'nonempty_creation_objects':72,'creation_objects_with_unresolved_library_links':unlinked,'metadata_evm_versions':dict(evms),'errors':0,'warnings':0,'stdin_sha256':cmd['stdin_sha256'],'stdout_sha256':cmd['stdout_sha256'],'interpretation':'Actual root standalone Solidity0.8.29 standard-JSON compile with GMX-declared optimizer settings. Compiler metadata defaults EVM to Cancun.10 creation objects retain unresolved library-address placeholders. This is not deployed bytecode, a full Hardhat build, runtime/test execution, formal proof or independent review.','P27_accepted':False};put(O/'result.json',result);shutil.copy2(__file__,O/'verify.py');put(O/'root-seal.json',{'utc':now(),'files':{p.name:h(p.read_bytes()) for p in O.iterdir() if p.is_file()},'acceptance':False});print(json.dumps({k:v for k,v in result.items() if k!='creation_objects_with_unresolved_library_links'}))
