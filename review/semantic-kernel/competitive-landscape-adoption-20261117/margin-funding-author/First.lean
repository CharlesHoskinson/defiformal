import DefiKernel.Margin.Funding
open DefiKernel DefiKernel.Typed DefiKernel.Margin
private def ledger (collateral secondary : Nat) : Ledger where
  balance
    | (.margin,.position,.primary) => collateral
    | (.margin,.output,.secondary) => secondary
    | (.margin,.owner,.claimPrimary) => 7
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | (.margin,.pool,.primary) => 100
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def position : Funding.Position := ⟨Funding.precision+1,10,-1,⟨0,0,0⟩⟩
private def latest : Funding.Factors := ⟨1,2,3⟩
private theorem domain : Funding.Admissible position latest := by decide
private def prices : Payment.Prices := ⟨3,2,by decide,by decide⟩
private def before (collateral secondary : Nat) : Funding.State :=
  ⟨⟨ledger collateral secondary,Funding.fixtureStore⟩,position⟩
private def run (collateral secondary : Nat) (holding : Bool) := Funding.run
  (before collateral secondary) latest domain prices ⟨0,collateral,secondary⟩ holding ownerContext
  Funding.payIds Funding.holdingIds
private def checks : List (String × Bool) := [
  ("real_joint_provisioning",decide (Funding.provisioned position latest domain prices ⟨0,3,0⟩=
    .ok Funding.fixtureStore)),
  ("fee_paid_pending_claims_and_snapshots_preserved",match run 3 0 false with
    | .error _ => false
    | .ok (after,r) => decide (r.funding.feePrimary=2 ∧ r.funding.pendingClaimPrimary=2 ∧
        r.funding.pendingClaimSecondary=3 ∧ r.funding.latest=latest ∧
        after.position=position ∧ after.world.state.balance (.margin,.position,.primary)=1 ∧
        after.world.state.balance (.margin,.costRecipient,.primary)=2 ∧
        after.world.state.balance (.margin,.owner,.claimPrimary)=7 ∧
        after.world.state.balance (.margin,.owner,.claimSecondary)=11)),
  ("positive_pnl_is_not_automatic_spendable_cash",match run 0 0 false with
    | .error _ => false
    | .ok (after,r) => decide (after.position.pnlUsd=10 ∧ r.payment.sourceRemainingCostUsd=6 ∧
        r.payment.economicShortfallUsd=6 ∧ after.world.state.balance (.margin,.costRecipient,.primary)=0)),
  ("secondary_payment_records_separate_holding_claim",match run 0 3 true with
    | .error _ => false
    | .ok (after,r) => decide (r.payment.paidSecondary=3 ∧ r.payment.sourceRemainingCostUsd=0 ∧
        r.holdingCollateralClaimSecondary=3 ∧ r.insufficientPrimaryFundingPayment=true ∧
        after.world.state.balance (.margin,.costRecipient,.secondary)=3 ∧
        after.world.state.balance (.margin,.holding,.claimSecondary)=8 ∧
        after.world.state.balance (.margin,.pool,.primary)=100 ∧
        after.world.state.balance (.margin,.owner,.claimSecondary)=11)),
  ("secondary_payment_requires_holding_configuration",match run 0 3 false with
    | .ok _ => false | .error reason => decide (reason=Funding.Refusal.emptyHoldingAddress))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first funding controls")
  for (name,passed) in checks do IO.println s!"FUNDING_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first funding comparison")
