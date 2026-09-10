from pathlib import Path
import json,hashlib,gzip,datetime,shutil,os
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p19-treejson-inverse-grok-r1';c=o/'closeout';read=lambda p:json.loads(p.read_text());h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not (o/'root-seal.json').exists()
for pid in [2103999,2120377]:assert not Path('/proc',str(pid)).exists()
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:cwd=str((p/'cwd').resolve());comm=(p/'comm').read_text().strip()
 except (OSError,RuntimeError):continue
 assert not (cwd.startswith(str(o)) and comm in ['lean','lake','grok','node']),(p.name,cwd)
for n,d in read(o/'attempt1-evidence-root-seal.json')['files'].items():assert h(o/n)==d,n
i=read(o/'inputs.json');s=Path(i['sandbox'])
for n,d in i['files'].items():assert h(s/n)==d,n
m=read(c/'MANIFEST.json');assert len(m['files'])==60
for f in m['files']:
 q=(c/f['path']).resolve();assert q.is_relative_to(o.resolve());assert h(q)==f['sha256'] and q.stat().st_size==f['bytes'],f['path']
p=read(o/'process.json');cp=read(c/'process.json');assert p['process_exit']==1 and cp['process_exit']==0;assert p['sessions']==cp['sessions']==['01a08c9c-62a2-7052-8cc8-735249226c6f'];assert p['reported_models']==cp['reported_models']==['grok-4.6-build'];assert h(o/'native.jsonl')==p['log_sha256'] and h(c/'native.jsonl')==cp['log_sha256']
v=read(c/'verdict.json');assert v['verdict']=='CHANGES_REQUIRED'
for n,d in v['source_hashes_frozen'].items():
 rel=Path('DefiKernel/Certificates')/(n+'.lean');assert h(o/'private-lean'/rel)==d==h(s/'lean'/rel),n
tools=v['compiler'];assert h(Path(tools['lean_bin']))==tools['lean_bin_sha256'];assert h(Path(tools['lake_bin']))==tools['lake_bin_sha256'];assert h(Path(tools['lean_bin']).parent.parent/'lib/lean/libleanshared.so')==tools['libleanshared_so_sha256']
original={x['id']:x for x in [json.loads(l) for l in (o/'logs/command-index.jsonl').read_text().splitlines() if l.strip()]};reported=read(c/'commands.json')['commands'];assert len(reported)==len(original)==12
for x in reported:
 old=original[x['id']]
 for k in ['argv','cwd','start','end','exit','rawstdout_sha256','rawstderr_sha256']:assert x[k]==old[k],(x['id'],k)
 assert h(c/x['log'])==x['rawstdout_sha256'];assert h(c/x['stderr'])==x['rawstderr_sha256']
vr=o/'root-verification'
for n,d in read(vr/'root-seal.json')['files'].items():assert h(vr/n)==d
ax=read(vr/'axioms343-command.json');co=read(vr/'comparison.json');assert ax['exit']==0 and ax['exact_names_match'] and not ax['forbidden'];assert ax['axiom_records']==331 and ax['zero_axiom_records']==12;assert co['reviewer_root_axiom_pairs_equal'] and len(co['controls'])==4 and all(x['matches_reviewer_stdout'] for x in co['controls'])
with (c/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
rec={'schema':'defiformal-p19-treejson-root-adjudication/v1','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'decision':'PARTIAL_PROOF_WORK_CHANGES_REQUIRED','requested_model':'grok-4.6','reported_models':p['reported_models'],'sessions':p['sessions'],'initial_exit':1,'same_session_reporting_closeout_exit':0,'all_five_final_reports_complete':True,'fresh_independent_reviews':1,'closeout_fresh_session':False,'frozen_input_bindings_verified':len(i['files']),'manifest_bindings_verified':60,'original_to_final_command_receipt_matches':12,'rawstream_bindings_verified':24,'root_named_declarations':343,'root_standard_axioms':331,'root_zero_axioms':12,'root_reviewer_axiom_map_equal':True,'root_control_probes_replayed':4,'reviewer_rebuild':'932job Correspondence target; actual changed sources rebuilt and Schema unchanged replayed.','progress':['R19 two unterminated-whitespace final precedence repairs independently reproduced, including downstream checkBytes malformed classification.','Six mixed-error and32C0/duplicate/quote/backslash controls preserved.','343named declarations compile with standard axioms only;32new R19 additions remain base/fixed cases.'],'required':['Actual universal EncodeDecodeRoundtripStatement remains Prop and h_lex/h_parse remain assumptions.','General recursive nonempty array/object/Expr/envelope inversion and actual TreeJson-production encoder correspondence remain open.','Full P19 acceptance campaigns and overlay/host binding work remain required.'],'qualifications':['Original fresh_session=true in finalreports identifies the initial independent review; closeout is the same session, not a second fresh audit.','Author axiom print order differs from source at index68, but exact name/axiom map agrees; no missing proof inferred from order alone.','Root controls helper accidentally copied priorR18 verifier into root-verification/verify-axioms.py. It was not executed here. Actual R19 343-name replay script is root-axiom-replay-actual.py, separately bound in root-replay-script-binding-correction.json.','1048576 probe only tests size expression, not successful decode;1048577 scanner/checker refusal was executed.','Author namedtargetbuild and1552/2628Certificates,420/677Typed,287/408Composition audit scopes remain distinct from343named checks.'],'acceptance':False,'whole_p19_accepted':False,'whole_program_complete':False};put(o/'root-adjudication.json',rec);shutil.copy2(__file__,o/'root-seal-verify.py')
files={}
for parent,dirs,names in os.walk(o):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for n in names:
  q=Path(parent)/n
  if n=='native.jsonl' or q==o/'root-seal.json':continue
  assert q.is_file() and not q.is_symlink();files[str(q.relative_to(o))]=h(q)
put(o/'root-seal.json',{'utc':rec['utc'],'files':files,'file_count':len(files),'manifest_bindings_verified':60,'acceptance':False});print(json.dumps({'sealed_files':len(files),'manifest_bindings':60,'rawstream_bindings':24,'root_named':343,'acceptance':False}))
