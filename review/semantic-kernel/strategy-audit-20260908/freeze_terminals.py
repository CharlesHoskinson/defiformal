from pathlib import Path
import json,gzip,tarfile,hashlib,shutil,datetime
H=Path('/home/charl');P=Path('review/semantic-kernel/program-loop-20260908');L=H/'.cache/defiformal-sprint11-builds/logs';records=[]
cases=[('sprint12','m4-compatible-recovery-r2',86604,0,['review/semantic-kernel/sprint12/implementation/grok-compatible-recovery-r2','lean/DefiKernel/Nary/Tree']),('claims','claims-generic-proofs-r1',1202,1,['review/semantic-kernel/claims-lifecycle/implementation/grok-generic-proofs-r1','lean/DefiKernel/Claims']),('certificates','certificates-official-repair-r2',13753,0,['review/semantic-kernel/certificates/planning/grok-gpt6-official-r2','openspec/changes/serialized-kernel-certificates']),('atlas','atlas-accessibility-r1',95489,0,['review/semantic-kernel/atlas/implementation/grok-accessibility-r1','viz/src','viz/test','viz/scripts','viz/package.json','viz/package-lock.json','viz/dist/index.html','README.md','docs/UNIFIED-DEFI-ELEMENT-TABLE.md','openspec/changes/design-atlas-visualization/design.md']),('honest-gate','honest-gate-clean-closeout-r2',82944,0,['review/semantic-kernel/honest-gate/implementation/grok-clean-closeout-r2','formal/v3/negtest-reporting.sh'])]
for lane,name,sid,rc,scopes in cases:
 r=H/f'defiformal-wt-{lane}-grok-gpt6-20260908';o=r/P/'native-worker';o.mkdir(exist_ok=True)
 receipt=o/(name+'.json')
 if receipt.exists():raise RuntimeError('Already frozen: '+str(receipt))
 raw=(L/(name+'.jsonl')).read_bytes();end=[x for line in raw.splitlines() if (x:=json.loads(line)).get('type')=='end'];assert len(end)==1;end=end[0];assert end.get('stopReason')==('cancelled' if rc else 'end_turn')
 files=[]
 for scope in scopes:
  p=r/scope;assert p.exists(),p
  files.extend([p] if p.is_file() else [q for q in sorted(p.rglob('*')) if q.is_file() and not q.is_symlink() and '__pycache__' not in q.parts])
 files=sorted(set(files));arc=o/(name+'-stage.tar.gz');assert not arc.exists()
 with tarfile.open(arc,'w:gz') as t:
  for p in files:t.add(p,arcname=str(p.relative_to(r)),recursive=False)
 z=o/(name+'.jsonl.gz');z.write_bytes(gzip.compress(raw,mtime=0));err=o/(name+'.stderr');shutil.copyfile(L/(name+'.stderr'),err)
 rec={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit_code':rc,'unified_session_id':sid,'terminal_observation_source':'Root actual write_stdin results preserved checkpoint-user-checklist-terminal-update.json; end-record corroborates reason/identity','native_session_id':end.get('sessionId'),'actual_model_keys':list(end.get('modelUsage',{})),'stop_reason':end.get('stopReason'),'raw_sha256':hashlib.sha256(raw).hexdigest(),'artifacts':[{'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in [arc,err,z]],'archive_files':len(files),'scope':scopes,'status':'cancelled incomplete candidate preserved; no acceptance' if rc else 'frozen candidate; independent acceptance pending','preservation_executor':'root GPT6, no source authorship or review acceptance implied'}
 receipt.write_text(json.dumps(rec,indent=2)+'\n');records.append(rec);print(name,rc,len(files),rec['artifacts'][0]['sha256'])
(H/'defiformal/review/semantic-kernel/strategy-audit-20260908/evidence/terminal-freezes.json').write_text(json.dumps(records,indent=2)+'\n')
