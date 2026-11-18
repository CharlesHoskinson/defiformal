import DefiKernel.Lending.Support
import Mathlib.Tactic.Ring

/-! Unindexed per-call simple interest on current debt. Repeated intervals accrue again. -/
namespace DefiKernel.Lending.Accrue
open DefiKernel.Typed
def signature : List (Unit Asset) := [.scalar,.scalar]
def rate : E signature .scalar := .arg .here
def elapsed : E signature .scalar := .arg (.there .here)
def rateTime : E signature .scalar := .binary (.scale .scalar) rate elapsed
def increment (borrower : Borrower) : E signature (.amount Asset.debt) :=
  .binary (.scale (.amount Asset.debt)) rateTime (.balance (ref .debt borrower.party))
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := .lit true
  deltas := [⟨.debt,ref .debt borrower.party,increment borrower⟩]
  supplyDeltas := [⟨.lending,.debt,increment borrower⟩]
  stateReads := [packedRef .debt borrower.party]
  envReads := []
  writes := [packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = accrueId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (rate elapsed : ℚ) : Request Party Asset Domain :=
  ⟨accrueId,[],[⟨.scalar,rate⟩,⟨.scalar,elapsed⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx (fun _ => none) 0 (request borrower ids rate elapsed) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,accrueId,.invoke⟩,
  ⟨borrower.party,.lending,accrueId,.changeSupply .lending .debt⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩]


/-- Increment is denominated in debt, with scalar rate per abstract time unit. -/
def delta (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger) : ℚ :=
  (rate * elapsed) * pre.balance (.lending,borrower.party,.debt)
def evaluated (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger) :
    Evaluated Party Asset Domain :=
  ⟨decide (0 ≤ rate) && decide (0 ≤ elapsed),
    [((.lending,borrower.party,.debt),delta borrower rate elapsed pre)],
    [((.lending,.debt),delta borrower rate elapsed pre)],
    [(.lending,borrower.party,.debt),(.lending,borrower.party,.debt)], [],
    [(.lending,borrower.party,.debt)], [], [(.lending,borrower.party,.debt)]⟩

theorem template_evaluate (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger)
    (ctx : InvocationContext Party Domain) :
    (template borrower).evaluate ⟨pre, (fun _ => none), ctx.principal, [],
      Args.cons rate (Args.cons elapsed Args.nil), 0⟩ =
        .ok (evaluated borrower rate elapsed pre) := by
  simp [Template.evaluate, Template.requiredStateReads, Template.requiredEnvReads,
    template, Accrue.rate, Accrue.elapsed, rateTime, increment, signature, ref, packedRef,
    Expr.eval, readBalance, Expr.stateReads, Expr.envReads, resolveRefs, CellRef.resolve,
    PartyRef.resolve, Args.get, BinaryOp.eval, UnaryOp.eval, numericValue, numericRat,
    evaluated, delta, bind, Except.bind, pure, Except.pure]
  rfl
theorem run_ok_iff (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger) (post : World) :
    run borrower store ctx ids rate elapsed pre = .ok post ↔
      ctx.principal = borrower.party ∧ hasAuthority store ids ctx accrueId .invoke = true ∧
      (evaluated borrower rate elapsed pre).Valid store ctx (request borrower ids rate elapsed) pre ∧
      post.capabilities = store ∧ ∀ cell,
        post.state.balance cell = pre.balance cell + (evaluated borrower rate elapsed pre).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry borrower) store ctx
    (fun _ => none) 0 (request borrower ids rate elapsed) pre post
  constructor
  · intro success
    obtain ⟨selected, registered, actor, dom, arity, args, checked, invoke, e,
      observed, valid, capabilities, balances⟩ := correspondence.mp success
    have selectedEq : selected = template borrower := by
      simpa [registry, request] using registered.symm
    subst selected
    have sameArgs : args = Args.cons rate (Args.cons elapsed Args.nil) := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have sameEvaluation : e = evaluated borrower rate elapsed pre :=
      Except.ok.inj (observed.symm.trans (template_evaluate borrower rate elapsed pre ctx))
    subst e
    have bound : ctx.principal = borrower.party := by
      simpa [request, eq_comm] using actor
    exact ⟨bound, invoke, valid, capabilities, balances⟩
  · rintro ⟨bound, invoke, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨template borrower, ?_, ?_, ?_, rfl, Args.cons rate (Args.cons elapsed Args.nil), rfl,
      invoke, evaluated borrower rate elapsed pre, template_evaluate borrower rate elapsed pre ctx,
      valid, capabilities, balances⟩
    · simp [registry, request]
    · simp [request, bound]
    · cases ctx.domain; rfl


theorem debt_effect (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger) :
    (evaluated borrower rate elapsed pre).effect (.lending,borrower.party,.debt) =
      delta borrower rate elapsed pre := by
  simp [Evaluated.effect, evaluated]

theorem effect_outside (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger)
    (cell : Cell Party Asset Domain) (outside : cell ≠ (.lending,borrower.party,.debt)) :
    (evaluated borrower rate elapsed pre).effect cell = 0 := by
  simp [Evaluated.effect, evaluated, Ne.symm outside]

theorem supply_value (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger)
    (domain : Domain) (asset : Asset) :
    (evaluated borrower rate elapsed pre).supply domain asset =
      if asset = .debt then delta borrower rate elapsed pre else 0 := by
  cases domain; cases asset <;> simp [Evaluated.supply, evaluated]

theorem actual_effects (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids rate elapsed pre = .ok post) :
    ctx.principal = borrower.party ∧ 0 ≤ rate ∧ 0 ≤ elapsed ∧
      post.state.balance (.lending,borrower.party,.debt) =
        pre.balance (.lending,borrower.party,.debt) * (1 + rate * elapsed) ∧
      post.capabilities = store := by
  obtain ⟨bound, _, valid, capabilities, balances⟩ :=
    (run_ok_iff borrower store ctx ids rate elapsed pre post).mp success
  have guard : 0 ≤ rate ∧ 0 ≤ elapsed := by
    simpa [evaluated, Bool.and_eq_true] using valid.1
  refine ⟨bound,guard.1,guard.2,?_,capabilities⟩
  rw [balances, debt_effect, delta]
  ring

theorem actual_frame (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids rate elapsed pre = .ok post)
    (cell : Cell Party Asset Domain) (outside : cell ≠ (.lending,borrower.party,.debt)) :
    post.state.balance cell = pre.balance cell := by
  obtain ⟨_,_,_,_,balances⟩ := (run_ok_iff borrower store ctx ids rate elapsed pre post).mp success
  simpa only [effect_outside borrower rate elapsed pre cell outside, add_zero] using balances cell

theorem actual_accounting (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (rate elapsed : ℚ)
    (pre : Ledger) (post : World)
    (success : run borrower store ctx ids rate elapsed pre = .ok post) :
    ∀ asset, total post.state .lending asset = total pre .lending asset +
      (if asset = .debt then delta borrower rate elapsed pre else 0) := by
  obtain ⟨_,_,valid,capabilities,balances⟩ :=
    (run_ok_iff borrower store ctx ids rate elapsed pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request borrower ids rate elapsed) pre
    (evaluated borrower rate elapsed pre) post).mpr ⟨valid,capabilities,balances⟩
  intro asset
  simpa only [supply_value] using applyEvaluated_accounting store ctx
    (request borrower ids rate elapsed) pre (evaluated borrower rate elapsed pre) post applied
      .lending asset


theorem delta_nonneg (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger)
    (hr : 0 ≤ rate) (ht : 0 ≤ elapsed) : 0 ≤ delta borrower rate elapsed pre :=
  mul_nonneg (mul_nonneg hr ht) (pre.nonneg _)

theorem evaluated_valid (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (rate elapsed : ℚ)
    (pre : Ledger) (hr : 0 ≤ rate) (ht : 0 ≤ elapsed)
    (supply : hasAuthority store ids ctx accrueId (.changeSupply .lending .debt) = true) :
    (evaluated borrower rate elapsed pre).Valid store ctx (request borrower ids rate elapsed) pre := by
  have positive := delta_nonneg borrower rate elapsed pre hr ht
  have effects_nonneg : ∀ cell, 0 ≤ (evaluated borrower rate elapsed pre).effect cell := by
    intro cell
    by_cases same : cell = (.lending,borrower.party,.debt)
    · subst cell; rw [debt_effect]; exact positive
    · rw [effect_outside borrower rate elapsed pre cell same]
  refine ⟨?_,?_,rfl,?_,?_,?_,?_,?_,?_⟩
  · simp [evaluated,hr,ht]
  · simp [Evaluated.stateReadsOK,evaluated]
  · have domain : ctx.domain = .lending := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK, decide_eq_true_eq]
    refine ⟨?_,?_,?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK, decide_eq_true_eq]
    intro cell negative
    exact (not_lt_of_ge (effects_nonneg cell) negative).elim
  · simp only [Evaluated.suppliesOK, decide_eq_true_eq]
    intro d a changed
    cases d
    cases a <;> simp only [supply_value, reduceCtorEq, if_false, if_true] at changed
    · exact (changed rfl).elim
    · exact (changed rfl).elim
    · exact supply
  · intro cell
    exact add_nonneg (pre.nonneg cell) (effects_nonneg cell)
  · simp only [Evaluated.accountingOK, decide_eq_true_eq]
    intro d a
    cases d
    cases a <;> simp [Evaluated.effect,evaluated,Evaluated.supply]
  · simp only [Evaluated.writesOK, decide_eq_true_eq]
    intro cell outside
    simp [evaluated] at outside
    exact effect_outside borrower rate elapsed pre cell outside

/-- Real invocation and debt-supply authority construct success, even if health deteriorates. -/
theorem enabled_success (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (rate elapsed : ℚ) (pre : Ledger) (hr : 0 ≤ rate) (ht : 0 ≤ elapsed)
    (invoke : hasAuthority store ids (borrowerContext borrower) accrueId .invoke = true)
    (supply : hasAuthority store ids (borrowerContext borrower) accrueId
      (.changeSupply .lending .debt) = true) :
    ∃ post, run borrower store (borrowerContext borrower) ids rate elapsed pre = .ok post := by
  have valid := evaluated_valid borrower store (borrowerContext borrower) ids rate elapsed pre hr ht supply
  have nonnegative : ∀ cell, 0 ≤ pre.balance cell +
      (evaluated borrower rate elapsed pre).effect cell := valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell => pre.balance cell +
    (evaluated borrower rate elapsed pre).effect cell,nonnegative⟩,store⟩
  exact ⟨post,(run_ok_iff borrower store (borrowerContext borrower) ids rate elapsed pre post).mpr
    ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩⟩

theorem provisioned_exact (borrower : Borrower) :
    provisioned borrower = .ok (fixtureStore borrower) := by
  cases borrower <;> decide

theorem fixture_rights (borrower : Borrower) :
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) accrueId .invoke = true ∧
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower) accrueId
      (.changeSupply .lending .debt) = true := by
  cases borrower <;> decide

/-- Reapplying the same supplied interval compounds on the updated debt, rather than replaying idempotently. -/
theorem repeated_interval (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (rate elapsed : ℚ)
    (pre : Ledger) (first second : World)
    (one : run borrower store ctx ids rate elapsed pre = .ok first)
    (two : run borrower first.capabilities ctx ids rate elapsed first.state = .ok second) :
    second.state.balance (.lending,borrower.party,.debt) =
      pre.balance (.lending,borrower.party,.debt) * (1+rate*elapsed)^2 := by
  have firstDebt := (actual_effects borrower store ctx ids rate elapsed pre first one).2.2.2.1
  have secondDebt := (actual_effects borrower first.capabilities ctx ids rate elapsed
    first.state second two).2.2.2.1
  rw [secondDebt,firstDebt]
  ring



theorem template_evaluate_caller (borrower : Borrower) (rate elapsed : ℚ) (pre : Ledger) (caller : Party) :
    (template borrower).evaluate ⟨pre, (fun _ => none), caller, [],
      Args.cons rate (Args.cons elapsed Args.nil), 0⟩ = .ok (evaluated borrower rate elapsed pre) :=
  template_evaluate borrower rate elapsed pre ⟨caller,.lending⟩

theorem run_eq_apply (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger)
    (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx accrueId .invoke = true) :
    run borrower store ctx ids rate elapsed pre =
      applyEvaluated store ctx (request borrower ids rate elapsed) pre (evaluated borrower rate elapsed pre) := by
  have domain : ctx.domain = .lending := by cases ctx.domain; rfl
  simp [run, Typed.execute, registry, request, bound, domain, signature, Args.check,
    (show (template borrower).partyArity = 0 from rfl),
    (show (template borrower).signature = [.scalar,.scalar] from rfl),
    template_evaluate_caller, invoke, Except.mapError, bind, Except.bind]
  rw [show Args.check (template borrower).signature [⟨.scalar,rate⟩,⟨.scalar,elapsed⟩] =
    .ok (Args.cons rate (Args.cons elapsed Args.nil)) from rfl]
  simp [template_evaluate_caller, Except.mapError, bind, Except.bind]


/-- Actor binding and invocation precede the arithmetic policy guard. -/
theorem negative_parameter_refusal (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (rate elapsed : ℚ)
    (pre : Ledger) (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx accrueId .invoke = true)
    (negative : rate < 0 ∨ elapsed < 0) :
    run borrower store ctx ids rate elapsed pre = .error Typed.Refusal.guard := by
  rw [run_eq_apply borrower store ctx ids rate elapsed pre bound invoke]
  have guard : (evaluated borrower rate elapsed pre).guard = false := by
    rcases negative with hr | ht
    · simp [evaluated,not_le.mpr hr]
    · simp [evaluated,not_le.mpr ht]
  simp [applyEvaluated,guard]

/-- Two applications are constructible; no interval-uniqueness or idempotence premise is imposed. -/
theorem enabled_twice (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (rate elapsed : ℚ) (pre : Ledger) (hr : 0 ≤ rate) (ht : 0 ≤ elapsed)
    (invoke : hasAuthority store ids (borrowerContext borrower) accrueId .invoke = true)
    (supply : hasAuthority store ids (borrowerContext borrower) accrueId
      (.changeSupply .lending .debt) = true) :
    ∃ first second,
      run borrower store (borrowerContext borrower) ids rate elapsed pre = .ok first ∧
      run borrower first.capabilities (borrowerContext borrower) ids rate elapsed first.state =
        .ok second ∧
      second.state.balance (.lending,borrower.party,.debt) =
        pre.balance (.lending,borrower.party,.debt) * (1+rate*elapsed)^2 := by
  obtain ⟨first,one⟩ := enabled_success borrower store ids rate elapsed pre hr ht invoke supply
  have caps := (actual_effects borrower store (borrowerContext borrower) ids
    rate elapsed pre first one).2.2.2.2
  obtain ⟨second,two⟩ := enabled_success borrower first.capabilities ids rate elapsed
    first.state hr ht (caps ▸ invoke) (caps ▸ supply)
  exact ⟨first,second,one,two,repeated_interval borrower store (borrowerContext borrower) ids
    rate elapsed pre first second one two⟩

end DefiKernel.Lending.Accrue
