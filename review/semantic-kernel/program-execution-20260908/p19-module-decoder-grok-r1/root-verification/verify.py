from pathlib import Path
import json,hashlib,datetime,subprocess,re,os,gzip,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-module-decoder-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-decoder-grok-r1-sandbox');P=O/'private-lean';V=O/'root-verification';T=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
proc=read(O/'process.json');assert proc['process_exit']==0 and proc['reported_models']==['grok-4.6-build'];assert not Path('/proc',str(read(O/'dispatch.json')['pid'])).exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(p.name,cwd)
assert h(O/'native.jsonl')==proc['log_sha256'];V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');inputs=read(O/'inputs.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
m=read(O/'MANIFEST.json');assert m['status']=='complete' and m['file_count']==len(m['files'])==49 and m['self_excluding'];verdict=read(O/'verdict.json');assert verdict['status']=='complete' and verdict['scoped_new_27']=='USABLE' and verdict['full_P19_accepted']==False
for row in m['files']:assert h(O/row['path'])==row['sha256'] and (O/row['path']).stat().st_size==row['bytes'],row['path']
rows=read(O/'commands.json')['commands'];assert len(rows)==7
for row in rows:
 meta=read(O/'logs'/row['id']/'meta.json')
 for k in ['id','argv','cwd','start','end','exit','timed_out']:assert row[k]==meta[k],(row['id'],k)
 for k in ['stdout','stderr']:assert h(O/row[k+'_path'])==row['raw'+k+'_sha256']
 assert row['exit']==0 and not row['timed_out'] and proc['started_utc']<=row['start']<=row['end']<=proc['finished_utc']
index=[json.loads(line) for line in (O/'logs/command-index.jsonl').read_text().splitlines()]
assert len(index)==7
for row in index:assert row==read(O/'logs'/row['id']/'meta.json'),row['id']
private={}
for parent,dirs,names in os.walk(P):
 dirs[:]=[d for d in dirs if d not in ['.lake','.git','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if p.suffix=='.lean' or name in ['lakefile.toml','lake-manifest.json','lean-toolchain']:
   q=S/'lean'/p.relative_to(P);assert q.is_file() and h(p)==h(q),p;private[str(p.relative_to(P))]=h(p)
assert len(private)==200;put(V/'private-source-bindings.json',private)
names=[];counts={}
for module in ['CanonicalJson','Correspondence','Roundtrip']:
 text=(P/f'DefiKernel/Certificates/{module}.lean').read_text();found=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',text,re.M);counts[module]=len(found);names+=['DefiKernel.Certificates.'+n for n in found]
assert counts=={'CanonicalJson':136,'Correspondence':312,'Roundtrip':160}
probe=O/'probes/axioms608/Axioms.lean';assert h(probe)==h(B/'p19-r26-root-inventory/Axioms.lean');argv=[str(T/'lake'),'env',str(T/'lean'),str(probe)];start=now();run=subprocess.run(argv,cwd=P,capture_output=True,timeout=90);(V/'axioms.stdout').write_bytes(run.stdout);(V/'axioms.stderr').write_bytes(run.stderr);put(V/'command.json',{'argv':argv,'cwd':str(P),'started_utc':start,'finished_utc':now(),'exit':run.returncode,'probe_sha256':h(probe),'lean_sha256':h(T/'lean'),'lake_sha256':h(T/'lake'),'stdout_sha256':h(V/'axioms.stdout'),'stderr_sha256':h(V/'axioms.stderr'),'actor':'root','scope':'Fresh root probe using completed independent review build; not a further independent reviewer or rebuild.'});assert run.returncode==0
raw=run.stdout.decode();std=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",raw,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",raw);got=[n for n,a in std]+zero;assert len(got)==len(set(got))==608 and set(got)==set(names) and len(std)==550 and len(zero)==58;assert all(set(a.replace('\n',' ').replace(',',' ').split())<={'propext','Classical.choice','Quot.sound'} for _,a in std);assert run.stdout==(O/'logs/probe-axioms608/stdout').read_bytes()==(B/'p19-r26-root-inventory/axioms.stdout').read_bytes()
author=S/'review/semantic-kernel/certificates/p19/implementation/agy-r26-proof';ar=read(author/'commands.json');assert len(ar)==159
for row in ar:
 assert read(author/'logs'/row['id']/'command.json')==row
 for k in ['stdout','stderr']:assert h(author/row[k+'_path'])==row[k+'_sha256']
am=read(author/'MANIFEST.json');entries=am['files'];assert len(entries)==38
for row in entries:
 p=Path(row['path']);p=p if p.is_absolute() else S/p
 # R26 author manifest paths are relative to the repository snapshot.
 assert h(p)==row['sha256'],str(p)
sourcebindings=read(O/'logs/source-manifest-bindings.json');assert len(sourcebindings)==13
for row in sourcebindings:assert h(S/row['path'])==row['claimed']==row['actual']
events=[]
for line in (O/'native.jsonl').read_text().splitlines():
 try:events.append(json.loads(line))
 except json.JSONDecodeError:pass
calls=[e for e in events if e.get('type')=='tool_call'];shell=[e for e in calls if e.get('kind')=='execute'];assert len(shell)==6
# Preserve the unrecorded failed setup call and native responses without fabricating recorder streams.
setupcalls=[e for e in shell if e['rawInput'].get('command')=='python3 tools/setup_private_lean.py'];assert len(setupcalls)==1
updates=[e for e in events if e.get('type')=='tool_call_update' and e.get('toolCallId') in {c['toolCallId'] for c in setupcalls}];put(V/'native-setup-failures.json',{'calls':setupcalls,'updates':updates})
put(V/'native-shell-evidence.json',{'calls':shell,'updates':[e for e in events if e.get('type')=='tool_call_update' and e.get('toolCallId') in {c['toolCallId'] for c in shell}]})
result={'utc':now(),'status':'completed_root_verified','candidate_archive_sha256':inputs['candidate_archive_sha256'],'input_bindings_verified':len(inputs['files']),'review_manifest_bindings':49,'private_lean_source_config_bindings':len(private),'reviewer_commands':7,'reviewer_raw_streams':14,'native_shell_calls':len(shell),'unrecorded_setup_failures':1,'author_manifest_bindings':38,'author_source_bindings':13,'author_command_records':159,'author_raw_streams':318,'explicit_theorem_counts':counts,'named_total':608,'standard_axioms':550,'zero_axioms':58,'forbidden_axioms':0,'root_probe_equals_reviewer_and_prior_root_stdout':True,'process_exit':0,'all_five_final_reports_complete':True,'reported_models':proc['reported_models'],'session':proc['sessions'][0],'scope':'Twenty-seven new lemmas and whole module decoder composition usable under unchanged structural admission; full P19 remains CHANGES_REQUIRED','acceptance':False};put(V/'result.json',result)
adj={**result,'h_dec_discharged':True,'remaining':[f for f in read(O/'findings.json')['findings'] if f['status']=='open'],'scope_notes':['Seven recorded successful proof/tool commands are distinct from six native shell calls: one failed setup, one successful setup containing three commands, one build driver containing three commands, one full axiom probe, and two read/hash/report operations. All native calls and updates are preserved.','Fresh review build visibly rebuilds Roundtrip and Verify. Target totals933/938 do not count newly compiled modules or establish full DefiKernel.','Independent sandbox walk5949 is distinct from frozen author archive5483 and dispatch5781bindings.','Returned model unknown in pre-terminal reports is resolved by terminal telemetry as grok-4.6-build; original reports remain unchanged.','Actual envelope traversal theorem avoids false raw-tree permutation equality. R26 report incorrectly described Json.mkObj equality.','Whole module decoder composition discharges h_dec under existing admission for typed/step/run; audit/codec are excluded by existing SupportedIR. Store inverse is unconditional; reduced nonnegative rational checks concern state cells.','h_depth and h_lex remain open. No universal roundtrip or full99scenario/16mutant/overlay/schema/hash/expectedIR/host acceptance.','Author MANIFEST38binding matches omit318streams; root separately verifies all159records and318rawstreams in the5483file archive.'],'full_P19_accepted':False};put(O/'root-adjudication.json',adj)
with (O/'native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name!='native.jsonl':files[str(p.relative_to(O))]=h(p)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_files':len(files),**result}))
