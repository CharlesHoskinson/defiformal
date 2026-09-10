from pathlib import Path
import datetime,hashlib,json,re,subprocess,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-tree-text-grok-r1';C=O/'closeout';R=O/'root-verification';W=O/'private-lean'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2244055').exists() and not Path('/proc/2218999').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve())
 except (OSError,RuntimeError):continue
 assert not cwd.startswith(str(O)),(p.name,cwd)
R.mkdir(exist_ok=False)
p=read(C/'process.json');assert p['process_exit']==0 and p['sessions']==['01a08cf0-d95c-7841-bbfa-0df382cd9d45'] and p['reported_models']==['grok-4.6-build'] and h(C/'native.jsonl')==p['log_sha256']
seal=read(O/'original-terminal/root-seal.json')
for n,d in seal['files'].items():assert h(O/'original-terminal'/n)==d,n
inputs=read(O/'inputs.json');S=Path(inputs['sandbox'])
for n,d in inputs['files'].items():assert h(S/n)==d,n
m=read(C/'MANIFEST.json');assert m['file_count']==len(m['files'])==48
for row in m['files']:
 path=(C/row['path']).resolve();assert path.is_relative_to(O) and h(path)==row['sha256'] and path.stat().st_size==row['bytes'],row['path']
commands=read(C/'commands.json')['commands'];assert len(commands)==9
for row in commands:
 raw=read(O/'logs'/row['id']/'meta.json');assert row==raw,row['id']
 for stream in ['stdout','stderr']:assert h(O/row[stream+'_path'])==row['raw'+stream+'_sha256']
candidate=read(B/'p19-roundtrip-proof-agy-r21-terminal-manifest.json');source_count=0
for row in candidate['files']:
 if row['path'].startswith('lean/DefiKernel/Certificates/'):
  assert h(W/row['path'].removeprefix('lean/'))==row['sha256'],row['path'];source_count+=1
names=[]
for module in ['CanonicalJson','Correspondence']:
 names+=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',(W/f'DefiKernel/Certificates/{module}.lean').read_text(),re.M)
expected=['DefiKernel.Certificates.'+n for n in names];assert len(expected)==len(set(expected))==448
probe=R/'Probe448.lean';shutil.copy2(O/'probes/axioms448/Probe.lean',probe)
assert re.findall(r'^#print axioms (\S+)',probe.read_text(),re.M)==expected
identity=read(O/'logs/compiler-identity.json');tool=Path(identity['lean_bin']).parent
assert h(tool/'lean')==identity['lean_bin_sha256'] and h(tool/'lake')==identity['lake_bin_sha256']
argv=[str(tool/'lake'),'env',str(tool/'lean'),str(probe)];start=now();run=subprocess.run(argv,cwd=W,capture_output=True,timeout=180);end=now();(R/'stdout').write_bytes(run.stdout);(R/'stderr').write_bytes(run.stderr)
put(R/'command.json',{'argv':argv,'cwd':str(W),'started_utc':start,'finished_utc':end,'exit':run.returncode,'probe_sha256':h(probe),'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),'stdout_sha256':h(R/'stdout'),'stderr_sha256':h(R/'stderr')})
assert run.returncode==0 and not run.stderr and run.stdout==(O/'logs/probe-axioms448/stdout').read_bytes()
text=run.stdout.decode();pairs=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",text,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",text)
assert len(pairs)==415 and len(zero)==33 and set(n for n,_ in pairs)|set(zero)==set(expected)
assert all(set(x.strip() for x in a.split(',') if x.strip())<={'propext','Classical.choice','Quot.sound'} for _,a in pairs)
verdict=read(C/'verdict.json');assert verdict['status']=='complete' and verdict['scoped_generic_text_inverse']=='USABLE' and not verdict['full_P19_accepted']
result={'utc':now(),'input_bindings_verified':len(inputs['files']),'manifest_bindings_verified':48,'private_certificate_sources_verified':source_count,'reviewer_commands_verified':9,'reviewer_raw_streams_verified':18,'source_theorem_lemma_count':448,'standard_axiom_records':415,'zero_axiom_records':33,'root_probe_stdout_byte_equal_reviewer':True,'reviewer_model_original_and_closeout':'grok-4.6-build','same_review_session':p['sessions'][0],'generic_text_inverse':'USABLE','full_P19':'CHANGES_REQUIRED','command_path_correction':'closeout/commands.json copies all9 original command records byte-for-field. Their stdout_path/stderr_path logs/... resolve from the parent review directory, despite top-level paths_resolve_from declaring closeout. Final MANIFEST uses correct ../logs/... paths. Root verifies against original per-command receipts without changing their original paths.','root_prior_correction':'Original root closeout brief set_option explanation was false: exact source/stream differences are three #eval marker lines. Reviewer final report correctly identifies them.','limits':['Main EncodeDecodeRoundtripStatement and whole-module/scanner composition remain open.','No new54/99/16 or7/21 campaign. Original author report gap remains explicit.','CanonicalJson inline helper86of157 exit1 has zero complete-file credit; successful448probe carries axiom evidence.'],'P19_accepted':False,'whole_program_complete':False}
put(R/'assessment.json',result);shutil.copy2(__file__,R/'verify.py');files={p.name:h(p) for p in R.iterdir() if p.is_file()};put(R/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:v for k,v in result.items() if k not in ['limits','command_path_correction','root_prior_correction']}))
