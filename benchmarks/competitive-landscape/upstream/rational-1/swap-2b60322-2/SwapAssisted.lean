import SwapModel

set_option maxHeartbeats 400000

namespace RationalSwap

open DefiKernel.Typed

theorem native_correspondence (x y d : ℚ) (defined : x + d ≠ 0) :
    nativeSwap x y d = .ok (y*d/(x+d), x+d, y-y*d/(x+d)) := by
  simp [nativeSwap, BinaryOp.eval, numericRat, numericValue, defined, bind, Except.bind,
    pure, Except.pure]

theorem success (x y d : ℚ) (hx : 0 < x) (hy : 0 < y) (hd : 0 < d) :
    ∃ output reserveX reserveY,
      swap (.exact x) (.exact y) (.exact d) = .success output reserveX reserveY ∧
      SuccessClaims x y d output reserveX reserveY := by
  have denominator : 0 < x+d := add_pos hx hd
  have nonzero : x+d ≠ 0 := ne_of_gt denominator
  have computed := native_correspondence x y d nonzero
  have output_positive : 0 < y*d/(x+d) := div_pos (mul_pos hy hd) denominator
  have output_bound : y*d/(x+d) < y := (div_lt_iff₀ denominator).mpr (by nlinarith)
  have product : (x+d) * (y-y*d/(x+d)) = x*y := by
    field_simp
    ring
  refine ⟨y*d/(x+d), x+d, y-y*d/(x+d), ?_, computed, rfl, rfl, rfl,
    output_positive, output_bound, denominator, sub_pos.mpr output_bound, product⟩
  simp [swap, swapExact, not_le.mpr hx, not_le.mpr hy, not_le.mpr hd, computed]

theorem canonical : Canonical := by
  refine ⟨success, ?_, ?_, ?_, ?_, ?_⟩
  · intro x y d invalid
    simp [swap, swapExact, invalid]
  · intro x y d hx hy invalid
    simp [swap, swapExact, not_le.mpr hx, not_le.mpr hy, invalid]
  · intro bad y d
    rfl
  · intro x bad d
    cases x <;> rfl
  · intro x y bad
    cases x <;> cases y <;> rfl

#print axioms canonical
#print axioms native_correspondence

end RationalSwap
