import DefiKernel.Lending.Accrue
open DefiKernel DefiKernel.Typed DefiKernel.Lending
private def initial : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.debt) => 2
    | (.lending,.alice,.collateral) => 5
    | (.lending,.aliceLocked,.collateral) => 2
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩;cases d;cases p <;> cases a <;> decide
private def first := Accrue.run .alice (Accrue.fixtureStore .alice) (borrowerContext .alice) Accrue.ids 1 1 initial
private def checks : List (String × Bool) := [
  ("actual_provisioning",decide (Accrue.provisioned .alice=.ok (Accrue.fixtureStore .alice))),
  ("successful_accrual_makes_healthy_position_unhealthy",match first with
    | .error _ => false
    | .ok post => decide (2*initial.balance (.lending,.alice,.debt) ≤
        initial.balance (.lending,.aliceLocked,.collateral)*2 ∧
        post.state.balance (.lending,.alice,.debt)=4 ∧
        post.state.balance (.lending,.alice,.cash)=3 ∧ post.state.balance (.lending,.pool,.cash)=10 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=2 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)*2 < 2*post.state.balance (.lending,.alice,.debt))),
  ("reapplying_same_interval_accrues_again",match first with
    | .error _ => false
    | .ok post => match Accrue.run .alice post.capabilities (borrowerContext .alice) Accrue.ids 1 1 post.state with
      | .error _ => false
      | .ok twice => decide (twice.state.balance (.lending,.alice,.debt)=8)),
  ("negative_rate_refuses",match Accrue.run .alice (Accrue.fixtureStore .alice)
    (borrowerContext .alice) Accrue.ids (-1) 1 initial with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first accrual controls")
  for (name,passed) in checks do IO.println s!"ACCRUE_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: first accrual regression")
