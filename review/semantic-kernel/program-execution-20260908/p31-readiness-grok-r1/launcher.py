from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';c=Path('/home/charl/.cache/defiformal-program/program-execution-20260908');o=b/'p31-readiness-grok-r1';s=c/'p31-readiness-grok-r1-sandbox';source=r/'review/semantic-kernel/adapters/readiness/p31';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/1660122').exists();assert (b/'p19-container-codec-grok-r1/root-seal.json').exists();o.mkdir(exist_ok=False);shutil.copytree(source,s)
files={str(p.relative_to(s)):h(p) for p in s.rglob('*') if p.is_file()}
for n,v in files.items():assert h(source/n)==v
write(o/'inputs.json',{'schema':'defiformal-p31-review-inputs/v1','utc':now(),'sandbox':str(s),'files':files,'source_pin':'7307349d0275af6fcb4144e1661d8b59d6b2663a','acceptance':False})
brief=f"""Fresh native Grok4.6 high independent source-readiness audit for P31. Read only frozen sandbox {s}; write review outputs only under {o}. One reviewer; AGY P19 R12 author runs elsewhere, do not read that live work or touch source/cache. No network/subagents/Foreman/code edits/branches/commits/pushes. This is source inspection of 4 readiness records and13 pinned Moriarty source/license files at7307349d0275af6fcb4144e1661d8b59d6b2663a, not implementation review or a new proof/compile campaign.

Assess each target Moriarty/Compact/ZKIR/PCT against the actual captured code and self-described scope. Verify every source SHA256 and Git blob identity against the manifest; record files inspected. Check accurate profile separation (bounded-atomic versus funded-source), typed interfaces, canonical codec admitted value types, funded transfer/allocation remainders, restricted Compact mapping, intermediate UInt128 arithmetic, compiler --skip-zk route and absence of key/proof credit, and deployment-owned TrustedAcceptanceBackend/evaluate trust boundary. Inspect exact API names/behavior, not just README claims. Identify unsupported claims or requirements that accidentally narrow source semantics. Distinguish a missing verified adapter contract from proof that no implementation exists anywhere. Source-declared compiler versions are not fresh tool observations.

P31 required tasks32.1-32.4 ask readiness records naming verified interface/source or blocked_unavailable; tasks32.5-32.8 require actual verified adapters. These drafts explicitly keep readiness and implementation unaccepted. Judge whether records are usable source preparation and what precise gaps remain. No actual DeFiKernel adapter/correspondence is claimed; missing Lean implementation is the known next phase, not a fabricated test failure. PCT certificate consumption requires accepted P20; cryptographic, semantic, oracle/custody/legal and durable state/nonce consumption are separate. Keep full P31 and program acceptance false.

Use cameronfreer lean4-skills review-only if a Lean claim is inspected; no Lean code/proof here so no new lake or K/Compact builds are required for source-only conclusions. Do not rerun old test campaigns. Write initial REVIEW.md/verdict.json early and final REVIEW.md, verdict.json, findings.json, commands.json, self-excluding MANIFEST.json by20turns. Reserve final4turns for closeout. Preserve failures and exact hashes. Root captures actual returned model and independently adjudicates. Do not alter frozen inputs.
"""
(o/'brief.txt').write_text(brief)
start=now();cmd=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','20']
with (o/'native.jsonl').open('x') as f,(o/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'schema':'defiformal-native-dispatch/v3','started_utc':start,'role':'auditor','scope':'P31 pinned source readiness audit; adapter implementation and full P31 remain open','pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(s),'brief_sha256':h(o/'brief.txt'),'status':'running','acceptance':False};write(o/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
terminal=[];models=set();sessions=set()
for line in (o/'native.jsonl').read_text().splitlines():
 try:d=json.loads(line)
 except:continue
 if d.get('type') in ['end','error','result']:terminal.append(d)
 if d.get('model'):models.add(d['model'])
 models.update(d.get('modelUsage',{}))
 for k in ['sessionId','session_id','conversation_id']:
  if d.get(k):sessions.add(d[k])
rec={'schema':'defiformal-native-process/v2','started_utc':start,'finished_utc':now(),'requested_model':'grok-4.6','reported_models':sorted(models),'sessions':sorted(sessions),'effort':'high','brief_sha256':h(o/'brief.txt'),'log_sha256':h(o/'native.jsonl'),'process_exit':code,'terminal_events':terminal,'acceptance':False};write(o/'process.json',rec);print(json.dumps({k:v for k,v in rec.items() if k!='terminal_events'}),flush=True)
