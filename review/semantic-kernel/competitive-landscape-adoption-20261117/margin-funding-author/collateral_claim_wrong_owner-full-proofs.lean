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


/-- Both obligations are in raw token units: ceil for fees, floor for pending funding claims. -/
theorem fee_rounding (position : Position) (latest : Factors) (domain : Admissible position latest) :
    position.sizeUsd*(latest.fee-position.snapshots.fee) ≤
      (quote position latest domain).feePrimary*precision ∧
    (quote position latest domain).feePrimary*precision <
      position.sizeUsd*(latest.fee-position.snapshots.fee)+precision := by
  exact Payment.primary_rounding ⟨precision,1,by norm_num [precision],by decide⟩
    ⟨position.sizeUsd*(latest.fee-position.snapshots.fee),0,0,0⟩

theorem claim_rounding (size difference : ℕ) :
    (size*difference/precision)*precision ≤ size*difference ∧
    size*difference < (size*difference/precision+1)*precision := by
  have positive : 0 < precision := by norm_num [precision]
  have remainder := Nat.mod_lt (size*difference) positive
  have division := Nat.div_add_mod (size*difference) precision
  rw [Nat.mul_comm] at division
  constructor
  · omega
  · rw [Nat.add_mul]; omega

/-- Converting the already-rounded funding token fee to USD creates no further primary dust. -/
theorem required_exact (prices : Payment.Prices) (q : Quote) (b : Buckets) :
    (Payment.payCost prices (paymentInput prices q b)).primaryRequired=q.feePrimary := by
  have bounds := Payment.primary_rounding prices (paymentInput prices q b)
  change q.feePrimary*prices.primary ≤ _ ∧ _ < q.feePrimary*prices.primary+prices.primary at bounds
  have lower := Nat.le_of_mul_le_mul_right bounds.1 prices.primary_pos
  have upper : (Payment.payCost prices (paymentInput prices q b)).primaryRequired < q.feePrimary+1 := by
    apply (Nat.mul_lt_mul_right prices.primary_pos).mp
    simpa only [Nat.add_mul,one_mul] using bounds.2
  omega

def holdingEvaluated (quantity : ℕ) : Evaluated Party Asset Domain :=
  ⟨true,[((.margin,.holding,.claimSecondary),(quantity:ℚ))],
    [((.margin,.claimSecondary),(quantity:ℚ))],[],[],[],[],[(.margin,.holding,.claimSecondary)]⟩
theorem holding_evaluate (quantity : ℕ) (pre : Ledger) (ctx : InvocationContext Party Domain) :
    (holdingTemplate quantity).evaluate ⟨pre,(fun _=>none),ctx.principal,[],Args.nil,0⟩ =
      .ok (holdingEvaluated quantity) := by
  simp [Template.evaluate,Template.requiredStateReads,Template.requiredEnvReads,
    holdingTemplate,ref,packedRef,Expr.eval,Expr.stateReads,Expr.envReads,
    resolveRefs,CellRef.resolve,PartyRef.resolve,holdingEvaluated,
    bind,Except.bind,pure,Except.pure]

theorem holding_ok_iff (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger) (post : World) :
    holdingExecute quantity store ctx ids pre = .ok post ↔
      ctx.principal=.owner ∧ hasAuthority store ids ctx holdingId .invoke=true ∧
      (holdingEvaluated quantity).Valid store ctx (holdingRequest ids) pre ∧
      post.capabilities=store ∧ ∀ cell,post.state.balance cell=pre.balance cell+
        (holdingEvaluated quantity).effect cell := by
  have correspondence := Typed.execute_ok_iff (holdingRegistry quantity) store ctx (fun _=>none) 0
    (holdingRequest ids) pre post
  constructor
  · intro success
    obtain ⟨selected,registered,actor,dom,arity,args,checked,invoke,e,observed,
      valid,capabilities,balances⟩ := correspondence.mp success
    have selectedEq : selected=holdingTemplate quantity := by
      simpa [holdingRegistry,holdingRequest] using registered.symm
    subst selected
    have argsEq : args=Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have same : e=holdingEvaluated quantity :=
      Except.ok.inj (observed.symm.trans (holding_evaluate quantity pre ctx))
    subst e
    exact ⟨by simpa [holdingRequest,eq_comm] using actor,invoke,valid,capabilities,balances⟩
  · rintro ⟨bound,invoke,valid,capabilities,balances⟩
    apply correspondence.mpr
    refine ⟨holdingTemplate quantity,?_,?_,?_,rfl,Args.nil,rfl,invoke,
      holdingEvaluated quantity,holding_evaluate quantity pre ctx,valid,capabilities,balances⟩
    · simp [holdingRegistry,holdingRequest]
    · simp [holdingRequest,bound]
    · cases ctx.domain; rfl

theorem holding_effect (quantity : ℕ) (cell : Cell Party Asset Domain) :
    (holdingEvaluated quantity).effect cell =
      if (.margin,.holding,.claimSecondary)=cell then (quantity:ℚ) else 0 := by
  simp [Evaluated.effect,holdingEvaluated]

theorem holding_valid (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger)
    (authority : hasAuthority store ids ctx holdingId (.changeSupply .margin .claimSecondary)=true) :
    (holdingEvaluated quantity).Valid store ctx (holdingRequest ids) pre := by
  refine ⟨rfl,?_,rfl,?_,?_,?_,?_,?_,?_⟩
  · simp [Evaluated.stateReadsOK,holdingEvaluated]
  · have domain : ctx.domain=.margin := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨by simp [holdingEvaluated],?_,?_⟩
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    rw [holding_effect] at negative
    split at negative
    · exact (not_lt_of_ge (Nat.cast_nonneg _) negative).elim
    · exact (lt_irrefl _ negative).elim
  · simp only [Evaluated.suppliesOK,decide_eq_true_eq]
    intro d a nonzero
    cases d; cases a <;> simp_all [Evaluated.supply,holdingEvaluated,holdingRequest]
  · intro cell
    rw [holding_effect]
    exact add_nonneg (pre.nonneg cell) (by split <;> positivity)
  · simp only [Evaluated.accountingOK,decide_eq_true_eq]
    intro d a
    cases d; cases a <;> simp [Evaluated.effect,Evaluated.supply,holdingEvaluated,
      PaymentSettlement.sum_if_party]
  · simp only [Evaluated.writesOK,decide_eq_true_eq]
    intro cell outside
    simp only [holdingEvaluated,List.mem_singleton] at outside
    rw [holding_effect,if_neg (Ne.symm outside)]

theorem holding_exists (quantity : ℕ) (store : Store) (ids : List CapabilityId) (pre : Ledger)
    (invoke : hasAuthority store ids ownerContext holdingId .invoke=true)
    (authority : hasAuthority store ids ownerContext holdingId (.changeSupply .margin .claimSecondary)=true) :
    ∃ post,holdingExecute quantity store ownerContext ids pre=.ok post := by
  have valid := holding_valid quantity store ownerContext ids pre authority
  have balances := valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell=>pre.balance cell+(holdingEvaluated quantity).effect cell,balances⟩,store⟩
  exact ⟨post,(holding_ok_iff quantity store ownerContext ids pre post).mpr
    ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩⟩


theorem settleHolding_ok_iff (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (post : World) :
    settleHolding quantity configured paid ctx ids=.ok post ↔
      if 0 < quantity then configured=true ∧
        holdingExecute quantity paid.capabilities ctx ids paid.state=.ok post else post=paid := by
  by_cases positive : 0 < quantity
  · cases configured <;> simp [settleHolding,positive,Except.mapError]
    cases executed : holdingExecute quantity paid.capabilities ctx ids paid.state <;>
      simp [executed,Except.mapError]
  · simp [settleHolding,positive,eq_comm]

def receipt (funding : Quote) (payment : Payment.Result) : Receipt :=
  ⟨funding,payment,payment.paidSecondary,
    decide (payment.paidPrimaryOutput+payment.paidCollateral<funding.feePrimary)⟩

theorem run_ok_iff (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt) :
    run before latest domain prices buckets configured ctx payIds holdingIds=.ok (after,observed) ↔
      ∃ paid,PaymentSettlement.execute prices
        (paymentInput prices (quote before.position latest domain) buckets)
        before.world.capabilities ctx payIds before.world.state=.ok paid ∧
      settleHolding (Payment.payCost prices
        (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary
        configured paid ctx holdingIds=.ok after.world ∧ after.position=before.position ∧
      observed=receipt (quote before.position latest domain)
        (Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)) := by
  cases executed : PaymentSettlement.execute prices
    (paymentInput prices (quote before.position latest domain) buckets)
    before.world.capabilities ctx payIds before.world.state with
  | error reason => simp [run,PaymentSettlement.run,executed,Except.mapError,
      bind,Except.bind,pure,Except.pure]
  | ok paid =>
    cases settled : settleHolding (Payment.payCost prices
      (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary
      configured paid ctx holdingIds with
    | error reason => simp [run,PaymentSettlement.run,executed,settled,Except.mapError,
        bind,Except.bind,pure,Except.pure]
    | ok post =>
      cases after
      simp [run,PaymentSettlement.run,executed,settled,Except.mapError,
        bind,Except.bind,pure,Except.pure,receipt,eq_comm,and_assoc,and_left_comm,and_comm]

theorem settleHolding_effects (quantity : ℕ) (configured : Bool) (paid : World)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (post : World)
    (success : settleHolding quantity configured paid ctx ids=.ok post) :
    post.capabilities=paid.capabilities ∧ ∀ cell,
      post.state.balance cell=paid.state.balance cell+
        (if (.margin,.holding,.claimSecondary)=cell then (quantity:ℚ) else 0) := by
  have description := (settleHolding_ok_iff quantity configured paid ctx ids post).mp success
  by_cases positive : 0 < quantity
  · rw [if_pos positive] at description
    obtain ⟨_,_,_,caps,balances⟩ := (holding_ok_iff quantity paid.capabilities ctx ids paid.state post).mp
      description.2
    exact ⟨caps,by intro cell; simpa only [holding_effect] using balances cell⟩
  · rw [if_neg positive] at description
    subst post
    have zero : quantity=0 := by omega
    simp [zero]

theorem actual_effects (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.position=before.position ∧ after.world.capabilities=before.world.capabilities ∧
    observed=receipt (quote before.position latest domain)
      (Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)) ∧
    ∀ cell,after.world.state.balance cell=before.world.state.balance cell+
      (PaymentSettlement.evaluated prices (paymentInput prices observed.funding buckets) true).effect cell+
      (if (.margin,.holding,.claimSecondary)=cell then (observed.holdingCollateralClaimSecondary:ℚ) else 0) := by
  obtain ⟨paid,payment,holding,position,observation⟩ :=
    (run_ok_iff before latest domain prices buckets configured ctx payIds holdingIds after observed).mp success
  have compat := PaymentSettlement.success_compatible _ _ _ _ _ _ _ payment
  obtain ⟨_,_,_,caps,balances⟩ := (PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp payment
  have decision : decide (PaymentSettlement.Compatible
      (paymentInput prices (quote before.position latest domain) buckets) before.world.state)=true := by
    simpa using compat
  rw [decision] at balances
  have held := settleHolding_effects _ _ _ _ _ _ holding
  refine ⟨position,held.1.trans caps,observation,?_⟩
  intro cell
  rw [held.2 cell,balances cell,observation]
  rfl

theorem actual_owner_claims_and_holding (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.world.state.balance (.margin,.owner,.claimPrimary)=
      before.world.state.balance (.margin,.owner,.claimPrimary) ∧
    after.world.state.balance (.margin,.owner,.claimSecondary)=
      before.world.state.balance (.margin,.owner,.claimSecondary) ∧
    after.world.state.balance (.margin,.holding,.claimSecondary)=
      before.world.state.balance (.margin,.holding,.claimSecondary)+
        (observed.holdingCollateralClaimSecondary:ℚ) := by
  have effects := (actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.2
  constructor
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.owner,.claimPrimary)
  constructor
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.owner,.claimSecondary)
  · simpa [PaymentSettlement.evaluated,Evaluated.effect] using effects (.margin,.holding,.claimSecondary)


/-- Actual four-asset accounting: physical assets and owner claims conserve; only holding claims issue. -/
theorem actual_accounting (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) (asset : Asset) :
    total after.world.state .margin asset=total before.world.state .margin asset+
      if asset=.claimSecondary then (observed.holdingCollateralClaimSecondary:ℚ) else 0 := by
  have effects := (actual_effects _ _ _ _ _ _ _ _ _ _ _ success).2.2.2
  unfold total
  simp_rw [effects]
  rw [Finset.sum_add_distrib,Finset.sum_add_distrib]
  have zero : ∑ p : Party,(PaymentSettlement.evaluated prices
      (paymentInput prices observed.funding buckets) true).effect (.margin,p,asset)=0 := by
    cases asset <;> simp [PaymentSettlement.evaluated,Evaluated.effect,
      Finset.sum_add_distrib,PaymentSettlement.sum_if_party] <;> ring
  rw [zero,add_zero]
  cases asset <;> simp

theorem actual_recipient_gains (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    after.world.state.balance (.margin,.costRecipient,.primary)-
      before.world.state.balance (.margin,.costRecipient,.primary)=
      ((observed.payment.paidPrimaryOutput+observed.payment.paidCollateral:ℕ):ℚ) ∧
    after.world.state.balance (.margin,.costRecipient,.secondary)-
      before.world.state.balance (.margin,.costRecipient,.secondary)=
      (observed.payment.paidSecondary:ℚ) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have effects := info.2.2.2
  have quoteEq : observed.payment=Payment.payCost prices (paymentInput prices observed.funding buckets) := by
    rw [info.2.2.1]; rfl
  constructor
  · rw [effects,PaymentSettlement.recipient_primary_effect,quoteEq]
    simp
  · rw [effects,PaymentSettlement.recipient_secondary_effect,quoteEq]
    simp

/-- Source residual, exact shortfall and the primary-shortfall warning remain distinct returned facts. -/
theorem actual_reconciliation (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed)) :
    (observed.funding.feePrimary:ℚ)*(prices.primary:ℚ)+(observed.payment.ceilDustUsd:ℚ)=
      (after.world.state.balance (.margin,.costRecipient,.primary)-
        before.world.state.balance (.margin,.costRecipient,.primary))*(prices.primary:ℚ)+
      (after.world.state.balance (.margin,.costRecipient,.secondary)-
        before.world.state.balance (.margin,.costRecipient,.secondary))*(prices.secondary:ℚ)+
      (observed.payment.sourceRemainingCostUsd:ℚ)+(observed.payment.floorDustUsd:ℚ) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have gains := actual_recipient_gains _ _ _ _ _ _ _ _ _ _ _ success
  rw [gains.1,gains.2,info.2.2.1]
  exact_mod_cast Payment.two_dust_reconciliation prices
    (paymentInput prices (quote before.position latest domain) buckets)

/-- Every compatible input constructs execution with genuine operation-scoped authorities.
The holding condition is required exactly when native secondary payment is positive. -/
theorem run_exists (before : State) (latest : Factors) (domain : Admissible before.position latest)
    (prices : Payment.Prices) (buckets : Buckets) (configured : Bool)
    (payIds holdingIds : List CapabilityId)
    (compatible : PaymentSettlement.Compatible
      (paymentInput prices (quote before.position latest domain) buckets) before.world.state)
    (invoke : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId .invoke=true)
    (debitOutput : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.output,.primary))=true)
    (debitCollateral : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.position,.primary))=true)
    (debitSecondary : hasAuthority before.world.capabilities payIds ownerContext PaymentSettlement.payId
      (.debit (.margin,.output,.secondary))=true)
    (holdingInvoke : hasAuthority before.world.capabilities holdingIds ownerContext holdingId .invoke=true)
    (holdingSupply : hasAuthority before.world.capabilities holdingIds ownerContext holdingId
      (.changeSupply .margin .claimSecondary)=true)
    (holdingConfig : 0 < (Payment.payCost prices
      (paymentInput prices (quote before.position latest domain) buckets)).paidSecondary → configured=true) :
    ∃ after observed,run before latest domain prices buckets configured ownerContext payIds holdingIds=
      .ok (after,observed) := by
  let funding := quote before.position latest domain
  let input := paymentInput prices funding buckets
  let native := Payment.payCost prices input
  obtain ⟨paid,executed⟩ := PaymentSettlement.execute_exists prices input before.world.capabilities
    payIds before.world.state compatible invoke debitOutput debitCollateral debitSecondary
  have caps := ((PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp executed).2.2.2.1
  have settled : ∃ post,settleHolding native.paidSecondary configured paid ownerContext holdingIds=.ok post := by
    by_cases positive : 0 < native.paidSecondary
    · have config := holdingConfig positive
      have hi : hasAuthority paid.capabilities holdingIds ownerContext holdingId .invoke=true := by
        rw [caps]; exact holdingInvoke
      have hs : hasAuthority paid.capabilities holdingIds ownerContext holdingId
          (.changeSupply .margin .claimSecondary)=true := by rw [caps]; exact holdingSupply
      obtain ⟨post,success⟩ := holding_exists native.paidSecondary paid.capabilities holdingIds paid.state hi hs
      exact ⟨post,(settleHolding_ok_iff _ _ _ _ _ _).mpr (by rw [if_pos positive]; exact ⟨config,success⟩)⟩
    · exact ⟨paid,(settleHolding_ok_iff _ _ _ _ _ _).mpr (by rw [if_neg positive])⟩
  obtain ⟨post,success⟩ := settled
  exact ⟨⟨post,before.position⟩,receipt funding native,
    (run_ok_iff _ _ _ _ _ _ _ _ _ _ _).mpr ⟨paid,executed,success,rfl,rfl⟩⟩

theorem provisioned_exact (position : Position) (latest : Factors) (domain : Admissible position latest)
    (prices : Payment.Prices) (buckets : Buckets) :
    provisioned position latest domain prices buckets=.ok fixtureStore := by rfl

theorem fixture_rights :
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId .invoke=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
    hasAuthority fixtureStore payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true ∧
    hasAuthority fixtureStore holdingIds ownerContext holdingId .invoke=true ∧
    hasAuthority fixtureStore holdingIds ownerContext holdingId (.changeSupply .margin .claimSecondary)=true := by decide


/-- Funding is an expense, not a pending-claim cash credit. This excludes all other health fees. -/
def signedFundingCharge (prices : Payment.Prices) (funding : Quote) : ℚ :=
  -(funding.feePrimary:ℚ)*(prices.primary:ℚ)
def markedCollateralEquity (state : State) (prices : Payment.Prices) : ℚ :=
  state.world.state.balance (.margin,.position,.primary)*(prices.primary:ℚ)+
    (state.position.pnlUsd:ℚ)+(state.position.impactUsd:ℚ)
theorem signedFundingCharge_nonpositive (prices : Payment.Prices) (funding : Quote) :
    signedFundingCharge prices funding ≤ 0 := by
  unfold signedFundingCharge
  exact mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Nat.cast_nonneg _)) (Nat.cast_nonneg _)

/-- Full primary-collateral settlement realizes the negative funding contribution once.
The post-collateral value already incorporates this fee; subtracting it again would double-count.
Marked PnL/impact are unchanged observations here, not a full source-health or cash-realization claim. -/
theorem primary_paid_equity (before : State) (latest : Factors)
    (domain : Admissible before.position latest) (prices : Payment.Prices) (buckets : Buckets)
    (configured : Bool) (ctx : InvocationContext Party Domain) (payIds holdingIds : List CapabilityId)
    (after : State) (observed : Receipt)
    (success : run before latest domain prices buckets configured ctx payIds holdingIds=
      .ok (after,observed))
    (noOutput : buckets.output=0)
    (funded : (quote before.position latest domain).feePrimary ≤ buckets.collateral) :
    markedCollateralEquity after prices=markedCollateralEquity before prices+
      signedFundingCharge prices (quote before.position latest domain) := by
  have info := actual_effects _ _ _ _ _ _ _ _ _ _ _ success
  have collateral := info.2.2.2 (.margin,.position,.primary)
  rw [PaymentSettlement.collateral_effect,info.2.2.1] at collateral
  simp only [receipt] at collateral
  have paid : (Payment.payCost prices (paymentInput prices
      (quote before.position latest domain) buckets)).paidCollateral=
        (quote before.position latest domain).feePrimary := by
    change min buckets.collateral
      ((Payment.payCost prices (paymentInput prices (quote before.position latest domain) buckets)).primaryRequired-
        min buckets.output (Payment.payCost prices
          (paymentInput prices (quote before.position latest domain) buckets)).primaryRequired)=_
    rw [required_exact,noOutput]
    simpa using min_eq_right funded
  rw [paid] at collateral
  have distinct : ((.margin,.holding,.claimSecondary) : Cell Party Asset Domain) ≠
      (.margin,.position,.primary) := by decide
  rw [if_neg distinct,add_zero] at collateral
  unfold markedCollateralEquity signedFundingCharge
  rw [collateral,info.1]
  ring
end DefiKernel.Margin.Funding
