import DefiKernel.ConcentratedLiquidity.SqrtPriceMath
set_option Elab.async false
namespace DefiKernel.ConcentratedLiquidity.SqrtPriceMath
open ConcentratedLiquidity
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


end DefiKernel.ConcentratedLiquidity.SqrtPriceMath
