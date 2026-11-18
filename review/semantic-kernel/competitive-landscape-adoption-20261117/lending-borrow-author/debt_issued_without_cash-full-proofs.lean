import DefiKernel.Lending.Oracle
import DefiKernel.Lending.Support
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

namespace DefiKernel.Lending.Borrow
open DefiKernel.Typed
def signature : List (Unit Asset) := [.amount .cash]
def amount : E signature (.amount Asset.cash) := .arg .here
def debtMint : E signature (.amount Asset.debt) :=
  .binary (.unconvert Asset.debt Asset.cash) amount (.lit 1)
def guard (borrower : Borrower) : E signature .bool := Oracle.allGuards [
  .binary (.le (.amount Asset.cash)) (.lit 0) amount,
  .binary (.lt (.price Asset.collateral Asset.cash)) (.lit 0) Oracle.price,
  .binary (.le .scalar) (.timestamp Oracle.key) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp Oracle.key) (.lit Oracle.maxAge)),
  .binary (.le (.amount Asset.cash))
    (.binary (.scale (.amount Asset.cash)) (.lit 2)
      (.binary (.add (.amount Asset.cash)) (Oracle.debtCash borrower) amount))
    (Oracle.lockedCash borrower)]
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := guard borrower
  deltas := [⟨.cash,ref .cash .pool,.lit 0⟩,
    ⟨.cash,ref .cash borrower.party,.lit 0⟩,⟨.debt,ref .debt borrower.party,debtMint⟩]
  supplyDeltas := [⟨.lending,.debt,debtMint⟩]
  stateReads := [packedRef .debt borrower.party,packedRef .collateral borrower.custody]
  envReads := [.observation Oracle.key,.currentTime]
  writes := [packedRef .cash .pool,packedRef .cash borrower.party,packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = borrowId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) : Request Party Asset Domain :=
  ⟨borrowId,[],[⟨.amount .cash,quantity⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx env now (request borrower ids quantity) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,borrowId,.invoke⟩,
  ⟨borrower.party,.lending,borrowId,.debit (.lending,.pool,.cash)⟩,
  ⟨borrower.party,.lending,borrowId,.changeSupply .lending .debt⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩]
def evaluated (borrower : Borrower) (quantity : ℚ) (condition : Bool) : Evaluated Party Asset Domain :=
  ⟨condition,
    [((.lending,.pool,.cash),-quantity), ((.lending,borrower.party,.cash),quantity),
      ((.lending,borrower.party,.debt),quantity)],
    [((.lending,.debt),quantity)],
    [(.lending,borrower.party,.debt),(.lending,borrower.custody,.collateral)],
    (template borrower).requiredEnvReads,
    [(.lending,borrower.party,.debt),(.lending,borrower.custody,.collateral)],
    [.observation Oracle.key,.currentTime],
    [(.lending,.pool,.cash),(.lending,borrower.party,.cash),(.lending,borrower.party,.debt)]⟩

theorem required_reads (borrower : Borrower) : (template borrower).requiredStateReads =
    [packedRef .debt borrower.party,packedRef .collateral borrower.custody] := rfl

theorem template_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party)
    (env : Environment Asset Domain) (now : Nat) :
    (template borrower).evaluate ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ =
      ((guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩).map
        (fun condition => evaluated borrower quantity condition) := by
  cases actual : (guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ <;>
    simp [Template.evaluate, required_reads, Template.requiredStateReads, Template.requiredEnvReads,
      template, amount, debtMint, signature, ref, packedRef, actual,
      Expr.eval, Expr.stateReads, Expr.envReads, resolveRefs, CellRef.resolve, PartyRef.resolve,
      Args.get, BinaryOp.eval, UnaryOp.eval, numericValue, numericRat, evaluated,
      Except.map, bind, Except.bind, pure, Except.pure]
  all_goals simp [guard, amount, debtMint, signature, Oracle.allGuards, Oracle.debtCash, Oracle.lockedCash, Oracle.price,
    Expr.stateReads, Expr.envReads, ref, packedRef, CellRef.resolve, PartyRef.resolve,
    bind, Except.bind, pure, Except.pure]

def Conditions (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (price : ℚ) (observedAt now : Nat) : Prop :=
  0 ≤ quantity ∧ 0 < price ∧ observedAt ≤ now ∧ now ≤ observedAt + Oracle.maxAge ∧
    2 * (pre.balance (.lending,borrower.party,.debt) + quantity) ≤
      pre.balance (.lending,borrower.custody,.collateral) * price

instance (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (price : ℚ) (observedAt now : Nat) :
    Decidable (Conditions borrower quantity pre price observedAt now) := by
  unfold Conditions
  infer_instance

theorem normalize_guard_decisions (p q r s t : Prop)
    [Decidable p] [Decidable q] [Decidable r] [Decidable s] [Decidable t] :
    (decide p && (decide q && (decide r && (decide s && decide t)))) = decide (p ∧ q ∧ r ∧ s ∧ t) := by
  simp only [Bool.decide_and]

theorem guard_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party)
    (env : Environment Asset Domain) (now observedAt : Nat) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩) :
    (guard borrower).eval ⟨pre,env,caller,[],Args.cons quantity Args.nil,now⟩ =
      .ok (decide (Conditions borrower quantity pre price observedAt now)) := by
  have freshCast : ((now : ℚ) ≤ (observedAt : ℚ)+5) ↔ now ≤ observedAt+5 := by norm_cast
  simp [guard, Oracle.allGuards, Oracle.price, Oracle.debtCash, Oracle.lockedCash,
    amount, signature, Expr.eval, readObservation, readBalance, point,
    CellRef.resolve, PartyRef.resolve, ref, Args.get, BinaryOp.eval, UnaryOp.eval,
    numericValue, numericRat, bind, Except.bind, pure, Except.pure,
    Conditions, Oracle.maxAge, Nat.cast_add, Nat.cast_le, freshCast]
  exact normalize_guard_decisions (0 ≤ quantity) (0 < price) (observedAt ≤ now)
    (now ≤ observedAt+5)
    (2*(pre.balance (.lending,borrower.party,.debt)+quantity) ≤
      pre.balance (.lending,borrower.custody,.collateral)*price)

theorem run_ok_iff (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World) :
    run borrower store ctx ids quantity env now pre = .ok post ↔
      ctx.principal = borrower.party ∧ hasAuthority store ids ctx borrowId .invoke = true ∧
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

theorem pool_cash_effect (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    (evaluated borrower quantity condition).effect (.lending,.pool,.cash) = -quantity := by
  cases borrower <;> simp [Evaluated.effect, evaluated, Borrower.party]
theorem borrower_cash_effect (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    (evaluated borrower quantity condition).effect (.lending,borrower.party,.cash) = quantity := by
  cases borrower <;> simp [Evaluated.effect, evaluated, Borrower.party]
theorem borrower_debt_effect (borrower : Borrower) (quantity : ℚ) (condition : Bool) :
    (evaluated borrower quantity condition).effect (.lending,borrower.party,.debt) = quantity := by
  simp [Evaluated.effect, evaluated]
theorem supply_value (borrower : Borrower) (quantity : ℚ) (condition : Bool)
    (domain : Domain) (asset : Asset) :
    (evaluated borrower quantity condition).supply domain asset = if asset = .debt then quantity else 0 := by
  cases domain; cases asset <;> simp [Evaluated.supply, evaluated]

theorem actual_effects (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World) (success : run borrower store ctx ids quantity env now pre = .ok post) :
    ctx.principal = borrower.party ∧
      post.state.balance (.lending,.pool,.cash) = pre.balance (.lending,.pool,.cash)-quantity ∧
      post.state.balance (.lending,borrower.party,.cash) = pre.balance (.lending,borrower.party,.cash)+quantity ∧
      post.state.balance (.lending,borrower.party,.debt) = pre.balance (.lending,borrower.party,.debt)+quantity ∧
      (∀ party, post.state.balance (.lending,party,.collateral) = pre.balance (.lending,party,.collateral)) ∧
      post.capabilities = store := by
  obtain ⟨bound, _, _, _, capabilities, balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  refine ⟨bound, ?_, ?_, ?_, ?_, capabilities⟩
  · simpa only [pool_cash_effect, sub_eq_add_neg] using balances (.lending,.pool,.cash)
  · simpa only [borrower_cash_effect] using balances (.lending,borrower.party,.cash)
  · simpa only [borrower_debt_effect] using balances (.lending,borrower.party,.debt)
  · intro party
    simpa [Evaluated.effect, evaluated] using balances (.lending,party,.collateral)

theorem actual_accounting (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) (post : World) (success : run borrower store ctx ids quantity env now pre = .ok post) :
    ∀ asset, total post.state .lending asset = total pre .lending asset +
      (if asset = .debt then quantity else 0) := by
  obtain ⟨_, _, _, valid, capabilities, balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity env now pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request borrower ids quantity) pre
    (evaluated borrower quantity true) post).mpr ⟨valid, capabilities, balances⟩
  intro asset
  simpa only [supply_value] using applyEvaluated_accounting store ctx (request borrower ids quantity)
    pre (evaluated borrower quantity true) post applied .lending asset

/-- Actual success derives the price/freshness/post-increase policy from the observed oracle point. -/
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
    0 ≤ quantity ∧ 0 < price ∧ observedAt ≤ now ∧ now ≤ observedAt+Oracle.maxAge ∧
      2*post.state.balance (.lending,borrower.party,.debt) ≤
        post.state.balance (.lending,borrower.custody,.collateral)*price := by
  have conditions := success_conditions borrower store ctx ids quantity env now observedAt pre post price point success
  have effects := actual_effects borrower store ctx ids quantity env now pre post success
  refine ⟨conditions.1, conditions.2.1, conditions.2.2.1, conditions.2.2.2.1, ?_⟩
  rw [effects.2.2.2.1, effects.2.2.2.2.1 borrower.custody]
  exact conditions.2.2.2.2

theorem effect_outside (borrower : Borrower) (quantity : ℚ) (condition : Bool)
    (cell : Cell Party Asset Domain) (pool : cell ≠ (.lending,.pool,.cash))
    (cash : cell ≠ (.lending,borrower.party,.cash))
    (debt : cell ≠ (.lending,borrower.party,.debt)) :
    (evaluated borrower quantity condition).effect cell = 0 := by
  simp [Evaluated.effect, evaluated, Ne.symm pool, Ne.symm cash, Ne.symm debt]

theorem evaluated_valid (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (nonnegative : 0 ≤ quantity)
    (funded : quantity ≤ pre.balance (.lending,.pool,.cash))
    (debitPool : hasAuthority store ids ctx borrowId (.debit (.lending,.pool,.cash)) = true)
    (supply : hasAuthority store ids ctx borrowId (.changeSupply .lending .debt) = true) :
    (evaluated borrower quantity true).Valid store ctx (request borrower ids quantity) pre := by
  have balances : ∀ cell, 0 ≤ pre.balance cell + (evaluated borrower quantity true).effect cell := by
    intro cell
    by_cases pool : cell = (.lending,.pool,.cash)
    · subst cell; rw [pool_cash_effect]; linarith
    · by_cases cash : cell = (.lending,borrower.party,.cash)
      · subst cell; rw [borrower_cash_effect]; linarith [pre.nonneg (.lending,borrower.party,.cash)]
      · by_cases debt : cell = (.lending,borrower.party,.debt)
        · subst cell; rw [borrower_debt_effect]; linarith [pre.nonneg (.lending,borrower.party,.debt)]
        · rw [effect_outside borrower quantity true cell pool cash debt]
          simpa using pre.nonneg cell
  refine ⟨rfl, ?_, ?_, ?_, ?_, ?_, balances, ?_, ?_⟩
  · simp [Evaluated.stateReadsOK, evaluated]
  · simp [Evaluated.envReadsOK, evaluated, Template.requiredEnvReads, template, guard,
      Oracle.allGuards, Oracle.price, Oracle.debtCash, Oracle.lockedCash, amount, debtMint,
      Expr.envReads]
  · have domain : ctx.domain = .lending := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK, decide_eq_true_eq]
    refine ⟨?_, ?_, ?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK, decide_eq_true_eq]
    intro cell negative
    by_cases pool : cell = (.lending,.pool,.cash)
    · subst cell; exact debitPool
    · by_cases cash : cell = (.lending,borrower.party,.cash)
      · subst cell; rw [borrower_cash_effect] at negative; linarith
      · by_cases debt : cell = (.lending,borrower.party,.debt)
        · subst cell; rw [borrower_debt_effect] at negative; linarith
        · rw [effect_outside borrower quantity true cell pool cash debt] at negative
          exact (lt_irrefl _ negative).elim
  · simp only [Evaluated.suppliesOK, decide_eq_true_eq]
    intro d a changed
    cases d
    cases a <;> simp only [supply_value, reduceCtorEq, if_false, if_true] at changed
    · exact (changed rfl).elim
    · exact (changed rfl).elim
    · exact supply
  · simp only [Evaluated.accountingOK, decide_eq_true_eq]
    intro d a
    cases d
    cases a with
    | cash =>
      simp [Evaluated.effect, evaluated, Evaluated.supply]
      rw [Finset.sum_add_distrib, Support.sum_if_party, Support.sum_if_party]
      ring
    | collateral => simp [Evaluated.effect, evaluated, Evaluated.supply]
    | debt => simp [Evaluated.effect, evaluated, Evaluated.supply]
  · simp only [Evaluated.writesOK, decide_eq_true_eq]
    intro cell outside
    simp [evaluated, List.mem_cons, List.not_mem_nil, or_false, not_or] at outside
    exact effect_outside borrower quantity true cell outside.1 outside.2.1 outside.2.2

theorem funded_success (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (quantity : ℚ) (env : Environment Asset Domain) (now observedAt : Nat) (pre : Ledger) (price : ℚ)
    (point : env Oracle.key = some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩)
    (policy : Conditions borrower quantity pre price observedAt now)
    (funded : quantity ≤ pre.balance (.lending,.pool,.cash))
    (invoke : hasAuthority store ids (borrowerContext borrower) borrowId .invoke = true)
    (debitPool : hasAuthority store ids (borrowerContext borrower) borrowId
      (.debit (.lending,.pool,.cash)) = true)
    (supply : hasAuthority store ids (borrowerContext borrower) borrowId
      (.changeSupply .lending .debt) = true) :
    ∃ post, run borrower store (borrowerContext borrower) ids quantity env now pre = .ok post := by
  have valid := evaluated_valid borrower store (borrowerContext borrower) ids quantity pre
    policy.1 funded debitPool supply
  have balances : ∀ cell, 0 ≤ pre.balance cell + (evaluated borrower quantity true).effect cell :=
    valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell => pre.balance cell + (evaluated borrower quantity true).effect cell,
    balances⟩,store⟩
  have actual := guard_evaluate borrower quantity pre borrower.party env now observedAt price point
  have decision : decide (Conditions borrower quantity pre price observedAt now) = true := by
    simpa using policy
  rw [decision] at actual
  exact ⟨post, (run_ok_iff borrower store (borrowerContext borrower) ids quantity env now pre post).mpr
    ⟨rfl, invoke, actual, valid, rfl, by intro cell; rfl⟩⟩

theorem provisioned_exact (borrower : Borrower) : provisioned borrower = .ok (fixtureStore borrower) := by
  cases borrower <;> decide

theorem fixture_rights (borrower : Borrower) :
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) borrowId .invoke = true ∧
      hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) borrowId
        (.debit (.lending,.pool,.cash)) = true ∧
      hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) borrowId
        (.changeSupply .lending .debt) = true := by
  cases borrower <;> decide

end DefiKernel.Lending.Borrow
