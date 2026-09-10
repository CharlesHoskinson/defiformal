from pathlib import Path,PurePosixPath
import subprocess,tarfile,io,re,json,hashlib,datetime,posixpath
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';repo=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p23-liquity-v1-source-repository');pin='3e64ee1b52c50d51587c64c1cf75e0ba82934979';base='packages/contracts/contracts/';out=b/'p23-v1-source-closure';out.mkdir(exist_ok=False)
def git(*a):return subprocess.check_output(['git',*a],cwd=repo)
assert git('rev-parse','HEAD').decode().strip()==pin
roots=[base+n for n in ['TroveManager.sol','SortedTroves.sol','ActivePool.sol','DefaultPool.sol','LUSDToken.sol','BorrowerOperations.sol','PriceFeed.sol','CollSurplusPool.sol','GasPool.sol','StabilityPool.sol','LQTY/LQTYToken.sol','LQTY/LQTYStaking.sol','LQTY/CommunityIssuance.sol','LQTY/LockupContractFactory.sol','Dependencies/TellorCaller.sol']]
archive=git('archive','--format=tar',pin,base);all_sources={}
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t.getmembers():
  if m.isfile() and m.name.endswith('.sol'):all_sources[m.name]=t.extractfile(m).read()
# Preserve quoted strings while removing comments, so import paths remain intact.
lex=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/')
def clean(txt):return lex.sub(lambda m:' ' if m.group().startswith(('//','/*')) else m.group(),txt)
imports=re.compile(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;')
queue=list(roots);seen=set();edges=[];unresolved=[]
while queue:
 n=queue.pop()
 if n in seen:continue
 if n not in all_sources:unresolved.append({'source':n,'reason':'selected source not found'});continue
 seen.add(n)
 for target in imports.findall(clean(all_sources[n].decode())):
  resolved=posixpath.normpath(posixpath.join(posixpath.dirname(n),target)) if target.startswith('.') else target
  edges.append({'from':n,'import':target,'to':resolved})
  if resolved not in all_sources:unresolved.append({'source':n,'import':target,'resolved':resolved})
  else:queue.append(resolved)
assert not unresolved,unresolved
files={}
for n in sorted(seen):
 data=all_sources[n];p=out/'upstream'/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data);blob=git('rev-parse',pin+':'+n).decode().strip();assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==blob;files[n]={'sha256':hashlib.sha256(data).hexdigest(),'git_blob':blob,'bytes':len(data)}
# Verify overlap against the previous selected-source capture.
old=json.loads((b/'p23-v1-source-entry-preparation/readiness.json').read_text()); overlap=0
for n,v in files.items():
 if n in old['files']:assert v==old['files'][n];overlap+=1
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();arc=out/'source-closure.tar.gz'
with tarfile.open(arc,'w:gz') as t:
 for n in sorted(seen):t.add(out/'upstream'/n,arcname=n,recursive=False)
now=datetime.datetime.now(datetime.timezone.utc).isoformat();record={'schema':'defiformal-static-solidity-source-closure/v1','utc':now,'source_repository':'https://github.com/liquity/dev.git','commit':pin,'root_files':roots,'source_files':files,'source_file_count':len(files),'import_edges':edges,'unresolved_static_imports':unresolved,'parser':'Quoted strings preserved; line/block comments removed; Solidity import string targets recursively resolved. No compiler invoked.','selected_capture_overlap_verified':overlap,'archive_sha256':sha(arc),'source_exposure':'development_source_preparation_not_untouched_holdout','source_execution':False,'compiler_check':False,'task24_1_accepted':False,'P23_accepted':False,'limits':['Static import closure for these15 named roots, not a completed deployment/test harness','External price feeds and Tellor are interfaces here; no deployment/address/state authenticity established','No compiler binary or EVM execution obtained from this capture','Empty eligible-set guard reachability and exact observed refusal remain unresolved','No Lean implementation or proof','Historical P10 liquidation-source dispute remains separate'],'next':'Use this pinned closure plus preserved compiler settings when AGY prepares the P23 source experiment; freeze admitted state domain, root/fixture source differences, runtime/compiler identities, and actual success/refusal observations.'};(out/'readiness.json').write_text(json.dumps(record,indent=2)+'\n');(out/'README.md').write_text('''# P23 V1 static source closure

This capture resolves the local Solidity imports of 15 named production roots at Liquity V1 pin `3e64ee1b52c50d51587c64c1cf75e0ba82934979`. Every captured source has a Git blob and SHA256 identity. The previous selected-source capture is unchanged.

This closes the identified source-file preparation gap for these roots. It does not establish successful compilation, deployment, or a reachable empty-set refusal. External oracle contracts remain interfaces. The experiment still needs an explicit pre-state domain, pinned compiler/runtime, actual partial-fill and required refusal observations, and independent review. P23 task24.1 remains open.
''');(out/'manifest.json').write_text(json.dumps({'schema':'defiformal-source-closure-manifest/v1','utc':now,'self_excluding':True,'files':{str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file()},'acceptance':False},indent=2)+'\n');print(json.dumps({'files':len(files),'roots':len(roots),'edges':len(edges),'unresolved':len(unresolved),'overlap':overlap,'acceptance':False}))
