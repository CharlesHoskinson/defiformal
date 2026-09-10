from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-parser-bridge-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-parser-bridge-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==25;assert not Path('/proc/1796002').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and name in ['lean','lake','grok','node']),(p.name,name,cwd)
i=json.loads((o/'inputs.json').read_text())
for n,v in i['files'].items():assert h(s/n)==v,n
c.mkdir(exist_ok=False);reports=['REVIEW.md','verdict.json','findings.json','commands.json']
reports=[n for n in reports if (o/n).exists()]
for n in reports:shutil.copy2(o/n,c/n)
with (o/'attempt1-native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max25_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f'''Resume SAME independent frozen R13 review session {prev['sessions'][0]}. You hit25turn cap after completing source inspection, exact200 axiom audit, runner controls and successful ProbeR13 attempt2, but no final reports. Root preserved terminal native evidence and original files. Finish reports NOW from collected evidence; no new research, probes or builds. You have12turns, reserve final2 for manifest. All new writes ONLY {c}; original parent logs/probes/source inputs immutable. Source sandbox {s}; frozen source evidence includes review/semantic-kernel/certificates/p19/implementation/agy-r13-proof/theorems.json under sandbox, not under output directory. No access to live AGY author worktree, no subagents/Foreman/network/code edits/branches/pushes.

Write REVIEW.md, verdict.json, findings.json, commands.json and a self-excluding MANIFEST.json in closeout. Bind actual frozen source IDs and immutable ../probes and ../logs with actual hashes; exclude growing native logs and caches. Read original brief for acceptance scope. Report exact completed commands, exits, stdout/stderr and source/probe identities; missing metadata stays unknown. R13 universal production byte roundtrip is still open. Distinguish actual string parser inverses and decodeDecodedIR bridge from h_sm assumed subdecoder success, weak numerical fuel lemmas and whole-byte parser agreement. JSON.mkObj field ordering and production raw object field ordering can differ yet parse to the same JSON; different .compress alone is not a defect unless an actual byte-equality claim requires it. Do not invent a new blanket parent symlink ban for safe fresh children.

Preserve initial failed ProbeR13 setup as failure, successful logs/probe-r13-attempt2.stdout is actual replay target. If initial probe source was overwritten, state that limitation; do not reconstruct and claim original bytes. Reviewer actual model comes from native receipts grok-4.6-build, requested grok-4.6 high. Full P19/task acceptance remains false unless exact gate evidence exists. This is same-session reporting closeout, not a new independent review. End after final artifacts; no more inspection loops. Root independently checks exact200 and replays successful probe afterward.
'''
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'R13 review reporting-only closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
