import DefiKernel.AMM.Checked
open DefiKernel.Arithmetic DefiKernel.AMM.Checked
private def zero : Word 256 := ⟨0, by decide⟩
private def one : Word 256 := ⟨1, by decide⟩
private def two : Word 256 := ⟨2, by decide⟩
private def four : Word 256 := ⟨4, by decide⟩
private def ten : Word 256 := ⟨10, by decide⟩
private def twenty : Word 256 := ⟨20, by decide⟩
private def maxWord : Word 256 := ⟨2^256-1, by
  have positive : 0 < (2 : Nat)^256 := pow_pos (by decide) _
  omega⟩
private def almostMax : Word 256 := ⟨2^256-2, by
  have positive : 0 < (2 : Nat)^256 := pow_pos (by decide) _
  omega⟩
private def halfRange : Word 256 :=
  ⟨2^255, Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 255 < 256)⟩
private def halfLessOne : Word 256 :=
  ⟨2^255-1, lt_of_le_of_lt (Nat.sub_le _ _) halfRange.bound⟩
private def resultMatches (actual : Except Refusal Swap) (q x y : Nat) : Bool :=
  match actual with
  | .error _ => false
  | .ok result => decide (result.output.value = q ∧ result.post.reserveX.value = x ∧
      result.post.reserveY.value = y)
private def errorMatches (actual : Except Refusal Swap) (reason : Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error observed => decide (observed = reason)
private def checks : List (String × Bool) := [
  ("zero_output_without_early_fee_rounding", resultMatches
    (swapPool ⟨ten, twenty⟩ one ⟨one, two⟩) 0 11 20),
  ("one_final_floor", resultMatches (swapPool ⟨ten, twenty⟩ two ⟨one, two⟩) 1 12 19),
  ("zero_fee_still_floors", resultMatches (swapPool ⟨ten, twenty⟩ two ⟨zero, one⟩) 3 12 17),
  ("nonreduced_fee_pair", resultMatches (swapPool ⟨ten, twenty⟩ one ⟨two, four⟩) 0 11 20),
  ("proper_near_one_fullwidth_fee", resultMatches
    (swapPool ⟨ten, twenty⟩ one ⟨almostMax, maxWord⟩) 0 11 20),
  ("768bit_product_not_truncated", resultMatches
    (swapPool ⟨halfRange, maxWord⟩ halfLessOne ⟨zero, maxWord⟩)
    (2^255-1) (2^256-1) (2^255)),
  ("zero_reserve_priority", errorMatches
    (swapPool ⟨zero, twenty⟩ zero ⟨zero, zero⟩) .badReserve),
  ("zero_output_reserve_priority", errorMatches
    (swapPool ⟨ten, zero⟩ zero ⟨zero, zero⟩) .badReserve),
  ("zero_amount_before_bad_fee", errorMatches
    (swapPool ⟨ten, twenty⟩ zero ⟨zero, zero⟩) .badAmount),
  ("zero_fee_denominator", errorMatches
    (swapPool ⟨ten, twenty⟩ one ⟨zero, zero⟩) .badFee),
  ("full_fee_refused", errorMatches
    (swapPool ⟨ten, twenty⟩ one ⟨one, one⟩) .badFee),
  ("excess_fee_refused", errorMatches
    (swapPool ⟨ten, twenty⟩ one ⟨two, one⟩) .badFee),
  ("bad_fee_before_reserve_overflow", errorMatches
    (swapPool ⟨maxWord, twenty⟩ one ⟨one, one⟩) .badFee),
  ("retained_input_reserve_overflow", errorMatches
    (swapPool ⟨maxWord, twenty⟩ one ⟨zero, one⟩) (.arithmetic .addOverflow)),
  ("zero_output_reverse_refuses_without_poststate", match swapPool ⟨ten, twenty⟩ one ⟨one, two⟩ with
    | .error _ => false
    | .ok first => errorMatches
      (swapPool ⟨first.post.reserveY, first.post.reserveX⟩ first.output ⟨one, two⟩) .badAmount)]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty Word control inventory")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate Word controls")
  for (name, passed) in checks do IO.println s!"WORD_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: Word control comparison")
  IO.println s!"WORD_CONTROL PASSED {checks.length}/{checks.length}"
