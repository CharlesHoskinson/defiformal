from pathlib import Path
import json,hashlib,datetime,gzip,os,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p26-source-grok-r1';C=O/'closeout';F=O/'original-terminal';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox');V=O/'root-verification';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
p=read(C/'process.json');orig=read(O/'process.json');assert p['process_exit']==0 and p['reported_models']==['grok-4.6-build'] and p['sessions']==orig['sessions'] and h(C/'native.jsonl')==p['log_sha256'];assert not Path('/proc',str(read(C/'dispatch.json')['pid'])).exists()
for proc in Path('/proc').iterdir():
 if not proc.name.isdigit():continue
 try:cwd=str((proc/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(proc.name,cwd)
V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py')
for name,d in read(F/'root-seal.json')['files'].items():assert h(F/name)==d,name
for name,d in read(F/'root-seal.json')['files'].items():
 if name=='native.jsonl.gz':continue
 assert h(O/name)==d,('parent mutated',name)
for name,d in read(O/'inputs.json')['files'].items():assert h(S/name)==d,name
m=read(C/'MANIFEST.json');assert m['file_count']==len(m['files'])==6 and m['self_excluding']
for name,row in m['files'].items():assert h(C/name)==row['sha256'] and (C/name).stat().st_size==row['bytes'],name
v=read(C/'verdict.json');assert v['verdict']=='usable' and not v['P26_accepted'] and not v['P29_accepted'];assert 'Placeholder' not in (C/'REVIEW.md').read_text()
commands=read(C/'commands.json')['commands'];assert len(commands)==5
for row in commands:
 if row.get('receipt'):
  rec=read(Path(row['receipt']))
  for key in ['argv','cwd','started_utc','finished_utc','exit','python_sha256']:
   assert row[key]==rec[key],(row['id'],key)
 for stream in ['stdout','stderr']:
  if row.get(stream+'_path'):assert h(Path(row[stream+'_path']))==row[stream+'_sha256']
bind=B/'p26-source-review-root-bindings-attempt2';bs=read(bind/'root-seal.json')
for name,d in bs['files'].items():assert h(bind/name)==d,name
native=[json.loads(l) for l in (C/'native.jsonl').read_text().splitlines()];calls=[x for x in native if x.get('type')=='tool_call'];summary=[]
for call in calls:
 row={'toolCallId':call['toolCallId'],'tool':call['toolName'],'input':call.get('rawInput')};summary.append(row)
put(V/'closeout-native-call-index.json',summary)
result={'utc':now(),'status':'completed_root_verified','scope':'P26 selected IBC source-preparation suitability only','scoped_result':'USABLE with required faithful observation mapping; no workflow, Lean, runtime or full P26/P29 acceptance','original_exit':orig['process_exit'],'original_max_turns':20,'closeout_exit':p['process_exit'],'requested_model':'grok-4.6','original_and_closeout_reported_models':p['reported_models'],'same_independent_session':p['sessions'][0],'original_native_sha256':orig['log_sha256'],'closeout_native_sha256':p['log_sha256'],'review_manifest_bindings_verified':6,'input_bindings_verified':56,'original_packet_bindings_verified':24,'reviewer_command_rows':5,'reviewer_native_shell_calls':4,'reviewer_identity_checks':38,'reviewer_source_excerpts':30,'root_source_identity_replay':'p26-source-review-root-bindings-attempt2/command.json','root_replay_matches_reviewer':True,'closeout_native_tool_calls':len(calls),'author_worktree_inspected_by_root_here':False,'source_execution':False,'Go_execution':False,'P26_accepted':False,'P29_accepted':False,'remaining':['Freeze faithful concrete workflow, observation and assumption contract for task27.1; ordinary duplicates return NOOP,nil and cannot be relabelled transaction errors.','Model actual errors separately: guards, stale prior channel sequence, future ordered sequence, failed proofs/refund.','Keep origin-dependent conditional refund, ordinary timeout maturity/nonreceipt and TimeoutOnClose closure/nonreceipt paths; no automatic refund from client freeze.','Implement Lean proofs plus success/refusal/double-terminal mutant/source-independent two-terminal negative; P29 cross-domain accounting remains separate.'],'corrections_and_limits':['Reviewer source-reading membership Active requirement does not establish every packet API fails on frozen status. Root additionally read selected keeper.go351-361 proving source VerifyNonMembership has Active guard too. Neither static check covers NOOP/earlier-guard alternatives universally.','Receipt writes via nested CacheContext are local parent-context writes, not an unconditional durable chain commit or synchronous counterparty rollback. Outer transaction behavior remains an explicit environment obligation.','Refund blocked sender is the original transfer sender and refund recipient; packet wording blocked recipient was ambiguous. Keep exact source variable and operation.','Closeout has six manifest bindings; original root seal binds24 prior files. Four native shells include two timed probe subprocesses and a combined Python identity+observation wrapper. Five report command rows are not five separate native shells.','Original standalone raw Python identity stdout/stderr files are absent; root recovered actual JSON stdout from completed native shell output in separate root evidence. No historical timestamps or streams were fabricated.','C0/C4 abbreviated argv report entries are summaries, not exact executable argv; exact shell text/IDs and output reside in preserved original native events and root native-execution-events.json.','Closeout terminal model/grok-build and completion are root telemetry bindings; author-requested auditor fields elsewhere remain historical.'],'acceptance':False}
put(V/'result.json',result);put(O/'root-adjudication.json',result)
for root in [O,C]:
 with (root/'native.jsonl.gz').open('xb') as out:
  with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((root/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['.lake','private-lean','__pycache__']]
 for name in names:
  path=Path(parent)/name
  if name!='native.jsonl':files[str(path.relative_to(O))]=h(path)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_files':len(files),'input_bindings':56,'manifest_bindings':6,'source_scoped_result':'USABLE','P26_accepted':False}))
