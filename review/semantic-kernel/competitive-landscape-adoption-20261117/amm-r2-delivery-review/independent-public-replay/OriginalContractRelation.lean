import SwapModel
import R2Replay

/-! Compatibility artifact only: the historical benchmark remains unchanged. -/
namespace R2OriginalRelation
open DefiKernel.AMM

def number : RationalSwap.Number → R2Bridge.Number
  | .exact value => .exact value
  | .malformed label => .malformed label

def reason : RationalSwap.Reason → R2Bridge.Reason
  | .badNumber => .badNumber
  | .badReserve => .badReserve
  | .badAmount => .badAmount
  | .nativeFailure failure => .nativeFailure failure

def result : RationalSwap.Result → R2Bridge.Result
  | .success output reserveX reserveY => .success output reserveX reserveY
  | .refused failure => .refused (reason failure)

theorem trace_identity (x y amount : ℚ) :
    R2Bridge.originalArithmetic x y amount = RationalSwap.nativeSwap x y amount := rfl

theorem success_claims_identity (x y amount output reserveX reserveY : ℚ) :
    R2Bridge.SuccessClaims x y amount output reserveX reserveY ↔
      RationalSwap.SuccessClaims x y amount output reserveX reserveY := Iff.rfl

theorem exact_behavior (x y amount : ℚ) :
    R2Bridge.swap (.exact x) (.exact y) (.exact amount) =
      result (RationalSwap.swap (.exact x) (.exact y) (.exact amount)) := by
  by_cases invalid : x ≤ 0 ∨ y ≤ 0
  · rw [R2Bridge.canonical.2.1 x y amount invalid]
    simp [RationalSwap.swap, RationalSwap.swapExact, invalid, result, reason]
  · have hx : 0 < x := lt_of_not_ge (fun h => invalid (Or.inl h))
    have hy : 0 < y := lt_of_not_ge (fun h => invalid (Or.inr h))
    by_cases badAmount : amount ≤ 0
    · rw [R2Bridge.canonical.2.2.1 x y amount hx hy badAmount]
      simp [RationalSwap.swap, RationalSwap.swapExact, invalid, badAmount, result, reason]
    · obtain ⟨output, reserveX, reserveY, executed, claims⟩ :=
        R2Bridge.success x y amount hx hy (lt_of_not_ge badAmount)
      have trace : RationalSwap.nativeSwap x y amount = .ok (output, reserveX, reserveY) := claims.1
      rw [executed]
      simp [RationalSwap.swap, RationalSwap.swapExact, invalid, badAmount, trace, result]

theorem all_constructor_behavior (x y amount : RationalSwap.Number) :
    R2Bridge.swap (number x) (number y) (number amount) =
      result (RationalSwap.swap x y amount) := by
  cases x <;> cases y <;> cases amount <;> try rfl
  exact exact_behavior _ _ _

end R2OriginalRelation
