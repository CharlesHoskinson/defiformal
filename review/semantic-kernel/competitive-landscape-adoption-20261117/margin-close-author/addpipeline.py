from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text();pos=s.index('def run (before')
s=s[:pos]+'''def fundingProgress (cfg : Config) (prepared funded : Funding.State)
    (buckets : Funding.Buckets) (funding : Funding.Receipt) : Progress :=
  ⟨funded,afterBuckets funding.payment,initialFees funding.funding cfg,
    [⟨.funding,funding.funding.feePrimary*cfg.prices.primary,buckets,prepared,funded,funding.payment⟩]⟩
def finish (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt) :
    Except Refusal Result :=
  let progress := fundingProgress cfg prepared funded buckets funding
  if 0<funding.payment.sourceRemainingCostUsd then
    if allowed before cfg then .ok ⟨{progress with fees:=emptyFees progress.fees},
      .exceptional .funding funding.payment.sourceRemainingCostUsd,remainingCosts cfg,base,impact⟩
    else .error (.insufficientFundsToPayForCosts funding.payment.sourceRemainingCostUsd "funding")
  else payRest cfg (allowed before cfg) base impact progress (remainingCosts cfg)

'''+s[pos:]
a=s.index('  let fees := initialFees funding.funding cfg',s.index('def run (before'));b=s.index('\ndef grants',a)
s=s[:a]+'''  finish before cfg base impact prepared funded preparedBuckets funding
'''+s[b:]
s=s.replace('end DefiKernel.Margin.Close','')
s+='''
def Admitted (value : ℤ) (cfg : Config) : Prop :=
  cfg.liquidation=false ∨ liquidatable value cfg=true
instance (value : ℤ) (cfg : Config) : Decidable (Admitted value cfg) :=
  inferInstanceAs (Decidable (_ ∨ _))
theorem admitted_iff (value : ℤ) (cfg : Config) :
    Admitted value cfg ↔ cfg.liquidation=false ∨
      value<(cfg.minCollateralUsd:ℤ) ∨ value≤0 ∨ value<(cfg.minLeverageUsd:ℤ) := by
  simp only [Admitted,liquidatable_iff,or_assoc]

theorem finish_preserves (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt)
    (result : Result) (success : finish before cfg base impact prepared funded buckets funding=.ok result) :
    preserves funded result.progress.state := by
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at success
    cases eligible : allowed before cfg with
    | false => simp [eligible] at success
    | true =>
      simp only [eligible,ite_true] at success
      obtain rfl := Except.ok.inj success
      exact ⟨rfl,rfl,fun _=>rfl⟩
  · simp only [finish,if_neg residual] at success
    exact payRest_preserves _ _ _ _ _ _ _ success

/-- Success exposes the actual two funded transfers and actual funding call, with concrete admission. -/
theorem run_execution (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state ∧
    Admitted (equity before cfg buckets domain) cfg ∧
    ∃ baseAfter base impactAfter impact funded funding,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      Funding.run ⟨impactAfter.world,before.position⟩ cfg.latest domain cfg.prices
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens)
        cfg.holdingConfigured ownerContext Funding.payIds Funding.holdingIds=.ok (funded,funding) ∧
      finish before cfg base impact ⟨impactAfter.world,before.position⟩ funded
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding=.ok result := by
  have compatible : PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state := by
    by_contra incompatible
    rw [reference_binding_refusal _ _ _ _ _ incompatible] at success
    cases success
  have admitted : Admitted (equity before cfg buckets domain) cfg := by
    by_contra denied
    have liq : cfg.liquidation=true := by
      cases value : cfg.liquidation <;> simp_all [Admitted]
    have health : liquidatable (equity before cfg buckets domain) cfg=false := by
      cases value : liquidatable (equity before cfg buckets domain) cfg <;> simp_all [Admitted]
    rw [healthy_refusal _ _ _ _ _ compatible liq health] at success
    cases success
  refine ⟨compatible,admitted,?_⟩
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using compatible
  have notDenied : (cfg.liquidation && !(liquidatable (equity before cfg buckets domain) cfg))=false := by
    rcases admitted with liq | health <;> simp [liq,health]
  cases baseCall : Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids with
  | error reason => simp [run,binding,notDenied,baseCall,Except.mapError,bind,Except.bind] at success
  | ok basePair =>
    rcases basePair with ⟨baseAfter,base⟩
    cases impactCall : Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice
      ownerContext ids with
    | error reason => simp [run,binding,notDenied,baseCall,impactCall,Except.mapError,bind,Except.bind] at success
    | ok impactPair =>
      rcases impactPair with ⟨impactAfter,impact⟩
      cases fundingCall : Funding.run ⟨impactAfter.world,before.position⟩ cfg.latest domain cfg.prices
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens)
        cfg.holdingConfigured ownerContext Funding.payIds Funding.holdingIds with
      | error reason => simp [run,binding,notDenied,baseCall,impactCall,fundingCall,Except.mapError,bind,Except.bind] at success
      | ok fundingPair =>
        rcases fundingPair with ⟨funded,funding⟩
        have finished : finish before cfg base impact ⟨impactAfter.world,before.position⟩ funded
            (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding=.ok result := by
          simpa only [run,binding,notDenied,Bool.not_true,Bool.false_eq_true,ite_false,
            baseCall,impactCall,fundingCall,Except.mapError,bind,Except.bind] using success
        exact ⟨baseAfter,base,impactAfter,impact,funded,funding,rfl,rfl,rfl,finished⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
