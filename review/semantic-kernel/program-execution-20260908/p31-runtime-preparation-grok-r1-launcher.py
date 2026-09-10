from pathlib import Path
import json,hashlib,datetime,subprocess,shutil,os
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';cache=Path('/home/charl/.cache/defiformal-program/program-execution-20260908');o=b/'p31-runtime-preparation-grok-r1';s=cache/'p31-runtime-preparation-grok-r1-sandbox';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert (b/'p19-envelope-codec-grok-r1/root-seal.json').exists();assert not Path('/proc/1753834').exists();o.mkdir(exist_ok=False);s.mkdir(exist_ok=False)
for name in ['p31-source-closure','p31-compact-add-diagnostic']:
 src=b/name;seal=json.loads((src/'root-seal.json').read_text())
 for n,v in seal['files'].items():assert h(src/n)==v,n
 for parent,dirs,files in os.walk(src):
  dirs[:]=[x for x in dirs if x not in ['node_modules','.git','.lake']]
  for name2 in files:
   p=Path(parent)/name2
   if p.is_file() and not p.is_symlink():q=s/name/p.relative_to(src);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
shutil.copytree(b/'p31-readiness-grok-r1',s/'prior-readiness-review',ignore=shutil.ignore_patterns('native.jsonl'))
files={str(p.relative_to(s)):h(p) for p in s.rglob('*') if p.is_file()};write(o/'inputs.json',{'schema':'defiformal-p31-runtime-review-inputs/v1','utc':now(),'sandbox':str(s),'files':files,'acceptance':False})
brief=f'''Fresh native Grok4.6 high independent bounded audit of P31 supplemental runnable-source preparation. Read only frozen sandbox {s}; all output and writable copies under {o}. AGY R13 works elsewhere: never access live author/code/cache. No subagents/Foreman/network/production edits/branches/commits/pushes. One reviewer. No Lean proof or adapter is claimed by these supplements, no Lean build required. Prior source-readiness audit retained its original13-file scope.

Audit two records in max14turns, final4 reserved for reporting:
(1) p31-source-closure:20 pinned source files,40 TypeScriptAST edges from original13 roots, plus exact upstream simulate.mjs and loan/swap.mori. Validate manifests/hash/source identity and stated static closure limits. First scanner attempt failed due absent legacy TypeScript5API in installed7; preserved zero-credit. Later isolated5.9.3 scanner/npm lock does not modify global compiler. No need rerun capture.py (it intentionally requires fresh output); inspect scanner and manifests. The actual pinned example runs four Simulation steps, adverse controls and missing-backend refusals. Re-run the unchanged example under absolute Node /home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node, output under review; compare semantically and exact bytes where stable. Agreement remaining Outstanding after loan settle must not be relabelled settled ledger. This is two bounded source examples, no accepted backend/proofs/correspondence.
(2) p31-compact-add-diagnostic: actual captured arithmetic source SHA b2969d0bc346fa93d88546578c9f9d29f1b74d7bc3f88f2e04709fa0932d9415 compiled under compiler0.31.1/language0.23.0/runtime0.16.0 --skip-zk. execve binds actual compiler; generated source includes overflow guard. Five calls passed, three in-range and two overflow refusals. Verify compile and runtime receipts, actual generated code and tool identities. For runtime replay copy compiled/ and probe.mjs into a private output subdirectory, byte verify copies, symlink its node_modules to read-only {cache/'p31-compact-runtime-tool/node_modules'} and run unchanged probe. Preserve artifacts and command hashes; do not mutate frozen sandbox or root package files. No new compile required unless a concrete discrepancy justifies it. Check no ZKIR/key/proof artifacts: this source exported pure circuits. Generated runtime evidence does not establish universal arithmetic or ZKIR soundness.

Judge whether these supplements accurately resolve the earlier missing frontend/bounds capture and unobserved Compact cast behavior for their explicitly bounded scope. They do not accept readiness tasks, adapters, full P31/P19/P20 or program. Full remaining pipeline and P20-dependent certificate consumption remain open. Identify concrete unsound claims, missing source/tool binding or overclaim; do not invent gates for limitations already explicit.

Write brief initial verdict early and final REVIEW.md, verdict.json, findings.json, commands.json (actualargv/cwd/exits/source/tool/probe/outputhashes), and self-excluding MANIFEST.json. Avoid expanding into proof/library implementation or broad additional campaigns. Reserve last4turns to finish ALL artifacts; root captures actual native model and adjudicates. Preserve failure evidence. Root independently verified R12 codec review already; this task reviews only two P31 supplements.
'''
(o/'brief.txt').write_text(brief);start=now();cmd=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','14']
with (o/'native.jsonl').open('x') as f,(o/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'started_utc':start,'pid':p.pid,'role':'auditor','scope':'P31 pinned source closure/simulation and generated Compact addition runtime preparation','requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(s),'brief_sha256':h(o/'brief.txt'),'status':'running','acceptance':False};write(o/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
