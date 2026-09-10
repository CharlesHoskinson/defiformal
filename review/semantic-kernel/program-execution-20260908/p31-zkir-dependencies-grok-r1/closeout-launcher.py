from pathlib import Path
import json,hashlib,datetime,gzip,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p31-zkir-dependencies-grok-r1';c=o/'closeout';s=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-dependencies-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
prev=json.loads((o/'process.json').read_text());assert prev['process_exit']==1 and prev['terminal_events'][-1]['num_turns']==18;assert not Path('/proc/2134960').exists()
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
write(o/'attempt1-terminal-seal.json',{'utc':now(),'exit':1,'stop_reason':'cancelled_at_max18_turns','reports':{n:h(o/n) for n in reports if (o/n).exists()},'native_sha256':h(o/'native.jsonl'),'native_gzip_sha256':h(o/'attempt1-native.jsonl.gz'),'missing_artifacts':[n for n in reports+['MANIFEST.json'] if not (o/n).exists()],'frozen_inputs_reverified':len(i['files']),'acceptance':False})
brief=f"Resume SAME P31 dependency source review {prev['sessions'][0]} to finish allfive finalreports. Initial18turnrun isterminalexit1 with no REVIEW/verdict/findings/commands/MANIFEST, but probes/binding-probe.py/json/stdout/stderr/-run.json exist. Preserveparent{ o } byte-for-byte. Writeonlyunder{ c }. Same review, notfreshsecondaudit. Maximum14turns; prioritizecompleteallfivefiles. No network/Rust/C/buildscript/proof execution, capture-scriptreruns, inputedits, subagents, Foreman, or otherworkerinspection.\n\nYour existing probe returns exit0 UNCONDITIONALLY and hasfalse flags: allMidnightmembersmatchfalse andfourstaticclaimsfalse. Do not call exit0 a successfulallchecks gate or omit these flags. Rootsourceinspection suggests PROBE defects: check_packet resolves extracted=packet/rec[path], butMidnightreceipt paths are relative to the enclosing p31-zkir-dependency-source-preparation root, noteachpackage; blstreceiptpaths ARErelative toblstpacketroot. The false staticchecks use wrongzero-based line offsets for preprocessinginputs/outputs,publicinputassert,Poseidonchipinit andblstmoduluslimbs (twolimbsperline). Verify independently. Preserveoriginalprobeandresultswithqualified/zerocreditforthosefailedchecks. A SINGLE corrected offline probe copy and bounded rerun undercloseout isallowed toresolve these concrete problems; recordchangedlines, actualargv/cwd/start/end/exit/Python/probe/outputstreamhashes. Do not overwriteparentprobe. It mustassert actualrelevantbooleans orclearlyreportdataonly; do not silentlyconvertfalseflagstopass.\n\nAll749frozeninputhashes match and13archivechecksums matchlockedCargo/registry inoriginalprobe; rootpriorarchive/memberreplayspassed464Midnight+159blst. Thoseare separateevidence, notpermissiontoskipindependentcheck. Interpretlicensefields accurately: originalCargo.toml.orig usesworkspaceinheritance forsomepackages whilepublishednormalizedCargo.toml/registry/receipt carryactualstrings orlicense-filepaths. No claimallpackagescontainstandaloneLICENSE. Capturedlicensetexts/metadata are sourceevidence, notlegalreview. Fixedcommitmentpreimageorder/fieldaliases/limbs shouldbindactualbytes; sourceagreementnotsemanticproof. KeepPiSkip/publictranscript/instanceinterfaceassumptions, Fqintegerrefinement, platformnativebuildselection andexternaldependencies/source-to-installed-binaryboundaryexplicit. Originalnavigationblstuncapturedclaimhistorical; latercaptureclosesnamedgap, notfullclosure.\n\nWriteREVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Manifestresolvespathsfromcloseout andbindsreportsplusoriginalparentprobe/outputs/receipts andanycorrectedcopy, excludesgrowingnative/self. Rootterminalidentitygrok-4.6-build, requestedgrok-4.6high session{prev['sessions'][0]}. No adapter32.7/32.9/fullP31/P19/P20/fullprogramacceptance fromsourceidentity. Stateconcretescopedresultaftercheckingactualflags andremaininginterfacework. Endwithallfive artifacts andchildrencollected.\n"
(c/'brief.txt').write_text(brief);cmd=['grok','--resume',prev['sessions'][0],'-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','14'];st=now()
with (c/'native.jsonl').open('x') as f,(c/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':st,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','resumed_session':prev['sessions'][0],'fresh_session':False,'brief_sha256':h(c/'brief.txt'),'scope':'P31 dependency review report completion and bounded probe correction','acceptance':False};write(c/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
