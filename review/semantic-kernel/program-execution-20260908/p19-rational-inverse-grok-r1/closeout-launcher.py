from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-rational-inverse-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-rational-inverse-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==30;assert not Path('/proc/2028868').exists()
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
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max30_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"Resume SAME independent R17 rational-inverse review session {prev['sessions'][0]} for REPORTING-ONLY completion. The original30turn run reached its cap after REVIEW.md, verdict.json, findings.json and commands.json, but MANIFEST.json is absent. Root preserved those four files and copied them byte-identically into {c}. Write ONLY under {c}. No source edits, builds, new probes, network, subagents, Foreman or other-worker inspection. Maximum8turns. Preserve original parent files and the four copied report bytes unless a concrete necessary correction is made explicitly and recorded. Main requirement now: a self-excluding MANIFEST.json binding the four reports and actual immutable ../logs, ../probes, ../tools and source identity evidence, excluding growing native streams/private-lean/.lake. Command paths in the byte-identical reports resolve from the original parent output directory, explicitly record this base in manifest/closeout notes. End immediately after reports/manifest complete.\n+\n+Root terminal identity now known: actual grok-4.6-build, requested grok-4.6 high, same session {prev['sessions'][0]}. Originalprocess exit1 is turn cap not a failed compiler command. All seven command metas exit0, including rebuilt Correspondence932jobs and exact299 axiom probe. Retain CHANGES_REQUIRED for wholeP19: universal Prop/h_lex/h_parse open, R16 mixed-error defect persists in unchanged R17 Decode, R18 repair active elsewhere. Your finding exprDepth_pos predatesR17 is important: actual new named theorem declarations29; historical R16 theorem-only count269 omitted that existing lemma. Keep exact299 current inventory and no forbidden axioms distinct from wholeP19 acceptance. Root verifies source/probe/tool hashes and named axiom equality separately; do not invent a root successful replay before it exists. No repeat7/21/54/99/16 runs or scanner replay. This is completion of the same review, not fresh independent review.\n+"
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','8'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'R17 rational inverse review manifest closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
