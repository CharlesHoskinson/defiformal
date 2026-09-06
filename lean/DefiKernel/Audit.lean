import DefiKernel.Acceptance

/-! Executable finite checks and axiom disclosure for this exact pilot. -/
namespace DefiKernel.Audit
open Examples

private def unitCase (t : Transition Unit) (expected : Option Refusal) : Bool :=
  decide (check policy () t initial = expected)

private def oracleCase (oracle : Oracle) (q : ℕ) (expected : Option Refusal) : Bool :=
  decide (check policy oracle (borrow (Quantity.ofNat q)) initial = expected)

/-- Finite regression cases; these do not measure protocol coverage or exhaustive behavior. -/
def runtimeChecks : List (String × Bool) := [
  ("transfer accepted", unitCase (transfer .alice .alice .bob (Quantity.ofNat 3)) none),
  ("unauthorized debit", unitCase (transfer .bob .alice .bob (Quantity.ofNat 3))
    (some .unauthorizedDebit)),
  ("insufficient funds", unitCase (transfer .alice .alice .bob (Quantity.ofNat 11))
    (some .insufficientFunds)),
  ("deposit accepted", unitCase (deposit (Quantity.ofNat 4)) none),
  ("withdraw accepted", unitCase (withdraw (Quantity.ofNat 2)) none),
  ("insufficient shares", unitCase (withdraw (Quantity.ofNat 5)) (some .insufficientFunds)),
  ("insufficient vault liquidity", decide (check policy () (withdraw (Quantity.ofNat 11))
    richShares = some .insufficientFunds)),
  ("borrow accepted", oracleCase fresh 3 none),
  ("stale oracle", oracleCase stale 3 (some .guard)),
  ("zero price", oracleCase zeroPrice 3 (some .guard)),
  ("future oracle", oracleCase future 3 (some .guard)),
  ("wrong feed", oracleCase { fresh with feed := 8 } 3 (some .guard)),
  ("excess credit", oracleCase fresh 9 (some .guard)),
  ("unbalanced effects", unitCase unbalanced (some .accounting)),
  ("wrong asset", unitCase wrongAsset (some .accounting)),
  ("wrong footprint", unitCase wrongFootprint (some .footprint)),
  ("unauthorized supply", unitCase unauthorizedIssue (some .unauthorizedSupply)),
  ("transfer post-state", decide (observe
    (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
    [(.alice, .usd), (.bob, .usd)] = .ok [7, 3])),
  ("deposit post-state", decide (observe (execute policy () (deposit (Quantity.ofNat 4)) initial)
    [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [6, 24, 6])),
  ("withdraw post-state", decide (observe (execute policy () (withdraw (Quantity.ofNat 2)) initial)
    [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [14, 16, 2])),
  ("borrow post-state", decide (observe (execute policy fresh (borrow (Quantity.ofNat 3)) initial)
    [(.alice, .usd), (.pool, .usd), (.alice, .debt), (.alice, .collateral)] = .ok [13, 97, 5, 10])),
  ("vault round trip", decide (observe (do
    let s ← execute policy () (deposit (Quantity.ofNat 4)) initial
    execute policy () (withdraw (Quantity.ofNat 2)) s) allCells =
    .ok (allCells.map initial.balance))),
  ("repeated borrow refused", decide (observe (do
    let s₁ ← execute policy fresh (borrow (Quantity.ofNat 3)) initial
    let s₂ ← execute policy fresh (borrow (Quantity.ofNat 3)) s₁
    execute policy fresh (borrow (Quantity.ofNat 3)) s₂) [(.alice, .debt)] = .error .guard)),
  ("refused execution", decide (observe
    (execute policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells =
    .error .unauthorizedDebit)),
  ("self-transfer net no-op", decide (observe
    (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial) allCells =
    .ok (allCells.map initial.balance)))]

#eval show IO Unit from do
  if runtimeChecks.isEmpty then throw (IO.userError "No runtime checks were collected")
  for (name, passed) in runtimeChecks do
    IO.println s!"{name}: {passed}"
    if !passed then throw (IO.userError s!"Runtime check failed: {name}")
  IO.println s!"Runtime checks passed: {runtimeChecks.length}/{runtimeChecks.length}"

end DefiKernel.Audit

#print axioms DefiKernel.check_eq_none_iff
#print axioms DefiKernel.applyEffect_accounting
#print axioms DefiKernel.applyEffect_locality
#print axioms DefiKernel.applyEffect_frame
#print axioms DefiKernel.execute_ok_iff
#print axioms DefiKernel.execute_authority
#print axioms DefiKernel.execute_accounting
#print axioms DefiKernel.execute_locality
#print axioms DefiKernel.Examples.transfer_accounted
#print axioms DefiKernel.Examples.deposit_accounted
#print axioms DefiKernel.Examples.withdraw_accounted
#print axioms DefiKernel.Examples.borrow_accounted
#print axioms DefiKernel.Examples.allCells_complete
#print axioms DefiKernel.Examples.borrow_declared_collateral_bound
#print axioms DefiKernel.transfer_accept
#print axioms DefiKernel.transfer_unauthorized
#print axioms DefiKernel.transfer_insufficient
#print axioms DefiKernel.deposit_accept
#print axioms DefiKernel.withdraw_accept
#print axioms DefiKernel.borrow_accept
#print axioms DefiKernel.stale_oracle_refused
#print axioms DefiKernel.zero_price_refused
#print axioms DefiKernel.future_oracle_refused
#print axioms DefiKernel.excess_credit_refused
#print axioms DefiKernel.unbalanced_refused
#print axioms DefiKernel.wrong_asset_refused
#print axioms DefiKernel.wrong_footprint_refused
#print axioms DefiKernel.unauthorized_issue_refused
#print axioms DefiKernel.wrong_feed_refused
#print axioms DefiKernel.insufficient_shares_refused
#print axioms DefiKernel.insufficient_vault_liquidity_refused
#print axioms DefiKernel.transfer_post
#print axioms DefiKernel.deposit_post
#print axioms DefiKernel.withdraw_post
#print axioms DefiKernel.borrow_post
#print axioms DefiKernel.vault_round_trip
#print axioms DefiKernel.repeated_borrow_refused
#print axioms DefiKernel.unauthorized_execute_refused
#print axioms DefiKernel.self_transfer_noop
#print axioms DefiKernel.wrong_asset_scalar_cancels
#print axioms DefiKernel.wrong_asset_not_accounted
#print axioms DefiKernel.unbalanced_not_accounted
#print axioms DefiKernel.missing_footprint_changes_balance
