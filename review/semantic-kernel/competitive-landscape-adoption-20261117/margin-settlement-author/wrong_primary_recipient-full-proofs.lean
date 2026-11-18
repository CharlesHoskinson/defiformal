import DefiKernel.Margin.Types
import DefiKernel.Margin.Payment
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

/-! A reference cost recipient receives computed payments. GMX recipient/handler refinement is separate. -/
namespace DefiKernel.Margin.PaymentSettlement
open DefiKernel.Typed
def payId : OperationId := ⟨0⟩
def guard (input : Payment.Inputs) : E [] .bool :=
  .binary .and
    (.binary (.eq (.amount Asset.primary)) (.balance (ref .primary .output)) (.lit input.primaryOutput))
    (.binary .and
      (.binary (.eq (.amount Asset.primary)) (.balance (ref .primary .position)) (.lit input.collateral))
      (.binary (.eq (.amount Asset.secondary)) (.balance (ref .secondary .output)) (.lit input.secondaryOutput)))
def template (prices : Payment.Prices) (input : Payment.Inputs) : Op :=
  let quote := Payment.payCost prices input
  {signature:=[],domain:=.margin,partyArity:=0,guard:=guard input,
   deltas:=[⟨.primary,ref .primary .output,.lit (-(quote.paidPrimaryOutput:ℚ))⟩,
     ⟨.primary,ref .primary .position,.lit (-(quote.paidCollateral:ℚ))⟩,
     ⟨.secondary,ref .secondary .output,.lit (-(quote.paidSecondary:ℚ))⟩,
     ⟨.primary,ref .primary .pool,.lit (quote.paidPrimaryOutput+quote.paidCollateral)⟩,
     ⟨.secondary,ref .secondary .costRecipient,.lit quote.paidSecondary⟩],
   supplyDeltas:=[],
   stateReads:=[packedRef .primary .output,packedRef .primary .position,packedRef .secondary .output],
   envReads:=[],writes:=[packedRef .primary .output,packedRef .primary .position,
     packedRef .secondary .output,packedRef .primary .pool,packedRef .secondary .costRecipient]}
private def registry (prices : Payment.Prices) (input : Payment.Inputs) : Registry Party Asset Domain :=
  fun id => if id=payId then some (template prices input) else none
def request (ids : List CapabilityId) : Request Party Asset Domain := ⟨payId,[],[],ids,some .owner⟩
def execute (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) :
    Except Typed.Refusal World :=
  Typed.execute (registry prices input) store ctx (fun _=>none) 0 (request ids) pre
def run (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) :
    Except Typed.Refusal (World × Payment.Result) := do
  let post ← execute prices input store ctx ids pre
  return (post,Payment.payCost prices input)
def grants : List (Grant Party Asset Domain) := [⟨.owner,.margin,payId,.invoke⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.output,.primary)⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.position,.primary)⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.output,.secondary)⟩]
def provisioned (prices : Payment.Prices) (input : Payment.Inputs) : Except AuthorityFailure Store :=
  grants.foldlM (fun store grant => do
    let (_,next) ← issueCapability (registryAuthorityConfig (registry prices input) (fun _ => .admin))
      ⟨.admin,.margin⟩ store grant
    return next) .empty
def fixtureStore : Store := ⟨grants.map (fun grant=>⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩,⟨3⟩]


def Compatible (input : Payment.Inputs) (pre : Ledger) : Prop :=
  pre.balance (.margin,.output,.primary) = (input.primaryOutput:ℚ) ∧
  pre.balance (.margin,.position,.primary) = (input.collateral:ℚ) ∧
  pre.balance (.margin,.output,.secondary) = (input.secondaryOutput:ℚ)
instance (input : Payment.Inputs) (pre : Ledger) : Decidable (Compatible input pre) := by
  unfold Compatible
  infer_instance

def evaluated (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    Evaluated Party Asset Domain :=
  let q := Payment.payCost prices input
  ⟨condition,[((.margin,.output,.primary),-(q.paidPrimaryOutput:ℚ)),
    ((.margin,.position,.primary),-(q.paidCollateral:ℚ)),
    ((.margin,.output,.secondary),-(q.paidSecondary:ℚ)),
    ((.margin,.costRecipient,.primary),((q.paidPrimaryOutput+q.paidCollateral:ℕ):ℚ)),
    ((.margin,.costRecipient,.secondary),(q.paidSecondary:ℚ))],[],
    [(.margin,.output,.primary),(.margin,.position,.primary),(.margin,.output,.secondary)],[],
    [(.margin,.output,.primary),(.margin,.position,.primary),(.margin,.output,.secondary)],[],
    [(.margin,.output,.primary),(.margin,.position,.primary),(.margin,.output,.secondary),
      (.margin,.costRecipient,.primary),(.margin,.costRecipient,.secondary)]⟩

theorem normalize_guard_decisions (p q r : Prop) [Decidable p] [Decidable q] [Decidable r] :
    (decide p && (decide q && decide r)) = decide (p ∧ q ∧ r) := by
  simp only [Bool.decide_and]

theorem template_evaluate (prices : Payment.Prices) (input : Payment.Inputs) (pre : Ledger)
    (ctx : InvocationContext Party Domain) :
    (template prices input).evaluate ⟨pre,(fun _=>none),ctx.principal,[],Args.nil,0⟩ =
      .ok (evaluated prices input (decide (Compatible input pre))) := by
  simp [Template.evaluate,Template.requiredStateReads,Template.requiredEnvReads,
    template,guard,ref,packedRef,Expr.eval,Expr.stateReads,Expr.envReads,readBalance,
    resolveRefs,CellRef.resolve,PartyRef.resolve,BinaryOp.eval,UnaryOp.eval,numericValue,numericRat,
    evaluated,Compatible,Bool.decide_and,Nat.cast_add,bind,Except.bind,pure,Except.pure]
  exact normalize_guard_decisions
    (pre.balance (.margin,.output,.primary) = (input.primaryOutput:ℚ))
    (pre.balance (.margin,.position,.primary) = (input.collateral:ℚ))
    (pre.balance (.margin,.output,.secondary) = (input.secondaryOutput:ℚ))

theorem execute_ok_iff (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World) :
    execute prices input store ctx ids pre = .ok post ↔
      ctx.principal = .owner ∧ hasAuthority store ids ctx payId .invoke = true ∧
      (evaluated prices input (decide (Compatible input pre))).Valid store ctx (request ids) pre ∧
      post.capabilities = store ∧ ∀ cell,post.state.balance cell = pre.balance cell+
        (evaluated prices input (decide (Compatible input pre))).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry prices input) store ctx (fun _=>none) 0
    (request ids) pre post
  constructor
  · intro success
    obtain ⟨selected,registered,actor,dom,arity,args,checked,invoke,e,observed,
      valid,capabilities,balances⟩ := correspondence.mp success
    have selectedEq : selected = template prices input := by
      simpa [registry,request] using registered.symm
    subst selected
    have argsEq : args = Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have same : e = evaluated prices input (decide (Compatible input pre)) :=
      Except.ok.inj (observed.symm.trans (template_evaluate prices input pre ctx))
    subst e
    have bound : ctx.principal = .owner := by simpa [request,eq_comm] using actor
    exact ⟨bound,invoke,valid,capabilities,balances⟩
  · rintro ⟨bound,invoke,valid,capabilities,balances⟩
    apply correspondence.mpr
    refine ⟨template prices input,?_,?_,?_,rfl,Args.nil,rfl,invoke,
      evaluated prices input (decide (Compatible input pre)),template_evaluate prices input pre ctx,
      valid,capabilities,balances⟩
    · simp [registry,request]
    · simp [request,bound]
    · cases ctx.domain; rfl

theorem run_ok_iff (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger)
    (post : World) (quote : Payment.Result) :
    run prices input store ctx ids pre = .ok (post,quote) ↔
      execute prices input store ctx ids pre = .ok post ∧ quote = Payment.payCost prices input := by
  cases actual : execute prices input store ctx ids pre <;>
    simp [run,actual,bind,Except.bind,pure,Except.pure,eq_comm,and_comm]

theorem success_compatible (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post) : Compatible input pre := by
  have valid := ((execute_ok_iff prices input store ctx ids pre post).mp success).2.2.1
  have observed := valid.1
  exact of_decide_eq_true observed

theorem output_primary_effect (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    (evaluated prices input condition).effect (.margin,.output,.primary) =
      -((Payment.payCost prices input).paidPrimaryOutput:ℚ) := by
  simp [Evaluated.effect,evaluated]
theorem collateral_effect (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    (evaluated prices input condition).effect (.margin,.position,.primary) =
      -((Payment.payCost prices input).paidCollateral:ℚ) := by
  simp [Evaluated.effect,evaluated]
theorem output_secondary_effect (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    (evaluated prices input condition).effect (.margin,.output,.secondary) =
      -((Payment.payCost prices input).paidSecondary:ℚ) := by
  simp [Evaluated.effect,evaluated]
theorem recipient_primary_effect (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    (evaluated prices input condition).effect (.margin,.costRecipient,.primary) =
      (((Payment.payCost prices input).paidPrimaryOutput+(Payment.payCost prices input).paidCollateral:ℕ):ℚ) := by
  simp [Evaluated.effect,evaluated]
theorem recipient_secondary_effect (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool) :
    (evaluated prices input condition).effect (.margin,.costRecipient,.secondary) =
      ((Payment.payCost prices input).paidSecondary:ℚ) := by
  simp [Evaluated.effect,evaluated]

theorem supply_zero (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool)
    (domain : Domain) (asset : Asset) : (evaluated prices input condition).supply domain asset = 0 := by
  simp [Evaluated.supply,evaluated]



def affected : List (Cell Party Asset Domain) := [(.margin,.output,.primary),
  (.margin,.position,.primary),(.margin,.output,.secondary),
  (.margin,.costRecipient,.primary),(.margin,.costRecipient,.secondary)]

theorem effect_outside (prices : Payment.Prices) (input : Payment.Inputs) (condition : Bool)
    (cell : Cell Party Asset Domain) (outside : cell ∉ affected) :
    (evaluated prices input condition).effect cell = 0 := by
  simp [affected] at outside
  rcases outside with ⟨h0,h1,h2,h3,h4⟩
  simp [Evaluated.effect,evaluated,Ne.symm h0,Ne.symm h1,Ne.symm h2,Ne.symm h3,Ne.symm h4]

theorem actual_frame (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post)
    (cell : Cell Party Asset Domain) (outside : cell ∉ affected) :
    post.state.balance cell = pre.balance cell := by
  obtain ⟨_,_,_,_,balances⟩ := (execute_ok_iff prices input store ctx ids pre post).mp success
  simpa only [effect_outside prices input _ cell outside,add_zero] using balances cell

theorem claim_counters_frame (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post) (party : Party) :
    post.state.balance (.margin,party,.claimPrimary) = pre.balance (.margin,party,.claimPrimary) ∧
    post.state.balance (.margin,party,.claimSecondary) = pre.balance (.margin,party,.claimSecondary) := by
  constructor
  · exact actual_frame prices input store ctx ids pre post success _ (by simp [affected])
  · exact actual_frame prices input store ctx ids pre post success _ (by simp [affected])

theorem actual_accounting (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post) :
    ∀ asset,total post.state .margin asset = total pre .margin asset := by
  obtain ⟨_,_,valid,capabilities,balances⟩ :=
    (execute_ok_iff prices input store ctx ids pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request ids) pre
    (evaluated prices input (decide (Compatible input pre))) post).mpr ⟨valid,capabilities,balances⟩
  intro asset
  simpa only [supply_zero,add_zero] using applyEvaluated_accounting store ctx (request ids) pre
    (evaluated prices input (decide (Compatible input pre))) post applied .margin asset

/-- Actual post-buckets equal the very same computed native quote's raw integer remainders. -/
theorem actual_buckets (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post) :
    post.state.balance (.margin,.output,.primary) = ((Payment.payCost prices input).outputLeft:ℚ) ∧
    post.state.balance (.margin,.position,.primary) = ((Payment.payCost prices input).collateralLeft:ℚ) ∧
    post.state.balance (.margin,.output,.secondary) = ((Payment.payCost prices input).secondaryLeft:ℚ) := by
  have compatible := success_compatible prices input store ctx ids pre post success
  obtain ⟨_,_,_,_,balances⟩ := (execute_ok_iff prices input store ctx ids pre post).mp success
  have bounds := Payment.payment_bounds prices input
  constructor
  · have observed := balances (.margin,.output,.primary)
    rw [output_primary_effect,compatible.1] at observed
    change post.state.balance (.margin,.output,.primary) =
      ((input.primaryOutput-(Payment.payCost prices input).paidPrimaryOutput:ℕ):ℚ)
    simpa only [Nat.cast_sub bounds.1,sub_eq_add_neg] using observed
  constructor
  · have observed := balances (.margin,.position,.primary)
    rw [collateral_effect,compatible.2.1] at observed
    change post.state.balance (.margin,.position,.primary) =
      ((input.collateral-(Payment.payCost prices input).paidCollateral:ℕ):ℚ)
    simpa only [Nat.cast_sub bounds.2.1,sub_eq_add_neg] using observed
  · have observed := balances (.margin,.output,.secondary)
    rw [output_secondary_effect,compatible.2.2] at observed
    change post.state.balance (.margin,.output,.secondary) =
      ((input.secondaryOutput-(Payment.payCost prices input).paidSecondary:ℕ):ℚ)
    simpa only [Nat.cast_sub bounds.2.2.1,sub_eq_add_neg] using observed

theorem actual_recipient_gains (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World)
    (success : execute prices input store ctx ids pre = .ok post) :
    post.state.balance (.margin,.costRecipient,.primary)-pre.balance (.margin,.costRecipient,.primary) =
      (((Payment.payCost prices input).paidPrimaryOutput+(Payment.payCost prices input).paidCollateral:ℕ):ℚ) ∧
    post.state.balance (.margin,.costRecipient,.secondary)-pre.balance (.margin,.costRecipient,.secondary) =
      ((Payment.payCost prices input).paidSecondary:ℚ) := by
  obtain ⟨_,_,_,_,balances⟩ := (execute_ok_iff prices input store ctx ids pre post).mp success
  constructor
  · rw [balances,recipient_primary_effect]; ring
  · rw [balances,recipient_secondary_effect]; ring

/-- Two-dust reconciliation of the returned metadata and the actual recipient's executed gains. -/
theorem actual_financial_reconciliation (prices : Payment.Prices) (input : Payment.Inputs)
    (store : Store) (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (pre : Ledger) (post : World) (quote : Payment.Result)
    (success : run prices input store ctx ids pre = .ok (post,quote)) :
    (input.costUsd:ℚ)+(quote.ceilDustUsd:ℚ) =
      (post.state.balance (.margin,.costRecipient,.primary)-pre.balance (.margin,.costRecipient,.primary))*
        (prices.primary:ℚ)+
      (post.state.balance (.margin,.costRecipient,.secondary)-pre.balance (.margin,.costRecipient,.secondary))*
        (prices.secondary:ℚ)+(quote.sourceRemainingCostUsd:ℚ)+(quote.floorDustUsd:ℚ) := by
  obtain ⟨executed,rfl⟩ := (run_ok_iff prices input store ctx ids pre post quote).mp success
  have gains := actual_recipient_gains prices input store ctx ids pre post executed
  rw [gains.1,gains.2]
  exact_mod_cast Payment.two_dust_reconciliation prices input

/-- The true economic shortfall is the positive part of cost minus actual executed payment value. -/
theorem actual_economic_shortfall (prices : Payment.Prices) (input : Payment.Inputs)
    (store : Store) (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (pre : Ledger) (post : World) (quote : Payment.Result)
    (success : run prices input store ctx ids pre = .ok (post,quote)) :
    (quote.economicShortfallUsd:ℚ) = max 0 ((input.costUsd:ℚ)-
      ((post.state.balance (.margin,.costRecipient,.primary)-pre.balance (.margin,.costRecipient,.primary))*
        (prices.primary:ℚ)+
       (post.state.balance (.margin,.costRecipient,.secondary)-pre.balance (.margin,.costRecipient,.secondary))*
        (prices.secondary:ℚ))) := by
  obtain ⟨executed,rfl⟩ := (run_ok_iff prices input store ctx ids pre post quote).mp success
  have gains := actual_recipient_gains prices input store ctx ids pre post executed
  rw [gains.1,gains.2]
  let paid : ℕ := ((Payment.payCost prices input).paidPrimaryOutput+
    (Payment.payCost prices input).paidCollateral)*prices.primary+
    (Payment.payCost prices input).paidSecondary*prices.secondary
  have paidCast : (paid:ℚ) =
      (((Payment.payCost prices input).paidPrimaryOutput+(Payment.payCost prices input).paidCollateral:ℕ):ℚ)*
        (prices.primary:ℚ)+((Payment.payCost prices input).paidSecondary:ℚ)*(prices.secondary:ℚ) := by
    simp only [paid,Nat.cast_add,Nat.cast_mul]
  rw [← paidCast]
  change ((input.costUsd-paid:ℕ):ℚ) = max 0 ((input.costUsd:ℚ)-(paid:ℚ))
  by_cases under : paid ≤ input.costUsd
  · rw [Nat.cast_sub under]
    symm
    apply max_eq_right
    exact sub_nonneg.mpr (by exact_mod_cast under)
  · have over : input.costUsd ≤ paid := le_of_not_ge under
    rw [Nat.sub_eq_zero_of_le over]
    simp only [Nat.cast_zero]
    symm
    apply max_eq_left
    exact sub_nonpos.mpr (by exact_mod_cast over)



theorem sum_if_party (party : Party) (value : ℚ) :
    ∑ p : Party,(if party=p then value else 0) = value := by
  simp [Finset.sum_ite_eq,Finset.mem_univ]

/-- Bucket funding is derived from native bounds and exact raw compatibility, never assumed as Valid. -/
theorem evaluated_valid (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger)
    (compatible : Compatible input pre)
    (debitOutput : hasAuthority store ids ctx payId (.debit (.margin,.output,.primary)) = true)
    (debitCollateral : hasAuthority store ids ctx payId (.debit (.margin,.position,.primary)) = true)
    (debitSecondary : hasAuthority store ids ctx payId (.debit (.margin,.output,.secondary)) = true) :
    (evaluated prices input true).Valid store ctx (request ids) pre := by
  have bounds := Payment.payment_bounds prices input
  have outputFunded : ((Payment.payCost prices input).paidPrimaryOutput:ℚ) ≤
      pre.balance (.margin,.output,.primary) := by
    rw [compatible.1]
    exact_mod_cast bounds.1
  have collateralFunded : ((Payment.payCost prices input).paidCollateral:ℚ) ≤
      pre.balance (.margin,.position,.primary) := by
    rw [compatible.2.1]
    exact_mod_cast bounds.2.1
  have secondaryFunded : ((Payment.payCost prices input).paidSecondary:ℚ) ≤
      pre.balance (.margin,.output,.secondary) := by
    rw [compatible.2.2]
    exact_mod_cast bounds.2.2.1
  have balances : ∀ cell,0 ≤ pre.balance cell+(evaluated prices input true).effect cell := by
    intro cell
    by_cases h0 : cell=(.margin,.output,.primary)
    · subst cell; rw [output_primary_effect]
      simpa only [sub_eq_add_neg] using sub_nonneg.mpr outputFunded
    · by_cases h1 : cell=(.margin,.position,.primary)
      · subst cell; rw [collateral_effect]
        simpa only [sub_eq_add_neg] using sub_nonneg.mpr collateralFunded
      · by_cases h2 : cell=(.margin,.output,.secondary)
        · subst cell; rw [output_secondary_effect]
          simpa only [sub_eq_add_neg] using sub_nonneg.mpr secondaryFunded
        · by_cases h3 : cell=(.margin,.costRecipient,.primary)
          · subst cell; rw [recipient_primary_effect]
            exact add_nonneg (pre.nonneg _) (Nat.cast_nonneg _)
          · by_cases h4 : cell=(.margin,.costRecipient,.secondary)
            · subst cell; rw [recipient_secondary_effect]
              exact add_nonneg (pre.nonneg _) (Nat.cast_nonneg _)
            · rw [effect_outside prices input true cell (by simp [affected,h0,h1,h2,h3,h4])]
              simpa using pre.nonneg cell
  refine ⟨rfl,?_,rfl,?_,?_,?_,balances,?_,?_⟩
  · simp [Evaluated.stateReadsOK,evaluated]
  · have domain : ctx.domain=.margin := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨?_,?_,?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    by_cases h0 : cell=(.margin,.output,.primary)
    · subst cell; exact debitOutput
    · by_cases h1 : cell=(.margin,.position,.primary)
      · subst cell; exact debitCollateral
      · by_cases h2 : cell=(.margin,.output,.secondary)
        · subst cell; exact debitSecondary
        · by_cases h3 : cell=(.margin,.costRecipient,.primary)
          · subst cell; rw [recipient_primary_effect] at negative
            exact (not_lt_of_ge (Nat.cast_nonneg _) negative).elim
          · by_cases h4 : cell=(.margin,.costRecipient,.secondary)
            · subst cell; rw [recipient_secondary_effect] at negative
              exact (not_lt_of_ge (Nat.cast_nonneg _) negative).elim
            · rw [effect_outside prices input true cell (by simp [affected,h0,h1,h2,h3,h4])] at negative
              exact (lt_irrefl _ negative).elim
  · simp [Evaluated.suppliesOK,supply_zero]
  · simp only [Evaluated.accountingOK,decide_eq_true_eq]
    intro d a
    cases d; cases a with
    | primary =>
      simp [Evaluated.effect,evaluated,Evaluated.supply]
      rw [Finset.sum_add_distrib,Finset.sum_add_distrib,sum_if_party,sum_if_party,sum_if_party]
      ring
    | secondary =>
      simp [Evaluated.effect,evaluated,Evaluated.supply]
      rw [Finset.sum_add_distrib,sum_if_party,sum_if_party]
      ring
    | claimPrimary => simp [Evaluated.effect,evaluated,Evaluated.supply]
    | claimSecondary => simp [Evaluated.effect,evaluated,Evaluated.supply]
  · simp only [Evaluated.writesOK,decide_eq_true_eq]
    intro cell outside
    apply effect_outside prices input true cell
    simpa only [evaluated,affected] using outside

theorem execute_exists (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ids : List CapabilityId) (pre : Ledger) (compatible : Compatible input pre)
    (invoke : hasAuthority store ids ownerContext payId .invoke = true)
    (debitOutput : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.primary)) = true)
    (debitCollateral : hasAuthority store ids ownerContext payId (.debit (.margin,.position,.primary)) = true)
    (debitSecondary : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.secondary)) = true) :
    ∃ post,execute prices input store ownerContext ids pre = .ok post := by
  have valid := evaluated_valid prices input store ownerContext ids pre compatible
    debitOutput debitCollateral debitSecondary
  have balances : ∀ cell,0 ≤ pre.balance cell+(evaluated prices input true).effect cell :=
    valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell=>pre.balance cell+(evaluated prices input true).effect cell,balances⟩,store⟩
  have decision : decide (Compatible input pre)=true := by simpa using compatible
  refine ⟨post,(execute_ok_iff prices input store ownerContext ids pre post).mpr ?_⟩
  rw [decision]
  exact ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩

theorem run_exists (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ids : List CapabilityId) (pre : Ledger) (compatible : Compatible input pre)
    (invoke : hasAuthority store ids ownerContext payId .invoke = true)
    (debitOutput : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.primary)) = true)
    (debitCollateral : hasAuthority store ids ownerContext payId (.debit (.margin,.position,.primary)) = true)
    (debitSecondary : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.secondary)) = true) :
    ∃ post,run prices input store ownerContext ids pre = .ok (post,Payment.payCost prices input) := by
  obtain ⟨post,executed⟩ := execute_exists prices input store ids pre compatible invoke
    debitOutput debitCollateral debitSecondary
  exact ⟨post,(run_ok_iff prices input store ownerContext ids pre post _).mpr ⟨executed,rfl⟩⟩

theorem provisioned_exact (prices : Payment.Prices) (input : Payment.Inputs) :
    provisioned prices input = .ok fixtureStore := by rfl

theorem fixture_rights :
    hasAuthority fixtureStore ids ownerContext payId .invoke = true ∧
    hasAuthority fixtureStore ids ownerContext payId (.debit (.margin,.output,.primary)) = true ∧
    hasAuthority fixtureStore ids ownerContext payId (.debit (.margin,.position,.primary)) = true ∧
    hasAuthority fixtureStore ids ownerContext payId (.debit (.margin,.output,.secondary)) = true := by decide

/-- Sufficient actual primary custody constructs execution and full exact-USD payment coverage. -/
theorem sufficient_primary_execution (prices : Payment.Prices) (input : Payment.Inputs)
    (store : Store) (ids : List CapabilityId) (pre : Ledger) (compatible : Compatible input pre)
    (liquid : ((Payment.payCost prices input).primaryRequired:ℚ) ≤
      pre.balance (.margin,.output,.primary)+pre.balance (.margin,.position,.primary))
    (invoke : hasAuthority store ids ownerContext payId .invoke = true)
    (debitOutput : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.primary)) = true)
    (debitCollateral : hasAuthority store ids ownerContext payId (.debit (.margin,.position,.primary)) = true)
    (debitSecondary : hasAuthority store ids ownerContext payId (.debit (.margin,.output,.secondary)) = true) :
    ∃ post,run prices input store ownerContext ids pre = .ok (post,Payment.payCost prices input) ∧
      (Payment.payCost prices input).sourceRemainingCostUsd=0 ∧
      (input.costUsd:ℚ) ≤
        (post.state.balance (.margin,.costRecipient,.primary)-pre.balance (.margin,.costRecipient,.primary))*
          (prices.primary:ℚ)+
        (post.state.balance (.margin,.costRecipient,.secondary)-pre.balance (.margin,.costRecipient,.secondary))*
          (prices.secondary:ℚ) := by
  have nativeLiquid : (Payment.payCost prices input).primaryRequired ≤
      input.primaryOutput+input.collateral := by
    rw [compatible.1,compatible.2.1] at liquid
    exact_mod_cast liquid
  have covered := Payment.sufficient_primary_coverage prices input nativeLiquid
  obtain ⟨post,executed⟩ := execute_exists prices input store ids pre compatible invoke
    debitOutput debitCollateral debitSecondary
  have gains := actual_recipient_gains prices input store ownerContext ids pre post executed
  refine ⟨post,(run_ok_iff prices input store ownerContext ids pre post _).mpr ⟨executed,rfl⟩,
    covered.1,?_⟩
  rw [gains.1,gains.2,covered.2.2.1]
  simp only [Nat.cast_zero,zero_mul,add_zero]
  exact_mod_cast covered.2.2.2


theorem template_evaluate_caller (prices : Payment.Prices) (input : Payment.Inputs)
    (pre : Ledger) (caller : Party) :
    (template prices input).evaluate ⟨pre,(fun _=>none),caller,[],Args.nil,0⟩ =
      .ok (evaluated prices input (decide (Compatible input pre))) :=
  template_evaluate prices input pre ⟨caller,.margin⟩

theorem execute_eq_apply (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger)
    (bound : ctx.principal=.owner)
    (invoke : hasAuthority store ids ctx payId .invoke=true) :
    execute prices input store ctx ids pre = applyEvaluated store ctx (request ids) pre
      (evaluated prices input (decide (Compatible input pre))) := by
  have domain : ctx.domain=.margin := by cases ctx.domain; rfl
  simp [execute,Typed.execute,registry,request,bound,domain,Args.check,
    (show (template prices input).partyArity=0 from rfl),
    (show (template prices input).signature=[] from rfl),
    template_evaluate_caller,invoke,Except.mapError,bind,Except.bind]
  rw [show Args.check (template prices input).signature [] = .ok Args.nil from rfl]
  simp [template_evaluate_caller,Except.mapError,bind,Except.bind]

/-- Reference state-binding refusal, not the selected GMX financial rejection or a rollback claim. -/
theorem mismatch_refusal (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger)
    (bound : ctx.principal=.owner) (invoke : hasAuthority store ids ctx payId .invoke=true)
    (mismatch : ¬ Compatible input pre) :
    run prices input store ctx ids pre = .error Typed.Refusal.guard := by
  have rejected : execute prices input store ctx ids pre = .error Typed.Refusal.guard := by
    rw [execute_eq_apply prices input store ctx ids pre bound invoke]
    have flag : decide (Compatible input pre)=false := decide_eq_false mismatch
    simp [applyEvaluated,evaluated,flag]
  simp [run,rejected,bind,Except.bind]

end DefiKernel.Margin.PaymentSettlement

