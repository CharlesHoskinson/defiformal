import DefiKernel.ConcentratedLiquidity.SqrtPriceMath
set_option Elab.async false

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

theorem identity (sqrtP : U160) (L : U128) (amount : U256) (add : Bool)
    (hz : amount.value = 0) :
    getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount add = .ok sqrtP := by
  unfold getNextSqrtPriceFromAmount0RoundingUp
  rw [if_pos hz]

theorem false_ne_true : ¬ false = true := fun h => Bool.noConfusion h
theorem true_eq_true : true = true := rfl

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
      | .error e => .error e := by
  run_tac do Lean.Core.liftIOCore (IO.FS.withFile "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-implementation-partial-review/logs/expanded-markers.log" .append (fun h => h.putStrLn "entered primary_add proof"))
  rw [primary_add_select sqrtP L amount hnz hfitB hwrapB]
  run_tac do Lean.Core.liftIOCore (IO.FS.withFile "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-implementation-partial-review/logs/expanded-markers.log" .append (fun h => h.putStrLn "after rw primary_add_select"))
  rfl


end DefiKernel.ConcentratedLiquidity.SqrtPriceMath
