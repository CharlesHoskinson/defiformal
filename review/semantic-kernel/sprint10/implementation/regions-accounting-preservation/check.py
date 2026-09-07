from pathlib import Path
import hashlib,json,re,subprocess,time,datetime,shutil
root=Path('/home/charl/defiformal'); out=root/'review/semantic-kernel/sprint10/implementation/regions-accounting-preservation'; lean=root/'lean'
modules=['Regions','Accounting','AccountingInterleaving','Preservation','TypedPreservation','BindingTransport']
paths=[lean/'DefiKernel/Interface'/f'{x}.lean' for x in modules]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def snap():return {str(p.relative_to(root)):{'sha256':sha(p),'bytes':p.stat().st_size} for p in paths}
def run(label,args):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.monotonic()
 p=subprocess.run(args,cwd=lean,capture_output=True,timeout=600)
 (out/f'{label}.stdout').write_bytes(p.stdout);(out/f'{label}.stderr').write_bytes(p.stderr)
 r=dict(command=args,cwd=str(lean),utc_start=start,utc_end=datetime.datetime.now(datetime.timezone.utc).isoformat(),wall_seconds=time.monotonic()-t,exit_code=p.returncode,stdout_sha256=sha(out/f'{label}.stdout'),stderr_sha256=sha(out/f'{label}.stderr'))
 records.append(r);(out/'execution.json').write_text(json.dumps(records,indent=2)+'\n')
 if p.returncode:raise RuntimeError(f'{label} exit {p.returncode}')
 return p.stdout.decode()
records=[];before=snap();head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
(out/'sources-before.json').write_text(json.dumps({'head':head,'sources':before},indent=2)+'\n')
run('build',['lake','build']+['DefiKernel.Interface.'+x for x in modules])
names=[]
for p in paths:
 names.extend('DefiKernel.Interface.'+n for n in re.findall(r'^(?:@\[[^\n]*\]\s*)?theorem\s+([\w.]+)',p.read_text(),re.M))
driver='\n'.join('import DefiKernel.Interface.'+x for x in modules)+'\n\n'+ '\n'.join('#print axioms '+n for n in names)+'\n'
(out/'axioms.lean').write_text(driver)
raw=run('axioms',['lake','env','lean',str(out/'axioms.lean')])
axioms=set()
for block in re.findall(r'depends on axioms:\s*\[([^\]]*)\]',raw):axioms.update(x.strip() for x in block.split(',') if x.strip())
assert axioms <= {'propext','Classical.choice','Quot.sound'},axioms
assert len(re.findall(r"'DefiKernel.Interface\.",raw))==len(names),(len(names),raw)
version=run('lean-version',['lake','env','lean','--version'])
locations=run('tool-paths',['lake','env','bash','-c','command -v lean; command -v lake'])
tools={p:{'resolved':str(Path(p).resolve()),'sha256':sha(Path(p).resolve())} for p in locations.splitlines() if p.startswith('/')}
after=snap(); assert before==after
endhead=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
result={'status':'PASS','initial_head':head,'final_head':endhead,'source_bytes_unchanged':before==after,'sources':after,'theorems':names,'theorem_count':len(names),'axioms':sorted(axioms),'lean_version':version.strip(),'tools':tools,'driver_sha256':sha(out/'axioms.lean'),'scope':'Targeted author checks; no official inventory, mutation execution, or independent acceptance.'}
(out/'checks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'status':result['status'],'theorems':len(names),'axioms':sorted(axioms)}))
