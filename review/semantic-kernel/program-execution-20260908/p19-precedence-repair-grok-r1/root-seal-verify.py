from pathlib import Path
import json,hashlib,gzip,datetime,shutil,os
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p19-precedence-repair-grok-r1';read=lambda p:json.loads(p.read_text());h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not (o/'root-seal.json').exists();assert not Path('/proc/2073996').exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(o)) and comm in ['lean','lake','grok','node']),(p.name,cwd)
i=read(o/'inputs.json');s=Path(i['sandbox'])
for n,digest in i['files'].items():assert h(s/n)==digest,n
m=read(o/'MANIFEST.json');assert len(m['files'])==57
for f in m['files']:assert h(o/f['path'])==f['sha256'] and (o/f['path']).stat().st_size==f['bytes']
p=read(o/'process.json');assert p['process_exit']==1 and p['reported_models']==['grok-4.6-build'];assert p['sessions']==['01a08c89-345b-7a32-ac53-18433d4822a9'];assert h(o/'native.jsonl')==p['log_sha256']
v=read(o/'verdict.json');assert v['verdict']=='CHANGES_REQUIRED'
for n,digest in v['source_hashes_frozen'].items():
 rel=Path('DefiKernel/Certificates')/(n+'.lean');assert h(o/'private-lean'/rel)==digest==h(s/'lean'/rel),n
cp=v['compiler'];assert h(Path(cp['lean_bin']))==cp['lean_bin_sha256'];assert h(Path(cp['lake_bin']))==cp['lake_bin_sha256'];assert h(Path(cp['lean_bin']).parent.parent/'lib/lean/libleanshared.so')==cp['libleanshared_so_sha256']
vr=o/'root-verification'
for n,digest in read(vr/'root-seal.json')['files'].items():assert h(vr/n)==digest
ax=read(vr/'axioms311-command.json');co=read(vr/'comparison.json');assert ax['exit']==0 and ax['exact_names_match'] and not ax['forbidden'];assert ax['axiom_records']==299 and ax['zero_axiom_records']==12;assert co['reviewer_root_axiom_pairs_equal'];assert len(co['controls'])==4 and all(c['matches_reviewer_stdout'] for c in co['controls'])
with (o/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((o/'native.jsonl').read_bytes())
rec={'schema':'defiformal-p19-precedence-repair-root-adjudication/v1','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'decision':'PARTIAL_PROOF_WORK_CHANGES_REQUIRED','requested_model':'grok-4.6','reported_models':p['reported_models'],'sessions':p['sessions'],'native_exit':1,'all_five_reports_complete':True,'same_session_closeout_required':False,'fresh_review_count':1,'frozen_input_bindings_verified':len(i['files']),'manifest_bindings_verified':57,'reviewer_rawstream_bindings_verified':24,'root_named_declarations':311,'root_standard_axioms':299,'root_zero_axioms':12,'root_reviewer_name_axiom_map_equal':True,'root_controls_replayed':4,'reviewer_fresh_build':'Correspondence target932jobs; CanonicalJson/Encode/Decode/Check/Correspondence rebuilt. Schema replayed with unchanged source.','progress':['R18 repaired6mixed-error cases and preserved32C0 roundtrips/duplicate/quote controls.','12new R18 base/component inverses confirmed;299previous named declarations retained.'],'required':['Full EncodeDecodeRoundtripStatement remains unproved Prop; derive scanner/parser success from actual unchanged admitted domain.','R18 retains2unterminated-whitespace final precedence defects. R19 root repairs verified separately and queued for fresh audit; this reviewer never inspected R19.','Arbitrary nested Expr/list/object/envelope byte inversion and full P19 acceptance campaigns remain open.'],'scope_corrections':['Original reviewer returned_model unknown reflects live authoring; terminal telemetry supplies grok-4.6-build without changing original reports.','1048576 probe checks size expression only;1048577 scanner/checker refusal is executed. No max-size successful decode claim.','Author lake build DefiKernel is a named-target cache replay, not unqualified full build. Author Verify1498/2545 Certificates,420/677Typed,287/408Composition is separate from311named probe.'],'acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False};put(o/'root-adjudication.json',rec);shutil.copy2(__file__,o/'root-seal-verify.py')
files={}
for parent,dirs,names in os.walk(o):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for n in names:
  q=Path(parent)/n
  if n=='native.jsonl' or q==o/'root-seal.json':continue
  assert q.is_file() and not q.is_symlink();files[str(q.relative_to(o))]=h(q)
put(o/'root-seal.json',{'utc':rec['utc'],'files':files,'file_count':len(files),'manifest_bindings_verified':57,'acceptance':False});print(json.dumps({'sealed_files':len(files),'manifest_bindings':57,'root_named':311,'rawstream_bindings':24,'acceptance':False}))
