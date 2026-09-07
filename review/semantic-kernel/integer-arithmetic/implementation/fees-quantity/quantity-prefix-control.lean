import DefiKernel.Arithmetic.Word
import DefiKernel.Typed.Types
import Mathlib.Data.Rat.Floor
import Mathlib.Tactic.Positivity

/-! Explicit positive-scale conversion. Inverse conversion never truncates a fraction. -/
namespace DefiKernel.Arithmetic.Quantity

variable {A : Type} {w : Nat}

def toQuantity (asset : A) (scale : ℚ) (hscale : 0 < scale) (q : Word w) :
    DefiKernel.Typed.Quantity asset where
  amount := (q.value : ℚ) * scale
  nonneg := by positivity

def fromRat (w : Nat) (scale amount : ℚ) : Except Failure (Word w) :=
  if scale ≤ 0 then .error .nonPositiveScale
  else if amount < 0 then .error .negativeQuantity
  else if (⌊amount / scale⌋₊ : ℚ) ≠ amount / scale then .error .nonIntegralQuantity
  else Word.checked .inputOverflow ⌊amount / scale⌋₊

end DefiKernel.Arithmetic.Quantity

#eval decide ((DefiKernel.Arithmetic.Quantity.toQuantity () (1/4) (by norm_num) (⟨7, by decide⟩ : DefiKernel.Arithmetic.Word 8)).amount = 7/4)
