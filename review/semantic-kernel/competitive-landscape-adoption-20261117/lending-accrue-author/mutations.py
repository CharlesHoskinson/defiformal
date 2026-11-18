from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-lending-accrue-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Lending/Accrue.lean').read_text();control=(r/'lean/DefiKernel/Lending/AccrueAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='/-- Increment is denominated';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Lending.Accrue\n'+tail
execute('intact-prefix',prefix(s),0,['ACCRUE_OBSERVATION 3 10 4 2','ACCRUE_CONTROL PASSED 21/21'])
wrongtime=s.replace('def rateTime : E signature .scalar := .binary (.scale .scalar) rate elapsed','def rateTime : E signature .scalar := rate',1)
wrongguard=s.replace('guard := .binary .and (.binary (.le .scalar) (.lit 0) rate)\n    (.binary (.le .scalar) (.lit 0) elapsed)','guard := .lit true',1)
for name,source,label,observation in [('elapsed_ignored',wrongtime,'fractional_rate_and_interval','ACCRUE_FRACTIONAL_OBSERVATION 5/2'),('negative_parameters_admitted',wrongguard,'two_negatives_still_refuse','ACCRUE_NEGATIVE_OBSERVATION 4')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'ACCRUE_CONTROL '+label+' false','FAIL: actual accrue comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual Accrue API-prefix bodies import unchanged Support/Types, not intact cached Accrue. Wrong elapsed and negative-parameter admission execute actual altered bodies. False runtime comparisons and unchanged-proof compiler rejection are distinct.'),indent=2)+'\n')
