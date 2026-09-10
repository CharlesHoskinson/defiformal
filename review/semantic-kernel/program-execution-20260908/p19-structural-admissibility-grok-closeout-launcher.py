from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-structural-admissibility-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-structural-admissibility-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==25;assert not Path('/proc/1861558').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and name in ['lean','lake','grok','node']),(p.name,name,cwd)
i=json.loads((o/'inputs.json').read_text())
for n,v in i['files'].items():assert h(s/n)==v,n
c.mkdir(exist_ok=False);reports=['REVIEW.md','verdict.json','findings.json','commands.json']
for n in reports:shutil.copy2(o/n,c/n)
with (o/'attempt1-native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max25_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f'''Resume SAME independent frozen R14 review, session {prev['sessions'][0]}. You hit25turn cap after writing complete REVIEW.md, verdict.json, findings.json, commands.json; only MANIFEST.json is missing. Root preserved original reports/native and copied those4 reports byte-identically to {c}. All writes ONLY under {c}; original parent reports/logs/probes/source inputs are immutable. Source sandbox {s}. AGY R15 still writes elsewhere; never access it. No subagents/Foreman/network/code edits/branches/pushes. REPORT CLOSEOUT ONLY, no new probes, builds or investigations. You have8turns.

Inspect existing four reports/commands and referenced immutable parent logs/probe identities. Finish a self-excluding MANIFEST.json in closeout binding the four copied reports and their immutable ../probes and ../logs references; keep native growing logs excluded. Paths must resolve from the manifest location, record actual hashes. Do not reproduce large private Lean caches or entire runner-tree in the manifest. If any command metadata is absent, state the limitation without inventing runs. Existing verdict remains CHANGES_REQUIRED, full P19 and task acceptance false. Freshness refers to original independent audit session; this is resumed closeout, not a new review. Actual model identity comes from root native terminal receipt. End once manifest and a brief closeout note are complete. Root independently audits217 exact declarations and replays existing successful ProbeR14 afterward. Preserve original four reports byte-identically; their log/probe paths resolve from original parent output directory. MANIFEST references from closeout must use ../logs and ../probes accordingly; clarify path bases rather than silently changing historical reports. Actual native original receipt returned grok-4.6-build. Inline helper failure has zero proof credit; preserve failed parser attempts as reported. No new source inspection or research; write manifest and finish.
'''
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','8'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'R14 review reporting-only closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
