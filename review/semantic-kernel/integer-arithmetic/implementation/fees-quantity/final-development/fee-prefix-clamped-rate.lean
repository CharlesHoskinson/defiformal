import DefiKernel.Arithmetic.Rounding

/-! Gross-based and on-top fee quotes. Natural rate parameters are never word-truncated. -/
namespace DefiKernel.Arithmetic.Fees

structure FeeQuote (w : Nat) where
  principal : Word w
  fee : Word w
  charged : Word w
  received : Word w
  deriving DecidableEq, Repr

variable {w : Nat}

def validatedRate (num den : Nat) : Except Failure Nat :=
  if den = 0 then .error .invalidRate else .ok (min num den)

def feeFromGross (mode : Rounding) (gross : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (gross.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let received ← Word.checked .subUnderflow (gross.value - fee.value)
  return ⟨gross, fee, gross, received⟩

def feeOnTop (mode : Rounding) (principal : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (principal.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let charged ← Word.checked .addOverflow (principal.value + fee.value)
  return ⟨principal, fee, charged, principal⟩

end DefiKernel.Arithmetic.Fees
open DefiKernel.Arithmetic DefiKernel.Arithmetic.Fees
private def observe (result : Except Failure (FeeQuote 8)) : Except Failure (Nat × Nat × Nat × Nat) :=
  result.map fun quote ↦ (quote.principal.value, quote.fee.value, quote.charged.value, quote.received.value)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 1 3) = .ok (100, 33, 100, 67))
#eval decide (observe (feeFromGross .up ⟨100, by decide⟩ 1 3) = .ok (100, 34, 100, 66))
#eval decide (observe (feeOnTop .up ⟨100, by decide⟩ 1 3) = .ok (100, 34, 134, 100))
#eval decide (observe (feeOnTop .up ⟨255, by decide⟩ 1 1) = .error .addOverflow)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 300 600) = .ok (100, 50, 100, 50))
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 3 2) = .error .invalidRate)
#eval decide (observe (feeFromGross .down ⟨100, by decide⟩ 1 0) = .error .invalidRate)
#eval decide (feeFromGross .up (⟨0, by decide⟩ : Word 0) 300 600 =
  .ok ⟨⟨0, by decide⟩, ⟨0, by decide⟩, ⟨0, by decide⟩, ⟨0, by decide⟩⟩)
