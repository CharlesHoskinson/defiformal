import DefiKernel.Margin.Realization

/-! Selected admission, two funded output legs and ordered payment prefix; caller work is separate. -/
namespace DefiKernel.Margin.Close
open DefiKernel.Typed
inductive Stage where | funding | pnl | fees | impact | diff deriving Repr, DecidableEq
def Stage.label : Stage → String
  | .funding => "funding" | .pnl => "pnl" | .fees => "fees" | .impact => "impact" | .diff => "diff"
structure Config where
  latest : Funding.Factors
  prices : Payment.Prices
  pnlPrice : Realization.Price
  side : Realization.Side
  sizeDeltaUsd : ℕ
  liquidation : Bool
  secondaryAdl : Bool
  healthOtherFeeTokens : ℕ
  minCollateralUsd : ℕ
  minLeverageUsd : ℕ
  closeBasePnlUsd : ℤ
  closeImpactUsd : ℤ
  otherFeeTokens : ℕ
  impactDiffUsd : ℕ
  holdingConfigured : Bool
structure Fees where
  fundingFee : ℕ
  nonFundingFee : ℕ
  pendingClaimPrimary : ℕ
  pendingClaimSecondary : ℕ
  latest : Funding.Factors
  deriving Repr, DecidableEq
def emptyFees (fees : Fees) : Fees := {fees with fundingFee:=0,nonFundingFee:=0}
def initialFees (funding : Funding.Quote) (cfg : Config) : Fees :=
  ⟨funding.feePrimary,cfg.otherFeeTokens,funding.pendingClaimPrimary,
    funding.pendingClaimSecondary,funding.latest⟩
inductive Refusal where
  | referenceBucketBinding
  | positionShouldNotBeLiquidated (reason : String) (equity minCollateral minLeverage : ℤ)
  | insufficientFundsToPayForCosts (residual : ℕ) (step : String)
  | emptyHoldingAddress
  | typed (reason : Typed.Refusal)
  deriving Repr, DecidableEq
inductive Kind where
  | complete
  | exceptional (stage : Stage) (residual : ℕ)
  deriving Repr, DecidableEq
structure Step where
  stage : Stage
  costUsd : ℕ
  buckets : Funding.Buckets
  before : Funding.State
  after : Funding.State
  payment : Payment.Result
structure Progress where
  state : Funding.State
  buckets : Funding.Buckets
  fees : Fees
  executed : List Step
structure Result where
  progress : Progress
  kind : Kind
  skipped : List (Stage × ℕ)
  baseRealization : Realization.Receipt
  impactRealization : Realization.Receipt

def equity (before : Funding.State) (cfg : Config) (buckets : Funding.Buckets)
    (domain : Funding.Admissible before.position cfg.latest) : ℤ :=
  (buckets.collateral*cfg.prices.primary:ℕ)+before.position.pnlUsd+before.position.impactUsd-
    (((Funding.quote before.position cfg.latest domain).feePrimary+cfg.healthOtherFeeTokens)*
      cfg.prices.primary:ℕ)
def liquidatable (value : ℤ) (cfg : Config) : Bool :=
  if value<(cfg.minCollateralUsd:ℤ) then true else
  if value≤0 then true else value<(cfg.minLeverageUsd:ℤ)
def allowed (before : Funding.State) (cfg : Config) : Bool :=
  decide (before.position.sizeUsd=cfg.sizeDeltaUsd) && (cfg.liquidation || cfg.secondaryAdl)
def remainingCosts (cfg : Config) : List (Stage × ℕ) :=
  (if cfg.closeBasePnlUsd<0 then [(.pnl,(-cfg.closeBasePnlUsd).toNat)] else []) ++
  [(.fees,cfg.otherFeeTokens*cfg.prices.primary)] ++
  (if cfg.closeImpactUsd<0 then [(.impact,(-cfg.closeImpactUsd).toNat)] else []) ++
  (if 0<cfg.impactDiffUsd then [(.diff,cfg.impactDiffUsd)] else [])
def afterBuckets (payment : Payment.Result) : Funding.Buckets :=
  ⟨payment.outputLeft,payment.collateralLeft,payment.secondaryLeft⟩
def addPayout (buckets : Funding.Buckets) (side : Realization.Side) (amount : ℕ) : Funding.Buckets :=
  match side with
  | .primary => {buckets with output:=buckets.output+amount}
  | .secondary => {buckets with secondary:=buckets.secondary+amount}
def fundingError : Funding.Refusal → Refusal
  | .typed reason => .typed reason | .emptyHoldingAddress => .emptyHoldingAddress

def nextProgress (progress : Progress) (stage : Stage) (cost : ℕ)
    (post : World) (payment : Payment.Result) : Progress :=
  let after : Funding.State := ⟨post,progress.state.position⟩
  let fees := if stage=.fees && !(payment.sourceRemainingCostUsd=0 && payment.paidSecondary=0)
    then emptyFees progress.fees else progress.fees
  ⟨after,afterBuckets payment,fees,
    progress.executed++[⟨stage,cost,progress.buckets,progress.state,after,payment⟩]⟩
def payOne (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ) :
    Except Refusal (Progress × Payment.Result) := do
  let input : Payment.Inputs := ⟨cost,progress.buckets.output,progress.buckets.collateral,
    progress.buckets.secondary⟩
  let (post,payment) ← (PaymentSettlement.run cfg.prices input progress.state.world.capabilities
    ownerContext Funding.payIds progress.state.world.state).mapError Refusal.typed
  return (nextProgress progress stage cost post payment,payment)

def payRest (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) : List (Stage × ℕ) → Except Refusal Result
  | [] => .ok ⟨progress,.complete,[],base,impact⟩
  | (stage,cost)::tail => do
    let (next,payment) ← payOne cfg progress stage cost
    if 0<payment.sourceRemainingCostUsd then
      if insolvencyAllowed then return ⟨{next with fees:=emptyFees next.fees},
        .exceptional stage payment.sourceRemainingCostUsd,tail,base,impact⟩
      else throw (Refusal.insufficientFundsToPayForCosts payment.sourceRemainingCostUsd stage.label)
    else payRest cfg insolvencyAllowed base impact next tail

def fundingProgress (cfg : Config) (prepared funded : Funding.State)
    (buckets : Funding.Buckets) (funding : Funding.Receipt) : Progress :=
  ⟨funded,afterBuckets funding.payment,initialFees funding.funding cfg,
    [⟨.funding,funding.funding.feePrimary*cfg.prices.primary,buckets,prepared,funded,funding.payment⟩]⟩
def finish (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt) :
    Except Refusal Result :=
  let progress := fundingProgress cfg prepared funded buckets funding
  if 0<funding.payment.sourceRemainingCostUsd then
    if allowed before cfg then .ok ⟨{progress with fees:=emptyFees progress.fees},
      .exceptional .funding funding.payment.sourceRemainingCostUsd,remainingCosts cfg,base,impact⟩
    else .error (.insufficientFundsToPayForCosts funding.payment.sourceRemainingCostUsd "funding")
  else payRest cfg (allowed before cfg) base impact progress (remainingCosts cfg)

def run (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (realizationIds : List CapabilityId) : Except Refusal Result := do
  if !(decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)) then
    throw .referenceBucketBinding
  let value := equity before cfg buckets domain
  if cfg.liquidation && !(liquidatable value cfg) then
    throw (Refusal.positionShouldNotBeLiquidated "" value cfg.minCollateralUsd cfg.minLeverageUsd)
  let (baseAfter,base) ← (Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice
    ownerContext realizationIds).mapError Refusal.typed
  let (impactAfter,impact) ← (Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side
    cfg.pnlPrice ownerContext realizationIds).mapError Refusal.typed
  let prepared : Funding.State := ⟨impactAfter.world,before.position⟩
  let preparedBuckets := addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens
  let (funded,funding) ← (Funding.run prepared cfg.latest domain cfg.prices preparedBuckets
    cfg.holdingConfigured ownerContext Funding.payIds Funding.holdingIds).mapError fundingError
  finish before cfg base impact prepared funded preparedBuckets funding

def grants (side : Realization.Side) : List (Grant Party Asset Domain) := Funding.grants++Realization.grants side
def fixtureStore (side : Realization.Side) : Store := ⟨(grants side).map (fun grant=>⟨grant,true⟩)⟩
def realizationIds : List CapabilityId := [⟨6⟩,⟨7⟩]
private def issuanceRegistry (cfg : Config) : Registry Party Asset Domain := fun id=>
  if id=PaymentSettlement.payId then some (PaymentSettlement.template cfg.prices ⟨0,0,0,0⟩)
  else if id=Funding.holdingId then some (Funding.holdingTemplate 0)
  else if id=Realization.realizeId then some (Realization.template cfg.closeBasePnlUsd cfg.side cfg.pnlPrice)
  else none
def provisioned (cfg : Config) : Except AuthorityFailure Store :=
  (grants cfg.side).foldlM (fun store grant=> do
    let (_,next) ← issueCapability (registryAuthorityConfig (issuanceRegistry cfg) (fun _=>.admin))
      ⟨.admin,.margin⟩ store grant
    return next) .empty



end DefiKernel.Margin.Close
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
  | .ok r => IO.println s!"CLOSE_ORDER_OBSERVATION {String.intercalate "," (r.progress.executed.map (fun (step : Close.Step)=>step.stage.label))}"
  for (name,passed) in checks do IO.println s!"CLOSE_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first close comparison")
  IO.println s!"CLOSE_CONTROL PASSED {checks.length}/{checks.length}"


end DefiKernel.Margin.CloseAudit
