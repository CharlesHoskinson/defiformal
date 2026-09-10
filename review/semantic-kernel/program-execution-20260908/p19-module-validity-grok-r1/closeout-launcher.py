from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p19-module-validity-grok-r1';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-validity-grok-r1-sandbox')
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
assert read(O/'verdict.json')['status']=='in_progress' and read(O/'MANIFEST.json')['file_count']==0
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
put(original/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'native_log_sha256':prev['log_sha256'],'status':'max30turns_reports_in_progress_six_commands_built_missing_578_probe','input_bindings_verified':len(i['files']),'acceptance':False})
C.mkdir(exist_ok=False)
brief=f"Resume SAME independent R24 proof-review session {prev['sessions'][0]} for bounded missing axiom probe plus reporting closeout. Original30turn cap terminatedexit1 after six recorded commands. Root preserved original outputs under {original}. This is continuation of same independent reviewer, not another reviewer. AGYR25 remains separate/live; do not inspect it. Frozen sandbox and original parent reports remain immutable; no source edits, network, other agents, extra windows or further broad investigation.\n\nActual original logs show Leanversion/preflight/context exit0 at22:14:40; Roundtrip rebuild22:14:55→58exit0 and Verify22:14:58→22:15:06exit0; sorryanalyzerexit0. Draftreports still falsely say pending compile/preflightfalse. Update finalreports from real receipts, not newtimestamps. Root supplied578probe was prepared but NOTexecuted: originalprobes/axioms578/Axioms.lean and inventory.json exist. Run this one missing proofinventory using completed reviewer private-lean build, then finalize all5reports in {C}. No need rebuild or run unchanged fixtures.12turn cap, spend at most3turns finishing probe, restfinalreports.\n\nUse your own CLOSEOUT recorder/output dirs. Do NOT invoke existing tools/probe_axioms578.py as-is: it writes parentlogs/parsed/modules.json, breaking immutableoriginal. Either copy/adapt recorder/probe into closeout with OUT={C}, PRIVATE={O}/private-lean, and read originalprobe/inventory withoutmodifyingthem; or record one subprocess directly in closeout. Output actualargv/cwd/start/end/exit/tool/probehash/rawstdout/stderr, parsewrappedaxiomlists, exact578names=136+312+130,520std58none expected. Failuresmustbe preserved. Existing6commandlogs remain parentimmutable; modulesummaries frompriorstdoutwriteonlycloseout. No rootexecutionrelabelledreviewer. Probe is source-supplied but your actualrun is fresh reviewerexecution. Finishprobe before sealing commands/MANIFEST.\n\nFinal5files REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json must stateactualscope. R24modulevalidityremovesh_valid; finaltheoremstillh_depth/h_dec/h_lex. ExistingfullEncodeDecodeRoundtripStatementunproved. Classify new28lemmas scopedusable only aftersource/build/probechecks; fullP19CHANGES_REQUIRED. JsonRawordercounterexample remainsvalid. TreeJson.Validdistinctkeys/recursivevalidity/arraybounds, notallkeyssorted. Extra canonical hypotheses on decodeWorld are not themselves a defect ifderivablefromexistingadmission; distinguishprovedcomponentlemmafrommissingcompositionderivation. WholeDocumentDepthBoundedusesjsonDepth(decodedIRToJson), stillneedsbridge toTreeJson.depth.\n\nAuthorMANIFESTcommands.jsonhashstale; rawstreams/probesomitted. All62recordercallsactorAGY;2root_preflightlabelsfalseactorcredit. No99/16closure fromstatusmappings. Count source-manifest bindings fromactualfrozenfile: do notcopy priorbrief15 blindly; source list appears13, root willadjudicateexactcount. No arbitrarygrammarcaps/imagepredicates/sourceorderchanges. Entirecoregoalunchanged.\n\nOriginalactualgrok-4.6-build; closeoutactualfollowsnative telemetry. Bindfinalreports and actual immutableparent/probe/raw references with explicitpathbases. Excludegrowingcloseoutnative/privatecache. Completefivefilesandcollectchildrenbeforeending. Rootverifiesadjudicatespublishes."

(C/'brief.txt').write_text(brief);started=now();argv=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12']
with (C/'native.jsonl').open('x') as out,(C/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'started_utc':started,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':False,'resumed_session':prev['sessions'][0],'brief_sha256':h(C/'brief.txt'),'scope':'R24 proof review missing578probe and reporting closeout','acceptance':False};put(C/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
