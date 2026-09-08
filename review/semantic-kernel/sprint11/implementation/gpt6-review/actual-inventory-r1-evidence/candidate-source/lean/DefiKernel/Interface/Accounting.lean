import DefiKernel.Interface.Regions
import DefiKernel.Atomic.Settlement
import Mathlib.Tactic.Ring

/-! Exact region changes are derived from actual successful execution. Continuation
accounting uses only the newly appended event suffix, even from arbitrary entry cursors. -/
namespace DefiKernel.Interface
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def eventDeltaSum (region : Region P A D) (events : List (Event P A D)) : ℚ :=
  (events.map (fun event ↦ receiptDelta region event.result.receipt)).sum

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem step_receipt_cell {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result) (cell : Cell P A D) :
    result.world.state.balance cell =
      pre.state.balance cell + receiptCellEffect result.receipt cell := by
  rw [receiptCellEffect_eq_receiptEffect]
  exact Atomic.step_receipt_balance (executeStep_sound _ _ _ _ _ _ _ h) cell

theorem step_receipt_region (region : Region P A D) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {step : Step P A D} {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result) :
    balanceSum region result.world.state =
      balanceSum region pre.state + receiptDelta region result.receipt := by
  unfold balanceSum receiptDelta
  calc
    region.cells.sum result.world.state.balance =
        region.cells.sum (fun c ↦ pre.state.balance c + receiptCellEffect result.receipt c) :=
      Finset.sum_congr rfl (fun c _ ↦ step_receipt_cell h c)
    _ = _ := Finset.sum_add_distrib

theorem step_effect_outside_writes {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result)
    (cell : Cell P A D) (outside : cell ∉ result.receipt.writes) :
    receiptCellEffect result.receipt cell = 0 := by
  have hc := step_receipt_cell h cell
  have hl := (executeStep_sound _ _ _ _ _ _ _ h).locality cell outside
  linarith

theorem step_effect_outside (cells : Finset (Cell P A D)) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {step : Step P A D} {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result)
    (within : WritesWithin cells result.receipt) (cell : Cell P A D) (outside : cell ∉ cells) :
    receiptCellEffect result.receipt cell = 0 :=
  step_effect_outside_writes h cell (fun hw ↦ outside (within cell hw))

theorem receiptDelta_eq_inter (region : Region P A D) (cells : Finset (Cell P A D))
    {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result)
    (within : WritesWithin cells result.receipt) :
    receiptDelta region result.receipt =
      (region.cells ∩ cells).sum (receiptCellEffect result.receipt) := by
  unfold receiptDelta
  symm
  apply Finset.sum_subset (Finset.inter_subset_left)
  intro c hr hc
  exact step_effect_outside cells h within c (fun hq ↦ hc (Finset.mem_inter.mpr ⟨hr, hq⟩))

theorem step_region_neutral (region : Region P A D) (cells : Finset (Cell P A D))
    {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result)
    (within : WritesWithin cells result.receipt) (neutral : NeutralOn region cells result.receipt) :
    balanceSum region result.world.state = balanceSum region pre.state := by
  rw [step_receipt_region region h, receiptDelta_eq_inter region cells h within, neutral, add_zero]

theorem step_value_frame (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {step : Step P A D} {pre : World P A D} {result : StepResult P A D}
    (h : executeStep cfg boundary index history step pre = .ok result)
    (separate : ∀ c ∈ result.receipt.writes, c ∉ support) :
    value result.world.state = value pre.state := by
  apply supported
  intro c hc
  exact (executeStep_sound _ _ _ _ _ _ _ h).locality c (fun hw ↦ separate c hw hc)

theorem step_total_preserved (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {step : Step P A D} {pre : World P A D} {result : StepResult P A D}
    (initial : balanceSum region pre.state = value pre.state)
    (h : executeStep cfg boundary index history step pre = .ok result)
    (within : WritesWithin cells result.receipt) (neutral : NeutralOn region cells result.receipt)
    (separate : ∀ c ∈ result.receipt.writes, c ∉ support) :
    balanceSum region result.world.state = value result.world.state := by
  rw [step_region_neutral region cells h within neutral,
    step_value_frame support value supported h separate]
  exact initial

omit [Fintype P] [Fintype A] [Fintype D] in
@[simp] theorem eventDeltaSum_nil (region : Region P A D) : eventDeltaSum region [] = 0 := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
@[simp] theorem eventDeltaSum_append (region : Region P A D) (xs ys : List (Event P A D)) :
    eventDeltaSum region (xs ++ ys) = eventDeltaSum region xs + eventDeltaSum region ys := by
  simp [eventDeltaSum, List.sum_append]

theorem advance_accounting_suffix (region : Region P A D) (cfg : Config P A D)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D) (step : Step P A D) :
    ∃ suffix : List (Event P A D),
      (Composition.advance cfg boundaries entry step).events = entry.events ++ suffix ∧
      balanceSum region (Composition.advance cfg boundaries entry step).world.state =
        balanceSum region entry.world.state + eventDeltaSum region suffix := by
  cases hf : entry.failure with
  | some failure => exact ⟨[], by simp [Composition.advance, hf], by simp [Composition.advance, hf]⟩
  | none =>
    cases he : executeStep cfg (boundaries entry.nextIndex) entry.nextIndex
        entry.outputs step entry.world with
    | error reason =>
      exact ⟨[], by simp [Composition.advance, hf, he], by simp [Composition.advance, hf, he]⟩
    | ok result =>
      refine ⟨[⟨entry.nextIndex, step, entry.world, result⟩], ?_, ?_⟩
      · simp [Composition.advance, hf, he]
      · simpa [Composition.advance, hf, he, eventDeltaSum] using step_receipt_region region he

theorem continueRun_accounting_suffix (region : Region P A D) (cfg : Config P A D)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D) (steps : List (Step P A D)) :
    ∃ suffix : List (Event P A D),
      (Composition.continueRun cfg boundaries entry steps).events = entry.events ++ suffix ∧
      balanceSum region (Composition.continueRun cfg boundaries entry steps).world.state =
        balanceSum region entry.world.state + eventDeltaSum region suffix := by
  induction steps generalizing entry with
  | nil => exact ⟨[], by simp [Composition.continueRun], by simp [Composition.continueRun]⟩
  | cons step steps ih =>
    obtain ⟨first, he, hb⟩ := advance_accounting_suffix region cfg boundaries entry step
    obtain ⟨tail, ht, hbt⟩ := ih (Composition.advance cfg boundaries entry step)
    refine ⟨first ++ tail, ?_, ?_⟩
    · simpa [Composition.continueRun, List.foldl_cons, he, List.append_assoc] using ht
    · change balanceSum region (Composition.continueRun cfg boundaries
        (Composition.advance cfg boundaries entry step) steps).world.state = _
      rw [hbt, hb, eventDeltaSum_append]
      ring

theorem continueRun_accounting (region : Region P A D) (cfg : Config P A D)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D) (steps : List (Step P A D)) :
    balanceSum region (Composition.continueRun cfg boundaries entry steps).world.state =
      balanceSum region entry.world.state + eventDeltaSum region
        ((Composition.continueRun cfg boundaries entry steps).events.drop entry.events.length) := by
  obtain ⟨suffix, he, hb⟩ := continueRun_accounting_suffix region cfg boundaries entry steps
  simpa [he] using hb

theorem issue_region_unchanged (region : Region P A D) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {grant : Grant P A D} {pre : World P A D} {result : StepResult P A D}
    (executed : executeStep cfg boundary index history (.issue grant) pre = .ok result) :
    balanceSum region result.world.state = balanceSum region pre.state := by
  rw [(executeStep_sound _ _ _ _ _ _ _ executed).issue_preserves_ledger]

theorem revoke_region_unchanged (region : Region P A D) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {id : CapabilityId} {pre : World P A D} {result : StepResult P A D}
    (executed : executeStep cfg boundary index history (.revoke id) pre = .ok result) :
    balanceSum region result.world.state = balanceSum region pre.state := by
  rw [(executeStep_sound _ _ _ _ _ _ _ executed).revoke_preserves_ledger]

theorem continueRun_outputs_suffix (cfg : Config P A D)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D) (steps : List (Step P A D)) :
    ∃ suffix, (Composition.continueRun cfg boundaries entry steps).outputs =
      entry.outputs ++ suffix := by
  induction steps generalizing entry with
  | nil => exact ⟨[], by simp [Composition.continueRun]⟩
  | cons step steps ih =>
    obtain ⟨suffix, hs⟩ := ih (Composition.advance cfg boundaries entry step)
    cases hf : entry.failure with
    | some failure =>
      exact ⟨suffix, by simpa [Composition.continueRun, Composition.advance, hf] using hs⟩
    | none =>
      cases he : executeStep cfg (boundaries entry.nextIndex) entry.nextIndex
          entry.outputs step entry.world with
      | error reason =>
        exact ⟨suffix, by simpa [Composition.continueRun, Composition.advance, hf, he] using hs⟩
      | ok result =>
        exact ⟨result.outputs ++ suffix, by
          simpa [Composition.continueRun, Composition.advance, hf, he, List.append_assoc] using hs⟩

end DefiKernel.Interface
