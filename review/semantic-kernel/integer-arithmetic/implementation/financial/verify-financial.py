#!/usr/bin/env python3
"""Capture fresh financial/audit commands and exact fixture/source provenance."""
import argparse
from datetime import datetime,timezone
import hashlib,json,re,subprocess,time
from pathlib import Path
R=Path(__file__).resolve().parents[5]
parser=argparse.ArgumentParser();parser.add_argument('--out',type=Path,required=True)
args=parser.parse_args();D=args.out.resolve();assert not D.exists();D.mkdir(parents=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
plan=R/'openspec/changes/checked-integer-financial-arithmetic/fixture-inventory.json'
fixtures=json.loads(plan.read_text())['fixtures'];expected=[f['label'] for f in fixtures]
assert len(expected)==len(set(expected))==45
paths=sorted((R/'lean/DefiKernel/Arithmetic').glob('*.lean'))
paths += [R/'lean/DefiKernel/Typed'/f for f in ['Types.lean','Expr.lean','Authority.lean','Transition.lean']]
paths += [R/'lean/lean-toolchain',R/'lean/lakefile.toml',R/'lean/lake-manifest.json',plan]
before={str(p.relative_to(R)):{'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in paths}
for p in paths:
 q=D/'inputs'/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
commands=[]
def run(name,argv):
 start=datetime.now(timezone.utc).isoformat();tick=time.monotonic()
 x=subprocess.run(argv,cwd=R/'lean',capture_output=True,timeout=600)
 logs={}
 for label,raw in [('stdout',x.stdout),('stderr',x.stderr)]:
  p=D/(name+'.'+label+'.log');p.write_bytes(raw);logs[label]={'path':p.name,'sha256':sha(raw),'bytes':len(raw)}
 commands.append({'label':name,'command':argv,'cwd':str(R/'lean'),'started_utc':start,'finished_utc':datetime.now(timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,'exit':x.returncode,'logs':logs,'timeout_seconds':600})
 (D/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
 assert x.returncode==0,(name,x.stdout.decode(),x.stderr.decode())
 return x.stdout.decode()
version=run('lean-version',['lake','env','lean','--version']);lean=Path(run('lean-path',['lake','env','which','lean']).strip())
run('build',['lake','build','DefiKernel.Arithmetic.Verify'])
runtime=run('runtime',['lake','env','lean','DefiKernel/Arithmetic/RuntimeAudit.lean'])
observations=re.findall(r'^(arithmetic\.fixture\.f[0-9]+): (true|false)$',runtime,re.M)
assert [k for k,_ in observations]==expected and all(v=='true' for _,v in observations)
proof=run('proof-audit',['lake','env','lean','DefiKernel/Arithmetic/ProofAudit.lean'])
assert 'AXIOM AUDIT PASSED:' in proof and 'forbidden=0' in proof
run('verify',['lake','env','lean','DefiKernel/Arithmetic/Verify.lean'])
after={str(p.relative_to(R)):sha(p.read_bytes()) for p in paths}
assert all(before[p]['sha256']==after[p] for p in before)
record={'status':'DEVELOPMENT_RUNTIME_PASS_NOT_FINAL_ACCEPTANCE','runtime_inventory':expected,'checks':dict(observations),'fixture_plan':{'path':str(plan.relative_to(R)),'sha256':sha(plan.read_bytes())},'sources':{p:before[p]['sha256'] for p in before if p.startswith('lean/DefiKernel/Arithmetic/')},'source_before':before,'source_after':after,'source_unchanged':True,'tool':{'path':str(lean),'sha256':sha(lean.read_bytes()),'version':version.strip()},'commands':'commands.json','runtime_log':'runtime.stdout.log','runtime_log_sha256':sha((D/'runtime.stdout.log').read_bytes()),'pure_checks':37,'actual_reference_checks':8,'finite_cells':16,'full_capability_entries':4,'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'scope':'Current-source development execution, not official frozen production mutations or native acceptance.'}
(D/'runtime-inventory.json').write_text(json.dumps(record,indent=2)+'\n')
helpers={}
for p in paths:
 if p.parent!=R/'lean/DefiKernel/Arithmetic':continue
 text=p.read_text();prefix=text.split('\n-- BEGIN PROOFS\n')[0];helpers[str(p.relative_to(R))]={'sha256':sha(p.read_bytes()),'runtime_prefix_sha256':sha(prefix.encode()),'imports':re.findall(r'^import (\S+)',text,re.M),'explicit_runtime_declarations':re.findall(r'^(?:private )?(?:def|abbrev|structure|inductive) (\w+)',prefix,re.M),'explicit_instance_count':len(re.findall(r'^instance\b',prefix,re.M)),'proof_marker_count':text.count('-- BEGIN PROOFS')}
(D/'actual-projection-inventory.json').write_text(json.dumps({'status':'ACTUAL_SOURCE_INVENTORY','modules':helpers,'limits':'Explicit lexical declaration inventory; compiler-generated declarations belong to dynamic proof inventory. ProofAudit/Verify are excluded runtime roots.'},indent=2)+'\n')
(D/'artifact-inventory.json').write_text(json.dumps([{'path':str(p.relative_to(D)),'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in sorted(D.rglob('*')) if p.is_file()],indent=2)+'\n')
print(json.dumps({'runtime':45,'true':45,'reference':8,'out':str(D)}))
