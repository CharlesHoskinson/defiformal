from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-lending-borrow-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Lending/Borrow.lean').read_text();control=(r/'lean/DefiKernel/Lending/BorrowAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='def evaluated';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Lending.Borrow\n'+tail
execute('intact-prefix',prefix(s),0,['BORROW_OBSERVATION 6 7 5','BORROW_CONTROL PASSED 25/25'])
health=s.replace('(.binary (.add (.amount Asset.cash)) (Oracle.debtCash borrower) amount)','(Oracle.debtCash borrower)',1)
a=s.index('  deltas := [');b=s.index('  supplyDeltas :=',a);block=s[a:b];changed=block.replace('.unary (.neg (.amount Asset.cash)) amount','.lit 0').replace('ref .cash borrower.party,amount','ref .cash borrower.party,.lit 0');assert changed!=block;cash=s[:a]+changed+s[b:]
for name,source,label,observation in [('pre_debt_health_omits_increase',health,'post_debt_includes_requested_increase','BORROW_HEALTH_OBSERVATION 5 8 4 3'),('debt_issued_without_cash',cash,'actual_cash_debt_movement','BORROW_OBSERVATION 3 10 5')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'BORROW_CONTROL '+label+' false','FAIL: actual borrow comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual Borrow API-prefix bodies import unchanged Oracle/Support/Types, not intact cached Borrow. Mutants actually succeed to explicit unhealthy/wrong-cash ledgers; comparison failure and unchanged-proof compiler rejection are distinct.'),indent=2)+'\n')
