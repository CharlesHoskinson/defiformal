from pathlib import Path
import subprocess,json,time,hashlib
r=Path('/private/tmp/defiformal-lending-deposit-author/cli-fixture');e=Path('/private/tmp/defiformal-lending-deposit-author');p=r/'lean/DefiKernel/Lending/DepositCollateralAudit.lean';original=p.read_bytes();mode=p.stat().st_mode;rows=[]
a=['python3',str(r/'scripts/replay_lending_deposit_collateral.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
try:
 for name,want,diagnostic in [('wrong-expected',1,'FAIL: actual deposit comparison'),('empty',3,'BLOCKED: empty deposit source'),('missing',3,'BLOCKED:'),('unreadable',3,'BLOCKED:'),('empty-inventory',3,'BLOCKED: deposit assertion inventory missing or duplicated')]:
  p.write_bytes(original);p.chmod(mode)
  if name=='wrong-expected':p.write_bytes(original.replace(b'(run 1) 4 3',b'(run 1) 5 3',1))
  elif name=='empty':p.write_bytes(b'')
  elif name=='missing':p.unlink()
  elif name=='unreadable':p.chmod(0o200)
  elif name=='empty-inventory':
   s=original.decode();p.write_text(s.split('private def checks :')[0]+'private def checks : List (String × Bool) := []\n#eval do'+s.split('#eval do',1)[1])
  t=time.monotonic();q=subprocess.run(a,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180);log=q.stdout+q.stderr;(e/('cli-'+name+'.log')).write_bytes(log)
  passed=q.returncode==want and diagnostic.encode() in log
  if name=='wrong-expected':passed=passed and b'DEPOSIT_CONTROL actual_free_to_own_custody false' in log
  rows.append(dict(name=name,argv=a,exit=q.returncode,expected_exit=want,required_diagnostic=diagnostic,pass_=passed,wall_seconds=time.monotonic()-t,log_sha256=hashlib.sha256(log).hexdigest()));print(name,q.returncode,passed,flush=True)
finally:
 if p.exists():p.chmod(mode)
 p.write_bytes(original);p.chmod(mode)
(e/'cli-controls.json').write_text(json.dumps(dict(status='PASS' if len(rows)==5 and all(x['pass_'] for x in rows) else 'FAIL',controls=rows),indent=2)+'\n');assert len(rows)==5 and all(x['pass_'] for x in rows)
