import DefiKernel.Arithmetic.Rounding
import DefiKernel.ConcentratedLiquidity.Types

/-! Documented floor/ceil FullMath at width 256. Not assembly mulmod/CRT identity. -/
namespace DefiKernel.ConcentratedLiquidity.FullMath
open ConcentratedLiquidity

/-- Rounding only produces `divisionByZero` or `quotientOverflow`. Other arms are unreachable. -/
def ofRoundingFailure (e : Arithmetic.Failure) : Failure :=
  match e with
  | .divisionByZero => .divisionByZero
  | .quotientOverflow => .quotientOverflow
  | .addOverflow => .addOverflow
  | .subUnderflow => .subUnderflow
  | .mulOverflow | .inputOverflow | .invalidRate
  | .nonPositiveScale | .negativeQuantity | .nonIntegralQuantity => .quotientOverflow

def liftMulDiv (mode : Arithmetic.Rounding) (a b : U256) (d : Nat) :
    Except Failure U256 :=
  match Arithmetic.Rounding.mulDiv (w := 256) mode a b d with
  | .ok q => .ok q
  | .error e => .error (ofRoundingFailure e)

def mulDiv (a b d : U256) : Except Failure U256 :=
  liftMulDiv .down a b d.value

def mulDivRoundingUp (a b d : U256) : Except Failure U256 :=
  liftMulDiv .up a b d.value

-- BEGIN PROOFS

theorem ofRoundingFailure_div_or_quot (e : Arithmetic.Failure)
    (h : e = .divisionByZero ∨ e = .quotientOverflow) :
    ofRoundingFailure e = .divisionByZero ∨ ofRoundingFailure e = .quotientOverflow := by
  cases h with
  | inl h => subst h; exact Or.inl rfl
  | inr h => subst h; exact Or.inr rfl

theorem rounding_error_div_or_quot (mode : Arithmetic.Rounding) (a b : U256) (d : Nat)
    (e : Arithmetic.Failure)
    (h : Arithmetic.Rounding.mulDiv (w := 256) mode a b d = .error e) :
    e = .divisionByZero ∨ e = .quotientOverflow :=
  Arithmetic.Rounding.mulDiv_error_cases (w := 256) mode a b d e h

theorem ofRoundingFailure_eq_of_rounding (e : Arithmetic.Failure)
    (h : e = .divisionByZero ∨ e = .quotientOverflow) :
    ofRoundingFailure e =
      match e with
      | .divisionByZero => .divisionByZero
      | .quotientOverflow => .quotientOverflow
      | _ => ofRoundingFailure e := by
  cases h with
  | inl h => subst h; rfl
  | inr h => subst h; rfl

theorem liftMulDiv_ok_iff (mode : Arithmetic.Rounding) (a b q : U256) (d : Nat) :
    liftMulDiv mode a b d = .ok q ↔
      Arithmetic.Rounding.mulDiv (w := 256) mode a b d = .ok q := by
  unfold liftMulDiv
  cases h : Arithmetic.Rounding.mulDiv (w := 256) mode a b d <;> simp [h]

theorem liftMulDiv_error_cases (mode : Arithmetic.Rounding) (a b : U256) (d : Nat)
    (failure : Failure) (h : liftMulDiv mode a b d = .error failure) :
    failure = .divisionByZero ∨ failure = .quotientOverflow := by
  unfold liftMulDiv at h
  cases hr : Arithmetic.Rounding.mulDiv (w := 256) mode a b d with
  | ok q =>
      simp [hr] at h
  | error e =>
      simp [hr] at h
      have he := rounding_error_div_or_quot mode a b d e hr
      have := ofRoundingFailure_div_or_quot e he
      simpa [h] using this

theorem liftMulDiv_error_iff (mode : Arithmetic.Rounding) (a b : U256) (d : Nat)
    (failure : Failure) :
    liftMulDiv mode a b d = .error failure ↔
      (d = 0 ∧ failure = .divisionByZero) ∨
        ∃ q : Nat, Arithmetic.Rounding.divideNat mode (a.value * b.value) d = .ok q ∧
          2 ^ 256 ≤ q ∧ failure = .quotientOverflow := by
  constructor
  · intro h
    unfold liftMulDiv at h
    cases hr : Arithmetic.Rounding.mulDiv (w := 256) mode a b d with
    | ok q => simp [hr] at h
    | error e =>
        simp [hr] at h
        have hr' : Arithmetic.Rounding.mulDiv (w := 256) mode a b d = .error e := hr
        have hcases := (Arithmetic.Rounding.mulDiv_error_iff (w := 256) mode a b d e).mp hr'
        rcases hcases with ⟨hz, he⟩ | ⟨q, hq, hb, he⟩
        · subst he
          simp [ofRoundingFailure] at h
          exact Or.inl ⟨hz, h.symm⟩
        · subst he
          simp [ofRoundingFailure] at h
          exact Or.inr ⟨q, hq, hb, h.symm⟩
  · intro h
    unfold liftMulDiv
    rcases h with ⟨hz, hf⟩ | ⟨q, hq, hb, hf⟩
    · subst hf
      have : Arithmetic.Rounding.mulDiv (w := 256) mode a b d = .error .divisionByZero := by
        simpa [hz] using
          (Arithmetic.Rounding.mulDiv_zero_denominator (w := 256) mode a b)
      simp [this, ofRoundingFailure]
    · subst hf
      have herr :
          Arithmetic.Rounding.mulDiv (w := 256) mode a b d = .error .quotientOverflow := by
        exact (Arithmetic.Rounding.mulDiv_error_iff (w := 256) mode a b d .quotientOverflow).mpr
          (Or.inr ⟨q, hq, hb, rfl⟩)
      simp [herr, ofRoundingFailure]

/-- P16-TH-FULLMATH-FLOOR: documented floor spec at width 256. -/
theorem mulDiv_ok_iff (a b q d : U256) :
    mulDiv a b d = .ok q ↔
      Arithmetic.Rounding.mulDiv (w := 256) .down a b d.value = .ok q :=
  liftMulDiv_ok_iff .down a b q d.value

theorem mulDiv_error_iff (a b d : U256) (failure : Failure) :
    mulDiv a b d = .error failure ↔
      (d.value = 0 ∧ failure = .divisionByZero) ∨
        ∃ q : Nat, Arithmetic.Rounding.divideNat .down (a.value * b.value) d.value = .ok q ∧
          2 ^ 256 ≤ q ∧ failure = .quotientOverflow :=
  liftMulDiv_error_iff .down a b d.value failure

theorem mulDiv_divisionByZero_iff (a b d : U256) :
    mulDiv a b d = .error .divisionByZero ↔ d.value = 0 := by
  rw [mulDiv_error_iff]
  constructor
  · intro h
    rcases h with h | ⟨_, _, _, hf⟩
    · exact h.1
    · cases hf
  · intro hz
    exact Or.inl ⟨hz, rfl⟩

/-- P16-TH-FULLMATH-CEIL: documented ceiling spec at width 256. -/
theorem mulDivRoundingUp_ok_iff (a b q d : U256) :
    mulDivRoundingUp a b d = .ok q ↔
      Arithmetic.Rounding.mulDiv (w := 256) .up a b d.value = .ok q :=
  liftMulDiv_ok_iff .up a b q d.value

theorem mulDivRoundingUp_error_iff (a b d : U256) (failure : Failure) :
    mulDivRoundingUp a b d = .error failure ↔
      (d.value = 0 ∧ failure = .divisionByZero) ∨
        ∃ q : Nat, Arithmetic.Rounding.divideNat .up (a.value * b.value) d.value = .ok q ∧
          2 ^ 256 ≤ q ∧ failure = .quotientOverflow :=
  liftMulDiv_error_iff .up a b d.value failure

theorem mulDivRoundingUp_divisionByZero_iff (a b d : U256) :
    mulDivRoundingUp a b d = .error .divisionByZero ↔ d.value = 0 := by
  rw [mulDivRoundingUp_error_iff]
  constructor
  · intro h
    rcases h with h | ⟨_, _, _, hf⟩
    · exact h.1
    · cases hf
  · intro hz
    exact Or.inl ⟨hz, rfl⟩

theorem mulDiv_zero_denominator (a b : U256) :
    mulDiv a b ⟨0, by decide⟩ = .error .divisionByZero :=
  (mulDiv_divisionByZero_iff a b ⟨0, by decide⟩).mpr rfl

theorem mulDivRoundingUp_zero_denominator (a b : U256) :
    mulDivRoundingUp a b ⟨0, by decide⟩ = .error .divisionByZero :=
  (mulDivRoundingUp_divisionByZero_iff a b ⟨0, by decide⟩).mpr rfl

end DefiKernel.ConcentratedLiquidity.FullMath
