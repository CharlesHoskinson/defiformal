import DefiKernel.Typed.Expr
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Aesop

namespace RationalSwap

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

-- The new reserve composition executes existing dimensioned-kernel arithmetic.
-- It is not a preexisting upstream AMM implementation or theorem.
def nativeSwap (x y d : ℚ) : Except EvalFailure (ℚ × ℚ × ℚ) := do
  let reserveX ← BinaryOp.eval (BinaryOp.add (Asset := Unit) .scalar) x d
  let numerator ← BinaryOp.eval (BinaryOp.scale (Asset := Unit) .scalar) y d
  let output ← BinaryOp.eval (BinaryOp.divide (Asset := Unit) .scalar) numerator reserveX
  let reserveY ← BinaryOp.eval (BinaryOp.sub (Asset := Unit) .scalar) y output
  return (output, reserveX, reserveY)

def swapExact (x y d : ℚ) : Result :=
  if x ≤ 0 ∨ y ≤ 0 then .refused .badReserve
  else if d ≤ 0 then .refused .badAmount
  else match nativeSwap x y d with
    | .error reason => .refused (.nativeFailure reason)
    | .ok (output, reserveX, reserveY) => .success output reserveX reserveY

def swap : Number → Number → Number → Result
  | .exact x, .exact y, .exact d => swapExact x y d
  | _, _, _ => .refused .badNumber

-- BEGIN SPECIFICATION

def SuccessClaims (x y d output reserveX reserveY : ℚ) : Prop :=
  nativeSwap x y d = .ok (output, reserveX, reserveY) ∧
  output = y*d/(x+d) ∧ reserveX = x+d ∧ reserveY = y-output ∧
  0 < output ∧ output < y ∧ 0 < reserveX ∧ 0 < reserveY ∧
  reserveX * reserveY = x*y

def Canonical : Prop :=
  (∀ x y d : ℚ, 0 < x → 0 < y → 0 < d →
    ∃ output reserveX reserveY,
      swap (.exact x) (.exact y) (.exact d) = .success output reserveX reserveY ∧
      SuccessClaims x y d output reserveX reserveY) ∧
  (∀ x y d : ℚ, x ≤ 0 ∨ y ≤ 0 → swap (.exact x) (.exact y) (.exact d) = .refused .badReserve) ∧
  (∀ x y d : ℚ, 0 < x → 0 < y → d ≤ 0 → swap (.exact x) (.exact y) (.exact d) = .refused .badAmount) ∧
  (∀ bad y d, swap (.malformed bad) y d = .refused .badNumber) ∧
  (∀ x bad d, swap x (.malformed bad) d = .refused .badNumber) ∧
  (∀ x y bad, swap x y (.malformed bad) = .refused .badNumber)

end RationalSwap
