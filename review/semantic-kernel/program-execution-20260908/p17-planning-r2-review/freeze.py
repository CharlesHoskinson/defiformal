from pathlib import Path
import json,hashlib,tarfile,datetime,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p17-planning-r2-review';W=Path('/home/charl/defiformal-wt-p17-vault-grok-gpt6-20260908')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=json.loads((B/'p17-planning-r2-process.json').read_text());assert p['process_exit']==0 and p['native_end']['stopReason']=='end_turn';assert sha(Path(p['log']))==p['log_sha256']
r1=json.loads((B/'p17-planning-candidate-r1-manifest.json').read_text());assert sha(B/r1['archive'])==r1['archive_sha256']=='000d48b5664a18ac3f4378f48bb150a51cf32427ff63d36d1dcf28e9cf1d72f1'
r1rows=[f for f in r1['files'] if '/grok-r1/' in f['path']];assert len(r1rows)==23
for f in r1rows: assert sha(W/f['path'])==f['sha256'],f['path']
plan=Path('openspec/changes/vault-platform-reuse-p17');ev=Path('review/semantic-kernel/vault-platform-reuse/p17/planning');am=json.loads((W/ev/'grok-r2/manifest.json').read_text());verified=0
for key,base in [('change_files',plan),('evidence_files',ev/'grok-r2')]:
 for row in am[key]:
  q=W/base/row['path'];assert sha(q)==row['sha256'] and q.stat().st_size==row['bytes'],q;verified+=1
paths=sorted(q.relative_to(W) for prefix in [plan,ev/'grok-r1',ev/'grok-r2'] for q in (W/prefix).rglob('*') if q.is_file())
rows=[{'path':str(q),'sha256':sha(W/q),'bytes':(W/q).stat().st_size} for q in paths]
a=B/'p17-planning-candidate-r2.tar.gz';assert not a.exists()
with tarfile.open(a,'w:gz') as t:
 for q in paths:
  assert not (W/q).is_symlink();t.add(W/q,arcname=str(q),recursive=False)
manifest={'schema':'defiformal-frozen-candidate/v1','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'worktree':str(W),'base':am['head'],'files':rows,'archive':a.name,'archive_sha256':sha(a),'accepted':False,'author_manifest_rows_verified':verified,'r1_evidence_files_preserved':len(r1rows),'process_receipt':'p17-planning-r2-process.json','process_receipt_sha256':sha(B/'p17-planning-r2-process.json')}
(B/'p17-planning-candidate-r2-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
with tarfile.open(a) as t:
 for f in t.getmembers():assert f.isfile() and not f.name.startswith('/') and '..' not in Path(f.name).parts
 t.extractall(O/'candidate',filter='data')
for f in rows:assert sha(O/'candidate'/f['path'])==f['sha256'] and sha(W/f['path'])==f['sha256']
(O/'binding.json').write_text(json.dumps({'archive_sha256':sha(a),'files':len(rows),'author_manifest_rows_verified':verified,'r1_evidence_files_preserved':23,'terminal_process_exit':p['process_exit'],'native_end':p['native_end'],'safe_extraction':True},indent=2)+'\n')
print(json.dumps({'archive':str(a),'sha256':sha(a),'files':len(rows),'author_manifest_rows_verified':verified,'r1_evidence_files_preserved':23},indent=2))
