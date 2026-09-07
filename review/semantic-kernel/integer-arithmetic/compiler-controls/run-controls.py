#!/usr/bin/env python3
"""Capture the actual asset-indexed arithmetic conversion compiler pair."""
import datetime,hashlib,json,pathlib,subprocess,time
ROOT=pathlib.Path(__file__).resolve().parents[4]
OUT=pathlib.Path(__file__).resolve().parent/'run-r1'
OUT.mkdir(exist_ok=False)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def git(*a): return subprocess.check_output(['git',*a],cwd=ROOT).decode().strip()
head=git('rev-parse','HEAD')
paths=list((ROOT/'lean/DefiKernel/Arithmetic').glob('*.lean'))+list((ROOT/'lean/DefiKernel/Typed').glob('*.lean'))+[ROOT/'lean'/n for n in ['lean-toolchain','lakefile.toml','lake-manifest.json']]+[OUT.parent/n for n in ['wrong-asset.lean','same-asset.lean']]
before={str(p.relative_to(ROOT)):{'sha256':sha(p),'git_blob':git('rev-parse',head+':'+str(p.relative_to(ROOT)))} for p in paths}
for p in paths: assert p.read_bytes()==subprocess.check_output(['git','show',head+':'+str(p.relative_to(ROOT))],cwd=ROOT)
lean=pathlib.Path(subprocess.check_output(['lake','env','which','lean'],cwd=ROOT/'lean',text=True).strip()).resolve()
rows=[]
for tag,name,expected in [('T01','wrong-asset.lean',1),('T02','same-asset.lean',0)]:
 argv=['lake','env','lean',str(OUT.parent/name)];start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic()
 p=subprocess.run(argv,cwd=ROOT/'lean',capture_output=True,timeout=600)
 logs={}
 for k,data in [('stdout',p.stdout),('stderr',p.stderr)]:
  f=OUT/(tag+'.'+k+'.log');f.write_bytes(data);logs[k]={'path':str(f.relative_to(ROOT)),'sha256':sha(f),'bytes':len(data)}
 text=(p.stdout+p.stderr).decode()
 passed=(p.returncode==expected and (tag=='T02' or ('type mismatch' in text.lower() and 'Asset.alt' in text and 'Asset.usd' in text)))
 rows.append({'id':tag,'command':argv,'cwd':str(ROOT/'lean'),'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,'actual_exit':p.returncode,'expected_exit':expected,'passed':passed,'logs':logs})
after={str(p.relative_to(ROOT)):sha(p) for p in paths}
record={'candidate':head,'kind':'actual-compiler-negative-positive-pair','source_before':before,'source_after':after,'source_unchanged':all(before[k]['sha256']==v for k,v in after.items()),'head_unchanged':head==git('rev-parse','HEAD'),'runner_sha256':sha(pathlib.Path(__file__)),'lean':{'path':str(lean),'sha256':sha(lean),'version':subprocess.check_output([str(lean),'--version'],text=True).strip()},'runs':rows,'scope':'Actual toQuantity asset index elaboration. T01 compiler rejection is distinct from compiled runtime mutation evidence.'}
record['passed']=record['source_unchanged'] and record['head_unchanged'] and all(r['passed'] for r in rows)
(OUT/'result.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'passed':record['passed'],'runs':[{k:r[k] for k in ['id','actual_exit','passed']} for r in rows]}))
raise SystemExit(0 if record['passed'] else 1)
