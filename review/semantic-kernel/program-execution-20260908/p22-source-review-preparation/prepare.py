from pathlib import Path
import json,hashlib,datetime,tarfile,shutil,subprocess,ast
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p22-source-review-preparation';o.mkdir(exist_ok=False);inputs=o/'inputs';inputs.mkdir();packet=b/'p22-source-entry-preparation';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
m=json.loads((packet/'manifest.json').read_text());ready=json.loads((packet/'readiness.json').read_text())
for n,d in m['files'].items():assert h(packet/n)==d,n
with tarfile.open(packet/ready['archive']) as t:
 for name,d in ready['files'].items():
  raw=(packet/'upstream'/name).read_bytes();assert hashlib.sha256(raw).hexdigest()==d['sha256'];assert len(raw)==d['bytes'];assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==d['git_blob'];assert t.extractfile(name).read()==raw
for n in list(m['files'])+['manifest.json']:
 p=inputs/'source-entry'/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(packet/n,p)
for name,digest in ready['development_material'].items():
 raw=subprocess.check_output(['git','show',ready['primary_commit']+':'+name],cwd=r);assert hashlib.sha256(raw).hexdigest()==digest,name;p=inputs/'historical-development'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(raw)
for name in ['AGENTS.md','.claude/skills/defi-footguns/SKILL.md','formal/v3/GATE-REGISTER.md','openspec/changes/reusable-verification-platform-program/tasks.md','openspec/changes/reusable-verification-platform-program/specs/source-bound-library-families/spec.md','review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md','review/semantic-kernel/program-execution-20260908/P17-ACCEPTANCE.md']:
 p=inputs/'current-contract'/name;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/name,p)
files={str(p.relative_to(inputs)):h(p) for p in inputs.rglob('*') if p.is_file()};put(o/'inputs.json',{'utc':now(),'files':files,'file_count':len(files),'source_commit':ready['commit'],'source_entry_bindings':len(m['files']),'upstream_git_blob_bindings':6,'historical_context_bindings':4,'source_execution':False,'acceptance':False})
brief='''Fresh native Grok4.6 high independent P22 Curve source-entry audit. Frozen inputs are provided in the sandbox; write only the new p22-source-grok-r1 output directory. One auditor. AGY implements P19 elsewhere; never inspect live author/reviewer files or caches. No source edits, network, package installation, subagents, Foreman, branches, commits, pushes, extra windows or Atlas.

Source: official curvefi/curve-contract pin574f44027d089de0eac765f5a74ea5ae96aba968,treeede72644a022dde8adeedb3b88a2eefc7370beab. Six captured upstream files, exact bytes/hash/Gitblob and selected archive. StableSwap3Pool.vy SHA03e0bf29ae2fe945a3629b8085062da8f9d9d25957e86001dfc3df68c895f9dc, blob04d170189a1b5ddfecfc0af9ea3fe23eb0840423,25886bytes. Source pin is new explicit selection; not established as old development revision or deployed identity. Four historical development files are captured at exact prior root commitfa1cc407bea0da33a23f0e53e6b3ec388357af21 and expected hashes. Current accepted program/P17 resource gate context is separate.

Inspect actual get_D, caller normalization/amplification/rates, uint256 arithmetic and all division/refusal assumptions in source. Existing root classification: N_COINS3, range255, zero sum returns0, adjacent iterate difference<=1 breaks, loop fallthrough returnsD at218 without explicit nonconvergence revert. This is successful residual return IF arithmetic completes, not a proven executable exhaustion witness or convergence guarantee. No compiler/runtime has run in this source packet. Vyper header0.2.4 and Brownie configs are captured but not a compiler identity or compilation proof. Do not infer division/overflow behavior beyond what pinned source and known unexecuted compiler assumptions justify.

Historical curveD.qnt is a declared3-to2 reduction, not unchanged three-coin source execution. Python reconciliation and development examples are contextual evidence, not full source-faithful Lean API or P22 acceptance. Identify exact model/source mismatches and required arithmetic/amplification/denominator domains. Preserve actual three-coin scope unless a later author explicitly proves a faithful parameterized correspondence. Do not silently replace source exceptional success with a fabricated refusal or claim every returnedD converged.

Task23.1 requires pinned bound-exhaustion guard/class and coherent source-entry contract; current source preparation alone does not complete author contract. Task23.2 requires Lean Curve implementation and bounded-iteration proofs. Task23.3 requires ordinary success, selected exceptional/residual or actual refusal, false-convergence mutant, source-independent over-bound negative and independent review. All remain open unless exact evidence proves them; no pretend current API. Review source/preparation suitability now, not finished implementation. Verify archive/source/manifest/historical bindings and actual code excerpts with your own read-only probes. Meaningful changed-byte rejection should exercise the SAME validation function used on intact bytes; do not raise on both branches and call it a gate test. Never invent root controls or command execution.

At most25turns: execute bounded source checks early, prepare all5reports EARLY and finalize byturn20 with5reserve. REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Every actual probe records argv,cwd,start/end,exit,script/tool/source/raw hashes. Preserve failures. Bind all immutable reports/probes/rawstreams after last command, exclude growingnative. Actual model unknown until terminal telemetry. State unresolved questions and stop investigation near cap; collect children. Root verifies/adjudicates/publishes. Full authorized core remains active.'''
(o/'brief.txt').write_text(brief)
launcher='''from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';PREP=B/'p22-source-review-preparation';O=B/'p22-source-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p22-source-grok-r1-sandbox');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\\n')
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
O.mkdir(exist_ok=False);shutil.copytree(PREP/'inputs',S);shutil.copy2(PREP/'inputs.json',O/'inputs.json');brief=(PREP/'brief.txt').read_text()+'\\n\\nSandbox: '+str(S)+'\\nOutput: '+str(O);(O/'brief.txt').write_text(brief);start=now();argv=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','25']
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
'''
ast.parse(launcher);(o/'launcher.py').write_text(launcher);put(o/'preparation.json',{'utc':now(),'status':'prepared_not_dispatched','input_files':len(files),'current_priority':'Live P28 review; any terminal P19 candidate review takes priority','author_guard':'R27 must remain live at launch; otherwise freeze/proof review first','review_cap':25,'source_execution':False,'P22_accepted':False})
(o/'prepare.py').write_bytes(Path(__file__).read_bytes());put(o/'root-seal.json',{'utc':now(),'files':{str(p.relative_to(o)):h(p) for p in o.rglob('*') if p.is_file()},'acceptance':False});print(json.dumps({'input_files':len(files),'source_entry_bindings':11,'upstream_git_blobs':6,'historical_context':4,'dispatched':False}))
