from pathlib import Path
import json,hashlib,gzip,datetime,os,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-recursive-token-grok-r1';R=O/'root-verification';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=datetime.datetime.now(datetime.timezone.utc).isoformat();assert not (O/'root-seal.json').exists();assert not Path('/proc/2163507').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) and name in ['lean','lake','grok','node']), (p.name,name,cwd)
proc=read(O/'process.json');assert proc['process_exit']==1 and proc['terminal_events'][-1]['num_turns']==35;assert proc['reported_models']==['grok-4.6-build'];assert proc['sessions']==['01a08cc6-e0bd-7153-8430-fed4b19e7455'];assert h(O/'native.jsonl')==proc['log_sha256']
for row in read(O/'MANIFEST.json')['files']:assert h(O/row['path'])==row['sha256']
for name,digest in read(R/'root-seal.json')['files'].items():assert h(R/name)==digest
with (O/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
a=read(R/'assessment.json');verdict=read(O/'verdict.json');assert verdict['verdict']=='CHANGES_REQUIRED' and not verdict['acceptance']
record={'schema':'defiformal-p19-r20-root-adjudication/v1','utc':now,'decision':'PARTIAL_GENERAL_TOKEN_INVERSE_CONFIRMED_FULL_P19_CHANGES_REQUIRED','requested_model':'grok-4.6','effort':'high','reported_models':proc['reported_models'],'sessions':proc['sessions'],'native_process_exit':1,'terminal_reason':'35-turn cap; all five final reports complete, no report closeout required','independent_review_count':1,'candidate_archive_sha256':'068e57d0d389306887276a6cbd2193d60a30f6daf0508e7db223730c3edb5b6a','manifest_bindings':46,'input_bindings':3884,'reviewer_commands_verified':8,'reviewer_raw_stream_bindings':16,'author_raw_stream_bindings':18,'root_replay':'root-verification/root-seal.json','theorem_lemma_count':418,'theorem_lemma_standard':390,'theorem_lemma_none':28,'including_16_defs':434,'all_standard':391,'all_none':43,'root_probe_stdout_byte_equal_reviewer':True,'new_proof':'General bounded TreeJson token inverse by size recursion and arbitrary Expr token inverse connected to production encodeExpr. Child success is derived, not assumed.','remaining':'General lexer inverse of emitted bytes, whole envelope/module representations and scanner admission from unchanged StructurallyAdmissibleIR. Main EncodeDecodeRoundtripStatement remains Prop and h_lex/h_parse success premises remain.','new_author_guidance':a['new_scope_cautions'],'review_report_rebuild_correction':a['review_report_correction'],'actual_rebuilt_modules':a['rebuilt_modules'],'failed_inline_helper_zero_credit':a['failed_inline_axiom_helper'],'identity_note':'Reviewer returned_model unknown in written report is preserved; terminal native metadata binds grok-4.6-build.','old_report_corrections':'75 new theorem/lemma declarations plus16defs, not91newtheorems; actual434 counts391standard43none, not422/12; rawVerify Certificates1659/2686; R20cons_cons fixes notR19; packedValue inner payload lacks production wrapper encode/valid.','P19_accepted':False,'P20_accepted':False,'whole_program_complete':False}
put(O/'root-adjudication.json',record);shutil.copy2(__file__,O/'root-seal-verify.py');files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name=='native.jsonl' or p==O/'root-seal.json':continue
  assert p.is_file() and not p.is_symlink();files[str(p.relative_to(O))]=h(p)
put(O/'root-seal.json',{'utc':now,'files':files,'file_count':len(files),'manifest_bindings':46,'acceptance':False});print(json.dumps({'sealed_files':len(files),'manifest_bindings':46,'decision':record['decision']}))
