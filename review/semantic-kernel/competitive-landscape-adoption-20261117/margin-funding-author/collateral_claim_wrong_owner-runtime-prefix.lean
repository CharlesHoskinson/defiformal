import DefiKernel.Margin.PaymentSettlement

/-! Source-stage funding quote/payment. Pending funding claims/snapshots are receipt data until caller commit. -/
namespace DefiKernel.Margin.Funding
open DefiKernel.Typed
def precision : ℕ := 10^45
structure Factors where
  fee : ℕ
  claimPrimary : ℕ
  claimSecondary : ℕ
  deriving Repr, DecidableEq
structure Position where
  sizeUsd : ℕ
  pnlUsd : ℤ
  impactUsd : ℤ
  snapshots : Factors
  deriving Repr, DecidableEq
def Admissible (position : Position) (latest : Factors) : Prop :=
  position.snapshots.fee ≤ latest.fee ∧ position.snapshots.claimPrimary ≤ latest.claimPrimary ∧
    position.snapshots.claimSecondary ≤ latest.claimSecondary
instance (position : Position) (latest : Factors) : Decidable (Admissible position latest) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))
structure Quote where
  feePrimary : ℕ
  pendingClaimPrimary : ℕ
  pendingClaimSecondary : ℕ
  latest : Factors
  deriving Repr, DecidableEq
def quote (position : Position) (latest : Factors) (_domain : Admissible position latest) : Quote :=
  ⟨(position.sizeUsd*(latest.fee-position.snapshots.fee)+precision-1)/precision,
    position.sizeUsd*(latest.claimPrimary-position.snapshots.claimPrimary)/precision,
    position.sizeUsd*(latest.claimSecondary-position.snapshots.claimSecondary)/precision,latest⟩
structure Buckets where
  output : ℕ
  collateral : ℕ
  secondary : ℕ
  deriving Repr, DecidableEq
def paymentInput (prices : Payment.Prices) (q : Quote) (b : Buckets) : Payment.Inputs :=
  ⟨q.feePrimary*prices.primary,b.output,b.collateral,b.secondary⟩
structure State where
  world : World
  position : Position
structure Receipt where
  funding : Quote
  payment : Payment.Result
  holdingCollateralClaimSecondary : ℕ
  insufficientPrimaryFundingPayment : Bool
  deriving Repr, DecidableEq
inductive Refusal where
  | typed (reason : Typed.Refusal)
  | emptyHoldingAddress
  deriving Repr, DecidableEq

def holdingId : OperationId := ⟨1⟩
def holdingTemplate (quantity : ℕ) : Op where
  signature:=[]
  domain:=.margin
  partyArity:=0
  guard:=.lit true
  deltas:=[⟨.claimSecondary,ref .claimSecondary .owner,.lit quantity⟩]
  supplyDeltas:=[⟨.margin,.claimSecondary,.lit quantity⟩]
  stateReads:=[]
  envReads:=[]
  writes:=[packedRef .claimSecondary .owner]
private def registry (prices : Payment.Prices) (i : Payment.Inputs) : Registry Party Asset Domain :=
  fun id => if id=PaymentSettlement.payId then some (PaymentSettlement.template prices i)
    else if id=holdingId then some (holdingTemplate (Payment.payCost prices i).paidSecondary) else none
def holdingRequest (ids : List CapabilityId) : Request Party Asset Domain :=
  ⟨holdingId,[],[],ids,some .owner⟩
private def holdingRegistry (quantity : ℕ) : Registry Party Asset Domain :=
  fun id => if id=holdingId then some (holdingTemplate quantity) else none
def holdingExecute (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (holdingRegistry quantity) store ctx (fun _=>none) 0 (holdingRequest ids) pre
def settleHolding (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) : Except Refusal World :=
  if 0 < quantity then
    if !configured then .error .emptyHoldingAddress else
      (holdingExecute quantity paid.capabilities ctx ids paid.state).mapError Refusal.typed
  else .ok paid
def run (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (holdingConfigured : Bool)
    (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId) :
    Except Refusal (State × Receipt) := do
  let funding := quote before.position latest domain
  let i := paymentInput prices funding buckets
  let (paid,payment) ← (PaymentSettlement.run prices i before.world.capabilities ctx payIds
    before.world.state).mapError Refusal.typed
  let after ← settleHolding payment.paidSecondary holdingConfigured paid ctx holdingIds
  return (⟨after,before.position⟩,⟨funding,payment,payment.paidSecondary,
    decide (payment.paidPrimaryOutput+payment.paidCollateral<funding.feePrimary)⟩)
def grants : List (Grant Party Asset Domain) := PaymentSettlement.grants ++ [
  ⟨.owner,.margin,holdingId,.invoke⟩,⟨.owner,.margin,holdingId,.changeSupply .margin .claimSecondary⟩]
def fixtureStore : Store := ⟨grants.map (fun grant=>⟨grant,true⟩)⟩
def payIds : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩,⟨3⟩]
def holdingIds : List CapabilityId := [⟨4⟩,⟨5⟩]
def provisioned (position : Position) (latest : Factors) (domain : Admissible position latest)
    (prices : Payment.Prices) (buckets : Buckets) : Except AuthorityFailure Store :=
  grants.foldlM (fun store grant => do
    let (_,next) ← issueCapability (registryAuthorityConfig
      (registry prices (paymentInput prices (quote position latest domain) buckets)) (fun _=>.admin))
      ⟨.admin,.margin⟩ store grant
    return next) .empty


def signedFundingCharge (prices : Payment.Prices) (funding : Quote) : ℚ :=
  -(funding.feePrimary:ℚ)*(prices.primary:ℚ)
def markedCollateralEquity (state : State) (prices : Payment.Prices) : ℚ :=
  state.world.state.balance (.margin,.position,.primary)*(prices.primary:ℚ)+
    (state.position.pnlUsd:ℚ)+(state.position.impactUsd:ℚ)

end DefiKernel.Margin.Funding
namespace DefiKernel.Margin.FundingAudit
open DefiKernel.Typed
private def ledger (collateral secondary : Nat) : Ledger where
  balance
    | (.margin,.position,.primary) => collateral
    | (.margin,.output,.secondary) => secondary
    | (.margin,.owner,.claimPrimary) => 7
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | (.margin,.pool,.primary) => 100
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def position : Funding.Position := ⟨Funding.precision+1,10,-1,⟨0,0,0⟩⟩
private def latest : Funding.Factors := ⟨1,2,3⟩
private theorem domain : Funding.Admissible position latest := by decide
private def prices : Payment.Prices := ⟨3,2,by decide,by decide⟩
private def before (collateral secondary : Nat) : Funding.State :=
  ⟨⟨ledger collateral secondary,Funding.fixtureStore⟩,position⟩
private def run (collateral secondary : Nat) (holding : Bool) := Funding.run
  (before collateral secondary) latest domain prices ⟨0,collateral,secondary⟩ holding ownerContext
  Funding.payIds Funding.holdingIds
private def refused (actual : Except Funding.Refusal (Funding.State × Funding.Receipt))
    (expected : Funding.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def custom (payIds holdingIds : List CapabilityId) (configured : Bool := true)
    (ctx : InvocationContext Party Domain := ownerContext) :=
  Funding.run (before 0 3) latest domain prices ⟨0,0,3⟩ configured ctx payIds holdingIds
private def checks : List (String × Bool) := [
  ("real_joint_provisioning",decide (Funding.provisioned position latest domain prices ⟨0,3,0⟩=
    .ok Funding.fixtureStore)),
  ("fee_paid_pending_claims_and_snapshots_preserved",match run 3 0 false with
    | .error _ => false
    | .ok (after,r) => decide (r.funding.feePrimary=2 ∧ r.funding.pendingClaimPrimary=2 ∧
        r.funding.pendingClaimSecondary=3 ∧ r.funding.latest=latest ∧
        after.position=position ∧ after.world.state.balance (.margin,.position,.primary)=1 ∧
        after.world.state.balance (.margin,.costRecipient,.primary)=2 ∧
        after.world.state.balance (.margin,.owner,.claimPrimary)=7 ∧
        after.world.state.balance (.margin,.owner,.claimSecondary)=11)),
  ("positive_pnl_is_not_automatic_spendable_cash",match run 0 0 false with
    | .error _ => false
    | .ok (after,r) => decide (after.position.pnlUsd=10 ∧ r.payment.sourceRemainingCostUsd=6 ∧
        r.payment.economicShortfallUsd=6 ∧ after.world.state.balance (.margin,.costRecipient,.primary)=0)),
  ("secondary_payment_records_separate_holding_claim",match run 0 3 true with
    | .error _ => false
    | .ok (after,r) => decide (r.payment.paidSecondary=3 ∧ r.payment.sourceRemainingCostUsd=0 ∧
        r.holdingCollateralClaimSecondary=3 ∧ r.insufficientPrimaryFundingPayment=true ∧
        after.world.state.balance (.margin,.costRecipient,.secondary)=3 ∧
        after.world.state.balance (.margin,.holding,.claimSecondary)=8 ∧
        after.world.state.balance (.margin,.pool,.primary)=100 ∧
        after.world.state.balance (.margin,.owner,.claimSecondary)=11)),
  ("secondary_payment_requires_holding_configuration",refused (run 0 3 false) .emptyHoldingAddress),
  ("missing_holding_invoke",refused (custom Funding.payIds [⟨5⟩]) (.typed .unauthorizedInvoke)),
  ("missing_holding_supply",refused (custom Funding.payIds [⟨4⟩]) (.typed .unauthorizedSupply)),
  ("holding_configuration_precedes_holding_invoke",refused (custom Funding.payIds [] false) .emptyHoldingAddress),
  ("payment_invoke_precedes_holding_configuration",refused (custom [] [] false) (.typed .unauthorizedInvoke)),
  ("secondary_debit_precedes_holding_configuration",refused (custom [⟨0⟩,⟨1⟩,⟨2⟩] [] false) (.typed .unauthorizedDebit)),
  ("wrong_actor_precedes_payment",refused (custom Funding.payIds Funding.holdingIds true ⟨.pool,.margin⟩)
    (.typed .actorMismatch)),
  ("wrong_preledger_bucket",refused (Funding.run (before 0 3) latest domain prices ⟨0,0,0⟩ false
    ownerContext Funding.payIds Funding.holdingIds) (.typed .guard)),
  ("secondary_payment_preserves_physical_totals",match run 0 3 true with
    | .error _ => false | .ok (after,_) => decide (total after.world.state .margin .primary=100 ∧
      total after.world.state .margin .secondary=3 ∧ total after.world.state .margin .claimPrimary=7 ∧
      total after.world.state .margin .claimSecondary=19)),
  ("primary_payment_needs_no_holding_rights_or_configuration",match Funding.run (before 3 0) latest domain
      prices ⟨0,3,0⟩ false ownerContext Funding.payIds [] with
    | .error _ => false | .ok (after,r) => decide (r.holdingCollateralClaimSecondary=0 ∧
      r.insufficientPrimaryFundingPayment=false ∧ after.world.state.balance (.margin,.holding,.claimSecondary)=5)),
  ("partial_secondary_distinguishes_three_observations",match Funding.run (before 0 1) latest domain prices
      ⟨0,0,1⟩ true ownerContext Funding.payIds Funding.holdingIds with
    | .error _ => false | .ok (after,r) => decide (r.insufficientPrimaryFundingPayment=true ∧
      r.payment.sourceRemainingCostUsd=4 ∧ r.payment.economicShortfallUsd=4 ∧
      r.holdingCollateralClaimSecondary=1 ∧ after.world.state.balance (.margin,.holding,.claimSecondary)=6)),
  ("quote_keeps_latest_factors_in_receipt",decide ((Funding.quote position latest domain).latest=latest)),
  ("zero_delta_quote_is_zero",decide (let q:=Funding.quote position ⟨0,0,0⟩ (by decide);
      q.feePrimary=0 ∧ q.pendingClaimPrimary=0 ∧ q.pendingClaimSecondary=0)),
  ("monotonic_snapshot_domain_is_not_a_silent_unsigned_subtraction",decide
    (¬ Funding.Admissible {position with snapshots:=⟨2,0,0⟩} latest)),
  ("zero_size_quote_is_zero",decide (let q:=Funding.quote {position with sizeUsd:=0} latest (by decide);
      q.feePrimary=0 ∧ q.pendingClaimPrimary=0 ∧ q.pendingClaimSecondary=0)),
  ("actual_signed_equity_fee_not_double_counted",match run 3 0 false with
    | .error _ => false | .ok (after,r) => decide (Funding.markedCollateralEquity (before 3 0) prices=18 ∧
      Funding.markedCollateralEquity after prices=12 ∧ Funding.signedFundingCharge prices r.funding= -6 ∧
      Funding.markedCollateralEquity after prices=Funding.markedCollateralEquity (before 3 0) prices+
        Funding.signedFundingCharge prices r.funding)),
  ("secondary_receipt_retains_claims_even_with_positive_source_residual",match Funding.run (before 0 1)
      latest domain prices ⟨0,0,1⟩ true ownerContext Funding.payIds Funding.holdingIds with
    | .error _ => false | .ok (after,r) => decide (r.funding.pendingClaimPrimary=2 ∧
      r.funding.pendingClaimSecondary=3 ∧ after.position.snapshots=position.snapshots ∧
      after.position.sizeUsd=position.sizeUsd ∧ after.position.impactUsd= -1))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first funding controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate funding controls")
  let q:=Funding.quote position latest domain
  IO.println s!"FUNDING_QUOTE {q.feePrimary} {q.pendingClaimPrimary} {q.pendingClaimSecondary}"
  match run 0 3 true with
  | .error reason => IO.println s!"FUNDING_OBSERVATION refused {repr reason}"
  | .ok (after,r) => IO.println s!"FUNDING_OBSERVATION {after.world.state.balance (.margin,.output,.secondary)} {after.world.state.balance (.margin,.costRecipient,.secondary)} {after.world.state.balance (.margin,.holding,.claimSecondary)} {after.world.state.balance (.margin,.owner,.claimSecondary)} {r.payment.sourceRemainingCostUsd} {r.payment.economicShortfallUsd} {r.insufficientPrimaryFundingPayment}"
  for (name,passed) in checks do IO.println s!"FUNDING_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first funding comparison")
  IO.println s!"FUNDING_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Margin.FundingAudit