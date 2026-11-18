import DefiKernel.AMM.Rational
import DefiKernel.Typed.Expr

/-! Full original rational R2 contract, now implemented by the reusable zero-fee pool library.
The generic Typed arithmetic trace is a specification witness, not the swap implementation. -/
namespace DefiKernel.AMM.R2Bridge
open DefiKernel.Typed

inductive Number where
  | exact (value : ℚ)
  | malformed (description : String)

inductive Reason where
  | badNumber | badReserve | badAmount
  | nativeFailure (reason : EvalFailure)
  deriving DecidableEq, Repr

inductive Result where
  | success (output reserveX reserveY : ℚ)
  | refused (reason : Reason)
  deriving DecidableEq, Repr

/-- Zero fee cannot produce a badFee refusal, for any independent signed reserve/input values. -/
theorem zero_fee_ne_badFee (pool : Rational.Pool) (amount : ℚ) :
    Rational.swapPool pool amount 0 ≠ .error .badFee := by
  simp only [Rational.swapPool]
  split_ifs <;> simp_all
  all_goals linarith

def projectLibrary : (actual : Except Rational.Refusal Rational.Swap) →
    (actual ≠ .error .badFee) → Result
  | .ok result, _ => .success result.output result.post.reserveX result.post.reserveY
  | .error .badReserve, _ => .refused .badReserve
  | .error .badAmount, _ => .refused .badAmount
  | .error .badFee, impossible => False.elim (impossible rfl)

theorem project_ok (actual : Except Rational.Refusal Rational.Swap)
    (safe : actual ≠ .error .badFee) (result : Rational.Swap) (observed : actual = .ok result) :
    projectLibrary actual safe = .success result.output result.post.reserveX result.post.reserveY := by
  subst actual
  rfl

theorem project_bad_reserve (actual : Except Rational.Refusal Rational.Swap)
    (safe : actual ≠ .error .badFee) (observed : actual = .error .badReserve) :
    projectLibrary actual safe = .refused .badReserve := by
  subst actual
  rfl

theorem project_bad_amount (actual : Except Rational.Refusal Rational.Swap)
    (safe : actual ≠ .error .badFee) (observed : actual = .error .badAmount) :
    projectLibrary actual safe = .refused .badAmount := by
  subst actual
  rfl

theorem project_success_iff (actual : Except Rational.Refusal Rational.Swap)
    (safe : actual ≠ .error .badFee) (output reserveX reserveY : ℚ) :
    projectLibrary actual safe = .success output reserveX reserveY ↔
      ∃ result, actual = .ok result ∧ result.output = output ∧
        result.post.reserveX = reserveX ∧ result.post.reserveY = reserveY := by
  cases actual with
  | ok result => simp [projectLibrary]
  | error reason =>
    cases reason with
    | badReserve => simp [projectLibrary]
    | badAmount => simp [projectLibrary]
    | badFee => exact False.elim (safe rfl)

/-- The only operation implementation: call the reusable pool API at fee zero and project it. -/
def swapExact (x y amount : ℚ) : Result :=
  projectLibrary (Rational.swapPool ⟨y, x⟩ amount 0) (zero_fee_ne_badFee ⟨y, x⟩ amount)

def swap : Number → Number → Number → Result
  | .exact x, .exact y, .exact amount => swapExact x y amount
  | _, _, _ => .refused .badNumber


end DefiKernel.AMM.R2Bridge
open DefiKernel.AMM.R2Bridge
private def run (x y amount : ℚ) : Result := swap (.exact x) (.exact y) (.exact amount)
private def checks : List (String × Bool) := [
  ("original_fractional", decide (run (1/3) (7/5) (2/9) = Result.success (14/25) (5/9) (21/25))),
  ("independent_fractional", decide (run (1/2) (2/3) (3/4) = Result.success (2/5) (5/4) (4/15))),
  ("unbounded_above_word256", let x : ℚ := 2^300; let amount : ℚ := 2^301;
    decide (run x (7/3) amount = Result.success (14/9) (3*x) (7/9))),
  ("unbounded_independent_denominators", let x : ℚ := 1/(2^300+1);
    let y : ℚ := 3/7; let amount : ℚ := 1/(3^300+1);
    decide (run x y amount = Result.success (y*amount/(x+amount)) (x+amount)
      (y-y*amount/(x+amount)))),
  ("zero_fee_unrounded", decide (run 10 20 2 = Result.success (10/3) 12 (50/3))),
  ("reject_word_floor", !decide (run 10 20 2 = Result.success 3 12 17)),
  ("formal_malformed_first", decide (swap (.malformed "bad-x") (.exact (-1)) (.exact (-1)) =
    Result.refused Reason.badNumber)),
  ("formal_malformed_second", decide (swap (.exact (-1)) (.malformed "0.5") (.exact (-1)) =
    Result.refused Reason.badNumber)),
  ("formal_malformed_third", decide (swap (.exact 0) (.exact (-1)) (.malformed "1/0") =
    Result.refused Reason.badNumber)),
  ("formal_multiple_malformed", decide (swap (.malformed "x") (.malformed "y") (.malformed "d") =
    Result.refused Reason.badNumber)),
  ("zero_x_before_amount", decide (run 0 1 (-1) = Result.refused Reason.badReserve)),
  ("negative_y_before_amount", decide (run 1 (-1) (-1) = Result.refused Reason.badReserve)),
  ("negative_x_before_amount", decide (run (-1) 1 (-1) = Result.refused Reason.badReserve)),
  ("zero_y_before_zero_amount", decide (run 1 0 0 = Result.refused Reason.badReserve)),
  ("zero_amount", decide (run 1 1 0 = Result.refused Reason.badAmount)),
  ("negative_amount", decide (run 1 1 (-1) = Result.refused Reason.badAmount))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty R2 constructor controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate R2 controls")
  for (name, passed) in checks do IO.println s!"R2_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: R2 constructor comparison")
  IO.println s!"R2_CONTROL PASSED {checks.length}/{checks.length}"