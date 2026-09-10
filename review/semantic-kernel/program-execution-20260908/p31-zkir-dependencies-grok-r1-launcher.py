from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';C=Path('/home/charl/.cache/defiformal-program/program-execution-20260908');O=B/'p31-zkir-dependencies-grok-r1';S=C/'p31-zkir-dependencies-grok-r1-sandbox';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert (B/'p19-treejson-inverse-grok-r1/root-seal.json').exists()
for pid in [2103999,2120377]:assert not Path('/proc',str(pid)).exists()
O.mkdir(exist_ok=False);S.mkdir(exist_ok=False);files=set()
for dn in ['p31-zkir-source-preparation','p31-zkir-dependency-source-preparation','p31-zkir-dependency-root-verification','p31-zkir-dependency-navigation','p31-zkir-blst-source-preparation','p31-zkir-blst-root-verification','p31-zkir-blst-root-verification-attempt2']:
 d=B/dn;seal=json.loads((d/'root-seal.json').read_text())['files'];assert seal
 for n,digest in seal.items():assert h(d/n)==digest;files.add(d/n)
 files.add(d/'root-seal.json')
for n in ['AGENTS.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','review/semantic-kernel/program-execution-20260908/P31-READINESS-ACCEPTANCE.md','review/semantic-kernel/program-execution-20260908/p31-zkir-source-grok-r1/root-adjudication.json']:
 p=R/n;assert p.is_file();files.add(p)
records={}
for p in sorted(files):
 q=S/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);assert h(q)==h(p);records[str(q.relative_to(S))]=h(q)
put(O/'inputs.json',{'schema':'defiformal-zkir-dependency-review-inputs/v1','utc':now(),'sandbox':str(S),'files':records,'file_count':len(records),'scope':'13locked dependency source archives, offline identity receipts and static commitment/field/transcript source navigation; original ZKIR source packet supplied as context. No semantic interface implementation.','acceptance':False})
brief=f'''Fresh native Grok4.6 high independent audit of P31 ZKIR dependency-source and navigation evidence. Sandbox {S}; output {O}; {len(records)} frozen input files. Sole reviewer. No live AGY/P19worktree/output/cache inspection, subagents, Foreman, newwindows, branches, commits or pushes. No network, Rust/C/buildscript execution, compiler/proof runs or changes to input snapshots. New offline diagnostic scripts and outputs only under {O}. Root will verify/adjudicate; your review is source readiness evidence, not a proof or adapter approval.

Under sandbox review/semantic-kernel/program-execution-20260908 inspect these packets: p31-zkir-dependency-source-preparation and root-verification (12midnight-* packages excluding rootzkir,464sourcefiles,532sealedfiles); p31-zkir-blst-source-preparation and both root-verification attempts (exactblst0.3.16,159members,167sealedfiles); p31-zkir-dependency-navigation (9sources14exactanchors); earlier p31-zkir-source-preparation and completed source review root-adjudication/P31readiness acceptance as context. Recompute exact lock selection, archive hash versus captured registry+Cargo.lock checksums/sizes, extracted-member bytes/safe paths, licenses/VCS metadata and HTTP receipt bindings. Do not fetch network or rerun capture scripts that create existingdirs or execute builds. Rootblst verifierattempt1 failed because unanchored pubfnblst_fr_mul also matchedmul_by_3; retainedfailedattemptzero credit. Correctedattempt2verified159members/sevenstaticanchors. Distinguish failedrootnavigationmatcher from crate correctness.

Evaluate static claims precisely: transient_commit putsopeningfirst; FieldReprfor[Fr] writesrawslice withoutlengthprefix; ZKIRpreprocess suppliesinputs++outputs; circuitposesopening++inputs++outputs and assertssecondpublicinput. CPUandcircuit PoseidonChip bothinitializefixedlengthinputs.len, but no generatedconstraintcorrespondence proof or runtimeexecution is claimed. Fieldwrapper transient_crypto::Fr wrapsouter::Scalar=midnight_curves::Fq; embeddedscalar usesmidnight_curves::Fr and mustnotbesubstituted. Checkmodulushex/LElimbs and underlyingblstfunction/constant bindings. Rootnavigationsaysblstuncapturedasofthatpacket; laterblstcaptureclosesNAMEDsourcegap, notallnonMidnightdependencies. Buildscriptplatform/feature/assemblyselection remainsunverified forinstalledbinary; source-to-binaryassumptionstaysdisclosed. No inventedmandatoryreprodbuildoruniversalcompiler-correctnessgate.

PiSkippreprocess adjuststranscriptcursor/checksassociatedinputvalues, circuitarmempty. Assesswitness/public-instance/skipcorrespondence boundary. Do not infer soundnessorbug solelyfromemptyarm. Source index/resource assumptions and bounded-integer-to-fieldrefinement need explicitadaptercontract. These13crates are notcompleteCargo/buildclosure; otherexternaldependencies remain. Allsourcecapturesarepureacquisition, no circuits/proofskeysrealexecution. Oldmockartifactexecution is historical, not anewrun. P31tasks32.1-4historicallyacceptedreadiness; these additions cannotclose32.7adapter/32.9review/fullP31/P19/P20/fullprogram.

Maximum18turns. Keepauditbounded and WRITEALLFIVEreportsEARLY: REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. The previousreviewcost timebyomittingfinalreports atcap; do not repeat. Oneofflinebindingprobe can batch thechecks; preserveactualargv/cwd/start/end/exit/Python/source/probe/rawstdout/rawstderrhashes. Sourcequotes/lineanchors mustbindactualsnapshottedbytes; report inference separately from bytechecks. Includeallrelevant immutable report/probe/log/source bindings; excludegrowingnativeandselfmanifest. Unknownmodelidentityuntilterminalreceipt is valid; neverinventactualmodel. This is sourceevidenceaudit, notapprovalfroma successfulhashscript. Reportconcretefindings/necessarynextinterfacework and any scopedreadinessconclusion. No additionaldependencyacquisition here. Collectchildprocessesbeforeending.
'''
(O/'brief.txt').write_text(brief);start=now();cmd=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','18']
with (O/'native.jsonl').open('x') as f,(O/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=S,stdout=f,stderr=e);d={'schema':'defiformal-native-dispatch/v3','started_utc':start,'role':'auditor','scope':'P31 locked ZKIR dependencies and static commitment/field/transcript source identity audit','pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(S),'brief_sha256':h(O/'brief.txt'),'status':'running','acceptance':False};put(O/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (O/'native.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except:continue
 if d.get('model'):models.add(d['model'])
 models.update(d.get('modelUsage',{}))
 for k in ['sessionId','session_id','conversation_id']:
  if d.get(k):sessions.add(d[k])
 if d.get('type') in ['end','error','result']:terminal.append(d)
rec={'schema':'defiformal-native-process/v2','started_utc':start,'finished_utc':now(),'requested_model':'grok-4.6','reported_models':sorted(models),'sessions':sorted(sessions),'effort':'high','brief_sha256':h(O/'brief.txt'),'log_sha256':h(O/'native.jsonl'),'process_exit':code,'terminal_events':terminal,'acceptance':False};put(O/'process.json',rec);print(json.dumps({k:v for k,v in rec.items() if k!='terminal_events'}),flush=True)
