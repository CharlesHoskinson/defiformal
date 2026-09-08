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
  run_tac liftIO (IO.eprintln "probe: before unfold")
  unfold getNextSqrtPriceFromAmount0RoundingUp
  run_tac liftIO (IO.eprintln "probe: after unfold")
  rw [if_neg hnz]
  run_tac liftIO (IO.eprintln "probe: after amount rw")
  rw [if_pos true_eq_true]
  run_tac liftIO (IO.eprintln "probe: after add rw")
  rw [if_pos hfitB]
  run_tac liftIO (IO.eprintln "probe: after product rw")
  rw [if_pos hwrapB]
  run_tac liftIO (IO.eprintln "probe: after wrap rw")


end DefiKernel.ConcentratedLiquidity.SqrtPriceMath
