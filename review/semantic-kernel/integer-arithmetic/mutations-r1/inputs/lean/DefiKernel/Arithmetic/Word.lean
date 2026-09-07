import Mathlib.Data.Nat.Basic

/-! Checked unsigned values. Width zero contains only zero. -/
namespace DefiKernel.Arithmetic

structure Word (w : Nat) where
  value : Nat
  bound : value < 2^w
  deriving DecidableEq, Repr

inductive Failure
  | inputOverflow | addOverflow | subUnderflow | mulOverflow
  | divisionByZero | quotientOverflow | invalidRate
  | nonPositiveScale | negativeQuantity | nonIntegralQuantity
  deriving DecidableEq, Repr

inductive Rounding | down | up
  deriving DecidableEq, Repr

variable {w : Nat}

def Word.checked (error : Failure) (n : Nat) : Except Failure (Word w) :=
  if h : n < 2^w then .ok ⟨n, h⟩ else .error error

def ofNat (w n : Nat) : Except Failure (Word w) :=
  Word.checked .inputOverflow n

-- BEGIN PROOFS

@[ext] theorem Word.ext {a b : Word w} (h : a.value = b.value) : a = b := by
  cases a; cases b; cases h; rfl

@[simp] theorem Word.checked_ok_iff (error : Failure) (n : Nat) (q : Word w) :
    Word.checked error n = .ok q ↔ n = q.value := by
  unfold Word.checked
  split
  · simp only [Except.ok.injEq]
    exact ⟨fun h ↦ congrArg Word.value h, fun h ↦ Word.ext h⟩
  · rename_i h
    constructor
    · intro eq; cases eq
    · intro eq
      exact False.elim (h (eq ▸ q.bound))

@[simp] theorem Word.checked_error_iff (error failure : Failure) (n : Nat) :
    Word.checked (w := w) error n = .error failure ↔ 2^w ≤ n ∧ error = failure := by
  unfold Word.checked
  split
  · rename_i h
    simp [Nat.not_le_of_lt h]
  · rename_i h
    simp [Nat.le_of_not_gt h]

theorem Word.checked_exists_iff (error : Failure) (n : Nat) :
    (∃ q : Word w, Word.checked error n = .ok q) ↔ n < 2^w := by
  simp only [Word.checked_ok_iff]
  exact ⟨fun ⟨q, h⟩ ↦ h ▸ q.bound, fun h ↦ ⟨⟨n, h⟩, rfl⟩⟩

@[simp] theorem ofNat_ok_iff (n : Nat) (q : Word w) :
    ofNat w n = .ok q ↔ n = q.value := Word.checked_ok_iff _ _ _

@[simp] theorem ofNat_error_iff (n : Nat) (failure : Failure) :
    ofNat w n = .error failure ↔ 2^w ≤ n ∧ failure = .inputOverflow := by
  rw [ofNat, Word.checked_error_iff]
  exact and_congr_right fun _ ↦ eq_comm

theorem ofNat_value (q : Word w) : ofNat w q.value = .ok q := by simp

theorem Word.width_zero (q : Word 0) : q.value = 0 := by
  have := q.bound
  change q.value < 1 at this
  omega

end DefiKernel.Arithmetic
