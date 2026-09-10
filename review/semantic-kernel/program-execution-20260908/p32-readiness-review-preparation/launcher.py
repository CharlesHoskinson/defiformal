from pathlib import Path
import json,hashlib,datetime,subprocess,shutil,os
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';cache=Path('/home/charl/.cache/defiformal-program/program-execution-20260908');o=b/'p32-readiness-grok-r1';s=cache/'p32-readiness-grok-r1-sandbox';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prep=b/'p32-readiness-review-preparation'
for entry in b.iterdir():
 if not entry.is_dir() or '-grok-' not in entry.name:continue
 for q in [entry/'dispatch.json',entry/'closeout/dispatch.json']:
  if q.exists() and not (q.parent/'process.json').exists():
   d=json.loads(q.read_text());pid=d.get('pid')
   assert not (pid and Path('/proc').joinpath(str(pid)).exists()),'Another native reviewer is live: '+str(q)
i=json.loads((prep/'inputs.json').read_text());assert str(s)==i['sandbox']
for n,v in i['files'].items():assert h(s/n)==v,n
assert h(prep/'brief.txt')==json.loads((prep/'preparation.json').read_text())['brief_sha256']
o.mkdir(exist_ok=False);shutil.copy2(prep/'inputs.json',o/'inputs.json');brief=(prep/'brief.txt').read_text()
(o/'brief.txt').write_text(brief);start=now();cmd=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','20']
with (o/'native.jsonl').open('x') as f,(o/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':start,'pid':p.pid,'role':'auditor','scope':'P32 six environment readiness records and exact P16 evidence bindings','requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(s),'brief_sha256':h(o/'brief.txt'),'status':'running','acceptance':False};write(o/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (o/'native.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except:continue
 models.update(d.get('modelUsage',{}))
 if d.get('model'):models.add(d['model'])
 for k in ['sessionId','session_id']:
  if d.get(k):sessions.add(d[k])
 if d.get('type') in ['end','error','result']:terminal.append(d)
rec={'started_utc':start,'finished_utc':now(),'process_exit':code,'reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':h(o/'native.jsonl'),'terminal_events':terminal,'acceptance':False};write(o/'process.json',rec);print(json.dumps({k:v for k,v in rec.items() if k!='terminal_events'}),flush=True)
