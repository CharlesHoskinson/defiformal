from pathlib import Path
import json, hashlib, gzip, datetime, shutil, os
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o=b/'p19-rational-inverse-grok-r1';c=o/'closeout'
read=lambda p:json.loads(p.read_text())
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not (o/'root-seal.json').exists()
for pid in [2028868,2050347]:assert not Path('/proc',str(pid)).exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(o)) and comm in ['lean','lake','grok','node']),(p.name,cwd)
i=read(o/'inputs.json');s=Path(i['sandbox'])
for n,digest in i['files'].items():assert h(s/n)==digest,n
manifest=read(c/'MANIFEST.json')
assert len(manifest['files'])==37
for f in manifest['files']:
 p=c/f['path'];assert h(p)==f['sha256'] and p.stat().st_size==f['bytes'],f['path']
for n in ['REVIEW.md','verdict.json','findings.json','commands.json']:assert h(c/n)==h(o/n),n
process=read(o/'process.json');closeout=read(c/'process.json')
assert process['process_exit']==1 and closeout['process_exit']==0
assert process['sessions']==closeout['sessions']==['01a08c6a-ab6b-7cd2-8fbb-b059a7adfde9']
assert process['reported_models']==closeout['reported_models']==['grok-4.6-build']
for p,rec in [(o,process),(c,closeout)]:assert h(p/'native.jsonl')==rec['log_sha256']
verdict=read(c/'verdict.json');assert verdict['verdict']=='CHANGES_REQUIRED'
for n,digest in verdict['source_hashes_frozen'].items():
 rel=Path('DefiKernel/Certificates')/(n+'.lean')
 assert h(o/'private-lean'/rel)==digest==h(s/'lean'/rel),n
cp=verdict['compiler']
assert h(Path(cp['lean_bin']))==cp['lean_bin_sha256']
assert h(Path(cp['lake_bin']))==cp['lake_bin_sha256']
assert h(Path(cp['lean_bin']).parent.parent/'lib/lean/libleanshared.so')==cp['libleanshared_so_sha256']
v=o/'root-verification';vr=read(v/'root-seal.json')
for n,digest in vr['files'].items():assert h(v/n)==digest,n
check=read(v/'axioms299-command.json');comparison=read(v/'comparison.json')
assert check['exit']==0 and check['exact_names_match'] and not check['forbidden']
assert check['axiom_records']==287 and check['zero_axiom_records']==12
assert comparison['reviewer_root_axiom_pairs_equal'] and comparison['new_r17_count']==29
with (c/'native.jsonl.gz').open('xb') as out:
 with gzip.GzipFile(filename='',mode='wb',fileobj=out,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
record={'schema':'defiformal-p19-rational-inverse-root-adjudication/v1',
 'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'decision':'PARTIAL_PROOF_WORK_CHANGES_REQUIRED','requested_model':'grok-4.6',
 'reported_models':process['reported_models'],'sessions':process['sessions'],
 'initial_process_exit':1,'same_session_closeout_exit':0,'fresh_review_count':1,
 'manifest_bindings_verified':37,'frozen_input_bindings_verified':len(i['files']),
 'root_named_declarations':299,'root_standard_axiom_records':287,'root_zero_axiom_records':12,
 'root_and_reviewer_axiom_pairs_equal':True,'raw_command_stream_bindings_verified':14,
 'new_r17_named_theorems':29,'r16_source_theorem_and_lemma_count':270,
 'historical_r16_theorem_only_inventory':269,
 'correction':'exprDepth_pos is a pre-existing R16 lemma, not new R17 work. Historical269 checks did not include it. R17 exact299 includes298 theorems plus this lemma.',
 'progress':'General decimal tokenization and canonical rational parser/decoder inverse independently rebuilt and checked. No removed historical source lines; Decode/Encode/Schema unchanged.',
 'open':['Universal EncodeDecodeRoundtripStatement remains an unproved Prop.',
         'Derive lexical acceptance and recursive parser success from StructurallyAdmissibleIR rather than assume them.',
         'R16 mixed-error precedence regressions persist in unchanged R17 Decode; R18 has repair brief.',
         'Full54fixture/99scenario/16mutant acceptance still deferred until universal theorem closes.'],
 'evidence_corrections':['Original reviewer identity was unknown while live; terminal telemetry above supplies it.',
  'Author command timestamps/raw-stream bindings are incomplete; author error-precedence preservation claim is false.',
  'Author Verify log has Certificates1486/2539, Typed420/677, Composition287/408. Review exact299 and root replay are separate scopes.'],
 'acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False}
write(o/'root-adjudication.json',record)
shutil.copy2(__file__,o/'root-seal-verify.py')
files={}
for parent,dirs,names in os.walk(o):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name in ['native.jsonl'] or p==o/'root-seal.json':continue
  assert p.is_file() and not p.is_symlink(),p
  files[str(p.relative_to(o))]=h(p)
write(o/'root-seal.json',{'utc':record['utc'],'files':files,'file_count':len(files),
 'manifest_bindings_verified':37,'acceptance':False})
print(json.dumps({'sealed_files':len(files),'manifest_bindings':37,'root_named':299,'new_r17_theorems':29,'acceptance':False}))
