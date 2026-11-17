import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-! Two-asset exact-rational pool step. The input fee remains inside the actual input reserve.
This reserve-only operation has no wallet, authority, Word, or deployed-source semantics. -/
namespace DefiKernel.AMM.Rational

structure Pool where
  reserveX : ℚ
  reserveY : ℚ
  deriving DecidableEq, Repr

structure Swap where
  output : ℚ
  post : Pool
  deriving DecidableEq, Repr

inductive Refusal where
  | badReserve | badAmount | badFee
  deriving DecidableEq, Repr

def effectiveInput (amount fee : ℚ) : ℚ := amount * (1 - fee)

def computed (pool : Pool) (amount fee : ℚ) : Swap :=
  let output := pool.reserveY * effectiveInput amount fee /
    (pool.reserveX + effectiveInput amount fee)
  ⟨output, ⟨pool.reserveX + effectiveInput amount fee, pool.reserveY - output⟩⟩

/-- Refusal priority: nonpositive reserves, nonpositive input, invalid fraction; then execution. -/
def swapPool (pool : Pool) (amount fee : ℚ) : Except Refusal Swap :=
  if pool.reserveX ≤ 0 ∨ pool.reserveY ≤ 0 then .error .badReserve
  else if amount ≤ 0 then .error .badAmount
  else if fee < 0 ∨ 1 ≤ fee then .error .badFee
  else .ok (computed pool amount fee)

def Pool.flip (pool : Pool) : Pool := ⟨pool.reserveY, pool.reserveX⟩

structure RoundTrip where
  returnedX : ℚ
  finalPool : Pool
  deriving DecidableEq, Repr

/-- Reverse the full first output against the actual first post-pool, with the same fee. -/
def roundTrip (pool : Pool) (amount fee : ℚ) : Except Refusal RoundTrip := do
  let forward ← swapPool pool amount fee
  let reverse ← swapPool forward.post.flip forward.output fee
  return ⟨reverse.output, reverse.post.flip⟩

def computedRoundTrip (pool : Pool) (amount fee : ℚ) : RoundTrip :=
  let forward := computed pool amount fee
  let reverse := computed forward.post.flip forward.output fee
  ⟨reverse.output, reverse.post.flip⟩

-- BEGIN SPECIFICATION

/-- Exact reserve/output claims; X input and Y output retain their distinct raw units. -/
def SuccessClaims (pool : Pool) (amount fee : ℚ) (result : Swap) : Prop :=
  result.output = pool.reserveY * effectiveInput amount fee /
      (pool.reserveX + effectiveInput amount fee) ∧
  result.post.reserveX = pool.reserveX + amount ∧
  result.post.reserveY = pool.reserveY - result.output ∧
  0 < result.output ∧ result.output < pool.reserveY ∧
  0 < result.post.reserveX ∧ 0 < result.post.reserveY ∧
  result.post.reserveX * result.post.reserveY - pool.reserveX * pool.reserveY =
    pool.reserveX * pool.reserveY * amount * fee /
      (pool.reserveX + effectiveInput amount fee) ∧
  pool.reserveX * pool.reserveY ≤ result.post.reserveX * result.post.reserveY

-- BEGIN PROOFS

theorem denominator_pos (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hd : 0 < amount) (hf : fee < 1) :
    0 < pool.reserveX + effectiveInput amount fee :=
  add_pos hx (mul_pos hd (sub_pos.mpr hf))

theorem success (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    swapPool pool amount fee = .ok (computed pool amount fee) := by
  simp [swapPool, not_le.mpr hx, not_le.mpr hy, not_le.mpr hd,
    not_lt.mpr hf0, not_le.mpr hf1]

theorem success_iff (pool : Pool) (amount fee : ℚ) (result : Swap) :
    swapPool pool amount fee = .ok result ↔
      0 < pool.reserveX ∧ 0 < pool.reserveY ∧ 0 < amount ∧
      0 ≤ fee ∧ fee < 1 ∧ computed pool amount fee = result := by
  unfold swapPool
  split_ifs <;> simp_all [not_or, not_le, not_lt]
  all_goals grind

theorem output_pos (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf : fee < 1) : 0 < (computed pool amount fee).output :=
  div_pos (mul_pos hy (mul_pos hd (sub_pos.mpr hf))) (denominator_pos pool amount fee hx hd hf)

theorem output_lt_reserve (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf : fee < 1) : (computed pool amount fee).output < pool.reserveY := by
  apply (div_lt_iff₀ (denominator_pos pool amount fee hx hd hf)).mpr
  nlinarith [mul_pos hx hy]

theorem post_reserves_pos (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf : fee < 1) :
    0 < (computed pool amount fee).post.reserveX ∧
      0 < (computed pool amount fee).post.reserveY :=
  ⟨add_pos hx hd, sub_pos.mpr (output_lt_reserve pool amount fee hx hy hd hf)⟩

/-- The full input, including its fee, is retained. Positive fees increase the product. -/
theorem product_increment (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hd : 0 < amount) (hf : fee < 1) :
    (computed pool amount fee).post.reserveX * (computed pool amount fee).post.reserveY -
      pool.reserveX * pool.reserveY =
      pool.reserveX * pool.reserveY * amount * fee /
        (pool.reserveX + effectiveInput amount fee) := by
  have hn := ne_of_gt (denominator_pos pool amount fee hx hd hf)
  dsimp only [computed, effectiveInput] at *
  field_simp [hn]
  ring

theorem product_nondecrease (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    pool.reserveX * pool.reserveY ≤
      (computed pool amount fee).post.reserveX * (computed pool amount fee).post.reserveY := by
  have gain := div_nonneg
    (mul_nonneg (le_of_lt (mul_pos (mul_pos hx hy) hd)) hf0)
    (le_of_lt (denominator_pos pool amount fee hx hd hf1))
  linarith [product_increment pool amount fee hx hd hf1]

theorem bad_reserve (pool : Pool) (amount fee : ℚ)
    (invalid : pool.reserveX ≤ 0 ∨ pool.reserveY ≤ 0) :
    swapPool pool amount fee = .error .badReserve := by simp [swapPool, invalid]

theorem bad_amount (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (invalid : amount ≤ 0) :
    swapPool pool amount fee = .error .badAmount := by
  simp [swapPool, not_le.mpr hx, not_le.mpr hy, invalid]

theorem bad_fee (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (invalid : fee < 0 ∨ 1 ≤ fee) :
    swapPool pool amount fee = .error .badFee := by
  simp [swapPool, not_le.mpr hx, not_le.mpr hy, not_le.mpr hd, invalid]

/-- Constructive successful execution over every admissible independent rational input. -/
theorem constructive_contract (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    ∃ result, swapPool pool amount fee = .ok result ∧ SuccessClaims pool amount fee result := by
  refine ⟨computed pool amount fee, success pool amount fee hx hy hd hf0 hf1,
    rfl, rfl, rfl, output_pos pool amount fee hx hy hd hf1,
    output_lt_reserve pool amount fee hx hy hd hf1, ?_, ?_,
    product_increment pool amount fee hx hd hf1,
    product_nondecrease pool amount fee hx hy hd hf0 hf1⟩
  · exact (post_reserves_pos pool amount fee hx hy hd hf1).1
  · exact (post_reserves_pos pool amount fee hx hy hd hf1).2

theorem round_trip_success (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    roundTrip pool amount fee = .ok (computedRoundTrip pool amount fee) := by
  have first := success pool amount fee hx hy hd hf0 hf1
  have post := post_reserves_pos pool amount fee hx hy hd hf1
  have second := success (computed pool amount fee).post.flip
    (computed pool amount fee).output fee post.2 post.1
    (output_pos pool amount fee hx hy hd hf1) hf0 hf1
  simp [roundTrip, first, second, computedRoundTrip, bind, Except.bind, pure, Except.pure]

/-- Returning all Y output leaves the same pool's Y reserve exactly at its initial value. -/
theorem round_trip_final_y (pool : Pool) (amount fee : ℚ) :
    (computedRoundTrip pool amount fee).finalPool.reserveY = pool.reserveY := by
  dsimp [computedRoundTrip, computed, Pool.flip]
  ring

/-- Pool-product monotonicity on both actual steps implies no positive returned-X gain.
No intervening trades, fee change, wallet settlement or external valuation is modelled. -/
theorem round_trip_nonprofit (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    (computedRoundTrip pool amount fee).returnedX ≤ amount := by
  let forward := computed pool amount fee
  let reverse := computed forward.post.flip forward.output fee
  have first := product_nondecrease pool amount fee hx hy hd hf0 hf1
  have post := post_reserves_pos pool amount fee hx hy hd hf1
  have second := product_nondecrease forward.post.flip forward.output fee post.2 post.1
    (output_pos pool amount fee hx hy hd hf1) hf0 hf1
  have finalY : reverse.post.reserveX = pool.reserveY := by
    dsimp [reverse, forward, computed, Pool.flip]
    ring
  have finalX : reverse.post.reserveY = pool.reserveX + amount - reverse.output := rfl
  have product : pool.reserveX * pool.reserveY ≤
      reverse.post.reserveX * reverse.post.reserveY := by
    change pool.reserveX * pool.reserveY ≤ forward.post.reserveX * forward.post.reserveY at first
    change forward.post.reserveY * forward.post.reserveX ≤
      reverse.post.reserveX * reverse.post.reserveY at second
    calc
      pool.reserveX * pool.reserveY ≤ forward.post.reserveX * forward.post.reserveY := first
      _ = forward.post.reserveY * forward.post.reserveX := mul_comm _ _
      _ ≤ reverse.post.reserveX * reverse.post.reserveY := second
  rw [finalY, finalX] at product
  have scaled : pool.reserveX * pool.reserveY ≤
      (pool.reserveX + amount - reverse.output) * pool.reserveY := by nlinarith [product]
  have bound := le_of_mul_le_mul_right scaled hy
  change reverse.output ≤ amount
  linarith

/-- Both actual calls succeed and the returned input asset cannot exceed the amount spent. -/
theorem round_trip_contract (pool : Pool) (amount fee : ℚ)
    (hx : 0 < pool.reserveX) (hy : 0 < pool.reserveY) (hd : 0 < amount)
    (hf0 : 0 ≤ fee) (hf1 : fee < 1) :
    ∃ result, roundTrip pool amount fee = .ok result ∧
      result.returnedX ≤ amount ∧ result.finalPool.reserveY = pool.reserveY :=
  ⟨computedRoundTrip pool amount fee, round_trip_success pool amount fee hx hy hd hf0 hf1,
    round_trip_nonprofit pool amount fee hx hy hd hf0 hf1, round_trip_final_y pool amount fee⟩

end DefiKernel.AMM.Rational
