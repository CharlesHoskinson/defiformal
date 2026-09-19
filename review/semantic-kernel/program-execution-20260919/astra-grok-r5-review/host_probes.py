import importlib.util,pathlib,tempfile,shutil,json,hashlib
root=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r5')
spec=importlib.util.spec_from_file_location('runner',root/'scripts/run_certificate_fixtures.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
rel='lean/DefiKernel/Certificates/trusted-host-records.json'
host=json.loads((root/rel).read_text())
with tempfile.TemporaryDirectory() as td:
 t=pathlib.Path(td)
 paths=list(m.REQUIRED_HOST_DEPENDENCIES)+[rel,'openspec/changes/serialized-kernel-certificates/grammar.json','openspec/changes/serialized-kernel-certificates/schema.json','lean/DefiKernel/Certificates/TrustedHost.lean','lean/DefiKernel/Arithmetic/Operations.lean']
 for p in paths:
  (t/p).parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(root/p,t/p)
 def run(name,h):
  (t/rel).write_text(json.dumps(h))
  try:r=m.verify_trusted_host(t,rel);print(name,'PASS',r['dependency_count'])
  except SystemExit as e:print(name,'REFUSED',str(e))
 run('intact',host)
 h=dict(host);h['dependencies']={};run('empty_dependencies',h)
 h=dict(host);h['library_compiler_records']={};run('missing_library_inventory',h)
 h=dict(host);h['library_compiler_records']={'fake':{'sha256':'wrong','theorem':'wrong','token':'wrong'}};run('substituted_library_inventory',h)
 p=t/'lean/DefiKernel/Arithmetic/Operations.lean';p.write_text(p.read_text()+'\n-- independent review drift\n');run('arithmetic_source_drift',host)
 p=t/'lean/DefiKernel/Certificates/TrustedHost.lean';p.write_text(p.read_text().replace('v4.33.0-rc2','WRONG-COMPILED-TOOLCHAIN'));run('compiled_host_source_drift',host)
