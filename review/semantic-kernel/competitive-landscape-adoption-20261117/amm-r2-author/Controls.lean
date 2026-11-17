import DefiKernel.AMM.R2Bridge
open DefiKernel.AMM.R2Bridge
private def run (x y amount : ℚ) : Result := swap (.exact x) (.exact y) (.exact amount)
private def checks : List (String × Bool) := [
  ("original_fractional", decide (run (1/3) (7/5) (2/9) = Result.success (14/25) (5/9) (21/25))),
  ("independent_fractional", decide (run (1/2) (2/3) (3/4) = Result.success (2/5) (5/4) (4/15))),
  ("unbounded_above_word256", let x : ℚ := 2^300; let amount : ℚ := 2^301;
    decide (run x (7/3) amount = Result.success (14/9) (3*x) (7/9))),
  ("unbounded_independent_denominators", let x : ℚ := 1/(2^300+1);
    let y : ℚ := 3/7; let amount : ℚ := 1/(3^300+1);
    decide (run x y amount = Result.success (y*amount/(x+amount)) (x+amount)
      (y-y*amount/(x+amount)))),
  ("zero_fee_unrounded", decide (run 10 20 2 = Result.success (10/3) 12 (50/3))),
  ("reject_word_floor", !decide (run 10 20 2 = Result.success 3 12 17)),
  ("formal_malformed_first", decide (swap (.malformed "bad-x") (.exact (-1)) (.exact (-1)) =
    Result.refused Reason.badNumber)),
  ("formal_malformed_second", decide (swap (.exact (-1)) (.malformed "0.5") (.exact (-1)) =
    Result.refused Reason.badNumber)),
  ("formal_malformed_third", decide (swap (.exact 0) (.exact (-1)) (.malformed "1/0") =
    Result.refused Reason.badNumber)),
  ("formal_multiple_malformed", decide (swap (.malformed "x") (.malformed "y") (.malformed "d") =
    Result.refused Reason.badNumber)),
  ("zero_x_before_amount", decide (run 0 1 (-1) = Result.refused Reason.badReserve)),
  ("negative_y_before_amount", decide (run 1 (-1) (-1) = Result.refused Reason.badReserve)),
  ("negative_x_before_amount", decide (run (-1) 1 (-1) = Result.refused Reason.badReserve)),
  ("zero_y_before_zero_amount", decide (run 1 0 0 = Result.refused Reason.badReserve)),
  ("zero_amount", decide (run 1 1 0 = Result.refused Reason.badAmount)),
  ("negative_amount", decide (run 1 1 (-1) = Result.refused Reason.badAmount))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty R2 constructor controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate R2 controls")
  for (name, passed) in checks do IO.println s!"R2_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: R2 constructor comparison")
  IO.println s!"R2_CONTROL PASSED {checks.length}/{checks.length}"
