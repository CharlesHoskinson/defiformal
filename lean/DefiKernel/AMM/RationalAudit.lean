import DefiKernel.AMM.Rational

/-! Finite regression controls for the rational pool library, separate from its universal proofs. -/
namespace DefiKernel.AMM.RationalAudit
open Rational

def successMatches (actual : Except Refusal Swap) (output reserveX reserveY : ℚ) : Bool :=
  match actual with
  | .error _ => false
  | .ok result => decide (result = ⟨output, ⟨reserveX, reserveY⟩⟩)

def refusalMatches (actual : Except Refusal Swap) (expected : Refusal) : Bool :=
  match actual with
  | .error reason => decide (reason = expected)
  | .ok _ => false

def roundTripMatches (actual : Except Refusal RoundTrip) (returned reserveX reserveY : ℚ) : Bool :=
  match actual with
  | .error _ => false
  | .ok result => decide (result = ⟨returned, ⟨reserveX, reserveY⟩⟩)

def checks : List (String × Bool) := [
  ("fee_retained_and_denominator", successMatches (swapPool ⟨10, 20⟩ 2 (1/2))  (20/11) 12 (200/11)),
  ("zero_fee_exact", successMatches (swapPool ⟨10, 20⟩ 2 0) (10/3) 12 (50/3)),
  ("fractional_independent_inputs", successMatches (swapPool ⟨1/2, 2/3⟩ (3/4) (1/3)) (1/3) (5/4) (1/3)),
  ("fee_increases_product", match swapPool ⟨10, 20⟩ 2 (1/2) with
    | .error _ => false
    | .ok result => decide (result.post.reserveX * result.post.reserveY = 2400/11 ∧
        200 < result.post.reserveX * result.post.reserveY)),
  ("reject_fee_removed_post_reserve", !successMatches (swapPool ⟨10, 20⟩ 2 (1/2)) (20/11) 11 (200/11)),
  ("reject_wrong_denominator", !successMatches (swapPool ⟨10, 20⟩ 2 (1/2)) 2 12 18),
  ("reserve_before_amount_and_fee", refusalMatches (swapPool ⟨0, 20⟩ 0 (-1)) .badReserve),
  ("signed_reserve_before_amount_and_fee", refusalMatches (swapPool ⟨-1, 20⟩ (-1) 2) .badReserve),
  ("amount_before_fee", refusalMatches (swapPool ⟨10, 20⟩ 0 2) .badAmount),
  ("signed_amount_before_fee", refusalMatches (swapPool ⟨10, 20⟩ (-1) (-1)) .badAmount),
  ("negative_fee_refused", refusalMatches (swapPool ⟨10, 20⟩ 2 (-1/2)) .badFee),
  ("full_fee_refused", refusalMatches (swapPool ⟨10, 20⟩ 2 1) .badFee),
  ("excess_fee_refused", refusalMatches (swapPool ⟨10, 20⟩ 2 (3/2)) .badFee),
  ("full_output_round_trip_fee", roundTripMatches (roundTrip ⟨10, 20⟩ 2 (1/2)) (4/7) (80/7) 20),
  ("full_output_round_trip_zero_fee", roundTripMatches (roundTrip ⟨10, 20⟩ 2 0) 2 10 20),
  ("round_trip_first_refusal", match roundTrip ⟨0, 20⟩ 0 (-1) with
    | .error reason => decide (reason = .badReserve)
    | .ok _ => false)]

def runChecks : IO Unit := do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty AMM rational inventory")
  if !decide (checks.map Prod.fst).Nodup then
    throw (IO.userError "BLOCKED: duplicate AMM rational inventory")
  for (name, passed) in checks do
    IO.println s!"AMM_RATIONAL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: AMM rational comparison")
  IO.println s!"AMM_RATIONAL PASSED {checks.length}/{checks.length}"

#eval runChecks

end DefiKernel.AMM.RationalAudit
