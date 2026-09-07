import DefiKernel.Arithmetic.Word
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-! Directed natural division and checked full-product multiplication/division.
The independent specifications expose floor inequalities and ceiling leastness. -/
namespace DefiKernel.Arithmetic.Rounding

variable {w : Nat}

def divideNat (mode : Arithmetic.Rounding) (numerator denominator : Nat) : Except Failure Nat :=
  if denominator = 0 then .error .divisionByZero
  else .ok (match mode with
    | .down => numerator / denominator
    | .up => numerator / denominator + (if numerator % denominator = 0 then 0 else 1))

def mulDiv (mode : Arithmetic.Rounding) (a b : Word w) (denominator : Nat) :
    Except Failure (Word w) := do
  let q ← divideNat mode (a.value * b.value) denominator
  Word.checked .quotientOverflow q

-- BEGIN PROOFS

theorem floor_characterization (n d q : Nat) (positive : 0 < d) :
    n / d = q ↔ q * d ≤ n ∧ n < (q + 1) * d := by
  constructor
  · rintro rfl
    exact ⟨Nat.div_mul_le_self n d, (Nat.div_lt_iff_lt_mul positive).mp (Nat.lt_succ_self _)⟩
  · rintro ⟨lo, hi⟩
    have := (Nat.le_div_iff_mul_le positive).mpr lo
    have := (Nat.div_lt_iff_lt_mul positive).mpr hi
    omega

theorem ceil_characterization (n d q : Nat) (positive : 0 < d) :
    n / d + (if n % d = 0 then 0 else 1) = q ↔
      n ≤ q * d ∧ ∀ k : Nat, n ≤ k * d → q ≤ k := by
  have base : n ≤ (n / d + (if n % d = 0 then 0 else 1)) * d ∧
      ∀ k : Nat, n ≤ k * d → n / d + (if n % d = 0 then 0 else 1) ≤ k := by
    have decomposition := Nat.div_add_mod' n d
    have remainder := Nat.mod_lt n positive
    by_cases exactDivision : n % d = 0
    · simp only [exactDivision, ↓reduceIte, Nat.add_zero]
      constructor
      · omega
      · intro k hk
        exact Nat.div_le_of_le_mul (by simpa [Nat.mul_comm] using hk)
    · simp only [exactDivision, ↓reduceIte]
      constructor
      · have := (floor_characterization n d (n / d) positive).mp rfl
        omega
      · intro k hk
        by_contra hn
        have small : k ≤ n / d := by omega
        have product := Nat.mul_le_mul_right d small
        omega
  constructor
  · rintro rfl; exact base
  · rintro ⟨lo, least⟩
    exact Nat.le_antisymm (base.2 q lo) (least _ base.1)

@[simp] theorem divideNat_error_iff (mode : Arithmetic.Rounding) (n d : Nat)
    (failure : Failure) :
    divideNat mode n d = .error failure ↔ d = 0 ∧ failure = .divisionByZero := by
  unfold divideNat
  split <;> simp_all [eq_comm]

@[simp] theorem divideNat_down_ok_iff (n d q : Nat) :
    divideNat .down n d = .ok q ↔ 0 < d ∧ q * d ≤ n ∧ n < (q + 1) * d := by
  by_cases hz : d = 0
  · simp [divideNat, hz]
  · have hp : 0 < d := Nat.pos_of_ne_zero hz
    simp only [divideNat, hz, ↓reduceIte, Except.ok.injEq, hp, true_and]
    exact floor_characterization n d q hp

@[simp] theorem divideNat_up_ok_iff (n d q : Nat) :
    divideNat .up n d = .ok q ↔
      0 < d ∧ n ≤ q * d ∧ ∀ k : Nat, n ≤ k * d → q ≤ k := by
  by_cases hz : d = 0
  · simp [divideNat, hz]
  · have hp : 0 < d := Nat.pos_of_ne_zero hz
    simp only [divideNat, hz, ↓reduceIte, Except.ok.injEq, hp, true_and]
    exact ceil_characterization n d q hp

/-- The fee bound follows from floor inequalities or ceiling leastness. -/
theorem divideNat_le (mode : Arithmetic.Rounding) (n d q k : Nat)
    (success : divideNat mode n d = .ok q) (bound : n ≤ k * d) : q ≤ k := by
  cases mode with
  | down =>
    obtain ⟨hp, hlo, hhi⟩ := (divideNat_down_ok_iff n d q).mp success
    have hq := (floor_characterization n d q hp).mpr ⟨hlo, hhi⟩
    rw [← hq]
    exact Nat.div_le_of_le_mul (by simpa [Nat.mul_comm] using bound)
  | up => exact ((divideNat_up_ok_iff n d q).mp success).2.2 k bound

theorem divideNat_exists_iff (mode : Arithmetic.Rounding) (n d : Nat) :
    (∃ q, divideNat mode n d = .ok q) ↔ 0 < d := by
  unfold divideNat
  by_cases hz : d = 0 <;> simp [hz, Nat.pos_iff_ne_zero]

@[simp] theorem divideNat_zero_denominator (mode : Arithmetic.Rounding) (n : Nat) :
    divideNat mode n 0 = .error .divisionByZero := by simp [divideNat]

theorem divideNat_zero (mode : Arithmetic.Rounding) (d : Nat) (positive : 0 < d) :
    divideNat mode 0 d = .ok 0 := by
  cases mode <;> simp [divideNat, Nat.ne_of_gt positive]

theorem divideNat_exact (mode : Arithmetic.Rounding) (n d : Nat) (positive : 0 < d)
    (divisible : d ∣ n) : divideNat mode n d = .ok (n / d) := by
  cases mode <;> simp [divideNat, Nat.ne_of_gt positive, Nat.mod_eq_zero_of_dvd divisible]

theorem divideNat_up_zero_iff (n d : Nat) :
    divideNat .up n d = .ok 0 ↔ 0 < d ∧ n = 0 := by
  rw [divideNat_up_ok_iff]
  simp

theorem divideNat_rounding_gap (n d down up : Nat)
    (floorSuccess : divideNat .down n d = .ok down)
    (ceilSuccess : divideNat .up n d = .ok up) :
    up = down + (if n % d = 0 then 0 else 1) := by
  have positive := ((divideNat_down_ok_iff n d down).mp floorSuccess).1
  have floorValue : n / d = down := by
    simpa [divideNat, Nat.ne_of_gt positive] using floorSuccess
  have ceilValue : n / d + (if n % d = 0 then 0 else 1) = up := by
    simpa [divideNat, Nat.ne_of_gt positive] using ceilSuccess
  rw [← ceilValue, floorValue]

theorem divideNat_equal_iff_dvd (n d down up : Nat)
    (floorSuccess : divideNat .down n d = .ok down)
    (ceilSuccess : divideNat .up n d = .ok up) : down = up ↔ d ∣ n := by
  rw [divideNat_rounding_gap n d down up floorSuccess ceilSuccess, Nat.dvd_iff_mod_eq_zero]
  split <;> omega

theorem divideNat_mono (mode : Arithmetic.Rounding) (n n' d q q' : Nat)
    (ordered : n ≤ n') (first : divideNat mode n d = .ok q)
    (second : divideNat mode n' d = .ok q') : q ≤ q' := by
  cases mode with
  | down =>
    obtain ⟨hp, hlo, hhi⟩ := (divideNat_down_ok_iff n d q).mp first
    obtain ⟨_, hlo', hhi'⟩ := (divideNat_down_ok_iff n' d q').mp second
    rw [← (floor_characterization n d q hp).mpr ⟨hlo, hhi⟩,
      ← (floor_characterization n' d q' hp).mpr ⟨hlo', hhi'⟩]
    exact Nat.div_le_div_right ordered
  | up =>
    have firstSpec := (divideNat_up_ok_iff n d q).mp first
    have secondSpec := (divideNat_up_ok_iff n' d q').mp second
    exact firstSpec.2.2 q' (ordered.trans secondSpec.2.1)

theorem divideNat_down_rational_error (n d q : Nat)
    (success : divideNat .down n d = .ok q) :
    0 ≤ (n : ℚ) / (d : ℚ) - (q : ℚ) ∧ (n : ℚ) / (d : ℚ) - (q : ℚ) < 1 := by
  obtain ⟨hp, hlo, hhi⟩ := (divideNat_down_ok_iff n d q).mp success
  have hd : (0 : ℚ) < d := by exact_mod_cast hp
  have lo : (q : ℚ) * d ≤ n := by exact_mod_cast hlo
  have hi : (n : ℚ) < ((q : ℚ) + 1) * d := by exact_mod_cast hhi
  have := (le_div_iff₀ hd).mpr lo
  have := (div_lt_iff₀ hd).mpr hi
  constructor <;> linarith

theorem divideNat_up_rational_error (n d q : Nat)
    (success : divideNat .up n d = .ok q) :
    0 ≤ (q : ℚ) - (n : ℚ) / (d : ℚ) ∧ (q : ℚ) - (n : ℚ) / (d : ℚ) < 1 := by
  obtain ⟨hp, upper, least⟩ := (divideNat_up_ok_iff n d q).mp success
  have hd : (0 : ℚ) < d := by exact_mod_cast hp
  have up : (n : ℚ) ≤ (q : ℚ) * d := by exact_mod_cast upper
  have leq := (div_le_iff₀ hd).mpr up
  by_cases hz : q = 0
  · have hn : n = 0 := by simpa [hz] using upper
    simp [hz, hn]
  · have hq : 1 ≤ q := by omega
    have prev : (q - 1) * d < n := by
      by_contra hn
      have := least (q - 1) (by omega)
      omega
    have prevQ : ((q - 1 : Nat) : ℚ) * d < n := by exact_mod_cast prev
    rw [Nat.cast_sub hq, Nat.cast_one] at prevQ
    have := (lt_div_iff₀ hd).mpr prevQ
    constructor <;> linarith

@[simp] theorem mulDiv_ok_iff (mode : Arithmetic.Rounding) (a b q : Word w) (d : Nat) :
    mulDiv mode a b d = .ok q ↔ divideNat mode (a.value * b.value) d = .ok q.value := by
  unfold mulDiv
  cases hd : divideNat mode (a.value * b.value) d <;> simp [bind, Except.bind]

@[simp] theorem mulDiv_down_ok_iff (a b q : Word w) (d : Nat) :
    mulDiv .down a b d = .ok q ↔
      0 < d ∧ q.value * d ≤ a.value * b.value ∧ a.value * b.value < (q.value + 1) * d := by
  rw [mulDiv_ok_iff, divideNat_down_ok_iff]

@[simp] theorem mulDiv_up_ok_iff (a b q : Word w) (d : Nat) :
    mulDiv .up a b d = .ok q ↔ 0 < d ∧ a.value * b.value ≤ q.value * d ∧
      ∀ k : Nat, a.value * b.value ≤ k * d → q.value ≤ k := by
  rw [mulDiv_ok_iff, divideNat_up_ok_iff]

theorem mulDiv_error_iff (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat)
    (failure : Failure) :
    mulDiv mode a b d = .error failure ↔
      (d = 0 ∧ failure = .divisionByZero) ∨
      ∃ q : Nat, divideNat mode (a.value * b.value) d = .ok q ∧
        2^w ≤ q ∧ failure = .quotientOverflow := by
  cases hd : divideNat mode (a.value * b.value) d with
  | error reason =>
    obtain ⟨hz, hr⟩ := (divideNat_error_iff _ _ _ _).mp hd
    simp [mulDiv, bind, Except.bind, hz, hr, eq_comm]
  | ok q =>
    have hp : 0 < d := (divideNat_exists_iff _ _ _).mp ⟨q, hd⟩
    simp only [mulDiv, hd, bind, Except.bind, Word.checked_error_iff]
    simp [Nat.ne_of_gt hp, eq_comm]

theorem mulDiv_exists_iff (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat) :
    (∃ q : Word w, mulDiv mode a b d = .ok q) ↔
      ∃ n : Nat, divideNat mode (a.value * b.value) d = .ok n ∧ n < 2^w := by
  constructor
  · rintro ⟨q, hq⟩
    exact ⟨q.value, (mulDiv_ok_iff _ _ _ _ _).mp hq, q.bound⟩
  · rintro ⟨n, hn, bound⟩
    exact ⟨⟨n, bound⟩, (mulDiv_ok_iff _ _ _ _ _).mpr hn⟩

@[simp] theorem mulDiv_zero_denominator (mode : Arithmetic.Rounding) (a b : Word w) :
    mulDiv mode a b 0 = .error .divisionByZero := by simp [mulDiv, bind, Except.bind]

theorem mulDiv_error_cases (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat)
    (failure : Failure) (refused : mulDiv mode a b d = .error failure) :
    failure = .divisionByZero ∨ failure = .quotientOverflow := by
  rcases (mulDiv_error_iff _ _ _ _ _).mp refused with h | ⟨q, hq, hb, hf⟩
  · exact Or.inl h.2
  · exact Or.inr hf

theorem mulDiv_quotientOverflow_iff (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat) :
    mulDiv mode a b d = .error .quotientOverflow ↔
      0 < d ∧ ∃ q : Nat, divideNat mode (a.value * b.value) d = .ok q ∧ 2^w ≤ q := by
  rw [mulDiv_error_iff]
  constructor
  · rintro (h | ⟨q, hq, hb, _⟩)
    · cases h.2
    · exact ⟨(divideNat_exists_iff _ _ _).mp ⟨q, hq⟩, q, hq, hb⟩
  · rintro ⟨_, q, hq, hb⟩
    exact Or.inr ⟨q, hq, hb, rfl⟩

theorem mulDiv_mono_left (mode : Arithmetic.Rounding) (a a' b q q' : Word w) (d : Nat)
    (_positive : 0 < d) (ordered : a.value ≤ a'.value)
    (first : mulDiv mode a b d = .ok q) (second : mulDiv mode a' b d = .ok q') :
    q.value ≤ q'.value :=
  divideNat_mono mode _ _ d _ _ (Nat.mul_le_mul_right b.value ordered)
    ((mulDiv_ok_iff _ _ _ _ _).mp first) ((mulDiv_ok_iff _ _ _ _ _).mp second)

theorem mulDiv_mono_right (mode : Arithmetic.Rounding) (a b b' q q' : Word w) (d : Nat)
    (_positive : 0 < d) (ordered : b.value ≤ b'.value)
    (first : mulDiv mode a b d = .ok q) (second : mulDiv mode a b' d = .ok q') :
    q.value ≤ q'.value :=
  divideNat_mono mode _ _ d _ _ (Nat.mul_le_mul_left a.value ordered)
    ((mulDiv_ok_iff _ _ _ _ _).mp first) ((mulDiv_ok_iff _ _ _ _ _).mp second)

theorem mulDiv_down_error_iff (a b : Word w) (d : Nat) (failure : Failure) :
    mulDiv .down a b d = .error failure ↔
      (d = 0 ∧ failure = .divisionByZero) ∨
      ∃ q : Nat, (0 < d ∧ q * d ≤ a.value * b.value ∧ a.value * b.value < (q + 1) * d) ∧
        2^w ≤ q ∧ failure = .quotientOverflow := by
  simp only [mulDiv_error_iff, divideNat_down_ok_iff]

theorem mulDiv_up_error_iff (a b : Word w) (d : Nat) (failure : Failure) :
    mulDiv .up a b d = .error failure ↔
      (d = 0 ∧ failure = .divisionByZero) ∨
      ∃ q : Nat, (0 < d ∧ a.value * b.value ≤ q * d ∧
        ∀ k : Nat, a.value * b.value ≤ k * d → q ≤ k) ∧
        2^w ≤ q ∧ failure = .quotientOverflow := by
  simp only [mulDiv_error_iff, divideNat_up_ok_iff]

theorem mulDiv_divisionByZero_iff (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat) :
    mulDiv mode a b d = .error .divisionByZero ↔ d = 0 := by
  simp [mulDiv_error_iff]

theorem mulDiv_zero_left (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat)
    (positive : 0 < d) (zero : a.value = 0) : mulDiv mode a b d = .ok a := by
  rw [mulDiv_ok_iff, zero, Nat.zero_mul]
  exact divideNat_zero mode d positive

theorem mulDiv_zero_right (mode : Arithmetic.Rounding) (a b : Word w) (d : Nat)
    (positive : 0 < d) (zero : b.value = 0) : mulDiv mode a b d = .ok b := by
  rw [mulDiv_ok_iff, zero, Nat.mul_zero]
  exact divideNat_zero mode d positive

theorem mulDiv_width_zero (mode : Arithmetic.Rounding) (a b : Word 0) (d : Nat)
    (positive : 0 < d) : mulDiv mode a b d = .ok a :=
  mulDiv_zero_left mode a b d positive (Word.width_zero a)

theorem mulDiv_exact_iff (mode : Arithmetic.Rounding) (a b q : Word w) (d : Nat)
    (positive : 0 < d) (divisible : d ∣ a.value * b.value) :
    mulDiv mode a b d = .ok q ↔ a.value * b.value / d = q.value := by
  rw [mulDiv_ok_iff, divideNat_exact mode _ d positive divisible, Except.ok.injEq]

theorem mulDiv_rounding_gap (a b down up : Word w) (d : Nat)
    (floorSuccess : mulDiv .down a b d = .ok down)
    (ceilSuccess : mulDiv .up a b d = .ok up) :
    up.value = down.value + (if (a.value * b.value) % d = 0 then 0 else 1) :=
  divideNat_rounding_gap _ d _ _ ((mulDiv_ok_iff _ _ _ _ _).mp floorSuccess)
    ((mulDiv_ok_iff _ _ _ _ _).mp ceilSuccess)

theorem mulDiv_equal_iff_dvd (a b down up : Word w) (d : Nat)
    (floorSuccess : mulDiv .down a b d = .ok down)
    (ceilSuccess : mulDiv .up a b d = .ok up) : down = up ↔ d ∣ a.value * b.value := by
  rw [← divideNat_equal_iff_dvd _ d down.value up.value
    ((mulDiv_ok_iff _ _ _ _ _).mp floorSuccess) ((mulDiv_ok_iff _ _ _ _ _).mp ceilSuccess)]
  exact ⟨fun h ↦ congrArg Word.value h, Word.ext⟩

theorem mulDiv_down_rational_error (a b q : Word w) (d : Nat)
    (success : mulDiv .down a b d = .ok q) :
    0 ≤ (a.value : ℚ) * (b.value : ℚ) / (d : ℚ) - (q.value : ℚ) ∧
      (a.value : ℚ) * (b.value : ℚ) / (d : ℚ) - (q.value : ℚ) < 1 := by
  simpa only [Nat.cast_mul] using
    divideNat_down_rational_error _ d _ ((mulDiv_ok_iff _ _ _ _ _).mp success)

theorem mulDiv_up_rational_error (a b q : Word w) (d : Nat)
    (success : mulDiv .up a b d = .ok q) :
    0 ≤ (q.value : ℚ) - (a.value : ℚ) * (b.value : ℚ) / (d : ℚ) ∧
      (q.value : ℚ) - (a.value : ℚ) * (b.value : ℚ) / (d : ℚ) < 1 := by
  simpa only [Nat.cast_mul] using
    divideNat_up_rational_error _ d _ ((mulDiv_ok_iff _ _ _ _ _).mp success)

theorem mulDiv_up_value_zero_iff (a b q : Word w) (d : Nat)
    (success : mulDiv .up a b d = .ok q) : q.value = 0 ↔ a.value * b.value = 0 := by
  obtain ⟨_, upper, least⟩ := (mulDiv_up_ok_iff a b q d).mp success
  constructor
  · intro zero
    simpa [zero] using upper
  · intro zero
    have := least 0 (by simp [zero])
    omega

end DefiKernel.Arithmetic.Rounding
