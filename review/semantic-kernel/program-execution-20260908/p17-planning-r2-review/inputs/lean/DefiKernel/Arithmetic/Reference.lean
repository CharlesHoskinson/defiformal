import DefiKernel.Arithmetic.Fees
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Typed.Transition
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

/-! Registered constant fee-quote transfers. This adapter uses the existing typed executor's
aggregate net effects, including coincident parties; it does not model sequential debit order. -/
namespace DefiKernel.Arithmetic.Reference
open Typed

variable {P A D : Type} {w : Nat}

def payerDelta (quote : Fees.FeeQuote w) (scale : ℚ) (payer : Cell P A D) :
    CellDelta P A D [] :=
  ⟨payer.2.2, ⟨payer.1, .literal payer.2.1⟩, .lit (-(quote.charged.value : ℚ) * scale)⟩

def recipientDelta (quote : Fees.FeeQuote w) (scale : ℚ) (recipient : Cell P A D) :
    CellDelta P A D [] :=
  ⟨recipient.2.2, ⟨recipient.1, .literal recipient.2.1⟩,
    .lit ((quote.received.value : ℚ) * scale)⟩

def collectorDelta (quote : Fees.FeeQuote w) (scale : ℚ) (collector : Cell P A D) :
    CellDelta P A D [] :=
  ⟨collector.2.2, ⟨collector.1, .literal collector.2.1⟩, .lit ((quote.fee.value : ℚ) * scale)⟩

def template (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) : Template P A D :=
  let payer := (domain, payer, asset)
  let recipient := (domain, recipient, asset)
  let collector := (domain, collector, asset)
  { signature := [], domain := domain, partyArity := 0, guard := .lit true
    deltas := [payerDelta quote scale payer, recipientDelta quote scale recipient,
    collectorDelta quote scale collector]
    supplyDeltas := [], stateReads := [], envReads := []
    writes := [⟨asset, ⟨domain, .literal payer.2.1⟩⟩,
      ⟨asset, ⟨domain, .literal recipient.2.1⟩⟩, ⟨asset, ⟨domain, .literal collector.2.1⟩⟩] }

def registry (operation : OperationId) (quote : Fees.FeeQuote w) (scale : ℚ)
    (domain : D) (asset : A) (payer recipient collector : P) : Registry P A D :=
  fun selected ↦ if selected = operation then
    some (template quote scale domain asset payer recipient collector) else none

def request (operation : OperationId) (capabilityIds : List CapabilityId) : Request P A D :=
  ⟨operation, [], [], capabilityIds, none⟩

/-- Explicit evaluated data used in the correspondence statement, not a caller input to execute. -/
def evaluated (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) : Evaluated P A D :=
  ⟨true, [((domain, payer, asset), -(quote.charged.value : ℚ) * scale),
    ((domain, recipient, asset), (quote.received.value : ℚ) * scale),
    ((domain, collector, asset), (quote.fee.value : ℚ) * scale)], [], [], [], [], [],
    [(domain, payer, asset), (domain, recipient, asset), (domain, collector, asset)]⟩

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- The three scalar contributions are added even when their target cells coincide. -/
def netEffect (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (cell : Cell P A D) : ℚ :=
  (if (domain, payer, asset) = cell then -(quote.charged.value : ℚ) * scale else 0) +
    (if (domain, recipient, asset) = cell then (quote.received.value : ℚ) * scale else 0) +
    (if (domain, collector, asset) = cell then (quote.fee.value : ℚ) * scale else 0)

variable [Fintype P] [Fintype A] [Fintype D]

/-- Refusal has no post-world: retain the supplied input separately from the actual result. -/
def observeExecution (operations : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (req : Request P A D) (state : State P A D) :
    (State P A D × CapabilityStore P A D) × Except Refusal (ExecutionResult P A D) :=
  ((state, store), Typed.execute operations store ctx env now req state)

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem template_evaluate (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P)
    (ctx : EvalContext P A D
      (template quote scale domain asset payer recipient collector).signature) :
    (template quote scale domain asset payer recipient collector).evaluate ctx =
      .ok (evaluated quote scale domain asset payer recipient collector) := by
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem evaluated_effect (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (cell : Cell P A D) :
    (evaluated quote scale domain asset payer recipient collector).effect cell =
      netEffect quote scale domain asset payer recipient collector cell := by
  simp [Evaluated.effect, evaluated, netEffect, add_assoc]

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
@[simp] theorem evaluated_supply (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (d : D) (a : A) :
    (evaluated quote scale domain asset payer recipient collector).supply d a = 0 := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem netEffect_outside (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (cell : Cell P A D)
    (hp : cell ≠ (domain, payer, asset)) (hr : cell ≠ (domain, recipient, asset))
    (hc : cell ≠ (domain, collector, asset)) :
    netEffect quote scale domain asset payer recipient collector cell = 0 := by
  simp [netEffect, Ne.symm hp, Ne.symm hr, Ne.symm hc]

theorem evaluated_writesOK (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) :
    (evaluated quote scale domain asset payer recipient collector).writesOK = true := by
  simp only [Evaluated.writesOK, decide_eq_true_eq]
  intro cell outside
  simp only [evaluated, List.mem_cons, List.not_mem_nil, or_false, not_or] at outside
  rw [evaluated_effect]
  exact netEffect_outside _ _ _ _ _ _ _ _ outside.1 outside.2.1 outside.2.2

theorem evaluated_domainOK (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) :
    (evaluated quote scale domain asset payer recipient collector).domainOK domain = true := by
  simp only [Evaluated.domainOK, decide_eq_true_eq]
  refine ⟨by simp [evaluated], ?_, by simp⟩
  intro cell nonzero
  by_contra wrong
  apply nonzero
  rw [evaluated_effect]
  apply netEffect_outside <;> intro h <;> exact wrong (congrArg Prod.fst h)

theorem evaluated_accountingOK (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P)
    (conservation : quote.charged.value = quote.received.value + quote.fee.value) :
    (evaluated quote scale domain asset payer recipient collector).accountingOK = true := by
  simp only [Evaluated.accountingOK, decide_eq_true_eq]
  intro d a
  simp only [evaluated_effect, evaluated_supply, netEffect, Finset.sum_add_distrib]
  by_cases hd : domain = d <;> by_cases ha : asset = a
  · subst d; subst a
    simp only [Prod.mk.injEq, true_and, and_true]
    simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]
    have hc : (quote.charged.value : ℚ) =
        (quote.received.value : ℚ) + (quote.fee.value : ℚ) := by exact_mod_cast conservation
    rw [hc]
    ring
  · simp [Prod.mk.injEq, hd, ha]
  · simp [Prod.mk.injEq, hd]
  · simp [Prod.mk.injEq, hd]

theorem quote_conservation (quote : Fees.FeeQuote w)
    (source : (∃ mode amount num den, Fees.feeFromGross mode amount num den = .ok quote) ∨
      ∃ mode amount num den, Fees.feeOnTop mode amount num den = .ok quote) :
    quote.charged.value = quote.received.value + quote.fee.value := by
  rcases source with ⟨mode, amount, num, den, h⟩ | ⟨mode, amount, num, den, h⟩
  · exact Fees.feeFromGross_conservation _ _ _ _ _ h
  · exact Fees.feeOnTop_conservation _ _ _ _ _ h

theorem evaluated_valid (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (req : Request P A D) (state : State P A D)
    (conservation : quote.charged.value = quote.received.value + quote.fee.value)
    (domainBinding : ctx.domain = domain)
    (debits : ∀ c, netEffect quote scale domain asset payer recipient collector c < 0 →
      hasAuthority store req.capabilityIds ctx req.operation (.debit c) = true)
    (funds : ∀ c, 0 ≤ state.balance c +
      netEffect quote scale domain asset payer recipient collector c) :
    (evaluated quote scale domain asset payer recipient collector).Valid store ctx req state := by
  refine ⟨rfl, rfl, rfl, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [domainBinding]
    exact evaluated_domainOK _ _ _ _ _ _ _
  · simpa only [Evaluated.debitsOK, decide_eq_true_eq, evaluated_effect] using debits
  · simp [Evaluated.suppliesOK]
  · simpa only [evaluated_effect] using funds
  · exact evaluated_accountingOK _ _ _ _ _ _ _ conservation
  · exact evaluated_writesOK _ _ _ _ _ _ _

/-- Derives the selected template's argument/evaluation path before the actual effect checks. -/
theorem execute_eq_apply (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (operations : Registry P A D)
    (store : CapabilityStore P A D) (ctx : InvocationContext P D)
    (env : Environment A D) (now : Nat) (req : Request P A D) (state : State P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true) :
    Typed.execute operations store ctx env now req state =
      applyEvaluated store ctx req state
        (evaluated quote scale domain asset payer recipient collector) := by
  have ht : (template quote scale domain asset payer recipient collector).domain = domain := rfl
  have hp : (template quote scale domain asset payer recipient collector).partyArity = 0 := rfl
  have ha : Args.check (template quote scale domain asset payer recipient collector).signature
      req.arguments = .ok .nil := by simp [template, arguments, Args.check]
  rcases actor with actor | actor <;>
    simp [Typed.execute, registered, actor, ht, hp, domainBinding, arity, ha, invoke,
      template_evaluate, bind, Except.bind, Except.mapError]

/-- Successful fee provenance supplies conservation; only the declared runtime boundary,
net authority and net resulting-balance conditions are external. -/
theorem execute_quote (quote : Fees.FeeQuote w) (scale : ℚ) (_positiveScale : 0 < scale)
    (domain : D) (asset : A) (payer recipient collector : P)
    (source : (∃ mode amount num den, Fees.feeFromGross mode amount num den = .ok quote) ∨
      ∃ mode amount num den, Fees.feeOnTop mode amount num den = .ok quote)
    (operations : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (req : Request P A D) (state : State P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true)
    (debits : ∀ c, netEffect quote scale domain asset payer recipient collector c < 0 →
      hasAuthority store req.capabilityIds ctx req.operation (.debit c) = true)
    (funds : ∀ c, 0 ≤ state.balance c +
      netEffect quote scale domain asset payer recipient collector c) :
    Typed.execute operations store ctx env now req state =
      .ok ⟨⟨fun c ↦ state.balance c +
        netEffect quote scale domain asset payer recipient collector c, funds⟩, store⟩ := by
  rw [execute_eq_apply quote scale domain asset payer recipient collector operations store ctx
    env now req state registered actor domainBinding arity arguments invoke]
  apply (applyEvaluated_ok_iff _ _ _ _ _ _).mpr
  exact ⟨evaluated_valid quote scale domain asset payer recipient collector store ctx req state
    (quote_conservation quote source) domainBinding debits funds, rfl,
    fun c ↦ by simp only [evaluated_effect]⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem netEffect_scalar_formula (quote : Fees.FeeQuote w) (scale : ℚ)
    (domain : D) (asset : A) (payer recipient collector : P) (cell : Cell P A D) (entry : ℚ) :
    entry + netEffect quote scale domain asset payer recipient collector cell =
      entry - (if (domain, payer, asset) = cell then (quote.charged.value : ℚ) * scale else 0) +
        (if (domain, recipient, asset) = cell then (quote.received.value : ℚ) * scale else 0) +
        (if (domain, collector, asset) = cell then (quote.fee.value : ℚ) * scale else 0) := by
  unfold netEffect
  split_ifs <;> ring

theorem execute_quote_balance (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (operations : Registry P A D)
    (store : CapabilityStore P A D) (ctx : InvocationContext P D)
    (env : Environment A D) (now : Nat) (req : Request P A D) (state : State P A D)
    (post : ExecutionResult P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true)
    (success : Typed.execute operations store ctx env now req state = .ok post)
    (cell : Cell P A D) :
    post.capabilities = store ∧ post.state.balance cell =
      state.balance cell -
        (if (domain, payer, asset) = cell then (quote.charged.value : ℚ) * scale else 0) +
        (if (domain, recipient, asset) = cell then (quote.received.value : ℚ) * scale else 0) +
        (if (domain, collector, asset) = cell then (quote.fee.value : ℚ) * scale else 0) := by
  rw [execute_eq_apply quote scale domain asset payer recipient collector operations store ctx
    env now req state registered actor domainBinding arity arguments invoke] at success
  obtain ⟨_, storeEq, balances⟩ := (applyEvaluated_ok_iff _ _ _ _ _ _).mp success
  refine ⟨storeEq, ?_⟩
  rw [balances, evaluated_effect]
  exact netEffect_scalar_formula _ _ _ _ _ _ _ _ _

/-- The denied permission is for a negative aggregate effect, including coincident targets.
No post-state is produced; all preceding executor checks are derived or explicitly bound. -/
theorem execute_unauthorizedDebit (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (operations : Registry P A D)
    (store : CapabilityStore P A D) (ctx : InvocationContext P D)
    (env : Environment A D) (now : Nat) (req : Request P A D) (state : State P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true)
    (bad : ∃ c, netEffect quote scale domain asset payer recipient collector c < 0 ∧
      hasAuthority store req.capabilityIds ctx req.operation (.debit c) ≠ true) :
    Typed.execute operations store ctx env now req state = .error .unauthorizedDebit := by
  rw [execute_eq_apply quote scale domain asset payer recipient collector operations store ctx
    env now req state registered actor domainBinding arity arguments invoke]
  let e := evaluated quote scale domain asset payer recipient collector
  have hg : e.guard = true := rfl
  have hs : e.stateReadsOK = true := rfl
  have he : e.envReadsOK = true := rfl
  have hd : e.domainOK ctx.domain = true := by
    rw [domainBinding]
    exact evaluated_domainOK _ _ _ _ _ _ _
  have hb : e.debitsOK store req ctx = false := by
    apply Bool.eq_false_iff.mpr
    intro good
    have all := of_decide_eq_true good
    obtain ⟨c, negative, denied⟩ := bad
    exact denied (all c (by simpa only [e, evaluated_effect] using negative))
  change applyEvaluated store ctx req state e = _
  simp only [applyEvaluated, hg, hs, he, hd, hb, Bool.not_true, Bool.false_eq_true,
    if_false, Bool.not_false, if_true]

/-- Insufficient funds follows successful net-debit authorization and zero supply checks. -/
theorem execute_insufficientFunds (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (operations : Registry P A D)
    (store : CapabilityStore P A D) (ctx : InvocationContext P D)
    (env : Environment A D) (now : Nat) (req : Request P A D) (state : State P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true)
    (debits : ∀ c, netEffect quote scale domain asset payer recipient collector c < 0 →
      hasAuthority store req.capabilityIds ctx req.operation (.debit c) = true)
    (bad : ∃ c, state.balance c +
      netEffect quote scale domain asset payer recipient collector c < 0) :
    Typed.execute operations store ctx env now req state = .error .insufficientFunds := by
  rw [execute_eq_apply quote scale domain asset payer recipient collector operations store ctx
    env now req state registered actor domainBinding arity arguments invoke]
  let e := evaluated quote scale domain asset payer recipient collector
  have hg : e.guard = true := rfl
  have hs : e.stateReadsOK = true := rfl
  have he : e.envReadsOK = true := rfl
  have hd : e.domainOK ctx.domain = true := by
    rw [domainBinding]
    exact evaluated_domainOK _ _ _ _ _ _ _
  have hb : e.debitsOK store req ctx = true := by
    simpa only [Evaluated.debitsOK, decide_eq_true_eq, e, evaluated_effect] using debits
  have hu : e.suppliesOK store req ctx = true := by simp [e, Evaluated.suppliesOK]
  have hn : ¬ ∀ c, 0 ≤ state.balance c + e.effect c := by
    intro good
    obtain ⟨c, negative⟩ := bad
    exact (not_lt_of_ge (good c)) (by simpa only [e, evaluated_effect] using negative)
  change applyEvaluated store ctx req state e = _
  simp only [applyEvaluated, hg, hs, he, hd, hb, hu, Bool.not_true, Bool.false_eq_true,
    if_false, hn, dite_false]

/-- The observation retains exactly the supplied input; an error has no fabricated post-world. -/
theorem observeExecution_input (operations : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (req : Request P A D) (state : State P A D) :
    (observeExecution operations store ctx env now req state).1 = (state, store) := rfl

theorem observeExecution_result (operations : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (req : Request P A D) (state : State P A D) :
    (observeExecution operations store ctx env now req state).2 =
      Typed.execute operations store ctx env now req state := rfl

/-- Successful arithmetic provenance supplies zero aggregate issuance in each domain/asset. -/
theorem quote_accounting (quote : Fees.FeeQuote w) (scale : ℚ) (_positiveScale : 0 < scale)
    (domain : D) (asset : A) (payer recipient collector : P)
    (source : (∃ mode amount num den, Fees.feeFromGross mode amount num den = .ok quote) ∨
      ∃ mode amount num den, Fees.feeOnTop mode amount num den = .ok quote) (d : D) (a : A) :
    ∑ p, netEffect quote scale domain asset payer recipient collector (d, p, a) = 0 := by
  have accounting := evaluated_accountingOK quote scale domain asset payer recipient collector
    (quote_conservation quote source)
  have all := of_decide_eq_true accounting
  simpa only [evaluated_effect, evaluated_supply] using all d a

/-- Actual successful execution frames every cell outside the three targets and the whole store. -/
theorem execute_quote_locality (quote : Fees.FeeQuote w) (scale : ℚ)
    (domain : D) (asset : A) (payer recipient collector : P) (operations : Registry P A D)
    (store : CapabilityStore P A D) (ctx : InvocationContext P D)
    (env : Environment A D) (now : Nat) (req : Request P A D) (state : State P A D)
    (post : ExecutionResult P A D)
    (registered : operations req.operation =
      some (template quote scale domain asset payer recipient collector))
    (actor : req.claimedActor = none ∨ req.claimedActor = some ctx.principal)
    (domainBinding : ctx.domain = domain) (arity : req.parties.length = 0)
    (arguments : req.arguments = [])
    (invoke : hasAuthority store req.capabilityIds ctx req.operation .invoke = true)
    (success : Typed.execute operations store ctx env now req state = .ok post)
    (cell : Cell P A D) (hp : cell ≠ (domain, payer, asset))
    (hr : cell ≠ (domain, recipient, asset)) (hc : cell ≠ (domain, collector, asset)) :
    post.capabilities = store ∧ post.state.balance cell = state.balance cell := by
  obtain ⟨storeEq, balance⟩ := execute_quote_balance quote scale domain asset payer recipient
    collector operations store ctx env now req state post registered actor domainBinding
    arity arguments invoke success cell
  exact ⟨storeEq, by simpa [Ne.symm hp, Ne.symm hr, Ne.symm hc] using balance⟩

end DefiKernel.Arithmetic.Reference
