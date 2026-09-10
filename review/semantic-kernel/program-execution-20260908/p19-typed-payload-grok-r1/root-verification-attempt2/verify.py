from pathlib import Path
import json,hashlib,datetime,subprocess,re,os,gzip,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-typed-payload-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-typed-payload-grok-r1-sandbox');P=O/'private-lean';V=O/'root-verification-attempt2';T=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
proc=read(O/'process.json');assert proc['process_exit']==0 and proc['reported_models']==['grok-4.6-build'];assert not Path('/proc',str(read(O/'dispatch.json')['pid'])).exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(O)) or cwd.startswith(str(S))),(p.name,cwd)
assert h(O/'native.jsonl')==proc['log_sha256'];V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');inputs=read(O/'inputs.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
m=read(O/'MANIFEST.json');assert m['status']=='complete' and m['file_count']==len(m['files'])==46 and m['self_excluding'];verdict=read(O/'verdict.json');assert verdict['status']=='complete' and verdict['scoped_new_3']=='USABLE' and verdict['full_P19_accepted']==False
for row in m['files']:assert h(O/row['path'])==row['sha256'] and (O/row['path']).stat().st_size==row['bytes'],row['path']
rows=read(O/'commands.json')['commands'];assert len(rows)==7
for row in rows:
 meta=read(O/'logs'/row['id']/'meta.json')
 for k in ['id','argv','cwd','start','end','exit','timed_out']:assert row[k]==meta[k],(row['id'],k)
 for k in ['stdout','stderr']:assert h(O/row[k+'_path'])==row['raw'+k+'_sha256']
 assert row['exit']==0 and not row['timed_out'] and proc['started_utc']<=row['start']<=row['end']<=proc['finished_utc']
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
assert counts=={'CanonicalJson':136,'Correspondence':312,'Roundtrip':133}
probe=O/'probes/axioms581/Axioms.lean';assert h(probe)==h(B/'p19-r25-root-inventory/Axioms.lean');argv=[str(T/'lake'),'env',str(T/'lean'),str(probe)];start=now();run=subprocess.run(argv,cwd=P,capture_output=True,timeout=90);(V/'axioms.stdout').write_bytes(run.stdout);(V/'axioms.stderr').write_bytes(run.stderr);put(V/'command.json',{'argv':argv,'cwd':str(P),'started_utc':start,'finished_utc':now(),'exit':run.returncode,'probe_sha256':h(probe),'lean_sha256':h(T/'lean'),'lake_sha256':h(T/'lake'),'stdout_sha256':h(V/'axioms.stdout'),'stderr_sha256':h(V/'axioms.stderr'),'actor':'root','scope':'Fresh root probe using completed independent review build; not a further independent reviewer or rebuild.'});assert run.returncode==0
raw=run.stdout.decode();std=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",raw,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",raw);got=[n for n,a in std]+zero;assert len(got)==len(set(got))==581 and set(got)==set(names) and len(std)==523 and len(zero)==58;assert all(set(a.replace('\n',' ').replace(',',' ').split())<={'propext','Classical.choice','Quot.sound'} for _,a in std);assert run.stdout==(O/'logs/probe-axioms581/stdout').read_bytes()==(B/'p19-r25-root-inventory/axioms.stdout').read_bytes()
author=S/'review/semantic-kernel/certificates/p19/implementation/agy-r25-proof';ar=read(author/'commands.json');assert len(ar)==31
for row in ar:
 assert read(author/'logs'/row['id']/'command.json')==row
 for k in ['stdout','stderr']:assert h(author/row[k+'_path'])==row[k+'_sha256']
am=read(author/'MANIFEST.json');entries=am['files'];assert len(entries)==181
for row in entries:
 p=Path(row['path']);p=p if p.is_absolute() else S/p
 # R25 author manifest paths are relative to the repository snapshot.
 assert h(p)==row['sha256'],str(p)
sourcebindings=read(O/'logs/source-manifest-bindings.json');assert len(sourcebindings)==13
for row in sourcebindings:assert h(S/row['path'])==row['claimed']==row['actual']
events=[]
for line in (O/'native.jsonl').read_text().splitlines():
 try:events.append(json.loads(line))
 except json.JSONDecodeError:pass
calls=[e for e in events if e.get('type')=='tool_call'];shell=[e for e in calls if e.get('kind')=='execute'];assert len(shell)==8
# Preserve the two unrecorded failed setup calls and native responses without fabricating recorder streams.
setupcalls=[e for e in shell if e['rawInput'].get('command')=='python3 tools/setup_private_lean.py'];assert len(setupcalls)==2
updates=[e for e in events if e.get('type')=='tool_call_update' and e.get('toolCallId') in {c['toolCallId'] for c in setupcalls}];put(V/'native-setup-failures.json',{'calls':setupcalls,'updates':updates})
result={'utc':now(),'status':'completed_root_verified','candidate_archive_sha256':inputs['candidate_archive_sha256'],'input_bindings_verified':len(inputs['files']),'review_manifest_bindings':46,'private_lean_source_config_bindings':len(private),'reviewer_commands':7,'reviewer_raw_streams':14,'native_shell_calls':len(shell),'unrecorded_setup_failures':2,'author_manifest_bindings':181,'author_source_bindings':13,'author_command_records':31,'author_raw_streams':62,'explicit_theorem_counts':counts,'named_total':581,'standard_axioms':523,'zero_axioms':58,'forbidden_axioms':0,'root_probe_equals_reviewer_and_prior_root_stdout':True,'process_exit':0,'all_five_final_reports_complete':True,'reported_models':proc['reported_models'],'session':proc['sessions'][0],'scope':'Three new qualified-port/output-observation/typed-payload lemmas usable; full P19 remains CHANGES_REQUIRED','acceptance':False};put(V/'result.json',result)
adj={**result,'remaining':verdict['remaining_open'],'scope_notes':['Seven recorded successful proof/tool commands are distinct from eight native shell calls; two setup cwd failures are preserved in native telemetry.','The fresh review build visibly rebuilds Roundtrip and Verify. Lake target totals 933/938 do not count newly compiled modules or establish a full DefiKernel build.','Independent sandbox walk 5107 is distinct from frozen author archive 4649 and the separately verified dispatch input map.','Model unknown in pre-terminal reports is resolved by terminal telemetry as grok-4.6-build; original reports remain unchanged.','R25 typed payload inversion is component progress. Existing depth, module decoder and lexical scan premises are not discharged.'],'full_P19_accepted':False};put(O/'root-adjudication.json',adj)
with (O/'native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name!='native.jsonl':files[str(p.relative_to(O))]=h(p)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_files':len(files),**result}))
