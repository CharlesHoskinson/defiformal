import DefiKernel.Lending.Repay

namespace DefiKernel.Lending.RepayAudit
open DefiKernel.Typed DefiKernel.Lending
private def initial (cash debt : Nat) : Ledger where
  balance
    | (.lending,.alice,.cash) => cash
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => 5
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.debt) => 7
    | (.lending,.bobLocked,.collateral) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def resultMatches (borrower : Borrower) (store : Store)
    (actual : Except Typed.Refusal World) (cash poolCash debt : ℚ) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.cash)=cash ∧
      post.state.balance (.lending,.pool,.cash)=poolCash ∧
      post.state.balance (.lending,borrower.party,.debt)=debt ∧ post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def noCashDebit : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 1
    ⟨⟨.alice,.lending,repayId,.debit (.lending,.alice,.cash)⟩,false⟩⟩
private def noDebtDebit : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 2
    ⟨⟨.alice,.lending,repayId,.debit (.lending,.alice,.debt)⟩,false⟩⟩
private def noDebtSupply : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 3
    ⟨⟨.alice,.lending,repayId,.changeSupply .lending .debt⟩,false⟩⟩
private def invokeOnly : Store := ⟨(Repay.fixtureStore .alice).entries.take 1⟩
private def overgrantedBob : Store :=
  ⟨(Repay.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def run (quantity : ℚ) (pre : Ledger := initial 3 2)
    (store : Store := Repay.fixtureStore .alice) : Except Typed.Refusal World :=
  Repay.run .alice store (borrowerContext .alice) Repay.ids quantity pre
private def checks : List (String × Bool) := [
  ("real_provisioning_alice", decide (Repay.provisioned .alice = .ok (Repay.fixtureStore .alice))),
  ("real_provisioning_bob", decide (Repay.provisioned .bob = .ok (Repay.fixtureStore .bob))),
  ("cash_and_debt_move_together_unhealthy", resultMatches .alice (Repay.fixtureStore .alice) (run 1) 2 11 1),
  ("fractional_repayment", resultMatches .alice (Repay.fixtureStore .alice) (run (1/2)) (5/2) (21/2) (3/2)),
  ("exact_full_debt_repayment", resultMatches .alice (Repay.fixtureStore .alice) (run 2) 1 12 0),
  ("bob_position_bound", resultMatches .bob (Repay.fixtureStore .bob)
    (Repay.run .bob (Repay.fixtureStore .bob) (borrowerContext .bob) Repay.ids 2 (initial 3 2)) 2 12 5),
  ("all_collateral_and_other_debt_unchanged", match run 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.collateral)=5 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=0 ∧
        post.state.balance (.lending,.bobLocked,.collateral)=20 ∧
        post.state.balance (.lending,.bob,.debt)=7)),
  ("zero_repay_invoke_only", resultMatches .alice invokeOnly (run 0 (initial 3 2) invokeOnly) 3 10 2),
  ("over_repayment_guard", refusalMatches (run 3 (initial 10 2)) .guard),
  ("negative_repayment_guard", refusalMatches (run (-1)) .guard),
  ("cash_insufficient_funds", refusalMatches (run 1 (initial 0 2)) .insufficientFunds),
  ("invoke_permission", refusalMatches (run 1 (initial 3 2) ⟨[]⟩) .unauthorizedInvoke),
  ("cash_debit_permission", refusalMatches (run 1 (initial 3 2) noCashDebit) .unauthorizedDebit),
  ("debt_debit_permission", refusalMatches (run 1 (initial 3 2) noDebtDebit) .unauthorizedDebit),
  ("debt_supply_permission", refusalMatches (run 1 (initial 3 2) noDebtSupply) .unauthorizedSupply),
  ("owner_binding_before_overgranted_rights", refusalMatches
    (Repay.run .alice overgrantedBob (borrowerContext .bob) Repay.ids 1 (initial 3 2)) .actorMismatch),
  ("cash_conservation_debt_supply_reconciliation", match run 1 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=25 ∧ total post.state .lending .debt=8))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty repayment controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate repayment controls")
  match run 1 with
  | .error reason => IO.println s!"REPAY_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"REPAY_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)}"
  match Repay.run .alice overgrantedBob (borrowerContext .bob) Repay.ids 1 (initial 3 2) with
  | .error reason => IO.println s!"REPAY_BINDING_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"REPAY_BINDING_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)}"
  for (name,passed) in checks do IO.println s!"REPAY_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual repayment comparison")
  IO.println s!"REPAY_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.RepayAudit
