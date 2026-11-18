import DefiKernel.AMM.Checked

/-! Same-pool full-output reversal in raw Word units. No wallet or market-price claim. -/
namespace DefiKernel.AMM.CheckedRoundTrip
open DefiKernel.Arithmetic DefiKernel.AMM.Checked

def flip (pool : Pool) : Pool := ⟨pool.reserveY, pool.reserveX⟩

def roundTrip (pool : Pool) (amount : Word 256) (fee : Fee) : Except Refusal (Swap × Swap) := do
  let forward ← swapPool pool amount fee
  let reverse ← swapPool (flip forward.post) amount fee
  return (forward, reverse)

/-- The reverse retained-input reserve is exactly original Y, so no new headroom premise. -/
theorem reverse_domain (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee)
    (positive : 0 < (computed pool amount fee domain).output.value) :
    Admissible (flip (computed pool amount fee domain).post)
      (computed pool amount fee domain).output fee := by
  have postPositive := post_reserves_positive pool amount fee domain
  have outputBound := floor_lt_reserve pool amount fee domain.reserveX_pos
    domain.reserveY_pos domain.fee_valid
  refine ⟨postPositive.2, postPositive.1, positive, domain.fee_valid, ?_⟩
  change pool.reserveY.value - floorValue pool amount fee + floorValue pool amount fee < 2^256
  rw [Nat.sub_add_cancel (le_of_lt outputBound)]
  exact pool.reserveY.bound

theorem zero_output_reverse_refusal (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee)
    (zero : (computed pool amount fee domain).output.value = 0) :
    roundTrip pool amount fee = .error .badAmount := by
  have postPositive := post_reserves_positive pool amount fee domain
  have refused := bad_amount (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee postPositive.2 postPositive.1 zero
  simp [roundTrip, success pool amount fee domain, refused, bind, Except.bind]

theorem constructive_two_success (pool : Pool) (amount : Word 256) (fee : Fee)
    (domain : Admissible pool amount fee)
    (positive : 0 < (computed pool amount fee domain).output.value) :
    ∃ reverse, swapPool (flip (computed pool amount fee domain).post)
      (computed pool amount fee domain).output fee = .ok reverse ∧
      roundTrip pool amount fee = .ok (computed pool amount fee domain, reverse) := by
  let reverseDomain := reverse_domain pool amount fee domain positive
  let reverse := computed (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee reverseDomain
  have executed := success (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee reverseDomain
  refine ⟨reverse, executed, ?_⟩
  simp only [roundTrip, success pool amount fee domain, bind, Except.bind, executed,
    pure, Except.pure]
  rfl

theorem two_success_no_profit (pool : Pool) (amount : Word 256) (fee : Fee)
    (forward reverse : Swap)
    (first : swapPool pool amount fee = .ok forward)
    (second : swapPool (flip forward.post) forward.output fee = .ok reverse) :
    reverse.post.reserveX.value = pool.reserveY.value ∧ reverse.output.value ≤ amount.value := by
  have domain := (exists_success_iff pool amount fee).mp ⟨forward, first⟩
  have same : computed pool amount fee domain = forward := Except.ok.inj
    ((success pool amount fee domain).symm.trans first)
  subst forward
  have reverseDomain := (exists_success_iff _ _ fee).mp ⟨reverse, second⟩
  have sameReverse : computed _ _ fee reverseDomain = reverse := Except.ok.inj
    ((success _ _ fee reverseDomain).symm.trans second)
  subst reverse
  have outputBound := floor_lt_reserve pool amount fee domain.reserveX_pos
    domain.reserveY_pos domain.fee_valid
  have restored : (computed (flip (computed pool amount fee domain).post)
      (computed pool amount fee domain).output fee reverseDomain).post.reserveX.value =
      pool.reserveY.value := by
    change pool.reserveY.value - floorValue pool amount fee + floorValue pool amount fee = _
    exact Nat.sub_add_cancel (le_of_lt outputBound)
  refine ⟨restored, ?_⟩
  have firstProduct := product_nondecrease pool amount fee domain
  have secondProduct := product_nondecrease _ _ fee reverseDomain
  have reverseBound := floor_lt_reserve (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee reverseDomain.reserveX_pos
    reverseDomain.reserveY_pos reverseDomain.fee_valid
  rw [restored] at secondProduct
  change pool.reserveX.value * pool.reserveY.value ≤
    (pool.reserveX.value + amount.value) *
      (pool.reserveY.value - floorValue pool amount fee) at firstProduct
  change (pool.reserveY.value - floorValue pool amount fee) *
      (pool.reserveX.value + amount.value) ≤
    pool.reserveY.value * (pool.reserveX.value + amount.value - floorValue
      (flip (computed pool amount fee domain).post)
        (computed pool amount fee domain).output fee) at secondProduct
  change floorValue (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee < pool.reserveX.value + amount.value at reverseBound
  change floorValue (flip (computed pool amount fee domain).post)
    (computed pool amount fee domain).output fee ≤ amount.value
  have cancel := Nat.sub_add_cancel (le_of_lt reverseBound)
  have hy := domain.reserveY_pos
  nlinarith

end DefiKernel.AMM.CheckedRoundTrip
