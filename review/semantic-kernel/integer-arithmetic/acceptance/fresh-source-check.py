#!/usr/bin/env python3
"""Freshly elaborate every arithmetic source file after the native cache concern."""
import pathlib,json,hashlib,subprocess,time,datetime
R=pathlib.Path(__file__).resolve().parents[4];O=pathlib.Path(__file__).resolve().parent/'fresh-source-r1';O.mkdir(exist_ok=False)
C='ddf1ac0e50f2e032385664a0965bab59eef91ea3';sha=lambda b:hashlib.sha256(b).hexdigest()
P=json.loads((R/'review/semantic-kernel/integer-arithmetic/proof-inventory-r2/proof-inventory.json').read_text())['source_bindings']
def snapshot():
 out={}
 for rel,b in P.items():
  raw=(R/rel).read_bytes();assert raw==subprocess.check_output(['git','show',C+':'+rel],cwd=R);assert sha(raw)==b['sha256'];out[rel]=sha(raw)
 return out
before=snapshot();runs=[]
mods=['Word','Operations','Rounding','Fees','Quantity','Reference','Examples','Tests','RuntimeAudit','ProofAudit','Verify']
for n,name in enumerate(mods):
 argv=['lake','env','lean','DefiKernel/Arithmetic/'+name+'.lean'];start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic()
 p=subprocess.run(argv,cwd=R/'lean',capture_output=True,timeout=600);logs={}
 for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
  path=O/(name+'.'+label+'.log');path.write_bytes(data);logs[label]={'path':str(path.relative_to(R)),'sha256':sha(data),'bytes':len(data)}
 runs.append({'argv':argv,'cwd':str(R/'lean'),'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,'exit':p.returncode,'timeout_seconds':600,'logs':logs})
 (O/'runs.json').write_text(json.dumps(runs,indent=2)+'\n');print(name,p.returncode,flush=True)
 if p.returncode:break
after=snapshot();lean=pathlib.Path(subprocess.check_output(['lake','env','which','lean'],cwd=R/'lean',text=True).strip()).resolve()
m={'candidate':C,'status':'PASS' if len(runs)==11 and all(r['exit']==0 for r in runs) and before==after else 'FAIL','source_before':before,'source_after':after,'runs':runs,'lean':{'path':str(lean),'sha256':sha(lean.read_bytes())},'scope':'All11Arithmetic source files freshly elaborated against pinned built imports. Addresses native concern about only cached proof-tail builds; not a clean rebuild of all mathlib/Typed imports. No source change or production mutation rerun.'}
(O/'result.json').write_text(json.dumps(m,indent=2)+'\n');print(m['status']);raise SystemExit(0 if m['status']=='PASS' else 1)
