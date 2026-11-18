import Mathlib.Data.Nat.Basic
import Mathlib.Tactic.Ring

/-! Native integer payment arithmetic for the accepted GMX helper boundary.
All quantities retain raw token/USD units. This is not an EVM256 refinement proof. -/
namespace DefiKernel.Margin.Payment
structure Prices where
  primary : ℕ
  secondary : ℕ
  primary_pos : 0 < primary
  secondary_pos : 0 < secondary
structure Inputs where
  costUsd : ℕ
  primaryOutput : ℕ
  collateral : ℕ
  secondaryOutput : ℕ
  deriving Repr, DecidableEq
structure Result where
  primaryRequired : ℕ
  paidPrimaryOutput : ℕ
  paidCollateral : ℕ
  primaryRemaining : ℕ
  secondaryRequired : ℕ
  paidSecondary : ℕ
  outputLeft : ℕ
  collateralLeft : ℕ
  secondaryLeft : ℕ
  sourceRemainingCostUsd : ℕ
  ceilDustUsd : ℕ
  floorDustUsd : ℕ
  economicShortfallUsd : ℕ
  deriving Repr, DecidableEq

def payCost (prices : Prices) (input : Inputs) : Result :=
  let required := input.costUsd/prices.primary
  let paidOutput := min input.primaryOutput required
  let paidCollateral := min input.collateral (required-paidOutput)
  let remaining := required-paidOutput-paidCollateral
  let secondaryRequired := remaining*prices.primary/prices.secondary
  let paidSecondary := min input.secondaryOutput secondaryRequired
  ⟨required,paidOutput,paidCollateral,remaining,secondaryRequired,paidSecondary,
    input.primaryOutput-paidOutput,input.collateral-paidCollateral,
    input.secondaryOutput-paidSecondary,(secondaryRequired-paidSecondary)*prices.secondary,
    required*prices.primary-input.costUsd,
    remaining*prices.primary-secondaryRequired*prices.secondary,
    input.costUsd-((paidOutput+paidCollateral)*prices.primary+paidSecondary*prices.secondary)⟩



end DefiKernel.Margin.Payment

namespace DefiKernel.Margin.PaymentAudit
open Payment
private def p11 : Prices := ⟨1,1,by decide,by decide⟩
private def p12 : Prices := ⟨1,2,by decide,by decide⟩
private def p23 : Prices := ⟨2,3,by decide,by decide⟩
private def p32 : Prices := ⟨3,2,by decide,by decide⟩
private def p34 : Prices := ⟨3,4,by decide,by decide⟩
private def observation (r : Result) : List ℕ := [r.outputLeft,r.collateralLeft,r.secondaryLeft,
  r.paidPrimaryOutput+r.paidCollateral,r.paidSecondary,r.sourceRemainingCostUsd]
private def cases : List (String × Prices × Inputs × List ℕ) := [
  ("zero_source_residual_shortfall",p12,⟨1,0,0,0⟩,[0,0,0,0,0,0]),
  ("two_dust_terms",p34,⟨5,0,0,0⟩,[0,0,0,0,0,4]),
  ("sufficient_primary",p34,⟨5,1,1,0⟩,[0,0,0,2,0,0]),
  ("pnl_stage_source_residual",p11,⟨20,0,3,0⟩,[0,0,0,3,0,17]),
  ("positive_secondary_with_dust",p34,⟨5,0,0,1⟩,[0,0,0,0,1,0]),
  ("positive_secondary_fully_paid",p32,⟨6,0,0,3⟩,[0,0,0,0,3,0]),
  ("mixed_tokens_fully_paid",p23,⟨10,1,1,2⟩,[0,0,0,2,2,0]),
  ("zero_cost_preserves_buckets",p34,⟨0,2,5,7⟩,[2,5,7,0,0,0]),
  ("primary_output_spent_before_collateral",p34,⟨5,1,5,2⟩,[0,4,2,2,0,0])]
private def extra : List (String × Bool) := [
  ("zero_source_residual_is_not_full_payment",let r:=payCost p12 ⟨1,0,0,0⟩;
    decide (r.sourceRemainingCostUsd=0 ∧ r.economicShortfallUsd=1 ∧ r.floorDustUsd=1)),
  ("ceil_floor_and_residual_are_distinct",let r:=payCost p34 ⟨5,0,0,0⟩;
    decide (r.ceilDustUsd=1 ∧ r.floorDustUsd=2 ∧ r.sourceRemainingCostUsd=4 ∧
      r.economicShortfallUsd=5)),
  ("paid_secondary_can_still_leave_economic_shortfall",let r:=payCost p34 ⟨5,0,0,1⟩;
    decide (r.paidSecondary=1 ∧ r.sourceRemainingCostUsd=0 ∧ r.economicShortfallUsd=1))]
#eval do
  if cases.isEmpty || extra.isEmpty then throw (IO.userError "BLOCKED: empty payment inventory")
  let checks : List (String × Bool) := cases.map
    (fun (row : String × Prices × Inputs × List ℕ) =>
      (row.1,decide (observation (payCost row.2.1 row.2.2.1)=row.2.2.2))) ++ extra
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate payment controls")
  for (name,p,i,_) in cases do
    let r:=payCost p i
    IO.println s!"PAYMENT_NATIVE_INPUT {name} {i.costUsd},{p.primary},{p.secondary},{i.primaryOutput},{i.collateral},{i.secondaryOutput}"
    IO.println s!"PAYMENT_NATIVE_CASE {name} {String.intercalate "," ((observation r).map toString)}"
    IO.println s!"PAYMENT_NATIVE_DUST {name} {r.ceilDustUsd},{r.floorDustUsd},{r.economicShortfallUsd}"
  for (name,passed) in checks do IO.println s!"PAYMENT_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual payment comparison")
  IO.println s!"PAYMENT_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Margin.PaymentAudit