from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
def Step.input (step : Step) : Payment.Inputs :=
  ⟨step.costUsd,step.buckets.output,step.buckets.collateral,step.buckets.secondary⟩
def Step.actualPaidUsd (prices : Payment.Prices) (step : Step) : ℚ :=
  (step.after.world.state.balance (.margin,.costRecipient,.primary)-
    step.before.world.state.balance (.margin,.costRecipient,.primary))*(prices.primary:ℚ)+
  (step.after.world.state.balance (.margin,.costRecipient,.secondary)-
    step.before.world.state.balance (.margin,.costRecipient,.secondary))*(prices.secondary:ℚ)
def Step.Financial (prices : Payment.Prices) (step : Step) : Prop :=
  step.payment=Payment.payCost prices step.input ∧
  PaymentSettlement.Compatible step.input step.before.world.state ∧
  PaymentSettlement.Compatible ⟨0,step.payment.outputLeft,step.payment.collateralLeft,
    step.payment.secondaryLeft⟩ step.after.world.state ∧
  (step.costUsd:ℚ)+(step.payment.ceilDustUsd:ℚ)=step.actualPaidUsd prices+
    (step.payment.sourceRemainingCostUsd:ℚ)+(step.payment.floorDustUsd:ℚ)

theorem ordinary_step_financial (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ)
    (post : World) (payment : Payment.Result)
    (success : PaymentSettlement.run cfg.prices
      ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
      progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state=.ok (post,payment)) :
    Step.Financial cfg.prices ⟨stage,cost,progress.buckets,progress.state,⟨post,progress.state.position⟩,payment⟩ := by
  obtain ⟨executed,quoteEq⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp success
  exact ⟨quoteEq,PaymentSettlement.success_compatible _ _ _ _ _ _ _ executed,
    payment_compatible _ _ _ _ _ success,
    PaymentSettlement.actual_financial_reconciliation _ _ _ _ _ _ _ _ success⟩

theorem funding_step_financial (cfg : Config) (prepared funded : Funding.State)
    (domain : Funding.Admissible prepared.position cfg.latest) (buckets : Funding.Buckets)
    (funding : Funding.Receipt)
    (success : Funding.run prepared cfg.latest domain cfg.prices buckets cfg.holdingConfigured ownerContext
      Funding.payIds Funding.holdingIds=.ok (funded,funding)) :
    Step.Financial cfg.prices ⟨.funding,funding.funding.feePrimary*cfg.prices.primary,
      buckets,prepared,funded,funding.payment⟩ := by
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.1
  obtain ⟨paid,executed,_,_,_⟩ := (Funding.run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mp success
  have compatible := PaymentSettlement.success_compatible _ _ _ _ _ _ _ executed
  refine ⟨?_,?_,funding_compatible _ _ _ _ _ _ success,?_⟩
  · rw [observation]; rfl
  · simpa only [Step.input,observation,Funding.receipt,Funding.paymentInput] using compatible
  · simpa only [Step.actualPaidUsd,Nat.cast_mul] using Funding.actual_reconciliation _ _ _ _ _ _ _ _ _ _ _ success

theorem payOne_financial (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result)
    (prior : ∀ step∈progress.executed,Step.Financial cfg.prices step)
    (success : payOne cfg progress stage cost=.ok (next,payment)) :
    ∀ step∈next.executed,Step.Financial cfg.prices step := by
  obtain ⟨post,paid,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  intro step member
  simp only [nextProgress,List.mem_append,List.mem_singleton] at member
  rcases member with old | rfl
  · exact prior step old
  · exact ordinary_step_financial _ _ _ _ _ _ paid

theorem payRest_financial (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (prior : ∀ step∈progress.executed,Step.Financial cfg.prices step)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    ∀ step∈result.progress.executed,Step.Financial cfg.prices step := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact prior
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have nextValid := payOne_financial _ _ _ _ _ _ prior actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact nextValid
      · rw [if_neg residual] at success
        exact ih next nextValid success

/-- Every returned payment is bound to its own actual pre/post ledger and exact native quote. -/
theorem run_financial (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∀ step∈result.progress.executed,Step.Financial cfg.prices step := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have fundingValid := funding_step_financial _ _ _ _ _ _ fundingCall
  have initialValid : ∀ step∈(fundingProgress cfg ⟨impactAfter.world,before.position⟩ funded
      (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding).executed,
      Step.Financial cfg.prices step := by
    intro step member
    simp only [fundingProgress,List.mem_singleton] at member
    subst step
    exact fundingValid
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      exact initialValid
  · simp only [finish,if_neg residual] at finished
    exact payRest_financial _ _ _ _ _ _ _ initialValid finished
end DefiKernel.Margin.Close
''';p.write_text(s)
