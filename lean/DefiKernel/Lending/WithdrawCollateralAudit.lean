import DefiKernel.Lending.WithdrawCollateral

namespace DefiKernel.Lending.WithdrawCollateralAudit
open DefiKernel.Typed
private def initial (free : Nat := 5) (locked : Nat := 10) (debt : Nat := 2) : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.collateral) => free
    | (.lending,.aliceLocked,.collateral) => locked
    | (.lending,.alice,.debt) => debt
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.collateral) => 7
    | (.lending,.bobLocked,.collateral) => 20
    | (.lending,.bob,.debt) => 7
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def run (quantity : ℚ) (pre : Ledger := initial)
    (env : Environment Asset Domain := Oracle.feed 2 98) (now : Nat := 100)
    (store : Store := WithdrawCollateral.fixtureStore .alice) : Except Typed.Refusal World :=
  WithdrawCollateral.run .alice store (borrowerContext .alice) WithdrawCollateral.ids quantity env now pre
private def resultMatches (borrower : Borrower) (actual : Except Typed.Refusal World)
    (free locked : ℚ) (store : Store := WithdrawCollateral.fixtureStore .alice) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.collateral)=free ∧
      post.state.balance (.lending,borrower.custody,.collateral)=locked ∧ post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def invokeOnly : Store := ⟨(WithdrawCollateral.fixtureStore .alice).entries.take 1⟩
private def noDebit : Store := ⟨(WithdrawCollateral.fixtureStore .alice).entries.set 1
  ⟨⟨.alice,.lending,withdrawCollateralId,.debit (.lending,.aliceLocked,.collateral)⟩,false⟩⟩
private def overgrantedBob : Store :=
  ⟨(WithdrawCollateral.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def wrongUnit : Environment Asset Domain := fun key =>
  if key=Oracle.key then some ⟨⟨.scalar,2⟩,98⟩ else none
private def wrongFeed : Environment Asset Domain := fun key =>
  if key=⟨.lending,⟨8⟩⟩ then some ⟨⟨.price .collateral .cash,2⟩,98⟩ else none
private def checks : List (String × Bool) := [
  ("real_provisioning_alice",decide (WithdrawCollateral.provisioned .alice=
    .ok (WithdrawCollateral.fixtureStore .alice))),
  ("real_provisioning_bob",decide (WithdrawCollateral.provisioned .bob=
    .ok (WithdrawCollateral.fixtureStore .bob))),
  ("actual_locked_to_own_free",resultMatches .alice (run 3) 8 7),
  ("fractional_withdrawal",resultMatches .alice (run (1/2)) (11/2) (19/2)),
  ("bob_owned_position",resultMatches .bob
    (WithdrawCollateral.run .bob (WithdrawCollateral.fixtureStore .bob) (borrowerContext .bob)
      WithdrawCollateral.ids 2 (Oracle.feed 2 98) 100 initial) 9 18 (WithdrawCollateral.fixtureStore .bob)),
  ("cash_debt_other_owner_frame",match run 3 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.cash)=3 ∧
        post.state.balance (.lending,.pool,.cash)=10 ∧ post.state.balance (.lending,.bob,.cash)=4 ∧
        post.state.balance (.lending,.alice,.debt)=2 ∧ post.state.balance (.lending,.bob,.debt)=7 ∧
        post.state.balance (.lending,.bob,.collateral)=7 ∧ post.state.balance (.lending,.bobLocked,.collateral)=20)),
  ("remaining_collateral_health_boundary",resultMatches .alice (run 8) 13 2),
  ("remaining_collateral_not_prestate_health",refusalMatches (run 9) .guard),
  ("free_collateral_does_not_back_debt",refusalMatches (run 0 (initial 1000 1 2)) .guard),
  ("over_locked_refuses_guard",refusalMatches (run 11) .guard),
  ("zero_quantity_still_rejects_unhealthy",refusalMatches (run 0 (initial 5 2 100)) .guard),
  ("zero_quantity_healthy_invoke_only",resultMatches .alice
    (run 0 initial (Oracle.feed 2 98) 100 invokeOnly) 5 10 invokeOnly),
  ("zero_exposure_still_requires_positive_price",refusalMatches
    (run 0 (initial 0 0 0) (Oracle.feed 0 98)) .guard),
  ("negative_price",refusalMatches (run 0 (initial 0 0 0) (Oracle.feed (-1) 98)) .guard),
  ("negative_quantity",refusalMatches (run (-1)) .guard),
  ("missing_oracle",refusalMatches (run 1 initial (fun _ => none)) (.evaluation .missingObservation)),
  ("missing_oracle_eager_negative_quantity",refusalMatches
    (run (-1) initial (fun _ => none)) (.evaluation .missingObservation)),
  ("wrong_oracle_unit",refusalMatches (run 1 initial wrongUnit) (.evaluation .observationUnit)),
  ("wrong_feed_key",refusalMatches (run 1 initial wrongFeed) (.evaluation .missingObservation)),
  ("future_timestamp",refusalMatches (run 1 initial (Oracle.feed 2 101)) .guard),
  ("stale_timestamp",refusalMatches (run 1 initial (Oracle.feed 2 94)) .guard),
  ("oldest_fresh_boundary",resultMatches .alice (run 1 initial (Oracle.feed 2 95)) 6 9),
  ("invoke_before_oracle_evaluation",refusalMatches (run 1 initial (fun _ => none) 100 ⟨[]⟩) .unauthorizedInvoke),
  ("custody_debit_authority",refusalMatches (run 1 initial (Oracle.feed 2 98) 100 noDebit) .unauthorizedDebit),
  ("guard_before_debit_authority",refusalMatches (run 9 initial (Oracle.feed 2 98) 100 noDebit) .guard),
  ("owner_binding_before_oracle_evaluation",refusalMatches
    (WithdrawCollateral.run .alice overgrantedBob (borrowerContext .bob) WithdrawCollateral.ids
      1 (fun _ => none) 100 initial) .actorMismatch),
  ("all_asset_totals_conserved",match run 3 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=42 ∧ total post.state .lending .debt=9))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty withdraw controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate withdraw controls")
  match run 3 with
  | .error reason => IO.println s!"WITHDRAW_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"WITHDRAW_OBSERVATION {post.state.balance (.lending,.alice,.collateral)} {post.state.balance (.lending,.aliceLocked,.collateral)} {post.state.balance (.lending,.alice,.debt)}"
  match run 9 with
  | .error reason => IO.println s!"WITHDRAW_HEALTH_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"WITHDRAW_HEALTH_OBSERVATION {post.state.balance (.lending,.alice,.collateral)} {post.state.balance (.lending,.aliceLocked,.collateral)} {post.state.balance (.lending,.alice,.debt)}"
  for (name,passed) in checks do IO.println s!"WITHDRAW_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual withdraw comparison")
  IO.println s!"WITHDRAW_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.WithdrawCollateralAudit
