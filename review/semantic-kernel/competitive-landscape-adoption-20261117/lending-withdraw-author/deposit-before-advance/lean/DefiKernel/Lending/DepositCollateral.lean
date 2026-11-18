import DefiKernel.Lending.Support
import Mathlib.Tactic.Ring

/-! Borrower-bound transfer of existing free collateral into that borrower's custody. -/
namespace DefiKernel.Lending.DepositCollateral
open DefiKernel.Typed
def signature : List (Unit Asset) := [.amount Asset.collateral]
def amount : E signature (.amount Asset.collateral) := .arg .here
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := .binary (.le (.amount Asset.collateral)) (.lit 0) amount
  deltas := [⟨.collateral,ref .collateral borrower.party,
      .unary (.neg (.amount Asset.collateral)) amount⟩,
    ⟨.collateral,ref .collateral borrower.custody,amount⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef .collateral borrower.party,packedRef .collateral borrower.custody]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = depositCollateralId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) :
    Request Party Asset Domain :=
  ⟨depositCollateralId,[],[⟨.amount Asset.collateral,quantity⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx (fun _ => none) 0
    (request borrower ids quantity) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,depositCollateralId,.invoke⟩,
  ⟨borrower.party,.lending,depositCollateralId,
    .debit (.lending,borrower.party,.collateral)⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store :=
  ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩]


def evaluated (borrower : Borrower) (quantity : ℚ) : Evaluated Party Asset Domain :=
  ⟨decide (0 ≤ quantity),
    [((.lending,borrower.party,.collateral),-quantity),
      ((.lending,borrower.custody,.collateral),quantity)], [], [], [], [], [],
    [(.lending,borrower.party,.collateral),(.lending,borrower.custody,.collateral)]⟩

theorem template_evaluate (borrower : Borrower) (quantity : ℚ) (pre : Ledger)
    (ctx : InvocationContext Party Domain) :
    (template borrower).evaluate ⟨pre, (fun _ => none), ctx.principal, [],
      Args.cons quantity Args.nil, 0⟩ = .ok (evaluated borrower quantity) := by
  simp [Template.evaluate, Template.requiredStateReads, Template.requiredEnvReads,
    template, amount, signature, ref, packedRef,
    Expr.eval, readBalance, Expr.stateReads, Expr.envReads, resolveRefs, CellRef.resolve,
    PartyRef.resolve, Args.get, BinaryOp.eval, UnaryOp.eval, numericValue, numericRat,
    evaluated, bind, Except.bind, pure, Except.pure]
  rfl
theorem run_ok_iff (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World) :
    run borrower store ctx ids quantity pre = .ok post ↔
      ctx.principal = borrower.party ∧ hasAuthority store ids ctx depositCollateralId .invoke = true ∧
      (evaluated borrower quantity).Valid store ctx (request borrower ids quantity) pre ∧
      post.capabilities = store ∧ ∀ cell,
        post.state.balance cell = pre.balance cell + (evaluated borrower quantity).effect cell := by
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
    have sameEvaluation : e = evaluated borrower quantity :=
      Except.ok.inj (observed.symm.trans (template_evaluate borrower quantity pre ctx))
    subst e
    have bound : ctx.principal = borrower.party := by
      simpa [request, eq_comm] using actor
    exact ⟨bound, invoke, valid, capabilities, balances⟩
  · rintro ⟨bound, invoke, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨template borrower, ?_, ?_, ?_, rfl, Args.cons quantity Args.nil, rfl,
      invoke, evaluated borrower quantity, template_evaluate borrower quantity pre ctx,
      valid, capabilities, balances⟩
    · simp [registry, request]
    · simp [request, bound]
    · cases ctx.domain; rfl


theorem free_effect (borrower : Borrower) (quantity : ℚ) :
    (evaluated borrower quantity).effect (.lending,borrower.party,.collateral) = -quantity := by
  cases borrower <;> simp [Evaluated.effect,evaluated,Borrower.party,Borrower.custody]

theorem locked_effect (borrower : Borrower) (quantity : ℚ) :
    (evaluated borrower quantity).effect (.lending,borrower.custody,.collateral) = quantity := by
  cases borrower <;> simp [Evaluated.effect,evaluated,Borrower.party,Borrower.custody]

theorem effect_outside (borrower : Borrower) (quantity : ℚ) (cell : Cell Party Asset Domain)
    (free : cell ≠ (.lending,borrower.party,.collateral))
    (locked : cell ≠ (.lending,borrower.custody,.collateral)) :
    (evaluated borrower quantity).effect cell = 0 := by
  simp [Evaluated.effect,evaluated,Ne.symm free,Ne.symm locked]

theorem supply_zero (borrower : Borrower) (quantity : ℚ) (domain : Domain) (asset : Asset) :
    (evaluated borrower quantity).supply domain asset = 0 := by
  simp [Evaluated.supply,evaluated]

/-- The actual execution moves existing free collateral into this owner's locked custody. -/
theorem actual_effects (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post) :
    ctx.principal = borrower.party ∧ 0 ≤ quantity ∧
      post.state.balance (.lending,borrower.party,.collateral) =
        pre.balance (.lending,borrower.party,.collateral)-quantity ∧
      post.state.balance (.lending,borrower.custody,.collateral) =
        pre.balance (.lending,borrower.custody,.collateral)+quantity ∧
      post.capabilities = store := by
  obtain ⟨bound,_,valid,capabilities,balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity pre post).mp success
  have nonnegative : 0 ≤ quantity := by simpa [evaluated] using valid.1
  refine ⟨bound,nonnegative,?_,?_,capabilities⟩
  · simpa only [free_effect,sub_eq_add_neg] using balances (.lending,borrower.party,.collateral)
  · simpa only [locked_effect] using balances (.lending,borrower.custody,.collateral)

theorem actual_frame (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post)
    (cell : Cell Party Asset Domain)
    (free : cell ≠ (.lending,borrower.party,.collateral))
    (locked : cell ≠ (.lending,borrower.custody,.collateral)) :
    post.state.balance cell = pre.balance cell := by
  obtain ⟨_,_,_,_,balances⟩ := (run_ok_iff borrower store ctx ids quantity pre post).mp success
  simpa only [effect_outside borrower quantity cell free locked,add_zero] using balances cell

theorem actual_accounting (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post) :
    ∀ asset, total post.state .lending asset = total pre .lending asset := by
  obtain ⟨_,_,valid,capabilities,balances⟩ :=
    (run_ok_iff borrower store ctx ids quantity pre post).mp success
  have applied := (applyEvaluated_ok_iff store ctx (request borrower ids quantity) pre
    (evaluated borrower quantity) post).mpr ⟨valid,capabilities,balances⟩
  intro asset
  simpa only [supply_zero,add_zero] using applyEvaluated_accounting store ctx
    (request borrower ids quantity) pre (evaluated borrower quantity) post applied .lending asset

theorem evaluated_valid (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (nonnegative : 0 ≤ quantity)
    (funded : quantity ≤ pre.balance (.lending,borrower.party,.collateral))
    (debit : hasAuthority store ids ctx depositCollateralId
      (.debit (.lending,borrower.party,.collateral)) = true) :
    (evaluated borrower quantity).Valid store ctx (request borrower ids quantity) pre := by
  have balances : ∀ cell, 0 ≤ pre.balance cell+(evaluated borrower quantity).effect cell := by
    intro cell
    by_cases free : cell = (.lending,borrower.party,.collateral)
    · subst cell; rw [free_effect]; simpa only [sub_eq_add_neg] using sub_nonneg.mpr funded
    · by_cases locked : cell = (.lending,borrower.custody,.collateral)
      · subst cell; rw [locked_effect]; exact add_nonneg (pre.nonneg _) nonnegative
      · rw [effect_outside borrower quantity cell free locked]; simpa using pre.nonneg cell
  refine ⟨?_,rfl,rfl,?_,?_,?_,balances,?_,?_⟩
  · simpa [evaluated] using nonnegative
  · have domain : ctx.domain = .lending := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨?_,?_,?_⟩
    · simp [evaluated]
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    by_cases free : cell = (.lending,borrower.party,.collateral)
    · subst cell; exact debit
    · by_cases locked : cell = (.lending,borrower.custody,.collateral)
      · subst cell; rw [locked_effect] at negative
        exact (not_lt_of_ge nonnegative negative).elim
      · rw [effect_outside borrower quantity cell free locked] at negative
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
    exact effect_outside borrower quantity cell outside.1 outside.2

theorem funded_success (borrower : Borrower) (store : Store) (ids : List CapabilityId)
    (quantity : ℚ) (pre : Ledger) (nonnegative : 0 ≤ quantity)
    (funded : quantity ≤ pre.balance (.lending,borrower.party,.collateral))
    (invoke : hasAuthority store ids (borrowerContext borrower) depositCollateralId .invoke = true)
    (debit : hasAuthority store ids (borrowerContext borrower) depositCollateralId
      (.debit (.lending,borrower.party,.collateral)) = true) :
    ∃ post, run borrower store (borrowerContext borrower) ids quantity pre = .ok post := by
  have valid := evaluated_valid borrower store (borrowerContext borrower) ids quantity pre
    nonnegative funded debit
  have nonneg : ∀ cell, 0 ≤ pre.balance cell+(evaluated borrower quantity).effect cell :=
    valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell => pre.balance cell+(evaluated borrower quantity).effect cell,
    nonneg⟩,store⟩
  exact ⟨post,(run_ok_iff borrower store (borrowerContext borrower) ids quantity pre post).mpr
    ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩⟩

theorem provisioned_exact (borrower : Borrower) :
    provisioned borrower = .ok (fixtureStore borrower) := by
  cases borrower <;> decide

theorem fixture_rights (borrower : Borrower) :
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower)
      depositCollateralId .invoke = true ∧
    hasAuthority (fixtureStore borrower) ids (borrowerContext borrower)
      depositCollateralId (.debit (.lending,borrower.party,.collateral)) = true := by
  cases borrower <;> decide

theorem insufficient_free_ne_success (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (post : World)
    (poor : pre.balance (.lending,borrower.party,.collateral) < quantity) :
    run borrower store ctx ids quantity pre ≠ .ok post := by
  intro success
  have balance := (actual_effects borrower store ctx ids quantity pre post success).2.2.1
  have nonnegative := post.state.nonneg (.lending,borrower.party,.collateral)
  rw [balance] at nonnegative
  exact (not_le_of_gt poor) (sub_nonneg.mp nonnegative)


theorem template_evaluate_caller (borrower : Borrower) (quantity : ℚ) (pre : Ledger) (caller : Party) :
    (template borrower).evaluate ⟨pre, (fun _ => none), caller, [],
      Args.cons quantity Args.nil, 0⟩ = .ok (evaluated borrower quantity) :=
  template_evaluate borrower quantity pre ⟨caller,.lending⟩

theorem run_eq_apply (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger)
    (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx depositCollateralId .invoke = true) :
    run borrower store ctx ids quantity pre =
      applyEvaluated store ctx (request borrower ids quantity) pre (evaluated borrower quantity) := by
  have domain : ctx.domain = .lending := by cases ctx.domain; rfl
  simp [run, Typed.execute, registry, request, bound, domain, signature, Args.check,
    (show (template borrower).partyArity = 0 from rfl),
    (show (template borrower).signature = [.amount Asset.collateral] from rfl),
    template_evaluate_caller, invoke, Except.mapError, bind, Except.bind]
  rw [show Args.check (template borrower).signature [⟨.amount Asset.collateral, quantity⟩] =
    .ok (Args.cons quantity Args.nil) from rfl]
  simp [template_evaluate_caller, Except.mapError, bind, Except.bind]


theorem negative_quantity_refusal (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity : ℚ)
    (pre : Ledger) (bound : ctx.principal = borrower.party)
    (invoke : hasAuthority store ids ctx depositCollateralId .invoke = true)
    (negative : quantity < 0) :
    run borrower store ctx ids quantity pre = .error Typed.Refusal.guard := by
  rw [run_eq_apply borrower store ctx ids quantity pre bound invoke]
  have guard : (evaluated borrower quantity).guard = false := by
    simp [evaluated,not_le.mpr negative]
  simp [applyEvaluated,guard]

/-- At any nonnegative illustrative price, a funded deposit cannot worsen the health inequality. -/
theorem health_preserved_at_price (borrower : Borrower) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (quantity price : ℚ)
    (pre : Ledger) (post : World)
    (success : run borrower store ctx ids quantity pre = .ok post)
    (priceNonnegative : 0 ≤ price)
    (healthy : 2*pre.balance (.lending,borrower.party,.debt) ≤
      pre.balance (.lending,borrower.custody,.collateral)*price) :
    2*post.state.balance (.lending,borrower.party,.debt) ≤
      post.state.balance (.lending,borrower.custody,.collateral)*price := by
  have effects := actual_effects borrower store ctx ids quantity pre post success
  have debt := actual_frame borrower store ctx ids quantity pre post success
    (.lending,borrower.party,.debt) (by simp) (by simp)
  rw [debt,effects.2.2.2.1]
  exact healthy.trans (mul_le_mul_of_nonneg_right (le_add_of_nonneg_right effects.2.1)
    priceNonnegative)

end DefiKernel.Lending.DepositCollateral
