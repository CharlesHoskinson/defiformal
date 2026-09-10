from pathlib import Path
import json,hashlib,datetime,subprocess,os,shutil,tarfile
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';c=Path('/home/charl/.cache/defiformal-program/program-execution-20260908');o=b/'p19-container-codec-grok-r1';s=c/'p19-container-codec-grok-r1-sandbox';base=c/'p19-overlay-grok-r1-sandbox';cachebase=b/'p19-general-codec-grok-r1/private-lean/.lake';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert (b/'p24-source-diagnostic-grok-r1/root-seal.json').exists();assert (cachebase/'build').is_dir();o.mkdir(exist_ok=False);s.mkdir(exist_ok=False)
for parent,dirs,names in os.walk(base):
 dirs[:]=[x for x in dirs if x not in ['.git','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if p.is_file() and not p.is_symlink():q=s/p.relative_to(base);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
m=json.loads((b/'p19-roundtrip-proof-agy-r11-terminal-manifest.json').read_text());a=b/m['archive'];assert h(a)==m['sha256']
with tarfile.open(a) as t:t.extractall(s,filter='data')
for f in m['files']:assert h(s/f['path'])==f['sha256'],f['path']
for n in ['p19-roundtrip-proof-agy-r11-root-precheck.json','p19-roundtrip-proof-agy-r11-terminal-manifest.json','p19-general-codec-grok-r1/root-adjudication.json','p19-proof-r11-historical-evidence-overwrite/restoration.json','P19-PLANNING-ACCEPTANCE.md']:
 q=s/'root-context'/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(b/n,q)
files={str(p.relative_to(s)):h(p) for p in s.rglob('*') if p.is_file()};(s/'lean/.lake').mkdir();os.symlink(cachebase/'packages',s/'lean/.lake/packages',target_is_directory=True);subprocess.run(['cp','-a','--reflink=auto',str(cachebase/'build'),str(s/'lean/.lake/build')],check=True);write(o/'inputs.json',{'schema':'defiformal-string-domain-review-inputs/v1','utc':now(),'sandbox':str(s),'candidate_archive_sha256':m['sha256'],'files':files,'files_verified':len(files),'private_build_cache':True,'packages':'Pinned package dependencies shared read-only; never modify/update packages','acceptance':False})
brief=f"""Fresh native Grok4.6 high independent audit of frozen P19 R11 general container/payload codecs. Sandbox {s}, output {o}, exact archive {m['sha256']}, all {m['file_count']} files verified. AGY R12 writes elsewhere; NEVER read live author source, output, or build cache. No subagents/Foreman/network/production edits/commits/branches/pushes. Pinned package dependencies read-only; your copied build cache is independent. Rebuild changed imports before audit. Source inputs must remain byte-identical; probes/private copies belong under output. Lean4.33.0-rc2 pinned, no updates.

User explicitly requests cameronfreer/lean4-skills. Read /home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/skills/lean4/SKILL.md and apply read-only review workflow. Helpers use literal absolute bin paths; lean4-skills-preflight --codex checks that installed wrapper contract. Use live LSP if available in your native harness; otherwise file-level lake checks. Record actual profile. Sole branch is semantic-kernel-pivot, worker copies detached; earlier AGENTS branch/model instructions are historical. Root adjudicates acceptance; this is R11 component audit only, full P19 open.

Read root-context R11 precheck, production Schema/CanonicalJson/Encode/Decode/Correspondence/Tests and new agy-r11-proof evidence. R11 has actual167 source theorems =15CanonicalJson+152Correspondence; author catalog165 differs. New17 general inverses cover libraryRef/Nat/NatList/state/request/operation/component/config/world/boundary/inputSource/invocation/step/outputObservation/typed-step-run payloads. Full EncodeDecodeRoundtripStatement remains a def Prop. Determine what those lemmas actually prove and how they connect to real production serialization. Do not credit helper inversion as whole byte/IR theorem.

Priorities, within35turns:
1. Independently compile new container/payload general proofs and run complete exact-name axiom inventory (standard only). Inspect duplicate keys/registry assumptions, arbitrary nonempty arrays/maps/config/world/boundaries, operand domain/rational representation, and missing hypotheses. Examine statement strength and serializer consistency. Name any valid progress separately from open whole-codec obligation.
2. Verify root R11 depth and sourcePin findings with a small discriminating probe or actual source. Scalars contribute1 to jsonDepth; root guard AST58 decodes successfully but computed65 fails<=64. sourcePinToJson omits compiler_record/audit_record and restricts bothnone. Check correct full domain connection; supported execution-only scope explicitly excludes audit/codec, so null helpers for excluded modes alone are not a defect. R11 decodeBytes now preserves resourceLimit; verify focused public array/depth boundary classifications and remaining limits. Avoid replaying unchanged R10 counterexamples or full fixture campaigns.
3. Verify report/source identities and count mismatch (actual fuels100, report256/65536). R11 historically overwrote3R5 evidence files; root preserved newbytes and restored historical originals before freeze. Assess actual runner --out default and consequences, do not mutate historical evidence or rerun it. R11 fresh fullcampaign output is not universal proof; known F13 expectedIRnull/host/overlay obligations remain outside this bounded review and open.

Write initial REVIEW.md/verdict.json early, then complete REVIEW.md, verdict.json, findings.json, exact commands.json with cwd/argv/exits/tool+probe+output hashes, and self-excluding MANIFEST.json. Reserve last5turns for closeout, collect children. Preserve failed attempts. No fabricated actual model identity. Scope verdict must separate correctly checked component theorems from resource/domain fixes and full theorem gaps; full P19 acceptance false.
"""
(o/'brief.txt').write_text(brief);start=now();cmd=['grok','-p',brief,'--model','grok-4.6','--reasoning-effort','high','--no-subagents','--disable-web-search','--permission-mode','bypassPermissions','--output-format','streaming-json','--max-turns','35']
with (o/'native.jsonl').open('x') as f,(o/'native.stderr').open('x') as e:
 p=subprocess.Popen(cmd,cwd=s,stdout=f,stderr=e);d={'schema':'defiformal-native-dispatch/v3','started_utc':start,'role':'auditor','scope':'Frozen R11 container codec proofs and resource fidelity audit','pid':p.pid,'requested_model':'grok-4.6','effort':'high','fresh_session':True,'sandbox':str(s),'brief_sha256':h(o/'brief.txt'),'status':'running','acceptance':False};write(o/'dispatch.json',d);print(json.dumps(d),flush=True);code=p.wait()
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
