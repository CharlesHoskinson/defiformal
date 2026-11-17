from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Funding.lean');s=p.read_text().replace('end DefiKernel.Margin.Funding','')
s+='''
/-- Actual four-asset accounting: physical assets and owner claims conserve; only holding claims issue. -/
theorem actual_accounting (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) (asset : Asset) :
    total after.world.state .margin asset=total before.world.state .margin asset+
      if asset=.claimSecondary then (observed.holdingCollateralClaimSecondary:ℚ) else 0 := by
  have effects := (actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.2
  unfold total
  simp_rw [effects]
  rw [Finset.sum_add_distrib,Finset.sum_add_distrib]
  have zero : ∑ p : Party,(PaymentSettlement.evaluated prices
      (paymentInput prices observed.funding buckets) true).effect (.margin,p,asset)=0 := by
    cases asset <;> simp [PaymentSettlement.evaluated,Evaluated.effect,
      Finset.sum_add_distrib,PaymentSettlement.sum_if_party] <;> ring
  rw [zero,add_zero]
  cases asset <;> simp

theorem actual_recipient_gains (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.world.state.balance (.margin,.costRecipient,.primary)-
      before.world.state.balance (.margin,.costRecipient,.primary)=
      ((observed.payment.paidPrimaryOutput+observed.payment.paidCollateral:ℕ):ℚ) ∧
    after.world.state.balance (.margin,.costRecipient,.secondary)-
      before.world.state.balance (.margin,.costRecipient,.secondary)=
      (observed.payment.paidSecondary:ℚ) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have effects := info.2.2.2
  have quoteEq : observed.payment=Payment.payCost prices (paymentInput prices observed.funding buckets) := by
    rw [info.2.2.1]; rfl
  constructor
  · rw [effects,PaymentSettlement.recipient_primary_effect,quoteEq]
    simp; ring
  · rw [effects,PaymentSettlement.recipient_secondary_effect,quoteEq]
    simp; ring

/-- Source residual, exact shortfall and the primary-shortfall warning remain distinct returned facts. -/
theorem actual_reconciliation (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    (observed.funding.feePrimary:ℚ)*(prices.primary:ℚ)+(observed.payment.ceilDustUsd:ℚ)=
      (after.world.state.balance (.margin,.costRecipient,.primary)-
        before.world.state.balance (.margin,.costRecipient,.primary))*(prices.primary:ℚ)+
      (after.world.state.balance (.margin,.costRecipient,.secondary)-
        before.world.state.balance (.margin,.costRecipient,.secondary))*(prices.secondary:ℚ)+
      (observed.payment.sourceRemainingCostUsd:ℚ)+(observed.payment.floorDustUsd:ℚ) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have gains := actual_recipient_gains _ _ _ _ _ _ _ _ _ _ _ success
  rw [gains.1,gains.2,info.2.2.1]
  exact_mod_cast Payment.two_dust_reconciliation prices
    (paymentInput prices (quote before.position latest domain) buckets)

/-- Every compatible input constructs execution with genuine operation-scoped authorities.
The holding condition is required exactly when native secondary payment is positive. -/
theorem run_exists (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (payIds holdingIds : List CapabilityId)
    (compatible : PaymentSettlement.Compatible
      (paymentInput prices (quote before.position latest domain) buckets) before.world.state)
    (invoke : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId .invoke=true)
    (debitOutput : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.output,.primary))=true)
    (debitCollateral : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.position,.primary))=true)
    (debitSecondary : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.output,.secondary))=true)
    (holdingInvoke : hasAuthority before.world.capabilities holdingIds ownerContext holdingId .invoke=true)
    (holdingSupply : hasAuthority before.world.capabilities holdingIds ownerContext holdingId
      (.changeSupply .margin .claimSecondary)=true)
    (holdingConfig : 0 < (Payment.payCost prices
      (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary → configured=true) :
    ∃ after observed,run before latest domain prices buckets configured ownerContext payIds holdingIds=
      .ok (after,observed) := by
  let funding := quote before.position latest domain
  let input := paymentInput prices funding buckets
  let native := Payment.payCost prices input
  obtain ⟨paid,executed⟩ := PaymentSettlement.execute_exists prices input before.world.capabilities
    payIds before.world.state compatible invoke debitOutput debitCollateral debitSecondary
  have caps := ((PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp executed).2.2.2.1
  have settled : ∃ post,settleHolding native.paidSecondary configured paid ownerContext holdingIds=.ok post := by
    by_cases positive : 0 < native.paidSecondary
    · have config := holdingConfig positive
      have hi : hasAuthority paid.capabilities holdingIds ownerContext holdingId .invoke=true := by
        rw [caps]; exact holdingInvoke
      have hs : hasAuthority paid.capabilities holdingIds ownerContext holdingId
          (.changeSupply .margin .claimSecondary)=true := by rw [caps]; exact holdingSupply
      obtain ⟨post,success⟩ := holding_exists native.paidSecondary paid.capabilities holdingIds paid.state hi hs
      exact ⟨post,(settleHolding_ok_iff _ _ _ _ _ _).mpr (by rw [if_pos positive]; exact ⟨config,success⟩)⟩
    · exact ⟨paid,(settleHolding_ok_iff _ _ _ _ _ _).mpr (by rw [if_neg positive])⟩
  obtain ⟨post,success⟩ := settled
  exact ⟨⟨post,before.position⟩,receipt funding native,
    (run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mpr ⟨paid,executed,success,rfl,rfl⟩⟩

theorem provisioned_exact (position : Position) (latest : Factors) (domain : Admissible position latest)
    (prices : Payment.Prices) (buckets : Buckets) :
    provisioned position latest domain prices buckets=.ok fixtureStore := by rfl

theorem fixture_rights :
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId .invoke=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true ∧
    hasAuthority fixtureStore holdingIds ownerContext holdingId .invoke=true ∧
    hasAuthority fixtureStore holdingIds ownerContext holdingId (.changeSupply .margin .claimSecondary)=true := by decide
end DefiKernel.Margin.Funding
''';p.write_text(s)
