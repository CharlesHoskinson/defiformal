from pathlib import Path
import json,hashlib,gzip,datetime,os,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p27-source-grok-r1';C=O/'closeout';F=O/'original-terminal';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox');V=O/'root-verification-attempt2';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
p=read(C/'process.json');original=read(F/'process.json');assert p['process_exit']==original['process_exit']==1 and p['sessions']==original['sessions'] and p['reported_models']==original['reported_models']==['grok-4.6-build'];assert not Path('/proc',str(read(C/'dispatch.json')['pid'])).exists()
for q in Path('/proc').iterdir():
 if not q.name.isdigit():continue
 try:cwd=str((q/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(q.name,cwd)
assert h(C/'native.jsonl')==p['log_sha256'] and h(O/'native.jsonl')==original['log_sha256'];V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py')
inputs=read(F/'inputs.json')
for name,d in inputs['files'].items():assert h(S/name)==d,name
for name,d in read(F/'root-seal.json')['files'].items():
 assert h(F/name)==d,name
 if name!='native.jsonl.gz':assert h(O/name)==d,name
m=read(C/'MANIFEST.json');assert len(m['files'])==m['file_count']==6 and len(m['immutable_parent_bindings'])==m['immutable_parent_binding_count']==19 and m['self_excluding']
for name,row in m['files'].items():assert h(C/name)==row['sha256'] and (C/name).stat().st_size==row['bytes'],name
for name,row in m['immutable_parent_bindings'].items():
 q=Path(row['path']);assert q.is_relative_to(F);assert h(q)==row['sha256'] and q.stat().st_size==row['bytes'],name
 if name!='root-seal.json':assert row['sha256']==row['original_root_seal_sha256'],name
verdict=read(C/'verdict.json');assert verdict['verdict']=='usable' and not verdict['P27_accepted'] and not verdict['task_28_1_accepted'];assert len(read(C/'commands.json')['commands'])==3 and len(read(C/'findings.json')['findings'])==10
for n in ['REVIEW.md','verdict.json','findings.json','commands.json','MANIFEST.json']:assert (C/n).stat().st_size>100
bindings=B/'p27-source-review-root-bindings';bs=read(bindings/'root-seal.json')
for name,d in bs['files'].items():assert h(bindings/name)==d,name
br=read(bindings/'result.json');assert br['frozen_input_bindings']==252 and br['root_actual_control_rejected'] and not br['reviewer_altered_control_gate_credit']
events=[json.loads(x) for x in (C/'native.jsonl').read_text().splitlines() if x.startswith('{')];calls=[e for e in events if e.get('type')=='tool_call'];shell=[e for e in calls if e.get('kind')=='execute'];put(V/'closeout-native-calls.json',{'calls':shell,'updates':[e for e in events if e.get('type')=='tool_call_update' and e.get('toolCallId') in {c['toolCallId'] for c in shell}]})
result={'utc':now(),'status':'completed_root_verified','frozen_input_bindings':252,'original_terminal_files':24,'closeout_manifest_bindings':6,'immutable_parent_bindings':19,'original_native_exit':1,'original_max_turns':30,'closeout_native_exit':1,'closeout_max_turns':8,'same_session':p['sessions'][0],'reported_models':p['reported_models'],'all_five_final_reports_complete':True,'original_native_probe_shells':3,'original_probe_records':3,'root_replayed_identity_assertions':106,'root_bound_source_excerpts':12,'root_extra_source_excerpts':2,'root_actual_altered_byte_control_rejected':True,'reviewer_control_gate_credit':False,'closeout_native_shell_calls':len(shell),'scope':'Source/dependency/compiler preparation usable, with corrected negative-control attribution. P27 workflow/proofs/campaigns remain open.','P27_accepted':False};put(V/'result.json',result)
adj={**result,'corrections':['Both native runs ended at their turn caps; all five final reports and six closeout/nineteen immutable parent bindings are complete. No further reporting closeout needed.','Reviewer altered-byte block does not exercise a binding validator; no negative gate-test credit. Root actual validator accepted89intact sources and rejected a same-length changed byte, preserving disk sources.','Original Python identity has no standalone stdout file. Its receipt and actual native event are retained, not a fabricated raw stream. Other two probe raw streams match receipts.','The first closeout hash shell raised NameError from JSON true in Python. Original native telemetry preserves it; successful second hash shell produced the manifest. No source/compiler/runtime execution in closeout.','106identity assertions and12excerpts are source/hash evidence;91contract compile is prior root execution. Source pin is not deployed identity, and10objects retain unresolved library links.','Liquidation health includes signed PnL while collateral sufficiency excludes positive PnL. Funding liability/claimables have distinct direction/rounding/keys. Actual healthy-liquidation and ordinary-unpaidcost refusals differ from allowed full-close liquidation/secondaryADL exceptional success. Residual events do not establish insurance or exact rational settlement.'],'remaining':verdict['remaining_explicit_obligations'],'root_binding_verification':'p27-source-review-root-bindings/root-seal.json','root_binding_verification_sha256':h(bindings/'root-seal.json'),'full_P27_accepted':False};put(O/'root-adjudication.json',adj)
for root in [O,C]:
 with (root/'native.jsonl.gz').open('xb') as f:
  with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((root/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  q=Path(parent)/name
  if name!='native.jsonl':files[str(q.relative_to(O))]=h(q)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_files':len(files),**result}))
