import DefiKernel.Margin.Payment
open DefiKernel.Margin.Payment
private def p12 : Prices := ⟨1,2,by decide,by decide⟩
private def p34 : Prices := ⟨3,4,by decide,by decide⟩
private def p32 : Prices := ⟨3,2,by decide,by decide⟩
private def checks : List (String × Bool) := [
  ("zero_source_residual_exact_shortfall",let r:=payCost p12 ⟨1,0,0,0⟩;
    decide (r.sourceRemainingCostUsd=0 ∧ r.paidCollateral=0 ∧ r.paidSecondary=0 ∧
      r.ceilDustUsd=0 ∧ r.floorDustUsd=1 ∧ r.economicShortfallUsd=1)),
  ("secondary_payment_with_dust_shortfall",let r:=payCost p34 ⟨5,0,0,1⟩;
    decide (r.paidSecondary=1 ∧ r.sourceRemainingCostUsd=0 ∧ r.ceilDustUsd=1 ∧
      r.floorDustUsd=2 ∧ r.economicShortfallUsd=1)),
  ("secondary_payment_fully_covers_cost",let r:=payCost p32 ⟨6,0,0,3⟩;
    decide (r.paidSecondary=3 ∧ r.sourceRemainingCostUsd=0 ∧ r.economicShortfallUsd=0)),
  ("sufficient_primary_pays_rounded_cost",let r:=payCost p34 ⟨5,1,1,0⟩;
    decide (r.paidPrimaryOutput=1 ∧ r.paidCollateral=1 ∧ r.paidSecondary=0 ∧
      r.sourceRemainingCostUsd=0 ∧ r.ceilDustUsd=1 ∧ r.floorDustUsd=0)),
  ("bankruptcy_residual_retained",let r:=payCost p12 ⟨20,0,3,0⟩;
    decide (r.paidCollateral=3 ∧ r.sourceRemainingCostUsd=16 ∧ r.floorDustUsd=1 ∧
      r.economicShortfallUsd=17))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty payment controls")
  for (name,passed) in checks do IO.println s!"PAYMENT_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual native payment comparison")
