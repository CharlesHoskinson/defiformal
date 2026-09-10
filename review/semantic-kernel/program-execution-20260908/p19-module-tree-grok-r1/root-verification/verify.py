from pathlib import Path
import collections,datetime,gzip,hashlib,json,os,re,shutil,subprocess
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-module-tree-grok-r1';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-tree-grok-r1-sandbox');P=O/'private-lean';V=O/'root-verification';T=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text())
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2314784').exists();V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');inputs=read(O/'inputs.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
m=read(O/'MANIFEST.json');assert len(m['files'])==m['file_count']==46 and m['self_excluding'];assert read(O/'verdict.json')['status']=='complete'
for r in m['files']:assert (O/r['path']).stat().st_size==r['bytes'] and h(O/r['path'])==r['sha256'],r['path']
process=read(O/'process.json');assert process['process_exit']==0 and process['reported_models']==['grok-4.6-build'] and h(O/'native.jsonl')==process['log_sha256']
rows=read(O/'commands.json')['commands'];assert len(rows)==7
for row in rows:
 meta=read(O/'logs'/row['id']/'meta.json')
 for key in ['id','argv','cwd','start','end','exit','timed_out']:assert meta[key]==row[key],(row['id'],key)
 assert h(O/row['stdout_path'])==row['rawstdout_sha256'] and h(O/row['stderr_path'])==row['rawstderr_sha256'];assert row['exit']==0 and not row['timed_out']
private_sources={}
for parent,dirs,files in os.walk(P):
 dirs[:]=[x for x in dirs if x not in ['.lake','.git','__pycache__']]
 for name in files:
  p=Path(parent)/name
  if p.suffix=='.lean' or name in ['lakefile.toml','lake-manifest.json','lean-toolchain']:
   q=S/'lean'/p.relative_to(P);assert q.is_file() and h(p)==h(q),str(p);private_sources[str(p.relative_to(P))]=h(p)
assert len(private_sources)>14
source_counts={};names=[]
for module in ['CanonicalJson','Correspondence','Roundtrip']:
 text=(P/f'DefiKernel/Certificates/{module}.lean').read_text();found=re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)',text,re.M);source_counts[module]=len(found);names += ['DefiKernel.Certificates.'+n for n in found]
assert source_counts=={'CanonicalJson':136,'Correspondence':312,'Roundtrip':102} and len(set(names))==550
probe=O/'probes/axioms550/Axioms.lean';assert h(probe)==h(B/'p19-r23-root-inventory/Axioms.lean')
argv=[str(T/'lake'),'env',str(T/'lean'),str(probe)];start=now()
with (V/'axioms.stdout').open('xb') as out,(V/'axioms.stderr').open('xb') as err:run=subprocess.run(argv,cwd=P,stdout=out,stderr=err,timeout=90)
put(V/'command.json',{'argv':argv,'cwd':str(P),'started_utc':start,'finished_utc':now(),'exit':run.returncode,'probe_sha256':h(probe),'lean_sha256':h(T/'lean'),'lake_sha256':h(T/'lake'),'stdout_sha256':h(V/'axioms.stdout'),'stderr_sha256':h(V/'axioms.stderr'),'scope':'ROOT fresh replay using completed independent reviewer build, not a new reviewer build or live author execution.'});assert run.returncode==0
raw=(V/'axioms.stdout').read_text();standard=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",raw,re.S);zero=re.findall(r"'([^']+)' does not depend on any axioms",raw);got=[n for n,a in standard]+zero;assert len(got)==550 and set(got)==set(names) and len(standard)==495 and len(zero)==55;assert all(set(a.replace('\n',' ').replace(',',' ').split())<={'propext','Classical.choice','Quot.sound'} for _,a in standard)
assert (V/'axioms.stdout').read_bytes()==(O/'logs/probe-axioms550/stdout').read_bytes()==(B/'p19-r23-root-inventory/axioms.stdout').read_bytes()
author=S/'review/semantic-kernel/certificates/p19/implementation/agy-r23-proof';ars=read(author/'commands.json');assert len(ars)==83;failed_final=[]
for row in ars:
 assert read(author/'logs'/row['id']/'command.json')==row;assert h(author/row['stdout_path'])==row['stdout_sha256'] and h(author/row['stderr_path'])==row['stderr_sha256']
 if row['id'] in read(O/'verdict.json')['final_bound_author_command_ids'] and row['exit']!=0:failed_final.append({'id':row['id'],'exit':row['exit'],'scope':'Bound to final sources but not a successful execution gate'})
result={'utc':now(),'reviewed_archive_sha256':inputs['candidate_archive_sha256'],'input_bindings_verified':len(inputs['files']),'review_manifest_bindings':46,'reviewer_command_receipts':7,'reviewer_raw_streams':14,'private_source_and_config_bindings':len(private_sources),'author_command_receipts':83,'author_raw_streams':166,'source_explicit_theorem_lemma_counts':source_counts,'named_total':550,'standard_axioms':495,'zero_axioms':55,'forbidden':0,'root_replay_stdout_equals_reviewer_and_prior_root':True,'failed_author_commands_in_final_bound_list':failed_final,'requested_model':'grok-4.6','reported_models':process['reported_models'],'session':process['sessions'][0],'scope':'Partial module string encoding and Request decoder proof are usable. Whole P19 remains CHANGES_REQUIRED.','acceptance':False};put(V/'result.json',result)
adj={**result,'status':'completed_root_verified','scoped_result':'USABLE admitted module TreeJson string encoding and direct Request decode; full codec/P19 CHANGES_REQUIRED','corrections':['Raw dispatch/inputs scope says R22 due copied label. Candidate archive, brief, source files and this review actually bind R23; root r23-review-dispatch-scope-correction.json preserves explanation.','Review phrase mkObj sorts keys in Json value must not imply canonical Raw-tree shape. The compiled h_order proves equality after decodeRequest lookup, not structural equality of arbitrary permuted objects. Root libraryRef structural-inequality counterexample remains valid.','Final-bound command list is source identity classification, not success. Failed entries listed here receive zero successful-gate credit.','Reviewer initial output-parser attempts returned0/451names before correct wrapped-axiom parsing. No separate failed-probes files exist; native stream and commands narrative retain those postprocess failures. Lean execution itself exited0; complete550output and root replay establish final inventory.'],'remaining':['Discharge actual h_valid,h_depth,h_dec,h_lex from faithful full structural admission and prove existing EncodeDecodeRoundtripStatement.','Keep production byte order and direct decoder semantics; complete envelope/world/payload/step/run validity and inverse maps.','Repair outstanding overlay/expectedIR/hash/schema/host/campaign issues with actual end-to-end evidence; no99/16 closure inferred.'],'next_author':'R24 already executing these obligations; use completed review on next terminal handoff, without reading live reviewer state.','full_P19_accepted':False};put(O/'root-adjudication.json',adj)
with (O/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((O/'native.jsonl').read_bytes())
files={}
for parent,dirs,names in os.walk(O):
 dirs[:]=[d for d in dirs if d not in ['private-lean','.lake','__pycache__']]
 for name in names:
  p=Path(parent)/name
  if name!='native.jsonl':files[str(p.relative_to(O))]=h(p)
assert 'root-seal.json' not in files;put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'review_manifest_bindings':46,'acceptance':False});print(json.dumps({'sealed_files':len(files),**result}))
