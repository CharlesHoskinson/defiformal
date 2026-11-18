import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
import DefiKernel.AMM.Rational

/-! Bounded unsigned reserves/input/rate words, widened exact products, one final output floor.
The fee is retained in the actual input reserve. Zero output is permitted; reversing zero as a
positive-input swap refuses. This is a mathematical Word API, not EVM256 source refinement. -/
namespace DefiKernel.AMM.Checked
open DefiKernel.Arithmetic

structure Pool where
  reserveX : Word 256
  reserveY : Word 256
  deriving DecidableEq, Repr

structure Fee where
  numerator : Word 256
  denominator : Word 256
  deriving DecidableEq, Repr

structure Swap where
  output : Word 256
  post : Pool
  deriving DecidableEq, Repr

inductive Refusal where
  | badReserve | badAmount | badFee
  | arithmetic (reason : Arithmetic.Failure)
  deriving DecidableEq, Repr

/-- Each actual product is carried at its full proven width. No modular multiplication. -/
theorem product_bound {m n : Nat} (a : Word m) (b : Word n) :
    a.value * b.value < 2 ^ (m+n) := by
  simpa only [pow_add] using Nat.mul_lt_mul'' a.bound b.bound

def feeDifference (fee : Fee) : Word 256 :=
  ⟨fee.denominator.value - fee.numerator.value,
    lt_of_le_of_lt (Nat.sub_le _ _) fee.denominator.bound⟩

def wideMul {m n : Nat} (a : Word m) (b : Word n) : Word (m+n) :=
  ⟨a.value * b.value, product_bound a b⟩

def wideAdd {w : Nat} (a b : Word w) : Word (w+1) :=
  ⟨a.value + b.value, by
    calc
      _ < 2 ^ w + 2 ^ w := Nat.add_lt_add a.bound b.bound
      _ = 2 ^ (w+1) := (Nat.mul_two (2 ^ w)).symm.trans (pow_succ (2 : Nat) w).symm⟩

def weightedInput (amount : Word 256) (fee : Fee) : Word 512 :=
  wideMul amount (feeDifference fee)

def scaledReserve (pool : Pool) (fee : Fee) : Word 512 :=
  wideMul pool.reserveX fee.denominator

def denominator (pool : Pool) (amount : Word 256) (fee : Fee) : Word 513 :=
  wideAdd (scaledReserve pool fee) (weightedInput amount fee)

def numerator (pool : Pool) (amount : Word 256) (fee : Fee) : Word 768 :=
  wideMul pool.reserveY (weightedInput amount fee)

/-- Guard priority: zero reserves, zero input, invalid fee pair, reserve-add overflow.
The only rounding is the final numerator/denominator floor; fee itself is never rounded first. -/
def swapPool (pool : Pool) (amount : Word 256) (fee : Fee) : Except Refusal Swap := do
  if pool.reserveX.value = 0 ∨ pool.reserveY.value = 0 then throw .badReserve
  if amount.value = 0 then throw .badAmount
  if ¬ fee.numerator.value < fee.denominator.value then throw .badFee
  let postX ← (Operations.add pool.reserveX amount).mapError Refusal.arithmetic
  let quotient ← (Rounding.divideNat .down (numerator pool amount fee).value
    (denominator pool amount fee).value).mapError Refusal.arithmetic
  let output ← (Word.checked .quotientOverflow quotient).mapError Refusal.arithmetic
  let postY ← (Operations.sub pool.reserveY output).mapError Refusal.arithmetic
  return ⟨output, ⟨postX, postY⟩⟩

/-- Full success domain: native input guards and the actual retained-input reserve capacity. -/
structure Admissible (pool : Pool) (amount : Word 256) (fee : Fee) : Prop where
  reserveX_pos : 0 < pool.reserveX.value
  reserveY_pos : 0 < pool.reserveY.value
  amount_pos : 0 < amount.value
  fee_valid : fee.numerator.value < fee.denominator.value
  reserve_fit : pool.reserveX.value + amount.value < 2 ^ 256

def floorValue (pool : Pool) (amount : Word 256) (fee : Fee) : Nat :=
  (numerator pool amount fee).value / (denominator pool amount fee).value

theorem denominator_pos (pool : Pool) (amount : Word 256) (fee : Fee)
    (hx : 0 < pool.reserveX.value) (hf : fee.numerator.value < fee.denominator.value) :
    0 < (denominator pool amount fee).value := by
  have hd : 0 < fee.denominator.value := lt_of_le_of_lt (Nat.zero_le _) hf
  have product := Nat.mul_pos hx hd
  change 0 < pool.reserveX.value * fee.denominator.value +
    amount.value * (fee.denominator.value - fee.numerator.value)
  omega

/-- Output fits because the positive scaled reserve makes the denominator larger than input. -/
theorem floor_lt_reserve (pool : Pool) (amount : Word 256) (fee : Fee)
    (hx : 0 < pool.reserveX.value) (hy : 0 < pool.reserveY.value)
    (hf : fee.numerator.value < fee.denominator.value) :
    floorValue pool amount fee < pool.reserveY.value := by
  have hd : 0 < fee.denominator.value := lt_of_le_of_lt (Nat.zero_le _) hf
  have product := Nat.mul_pos hx hd
  have gap : (weightedInput amount fee).value < (denominator pool amount fee).value := by
    change amount.value * (fee.denominator.value - fee.numerator.value) <
      pool.reserveX.value * fee.denominator.value +
        amount.value * (fee.denominator.value - fee.numerator.value)
    omega
  exact (Nat.div_lt_iff_lt_mul (denominator_pos pool amount fee hx hf)).mpr
    (Nat.mul_lt_mul_of_pos_left gap hy)

def floorOutput (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) : Word 256 :=
  ⟨floorValue pool amount fee,
    lt_trans (floor_lt_reserve pool amount fee domain.reserveX_pos domain.reserveY_pos
      domain.fee_valid) pool.reserveY.bound⟩

def computed (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) : Swap :=
  ⟨floorOutput pool amount fee domain,
    ⟨⟨pool.reserveX.value + amount.value, domain.reserve_fit⟩,
      ⟨pool.reserveY.value - floorValue pool amount fee,
        lt_of_le_of_lt (Nat.sub_le _ _) pool.reserveY.bound⟩⟩⟩

/-- Every admissible input actually succeeds; no successful-output or output-bound premise. -/
theorem success (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    swapPool pool amount fee = .ok (computed pool amount fee domain) := by
  have add : Operations.add pool.reserveX amount =
      .ok (computed pool amount fee domain).post.reserveX :=
    (Operations.add_ok_iff _ _ _).mpr rfl
  have divided : Rounding.divideNat .down (numerator pool amount fee).value
      (denominator pool amount fee).value = .ok (floorValue pool amount fee) := by
    simp only [Rounding.divideNat, Nat.ne_of_gt
      (denominator_pos pool amount fee domain.reserveX_pos domain.fee_valid),
      if_false, floorValue]
  have checked : Word.checked (w := 256) .quotientOverflow (floorValue pool amount fee) =
      .ok (floorOutput pool amount fee domain) := (Word.checked_ok_iff _ _ _).mpr rfl
  have sub : Operations.sub pool.reserveY (floorOutput pool amount fee domain) =
      .ok (computed pool amount fee domain).post.reserveY :=
    (Operations.sub_ok_iff _ _ _).mpr ⟨le_of_lt (floor_lt_reserve pool amount fee
      domain.reserveX_pos domain.reserveY_pos domain.fee_valid), rfl⟩
  simp [swapPool, Nat.ne_of_gt domain.reserveX_pos, Nat.ne_of_gt domain.reserveY_pos,
    Nat.ne_of_gt domain.amount_pos, domain.fee_valid, add, divided, checked, sub,
    Except.mapError, bind, Except.bind, pure, Except.pure, computed]

theorem bad_reserve (pool : Pool) (amount : Word 256) (fee : Fee)
    (invalid : pool.reserveX.value = 0 ∨ pool.reserveY.value = 0) :
    swapPool pool amount fee = .error .badReserve := by
  simp [swapPool, invalid, bind, Except.bind]
  rfl

theorem bad_amount (pool : Pool) (amount : Word 256) (fee : Fee)
    (hx : 0 < pool.reserveX.value) (hy : 0 < pool.reserveY.value)
    (invalid : amount.value = 0) : swapPool pool amount fee = .error .badAmount := by
  simp [swapPool, Nat.ne_of_gt hx, Nat.ne_of_gt hy, invalid, bind, Except.bind]
  rfl

theorem bad_fee (pool : Pool) (amount : Word 256) (fee : Fee)
    (hx : 0 < pool.reserveX.value) (hy : 0 < pool.reserveY.value)
    (hd : 0 < amount.value) (invalid : ¬fee.numerator.value < fee.denominator.value) :
    swapPool pool amount fee = .error .badFee := by
  simp [swapPool, Nat.ne_of_gt hx, Nat.ne_of_gt hy, Nat.ne_of_gt hd, invalid, bind, Except.bind]
  rfl

theorem reserve_overflow (pool : Pool) (amount : Word 256) (fee : Fee)
    (hx : 0 < pool.reserveX.value) (hy : 0 < pool.reserveY.value)
    (hd : 0 < amount.value) (hf : fee.numerator.value < fee.denominator.value)
    (overflow : 2 ^ 256 ≤ pool.reserveX.value + amount.value) :
    swapPool pool amount fee = .error (.arithmetic .addOverflow) := by
  have rejected : Operations.add pool.reserveX amount = .error Arithmetic.Failure.addOverflow :=
    (Operations.add_error_iff _ _ _).mpr ⟨overflow, rfl⟩
  simp [swapPool, Nat.ne_of_gt hx, Nat.ne_of_gt hy, Nat.ne_of_gt hd, hf, rejected,
    Except.mapError, bind, Except.bind]

theorem exists_success_iff (pool : Pool) (amount : Word 256) (fee : Fee) :
    (∃ result, swapPool pool amount fee = .ok result) ↔ Admissible pool amount fee := by
  constructor
  · rintro ⟨result, executed⟩
    have hx : 0 < pool.reserveX.value := by
      by_contra invalid
      have rejected := bad_reserve pool amount fee (.inl (Nat.eq_zero_of_not_pos invalid))
      rw [rejected] at executed
      cases executed
    have hy : 0 < pool.reserveY.value := by
      by_contra invalid
      have rejected := bad_reserve pool amount fee (.inr (Nat.eq_zero_of_not_pos invalid))
      rw [rejected] at executed
      cases executed
    have hd : 0 < amount.value := by
      by_contra invalid
      have rejected := bad_amount pool amount fee hx hy (Nat.eq_zero_of_not_pos invalid)
      rw [rejected] at executed
      cases executed
    have hf : fee.numerator.value < fee.denominator.value := by
      by_contra invalid
      rw [bad_fee pool amount fee hx hy hd invalid] at executed
      cases executed
    have fit : pool.reserveX.value + amount.value < 2 ^ 256 := by
      by_contra invalid
      rw [reserve_overflow pool amount fee hx hy hd hf (Nat.le_of_not_gt invalid)] at executed
      cases executed
    exact ⟨hx, hy, hd, hf, fit⟩
  · intro domain
    exact ⟨computed pool amount fee domain, success pool amount fee domain⟩

def rationalPool (pool : Pool) : Rational.Pool :=
  ⟨pool.reserveX.value, pool.reserveY.value⟩

def rationalFee (fee : Fee) : ℚ := (fee.numerator.value : ℚ) / fee.denominator.value

theorem rational_fee_valid (fee : Fee) (valid : fee.numerator.value < fee.denominator.value) :
    0 ≤ rationalFee fee ∧ rationalFee fee < 1 := by
  have denPos : (0 : ℚ) < fee.denominator.value := by
    exact_mod_cast lt_of_le_of_lt (Nat.zero_le _) valid
  have feeLt : (fee.numerator.value : ℚ) < fee.denominator.value := by exact_mod_cast valid
  constructor
  · exact div_nonneg (Nat.cast_nonneg _) (le_of_lt denPos)
  · exact (div_lt_iff₀ denPos).mpr (by simpa using feeLt)

/-- The exact scaled fraction is the accepted rational quote with the same raw units and fee. -/
theorem quote_correspondence (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    ((numerator pool amount fee).value : ℚ) / (denominator pool amount fee).value =
      (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).output := by
  have feeDenPos : 0 < fee.denominator.value :=
    lt_of_le_of_lt (Nat.zero_le _) domain.fee_valid
  have feeDenNe : (fee.denominator.value : ℚ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt feeDenPos
  have denNe : ((denominator pool amount fee).value : ℚ) ≠ 0 := by
    exact_mod_cast Nat.ne_of_gt (denominator_pos pool amount fee domain.reserveX_pos domain.fee_valid)
  have hx : (0 : ℚ) < pool.reserveX.value := by exact_mod_cast domain.reserveX_pos
  have hd : (0 : ℚ) < amount.value := by exact_mod_cast domain.amount_pos
  have rationalDenNe := ne_of_gt (Rational.denominator_pos (rationalPool pool)
    amount.value (rationalFee fee) hx hd (rational_fee_valid fee domain.fee_valid).2)
  have difference := Nat.cast_sub (R := ℚ) (Nat.le_of_lt domain.fee_valid)
  dsimp only [numerator, denominator, weightedInput, scaledReserve, wideMul, wideAdd,
    feeDifference, rationalPool, rationalFee, Rational.computed, Rational.effectiveInput] at *
  push_cast [difference] at *
  field_simp [feeDenNe, denNe, rationalDenNe]

/-- One final floor is an interval around the exact fee-aware rational output. -/
theorem rational_floor_interval (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    ((floorOutput pool amount fee domain).value : ℚ) ≤
        (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).output ∧
      (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).output <
        (floorOutput pool amount fee domain).value + 1 := by
  have divided : Rounding.divideNat .down (numerator pool amount fee).value
      (denominator pool amount fee).value = .ok (floorValue pool amount fee) := by
    simp only [Rounding.divideNat, Nat.ne_of_gt
      (denominator_pos pool amount fee domain.reserveX_pos domain.fee_valid), if_false, floorValue]
  have error := Rounding.divideNat_down_rational_error _ _ _ divided
  rw [quote_correspondence pool amount fee domain] at error
  change (floorValue pool amount fee : ℚ) ≤ _ ∧ _ < (floorValue pool amount fee : ℚ) + 1
  constructor <;> linarith

/-- No hidden multiplication, division, quotient, or subtraction error is reachable. -/
theorem arithmetic_error_iff (pool : Pool) (amount : Word 256) (fee : Fee)
    (error : Arithmetic.Failure) :
    swapPool pool amount fee = .error (.arithmetic error) ↔
      0 < pool.reserveX.value ∧ 0 < pool.reserveY.value ∧ 0 < amount.value ∧
      fee.numerator.value < fee.denominator.value ∧
      2 ^ 256 ≤ pool.reserveX.value + amount.value ∧ error = .addOverflow := by
  constructor
  · intro observed
    have hx : 0 < pool.reserveX.value := by
      by_contra invalid
      rw [bad_reserve pool amount fee (.inl (Nat.eq_zero_of_not_pos invalid))] at observed
      cases observed
    have hy : 0 < pool.reserveY.value := by
      by_contra invalid
      rw [bad_reserve pool amount fee (.inr (Nat.eq_zero_of_not_pos invalid))] at observed
      cases observed
    have hd : 0 < amount.value := by
      by_contra invalid
      rw [bad_amount pool amount fee hx hy (Nat.eq_zero_of_not_pos invalid)] at observed
      cases observed
    have hf : fee.numerator.value < fee.denominator.value := by
      by_contra invalid
      rw [bad_fee pool amount fee hx hy hd invalid] at observed
      cases observed
    have overflow : 2 ^ 256 ≤ pool.reserveX.value + amount.value := by
      by_contra invalid
      have domain : Admissible pool amount fee := ⟨hx, hy, hd, hf, Nat.lt_of_not_ge invalid⟩
      rw [success pool amount fee domain] at observed
      cases observed
    rw [reserve_overflow pool amount fee hx hy hd hf overflow] at observed
    have same : Arithmetic.Failure.addOverflow = error := by
      injection observed with reason
      injection reason
    exact ⟨hx, hy, hd, hf, overflow, same.symm⟩
  · rintro ⟨hx, hy, hd, hf, overflow, rfl⟩
    exact reserve_overflow pool amount fee hx hy hd hf overflow

theorem rational_execution (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    Rational.swapPool (rationalPool pool) amount.value (rationalFee fee) =
      .ok (Rational.computed (rationalPool pool) amount.value (rationalFee fee)) := by
  apply Rational.success
  · change (0 : ℚ) < (pool.reserveX.value : ℚ)
    exact_mod_cast domain.reserveX_pos
  · change (0 : ℚ) < (pool.reserveY.value : ℚ)
    exact_mod_cast domain.reserveY_pos
  · exact_mod_cast domain.amount_pos
  · exact (rational_fee_valid fee domain.fee_valid).1
  · exact (rational_fee_valid fee domain.fee_valid).2

theorem post_reserves_positive (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    0 < (computed pool amount fee domain).post.reserveX.value ∧
      0 < (computed pool amount fee domain).post.reserveY.value := by
  have floorBound := floor_lt_reserve pool amount fee domain.reserveX_pos
    domain.reserveY_pos domain.fee_valid
  have hx := domain.reserveX_pos
  change 0 < pool.reserveX.value + amount.value ∧
    0 < pool.reserveY.value - floorValue pool amount fee
  constructor <;> omega

theorem post_x_correspondence (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    ((computed pool amount fee domain).post.reserveX.value : ℚ) =
      (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).post.reserveX := by
  change ((pool.reserveX.value + amount.value : Nat) : ℚ) =
    (pool.reserveX.value : ℚ) + (amount.value : ℚ)
  exact Nat.cast_add _ _

/-- Floor rounding retains up to (but strictly less than) one extra raw Y unit in the pool. -/
theorem post_y_interval (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).post.reserveY ≤
        ((computed pool amount fee domain).post.reserveY.value : ℚ) ∧
      ((computed pool amount fee domain).post.reserveY.value : ℚ) <
        (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).post.reserveY + 1 := by
  have floorBounds := rational_floor_interval pool amount fee domain
  have castDifference := Nat.cast_sub (R := ℚ) (le_of_lt (floor_lt_reserve pool amount fee
    domain.reserveX_pos domain.reserveY_pos domain.fee_valid))
  change (pool.reserveY.value : ℚ) -
      (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).output ≤
        ((pool.reserveY.value - floorValue pool amount fee : Nat) : ℚ) ∧
    ((pool.reserveY.value - floorValue pool amount fee : Nat) : ℚ) <
      (pool.reserveY.value : ℚ) -
        (Rational.computed (rationalPool pool) amount.value (rationalFee fee)).output + 1
  rw [castDifference]
  change _ ≤ (pool.reserveY.value : ℚ) - (floorValue pool amount fee : ℚ) ∧
    (pool.reserveY.value : ℚ) - (floorValue pool amount fee : ℚ) < _
  change (floorValue pool amount fee : ℚ) ≤ _ ∧ _ < (floorValue pool amount fee : ℚ) + 1 at floorBounds
  constructor <;> linarith [floorBounds.1, floorBounds.2]

/-- Rounding only strengthens the exact rational product bound; equality is not claimed. -/
theorem product_nondecrease (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee) :
    pool.reserveX.value * pool.reserveY.value ≤
      (computed pool amount fee domain).post.reserveX.value *
        (computed pool amount fee domain).post.reserveY.value := by
  have hx : (0 : ℚ) < pool.reserveX.value := by exact_mod_cast domain.reserveX_pos
  have hy : (0 : ℚ) < pool.reserveY.value := by exact_mod_cast domain.reserveY_pos
  have hd : (0 : ℚ) < amount.value := by exact_mod_cast domain.amount_pos
  have feeBounds := rational_fee_valid fee domain.fee_valid
  have exactProduct := Rational.product_nondecrease (rationalPool pool) amount.value
    (rationalFee fee) hx hy hd feeBounds.1 feeBounds.2
  have postPositive := Rational.post_reserves_pos (rationalPool pool) amount.value
    (rationalFee fee) hx hy hd feeBounds.2
  have roundedProduct := mul_le_mul_of_nonneg_left (post_y_interval pool amount fee domain).1
    (le_of_lt postPositive.1)
  rw [←post_x_correspondence pool amount fee domain] at roundedProduct exactProduct
  have ordered : (pool.reserveX.value : ℚ) * (pool.reserveY.value : ℚ) ≤
      ((computed pool amount fee domain).post.reserveX.value : ℚ) *
        ((computed pool amount fee domain).post.reserveY.value : ℚ) :=
    le_trans exactProduct roundedProduct
  exact_mod_cast ordered

end DefiKernel.AMM.Checked
