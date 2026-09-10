from pathlib import Path
import json,hashlib,datetime,gzip,shutil,os
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-parser-bridge-grok-r1';c=o/'closeout';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o/'root-seal.json').exists()
for pid in [1796002,1842357]:assert not Path('/proc').joinpath(str(pid)).exists()
i=read(o/'inputs.json');sandbox=Path(i['sandbox'])
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(o)) or cwd.startswith(str(sandbox))) and comm in ['grok','lean','lake','node']),(p.name,comm,cwd)
for n,v in i['files'].items():assert h(sandbox/n)==v,n
for d in [o,c]:
 proc=read(d/'process.json');assert h(d/'native.jsonl')==proc['log_sha256'];assert proc['reported_models']==['grok-4.6-build'];assert proc['sessions']==['01a08bdf-5a94-7ba0-b04d-697686708e06']
assert read(c/'process.json')['process_exit']==0
m=read(c/'MANIFEST.json');refs=m['files']+m['references']
for f in refs:assert h(c/f['path'])==f['sha256'],f['path']
commands=read(c/'commands.json');bindings=[]
for item in commands['commands']:
 for k,v in item.items():
  if isinstance(v,str) and k+'_sha256' in item and (c/v).is_file():
   assert h(c/v)==item[k+'_sha256'],(item['id'],k)
   bindings.append({'command':item['id'],'field':k,'sha256':item[k+'_sha256']})
tools=commands['compiler_pin']
for k in ['lean_bin','lake_bin']:assert h(Path(tools[k]))==tools[k+'_sha256']
shared=Path(tools['lean_bin']).parent.parent/'lib/lean/libleanshared.so';assert h(shared)==tools['libleanshared_so_sha256']
ax=read(o/'root-verification/axioms200-command.json');replay=read(o/'root-verification/replay-r13-command.json')
assert ax['exit']==0 and ax['exact_names_match'] and ax['axiom_records']==196 and ax['zero_axiom_records']==4 and not ax['forbidden']
assert replay['exit']==0 and replay['exact_stdout_match'] and replay['exact_stderr_match']
for src,name in [('/tmp/defiformal-p19-parser-bridge-root-verify.py','verify.py'),('/tmp/defiformal-p19-r13-root-replay.py','replay.py')]:shutil.copy2(src,o/'root-verification'/name)
shutil.copy2(__file__,o/'root-seal-verify.py')
with (c/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
write(o/'root-adjudication.json',{'schema':'defiformal-root-review-adjudication/v1','utc':now(),'candidate':'AGY R13','candidate_archive_sha256':i['candidate_archive_sha256'],'verdict':'CHANGES_REQUIRED','reviewer_actual_model':'grok-4.6-build','reviewer_session':'01a08bdf-5a94-7ba0-b04d-697686708e06','review_lifecycle':'Fresh original independent review reached25turn cap; same-session reporting closeout terminated successfully. No new independent reviewer is claimed for closeout.','frozen_inputs_verified':len(i['files']),'review_manifest_bindings_verified':len(refs),'command_path_hash_bindings_verified':bindings,'compiler_binary_hashes_verified':3,'root_exact_named_theorems':200,'standard_axioms_only':196,'zero_axioms':4,'root_replay':replay,'accepted_component_evidence':['General escaped-string tokenizer/parser inversion and actual decodeDecodedIR bridge are proved components.','Canonical claimed-state and libraryRef object helpers align at documented scope.','Current lexical final-component refusal preserves live relative/dangling/absolute-link controls.'],'remaining_R13_gaps':['Arbitrary source-map inverse assumes decoder success in R13.','R13 fuel lemmas prove numerical inequality only, not stability/parser agreement.','Universal actual byte roundtrip remains open.','R13 relative-link regression itself is dangling, although independent live-relative control succeeds.'],'historical_resolution_note':'Frozen R14 separately adds source-map inverse, inductive fuel stability and live-relative regression. Root217 checked; independent R14 review pending. Do not transfer R13 approval to R14.','evidence_limitations':['Initial ProbeR13 failed source was overwritten; retain failure stdout without reconstructing source or granting success credit.','Earlier failed inline-axiom log overwritten by retry; failure has zero credit.','commands.json fresh_session true describes original review; actual closeout dispatch is fresh_session false.','Parent-symlink fresh-child exit1 is later missing-fixture failure, not symlink refusal or successful pipeline evidence.','No full54/99/16 campaign or F01 replay in this review.'],'acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False})
files=[]
for parent,dirs,names in os.walk(o):
 dirs[:]=[x for x in dirs if x not in ['private-lean','.lake','node_modules','__pycache__','.git']]
 for name in names:
  p=Path(parent)/name
  if p.is_symlink() or not p.is_file() or name=='native.jsonl':continue
  files.append({'path':str(p.relative_to(o)),'sha256':h(p),'bytes':p.stat().st_size})
write(o/'root-seal.json',{'schema':'defiformal-root-review-seal/v1','utc':now(),'files':sorted(files,key=lambda f:f['path']),'file_count':len(files),'frozen_inputs_verified':len(i['files']),'manifest_bindings_verified':len(refs),'excluded':['private-lean and rebuildable caches','native.jsonl retained as separately hashed gzip','symlinks'],'acceptance':False})
for f in files:assert h(o/f['path'])==f['sha256']
print(json.dumps({'sealed_files':len(files),'manifest_bindings':len(refs),'command_bindings':len(bindings),'root_axioms':200,'root_replay_exact':True,'acceptance':False}))
