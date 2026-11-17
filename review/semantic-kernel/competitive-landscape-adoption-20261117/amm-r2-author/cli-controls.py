from pathlib import Path
import subprocess,json,hashlib,time
repo=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-r2-author')
p=repo/'lean/DefiKernel/AMM/R2BridgeAudit.lean';original=p.read_bytes();mode=p.stat().st_mode;rows=[]
argv=['python3',str(repo/'scripts/replay_amm_r2.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64','--output']
cases=[('wrong-expected',1,'FAIL: native command failed: fresh-source'),('empty',3,'BLOCKED: empty input: controls'),('missing',3,'BLOCKED:'),('unreadable',3,'BLOCKED:')]
try:
 for name,expected,diagnostic in cases:
  p.write_bytes(original);p.chmod(mode)
  if name=='wrong-expected':p.write_bytes(original.replace(b'Result.success (14/25)',b'Result.success (15/25)',1))
  elif name=='empty':p.write_bytes(b'')
  elif name=='missing':p.unlink()
  elif name=='unreadable':p.chmod(0o200)
  command=argv+[str(e/('cli-'+name))];t=time.monotonic()
  r=subprocess.run(command,cwd=repo,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180)
  log=r.stdout+r.stderr;(e/('cli-'+name+'.log')).write_bytes(log)
  passed=r.returncode==expected and diagnostic.encode() in log
  if name=='wrong-expected':passed=passed and b'R2_CONTROL original_fractional false' in log
  rows.append(dict(name=name,argv=command,exit=r.returncode,expected_exit=expected,diagnostic=diagnostic,pass_=passed,wall_seconds=time.monotonic()-t,log_sha256=hashlib.sha256(log).hexdigest()))
  print(name,r.returncode,passed,flush=True)
finally:
 p.chmod(mode) if p.exists() else None
 p.write_bytes(original);p.chmod(mode)
(e/'cli-controls.json').write_text(json.dumps(dict(status='PASS' if all(r['pass_'] for r in rows) and len(rows)==4 else 'FAIL',checks=rows),indent=2)+'\n')
assert len(rows)==4 and all(r['pass_'] for r in rows)
