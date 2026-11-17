from pathlib import Path
import subprocess,time,datetime,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-margin-close-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');s=(r/'lean/DefiKernel/Margin/Close.lean').read_text();control=(r/'lean/DefiKernel/Margin/CloseAudit.lean').read_text();tail='\n'.join(control.splitlines()[1:]);marker='/-- Concrete arithmetic admission';rows=[]
def execute(name,source,expected,diagnostics):
 p=e/('r2-'+name+'.lean');p.write_text(source);a=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();started=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(a,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/('r2-'+name+'.log')).write_bytes(q.stdout);assert q.returncode==expected and all(v.encode() in q.stdout for v in diagnostics),(name,q.returncode,q.stdout[-1000:]);rows.append(dict(name=name,argv=a,cwd=str(r/'lean'),started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
tail=tail[:tail.index('/-- Concrete admitted, funded')]+"\nend DefiKernel.Margin.CloseAudit\n"
def prefix(source):return source[:source.index(marker)]+'\nend DefiKernel.Margin.Close\n'+tail
execute('intact-prefix',prefix(s),0,['CLOSE_OBSERVATION DefiKernel.Margin.Close.Kind.complete 16 4 3','CLOSE_EQUITY_OBSERVATION 0 13','CLOSE_DUST_OBSERVATION 0 1','CLOSE_ORDER_OBSERVATION funding,pnl','CLOSE_CONTROL PASSED 26/26'])
a=s.index('def equity');b=s.index('def liquidatable',a)
wrongsign=s[:a]+s[a:b].replace('before.position.impactUsd-','before.position.impactUsd+',1)+s[b:]
wrongadl=s.replace('if cfg.liquidation && !(liquidatable value cfg)','if cfg.liquidation && !cfg.secondaryAdl && !(liquidatable value cfg)',1)
old='  (if cfg.closeBasePnlUsd<0 then [(.pnl,(-cfg.closeBasePnlUsd).toNat)] else []) ++\n  [(.fees,cfg.otherFeeTokens*cfg.prices.primary)] ++'
new='  [(.fees,cfg.otherFeeTokens*cfg.prices.primary)] ++\n  (if cfg.closeBasePnlUsd<0 then [(.pnl,(-cfg.closeBasePnlUsd).toNat)] else []) ++'
wrongorder=s.replace(old,new,1)
wrongclaim=s.replace('{fees with fundingFee:=0,nonFundingFee:=0}','{fees with fundingFee:=0,nonFundingFee:=0,pendingClaimPrimary:=0,pendingClaimSecondary:=0,latest:=⟨0,0,0⟩}',1)
phantom='def phantomPool (before : Funding.State) (cfg : Config) : Funding.State :=\n  let quantity := (Realization.quote cfg.closeBasePnlUsd cfg.side cfg.pnlPrice).paidTokens+\n    (Realization.quote cfg.closeImpactUsd cfg.side cfg.pnlPrice).paidTokens\n  let fabricated : Ledger := ⟨fun cell=>before.world.state.balance cell+\n    if cell=(.margin,.pool,cfg.side.asset) then (quantity:ℚ) else 0,\n    by intro cell; exact add_nonneg (before.world.state.nonneg cell) (by split <;> positivity)⟩\n  ⟨⟨fabricated,before.world.capabilities⟩,before.position⟩\n'
a=s.index('def run (before');b=s.index('def grants',a)
wrongcash=s[:a]+phantom+s[a:b].replace('Realization.run before cfg.closeBasePnlUsd','Realization.run (phantomPool before cfg) cfg.closeBasePnlUsd',1)+s[b:]
wrongshort=s.replace('buckets,prepared,funded,funding.payment⟩]','buckets,prepared,funded,{funding.payment with economicShortfallUsd:=0}⟩]',1)
for name,source,label,observation in [
 ('positive_funding_equity_sign',wrongsign,'simple_zero_equity_admitted_funding_ten_from_collateral_ten','CLOSE_EQUITY_OBSERVATION 20 19'),
 ('adl_bypasses_liquidation_guard',wrongadl,'secondary_adl_does_not_bypass_healthy_liquidation_guard','CLOSE_EQUITY_OBSERVATION 0 13'),
 ('fees_before_negative_pnl',wrongorder,'pnl_stops_before_fees_impact_and_diff','CLOSE_ORDER_OBSERVATION funding,fees,pnl'),
 ('empty_fees_loses_claims_snapshots',wrongclaim,'allowed_bankruptcy_retains_prefix_skipped_costs_and_claims','CLOSE_CLAIM_OBSERVATION 0 0 0'),
 ('unfunded_pnl_as_pool_cash',wrongcash,'insufficient_preparation_pool_refuses','CLOSE_OBSERVATION DefiKernel.Margin.Close.Kind.complete 20 4 3'),
 ('zero_residual_erases_economic_shortfall',wrongshort,'zero_source_residual_does_not_mean_economic_payment','CLOSE_DUST_OBSERVATION 0 0')]:
 assert source!=s,name
 execute(name+'-runtime-prefix',prefix(source),1,[observation,'CLOSE_CONTROL '+label+' false','FAIL: actual first close comparison'])
 execute(name+'-full-proofs',source,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(s.encode()).hexdigest(),controls_sha256=hashlib.sha256(control.encode()).hexdigest(),runs=rows,scope='Actual altered Close implementation prefixes importing unchanged accepted Realization/Funding/Payment. Six altered runtime observations/false comparisons are distinct from rejection by unchanged full generic proofs. No intact Close cache is imported. Zero-residual mutation changes diagnostic economic shortfall only, not the accepted native Payment formula.'),indent=2)+'\n')
