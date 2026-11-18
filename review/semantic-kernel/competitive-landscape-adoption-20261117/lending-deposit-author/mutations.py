from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-lending-deposit-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Lending/DepositCollateral.lean').read_text();control=(r/'lean/DefiKernel/Lending/DepositCollateralAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='def evaluated';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Lending.DepositCollateral\n'+tail
execute('intact-prefix',prefix(s),0,['DEPOSIT_OBSERVATION 4 3 0 100','DEPOSIT_CONTROL PASSED 18/18'])
a=s.index('def template');b=s.index('private def registry',a)
block=s[a:b];wrong=s[:a]+block.replace('borrower.custody','.pool')+s[b:]
assert wrong!=s
execute('wrong_custody-runtime-prefix',prefix(wrong),1,['DEPOSIT_OBSERVATION 4 2 1 100','DEPOSIT_CONTROL actual_free_to_own_custody false','FAIL: actual deposit comparison'])
execute('wrong_custody-full-proofs',wrong,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Altered actual template changes both collateral credit target and declared write target to pool, so it executes to the observed wrong custody ledger. Prefix imports unchanged Support/Types, not intact cached DepositCollateral. False runtime comparison and unchanged-proof compiler rejection are distinct.'),indent=2)+'\n')
