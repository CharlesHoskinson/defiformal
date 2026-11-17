from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('  costUsd : ℕ\n  before : Funding.State','  costUsd : ℕ\n  buckets : Funding.Buckets\n  before : Funding.State').replace('⟨stage,cost,progress.state,after,payment⟩','⟨stage,cost,progress.buckets,progress.state,after,payment⟩').replace('⟨.funding,funding.funding.feePrimary*cfg.prices.primary,prepared,funded,funding.payment⟩','⟨.funding,funding.funding.feePrimary*cfg.prices.primary,preparedBuckets,prepared,funded,funding.payment⟩').replace('end DefiKernel.Margin.Close','')
s+='''
/-- Concrete arithmetic admission, independent of custody sufficiency and of the ADL flag. -/
theorem liquidatable_iff (value : ℤ) (cfg : Config) :
    liquidatable value cfg=true ↔ value<(cfg.minCollateralUsd:ℤ) ∨ value≤0 ∨ value<(cfg.minLeverageUsd:ℤ) := by
  by_cases first : value<(cfg.minCollateralUsd:ℤ)
  · simp [liquidatable,first]
  · by_cases second : value≤0 <;> simp [liquidatable,first,second]

theorem allowed_iff (before : Funding.State) (cfg : Config) :
    allowed before cfg=true ↔ before.position.sizeUsd=cfg.sizeDeltaUsd ∧
      (cfg.liquidation=true ∨ cfg.secondaryAdl=true) := by
  simp [allowed,Bool.or_eq_true]

theorem emptyFees_preserves (fees : Fees) :
    (emptyFees fees).fundingFee=0 ∧ (emptyFees fees).nonFundingFee=0 ∧
    (emptyFees fees).pendingClaimPrimary=fees.pendingClaimPrimary ∧
    (emptyFees fees).pendingClaimSecondary=fees.pendingClaimSecondary ∧
    (emptyFees fees).latest=fees.latest := by exact ⟨rfl,rfl,rfl,rfl,rfl⟩

theorem healthy_refusal (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩
      before.world.state)
    (liquidation : cfg.liquidation=true)
    (healthy : liquidatable (equity before cfg buckets domain) cfg=false) :
    run before cfg domain buckets ids=.error (.positionShouldNotBeLiquidated ""
      (equity before cfg buckets domain) cfg.minCollateralUsd cfg.minLeverageUsd) := by
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using compatible
  simp [run,binding,liquidation,healthy,bind,Except.bind]

theorem reference_binding_refusal (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (incompatible : ¬ PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state) :
    run before cfg domain buckets ids=.error .referenceBucketBinding := by
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=false := by simpa using incompatible
  simp [run,binding,bind,Except.bind]

theorem payout_compatible (before after : Funding.State) (basePnlUsd : ℤ)
    (side : Realization.Side) (price : Realization.Price) (ids : List CapabilityId)
    (receipt : Realization.Receipt) (buckets : Funding.Buckets)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩
      before.world.state)
    (success : Realization.run before basePnlUsd side price ownerContext ids=.ok (after,receipt)) :
    PaymentSettlement.Compatible ⟨0,(addPayout buckets side receipt.paidTokens).output,
      (addPayout buckets side receipt.paidTokens).collateral,
      (addPayout buckets side receipt.paidTokens).secondary⟩ after.world.state := by
  have paid := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ success).2
  have frame := Realization.actual_frame before basePnlUsd side price ownerContext ids after receipt success
  cases side with
  | primary =>
    refine ⟨?_,?_,?_⟩
    · simpa [addPayout,Realization.Side.asset,compatible.1,Nat.cast_add] using paid
    · simpa [addPayout] using (frame (.margin,.position,.primary) (by decide) (by decide)).trans compatible.2.1
    · simpa [addPayout] using (frame (.margin,.output,.secondary) (by decide) (by decide)).trans compatible.2.2
  | secondary =>
    refine ⟨?_,?_,?_⟩
    · simpa [addPayout] using (frame (.margin,.output,.primary) (by decide) (by decide)).trans compatible.1
    · simpa [addPayout] using (frame (.margin,.position,.primary) (by decide) (by decide)).trans compatible.2.1
    · simpa [addPayout,Realization.Side.asset,compatible.2.2,Nat.cast_add] using paid

theorem payment_compatible (before : Funding.State) (prices : Payment.Prices)
    (input : Payment.Inputs) (post : World) (payment : Payment.Result)
    (success : PaymentSettlement.run prices input before.world.capabilities ownerContext Funding.payIds
      before.world.state=.ok (post,payment)) :
    PaymentSettlement.Compatible ⟨0,payment.outputLeft,payment.collateralLeft,payment.secondaryLeft⟩ post.state := by
  obtain ⟨executed,rfl⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp success
  exact PaymentSettlement.actual_buckets _ _ _ _ _ _ _ executed

theorem funding_compatible (before after : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (receipt : Funding.Receipt)
    (success : Funding.run before cfg.latest domain cfg.prices buckets cfg.holdingConfigured ownerContext
      Funding.payIds Funding.holdingIds=.ok (after,receipt)) :
    PaymentSettlement.Compatible ⟨0,receipt.payment.outputLeft,receipt.payment.collateralLeft,
      receipt.payment.secondaryLeft⟩ after.world.state := by
  obtain ⟨paid,executed,held,position,observed⟩ := (Funding.run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mp success
  have bucketsAfter := PaymentSettlement.actual_buckets _ _ _ _ _ _ _ executed
  have holding := (Funding.settleHolding_effects _ _ _ _ _ _ held).2
  rw [observed]
  refine ⟨?_,?_,?_⟩
  · simpa [Funding.receipt,bucketsAfter.1] using holding (.margin,.output,.primary)
  · simpa [Funding.receipt,bucketsAfter.2.1] using holding (.margin,.position,.primary)
  · simpa [Funding.receipt,bucketsAfter.2.2] using holding (.margin,.output,.secondary)

theorem provisioned_exact (cfg : Config) : provisioned cfg=.ok (fixtureStore cfg.side) := by
  cases cfg.side <;> rfl
end DefiKernel.Margin.Close
''';p.write_text(s)
