from pathlib import Path
import json,hashlib,re,subprocess,time,datetime,shutil
R=Path('/home/charl/defiformal');E=Path(__file__).resolve().parent;L=R/'lean';P=L/'DefiKernel/Arithmetic/Rounding.lean'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def b(p):return {'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size}
records=[]
def run(label,args):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.monotonic();p=subprocess.run(args,cwd=L,capture_output=True,timeout=300)
 (E/(label+'.stdout')).write_bytes(p.stdout);(E/(label+'.stderr')).write_bytes(p.stderr)
 records.append({'label':label,'command':args,'cwd':str(L),'utc_start':start,'utc_end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'seconds':time.monotonic()-t,'exit_code':p.returncode,'stdout':b(E/(label+'.stdout')),'stderr':b(E/(label+'.stderr'))})
 (E/'execution.json').write_text(json.dumps(records,indent=2)+'\n')
 if p.returncode:raise RuntimeError(label+' failed')
 return p.stdout.decode()
source=b(P);head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
run('build',['lake','build','DefiKernel.Arithmetic.Rounding'])
names=re.findall(r'^(?:@\[[^\n]*\]\s*)?theorem\s+([\w.]+)',P.read_text(),re.M)
driver='import DefiKernel.Arithmetic.Rounding\n\n'+ '\n'.join('#print axioms DefiKernel.Arithmetic.Rounding.'+n for n in names)+'\n'
(E/'axioms.lean').write_text(driver);raw=run('axioms',['lake','env','lean',str(E/'axioms.lean')]);axioms=set()
for block in re.findall(r'depends on axioms:\s*\[([^\]]*)\]',raw):axioms.update(x.strip()for x in block.split(',')if x.strip())
assert axioms<={'propext','Classical.choice','Quot.sound'}
assert len(re.findall(r"'DefiKernel.Arithmetic.Rounding\.",raw))==len(names)
probes='''import DefiKernel.Arithmetic.Rounding
open DefiKernel.Arithmetic
#eval ("down21/4", decide (Rounding.divideNat .down 21 4 = .ok 5))
#eval ("up21/4", decide (Rounding.divideNat .up 21 4 = .ok 6))
#eval ("zero-denominator", decide (Rounding.divideNat .up 21 0 = .error .divisionByZero))
#eval ("full-product", decide (Rounding.mulDiv .down (⟨200, by decide⟩ : Word 8) ⟨200, by decide⟩ 200 = .ok ⟨200, by decide⟩))
#eval ("floor-fits", decide (Rounding.mulDiv .down (⟨254, by decide⟩ : Word 8) ⟨254, by decide⟩ 253 = .ok ⟨255, by decide⟩))
#eval ("ceil-overflow", decide (Rounding.mulDiv .up (⟨254, by decide⟩ : Word 8) ⟨254, by decide⟩ 253 = .error .quotientOverflow))
#eval ("width-zero", decide (Rounding.mulDiv .up (⟨0, by decide⟩ : Word 0) ⟨0, by decide⟩ 3 = .ok ⟨0, by decide⟩))
'''
(E/'literal-probes.lean').write_text(probes);out=run('literal-probes',['lake','env','lean',str(E/'literal-probes.lean')]);assert out.count(', true)')==7 and ', false)'not in out
version=run('lean-version',['lake','env','lean','--version']);locations=run('tool-paths',['lake','env','bash','-c','command -v lean; command -v lake'])
anchors=[];prefix=P.read_text().split('-- BEGIN PROOFS')[0]
for x in json.loads((R/'openspec/changes/checked-integer-financial-arithmetic/mutation-inventory.json').read_text())['mutants']:
 if x['id']in['M03','M04','M05','M06']:
  count=prefix.count(x['needle']);assert count==1
  anchors.append({'id':x['id'],'runtime_needle_count':count,'needle':x['needle'],'scope':'Anchor check only; no mutation run.'})
assert source==b(P)
result={'status':'targeted_author_checks_pass','head_before':head,'head_after':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'source_before':source,'source_after':b(P),'unchanged_source':True,'theorem_count':len(names),'theorems':names,'axioms':sorted(axioms),'literal_probe_count':7,'runtime_anchors':anchors,'version':version.strip(),'tools':{x:{'resolved':str(Path(x).resolve()),'sha256':sha(Path(x).resolve())}for x in locations.splitlines()if x.startswith('/')},'scope':'Universal theorem elaboration and seven development computations; not official45fixture/12mutant/65control/27968diagnostic evidence.'}
(E/'checks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'status':result['status'],'theorems':len(names),'axioms':result['axioms'],'runtime_probes':7}))
