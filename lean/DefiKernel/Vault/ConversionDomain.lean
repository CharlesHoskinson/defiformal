import DefiKernel.Vault.Conversion

/-! Quantified checked share conversion. Amounts are raw integer units, lifted at scale 1.
Admissibility proves checked multiplication and positive-denominator floor division succeed. -/
namespace DefiKernel.Vault.ConversionDomain
open DefiKernel.Arithmetic

/-- Exactly the successful arithmetic domain: checked product fits and chi is positive. -/
def Admissible (assets : Word 256) (chi : Word 192) : Prop :=
  0 < chi.value ∧ assets.value * RAY < 2 ^ 256

/-- The output bound is derived, not supplied as a successful-result premise. -/
def floorWord (assets : Word 256) (chi : Word 192) (domain : Admissible assets chi) : Word 256 :=
  ⟨assets.value * RAY / chi.value,
    lt_of_le_of_lt (Nat.div_le_self _ _) domain.2⟩

/-- The native executable actually returns the computed floor Word on every admissible input. -/
theorem native_success (assets : Word 256) (chi : Word 192)
    (domain : Admissible assets chi) :
    convertToShares assets chi = .ok (floorWord assets chi domain) := by
  have productBound : assets.value * rayWord.value < 2 ^ 256 := by
    simpa only [rayWord_value] using domain.2
  apply (convertToShares_ok assets chi (floorWord assets chi domain) domain.1 productBound).mpr
  change Rounding.divideNat .down (assets.value * RAY) chi.value =
    .ok (assets.value * RAY / chi.value)
  apply (Rounding.divideNat_down_ok_iff _ _ _).mpr
  exact ⟨domain.1, (Rounding.floor_characterization _ _ _ domain.1).mp rfl⟩

theorem floor_bounds (assets : Word 256) (chi : Word 192)
    (domain : Admissible assets chi) :
    (floorWord assets chi domain).value * chi.value ≤ assets.value * RAY ∧
      assets.value * RAY < ((floorWord assets chi domain).value + 1) * chi.value := by
  exact (Rounding.floor_characterization _ _ _ domain.1).mp rfl

/-- Rational amounts use raw scale 1. Floor rounding is an interval, not unrounded equality. -/
theorem rational_floor_interval (assets : Word 256) (chi : Word 192)
    (domain : Admissible assets chi) :
    ((floorWord assets chi domain).value : ℚ) ≤ (assets.value : ℚ) * RAY / chi.value ∧
      (assets.value : ℚ) * RAY / chi.value < (floorWord assets chi domain).value + 1 := by
  have divided : Rounding.divideNat .down (assets.value * RAY) chi.value =
      .ok (floorWord assets chi domain).value := by
    apply (Rounding.divideNat_down_ok_iff _ _ _).mpr
    exact ⟨domain.1, floor_bounds assets chi domain⟩
  have bounds := Rounding.divideNat_down_rational_error _ _ _ divided
  push_cast at bounds
  constructor <;> linarith

/-- Multiplication failure precedes denominator handling, including when chi is zero. -/
theorem native_overflow (assets : Word 256) (chi : Word 192)
    (overflow : 2 ^ 256 ≤ assets.value * RAY) :
    convertToShares assets chi = .error .mulOverflow := by
  apply convertToShares_mulOverflow
  simpa only [rayWord_value] using overflow

/-- A zero rate is divisionByZero only after the checked product succeeds. -/
theorem native_zero_rate (assets : Word 256) (chi : Word 192)
    (productBound : assets.value * RAY < 2 ^ 256) (zeroRate : chi.value = 0) :
    convertToShares assets chi = .error .divisionByZero := by
  unfold convertToShares
  have bound : assets.value * rayWord.value < 2 ^ 256 := by
    simpa only [rayWord_value] using productBound
  rw [mul_ray_ok assets bound, mapError_ok, zeroRate]
  simp [bind, Except.bind, Except.mapError, ofArith]

/-- Success has exactly the declared domain, including every Word amount and Word rate. -/
theorem successful_iff_admissible (assets : Word 256) (chi : Word 192) :
    (∃ shares, convertToShares assets chi = .ok shares) ↔ Admissible assets chi := by
  constructor
  · rintro ⟨shares, success⟩
    have productBound : assets.value * RAY < 2 ^ 256 := by
      by_contra outside
      rw [native_overflow assets chi (Nat.le_of_not_gt outside)] at success
      cases success
    have positive : 0 < chi.value := by
      by_contra zero
      rw [native_zero_rate assets chi productBound (Nat.eq_zero_of_not_pos zero)] at success
      cases success
    exact ⟨positive, productBound⟩
  · intro domain
    exact ⟨floorWord assets chi domain, native_success assets chi domain⟩

/-- Complete error classification: checked multiplication has precedence over division. -/
theorem native_error_iff (assets : Word 256) (chi : Word 192) (failure : Vault.Failure) :
    convertToShares assets chi = .error failure ↔
      (2 ^ 256 ≤ assets.value * RAY ∧ failure = .mulOverflow) ∨
      (assets.value * RAY < 2 ^ 256 ∧ chi.value = 0 ∧ failure = .divisionByZero) := by
  by_cases productBound : assets.value * RAY < 2 ^ 256
  · by_cases zero : chi.value = 0
    · rw [native_zero_rate assets chi productBound zero]
      constructor
      · intro equality
        exact Or.inr ⟨productBound, zero, (Except.error.inj equality).symm⟩
      · rintro (⟨overflow, _⟩ | ⟨_, _, equality⟩)
        · exact False.elim (Nat.not_le_of_gt productBound overflow)
        · subst failure
          rfl
    · rw [native_success assets chi ⟨Nat.pos_of_ne_zero zero, productBound⟩]
      constructor
      · intro impossible
        cases impossible
      · rintro (⟨overflow, _⟩ | ⟨_, zeroRate, _⟩)
        · exact False.elim (Nat.not_le_of_gt productBound overflow)
        · exact False.elim (zero zeroRate)
  · rw [native_overflow assets chi (Nat.le_of_not_gt productBound)]
    constructor
    · intro equality
      exact Or.inl ⟨Nat.le_of_not_gt productBound, (Except.error.inj equality).symm⟩
    · rintro (⟨_, equality⟩ | ⟨bound, _, _⟩)
      · subst failure
        rfl
      · exact False.elim (productBound bound)

/-- No successful checked product can subsequently overflow a floor quotient. -/
theorem no_quotient_overflow (assets : Word 256) (chi : Word 192) :
    convertToShares assets chi ≠ .error .quotientOverflow := by
  intro failure
  rcases (native_error_iff assets chi .quotientOverflow).mp failure with ⟨_, impossible⟩ |
    ⟨_, _, impossible⟩ <;> cases impossible

end DefiKernel.Vault.ConversionDomain
