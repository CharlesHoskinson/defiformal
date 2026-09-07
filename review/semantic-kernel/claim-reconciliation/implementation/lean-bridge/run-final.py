from pathlib import Path
import subprocess,json,hashlib,time,re,sys
from datetime import datetime,timezone
R=Path(__file__).resolve().parents[5];E=Path(__file__).resolve().parent;L=R/'lean'
assert (L/'lean-toolchain').is_file()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def git(*a):return subprocess.check_output(['git',*a],cwd=R).decode().strip()
def save(n,d):(E/n).write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
modules={};pending=['DefiHistorical']
while pending:
 m=pending.pop();p=L/(m.replace('.','/')+'.lean')
 if m in modules or not p.is_file():continue
 modules[m]=str(p.relative_to(R));pending+=re.findall(r'^import ([\w.]+)',p.read_text(),re.M)
inputs=list(modules.values())+['lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json','formal/v3/m5-convex.mjs']
def snapshot():
 rows=[]
 for f in sorted(inputs):
  p=R/f;pr=subprocess.run(['git','rev-parse','HEAD:'+f],cwd=R,capture_output=True,text=True)
  rows.append({'path':f,'sha256':sha(p),'bytes':p.stat().st_size,'git_blob_at_HEAD':pr.stdout.strip() if pr.returncode==0 else None})
 return {'utc':utc(),'head':git('rev-parse','HEAD'),'files':rows}
before=snapshot();save('final-source-before.json',before)
toolroot=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')
tools={n:{'path':str(toolroot/n),'sha256':sha(toolroot/n),'version':subprocess.check_output([str(toolroot/n),'--version'],cwd=L).decode().strip()} for n in ['lake','lean']}
runs=[]
for label,cmd in [('root',['lake','build','DefiHistorical']),('verify-build',['lake','build','DefiHistorical.Convex.Verify']),('verify-direct',['lake','env','lean','DefiHistorical/Convex/Verify.lean'])]:
 start=utc();t=time.monotonic()
 with (E/(label+'.stdout.log')).open('wb') as o,(E/(label+'.stderr.log')).open('wb') as e:
  cp=subprocess.run(cmd,cwd=L,stdout=o,stderr=e)
 runs.append({'command':cmd,'cwd':str(L),'utc':start,'duration_seconds':time.monotonic()-t,'exit':cp.returncode,'stdout':label+'.stdout.log','stderr':label+'.stderr.log','stdout_sha256':sha(E/(label+'.stdout.log')),'stderr_sha256':sha(E/(label+'.stderr.log'))})
 if cp.returncode:break
after=snapshot();save('final-source-after.json',after)
unchanged={x['path']:x['sha256'] for x in before['files']}=={x['path']:x['sha256'] for x in after['files']}
execution={'kind':'actual_targeted_Lean_checks','tools':tools,'python':{'path':sys.executable,'sha256':sha(Path(sys.executable))},'runs':runs,'source_unchanged':unchanged,'head_before':before['head'],'head_after':after['head'],'script_sha256':sha(Path(__file__))}
save('final-execution.json',execution)
assert len(runs)==3 and all(x['exit']==0 for x in runs) and unchanged
rows=[]
for line in (E/'verify-direct.stdout.log').read_text().splitlines():
 if 'HISTORICAL INVENTORY {' in line:rows.append(json.loads(line.split('HISTORICAL INVENTORY ',1)[1]))
assert rows and len(rows)==len({x['name'] for x in rows})
explicit={}
for m,f in modules.items():
 if not m.startswith('DefiHistorical'):continue
 text=(R/f).read_text();ns=re.search(r'^namespace ([\w.]+)',text,re.M)
 if ns:
  for kind,name in re.findall(r'^(?:@\[[^\n]+\] )?(theorem|lemma) ([\w\']+)',text,re.M):explicit[ns[1]+'.'+name]=f
for x in rows:
 p=modules[x['module']];x['source_path']=p;x['source_sha256']=sha(R/p);x['explicit_source_theorem']=x['name'] in explicit
 x['class']='supplemental' if x['kind']!='theorem' else 'generated'
 if x['explicit_source_theorem']:
  x['class']='generic' if x['module'].endswith('Saturation') or x['name'].endswith(('.path_rank','.ranked_antisymm')) else 'counterexample_or_finite_control' if x['module'].endswith('Counterexamples') else 'concrete_instance'
 assert set(x['axioms'])<={'propext','Classical.choice','Quot.sound'}
 assert '⋯' not in x['statement']
counts={k:sum(x['class']==k for x in rows) for k in ['generic','concrete_instance','counterexample_or_finite_control','generated','supplemental']}
assert set(explicit)<={x['name'] for x in rows},set(explicit)-{x['name'] for x in rows}
save('proof-inventory.json',{'status':'actual_elaborated_imported_inventory','head_at_execution':before['head'],'counts':counts,'theorems':sum(x['kind']=='theorem' for x in rows),'explicit_source_theorems':len(explicit),'source_modules':modules,'declarations':rows,'limits':'Private and generated declarations are retained by actual elaborated identity. Audit includes imported source only; Verify and root contain commands/imports, no theorem helpers. DataExport is independently checked by parent, outside this proof import closure.'})
print(json.dumps({'checks':len(runs),'source_unchanged':unchanged,'counts':counts,'explicit':len(explicit),'total':len(rows)}))
