import DefiKernel.Lending.DepositCollateral
open DefiKernel DefiKernel.Typed DefiKernel.Lending
private def initial : Ledger where
  balance
    | (.lending,.alice,.collateral) => 5
    | (.lending,.aliceLocked,.collateral) => 2
    | (.lending,.alice,.debt) => 100
    | (.lending,.alice,.cash) => 3
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> decide
private def run (q : ℚ) := DepositCollateral.run .alice
  (DepositCollateral.fixtureStore .alice) (borrowerContext .alice) DepositCollateral.ids q initial
private def checks : List (String × Bool) := [
  ("real_provisioning",decide (DepositCollateral.provisioned .alice =
    .ok (DepositCollateral.fixtureStore .alice))),
  ("actual_funded_unhealthy_deposit",match run 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.collateral)=4 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=3 ∧
        post.state.balance (.lending,.alice,.debt)=100 ∧
        post.state.balance (.lending,.alice,.cash)=3)),
  ("insufficient_free_collateral",match run 6 with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.insufficientFunds)),
  ("negative_quantity",match run (-1) with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty deposit controls")
  for (name,passed) in checks do IO.println s!"DEPOSIT_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first deposit comparison")
