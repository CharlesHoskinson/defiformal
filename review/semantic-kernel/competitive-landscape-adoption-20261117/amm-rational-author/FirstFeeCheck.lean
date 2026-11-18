import DefiKernel.AMM.Rational
open DefiKernel.AMM.Rational
#eval do
  let observed := swapPool ⟨10, 20⟩ 2 (1/2)
  if !decide (observed = (Except.ok (⟨20/11, ⟨12, 200/11⟩⟩ : Swap) : Except Refusal Swap)) then
    throw (IO.userError "FAIL: fee-retaining actual reserve result")
  IO.println "AMM FIRST fee_retained_and_denominator true"
