#!/usr/bin/env python3
"""A01-A04 mutate copied saved artifacts and invoke the real reconciliation CLI."""
import argparse,hashlib,json,shutil,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);p.add_argument('--production',type=Path,required=True);p.add_argument('--controls',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=a.repo.resolve();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
checker=r/'scripts/check_integer_arithmetic_evidence.py';bound=hashlib.sha256(checker.read_bytes()).hexdigest();records=[]
for name in ['unchanged','A01','A02','A03','A04']:
 d=out/name;prod=d/'production';controls=d/'controls';shutil.copytree(a.production,prod);shutil.copytree(a.controls,controls)
 if name=='A01':
  f=prod/'results.json';v=json.loads(f.read_text());row=next(vv for k,vv in v['results'].items() if k!='control');key=next(k for k,val in row['checks'].items() if val=='true');row['checks'][key]='false';f.write_text(json.dumps(v,indent=2)+'\n')
 if name=='A02':
  v=json.loads((prod/'results.json').read_text());variant=next(k for k in v['results'] if k!='control');(prod/(variant+'.log')).write_bytes((prod/'control.log').read_bytes())
 if name=='A03':
  f=controls/'summary.json';v=json.loads(f.read_text());v['cases'].pop();f.write_text(json.dumps(v,indent=2)+'\n')
 if name=='A04':
  f=controls/'summary.json';v=json.loads(f.read_text());row=next(c for c in v['cases'] if c['name']=='production-eval-discriminating-mutant');base=json.loads((controls/'import-manifest.json').read_text())['original_run_root'];row['log']=str(Path(base)/'runs'/row['name']/'probe.log');f.write_text(json.dumps(v,indent=2)+'\n')
 command=['python3',str(checker),'--repo',str(r),'--production',str(prod),'--controls',str(controls),'--out',str(d/'result.json')]
 tick=time.monotonic();x=subprocess.run(command,cwd=r,capture_output=True,timeout=600);elapsed=time.monotonic()-tick
 (d/'stdout.log').write_bytes(x.stdout);(d/'stderr.log').write_bytes(x.stderr)
 expected=0 if name=='unchanged' else 3
 reason={'A01':'saved observations differ from raw log','A02':'variant log hash mismatch','A03':'CLI case inventory incomplete','A04':'CLI log path is not its top-level case log'}.get(name)
 verdict=json.loads((d/'result.json').read_text())
 reason_matches=reason is None or reason in verdict.get('reason','')
 records.append({'id':name,'command':command,'actual_exit':x.returncode,'expected_exit':expected,'passed':x.returncode==expected and reason_matches,'expected_reason':reason,'reason_matches':reason_matches,'elapsed_seconds':elapsed,'stdout_sha256':hashlib.sha256(x.stdout).hexdigest(),'stderr_sha256':hashlib.sha256(x.stderr).hexdigest()})
 (out/'results.json').write_text(json.dumps({'checker_sha256':bound,'cases':records,'scope':'Actual copied-artifact CLI controls; no Lean re-execution'},indent=2)+'\n')
assert hashlib.sha256(checker.read_bytes()).hexdigest()==bound
assert len(records)==5 and all(row['passed'] for row in records)
print('PASS: unchanged copied evidence and A01-A04 actual rejection controls')
