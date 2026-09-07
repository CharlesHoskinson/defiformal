import subprocess,json,hashlib,datetime,sys,re
from pathlib import Path
repo=Path('/home/charl/defiformal');out=repo/'review/semantic-kernel/sprint9/planning/baseline'/sys.argv[1];out.mkdir(parents=True,exist_ok=False)
sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip()
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(name,x):(out/name).write_text(json.dumps(x,indent=2)+'\n')
paths=subprocess.check_output(['git','ls-files','lean'],cwd=repo,text=True).splitlines();manifest={p:{'sha256':digest(repo/p),'git_blob':subprocess.check_output(['git','rev-parse',f'{sha}:{p}'],cwd=repo,text=True).strip()} for p in paths if (repo/p).is_file()}
for p,r in manifest.items():assert hashlib.sha256(subprocess.check_output(['git','show',f'{sha}:{p}'],cwd=repo)).hexdigest()==r['sha256'],p
save('source-before.json',manifest)
commands=[['lake','build']]+[['lake','env','lean',f'DefiKernel/{f}.lean'] for f in ['Atomic/Audit','Atomic/Verify','Interleaving/Audit','Interleaving/Verify','Parallel/Audit','Parallel/Verify','Composition/Audit','Composition/Verify','Typed/Audit','Typed/Verify','Audit','ContractAudit','VerifyAxioms']]
records=[]
for i,argv in enumerate(commands):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();p=subprocess.run(argv,cwd=repo/'lean',stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 logs={}
 for suffix,data in [('stdout',p.stdout),('stderr',p.stderr),('combined',p.stdout+p.stderr)]:
  name=f'{i:02d}.{suffix}.log';(out/name).write_bytes(data);logs[suffix]={'path':name,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
 records.append({'argv':argv,'cwd':'lean','started_at':start,'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit_code':p.returncode,'logs':logs,'combined_order':'stdout then stderr'})
 save('lean-runs.json',{'candidate':sha,'runs':records});print(' '.join(argv),p.returncode,flush=True)
 if p.returncode:break
after={p:digest(repo/p) for p in manifest};save('source-after.json',after);unchanged=all(after[p]==r['sha256'] for p,r in manifest.items())
checks=[]
for i,count in [(1,int(sys.argv[2]) if len(sys.argv)>2 else 129),(3,116),(5,131),(7,93),(9,189),(11,33),(12,43)]:
 if i<len(records):
  data=(out/records[i]['logs']['stdout']['path']).read_text();rows=re.findall(r'^([^:\n]+): (true|false)$',data,re.M);checks.append({'driver':i,'observed':len(rows),'expected':count,'passed':len(rows)==count and len({n for n,v in rows})==len(rows) and all(v=='true' for n,v in rows)})
save('verification.json',{'candidate':sha,'commands_expected':len(commands),'commands_run':len(records),'all_commands_passed':len(records)==len(commands) and all(r['exit_code']==0 for r in records),'source_files':len(manifest),'source_unchanged':unchanged,'head_unchanged':sha==subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'runtime_extraction_checks':checks})
print('integration done; source unchanged',unchanged,flush=True)
