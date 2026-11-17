import DefiKernel.Lending.Oracle
import DefiKernel.Lending.Support
import Mathlib.Tactic.Ring

namespace DefiKernel.Lending.WithdrawCollateral
open DefiKernel.Typed
def signature : List (Unit Asset) := [.amount Asset.collateral]
def amount : E signature (.amount Asset.collateral) := .arg .here
def remainingCash (borrower : Borrower) : E signature (.amount Asset.cash) :=
  .binary (.convert Asset.collateral Asset.cash)
    (.balance (ref .collateral borrower.custody)) Oracle.price
def guard (borrower : Borrower) : E signature .bool := Oracle.allGuards [
  .binary (.le (.amount Asset.collateral)) (.lit 0) amount,
  .binary (.le (.amount Asset.collateral)) amount (.balance (ref .collateral borrower.custody)),
  .binary (.lt (.price Asset.collateral Asset.cash)) (.lit 0) Oracle.price,
  .binary (.le .scalar) (.timestamp Oracle.key) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp Oracle.key) (.lit Oracle.maxAge)),
  .binary (.le (.amount Asset.cash))
    (.binary (.scale (.amount Asset.cash)) (.lit 2) (Oracle.debtCash borrower))
    (remainingCash borrower)]
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := guard borrower
  deltas := [⟨.collateral,ref .collateral borrower.custody,
      .unary (.neg (.amount Asset.collateral)) amount⟩,
    ⟨.collateral,ref .collateral borrower.party,amount⟩]
  supplyDeltas := []
  stateReads := [packedRef .collateral borrower.custody,packedRef .debt borrower.party]
  envReads := [.observation Oracle.key,.currentTime]
  writes := [packedRef .collateral borrower.custody,packedRef .collateral borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = withdrawCollateralId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) :
    Request Party Asset Domain :=
  ⟨withdrawCollateralId,[],[⟨.amount Asset.collateral,quantity⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx env now (request borrower ids quantity) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,withdrawCollateralId,.invoke⟩,
  ⟨borrower.party,.lending,withdrawCollateralId,
    .debit (.lending,borrower.custody,.collateral)⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store :=
  ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩]


def evaluated (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    Evaluated Party Asset Domain :=
  ⟨condition,
    [((.lending,borrower.custody,.collateral),-quantity),
      ((.lending,borrower.party,.collateral),quantity)], [],
    [(.lending,borrower.custody,.collateral),(.lending,borrower.party,.debt),
      (.lending,borrower.custody,.collateral)],
    (template borrower).requiredEnvReads,
    [(.lending,borrower.custody,.collateral),(.lending,borrower.party,.debt)],
    [.observation Oracle.key,.currentTime],
    [(.lending,borrower.custody,.collateral),(.lending,borrower.party,.collateral)]⟩

theorem required_reads (borrower : Borrower) : (template borrower).requiredStateReads =
    [packedRef .collateral borrower.custody,packedRef .debt borrower.party,
      packedRef .collateral borrower.custody] := rfl
theorem template_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party)
    (env : Environment Asset Domain) (now : Nat) :
    (template borrower).evaluate ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ =
      ((guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩).map
        (fun condition => evaluated borrower quantity condition) := by
  cases actual : (guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ <;>
    simp [Template.evaluate, required_reads, Template.requiredStateReads, Template.requiredEnvReads,
      template, amount, remainingCash, signature, ref, packedRef, actual,
      Expr.eval, Expr.stateReads, Expr.envReads, resolveRefs, CellRef.resolve, PartyRef.resolve,
      Args.get, BinaryOp.eval, UnaryOp.eval, numericValue, numericRat, evaluated,
      Except.map, bind, Except.bind, pure, Except.pure]
  all_goals simp [guard, amount, remainingCash, signature, Oracle.allGuards, Oracle.debtCash, Oracle.lockedCash, remainingCash, Oracle.price,
    Expr.stateReads, Expr.envReads, ref, packedRef, CellRef.resolve, PartyRef.resolve,
    bind, Except.bind, pure, Except.pure]


def Conditions (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (price : ℚ) (observedAt now : Nat) : Prop :=
  0 ≤ quantity ∧ quantity ≤ pre.balance (.lending,borrower.custody,.collateral) ∧
    0 < price ∧ observedAt ≤ now ∧ now ≤ observedAt+Oracle.maxAge ∧
    2*pre.balance (.lending,borrower.party,.debt) ≤
      (pre.balance (.lending,borrower.custody,.collateral)-quantity)*price

instance (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (price : ℚ)
    (observedAt now : Nat) : Decidable (Conditions borrower quantity pre price observedAt now) := by
  unfold Conditions
  infer_instance

theorem normalize_guard_decisions (p q r s t u : Prop)
    [Decidable p] [Decidable q] [Decidable r] [Decidable s] [Decidable t] [Decidable u] :
    (decide p && (decide q && (decide r && (decide s && (decide t && decide u))))) =
      decide (p ∧ q ∧ r ∧ s ∧ t ∧ u) := by
  simp only [Bool.decide_and]

theorem guard_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party)
    (env : Environment Asset Domain) (now observedAt : Nat) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩) :
    (guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ =
      .ok (decide (Conditions borrower quantity pre price observedAt now)) := by
  have freshCast : ((now : ℚ) ≤ (observedAt : ℚ)+5) ↔ now ≤ observedAt+5 := by norm_cast
  simp [guard, Oracle.allGuards, Oracle.price, Oracle.debtCash, remainingCash,
    amount, signature, Expr.eval, readObservation, readBalance, point,
    CellRef.resolve, PartyRef.resolve, ref, Args.get, BinaryOp.eval, UnaryOp.eval,
    numericValue, numericRat, bind, Except.bind, pure, Except.pure,
    Conditions, Oracle.maxAge, Nat.cast_add, Nat.cast_le, freshCast]
  exact normalize_guard_decisions (0 ≤ quantity)
    (quantity ≤ pre.balance (.lending,borrower.custody,.collateral))
    (0 < price) (observedAt ≤ now) (now ≤ observedAt+5)
    (2*pre.balance (.lending,borrower.party,.debt) ≤
      (pre.balance (.lending,borrower.custody,.collateral)-quantity)*price)
theorem run_ok_iff (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World) :
    run borrower store ctx ids quantity env now pre = .ok post ↔
      ctx.principal = borrower.party ∧ hasAuthority store ids ctx withdrawCollateralId .invoke = true ∧
      (guard borrower).eval ⟨pre,env,ctx.principal,[],Args.cons quantity Args.nil,now⟩ = .ok true ∧
      (evaluated borrower quantity true).Valid store ctx (request borrower ids quantity) pre ∧
      post.capabilities = store ∧ ∀ cell,
        post.state.balance cell = pre.balance cell + (evaluated borrower quantity true).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry borrower) store ctx env now
    (request borrower ids quantity) pre post
  constructor
  · intro success
    obtain ⟨selected, registered, actor, dom, arity, args, checked, invoke, e,
      observed, valid, capabilities, balances⟩ := correspondence.mp success
    have selectedEq : selected = template borrower := by
      simpa [registry, request] using registered.symm
    subst selected
    have sameArgs : args = Args.cons quantity Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have expected := template_evaluate borrower quantity pre ctx.principal env now
    cases actual : (guard borrower).eval ⟨pre,env,ctx.principal,[],Args.cons quantity Args.nil,now⟩ with
    | error reason =>
      rw [actual] at expected
      have impossible := observed.symm.trans expected
      cases impossible
    | ok condition =>
      rw [actual] at expected
      have same : e = evaluated borrower quantity condition := Except.ok.inj (observed.symm.trans expected)
      subst e
      have conditionTrue : condition = true := valid.1
      subst condition
      have bound : ctx.principal = borrower.party := by simpa [request, eq_comm] using actor
      exact ⟨bound, invoke, rfl, valid, capabilities, balances⟩
  · rintro ⟨bound, invoke, actual, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨template borrower, ?_, ?_, ?_, rfl, Args.cons quantity Args.nil, rfl,
      invoke, evaluated borrower quantity true, ?_, valid, capabilities, balances⟩
    · simp [registry, request]
    · simp [request, bound]
    · cases ctx.domain; rfl
    · have expected := template_evaluate borrower quantity pre ctx.principal env now
      rw [actual] at expected
      exact expected


theorem free_effect (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    (evaluated borrower quantity condition).effect (.lending,borrower.party,.collateral) = quantity := by
  cases borrower <;> simp [Evaluated.effect,evaluated,Borrower.party,Borrower.custody]

theorem locked_effect (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    (evaluated borrower quantity condition).effect (.lending,borrower.custody,.collateral) = -quantity := by
  cases borrower <;> simp [Evaluated.effect,evaluated,Borrower.party,Borrower.custody]

theorem effect_outside (borrower : Borrower) (quantity : ℚ) (condition : Bool)
    (cell : Cell Party Asset Domain)
    (free : cell ≠ (.lending,borrower.party,.collateral))
    (locked : cell ≠ (.lending,borrower.custody,.collateral)) :
    (evaluated borrower quantity condition).effect cell = 0 := by
  simp [Evaluated.effect,evaluated,Ne.symm free,Ne.symm locked]

theorem supply_zero (borrower : Borrower) (quantity : ℚ) (condition : Bool)
    (domain : Domain) (asset : Asset) :
    (evaluated borrower quantity condition).supply domain asset = 0 := by
  simp [Evaluated.supply,evaluated]

theorem actual_effects (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity env now pre = .ok post) :
    ctx.principal = borrower.party ∧
      post.state.balance (.lending,borrower.party,.collateral) =
        pre.balance (.lending,borrower.party,.collateral)+quantity ∧
      post.state.balance (.lending,borrower.custody,.collateral) =
        pre.balance (.lending,borrower.custody,.collateral)-quantity ∧
      post.capabilities = store := by
  obtain ⟨bound,_,_,_,capabilities,balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  refine ⟨bound,?_,?_,capabilities⟩
  · simpa only [free_effect] using balances (.lending,borrower.party,.collateral)
  · simpa only [locked_effect,sub_eq_add_neg] using balances (.lending,borrower.custody,.collateral)

theorem actual_frame (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World) (success : run borrower store ctx ids quantity env now pre = .ok post)
    (cell : Cell Party Asset Domain)
    (free : cell ≠ (.lending,borrower.party,.collateral))
    (locked : cell ≠ (.lending,borrower.custody,.collateral)) :
    post.state.balance cell = pre.balance cell := by
  obtain ⟨_,_,_,_,_,balances⟩ := (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  simpa only [effect_outside borrower quantity true cell free locked,add_zero] using balances cell

theorem actual_accounting (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (env : Environment Asset Domain) (now : Nat) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity env now pre = .ok post) :
    ∀ asset, total post.state .lending asset = total pre .lending asset := by
  obtain ⟨_,_,_,valid,capabilities,balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request borrower ids quantity) pre
    (evaluated borrower quantity true) post).mpr ⟨valid,capabilities,balances⟩
  intro asset
  simpa only [supply_zero,add_zero] using applyEvaluated_accounting store ctx
    (request borrower ids quantity) pre (evaluated borrower quantity true) post applied .lending asset
/-- Actual success derives the price/freshness/post-withdrawal policy from the observed oracle point. -/
theorem success_conditions (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now observedAt : Nat)
    (pre : Ledger) (post : World) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩)
    (success : run borrower store ctx ids quantity env now pre = .ok post) :
    Conditions borrower quantity pre price observedAt now := by
  obtain ⟨_, _, actual, _, _, _⟩ :=
    (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  have expected := guard_evaluate borrower quantity pre ctx.principal env now observedAt price point
  have decision : decide (Conditions borrower quantity pre price observedAt now) = true :=
    (Except.ok.inj (actual.symm.trans expected)).symm
  exact of_decide_eq_true decision


theorem actual_collateralization (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (env : Environment Asset Domain) (now observedAt : Nat) (pre : Ledger) (post : World) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩)
    (success : run borrower store ctx ids quantity env now pre = .ok post) :
    Conditions borrower quantity pre price observedAt now ∧
      2*post.state.balance (.lending,borrower.party,.debt) ≤
        post.state.balance (.lending,borrower.custody,.collateral)*price := by
  have conditions := success_conditions borrower store ctx ids quantity env now observedAt
    pre post price point success
  have effects := actual_effects borrower store ctx ids quantity env now pre post success
  have debt := actual_frame borrower store ctx ids quantity env now pre post success
    (.lending,borrower.party,.debt) (by simp) (by simp)
  refine ⟨conditions,?_⟩
  rw [debt,effects.2.2.1]
  exact conditions.2.2.2.2.2



theorem evaluated_valid (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (nonnegative : 0 ≤ quantity)
    (funded : quantity ≤ pre.balance (.lending,borrower.custody,.collateral))
    (debit : hasAuthority store ids ctx withdrawCollateralId
      (.debit (.lending,borrower.custody,.collateral)) = true) :
    (evaluated borrower quantity true).Valid store ctx (request borrower ids quantity) pre := by
  have balances : ∀ cell, 0 ≤ pre.balance cell+(evaluated borrower quantity true).effect cell := by
    intro cell
    by_cases locked : cell = (.lending,borrower.custody,.collateral)
    · subst cell; rw [locked_effect]; simpa only [sub_eq_add_neg] using sub_nonneg.mpr funded
    · by_cases free : cell = (.lending,borrower.party,.collateral)
      · subst cell; rw [free_effect]; exact add_nonneg (pre.nonneg _) nonnegative
      · rw [effect_outside borrower quantity true cell free locked]; simpa using pre.nonneg cell
  refine ⟨rfl,?_,?_,?_,?_,?_,balances,?_,?_⟩
  · simp [Evaluated.stateReadsOK,evaluated]
  · simp [Evaluated.envReadsOK,evaluated,Template.requiredEnvReads,template,guard,
      Oracle.allGuards,Oracle.price,Oracle.debtCash,remainingCash,amount,Expr.envReads]
  · have domain : ctx.domain = .lending := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨?_,?_,?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    by_cases locked : cell = (.lending,borrower.custody,.collateral)
    · subst cell; exact debit
    · by_cases free : cell = (.lending,borrower.party,.collateral)
      · subst cell; rw [free_effect] at negative
        exact (not_lt_of_ge nonnegative negative).elim
      · rw [effect_outside borrower quantity true cell free locked] at negative
        exact (lt_irrefl _ negative).elim
  · simp [Evaluated.suppliesOK,supply_zero]
  · simp only [Evaluated.accountingOK,decide_eq_true_eq]
    intro d a
    cases d; cases a with
    | cash => simp [Evaluated.effect,evaluated,Evaluated.supply]
    | debt => simp [Evaluated.effect,evaluated,Evaluated.supply]
    | collateral =>
      simp [Evaluated.effect,evaluated,Evaluated.supply]
      rw [Finset.sum_add_distrib,Support.sum_if_party,Support.sum_if_party]
      ring
  · simp only [Evaluated.writesOK,decide_eq_true_eq]
    intro cell outside
    simp [evaluated] at outside
    exact effect_outside borrower quantity true cell outside.2 outside.1

/-- Policy, observed point and real rights construct success; no assumed Valid/result certificate. -/
theorem funded_success (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (quantity : ℚ) (env : Environment Asset Domain) (now observedAt : Nat)
    (pre : Ledger) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩)
    (policy : Conditions borrower quantity pre price observedAt now)
    (invoke : hasAuthority store ids (borrowerContext borrower) withdrawCollateralId .invoke = true)
    (debit : hasAuthority store ids (borrowerContext borrower) withdrawCollateralId
      (.debit (.lending,borrower.custody,.collateral)) = true) :
    ∃ post, run borrower store (borrowerContext borrower) ids quantity env now pre = .ok post := by
  have valid := evaluated_valid borrower store (borrowerContext borrower) ids quantity pre
    policy.1 policy.2.1 debit
  have nonneg : ∀ cell, 0 ≤ pre.balance cell+(evaluated borrower quantity true).effect cell :=
    valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell => pre.balance cell+(evaluated borrower quantity true).effect cell,
    nonneg⟩,store⟩
  have actual := guard_evaluate borrower quantity pre borrower.party env now observedAt price point
  have decision : decide (Conditions borrower quantity pre price observedAt now) = true := by
    simpa using policy
  rw [decision] at actual
  exact ⟨post,(run_ok_iff borrower store (borrowerContext borrower) ids quantity env now pre post).mpr
    ⟨rfl,invoke,actual,valid,rfl,by intro cell; rfl⟩⟩

theorem provisioned_exact (borrower : Borrower) :
    provisioned borrower = .ok (fixtureStore borrower) := by
  cases borrower <;> decide

theorem fixture_rights (borrower : Borrower) :
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower)
      withdrawCollateralId .invoke = true ∧
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower)
      withdrawCollateralId (.debit (.lending,borrower.custody,.collateral)) = true := by
  cases borrower <;> decide


/-- With a well-typed observation, every failed policy condition yields the guard constructor. -/
theorem policy_refusal (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (env : Environment Asset Domain) (now observedAt : Nat) (pre : Ledger) (price : ℚ)
    (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx withdrawCollateralId .invoke = true)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩)
    (rejected : ¬ Conditions borrower quantity pre price observedAt now) :
    run borrower store ctx ids quantity env now pre = .error Typed.Refusal.guard := by
  have actual := guard_evaluate borrower quantity pre ctx.principal env now observedAt price point
  have decision : decide (Conditions borrower quantity pre price observedAt now) = false :=
    decide_eq_false rejected
  rw [decision] at actual
  have observed := template_evaluate borrower quantity pre ctx.principal env now
  rw [actual,bound] at observed
  have domain : ctx.domain = .lending := by cases ctx.domain; rfl
  simp [run,Typed.execute,registry,request,bound,domain,signature,Args.check,
    (show (template borrower).partyArity = 0 from rfl),
    (show (template borrower).signature = [.amount Asset.collateral] from rfl),
    invoke,Except.mapError,bind,Except.bind]
  rw [show Args.check (template borrower).signature [⟨.amount Asset.collateral,quantity⟩] =
    .ok (Args.cons quantity Args.nil) from rfl]
  simp [observed,Except.mapError,Except.map,bind,Except.bind,applyEvaluated,evaluated]

end DefiKernel.Lending.WithdrawCollateral

