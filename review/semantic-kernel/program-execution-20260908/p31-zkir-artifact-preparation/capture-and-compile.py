from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p31-zkir-artifact-preparation';repo=Path('/home/charl/Moriarty');pin='7307349d0275af6fcb4144e1661d8b59d6b2663a';node=Path('/home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');o.mkdir(exist_ok=False);source=o/'source';source.mkdir();files=[];old=b/'p31-source-closure'
for mname in ['manifest.json','example-inputs.json']:
 m=json.loads((old/mname).read_text())
 for f in m['files']:
  p=old/'source'/f['path'];assert h(p)==f['sha256'];q=source/f['path'];q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);files.append({'path':f['path'],'sha256':f['sha256'],'bytes':q.stat().st_size,'git_blob':f['git_blob'],'capture':'prior verified source closure'})
extra=['experiments/moriarty-language/compact/materialize-mapping.mjs','experiments/moriarty-language/compact/generated/materialization.json']
for name in ['loan','swap']:
 for f in ['kernel.compact','harness.compact','metadata.json','bound-program.json']:extra.append('experiments/moriarty-language/compact/generated/'+name+'/'+f)
for n in extra:
 data=subprocess.check_output(['git','show',pin+':'+n],cwd=repo);q=source/n;q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists();q.write_bytes(data);oid=subprocess.check_output(['git','rev-parse',pin+':'+n],cwd=repo,text=True).strip();assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==oid;files.append({'path':n,'sha256':h(q),'bytes':len(data),'git_blob':oid,'capture':'git show pinned source; exit0'})
write(o/'inputs.json',{'source_pin':pin,'files':files,'file_count':len(files),'node':str(node),'node_sha256':h(node),'scope':'Pinned source and upstream generated snapshots; not adapter acceptance.','acceptance':False});commands=[]
def run(label,argv,cwd):
 start=now();p=subprocess.run(argv,cwd=cwd,capture_output=True,timeout=90);end=now();(o/(label+'.stdout')).write_bytes(p.stdout);(o/(label+'.stderr')).write_bytes(p.stderr);rec={'label':label,'argv':argv,'cwd':str(cwd),'started_utc':start,'finished_utc':end,'exit':p.returncode,'stdout_sha256':h(o/(label+'.stdout')),'stderr_sha256':h(o/(label+'.stderr'))};commands.append(rec);write(o/'commands.json',commands);assert p.returncode==0,p.stderr.decode();return p.stdout
script=source/'experiments/moriarty-language/compact/materialize-mapping.mjs';run('materialize',[str(node),str(script),str(o/'generated')],o)
rows=[]
for p in sorted((o/'generated').rglob('*')):
 if p.is_file():
  rel=p.relative_to(o/'generated');expected=source/'experiments/moriarty-language/compact/generated'/rel;rows.append({'path':str(rel),'sha256':h(p),'pinned_sha256':h(expected),'exact_match':p.read_bytes()==expected.read_bytes()})
write(o/'materialization-comparison.json',{'files':rows,'all_exact':all(f['exact_match'] for f in rows),'acceptance':False});assert len(rows)==9 and all(f['exact_match'] for f in rows)
versions={}
for flag in ['--version','--language-version','--runtime-version','--ledger-version']:versions[flag]=run('version-'+flag[2:],['/home/charl/.local/bin/compact','compile',flag],o).decode().strip()
assert versions['--version']=='0.31.1' and versions['--language-version']=='0.23.0' and versions['--runtime-version']=='0.16.0'
argv=['/usr/bin/strace','-f','-s','4096','-e','trace=execve','-o',str(o/'compile-execve.log'),'/home/charl/.local/bin/compact','compile','--skip-zk','--compact-path',str(source/'experiments/moriarty-language/compact'),str(o/'generated/loan/harness.compact'),str(o/'compiled/loan-harness')];run('compile-loan-harness',argv,o)
artifacts=[{'path':str(p.relative_to(o)),'bytes':p.stat().st_size,'sha256':h(p)} for p in sorted((o/'compiled').rglob('*')) if p.is_file()];assert not list((o/'compiled').rglob('*.prover')) and not list((o/'compiled').rglob('*.verifier'))
write(o/'compile-receipt.json',{'utc':now(),'source_pin':pin,'source_inputs_sha256':h(o/'inputs.json'),'materialization_comparison_sha256':h(o/'materialization-comparison.json'),'versions':versions,'compiler_binary':'/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/compactc.bin','compiler_binary_sha256':h(Path('/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/compactc.bin')),'execve_sha256':h(o/'compile-execve.log'),'commands_sha256':h(o/'commands.json'),'generated_loan_harness_sha256':h(o/'generated/loan/harness.compact'),'generated_loan_kernel_sha256':h(o/'generated/loan/kernel.compact'),'artifacts':artifacts,'skip_zk':True,'keys_generated':False,'proofs_generated':False,'scope':'Exact regeneration of nine upstream loan/swap snapshots and compilation of loan test-only snapshot harness; no financial settlement, PCD or full compiler/ledger correspondence.','acceptance':False});shutil.copy2(__file__,o/'capture-and-compile.py');print(json.dumps({'source_files':len(files),'materialized_files_exact':len(rows),'versions':versions,'compiled_artifacts':artifacts}))
