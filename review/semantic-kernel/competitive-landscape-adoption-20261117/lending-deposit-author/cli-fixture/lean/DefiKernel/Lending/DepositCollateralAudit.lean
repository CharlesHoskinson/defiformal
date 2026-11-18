import DefiKernel.Lending.DepositCollateral

namespace DefiKernel.Lending.DepositCollateralAudit
open DefiKernel.Typed
private def initial (free : Nat := 5) (locked : Nat := 2) (debt : Nat := 100) : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.collateral) => free
    | (.lending,.aliceLocked,.collateral) => locked
    | (.lending,.alice,.debt) => debt
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.collateral) => 7
    | (.lending,.bobLocked,.collateral) => 20
    | (.lending,.bob,.debt) => 2
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def run (quantity : ℚ) (pre : Ledger := initial)
    (store : Store := DepositCollateral.fixtureStore .alice) : Except Typed.Refusal World :=
  DepositCollateral.run .alice store (borrowerContext .alice) DepositCollateral.ids quantity pre
private def resultMatches (borrower : Borrower) (actual : Except Typed.Refusal World)
    (free locked : ℚ) (store : Store := DepositCollateral.fixtureStore .alice) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.collateral)=free ∧
      post.state.balance (.lending,borrower.custody,.collateral)=locked ∧ post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def invokeOnly : Store := ⟨(DepositCollateral.fixtureStore .alice).entries.take 1⟩
private def noDebit : Store := ⟨(DepositCollateral.fixtureStore .alice).entries.set 1
  ⟨⟨.alice,.lending,depositCollateralId,.debit (.lending,.alice,.collateral)⟩,false⟩⟩
private def overgrantedBob : Store :=
  ⟨(DepositCollateral.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def bobDebitOnly : Store := ⟨[
  ⟨⟨.alice,.lending,depositCollateralId,.invoke⟩,true⟩,
  ⟨⟨.alice,.lending,depositCollateralId,.debit (.lending,.bob,.collateral)⟩,true⟩]⟩
private def checks : List (String × Bool) := [
  ("real_provisioning_alice",decide (DepositCollateral.provisioned .alice=
    .ok (DepositCollateral.fixtureStore .alice))),
  ("real_provisioning_bob",decide (DepositCollateral.provisioned .bob=
    .ok (DepositCollateral.fixtureStore .bob))),
  ("actual_free_to_own_custody",resultMatches .alice (run 1) 4 3),
  ("fractional_deposit",resultMatches .alice (run (1/2)) (9/2) (5/2)),
  ("deposit_entire_free_balance",resultMatches .alice (run 5) 0 7),
  ("bob_owned_custody",resultMatches .bob
    (DepositCollateral.run .bob (DepositCollateral.fixtureStore .bob) (borrowerContext .bob)
      DepositCollateral.ids 2 initial) 5 22 (DepositCollateral.fixtureStore .bob)),
  ("unhealthy_deposit_needs_no_oracle",resultMatches .alice (run 1 (initial 5 2 100)) 4 3),
  ("deposit_need_not_restore_health",match run 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.aliceLocked,.collateral)*2 <
        2*post.state.balance (.lending,.alice,.debt))),
  ("cash_debt_and_other_owner_frame",match run 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.cash)=3 ∧
        post.state.balance (.lending,.pool,.cash)=10 ∧ post.state.balance (.lending,.bob,.cash)=4 ∧
        post.state.balance (.lending,.alice,.debt)=100 ∧ post.state.balance (.lending,.bob,.debt)=2 ∧
        post.state.balance (.lending,.bob,.collateral)=7 ∧
        post.state.balance (.lending,.bobLocked,.collateral)=20 ∧
        post.state.balance (.lending,.pool,.collateral)=0)),
  ("zero_quantity_invoke_only",resultMatches .alice (run 0 initial invokeOnly) 5 2 invokeOnly),
  ("negative_quantity",refusalMatches (run (-1)) .guard),
  ("insufficient_free_collateral",refusalMatches (run 6) .insufficientFunds),
  ("locked_balance_does_not_fund_free_debit",refusalMatches (run 1 (initial 0 1000)) .insufficientFunds),
  ("invoke_before_guard",refusalMatches (run (-1) initial ⟨[]⟩) .unauthorizedInvoke),
  ("free_debit_authority",refusalMatches (run 1 initial noDebit) .unauthorizedDebit),
  ("other_borrower_debit_right_is_insufficient",refusalMatches (run 1 initial bobDebitOnly) .unauthorizedDebit),
  ("owner_binding_before_guard",refusalMatches
    (DepositCollateral.run .alice overgrantedBob (borrowerContext .bob) DepositCollateral.ids
      (-1) initial) .actorMismatch),
  ("all_asset_totals_conserved_no_supply",match run 1 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=34 ∧ total post.state .lending .debt=102))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty deposit controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate deposit controls")
  match run 1 with
  | .error reason => IO.println s!"DEPOSIT_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"DEPOSIT_OBSERVATION {post.state.balance (.lending,.alice,.collateral)} {post.state.balance (.lending,.aliceLocked,.collateral)} {post.state.balance (.lending,.pool,.collateral)} {post.state.balance (.lending,.alice,.debt)}"
  for (name,passed) in checks do IO.println s!"DEPOSIT_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual deposit comparison")
  IO.println s!"DEPOSIT_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.DepositCollateralAudit
