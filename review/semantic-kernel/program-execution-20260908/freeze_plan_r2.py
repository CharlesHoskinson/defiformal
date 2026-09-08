#!/usr/bin/env python3
import datetime,difflib,gzip,hashlib,json,pathlib,tarfile
X=pathlib.Path(__file__).resolve().parent
C=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260908')
old=json.loads((X/'repair-candidate-manifest.json').read_text());W=pathlib.Path(old['worktree']);P=pathlib.Path(old['program']);h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
events=[]
for line in (C/'repair-author-r2.jsonl').read_text().splitlines():
 try:events.append(json.loads(line))
 except json.JSONDecodeError:pass
ends=[e for e in events if e.get('type')=='end'];assert len(ends)==1,'No native terminal';assert ends[0].get('stopReason')=='end_turn','Native did not finish normally'
files={str(p.relative_to(P)):h(p) for p in sorted(P.rglob('*')) if p.is_file()};assert set(files)==set(old['files']),'Unexpected program file set'
archive=X/'repair-candidate-r2.tar.gz';assert not archive.exists()
with tarfile.open(archive,'w:gz') as tar:
 for rel in files:tar.add(P/rel,arcname=rel)
diff=[]
with tarfile.open(X/'repair-candidate-r1.tar.gz') as tar:
 for rel in files:
  before=tar.extractfile('openspec/changes/reusable-verification-platform-program/'+rel).read().decode().splitlines(True);after=(P/rel).read_text().splitlines(True)
  diff.extend(difflib.unified_diff(before,after,fromfile='r1/'+rel,tofile='r2/'+rel))
(X/'repair-candidate-r2.diff').write_text(''.join(diff))
author=W/'review/semantic-kernel/program-plan-repair-r2-20260908';assert (author/'REPORT.md').is_file() and (author/'result.json').is_file()
for p in sorted(author.rglob('*')):
 if p.is_file():
  q=X/'plan-r2-author'/p.relative_to(author);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
m={'worktree':str(W),'program':str(P),'archive':str(archive),'archive_sha256':h(archive),'files':files,'native_terminal':ends[0],'process_exit':0,'prior_archive_sha256':'f4162b193aa0ad2b0884c93652cc6bb4507f443ee96318d96c687199f13f35a2','changed_files':[p for p,v in files.items() if v!=old['files'][p]],'independent_acceptance':False,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(X/'repair-candidate-r2-manifest.json').write_text(json.dumps(m,indent=2)+'\n')
for ext in ['jsonl','stderr']:
 p=C/('repair-author-r2.'+ext)
 with gzip.open(X/(p.name+'.gz'),'wb') as f:f.write(p.read_bytes())
print(json.dumps({'archive_sha256':m['archive_sha256'],'changed_files':m['changed_files'],'stop_reason':ends[0].get('stopReason')}))
