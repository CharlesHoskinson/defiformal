from pathlib import Path
import json,hashlib,datetime,gzip,shutil,os
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-structural-admissibility-grok-r1';c=o/'closeout';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o/'root-seal.json').exists()
for pid in [1861558,1889219]:assert not Path('/proc').joinpath(str(pid)).exists()
i=read(o/'inputs.json');sandbox=Path(i['sandbox'])
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(o)) or cwd.startswith(str(sandbox))) and comm in ['grok','lean','lake','node']),(p.name,comm,cwd)
for n,v in i['files'].items():assert h(sandbox/n)==v,n
for d in [o,c]:
 proc=read(d/'process.json');assert h(d/'native.jsonl')==proc['log_sha256'];assert proc['reported_models']==['grok-4.6-build'];assert proc['sessions']==['01a08bfc-7e0f-7520-a6a0-52b78b622f0f']
closeout_process=read(c/'process.json')
assert closeout_process['process_exit']==1 and closeout_process['terminal_events'][-1]['num_turns']==8
for n in ['REVIEW.md','verdict.json','findings.json','commands.json']:assert (o/n).read_bytes()==(c/n).read_bytes(),n
m=read(c/'MANIFEST.json');refs=m['files']+m['references']
for f in refs:assert h(c/f['path'])==f['sha256'],f['path']
commands=read(c/'commands.json');bindings=[]
for item in commands['commands']:
 for k,v in item.items():
  if isinstance(v,str) and k+'_sha256' in item and (o/v).is_file():
   assert h(o/v)==item[k+'_sha256'],(item['id'],k)
   bindings.append({'command':item['id'],'field':k,'sha256':item[k+'_sha256']})
tools=commands['compiler_pin']
for k in ['lean_bin','lake_bin']:assert h(Path(tools[k]))==tools[k+'_sha256']
shared=Path(tools['lean_bin']).parent.parent/'lib/lean/libleanshared.so';assert h(shared)==tools['libleanshared_so_sha256']
ax=read(o/'root-verification/axioms217-command.json');replay=read(o/'root-verification/replay-r14-command.json')
assert ax['exit']==0 and ax['exact_names_match'] and ax['axiom_records']==210 and ax['zero_axiom_records']==7 and not ax['forbidden']
assert replay['exit']==0 and replay['exact_stdout_match'] and replay['exact_stderr_match']
for src,name in [('/tmp/defiformal-p19-structural-admissibility-root-verify.py','verify.py'),('/tmp/defiformal-p19-r14-root-replay.py','replay.py')]:shutil.copy2(src,o/'root-verification'/name)
shutil.copy2(__file__,o/'root-seal-verify.py')
with (c/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
write(o/'root-adjudication.json',{'schema':'defiformal-root-review-adjudication/v1','utc':now(),'candidate':'AGY R14','candidate_archive_sha256':i['candidate_archive_sha256'],'verdict':'CHANGES_REQUIRED','reviewer_actual_model':'grok-4.6-build','reviewer_session':'01a08bfc-7e0f-7520-a6a0-52b78b622f0f','review_lifecycle':'Fresh independent R14 review reached25turn cap; same-session manifest-only closeout also reached8turn cap AFTER producing complete hash-verified manifest and note. Both native exits1 retained; original four reports preserved byte-identically. Artifact completeness is independently checked, not inferred from CLI exit.','frozen_inputs_verified':len(i['files']),'review_manifest_bindings_verified':len(refs),'command_path_hash_bindings_verified':bindings,'compiler_binary_hashes_verified':3,'root_exact_named_theorems':217,'standard_axioms_only':210,'zero_axioms':7,'root_replay':replay,'verified_component_evidence':['General sourceMap inverse from SourceMapSorted removes prior assumed subdecoder success.','Inductive depth and maximum-array fuel stability covers arrays and objects under strict depth/fuel condition.','Actual decodeDecodedIR_of_structurallyAdmissible connects the full declared supported execution domain to object decoding.','Live relative sibling symlink regression correctly checks resolution and sentinel preservation.'],'remaining_gaps':['Universal EncodeDecodeRoundtripStatement remains an open Prop; recursive parser, lexical scan, UTF8 and actual byte serialization bridge remain required.','parser_max_* return domain hypotheses; jsonMaxArrayLengthFuel_adequate is an inequality alias, not parser agreement.','Author auditor_model role label and Verify.lean aggregate counts do not identify this review or replace exact217 evidence.'],'evidence_limitations':['Original review reports retain returned_model null; native process receipts independently establish grok-4.6-build.','Copied report log/probe paths resolve from original parent output directory; closeout MANIFEST references resolve from closeout.','Failed inline-axiom helper and initial axiom-output parser attempts have zero proof-check credit; successful multiline exact-name audit is separate.','Witness byte decoding and small fuel/source-map diagnostics are bounded checks, not the universal roundtrip proof.','No F01, full54/99/16 or unchanged21 runtime campaign rerun in this review.'],'acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False})
files=[]
for parent,dirs,names in os.walk(o):
 dirs[:]=[x for x in dirs if x not in ['private-lean','.lake','node_modules','__pycache__','.git']]
 for name in names:
  p=Path(parent)/name
  if p.is_symlink() or not p.is_file() or name=='native.jsonl':continue
  files.append({'path':str(p.relative_to(o)),'sha256':h(p),'bytes':p.stat().st_size})
write(o/'root-seal.json',{'schema':'defiformal-root-review-seal/v1','utc':now(),'files':sorted(files,key=lambda f:f['path']),'file_count':len(files),'frozen_inputs_verified':len(i['files']),'manifest_bindings_verified':len(refs),'excluded':['private-lean and rebuildable caches','native.jsonl retained as separately hashed gzip','symlinks'],'acceptance':False})
for f in files:assert h(o/f['path'])==f['sha256']
print(json.dumps({'sealed_files':len(files),'manifest_bindings':len(refs),'command_bindings':len(bindings),'root_axioms':217,'root_replay_exact':True,'acceptance':False}))
