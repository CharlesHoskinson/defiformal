from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
/-- Concrete admission, SUM pool custody, SUM rounded primary custody and genuine rights construct
actual execution and actual economic coverage. Source residual zero is never used as a coverage premise. -/
theorem constructive_solvency (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (budget : SolventBudget before cfg domain buckets)
    (rights : ExecutionRights before.world.capabilities cfg.side ids) :
    ∃ result,run before cfg domain buckets ids=.ok result ∧ result.kind=.complete ∧
      (∀ step∈result.progress.executed,Step.Covered cfg.prices step) ∧
      (∀ step∈result.progress.executed,Step.Financial cfg.prices step) ∧
      ∀ cell,0≤result.progress.state.world.state.balance cell := by
  obtain ⟨pi,po,pc,ps,hi,hs,ri,rd⟩ := rights
  obtain ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,preparedCompatible,caps,poolRemaining⟩ :=
    preparation_exists before cfg buckets ids budget.1 budget.2.2.1 ri rd
  let prepared : Funding.State := ⟨impactAfter.world,before.position⟩
  let preparedBuckets := addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens
  let quote := Funding.quote before.position cfg.latest domain
  let input := Funding.paymentInput cfg.prices quote preparedBuckets
  have baseObservation := (Realization.actual_effects _ _ _ _ _ _ _ _ baseCall).2.2.1
  have impactObservation := (Realization.actual_effects _ _ _ _ _ _ _ _ impactCall).2.2.1
  have preparedLiquid : quote.feePrimary+primaryBudget cfg (remainingCosts cfg)≤
      preparedBuckets.output+preparedBuckets.collateral := by
    dsimp only [preparedBuckets]
    rw [baseObservation,impactObservation]
    cases cfg.side <;> simpa [addPayout,preparationTokens,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm] using budget.2.2.2
  have required : primaryNeed cfg.prices input.costUsd=quote.feePrimary :=
    Funding.required_exact cfg.prices quote preparedBuckets
  have headLiquid : primaryNeed cfg.prices input.costUsd≤preparedBuckets.output+preparedBuckets.collateral := by
    rw [required]; omega
  have full := primary_full cfg.prices input headLiquid
  have preparedRights : ExecutionRights prepared.world.capabilities cfg.side ids := by
    rw [caps]
    exact ⟨pi,po,pc,ps,hi,hs,ri,rd⟩
  obtain ⟨pi2,po2,pc2,ps2,hi2,hs2,_,_⟩ := preparedRights
  obtain ⟨funded,funding,fundingCall⟩ := Funding.run_exists prepared cfg.latest domain cfg.prices preparedBuckets
    cfg.holdingConfigured Funding.payIds Funding.holdingIds preparedCompatible pi2 po2 pc2 ps2 hi2 hs2
    (by intro positive; rw [full.2.2.1] at positive; omega)
  have fundingInfo := Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall
  have observation := fundingInfo.2.2.1
  let progress := fundingProgress cfg prepared funded preparedBuckets funding
  have compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state :=
    funding_compatible _ _ _ _ _ _ fundingCall
  have paidRights : PayRights progress.state.world.capabilities := by
    change PayRights funded.world.capabilities
    rw [fundingInfo.2.1]
    exact ⟨pi2,po2,pc2,ps2⟩
  have liquid : primaryBudget cfg (remainingCosts cfg)≤progress.buckets.output+progress.buckets.collateral := by
    change primaryBudget cfg (remainingCosts cfg)≤funding.payment.outputLeft+funding.payment.collateralLeft
    rw [observation]
    change primaryBudget cfg (remainingCosts cfg)≤(Payment.payCost cfg.prices input).outputLeft+
      (Payment.payCost cfg.prices input).collateralLeft
    have capacity := full.2.2.2.2
    rw [required] at capacity
    omega
  have firstFinancial := funding_step_financial cfg prepared funded domain preparedBuckets funding fundingCall
  have firstCovered := step_covered_of_primary cfg.prices _ firstFinancial
    (by simpa only [observation,Funding.receipt] using headLiquid)
  have prior : ∀ step∈progress.executed,Step.Covered cfg.prices step := by
    intro step member
    simp only [progress,fundingProgress,List.mem_singleton] at member
    subst step
    exact firstCovered
  obtain ⟨result,remainder,complete,covered⟩ := payRest_exists cfg (allowed before cfg) base impact progress
    (remainingCosts cfg) compatible paidRights liquid prior
  have zero : funding.payment.sourceRemainingCostUsd=0 := by rw [observation]; exact full.1
  have finished : finish before cfg base impact prepared funded preparedBuckets funding=.ok result := by
    rw [finish,zero]
    exact remainder
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using budget.1
  have notDenied : (cfg.liquidation && !(liquidatable (equity before cfg buckets domain) cfg))=false := by
    rcases budget.2.1 with liq | health
    · simp [liq]
    · simp [health]
  have executed : run before cfg domain buckets ids=.ok result := by
    simpa only [run,binding,notDenied,Bool.not_true,Bool.false_eq_true,ite_false,
      baseCall,impactCall,fundingCall,Except.mapError,bind,Except.bind] using finished
  exact ⟨result,executed,complete,covered,run_financial _ _ _ _ _ _ executed,
    result.progress.state.world.state.nonneg⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
