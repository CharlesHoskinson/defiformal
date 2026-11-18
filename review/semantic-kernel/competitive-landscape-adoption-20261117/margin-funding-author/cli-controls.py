from pathlib import Path
import subprocess,json,time,hashlib
r=Path('/private/tmp/defiformal-margin-funding-author/cli-fixture');e=Path('/private/tmp/defiformal-margin-funding-author');p=r/'lean/DefiKernel/Margin/FundingAudit.lean';original=p.read_bytes();mode=p.stat().st_mode;rows=[]
a=['python3',str(r/'scripts/replay_margin_funding.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
try:
 for name,want,diagnostic in [('wrong-expected',1,'FAIL: actual first funding comparison'),('empty',3,'BLOCKED: empty margin funding source/model'),('missing',3,'BLOCKED:'),('unreadable',3,'BLOCKED:'),('empty-inventory',3,'BLOCKED: margin funding assertion inventory missing or duplicated')]:
  p.write_bytes(original);p.chmod(mode)
  if name=='wrong-expected':p.write_bytes(original.replace(b'r.funding.feePrimary=2',b'r.funding.feePrimary=3',1))
  elif name=='empty':p.write_bytes(b'')
  elif name=='missing':p.unlink()
  elif name=='unreadable':p.chmod(0o200)
  elif name=='empty-inventory':
   data=original.decode();p.write_text(data.split('private def checks :')[0]+'private def checks : List (String × Bool) := []\n#eval do'+data.split('#eval do',1)[1])
  t=time.monotonic();q=subprocess.run(a,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180);log=q.stdout+q.stderr;(e/('cli-'+name+'.log')).write_bytes(log)
  passed=q.returncode==want and diagnostic.encode() in log
  if name=='wrong-expected':passed=passed and b'FUNDING_CONTROL fee_paid_pending_claims_and_snapshots_preserved false' in log
  rows.append(dict(name=name,argv=a,exit=q.returncode,expected_exit=want,required_diagnostic=diagnostic,pass_=passed,wall_seconds=time.monotonic()-t,log_sha256=hashlib.sha256(log).hexdigest()));print(name,q.returncode,passed,flush=True)
finally:
 if p.exists():p.chmod(mode)
 p.write_bytes(original);p.chmod(mode)
(e/'cli-controls.json').write_text(json.dumps(dict(status='PASS' if len(rows)==5 and all(x['pass_'] for x in rows) else 'FAIL',controls=rows),indent=2)+'\n');assert len(rows)==5 and all(x['pass_'] for x in rows)
