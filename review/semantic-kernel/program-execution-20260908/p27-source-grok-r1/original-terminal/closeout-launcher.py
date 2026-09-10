from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p27-source-grok-r1';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox')
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
assert read(O/'MANIFEST.json')['status']=='draft' and len(read(O/'MANIFEST.json').get('files', []))==0
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
put(original/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'native_log_sha256':prev['log_sha256'],'status':'max30turns_substantive_four_reports_manifest_still_empty','input_bindings_verified':len(i['files']),'acceptance':False})
C.mkdir(exist_ok=False)
brief=f"Resume SAME independent P27 GMX review session {prev['sessions'][0]} for REPORTING CLOSEOUT ONLY. The30turn audit ended at cap. REVIEW.md/verdict/findings/commands contain substantive final material, but MANIFEST.json remains draft with0bindings. Root froze originals under {original}. You are the same continuing reviewer, not a new independent review. Originalactualmodelgrok-4.6-build.\n\nWrite all5 finalized files to {C}: REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Copy the four completed originalreports with minimal necessary metadata/path-base corrections and finalize the manifest. Parent {O}, originalsnapshot andsandbox {S} are immutable. No new source investigation, searches, compiler/EVM/tests, identity/observation probes, AGY files/caches, downloads, subagents, Foreman, windows, branches or commits. Maximum8turns; these reports already contain your findings. Finalize immediately from original evidence and stop.\n\nRetain usable source-preparation-only verdict, P27/tasks28.1-3 unaccepted. Preserve actual pin a85ea3491c19c93bb4b5a002d9b358fb769b7849,91source/243selectedlexicaledges,91contracts72nonemptycreationobjects10unresolvedlinks.106identitychecks and12excerpts are source/hash probes, not compiler/runtime execution. The compilerbaseline is root's prior execution, not yours. Keep scalar PnL/health/collateral distinctions, unsignedfundingfee vs separateclaimables/directionalrounding, actual healthy-liquidation and ordinary-unpaidcost refusals, allowedfullclose liquidation/secondaryADL exceptional success, explicit source-rounded residual andnoautomaticinsurance.\n\nCommands report3recorded probes; distinguish wrapper argv from inner subprocess argv in raw/*.command.json. Python_identity has no separatelysavedrawstdout; if necessaryciteoriginalnativejsonl.gz rather thaninvent a logfile. Its owncommandreceipt ispresent. Preserve exact actualtimestamps, tool/script/sourcehashes andscope. Parent command outcomes areall0 while original nativeprocessendedcapexit1. No extra proof credit fromexitstatus.\n\nManifest: allcloseoutimmutable reports/probes (if any), plus explicit immutable_parent_bindings to the originalreports/probes/rawreceipts/rawstreams you rely on. Exclude the manifestitself andgrowingnative logs. Include path bases, actualhashes andbytes. Do notwriteparent. Do notrerun original scripts: they hardcodeparentoutput paths. Mark completed reporting accurately; do notinventexecutionorclosewholefamily. Record anyremaininguncertainty honestly."

(C/'brief.txt').write_text(brief);started=now();argv=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','8']
with (C/'native.jsonl').open('x') as out,(C/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'started_utc':started,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':False,'resumed_session':prev['sessions'][0],'brief_sha256':h(C/'brief.txt'),'scope':'P27 GMX source review reporting closeout','acceptance':False};put(C/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
