from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p25-source-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p25-source-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert (B/'p19-recursive-token-grok-r1/root-seal.json').exists();assert not Path('/proc/2163507').exists();O.mkdir(exist_ok=False);S.mkdir(exist_ok=False)
for name in ['p25-balancer-source-preparation','p25-balancer-source-verification','p25-balancer-source-verification-attempt2','p25-balancer-tree-identity-followup','p25-balancer-dependency-preparation','p25-balancer-dependency-root-verification','p25-balancer-compiler-preparation','p25-balancer-compiler-baseline','p25-balancer-build-profile-followup']:
 base=B/name;seal=read(base/'root-seal.json')
 for n,digest in seal['files'].items():assert h(base/n)==digest,n
 for n in list(seal['files'])+['root-seal.json']:
  p=base/n;q=S/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
for name in ['openspec/changes/reusable-verification-platform-program/tasks.md','openspec/changes/reusable-verification-platform-program/specs/source-bound-library-families/spec.md','review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md','AGENTS.md']:
 q=S/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/name,q)
arc=read(B/'p25-balancer-source-preparation/archive-http.json');p=Path(arc['archive_cache_path']);assert h(p)==arc['sha256'];(S/'source-archives').mkdir();shutil.copy2(p,S/'source-archives/balancer.tar.gz')
files={str(p.relative_to(S)):h(p) for p in S.rglob('*') if p.is_file()};put(O/'inputs.json',{'utc':now(),'sandbox':str(S),'files':files,'file_count':len(files),'scope':'Frozen P25 source acquisition/dependency and compiler baseline audit only','acceptance':False})
brief=f'''Fresh native Grok4.6 high independent P25 Balancer source-preparation and compiler-baseline audit. Read only frozen sandbox {S}; write only {O}. One independent auditor. AGY R21/R22 works separately; do not inspect any author worktree, drafts, native logs, or cache. No subagents, Foreman, network, branches, commits, pushes, package installs or upstream code edits. Current routing AGY author/Grok auditor supersedes historical AGENTS roles.

P25 task26.1 still needs AGY cash-plus-owed and hook-revert observation contract and your later design review; tasks26.2/26.3 implementation, Lean accounting/rollback proof, actual join/refusal/mutants remain open. Audit this packet as source/compiler input only. Do not mark source-entry observations frozen or fullP25 accepted.

Source official balancer/balancer-v3-monorepo commit449f7e074be4a92f9ed35ac8d201f45d4ac01f7e is observed mainHEAD, not deployedidentity.78capturedfiles incl68source import traversal plusconfig/unexecuted reference tests;210localedges and72externaloccurrences inoriginalpacket. Initialrootverification exit1 checking recursive-tree sha againstcommit.tree sha ispreserved withzerocredit. OriginaltreeAPIcalledwithcommitSHAechoescommitSHA; explicit-treefollowup returnscommit.treeSHA andidentical1247entries. Verify actualevidence; do notcallfailedfirstattempt successful.

Lockeddeps OpenZeppelin5.4.0 npmarchive sha512SRI+sha1shasum, Permit2 commitcc56ad0f3439c502c246fc5cfcc3db92bb8b7219 gitblobchecks all104archivemembers. Yarnchecksumsarecachecontainers, notrawarchivehashes. Finalselected98sources=68Balancer26OZ4Permit2,308lexicaledges,0unresolvedsourcepaths. This excludesreference-testclosure andisnotfullnpm/buildclosure. Verify exactgraphs/files/numericclaims, tarpath safety, Gitblobs/integrity. Archivedsources and rawinput/output gzip are frozen. Originalstored_path/cachepath strings are historical; resolve fromsandbox copies. OriginalBalancerarchive is supplied source-archives/balancer.tar.gz.

Rootdirectcompileofficialsolc0.8.27+commit.40a35a09 SHA256b9977d500c17cba6f0032ca939ef98c4decf6363f19f386d05fb02f708115264 --standard-json,optimizer999,Cancun,viaIRomitted/false,98sources,96contracts/44bytecodeoutputs,0errors4warnings. Verify inputsourcebytes/compiler/output/source-set/diagnostics/rawstreams and metadata. One fresh isolated reproduction using suppliedinput is allowed and useful; toolbinary may be read/executed at the explicit compiler.json binary_path afterhashverification, butwriteoutputs onlyreviewdir. Do not execute contracts, invent runtime outcomes, or rerun downloads/capturehelpers. Record actualargv,cwd,start,end,exit,compiler/probe/input/stdout/stderrhashes. Exit0alone insufficient; parse nonempty outputs/error severity.

Warnings actual: transient2394 plus5574 runtimeRouter26365,Vault33240,VaultExtension28902. These belongto0.8.27/noIR/999baseline, notHardhatdeployment. Profilefollowup3Gitboundfiles showsHardhat usesviaIRunlessCOVERAGE=true,customoptimizersequence,0.8.26/0.8.27compilers;Vault andVaultExtension override0.8.26/runs500. LocalHardhatallowUnlimitedContractSize=true. NoHardhatresolution/buildwasrun. Do not infer deployedsize or endorse bypassinglimits frombaseline. Flag anymaterialprofileclaimmismatch; preserveactualrunsettings.

Inspect six navigationexcerpts and source-backed subtleties forlatercontract: signedtokenDelta creditnegative/debtpositive; nonzerocounter onlyzerotransitions; outerunlock requireszero outstandingdeltas,nestedunlockdistinct; settle usesbalance-priorreserves andcapscreditbyamountHint,excesstokenresidue mustnotvanishfromaccounting;before/afteraddhooks surroundactualstateupdates, beforehookcanalterbalances/ratesreloadedbeforeaccounting;afterhookfalseorwronglengthreverts. SourceinspectionisnotwholeEVMrollbackproof. ExistingP17pinmustnotbesubstituted. Financialinteger/token/Permit2/compiler/runtimeassumptions and sourceexecution gate remainopen.

Maximum25turns. Write allfive artifacts early and finish them: REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Manifestbinds immutable reports/probes/rawreceipts, excludesgrowingnative andscratchbuildcache. Preserve failedattempts and modelidentityunknownuntilrootterminalmetadata. No invented commandtimestamps. Return scopedusable/changesrequired onsource/compilerpreparation, notP25implementationacceptance; list concrete gaps. Collectchildrenbeforeending.
'''
(O/'brief.txt').write_text(brief);start=now();argv=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','25']
with (O/'native.jsonl').open('x') as out,(O/'native.stderr').open('x') as err:
 p=subprocess.Popen(argv,cwd=S,stdout=out,stderr=err);d={'schema':'defiformal-native-dispatch/v3','started_utc':start,'pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(S),'brief_sha256':h(O/'brief.txt'),'scope':'P25 frozen source/dependency/compiler preparation audit','status':'running','acceptance':False};put(O/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
models=set();sessions=set();terminal=[]
for line in (O/'native.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except:continue
 models.update(d.get('modelUsage',{}))
 if d.get('model'):models.add(d['model'])
 for k in ['sessionId','session_id']:
  if d.get(k):sessions.add(d[k])
 if d.get('type') in ['end','error','result']:terminal.append(d)
rec={'started_utc':start,'finished_utc':now(),'process_exit':code,'reported_models':sorted(models),'sessions':sorted(sessions),'log_sha256':h(O/'native.jsonl'),'terminal_events':terminal,'acceptance':False};put(O/'process.json',rec);print(json.dumps({k:v for k,v in rec.items() if k!='terminal_events'}),flush=True)
