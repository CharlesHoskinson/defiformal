import DefiKernel.Examples

/-! Concrete behavior contracts for the bounded reference examples. -/
namespace DefiKernel
open Examples

theorem transfer_accept : check policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial =
    none := by decide +kernel

theorem transfer_unauthorized :
    check policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial =
      some .unauthorizedDebit := by decide +kernel

theorem transfer_insufficient :
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 11)) initial =
      some .insufficientFunds := by decide +kernel

theorem deposit_accept :
    check policy () (deposit (Quantity.ofNat 4)) initial = none := by decide +kernel

theorem withdraw_accept :
    check policy () (withdraw (Quantity.ofNat 2)) initial = none := by decide +kernel

theorem borrow_accept :
    check policy fresh (borrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem stale_oracle_refused :
    check policy stale (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem zero_price_refused :
    check policy zeroPrice (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem future_oracle_refused :
    check policy future (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem excess_credit_refused :
    check policy fresh (borrow (Quantity.ofNat 9)) initial = some .guard := by decide +kernel

theorem unbalanced_refused :
    check policy () unbalanced initial = some .accounting := by decide +kernel

theorem wrong_asset_refused :
    check policy () wrongAsset initial = some .accounting := by decide +kernel

theorem wrong_footprint_refused :
    check policy () wrongFootprint initial = some .footprint := by decide +kernel

theorem unauthorized_issue_refused :
    check policy () unauthorizedIssue initial = some .unauthorizedSupply := by decide +kernel

theorem wrong_feed_refused :
    check policy { fresh with feed := 8 } (borrow (Quantity.ofNat 3)) initial =
      some .guard := by decide +kernel

theorem insufficient_shares_refused :
    check policy () (withdraw (Quantity.ofNat 5)) initial =
      some .insufficientFunds := by decide +kernel

/-- Twenty USD of vault liquidity cannot redeem all twenty fixture shares. -/
theorem insufficient_vault_liquidity_refused :
    check policy () (withdraw (Quantity.ofNat 11)) richShares =
      some .insufficientFunds := by decide +kernel

theorem transfer_post :
    observe (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
      [(.alice, .usd), (.bob, .usd)] = .ok [7, 3] := by decide +kernel

theorem deposit_post :
    observe (execute policy () (deposit (Quantity.ofNat 4)) initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [6, 24, 6] := by decide +kernel

theorem withdraw_post :
    observe (execute policy () (withdraw (Quantity.ofNat 2)) initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [14, 16, 2] := by decide +kernel

theorem borrow_post :
    observe (execute policy fresh (borrow (Quantity.ofNat 3)) initial)
      [(.alice, .usd), (.pool, .usd), (.alice, .debt), (.alice, .collateral)] =
      .ok [13, 97, 5, 10] := by decide +kernel

/-- Observable round trip across every cell, not just the deposited asset. -/
theorem vault_round_trip :
    observe (do
      let s ← execute policy () (deposit (Quantity.ofNat 4)) initial
      execute policy () (withdraw (Quantity.ofNat 2)) s) allCells =
      .ok (allCells.map initial.balance) := by decide +kernel

/-- Two borrows update debt; a third is refused using that updated debt. -/
theorem repeated_borrow_refused :
    observe (do
      let s₁ ← execute policy fresh (borrow (Quantity.ofNat 3)) initial
      let s₂ ← execute policy fresh (borrow (Quantity.ofNat 3)) s₁
      execute policy fresh (borrow (Quantity.ofNat 3)) s₂) [(.alice, .debt)] =
      .error .guard := by decide +kernel

theorem unauthorized_execute_refused :
    observe (execute policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial)
      allCells = .error .unauthorizedDebit := by decide +kernel

/-- A too-large self-transfer is still a no-op under the documented net-effect semantics. -/
theorem self_transfer_noop :
    observe (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial)
      allCells = .ok (allCells.map initial.balance) := by decide +kernel

/-- This defective effect defeats scalar accounting while violating asset accounting. -/
theorem wrong_asset_scalar_cancels :
    (∑ a, ∑ owner, wrongAsset.effect (owner, a)) = 0 := by decide +kernel

theorem wrong_asset_not_accounted : ¬ Accounted wrongAsset := by decide +kernel

theorem unbalanced_not_accounted : ¬ Accounted unbalanced := by decide +kernel

theorem missing_footprint_changes_balance :
    (.bob, .usd) ∉ wrongFootprint.writes ∧ wrongFootprint.effect (.bob, .usd) = 1 :=
  by decide +kernel

end DefiKernel
