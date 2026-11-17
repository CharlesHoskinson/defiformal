from pathlib import Path
import subprocess,time,json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-lending-withdraw-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');rows=[]
checks=[('delivery-production-build',[str(tc/'bin/lake'),'build']),('delivery-fresh-controls',[str(tc/'bin/lake'),'env','lean','DefiKernel/Lending/WithdrawCollateralAudit.lean']),('delivery-axioms',[str(tc/'bin/lake'),'env','lean',str(e/'DeliveryAudit.lean')])]
checks += [('delivery-fresh-lifecycle',[str(tc/'bin/lake'),'env','lean','DefiKernel/Lending/LifecycleAudit.lean'])]
checks += [('delivery-kernel-'+module,[str(tc/'bin/lake'),'env','leanchecker','-v','DefiKernel.Lending.'+module]) for module in ['WithdrawCollateral','WithdrawCollateralAudit','LifecycleAudit']]
for name,a in checks:
 t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180);(e/(name+'-r2.log')).write_bytes(q.stdout);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
 if q.returncode:break
(e/'delivery-verification-r2.json').write_text(json.dumps(dict(status='PASS' if len(rows)==7 and all(row['exit']==0 for row in rows) else 'FAIL',runs=rows),indent=2)+'\n');assert len(rows)==7 and all(row['exit']==0 for row in rows)
