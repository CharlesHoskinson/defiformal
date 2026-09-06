import DefiKernel.ContractExamples

/-! Kernel-checked finite contract execution and refusal examples, not protocol coverage. -/
namespace DefiKernel.ContractAcceptance
open Examples Contracts ContractExamples

theorem transfer_post :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 3)) initial) allCells = .ok [7, 4, 10, 2, 3, 0,
      0, 0, 20, 0, 0, 0, 100, 0, 0, 0] := by decide +kernel

theorem deposit_post :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .ok [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem withdraw_post :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 2)) policy ()
      (withdraw (Quantity.ofNat 2)) initial) allCells = .ok [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem borrow_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (borrow (Quantity.ofNat 3)) initial) allCells = .ok [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0,
      97, 0, 0, 0] := by decide +kernel

theorem vault_drain_base_accepted :
    check policy () policyVaultDrain initial = none := by decide +kernel

theorem vault_drain_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 10)) policy ()
      (policyVaultDrain) initial) allCells = .error .contract := by decide +kernel

theorem unbacked_issue_base_accepted :
    check policy () policyUnbackedIssue initial = none := by decide +kernel

theorem unbacked_issue_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 200)) policy ()
      (policyUnbackedIssue) initial) allCells = .error .contract := by decide +kernel

theorem debt_erasure_base_accepted :
    check policy () policyDebtBurn initial = none := by decide +kernel

theorem debt_erasure_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (⟨policyDebtBurn.actor, policyDebtBurn.effect, policyDebtBurn.supplyChange,
        policyDebtBurn.writes, fun _ _ ↦ true⟩) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_recipient_base_accepted :
    check policy () (transfer .alice .alice .pool (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_recipient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .pool (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_source_base_accepted :
    check policy () (transfer .alice .vault .bob (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_source_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .vault .bob (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem unrelated_cell_base_accepted :
    check policy () (unrelatedEffect) initial = none := by decide +kernel

theorem unrelated_cell_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (unrelatedEffect) initial) allCells = .error .contract := by decide +kernel

theorem wrong_amount_base_accepted :
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 4)) initial = none := by
  decide +kernel

theorem wrong_amount_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 4)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_actor_base_accepted :
    check policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial = none := by decide +kernel

theorem wrong_actor_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 0)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (wrongSupply) initial) allCells = .error .contract := by decide +kernel

theorem forged_stale_base_accepted :
    check policy (stale) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_stale_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (stale)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_isolated_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel

theorem forged_isolated_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .error .contract := by decide +kernel

theorem forged_future_base_accepted :
    check policy (future) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_future_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (future)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_wrong_feed_base_accepted :
    check policy ({ fresh with feed := 8 }) (forgedBorrow (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem forged_wrong_feed_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy ({ fresh with
      feed := 8 })
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_excess_credit_base_accepted :
    check policy (fresh) (forgedBorrow (Quantity.ofNat 9)) initial = none := by decide +kernel

theorem forged_excess_credit_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 9)) policy (fresh)
      (forgedBorrow (Quantity.ofNat 9)) initial) allCells = .error .contract := by decide +kernel

theorem forged_fresh_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (forgedBorrow (Quantity.ofNat 3)) initial) [(.alice, .usd), (.pool, .usd), (.alice, .debt),
      (.alice, .collateral)] = .ok [13, 97, 5, 10] := by decide +kernel

theorem zero_borrow_positive_price_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .ok (allCells.map zeroDebt.balance) :=
      by decide +kernel

theorem base_insufficient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 11)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 11)) initial) allCells = .error (.base
      .insufficientFunds) := by decide +kernel

theorem base_unauthorized_refused :
    Contracts.observe (run (transferContract .bob .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells = .error (.base
      .unauthorizedDebit) := by decide +kernel

theorem base_footprint_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 1)) policy ()
      (wrongFootprint) initial) allCells = .error (.base .footprint) := by decide +kernel

theorem base_guard_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      ({ transfer .alice .alice .bob (Quantity.ofNat 3) with guard := fun _ _ ↦ false }) initial)
      allCells = .error (.base .guard) := by decide +kernel

theorem base_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) { policy with supply
      := fun _ _ ↦ false } ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .error (.base .unauthorizedSupply) := by
  decide +kernel

theorem always_base_accounting_refused :
    Contracts.observe (run (always Unit) policy ()
      (unbalanced) initial) allCells = .error (.base .accounting) := by decide +kernel

theorem withdraw_liquidity_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 11)) policy ()
      (withdraw (Quantity.ofNat 11)) richShares) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

theorem withdraw_shares_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 5)) policy ()
      (withdraw (Quantity.ofNat 5)) initial) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

end DefiKernel.ContractAcceptance
