from pathlib import Path
import json,hashlib,gzip,datetime,shutil,os
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-byte-pipeline-grok-r1';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o/'root-seal.json').exists();assert not Path('/proc/1904466').exists();proc=read(o/'process.json');assert proc['process_exit']==1 and proc['terminal_events'][-1]['num_turns']==30;assert h(o/'native.jsonl')==proc['log_sha256'];assert proc['reported_models']==['grok-4.6-build'];i=read(o/'inputs.json');sandbox=Path(i['sandbox'])
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not ((cwd.startswith(str(o)) or cwd.startswith(str(sandbox))) and comm in ['grok','lean','lake','node']),(p.name,comm,cwd)
for n,v in i['files'].items():assert h(sandbox/n)==v,n
m=read(o/'MANIFEST.json');refs=m['files']
for f in refs:assert h(o/f['path'])==f['sha256'],f['path']
commands=read(o/'commands.json');bindings=[]
for item in commands['commands']:
 for k,v in item.items():
  if isinstance(v,str) and k+'_sha256' in item and (o/v).is_file():assert h(o/v)==item[k+'_sha256'],(item['id'],k);bindings.append({'command':item['id'],'field':k,'sha256':item[k+'_sha256']})
tools=commands['compiler_pin']
for k in ['lean_bin','lake_bin']:assert h(Path(tools[k]))==tools[k+'_sha256']
assert h(Path(tools['lean_bin']).parent.parent/'lib/lean/libleanshared.so')==tools['libleanshared_so_sha256']
ax=read(o/'root-verification/axioms247-command.json');replays=read(o/'root-verification/replay-controls.json');assert ax['exit']==0 and ax['exact_names_match'] and ax['axiom_records']==236 and ax['zero_axiom_records']==11 and not ax['forbidden'];assert len(replays)==2 and all(x['exit']==0 and x['exact_stdout_match'] and x['exact_stderr_match'] for x in replays)
for src,name in [('/tmp/defiformal-p19-byte-pipeline-root-verify.py','verify.py'),('/tmp/defiformal-p19-r15-review-root-replay.py','replay.py')]:shutil.copy2(src,o/'root-verification'/name)
shutil.copy2(__file__,o/'root-seal-verify.py')
with (o/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
enc=sandbox/'lean/DefiKernel/Certificates/Encode.lean';s=enc.read_text();a=s.index('def encodeEnvelope');z=s.index('def encodeTypedExecutePayload',a);env=s[a:z];assert 'qsort' not in env and 'jsonObj [' in env
erratum={'utc':now(),'incorrect_root_statement':'encodeEnvelope sorts its fields','correct_statement':'encodeEnvelope passes its fields to jsonObj in declaration order. jsonObj preserves supplied order. encodeSourceMap separately sorts source-map entries. Lean.Json.mkObj sorts its internal map.','frozen_Encode_sha256':h(enc),'encodeEnvelope_definition':env,'impact':'Earlier root briefs R14/R15/R16 contain the mistaken envelope-sorting note. Preserve them as historical instructions, correct future briefs, and prove parsing actual encoder output equals helper Json without inventing raw .compress equality.','source_code_change':False}
write(b/'p19-production-order-root-correction.json',erratum)
write(o/'root-adjudication.json',{'schema':'defiformal-root-review-adjudication/v1','utc':now(),'candidate':'AGY R15','candidate_archive_sha256':i['candidate_archive_sha256'],'verdict':'CHANGES_REQUIRED','reviewer_actual_model':'grok-4.6-build','reviewer_session':proc['sessions'][0],'review_lifecycle':'Fresh independent review reached30turn cap after writing complete reports and manifest; terminal exit1 preserved. Artifact completeness/hash checks independently verified; no reporting resume needed.','frozen_inputs_verified':len(i['files']),'manifest_bindings_verified':len(refs),'command_path_hash_bindings_verified':bindings,'compiler_binary_hashes_verified':3,'root_exact_named_theorems':247,'standard_axioms_only':236,'zero_axioms':11,'root_replays':replays,'verified_component_evidence':['R15 named theorem inventory compiles with standard axioms only.','Actual UTF8/pipeline decomposition is proved conditionally on lexical and parser success.','Context parser steps are useful facts conditional on child fold success.','Independent escaped-key runtime diagnostic and extra duplicate/escape controls exactly replay.'],'remaining':['Repair lexical false-duplicate identity on control-character versus literal escape spelling.','Prove h_lex and h_parse from declared domain and compose unconditional universal byte roundtrip.','Complete actual recursive parser induction and generic numeric/rational inverses.','Formal admissibility of the escaped-key witness remains unproved; failed decide/sorryAx attempt has zero proof credit.','Correct resolves-all-findings wording and Verify scope reporting in future author artifacts.'],'root_correction':'p19-production-order-root-correction.json: root earlier envelope-sorting claim was wrong; reviewer declaration-order account is correct.','Verify_scope_note':'R15 author log Certificates1392/2520, Typed420/677, Composition287/408. These prefix counts are distinct from exact247 inventory; review inspected historical log, not a new Verify run.','acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False})
files=[]
for parent,dirs,names in os.walk(o):
 dirs[:]=[x for x in dirs if x not in ['private-lean','.lake','node_modules','__pycache__','.git']]
 for name in names:
  p=Path(parent)/name
  if p.is_symlink() or not p.is_file() or name=='native.jsonl':continue
  files.append({'path':str(p.relative_to(o)),'sha256':h(p),'bytes':p.stat().st_size})
write(o/'root-seal.json',{'schema':'defiformal-root-review-seal/v1','utc':now(),'files':sorted(files,key=lambda f:f['path']),'file_count':len(files),'frozen_inputs_verified':len(i['files']),'manifest_bindings_verified':len(refs),'excluded':['private-lean and rebuildable caches','native.jsonl retained in separately hashed gzip','symlinks'],'acceptance':False})
for f in files:assert h(o/f['path'])==f['sha256']
print(json.dumps({'sealed_files':len(files),'manifest_bindings':len(refs),'command_bindings':len(bindings),'root_axioms':247,'root_replays_exact':2,'acceptance':False}))
