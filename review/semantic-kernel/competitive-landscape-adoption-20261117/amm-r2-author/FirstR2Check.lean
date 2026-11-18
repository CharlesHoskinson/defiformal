import DefiKernel.AMM.R2Bridge
open DefiKernel.AMM.R2Bridge
#eval do
  let actual := swap (.exact (1/2)) (.exact (2/3)) (.exact (3/4))
  if !decide (actual = Result.success (2/5) (5/4) (4/15)) then
    throw (IO.userError "FAIL: fractional library R2 output")
  if !decide (swap (.exact (-1)) (.malformed "bad") (.exact 0) = Result.refused Reason.badNumber) then
    throw (IO.userError "FAIL: malformed priority")
  IO.println "R2_FIRST fractional_library_and_malformed_priority true"
