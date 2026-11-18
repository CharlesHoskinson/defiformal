from pathlib import Path
import hashlib,json,re,subprocess,sys

repo=Path('/private/tmp/defiformal-release-author')
evidence=Path('/private/tmp/defiformal-release-author-evidence')
base='6ebed6bf2af7bb753ab26085cc934cfc5dfd321a'
allowed={'LICENSE','CONTRIBUTING.md','THIRD_PARTY_NOTICES.md','README.md','benchmarks/competitive-landscape/README.md','docs/releases/v0.1.0.md'}

def git(*args):return subprocess.check_output(['git',*args],cwd=repo)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
changed=set(git('diff','--name-only',base).decode().splitlines())|set(git('ls-files','--others','--exclude-standard').decode().splitlines())
assert changed==allowed,changed
assert (repo/'LICENSE').read_bytes()==(evidence/'apache-official.txt').read_bytes()
assert sha(repo/'LICENSE')=='cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30'
subprocess.run(['git','diff','--check'],cwd=repo,check=True)
subprocess.run(['git','diff','--exit-code',base,'--','lean','benchmarks/competitive-landscape/upstream'],cwd=repo,check=True)
manifest=json.loads((repo/'benchmarks/competitive-landscape/PROVENANCE.json').read_text())
assert len(manifest['files'])==168
for entry in manifest['files']:
 path=repo/'benchmarks/competitive-landscape'/entry['path']
 assert sha(path)==entry['sha256'],entry['path']
snapshots=[entry for entry in manifest['files'] if '/upstream/DefiKernel/' in entry['path']]
assert len(snapshots)==6
for entry in snapshots:
 rel=entry['path'].split('/upstream/',1)[1]
 assert (repo/'benchmarks/competitive-landscape'/entry['path']).read_bytes()==git('show',manifest['upstream_defiformal_revision']+':lean/'+rel)
notices={}
for name in ['Permission','Extremal','Nary','Independence','Interface','FlowPolarity']:
 path='lean/Defialgebra/'+name+'.lean'
 assert (repo/path).read_bytes()==git('show',base+':'+path)
 assert 'Copyright (c) 2026 Charles Hoskinson. All rights reserved.' in (repo/path).read_text()
 notices[path]=sha(repo/path)
links=[]
for name in sorted(allowed-{'LICENSE'}):
 path=repo/name
 for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)',path.read_text()):
  if re.match(r'^[A-Za-z][A-Za-z0-9+.-]*:',target):continue
  location=target.split('#',1)[0]
  resolved=(path.parent/location).resolve()
  assert resolved.exists(),(name,target)
  assert resolved.is_relative_to(repo),(name,target)
  links.append({'source':name,'target':target})
result={'status':'passed','base_revision':base,'python':sys.version,'python_executable':sys.executable,'files':{name:sha(repo/name) for name in sorted(allowed)},'official_license_url':'https://www.apache.org/licenses/LICENSE-2.0.txt','license_bytes':(repo/'LICENSE').stat().st_size,'adapter_files_checked':168,'native_snapshots_verified':6,'named_original_notices_preserved':notices,'relative_links_checked':len(links),'source_and_historical_notices_unchanged':True,'checks':['only six allowed documentation/license files changed','canonical official Apache text matches byte-for-byte','git diff --check','all Lean and imported adapter source bytes unchanged','168 adapter provenance hashes','six native snapshots match pinned Git objects','six explicit original holder notices preserved','relative Markdown targets exist'],'scope':'Documentation/license preparation only. No Lean proof build repeated; no tag or release published; no outside reproduction claimed.'}
(evidence/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
(evidence/'FREEZE.json').write_text(json.dumps({'base_revision':base,'files':result['files'],'source_digest':hashlib.sha256(json.dumps(result['files'],sort_keys=True).encode()).hexdigest()},indent=2)+'\n')
print(json.dumps(result,indent=2))
