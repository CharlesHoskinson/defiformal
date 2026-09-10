from pathlib import Path
import json,hashlib,gzip,datetime,os,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p25-source-grok-r1';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=datetime.datetime.now(datetime.timezone.utc).isoformat();assert not (O/'root-seal.json').exists();assert not Path('/proc/2195873').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) and name in ['solc','grok','node']), (p.name,name,cwd)
proc=read(O/'process.json');assert proc['process_exit']==1 and proc['terminal_events'][-1]['num_turns']==25;assert proc['reported_models']==['grok-4.6-build'];assert proc['sessions']==['01a08cdf-7d59-7153-ad16-afeb3b229230'];assert h(O/'native.jsonl')==proc['log_sha256'];m=read(O/'MANIFEST.json')
for row in m['files']+m['references']:assert h(O/row['path'])==row['sha256']
for dn in ['root-verification','root-verification-attempt2','root-verification-attempt3']:
 for name,digest in read(O/dn/'root-seal.json')['files'].items():assert h(O/dn/name)==digest
with (O/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
a=read(O/'root-verification-attempt3/assessment.json');v=read(O/'verdict.json');assert v['verdict']=='USABLE' and not v['acceptance'];assert a['compiler_input_stdout_stderr_byte_equal_frozen'] and a['four_overstrict_predicates_independently_resolved']
record={'schema':'defiformal-p25-source-review-root-adjudication/v1','utc':now,'decision':'USABLE_SCOPED_SOURCE_AND_COMPILER_PREPARATION_WITH_REVIEW_CORRECTIONS','requested_model':'grok-4.6','effort':'high','reported_models':proc['reported_models'],'sessions':proc['sessions'],'native_exit':1,'terminal_reason':'25turncap_allfive_reports_complete','independent_review_count':1,'input_bindings':175,'manifest_bindings':16,'reviewer_commands_verified':2,'reviewer_raw_stream_bindings':4,'source_members':78,'selected_compiler_sources':98,'selected_import_edges':308,'compiler_contracts':96,'compiler_bytecode_outputs':44,'compiler_errors':0,'compiler_warnings':4,'compiler_input_stdout_stderr_match_root_frozen':True,'root_verification':'root-verification-attempt3/root-seal.json','failed_root_attempts':['root-verification/root-seal.json','root-verification-attempt2/root-seal.json'],'review_test_count_correction':a['review_reference_test_count_correction'],'review_oz_path_correction':a['oz_path_wording_correction'],'root_failed_receipt_note_correction':a['root_attempt1_correction'],'initial_reviewer_failure_receipt_limit':a['first_python_wrapper_failure_limit'],'failed_reviewer_predicates':'Original26/30 probe summary preserved. Four wrong predicates (testscope/symlink traversal/npmdocument/count-versus-bool) are not source packet defects; rootchecked concrete corrected facts with reference-test qualification.','compiler_scope':'Actual direct0.8.27 standard-json/noIR/optimizer999/Cancun reproduction, not fullForge or Hardhat build or EVM execution. Hardhat viaIR0.8.26/500 Vault overrides remain separate.','next_obligations':['AGY freezes actual P25 cash/reserve/signeddelta/pool/fee/excesstoken and hook-revert observation contract; independent review of that contract.','Implement SharedVault model/accounting/rollback proof; run join success, hook-revert refusal, publish-on-revert and independent conservation-break negatives.','Resolve actual selected build profile/runtime/source correspondence; retain token/Permit2/compiler/EVM assumptions and reference-test dependency boundary.'],'task_26_1_accepted':False,'task_26_2_accepted':False,'task_26_3_accepted':False,'P25_accepted':False,'whole_program_complete':False}
put(O/'root-adjudication.json',record);shutil.copy2(__file__,O/'root-seal-verify.py');files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[x for x in dirs if x not in ['__pycache__','.lake']]
 for name in names:
  p=Path(parent)/name
  if name=='native.jsonl' or p==O/'root-seal.json':continue
  assert p.is_file() and not p.is_symlink();files[str(p.relative_to(O))]=h(p)
put(O/'root-seal.json',{'utc':now,'files':files,'file_count':len(files),'manifest_bindings':16,'acceptance_scope':'Source/compiler preparation only','P25_accepted':False});print(json.dumps({'sealed_files':len(files),'manifest_bindings':16,'decision':record['decision']}))
