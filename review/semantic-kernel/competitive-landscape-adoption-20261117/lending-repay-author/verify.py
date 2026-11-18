from pathlib import Path
import subprocess,time,json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-lending-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');rows=[]
checks=[('production-build',[str(tc/'bin/lake'),'build','DefiKernel']),('fresh-controls',[str(tc/'bin/lake'),'env','lean','DefiKernel/Lending/RepayAudit.lean']),('axioms',[str(tc/'bin/lake'),'env','lean',str(e/'Audit.lean')]),('kernel',[str(tc/'bin/lake'),'env','leanchecker','-v','DefiKernel.Lending.Repay']),('kernel-types',[str(tc/'bin/lake'),'env','leanchecker','-v','DefiKernel.Lending.Types']),('kernel-controls',[str(tc/'bin/lake'),'env','leanchecker','-v','DefiKernel.Lending.RepayAudit'])]
for name,a in checks:
 t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180);(e/(name+'.log')).write_bytes(q.stdout);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
 if q.returncode:break
(e/'proof-verification.json').write_text(json.dumps(dict(status='PASS' if len(rows)==6 and all(row['exit']==0 for row in rows) else 'FAIL',runs=rows),indent=2)+'\n');assert len(rows)==6 and all(row['exit']==0 for row in rows)
