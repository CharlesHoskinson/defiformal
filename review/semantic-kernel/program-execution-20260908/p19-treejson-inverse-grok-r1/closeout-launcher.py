from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-treejson-inverse-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-treejson-inverse-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==30;assert not Path('/proc/2103999').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());name=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and name in ['lean','lake','grok','node']),(p.name,name,cwd)
i=json.loads((o/'inputs.json').read_text())
for n,v in i['files'].items():assert h(s/n)==v,n
c.mkdir(exist_ok=False);reports=['REVIEW.md','verdict.json','findings.json','commands.json']
for n in reports:
 if (o/n).exists():shutil.copy2(o/n,c/n)
with (o/'attempt1-native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max30_turns','reports':{n:h(o/n) for n in reports if (o/n).exists()},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':[n for n in reports+['MANIFEST.json'] if not (o/n).exists()],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"Resume SAME independent R19 TreeJson/precedence review session {prev['sessions'][0]} for REPORTING-ONLY completion. The30turn run reached its cap with all five finalreports missing, but the actual evidence is captured in parent logs/command-index.jsonl, logs/*/meta.json/stdout/stderr, probes/*, compiler/source/author-command bindings and tools. Root preserves the terminal native stream and existing artifacts. Write all five finalreports ONLY under {c}: REVIEW.md, verdict.json, findings.json, commands.json and a self-excluding MANIFEST.json. Parent output {o} stays immutable. No new probes/builds/source edits/network/subagents/Foreman/other-worker inspection. Maximum12turns; prioritize producing the complete report set from existing evidence and end. This is the same independent review, not a fresh second review.\n\nUse exact captured results and qualify scope. Read logs/command-index.jsonl and all actual12command receipts to reconstruct commands.json with originalargv/cwd/start/end/exit/tool/probe/rawstdout/stderr hashes. Correctly resolve ../logs and ../probes from closeout or explicitly state parentpathbase. Complete manifest binds all reportfiles and relevant immutable parent evidence, excludes growingnative/private-lean/.lake, and self-excludes. Preserve any failures with zero credit and do not invent missing receipts.\n\nRoot terminal identity is now known: requestedgrok-4.6 high, actualgrok-4.6-build, same session{prev['sessions'][0]}; originalnativeexit1 is max30turn cap, not failedLean. Determine actual rebuild and343named declarations (331standard12none), root/author inventory alignment and exact proofscope from your completed source/evidence. The main universal theorem remains Prop and R19 TreeJson/Expr additions are scalar/empty/fixed-expression cases, not arbitrary nonempty recursive inversion; no production TreeJson encoder correspondence. R19 repaired2unterminatedwhitespace cases; root6mixed/32C0/4finalunterminated controls passed. Your successful runtimeprobes are evidence, not approval of universal theorem. No-whitespace scannerintermediate differsR15 whilefinaldecoderagrees. Preserve all1MiB/depth64/array4096/fullstrings. Author1552/2628Certificates,420/677Typed,287/408Composition is separate from343namedproofs. NamedtargetlakebuildDefiKernel is notunqualifiedbuild. Include concrete new concerns if found, otherwise state exact remaining obligations without inventedfindings. Never inspect liveR20. No7/21/full54/99/16newruns. FullP19/roadmapremainopen.\n"
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','12'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'R19 TreeJson review all-five-report closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
