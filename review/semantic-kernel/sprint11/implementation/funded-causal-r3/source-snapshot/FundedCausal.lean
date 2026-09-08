import DefiKernel.Nary.Causal
import DefiKernel.Nary.Examples
import DefiKernel.Nary.FundedEnabledness
import DefiKernel.Nary.LocalOrder
import DefiKernel.Nary.Observation
import DefiKernel.Interface.Accounting

/-! Concrete F10 funded causal instance and F12/F16/F17 companions. Obligations of
`continueMonitored_initialized` are discharged from initialization, own-output provenance,
deposit arithmetic and actual `executeStep` equations. This module does not assume the
desired whole-run `K` as a premise, does not treat the twelve Boolean schedule checks as
the proof, and does not manufacture expected worlds by calling the candidate dispatcher.
Live selected `executeStep = .ok` at an arbitrary current `FundedK` world is transported
from `FundedEnabledness` helpers; it is not a future-success or whole-run hypothesis. -/
namespace DefiKernel.Nary.FundedCausal
open Typed Composition
open DefiKernel.Nary
open DefiKernel.Nary.Examples
open Interface (receiptCellEffect step_receipt_cell)
open DefiKernel.Nary.FundedEnabledness
  (f10_producer_enabled f10_consumer_enabled f10_deposit1_enabled f10_deposit2_enabled)

variable {Q : Type}

def phaseOf : Nat → ReservePhase
  | 0 => .awaiting
  | 1 => .ready6
  | _ => .consumed

def consumedFlag (n0 : Nat) : Nat := if n0 = 2 then 1 else 0

def fundedInv (s : State P A D) : Prop :=
  4 ≤ s.balance vaultC ∧
    0 ≤ s.balance donor1C ∧
    0 ≤ s.balance donor2C ∧
    0 ≤ s.balance recipientC ∧
    s.balance budgetC = 6 ∧
    s.balance sentinelC = 11

def fundedBalances (n0 n1 n2 : Nat) (s : State P A D) : Prop :=
  s.balance vaultC = 10 - 6 * consumedFlag n0 + n1 + 2 * n2 ∧
    s.balance donor1C = 2 - n1 ∧
    s.balance donor2C = 3 - 2 * n2 ∧
    s.balance recipientC = 6 * consumedFlag n0 ∧
    s.balance budgetC = 6 ∧
    s.balance sentinelC = 11

def FundedK (q : ReservePhase) (m : M3) : Prop :=
  Reachable f10Cfg f10Bounds f10Branches f10Initial m ∧
    m.world.capabilities = f10Store ∧
    (m.locals 0).nextIndex ≤ 2 ∧
    (m.locals 1).nextIndex ≤ 1 ∧
    (m.locals 2).nextIndex ≤ 1 ∧
    fundedBalances (m.locals 0).nextIndex (m.locals 1).nextIndex (m.locals 2).nextIndex
      m.world.state ∧
    q = phaseOf (m.locals 0).nextIndex ∧
    ((m.locals 0).nextIndex = 0 → (m.locals 0).outputs = []) ∧
    (1 ≤ (m.locals 0).nextIndex → (m.locals 0).outputs = [budgetOut 0])

def fundedInvariant (_b : Fin 3) (s : State P A D) : Prop := fundedInv s

/-- Transition plus post-state invariant. The post invariant is proved from the actual
receipt, not assumed; peers then rely on that post-state. -/
def fundedGuarantee (b : Fin 3) (pre post : State P A D) : Prop :=
  fundedInv post ∧
    match b with
    | ⟨0, _⟩ =>
      post.balance donor1C = pre.balance donor1C ∧
        post.balance donor2C = pre.balance donor2C ∧
        post.balance budgetC = pre.balance budgetC ∧
        post.balance sentinelC = pre.balance sentinelC ∧
        ((post.balance vaultC = pre.balance vaultC ∧
            post.balance recipientC = pre.balance recipientC) ∨
          (post.balance vaultC = pre.balance vaultC - 6 ∧
            post.balance recipientC = pre.balance recipientC + 6))
    | ⟨1, _⟩ =>
      post.balance vaultC = pre.balance vaultC + 1 ∧
        post.balance donor1C = pre.balance donor1C - 1 ∧
        post.balance donor2C = pre.balance donor2C ∧
        post.balance recipientC = pre.balance recipientC ∧
        post.balance budgetC = pre.balance budgetC ∧
        post.balance sentinelC = pre.balance sentinelC
    | ⟨2, _⟩ =>
      post.balance vaultC = pre.balance vaultC + 2 ∧
        post.balance donor1C = pre.balance donor1C ∧
        post.balance donor2C = pre.balance donor2C - 2 ∧
        post.balance recipientC = pre.balance recipientC ∧
        post.balance budgetC = pre.balance budgetC ∧
        post.balance sentinelC = pre.balance sentinelC

/-- Peers rely on the post-state invariant established by the selected guarantee. -/
def fundedRely (_b : Fin 3) (_pre post : State P A D) : Prop :=
  fundedInv post

def fundedAssumption (b : Fin 3) (q : ReservePhase) (m : M3) : Prop :=
  ((m.locals b).failure = none →
      (m.locals b).nextIndex =
        min (m.locals b).consumed (f10Branches b).length) ∧
    match b with
    | ⟨0, _⟩ =>
      (m.locals 0).nextIndex ≠ 1 ∨
        (q = .ready6 ∧ (m.locals 0).outputs = [budgetOut 0] ∧
          6 ≤ m.world.state.balance vaultC - 4)
    | ⟨1, _⟩ =>
      (m.locals 1).nextIndex = 0 → 1 ≤ m.world.state.balance donor1C
    | ⟨2, _⟩ =>
      (m.locals 2).nextIndex = 0 → 2 ≤ m.world.state.balance donor2C

def fundedExternal (_b : Fin 3) (_q : ReservePhase) (_m : M3) : Prop := True

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem f10_catalog_valid : validateCatalog f10Cfg.registry f10Cfg.catalog = true := by
  decide

theorem f10_initial_balances :
    f10Initial.state.balance vaultC = 10 ∧
      f10Initial.state.balance donor1C = 2 ∧
      f10Initial.state.balance donor2C = 3 ∧
      f10Initial.state.balance recipientC = 0 ∧
      f10Initial.state.balance budgetC = 6 ∧
      f10Initial.state.balance sentinelC = 11 := by
  decide +kernel

theorem f10_initial_inv : fundedInv f10Initial.state := by
  have h := f10_initial_balances
  refine ⟨?_, ?_, ?_, ?_, h.2.2.2.2.1, h.2.2.2.2.2⟩
  · linarith [h.1]
  · linarith [h.2.1]
  · linarith [h.2.2.1]
  · linarith [h.2.2.2.1]

theorem f10_initial_store : f10Initial.capabilities = f10Store := rfl

theorem funded_inv_of_balances {n0 n1 n2 : Nat} {s : State P A D}
    (h0 : n0 ≤ 2) (h1 : n1 ≤ 1) (h2 : n2 ≤ 1)
    (hb : fundedBalances n0 n1 n2 s) : fundedInv s := by
  have hc : consumedFlag n0 = 0 ∨ consumedFlag n0 = 1 := by
    unfold consumedFlag; split <;> simp
  rcases hb with ⟨hv, hd1, hd2, hr, hbgt, hsen⟩
  have n1Q : (n1 : ℚ) ≤ 1 := by exact_mod_cast h1
  have n2Q : (n2 : ℚ) ≤ 1 := by exact_mod_cast h2
  refine ⟨?_, ?_, ?_, ?_, hbgt, hsen⟩
  · rcases hc with hc | hc <;> simp [hc] at hv <;> linarith
  · linarith [n1Q]
  · linarith [n2Q]
  · rcases hc with hc | hc <;> simp [hc] at hr <;> linarith

theorem rec200_effects (cell : C) : receiptCellEffect rec200 cell = 0 := by
  decide +kernel +revert

theorem rec201_effects :
    receiptCellEffect rec201 vaultC = -6 ∧
      receiptCellEffect rec201 recipientC = 6 ∧
      receiptCellEffect rec201 donor1C = 0 ∧
      receiptCellEffect rec201 donor2C = 0 ∧
      receiptCellEffect rec201 budgetC = 0 ∧
      receiptCellEffect rec201 sentinelC = 0 := by
  decide +kernel

theorem rec202_effects :
    receiptCellEffect rec202 vaultC = 1 ∧
      receiptCellEffect rec202 donor1C = -1 ∧
      receiptCellEffect rec202 donor2C = 0 ∧
      receiptCellEffect rec202 recipientC = 0 ∧
      receiptCellEffect rec202 budgetC = 0 ∧
      receiptCellEffect rec202 sentinelC = 0 := by
  decide +kernel

theorem rec203_effects :
    receiptCellEffect rec203 vaultC = 2 ∧
      receiptCellEffect rec203 donor1C = 0 ∧
      receiptCellEffect rec203 donor2C = -2 ∧
      receiptCellEffect rec203 recipientC = 0 ∧
      receiptCellEffect rec203 budgetC = 0 ∧
      receiptCellEffect rec203 sentinelC = 0 := by
  decide +kernel

theorem f10_producer_receipt {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv200) pre = .ok result) :
    result.receipt = rec200 := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv200 =
        .ok (⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨200⟩, [], [], ids [0], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    have he : extractReceipt f10Cfg boundary ⟨⟨200⟩, [], [], ids [0], none⟩ pre =
        .ok (evaluated true [] [] []) := by
      rfl
    rw [he] at extracted
    cases extracted
    rfl

theorem f10_consumer_deltas {boundary : Boundary P A D} {pre : W}
    {result : StepResult P A D}
    (h : executeStep f10Cfg boundary 1 [budgetOut 0] (.invoke inv201) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(vaultC, -6), (recipientC, 6)] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary 1 [budgetOut 0] inv201 =
        .ok (⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩,
          ⟨⟨201⟩, [], [⟨.amount .usd, 6⟩], ids [1, 2], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    have ht : f10Cfg.registry ⟨201⟩ = some (consumerTransfer .recipient) := rfl
    have hargs : Args.check (consumerTransfer .recipient).signature [⟨.amount .usd, 6⟩] =
        .ok (.cons (6 : ℚ) .nil) := by
      simp [Args.check, consumerTransfer]
    simp [extractReceipt, ht, hargs, bind, Except.bind, Except.mapError] at extracted
    cases hev : (consumerTransfer .recipient).evaluate
        ⟨pre.state, boundary.env, boundary.ctx.principal, [], .cons (6 : ℚ) .nil, boundary.now⟩ with
    | error _ => simp [hev] at extracted
    | ok e' =>
      have heq : e' = e := by simpa [hev] using extracted
      refine ⟨_, e, rfl, ?_⟩
      have hev' :
          (consumerTransfer .recipient).evaluate
            ⟨pre.state, boundary.env, boundary.ctx.principal, [], .cons (6 : ℚ) .nil,
              boundary.now⟩ = .ok e := heq ▸ hev
      simp [Template.evaluate, consumerTransfer, resolveRefs, packed, cellRef, bind,
        Except.bind, pure, Except.pure, usdArg, litAmt] at hev'
      cases hev'
      rfl

theorem constTransfer_deltas (src dst : P) (q : ℚ)
    (ctx : EvalContext P A D []) (e : Evaluated P A D)
    (h : (constTransfer src dst q).evaluate ctx = .ok e) :
    e.deltas = [((.home, src, .usd), -q), ((.home, dst, .usd), q)] := by
  simp [Template.evaluate, constTransfer, resolveRefs, packed, cellRef, bind, Except.bind,
    pure, Except.pure, litAmt, negAmt] at h
  cases h
  rfl

theorem f10_deposit1_deltas {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(donor1C, -1), (vaultC, 1)] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv202 =
        .ok (⟨⟨202⟩, [], []⟩, ⟨⟨202⟩, [], [], ids [3, 4], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    have ht : f10Cfg.registry ⟨202⟩ = some (constTransfer .donor1 .vault 1) := rfl
    have hargs : Args.check (constTransfer .donor1 .vault 1).signature [] = .ok .nil := rfl
    simp [extractReceipt, ht, hargs, bind, Except.bind, Except.mapError] at extracted
    cases hev : (constTransfer .donor1 .vault 1).evaluate
        ⟨pre.state, boundary.env, boundary.ctx.principal, [], .nil, boundary.now⟩ with
    | error _ => simp [hev] at extracted
    | ok e' =>
      have heq : e' = e := by simpa [hev] using extracted
      exact ⟨_, e, rfl, constTransfer_deltas _ _ _ _ _ (heq ▸ hev)⟩

theorem f10_deposit2_deltas {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result) :
    ∃ request e, result.receipt = .invoked request e ∧
      e.deltas = [(donor2C, -2), (vaultC, 2)] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv203 =
        .ok (⟨⟨203⟩, [], []⟩, ⟨⟨203⟩, [], [], ids [5, 6], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    have ht : f10Cfg.registry ⟨203⟩ = some (constTransfer .donor2 .vault 2) := rfl
    have hargs : Args.check (constTransfer .donor2 .vault 2).signature [] = .ok .nil := rfl
    simp [extractReceipt, ht, hargs, bind, Except.bind, Except.mapError] at extracted
    cases hev : (constTransfer .donor2 .vault 2).evaluate
        ⟨pre.state, boundary.env, boundary.ctx.principal, [], .nil, boundary.now⟩ with
    | error _ => simp [hev] at extracted
    | ok e' =>
      have heq : e' = e := by simpa [hev] using extracted
      exact ⟨_, e, rfl, constTransfer_deltas _ _ _ _ _ (heq ▸ hev)⟩

theorem two_delta_cell (request : Request P A D) (e : Evaluated P A D)
    (c1 c2 : C) (a1 a2 : ℚ) (h : e.deltas = [(c1, a1), (c2, a2)]) (cell : C) :
    receiptCellEffect (.invoked request e) cell =
      (if c1 = cell then a1 else 0) + (if c2 = cell then a2 else 0) := by
  simp [receiptCellEffect, h]

theorem f10_start_K : FundedK .awaiting (start f10Initial) := by
  have hb := f10_initial_balances
  refine ⟨.start, rfl, by simp [start_locals], by simp [start_locals],
    by simp [start_locals], ?_, rfl, ?_, ?_⟩
  · simp [fundedBalances, start_world, consumedFlag, start_locals, hb]
  · intro h0
    simp [start_locals]
  · intro h0
    simp [start_locals] at h0

theorem f10_inv_derivation : InvariantDerivation (Q := ReservePhase) (B := Fin 3)
    FundedK fundedInvariant := by
  intro q m hk b
  exact funded_inv_of_balances hk.2.2.1 hk.2.2.2.1 hk.2.2.2.2.1 hk.2.2.2.2.2.1

theorem f10_present_external : PresentExternal (Q := ReservePhase) (B := Fin 3)
    FundedK fundedExternal := by
  intro _ _ _ _; exact trivial

theorem f10_assumption_derivation : AssumptionDerivation (Q := ReservePhase) (B := Fin 3)
    FundedK fundedAssumption fundedExternal := by
  intro q m b hk _
  have n0 := hk.2.2.1
  have n1 := hk.2.2.2.1
  have n2 := hk.2.2.2.2.1
  have hb := hk.2.2.2.2.2.1
  have hq := hk.2.2.2.2.2.2.1
  refine ⟨fun hf => hk.1.active_index b hf, ?_⟩
  match b with
  | ⟨0, _⟩ =>
    have hn : (m.locals 0).nextIndex = 0 ∨ (m.locals 0).nextIndex = 1 ∨
        (m.locals 0).nextIndex = 2 := by omega
    rcases hn with h | h | h
    · exact Or.inl (by omega)
    · refine Or.inr ⟨?_, ?_, ?_⟩
      · simpa [hq, h, phaseOf]
      · exact hk.2.2.2.2.2.2.2.2 (by omega)
      · have hv := hb.1
        simp [h, consumedFlag] at hv
        linarith [n1, n2]
    · exact Or.inl (by omega)
  | ⟨1, _⟩ =>
    intro hn0
    have hd1 := hb.2.1
    rw [hn0] at hd1
    simp at hd1
    change 1 ≤ m.world.state.balance donor1C
    linarith [hd1]
  | ⟨2, _⟩ =>
    intro hn0
    have hd2 := hb.2.2.1
    rw [hn0] at hd2
    simp at hd2
    change 2 ≤ m.world.state.balance donor2C
    linarith [hd2]

theorem f10_cross : GuaranteeInclusion (B := Fin 3) fundedGuarantee fundedRely := by
  intro b peer _ pre post hg
  exact hg.1

theorem f10_stable : RelyStable (B := Fin 3) fundedInvariant fundedRely := by
  intro b pre post _ hr
  exact hr

theorem skip_nextIndex (m : M3) (b own : Fin 3) :
    ((m.skip b).locals own).nextIndex = (m.locals own).nextIndex := by
  by_cases h : own = b
  · subst own
    simp [skip_selected]
  · rw [skip_away m b own h]

theorem skip_outputs (m : M3) (b own : Fin 3) :
    ((m.skip b).locals own).outputs = (m.locals own).outputs := by
  by_cases h : own = b
  · subst own
    simp [skip_selected]
  · rw [skip_away m b own h]

theorem f10_skip_update : SkipUpdateObligation (Q := ReservePhase)
    f10Cfg f10Bounds f10Branches reserveUpdate FundedK := by
  intro q m b hskip hk
  have step : AdvanceSound f10Cfg f10Bounds f10Branches m b (m.skip b) := by
    rcases hskip with hf | ⟨hnone, habs⟩
    · cases hfail : (m.locals b).failure with
      | none => simp [hfail] at hf
      | some failure => exact .halted failure hfail
    · exact .exhausted hnone habs
  refine ⟨.next b hk.1 step, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa [skip_world] using hk.2.1
  · simpa [skip_nextIndex] using hk.2.2.1
  · simpa [skip_nextIndex] using hk.2.2.2.1
  · simpa [skip_nextIndex] using hk.2.2.2.2.1
  · simpa [skip_world, skip_nextIndex] using hk.2.2.2.2.2.1
  · simp [reserveUpdate]
    simpa [skip_nextIndex] using hk.2.2.2.2.2.2.1
  · intro h0
    have h0' : (m.locals 0).nextIndex = 0 := by simpa [skip_nextIndex] using h0
    simpa [skip_outputs] using hk.2.2.2.2.2.2.2.1 h0'
  · intro h0
    have h0' : 1 ≤ (m.locals 0).nextIndex := by simpa [skip_nextIndex] using h0
    simpa [skip_outputs] using hk.2.2.2.2.2.2.2.2 h0'

theorem f10_branches_zero : f10Branches (0 : Fin 3) = [inv200, inv201] := by
  simp [f10Branches]

theorem f10_branches_one : f10Branches (1 : Fin 3) = [inv202] := by
  simp [f10Branches]

theorem f10_branches_two : f10Branches (2 : Fin 3) = [inv203] := by
  simp [f10Branches]

theorem f10_bounds_zero (n : Nat) : f10Bounds (0 : Fin 3) n = vaultBound := by
  simp [f10Bounds]

theorem f10_bounds_one (n : Nat) : f10Bounds (1 : Fin 3) n = donor1Bound := by
  simp [f10Bounds]

theorem f10_bounds_two (n : Nat) : f10Bounds (2 : Fin 3) n = donor2Bound := by
  simp [f10Bounds]

theorem vaultC_ne_recipientC : vaultC ≠ recipientC := by decide
theorem vaultC_ne_donor1C : vaultC ≠ donor1C := by decide
theorem vaultC_ne_donor2C : vaultC ≠ donor2C := by decide
theorem vaultC_ne_budgetC : vaultC ≠ budgetC := by decide
theorem vaultC_ne_sentinelC : vaultC ≠ sentinelC := by decide
theorem donor1C_ne_donor2C : donor1C ≠ donor2C := by decide
theorem donor1C_ne_recipientC : donor1C ≠ recipientC := by decide
theorem donor1C_ne_budgetC : donor1C ≠ budgetC := by decide
theorem donor1C_ne_sentinelC : donor1C ≠ sentinelC := by decide
theorem donor2C_ne_recipientC : donor2C ≠ recipientC := by decide
theorem donor2C_ne_budgetC : donor2C ≠ budgetC := by decide
theorem donor2C_ne_sentinelC : donor2C ≠ sentinelC := by decide
theorem recipientC_ne_budgetC : recipientC ≠ budgetC := by decide
theorem recipientC_ne_sentinelC : recipientC ≠ sentinelC := by decide
theorem budgetC_ne_sentinelC : budgetC ≠ sentinelC := by decide

theorem f10_invoke_capabilities {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : W}
    {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv) pre = .ok result) :
    result.world.capabilities = pre.capabilities :=
  StepSound.invoke_preserves_capabilities (executeStep_sound _ _ _ _ _ _ _ h)

theorem f10_identity_cell {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv200) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell = pre.state.balance cell := by
  have hr := f10_producer_receipt h
  have he := rec200_effects cell
  rw [step_receipt_cell h, hr, he, add_zero]

theorem f10_two_delta_balances {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : W}
    {result : StepResult P A D} {request : Request P A D} {e : Evaluated P A D}
    {c1 c2 : C} {a1 a2 : ℚ}
    (h : executeStep f10Cfg boundary index history (.invoke inv) pre = .ok result)
    (hr : result.receipt = .invoked request e) (hd : e.deltas = [(c1, a1), (c2, a2)])
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if c1 = cell then a1 else 0) + (if c2 = cell then a2 else 0)) := by
  rw [step_receipt_cell h, hr, two_delta_cell request e c1 c2 a1 a2 hd]

theorem f10_consumer_cell {boundary : Boundary P A D} {pre : W}
    {result : StepResult P A D}
    (h : executeStep f10Cfg boundary 1 [budgetOut 0] (.invoke inv201) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if vaultC = cell then (-6 : ℚ) else 0) +
          (if recipientC = cell then (6 : ℚ) else 0)) := by
  obtain ⟨request, e, hr, hd⟩ := f10_consumer_deltas h
  exact f10_two_delta_balances h hr hd cell

theorem f10_deposit1_cell {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if donor1C = cell then (-1 : ℚ) else 0) +
          (if vaultC = cell then (1 : ℚ) else 0)) := by
  obtain ⟨request, e, hr, hd⟩ := f10_deposit1_deltas h
  exact f10_two_delta_balances h hr hd cell

theorem f10_deposit2_cell {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result)
    (cell : C) :
    result.world.state.balance cell =
      pre.state.balance cell +
        ((if donor2C = cell then (-2 : ℚ) else 0) +
          (if vaultC = cell then (2 : ℚ) else 0)) := by
  obtain ⟨request, e, hr, hd⟩ := f10_deposit2_deltas h
  exact f10_two_delta_balances h hr hd cell

theorem two_cell_update {pre post : State P A D} {c1 c2 : C} {a1 a2 : ℚ}
    (h : ∀ cell, post.balance cell =
      pre.balance cell + ((if c1 = cell then a1 else 0) + (if c2 = cell then a2 else 0)))
    (hne : c1 ≠ c2) :
    post.balance c1 = pre.balance c1 + a1 ∧
      post.balance c2 = pre.balance c2 + a2 ∧
      ∀ cell, cell ≠ c1 → cell ≠ c2 → post.balance cell = pre.balance cell := by
  refine ⟨?_, ?_, ?_⟩
  · have hx := h c1
    rw [if_pos rfl, if_neg hne.symm] at hx
    simpa using hx
  · have hx := h c2
    rw [if_neg hne, if_pos rfl] at hx
    simpa using hx
  · intro cell h1 h2
    have hx := h cell
    rw [if_neg h1.symm, if_neg h2.symm] at hx
    simpa using hx

theorem fin3_cases (b : Fin 3) : b = 0 ∨ b = 1 ∨ b = 2 := by
  match b with
  | ⟨0, _⟩ => exact Or.inl (Fin.ext rfl)
  | ⟨1, _⟩ => exact Or.inr (Or.inl (Fin.ext rfl))
  | ⟨2, _⟩ => exact Or.inr (Or.inr (Fin.ext rfl))

theorem f10_producer_outputs {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv200) pre = .ok result)
    (hidx : index = 0) (hbud : pre.state.balance budgetC = 6) :
    result.outputs = [budgetOut 0] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv200 =
        .ok (⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩, ⟨⟨200⟩, [], [], ids [0], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    subst hidx
    have he : extractReceipt f10Cfg boundary ⟨⟨200⟩, [], [], ids [0], none⟩ pre =
        .ok (evaluated true [] [] []) := by
      rfl
    rw [he] at extracted
    cases extracted
    have hpost := (applyEvaluated_ok_iff _ _ _ _ _ _).mp applied
    have hbal : post.state.balance budgetC = 6 := by
      have hx := hpost.2.2 budgetC
      simpa [Evaluated.effect, evaluated, hbud] using hx
    change snapshots 0 inv200.component ⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩ post.state = [budgetOut 0]
    simp [snapshots, inv200, invoke, budgetOut, name]
    exact ⟨rfl, hbal⟩

theorem f10_consumer_outputs {boundary : Boundary P A D} {pre : W}
    {result : StepResult P A D}
    (h : executeStep f10Cfg boundary 1 [budgetOut 0] (.invoke inv201) pre = .ok result) :
    result.outputs = [] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary 1 [budgetOut 0] inv201 =
        .ok (⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩,
          ⟨⟨201⟩, [], [⟨.amount .usd, 6⟩], ids [1, 2], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    rfl

theorem f10_deposit1_outputs {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv202) pre = .ok result) :
    result.outputs = [] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv202 =
        .ok (⟨⟨202⟩, [], []⟩, ⟨⟨202⟩, [], [], ids [3, 4], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    rfl

theorem f10_deposit2_outputs {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : StepResult P A D}
    (h : executeStep f10Cfg boundary index history (.invoke inv203) pre = .ok result) :
    result.outputs = [] := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary index history inv203 =
        .ok (⟨⟨203⟩, [], []⟩, ⟨⟨203⟩, [], [], ids [5, 6], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    rfl

theorem f10_selected_cases {m : M3} {b : Fin 3} {inv : Invocation P A D}
    (hord : (m.locals b).nextIndex = min (m.locals b).consumed (f10Branches b).length)
    (hs : (f10Branches b)[(m.locals b).consumed]? = some inv) :
    (m.locals b).nextIndex = (m.locals b).consumed ∧
      ((b = 0 ∧ ((m.locals 0).nextIndex = 0 ∧ inv = inv200 ∨
          (m.locals 0).nextIndex = 1 ∧ inv = inv201)) ∨
        (b = 1 ∧ (m.locals 1).nextIndex = 0 ∧ inv = inv202) ∨
        (b = 2 ∧ (m.locals 2).nextIndex = 0 ∧ inv = inv203)) := by
  have hidx := nextIndex_eq_consumed_of_selected f10Branches m b inv hord hs
  refine ⟨hidx, ?_⟩
  have hlt : (m.locals b).consumed < (f10Branches b).length :=
    (List.getElem?_eq_some_iff.mp hs).1
  rcases fin3_cases b with hb | hb | hb
  · subst b
    have hlen : (f10Branches (0 : Fin 3)).length = 2 := by simp [f10Branches]
    have hc : (m.locals 0).consumed = 0 ∨ (m.locals 0).consumed = 1 := by
      omega
    refine Or.inl ⟨rfl, ?_⟩
    rw [hidx]
    rcases hc with hc | hc
    · have : (f10Branches (0 : Fin 3))[(m.locals 0).consumed]? = some inv200 := by
        simp [f10Branches, hc]
      simp [this] at hs
      exact Or.inl ⟨hc, hs.symm⟩
    · have : (f10Branches (0 : Fin 3))[(m.locals 0).consumed]? = some inv201 := by
        simp [f10Branches, hc]
      simp [this] at hs
      exact Or.inr ⟨hc, hs.symm⟩
  · subst b
    have hlen : (f10Branches (1 : Fin 3)).length = 1 := by simp [f10Branches]
    have hc : (m.locals 1).consumed = 0 := by omega
    refine Or.inr (Or.inl ⟨rfl, ?_⟩)
    rw [hidx]
    have : (f10Branches (1 : Fin 3))[(m.locals 1).consumed]? = some inv202 := by
      simp [f10Branches, hc]
    simp [this] at hs
    exact ⟨hc, hs.symm⟩
  · subst b
    have hlen : (f10Branches (2 : Fin 3)).length = 1 := by simp [f10Branches]
    have hc : (m.locals 2).consumed = 0 := by omega
    refine Or.inr (Or.inr ⟨rfl, ?_⟩)
    rw [hidx]
    have : (f10Branches (2 : Fin 3))[(m.locals 2).consumed]? = some inv203 := by
      simp [f10Branches, hc]
    simp [this] at hs
    exact ⟨hc, hs.symm⟩

theorem f10_selected_success : SelectedSuccessGuarantee (Q := ReservePhase)
    f10Cfg f10Bounds f10Branches fundedInvariant fundedGuarantee fundedAssumption := by
  intro b q m inv result hf hs hok hI hA
  have hsel := f10_selected_cases (hA.1 hf) hs
  have hidx := hsel.1
  rcases hsel.2 with ⟨hb0, hop⟩ | ⟨hb1, hn1, hinv1⟩ | ⟨hb2, hn2, hinv2⟩
  · subst hb0
    rcases hop with ⟨hn0, hinv0⟩ | ⟨hn0, hinv0⟩
    · subst hinv0
      have hcell := f10_identity_cell hok
      have hpost : fundedInv result.world.state := by
        rcases hI with ⟨hv, hd1, hd2, hr, hb, hs⟩
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
        · simpa [hcell] using hv
        · simpa [hcell] using hd1
        · simpa [hcell] using hd2
        · simpa [hcell] using hr
        · simpa [hcell] using hb
        · simpa [hcell] using hs
      refine ⟨hpost, hpost, ?_⟩
      simp [fundedGuarantee]
      refine ⟨hcell donor1C, hcell donor2C, hcell budgetC, hcell sentinelC, Or.inl ⟨?_, ?_⟩⟩
      · exact hcell vaultC
      · exact hcell recipientC
    · subst hinv0
      have hout : (m.locals 0).outputs = [budgetOut 0] := by
        have ha := hA.2
        simp at ha
        rcases ha with hne | ⟨_, ho, _⟩
        · exact (hne hn0).elim
        · exact ho
      have hvault : 6 ≤ m.world.state.balance vaultC - 4 := by
        have ha := hA.2
        simp at ha
        rcases ha with hne | ⟨_, _, hv⟩
        · exact (hne hn0).elim
        · exact hv
      have hstep : executeStep f10Cfg (f10Bounds (0 : Fin 3) 1) 1 [budgetOut 0]
          (.invoke inv201) m.world = .ok result := by
        simpa [hn0, hout] using hok
      have hu := two_cell_update (f10_consumer_cell hstep) vaultC_ne_recipientC
      have hpost : fundedInv result.world.state := by
        rcases hI with ⟨hv, hd1, hd2, hr, hb, hsen⟩
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
        · linarith [hu.1, hvault]
        · simpa [hu.2.2 donor1C (by decide) (by decide)] using hd1
        · simpa [hu.2.2 donor2C (by decide) (by decide)] using hd2
        · linarith [hu.2.1]
        · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb
        · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hsen
      refine ⟨hpost, hpost, hu.2.2 donor1C (by decide) (by decide),
        hu.2.2 donor2C (by decide) (by decide),
        hu.2.2 budgetC (by decide) (by decide),
        hu.2.2 sentinelC (by decide) (by decide),
        Or.inr ⟨by linarith [hu.1], hu.2.1⟩⟩
  · subst hb1
    subst hinv1
    have hfund : 1 ≤ m.world.state.balance donor1C := (by
      have ha := hA.2
      simp at ha
      exact ha hn1)
    have hu := two_cell_update (f10_deposit1_cell hok) vaultC_ne_donor1C.symm
    have hpost : fundedInv result.world.state := by
      rcases hI with ⟨hv, hd1, hd2, hr, hb, hsen⟩
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
      · linarith [hu.2.1]
      · linarith [hu.1, hfund]
      · simpa [hu.2.2 donor2C (by decide) (by decide)] using hd2
      · simpa [hu.2.2 recipientC (by decide) (by decide)] using hr
      · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb
      · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hsen
    exact ⟨hpost, hpost, hu.2.1, by linarith [hu.1],
      hu.2.2 donor2C (by decide) (by decide),
      hu.2.2 recipientC (by decide) (by decide),
      hu.2.2 budgetC (by decide) (by decide),
      hu.2.2 sentinelC (by decide) (by decide)⟩
  · subst hb2
    subst hinv2
    have hfund : 2 ≤ m.world.state.balance donor2C := (by
      have ha := hA.2
      simp at ha
      exact ha hn2)
    have hu := two_cell_update (f10_deposit2_cell hok) vaultC_ne_donor2C.symm
    have hpost : fundedInv result.world.state := by
      rcases hI with ⟨hv, hd1, hd2, hr, hb, hsen⟩
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
      · linarith [hu.2.1]
      · simpa [hu.2.2 donor1C (by decide) (by decide)] using hd1
      · linarith [hu.1, hfund]
      · simpa [hu.2.2 recipientC (by decide) (by decide)] using hr
      · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb
      · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hsen
    exact ⟨hpost, hpost, hu.2.1, hu.2.2 donor1C (by decide) (by decide), by linarith [hu.1],
      hu.2.2 recipientC (by decide) (by decide),
      hu.2.2 budgetC (by decide) (by decide),
      hu.2.2 sentinelC (by decide) (by decide)⟩

theorem refuse_nextIndex (m : M3) (b own : Fin 3) (inv : Invocation P A D)
    (reason : Composition.Failure) :
    ((m.refuse b inv reason).locals own).nextIndex = (m.locals own).nextIndex := by
  by_cases h : own = b
  · subst own
    simp [refuse_selected]
  · rw [refuse_away m b own inv reason h]

theorem refuse_outputs (m : M3) (b own : Fin 3) (inv : Invocation P A D)
    (reason : Composition.Failure) :
    ((m.refuse b inv reason).locals own).outputs = (m.locals own).outputs := by
  by_cases h : own = b
  · subst own
    simp [refuse_selected]
  · rw [refuse_away m b own inv reason h]

theorem error_not_ready (b : Fin 3) (index : Nat) (inv : Invocation P A D) (w : W)
    (reason : Composition.Failure) :
    isReadyProducer ⟨b, index, inv, w, .error reason⟩ = false := by
  simp [isReadyProducer]

theorem error_not_consumed (b : Fin 3) (index : Nat) (inv : Invocation P A D) (w : W)
    (reason : Composition.Failure) :
    isConsumedConsumer ⟨b, index, inv, w, .error reason⟩ = false := by
  simp [isConsumedConsumer]

theorem f10_refusal_update : RefusalUpdateObligation (Q := ReservePhase)
    f10Cfg f10Bounds f10Branches reserveUpdate FundedK := by
  intro q m b inv reason hf hs herr hk
  have step : AdvanceSound f10Cfg f10Bounds f10Branches m b (m.refuse b inv reason) :=
    .refused inv reason hf hs herr
  refine ⟨.next b hk.1 step, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa [refuse_world] using hk.2.1
  · simpa [refuse_nextIndex] using hk.2.2.1
  · simpa [refuse_nextIndex] using hk.2.2.2.1
  · simpa [refuse_nextIndex] using hk.2.2.2.2.1
  · simpa [refuse_world, refuse_nextIndex] using hk.2.2.2.2.2.1
  · have hphase :
        reserveUpdate q
          { participant := b, boundary := f10Bounds b (m.locals b).nextIndex, before := m,
            after := m.refuse b inv reason,
            attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩ } = q := by
      simp [reserveUpdate, error_not_ready, error_not_consumed]
      cases q <;> rfl
    rw [hphase]
    simpa [refuse_nextIndex] using hk.2.2.2.2.2.2.1
  · intro h0
    have h0' : (m.locals 0).nextIndex = 0 := by simpa [refuse_nextIndex] using h0
    simpa [refuse_outputs] using hk.2.2.2.2.2.2.2.1 h0'
  · intro h0
    have h0' : 1 ≤ (m.locals 0).nextIndex := by simpa [refuse_nextIndex] using h0
    simpa [refuse_outputs] using hk.2.2.2.2.2.2.2.2 h0'

theorem f10_consumer_receipt {boundary : Boundary P A D} {pre : W}
    {result : StepResult P A D}
    (h : executeStep f10Cfg boundary 1 [budgetOut 0] (.invoke inv201) pre = .ok result) :
    result.receipt = rec201 := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f10Cfg boundary 1 [budgetOut 0] inv201 =
        .ok (⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩,
          ⟨⟨201⟩, [], [⟨.amount .usd, 6⟩], ids [1, 2], none⟩) := by
      rfl
    rw [hp] at prepared
    cases prepared
    have ht : f10Cfg.registry ⟨201⟩ = some (consumerTransfer .recipient) := rfl
    have hargs : Args.check (consumerTransfer .recipient).signature [⟨.amount .usd, 6⟩] =
        .ok (.cons (6 : ℚ) .nil) := by
      simp [Args.check, consumerTransfer]
    simp [extractReceipt, ht, hargs, bind, Except.bind, Except.mapError] at extracted
    cases hev : (consumerTransfer .recipient).evaluate
        ⟨pre.state, boundary.env, boundary.ctx.principal, [], .cons (6 : ℚ) .nil, boundary.now⟩ with
    | error _ => simp [hev] at extracted
    | ok e' =>
      have heq : e' = e := by simpa [hev] using extracted
      have hvalid := (applyEvaluated_ok_iff _ _ _ _ _ _).mp applied
      have hguard : e.guard = true := hvalid.1.1
      have hev' :
          (consumerTransfer .recipient).evaluate
            ⟨pre.state, boundary.env, boundary.ctx.principal, [], .cons (6 : ℚ) .nil,
              boundary.now⟩ = .ok e := heq ▸ hev
      simp [Template.evaluate, consumerTransfer, resolveRefs, packed, cellRef, bind,
        Except.bind, pure, Except.pure, usdArg] at hev'
      cases hev'
      simp only [rec201, recConsumer, evaluated]
      rw [← hguard]
      rfl

theorem accept_nextIndex_sel (m : M3) (b : Fin 3) (inv : Invocation P A D)
    (result : StepResult P A D) :
    ((m.accept b inv result).locals b).nextIndex = (m.locals b).nextIndex + 1 := by
  simp [accept_selected]

theorem accept_nextIndex_away (m : M3) (b own : Fin 3) (inv : Invocation P A D)
    (result : StepResult P A D) (h : own ≠ b) :
    ((m.accept b inv result).locals own).nextIndex = (m.locals own).nextIndex := by
  rw [accept_away m b own inv result h]

theorem accept_outputs_sel (m : M3) (b : Fin 3) (inv : Invocation P A D)
    (result : StepResult P A D) :
    ((m.accept b inv result).locals b).outputs = (m.locals b).outputs ++ result.outputs := by
  simp [accept_selected]

theorem accept_outputs_away (m : M3) (b own : Fin 3) (inv : Invocation P A D)
    (result : StepResult P A D) (h : own ≠ b) :
    ((m.accept b inv result).locals own).outputs = (m.locals own).outputs := by
  rw [accept_away m b own inv result h]

theorem f10_ready_attempt {w : W} {result : StepResult P A D}
    (hrec : result.receipt = rec200) (houts : result.outputs = [budgetOut 0]) :
    isReadyProducer ⟨0, 0, inv200, w, .ok result⟩ = true := by
  simp [isReadyProducer, hrec, houts, inv200, invoke]

theorem f10_consumed_attempt {w : W} {result : StepResult P A D}
    (hrec : result.receipt = rec201) :
    isConsumedConsumer ⟨0, 1, inv201, w, .ok result⟩ = true := by
  simp [isConsumedConsumer, hrec, inv201, invoke]

theorem f10_not_ready_peer {b : Fin 3} {index : Nat} {inv : Invocation P A D}
    {w : W} {result : StepResult P A D} (hb : b ≠ 0) :
    isReadyProducer ⟨b, index, inv, w, .ok result⟩ = false := by
  simp [isReadyProducer, hb]

theorem f10_not_consumed_peer {b : Fin 3} {index : Nat} {inv : Invocation P A D}
    {w : W} {result : StepResult P A D} (hb : b ≠ 0) :
    isConsumedConsumer ⟨b, index, inv, w, .ok result⟩ = false := by
  simp [isConsumedConsumer, hb]

theorem f10_success_update : SuccessUpdateObligation (Q := ReservePhase)
    f10Cfg f10Bounds f10Branches reserveUpdate FundedK fundedInvariant
    fundedGuarantee fundedAssumption := by
  intro q m b inv result hf hs hok hk hA hg hinvs
  have hsel := f10_selected_cases (hA.1 hf) hs
  have step : AdvanceSound f10Cfg f10Bounds f10Branches m b (m.accept b inv result) :=
    .accepted inv result hf hs hok
  have hstore : (m.accept b inv result).world.capabilities = f10Store := by
    rw [accept_world, f10_invoke_capabilities hok, hk.2.1]
  have hb := hk.2.2.2.2.2.1
  have hq := hk.2.2.2.2.2.2.1
  have hout0 := hk.2.2.2.2.2.2.2.1
  have hout1 := hk.2.2.2.2.2.2.2.2
  rcases hsel.2 with ⟨hb0, hop⟩ | ⟨hb1, hn1, hinv1⟩ | ⟨hb2, hn2, hinv2⟩
  · subst hb0
    rcases hop with ⟨hn0, hinv0⟩ | ⟨hn0, hinv0⟩
    · subst hinv0
      have houts := f10_producer_outputs hok (by rw [hn0]) hb.2.2.2.2.1
      have hrec := f10_producer_receipt hok
      have hn0' : ((m.accept 0 inv200 result).locals 0).nextIndex = 1 := by
        simp [accept_selected, hn0]
      have hn1' : ((m.accept 0 inv200 result).locals 1).nextIndex = (m.locals 1).nextIndex :=
        accept_nextIndex_away m 0 1 inv200 result (by decide)
      have hn2' : ((m.accept 0 inv200 result).locals 2).nextIndex = (m.locals 2).nextIndex :=
        accept_nextIndex_away m 0 2 inv200 result (by decide)
      have hcell := f10_identity_cell hok
      refine ⟨.next 0 hk.1 step, hstore, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · omega
      · simpa [hn1'] using hk.2.2.2.1
      · simpa [hn2'] using hk.2.2.2.2.1
      · simp [fundedBalances, accept_world, hn0', hn1', hn2', consumedFlag, hcell]
        simpa [fundedBalances, hn0, consumedFlag] using hb
      · have hready := f10_ready_attempt (w := m.world) hrec houts
        have hready' :
            isReadyProducer ⟨0, (m.locals 0).nextIndex, inv200, m.world, .ok result⟩ = true := by
          simpa [hn0] using hready
        have hq0 : q = .awaiting := by simpa [hn0, phaseOf] using hq
        simp [reserveUpdate, hready', hq0, hn0', phaseOf]
      · intro hcontra
        simp [hn0'] at hcontra
      · intro _
        simp [accept_outputs_sel, hout0 hn0, houts]
    · subst hinv0
      have hout : (m.locals 0).outputs = [budgetOut 0] := by
        have ha := hA.2
        simp at ha
        rcases ha with hne | ⟨_, ho, _⟩
        · exact (hne hn0).elim
        · exact ho
      have hstep : executeStep f10Cfg (f10Bounds (0 : Fin 3) 1) 1 [budgetOut 0]
          (.invoke inv201) m.world = .ok result := by
        simpa [hn0, hout] using hok
      have houts := f10_consumer_outputs hstep
      have hrec := f10_consumer_receipt hstep
      have hn0' : ((m.accept 0 inv201 result).locals 0).nextIndex = 2 := by
        simp [accept_selected, hn0]
      have hn1' : ((m.accept 0 inv201 result).locals 1).nextIndex = (m.locals 1).nextIndex :=
        accept_nextIndex_away m 0 1 inv201 result (by decide)
      have hn2' : ((m.accept 0 inv201 result).locals 2).nextIndex = (m.locals 2).nextIndex :=
        accept_nextIndex_away m 0 2 inv201 result (by decide)
      have hu := two_cell_update (f10_consumer_cell hstep) vaultC_ne_recipientC
      refine ⟨.next 0 hk.1 step, hstore, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · omega
      · simpa [hn1'] using hk.2.2.2.1
      · simpa [hn2'] using hk.2.2.2.2.1
      · simp [fundedBalances, accept_world, hn0', hn1', hn2', consumedFlag]
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
        · have hv := hb.1
          simp [hn0, consumedFlag] at hv
          linarith [hu.1]
        · simpa [hu.2.2 donor1C (by decide) (by decide)] using hb.2.1
        · simpa [hu.2.2 donor2C (by decide) (by decide)] using hb.2.2.1
        · have hr := hb.2.2.2.1
          simp [hn0, consumedFlag] at hr
          linarith [hu.2.1]
        · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb.2.2.2.2.1
        · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hb.2.2.2.2.2
      · have hcons := f10_consumed_attempt (w := m.world) hrec
        have hcons' :
            isConsumedConsumer ⟨0, (m.locals 0).nextIndex, inv201, m.world, .ok result⟩ = true := by
          simpa [hn0] using hcons
        have hq1 : q = .ready6 := by simpa [hn0, phaseOf] using hq
        simp [reserveUpdate, hcons', hq1, hn0', phaseOf]
      · intro hcontra
        simp [hn0'] at hcontra
      · intro _
        simp [accept_outputs_sel, hout, houts]
  · subst hb1
    subst hinv1
    have houts := f10_deposit1_outputs hok
    have hn1' : ((m.accept 1 inv202 result).locals 1).nextIndex = 1 := by
      simp [accept_selected, hn1]
    have hn0' : ((m.accept 1 inv202 result).locals 0).nextIndex = (m.locals 0).nextIndex :=
      accept_nextIndex_away m 1 0 inv202 result (by decide)
    have hn2' : ((m.accept 1 inv202 result).locals 2).nextIndex = (m.locals 2).nextIndex :=
      accept_nextIndex_away m 1 2 inv202 result (by decide)
    have hu := two_cell_update (f10_deposit1_cell hok) vaultC_ne_donor1C.symm
    have hne0 : (0 : Fin 3) ≠ 1 := by decide
    refine ⟨.next 1 hk.1 step, hstore, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · simpa [hn0'] using hk.2.2.1
    · omega
    · simpa [hn2'] using hk.2.2.2.2.1
    · simp [fundedBalances, accept_world, hn0', hn1', hn2']
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
      · have hv := hb.1
        simp [hn1] at hv
        linarith [hu.2.1]
      · have hd := hb.2.1
        simp [hn1] at hd
        linarith [hu.1]
      · simpa [hu.2.2 donor2C (by decide) (by decide)] using hb.2.2.1
      · simpa [hu.2.2 recipientC (by decide) (by decide)] using hb.2.2.2.1
      · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb.2.2.2.2.1
      · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hb.2.2.2.2.2
    · have hnready := f10_not_ready_peer (b := 1) (index := (m.locals 1).nextIndex)
          (inv := inv202) (w := m.world) (result := result) (by decide)
      have hncons := f10_not_consumed_peer (b := 1) (index := (m.locals 1).nextIndex)
          (inv := inv202) (w := m.world) (result := result) (by decide)
      have hphase :
          reserveUpdate q
            { participant := 1, boundary := f10Bounds 1 (m.locals 1).nextIndex, before := m,
              after := m.accept 1 inv202 result,
              attempt := some ⟨1, (m.locals 1).nextIndex, inv202, m.world, .ok result⟩ } = q := by
        simp [reserveUpdate, hnready, hncons]
        cases q <;> rfl
      rw [hphase]
      simpa [hn0'] using hq
    · intro h0
      have h0' : (m.locals 0).nextIndex = 0 := by simpa [hn0'] using h0
      simpa [accept_outputs_away m 1 0 inv202 result hne0] using hout0 h0'
    · intro h0
      have h0' : 1 ≤ (m.locals 0).nextIndex := by simpa [hn0'] using h0
      simpa [accept_outputs_away m 1 0 inv202 result hne0] using hout1 h0'
  · subst hb2
    subst hinv2
    have houts := f10_deposit2_outputs hok
    have hn2' : ((m.accept 2 inv203 result).locals 2).nextIndex = 1 := by
      simp [accept_selected, hn2]
    have hn0' : ((m.accept 2 inv203 result).locals 0).nextIndex = (m.locals 0).nextIndex :=
      accept_nextIndex_away m 2 0 inv203 result (by decide)
    have hn1' : ((m.accept 2 inv203 result).locals 1).nextIndex = (m.locals 1).nextIndex :=
      accept_nextIndex_away m 2 1 inv203 result (by decide)
    have hu := two_cell_update (f10_deposit2_cell hok) vaultC_ne_donor2C.symm
    have hne0 : (0 : Fin 3) ≠ 2 := by decide
    refine ⟨.next 2 hk.1 step, hstore, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · simpa [hn0'] using hk.2.2.1
    · simpa [hn1'] using hk.2.2.2.1
    · omega
    · simp [fundedBalances, accept_world, hn0', hn1', hn2']
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
      · have hv := hb.1
        simp [hn2] at hv
        linarith [hu.2.1]
      · simpa [hu.2.2 donor1C (by decide) (by decide)] using hb.2.1
      · have hd := hb.2.2.1
        simp [hn2] at hd
        linarith [hu.1]
      · simpa [hu.2.2 recipientC (by decide) (by decide)] using hb.2.2.2.1
      · simpa [hu.2.2 budgetC (by decide) (by decide)] using hb.2.2.2.2.1
      · simpa [hu.2.2 sentinelC (by decide) (by decide)] using hb.2.2.2.2.2
    · have hnready := f10_not_ready_peer (b := 2) (index := (m.locals 2).nextIndex)
          (inv := inv203) (w := m.world) (result := result) (by decide)
      have hncons := f10_not_consumed_peer (b := 2) (index := (m.locals 2).nextIndex)
          (inv := inv203) (w := m.world) (result := result) (by decide)
      have hphase :
          reserveUpdate q
            { participant := 2, boundary := f10Bounds 2 (m.locals 2).nextIndex, before := m,
              after := m.accept 2 inv203 result,
              attempt := some ⟨2, (m.locals 2).nextIndex, inv203, m.world, .ok result⟩ } = q := by
        simp [reserveUpdate, hnready, hncons]
        cases q <;> rfl
      rw [hphase]
      simpa [hn0'] using hq
    · intro h0
      have h0' : (m.locals 0).nextIndex = 0 := by simpa [hn0'] using h0
      simpa [accept_outputs_away m 2 0 inv203 result hne0] using hout0 h0'
    · intro h0
      have h0' : 1 ≤ (m.locals 0).nextIndex := by simpa [hn0'] using h0
      simpa [accept_outputs_away m 2 0 inv203 result hne0] using hout1 h0'

theorem f10_monitored_initialized (schedule : Schedule (Fin 3)) :
    FundedK
        (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
          (.awaiting, start f10Initial) schedule).1
        (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
          (.awaiting, start f10Initial) schedule).2 ∧
      ∀ b, fundedInvariant b
        (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
          (.awaiting, start f10Initial) schedule).2.world.state :=
  continueMonitored_start_initialized f10Cfg f10Bounds f10Branches reserveUpdate
    .awaiting f10Initial FundedK fundedInvariant fundedGuarantee fundedRely
    fundedAssumption fundedExternal f10_start_K f10_inv_derivation
    f10_assumption_derivation f10_present_external f10_selected_success f10_cross
    f10_stable f10_skip_update f10_refusal_update f10_success_update schedule

theorem f10_every_prefix_reserve (schedule : Schedule (Fin 3)) (n : Nat) :
    4 ≤ (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
      (.awaiting, start f10Initial) (schedule.take n)).2.world.state.balance vaultC :=
  (f10_monitored_initialized (schedule.take n)).2 0 |>.1

theorem f10_budget_initialized {q : ReservePhase} {m : M3} (hk : FundedK q m) :
    m.world.state.balance budgetC = 6 :=
  hk.2.2.2.2.2.1.2.2.2.2.1

theorem f10_store_preserved {q : ReservePhase} {m : M3} (hk : FundedK q m) :
    m.world.capabilities = f10Store :=
  hk.2.1

theorem f10_own_output_provenance {q : ReservePhase} {m : M3} (hk : FundedK q m) :
    ((m.locals 0).nextIndex = 0 → (m.locals 0).outputs = []) ∧
      (1 ≤ (m.locals 0).nextIndex → (m.locals 0).outputs = [budgetOut 0]) :=
  ⟨hk.2.2.2.2.2.2.2.1, hk.2.2.2.2.2.2.2.2⟩

theorem fin3_count_sum (s : List (Fin 3)) :
    s.count 0 + s.count 1 + s.count 2 = s.length := by
  induction s with
  | nil => simp
  | cons b rest ih =>
    rcases fin3_cases b with hb | hb | hb <;> subst b <;> simp [List.count_cons, ih] <;> omega

theorem f10_complete_length (s : Schedule (Fin 3))
    (h0 : s.count 0 = 2) (h1 : s.count 1 = 1) (h2 : s.count 2 = 1) :
    s.length = 4 := by
  have := fin3_count_sum s
  omega

theorem f10_complete_mem (s : Schedule (Fin 3))
    (h0 : s.count 0 = 2) (h1 : s.count 1 = 1) (h2 : s.count 2 = 1) :
    s ∈ f10Schedules := by
  have hlen := f10_complete_length s h0 h1 h2
  obtain ⟨a, b, c, d, rfl⟩ : ∃ a b c d, s = [a, b, c, d] := by
    cases s with
    | nil => simp at hlen
    | cons a s =>
      cases s with
      | nil => simp at hlen
      | cons b s =>
        cases s with
        | nil => simp at hlen
        | cons c s =>
          cases s with
          | nil => simp at hlen
          | cons d s =>
            cases s with
            | nil => exact ⟨a, b, c, d, rfl⟩
            | cons _ _ =>
              simp [List.length_cons] at hlen
              try omega
  rcases fin3_cases a with ha | ha | ha <;> subst a
  <;> rcases fin3_cases b with hb | hb | hb <;> subst b
  <;> rcases fin3_cases c with hc | hc | hc <;> subst c
  <;> rcases fin3_cases d with hd | hd | hd <;> subst d
  <;> simp [List.count_cons, List.count_nil, f10Schedules] at h0 h1 h2 ⊢

set_option maxHeartbeats 1200000 in
theorem f10_member_machineEq (s : List (Fin 3)) (hs : s ∈ f10Schedules) :
    machineEq fin3Roster (runPrefix f10Cfg f10Bounds f10Initial f10Branches s)
      (expectedF10 (s.map Fin.val)) = true := by
  simp [f10Schedules] at hs
  rcases hs with
    h | h | h | h | h | h | h | h | h | h | h | h
  all_goals
    subst s
    decide +kernel

set_option maxHeartbeats 1200000 in
-- twelve concrete expected F10 machines
theorem f10_expected_finals (s : List (Fin 3)) (hs : s ∈ f10Schedules) :
    let e := expectedF10 (s.map Fin.val)
    e.world.state.balance vaultC = 7 ∧
      e.world.state.balance donor1C = 1 ∧
      e.world.state.balance donor2C = 1 ∧
      e.world.state.balance recipientC = 6 ∧
      e.world.state.balance budgetC = 6 ∧
      (e.locals 0).nextIndex = 2 ∧
      (e.locals 1).nextIndex = 1 ∧
      (e.locals 2).nextIndex = 1 ∧
      (e.locals 0).failure = none ∧
      (e.locals 1).failure = none ∧
      (e.locals 2).failure = none := by
  simp [f10Schedules] at hs
  rcases hs with
    h | h | h | h | h | h | h | h | h | h | h | h
  all_goals
    subst s
    decide +kernel

/-- Every complete schedule of lengths 2,1,1 succeeds with finals 7/1/1/6/6.
Soundness/K-preservation does not supply this; the runs are identified with the
independent expected machines. -/
theorem f10_complete_success (s : Schedule (Fin 3))
    (h0 : s.count 0 = 2) (h1 : s.count 1 = 1) (h2 : s.count 2 = 1) :
    let m := (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
      (.awaiting, start f10Initial) s).2
    m.world.state.balance vaultC = 7 ∧
      m.world.state.balance donor1C = 1 ∧
      m.world.state.balance donor2C = 1 ∧
      m.world.state.balance recipientC = 6 ∧
      m.world.state.balance budgetC = 6 ∧
      (m.locals 0).nextIndex = 2 ∧
      (m.locals 1).nextIndex = 1 ∧
      (m.locals 2).nextIndex = 1 ∧
      (m.locals 0).failure = none ∧
      (m.locals 1).failure = none ∧
      (m.locals 2).failure = none := by
  have hmem := f10_complete_mem s h0 h1 h2
  have herase :
      (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
        (.awaiting, start f10Initial) s).2 =
        runPrefix f10Cfg f10Bounds f10Initial f10Branches s :=
    continueMonitored_erase _ _ _ _ _ _
  have heq := (machineEq_iff fin3Roster _ _).mp (f10_member_machineEq s hmem)
  have hf := f10_expected_finals s hmem
  simpa [herase, heq] using hf

/-- Guard facts from current K for a live selected token. These are the actual
enabledness premises (identity producer, 6 ≤ vault at consume, donor funding at
nextIndex = 0). They are not an `executeStep = .ok` claim: catalog/authority/accounting
checks sit outside the financial guards, and StepSound does not imply progress.
The actual current-world `executeStep = .ok` bridge is `f10_live_selected_enabled`. -/
theorem f10_selected_guards {q : ReservePhase} {m : M3} {b : Fin 3}
    {inv : Invocation P A D}
    (hk : FundedK q m) (hf : (m.locals b).failure = none)
    (hs : (f10Branches b)[(m.locals b).consumed]? = some inv) :
    (b = 0 ∧ inv = inv200 ∧ (m.locals 0).nextIndex = 0 ∧ (m.locals 0).outputs = []) ∨
      (b = 0 ∧ inv = inv201 ∧ (m.locals 0).nextIndex = 1 ∧
        (m.locals 0).outputs = [budgetOut 0] ∧
        6 ≤ m.world.state.balance vaultC) ∨
      (b = 1 ∧ inv = inv202 ∧ (m.locals 1).nextIndex = 0 ∧
        1 ≤ m.world.state.balance donor1C) ∨
      (b = 2 ∧ inv = inv203 ∧ (m.locals 2).nextIndex = 0 ∧
        2 ≤ m.world.state.balance donor2C) := by
  have hA := f10_assumption_derivation q m b hk (f10_present_external q m b hk)
  have hsel := f10_selected_cases (hA.1 hf) hs
  rcases hsel.2 with ⟨hb0, hop⟩ | ⟨hb1, hn1, hinv1⟩ | ⟨hb2, hn2, hinv2⟩
  · subst hb0
    rcases hop with ⟨hn0, hinv0⟩ | ⟨hn0, hinv0⟩
    · exact Or.inl ⟨rfl, hinv0, hn0, hk.2.2.2.2.2.2.2.1 hn0⟩
    · have ha := hA.2
      simp at ha
      rcases ha with hne | ⟨_, hout, hvault⟩
      · exact (hne hn0).elim
      · refine Or.inr (Or.inl ⟨rfl, hinv0, hn0, hout, ?_⟩)
        linarith [hvault]
  · subst hb1
    subst hinv1
    have ha := hA.2
    simp at ha
    exact Or.inr (Or.inr (Or.inl ⟨rfl, rfl, hn1, ha hn1⟩))
  · subst hb2
    subst hinv2
    have ha := hA.2
    simp at ha
    exact Or.inr (Or.inr (Or.inr ⟨rfl, rfl, hn2, ha hn2⟩))

/-- Donor (and any participant) own-output history is empty while `nextIndex = 0`.
Skip and refuse preserve both fields; a selected accept increments `nextIndex`, so
the index-zero case never observes a successful own emission. This is a Reachable
local invariant, not an extra FundedK premise. -/
theorem f10_reachable_empty_outputs {m : M3}
    (h : Reachable f10Cfg f10Bounds f10Branches f10Initial m) :
    ∀ b : Fin 3, (m.locals b).nextIndex = 0 → (m.locals b).outputs = [] := by
  induction h with
  | start =>
    intro b hidx
    simp [start_locals]
  | @next pre post sel previous step ih =>
    intro own hidx
    cases step with
    | halted _ _ =>
      rw [skip_outputs pre sel own]
      rw [skip_nextIndex pre sel own] at hidx
      exact ih own hidx
    | exhausted _ _ =>
      rw [skip_outputs pre sel own]
      rw [skip_nextIndex pre sel own] at hidx
      exact ih own hidx
    | refused inv reason _ _ _ =>
      rw [refuse_outputs pre sel own inv reason]
      rw [refuse_nextIndex pre sel own inv reason] at hidx
      exact ih own hidx
    | accepted inv result _ _ _ =>
      by_cases ho : own = sel
      · subst own
        rw [accept_nextIndex_sel pre sel inv result] at hidx
        omega
      · rw [accept_outputs_away pre sel own inv result ho]
        rw [accept_nextIndex_away pre sel own inv result ho] at hidx
        exact ih own hidx

/-- Exact helper receipt, output, store and cell facts for a live selected call at an
arbitrary current `FundedK` world. Derived from `f10_selected_guards`, store/budget
from K, and empty donor history from Reachable. Not a future or whole-run success
hypothesis. -/
theorem f10_live_selected_enabled_details {q : ReservePhase} {m : M3} {b : Fin 3}
    {inv : Invocation P A D}
    (hk : FundedK q m) (hf : (m.locals b).failure = none)
    (hs : (f10Branches b)[(m.locals b).consumed]? = some inv) :
    ∃ result, executeStep f10Cfg (f10Bounds b (m.locals b).nextIndex)
        (m.locals b).nextIndex (m.locals b).outputs (.invoke inv) m.world = .ok result ∧
      result.world.capabilities = f10Store ∧
      ((b = 0 ∧ inv = inv200 ∧ result.receipt = rec200 ∧ result.outputs = [budgetOut 0] ∧
          ∀ c, result.world.state.balance c = m.world.state.balance c) ∨
        (b = 0 ∧ inv = inv201 ∧ result.receipt = rec201 ∧ result.outputs = [] ∧
          result.world.state.balance vaultC = m.world.state.balance vaultC + (-6) ∧
          result.world.state.balance recipientC = m.world.state.balance recipientC + 6 ∧
          ∀ c, c ≠ vaultC → c ≠ recipientC →
            result.world.state.balance c = m.world.state.balance c) ∨
        (b = 1 ∧ inv = inv202 ∧ result.receipt = rec202 ∧ result.outputs = [] ∧
          result.world.state.balance donor1C = m.world.state.balance donor1C + (-1) ∧
          result.world.state.balance vaultC = m.world.state.balance vaultC + 1 ∧
          ∀ c, c ≠ donor1C → c ≠ vaultC →
            result.world.state.balance c = m.world.state.balance c) ∨
        (b = 2 ∧ inv = inv203 ∧ result.receipt = rec203 ∧ result.outputs = [] ∧
          result.world.state.balance donor2C = m.world.state.balance donor2C + (-2) ∧
          result.world.state.balance vaultC = m.world.state.balance vaultC + 2 ∧
          ∀ c, c ≠ donor2C → c ≠ vaultC →
            result.world.state.balance c = m.world.state.balance c)) := by
  have hstore := f10_store_preserved hk
  have hbudget := f10_budget_initialized hk
  rcases f10_selected_guards hk hf hs with hprod | hcons | hd1 | hd2
  · rcases hprod with ⟨hb, hinv, hn0, hout⟩
    subst b
    subst inv
    rcases f10_producer_enabled m.world hstore hbudget with
      ⟨result, hstep, hrec, houts, hcap, hbal⟩
    refine ⟨result, ?_, hcap, Or.inl ⟨rfl, rfl, hrec, houts, hbal⟩⟩
    simpa [hn0, hout] using hstep
  · rcases hcons with ⟨hb, hinv, hn0, hout, hvault⟩
    subst b
    subst inv
    rcases f10_consumer_enabled m.world hstore hvault with
      ⟨result, hstep, hrec, houts, hcap, hv, hr, hfr⟩
    refine ⟨result, ?_, hcap, Or.inr (Or.inl ⟨rfl, rfl, hrec, houts, hv, hr, hfr⟩)⟩
    simpa [hn0, hout] using hstep
  · rcases hd1 with ⟨hb, hinv, hn1, hfund⟩
    subst b
    subst inv
    have hout : (m.locals 1).outputs = [] := f10_reachable_empty_outputs hk.1 1 hn1
    rcases f10_deposit1_enabled m.world hstore hfund with
      ⟨result, hstep, hrec, houts, hcap, hd, hv, hfr⟩
    refine ⟨result, ?_, hcap, Or.inr (Or.inr (Or.inl ⟨rfl, rfl, hrec, houts, hd, hv, hfr⟩))⟩
    simpa [hn1, hout] using hstep
  · rcases hd2 with ⟨hb, hinv, hn2, hfund⟩
    subst b
    subst inv
    have hout : (m.locals 2).outputs = [] := f10_reachable_empty_outputs hk.1 2 hn2
    rcases f10_deposit2_enabled m.world hstore hfund with
      ⟨result, hstep, hrec, houts, hcap, hd, hv, hfr⟩
    refine ⟨result, ?_, hcap, Or.inr (Or.inr (Or.inr ⟨rfl, rfl, hrec, houts, hd, hv, hfr⟩))⟩
    simpa [hn2, hout] using hstep

/-- Actual `executeStep = .ok` for the live selected invocation at an arbitrary current
`FundedK` world. Premises are current K, selected-branch `failure = none`, and the
actual current branch lookup. Index, own history, store, budget and funding are
derived; donor index-0 history is the Reachable empty-output invariant. This does
not assume future or whole-run success and does not replace symbolic enabledness by
a finite runtime check. -/
theorem f10_live_selected_enabled {q : ReservePhase} {m : M3} {b : Fin 3}
    {inv : Invocation P A D}
    (hk : FundedK q m) (hf : (m.locals b).failure = none)
    (hs : (f10Branches b)[(m.locals b).consumed]? = some inv) :
    ∃ result, executeStep f10Cfg (f10Bounds b (m.locals b).nextIndex)
        (m.locals b).nextIndex (m.locals b).outputs (.invoke inv) m.world = .ok result := by
  obtain ⟨result, hstep, _⟩ := f10_live_selected_enabled_details hk hf hs
  exact ⟨result, hstep⟩

/-- Initialized arbitrary-prefix corollary: after any `schedule.take n`, a live selected
call at the resulting monitored machine is actually `executeStep = .ok`. -/
theorem f10_initialized_prefix_enabled (schedule : Schedule (Fin 3)) (n : Nat)
    {b : Fin 3} {inv : Invocation P A D} :
    let m := (continueMonitored f10Cfg f10Bounds f10Branches reserveUpdate
      (.awaiting, start f10Initial) (schedule.take n)).2
    (m.locals b).failure = none →
      (f10Branches b)[(m.locals b).consumed]? = some inv →
        ∃ result, executeStep f10Cfg (f10Bounds b (m.locals b).nextIndex)
          (m.locals b).nextIndex (m.locals b).outputs (.invoke inv) m.world = .ok result :=
  fun hf hs =>
    f10_live_selected_enabled (f10_monitored_initialized (schedule.take n)).1 hf hs

/-- F12: authorized peer withdrawal 3 after the producer, then consumer 6, leaves vault 1.
The generic funded instance rely is `fundedRely` (post-state `fundedInv`), not
`depositOnlyRely`. Fuller F12 readiness and actual-step proofs live in the companion
module; this tail theorem does not replace them. -/
theorem f12_vault_final :
    (runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule).world.state.balance vaultC =
      1 := by
  have h : machineEq fin3Roster
      (runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule) f12Expected = true := by
    decide +kernel
  have heq := (machineEq_iff fin3Roster _ _).mp h
  simpa [heq, f12Expected, f12AfterCons] using
    (by decide +kernel : f12AfterCons.state.balance vaultC = 1)

/-- Separate monotone peer relation used to exhibit the F12 readiness issue: vault does
not fall. This is not the generic funded instance rely; `fundedRely` is post `fundedInv`.
F12's authorized withdrawal 3 after the producer falsifies it (10 to 7) while all three
calls still succeed. The companion module contains fuller F12 proofs. This relation is
not used by the generic funded instance. -/
def depositOnlyRely (pre post : State P A D) : Prop :=
  pre.balance vaultC ≤ post.balance vaultC

theorem f12_deposit_only_rely_false :
    ¬ depositOnlyRely f12AfterProd.state f12AfterPeer.state := by
  intro h
  unfold depositOnlyRely at h
  have hp : f12AfterProd.state.balance vaultC = (10 : ℚ) := by decide +kernel
  have hq : f12AfterPeer.state.balance vaultC = (7 : ℚ) := by decide +kernel
  rw [hp, hq] at h
  norm_num at h

theorem f16_catalog_valid : validateCatalog f16Cfg.registry f16Cfg.catalog = true := by
  decide

theorem f16_producer_invoke_auth :
    hasAuthority f16Store (ids [0]) vaultBound.ctx ⟨210⟩ .invoke = true := by
  decide +kernel

set_option maxHeartbeats 800000 in -- concrete monitored F16 fold
theorem f16_monitor_awaiting :
    (continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) f16Schedule).1 = .awaiting := by
  decide +kernel

set_option maxHeartbeats 800000 in -- concrete monitored F16 locals
theorem f16_no_p0_output :
    ((continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) f16Schedule).2.locals 0).outputs = [] := by
  decide +kernel

set_option maxHeartbeats 800000 in -- concrete monitored F17 fold
theorem f17_monitor_awaiting :
    (continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) f17Schedule).1 = .awaiting := by
  decide +kernel

set_option maxHeartbeats 800000 in -- concrete monitored F17 p0 silence
theorem f17_p0_silent :
    ((continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) f17Schedule).2.locals 0).outputs = [] ∧
      ((continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
        (.awaiting, start f10Initial) f17Schedule).2.locals 0).nextIndex = 0 := by
  decide +kernel

end DefiKernel.Nary.FundedCausal




