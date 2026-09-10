from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';PREP=B/'p22-source-review-preparation';O=B/'p22-source-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p22-source-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert (B/'p28-source-grok-r1/root-seal.json').exists(),'P28 source review must be root-sealed first'
for name in ['p28-source-grok-r1']:
 m=read(B/name/'root-seal.json')
 for p,d in m['files'].items():assert h(B/name/p)==d,p
assert not (B/'p19-roundtrip-proof-agy-r27-process.json').exists(),'R27 terminal: prioritize freeze and proof review'
a=read(B/'p19-roundtrip-proof-agy-r27-dispatch.json');assert Path('/proc',str(a['pid'])).exists(),'R27 author no longer live: prioritize freeze'
reviewer=read(B/'STATE.json')['independent_reviewer'];assert not Path('/proc',str(reviewer['pid'])).exists(),'Reviewer still live'
assert not Path('/proc',str(read(B/'p28-source-grok-r1/dispatch.json')['pid'])).exists(),'P28 reviewer still live'
m=read(PREP/'inputs.json')
for p,d in m['files'].items():assert h(PREP/'inputs'/p)==d,p
O.mkdir(exist_ok=False);shutil.copytree(PREP/'inputs',S);shutil.copy2(PREP/'inputs.json',O/'inputs.json');brief=(PREP/'brief.txt').read_text()+'\n\nSandbox: '+str(S)+'\nOutput: '+str(O);(O/'brief.txt').write_text(brief);start=now();argv=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','25']
with (O/'native.jsonl').open('x') as f,(O/'native.stderr').open('x') as e:
 p=subprocess.Popen(argv,cwd=S,stdout=f,stderr=e);d={'started_utc':start,'pid':p.pid,'role':'auditor','requested_model':'grok-4.6','effort':'high','fresh_session':True,'scope':'P22 Curve pinned source-entry preparation only','sandbox':str(S),'brief_sha256':h(O/'brief.txt'),'status':'running','acceptance':False};put(O/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (O/'native.jsonl').read_text().splitlines():
 try:e=json.loads(line)
 except json.JSONDecodeError:continue
 models.update(e.get('modelUsage',{}))
 if e.get('model'):models.add(e['model'])
 for k in ['sessionId','session_id']:
  if e.get(k):sessions.add(e[k])
 if e.get('type') in ['end','error','result']:terminal.append(e)
d={'started_utc':start,'finished_utc':now(),'process_exit':code,'reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':h(O/'native.jsonl'),'brief_sha256':h(O/'brief.txt'),'terminal_events':terminal,'acceptance':False};put(O/'process.json',d);print(json.dumps({k:v for k,v in d.items() if k!='terminal_events'}),flush=True)
