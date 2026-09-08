import DefiKernel.ConcentratedLiquidity.SqrtPriceMath

namespace DefiKernel.ConcentratedLiquidity.SqrtPriceMath
open ConcentratedLiquidity

theorem add_mod_eq_sub {W a : Nat} (hle : W ≤ a) (hlt : a < W + W) :
    a % W = a - W := by
  have hW : 0 < W := by
    cases W with
    | zero => exact (Nat.not_lt_zero a hlt).elim
    | succ n => exact Nat.succ_pos n
  have hlt2 : a < 2 * W := by
    have : W + W = 2 * W := (two_mul W).symm
    rwa [this] at hlt
  have hdiv : a / W = 1 := by
    have hge : 1 ≤ a / W := (Nat.le_div_iff_mul_le hW).mpr (by simpa using hle)
    have hlt' : a / W < 2 := (Nat.div_lt_iff_lt_mul hW).mpr hlt2
    omega
  have hdecomp := Nat.div_add_mod a W
  rw [hdiv] at hdecomp
  omega

theorem wrap_ge_iff_width (W n1 prod : Nat) (hn1 : n1 < W) (hprod : prod < W) :
    (n1 + prod) % W ≥ n1 ↔ n1 + prod < W := by
  constructor
  · intro hge
    by_contra hnot
    have hle : W ≤ n1 + prod := Nat.le_of_not_gt hnot
    have hlt : n1 + prod < W + W := Nat.add_lt_add hn1 hprod
    have hmod : (n1 + prod) % W = n1 + prod - W := add_mod_eq_sub hle hlt
    have hge' : n1 + prod - W ≥ n1 := by
      simpa [hmod] using hge
    have hadd : n1 + prod - W + W ≥ n1 + W := Nat.add_le_add_right hge' _
    have hsum : n1 + prod ≥ n1 + W := by
      rwa [Nat.sub_add_cancel hle] at hadd
    have hprodle : W ≤ prod := Nat.le_of_add_le_add_left hsum
    exact (Nat.not_le.mpr hprod) hprodle
  · intro hfit
    have : (n1 + prod) % W = n1 + prod := Nat.mod_eq_of_lt hfit
    rw [this]
    exact Nat.le_add_right _ _

theorem wrap_ge_iff_sum_fit (n1 prod : Nat) (hn1 : n1 < 2 ^ 256)
    (hprod : prod < 2 ^ 256) :
    wrap256 (n1 + prod) ≥ n1 ↔ n1 + prod < 2 ^ 256 :=
  wrap_ge_iff_width (2 ^ 256) n1 prod hn1 hprod

theorem false_ne_true : ¬ false = true := fun h => Bool.noConfusion h
theorem true_eq_true : true = true := rfl

theorem product_fit_iff (amount : U256) (sqrtP : U160) :
    Nat.blt (product amount sqrtP) (2 ^ 256) = true ↔
      product amount sqrtP < 2 ^ 256 := by
  rw [Nat.blt_eq]

theorem product_overflow_iff (amount : U256) (sqrtP : U160) :
    Nat.blt (product amount sqrtP) (2 ^ 256) = false ↔
      2 ^ 256 ≤ product amount sqrtP := by
  constructor
  · intro h
    exact Nat.le_of_not_gt fun hlt =>
      false_ne_true (h.symm.trans ((product_fit_iff amount sqrtP).mpr hlt))
  · intro hle
    cases hb : Nat.blt (product amount sqrtP) (2 ^ 256) with
    | false => rfl
    | true =>
      exact absurd ((product_fit_iff amount sqrtP).mp hb) (Nat.not_lt.mpr hle)

theorem wrap_fit_iff (L : U128) (amount : U256) (sqrtP : U160)
    (hprod : product amount sqrtP < 2 ^ 256) :
    Nat.ble (numerator1 L) (wrap256 (numerator1 L + product amount sqrtP)) = true ↔
      numerator1 L + product amount sqrtP < 2 ^ 256 := by
  rw [Nat.ble_eq]
  exact wrap_ge_iff_sum_fit (numerator1 L) (product amount sqrtP)
    (numerator1_lt_u256 L) hprod

theorem wrap_overflow_iff (L : U128) (amount : U256) (sqrtP : U160)
    (hprod : product amount sqrtP < 2 ^ 256) :
    Nat.ble (numerator1 L) (wrap256 (numerator1 L + product amount sqrtP)) = false ↔
      2 ^ 256 ≤ numerator1 L + product amount sqrtP := by
  constructor
  · intro h
    exact Nat.le_of_not_gt fun hlt =>
      false_ne_true (h.symm.trans ((wrap_fit_iff L amount sqrtP hprod).mpr hlt))
  · intro hle
    cases hb : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) with
    | false => rfl
    | true =>
      exact absurd ((wrap_fit_iff L amount sqrtP hprod).mp hb)
        (Nat.not_lt.mpr hle)

theorem remove_guard_iff (L : U128) (amount : U256) (sqrtP : U160) :
    (Nat.blt (product amount sqrtP) (2 ^ 256) &&
      decide (numerator1 L > product amount sqrtP)) = true ↔
      product amount sqrtP < 2 ^ 256 ∧ numerator1 L > product amount sqrtP := by
  simp [Nat.blt_eq, Bool.and_eq_true]

theorem identity (sqrtP : U160) (L : U128) (amount : U256) (add : Bool)
    (hz : amount.value = 0) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount add = .ok sqrtP := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  rw [if_pos hz]

theorem primary_add_select (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) = true)
    (hwrapB : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) = true) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      addPrimary sqrtP L amount := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  rw [if_neg hnz, if_pos true_eq_true, if_pos hfitB, if_pos hwrapB]

theorem wrap_fallback_select (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) = true)
    (hwrapB : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) = false) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      addFallback sqrtP L amount := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  have hne : ¬ Nat.ble (numerator1 L)
      (wrap256 (numerator1 L + product amount sqrtP)) = true :=
    fun h => false_ne_true (hwrapB.symm.trans h)
  rw [if_neg hnz, if_pos true_eq_true, if_pos hfitB, if_neg hne]

theorem prod_fallback_select (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hovB : Nat.blt (product amount sqrtP) (2 ^ 256) = false) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      addFallback sqrtP L amount := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  have hne : ¬ Nat.blt (product amount sqrtP) (2 ^ 256) = true :=
    fun h => false_ne_true (hovB.symm.trans h)
  rw [if_neg hnz, if_pos true_eq_true, if_neg hne]

theorem remove_require (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hfail : (Nat.blt (product amount sqrtP) (2 ^ 256) &&
      decide (numerator1 L > product amount sqrtP)) = false) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount false = .error .subUnderflow := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  have hne : ¬ (Nat.blt (product amount sqrtP) (2 ^ 256) &&
      decide (numerator1 L > product amount sqrtP)) = true :=
    fun h => false_ne_true (hfail.symm.trans h)
  rw [if_neg hnz, if_neg false_ne_true, if_neg hne]

theorem remove_primary_select (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hguard : (Nat.blt (product amount sqrtP) (2 ^ 256) &&
      decide (numerator1 L > product amount sqrtP)) = true) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount false =
      removePrimary sqrtP L amount := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  rw [if_neg hnz, if_neg false_ne_true, if_pos hguard]

theorem primary_add (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) = true)
    (hwrapB : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) = true) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
          (wrapWord (numerator1 L + product amount sqrtP)) with
      | .ok q => .ok (bareToUint160 q)
      | .error e => .error e :=
  (primary_add_select sqrtP L amount hnz hfitB hwrapB).trans
    (addPrimary_fullmath sqrtP L amount)

theorem addFallback_eq (sqrtP : U160) (L : U128) (amount : U256) :
    addFallback sqrtP L amount =
      match checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L))
          amount with
      | .error e => .error e
      | .ok inner =>
          .ok (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
            divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩) := rfl

theorem wrap_fallback (sqrtP : U160) (L : U128) (amount : U256) (inner : U256)
    (hnz : amount.value ≠ 0)
    (hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) = true)
    (hwrapB : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) = false)
    (hinner :
      checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)) amount =
        .ok inner) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      .ok (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
        divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩) := by
  rw [wrap_fallback_select sqrtP L amount hnz hfitB hwrapB, addFallback_eq, hinner]

theorem prod_fallback (sqrtP : U160) (L : U128) (amount : U256) (inner : U256)
    (hnz : amount.value ≠ 0)
    (hovB : Nat.blt (product amount sqrtP) (2 ^ 256) = false)
    (hinner :
      checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)) amount =
        .ok inner) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true =
      .ok (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
        divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩) := by
  rw [prod_fallback_select sqrtP L amount hnz hovB, addFallback_eq, hinner]

theorem remove_primary (sqrtP : U160) (L : U128) (amount : U256)
    (hnz : amount.value ≠ 0)
    (hguard : (Nat.blt (product amount sqrtP) (2 ^ 256) &&
      decide (numerator1 L > product amount sqrtP)) = true) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount false =
      match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
          ⟨numerator1 L - product amount sqrtP,
            lt_of_le_of_lt (Nat.sub_le _ _) (numerator1_lt_u256 L)⟩ with
      | .ok q => toUint160 q
      | .error e => .error e :=
  (remove_primary_select sqrtP L amount hnz hguard).trans
    (removePrimary_fullmath sqrtP L amount)

theorem primary_add_precast_le (sqrtP : U160) (L : U128) (amount : U256)
    (_hfit : product amount sqrtP < 2 ^ 256)
    (hnowrap : numerator1 L + product amount sqrtP < 2 ^ 256)
    (q : U256)
    (hsucc : FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
        (wrapWord (numerator1 L + product amount sqrtP)) = .ok q) :
    q.value ≤ sqrtP.value := by
  have hd : (wrapWord (numerator1 L + product amount sqrtP)).value =
      numerator1 L + product amount sqrtP :=
    wrapWord_value_of_lt _ hnowrap
  have hok :=
    (FullMath.mulDivRoundingUp_ok_iff (numerator1Word L) (widen160 sqrtP) q
      (wrapWord (numerator1 L + product amount sqrtP))).mp hsucc
  have hspec :=
    (Arithmetic.Rounding.mulDiv_up_ok_iff (numerator1Word L) (widen160 sqrtP) q
      (wrapWord (numerator1 L + product amount sqrtP)).value).mp hok
  have hineq :
      (numerator1Word L).value * (widen160 sqrtP).value ≤
        sqrtP.value * (wrapWord (numerator1 L + product amount sqrtP)).value := by
    have hcomm :
        numerator1 L * sqrtP.value = sqrtP.value * numerator1 L := Nat.mul_comm _ _
    have hadd :
        sqrtP.value * numerator1 L ≤
          sqrtP.value * (numerator1 L + product amount sqrtP) := by
      rw [Nat.mul_add]
      exact Nat.le_add_right _ _
    simpa [hd] using (hcomm.symm ▸ hadd)
  exact hspec.2.2 sqrtP.value hineq

theorem wrap_fallback_sqrtP_pos (sqrtP : U160) (L : U128) (amount : U256)
    (hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) = true)
    (hwrapB : Nat.ble (numerator1 L)
        (wrap256 (numerator1 L + product amount sqrtP)) = false) :
    0 < sqrtP.value := by
  have hfit := (product_fit_iff amount sqrtP).mp hfitB
  have hov := (wrap_overflow_iff L amount sqrtP hfit).mp hwrapB
  by_contra hP
  have hP0 : sqrtP.value = 0 := Nat.eq_zero_of_not_pos hP
  have hprod0 : product amount sqrtP = 0 := by
    change amount.value * sqrtP.value = 0
    rw [hP0, Nat.mul_zero]
  have hsum : numerator1 L + product amount sqrtP = numerator1 L := by
    rw [hprod0, Nat.add_zero]
  have hlt : numerator1 L + product amount sqrtP < 2 ^ 256 := by
    rw [hsum]
    exact numerator1_lt_u256 L
  exact Nat.not_le.mpr hlt hov

theorem prod_fallback_sqrtP_pos (sqrtP : U160) (_L : U128) (amount : U256)
    (hovB : Nat.blt (product amount sqrtP) (2 ^ 256) = false) :
    0 < sqrtP.value := by
  have hov := (product_overflow_iff amount sqrtP).mp hovB
  by_contra hP
  have hP0 : sqrtP.value = 0 := Nat.eq_zero_of_not_pos hP
  have hprod0 : product amount sqrtP = 0 := by
    change amount.value * sqrtP.value = 0
    rw [hP0, Nat.mul_zero]
  have hlt : product amount sqrtP < 2 ^ 256 := by
    rw [hprod0]
    exact two_pow_pos_256
  exact Nat.not_le.mpr hlt hov

theorem fallback_inner_pos (sqrtP : U160) (L : U128) (amount : U256) (inner : U256)
    (hnz : amount.value ≠ 0)
    (hinner :
      checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)) amount =
        .ok inner) :
    0 < inner.value := by
  have hadd := (checkedAdd_ok_iff _ _ _).mp hinner
  have hsum := (Arithmetic.Operations.add_ok_iff _ _ _).mp hadd
  have hamt : 0 < amount.value := Nat.pos_of_ne_zero hnz
  have hpos :
      0 <
        (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)).value +
          amount.value :=
    Nat.add_pos_right _ hamt
  simpa [hsum] using hpos

theorem fallback_precast_le (sqrtP : U160) (L : U128) (amount : U256) (inner : U256)
    (hnz : amount.value ≠ 0)
    (hP : 0 < sqrtP.value)
    (hinner :
      checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)) amount =
        .ok inner) :
    divRoundingUp (numerator1 L) inner.value ≤ sqrtP.value := by
  have hpos := fallback_inner_pos sqrtP L amount inner hnz hinner
  have hadd := (checkedAdd_ok_iff _ _ _).mp hinner
  have hsum := (Arithmetic.Operations.add_ok_iff _ _ _).mp hadd
  have hfloor :
      (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)).value =
        numerator1 L / sqrtP.value := rfl
  have hamt : 1 ≤ amount.value := Nat.succ_le_of_lt (Nat.pos_of_ne_zero hnz)
  have hge : numerator1 L / sqrtP.value + 1 ≤ inner.value := by
    have hinner_val : inner.value =
        numerator1 L / sqrtP.value + amount.value := by
      rw [← hfloor]
      exact hsum.symm
    rw [hinner_val]
    exact Nat.add_le_add_left hamt _
  have hstrict :
      numerator1 L < sqrtP.value * (numerator1 L / sqrtP.value + 1) := by
    let floorN := numerator1 L / sqrtP.value
    have hN :
        numerator1 L =
          sqrtP.value * floorN + numerator1 L % sqrtP.value :=
      (Nat.div_add_mod (numerator1 L) sqrtP.value).symm
    have hlt :
        sqrtP.value * floorN + numerator1 L % sqrtP.value <
          sqrtP.value * floorN + sqrtP.value :=
      Nat.add_lt_add_left (Nat.mod_lt (numerator1 L) hP) _
    have hmul :
        sqrtP.value * floorN + sqrtP.value = sqrtP.value * (floorN + 1) := by
      rw [Nat.mul_add, Nat.mul_one]
    change numerator1 L < sqrtP.value * (floorN + 1)
    rw [hN, ← hmul]
    exact hlt
  have hle : numerator1 L ≤ sqrtP.value * inner.value :=
    Nat.le_trans (Nat.le_of_lt hstrict)
      (Nat.mul_le_mul_left _ hge)
  have hdiv := divRoundingUp_eq_divideNat_up (numerator1 L) inner.value hpos
  exact Arithmetic.Rounding.divideNat_le .up (numerator1 L) inner.value
    (divRoundingUp (numerator1 L) inner.value) sqrtP.value hdiv hle

theorem add_result_le (sqrtP : U160) (L : U128) (amount : U256) (q : U160)
    (hsucc : getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true = .ok q) :
    q.value ≤ sqrtP.value := by
  by_cases hz : amount.value = 0
  · have hid := identity sqrtP L amount true hz
    rw [hid] at hsucc
    injection hsucc with hq
    subst hq
    exact Nat.le_refl _
  · cases hfitB : Nat.blt (product amount sqrtP) (2 ^ 256) with
    | false =>
      cases hinner :
        checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L))
          amount with
      | error e =>
        have hsel := prod_fallback_select sqrtP L amount hz hfitB
        rw [hsel, addFallback_eq, hinner] at hsucc
        cases hsucc
      | ok inner =>
        have hpub := prod_fallback sqrtP L amount inner hz hfitB hinner
        rw [hpub] at hsucc
        injection hsucc with hq
        have hP := prod_fallback_sqrtP_pos sqrtP L amount hfitB
        have hle := fallback_precast_le sqrtP L amount inner hz hP hinner
        have hlt : divRoundingUp (numerator1 L) inner.value < 2 ^ 160 :=
          Nat.lt_of_le_of_lt hle sqrtP.bound
        have hval :
            (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
              divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩).value =
              divRoundingUp (numerator1 L) inner.value :=
          Nat.mod_eq_of_lt hlt
        rw [← hq, hval]
        exact hle
    | true =>
      cases hwrapB : Nat.ble (numerator1 L)
          (wrap256 (numerator1 L + product amount sqrtP)) with
      | false =>
        cases hinner :
          checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L))
            amount with
        | error e =>
          have hsel := wrap_fallback_select sqrtP L amount hz hfitB hwrapB
          rw [hsel, addFallback_eq, hinner] at hsucc
          cases hsucc
        | ok inner =>
          have hpub := wrap_fallback sqrtP L amount inner hz hfitB hwrapB hinner
          rw [hpub] at hsucc
          injection hsucc with hq
          have hP := wrap_fallback_sqrtP_pos sqrtP L amount hfitB hwrapB
          have hle := fallback_precast_le sqrtP L amount inner hz hP hinner
          have hlt : divRoundingUp (numerator1 L) inner.value < 2 ^ 160 :=
            Nat.lt_of_le_of_lt hle sqrtP.bound
          have hval :
              (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
                divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩).value =
                divRoundingUp (numerator1 L) inner.value :=
            Nat.mod_eq_of_lt hlt
          rw [← hq, hval]
          exact hle
      | true =>
        have hpub := primary_add sqrtP L amount hz hfitB hwrapB
        rw [hpub] at hsucc
        cases hfm : FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
            (wrapWord (numerator1 L + product amount sqrtP)) with
        | error e =>
          rw [hfm] at hsucc
          cases hsucc
        | ok qf =>
          rw [hfm] at hsucc
          injection hsucc with hq
          have hfit := (product_fit_iff amount sqrtP).mp hfitB
          have hnowrap := (wrap_fit_iff L amount sqrtP hfit).mp hwrapB
          have hle := primary_add_precast_le sqrtP L amount hfit hnowrap qf hfm
          have hlt : qf.value < 2 ^ 160 := Nat.lt_of_le_of_lt hle sqrtP.bound
          have hval : (bareToUint160 qf).value = qf.value :=
            bareToUint160_value_of_lt qf hlt
          rw [← hq, hval]
          exact hle

end DefiKernel.ConcentratedLiquidity.SqrtPriceMath

