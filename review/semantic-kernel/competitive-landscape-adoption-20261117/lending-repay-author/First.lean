import DefiKernel.Lending.Repay
open DefiKernel DefiKernel.Typed DefiKernel.Lending
private def initial (wallet debt : Nat) : Ledger where
  balance
    | (.lending,.alice,.cash) => wallet
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => 5
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.debt) => 7
    | (.lending,.bobLocked,.collateral) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩;cases d;cases p <;> cases a <;> simp
private def checks : List (String × Bool) := match Repay.provisioned .alice with
  | .error _ => [("real_provisioning",false)]
  | .ok store => [
    ("cash_and_debt_together_on_unhealthy_position", match Repay.run .alice store
        ⟨.alice,.lending⟩ Repay.ids 1 (initial 3 2) with
      | .error _ => false
      | .ok post => decide (post.state.balance (.lending,.alice,.cash)=2 ∧
          post.state.balance (.lending,.pool,.cash)=11 ∧
          post.state.balance (.lending,.alice,.debt)=1 ∧
          post.state.balance (.lending,.alice,.collateral)=5 ∧
          post.state.balance (.lending,.aliceLocked,.collateral)=0 ∧
          post.state.balance (.lending,.bob,.debt)=7 ∧ post.capabilities=store)),
    ("over_repay_guard", match Repay.run .alice store ⟨.alice,.lending⟩ Repay.ids 3 (initial 10 2) with
      | .ok _ => false | .error reason => decide (reason = Typed.Refusal.guard)),
    ("cash_funding_refusal", match Repay.run .alice store ⟨.alice,.lending⟩ Repay.ids 1 (initial 0 2) with
      | .ok _ => false | .error reason => decide (reason = Typed.Refusal.insufficientFunds)),
    ("borrower_binding_even_with_overgranted_rights", let overgranted : Store :=
      ⟨store.entries.map (fun cap => {cap with holder:=.bob})⟩;
      match Repay.run .alice overgranted ⟨.bob,.lending⟩ Repay.ids 1 (initial 3 2) with
      | .ok _ => false | .error reason => decide (reason = Typed.Refusal.actorMismatch))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty lending first controls")
  for (name,passed) in checks do IO.println s!"LENDING_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: lending first regression")
