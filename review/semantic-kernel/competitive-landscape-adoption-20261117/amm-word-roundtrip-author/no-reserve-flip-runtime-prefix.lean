import DefiKernel.AMM.Checked

/-! Same-pool full-output reversal in raw Word units. No wallet or market-price claim. -/
namespace DefiKernel.AMM.CheckedRoundTrip
open DefiKernel.Arithmetic DefiKernel.AMM.Checked

def flip (pool : Pool) : Pool := ⟨pool.reserveX, pool.reserveY⟩

def roundTrip (pool : Pool) (amount : Word 256) (fee : Fee) : Except Refusal (Swap × Swap) := do
  let forward ← swapPool pool amount fee
  let reverse ← swapPool (flip forward.post) forward.output fee
  return (forward, reverse)


end DefiKernel.AMM.CheckedRoundTrip

namespace DefiKernel.AMM.CheckedRoundTripAudit
open DefiKernel.Arithmetic DefiKernel.AMM.Checked DefiKernel.AMM.CheckedRoundTrip
private def word (n : Nat) (bounded : n < 2^256 := by decide) : Word 256 := ⟨n, bounded⟩
private def maxWord : Word 256 := ⟨2^256-1, by
  have positive : 0 < (2 : Nat)^256 := pow_pos (by decide) _
  omega⟩
private def pool (x y : Nat) (hx : x < 2^256 := by decide)
    (hy : y < 2^256 := by decide) : Pool := ⟨word x hx, word y hy⟩
private def fee (n d : Nat) (hn : n < 2^256 := by decide)
    (hd : d < 2^256 := by decide) : Fee := ⟨word n hn, word d hd⟩
private def resultMatches (actual : Except Refusal (Swap × Swap))
    (q x y returned reverseX reverseY : Nat) : Bool :=
  match actual with
  | .error _ => false
  | .ok (first, second) => decide (first.output.value = q ∧ first.post.reserveX.value = x ∧
      first.post.reserveY.value = y ∧ second.output.value = returned ∧
      second.post.reserveX.value = reverseX ∧ second.post.reserveY.value = reverseY)
private def errorMatches (actual : Except Refusal (Swap × Swap)) (expected : Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason = expected)
private def checks : List (String × Bool) := [
  ("zero_fee_floor_loss", resultMatches (roundTrip (pool 10 20) (word 2) (fee 0 1)) 3 12 17 1 20 11),
  ("fee_retained_second_zero_output", resultMatches (roundTrip (pool 10 20) (word 2) (fee 1 2))
    1 12 19 0 20 12),
  ("exact_roundtrip_equality", resultMatches (roundTrip (pool 1 2) (word 1) (fee 0 1)) 1 2 1 1 2 1),
  ("reverse_headroom_from_original_max_reserve", resultMatches
    (roundTrip ⟨word 1, maxWord⟩ (word 1) (fee 0 1))
    (2^255-1) 2 (2^255) 0 (2^256-1) 2),
  ("zero_output_actual_forward_then_reverse_refusal", match swapPool (pool 10 20) (word 1) (fee 1 2) with
    | .error _ => false
    | .ok first => decide (first.output.value = 0 ∧ first.post.reserveX.value = 11 ∧
        first.post.reserveY.value = 20) &&
        errorMatches (roundTrip (pool 10 20) (word 1) (fee 1 2)) .badAmount),
  ("forward_bad_reserve_priority", errorMatches (roundTrip (pool 0 20) (word 0) (fee 1 0)) .badReserve),
  ("forward_bad_amount_priority", errorMatches (roundTrip (pool 10 20) (word 0) (fee 1 0)) .badAmount),
  ("forward_bad_fee", errorMatches (roundTrip (pool 10 20) (word 1) (fee 1 1)) .badFee),
  ("forward_reserve_overflow", errorMatches
    (roundTrip ⟨maxWord, word 20⟩ (word 1) (fee 0 1)) (.arithmetic .addOverflow))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty Word roundtrip controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate Word roundtrip controls")
  for (name, passed) in checks do IO.println s!"WORD_ROUNDTRIP_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: Word roundtrip comparison")
  IO.println s!"WORD_ROUNDTRIP_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.AMM.CheckedRoundTripAudit