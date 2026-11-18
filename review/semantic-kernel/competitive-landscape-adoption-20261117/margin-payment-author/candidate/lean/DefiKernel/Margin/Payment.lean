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
  let required := (input.costUsd+prices.primary-1)/prices.primary
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


/-- Native ceil division covers the cost with less than one primary token of USD excess. -/
theorem primary_rounding (prices : Prices) (input : Inputs) :
    input.costUsd ≤ (payCost prices input).primaryRequired*prices.primary ∧
    (payCost prices input).primaryRequired*prices.primary < input.costUsd+prices.primary := by
  have remainder := Nat.mod_lt (input.costUsd+prices.primary-1) prices.primary_pos
  have division := Nat.div_add_mod (input.costUsd+prices.primary-1) prices.primary
  dsimp [payCost]
  rw [Nat.mul_comm] at division
  omega

theorem payment_bounds (prices : Prices) (input : Inputs) :
    (payCost prices input).paidPrimaryOutput ≤ input.primaryOutput ∧
    (payCost prices input).paidCollateral ≤ input.collateral ∧
    (payCost prices input).paidSecondary ≤ input.secondaryOutput ∧
    (payCost prices input).paidSecondary ≤ (payCost prices input).secondaryRequired ∧
    (payCost prices input).paidPrimaryOutput+(payCost prices input).paidCollateral ≤
      (payCost prices input).primaryRequired := by
  dsimp [payCost]
  omega

/-- Each bucket is spent at most once; these are actual computed remaining balances. -/
theorem bucket_reconciliation (prices : Prices) (input : Inputs) :
    input.primaryOutput = (payCost prices input).outputLeft+
      (payCost prices input).paidPrimaryOutput ∧
    input.collateral = (payCost prices input).collateralLeft+(payCost prices input).paidCollateral ∧
    input.secondaryOutput = (payCost prices input).secondaryLeft+(payCost prices input).paidSecondary ∧
    (payCost prices input).paidPrimaryOutput+(payCost prices input).paidCollateral+
      (payCost prices input).primaryRemaining = (payCost prices input).primaryRequired := by
  dsimp [payCost]
  omega

theorem secondary_rounding (prices : Prices) (input : Inputs) :
    (payCost prices input).floorDustUsd < prices.secondary ∧
    (payCost prices input).secondaryRequired*prices.secondary+
      (payCost prices input).floorDustUsd =
        (payCost prices input).primaryRemaining*prices.primary := by
  have remainder := Nat.mod_lt ((payCost prices input).primaryRemaining*prices.primary)
    prices.secondary_pos
  have division := Nat.div_add_mod ((payCost prices input).primaryRemaining*prices.primary)
    prices.secondary
  change ((payCost prices input).primaryRemaining*prices.primary)-
    (((payCost prices input).primaryRemaining*prices.primary)/prices.secondary)*prices.secondary <
      prices.secondary ∧
    (((payCost prices input).primaryRemaining*prices.primary)/prices.secondary)*prices.secondary+
      (((payCost prices input).primaryRemaining*prices.primary)-
        (((payCost prices input).primaryRemaining*prices.primary)/prices.secondary)*prices.secondary) =
          (payCost prices input).primaryRemaining*prices.primary
  rw [Nat.mul_comm] at division
  omega

theorem ceil_dust_bound (prices : Prices) (input : Inputs) :
    (payCost prices input).ceilDustUsd < prices.primary := by
  have rounding := primary_rounding prices input
  change (payCost prices input).primaryRequired*prices.primary-input.costUsd < prices.primary
  omega

/-- Source residual, exact economic shortfall and both distinct rounding terms reconcile. -/
theorem two_dust_reconciliation (prices : Prices) (input : Inputs) :
    input.costUsd+(payCost prices input).ceilDustUsd =
      ((payCost prices input).paidPrimaryOutput+(payCost prices input).paidCollateral)*prices.primary+
      (payCost prices input).paidSecondary*prices.secondary+
      (payCost prices input).sourceRemainingCostUsd+(payCost prices input).floorDustUsd := by
  let result := payCost prices input
  have primary := (primary_rounding prices input).1
  have buckets := (bucket_reconciliation prices input).2.2.2
  have secondary := (secondary_rounding prices input).2
  have paidBound := (payment_bounds prices input).2.2.2.1
  change input.costUsd ≤ result.primaryRequired*prices.primary at primary
  change result.paidPrimaryOutput+result.paidCollateral+result.primaryRemaining =
    result.primaryRequired at buckets
  change result.secondaryRequired*prices.secondary+result.floorDustUsd =
    result.primaryRemaining*prices.primary at secondary
  have secondaryPaid : result.paidSecondary*prices.secondary+
      (result.secondaryRequired-result.paidSecondary)*prices.secondary =
        result.secondaryRequired*prices.secondary := by
    rw [← Nat.add_mul,Nat.add_sub_of_le paidBound]
  change input.costUsd+result.ceilDustUsd =
    (result.paidPrimaryOutput+result.paidCollateral)*prices.primary+
      result.paidSecondary*prices.secondary+result.sourceRemainingCostUsd+result.floorDustUsd
  calc
    input.costUsd+result.ceilDustUsd = result.primaryRequired*prices.primary := by
      change input.costUsd+(result.primaryRequired*prices.primary-input.costUsd) = _
      omega
    _ = (result.paidPrimaryOutput+result.paidCollateral)*prices.primary+
        result.primaryRemaining*prices.primary := by rw [← buckets]; ring
    _ = (result.paidPrimaryOutput+result.paidCollateral)*prices.primary+
        (result.paidSecondary*prices.secondary+
          (result.secondaryRequired-result.paidSecondary)*prices.secondary)+result.floorDustUsd := by
      rw [secondaryPaid]
      omega
    _ = _ := by
      change (result.paidPrimaryOutput+result.paidCollateral)*prices.primary+
        (result.paidSecondary*prices.secondary+result.sourceRemainingCostUsd)+result.floorDustUsd = _
      omega

/-- A zero source residual can leave a strictly positive exact USD shortfall. -/
theorem zero_residual_shortfall_witness :
    let result := payCost ⟨1,2,by decide,by decide⟩ ⟨1,0,0,0⟩
    result.sourceRemainingCostUsd = 0 ∧ result.economicShortfallUsd = 1 ∧
      result.floorDustUsd = 1 ∧ result.paidPrimaryOutput = 0 ∧ result.paidSecondary = 0 := by
  decide


theorem sufficient_primary_remaining_zero (prices : Prices) (input : Inputs)
    (liquid : (payCost prices input).primaryRequired ≤ input.primaryOutput+input.collateral) :
    (payCost prices input).primaryRemaining = 0 := by
  dsimp [payCost] at liquid ⊢
  omega

/-- Native computed payments cover the exact cost under sufficient actual primary buckets. -/
theorem sufficient_primary_coverage (prices : Prices) (input : Inputs)
    (liquid : (payCost prices input).primaryRequired ≤ input.primaryOutput+input.collateral) :
    (payCost prices input).sourceRemainingCostUsd = 0 ∧
    (payCost prices input).floorDustUsd = 0 ∧ (payCost prices input).paidSecondary = 0 ∧
    input.costUsd ≤ ((payCost prices input).paidPrimaryOutput+
      (payCost prices input).paidCollateral)*prices.primary := by
  have remaining := sufficient_primary_remaining_zero prices input liquid
  have secondary : (payCost prices input).secondaryRequired = 0 := by
    change (payCost prices input).primaryRemaining*prices.primary/prices.secondary = 0
    rw [remaining]
    simp
  have residual : (payCost prices input).sourceRemainingCostUsd = 0 := by
    change ((payCost prices input).secondaryRequired-
      (payCost prices input).paidSecondary)*prices.secondary = 0
    rw [secondary]
    simp
  have dust : (payCost prices input).floorDustUsd = 0 := by
    change (payCost prices input).primaryRemaining*prices.primary-
      (payCost prices input).secondaryRequired*prices.secondary = 0
    rw [remaining,secondary]
    simp
  have paid : (payCost prices input).paidSecondary = 0 := by
    change min input.secondaryOutput (payCost prices input).secondaryRequired = 0
    rw [secondary]
    simp
  have total := (bucket_reconciliation prices input).2.2.2
  rw [remaining,add_zero] at total
  refine ⟨residual,dust,paid,?_⟩
  rw [total]
  exact (primary_rounding prices input).1

end DefiKernel.Margin.Payment

