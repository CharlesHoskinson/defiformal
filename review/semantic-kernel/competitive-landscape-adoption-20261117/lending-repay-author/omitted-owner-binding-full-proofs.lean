import DefiKernel.Lending.Types
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

/-! Repayment is a cash transfer plus capped liability/supply burn; no oracle or health guard. -/
namespace DefiKernel.Lending.Repay
open DefiKernel.Typed DefiKernel.Lending

def signature : List (Unit Asset) := [.amount .cash]
def amount : E signature (.amount Asset.cash) := .arg .here
/-- Explicit denomination: one cash unit per debt unit. -/
def debtBurn : E signature (.amount Asset.debt) :=
  .binary (.unconvert Asset.debt Asset.cash) amount (.lit 1)
def outstanding (borrower : Borrower) : E signature (.amount Asset.cash) :=
  .binary (.convert Asset.debt Asset.cash) (.balance (ref .debt borrower.party)) (.lit 1)
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := .binary .and (.binary (.le (.amount Asset.cash)) (.lit 0) amount)
    (.binary (.le (.amount Asset.cash)) amount (outstanding borrower))
  deltas := [
    ⟨.cash, ref .cash borrower.party, .unary (.neg (.amount Asset.cash)) amount⟩,
    ⟨.cash, ref .cash .pool, amount⟩,
    ⟨.debt, ref .debt borrower.party, .unary (.neg (.amount Asset.debt)) debtBurn⟩]
  supplyDeltas := [⟨.lending, .debt, .unary (.neg (.amount Asset.debt)) debtBurn⟩]
  stateReads := [packedRef .debt borrower.party]
  envReads := []
  writes := [packedRef .cash borrower.party, packedRef .cash .pool, packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = repayId then some (template borrower) else none

def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) : Request Party Asset Domain :=
  ⟨repayId, [], [⟨.amount .cash, quantity⟩], ids, none⟩
/-- The public request always binds the intended borrower to the authenticated actual caller. -/
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx (fun _ => none) 0 (request borrower ids quantity) pre

def authorityConfig (borrower : Borrower) : AuthorityConfig Party Domain :=
  registryAuthorityConfig (registry borrower) (fun _ => .admin)
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,repayId,.invoke⟩,
  ⟨borrower.party,.lending,repayId,.debit (.lending,borrower.party,.cash)⟩,
  ⟨borrower.party,.lending,repayId,.debit (.lending,borrower.party,.debt)⟩,
  ⟨borrower.party,.lending,repayId,.changeSupply .lending .debt⟩]
def issueGrants (borrower : Borrower) (store : Store) :
    List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | grant::rest => do
    let (_, next) ← issueCapability (authorityConfig borrower) ⟨.admin,.lending⟩ store grant
    issueGrants borrower next rest
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  issueGrants borrower .empty (grants borrower)
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩,⟨3⟩]
def evaluated (borrower : Borrower) (quantity : ℚ) (pre : Ledger) :
    Evaluated Party Asset Domain :=
  ⟨decide (0 ≤ quantity) && decide (quantity ≤ pre.balance (.lending,borrower.party,.debt)),
    [((.lending,borrower.party,.cash),-quantity), ((.lending,.pool,.cash),quantity),
      ((.lending,borrower.party,.debt),-quantity)],
    [((.lending,.debt),-quantity)],
    [(.lending,borrower.party,.debt)], [], [(.lending,borrower.party,.debt)], [],
    [(.lending,borrower.party,.cash), (.lending,.pool,.cash), (.lending,borrower.party,.debt)]⟩

theorem template_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (ctx : InvocationContext Party Domain) :
    (template borrower).evaluate ⟨pre, (fun _ => none), ctx.principal, [],
      Args.cons quantity Args.nil, 0⟩ = .ok (evaluated borrower quantity pre) := by
  simp [Template.evaluate, Template.requiredStateReads, Template.requiredEnvReads,
    template, amount, debtBurn, outstanding, signature, ref, packedRef,
    Expr.eval, readBalance, Expr.stateReads, Expr.envReads, resolveRefs, CellRef.resolve,
    PartyRef.resolve, Args.get, BinaryOp.eval, UnaryOp.eval, numericValue, numericRat,
    evaluated, bind, Except.bind, pure, Except.pure]
  rfl

theorem run_ok_iff (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World) :
    run borrower store ctx ids quantity pre = .ok post ↔
      ctx.principal = borrower.party ∧ hasAuthority store ids ctx repayId .invoke = true ∧
      (evaluated borrower quantity pre).Valid store ctx (request borrower ids quantity) pre ∧
      post.capabilities = store ∧ ∀ cell,
        post.state.balance cell = pre.balance cell + (evaluated borrower quantity pre).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry borrower) store ctx
    (fun _ => none) 0 (request borrower ids quantity) pre post
  constructor
  · intro success
    obtain ⟨selected, registered, actor, dom, arity, args, checked, invoke, e,
      observed, valid, capabilities, balances⟩ := correspondence.mp success
    have selectedEq : selected = template borrower := by
      simpa [registry, request] using registered.symm
    subst selected
    have sameArgs : args = Args.cons quantity Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have sameEvaluation : e = evaluated borrower quantity pre :=
      Except.ok.inj (observed.symm.trans (template_evaluate borrower quantity pre ctx))
    subst e
    have bound : ctx.principal = borrower.party := by
      simpa [request, eq_comm] using actor
    exact ⟨bound, invoke, valid, capabilities, balances⟩
  · rintro ⟨bound, invoke, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨template borrower, ?_, ?_, ?_, rfl, Args.cons quantity Args.nil, rfl,
      invoke, evaluated borrower quantity pre, template_evaluate borrower quantity pre ctx,
      valid, capabilities, balances⟩
    · simp [registry, request]
    · simp [request, bound]
    · cases ctx.domain; rfl

theorem borrower_cash_effect (borrower : Borrower) (quantity : ℚ) (pre : Ledger) :
    (evaluated borrower quantity pre).effect (.lending,borrower.party,.cash) = -quantity := by
  cases borrower <;> simp [Evaluated.effect, evaluated, Borrower.party]

theorem pool_cash_effect (borrower : Borrower) (quantity : ℚ) (pre : Ledger) :
    (evaluated borrower quantity pre).effect (.lending,.pool,.cash) = quantity := by
  cases borrower <;> simp [Evaluated.effect, evaluated, Borrower.party]

theorem borrower_debt_effect (borrower : Borrower) (quantity : ℚ) (pre : Ledger) :
    (evaluated borrower quantity pre).effect (.lending,borrower.party,.debt) = -quantity := by
  simp [Evaluated.effect, evaluated]

theorem effect_outside (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (cell : Cell Party Asset Domain)
    (cash : cell ≠ (.lending,borrower.party,.cash))
    (pool : cell ≠ (.lending,.pool,.cash))
    (debt : cell ≠ (.lending,borrower.party,.debt)) :
    (evaluated borrower quantity pre).effect cell = 0 := by
  simp [Evaluated.effect, evaluated, Ne.symm cash, Ne.symm pool, Ne.symm debt]

theorem supply_value (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (domain : Domain) (asset : Asset) :
    (evaluated borrower quantity pre).supply domain asset =
      if asset = .debt then -quantity else 0 := by
  cases domain; cases asset <;> simp [Evaluated.supply, evaluated]

/-- Successful repayment couples cash movement and liability reduction for the authenticated owner. -/
theorem actual_effects (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post) :
    ctx.principal = borrower.party ∧ 0 ≤ quantity ∧
      quantity ≤ pre.balance (.lending,borrower.party,.debt) ∧
      post.state.balance (.lending,borrower.party,.cash) =
        pre.balance (.lending,borrower.party,.cash) - quantity ∧
      post.state.balance (.lending,.pool,.cash) = pre.balance (.lending,.pool,.cash) + quantity ∧
      post.state.balance (.lending,borrower.party,.debt) =
        pre.balance (.lending,borrower.party,.debt) - quantity ∧ post.capabilities = store := by
  obtain ⟨bound, _, valid, capabilities, balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity pre post).mp success
  have guard := valid.1
  have cap : 0 ≤ quantity ∧ quantity ≤ pre.balance (.lending,borrower.party,.debt) := by
    simpa [evaluated, Bool.and_eq_true] using guard
  refine ⟨bound, cap.1, cap.2, ?_, ?_, ?_, capabilities⟩
  · simpa only [borrower_cash_effect, sub_eq_add_neg] using balances (.lending,borrower.party,.cash)
  · simpa only [pool_cash_effect] using balances (.lending,.pool,.cash)
  · simpa only [borrower_debt_effect, sub_eq_add_neg] using balances (.lending,borrower.party,.debt)

/-- Cash and collateral are conserved; debt instead reconciles to its negative supply delta. -/
theorem actual_accounting (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post) :
    ∀ asset, total post.state .lending asset = total pre .lending asset +
      (if asset = .debt then -quantity else 0) := by
  obtain ⟨_, _, valid, capabilities, balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request borrower ids quantity) pre
    (evaluated borrower quantity pre) post).mpr ⟨valid, capabilities, balances⟩
  intro asset
  simpa only [supply_value] using applyEvaluated_accounting store ctx (request borrower ids quantity)
    pre (evaluated borrower quantity pre) post applied .lending asset

theorem collateral_cells_unchanged (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (post : World) (success : run borrower store ctx ids quantity pre = .ok post)
    (party : Party) :
    post.state.balance (.lending,party,.collateral) = pre.balance (.lending,party,.collateral) := by
  obtain ⟨_, _, _, _, balances⟩ := (run_ok_iff borrower store ctx ids quantity pre post).mp success
  simpa [Evaluated.effect, evaluated] using balances (.lending,party,.collateral)

theorem sum_if_party (party : Party) (value : ℚ) :
    ∑ p : Party, (if party = p then value else 0) = value := by
  simp [Finset.sum_ite_eq, Finset.mem_univ]

theorem evaluated_valid (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger)
    (nonnegative : 0 ≤ quantity)
    (debtCap : quantity ≤ pre.balance (.lending,borrower.party,.debt))
    (cashFunded : quantity ≤ pre.balance (.lending,borrower.party,.cash))
    (debitCash : hasAuthority store ids ctx repayId (.debit (.lending,borrower.party,.cash)) = true)
    (debitDebt : hasAuthority store ids ctx repayId (.debit (.lending,borrower.party,.debt)) = true)
    (supply : hasAuthority store ids ctx repayId (.changeSupply .lending .debt) = true) :
    (evaluated borrower quantity pre).Valid store ctx (request borrower ids quantity) pre := by
  have balances : ∀ cell, 0 ≤ pre.balance cell + (evaluated borrower quantity pre).effect cell := by
    intro cell
    by_cases cash : cell = (.lending,borrower.party,.cash)
    · subst cell; rw [borrower_cash_effect]; linarith
    · by_cases pool : cell = (.lending,.pool,.cash)
      · subst cell; rw [pool_cash_effect]; linarith [pre.nonneg (.lending,.pool,.cash)]
      · by_cases debt : cell = (.lending,borrower.party,.debt)
        · subst cell; rw [borrower_debt_effect]; linarith
        · rw [effect_outside borrower quantity pre cell cash pool debt]
          simpa using pre.nonneg cell
  refine ⟨?_, ?_, rfl, ?_, ?_, ?_, balances, ?_, ?_⟩
  · simp [evaluated, nonnegative, debtCap]
  · simp [Evaluated.stateReadsOK, evaluated]
  · have domain : ctx.domain = .lending := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK, decide_eq_true_eq]
    refine ⟨?_, ?_, ?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK, decide_eq_true_eq]
    intro cell negative
    by_cases cash : cell = (.lending,borrower.party,.cash)
    · subst cell; exact debitCash
    · by_cases pool : cell = (.lending,.pool,.cash)
      · subst cell; rw [pool_cash_effect] at negative; linarith
      · by_cases debt : cell = (.lending,borrower.party,.debt)
        · subst cell; exact debitDebt
        · rw [effect_outside borrower quantity pre cell cash pool debt] at negative
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
      rw [Finset.sum_add_distrib, sum_if_party, sum_if_party]
      ring
    | collateral => simp [Evaluated.effect, evaluated, Evaluated.supply]
    | debt =>
      simp [Evaluated.effect, evaluated, Evaluated.supply]
  · simp only [Evaluated.writesOK, decide_eq_true_eq]
    intro cell outside
    simp [evaluated, List.mem_cons, List.not_mem_nil, or_false, not_or] at outside
    exact effect_outside borrower quantity pre cell outside.1 outside.2.1 outside.2.2

/-- Funding and real rights construct execution; no successful output or Valid certificate premise. -/
theorem funded_success (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (quantity : ℚ) (pre : Ledger) (nonnegative : 0 ≤ quantity)
    (debtCap : quantity ≤ pre.balance (.lending,borrower.party,.debt))
    (cashFunded : quantity ≤ pre.balance (.lending,borrower.party,.cash))
    (invoke : hasAuthority store ids (borrowerContext borrower) repayId .invoke = true)
    (debitCash : hasAuthority store ids (borrowerContext borrower) repayId
      (.debit (.lending,borrower.party,.cash)) = true)
    (debitDebt : hasAuthority store ids (borrowerContext borrower) repayId
      (.debit (.lending,borrower.party,.debt)) = true)
    (supply : hasAuthority store ids (borrowerContext borrower) repayId
      (.changeSupply .lending .debt) = true) :
    ∃ post, run borrower store (borrowerContext borrower) ids quantity pre = .ok post := by
  have valid := evaluated_valid borrower store (borrowerContext borrower) ids quantity pre
    nonnegative debtCap cashFunded debitCash debitDebt supply
  have balances : ∀ cell, 0 ≤ pre.balance cell + (evaluated borrower quantity pre).effect cell :=
    valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell => pre.balance cell + (evaluated borrower quantity pre).effect cell,
    balances⟩, store⟩
  exact ⟨post, (run_ok_iff borrower store (borrowerContext borrower) ids quantity pre post).mpr
    ⟨rfl, invoke, valid, rfl, by intro cell; rfl⟩⟩

def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
/-- Exact result of the real administrative provisioning API, not a substituted success store. -/
theorem provisioned_exact (borrower : Borrower) : provisioned borrower = .ok (fixtureStore borrower) := by
  cases borrower <;> decide

theorem fixture_rights (borrower : Borrower) :
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) repayId .invoke = true ∧
      hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) repayId
        (.debit (.lending,borrower.party,.cash)) = true ∧
      hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) repayId
        (.debit (.lending,borrower.party,.debt)) = true ∧
      hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) repayId
        (.changeSupply .lending .debt) = true := by
  cases borrower <;> decide

theorem template_evaluate_caller (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party) :
    (template borrower).evaluate ⟨pre, (fun _ => none), caller, [],
      Args.cons quantity Args.nil, 0⟩ = .ok (evaluated borrower quantity pre) :=
  template_evaluate borrower quantity pre ⟨caller,.lending⟩

theorem run_eq_apply (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger)
    (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx repayId .invoke = true) :
    run borrower store ctx ids quantity pre =
      applyEvaluated store ctx (request borrower ids quantity) pre (evaluated borrower quantity pre) := by
  have domain : ctx.domain = .lending := by cases ctx.domain; rfl
  simp [run, Typed.execute, registry, request, bound, domain, signature, Args.check,
    (show (template borrower).partyArity = 0 from rfl),
    (show (template borrower).signature = [.amount Asset.cash] from rfl),
    template_evaluate_caller, invoke, Except.mapError, bind, Except.bind]
  rw [show Args.check (template borrower).signature [⟨.amount Asset.cash, quantity⟩] =
    .ok (Args.cons quantity Args.nil) from rfl]
  simp [template_evaluate_caller, Except.mapError, bind, Except.bind]

theorem over_repay_refusal (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger)
    (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx repayId .invoke = true)
    (over : pre.balance (.lending,borrower.party,.debt) < quantity) :
    run borrower store ctx ids quantity pre = .error Typed.Refusal.guard := by
  rw [run_eq_apply borrower store ctx ids quantity pre bound invoke]
  have guard : (evaluated borrower quantity pre).guard = false := by
    simp [evaluated, not_le.mpr over]
  simp [applyEvaluated, guard]

theorem insufficient_cash_ne_success (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (post : World) (poor : pre.balance (.lending,borrower.party,.cash) < quantity) :
    run borrower store ctx ids quantity pre ≠ .ok post := by
  intro success
  have effects := actual_effects borrower store ctx ids quantity pre post success
  have balance := effects.2.2.2.1
  have nonnegative := post.state.nonneg (.lending,borrower.party,.cash)
  linarith

end DefiKernel.Lending.Repay
