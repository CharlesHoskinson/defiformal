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

-- BEGIN PROOFS

@[simp] theorem toQuantity_amount (asset : A) (scale : ℚ) (hscale : 0 < scale)
    (q : Word w) : (toQuantity asset scale hscale q).amount = (q.value : ℚ) * scale := rfl

theorem fromRat_ok_iff_div (scale amount : ℚ) (q : Word w) :
    fromRat w scale amount = .ok q ↔
      0 < scale ∧ 0 ≤ amount ∧ (q.value : ℚ) = amount / scale := by
  unfold fromRat
  by_cases hs : scale ≤ 0
  · simp [hs, not_lt.mpr hs]
  · have hsp : 0 < scale := lt_of_not_ge hs
    by_cases ha : amount < 0
    · simp [hs, ha, not_le.mpr ha]
    · have han : 0 ≤ amount := le_of_not_gt ha
      by_cases hi : (⌊amount / scale⌋₊ : ℚ) = amount / scale
      · simp only [hs, ha, if_false]
        rw [if_neg (not_not.mpr hi), Word.checked_ok_iff]
        constructor
        · intro h
          exact ⟨hsp, han, h ▸ hi⟩
        · rintro ⟨_, _, h⟩
          exact_mod_cast hi.trans h.symm
      · simp only [hs, ha, if_false]
        rw [if_pos hi]
        simp only [reduceCtorEq, false_iff]
        rintro ⟨_, _, h⟩
        apply hi
        rw [← h, Nat.floor_natCast]

theorem fromRat_ok_iff (scale amount : ℚ) (q : Word w) :
    fromRat w scale amount = .ok q ↔ 0 < scale ∧ amount = (q.value : ℚ) * scale := by
  rw [fromRat_ok_iff_div]
  constructor
  · rintro ⟨hs, _, h⟩
    exact ⟨hs, (eq_div_iff (ne_of_gt hs)).mp h |>.symm⟩
  · rintro ⟨hs, h⟩
    refine ⟨hs, ?_, (eq_div_iff (ne_of_gt hs)).mpr h.symm⟩
    rw [h]
    positivity

theorem fromRat_exists_iff (w : Nat) (scale amount : ℚ) :
    (∃ q, fromRat w scale amount = .ok q) ↔
      0 < scale ∧ ∃ n : Nat, n < 2^w ∧ amount = (n : ℚ) * scale := by
  simp only [fromRat_ok_iff]
  constructor
  · rintro ⟨q, hs, hq⟩
    exact ⟨hs, q.value, q.bound, hq⟩
  · rintro ⟨hs, n, hn, h⟩
    exact ⟨⟨n, hn⟩, hs, h⟩

@[simp] theorem fromRat_toQuantity (asset : A) (scale : ℚ) (hs : 0 < scale)
    (q : Word w) : fromRat w scale (toQuantity asset scale hs q).amount = .ok q := by
  exact (fromRat_ok_iff _ _ _).mpr ⟨hs, rfl⟩

theorem toQuantity_fromRat (asset : A) (scale amount : ℚ) (hs : 0 < scale)
    (q : Word w) (h : fromRat w scale amount = .ok q) :
    (toQuantity asset scale hs q).amount = amount :=
  ((fromRat_ok_iff _ _ _).mp h).2.symm

/-- Exact failure tags retain scale, sign, integrality and bound precedence. -/
theorem fromRat_error_iff (w : Nat) (scale amount : ℚ) (failure : Failure) :
    fromRat w scale amount = .error failure ↔
      (scale ≤ 0 ∧ failure = .nonPositiveScale) ∨
      (0 < scale ∧ amount < 0 ∧ failure = .negativeQuantity) ∨
      (0 < scale ∧ 0 ≤ amount ∧ (⌊amount / scale⌋₊ : ℚ) ≠ amount / scale ∧
        failure = .nonIntegralQuantity) ∨
      (0 < scale ∧ 0 ≤ amount ∧ (⌊amount / scale⌋₊ : ℚ) = amount / scale ∧
        2^w ≤ ⌊amount / scale⌋₊ ∧ failure = .inputOverflow) := by
  by_cases hs : scale ≤ 0
  · simp [fromRat, hs, not_lt.mpr hs, eq_comm]
  · have hsp : 0 < scale := lt_of_not_ge hs
    by_cases ha : amount < 0
    · simp [fromRat, hs, hsp, ha, not_le.mpr ha, eq_comm]
    · have han : 0 ≤ amount := le_of_not_gt ha
      by_cases hi : (⌊amount / scale⌋₊ : ℚ) = amount / scale
      · simp only [fromRat, hs, ha, if_false, ne_eq, hi, not_true_eq_false]
        rw [if_false, Word.checked_error_iff]
        simp [hs, hsp, ha, han, hi, eq_comm]
      · simp [fromRat, hs, hsp, ha, han, hi, eq_comm]

theorem toQuantity_fromRat_eq (asset : A) (scale : ℚ) (hs : 0 < scale)
    (quantity : DefiKernel.Typed.Quantity asset) (q : Word w)
    (h : fromRat w scale quantity.amount = .ok q) :
    toQuantity asset scale hs q = quantity := by
  cases quantity with
  | mk amount nonneg =>
    have heq := toQuantity_fromRat asset scale amount hs q h
    change DefiKernel.Typed.Quantity.mk ((q.value : ℚ) * scale) _ = _
    cases heq
    rfl

end DefiKernel.Arithmetic.Quantity
