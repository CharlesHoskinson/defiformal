import DefiKernel.AMM.WordSettlement

namespace DefiKernel.AMM.WordSettlementAudit
open DefiKernel.Typed DefiKernel.Arithmetic DefiKernel.AMM.Settlement
private def word (n : Nat) (bound : n < 2^256 := by decide) : Word 256 := ⟨n,bound⟩
private def maxWord : Word 256 := ⟨2^256-1, by
  have positive : 0 < (2 : Nat)^256 := pow_pos (by decide) _
  omega⟩
private def half : Word 256 := ⟨2^255, Nat.pow_lt_pow_right (by decide) (by decide)⟩
private def halfLess : Word 256 := ⟨2^255-1, lt_of_le_of_lt (Nat.sub_le _ _) half.bound⟩
private def initial (wallet x y : Nat) : S where
  balance
    | (.pool, .trader, .x) => wallet
    | (.pool, .pool, .x) => x
    | (.pool, .trader, .y) => 0
    | (.pool, .pool, .y) => y
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def resultMatches (actual : Except WordSettlement.Refusal W)
    (traderX poolX traderY poolY : ℚ) (expectedStore : Store := fullStore) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.pool, .trader, .x) = traderX ∧
      post.state.balance (.pool, .pool, .x) = poolX ∧
      post.state.balance (.pool, .trader, .y) = traderY ∧
      post.state.balance (.pool, .pool, .y) = poolY ∧ post.capabilities = expectedStore)
private def refusalMatches (actual : Except WordSettlement.Refusal W)
    (reason : WordSettlement.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error observed => decide (observed = reason)
private def noTraderDebit : Store :=
  ⟨[⟨⟨.trader, .pool, operation, .invoke⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .pool, .y)⟩, true⟩]⟩
private def noPoolDebit : Store := ⟨fullStore.entries.take 2⟩
private def checks : List (String × Bool) := [
  ("fee_retained_floor_actual_balances", resultMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ fullStore (initial 5 10 20)) 3 12 1 19),
  ("zero_fee_still_floor", resultMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 0,word 1⟩ fullStore (initial 5 10 20)) 3 12 3 17),
  ("zero_output_still_settles_input", resultMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 1) ⟨word 1,word 2⟩ fullStore (initial 5 10 20)) 4 11 0 20),
  ("zero_output_needs_no_pool_y_debit", resultMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 1) ⟨word 1,word 2⟩ noPoolDebit (initial 5 10 20))
      4 11 0 20 noPoolDebit),
  ("exact_input_funding", resultMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ fullStore (initial 2 10 20)) 0 12 1 19),
  ("fullwidth_quote_and_ledger_casts", resultMatches
    (WordSettlement.run ⟨half,maxWord⟩ halfLess ⟨word 0,maxWord⟩ fullStore
      (initial (2^255-1) (2^255) (2^256-1))) 0 (2^256-1) (2^255-1) (2^255)),
  ("mismatched_x_reserve", refusalMatches
    (WordSettlement.run ⟨word 11,word 20⟩ (word 1) ⟨word 1,word 2⟩ fullStore (initial 5 10 20)) .reserveMismatch),
  ("mismatched_y_reserve", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 1) ⟨word 1,word 2⟩ fullStore (initial 5 10 21)) .reserveMismatch),
  ("same_ratio_wrong_raw_units", refusalMatches
    (WordSettlement.run ⟨word 1000,word 2000⟩ (word 1) ⟨word 0,word 1⟩ fullStore (initial 5 1 2)) .reserveMismatch),
  ("mismatch_before_native_errors", refusalMatches
    (WordSettlement.run ⟨word 0,word 20⟩ (word 0) ⟨word 0,word 0⟩ ⟨[]⟩ (initial 5 10 20)) .reserveMismatch),
  ("native_zero_x", refusalMatches
    (WordSettlement.run ⟨word 0,word 20⟩ (word 1) ⟨word 0,word 1⟩ fullStore (initial 5 0 20)) (.quote .badReserve)),
  ("native_zero_y", refusalMatches
    (WordSettlement.run ⟨word 10,word 0⟩ (word 1) ⟨word 0,word 1⟩ fullStore (initial 5 10 0)) (.quote .badReserve)),
  ("native_zero_amount_before_bad_fee", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 0) ⟨word 0,word 0⟩ fullStore (initial 5 10 20)) (.quote .badAmount)),
  ("native_bad_fee", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 1) ⟨word 0,word 0⟩ fullStore (initial 5 10 20)) (.quote .badFee)),
  ("native_full_fee", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 1) ⟨word 1,word 1⟩ fullStore (initial 5 10 20)) (.quote .badFee)),
  ("native_reserve_add_overflow", refusalMatches
    (WordSettlement.run ⟨maxWord,word 20⟩ (word 1) ⟨word 0,word 1⟩ fullStore
      (initial 5 (2^256-1) 20)) (.quote (.arithmetic .addOverflow))),
  ("native_bad_fee_before_overflow", refusalMatches
    (WordSettlement.run ⟨maxWord,word 20⟩ (word 1) ⟨word 1,word 1⟩ fullStore
      (initial 5 (2^256-1) 20)) (.quote .badFee)),
  ("native_error_before_typed_authority", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 0) ⟨word 0,word 1⟩ ⟨[]⟩ (initial 5 10 20)) (.quote .badAmount)),
  ("actual_invoke_authority", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ ⟨[]⟩ (initial 5 10 20)) (.typed .unauthorizedInvoke)),
  ("actual_trader_debit_authority", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ noTraderDebit (initial 5 10 20)) (.typed .unauthorizedDebit)),
  ("actual_pool_y_debit_for_positive_output", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ noPoolDebit (initial 5 10 20)) (.typed .unauthorizedDebit)),
  ("actual_trader_insufficient_funds", refusalMatches
    (WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ fullStore (initial 1 10 20)) (.typed .insufficientFunds))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty Word settlement controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate Word settlement controls")
  match WordSettlement.run ⟨word 10,word 20⟩ (word 2) ⟨word 1,word 2⟩ fullStore (initial 5 10 20) with
  | .error reason => IO.println s!"WORD_SETTLEMENT_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"WORD_SETTLEMENT_OBSERVATION {post.state.balance (.pool, .trader, .x)} {post.state.balance (.pool, .pool, .x)} {post.state.balance (.pool, .trader, .y)} {post.state.balance (.pool, .pool, .y)}"
  match WordSettlement.run ⟨word 11,word 20⟩ (word 1) ⟨word 1,word 2⟩ fullStore (initial 5 10 20) with
  | .error reason => IO.println s!"WORD_SETTLEMENT_MISMATCH_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"WORD_SETTLEMENT_MISMATCH_OBSERVATION {post.state.balance (.pool, .trader, .x)} {post.state.balance (.pool, .pool, .x)} {post.state.balance (.pool, .trader, .y)} {post.state.balance (.pool, .pool, .y)}"
  for (name, passed) in checks do IO.println s!"WORD_SETTLEMENT_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual Word settlement comparison")
  IO.println s!"WORD_SETTLEMENT_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.AMM.WordSettlementAudit
