from pathlib import Path
import json,hashlib,datetime,subprocess,gzip,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p25-balancer-compiler-baseline';C=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p25-solc-build');O.mkdir(exist_ok=False);C.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();started=now()
compiler=json.loads((B/'p25-balancer-compiler-preparation/compiler.json').read_text());binary=Path(compiler['binary_path']);assert h(binary)==compiler['binary_sha256'];m=json.loads((B/'p25-balancer-dependency-preparation/imports.json').read_text());sources={};bindings=[]
for row in m['files']:
 p=Path(row['stored_path']);assert h(p)==row['sha256'];name=row['path'] if row['package']=='balancer' else ('@openzeppelin/contracts/' if row['package']=='openzeppelin' else 'permit2/')+row['path'];assert name not in sources;sources[name]={'content':p.read_text()};bindings.append({'source_name':name,'path':str(p),'sha256':h(p)})
aliases=json.loads((B/'p25-balancer-source-preparation/source-manifest.json').read_text())['package_aliases'];remappings=[a+'/='+v+'/' for a,v in sorted(aliases.items())]
settings={'optimizer':{'enabled':True,'runs':999},'evmVersion':'cancun','remappings':remappings,'outputSelection':{'*':{'*':['abi','evm.bytecode.object','evm.deployedBytecode.object','metadata']}}}
request={'language':'Solidity','sources':sources,'settings':settings};put(C/'input.json',request);argv=[str(binary),'--standard-json'];start=now();timeout=False
with (C/'input.json').open('rb') as i,(C/'stdout.json').open('xb') as out,(C/'stderr.txt').open('xb') as err:
 try:run=subprocess.run(argv,stdin=i,stdout=out,stderr=err,cwd=C,timeout=240);code=run.returncode
 except subprocess.TimeoutExpired:code=None;timeout=True
end=now()
for src,dest in [('input.json','input.json.gz'),('stdout.json','stdout.json.gz'),('stderr.txt','stderr.txt.gz')]:
 with (O/dest).open('xb') as f:
  with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((C/src).read_bytes())
put(O/'command.json',{'argv':argv,'cwd':str(C),'started_utc':start,'finished_utc':end,'exit':code,'timed_out':timeout,'compiler_sha256':h(binary),'stdin_sha256':h(C/'input.json'),'stdout_sha256':h(C/'stdout.json'),'stderr_sha256':h(C/'stderr.txt'),'raw_files':{n:{'cache_path':str(C/n),'sha256':h(C/n),'bytes':(C/n).stat().st_size} for n in ['input.json','stdout.json','stderr.txt']},'archive_files':{n:h(O/n) for n in ['input.json.gz','stdout.json.gz','stderr.txt.gz']}})
assert code==0 and not timeout
result=json.loads((C/'stdout.json').read_text());errors=result.get('errors',[]);fatal=[x for x in errors if x['severity']=='error'];put(O/'diagnostics.json',errors)
contracts=[]
for source,items in result.get('contracts',{}).items():
 for name,obj in items.items():contracts.append({'source':source,'contract':name,'creation_bytes':len(obj.get('evm',{}).get('bytecode',{}).get('object',''))//2,'runtime_bytes':len(obj.get('evm',{}).get('deployedBytecode',{}).get('object',''))//2,'metadata_sha256':hashlib.sha256(obj.get('metadata','').encode()).hexdigest()})
record={'started_utc':started,'finished_utc':end,'balancer_commit':m['balancer_commit'],'compiler_sha256':h(binary),'compiler_reported_version':compiler['reported_version'],'settings':settings,'source_count':len(sources),'source_bindings':bindings,'contract_count':len(contracts),'contracts':contracts,'error_count':len(fatal),'warning_count':sum(x['severity']=='warning' for x in errors),'bytecode_contracts':sum(x['creation_bytes']>0 for x in contracts),'compiler_success':not fatal,'EVM_execution':False,'full_upstream_build':False,'reference_tests_compiled':False,'P25_accepted':False}
put(O/'result.json',record);shutil.copy2(__file__,O/'build.py');files={p.name:h(p) for p in O.iterdir() if p.is_file()};put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:record[k] for k in ['source_count','contract_count','error_count','warning_count','bytecode_contracts','compiler_success','EVM_execution','P25_accepted']}));assert not fatal
