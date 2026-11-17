from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Funding.lean');s=p.read_text()
pos=s.index('def run (before')
s=s[:pos]+'''def settleHolding (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) : Except Refusal World :=
  if 0 < quantity then
    if !configured then .error .emptyHoldingAddress else
      (holdingExecute quantity paid.capabilities ctx ids paid.state).mapError Refusal.typed
  else .ok paid
'''+s[pos:]
a=s.index('  let after ← if');b=s.index('  return (⟨after',a)
s=s[:a]+'''  let after ← settleHolding payment.paidSecondary holdingConfigured paid ctx holdingIds
'''+s[b:]
s=s.replace('end DefiKernel.Margin.Funding','')
s+='''
theorem settleHolding_ok_iff (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (post : World) :
    settleHolding quantity configured paid ctx ids=.ok post ↔
      if 0 < quantity then configured=true ∧
        holdingExecute quantity paid.capabilities ctx ids paid.state=.ok post else post=paid := by
  by_cases positive : 0 < quantity
  · cases configured <;> simp [settleHolding,positive,Except.mapError]
    cases executed : holdingExecute quantity paid.capabilities ctx ids paid.state <;>
      simp [executed,Except.mapError]
  · simp [settleHolding,positive,eq_comm]

def receipt (funding : Quote) (payment : Payment.Result) : Receipt :=
  ⟨funding,payment,payment.paidSecondary,
    decide (payment.paidPrimaryOutput+payment.paidCollateral<funding.feePrimary)⟩

theorem run_ok_iff (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt) :
    run before latest domain prices buckets configured ctx payIds holdingIds=.ok (after,observed) ↔
      ∃ paid,PaymentSettlement.execute prices
        (paymentInput prices (quote before.position latest domain) buckets)
        before.world.capabilities ctx payIds before.world.state=.ok paid ∧
      settleHolding (Payment.payCost prices
        (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary
        configured paid ctx holdingIds=.ok after.world ∧ after.position=before.position ∧
      observed=receipt (quote before.position latest domain)
        (Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)) := by
  cases executed : PaymentSettlement.execute prices
    (paymentInput prices (quote before.position latest domain) buckets)
    before.world.capabilities ctx payIds before.world.state with
  | error reason => simp [run,PaymentSettlement.run,executed,Except.mapError,
      bind,Except.bind,pure,Except.pure]
  | ok paid =>
    cases settled : settleHolding (Payment.payCost prices
      (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary
      configured paid ctx holdingIds with
    | error reason => simp [run,PaymentSettlement.run,executed,settled,Except.mapError,
        bind,Except.bind,pure,Except.pure]
    | ok post =>
      cases after
      simp [run,PaymentSettlement.run,executed,settled,Except.mapError,
        bind,Except.bind,pure,Except.pure,receipt,eq_comm,and_assoc,and_left_comm,and_comm]

theorem settleHolding_effects (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (post : World)
    (success : settleHolding quantity configured paid ctx ids=.ok post) :
    post.capabilities=paid.capabilities ∧ ∀ cell,
      post.state.balance cell=paid.state.balance cell+
        (if (.margin,.holding,.claimSecondary)=cell then (quantity:ℚ) else 0) := by
  have description := (settleHolding_ok_iff quantity configured paid ctx ids post).mp success
  by_cases positive : 0 < quantity
  · rw [if_pos positive] at description
    obtain ⟨_,_,_,caps,balances⟩ := (holding_ok_iff quantity paid.capabilities ctx ids paid.state post).mp
      description.2
    exact ⟨caps,by intro cell; simpa only [holding_effect] using balances cell⟩
  · rw [if_neg positive] at description
    subst post
    have zero : quantity=0 := by omega
    simp [zero]

theorem actual_effects (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.position=before.position ∧ after.world.capabilities=before.world.capabilities ∧
    observed=receipt (quote before.position latest domain)
      (Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)) ∧
    ∀ cell,after.world.state.balance cell=before.world.state.balance cell+
      (PaymentSettlement.evaluated prices (paymentInput prices observed.funding buckets) true).effect cell+
      (if (.margin,.holding,.claimSecondary)=cell then (observed.holdingCollateralClaimSecondary:ℚ) else 0) := by
  obtain ⟨paid,payment,holding,position,observation⟩ :=
    (run_ok_iff before latest domain prices buckets configured ctx payIds holdingIds after observed).mp success
  have compat := PaymentSettlement.success_compatible _ _ _ _ _ _ _ payment
  obtain ⟨_,_,_,caps,balances⟩ := (PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp payment
  have decision : decide (PaymentSettlement.Compatible
      (paymentInput prices (quote before.position latest domain) buckets) before.world.state)=true := by
    simpa using compat
  rw [decision] at balances
  have held := settleHolding_effects _ _ _ _ _ _ holding
  refine ⟨position,held.1.trans caps,observation,?_⟩
  intro cell
  rw [held.2 cell,balances cell,observation]
  rfl

theorem actual_owner_claims_and_holding (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.world.state.balance (.margin,.owner,.claimPrimary)=
      before.world.state.balance (.margin,.owner,.claimPrimary) ∧
    after.world.state.balance (.margin,.owner,.claimSecondary)=
      before.world.state.balance (.margin,.owner,.claimSecondary) ∧
    after.world.state.balance (.margin,.holding,.claimSecondary)=
      before.world.state.balance (.margin,.holding,.claimSecondary)+
        (observed.holdingCollateralClaimSecondary:ℚ) := by
  have effects := (actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.2
  constructor
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.owner,.claimPrimary)
  constructor
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.owner,.claimSecondary)
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.holding,.claimSecondary)
end DefiKernel.Margin.Funding
'''
p.write_text(s)
