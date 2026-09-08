import DefiKernel.Nary.Examples
import DefiKernel.Typed.Transition

/-! Reusable F10 enabledness: actual `executeStep = .ok` under current store, history and
funding hypotheses. Success is constructed from catalog/access/typed guard/nonnegative
effects/extract, not assumed, not derived from StepSound, and not a whole-run fact.
Extra current hypotheses are only those FundedK already maintains (`budgetC = 6`). -/
namespace DefiKernel.Nary.FundedEnabledness
open Typed Composition
open DefiKernel.Nary
open DefiKernel.Nary.Examples

def producerIface : OperationInterface P A D := ⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩
def consumerIface : OperationInterface P A D := ⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩
def deposit1Iface : OperationInterface P A D := ⟨⟨202⟩, [], []⟩
def deposit2Iface : OperationInterface P A D := ⟨⟨203⟩, [], []⟩

def producerRequest : Request P A D := ⟨⟨200⟩, [], [], ids [0], none⟩
def consumerRequest : Request P A D :=
  ⟨⟨201⟩, [], [⟨.amount .usd, (6 : ℚ)⟩], ids [1, 2], none⟩
def deposit1Request : Request P A D := ⟨⟨202⟩, [], [], ids [3, 4], none⟩
def deposit2Request : Request P A D := ⟨⟨203⟩, [], [], ids [5, 6], none⟩

def producerEval : Evaluated P A D := evaluated true [] [] []
def consumerEval : Evaluated P A D :=
  evaluated true [(vaultC, -6), (recipientC, 6)] [vaultC] [vaultC, recipientC]
def deposit1Eval : Evaluated P A D :=
  evaluated true [(donor1C, -1), (vaultC, 1)] [donor1C] [donor1C, vaultC]
def deposit2Eval : Evaluated P A D :=
  evaluated true [(donor2C, -2), (vaultC, 2)] [donor2C] [donor2C, vaultC]

def applyWorld (state : State P A D) (store : Store) (e : Evaluated P A D)
    (hn : ∀ c, 0 ≤ state.balance c + e.effect c) : W :=
  ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem f10_catalog_valid : validateCatalog f10Cfg.registry f10Cfg.catalog = true := by
  decide

theorem f10_bounds_producer (n : Nat) : f10Bounds (0 : Fin 3) n = vaultBound := rfl
theorem f10_bounds_deposit1 (n : Nat) : f10Bounds (1 : Fin 3) n = donor1Bound := rfl
theorem f10_bounds_deposit2 (n : Nat) : f10Bounds (2 : Fin 3) n = donor2Bound := rfl

theorem prepare_producer :
    prepareInvocation f10Cfg vaultBound 0 [] inv200 =
      .ok (producerIface, producerRequest) := by
  decide +kernel

theorem prepare_consumer :
    prepareInvocation f10Cfg vaultBound 1 [budgetOut 0] inv201 =
      .ok (consumerIface, consumerRequest) := by
  decide +kernel

theorem prepare_deposit1 :
    prepareInvocation f10Cfg donor1Bound 0 [] inv202 =
      .ok (deposit1Iface, deposit1Request) := by
  decide +kernel

theorem prepare_deposit2 :
    prepareInvocation f10Cfg donor2Bound 0 [] inv203 =
      .ok (deposit2Iface, deposit2Request) := by
  decide +kernel

theorem executeStep_invoke_ok {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre post : W} {iface : OperationInterface P A D} {request : Request P A D}
    {e : Evaluated P A D}
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
        request pre.state = .ok post)
    (he : extractReceipt cfg boundary request pre = .ok e) :
    executeStep cfg boundary index history (.invoke inv) pre =
      .ok ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩ := by
  simp [executeStep, hv, hp, hx, he, bind, Except.bind, Except.mapError, pure, Except.pure]

theorem producer_effect (c : C) : producerEval.effect c = 0 := by
  simp [producerEval, evaluated, Evaluated.effect]

theorem producer_extract (pre : W) :
    extractReceipt f10Cfg vaultBound producerRequest pre = .ok producerEval := by
  rfl

theorem producer_invoke_auth :
    hasAuthority f10Store (ids [0]) vaultBound.ctx ⟨200⟩ Right.invoke = true := by
  decide +kernel

theorem producer_valid (state : State P A D) :
    producerEval.Valid f10Store vaultBound.ctx producerRequest state := by
  simp [Evaluated.Valid, Evaluated.stateReadsOK, Evaluated.envReadsOK, Evaluated.domainOK,
    Evaluated.debitsOK, Evaluated.suppliesOK, Evaluated.accountingOK, Evaluated.writesOK,
    producerEval, evaluated, Evaluated.effect, Evaluated.supply]
  intro d p a
  exact state.nonneg (d, p, a)

theorem producer_execute (state : State P A D)
    (hn : ∀ c, 0 ≤ state.balance c + producerEval.effect c) :
    execute f10Cfg.registry f10Store vaultBound.ctx vaultBound.env vaultBound.now
        producerRequest state = .ok (applyWorld state f10Store producerEval hn) := by
  refine (execute_ok_iff f10Cfg.registry f10Store vaultBound.ctx vaultBound.env
      vaultBound.now producerRequest state (applyWorld state f10Store producerEval hn)).mpr ?_
  refine ⟨producerSnapshot, rfl, Or.inl rfl, rfl, rfl, .nil, rfl, producer_invoke_auth,
    producerEval, rfl, producer_valid state, rfl, ?_⟩
  intro c
  rfl

theorem budget_asset : budgetC.2.2 = Asset.usd := rfl

theorem producer_snapshots (state : State P A D) (h : state.balance budgetC = 6) :
    snapshots 0 ⟨0⟩ producerIface state = [budgetOut 0] := by
  simp [snapshots, producerIface, budgetOut, name, budget_asset, h]

theorem f10_producer_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hbudget : pre.state.balance budgetC = 6) :
    ∃ result, executeStep f10Cfg (f10Bounds (0 : Fin 3) 0) 0 [] (.invoke inv200) pre =
        .ok result ∧
      result.receipt = rec200 ∧
      result.outputs = [budgetOut 0] ∧
      result.world.capabilities = f10Store ∧
      ∀ c, result.world.state.balance c = pre.state.balance c := by
  rcases pre with ⟨state, caps⟩
  subst hstore
  have hbudget' : state.balance budgetC = 6 := hbudget
  have hn : ∀ c, 0 ≤ state.balance c + producerEval.effect c := by
    intro c
    simp [producer_effect]
    exact state.nonneg c
  let post := applyWorld state f10Store producerEval hn
  have hx : execute f10Cfg.registry f10Store vaultBound.ctx vaultBound.env vaultBound.now
      producerRequest state = .ok post := producer_execute state hn
  have hstep := executeStep_invoke_ok (cfg := f10Cfg) (boundary := vaultBound)
      (index := 0) (history := []) (inv := inv200) (pre := ⟨state, f10Store⟩)
      (post := post) (iface := producerIface) (request := producerRequest)
      (e := producerEval) f10_catalog_valid prepare_producer hx (producer_extract _)
  refine ⟨⟨post, .invoked producerRequest producerEval,
      snapshots 0 inv200.component producerIface post.state⟩, ?_⟩
  refine ⟨?_, rfl, ?_, rfl, ?_⟩
  · simpa [f10_bounds_producer] using hstep
  · have hbal : post.state.balance budgetC = 6 := by
      simp [post, applyWorld, producer_effect, hbudget']
    exact producer_snapshots post.state hbal
  · intro c
    simp [post, applyWorld, producer_effect]

theorem consumer_args :
    Args.check (consumerTransfer .recipient).signature consumerRequest.arguments =
      .ok (.cons (6 : ℚ) .nil) := rfl

theorem consumer_invoke_auth :
    hasAuthority f10Store (ids [1, 2]) vaultBound.ctx ⟨201⟩ Right.invoke = true := by
  decide +kernel

theorem consumer_debit_auth :
    hasAuthority f10Store (ids [1, 2]) vaultBound.ctx ⟨201⟩ (.debit vaultC) = true := by
  decide +kernel

/-- `BinaryOp.le` decides `numericRat` amounts, not a raw `ℚ` inequality. The Prop
`q ≤ v` is definitionally the `numericRat` comparison; `decide_eq_true` then uses
the same `Decidable` instance as `BinaryOp.eval`. -/
theorem amount_le_decide {q v : ℚ} (h : q ≤ v) :
    decide (numericRat (.amount Asset.usd) q ≤ numericRat (.amount Asset.usd) v) = true := by
  apply decide_eq_true
  simpa [numericRat] using h

theorem amount_zero_le_six :
    decide (numericRat (.amount Asset.usd) (0 : ℚ) ≤ numericRat (.amount Asset.usd) (6 : ℚ)) =
      true := by
  decide

def consumerCtx (state : State P A D) :
    EvalContext P A D (consumerTransfer .recipient).signature :=
  ⟨state, vaultBound.env, vaultBound.ctx.principal, [], .cons (6 : ℚ) .nil, vaultBound.now⟩

theorem consumer_guard (state : State P A D) (h : 6 ≤ state.balance vaultC) :
    (consumerTransfer .recipient).guard.eval (consumerCtx state) = .ok true := by
  simp [consumerCtx, consumerTransfer, andBool, nonnegative, usdArg, Expr.eval,
    BinaryOp.eval, Args.get, readBalance, CellRef.resolve, PartyRef.resolve, cellRef,
    bind, Except.bind, pure, Except.pure]
  have hcell : (Domain.home, Party.vault, Asset.usd) = vaultC := rfl
  simpa [numericRat, hcell] using And.intro (by decide : (0 : ℚ) ≤ 6) h

theorem vaultC_tuple : (Domain.home, Party.vault, Asset.usd) = vaultC := rfl
theorem recipientC_tuple : (Domain.home, Party.recipient, Asset.usd) = recipientC := rfl
theorem donor1C_tuple : (Domain.home, Party.donor1, Asset.usd) = donor1C := rfl
theorem donor2C_tuple : (Domain.home, Party.donor2, Asset.usd) = donor2C := rfl

theorem consumer_caller (state : State P A D) :
    (consumerCtx state).caller = vaultBound.ctx.principal := rfl
theorem consumer_parties_ctx (state : State P A D) :
    (consumerCtx state).parties = [] := rfl

theorem consumer_resolve_required (state : State P A D) :
    resolveRefs (consumerCtx state).caller (consumerCtx state).parties
      (consumerTransfer .recipient).requiredStateReads = .ok [vaultC] := by
  rw [consumer_caller state, consumer_parties_ctx state]
  simp [resolveRefs, Template.requiredStateReads, consumerTransfer, packed, cellRef,
    Expr.stateReads, nonnegative, andBool, usdArg, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    List.flatMap, vaultC]

theorem consumer_resolve_declared (state : State P A D) :
    resolveRefs (consumerCtx state).caller (consumerCtx state).parties
      (consumerTransfer .recipient).stateReads = .ok [vaultC] := by
  rw [consumer_caller state, consumer_parties_ctx state]
  simp [resolveRefs, consumerTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure, vaultC]

theorem consumer_resolve_writes (state : State P A D) :
    resolveRefs (consumerCtx state).caller (consumerCtx state).parties
      (consumerTransfer .recipient).writes = .ok [vaultC, recipientC] := by
  rw [consumer_caller state, consumer_parties_ctx state]
  simp [resolveRefs, consumerTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    vaultC, recipientC]

theorem consumer_delta_eval (state : State P A D) :
    List.mapM
      (fun d ↦
        match CellRef.resolve (consumerCtx state).caller (consumerCtx state).parties d.target with
        | Except.error err => Except.error err
        | Except.ok v =>
          match Expr.eval (consumerCtx state) d.amount with
          | Except.error err => Except.error err
          | Except.ok v1 => Except.ok (v, v1))
      (consumerTransfer .recipient).deltas =
      .ok [(vaultC, -6), (recipientC, 6)] := by
  simp [consumerCtx, consumerTransfer, List.mapM, List.mapM.loop, CellRef.resolve,
    PartyRef.resolve, cellRef, Expr.eval, UnaryOp.eval, usdArg, Args.get, bind,
    Except.bind, pure, Except.pure, numericValue, numericRat, vaultC, recipientC]

theorem consumer_evaluate (state : State P A D) (h : 6 ≤ state.balance vaultC) :
    (consumerTransfer .recipient).evaluate (consumerCtx state) = .ok consumerEval := by
  unfold Template.evaluate
  rw [consumer_resolve_required state, consumer_resolve_declared state,
    consumer_resolve_writes state]
  simp only [bind, Except.bind, pure, Except.pure]
  rw [consumer_guard state h]
  simp [consumerCtx, consumerTransfer, List.mapM, List.mapM.loop, CellRef.resolve,
    PartyRef.resolve, cellRef, Expr.eval, UnaryOp.eval, usdArg, Args.get, bind,
    Except.bind, pure, Except.pure, numericValue, numericRat, vaultC, recipientC,
    consumerEval, evaluated, Template.requiredEnvReads, Expr.envReads,
    andBool, nonnegative]

theorem consumer_extract (pre : W) (h : 6 ≤ pre.state.balance vaultC) :
    extractReceipt f10Cfg vaultBound consumerRequest pre = .ok consumerEval := by
  unfold extractReceipt
  simp only [bind, Except.bind, Except.mapError]
  rw [show f10Cfg.registry consumerRequest.operation = some (consumerTransfer .recipient) from rfl]
  simp only [bind, Except.bind, Except.mapError]
  rw [consumer_args]
  simp only [Except.mapError, bind, Except.bind]
  change ((consumerTransfer .recipient).evaluate (consumerCtx pre.state)).mapError
      (fun _ ↦ Failure.internalReceipt) = .ok consumerEval
  rw [consumer_evaluate pre.state h]
  rfl

theorem vaultC_ne_recipientC : vaultC ≠ recipientC := by decide

theorem consumer_effect (c : C) :
    consumerEval.effect c =
      if c = vaultC then (-6 : ℚ) else if c = recipientC then 6 else 0 := by
  simp [consumerEval, evaluated, Evaluated.effect]
  by_cases hv : c = vaultC <;> by_cases hr : c = recipientC
  · exact (vaultC_ne_recipientC (hv.symm.trans hr)).elim
  · subst c; simp [eq_comm, vaultC_ne_recipientC.symm]
  · subst c; simp [eq_comm, hv]
  · simp [eq_comm, hv, hr]

theorem consumer_stateReadsOK : consumerEval.stateReadsOK = true := by decide
theorem consumer_envReadsOK : consumerEval.envReadsOK = true := by decide
theorem consumer_domainOK : consumerEval.domainOK Domain.home = true := by decide +kernel
theorem consumer_debitsOK :
    consumerEval.debitsOK f10Store consumerRequest vaultBound.ctx = true := by
  decide +kernel
theorem consumer_suppliesOK :
    consumerEval.suppliesOK f10Store consumerRequest vaultBound.ctx = true := by
  decide +kernel
theorem consumer_accountingOK : consumerEval.accountingOK = true := by decide +kernel
theorem consumer_writesOK : consumerEval.writesOK = true := by decide +kernel

theorem consumer_nonneg (state : State P A D) (h : 6 ≤ state.balance vaultC) :
    ∀ c, 0 ≤ state.balance c + consumerEval.effect c := by
  intro c
  rw [consumer_effect]
  split_ifs with hv hr
  · subst hv
    simpa using sub_nonneg.mpr h
  · subst hr
    exact add_nonneg (state.nonneg recipientC) (by decide : (0 : ℚ) ≤ 6)
  · simpa using state.nonneg c

theorem consumer_valid (state : State P A D) (h : 6 ≤ state.balance vaultC) :
    consumerEval.Valid f10Store vaultBound.ctx consumerRequest state :=
  ⟨rfl, consumer_stateReadsOK, consumer_envReadsOK, consumer_domainOK,
    consumer_debitsOK, consumer_suppliesOK, consumer_nonneg state h,
    consumer_accountingOK, consumer_writesOK⟩

theorem consumer_execute (state : State P A D) (h : 6 ≤ state.balance vaultC)
    (hn : ∀ c, 0 ≤ state.balance c + consumerEval.effect c) :
    execute f10Cfg.registry f10Store vaultBound.ctx vaultBound.env vaultBound.now
        consumerRequest state = .ok (applyWorld state f10Store consumerEval hn) := by
  refine (execute_ok_iff f10Cfg.registry f10Store vaultBound.ctx vaultBound.env
      vaultBound.now consumerRequest state (applyWorld state f10Store consumerEval hn)).mpr ?_
  refine ⟨consumerTransfer .recipient, rfl, Or.inl rfl, rfl, rfl, ?_⟩
  refine ⟨.cons (6 : ℚ) .nil, consumer_args, consumer_invoke_auth, ?_⟩
  refine ⟨consumerEval, consumer_evaluate state h, consumer_valid state h, rfl, ?_⟩
  intro c
  rfl

theorem consumer_snapshots (state : State P A D) :
    snapshots 1 inv201.component consumerIface state = [] := rfl

theorem f10_consumer_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hvault : 6 ≤ pre.state.balance vaultC) :
    ∃ result, executeStep f10Cfg (f10Bounds (0 : Fin 3) 1) 1 [budgetOut 0]
        (.invoke inv201) pre = .ok result ∧
      result.receipt = rec201 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + (-6) ∧
      result.world.state.balance recipientC = pre.state.balance recipientC + 6 ∧
      ∀ c, c ≠ vaultC → c ≠ recipientC →
        result.world.state.balance c = pre.state.balance c := by
  rcases pre with ⟨state, caps⟩
  subst hstore
  have hvault' : 6 ≤ state.balance vaultC := hvault
  have hn := consumer_nonneg state hvault'
  let post := applyWorld state f10Store consumerEval hn
  have hx : execute f10Cfg.registry f10Store vaultBound.ctx vaultBound.env vaultBound.now
      consumerRequest state = .ok post := consumer_execute state hvault' hn
  have hstep := executeStep_invoke_ok (cfg := f10Cfg) (boundary := vaultBound)
      (index := 1) (history := [budgetOut 0]) (inv := inv201) (pre := ⟨state, f10Store⟩)
      (post := post) (iface := consumerIface) (request := consumerRequest)
      (e := consumerEval) f10_catalog_valid prepare_consumer hx
      (consumer_extract ⟨state, f10Store⟩ hvault')
  refine ⟨⟨post, .invoked consumerRequest consumerEval,
      snapshots 1 inv201.component consumerIface post.state⟩, ?_⟩
  refine ⟨?_, rfl, consumer_snapshots post.state, rfl, ?_, ?_, ?_⟩
  · simpa [f10_bounds_producer] using hstep
  · simp [post, applyWorld, consumer_effect]
  · simp [post, applyWorld, consumer_effect, vaultC_ne_recipientC.symm]
  · intro c hv hr
    simp [post, applyWorld, consumer_effect, hv, hr]

def deposit1Ctx (state : State P A D) :
    EvalContext P A D (constTransfer .donor1 .vault 1).signature :=
  ⟨state, donor1Bound.env, donor1Bound.ctx.principal, [], .nil, donor1Bound.now⟩

def deposit2Ctx (state : State P A D) :
    EvalContext P A D (constTransfer .donor2 .vault 2).signature :=
  ⟨state, donor2Bound.env, donor2Bound.ctx.principal, [], .nil, donor2Bound.now⟩

theorem deposit1_args :
    Args.check (constTransfer .donor1 .vault 1).signature deposit1Request.arguments =
      .ok .nil := rfl
theorem deposit2_args :
    Args.check (constTransfer .donor2 .vault 2).signature deposit2Request.arguments =
      .ok .nil := rfl

theorem deposit1_invoke_auth :
    hasAuthority f10Store (ids [3, 4]) donor1Bound.ctx ⟨202⟩ Right.invoke = true := by
  decide +kernel
theorem deposit1_debit_auth :
    hasAuthority f10Store (ids [3, 4]) donor1Bound.ctx ⟨202⟩ (.debit donor1C) = true := by
  decide +kernel
theorem deposit2_invoke_auth :
    hasAuthority f10Store (ids [5, 6]) donor2Bound.ctx ⟨203⟩ Right.invoke = true := by
  decide +kernel
theorem deposit2_debit_auth :
    hasAuthority f10Store (ids [5, 6]) donor2Bound.ctx ⟨203⟩ (.debit donor2C) = true := by
  decide +kernel

theorem deposit1_caller (state : State P A D) :
    (deposit1Ctx state).caller = donor1Bound.ctx.principal := rfl
theorem deposit1_parties_ctx (state : State P A D) :
    (deposit1Ctx state).parties = [] := rfl
theorem deposit2_caller (state : State P A D) :
    (deposit2Ctx state).caller = donor2Bound.ctx.principal := rfl
theorem deposit2_parties_ctx (state : State P A D) :
    (deposit2Ctx state).parties = [] := rfl

theorem deposit1_guard (state : State P A D) (h : 1 ≤ state.balance donor1C) :
    (constTransfer .donor1 .vault 1).guard.eval (deposit1Ctx state) = .ok true := by
  simp [deposit1Ctx, constTransfer, leBalance, Expr.eval, BinaryOp.eval, readBalance,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure]
  have hcell : (Domain.home, Party.donor1, Asset.usd) = donor1C := rfl
  simpa [numericRat, hcell] using h

theorem deposit2_guard (state : State P A D) (h : 2 ≤ state.balance donor2C) :
    (constTransfer .donor2 .vault 2).guard.eval (deposit2Ctx state) = .ok true := by
  simp [deposit2Ctx, constTransfer, leBalance, Expr.eval, BinaryOp.eval, readBalance,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure]
  have hcell : (Domain.home, Party.donor2, Asset.usd) = donor2C := rfl
  simpa [numericRat, hcell] using h

theorem deposit1_resolve_required (state : State P A D) :
    resolveRefs (deposit1Ctx state).caller (deposit1Ctx state).parties
      (constTransfer .donor1 .vault 1).requiredStateReads = .ok [donor1C] := by
  rw [deposit1_caller state, deposit1_parties_ctx state]
  simp [resolveRefs, Template.requiredStateReads, constTransfer, packed, cellRef,
    Expr.stateReads, leBalance, negAmt, litAmt, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    List.flatMap, donor1C]

theorem deposit1_resolve_declared (state : State P A D) :
    resolveRefs (deposit1Ctx state).caller (deposit1Ctx state).parties
      (constTransfer .donor1 .vault 1).stateReads = .ok [donor1C] := by
  rw [deposit1_caller state, deposit1_parties_ctx state]
  simp [resolveRefs, constTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure, donor1C]

theorem deposit1_resolve_writes (state : State P A D) :
    resolveRefs (deposit1Ctx state).caller (deposit1Ctx state).parties
      (constTransfer .donor1 .vault 1).writes = .ok [donor1C, vaultC] := by
  rw [deposit1_caller state, deposit1_parties_ctx state]
  simp [resolveRefs, constTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    donor1C, vaultC]

theorem deposit2_resolve_required (state : State P A D) :
    resolveRefs (deposit2Ctx state).caller (deposit2Ctx state).parties
      (constTransfer .donor2 .vault 2).requiredStateReads = .ok [donor2C] := by
  rw [deposit2_caller state, deposit2_parties_ctx state]
  simp [resolveRefs, Template.requiredStateReads, constTransfer, packed, cellRef,
    Expr.stateReads, leBalance, negAmt, litAmt, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    List.flatMap, donor2C]

theorem deposit2_resolve_declared (state : State P A D) :
    resolveRefs (deposit2Ctx state).caller (deposit2Ctx state).parties
      (constTransfer .donor2 .vault 2).stateReads = .ok [donor2C] := by
  rw [deposit2_caller state, deposit2_parties_ctx state]
  simp [resolveRefs, constTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure, donor2C]

theorem deposit2_resolve_writes (state : State P A D) :
    resolveRefs (deposit2Ctx state).caller (deposit2Ctx state).parties
      (constTransfer .donor2 .vault 2).writes = .ok [donor2C, vaultC] := by
  rw [deposit2_caller state, deposit2_parties_ctx state]
  simp [resolveRefs, constTransfer, packed, cellRef, List.mapM, List.mapM.loop,
    CellRef.resolve, PartyRef.resolve, bind, Except.bind, pure, Except.pure,
    donor2C, vaultC]

theorem deposit1_evaluate (state : State P A D) (h : 1 ≤ state.balance donor1C) :
    (constTransfer .donor1 .vault 1).evaluate (deposit1Ctx state) = .ok deposit1Eval := by
  unfold Template.evaluate
  rw [deposit1_resolve_required state, deposit1_resolve_declared state,
    deposit1_resolve_writes state]
  simp only [bind, Except.bind, pure, Except.pure]
  rw [deposit1_guard state h]
  simp [deposit1Ctx, constTransfer, List.mapM, List.mapM.loop, CellRef.resolve,
    PartyRef.resolve, cellRef, Expr.eval, litAmt, negAmt, bind, Except.bind, pure,
    Except.pure, donor1C, vaultC, deposit1Eval, evaluated, Template.requiredEnvReads,
    Expr.envReads, leBalance]

theorem deposit2_evaluate (state : State P A D) (h : 2 ≤ state.balance donor2C) :
    (constTransfer .donor2 .vault 2).evaluate (deposit2Ctx state) = .ok deposit2Eval := by
  unfold Template.evaluate
  rw [deposit2_resolve_required state, deposit2_resolve_declared state,
    deposit2_resolve_writes state]
  simp only [bind, Except.bind, pure, Except.pure]
  rw [deposit2_guard state h]
  simp [deposit2Ctx, constTransfer, List.mapM, List.mapM.loop, CellRef.resolve,
    PartyRef.resolve, cellRef, Expr.eval, litAmt, negAmt, bind, Except.bind, pure,
    Except.pure, donor2C, vaultC, deposit2Eval, evaluated, Template.requiredEnvReads,
    Expr.envReads, leBalance]

theorem deposit1_extract (pre : W) (h : 1 ≤ pre.state.balance donor1C) :
    extractReceipt f10Cfg donor1Bound deposit1Request pre = .ok deposit1Eval := by
  unfold extractReceipt
  simp only [bind, Except.bind, Except.mapError]
  rw [show f10Cfg.registry deposit1Request.operation = some (constTransfer .donor1 .vault 1) from rfl]
  simp only [bind, Except.bind, Except.mapError]
  rw [deposit1_args]
  simp only [Except.mapError, bind, Except.bind]
  change ((constTransfer .donor1 .vault 1).evaluate (deposit1Ctx pre.state)).mapError
      (fun _ ↦ Failure.internalReceipt) = .ok deposit1Eval
  rw [deposit1_evaluate pre.state h]
  rfl

theorem deposit2_extract (pre : W) (h : 2 ≤ pre.state.balance donor2C) :
    extractReceipt f10Cfg donor2Bound deposit2Request pre = .ok deposit2Eval := by
  unfold extractReceipt
  simp only [bind, Except.bind, Except.mapError]
  rw [show f10Cfg.registry deposit2Request.operation = some (constTransfer .donor2 .vault 2) from rfl]
  simp only [bind, Except.bind, Except.mapError]
  rw [deposit2_args]
  simp only [Except.mapError, bind, Except.bind]
  change ((constTransfer .donor2 .vault 2).evaluate (deposit2Ctx pre.state)).mapError
      (fun _ ↦ Failure.internalReceipt) = .ok deposit2Eval
  rw [deposit2_evaluate pre.state h]
  rfl

theorem donor1C_ne_vaultC : donor1C ≠ vaultC := by decide
theorem donor2C_ne_vaultC : donor2C ≠ vaultC := by decide

theorem deposit1_effect (c : C) :
    deposit1Eval.effect c =
      if c = donor1C then (-1 : ℚ) else if c = vaultC then 1 else 0 := by
  simp [deposit1Eval, evaluated, Evaluated.effect]
  by_cases h1 : c = donor1C
  · subst c
    simp [donor1C_ne_vaultC.symm]
  · by_cases h2 : c = vaultC
    · subst c
      have hne : donor1C ≠ vaultC := Ne.symm h1
      simp [h1, hne]
    · simp [h1, h2, eq_comm]

theorem deposit2_effect (c : C) :
    deposit2Eval.effect c =
      if c = donor2C then (-2 : ℚ) else if c = vaultC then 2 else 0 := by
  simp [deposit2Eval, evaluated, Evaluated.effect]
  by_cases h1 : c = donor2C
  · subst c
    simp [donor2C_ne_vaultC.symm]
  · by_cases h2 : c = vaultC
    · subst c
      have hne : donor2C ≠ vaultC := Ne.symm h1
      simp [h1, hne]
    · simp [h1, h2, eq_comm]

theorem deposit1_stateReadsOK : deposit1Eval.stateReadsOK = true := by decide
theorem deposit1_envReadsOK : deposit1Eval.envReadsOK = true := by decide
theorem deposit1_domainOK : deposit1Eval.domainOK Domain.home = true := by decide +kernel
theorem deposit1_debitsOK :
    deposit1Eval.debitsOK f10Store deposit1Request donor1Bound.ctx = true := by
  decide +kernel
theorem deposit1_suppliesOK :
    deposit1Eval.suppliesOK f10Store deposit1Request donor1Bound.ctx = true := by
  decide +kernel
theorem deposit1_accountingOK : deposit1Eval.accountingOK = true := by decide +kernel
theorem deposit1_writesOK : deposit1Eval.writesOK = true := by decide +kernel

theorem deposit2_stateReadsOK : deposit2Eval.stateReadsOK = true := by decide
theorem deposit2_envReadsOK : deposit2Eval.envReadsOK = true := by decide
theorem deposit2_domainOK : deposit2Eval.domainOK Domain.home = true := by decide +kernel
theorem deposit2_debitsOK :
    deposit2Eval.debitsOK f10Store deposit2Request donor2Bound.ctx = true := by
  decide +kernel
theorem deposit2_suppliesOK :
    deposit2Eval.suppliesOK f10Store deposit2Request donor2Bound.ctx = true := by
  decide +kernel
theorem deposit2_accountingOK : deposit2Eval.accountingOK = true := by decide +kernel
theorem deposit2_writesOK : deposit2Eval.writesOK = true := by decide +kernel

theorem deposit1_nonneg (state : State P A D) (h : 1 ≤ state.balance donor1C) :
    ∀ c, 0 ≤ state.balance c + deposit1Eval.effect c := by
  intro c
  rw [deposit1_effect]
  split_ifs with hv hr
  · subst hv
    simpa using sub_nonneg.mpr h
  · subst hr
    exact add_nonneg (state.nonneg vaultC) (by decide : (0 : ℚ) ≤ 1)
  · simpa using state.nonneg c

theorem deposit2_nonneg (state : State P A D) (h : 2 ≤ state.balance donor2C) :
    ∀ c, 0 ≤ state.balance c + deposit2Eval.effect c := by
  intro c
  rw [deposit2_effect]
  split_ifs with hv hr
  · subst hv
    simpa using sub_nonneg.mpr h
  · subst hr
    exact add_nonneg (state.nonneg vaultC) (by decide : (0 : ℚ) ≤ 2)
  · simpa using state.nonneg c

theorem deposit1_valid (state : State P A D) (h : 1 ≤ state.balance donor1C) :
    deposit1Eval.Valid f10Store donor1Bound.ctx deposit1Request state :=
  ⟨rfl, deposit1_stateReadsOK, deposit1_envReadsOK, deposit1_domainOK,
    deposit1_debitsOK, deposit1_suppliesOK, deposit1_nonneg state h,
    deposit1_accountingOK, deposit1_writesOK⟩

theorem deposit2_valid (state : State P A D) (h : 2 ≤ state.balance donor2C) :
    deposit2Eval.Valid f10Store donor2Bound.ctx deposit2Request state :=
  ⟨rfl, deposit2_stateReadsOK, deposit2_envReadsOK, deposit2_domainOK,
    deposit2_debitsOK, deposit2_suppliesOK, deposit2_nonneg state h,
    deposit2_accountingOK, deposit2_writesOK⟩

theorem deposit1_execute (state : State P A D) (h : 1 ≤ state.balance donor1C)
    (hn : ∀ c, 0 ≤ state.balance c + deposit1Eval.effect c) :
    execute f10Cfg.registry f10Store donor1Bound.ctx donor1Bound.env donor1Bound.now
        deposit1Request state = .ok (applyWorld state f10Store deposit1Eval hn) := by
  refine (execute_ok_iff f10Cfg.registry f10Store donor1Bound.ctx donor1Bound.env
      donor1Bound.now deposit1Request state (applyWorld state f10Store deposit1Eval hn)).mpr ?_
  refine ⟨constTransfer .donor1 .vault 1, rfl, Or.inl rfl, rfl, rfl, ?_⟩
  refine ⟨.nil, deposit1_args, deposit1_invoke_auth, ?_⟩
  refine ⟨deposit1Eval, deposit1_evaluate state h, deposit1_valid state h, rfl, ?_⟩
  intro c
  rfl

theorem deposit2_execute (state : State P A D) (h : 2 ≤ state.balance donor2C)
    (hn : ∀ c, 0 ≤ state.balance c + deposit2Eval.effect c) :
    execute f10Cfg.registry f10Store donor2Bound.ctx donor2Bound.env donor2Bound.now
        deposit2Request state = .ok (applyWorld state f10Store deposit2Eval hn) := by
  refine (execute_ok_iff f10Cfg.registry f10Store donor2Bound.ctx donor2Bound.env
      donor2Bound.now deposit2Request state (applyWorld state f10Store deposit2Eval hn)).mpr ?_
  refine ⟨constTransfer .donor2 .vault 2, rfl, Or.inl rfl, rfl, rfl, ?_⟩
  refine ⟨.nil, deposit2_args, deposit2_invoke_auth, ?_⟩
  refine ⟨deposit2Eval, deposit2_evaluate state h, deposit2_valid state h, rfl, ?_⟩
  intro c
  rfl

theorem deposit1_snapshots (state : State P A D) :
    snapshots 0 inv202.component deposit1Iface state = [] := rfl
theorem deposit2_snapshots (state : State P A D) :
    snapshots 0 inv203.component deposit2Iface state = [] := rfl

theorem f10_deposit1_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hdonor : 1 ≤ pre.state.balance donor1C) :
    ∃ result, executeStep f10Cfg (f10Bounds (1 : Fin 3) 0) 0 [] (.invoke inv202) pre =
        .ok result ∧
      result.receipt = rec202 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance donor1C = pre.state.balance donor1C + (-1) ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + 1 ∧
      ∀ c, c ≠ donor1C → c ≠ vaultC →
        result.world.state.balance c = pre.state.balance c := by
  rcases pre with ⟨state, caps⟩
  subst hstore
  have hdonor' : 1 ≤ state.balance donor1C := hdonor
  have hn := deposit1_nonneg state hdonor'
  let post := applyWorld state f10Store deposit1Eval hn
  have hx : execute f10Cfg.registry f10Store donor1Bound.ctx donor1Bound.env donor1Bound.now
      deposit1Request state = .ok post := deposit1_execute state hdonor' hn
  have hstep := executeStep_invoke_ok (cfg := f10Cfg) (boundary := donor1Bound)
      (index := 0) (history := []) (inv := inv202) (pre := ⟨state, f10Store⟩)
      (post := post) (iface := deposit1Iface) (request := deposit1Request)
      (e := deposit1Eval) f10_catalog_valid prepare_deposit1 hx
      (deposit1_extract ⟨state, f10Store⟩ hdonor')
  refine ⟨⟨post, .invoked deposit1Request deposit1Eval,
      snapshots 0 inv202.component deposit1Iface post.state⟩, ?_⟩
  refine ⟨?_, rfl, deposit1_snapshots post.state, rfl, ?_, ?_, ?_⟩
  · simpa [f10_bounds_deposit1] using hstep
  · simp [post, applyWorld, deposit1_effect]
  · simp [post, applyWorld, deposit1_effect, donor1C_ne_vaultC.symm]
  · intro c hv hr
    simp [post, applyWorld, deposit1_effect, hv, hr]

theorem f10_deposit2_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hdonor : 2 ≤ pre.state.balance donor2C) :
    ∃ result, executeStep f10Cfg (f10Bounds (2 : Fin 3) 0) 0 [] (.invoke inv203) pre =
        .ok result ∧
      result.receipt = rec203 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance donor2C = pre.state.balance donor2C + (-2) ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + 2 ∧
      ∀ c, c ≠ donor2C → c ≠ vaultC →
        result.world.state.balance c = pre.state.balance c := by
  rcases pre with ⟨state, caps⟩
  subst hstore
  have hdonor' : 2 ≤ state.balance donor2C := hdonor
  have hn := deposit2_nonneg state hdonor'
  let post := applyWorld state f10Store deposit2Eval hn
  have hx : execute f10Cfg.registry f10Store donor2Bound.ctx donor2Bound.env donor2Bound.now
      deposit2Request state = .ok post := deposit2_execute state hdonor' hn
  have hstep := executeStep_invoke_ok (cfg := f10Cfg) (boundary := donor2Bound)
      (index := 0) (history := []) (inv := inv203) (pre := ⟨state, f10Store⟩)
      (post := post) (iface := deposit2Iface) (request := deposit2Request)
      (e := deposit2Eval) f10_catalog_valid prepare_deposit2 hx
      (deposit2_extract ⟨state, f10Store⟩ hdonor')
  refine ⟨⟨post, .invoked deposit2Request deposit2Eval,
      snapshots 0 inv203.component deposit2Iface post.state⟩, ?_⟩
  refine ⟨?_, rfl, deposit2_snapshots post.state, rfl, ?_, ?_, ?_⟩
  · simpa [f10_bounds_deposit2] using hstep
  · simp [post, applyWorld, deposit2_effect]
  · simp [post, applyWorld, deposit2_effect, donor2C_ne_vaultC.symm]
  · intro c hv hr
    simp [post, applyWorld, deposit2_effect, hv, hr]

end DefiKernel.Nary.FundedEnabledness


