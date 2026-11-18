from pathlib import Path
s=Path('/private/tmp/defiformal-margin-funding-author/mutations.py').read_text();s=s[:s.index('def prefix(source)')]+'''def prefix(source):return source[:source.index(marker)]+'\\nend DefiKernel.Margin.Realization\\n'+tail
execute('intact-prefix',prefix(s),0,['REALIZATION_OBSERVATION 2 4 3 1','REALIZATION_CONTROL PASSED 18/18'])
wrongceil=s.replace('basePnlUsd.toNat/price.max','(basePnlUsd.toNat+price.max-1)/price.max',1)
phantom='''+repr('''def phantomPool (pre : Ledger) (side : Side) (quantity : ℕ) : Ledger :=
  ⟨fun cell=>pre.balance cell+if cell=(.margin,.pool,side.asset) then (quantity:ℚ) else 0,
    by intro cell; exact add_nonneg (pre.nonneg cell) (by split <;> positivity)⟩
''')+'''
a=s.index('def run (before');b=s.index('def grants',a)
wrongcash=s[:a]+phantom+s[a:b].replace('ctx ids before.world.state','ctx ids (phantomPool before.world.state side (quote basePnlUsd side price).paidTokens)')+s[b:]
for name,source,label,observation in [('ceil_instead_of_floor',wrongceil,'primary_pool_funded_floor_and_dust','REALIZATION_OBSERVATION 1 5 4 1'),('pnl_as_unfunded_pool_cash',wrongcash,'insufficient_actual_pool_refuses','REALIZATION_OBSERVATION 5 4 3 1')]:
 assert source!=s
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'REALIZATION_CONTROL '+label+' false','FAIL: first realization comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual altered Realization implementation prefixes importing unchanged Funding/PaymentSettlement; no intact Realization cache. Ceiling mutates the computed payout. PnL-as-cash mutant injects fictitious pool funding before the actual executor, so payout succeeds while original pool is not debited and previously insufficient pool succeeds. Runtime false comparisons and unchanged full-proof rejection are distinct.'),indent=2)+'\\n')
'''
s=s.replace('margin-funding-author','margin-realization-author').replace('FundingAudit.lean','RealizationAudit.lean').replace('Funding.lean','Realization.lean').replace("marker='/-- Both obligations'","marker='/-- The returned dust'")
Path('/private/tmp/defiformal-margin-realization-author/mutations.py').write_text(s)
