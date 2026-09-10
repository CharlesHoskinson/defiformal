from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-tree-text-grok-r1';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();read=lambda p:json.loads(p.read_text())
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2218999').exists() and not Path('/proc/2244055').exists();a=read(O/'root-verification/assessment.json');assert a['root_probe_stdout_byte_equal_reviewer'] and a['source_theorem_lemma_count']==448
process=read(O/'closeout/process.json');assert process['process_exit']==0 and h(O/'closeout/native.jsonl')==process['log_sha256']
with (O/'closeout/native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((O/'closeout/native.jsonl').read_bytes())
put(O/'root-adjudication.json',{'utc':now(),'decision':'PARTIAL_GENERAL_SERIALIZED_TEXT_INVERSE_CONFIRMED_FULL_P19_CHANGES_REQUIRED','candidate_archive_sha256':'41726f194c0d3640a32bddf32b31ce83e81cc5ba92be657fcb68f57deac571d4','native_requested_model':'grok-4.6','native_original_and_closeout_reported_model':'grok-4.6-build','native_same_session':process['sessions'][0],'original_exit':1,'original_stop':'max30turns_reports_in_progress','closeout_exit':0,'review':'closeout/REVIEW.md','manifest_bindings':48,'verification':'root-verification/assessment.json','strongest_result':'General tokenize_tree and parseCanonicalJson_tree invert actual TreeJson.encode String text; main induction derives child success.','full_P19_remaining':['Whole production module representation/validity/depth from unchanged structural admission.','scanLexical production byte success and proof of existing EncodeDecodeRoundtripStatement.','All remaining P19 overlay, expected decoded IR, host/tool identity and full54/99/16 evidence obligations.'],'report_corrections':['commands.json raw logs/... paths resolve from the parent review directory; MANIFEST correctly uses ../logs paths. Original command fields are retained exactly.','Root closeout brief set_option explanation was incorrect. The three #eval marker lines account for the entire stdout difference, correctly identified in final Grok review.'],'failed_evidence_retained':['Original cap30 reports are IN_PROGRESS, not a verdict.','CanonicalJson inline helper only86of157resolved,exit1; successful448probe supplies exactnamed inventory.','Initial recorder import failed before raw timestamps/streams existed.','Original root archive check wrongly looked for build config in candidate tar; separate immutable input bindings resolve all3configs.'],'future_review_efficiency':'After a fresh affected-module build, use a complete explicit #print axioms inventory. Do not repeat the known incomplete CanonicalJson inline helper or an expensive redundant Correspondence helper without a new concrete concern.','P19_accepted':False,'whole_program_complete':False})
shutil.copy2(__file__,O/'root-seal-builder.py')
files={}
for root,ds,fs in os.walk(O):
 ds[:]=[d for d in ds if d not in ['private-lean','.lake','__pycache__']]
 for name in fs:
  p=Path(root)/name
  if name=='native.jsonl' or p==O/'root-seal.json':continue
  assert not p.is_symlink();files[str(p.relative_to(O))]=h(p)
put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'manifest_bindings_verified':48,'P19_accepted':False});print(json.dumps({'sealed_files':len(files),'manifest_bindings':48,'root_named_axioms':448,'P19_accepted':False}))
