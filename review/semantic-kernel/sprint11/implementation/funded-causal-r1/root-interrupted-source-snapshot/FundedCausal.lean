import DefiKernel.Nary.Causal
import DefiKernel.Nary.Examples
import DefiKernel.Nary.LocalOrder
import DefiKernel.Nary.Observation
import DefiKernel.Interface.Accounting

/-! Concrete F10 funded causal instance and F12/F16/F17 companions. Obligations of
`continueMonitored_initialized` are discharged from initialization, own-output provenance,
deposit arithmetic and actual `executeStep` equations. This module does not assume the
desired whole-run `K` as a premise, does not treat the twelve Boolean schedule checks as
the proof, and does not manufacture expected worlds by calling the candidate dispatcher. -/
namespace DefiKernel.Nary.FundedCausal
open Typed Composition
open DefiKernel.Nary
open DefiKernel.Nary.Examples
open Interface (receiptCellEffect step_receipt_cell)

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
    s.balance donor2C = 3 - n2 ∧
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
    | ⟨1, _⟩ => 1 ≤ m.world.state.balance donor1C
    | ⟨2, _⟩ => 2 ≤ m.world.state.balance donor2C

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
  have n1le : (n1 : ℚ) ≤ 2 := by exact_mod_cast (Nat.le_trans h1 (by decide : 1 ≤ 2))
  have n2le : (n2 : ℚ) ≤ 3 := by exact_mod_cast (Nat.le_trans h2 (by decide : 1 ≤ 3))
  refine ⟨?_, ?_, ?_, ?_, hbgt, hsen⟩
  · rcases hc with hc | hc <;> simp [hc] at hv <;> linarith
  · linarith [n1le]
  · linarith [n2le]
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
    have hnQ : ((m.locals 1).nextIndex : ℚ) ≤ 1 := by exact_mod_cast n1
    change 1 ≤ m.world.state.balance donor1C
    rw [hb.2.1]
    linarith [hnQ]
  | ⟨2, _⟩ =>
    have hnQ : ((m.locals 2).nextIndex : ℚ) ≤ 1 := by exact_mod_cast n2
    change 2 ≤ m.world.state.balance donor2C
    rw [hb.2.2.1]
    linarith [hnQ]

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
  · simpa [skip_nextIndex] using hk.2.2.2.2.2.2.1
  · intro h0
    have h0' : (m.locals 0).nextIndex = 0 := by simpa [skip_nextIndex] using h0
    simpa [skip_outputs] using hk.2.2.2.2.2.2.2.1 h0'
  · intro h0
    have h0' : 1 ≤ (m.locals 0).nextIndex := by simpa [skip_nextIndex] using h0
    simpa [skip_outputs] using hk.2.2.2.2.2.2.2.2 h0'

/-- F12: authorized peer withdrawal 3 after the producer, then consumer 6, leaves vault 1.
The deposit-only rely used by the funded instance is false of this peer step. -/
theorem f12_vault_final :
    (runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule).world.state.balance vaultC =
      1 := by
  have h : machineEq fin3Roster
      (runPrefix f12Cfg f12Bounds f12Initial f12Branches f12Schedule) f12Expected = true := by
    decide +kernel
  have heq := (machineEq_iff fin3Roster _ _).mp h
  simpa [heq, f12Expected, f12AfterCons] using
    (by decide +kernel : f12AfterCons.state.balance vaultC = 1)

/-- Deposit-only peer rely of the funded instance: vault does not fall. F12's authorized
withdrawal 3 after the producer falsifies it (10 to 7) while all three calls still succeed. -/
def depositOnlyRely (pre post : State P A D) : Prop :=
  pre.balance vaultC ≤ post.balance vaultC

theorem f12_deposit_only_rely_false :
    ¬ depositOnlyRely f12AfterProd.state f12AfterPeer.state := by
  intro h
  have hp : f12AfterProd.state.balance vaultC = 10 := by decide +kernel
  have hq : f12AfterPeer.state.balance vaultC = 7 := by decide +kernel
  linarith

theorem f16_monitor_awaiting :
    (continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate
      (.awaiting, start f16Initial) f16Schedule).1 = .awaiting := by
  decide +kernel

theorem f17_monitor_awaiting :
    (continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate
      (.awaiting, start f10Initial) f17Schedule).1 = .awaiting := by
  decide +kernel

end DefiKernel.Nary.FundedCausal




