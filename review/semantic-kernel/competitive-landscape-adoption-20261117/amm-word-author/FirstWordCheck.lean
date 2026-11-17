import DefiKernel.AMM.Checked
open DefiKernel.Arithmetic DefiKernel.AMM.Checked
private def zero : Word 256 := ⟨0, by decide⟩
private def one : Word 256 := ⟨1, by decide⟩
private def two : Word 256 := ⟨2, by decide⟩
private def ten : Word 256 := ⟨10, by decide⟩
private def twenty : Word 256 := ⟨20, by decide⟩
private def resultMatches (actual : Except Refusal Swap) (q x y : Nat) : Bool :=
  match actual with
  | .error _ => false
  | .ok result => decide (result.output.value = q ∧ result.post.reserveX.value = x ∧
      result.post.reserveY.value = y)
#eval do
  let checks := [
    ("fractional_fee_single_floor_zero_output", resultMatches (swapPool ⟨ten, twenty⟩ one ⟨one, two⟩) 0 11 20),
    ("fractional_fee_nonzero_floor", resultMatches (swapPool ⟨ten, twenty⟩ two ⟨one, two⟩) 1 12 19),
    ("reserve_refusal_priority", decide (swapPool ⟨zero, twenty⟩ zero ⟨zero, zero⟩ = (Except.error Refusal.badReserve : Except Refusal Swap))),
    ("zero_denominator_fee_refused", decide (swapPool ⟨ten, twenty⟩ one ⟨zero, zero⟩ = (Except.error Refusal.badFee : Except Refusal Swap)))]
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty Word first checks")
  for (name, passed) in checks do IO.println s!"WORD_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: Word fee/floor/refusal check")
