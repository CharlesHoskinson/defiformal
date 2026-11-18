from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-margin-payment-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Margin/Payment.lean').read_text();control=(r/'lean/DefiKernel/Margin/PaymentAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='/-- Native ceil division';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Margin.Payment\n'+tail
execute('intact-prefix',prefix(s),0,['PAYMENT_CONTROL PASSED 12/12'])
wrongceil=s.replace('let required := (input.costUsd+prices.primary-1)/prices.primary','let required := input.costUsd/prices.primary',1)
old='input.costUsd-((paidOutput+paidCollateral)*prices.primary+paidSecondary*prices.secondary)'
wrongshortfall=s.replace(old,'(secondaryRequired-paidSecondary)*prices.secondary',1)
for name,source,label,observed in [('floor_instead_of_ceil',wrongceil,'sufficient_primary','PAYMENT_NATIVE_CASE sufficient_primary 0,1,0,1,0,0'),('source_residual_as_economic_shortfall',wrongshortfall,'zero_source_residual_is_not_full_payment','PAYMENT_NATIVE_DUST zero_source_residual_shortfall 0,1,0')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observed,'PAYMENT_CONTROL '+label+' false','FAIL: actual payment comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual altered Payment API-prefix bodies; no import of intact cached Payment. Wrong ceil changes real payment buckets; source-residual substitution changes real economic-shortfall field while core source-helper projection stays unchanged. Runtime assertion failure and unchanged-proof compiler rejection are distinct.'),indent=2)+'\n')
