import DefiKernel.Margin.Funding
open DefiKernel DefiKernel.Typed DefiKernel.Margin
private def ledger (collateral secondary : Nat) : Ledger where
  balance
    | (.margin,.position,.primary) => collateral
    | (.margin,.output,.secondary) => secondary
    | (.margin,.owner,.claimPrimary) => 7
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def position : Funding.Position := ⟨Funding.precision+1,10,-1,⟨0,0,0⟩⟩
private def latest : Funding.Factors := ⟨1,2,3⟩
private theorem domain : Funding.Admissible position latest := by decide
private def prices : Payment.Prices := ⟨3,2,by decide,by decide⟩
#eval do
  for (name,c,s) in [("positive_funding_primary_helper_and_branch",3,0),
      ("positive_funding_secondary_helper_and_branch",0,3),
      ("partial_funding_secondary_helper_and_branch",0,1)] do
    match Funding.run ⟨⟨ledger c s,Funding.fixtureStore⟩,position⟩ latest domain prices ⟨0,c,s⟩ true
        ownerContext Funding.payIds Funding.holdingIds with
    | .error reason => throw (IO.userError s!"FAIL: native funding {repr reason}")
    | .ok (_,r) => IO.println s!"NATIVE_BRANCH_PAIR {name} {r.funding.feePrimary} {r.payment.paidPrimaryOutput+r.payment.paidCollateral} {r.payment.paidSecondary} {r.payment.sourceRemainingCostUsd} {if r.insufficientPrimaryFundingPayment then 1 else 0} {r.holdingCollateralClaimSecondary}"
