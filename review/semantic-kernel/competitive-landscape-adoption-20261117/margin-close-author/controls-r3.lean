import DefiKernel.Margin.Close
namespace DefiKernel.Margin.CloseAudit
open DefiKernel.Typed
private def position : Funding.Position := ⟨Funding.precision+1,-40,0,⟨0,0,0⟩⟩
private def cfg : Close.Config :=
  ⟨⟨1,2,3⟩,⟨3,2,by decide,by decide⟩,⟨3,by decide⟩,.primary,
    Funding.precision+1,true,false,0,1,4,10,4,1,1,true⟩
private def ledger (c s pool : Nat) : Ledger where
  balance
    | (.margin,.position,.primary) => c
    | (.margin,.output,.secondary) => s
    | (.margin,.pool,.primary) => pool
    | (.margin,.pool,.secondary) => pool
    | (.margin,.owner,.claimPrimary) => 7
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def run (c s pool : Nat) (config : Close.Config) (pos : Funding.Position)
    (domain : Funding.Admissible pos config.latest) :=
  Close.run ⟨⟨ledger c s pool,Close.fixtureStore config.side⟩,pos⟩ config domain ⟨0,c,s⟩ Close.realizationIds
private def refused (actual : Except Close.Refusal Close.Result) (expected : Close.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def healthy : Funding.Position := ⟨Funding.precision,2,-1,⟨0,0,0⟩⟩
private def healthyCfg : Close.Config := {cfg with sizeDeltaUsd:=Funding.precision}
private def bankruptCfg : Close.Config := {cfg with closeBasePnlUsd:= -7,closeImpactUsd:= -2}
private def simplePosition : Funding.Position := ⟨10*Funding.precision,0,0,⟨0,0,0⟩⟩
private def simpleCfg : Close.Config := {cfg with
  prices:=⟨1,2,by decide,by decide⟩,
  pnlPrice:=⟨1,by decide⟩,sizeDeltaUsd:=10*Funding.precision,closeBasePnlUsd:=0,
  closeImpactUsd:=0,otherFeeTokens:=0,impactDiffUsd:=0,holdingConfigured:=false,minLeverageUsd:=1}
private def onePosition : Funding.Position := ⟨Funding.precision,-3,-2,⟨0,0,0⟩⟩
private def laterCfg : Close.Config := {simpleCfg with
  sizeDeltaUsd:=Funding.precision,
  closeBasePnlUsd:= -3,closeImpactUsd:= -2,otherFeeTokens:=1,impactDiffUsd:=1,holdingConfigured:=true}
private def dustCfg : Close.Config := {simpleCfg with sizeDeltaUsd:=Funding.precision}
private def secondaryFeesCfg : Close.Config := {dustCfg with prices:=⟨1,1,by decide,by decide⟩,otherFeeTokens:=1}
private def before (c s pool : Nat) (config : Close.Config) (pos : Funding.Position) : Funding.State :=
  ⟨⟨ledger c s pool,Close.fixtureStore config.side⟩,pos⟩
private def runStore (c s pool : Nat) (config : Close.Config) (pos : Funding.Position)
    (domain : Funding.Admissible pos config.latest) (store : Store) :=
  Close.run ⟨⟨ledger c s pool,store⟩,pos⟩ config domain ⟨0,c,s⟩ Close.realizationIds
private def nonzeroRecipient : Ledger where
  balance
    | (.margin,.costRecipient,.primary) => 10
    | (.margin,.costRecipient,.secondary) => 20
    | cell => (ledger 10 0 20).balance cell
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp [ledger]
private def fractional : Ledger where
  balance
    | (.margin,.position,.primary) => 1/2
    | cell => (ledger 0 0 0).balance cell
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> norm_num [ledger]
private def checks : List (String × Bool) := [
  ("simple_zero_equity_real_provision",decide (Close.provisioned simpleCfg=.ok (Close.fixtureStore .primary))),
  ("simple_zero_equity_admitted_funding_ten_from_collateral_ten",match run 10 0 0 simpleCfg simplePosition (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧ r.progress.fees.fundingFee=10 ∧
      r.progress.executed.map (·.stage)=[.funding,.fees] ∧ r.progress.executed.map (·.costUsd)=[10,0] ∧
      r.progress.state.world.state.balance (.margin,.position,.primary)=0 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.primary)=10 ∧
      r.progress.state.world.state.balance (.margin,.pool,.primary)=0 ∧
      r.progress.state.world.state.balance (.margin,.holding,.claimSecondary)=5 ∧
      Close.equity ⟨⟨ledger 10 0 0,Close.fixtureStore .primary⟩,simplePosition⟩ simpleCfg ⟨0,10,0⟩ (by decide)=0)),
  ("genuine_shared_eight_capability_provisioning",decide (Close.provisioned cfg=.ok (Close.fixtureStore .primary))),
  ("admitted_two_cash_legs_then_actual_ordered_payments",match run 10 0 20 cfg position (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧ r.progress.executed.map (·.stage)=
      [.funding,.fees,.diff] ∧ r.progress.executed.map (·.costUsd)=[6,3,1] ∧
      r.baseRealization.paidTokens=3 ∧ r.impactRealization.paidTokens=1 ∧
      r.progress.state.world.state.balance (.margin,.pool,.primary)=16 ∧
      r.progress.state.world.state.balance (.margin,.output,.primary)=0 ∧
      r.progress.state.world.state.balance (.margin,.position,.primary)=10 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.primary)=4 ∧
      r.progress.state.world.capabilities=Close.fixtureStore .primary)),
  ("funded_healthy_liquidation_refuses",refused (run 5 0 20 healthyCfg healthy (by decide))
    (.positionShouldNotBeLiquidated "" 13 1 4)),
  ("secondary_adl_does_not_bypass_healthy_liquidation_guard",refused
    (run 5 0 20 {healthyCfg with secondaryAdl:=true} healthy (by decide))
    (.positionShouldNotBeLiquidated "" 13 1 4)),
  ("allowed_bankruptcy_retains_prefix_skipped_costs_and_claims",match run 0 1 20 bankruptCfg position (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.exceptional .funding 4 ∧
      r.progress.executed.map (·.stage)=[.funding] ∧ r.skipped=[(.pnl,7),(.fees,3),(.impact,2),(.diff,1)] ∧
      r.progress.fees.fundingFee=0 ∧ r.progress.fees.nonFundingFee=0 ∧
      r.progress.fees.pendingClaimPrimary=2 ∧ r.progress.fees.pendingClaimSecondary=3 ∧
      r.progress.fees.latest=cfg.latest ∧ r.progress.state.position=position ∧
      r.progress.state.world.state.balance (.margin,.holding,.claimSecondary)=6 ∧
      r.progress.state.world.state.balance (.margin,.owner,.claimSecondary)=11 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.secondary)=1)),
  ("ordinary_full_close_shortfall_refuses",refused (run 0 1 20 {bankruptCfg with liquidation:=false}
    position (by decide)) (.insufficientFundsToPayForCosts 4 "funding")),
  ("partial_liquidation_not_exceptionally_allowed",refused (run 0 1 20
    {bankruptCfg with sizeDeltaUsd:=Funding.precision} position (by decide))
    (.insufficientFundsToPayForCosts 4 "funding")),
  ("insufficient_preparation_pool_refuses",refused (run 10 0 2 cfg position (by decide))
    (.typed .insufficientFunds)),
  ("second_positive_cash_leg_uses_remaining_same_pool",refused (run 10 0 3 cfg position (by decide))
    (.typed .insufficientFunds)),
  ("zero_source_residual_does_not_mean_economic_payment",match run 0 0 0 dustCfg onePosition (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧
      r.progress.executed.head?.map (fun step=>step.payment.sourceRemainingCostUsd)=some 0 ∧
      r.progress.executed.head?.map (fun step=>step.payment.economicShortfallUsd)=some 1 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.primary)=0 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.secondary)=0)),
  ("pnl_stops_before_fees_impact_and_diff",match run 2 0 0 laterCfg onePosition (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.exceptional .pnl 2 ∧
      r.progress.executed.map (·.stage)=[.funding,.pnl] ∧
      r.skipped=[(.fees,1),(.impact,2),(.diff,1)] ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.primary)=2 ∧
      r.progress.fees.pendingClaimPrimary=2 ∧ r.progress.fees.pendingClaimSecondary=3)),
  ("secondary_fees_zero_residual_empties_charges_not_claims",match run 1 2 0 secondaryFeesCfg onePosition (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧ r.progress.fees.fundingFee=0 ∧
      r.progress.fees.nonFundingFee=0 ∧ r.progress.fees.pendingClaimPrimary=2 ∧
      r.progress.fees.pendingClaimSecondary=3 ∧ r.progress.fees.latest=cfg.latest ∧
      r.progress.state.world.state.balance (.margin,.output,.secondary)=1)),
  ("ordinary_route_can_pay_healthy_position",match run 5 0 20 {healthyCfg with liquidation:=false}
      healthy (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete)),
  ("ordinary_full_adl_allows_exception_after_funding",match run 0 1 20
      {bankruptCfg with liquidation:=false,secondaryAdl:=true} position (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.exceptional .funding 4)),
  ("partial_adl_does_not_enable_exception",refused (run 0 1 20
    {bankruptCfg with liquidation:=false,secondaryAdl:=true,sizeDeltaUsd:=Funding.precision} position (by decide))
    (.insufficientFundsToPayForCosts 4 "funding")),
  ("holding_configuration_precedes_financial_early_return",refused (run 0 1 20
    {bankruptCfg with holdingConfigured:=false} position (by decide)) .emptyHoldingAddress),
  ("initial_raw_bucket_binding_precedes_source_guard",refused (Close.run
    (before 5 0 20 healthyCfg healthy) healthyCfg (by decide) ⟨0,0,0⟩ Close.realizationIds) .referenceBucketBinding),
  ("fractional_custody_is_not_a_raw_integer_bucket",refused (Close.run
    ⟨⟨fractional,Close.fixtureStore .primary⟩,onePosition⟩ dustCfg (by decide) ⟨0,0,0⟩ Close.realizationIds)
    .referenceBucketBinding),
  ("funding_needs_real_invoke_when_no_preparation",refused (runStore 10 0 0 simpleCfg simplePosition
    (by decide) .empty) (.typed .unauthorizedInvoke)),
  ("healthy_guard_remains_selected_before_reference_payment_authority",refused (runStore 5 0 20 healthyCfg healthy
    (by decide) .empty) (.positionShouldNotBeLiquidated "" 13 1 4)),
  ("unused_realization_and_holding_rights_may_be_absent",match runStore 10 0 0 simpleCfg simplePosition
      (by decide) ⟨(Close.fixtureStore .primary).entries.take 4⟩ with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧ r.progress.state.world.capabilities.entries.length=4)),
  ("secondary_preparation_is_actual_selected_pool_transfer",match run 10 0 20 {cfg with side:=.secondary}
      position (by decide) with
    | .error _ => false | .ok r => decide (r.kind=.complete ∧
      r.progress.state.world.state.balance (.margin,.pool,.secondary)=16 ∧
      r.progress.state.world.state.balance (.margin,.pool,.primary)=20 ∧
      r.progress.state.world.state.balance (.margin,.output,.secondary)=4 ∧
      r.progress.state.world.state.balance (.margin,.position,.primary)=6)),
  ("recipient_gains_do_not_assume_zero_prebalance",match Close.run
      ⟨⟨nonzeroRecipient,Close.fixtureStore .primary⟩,position⟩ cfg (by decide) ⟨0,10,0⟩ Close.realizationIds with
    | .error _ => false | .ok r => decide (r.progress.state.world.state.balance (.margin,.costRecipient,.primary)=14 ∧
      r.progress.state.world.state.balance (.margin,.costRecipient,.secondary)=20)),
  ("actual_totals_and_pending_owner_claims_frame",match run 10 0 20 cfg position (by decide) with
    | .error _ => false | .ok r => decide (total r.progress.state.world.state .margin .primary=30 ∧
      total r.progress.state.world.state .margin .secondary=20 ∧
      r.progress.state.world.state.balance (.margin,.owner,.claimPrimary)=7 ∧
      r.progress.state.world.state.balance (.margin,.owner,.claimSecondary)=11 ∧
      r.progress.state.position=position))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first close controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate close controls")
  match run 10 0 20 cfg position (by decide) with
  | .error reason => IO.println s!"CLOSE_OBSERVATION refused {repr reason}"
  | .ok r => IO.println s!"CLOSE_OBSERVATION {repr r.kind} {r.progress.state.world.state.balance (.margin,.pool,.primary)} {r.progress.state.world.state.balance (.margin,.costRecipient,.primary)} {r.progress.executed.length}"
  IO.println s!"CLOSE_EQUITY_OBSERVATION {Close.equity (before 10 0 0 simpleCfg simplePosition) simpleCfg ⟨0,10,0⟩ (by decide)} {Close.equity (before 5 0 20 healthyCfg healthy) healthyCfg ⟨0,5,0⟩ (by decide)}"
  match run 0 1 20 bankruptCfg position (by decide) with
  | .error reason => IO.println s!"CLOSE_CLAIM_OBSERVATION refused {repr reason}"
  | .ok r => IO.println s!"CLOSE_CLAIM_OBSERVATION {r.progress.fees.pendingClaimPrimary} {r.progress.fees.pendingClaimSecondary} {r.progress.fees.latest.fee}"
  match run 0 0 0 dustCfg onePosition (by decide) with
  | .error reason => IO.println s!"CLOSE_DUST_OBSERVATION refused {repr reason}"
  | .ok r =>
    match r.progress.executed.head? with
    | none => throw (IO.userError "BLOCKED: empty close trace")
    | some step => IO.println s!"CLOSE_DUST_OBSERVATION {step.payment.sourceRemainingCostUsd} {step.payment.economicShortfallUsd}"
  match run 2 0 0 laterCfg onePosition (by decide) with
  | .error reason => IO.println s!"CLOSE_ORDER_OBSERVATION refused {repr reason}"
  | .ok r => IO.println s!"CLOSE_ORDER_OBSERVATION {String.intercalate "," (r.progress.executed.map (fun step=>step.stage.label))}"
  for (name,passed) in checks do IO.println s!"CLOSE_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first close comparison")
  IO.println s!"CLOSE_CONTROL PASSED {checks.length}/{checks.length}"

/-- Concrete admitted, funded, genuinely authorized input makes the constructive result non-vacuous. -/
theorem simple_constructive_witness :
    ∃ result,Close.run (before 10 0 0 simpleCfg simplePosition) simpleCfg (by decide) ⟨0,10,0⟩
      Close.realizationIds=.ok result ∧ result.kind=.complete ∧
      ∀ step∈result.progress.executed,Close.Step.Covered simpleCfg.prices step := by
  have budget : Close.SolventBudget (before 10 0 0 simpleCfg simplePosition) simpleCfg (by decide) ⟨0,10,0⟩ := by
    unfold Close.SolventBudget Close.Admitted
    decide
  obtain ⟨result,executed,complete,covered,_,_⟩ := Close.constructive_solvency
    (before 10 0 0 simpleCfg simplePosition) simpleCfg (by decide) ⟨0,10,0⟩ Close.realizationIds budget
    (Close.fixture_rights .primary)
  exact ⟨result,executed,complete,covered⟩
end DefiKernel.Margin.CloseAudit
