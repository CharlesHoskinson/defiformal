from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Funding.lean');s=p.read_text().replace('end DefiKernel.Margin.Funding','')
s+='''
/-- Funding is an expense, not a pending-claim cash credit. This excludes all other health fees. -/
def signedFundingCharge (prices : Payment.Prices) (funding : Quote) : ℚ :=
  -(funding.feePrimary:ℚ)*(prices.primary:ℚ)
def markedCollateralEquity (state : State) (prices : Payment.Prices) : ℚ :=
  state.world.state.balance (.margin,.position,.primary)*(prices.primary:ℚ)+
    (state.position.pnlUsd:ℚ)+(state.position.impactUsd:ℚ)
theorem signedFundingCharge_nonpositive (prices : Payment.Prices) (funding : Quote) :
    signedFundingCharge prices funding ≤ 0 := by
  unfold signedFundingCharge
  exact mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Nat.cast_nonneg _)) (Nat.cast_nonneg _)

/-- Full primary-collateral settlement realizes the negative funding contribution once.
The post-collateral value already incorporates this fee; subtracting it again would double-count.
Marked PnL/impact are unchanged observations here, not a full source-health or cash-realization claim. -/
theorem primary_paid_equity (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed))
    (noOutput : buckets.output=0)
    (funded : (quote before.position latest domain).feePrimary ≤ buckets.collateral) :
    markedCollateralEquity after prices=markedCollateralEquity before prices+
      signedFundingCharge prices (quote before.position latest domain) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have collateral := info.2.2.2 (.margin,.position,.primary)
  rw [PaymentSettlement.collateral_effect,info.2.2.1] at collateral
  simp only [receipt] at collateral
  have paid : (Payment.payCost prices (paymentInput prices
      (quote before.position latest domain) buckets)).paidCollateral=
        (quote before.position latest domain).feePrimary := by
    change min buckets.collateral
      ((Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)).primaryRequired-
        min buckets.output (Payment.payCost prices
          (paymentInput prices (quote before.position latest domain) buckets)).primaryRequired)=_
    rw [required_exact,noOutput]
    simpa using min_eq_right funded
  rw [paid] at collateral
  simp only [reduceCtorEq,if_false,add_zero] at collateral
  unfold markedCollateralEquity signedFundingCharge
  rw [collateral,info.1]
  ring
end DefiKernel.Margin.Funding
''';p.write_text(s)
