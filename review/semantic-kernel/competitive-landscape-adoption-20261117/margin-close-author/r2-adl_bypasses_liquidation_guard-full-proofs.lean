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
  if cfg.liquidation && !cfg.secondaryAdl && !(liquidatable value cfg) then
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


/-- Concrete arithmetic admission, independent of custody sufficiency and of the ADL flag. -/
theorem liquidatable_iff (value : ℤ) (cfg : Config) :
    liquidatable value cfg=true ↔ value<(cfg.minCollateralUsd:ℤ) ∨ value≤0 ∨ value<(cfg.minLeverageUsd:ℤ) := by
  by_cases first : value<(cfg.minCollateralUsd:ℤ)
  · simp [liquidatable,first]
  · by_cases second : value≤0 <;> simp [liquidatable,first,second]

theorem allowed_iff (before : Funding.State) (cfg : Config) :
    allowed before cfg=true ↔ before.position.sizeUsd=cfg.sizeDeltaUsd ∧
      (cfg.liquidation=true ∨ cfg.secondaryAdl=true) := by
  simp [allowed,Bool.or_eq_true]

theorem emptyFees_preserves (fees : Fees) :
    (emptyFees fees).fundingFee=0 ∧ (emptyFees fees).nonFundingFee=0 ∧
    (emptyFees fees).pendingClaimPrimary=fees.pendingClaimPrimary ∧
    (emptyFees fees).pendingClaimSecondary=fees.pendingClaimSecondary ∧
    (emptyFees fees).latest=fees.latest := by exact ⟨rfl,rfl,rfl,rfl,rfl⟩

theorem healthy_refusal (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩
      before.world.state)
    (liquidation : cfg.liquidation=true)
    (healthy : liquidatable (equity before cfg buckets domain) cfg=false) :
    run before cfg domain buckets ids=.error (.positionShouldNotBeLiquidated ""
      (equity before cfg buckets domain) cfg.minCollateralUsd cfg.minLeverageUsd) := by
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using compatible
  simp [run,binding,liquidation,healthy,bind,Except.bind]
  rfl

theorem reference_binding_refusal (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (incompatible : ¬ PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state) :
    run before cfg domain buckets ids=.error .referenceBucketBinding := by
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=false := by simpa using incompatible
  simp [run,binding,bind,Except.bind]
  rfl

theorem payout_compatible (before after : Funding.State) (basePnlUsd : ℤ)
    (side : Realization.Side) (price : Realization.Price) (ids : List CapabilityId)
    (receipt : Realization.Receipt) (buckets : Funding.Buckets)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩
      before.world.state)
    (success : Realization.run before basePnlUsd side price ownerContext ids=.ok (after,receipt)) :
    PaymentSettlement.Compatible ⟨0,(addPayout buckets side receipt.paidTokens).output,
      (addPayout buckets side receipt.paidTokens).collateral,
      (addPayout buckets side receipt.paidTokens).secondary⟩ after.world.state := by
  have paid := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ success).2
  have frame := Realization.actual_frame before basePnlUsd side price ownerContext ids after receipt success
  cases side with
  | primary =>
    refine ⟨?_,?_,?_⟩
    · simpa [addPayout,Realization.Side.asset,compatible.1,Nat.cast_add] using paid
    · simpa [addPayout] using (frame (.margin,.position,.primary) (by decide) (by decide)).trans compatible.2.1
    · simpa [addPayout] using (frame (.margin,.output,.secondary) (by decide) (by decide)).trans compatible.2.2
  | secondary =>
    refine ⟨?_,?_,?_⟩
    · simpa [addPayout] using (frame (.margin,.output,.primary) (by decide) (by decide)).trans compatible.1
    · simpa [addPayout] using (frame (.margin,.position,.primary) (by decide) (by decide)).trans compatible.2.1
    · simpa [addPayout,Realization.Side.asset,compatible.2.2,Nat.cast_add] using paid

theorem payment_compatible (before : Funding.State) (prices : Payment.Prices)
    (input : Payment.Inputs) (post : World) (payment : Payment.Result)
    (success : PaymentSettlement.run prices input before.world.capabilities ownerContext Funding.payIds
      before.world.state=.ok (post,payment)) :
    PaymentSettlement.Compatible ⟨0,payment.outputLeft,payment.collateralLeft,payment.secondaryLeft⟩ post.state := by
  obtain ⟨executed,rfl⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp success
  exact PaymentSettlement.actual_buckets _ _ _ _ _ _ _ executed

theorem funding_compatible (before after : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (receipt : Funding.Receipt)
    (success : Funding.run before cfg.latest domain cfg.prices buckets cfg.holdingConfigured ownerContext
      Funding.payIds Funding.holdingIds=.ok (after,receipt)) :
    PaymentSettlement.Compatible ⟨0,receipt.payment.outputLeft,receipt.payment.collateralLeft,
      receipt.payment.secondaryLeft⟩ after.world.state := by
  obtain ⟨paid,executed,held,position,observed⟩ := (Funding.run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mp success
  have bucketsAfter := PaymentSettlement.actual_buckets _ _ _ _ _ _ _ executed
  have holding := (Funding.settleHolding_effects _ _ _ _ _ _ held).2
  rw [observed]
  refine ⟨?_,?_,?_⟩
  · simpa [Funding.receipt,bucketsAfter.1] using holding (.margin,.output,.primary)
  · simpa [Funding.receipt,bucketsAfter.2.1] using holding (.margin,.position,.primary)
  · simpa [Funding.receipt,bucketsAfter.2.2] using holding (.margin,.output,.secondary)

theorem provisioned_exact (cfg : Config) : provisioned cfg=.ok (fixtureStore cfg.side) := by
  rcases cfg with ⟨latest,prices,pnlPrice,side,size,liq,adl,healthFee,minC,minL,base,impact,other,diff,holding⟩
  cases side <;> rfl


def preserves (before after : Funding.State) : Prop :=
  after.position=before.position ∧ after.world.capabilities=before.world.capabilities ∧
    (∀ asset,total after.world.state .margin asset=total before.world.state .margin asset) ∧
    ∀ cell,cell ∉ PaymentSettlement.affected → after.world.state.balance cell=before.world.state.balance cell

theorem preserves_trans (a b c : Funding.State) (ab : preserves a b) (bc : preserves b c) :
    preserves a c :=
  ⟨bc.1.trans ab.1,bc.2.1.trans ab.2.1,
    fun asset=>(bc.2.2.1 asset).trans (ab.2.2.1 asset),
    fun cell outside=>(bc.2.2.2 cell outside).trans (ab.2.2.2 cell outside)⟩

theorem payOne_ok_iff (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) :
    payOne cfg progress stage cost=.ok (next,payment) ↔
      ∃ post,PaymentSettlement.run cfg.prices
        ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
        progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state=
          .ok (post,payment) ∧
        next=nextProgress progress stage cost post payment := by
  cases actual : PaymentSettlement.run cfg.prices
    ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state with
  | error reason => simp [payOne,actual,Except.mapError,bind,Except.bind]
  | ok pair =>
    rcases pair with ⟨post,q⟩
    constructor
    · intro success
      have same : (nextProgress progress stage cost post q,q)=(next,payment) :=
        Except.ok.inj (by simpa only [payOne,actual,Except.mapError,bind,Except.bind,pure,Except.pure] using success)
      have paymentEq := congrArg Prod.snd same
      have nextEq := congrArg Prod.fst same
      change q=payment at paymentEq
      change nextProgress progress stage cost post q=next at nextEq
      subst payment
      exact ⟨post,rfl,nextEq.symm⟩
    · rintro ⟨post2,executed,nextEq⟩
      have same : (post,q)=(post2,payment) := Except.ok.inj executed
      rcases Prod.mk.inj same with ⟨rfl,rfl⟩
      subst next
      simp only [payOne,actual,Except.mapError,bind,Except.bind,pure,Except.pure]

theorem payOne_preserves (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    preserves progress.state next.state := by
  obtain ⟨post,paid,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  obtain ⟨executed,_⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp paid
  have caps := ((PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp executed).2.2.2.1
  exact ⟨rfl,caps,PaymentSettlement.actual_accounting _ _ _ _ _ _ _ executed,
    fun cell outside=>PaymentSettlement.actual_frame _ _ _ _ _ _ _ executed cell outside⟩

theorem payRest_preserves (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    preserves progress.state result.progress.state := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact ⟨rfl,rfl,fun _=>rfl,fun _ _=>rfl⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have step := payOne_preserves cfg progress next stage cost payment actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact step
      · rw [if_neg residual] at success
        exact preserves_trans _ _ _ step (ih next success)


def Admitted (value : ℤ) (cfg : Config) : Prop :=
  cfg.liquidation=false ∨ liquidatable value cfg=true
instance (value : ℤ) (cfg : Config) : Decidable (Admitted value cfg) :=
  inferInstanceAs (Decidable (_ ∨ _))
theorem admitted_iff (value : ℤ) (cfg : Config) :
    Admitted value cfg ↔ cfg.liquidation=false ∨
      value<(cfg.minCollateralUsd:ℤ) ∨ value≤0 ∨ value<(cfg.minLeverageUsd:ℤ) := by
  simp only [Admitted,liquidatable_iff,or_assoc]

theorem finish_preserves (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt)
    (result : Result) (success : finish before cfg base impact prepared funded buckets funding=.ok result) :
    preserves funded result.progress.state := by
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at success
    cases eligible : allowed before cfg with
    | false => simp [eligible] at success
    | true =>
      simp only [eligible,ite_true] at success
      obtain rfl := Except.ok.inj success
      exact ⟨rfl,rfl,fun _=>rfl,fun _ _=>rfl⟩
  · simp only [finish,if_neg residual] at success
    exact payRest_preserves _ _ _ _ _ _ _ success

/-- Success exposes the actual two funded transfers and actual funding call, with concrete admission. -/
theorem run_execution (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state ∧
    Admitted (equity before cfg buckets domain) cfg ∧
    ∃ baseAfter base impactAfter impact funded funding,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      Funding.run ⟨impactAfter.world,before.position⟩ cfg.latest domain cfg.prices
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens)
        cfg.holdingConfigured ownerContext Funding.payIds Funding.holdingIds=.ok (funded,funding) ∧
      finish before cfg base impact ⟨impactAfter.world,before.position⟩ funded
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding=.ok result := by
  have compatible : PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state := by
    by_contra incompatible
    rw [reference_binding_refusal _ _ _ _ _ incompatible] at success
    cases success
  have admitted : Admitted (equity before cfg buckets domain) cfg := by
    by_contra denied
    have liq : cfg.liquidation=true := by
      cases value : cfg.liquidation <;> simp_all [Admitted]
    have health : liquidatable (equity before cfg buckets domain) cfg=false := by
      cases value : liquidatable (equity before cfg buckets domain) cfg <;> simp_all [Admitted]
    rw [healthy_refusal _ _ _ _ _ compatible liq health] at success
    cases success
  refine ⟨compatible,admitted,?_⟩
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using compatible
  have notDenied : (cfg.liquidation && !(liquidatable (equity before cfg buckets domain) cfg))=false := by
    rcases admitted with liq | health
    · simp [liq]
    · simp [health]
  cases baseCall : Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids with
  | error reason => simp [run,binding,notDenied,baseCall,Except.mapError,bind,Except.bind] at success
  | ok basePair =>
    rcases basePair with ⟨baseAfter,base⟩
    cases impactCall : Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice
      ownerContext ids with
    | error reason => simp [run,binding,notDenied,baseCall,impactCall,Except.mapError,bind,Except.bind] at success
    | ok impactPair =>
      rcases impactPair with ⟨impactAfter,impact⟩
      cases fundingCall : Funding.run ⟨impactAfter.world,before.position⟩ cfg.latest domain cfg.prices
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens)
        cfg.holdingConfigured ownerContext Funding.payIds Funding.holdingIds with
      | error reason => simp [run,binding,notDenied,baseCall,impactCall,fundingCall,Except.mapError,bind,Except.bind] at success
      | ok fundingPair =>
        rcases fundingPair with ⟨funded,funding⟩
        have finished : finish before cfg base impact ⟨impactAfter.world,before.position⟩ funded
            (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding=.ok result := by
          simpa only [run,binding,notDenied,Bool.not_true,Bool.false_eq_true,ite_false,
            baseCall,impactCall,fundingCall,Except.mapError,bind,Except.bind] using success
        exact ⟨baseAfter,base,impactAfter,impact,funded,funding,rfl,impactCall,fundingCall,finished⟩


/-- Actual preparation/funding/payment execution conserves both physical assets and leaves owner funding claims pending. -/
theorem run_accounting (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    result.progress.state.position=before.position ∧
    result.progress.state.world.capabilities=before.world.capabilities ∧
    total result.progress.state.world.state .margin .primary=total before.world.state .margin .primary ∧
    total result.progress.state.world.state .margin .secondary=total before.world.state .margin .secondary ∧
    result.progress.state.world.state.balance (.margin,.owner,.claimPrimary)=
      before.world.state.balance (.margin,.owner,.claimPrimary) ∧
    result.progress.state.world.state.balance (.margin,.owner,.claimSecondary)=
      before.world.state.balance (.margin,.owner,.claimSecondary) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have baseInfo := Realization.actual_effects _ _ _ _ _ _ _ _ baseCall
  have impactInfo := Realization.actual_effects _ _ _ _ _ _ _ _ impactCall
  have fundingInfo := Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall
  have final := finish_preserves _ _ _ _ _ _ _ _ _ finished
  have totals (asset : Asset) (notClaim : asset≠.claimSecondary) :
      total result.progress.state.world.state .margin asset=total before.world.state .margin asset := by
    calc
      _ = total funded.world.state .margin asset := final.2.2.1 asset
      _ = total impactAfter.world.state .margin asset := by
        simpa only [if_neg notClaim,add_zero] using Funding.actual_accounting _ _ _ _ _ _ _ _ _ _ _ fundingCall asset
      _ = total baseAfter.world.state .margin asset := Realization.actual_accounting _ _ _ _ _ _ _ _ impactCall asset
      _ = total before.world.state .margin asset := Realization.actual_accounting _ _ _ _ _ _ _ _ baseCall asset
  refine ⟨final.1.trans fundingInfo.1,
    final.2.1.trans (fundingInfo.2.1.trans (impactInfo.2.1.trans baseInfo.2.1)),
    totals .primary (by decide),totals .secondary (by decide),?_,?_⟩
  · have fundingOwner := (Funding.actual_owner_claims_and_holding _ _ _ _ _ _ _ _ _ _ _ fundingCall).1
    calc
      _ = funded.world.state.balance (.margin,.owner,.claimPrimary) :=
        final.2.2.2 _ (by simp [PaymentSettlement.affected])
      _ = impactAfter.world.state.balance (.margin,.owner,.claimPrimary) := fundingOwner
      _ = baseAfter.world.state.balance (.margin,.owner,.claimPrimary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ impactCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
      _ = before.world.state.balance (.margin,.owner,.claimPrimary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ baseCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
  · have fundingOwner := (Funding.actual_owner_claims_and_holding _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.1
    calc
      _ = funded.world.state.balance (.margin,.owner,.claimSecondary) :=
        final.2.2.2 _ (by simp [PaymentSettlement.affected])
      _ = impactAfter.world.state.balance (.margin,.owner,.claimSecondary) := fundingOwner
      _ = baseAfter.world.state.balance (.margin,.owner,.claimSecondary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ impactCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
      _ = before.world.state.balance (.margin,.owner,.claimSecondary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ baseCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)


def Step.input (step : Step) : Payment.Inputs :=
  ⟨step.costUsd,step.buckets.output,step.buckets.collateral,step.buckets.secondary⟩
def Step.actualPaidUsd (prices : Payment.Prices) (step : Step) : ℚ :=
  (step.after.world.state.balance (.margin,.costRecipient,.primary)-
    step.before.world.state.balance (.margin,.costRecipient,.primary))*(prices.primary:ℚ)+
  (step.after.world.state.balance (.margin,.costRecipient,.secondary)-
    step.before.world.state.balance (.margin,.costRecipient,.secondary))*(prices.secondary:ℚ)
def Step.Financial (prices : Payment.Prices) (step : Step) : Prop :=
  step.payment=Payment.payCost prices step.input ∧
  PaymentSettlement.Compatible step.input step.before.world.state ∧
  PaymentSettlement.Compatible ⟨0,step.payment.outputLeft,step.payment.collateralLeft,
    step.payment.secondaryLeft⟩ step.after.world.state ∧
  (step.costUsd:ℚ)+(step.payment.ceilDustUsd:ℚ)=step.actualPaidUsd prices+
    (step.payment.sourceRemainingCostUsd:ℚ)+(step.payment.floorDustUsd:ℚ)

theorem ordinary_step_financial (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ)
    (post : World) (payment : Payment.Result)
    (success : PaymentSettlement.run cfg.prices
      ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
      progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state=.ok (post,payment)) :
    Step.Financial cfg.prices ⟨stage,cost,progress.buckets,progress.state,⟨post,progress.state.position⟩,payment⟩ := by
  obtain ⟨executed,quoteEq⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp success
  exact ⟨quoteEq,PaymentSettlement.success_compatible _ _ _ _ _ _ _ executed,
    payment_compatible _ _ _ _ _ success,
    PaymentSettlement.actual_financial_reconciliation _ _ _ _ _ _ _ _ success⟩

theorem funding_step_financial (cfg : Config) (prepared funded : Funding.State)
    (domain : Funding.Admissible prepared.position cfg.latest) (buckets : Funding.Buckets)
    (funding : Funding.Receipt)
    (success : Funding.run prepared cfg.latest domain cfg.prices buckets cfg.holdingConfigured ownerContext
      Funding.payIds Funding.holdingIds=.ok (funded,funding)) :
    Step.Financial cfg.prices ⟨.funding,funding.funding.feePrimary*cfg.prices.primary,
      buckets,prepared,funded,funding.payment⟩ := by
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.1
  obtain ⟨paid,executed,_,_,_⟩ := (Funding.run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mp success
  have compatible := PaymentSettlement.success_compatible _ _ _ _ _ _ _ executed
  refine ⟨?_,?_,funding_compatible _ _ _ _ _ _ success,?_⟩
  · rw [observation]; rfl
  · simpa only [Step.input,observation,Funding.receipt,Funding.paymentInput] using compatible
  · simpa only [Step.actualPaidUsd,Nat.cast_mul] using Funding.actual_reconciliation _ _ _ _ _ _ _ _ _ _ _ success

theorem payOne_financial (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result)
    (prior : ∀ step∈progress.executed,Step.Financial cfg.prices step)
    (success : payOne cfg progress stage cost=.ok (next,payment)) :
    ∀ step∈next.executed,Step.Financial cfg.prices step := by
  obtain ⟨post,paid,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  intro step member
  simp only [nextProgress,List.mem_append,List.mem_singleton] at member
  rcases member with old | rfl
  · exact prior step old
  · exact ordinary_step_financial _ _ _ _ _ _ paid

theorem payRest_financial (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (prior : ∀ step∈progress.executed,Step.Financial cfg.prices step)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    ∀ step∈result.progress.executed,Step.Financial cfg.prices step := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact prior
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have nextValid := payOne_financial _ _ _ _ _ _ prior actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact nextValid
      · rw [if_neg residual] at success
        exact ih next nextValid success

/-- Every returned payment is bound to its own actual pre/post ledger and exact native quote. -/
theorem run_financial (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∀ step∈result.progress.executed,Step.Financial cfg.prices step := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have fundingValid := funding_step_financial _ _ _ _ _ _ fundingCall
  have initialValid : ∀ step∈(fundingProgress cfg ⟨impactAfter.world,before.position⟩ funded
      (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens) funding).executed,
      Step.Financial cfg.prices step := by
    intro step member
    simp only [fundingProgress,List.mem_singleton] at member
    subst step
    exact fundingValid
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      exact initialValid
  · simp only [finish,if_neg residual] at finished
    exact payRest_financial _ _ _ _ _ _ _ initialValid finished


/-- The source health fee contains one negative funding contribution; this is not post-payment subtraction. -/
theorem equity_funding_contribution (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets) :
    equity before cfg buckets domain=
      (buckets.collateral*cfg.prices.primary:ℕ)+before.position.pnlUsd+before.position.impactUsd-
      (cfg.healthOtherFeeTokens*cfg.prices.primary:ℕ)-
      ((Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary:ℕ) := by
  simp only [equity,Nat.add_mul,Nat.cast_add]
  ring

def Step.entry (step : Step) : Stage × ℕ := (step.stage,step.costUsd)

theorem payOne_entries (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    next.executed.map Step.entry=progress.executed.map Step.entry++[(stage,cost)] := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  simp [nextProgress,Step.entry]

/-- Returned entries are an exact prefix of the quoted active costs; later costs are retained as skipped. -/
theorem payRest_prefix (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    ∃ done,costs=done++result.skipped ∧
      result.progress.executed.map Step.entry=progress.executed.map Step.entry++done ∧
      (match result.kind with
        | .complete => result.skipped=[]
        | .exceptional stage residual => insolvencyAllowed=true ∧ 0<residual ∧
            ∃ earlier cost,done=earlier++[(stage,cost)]) := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact ⟨[],rfl,by simp,rfl⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have entries := payOne_entries _ _ _ _ _ _ actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact ⟨[(stage,cost)],rfl,entries,rfl,residual,[],cost,rfl⟩
      · rw [if_neg residual] at success
        obtain ⟨done,partition,observed,shape⟩ := ih next success
        refine ⟨(stage,cost)::done,?_,?_,?_⟩
        · rw [partition]; rfl
        · rw [observed,entries,List.append_assoc]; rfl
        · cases kind : result.kind with
          | complete => simpa only [kind] using shape
          | exceptional stopped remaining =>
            rw [kind] at shape
            obtain ⟨allowed,positive,earlier,stoppedCost,last⟩ := shape
            exact ⟨allowed,positive,(stage,cost)::earlier,stoppedCost,by rw [last]; rfl⟩


def Clear (steps : List Step) : Prop := ∀ step∈steps,step.payment.sourceRemainingCostUsd=0
def Policy (result : Result) : Prop := match result.kind with
  | .complete => Clear result.progress.executed
  | .exceptional stopped residual => ∃ earlier last,
      result.progress.executed=earlier++[last] ∧ Clear earlier ∧
      last.stage=stopped ∧ last.payment.sourceRemainingCostUsd=residual

theorem payOne_steps (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    ∃ last,next.executed=progress.executed++[last] ∧ last.stage=stage ∧ last.payment=payment := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  exact ⟨⟨stage,cost,progress.buckets,progress.state,⟨post,progress.state.position⟩,payment⟩,rfl,rfl,rfl⟩

theorem payRest_policy (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result) (prior : Clear progress.executed)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) : Policy result := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact prior
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      obtain ⟨last,entries,lastStage,lastPayment⟩ := payOne_steps _ _ _ _ _ _ actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact ⟨progress.executed,last,entries,prior,lastStage,by rw [lastPayment]⟩
      · rw [if_neg residual] at success
        have zero : payment.sourceRemainingCostUsd=0 := by omega
        have clear : Clear next.executed := by
          intro step member
          rw [entries] at member
          rcases List.mem_append.mp member with old | lastMem
          · exact prior step old
          · have same := List.mem_singleton.mp lastMem
            subst step
            rw [lastPayment,zero]
        exact ih next clear success

/-- Complete results have no positive source residual; exceptional results stop at the first one. -/
theorem run_policy (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) : Policy result := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      refine ⟨[],⟨.funding,funding.funding.feePrimary*cfg.prices.primary,
        addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens,
        ⟨impactAfter.world,before.position⟩,funded,funding.payment⟩,rfl,?_,rfl,rfl⟩
      intro step member
      cases member
  · simp only [finish,if_neg residual] at finished
    have zero : funding.payment.sourceRemainingCostUsd=0 := by omega
    apply payRest_policy _ _ _ _ _ _ _ ?_ finished
    intro step member
    simp only [fundingProgress,List.mem_singleton] at member
    subst step
    exact zero


def primaryNeed (prices : Payment.Prices) (cost : ℕ) : ℕ := (cost+prices.primary-1)/prices.primary
def primaryBudget (cfg : Config) (costs : List (Stage × ℕ)) : ℕ :=
  (costs.map (fun entry=>primaryNeed cfg.prices entry.2)).sum
def preparationTokens (cfg : Config) : ℕ :=
  (Realization.quote cfg.closeBasePnlUsd cfg.side cfg.pnlPrice).paidTokens+
  (Realization.quote cfg.closeImpactUsd cfg.side cfg.pnlPrice).paidTokens
/-- Concrete arithmetic/custody premises. No successful execution or zero-residual certificate is assumed. -/
def SolventBudget (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets) : Prop :=
  PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state ∧
  Admitted (equity before cfg buckets domain) cfg ∧
  (preparationTokens cfg:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset) ∧
  (Funding.quote before.position cfg.latest domain).feePrimary+primaryBudget cfg (remainingCosts cfg) ≤
    buckets.output+buckets.collateral+(match cfg.side with | .primary => preparationTokens cfg | .secondary => 0)
def ExecutionRights (store : Store) (side : Realization.Side) (ids : List CapabilityId) : Prop :=
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId .invoke=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true ∧
  hasAuthority store Funding.holdingIds ownerContext Funding.holdingId .invoke=true ∧
  hasAuthority store Funding.holdingIds ownerContext Funding.holdingId (.changeSupply .margin .claimSecondary)=true ∧
  hasAuthority store ids ownerContext Realization.realizeId .invoke=true ∧
  hasAuthority store ids ownerContext Realization.realizeId (.debit (.margin,.pool,side.asset))=true

theorem fixture_rights (side : Realization.Side) : ExecutionRights (fixtureStore side) side realizationIds := by
  unfold ExecutionRights
  cases side <;> decide

/-- The SUM pool budget constructs both cash legs in source order, using remaining actual custody. -/
theorem preparation_exists (before : Funding.State) (cfg : Config) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)
    (poolBudget : (preparationTokens cfg:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset))
    (invoke : hasAuthority before.world.capabilities ids ownerContext Realization.realizeId .invoke=true)
    (debit : hasAuthority before.world.capabilities ids ownerContext Realization.realizeId
      (.debit (.margin,.pool,cfg.side.asset))=true) :
    ∃ baseAfter base impactAfter impact,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      PaymentSettlement.Compatible ⟨0,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).output,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).collateral,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).secondary⟩
        impactAfter.world.state ∧ impactAfter.world.capabilities=before.world.capabilities ∧
      impactAfter.world.state.balance (.margin,.pool,cfg.side.asset)=
        before.world.state.balance (.margin,.pool,cfg.side.asset)-(preparationTokens cfg:ℚ) := by
  let baseQuote := Realization.quote cfg.closeBasePnlUsd cfg.side cfg.pnlPrice
  let impactQuote := Realization.quote cfg.closeImpactUsd cfg.side cfg.pnlPrice
  have sumBudget : (baseQuote.paidTokens:ℚ)+(impactQuote.paidTokens:ℚ) ≤
      before.world.state.balance (.margin,.pool,cfg.side.asset) := by
    simpa only [preparationTokens,Nat.cast_add] using poolBudget
  have baseFunded : (baseQuote.paidTokens:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset) :=
    le_trans (le_add_of_nonneg_right (Nat.cast_nonneg _)) sumBudget
  obtain ⟨baseAfter,base,baseCall⟩ := Realization.run_exists before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ids
    (fun _=>⟨baseFunded,invoke,debit⟩)
  have baseInfo := Realization.actual_effects _ _ _ _ _ _ _ _ baseCall
  have basePool := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ baseCall).1
  rw [baseInfo.2.2.1] at basePool
  have impactFunded : (impactQuote.paidTokens:ℚ) ≤ baseAfter.world.state.balance (.margin,.pool,cfg.side.asset) := by
    rw [basePool]
    exact (le_sub_iff_add_le).mpr (by simpa only [add_comm] using sumBudget)
  have invokeAfter : hasAuthority baseAfter.world.capabilities ids ownerContext Realization.realizeId .invoke=true := by
    rw [baseInfo.2.1]; exact invoke
  have debitAfter : hasAuthority baseAfter.world.capabilities ids ownerContext Realization.realizeId
      (.debit (.margin,.pool,cfg.side.asset))=true := by rw [baseInfo.2.1]; exact debit
  obtain ⟨impactAfter,impact,impactCall⟩ := Realization.run_exists ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd
    cfg.side cfg.pnlPrice ids (fun _=>⟨impactFunded,invokeAfter,debitAfter⟩)
  have impactInfo := Realization.actual_effects _ _ _ _ _ _ _ _ impactCall
  have impactPool := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ impactCall).1
  rw [impactInfo.2.2.1] at impactPool
  have baseCompatible := payout_compatible _ _ _ _ _ _ _ _ compatible baseCall
  have impactCompatible := payout_compatible ⟨baseAfter.world,before.position⟩ impactAfter cfg.closeImpactUsd cfg.side
    cfg.pnlPrice ids impact (addPayout buckets cfg.side base.paidTokens) baseCompatible impactCall
  refine ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,impactCompatible,
    impactInfo.2.1.trans baseInfo.2.1,?_⟩
  rw [impactPool,basePool]
  simp only [preparationTokens,Nat.cast_add]
  ring


/-- Sufficient primary tokens eliminate secondary spending and economic shortfall, retaining exact capacity. -/
theorem primary_full (prices : Payment.Prices) (input : Payment.Inputs)
    (liquid : primaryNeed prices input.costUsd ≤ input.primaryOutput+input.collateral) :
    (Payment.payCost prices input).sourceRemainingCostUsd=0 ∧
    (Payment.payCost prices input).economicShortfallUsd=0 ∧
    (Payment.payCost prices input).paidSecondary=0 ∧
    (Payment.payCost prices input).floorDustUsd=0 ∧
    (Payment.payCost prices input).outputLeft+(Payment.payCost prices input).collateralLeft+
      primaryNeed prices input.costUsd=input.primaryOutput+input.collateral := by
  have coverage := Payment.sufficient_primary_coverage prices input liquid
  have remaining := Payment.sufficient_primary_remaining_zero prices input liquid
  have buckets := Payment.bucket_reconciliation prices input
  have shortfall : (Payment.payCost prices input).economicShortfallUsd=0 := by
    change input.costUsd-(((Payment.payCost prices input).paidPrimaryOutput+
      (Payment.payCost prices input).paidCollateral)*prices.primary+
      (Payment.payCost prices input).paidSecondary*prices.secondary)=0
    rw [coverage.2.2.1]
    simp only [zero_mul,add_zero]
    exact Nat.sub_eq_zero_of_le coverage.2.2.2
  refine ⟨coverage.1,shortfall,coverage.2.2.1,coverage.2.1,?_⟩
  change (Payment.payCost prices input).primaryRemaining=0 at remaining
  change (Payment.payCost prices input).outputLeft+(Payment.payCost prices input).collateralLeft+
    (Payment.payCost prices input).primaryRequired=input.primaryOutput+input.collateral
  omega

def Step.Covered (prices : Payment.Prices) (step : Step) : Prop :=
  step.payment.sourceRemainingCostUsd=0 ∧ step.payment.economicShortfallUsd=0 ∧
    (step.costUsd:ℚ)≤step.actualPaidUsd prices

theorem step_covered_of_primary (prices : Payment.Prices) (step : Step)
    (financial : Step.Financial prices step)
    (liquid : primaryNeed prices step.costUsd≤step.buckets.output+step.buckets.collateral) :
    Step.Covered prices step := by
  have full := primary_full prices step.input liquid
  have residue : step.payment.sourceRemainingCostUsd=0 := by rw [financial.1]; exact full.1
  have shortfall : step.payment.economicShortfallUsd=0 := by rw [financial.1]; exact full.2.1
  have dust : step.payment.floorDustUsd=0 := by rw [financial.1]; exact full.2.2.2.1
  refine ⟨residue,shortfall,?_⟩
  have reconciled := financial.2.2.2
  rw [residue,dust] at reconciled
  simp only [Nat.cast_zero,add_zero] at reconciled
  calc
    _ ≤ (step.costUsd:ℚ)+(step.payment.ceilDustUsd:ℚ) := le_add_of_nonneg_right (Nat.cast_nonneg _)
    _ = step.actualPaidUsd prices := reconciled

def PayRights (store : Store) : Prop :=
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId .invoke=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true

theorem payOne_exists (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ)
    (compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state)
    (rights : PayRights progress.state.world.capabilities) :
    ∃ next,payOne cfg progress stage cost=.ok (next,Payment.payCost cfg.prices
      ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩) := by
  obtain ⟨post,paid⟩ := PaymentSettlement.run_exists cfg.prices
    ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    progress.state.world.capabilities Funding.payIds progress.state.world.state compatible
    rights.1 rights.2.1 rights.2.2.1 rights.2.2.2
  exact ⟨nextProgress progress stage cost post _,(payOne_ok_iff _ _ _ _ _ _).mpr ⟨post,paid,rfl⟩⟩

theorem payRest_exists (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ))
    (compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state)
    (rights : PayRights progress.state.world.capabilities)
    (liquid : primaryBudget cfg costs≤progress.buckets.output+progress.buckets.collateral)
    (prior : ∀ step∈progress.executed,Step.Covered cfg.prices step) :
    ∃ result,payRest cfg insolvencyAllowed base impact progress costs=.ok result ∧ result.kind=.complete ∧
      ∀ step∈result.progress.executed,Step.Covered cfg.prices step := by
  induction costs generalizing progress with
  | nil => exact ⟨⟨progress,.complete,[],base,impact⟩,rfl,rfl,prior⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    let input : Payment.Inputs := ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    let quote := Payment.payCost cfg.prices input
    have budget : primaryNeed cfg.prices cost+primaryBudget cfg tail≤
        progress.buckets.output+progress.buckets.collateral := by simpa [primaryBudget] using liquid
    have headLiquid : primaryNeed cfg.prices cost≤progress.buckets.output+progress.buckets.collateral := by omega
    have full := primary_full cfg.prices input headLiquid
    obtain ⟨next,actual⟩ := payOne_exists cfg progress stage cost compatible rights
    obtain ⟨post,paid,nextEq⟩ := (payOne_ok_iff _ _ _ _ _ _).mp actual
    have nextCompatible : PaymentSettlement.Compatible
        ⟨0,next.buckets.output,next.buckets.collateral,next.buckets.secondary⟩ next.state.world.state := by
      rw [nextEq]
      exact payment_compatible _ _ _ _ _ paid
    have caps := (payOne_preserves _ _ _ _ _ _ actual).2.1
    have nextRights : PayRights next.state.world.capabilities := by rw [caps]; exact rights
    have nextLiquid : primaryBudget cfg tail≤next.buckets.output+next.buckets.collateral := by
      rw [nextEq]
      change primaryBudget cfg tail≤quote.outputLeft+quote.collateralLeft
      have capacity := full.2.2.2.2
      change quote.outputLeft+quote.collateralLeft+primaryNeed cfg.prices cost=
        progress.buckets.output+progress.buckets.collateral at capacity
      omega
    have newFinancial := ordinary_step_financial cfg progress stage cost post quote paid
    have newCovered := step_covered_of_primary cfg.prices _ newFinancial headLiquid
    have allCovered : ∀ step∈next.executed,Step.Covered cfg.prices step := by
      rw [nextEq]
      intro step member
      simp only [nextProgress,List.mem_append,List.mem_singleton] at member
      rcases member with old | rfl
      · exact prior step old
      · exact newCovered
    obtain ⟨result,recurse,complete,covered⟩ := ih next nextCompatible nextRights nextLiquid allCovered
    refine ⟨result,?_,complete,covered⟩
    rw [payRest,actual]
    simp only [bind,Except.bind]
    have zero : quote.sourceRemainingCostUsd=0 := full.1
    rw [show (Payment.payCost cfg.prices input).sourceRemainingCostUsd=0 from zero]
    exact recurse


/-- Concrete admission, SUM pool custody, SUM rounded primary custody and genuine rights construct
actual execution and actual economic coverage. Source residual zero is never used as a coverage premise. -/
theorem constructive_solvency (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (budget : SolventBudget before cfg domain buckets)
    (rights : ExecutionRights before.world.capabilities cfg.side ids) :
    ∃ result,run before cfg domain buckets ids=.ok result ∧ result.kind=.complete ∧
      (∀ step∈result.progress.executed,Step.Covered cfg.prices step) ∧
      (∀ step∈result.progress.executed,Step.Financial cfg.prices step) ∧
      ∀ cell,0≤result.progress.state.world.state.balance cell := by
  obtain ⟨pi,po,pc,ps,hi,hs,ri,rd⟩ := rights
  obtain ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,preparedCompatible,caps,poolRemaining⟩ :=
    preparation_exists before cfg buckets ids budget.1 budget.2.2.1 ri rd
  let prepared : Funding.State := ⟨impactAfter.world,before.position⟩
  let preparedBuckets := addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens
  let quote := Funding.quote before.position cfg.latest domain
  let input := Funding.paymentInput cfg.prices quote preparedBuckets
  have baseObservation := (Realization.actual_effects _ _ _ _ _ _ _ _ baseCall).2.2.1
  have impactObservation := (Realization.actual_effects _ _ _ _ _ _ _ _ impactCall).2.2.1
  have preparedLiquid : quote.feePrimary+primaryBudget cfg (remainingCosts cfg)≤
      preparedBuckets.output+preparedBuckets.collateral := by
    dsimp only [preparedBuckets]
    rw [baseObservation,impactObservation]
    cases sideEq : cfg.side <;> simpa [quote,sideEq,addPayout,preparationTokens,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm] using budget.2.2.2
  have required : primaryNeed cfg.prices input.costUsd=quote.feePrimary :=
    Funding.required_exact cfg.prices quote preparedBuckets
  have headLiquid : primaryNeed cfg.prices input.costUsd≤preparedBuckets.output+preparedBuckets.collateral := by
    rw [required]; omega
  have full := primary_full cfg.prices input headLiquid
  have preparedRights : ExecutionRights prepared.world.capabilities cfg.side ids := by
    rw [caps]
    exact ⟨pi,po,pc,ps,hi,hs,ri,rd⟩
  obtain ⟨pi2,po2,pc2,ps2,hi2,hs2,_,_⟩ := preparedRights
  obtain ⟨funded,funding,fundingCall⟩ := Funding.run_exists prepared cfg.latest domain cfg.prices preparedBuckets
    cfg.holdingConfigured Funding.payIds Funding.holdingIds preparedCompatible pi2 po2 pc2 ps2 hi2 hs2
    (by intro positive; rw [full.2.2.1] at positive; omega)
  have fundingInfo := Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall
  have observation := fundingInfo.2.2.1
  let progress := fundingProgress cfg prepared funded preparedBuckets funding
  have compatible : PaymentSettlement.Compatible
      ⟨0,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩ progress.state.world.state :=
    funding_compatible _ _ _ _ _ _ fundingCall
  have paidRights : PayRights progress.state.world.capabilities := by
    change PayRights funded.world.capabilities
    rw [fundingInfo.2.1]
    exact ⟨pi2,po2,pc2,ps2⟩
  have liquid : primaryBudget cfg (remainingCosts cfg)≤progress.buckets.output+progress.buckets.collateral := by
    change primaryBudget cfg (remainingCosts cfg)≤funding.payment.outputLeft+funding.payment.collateralLeft
    rw [observation]
    change primaryBudget cfg (remainingCosts cfg)≤(Payment.payCost cfg.prices input).outputLeft+
      (Payment.payCost cfg.prices input).collateralLeft
    have capacity := full.2.2.2.2
    rw [required] at capacity
    change (Payment.payCost cfg.prices input).outputLeft+(Payment.payCost cfg.prices input).collateralLeft+
      quote.feePrimary=preparedBuckets.output+preparedBuckets.collateral at capacity
    omega
  have firstFinancial := funding_step_financial cfg prepared funded domain preparedBuckets funding fundingCall
  have firstCovered := step_covered_of_primary cfg.prices _ firstFinancial
    (by rw [observation]; change primaryNeed cfg.prices input.costUsd≤preparedBuckets.output+preparedBuckets.collateral; exact headLiquid)
  have prior : ∀ step∈progress.executed,Step.Covered cfg.prices step := by
    intro step member
    simp only [progress,fundingProgress,List.mem_singleton] at member
    subst step
    exact firstCovered
  obtain ⟨result,remainder,complete,covered⟩ := payRest_exists cfg (allowed before cfg) base impact progress
    (remainingCosts cfg) compatible paidRights liquid prior
  have zero : funding.payment.sourceRemainingCostUsd=0 := by rw [observation]; exact full.1
  have finished : finish before cfg base impact prepared funded preparedBuckets funding=.ok result := by
    rw [finish,zero]
    exact remainder
  have binding : decide (PaymentSettlement.Compatible
      ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)=true := by simpa using budget.1
  have notDenied : (cfg.liquidation && !(liquidatable (equity before cfg buckets domain) cfg))=false := by
    rcases budget.2.1 with liq | health
    · simp [liq]
    · simp [health]
  have executed : run before cfg domain buckets ids=.ok result := by
    simp only [run,binding,notDenied,Bool.not_true,Bool.false_eq_true,ite_false,
      baseCall,impactCall,Except.mapError,bind,Except.bind]
    have canonicalFunding := fundingCall
    dsimp only [prepared,preparedBuckets] at canonicalFunding
    rw [canonicalFunding]
    exact finished
  exact ⟨result,executed,complete,covered,run_financial _ _ _ _ _ _ executed,
    result.progress.state.world.state.nonneg⟩


def Fees.pending (fees : Fees) : ℕ × ℕ × Funding.Factors :=
  (fees.pendingClaimPrimary,fees.pendingClaimSecondary,fees.latest)
theorem payOne_pending (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    next.fees.pending=progress.fees.pending := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  change (if stage=.fees && !(payment.sourceRemainingCostUsd=0 && payment.paidSecondary=0)
    then emptyFees progress.fees else progress.fees).pending=progress.fees.pending
  split <;> rfl

theorem payRest_pending (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    result.progress.fees.pending=progress.fees.pending := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    rfl
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have step := payOne_pending _ _ _ _ _ _ actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact step
      · rw [if_neg residual] at success
        exact (ih next success).trans step

/-- Zeroing fees never loses pending owner funding claims or their latest-factor receipt. -/
theorem run_pending (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    result.progress.fees.pending=
      ((Funding.quote before.position cfg.latest domain).pendingClaimPrimary,
       (Funding.quote before.position cfg.latest domain).pendingClaimSecondary,cfg.latest) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.2.1
  have projected : result.progress.fees.pending=(initialFees funding.funding cfg).pending := by
    by_cases residual : 0<funding.payment.sourceRemainingCostUsd
    · simp only [finish,if_pos residual] at finished
      cases allowedEq : allowed before cfg with
      | false => simp [allowedEq] at finished
      | true =>
        simp only [allowedEq,ite_true] at finished
        obtain rfl := Except.ok.inj finished
        rfl
    · simp only [finish,if_neg residual] at finished
      exact payRest_pending _ _ _ _ _ _ _ finished
  rw [projected,observation]
  rfl

/-- The returned trace is an exact active-cost prefix; exceptional success requires actual full-size eligibility. -/
theorem run_prefix (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∃ done,((Stage.funding,(Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary)::
      remainingCosts cfg)=done++result.skipped ∧ result.progress.executed.map Step.entry=done ∧
      (match result.kind with
        | .complete => result.skipped=[]
        | .exceptional stage residual => before.position.sizeUsd=cfg.sizeDeltaUsd ∧
            (cfg.liquidation=true ∨ cfg.secondaryAdl=true) ∧ 0<residual ∧
            ∃ earlier cost,done=earlier++[(stage,cost)]) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.2.1
  let entry := (Stage.funding,funding.funding.feePrimary*cfg.prices.primary)
  have entryEq : entry=(Stage.funding,(Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary) := by
    dsimp only [entry]
    rw [observation]; rfl
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      have eligible := (allowed_iff before cfg).mp allowedEq
      refine ⟨[entry],?_,?_,eligible.1,eligible.2,residual,[],entry.2,?_⟩
      · rw [entryEq]; rfl
      · rfl
      · rfl
  · simp only [finish,if_neg residual] at finished
    obtain ⟨done,partition,observed,shape⟩ := payRest_prefix _ _ _ _ _ _ _ finished
    refine ⟨entry::done,?_,?_,?_⟩
    · rw [← entryEq,partition]; rfl
    · simpa only [fundingProgress,List.map_cons,List.map_nil,Step.entry,List.cons_append,List.nil_append] using observed
    · cases kind : result.kind with
      | complete => simpa only [kind] using shape
      | exceptional stopped remaining =>
        rw [kind] at shape
        obtain ⟨eligible,positive,earlier,cost,last⟩ := shape
        have eligibility := (allowed_iff before cfg).mp eligible
        exact ⟨eligibility.1,eligibility.2,positive,entry::earlier,cost,by rw [last]; rfl⟩


/-- Adjacency of the actual pre/post worlds recorded by the selected payment prefix. -/
def Chain (before after : Funding.State) : List Step → Prop
  | [] => before=after
  | step::tail => step.before=before ∧ Chain step.after after tail

theorem chain_append_step (start middle finish : Funding.State) (steps : List Step) (last : Step)
    (prior : Chain start middle steps) (beforeEq : last.before=middle) (afterEq : last.after=finish) :
    Chain start finish (steps++[last]) := by
  induction steps generalizing start with
  | nil =>
    change start=middle at prior
    subst start
    exact ⟨beforeEq,afterEq⟩
  | cons head tail ih => exact ⟨prior.1,ih head.after prior.2⟩

theorem payOne_chain (cfg : Config) (start : Funding.State) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (prior : Chain start progress.state progress.executed)
    (success : payOne cfg progress stage cost=.ok (next,payment)) : Chain start next.state next.executed := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  exact chain_append_step _ _ _ _ _ prior rfl rfl

theorem payRest_chain (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (start : Funding.State) (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (prior : Chain start progress.state progress.executed)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    Chain start result.progress.state result.progress.executed := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact prior
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have step := payOne_chain _ _ _ _ _ _ _ prior actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact step
      · rw [if_neg residual] at success
        exact ih next step success

theorem finish_chain (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt)
    (result : Result) (success : finish before cfg base impact prepared funded buckets funding=.ok result) :
    Chain prepared result.progress.state result.progress.executed := by
  have initial : Chain prepared (fundingProgress cfg prepared funded buckets funding).state
      (fundingProgress cfg prepared funded buckets funding).executed := ⟨rfl,rfl⟩
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at success
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at success
    | true =>
      simp only [allowedEq,ite_true] at success
      obtain rfl := Except.ok.inj success
      exact initial
  · simp only [finish,if_neg residual] at success
    exact payRest_chain _ _ _ _ _ _ _ _ initial success

/-- The chain's initial world is the actual two-cash-leg result, not an unrelated ledger. -/
theorem run_chain (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∃ baseAfter base impactAfter impact,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      Chain ⟨impactAfter.world,before.position⟩ result.progress.state result.progress.executed := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  exact ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,finish_chain _ _ _ _ _ _ _ _ _ finished⟩


def Stage.rank : Stage → ℕ | .funding => 0 | .pnl => 1 | .fees => 2 | .impact => 3 | .diff => 4
/-- Fixed source order, independently of the observed cost magnitudes. -/
theorem remaining_ordered (cfg : Config) :
    ((remainingCosts cfg).map (fun entry=>entry.1.rank)).Pairwise (·<·) := by
  by_cases pnl : cfg.closeBasePnlUsd<0 <;> by_cases impact : cfg.closeImpactUsd<0 <;>
    by_cases diff : 0<cfg.impactDiffUsd <;> simp [remainingCosts,pnl,impact,diff,Stage.rank]

theorem payRest_refusal (cfg : Config) (base impact : Realization.Receipt) (progress next : Progress)
    (stage : Stage) (cost : ℕ) (tail : List (Stage × ℕ)) (payment : Payment.Result)
    (paid : payOne cfg progress stage cost=.ok (next,payment))
    (shortfall : 0<payment.sourceRemainingCostUsd) :
    payRest cfg false base impact progress ((stage,cost)::tail)=
      .error (.insufficientFundsToPayForCosts payment.sourceRemainingCostUsd stage.label) := by
  rw [payRest,paid]
  simp only [bind,Except.bind,if_pos shortfall,Bool.false_eq_true,ite_false]
  rfl

theorem payRest_exception_fees (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result) (stage : Stage) (residual : ℕ)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result)
    (exceptional : result.kind=.exceptional stage residual) :
    result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0 := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    cases exceptional
  | cons head tail ih =>
    rcases head with ⟨current,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress current cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      by_cases positive : 0<payment.sourceRemainingCostUsd
      · rw [if_pos positive] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact ⟨rfl,rfl⟩
      · rw [if_neg positive] at success
        exact ih next success

theorem run_exception_fees (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result) (stage : Stage) (residual : ℕ)
    (success : run before cfg domain buckets ids=.ok result) (exceptional : result.kind=.exceptional stage residual) :
    result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0 := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  by_cases positive : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos positive] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      exact ⟨rfl,rfl⟩
  · simp only [finish,if_neg positive] at finished
    exact payRest_exception_fees _ _ _ _ _ _ _ _ _ finished exceptional

/-- Selected prefix correctness; economic coverage is the separate constructive_solvency theorem. -/
theorem liquidation_correct (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    Admitted (equity before cfg buckets domain) cfg ∧ Policy result ∧
    (∀ step∈result.progress.executed,Step.Financial cfg.prices step) ∧
    result.progress.fees.pending=
      ((Funding.quote before.position cfg.latest domain).pendingClaimPrimary,
       (Funding.quote before.position cfg.latest domain).pendingClaimSecondary,cfg.latest) ∧
    (∀ stage residual,result.kind=.exceptional stage residual →
      before.position.sizeUsd=cfg.sizeDeltaUsd ∧ (cfg.liquidation=true ∨ cfg.secondaryAdl=true) ∧
      0<residual ∧ result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0) := by
  refine ⟨(run_execution _ _ _ _ _ _ success).2.1,run_policy _ _ _ _ _ _ success,
    run_financial _ _ _ _ _ _ success,run_pending _ _ _ _ _ _ success,?_⟩
  intro stage residual exceptional
  obtain ⟨done,_,_,shape⟩ := run_prefix _ _ _ _ _ _ success
  rw [exceptional] at shape
  have fees := run_exception_fees _ _ _ _ _ _ _ _ success exceptional
  exact ⟨shape.1,shape.2.1,shape.2.2.1,fees⟩
end DefiKernel.Margin.Close
