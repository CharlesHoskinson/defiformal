import DefiKernel.Arithmetic.Word

/-! Checked addition, subtraction and multiplication without modular wraparound. -/
namespace DefiKernel.Arithmetic.Operations

variable {w : Nat}

def add (a b : Word w) : Except Failure (Word w) :=
  Word.checked .addOverflow (a.value + b.value)

def sub (a b : Word w) : Except Failure (Word w) :=
  if b.value ≤ a.value then Word.checked .subUnderflow (a.value - b.value)
  else .error .subUnderflow

def mul (a b : Word w) : Except Failure (Word w) :=
  Word.checked .mulOverflow (a.value * b.value)

-- BEGIN PROOFS

@[simp] theorem add_ok_iff (a b q : Word w) :
    add a b = .ok q ↔ a.value + b.value = q.value := Word.checked_ok_iff _ _ _

@[simp] theorem add_error_iff (a b : Word w) (failure : Failure) :
    add a b = .error failure ↔ 2^w ≤ a.value + b.value ∧ failure = .addOverflow := by
  rw [add, Word.checked_error_iff]
  exact and_congr_right fun _ ↦ eq_comm

@[simp] theorem mul_ok_iff (a b q : Word w) :
    mul a b = .ok q ↔ a.value * b.value = q.value := Word.checked_ok_iff _ _ _

@[simp] theorem mul_error_iff (a b : Word w) (failure : Failure) :
    mul a b = .error failure ↔ 2^w ≤ a.value * b.value ∧ failure = .mulOverflow := by
  rw [mul, Word.checked_error_iff]
  exact and_congr_right fun _ ↦ eq_comm

theorem sub_difference_bound (a b : Word w) : a.value - b.value < 2^w :=
  lt_of_le_of_lt (Nat.sub_le _ _) a.bound

theorem sub_checked_ne_error (a b : Word w) (failure : Failure) :
    Word.checked (w := w) .subUnderflow (a.value - b.value) ≠ .error failure := by
  intro h
  exact Nat.not_le_of_lt (sub_difference_bound a b)
    ((Word.checked_error_iff _ _ _).mp h).1

@[simp] theorem sub_ok_iff (a b q : Word w) :
    sub a b = .ok q ↔ b.value ≤ a.value ∧ a.value - b.value = q.value := by
  unfold sub
  by_cases h : b.value ≤ a.value <;> simp [h]

@[simp] theorem sub_error_iff (a b : Word w) (failure : Failure) :
    sub a b = .error failure ↔ a.value < b.value ∧ failure = .subUnderflow := by
  unfold sub
  split
  · simp_all only [sub_checked_ne_error, false_iff, not_and]
    omega
  · simp_all [eq_comm]

theorem add_mono (a a' b q q' : Word w) (h : a.value ≤ a'.value)
    (hq : add a b = .ok q) (hq' : add a' b = .ok q') : q.value ≤ q'.value := by
  have := (add_ok_iff _ _ _).mp hq
  have := (add_ok_iff _ _ _).mp hq'
  omega

theorem mul_mono (a a' b q q' : Word w) (h : a.value ≤ a'.value)
    (hq : mul a b = .ok q) (hq' : mul a' b = .ok q') : q.value ≤ q'.value := by
  rw [← (mul_ok_iff _ _ _).mp hq, ← (mul_ok_iff _ _ _).mp hq']
  exact Nat.mul_le_mul_right _ h

theorem sub_mono (a a' b q q' : Word w) (h : a.value ≤ a'.value)
    (hq : sub a b = .ok q) (hq' : sub a' b = .ok q') : q.value ≤ q'.value := by
  have := (sub_ok_iff _ _ _).mp hq
  have := (sub_ok_iff _ _ _).mp hq'
  omega

theorem sub_antitone (a b b' q q' : Word w) (h : b.value ≤ b'.value)
    (hq : sub a b = .ok q) (hq' : sub a b' = .ok q') : q'.value ≤ q.value := by
  have := (sub_ok_iff _ _ _).mp hq
  have := (sub_ok_iff _ _ _).mp hq'
  omega

theorem add_comm (a b : Word w) : add a b = add b a := by
  simp only [add, Nat.add_comm]

theorem mul_comm (a b : Word w) : mul a b = mul b a := by
  simp only [mul, Nat.mul_comm]

theorem add_zero (a z : Word w) (hz : z.value = 0) : add a z = .ok a := by
  simp [hz]

theorem sub_zero (a z : Word w) (hz : z.value = 0) : sub a z = .ok a := by
  simp [hz]

theorem sub_self (a z : Word w) (hz : z.value = 0) : sub a a = .ok z := by
  simp [hz]

theorem mul_zero (a z : Word w) (hz : z.value = 0) : mul a z = .ok z := by
  simp [hz]

theorem mul_one (a one : Word w) (h : one.value = 1) : mul a one = .ok a := by
  simp [h]

theorem add_mono_right (a b b' q q' : Word w) (h : b.value ≤ b'.value)
    (hq : add a b = .ok q) (hq' : add a b' = .ok q') : q.value ≤ q'.value := by
  exact add_mono b b' a q q' h ((add_comm _ _).trans hq) ((add_comm _ _).trans hq')

theorem mul_mono_right (a b b' q q' : Word w) (h : b.value ≤ b'.value)
    (hq : mul a b = .ok q) (hq' : mul a b' = .ok q') : q.value ≤ q'.value := by
  exact mul_mono b b' a q q' h ((mul_comm _ _).trans hq) ((mul_comm _ _).trans hq')

end DefiKernel.Arithmetic.Operations
