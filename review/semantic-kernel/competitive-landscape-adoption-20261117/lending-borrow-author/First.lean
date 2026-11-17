import DefiKernel.Lending.Borrow
open DefiKernel DefiKernel.Typed DefiKernel.Lending
private def initial (pool free locked debt : Nat) : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => pool
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => free
    | (.lending,.aliceLocked,.collateral) => locked
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def checks : List (String × Bool) := match Borrow.provisioned .alice with
  | .error _ => [("provisioned",false)]
  | .ok store => [
    ("actual_borrow_locked_custody",match Borrow.run .alice store (borrowerContext .alice) Borrow.ids 3
      (Oracle.feed 2 98) 100 (initial 10 5 10 2) with
      | .error _ => false
      | .ok post => decide (post.state.balance (.lending,.alice,.cash)=6 ∧
          post.state.balance (.lending,.pool,.cash)=7 ∧ post.state.balance (.lending,.alice,.debt)=5 ∧
          post.state.balance (.lending,.alice,.collateral)=5 ∧
          post.state.balance (.lending,.aliceLocked,.collateral)=10)),
    ("free_collateral_does_not_back_debt",match Borrow.run .alice store (borrowerContext .alice) Borrow.ids 1
      (Oracle.feed 2 98) 100 (initial 10 100 0 2) with
      | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard)),
    ("missing_oracle_eager_even_negative_amount",match Borrow.run .alice store (borrowerContext .alice) Borrow.ids (-1)
      (fun _ => none) 100 (initial 10 5 10 2) with
      | .ok _ => false | .error reason => decide (reason=Typed.Refusal.evaluation EvalFailure.missingObservation))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first borrow controls")
  for (name,passed) in checks do IO.println s!"BORROW_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: first borrow regression")
