from pathlib import Path, PurePosixPath
import datetime,hashlib,json,urllib.request,tarfile,shutil,re,posixpath
ROOT=Path('/home/charl/defiformal');BASE=ROOT/'review/semantic-kernel/program-execution-20260908';DISC=BASE/'p25-balancer-source-discovery';OUT=BASE/'p25-balancer-source-preparation';CACHE=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p25-balancer-source')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda data:hashlib.sha256(data).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
OUT.mkdir(exist_ok=False);CACHE.mkdir(exist_ok=False)
commit=json.loads((DISC/'commit.json').read_text());pin=commit['sha'];tree=json.loads((DISC/'tree.json').read_text());assert not tree['truncated'];blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'}
url='https://codeload.github.com/balancer/balancer-v3-monorepo/tar.gz/'+pin;archive=CACHE/(pin+'.tar.gz');start=now()
with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=60) as response:
 status=response.status;headers=dict(response.headers);final=response.url
 with archive.open('xb') as f:
  size=0
  while data:=response.read(1024*1024):
   size+=len(data);assert size<=100*1024*1024,'Archive exceeds bound';f.write(data)
assert status==200
put(OUT/'archive-http.json',{'url':url,'final_url':final,'started_utc':start,'finished_utc':now(),'status':status,'headers':headers,'bytes':size,'sha256':sha(archive.read_bytes()),'archive_cache_path':str(archive),'archive_published':False})
shutil.copytree(DISC,OUT/'discovery')
with tarfile.open(archive) as tar:
 members={};regular_count=0
 for member in tar.getmembers():
  parts=PurePosixPath(member.name).parts;assert parts and not member.name.startswith('/') and '..' not in parts
  if member.isfile():members['/'.join(parts[1:])]=member;regular_count+=1
 def get(path):
  member=members[path];assert member.size<=8*1024*1024,path;data=tar.extractfile(member).read();blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest();assert blob==blobs[path]['sha'],path;return data
 aliases={}
 for path in blobs:
  if path.endswith('/package.json') and path.count('/')==2:
   package=json.loads(get(path));aliases[package['name']]=posixpath.dirname(path)
 seeds=['pkg/vault/contracts/Vault.sol','pkg/vault/contracts/VaultExtension.sol','pkg/vault/contracts/VaultAdmin.sol','pkg/vault/contracts/Router.sol','pkg/vault/contracts/BaseHooks.sol','pkg/vault/contracts/test/PoolHooksMock.sol','pkg/vault/contracts/test/UnlockCallerMock.sol']
 queue=seeds[:];seen=set();edges=[];external=[]
 while queue:
  path=queue.pop(0)
  if path in seen:continue
  data=get(path);seen.add(path)
  # Imports are source-navigation edges. Compiler resolution remains a separate gate.
  for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',data.decode()):
   spec=match.group(1);target=None
   if spec.startswith('.'):target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec))
   else:
    for alias,base in aliases.items():
     if spec.startswith(alias+'/'):target=base+spec[len(alias):];break
   row={'from':path,'import':spec,'line':data[:match.start()].count(b'\n')+1,'resolved':target if target in blobs else None}
   if target in blobs:edges.append(row);queue.append(target)
   else:external.append(row)
 auxiliary=['LICENSE','README.md','package.json','yarn.lock','pkg/vault/package.json','pkg/vault/foundry.toml','pkg/interfaces/package.json','pkg/solidity-utils/package.json','pkg/vault/test/foundry/Hooks.t.sol','pkg/vault/test/foundry/HookAdjustedLiquidity.t.sol']
 records=[]
 for path in sorted(seen|set(auxiliary)):
  data=get(path);dest=OUT/'source'/path;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data);records.append({'path':'source/'+path,'upstream_path':path,'sha256':sha(data),'git_blob_sha1':blobs[path]['sha'],'bytes':len(data),'role':'import_traversal_source' if path in seen else 'configuration_or_unexecuted_reference_test','url':'https://github.com/balancer/balancer-v3-monorepo/blob/'+pin+'/'+path})
put(OUT/'source-manifest.json',{'utc':now(),'repository':'https://github.com/balancer/balancer-v3-monorepo','commit':pin,'selection':'Official main HEAD observed at discovery time; candidate source pin, not deployment identity or accepted source-entry gate.','seeds':seeds,'files':records,'file_count':len(records),'traversed_source_files':len(seen),'local_import_edges':edges,'unresolved_external_imports':external,'package_aliases':aliases,'archive_regular_members':regular_count,'test_import_closure_claimed':False,'compiler_import_closure_claimed':False,'source_execution':False,'acceptance':False})
shutil.copy2(__file__,OUT/'capture.py')
(OUT/'README.md').write_text(f'''# P25 Balancer source candidate\n\nPinned official Balancer V3 source `{pin}` for later AGY source-entry design and Grok review. The main HEAD was observed at the recorded discovery time; this is not an assertion that a deployed vault uses this revision.\n\nThe packet contains {len(records)} files whose Git blob identities match the captured GitHub tree, including {len(seen)} sources reached from seven vault/router/hook seeds. There are {len(edges)} local import edges and {len(external)} unresolved external import occurrences. Import traversal is source navigation, not compiler resolution. The two reference tests are retained without a test dependency closure or execution claim.\n\nP25 must still freeze cash-plus-owed and hook-revert observations, resolve compiler and external dependencies, execute nonempty join and refusal controls, implement the shared-vault Lean model and proofs, detect publish-on-revert and independent conservation-break negatives, and obtain independent review. No P25 task is accepted here. P17 keeps its separate accepted source pin.\n\nArchive bytes stay in the recorded local cache; published source bytes can be checked against the captured commit tree without running downloaded code. No source build, package install, EVM test, Lean proof or deployment correspondence ran in this capture.\n''')
files={str(p.relative_to(OUT)):sha(p.read_bytes()) for p in OUT.rglob('*') if p.is_file()};put(OUT/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'P25_accepted':False});print(json.dumps({'commit':pin,'source_files':len(records),'traversed_source_files':len(seen),'local_import_edges':len(edges),'external_import_occurrences':len(external),'archive_bytes':size,'sealed_files':len(files),'acceptance':False}))
