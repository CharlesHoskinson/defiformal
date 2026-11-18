import DefiKernel.Margin.Close
open DefiKernel DefiKernel.Typed DefiKernel.Margin
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
    (.typed .insufficientFunds))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first close controls")
  for (name,passed) in checks do IO.println s!"CLOSE_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first close comparison")
