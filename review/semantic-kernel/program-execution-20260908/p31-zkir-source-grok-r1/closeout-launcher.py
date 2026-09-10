from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p31-zkir-source-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-source-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==20;assert not Path('/proc/2054415').exists()
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
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max20_turns','reports':{n:h(o/n) for n in reports},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':['MANIFEST.json'],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"Resume SAME independent P31 ZKIR source/release review session {prev['sessions'][0]} for REPORTING-ONLY closeout. Original20turn run ended at cap after REVIEW.md/verdict.json/findings.json/commands.json but no MANIFEST.json. Root preserved originalparentfiles and copiedfourreports byteidentically to {c}. All writes ONLY here. No source edits, network, builds, probes, compiler/mock/materialization execution, subagents, Foreman or other-worker inspection. Maximum6turns: create self-excluding MANIFEST.json binding fourreports and immutable ../probes, relevant input/command hash evidence. Command relative paths in copied reports resolve from original parent output; manifest ../paths resolve from closeout. Exclude growingnative logs and privatecaches. Preserve fourcopiedreportbytes; any necessarycorrection explicit notes rather than rewritinghistory. End as soon as manifestcomplete.\n\nRoot terminal metadata: actualgrok-4.6-build, requestedaliasgrok-4.6 high, same session {prev['sessions'][0]}. Originalreports returned_modelgrok-4.6 is an alias, not actualnativebuildidentity; explicitly correctthis in closeoutmanifestnotes. Source138hashes/crate2.1.0checksum/ninecratefiles/sixreleasefiles and distinct4commits are boundedsource/releaseidentity evidence, not semanticcontract or adapter32.7/correspondence/proofsoundness. Keep original usable scopedverdict with fullP31/PCT/P20/wholeprogram false. Do notinvent mandatoryreproduciblebuildgate. Preserve original404acquisition evidence. Root verifiesactualrawcommand/source/toolbindings separately; do not claim verificationnotyetobserved. This is completion of same review, not secondindependentreview.\n"
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','6'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'P31 ZKIR source review manifest closeout','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
