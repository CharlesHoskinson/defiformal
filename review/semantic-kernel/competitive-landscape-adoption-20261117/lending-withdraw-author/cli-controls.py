from pathlib import Path
import subprocess,json,time,hashlib
r=Path('/private/tmp/defiformal-lending-withdraw-author/cli-fixture');e=r.parent;rows=[]
paths={name:r/('lean/DefiKernel/Lending/'+stem+'.lean') for name,stem in [('withdraw','WithdrawCollateralAudit'),('lifecycle','LifecycleAudit')]}
originals={name:p.read_bytes() for name,p in paths.items()};modes={name:p.stat().st_mode for name,p in paths.items()}
a=['python3',str(r/'scripts/replay_lending_withdraw_collateral.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
def restore():
 for name,p in paths.items():
  if p.exists():p.chmod(modes[name])
  p.write_bytes(originals[name]);p.chmod(modes[name])
try:
 for target in ['withdraw','lifecycle']:
  for name,want in [('wrong-expected',1),('empty',3),('missing',3),('unreadable',3),('empty-inventory',3)]:
   restore();p=paths[target];original=originals[target]
   if name=='wrong-expected':
    old,new=(b'(run 3) 8 7',b'(run 3) 9 7') if target=='withdraw' else (b'stages 4 7 98 3 5 5',b'stages 4 8 98 3 5 5')
    changed=original.replace(old,new,1);assert changed!=original;p.write_bytes(changed)
   elif name=='empty':p.write_bytes(b'')
   elif name=='missing':p.unlink()
   elif name=='unreadable':p.chmod(0o200)
   elif name=='empty-inventory':
    s=original.decode();p.write_text(s.split('private def checks :')[0]+'private def checks : List (String × Bool) := []\n#eval do'+s.split('#eval do',1)[1])
   t=time.monotonic();q=subprocess.run(a,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180);log=q.stdout+q.stderr;stem='cli-'+target+'-'+name;(e/(stem+'.log')).write_bytes(log)
   diagnostic=('FAIL: actual '+target+' comparison') if name=='wrong-expected' else ('BLOCKED: '+target+' assertion inventory missing or duplicated') if name=='empty-inventory' else ('BLOCKED: empty '+target+' source') if name=='empty' else 'BLOCKED:'
   passed=q.returncode==want and diagnostic.encode() in log
   if name=='wrong-expected':
    label='WITHDRAW_CONTROL actual_locked_to_own_free false' if target=='withdraw' else 'LIFECYCLE_CONTROL withdrawal_final_exact_ledger false'
    passed=passed and label.encode() in log
   rows.append(dict(name=stem,argv=a,exit=q.returncode,expected_exit=want,required_diagnostic=diagnostic,pass_=passed,wall_seconds=time.monotonic()-t,log_sha256=hashlib.sha256(log).hexdigest()));print(stem,q.returncode,passed,flush=True)
finally:restore()
(e/'cli-controls.json').write_text(json.dumps(dict(status='PASS' if len(rows)==10 and all(x['pass_'] for x in rows) else 'FAIL',controls=rows),indent=2)+'\n');assert len(rows)==10 and all(x['pass_'] for x in rows)
