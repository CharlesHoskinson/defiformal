import DefiKernel.Arithmetic.Rounding
open DefiKernel.Arithmetic
#eval ("down21/4", decide (Rounding.divideNat .down 21 4 = .ok 5))
#eval ("up21/4", decide (Rounding.divideNat .up 21 4 = .ok 6))
#eval ("zero-denominator", decide (Rounding.divideNat .up 21 0 = .error .divisionByZero))
#eval ("full-product", decide (Rounding.mulDiv .down (⟨200, by decide⟩ : Word 8) ⟨200, by decide⟩ 200 = .ok ⟨200, by decide⟩))
#eval ("floor-fits", decide (Rounding.mulDiv .down (⟨254, by decide⟩ : Word 8) ⟨254, by decide⟩ 253 = .ok ⟨255, by decide⟩))
#eval ("ceil-overflow", decide (Rounding.mulDiv .up (⟨254, by decide⟩ : Word 8) ⟨254, by decide⟩ 253 = .error .quotientOverflow))
#eval ("width-zero", decide (Rounding.mulDiv .up (⟨0, by decide⟩ : Word 0) ⟨0, by decide⟩ 3 = .ok ⟨0, by decide⟩))
