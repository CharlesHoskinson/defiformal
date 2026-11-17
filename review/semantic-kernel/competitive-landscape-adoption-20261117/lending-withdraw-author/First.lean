import DefiKernel.Lending.WithdrawCollateral
open DefiKernel DefiKernel.Typed DefiKernel.Lending
private def initial : Ledger where
  balance
    | (.lending,.alice,.collateral) => 5
    | (.lending,.aliceLocked,.collateral) => 10
    | (.lending,.alice,.debt) => 2
    | (.lending,.alice,.cash) => 3
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> decide
private def run (q : ℚ) (env : Environment Asset Domain := Oracle.feed 2 98) :=
  WithdrawCollateral.run .alice (WithdrawCollateral.fixtureStore .alice)
    (borrowerContext .alice) WithdrawCollateral.ids q env 100 initial
private def checks : List (String × Bool) := [
  ("real_provisioning",decide (WithdrawCollateral.provisioned .alice =
    .ok (WithdrawCollateral.fixtureStore .alice))),
  ("actual_locked_to_free",match run 3 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.collateral)=8 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=7 ∧
        post.state.balance (.lending,.alice,.debt)=2 ∧ post.state.balance (.lending,.alice,.cash)=3)),
  ("remaining_health_refusal",match run 9 with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard)),
  ("over_locked_is_guard_refusal",match run 11 with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard)),
  ("missing_oracle_eager_negative",match run (-1) (fun _ => none) with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.evaluation .missingObservation))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first withdrawal controls")
  for (name,passed) in checks do IO.println s!"WITHDRAW_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first withdrawal comparison")
