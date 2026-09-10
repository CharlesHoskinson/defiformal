from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p31-zkir-artifact-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-artifact-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==20;assert not Path('/proc/1927454').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and name in ['lean','lake','grok','node']),(p.name,name,cwd)
i=json.loads((o/'inputs.json').read_text())
for n,v in i['files'].items():assert h(s/n)==v,n
c.mkdir(exist_ok=False);reports=['verdict.json','findings.json','commands.json']
for n in reports:shutil.copy2(o/n,c/n)
with (o/'attempt1-native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max20_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['REVIEW.md','MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"""Resume SAME independent P31 ZKIR artifact review session {prev['sessions'][0]}. Initial20turn process terminated exit1 at cap after verdict.json/findings.json/commands.json. REVIEW.md and MANIFEST.json are missing. Root preserved all originals and copied those3 reports byte-identically to {c}. REPORTING-ONLY CLOSEOUT, at most8turns. All writes only under {c}. No new probes/builds/network/subagents/source edits. Do not inspect active AGY work. Do not rewrite the3 copied reports or parent evidence.
Create REVIEW.md summarizing the existing verdict/findings and explicit limitations. Create self-excluding MANIFEST.json hashing these4 reports and all relevant immutable ../replay files, including raw stdout/stderr, command receipts, copied ZKIR inputs and bzkir outputs, materialized sources and identity records. Paths resolve from closeout. Exclude growing native logs and caches. No execution invention; incomplete command metadata stays incomplete. Parent report returned_model says grok-4.6; root native terminal shows actual grok-4.6-build. State this distinction in REVIEW.md without changing original reports. Fixed report utc fields are author metadata, not substitutes for per-command captured times. Commands.json brief-sha256 entry labels the brief content hash stdout_sha256; disclose that it is a content identity, not an observed raw stdout digest.
Scope remains usable artifact/interface preparation, not constraint soundness/source-to-ledger correspondence or adapter32.7/fullP31 acceptance. Preserve separately accepted readiness32.1-32.4. record0/record1 snapshot wrapper circuits differ from pure transition0/transition1; skip-zk and mock output imply no real keys/proofs/ledger execution. Review observed97input hashes,33source identities,nine rematerialized files,two valid and3negative mock controls; root independently verifies. A CLOSEOUT.md may disclose missing reporting metadata. This is same-session completion, not a second independent audit. End immediately when REVIEW.md and MANIFEST.json are complete.
"""
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','8'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'P31 ZKIR artifact review reporting-only closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (c/'native.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except:continue
 models.update(d.get('modelUsage',{}))
 if d.get('model'):models.add(d['model'])
 for k in ['sessionId','session_id']:
  if d.get(k):sessions.add(d[k])
 if d.get('type') in ['end','error','result']:terminal.append(d)
rec={'started_utc':st,'finished_utc':now(),'process_exit':code,'reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':h(c/'native.jsonl'),'terminal_events':terminal,'acceptance':False};write(c/'process.json',rec);print(json.dumps({k:v for k,v in rec.items() if k!='terminal_events'}),flush=True)
