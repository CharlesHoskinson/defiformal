from pathlib import Path
import datetime,gzip,hashlib,json,os,shutil,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p26-source-grok-r1';C=O/'closeout';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox')
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
assert 'Placeholder' in (O/'REVIEW.md').read_text() and read(O/'commands.json')['status']=='draft'
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
put(original/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'native_log_sha256':prev['log_sha256'],'status':'max20turns_substantive_findings_three_placeholder_reports','input_bindings_verified':len(i['files']),'acceptance':False})
C.mkdir(exist_ok=False)
brief=f"Resume SAME independent P26 IBC source-preparation review session {prev['sessions'][0]} for REPORTING CLOSEOUT only. Your20turn audit ended at its cap. verdict.json and findings.json are substantive, but REVIEW.md,commands.json and MANIFEST.json remain placeholders. Root preserved all original outputs under {original}. This is one continuing review, not a fresh second reviewer. All frozen inputs are unchanged. No complete review acceptance yet.\n\nWrite ALL5 finalized files in {C}: REVIEW.md,verdict.json,findings.json,commands.json,self-excluding MANIFEST.json. Parent {O} and sandbox {S} are immutable. Maximum12turns. Use completed inspection and actual parent raw/probes receipts immediately; no new research, searches, builds, probes, downloads, source edits, agents, AGY worktree or cache access. No need to investigate more to close the scoped source review. Include exact path bases for parent artifacts. Preserve failed/missing evidence honestly; don't invent start/end, script/tool hashes or execution. Original identity38checks and30excerpts are source inspection/hash evidence only. Python_identity command has no raw output file; cite original native event if needed, never fabricate one. Finalize reports before cap and stop.\n\nScope is source preparation ONLY, observed official ibc-go commit8a7d8134b7f7cedb3a2809ad3797717f38e44293, not deployed identity. Ordinary duplicates return NOOP,nil before app callback; earlier guards may error. BelowrecvStartSequence and futureordered sequence are actual refusal cases. Retain timeout-on-close path; ordinary timeout maturity/nonreceipt proof requirements, commit consumption, origin-specific conditional refund, blocked sender guard, verified client freeze with no automatic refund, and frozen-client recovery assumptions. Local SDK nested caches are not remote rollback. Preserve selected source and exact cited paths.\n\nAvoid overbroad statement frozen client blocks EVERY recv/timeout/ack: if making claim tie it to paths requiring Active membership/nonmembership verification; NOOP/earlier guards can run first, and omitted nonmembership implementation is not proved by membership anchor alone. Do not strengthen conclusions beyond actually read code. Task27.1 still needs real workflow/observation/assumptions contract and independent review;27.2/3 Lean proof/requiredcampaigns and P29 accounting are open. No invented transaction-error model for ordinary replay. Full roadmap unchanged.\n\nRequestedgrok4.6 high, originalactualgrok-4.6-build. Closeout actual follows native telemetry. Manifest must hash actual immutable files excluding growingcloseoutnative and itself. Record original cap exit1 and separate closeout outcome. No additional investigation; produce concise complete evidence now."

(C/'brief.txt').write_text(brief);started=now();argv=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12']
with (C/'native.jsonl').open('x') as out,(C/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'started_utc':started,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':False,'resumed_session':prev['sessions'][0],'brief_sha256':h(C/'brief.txt'),'scope':'P26 IBC source review reporting closeout','acceptance':False};put(C/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
