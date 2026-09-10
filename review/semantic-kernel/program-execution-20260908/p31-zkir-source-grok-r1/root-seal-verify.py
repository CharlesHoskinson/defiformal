from pathlib import Path
import json,hashlib,gzip,datetime,shutil,os
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o=b/'p31-zkir-source-grok-r1';c=o/'closeout'
read=lambda p:json.loads(p.read_text())
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not (o/'root-seal.json').exists()
for pid in [2054415,2067990]:assert not Path('/proc',str(pid)).exists()
process,closeout=read(o/'process.json'),read(c/'process.json')
assert process['process_exit']==1 and closeout['process_exit']==0
assert process['sessions']==closeout['sessions']==['01a08c7b-ea68-7df1-be80-3738e855c0e0']
assert process['reported_models']==closeout['reported_models']==['grok-4.6-build']
for p,rec in [(o,process),(c,closeout)]:assert h(p/'native.jsonl')==rec['log_sha256']
manifest=read(c/'MANIFEST.json');assert len(manifest['files'])==manifest['file_count']==9
for n,digest in manifest['files'].items():assert h(c/n)==digest,n
for n in ['REVIEW.md','verdict.json','findings.json','commands.json']:assert h(c/n)==h(o/n),n
inputs=read(o/'inputs.json');sandbox=Path(inputs['sandbox'])
for n,digest in inputs['files'].items():assert h(sandbox/n)==digest,n
root=o/'root-verification'
for n,digest in read(root/'root-seal.json')['files'].items():assert h(root/n)==digest,n
assessment=read(root/'assessment.json');assert assessment['inputs_verified']==138
assert assessment['crate_archive_and_nine_members_match'] and assessment['release_archive_and_six_installed_members_match']
assert read(c/'verdict.json')['decision']=='usable' and not read(c/'verdict.json')['changes_required']
with (c/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
record={'schema':'defiformal-p31-zkir-source-root-adjudication/v1',
 'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'decision':'USABLE_SCOPED_SOURCE_AND_RELEASE_IDENTITY_EVIDENCE',
 'requested_model':'grok-4.6','effort':'high','reported_models':process['reported_models'],
 'sessions':process['sessions'],'original_process_exit':1,'same_session_closeout_exit':0,
 'independent_review_count':1,'manifest_bindings':9,'input_bindings':138,
 'root_replay':'root-verification/root-seal.json',
 'identity_checks':{'published_crate_checksum_and_members':9,'crate_vcs_git_comparable_files':6,'release_archive_installed_members':6},
 'current_gap':'Published ZKIR source and release identity are available; accepted semantic interface, Compact-to-ZKIR correspondence and adapter32.7 remain open.',
 'historical_readiness_32_1_to_32_4':'Preserved unchanged, including original32.3 blocked readiness record.',
 'receipt_limits':'Reviewer retained decoded stdout/structured identity results; no separately captured raw stderr/interpreter hash. Root replay has separate raw streams and interpreter binding. Do not relabel these as reviewer capture.',
 'identity_correction':'Original returned_model grok-4.6 is the requested alias; terminal native identity is grok-4.6-build.',
 'source_to_binary_equivalence_proved':False,'mandatory_reproducible_build_gate_invented':False,
 'semantic_contract_accepted':False,'adapter_32_7_accepted':False,'adapter_32_9_accepted':False,
 'P20_accepted':False,'PCT_accepted':False,'P31_accepted':False,'whole_program_complete':False,
 'next_obligations':['AGY designs the actual JSON2.0 subset interface with opcode meanings, witness/public-input layout, PiSkip and communications commitment, then fresh Grok reviews it.',
  'Bound required dependency source semantics or explicit assumptions; field arithmetic needs financial integer refinement.',
  'Prove actual Compact/harness-to-ZKIR correspondence and implement adapter32.7; distinguish snapshot recordN from transitionN.',
  'PCT remains dependent on accepted P20; complete actual adapter review32.9.']}
write(o/'root-adjudication.json',record)
shutil.copy2(__file__,o/'root-seal-verify.py')
files={}
for parent,dirs,names in os.walk(o):
 dirs[:]=[d for d in dirs if d not in ['__pycache__','.lake','private-lean']]
 for name in names:
  p=Path(parent)/name
  if name=='native.jsonl' or p==o/'root-seal.json':continue
  assert p.is_file() and not p.is_symlink(),p
  files[str(p.relative_to(o))]=h(p)
write(o/'root-seal.json',{'utc':record['utc'],'files':files,'file_count':len(files),
 'manifest_bindings':9,'acceptance_scope':'Source navigation and release identity only','P31_accepted':False})
print(json.dumps({'sealed_files':len(files),'manifest_bindings':9,'inputs':138,'decision':record['decision']}))
