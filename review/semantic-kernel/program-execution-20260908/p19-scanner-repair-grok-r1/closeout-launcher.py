from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-scanner-repair-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-scanner-repair-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==30;assert not Path('/proc/1962071').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and name in ['lean','lake','grok','node']),(p.name,name,cwd)
i=json.loads((o/'inputs.json').read_text())
for n,v in i['files'].items():assert h(s/n)==v,n
c.mkdir(exist_ok=False);reports=[]
for n in reports:shutil.copy2(o/n,c/n)
with (o/'attempt1-native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max30_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['REVIEW.md','verdict.json','findings.json','commands.json','MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"Resume SAME independent R16 scanner audit session {prev['sessions'][0]} for REPORTING-ONLY CLOSEOUT. Original30turn process terminal exit1 at cap, all five final reports missing. Root preserves original logs/probes/failed attempts/private build and native stream. All writes only under {c}. No source edits, builds, new probes, subagents, network, Foreman or other-worker inspection. At most12turns; produce all five reports now from completed evidence. This is same-session completion, not a new independent audit.\nImportant observed failure: logs/probe-axioms269/meta.json and logs/encode-sourcemap/meta.json both exit1; metadata credit=true is erroneous success credit. Preserve original records; explicitly correct credit in final reports. These commands contain invalid probe syntax (doc-comment placement before eval/print and missing String.containsSubstr); emitted values/axiom lines do not make failed compilation a successful gate. Failed original sources and outputs stay immutable. c0-replay exit0 is distinct. probes/limits exists but any unrun/missing receipt must stay unrun. Root is independently checking the269-name inventory on your rebuilt imports and replaying successful C0 controls under ../root-verification; report that as separate root verification if present, not your original successful command.\nWrite REVIEW.md, verdict.json, findings.json, commands.json, MANIFEST.json. Summarize exact inspected source/rebuild identity, actual proof progress and remaining universal h_lex/h_parse, scanner repair controls, sourceMap fast path, moved sort helper, preserved domain and actual declaration-order encoder. Clearly disclose incomplete resource/malformed-input review if not executed. Use commands actual per-command metadata/raw logs, distinguish setupfailures and failedprobes, no invented argv/timestamps/exits/model. Native actual model is grok-4.6-build, requested alias grok-4.6. FullP19 false; no54/99/16 acceptance.\nManifest self-excludes and hashes five-report dependencies plus immutable ../logs, ../probes, ../failed-probes, ../tools as appropriate (paths resolve from closeout). Exclude growing native logs/private-lean/.lake. Avoid copying huge inputs.json into prose. Do not fix or rewrite parent files. End immediately after final reports/manifest.\n"
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'R16 scanner repair review reporting-only closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
