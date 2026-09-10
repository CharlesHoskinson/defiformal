from pathlib import Path
import json,hashlib,tarfile,tomllib,datetime,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';S=B/'p31-zkir-blst-source-preparation';O=B/'p31-zkir-blst-root-verification';O.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');start=now();shutil.copy2(__file__,O/'verify.py')
seal=json.loads((S/'root-seal.json').read_text())['files'];assert {str(p.relative_to(S)) for p in S.rglob('*') if p.is_file()}==set(seal)|{'root-seal.json'}
for n,d in seal.items():assert h(S/n)==d,n
r=json.loads((S/'receipt.json').read_text());reg=json.loads((S/'registry.json').read_text())['version'];lock=tomllib.loads((S/'Cargo.lock').read_text());p=[p for p in lock['package'] if p['name']=='blst'];assert len(p)==1 and p[0]['version']==r['version']=='0.3.16';arc=S/r['archive'];assert h(arc)==reg['checksum']==p[0]['checksum']==r['archive_sha256'];assert arc.stat().st_size==reg['crate_size'];fs={f['tar_member']:f for f in r['source_files']};assert len(fs)==159
with tarfile.open(arc) as t:
 members=[m for m in t.getmembers() if m.isfile()];assert {m.name for m in members}==set(fs) and len(members)==len(fs)
 for m in members:
  f=fs[m.name];assert h(S/f['path'])==hashlib.sha256(t.extractfile(m).read()).hexdigest()==f['sha256'];assert (S/f['path']).stat().st_size==m.size==f['bytes']
for n in ['registry.json',arc.name]:
 http=json.loads((S/(n+'.http.json')).read_text());assert http['status']==200 and http['sha256']==h(S/n)
root=S/'source/blst-0.3.16';anchors=[]
for file,needle in [('src/bindings.rs','pub fn blst_fr_add'),('src/bindings.rs','pub fn blst_fr_mul'),('blst/src/exports.c','add_mod_256(ret, a, b, BLS12_381_r)'),('blst/src/exports.c','mul_mont_sparse_256(ret, a, b, BLS12_381_r, r0)'),('blst/src/consts.c','const vec256 BLS12_381_r ='),('build.rs','cc.define("__BLST_NO_ASM__", None)'),('build.rs','match (cfg!(feature = "portable"), cfg!(feature = "force-adx"))')]:
 q=root/file;lines=q.read_text().splitlines();matches=[i for i,l in enumerate(lines,1) if needle in l];assert len(matches)==1;anchors.append({'source':str(q.relative_to(R)),'sha256':h(q),'line':matches[0],'text':lines[matches[0]-1],'classification':'static_source_navigation'})
put(O/'result.json',{'schema':'defiformal-blst-offline-verification/v1','started_utc':start,'finished_utc':now(),'source_seal_sha256':h(S/'root-seal.json'),'sealed_files_checked':len(seal),'archive_members_checked':len(fs),'archive_matches_lock_and_registry':True,'anchors':anchors,'downloaded_source_or_build_script_executions':0,'network_requests':0,'source_acquisition_complete_for_locked_blst':True,'complete_dependency_build_closure':False,'semantic_or_adapter_acceptance':False,'qualification':'Native arithmetic entry points and build-selection code are captured, not proved or executed. Platform flags/toolchain/external dependencies and source-to-installed-binary binding remain separate obligations.'})
put(O/'root-seal.json',{'files':{str(p.relative_to(O)):h(p) for p in O.rglob('*') if p.is_file()},'acceptance':False});print(json.dumps({'sealed_files_verified':len(seal),'members_verified':len(fs),'static_anchors':len(anchors),'acceptance':False}))
