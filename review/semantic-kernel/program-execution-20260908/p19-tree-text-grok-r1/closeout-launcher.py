from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p19-tree-text-grok-r1';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-tree-text-grok-r1-sandbox')
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
prev=read(O/'process.json');dispatch=read(O/'dispatch.json');assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==30 and len(prev['sessions'])==1
assert not Path('/proc',str(dispatch['pid'])).exists() and h(O/'native.jsonl')==prev['log_sha256']
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(p.name,cwd)
i=read(O/'inputs.json')
for name,digest in i['files'].items():assert h(S/name)==digest,name
assert read(O/'verdict.json')['status']=='in_progress'
original=O/'original-terminal';original.mkdir(exist_ok=False)
for root,ds,fs in os.walk(O):
 ds[:]=[d for d in ds if d not in ['original-terminal','closeout','private-lean','.lake','__pycache__']]
 for name in fs:
  p=Path(root)/name
  if name=='native.jsonl':continue
  q=original/p.relative_to(O);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
with (original/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
files={str(p.relative_to(original)):h(p) for p in original.rglob('*') if p.is_file()}
put(original/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'native_log_sha256':prev['log_sha256'],'status':'max30turns_all_five_reports_in_progress_no_verdict','input_bindings_verified':len(i['files']),'acceptance':False})
C.mkdir(exist_ok=False)
brief=f'''Resume SAME independent R21 TreeJson text-parser review session {prev['sessions'][0]} for completion of the reports. Your original 30-turn attempt hit its cap; all five report files exist only as IN_PROGRESS placeholders. Root preserved every immutable original artifact and compressed native stream under {original}, with a root seal. This is one continued independent audit, not a new reviewer.

Write all five FINAL artifacts only under {C}: REVIEW.md, verdict.json, findings.json, commands.json and self-excluding MANIFEST.json. Parent output {O}, original-terminal snapshot and source sandbox {S} remain immutable. Read your existing completed evidence and finish any needed direct inspection of frozen proof source. No new builds/probes/source edits/network/subagents/Foreman or author-worktree inspection. Maximum12turns, prioritize completing all five reports. No additional verification command is needed merely to finish reporting.

Existing logs/command-index.jsonl and logs/*/meta.json/stdout/stderr record nine commands. Reconstruct commands.json faithfully from those exact original receipts and record any fields absent as absent/unknown, not synthesized historic times. The actual build target was Correspondence: six certificate modules Built, Schema/Typed.Transition Replayed,932jobs, exit0. Soundness/Tests/Verify/Audit were not rebuilt. Root has not yet adjudicated your final review.

Probe448 records 448 exact explicit theorem/lemma names (136 CanonicalJson +312 Correspondence),415 standard-axiom and33 zero-axiom, no forbidden reported. Root's prior inventory has equal name/axiom pairs. The stdout hashes differ because your probe has a set_option line; examine actual content before explaining the difference. Keep explicit declarations distinct from generated constants/definitions. Include lemma exprDepth_pos and dotted TreeJson names. Failed-probes/lake-rebuild-import-error.json preserves a setup Python import error before recorder entry, with no raw command timestamps/streams; don't invent them or credit a build for that attempt. Inline axiom helper completeness must be reported accurately from actual raw result, not defaulted from a claimed count.

R21 adds30theorems plus NonDigitHead and appends general tokenizer/fuel/length/parser proofs to CanonicalJson. Old prefix and other production source remain R20. Generic tokenize_tree and parseCanonicalJson_tree prove serialized TreeJson text inversion under explicit validity/depth conditions; do not mislabel this only token-level. Review suffix constraints, length/fuel induction and child hypotheses derived in main theorem. Production whole-module encodeModule representation and scanLexical success remain open; EncodeDecodeRoundtripStatement is still a Prop definition, h_lex/h_parse remain assumed. FullP19 is not accepted by a generic TreeJson result. Tree depth64 must later come from wholeIR admission; packedValueToTreeJson is inner payload, not production unit/value wrapper. Preserve full supported resource domain.

R21 author report directory was absent, native SUCCESS/exit0 had repeated waiting messages and97 command observations are not raw per-command receipts. No R21 author build/test count can be inferred. Your fresh isolated build/probe evidence is separate and should receive its own scope. No7/21/54/99/16 new campaign credit. No production source or review is accepted merely due CLI exit. Requested grok-4.6 high, original terminal actual grok-4.6-build, same session{prev['sessions'][0]}. Future closeout actual identity follows terminal telemetry.

Manifest must bind all final report/probe/raw evidence including relevant ../logs, ../probes, ../tools and ../failed-probes paths with explicit closeout-relative resolution. Exclude growing native/private build cache. Do not list placeholder hashes or zero bytes for real files. End after all five final files are complete. State scoped usable/changes-required on the generic text inverse, fullP19 remaining obligations and any new concrete finding without invented blocker.
'''
(C/'brief.txt').write_text(brief);shutil.copy2(__file__,O/'closeout-launcher.py');started=now();argv=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12']
with (C/'native.jsonl').open('x') as out,(C/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'started_utc':started,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':False,'resumed_session':prev['sessions'][0],'brief_sha256':h(C/'brief.txt'),'scope':'R21 TreeJson text inverse review reporting closeout','acceptance':False};put(C/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (C/'native.jsonl').read_text().splitlines():
 try:event=json.loads(line)
 except json.JSONDecodeError:continue
 models.update(event.get('modelUsage',{}))
 if event.get('model'):models.add(event['model'])
 for key in ['sessionId','session_id']:
  if event.get(key):sessions.add(event[key])
 if event.get('type') in ['end','error','result']:terminal.append(event)
result={'started_utc':started,'finished_utc':now(),'process_exit':code,'reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':h(C/'native.jsonl'),'terminal_events':terminal,'acceptance':False};put(C/'process.json',result);print(json.dumps({k:v for k,v in result.items() if k!='terminal_events'}),flush=True)
