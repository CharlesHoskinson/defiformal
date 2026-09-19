from pathlib import Path
import datetime, hashlib, json, subprocess, fcntl
OUT = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919')
WORK = Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909')
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,d): p.write_text(json.dumps(d,indent=2)+'\n')
lock=(OUT/'author.lock').open('a')
fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
brief=OUT/'grok-r4-brief.txt'
argv=['grok','--prompt-file',str(brief),'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','120']
started=now()
with (OUT/'grok-r4-native.jsonl').open('x') as stdout, (OUT/'grok-r4-native.stderr').open('x') as stderr:
 p=subprocess.Popen(argv,cwd=WORK,stdout=stdout,stderr=stderr,start_new_session=True)
 dispatch={'started_utc':started,'pid':p.pid,'argv':argv,'cwd':str(WORK),'requested_model':'grok-4.6','effort':'high','brief_sha256':sha(brief),'status':'running','acceptance':False}
 write(OUT/'grok-r4-dispatch.json',dispatch)
 state=json.loads((OUT/'STATE.json').read_text()); state.update(phase='grok_r4_implementation_running',updated_utc=now(),native_author_handle=dispatch);write(OUT/'STATE.json',state)
 print(json.dumps(dispatch),flush=True)
 code=p.wait()
models=set();sessions=set();terminal=[]
for line in (OUT/'grok-r4-native.jsonl').read_text().splitlines():
 try: e=json.loads(line)
 except json.JSONDecodeError: continue
 models.update(e.get('modelUsage',{}))
 if e.get('model'): models.add(e['model'])
 for key in ['sessionId','session_id']:
  if e.get(key): sessions.add(e[key])
 if e.get('type') in ['end','error','result']:terminal.append(e)
result={'started_utc':started,'finished_utc':now(),'process_exit':code,'requested_model':'grok-4.6','reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':sha(OUT/'grok-r4-native.jsonl'),'terminal_events':terminal,'acceptance':False}
write(OUT/'grok-r4-process.json',result)
state=json.loads((OUT/'STATE.json').read_text());state.update(phase='grok_r4_terminal_needs_freeze_and_astra_review',updated_utc=now(),native_author_result='grok-r4-process.json');write(OUT/'STATE.json',state)
print(json.dumps({k:v for k,v in result.items() if k!='terminal_events'}),flush=True)
