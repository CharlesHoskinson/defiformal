from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
/-- Sufficient primary tokens eliminate secondary spending and economic shortfall, retaining exact capacity. -/
theorem primary_full (prices : Payment.Prices) (input : Payment.Inputs)
    (liquid : primaryNeed prices input.costUsd ≤ input.primaryOutput+input.collateral) :
    (Payment.payCost prices input).sourceRemainingCostUsd=0 ∧
    (Payment.payCost prices input).economicShortfallUsd=0 ∧
    (Payment.payCost prices input).paidSecondary=0 ∧
    (Payment.payCost prices input).floorDustUsd=0 ∧
    (Payment.payCost prices input).outputLeft+(Payment.payCost prices input).collateralLeft+
      primaryNeed prices input.costUsd=input.primaryOutput+input.collateral := by
  have coverage := Payment.sufficient_primary_coverage prices input liquid
  have remaining := Payment.sufficient_primary_remaining_zero prices input liquid
  have buckets := Payment.bucket_reconciliation prices input
  have shortfall : (Payment.payCost prices input).economicShortfallUsd=0 := by
    change input.costUsd-(((Payment.payCost prices input).paidPrimaryOutput+
      (Payment.payCost prices input).paidCollateral)*prices.primary+
      (Payment.payCost prices input).paidSecondary*prices.secondary)=0
    rw [coverage.2.2.1]
    simp only [zero_mul,add_zero]
    exact Nat.sub_eq_zero_of_le coverage.2.2.2
  refine ⟨coverage.1,shortfall,coverage.2.2.1,coverage.2.1,?_⟩
  change (Payment.payCost prices input).primaryRemaining=0 at remaining
  change (Payment.payCost prices input).outputLeft+(Payment.payCost prices input).collateralLeft+
    (Payment.payCost prices input).primaryRequired=input.primaryOutput+input.collateral
  omega

def Step.Covered (prices : Payment.Prices) (step : Step) : Prop :=
  step.payment.sourceRemainingCostUsd=0 ∧ step.payment.economicShortfallUsd=0 ∧
    (step.costUsd:ℚ)≤step.actualPaidUsd prices

theorem step_covered_of_primary (prices : Payment.Prices) (step : Step)
    (financial : Step.Financial prices step)
    (liquid : primaryNeed prices step.costUsd≤step.buckets.output+step.buckets.collateral) :
    Step.Covered prices step := by
  have full := primary_full prices step.input liquid
  have residue : step.payment.sourceRemainingCostUsd=0 := by rw [financial.1]; exact full.1
  have shortfall : step.payment.economicShortfallUsd=0 := by rw [financial.1]; exact full.2.1
  have dust : step.payment.floorDustUsd=0 := by rw [financial.1]; exact full.2.2.2.1
  refine ⟨residue,shortfall,?_⟩
  have reconciled := financial.2.2.2
  rw [residue,dust] at reconciled
  simp only [Nat.cast_zero,add_zero] at reconciled
  calc
    _ ≤ (step.costUsd:ℚ)+(step.payment.ceilDustUsd:ℚ) := le_add_of_nonneg_right (Nat.cast_nonneg _)
    _ = step.actualPaidUsd prices := reconciled

def PayRights (store : Store) : Prop :=
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId .invoke=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true

theorem payOne_exists (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ)
    (compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state)
    (rights : PayRights progress.state.world.capabilities) :
    ∃ next,payOne cfg progress stage cost=.ok (next,Payment.payCost cfg.prices
      ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩) := by
  obtain ⟨post,paid⟩ := PaymentSettlement.run_exists cfg.prices
    ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    progress.state.world.capabilities Funding.payIds progress.state.world.state compatible
    rights.1 rights.2.1 rights.2.2.1 rights.2.2.2
  exact ⟨nextProgress progress stage cost post _,(payOne_ok_iff _ _ _ _ _ _).mpr ⟨post,paid,rfl⟩⟩

theorem payRest_exists (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ))
    (compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state)
    (rights : PayRights progress.state.world.capabilities)
    (liquid : primaryBudget cfg costs≤progress.buckets.output+progress.buckets.collateral)
    (prior : ∀ step∈progress.executed,Step.Covered cfg.prices step) :
    ∃ result,payRest cfg insolvencyAllowed base impact progress costs=.ok result ∧ result.kind=.complete ∧
      ∀ step∈result.progress.executed,Step.Covered cfg.prices step := by
  induction costs generalizing progress with
  | nil => exact ⟨⟨progress,.complete,[],base,impact⟩,rfl,rfl,prior⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    let input : Payment.Inputs := ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    let quote := Payment.payCost cfg.prices input
    have budget : primaryNeed cfg.prices cost+primaryBudget cfg tail≤
        progress.buckets.output+progress.buckets.collateral := by simpa [primaryBudget] using liquid
    have headLiquid : primaryNeed cfg.prices cost≤progress.buckets.output+progress.buckets.collateral := by omega
    have full := primary_full cfg.prices input headLiquid
    obtain ⟨next,actual⟩ := payOne_exists cfg progress stage cost compatible rights
    obtain ⟨post,paid,nextEq⟩ := (payOne_ok_iff _ _ _ _ _ _).mp actual
    have nextCompatible : PaymentSettlement.Compatible
        ⟨0,next.buckets.output,next.buckets.collateral,next.buckets.secondary⟩ next.state.world.state := by
      rw [nextEq]
      exact payment_compatible _ _ _ _ _ paid
    have caps := (payOne_preserves _ _ _ _ _ _ actual).2.1
    have nextRights : PayRights next.state.world.capabilities := by rw [caps]; exact rights
    have nextLiquid : primaryBudget cfg tail≤next.buckets.output+next.buckets.collateral := by
      rw [nextEq]
      change primaryBudget cfg tail≤quote.outputLeft+quote.collateralLeft
      have capacity := full.2.2.2.2
      change quote.outputLeft+quote.collateralLeft+primaryNeed cfg.prices cost=
        progress.buckets.output+progress.buckets.collateral at capacity
      omega
    have newFinancial := ordinary_step_financial _ _ _ _ _ _ paid
    have newCovered := step_covered_of_primary cfg.prices _ newFinancial headLiquid
    have allCovered : ∀ step∈next.executed,Step.Covered cfg.prices step := by
      rw [nextEq]
      intro step member
      simp only [nextProgress,List.mem_append,List.mem_singleton] at member
      rcases member with old | rfl
      · exact prior step old
      · exact newCovered
    obtain ⟨result,recurse,complete,covered⟩ := ih next nextCompatible nextRights nextLiquid allCovered
    refine ⟨result,?_,complete,covered⟩
    rw [payRest,actual]
    simp only [bind,Except.bind]
    have zero : quote.sourceRemainingCostUsd=0 := full.1
    rw [show (Payment.payCost cfg.prices input).sourceRemainingCostUsd=0 from zero]
    exact recurse
end DefiKernel.Margin.Close
''';p.write_text(s)
