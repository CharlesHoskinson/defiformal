from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-margin-realization-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Margin/Realization.lean').read_text();control=(r/'lean/DefiKernel/Margin/RealizationAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='/-- The returned dust';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/(name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Margin.Realization\n'+tail
execute('intact-prefix',prefix(s),0,['REALIZATION_OBSERVATION 2 4 3 1','REALIZATION_CONTROL PASSED 18/18'])
wrongceil=s.replace('basePnlUsd.toNat/price.max','(basePnlUsd.toNat+price.max-1)/price.max',1)
phantom='def phantomPool (pre : Ledger) (side : Side) (quantity : ℕ) : Ledger :=\n  ⟨fun cell=>pre.balance cell+if cell=(.margin,.pool,side.asset) then (quantity:ℚ) else 0,\n    by intro cell; exact add_nonneg (pre.nonneg cell) (by split <;> positivity)⟩\n'
a=s.index('def run (before');b=s.index('def grants',a)
wrongcash=s[:a]+phantom+s[a:b].replace('ctx ids before.world.state','ctx ids (phantomPool before.world.state side (quote basePnlUsd side price).paidTokens)')+s[b:]
for name,source,label,observation in [('ceil_instead_of_floor',wrongceil,'primary_pool_funded_floor_and_dust','REALIZATION_OBSERVATION 1 5 4 1'),('pnl_as_unfunded_pool_cash',wrongcash,'insufficient_actual_pool_refuses','REALIZATION_OBSERVATION 5 4 3 1')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'REALIZATION_CONTROL '+label+' false','FAIL: first realization comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual altered Realization implementation prefixes importing unchanged Funding/PaymentSettlement; no intact Realization cache. Ceiling mutates the computed payout. PnL-as-cash mutant injects fictitious pool funding before the actual executor, so payout succeeds while original pool is not debited and previously insufficient pool succeeds. Runtime false comparisons and unchanged full-proof rejection are distinct.'),indent=2)+'\n')
