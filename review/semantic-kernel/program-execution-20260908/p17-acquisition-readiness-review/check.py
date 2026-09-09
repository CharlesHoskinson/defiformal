from pathlib import Path
import json,hashlib,subprocess,posixpath,re,datetime
O=Path(__file__).parent; R=Path('/home/charl/defiformal'); X=O/'inputs/review/semantic-kernel/program-execution-20260908'; A=X/'p17-source-acquisition'; C=X/'p17-compiler-readiness'
def load(f):return json.loads(f.read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
checks=[];commands=[]
def check(name,ok,**e):checks.append({'name':name,'ok':bool(ok),**e})
def git(repo,*args):
 argv=['git','--git-dir',repo,*args];p=subprocess.run(argv,capture_output=True);commands.append({'argv':argv,'actual_exit':p.returncode,'stdout':p.stdout.decode(errors='replace'),'stderr':p.stderr.decode(errors='replace')});check('git exit',p.returncode==0,argv=argv);return p.stdout
for d in [A,C]:
 m=load(d/'manifest.json')['files']
 for f,h in m.items():check('retained manifest',sha((d/f).read_bytes())==h,path=str(d/f))
 check('manifest exact members',set(m)=={str(f.relative_to(d)) for f in d.rglob('*') if f.is_file() and f!=d/'manifest.json'},root=d.name)
closure=load(A/'compile-source-closure.json');cap=load(A/'capture.json');keys=closure['compiler_source_keys'];check('10 closure keys',len(keys)==closure['closure_count']==10)
repo=next(v['repository_cache'] for v in keys.values() if v['repository_path']=='src/SUsds.sol');rev=cap['resolved_commit']
for f,h in cap['files'].items():
 b=(A/'capture'/f).read_bytes();check('capture vs hash and immutable Git',sha(b)==h and git(repo,'show',rev+':'+f)==b,path=f)
for key,v in keys.items():
 b=(A/'compile-source-closure'/key).read_bytes();blob=git(v['repository_cache'],'show',v['commit']+':'+v['repository_path']);oid=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
 check('closure bytes/hash/blob',b==blob and sha(b)==v['sha256'] and len(b)==v['bytes'] and oid==v['git_blob_oid'],key=key)
 src=b.decode();raw=re.findall(r'^\s*import\s+[^;]*?[\"\']([^\"\']+)[\"\']\s*;',src,re.M);imports=[posixpath.normpath(posixpath.join(posixpath.dirname(key),q)) if q.startswith('.') else q for q in raw]
 check('actual imports resolved',imports==v['imports'] and all(q in keys for q in imports),key=key,imports=imports)
up='723f8cab09cdae1aca9ec9cc1cfa040c2d4b06c1';core='dbb6104ce834628e473d2173bbc9d47f81a9eec3';uprepo=next(v['repository_cache'] for v in keys.values() if v['commit']==up)
check('sdai exact nested gitlink',('160000 commit '+up+'\tlib/openzeppelin-contracts-upgradeable') in git(repo,'ls-tree',rev,'lib/openzeppelin-contracts-upgradeable').decode())
check('OZ exact nested gitlink',('160000 commit '+core+'\tlib/openzeppelin-contracts') in git(uprepo,'ls-tree',up,'lib/openzeppelin-contracts').decode())
acq=load(C/'compiler-acquisition.json');index=load(C/'solc-bin-list.json');binary=Path(acq['binary_path']);bh=sha(binary.read_bytes());entry=next(e for e in index['builds'] if e['path']==binary.name)
check('official retained index and binary',sha((C/'solc-bin-list.json').read_bytes())==acq['index_sha256'] and entry==acq['upstream_entry'] and bh==entry['sha256'][2:]==acq['binary_sha256'],binary_path=str(binary),binary_sha256=bh,index_sha256=acq['index_sha256'])
check('retained compiler version',acq['version_exit']==0 and (C/'solc-version.stdout').read_text()==acq['version_stdout'] and not (C/'solc-version.stderr').read_bytes())
i=load(C/'standard-json-input.json');output=load(C/'solc.stdout');smoke=load(C/'compile-smoke.json')
check('standard JSON exact 10 sources',set(i['sources'])==set(keys) and all(i['sources'][k]['content'].encode()==(A/'compile-source-closure'/k).read_bytes() for k in keys))
check('recorded invocation/input/settings',smoke['actual_exit']==0 and smoke['argv']==[str(binary),'--standard-json'] and smoke['compiler_sha256']==bh and smoke['settings']==i['settings'] and i['language']=='Solidity' and set(smoke['source_keys'])==set(keys))
check('actual compiler diagnostics',not output.get('errors',[]) and not smoke['errors'] and not smoke['warnings'] and not (C/'solc.stderr').read_bytes())
art=[]
for file,contracts in output['contracts'].items():
 for name,v in contracts.items():
  cr=v['evm']['bytecode']['object'];rt=v['evm']['deployedBytecode']['object']
  if not cr and not rt:continue
  art.append(file+':'+name);record=smoke['artifacts'][art[-1]]
  check('creation/runtime units',record['creation_hex_sha256']==sha(cr.encode()) and record['runtime_hex_sha256']==sha(rt.encode()) and record['creation_bytes']==len(bytes.fromhex(cr)) and record['runtime_bytes']==len(bytes.fromhex(rt)),artifact=art[-1],creation_hex_sha256=sha(cr.encode()),runtime_hex_sha256=sha(rt.encode()),creation_bytes=len(bytes.fromhex(cr)),runtime_bytes=len(bytes.fromhex(rt)))
check('artifact exact denominator',set(art)==set(smoke['artifacts']),count=len(art))
inputs=load(O/'input-manifest.json');preserved={k:sha((R/k).read_bytes())==v['sha256'] for k,v in inputs['files'].items()};check('all original input bytes preserved',all(preserved.values()),count=len(preserved))
(O/'commands.json').write_text(json.dumps(commands,indent=2)+'\n');(O/'checks.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'passed':sum(c['ok'] for c in checks),'total':len(checks),'preserved_inputs':preserved,'receipt_limit':'Historical root process exits reused from retained receipts; no fresh compiler/network run.'},indent=2)+'\n')
print(json.dumps({'passed':sum(c['ok'] for c in checks),'total':len(checks),'failures':[c for c in checks if not c['ok']],'artifact_count':len(art),'git_reads':len(commands)},indent=2));raise SystemExit(0 if all(c['ok'] for c in checks) else 1)
