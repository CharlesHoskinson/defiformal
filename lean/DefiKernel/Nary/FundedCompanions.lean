import DefiKernel.Nary.Interference
import DefiKernel.Nary.Observation
import DefiKernel.Nary.CausalRuntime
import DefiKernel.Nary.Examples
import DefiKernel.Interface.Accounting
import Mathlib.Tactic.Linarith

/-! Proof-only F12/F16/F17 companions and a standalone F10 deposit Ready-bound
witness. This module does not import `FundedCausal`, does not assume a desired
run, and does not add proof imports to runtime. Expected machines are the
independent Examples literals. -/
namespace DefiKernel.Nary.FundedCompanions
open Typed Composition
open DefiKernel.Nary
open DefiKernel.Nary.Examples
open Interface (receiptCellEffect step_receipt_cell)

/-- Ready budget inequality used by the funded monitor obligation: `6 ≤ vault - 4`. -/
def readyBudgetBound (s : State P A D) : Prop :=
  (6 : ℚ) ≤ s.balance vaultC - (4 : ℚ)

/-- Ordinary initialized reserve `4 ≤ vault`. Distinct from `readyBudgetBound`. -/
def vaultReserve4 (s : State P A D) : Prop :=
  (4 : ℚ) ≤ s.balance vaultC

def readyInv (_b : Fin 3) (s : State P A D) : Prop :=
  readyBudgetBound s

/-- Deposit-only peer rely: vault does not fall. This is the safe rely, not the
F12 covering relation. -/
def depositOnlyRely (_b : Fin 3) (pre post : State P A D) : Prop :=
  pre.balance vaultC ≤ post.balance vaultC

/-- Independent expected worlds for F10 deposit steps; not produced by `runNary`. -/
def f10AfterDeposit1 : W := mkWorld 11 0 1 3 0 0 6 0 f10Store
def f10AfterDeposit2 : W := mkWorld 12 0 2 1 0 0 6 0 f10Store

def f12ProdResult : SR := sr f12AfterProd rec200 [budgetOut 0]
def f12PeerResult : SR := sr f12AfterPeer rec16s
def f12ConsResult : SR := sr f12AfterCons rec201
def f16PeerResult : SR := sr f16AfterPeer rec202s
def f17PeerResult : SR := sr f10Initial rec200 [budgetOut 0]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.unusedSimpArgs false
set_option linter.style.setOption false

theorem locals3_0 (l0 l1 l2 : LS) : locals3 l0 l1 l2 0 = l0 := by simp [locals3]
theorem locals3_1 (l0 l1 l2 : LS) : locals3 l0 l1 l2 1 = l1 := by simp [locals3]
theorem mkWorld_store (v d0 d1 d2 r r1 b ad : Nat) (store : Store) :
    (mkWorld v d0 d1 d2 r r1 b ad store).capabilities = store :=
  rfl
theorem sr_outputs (w : W) (receipt : Receipt P A D) (outs : List (OutputObservation A)) :
    (sr w receipt outs).outputs = outs :=
  rfl
theorem sr_receipt (w : W) (receipt : Receipt P A D) (outs : List (OutputObservation A)) :
    (sr w receipt outs).receipt = receipt :=
  rfl

theorem admit_exists_of_isOk
    {Q R S : Type} [DecidableEq Q] [DecidableEq R] [DecidableEq S]
    [Fintype Q] [Fintype R] [Fintype S]
    {cfg : Config Q R S} {roster : Roster (Fin 3)}
    {boundaries : Boundaries (Fin 3) Q R S} {branches : Branches (Fin 3) Q R S}
    {schedule : Schedule (Fin 3)}
    (h : (admit cfg roster boundaries branches schedule).isOk = true) :
    ∃ fps, admit cfg roster boundaries branches schedule = .ok fps := by
  cases ha : admit cfg roster boundaries branches schedule with
  | error _ =>
    rw [ha] at h
    simp [Except.toBool] at h
  | ok fps => exact ⟨fps, rfl⟩

theorem runNary_executed_of_isOk
    {Q R S : Type} [DecidableEq Q] [DecidableEq R] [DecidableEq S]
    [Fintype Q] [Fintype R] [Fintype S]
    {cfg : Config Q R S} {roster : Roster (Fin 3)}
    {boundaries : Boundaries (Fin 3) Q R S} {initial : World Q R S}
    {branches : Branches (Fin 3) Q R S} {schedule : Schedule (Fin 3)}
    (h : (admit cfg roster boundaries branches schedule).isOk = true) :
    runNary cfg roster boundaries initial branches schedule =
      .executed schedule (runPrefix cfg boundaries initial branches schedule) := by
  obtain ⟨fps, ha⟩ := admit_exists_of_isOk h
  exact runNary_executed cfg roster boundaries initial branches schedule fps ha

theorem readyBudgetBound_iff (s : State P A D) :
    readyBudgetBound s ↔ (10 : ℚ) ≤ s.balance vaultC := by
  constructor
  · intro h
    simp [readyBudgetBound] at h
    linarith
  · intro h
    simp [readyBudgetBound]
    linarith

theorem depositOnlyRely_stable_ready : Stable readyInv depositOnlyRely := by
  intro _b pre post hinv hrel
  simp [readyInv, readyBudgetBound, depositOnlyRely] at hinv hrel ⊢
  linarith

theorem vaultC_ne_donor1C : vaultC ≠ donor1C := by decide
theorem vaultC_ne_donor2C : vaultC ≠ donor2C := by decide
theorem vaultC_ne_budgetC : vaultC ≠ budgetC := by decide
theorem donor1C_ne_budgetC : donor1C ≠ budgetC := by decide
theorem donor2C_ne_budgetC : donor2C ≠ budgetC := by decide
theorem donor1C_ne_vaultC : donor1C ≠ vaultC := by decide
theorem donor2C_ne_vaultC : donor2C ≠ vaultC := by decide

theorem two_delta_cell (request : Request P A D) (e : Evaluated P A D)
    (c1 c2 : C) (a1 a2 : ℚ) (h : e.deltas = [(c1, a1), (c2, a2)]) (cell : C) :
    receiptCellEffect (.invoked request e) cell =
      (if c1 = cell then a1 else 0) + (if c2 = cell then a2 else 0) := by
  simp [receiptCellEffect, h]

theorem two_delta_balances {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : W} {result : StepResult P A D} {request : Request P A D}
    {e : Evaluated P A D} {c1 c2 : C} {a1 a2 : ℚ}
    (h : executeStep cfg boundary index history (.invoke inv) pre = .ok result)
    (hr : result.receipt = .invoked request e) (hd : e.deltas = [(c1, a1), (c2, a2)])
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if c1 = cell then a1 else 0) + (if c2 = cell then a2 else 0)) := by
  rw [step_receipt_cell h, hr, two_delta_cell request e c1 c2 a1 a2 hd]

theorem constTransfer_deltas (src dst : P) (q : ℚ)
    (ctx : EvalContext P A D []) (e : Evaluated P A D)
    (h : (constTransfer src dst q).evaluate ctx = .ok e) :
    e.deltas = [((.home, src, .usd), -q), ((.home, dst, .usd), q)] := by
  simp [Template.evaluate, constTransfer, resolveRefs, packed, cellRef, bind, Except.bind,
    pure, Except.pure, litAmt, negAmt] at h
  cases h
  rfl

theorem deposit_deltas {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {pre : W}
    {result : StepResult P A D} {op : Nat} {src dst : P} {q : ℚ}
    {caps : List Nat} {iface : OperationInterface P A D}
    (h : executeStep cfg boundary index history (.invoke (invoke op caps)) pre = .ok result)
    (hp : prepareInvocation cfg boundary index history (invoke op caps) =
      .ok (iface, ⟨⟨op⟩, [], [], ids caps, none⟩))
    (ht : cfg.registry ⟨op⟩ = some (constTransfer src dst q)) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [((.home, src, .usd), -q), ((.home, dst, .usd), q)] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface' request e prepared executed extracted applied =>
    rw [hp] at prepared
    cases prepared
    have hargs : Args.check (constTransfer src dst q).signature [] = .ok .nil := rfl
    simp [extractReceipt, ht, hargs, bind, Except.bind, Except.mapError] at extracted
    cases hev : (constTransfer src dst q).evaluate
        ⟨pre.state, boundary.env, boundary.ctx.principal, [], .nil, boundary.now⟩ with
    | error _ => simp [hev] at extracted
    | ok e' =>
      have heq : e' = e := by simpa [hev] using extracted
      exact ⟨_, e, rfl, constTransfer_deltas _ _ _ _ _ (heq ▸ hev)⟩

/-! ### F10 standalone deposit Ready-bound witness -/

theorem f10_catalog_valid : validateCatalog f10Cfg.registry f10Cfg.catalog = true := by
  decide

theorem f10_initial_ready : readyBudgetBound f10Initial.state := by
  simp [readyBudgetBound]
  decide +kernel

theorem f10_initial_vault10 : f10Initial.state.balance vaultC = 10 := by
  decide +kernel

theorem f10_initial_budget6 : f10Initial.state.balance budgetC = 6 := by
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f10_producer_execute :
    executeStep f10Cfg vaultBound 0 [] (.invoke inv200) f10Initial =
      .ok (sr f10Initial rec200 [budgetOut 0]) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f10_deposit1_execute :
    executeStep f10Cfg donor1Bound 0 [] (.invoke inv202) f10Initial =
      .ok (sr f10AfterDeposit1 rec202) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f10_deposit2_execute :
    executeStep f10Cfg donor2Bound 0 [] (.invoke inv203) f10Initial =
      .ok (sr f10AfterDeposit2 rec203) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f10_deposit1_prepare {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} :
    prepareInvocation f10Cfg boundary index history inv202 =
      .ok (⟨⟨202⟩, [], []⟩, ⟨⟨202⟩, [], [], ids [3, 4], none⟩) :=
  rfl

theorem f10_deposit2_prepare {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} :
    prepareInvocation f10Cfg boundary index history inv203 =
      .ok (⟨⟨203⟩, [], []⟩, ⟨⟨203⟩, [], [], ids [5, 6], none⟩) :=
  rfl

theorem f10_deposit1_deltas {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(donor1C, -1), (vaultC, 1)] :=
  deposit_deltas h f10_deposit1_prepare rfl

theorem f10_deposit2_deltas {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(donor2C, -2), (vaultC, 2)] :=
  deposit_deltas h f10_deposit2_prepare rfl

theorem f10_deposit1_cell {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if donor1C = cell then (-1 : ℚ) else 0) +
          (if vaultC = cell then (1 : ℚ) else 0)) := by
  obtain ⟨request, e, hr, hd⟩ := f10_deposit1_deltas h
  exact two_delta_balances h hr hd cell

theorem f10_deposit2_cell {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if donor2C = cell then (-2 : ℚ) else 0) +
          (if vaultC = cell then (2 : ℚ) else 0)) := by
  obtain ⟨request, e, hr, hd⟩ := f10_deposit2_deltas h
  exact two_delta_balances h hr hd cell

/-- Actual successful inv202 preserves `6 ≤ vault - 4` and leaves the budget cell
unchanged. The hypothesis is the successful `executeStep` equation, not future
enabledness. -/
theorem f10_deposit1_preserves_ready {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result)
    (hready : readyBudgetBound pre.state) :
    readyBudgetBound result.world.state ∧
      result.world.state.balance budgetC = pre.state.balance budgetC := by
  have hv := f10_deposit1_cell h vaultC
  have hb := f10_deposit1_cell h budgetC
  simp [donor1C_ne_vaultC, vaultC_ne_budgetC, donor1C_ne_budgetC] at hv hb
  refine ⟨?_, hb⟩
  simp [readyBudgetBound] at hready ⊢
  linarith

theorem f10_deposit2_preserves_ready {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result)
    (hready : readyBudgetBound pre.state) :
    readyBudgetBound result.world.state ∧
      result.world.state.balance budgetC = pre.state.balance budgetC := by
  have hv := f10_deposit2_cell h vaultC
  have hb := f10_deposit2_cell h budgetC
  simp [donor2C_ne_vaultC, vaultC_ne_budgetC, donor2C_ne_budgetC] at hv hb
  refine ⟨?_, hb⟩
  simp [readyBudgetBound] at hready ⊢
  linarith

theorem f10_deposit1_execute_preserves_ready :
    readyBudgetBound f10Initial.state ∧
      executeStep f10Cfg donor1Bound 0 [] (.invoke inv202) f10Initial =
        .ok (sr f10AfterDeposit1 rec202) ∧
      readyBudgetBound f10AfterDeposit1.state ∧
      f10AfterDeposit1.state.balance budgetC = 6 ∧
      f10AfterDeposit1.state.balance vaultC = 11 := by
  refine ⟨f10_initial_ready, f10_deposit1_execute, ?_, ?_, ?_⟩
  · simp [readyBudgetBound]
    decide +kernel
  · decide +kernel
  · decide +kernel

theorem f10_deposit2_execute_preserves_ready :
    readyBudgetBound f10Initial.state ∧
      executeStep f10Cfg donor2Bound 0 [] (.invoke inv203) f10Initial =
        .ok (sr f10AfterDeposit2 rec203) ∧
      readyBudgetBound f10AfterDeposit2.state ∧
      f10AfterDeposit2.state.balance budgetC = 6 ∧
      f10AfterDeposit2.state.balance vaultC = 12 := by
  refine ⟨f10_initial_ready, f10_deposit2_execute, ?_, ?_, ?_⟩
  · simp [readyBudgetBound]
    decide +kernel
  · decide +kernel
  · decide +kernel

theorem f10_producer_advance :
    advance f10Cfg f10Bounds f10Branches (start f10Initial) 0 =
      (start f10Initial).accept 0 inv200 (sr f10Initial rec200 [budgetOut 0]) := by
  have hfail : ((start (B := Fin 3) f10Initial).locals 0).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f10Initial).locals 0).failure.isSome = false := by
    simp [hfail]
  have hsel : (f10Branches 0)[((start (B := Fin 3) f10Initial).locals 0).consumed]? =
      some inv200 := by
    simp [start_locals, f10Branches]
  have hex : executeStep f10Cfg
      (f10Bounds 0 ((start (B := Fin 3) f10Initial).locals 0).nextIndex)
      ((start (B := Fin 3) f10Initial).locals 0).nextIndex
      ((start (B := Fin 3) f10Initial).locals 0).outputs (.invoke inv200)
      (start (B := Fin 3) f10Initial).world =
        .ok (sr f10Initial rec200 [budgetOut 0]) := by
    simp [start_locals, start_world, f10Bounds]
    exact f10_producer_execute
  simp [advance, his, hsel, hex]

theorem f10_producer_prefix :
    runPrefix f10Cfg f10Bounds f10Initial f10Branches [0] =
      (start f10Initial).accept 0 inv200 (sr f10Initial rec200 [budgetOut 0]) := by
  rw [runPrefix, continueRun_cons, f10_producer_advance, continueRun_nil]

theorem f10_producer_prefix_world :
    (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world = f10Initial := by
  rw [f10_producer_prefix, accept_world]
  rfl

theorem f10_producer_prefix_ready :
    readyBudgetBound (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state ∧
      (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state.balance budgetC = 6 ∧
      ((runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).locals 0).outputs =
        [budgetOut 0] := by
  rw [f10_producer_prefix_world, f10_producer_prefix]
  refine ⟨f10_initial_ready, f10_initial_budget6, ?_⟩
  simp [accept_selected, start_locals, sr]

/-- Deposit 202 at the actual post-producer world, which is still the Ready vault 10
state. Success is the `executeStep` equation, not a future-enabledness premise. -/
theorem f10_deposit1_after_producer_preserves_ready :
    executeStep f10Cfg donor1Bound 0 [] (.invoke inv202)
        (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world =
      .ok (sr f10AfterDeposit1 rec202) ∧
      readyBudgetBound (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state ∧
      readyBudgetBound f10AfterDeposit1.state ∧
      f10AfterDeposit1.state.balance budgetC =
        (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state.balance budgetC := by
  rw [f10_producer_prefix_world]
  refine ⟨f10_deposit1_execute, f10_initial_ready, ?_, ?_⟩
  · simp [readyBudgetBound]
    decide +kernel
  · exact (f10_deposit1_preserves_ready f10_deposit1_execute f10_initial_ready).2

theorem f10_deposit2_after_producer_preserves_ready :
    executeStep f10Cfg donor2Bound 0 [] (.invoke inv203)
        (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world =
      .ok (sr f10AfterDeposit2 rec203) ∧
      readyBudgetBound (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state ∧
      readyBudgetBound f10AfterDeposit2.state ∧
      f10AfterDeposit2.state.balance budgetC =
        (runPrefix f10Cfg f10Bounds f10Initial f10Branches [0]).world.state.balance budgetC := by
  rw [f10_producer_prefix_world]
  refine ⟨f10_deposit2_execute, f10_initial_ready, ?_, ?_⟩
  · simp [readyBudgetBound]
    decide +kernel
  · exact (f10_deposit2_preserves_ready f10_deposit2_execute f10_initial_ready).2

/-! ### F12 stale authorized withdrawal after producer then consume 6 -/

theorem f12_catalog_valid : validateCatalog f12Cfg.registry f12Cfg.catalog = true := by
  decide

theorem f12_consumer_template :
    f12Cfg.registry ⟨201⟩ = some (consumerTransfer .recipient) :=
  rfl

/-- Ordinary consumer funds guard: nonnegative amount and amount ≤ vault. There is
no reserve conjunct. -/
theorem f12_consumer_guard :
    (consumerTransfer .recipient).guard =
      andBool (nonnegative usdArg)
        (.binary (.le (.amount .usd)) usdArg (.balance (cellRef .vault))) :=
  rfl

theorem f12_vaults :
    f12AfterProd.state.balance vaultC = 10 ∧
      f12AfterPeer.state.balance vaultC = 7 ∧
      f12AfterCons.state.balance vaultC = 1 ∧
      f12AfterCons.state.balance budgetC = 6 ∧
      f12AfterCons.state.balance recipientC = 6 ∧
      f12AfterCons.state.balance donor1C = 3 := by
  decide +kernel

theorem f12_ready_after_producer : readyBudgetBound f12AfterProd.state := by
  simp [readyBudgetBound]
  decide +kernel

/-- Named invariant failure: Ready bound `6 ≤ vault - 4` is false after the
authorized withdrawal 3 (vault 7). Ordinary reserve `4 ≤ vault` still holds. -/
theorem f12_not_ready_after_peer : ¬ readyBudgetBound f12AfterPeer.state := by
  simp [readyBudgetBound]
  decide +kernel

theorem f12_reserve4_after_peer : vaultReserve4 f12AfterPeer.state := by
  simp [vaultReserve4]
  decide +kernel

theorem f12_not_depositOnlyRely :
    ¬ depositOnlyRely 0 f12AfterProd.state f12AfterPeer.state := by
  intro h
  simp [depositOnlyRely] at h
  have hp : f12AfterProd.state.balance vaultC = 10 := f12_vaults.1
  have hq : f12AfterPeer.state.balance vaultC = 7 := f12_vaults.2.1
  linarith

/-- Any rely that covers the actual vault 10→7 step cannot stabilize
`readyBudgetBound`. `Stable readyInv depositOnlyRely` remains true. -/
theorem f12_not_stable_if_rely_covers
    (rely : Fin 3 → State P A D → State P A D → Prop)
    (covers : rely 0 f12AfterProd.state f12AfterPeer.state) :
    ¬ Stable readyInv rely := by
  intro hstable
  exact f12_not_ready_after_peer (hstable 0 _ _ f12_ready_after_producer covers)

def f12WithdrawalGuarantee (b : Fin 3) (pre post : State P A D) : Prop :=
  b = 1 ∧ pre.balance vaultC = 10 ∧ post.balance vaultC = 7

theorem f12_withdrawal_guarantee :
    f12WithdrawalGuarantee 1 f12AfterProd.state f12AfterPeer.state :=
  ⟨rfl, f12_vaults.1, f12_vaults.2.1⟩

theorem f12_not_cross_depositOnlyRely :
    ¬ CrossInclusion f12WithdrawalGuarantee depositOnlyRely := by
  intro h
  have hr : depositOnlyRely 0 f12AfterProd.state f12AfterPeer.state :=
    h 1 0 (by decide) _ _ f12_withdrawal_guarantee
  exact f12_not_depositOnlyRely hr

theorem f12_consumer_funds_valid :
    (6 : ℚ) ≤ f12AfterPeer.state.balance vaultC := by
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f12_producer_execute :
    executeStep f12Cfg vaultBound 0 [] (.invoke inv200) f12Initial =
      .ok f12ProdResult := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f12_peer_execute :
    executeStep f12Cfg vaultBound 0 [] (.invoke inv16) f12AfterProd =
      .ok f12PeerResult := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f12_consumer_execute :
    executeStep f12Cfg vaultBound 1 [budgetOut 0] (.invoke inv201) f12AfterPeer =
      .ok f12ConsResult := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f12_producer_prepare :
    prepareInvocation f12Cfg vaultBound 0 [] inv200 =
      .ok (⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨200⟩, [], [], ids [0], none⟩) :=
  rfl

theorem f12_peer_prepare {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} :
    prepareInvocation f12Cfg boundary index history inv16 =
      .ok (⟨⟨16⟩, [], []⟩, ⟨⟨16⟩, [], [], ids [7, 8], none⟩) :=
  rfl

theorem f12_consumer_prepare :
    prepareInvocation f12Cfg vaultBound 1 [budgetOut 0] inv201 =
      .ok (⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩,
        ⟨⟨201⟩, [], [⟨.amount .usd, 6⟩], ids [1, 2], none⟩) :=
  rfl

theorem f12_producer_access :
    ∃ component iface request template,
      prepareInvocation f12Cfg vaultBound 0 [] inv200 = .ok (iface, request) ∧
        lookupOperation f12Cfg.catalog inv200.component inv200.operation =
          some (component, iface) ∧
        f12Cfg.registry request.operation = some template ∧
        checkAccess component template vaultBound.ctx request.parties = .ok PUnit.unit := by
  have prepared := f12_producer_prepare
  obtain ⟨component, template, hl, ht, hc⟩ :=
    prepareInvocation_access _ _ _ _ _ _ _ prepared
  exact ⟨component, ⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨200⟩, [], [], ids [0], none⟩, template,
    prepared, hl, ht, hc⟩

theorem f12_peer_access :
    ∃ component iface request template,
      prepareInvocation f12Cfg vaultBound 0 [] inv16 = .ok (iface, request) ∧
        lookupOperation f12Cfg.catalog inv16.component inv16.operation =
          some (component, iface) ∧
        f12Cfg.registry request.operation = some template ∧
        checkAccess component template vaultBound.ctx request.parties = .ok PUnit.unit := by
  have prepared := f12_peer_prepare (boundary := vaultBound) (index := 0) (history := [])
  obtain ⟨component, template, hl, ht, hc⟩ :=
    prepareInvocation_access _ _ _ _ _ _ _ prepared
  exact ⟨component, ⟨⟨16⟩, [], []⟩, ⟨⟨16⟩, [], [], ids [7, 8], none⟩, template,
    prepared, hl, ht, hc⟩

theorem f12_consumer_access :
    ∃ component iface request template,
      prepareInvocation f12Cfg vaultBound 1 [budgetOut 0] inv201 = .ok (iface, request) ∧
        lookupOperation f12Cfg.catalog inv201.component inv201.operation =
          some (component, iface) ∧
        f12Cfg.registry request.operation = some template ∧
        checkAccess component template vaultBound.ctx request.parties = .ok PUnit.unit := by
  have prepared := f12_consumer_prepare
  obtain ⟨component, template, hl, ht, hc⟩ :=
    prepareInvocation_access _ _ _ _ _ _ _ prepared
  exact ⟨component, ⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩,
    ⟨⟨201⟩, [], [⟨.amount .usd, 6⟩], ids [1, 2], none⟩, template, prepared, hl, ht, hc⟩

theorem f12_peer_deltas {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f12Cfg boundary index history (.invoke inv16) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(vaultC, -3), (donor1C, 3)] :=
  deposit_deltas (cfg := f12Cfg) (src := .vault) (dst := .donor1) (q := 3) (op := 16)
    (caps := [7, 8]) h f12_peer_prepare rfl

theorem f12_peer_breaks_ready {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f12Cfg boundary index history (.invoke inv16) pre = .ok result)
    (hpre : pre.state.balance vaultC = 10) :
    result.world.state.balance vaultC = 7 ∧
      ¬ readyBudgetBound result.world.state ∧
      result.world.state.balance budgetC = pre.state.balance budgetC := by
  obtain ⟨request, e, hr, hd⟩ := f12_peer_deltas h
  have hv := two_delta_balances h hr hd vaultC
  have hb := two_delta_balances h hr hd budgetC
  simp [donor1C_ne_vaultC, vaultC_ne_budgetC, donor1C_ne_budgetC] at hv hb
  have hv7 : result.world.state.balance vaultC = 7 := by linarith
  refine ⟨hv7, ?_, hb⟩
  intro hready
  simp [readyBudgetBound, hv7] at hready
  linarith

theorem f12_producer_advance :
    advance f12Cfg f12Bounds f12Branches (start f12Initial) 0 =
      (start f12Initial).accept 0 inv200 f12ProdResult := by
  have hfail : ((start (B := Fin 3) f12Initial).locals 0).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f12Initial).locals 0).failure.isSome = false := by
    simp [hfail]
  have hsel : (f12Branches 0)[((start (B := Fin 3) f12Initial).locals 0).consumed]? =
      some inv200 := by
    simp [start_locals, f12Branches]
  have hex : executeStep f12Cfg
      (f12Bounds 0 ((start (B := Fin 3) f12Initial).locals 0).nextIndex)
      ((start (B := Fin 3) f12Initial).locals 0).nextIndex
      ((start (B := Fin 3) f12Initial).locals 0).outputs (.invoke inv200)
      (start (B := Fin 3) f12Initial).world = .ok f12ProdResult := by
    simp [start_locals, start_world, f12Bounds]
    exact f12_producer_execute
  simp [advance, his, hsel, hex]

def f12M1 : M3 := (start f12Initial).accept 0 inv200 f12ProdResult

theorem f12_peer_advance :
    advance f12Cfg f12Bounds f12Branches f12M1 1 =
      f12M1.accept 1 inv16 f12PeerResult := by
  have haway : f12M1.locals 1 = (start f12Initial).locals 1 :=
    accept_away (start f12Initial) 0 1 inv200 f12ProdResult (by decide)
  have hfail : (f12M1.locals 1).failure = none := by
    simp [haway, start_locals]
  have his : (f12M1.locals 1).failure.isSome = false := by simp [hfail]
  have hsel : (f12Branches 1)[(f12M1.locals 1).consumed]? = some inv16 := by
    simp [haway, start_locals, f12Branches]
  have hex : executeStep f12Cfg (f12Bounds 1 (f12M1.locals 1).nextIndex)
      (f12M1.locals 1).nextIndex (f12M1.locals 1).outputs (.invoke inv16) f12M1.world =
        .ok f12PeerResult := by
    simp [haway, start_locals, f12M1, accept_world, f12Bounds]
    exact f12_peer_execute
  simp [advance, his, hsel, hex]

def f12M2 : M3 := f12M1.accept 1 inv16 f12PeerResult

theorem f12_consumer_advance :
    advance f12Cfg f12Bounds f12Branches f12M2 0 =
      f12M2.accept 0 inv201 f12ConsResult := by
  have haway : f12M2.locals 0 = f12M1.locals 0 :=
    accept_away f12M1 1 0 inv16 f12PeerResult (by decide)
  have hfail : (f12M2.locals 0).failure = none := by
    simp [haway, f12M1, accept_selected, start_locals]
  have his : (f12M2.locals 0).failure.isSome = false := by simp [hfail]
  have hsel : (f12Branches 0)[(f12M2.locals 0).consumed]? = some inv201 := by
    simp [haway, f12M1, accept_selected, start_locals, f12Branches]
  have hex : executeStep f12Cfg (f12Bounds 0 (f12M2.locals 0).nextIndex)
      (f12M2.locals 0).nextIndex (f12M2.locals 0).outputs (.invoke inv201) f12M2.world =
        .ok f12ConsResult := by
    have hout : (f12M2.locals 0).outputs = [budgetOut 0] := by
      simp [haway, f12M1, accept_selected, start_locals, f12ProdResult, sr]
    have hidx : (f12M2.locals 0).nextIndex = 1 := by
      simp [haway, f12M1, accept_selected, start_locals]
    simp [f12M2, accept_world, f12M1, f12Bounds, hout, hidx]
    exact f12_consumer_execute
  simp [advance, his, hsel, hex]

theorem f12_runPrefix :
    runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule =
      f12M2.accept 0 inv201 f12ConsResult := by
  have h2 : f12M1.accept 1 inv16 f12PeerResult = f12M2 := rfl
  rw [f12Schedule, runPrefix, continueRun_cons, f12_producer_advance, continueRun_cons]
  change continueRun f12Cfg f12Bounds f12Branches
      (advance f12Cfg f12Bounds f12Branches f12M1 1) [0] =
    f12M2.accept 0 inv201 f12ConsResult
  rw [f12_peer_advance, h2, continueRun_cons, f12_consumer_advance, continueRun_nil]

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f12_prefix_eq_expected :
    runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule = f12Expected := by
  apply (machineEq_iff fin3Roster _ _).mp
  decide +kernel

theorem f12_admit_isOk :
    (admit f12Cfg fin3Roster f12Bounds f12Branches f12Schedule).isOk = true := by
  decide

theorem f12_admit_ok :
    validateCatalog f12Cfg.registry f12Cfg.catalog = true ∧
      (∃ fps, analyzeAll f12Cfg f12Bounds f12Branches fin3Roster.order = .ok fps) ∧
      Complete f12Branches f12Schedule := by
  obtain ⟨fps, ha⟩ := admit_exists_of_isOk f12_admit_isOk
  obtain ⟨hv, hanal, hc⟩ := admit_ok f12Cfg fin3Roster f12Bounds f12Branches f12Schedule fps ha
  exact ⟨hv, ⟨fps, hanal⟩, hc⟩

theorem f12_complete_counts :
    f12Schedule.count 0 = 2 ∧ f12Schedule.count 1 = 1 ∧ f12Schedule.count 2 = 0 ∧
      (f12Branches 0).length = 2 ∧ (f12Branches 1).length = 1 ∧
      (f12Branches 2).length = 0 := by
  simp [f12Schedule, f12Branches]

theorem f12_runNary_prefix :
    runNary f12Cfg fin3Roster f12Bounds f12Initial f12Branches f12Schedule =
      .executed f12Schedule
        (runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule) :=
  runNary_executed_of_isOk f12_admit_isOk

theorem f12_runNary_expected :
    runNary f12Cfg fin3Roster f12Bounds f12Initial f12Branches f12Schedule =
      .executed f12Schedule f12Expected := by
  rw [f12_runNary_prefix, f12_prefix_eq_expected]

theorem f12_runNary_outcome :
    match runNary f12Cfg fin3Roster f12Bounds f12Initial f12Branches f12Schedule with
    | .executed sched m =>
        sched = f12Schedule ∧
          m.world.state.balance vaultC = 1 ∧
          m.world.state.balance budgetC = 6 ∧
          m.world.state.balance recipientC = 6 ∧
          m.world.state.balance donor1C = 3 ∧
          m.world.capabilities = f12Store ∧
          (m.locals 0).outputs = [budgetOut 0] ∧
          (m.locals 0).nextIndex = 2 ∧
          (m.locals 1).nextIndex = 1 ∧
          ¬ readyBudgetBound m.world.state
    | .refused _ _ _ => False := by
  rw [f12_runNary_expected]
  refine ⟨rfl, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa [f12Expected] using f12_vaults.2.2.1
  · simpa [f12Expected] using f12_vaults.2.2.2.1
  · simpa [f12Expected] using f12_vaults.2.2.2.2.1
  · simpa [f12Expected] using f12_vaults.2.2.2.2.2
  · simp [f12Expected, f12AfterCons, mkWorld_store]
  · simp [f12Expected, locals3, localSucc]
  · simp [f12Expected, locals3, localSucc]
  · simp [f12Expected, locals3, localSucc]
  · intro h
    simp [f12Expected, readyBudgetBound] at h
    have : f12AfterCons.state.balance vaultC = 1 := f12_vaults.2.2.1
    simp [this] at h
    linarith

theorem f12_valid_authority_success :
    validateCatalog f12Cfg.registry f12Cfg.catalog = true ∧
      executeStep f12Cfg vaultBound 0 [] (.invoke inv200) f12Initial = .ok f12ProdResult ∧
      executeStep f12Cfg vaultBound 0 [] (.invoke inv16) f12AfterProd = .ok f12PeerResult ∧
      executeStep f12Cfg vaultBound 1 [budgetOut 0] (.invoke inv201) f12AfterPeer =
        .ok f12ConsResult ∧
      (6 : ℚ) ≤ f12AfterPeer.state.balance vaultC :=
  ⟨f12_catalog_valid, f12_producer_execute, f12_peer_execute, f12_consumer_execute,
    f12_consumer_funds_valid⟩

/-- Remaining premises after the named Ready-bound failure: catalog/authority,
ordinary consumer funds, producer provenance, and the still-true deposit-only
stability lemma. The failed named items are `readyBudgetBound` after the peer
step and `depositOnlyRely`/`Stable readyInv` of any covering rely. -/
theorem f12_remaining_premises :
    validateCatalog f12Cfg.registry f12Cfg.catalog = true ∧
      Stable readyInv depositOnlyRely ∧
      vaultReserve4 f12AfterPeer.state ∧
      ((runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule).locals 0).outputs =
        [budgetOut 0] ∧
      ¬ readyBudgetBound f12AfterPeer.state ∧
      ¬ depositOnlyRely 0 f12AfterProd.state f12AfterPeer.state :=
  ⟨f12_catalog_valid, depositOnlyRely_stable_ready, f12_reserve4_after_peer,
    by rw [f12_prefix_eq_expected]; simp [f12Expected, locals3, localSucc],
    f12_not_ready_after_peer, f12_not_depositOnlyRely⟩

/-! ### F16 refused producer, valid catalog/authority, monitor awaiting -/

theorem f16_catalog_valid : validateCatalog f16Cfg.registry f16Cfg.catalog = true := by
  decide

theorem f16_false_guard : falseProducer.guard = .lit false :=
  rfl

theorem f16_registry_producer : f16Cfg.registry ⟨210⟩ = some falseProducer :=
  rfl

theorem f16_producer_prepare :
    prepareInvocation f16Cfg vaultBound 0 [] inv210 =
      .ok (⟨⟨210⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨210⟩, [], [], ids [0], none⟩) :=
  rfl

theorem f16_producer_access :
    ∃ component iface request template,
      prepareInvocation f16Cfg vaultBound 0 [] inv210 = .ok (iface, request) ∧
        lookupOperation f16Cfg.catalog inv210.component inv210.operation =
          some (component, iface) ∧
        f16Cfg.registry request.operation = some template ∧
        checkAccess component template vaultBound.ctx request.parties = .ok PUnit.unit := by
  have prepared := f16_producer_prepare
  obtain ⟨component, template, hl, ht, hc⟩ :=
    prepareInvocation_access _ _ _ _ _ _ _ prepared
  exact ⟨component, ⟨⟨210⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨210⟩, [], [], ids [0], none⟩, template,
    prepared, hl, ht, hc⟩

theorem f16_producer_invoke_auth :
    hasAuthority f16Store (ids [0]) vaultBound.ctx ⟨210⟩ .invoke = true := by
  decide +kernel

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f16_producer_execute :
    executeStep f16Cfg vaultBound 0 [] (.invoke inv210) f16Initial =
      .error (.kernel .guard) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f16_producer_not_ok :
    ∀ result, executeStep f16Cfg vaultBound 0 [] (.invoke inv210) f16Initial ≠
      .ok result := by
  intro result h
  have he := f16_producer_execute
  rw [he] at h
  cases h

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f16_peer_execute :
    executeStep f16Cfg donor1Bound 0 [] (.invoke inv202) f16Initial =
      .ok f16PeerResult := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f16_error_not_ready :
    isReadyProducer ⟨0, 0, inv210, f16Initial, .error (.kernel .guard)⟩ = false := by
  simp [isReadyProducer]

theorem f16_producer_advance :
    advance f16Cfg f16Bounds f16Branches (start f16Initial) 0 =
      (start f16Initial).refuse 0 inv210 (.kernel .guard) := by
  have hfail : ((start (B := Fin 3) f16Initial).locals 0).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f16Initial).locals 0).failure.isSome = false := by
    simp [hfail]
  have hsel : (f16Branches 0)[((start (B := Fin 3) f16Initial).locals 0).consumed]? =
      some inv210 := by
    simp [start_locals, f16Branches]
  have hex : executeStep f16Cfg
      (f16Bounds 0 ((start (B := Fin 3) f16Initial).locals 0).nextIndex)
      ((start (B := Fin 3) f16Initial).locals 0).nextIndex
      ((start (B := Fin 3) f16Initial).locals 0).outputs (.invoke inv210)
      (start (B := Fin 3) f16Initial).world = .error (.kernel .guard) := by
    simp [start_locals, start_world, f16Bounds]
    exact f16_producer_execute
  simp [advance, his, hsel, hex]

def f16M1 : M3 := (start f16Initial).refuse 0 inv210 (.kernel .guard)

theorem f16_consumer_skip :
    advance f16Cfg f16Bounds f16Branches f16M1 0 = f16M1.skip 0 := by
  have hf : (f16M1.locals 0).failure =
      some ⟨0, some (.invoke inv210), .kernel .guard⟩ := by
    simp [f16M1, refuse_selected, start_locals]
  have his : (f16M1.locals 0).failure.isSome = true := by simp [hf]
  simp [advance, his]

def f16M2 : M3 := f16M1.skip 0

theorem f16_peer_advance :
    advance f16Cfg f16Bounds f16Branches f16M2 1 =
      f16M2.accept 1 inv202 f16PeerResult := by
  have hskip : f16M2.locals 1 = f16M1.locals 1 :=
    skip_away f16M1 0 1 (by decide)
  have haway : f16M1.locals 1 = (start f16Initial).locals 1 :=
    refuse_away (start f16Initial) 0 1 inv210 (.kernel .guard) (by decide)
  have hfail : (f16M2.locals 1).failure = none := by
    simp [hskip, haway, start_locals]
  have his : (f16M2.locals 1).failure.isSome = false := by simp [hfail]
  have hsel : (f16Branches 1)[(f16M2.locals 1).consumed]? = some inv202 := by
    simp [hskip, haway, start_locals, f16Branches]
  have hex : executeStep f16Cfg (f16Bounds 1 (f16M2.locals 1).nextIndex)
      (f16M2.locals 1).nextIndex (f16M2.locals 1).outputs (.invoke inv202) f16M2.world =
        .ok f16PeerResult := by
    simp [hskip, haway, start_locals, f16M2, skip_world, f16M1, refuse_world, start_world,
      f16Bounds]
    exact f16_peer_execute
  simp [advance, his, hsel, hex]

theorem f16_runPrefix :
    runPrefix f16Cfg f16Bounds f16Initial f16Branches f16Schedule =
      f16M2.accept 1 inv202 f16PeerResult := by
  have h2 : f16M1.skip 0 = f16M2 := rfl
  rw [f16Schedule, runPrefix, continueRun_cons, f16_producer_advance, continueRun_cons]
  change continueRun f16Cfg f16Bounds f16Branches
      (advance f16Cfg f16Bounds f16Branches f16M1 0) [1] =
    f16M2.accept 1 inv202 f16PeerResult
  rw [f16_consumer_skip, h2, continueRun_cons, f16_peer_advance, continueRun_nil]

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f16_prefix_eq_expected :
    runPrefix f16Cfg f16Bounds f16Initial f16Branches f16Schedule = f16Expected := by
  apply (machineEq_iff fin3Roster _ _).mp
  decide +kernel

theorem f16_admit_isOk :
    (admit f16Cfg fin3Roster f16Bounds f16Branches f16Schedule).isOk = true := by
  decide

theorem f16_admit_ok :
    validateCatalog f16Cfg.registry f16Cfg.catalog = true ∧
      (∃ fps, analyzeAll f16Cfg f16Bounds f16Branches fin3Roster.order = .ok fps) ∧
      Complete f16Branches f16Schedule := by
  obtain ⟨fps, ha⟩ := admit_exists_of_isOk f16_admit_isOk
  obtain ⟨hv, hanal, hc⟩ := admit_ok f16Cfg fin3Roster f16Bounds f16Branches f16Schedule fps ha
  exact ⟨hv, ⟨fps, hanal⟩, hc⟩

theorem f16_complete_counts :
    f16Schedule.count 0 = 2 ∧ f16Schedule.count 1 = 1 ∧ f16Schedule.count 2 = 0 ∧
      (f16Branches 0).length = 2 ∧ (f16Branches 1).length = 1 ∧
      (f16Branches 2).length = 0 := by
  simp [f16Schedule, f16Branches]

theorem f16_runNary_prefix :
    runNary f16Cfg fin3Roster f16Bounds f16Initial f16Branches f16Schedule =
      .executed f16Schedule
        (runPrefix f16Cfg f16Bounds f16Initial f16Branches f16Schedule) :=
  runNary_executed_of_isOk f16_admit_isOk

theorem f16_runNary_expected :
    runNary f16Cfg fin3Roster f16Bounds f16Initial f16Branches f16Schedule =
      .executed f16Schedule f16Expected := by
  rw [f16_runNary_prefix, f16_prefix_eq_expected]

theorem f16_runNary_outcome :
    match runNary f16Cfg fin3Roster f16Bounds f16Initial f16Branches f16Schedule with
    | .executed sched m =>
        sched = f16Schedule ∧
          m.world.state.balance vaultC = 11 ∧
          (m.locals 0).outputs = [] ∧
          (m.locals 0).events = [] ∧
          (m.locals 0).consumed = 2 ∧
          (m.locals 0).nextIndex = 0 ∧
          (m.locals 0).failure = some f16Fail ∧
          m.attempts.length = 2 ∧
          m.world.capabilities = f16Store
    | .refused _ _ _ => False := by
  rw [f16_runNary_expected]
  refine ⟨rfl, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [f16Expected]
    decide +kernel
  · simp [f16Expected, locals3, localFail]
  · simp [f16Expected, locals3, localFail]
  · simp [f16Expected, locals3, localFail]
  · simp [f16Expected, locals3, localFail]
  · simp [f16Expected, locals3, localFail]
  · simp [f16Expected]
  · simp [f16Expected, f16AfterPeer, mkWorld_store]

theorem f16_monitored_erases :
    (continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) f16Schedule).2 =
      runPrefix f16Cfg f16Bounds f16Initial f16Branches f16Schedule :=
  continueMonitored_erase _ _ _ _ _ _

theorem f16_first_attempt_is_error :
    ((runPrefix f16Cfg f16Bounds f16Initial f16Branches [0]).attempts).head? =
      some ⟨0, 0, inv210, f16Initial, .error (.kernel .guard)⟩ := by
  rw [runPrefix, continueRun_cons, f16_producer_advance, continueRun_nil, refuse_attempts,
    start_attempts, start_locals, start_world]
  simp

/-- Monitor consumes the actual refused producer attempt from the dispatcher, not a
synthetic `MonitorInput`. The error is not a Ready producer, so the phase stays
awaiting. -/
theorem f16_first_monitored :
    advanceMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) 0 =
      (.awaiting, (start f16Initial).refuse 0 inv210 (.kernel .guard)) := by
  have hadv := f16_producer_advance
  have hbnd : f16Bounds 0 ((start (B := Fin 3) f16Initial).locals 0).nextIndex =
      f16Bounds 0 0 := by
    simp [start_locals]
  have hphase : reserveUpdate .awaiting
      { participant := 0
        boundary := f16Bounds 0 0
        before := start f16Initial
        after := (start f16Initial).refuse 0 inv210 (.kernel .guard)
        attempt := some ⟨0, 0, inv210, f16Initial, .error (.kernel .guard)⟩ } =
      .awaiting := by
    simp [reserveUpdate, f16_error_not_ready]
  dsimp [advanceMonitored]
  rw [hadv]
  simp [refuse_attempts, start_attempts, start_locals, start_world, hbnd, hphase]

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f16_monitor_awaiting :
    (continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) f16Schedule).1 = .awaiting := by
  decide +kernel

theorem f16_no_p0_output :
    ((runPrefix f16Cfg f16Bounds f16Initial f16Branches f16Schedule).locals 0).outputs =
      [] := by
  rw [f16_prefix_eq_expected]
  simp [f16Expected, locals3, localFail]

theorem f16_valid_authority_refusal :
    validateCatalog f16Cfg.registry f16Cfg.catalog = true ∧
      hasAuthority f16Store (ids [0]) vaultBound.ctx ⟨210⟩ .invoke = true ∧
      prepareInvocation f16Cfg vaultBound 0 [] inv210 =
        .ok (⟨⟨210⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨210⟩, [], [], ids [0], none⟩) ∧
      executeStep f16Cfg vaultBound 0 [] (.invoke inv210) f16Initial =
        .error (.kernel .guard) ∧
      falseProducer.guard = .lit false :=
  ⟨f16_catalog_valid, f16_producer_invoke_auth, f16_producer_prepare, f16_producer_execute,
    f16_false_guard⟩

/-! ### F17 successful peer lookalike; p0 monitor remains awaiting -/

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f17_peer_execute :
    executeStep f10Cfg vaultBound 0 [] (.invoke inv200) f10Initial =
      .ok f17PeerResult := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f17_same_key_index_value :
    f17PeerResult.outputs = [budgetOut 0] ∧
      (budgetOut 0).step = 0 ∧
      (budgetOut 0).port = name 0 7 ∧
      (budgetOut 0).value = ⟨.amount .usd, 6⟩ ∧
      f17PeerResult.receipt = rec200 := by
  simp [f17PeerResult, sr, budgetOut, name]

/-- Exact producer ownership: the Ready predicate requires participant `0`. The
peer lookalike uses the same key/index/value and succeeds, but is not participant 0.
No impersonation premise is used. -/
theorem f17_peer_not_ready_producer :
    isReadyProducer ⟨1, 0, inv200, f10Initial, .ok f17PeerResult⟩ = false := by
  simp [isReadyProducer, f17PeerResult]

theorem f17_own_producer_is_ready :
    isReadyProducer ⟨0, 0, inv200, f10Initial, .ok f17PeerResult⟩ = true := by
  simp [isReadyProducer, f17PeerResult, sr, inv200, invoke]

theorem f17_peer_advance :
    advance f10Cfg f17Bounds f17Branches (start f10Initial) 1 =
      (start f10Initial).accept 1 inv200 f17PeerResult := by
  have hfail : ((start (B := Fin 3) f10Initial).locals 1).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f10Initial).locals 1).failure.isSome = false := by
    simp [hfail]
  have hsel : (f17Branches 1)[((start (B := Fin 3) f10Initial).locals 1).consumed]? =
      some inv200 := by
    simp [start_locals, f17Branches]
  have hex : executeStep f10Cfg
      (f17Bounds 1 ((start (B := Fin 3) f10Initial).locals 1).nextIndex)
      ((start (B := Fin 3) f10Initial).locals 1).nextIndex
      ((start (B := Fin 3) f10Initial).locals 1).outputs (.invoke inv200)
      (start (B := Fin 3) f10Initial).world = .ok f17PeerResult := by
    simp [start_locals, start_world, f17Bounds]
    exact f17_peer_execute
  simp [advance, his, hsel, hex]

theorem f17_runPrefix :
    runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule =
      (start f10Initial).accept 1 inv200 f17PeerResult := by
  rw [f17Schedule, runPrefix, continueRun_cons, f17_peer_advance, continueRun_nil]

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f17_prefix_eq_expected :
    runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule = f17Expected := by
  apply (machineEq_iff fin3Roster _ _).mp
  decide +kernel

/-- F17 is a one-token prefix, not a complete 2/1/0 schedule. `admit` reports the
p0 count mismatch; the lookalike is the actual `runPrefix`. -/
theorem f17_admit_schedule :
    admit f10Cfg fin3Roster f17Bounds f17Branches f17Schedule =
      .error (.schedule ⟨0, 2, 0⟩) := by
  decide

theorem f17_runNary_refused :
    runNary f10Cfg fin3Roster f17Bounds f10Initial f17Branches f17Schedule =
      .refused (.schedule ⟨0, 2, 0⟩) f10Initial f17Schedule :=
  runNary_admission_refusal _ _ _ _ _ _ _ f17_admit_schedule

theorem f17_prefix_outcome :
    (runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).world = f10Initial ∧
      ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 1).outputs =
        [budgetOut 0] ∧
      ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 1).nextIndex =
        1 ∧
      ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 0).outputs =
        [] ∧
      ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 0).nextIndex =
        0 ∧
      (runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).world.capabilities =
        f10Store := by
  rw [f17_prefix_eq_expected]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [f17Expected, f17After]
  · simp [f17Expected, locals3, localSucc]
  · simp [f17Expected, locals3, localSucc]
  · simp [f17Expected, locals3, emptyLocal]
  · simp [f17Expected, locals3, emptyLocal]
  · simp [f17Expected, f17After, f10Initial, mkWorld_store]

theorem f17_monitored_erases :
    (continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) f17Schedule).2 =
      runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule :=
  continueMonitored_erase _ _ _ _ _ _

theorem f17_first_monitored :
    advanceMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) 1 =
      (.awaiting, (start f10Initial).accept 1 inv200 f17PeerResult) := by
  have hadv := f17_peer_advance
  have hbnd : f17Bounds 1 ((start (B := Fin 3) f10Initial).locals 1).nextIndex =
      f17Bounds 1 0 := by
    simp [start_locals]
  have hphase : reserveUpdate .awaiting
      { participant := 1
        boundary := f17Bounds 1 0
        before := start f10Initial
        after := (start f10Initial).accept 1 inv200 f17PeerResult
        attempt := some ⟨1, 0, inv200, f10Initial, .ok f17PeerResult⟩ } = .awaiting := by
    simp [reserveUpdate, f17_peer_not_ready_producer]
  dsimp [advanceMonitored]
  rw [hadv]
  simp [accept_attempts, start_attempts, start_locals, start_world, hbnd, hphase]

set_option maxHeartbeats 800000 in
-- kernel reduction of executeStep, machineEq, or continueMonitored

theorem f17_monitor_awaiting :
    (continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) f17Schedule).1 = .awaiting := by
  decide +kernel

theorem f17_p0_silent :
    ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 0).outputs =
      [] ∧
      ((runPrefix f10Cfg f17Bounds f10Initial f17Branches f17Schedule).locals 0).nextIndex =
        0 :=
  ⟨f17_prefix_outcome.2.2.2.1, f17_prefix_outcome.2.2.2.2.1⟩

end DefiKernel.Nary.FundedCompanions
