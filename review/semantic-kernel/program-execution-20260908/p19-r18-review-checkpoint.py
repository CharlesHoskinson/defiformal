from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908'
read=lambda p:json.loads(p.read_text())
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,j:p.write_text(json.dumps(j,indent=2)+'\n')
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
a=read(b/'p19-roundtrip-proof-agy-r19-dispatch.json');d=read(b/'p31-zkir-source-grok-r1/dispatch.json')
assert Path('/proc',str(a['pid'])).exists() and Path('/proc',str(d['pid'])).exists()
a['root_supervisor_handle']=73846;d['root_supervisor_handle']=15242
s=read(b/'STATE.json');s['updated_utc']=now;s['phase']='AGY_R19_running_Grok_P31_ZKIR_source_review_running';s['native_author_handle']=73846
p=s['p19'];p['previous_implementation_dispatch_r18']={**p['implementation_dispatch'],'status':'terminal_frozen_root_prechecked_pending_independent_review','process_exit':0,'reported_models':['gemini-3.8-flash-high'],'conversation_id':'e796eaea-c10e-4792-8493-1acd9d61a313'}
p['implementation_dispatch']=a;p['phase']='R18_partial_scanner_repair_frozen_R19_recursive_parser_and_remaining_precedence_repair_running'
p['rational_inverse_review'].update({'status':'terminal_root_sealed_CHANGES_REQUIRED','process_exit':1,'closeout_process_exit':0,'reported_models':['grok-4.6-build'],'sessions':['01a08c6a-ab6b-7cd2-8fbb-b059a7adfde9'],'root_seal':'p19-rational-inverse-grok-r1/root-seal.json','root_adjudication':'p19-rational-inverse-grok-r1/root-adjudication.json','root_named_check':299,'new_r17_theorems':29,'acceptance':False})
p['agy_r17_partial']['new_theorems']=29;p['agy_r17_partial']['count_correction']='exprDepth_pos predatesR17; oldR16 theorem-only269 omitted this existing lemma.'
p['agy_r18_partial']={'manifest':'p19-roundtrip-proof-agy-r18-terminal-manifest.json','archive_sha256':read(b/'p19-roundtrip-proof-agy-r18-terminal-manifest.json')['sha256'],'file_count':3527,'root_precheck':'p19-roundtrip-proof-agy-r18-root-precheck.json','named_declarations':311,'standard_axioms':299,'zero_axioms':12,'new_theorems':12,'root_controls':'p19-r18-root-controls/root-seal.json','six_mixed_error_cases_restored':True,'c0_controls_match':True,'remaining_precedence_final_failure_changes':2,'acceptance':False}
p['r18_freeze_preparation']['status']='terminal_frozen_root_prechecked'
p['r19_freeze_preparation']={'script':'p19-roundtrip-proof-agy-r19-freeze.py','status':'prepared_wait_for_terminal_and_children_collected'}
p['precedence_repair_review_preparation']=read(b/'p19-precedence-repair-review-preparation.json')
p['unterminated_precedence_regression']={'record':'p19-r18-unterminated-precedence-finding.json','cases':2,'status':'required_repair_delivered_to_R19','brief_sha256':a['brief_sha256'],'acceptance':False}
p['error_precedence_regression']['r18_six_case_status']='root_verified_restored; separate unterminated precedence finding remains'
p['next_author_focus']='R19 repairs two unterminated-string whitespace precedence cases and develops full recursive parser/scanner inversion; finite component inverses do not close the universal statement.'
s['p31']['zkir_source_review_preparation']['status']='dispatched'
s['p31']['zkir_source_review']=d
s['independent_reviewer']=d
s['continuation_loop'].update({'native_author_status':'P19_R19_running','native_reviewer_status':'P31_ZKIR_source_review_running','observed_utc':now})
s['next_actions']=['Poll AGY R19 supervisor73846 and P31 ZKIR source reviewer15242; do not duplicate live jobs.','After P31 terminal, verify exact source/release/artifact scope and seal review; launch prepared fresh R18 precedence review.','After R19 terminal, collect children, freeze using prepared helper, verify actual recursive proofs and all scanner regressions; preserve evidence without wholeP19 acceptance.','Continue full core roadmap; P33 entry packet prepared, P32 five environment pin gaps and P34 remain open. Atlas stays parked.']
write(b/'STATE.json',s)
cp=r/'review/semantic-kernel/strategy-audit-20260908/CURRENT.json';c=read(cp)
c.update({'updated_utc':now,'current_task':'AGY R19 universal recursive codec proof and remaining scanner precedence repair; Grok P31 ZKIR source review','process_liveness':f'Observed {now}: AGY73846 PID{a["pid"]} and Grok15242 PID{d["pid"]} present. R18 author7649 terminal and frozen; R17 reviewer10078 plus30323 closeout terminal and root sealed.','review_capacity':'Sole fresh Grok P31 ZKIR source/interface review running. Prepared R18 candidate review follows.'})
write(cp,c)
shutil.copy2(__file__,b/'p19-r18-review-checkpoint.py')
paths=[]
for name in ['p19-rational-inverse-grok-r1','p19-r18-root-precheck','p19-r18-root-controls']:
 o=b/name;seal=read(o/'root-seal.json')
 for n,digest in seal['files'].items():assert h(o/n)==digest,n;paths.append(o/n)
 paths.append(o/'root-seal.json')
for n in ['STATE.json','p19-r18-review-checkpoint.py','p19-roundtrip-proof-agy-r18-root-precheck.json','p19-r18-unterminated-precedence-finding.json','p19-roundtrip-proof-agy-r18-terminal-manifest.json','p19-roundtrip-proof-agy-r18-terminal.tar.gz','p19-roundtrip-proof-agy-r18-terminal-scratch.tar.gz','p19-roundtrip-proof-agy-r18-native-init.json','p19-roundtrip-proof-agy-r18-native.jsonl.gz','p19-roundtrip-proof-agy-r18-process.json','p19-roundtrip-proof-agy-r19-launcher.py','p19-roundtrip-proof-agy-r19-freeze.py','p19-roundtrip-proof-agy-r19-brief.txt','p19-roundtrip-proof-agy-r19-dispatch.json','p19-precedence-repair-grok-r1-launcher.py','p19-precedence-repair-review-preparation.json','p31-zkir-source-grok-r1/inputs.json','p31-zkir-source-grok-r1/brief.txt','p31-zkir-source-grok-r1/dispatch.json']:paths.append(b/n)
paths.append(cp);paths=sorted(set(paths))
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).strip()
assert all(p.is_file() for p in paths)
assert not any(p.name=='AGENDA.md' or '.lake' in p.parts or p.name=='native.jsonl' for p in paths)
subprocess.run(['git','add','--']+[str(p.relative_to(r)) for p in paths],cwd=r,check=True)
print(json.dumps({'staged_files':len(paths),'observed_utc':now,'author_handle':73846,'review_handle':15242}))
