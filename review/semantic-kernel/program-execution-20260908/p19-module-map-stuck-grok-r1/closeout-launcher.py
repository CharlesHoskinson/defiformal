from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p19-module-map-stuck-grok-r1';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-map-stuck-grok-r1-sandbox')
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
prev=read(O/'process.json');dispatch=read(O/'dispatch.json');assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==20 and len(prev['sessions'])==1
assert not Path('/proc',str(dispatch['pid'])).exists() and h(O/'native.jsonl')==prev['log_sha256']
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(p.name,cwd)
i=read(O/'inputs.json')
for name,digest in i['files'].items():assert h(S/name)==digest,name
assert all(not (O/n).exists() for n in ['REVIEW.md','verdict.json','findings.json','commands.json','MANIFEST.json'])
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
put(original/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'native_log_sha256':prev['log_sha256'],'status':'max20turns_no_final_artifacts_no_verdict','input_bindings_verified':len(i['files']),'acceptance':False})
C.mkdir(exist_ok=False)
brief=f'''Resume SAME independent frozen R22 stuck-review session {prev['sessions'][0]} for REPORTING CLOSEOUT. Your20-turn review terminated at its cap without any of the5 required reports. Root preserved original native output and input bindings under {original}. Your source reading remains evidence; there is no completed verdict yet. This is a continuation of one independent review, not another reviewer.

Write all5 FINAL files under {C}: REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Parent {O} and sandbox {S} remain immutable. Maximum12turns: produce the reports immediately using your completed inspection. No new searches, builds, probes, source edits, network, agents or AGY-worktree access. No need to resolve every mathematical question to report a scoped diagnosis. Mark untested repair suggestions as untested; do not manufacture Lean execution, timestamps or counterexamples. commands.json may explicitly contain no compiler commands if none ran; original native read/search calls can be identified separately with native toolCallId and source path, not invented shell argv/start/end.

Scope: root's3 scratch runs failed with12/4/4 errors; this is root evidence, not your compiler run. R22 production unchanged from R21. Full supported-module theorem remains open and generic serialized TreeJson inverse is prior reviewed work. Report actionable causes for capabilityIds coercion/List.flatMap vs map, JsonNumber.fromNat normalization, Json.mkObj equality with different field order, malformed TypesEnum syntax, missing helper identifiers and heartbeat expansion. Include exact source/line/library references only where verified by your inspection. Distinguish confirmed source reasoning from prospective Lean tactics. Do not claim all object representations equal merely from JSON semantic order-insensitivity: inspect actual Lean representation requirements; if unfinished, say so.

Report the unsupported-tag statement issue with precise scope: encodeStep interpolates unsupported tag text while TreeJson escapes; if no diagnostic was run, call it source-level mismatch evidence, not executed counterexample or supported-input bug. New helper hypotheses must follow existing supported admission; no narrowing public grammar, parser-success premise or replacement codec. FullP19 CHANGES_REQUIRED. Preserve production signatures and full resource grammar. Remaining map/validity/depth/scanner and overlay/decodedIR/host/campaign obligations are still open.

Requestedmodelgrok-4.6 high, original actualgrok-4.6-build, sameSID{prev['sessions'][0]}; closeout actual identity follows terminal telemetry. Bind final reports plus exact frozen input/native or source references with explicit path bases. Exclude growing closeout native stream and private build cache; never invent placeholder hashes. Collect any children and finish after all5 files exist with finalized verdict.'''

(C/'brief.txt').write_text(brief);started=now();argv=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12']
with (C/'native.jsonl').open('x') as out,(C/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'started_utc':started,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':False,'resumed_session':prev['sessions'][0],'brief_sha256':h(C/'brief.txt'),'scope':'R22 module-map stuck review reporting closeout','acceptance':False};put(C/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
