import DefiKernel.Metatheory.SequentialGroups
import DefiKernel.Parallel.Observation

/-! Continuation observations retain every computational input and every observed event field.
Only past raw event worlds are omitted. Local comparison sites admit independent omission tests. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

structure CursorObservation (P A D : Type) where
  world : World P A D
  branch : BranchObservation P A D

def observeCursor {P A D : Type} (cursor : Cursor P A D) : CursorObservation P A D :=
  ⟨cursor.world, observeBranch cursor⟩

def CursorEquivalent {P A D : Type} (left right : Cursor P A D) : Prop :=
  (∀ cell, left.world.state.balance cell = right.world.state.balance cell) ∧
    left.world.capabilities = right.world.capabilities ∧
    observeBranch left = observeBranch right

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def eventEq (left right : EventObservation P A D) : Bool :=
  decide (left.index = right.index) && decide (left.step = right.step) &&
    decide (left.receipt = right.receipt) && decide (left.outputs = right.outputs)

def eventsEq : List (EventObservation P A D) → List (EventObservation P A D) → Bool
  | [], [] => true
  | left :: lefts, right :: rights => eventEq left right && eventsEq lefts rights
  | _, _ => false

def observationEq (left right : CursorObservation P A D) : Bool :=
  decide (∀ cell, left.world.state.balance cell = right.world.state.balance cell) &&
    decide (left.world.capabilities = right.world.capabilities) &&
    eventsEq left.branch.events right.branch.events &&
    decide (left.branch.outputs = right.branch.outputs) &&
    decide (left.branch.nextIndex = right.branch.nextIndex) &&
    decide (left.branch.failure = right.branch.failure)

def cursorEq (left right : Cursor P A D) : Bool :=
  observationEq (observeCursor left) (observeCursor right)

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem eventEq_iff (left right : EventObservation P A D) :
    eventEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [eventEq, EventObservation.mk.injEq, and_assoc]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem eventsEq_iff (left right : List (EventObservation P A D)) :
    eventsEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [eventsEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [eventsEq]
    | cons other rest => simp [eventsEq, eventEq_iff, ih]

theorem cursorEq_iff (left right : Cursor P A D) :
    cursorEq left right = true ↔ CursorEquivalent left right := by
  simp only [cursorEq, observationEq, observeCursor, Bool.and_eq_true,
    eventsEq_iff, CursorEquivalent, observeBranch, BranchObservation.mk.injEq, and_assoc]
  constructor
  · rintro ⟨hb, hs, he, ho, hi, hf⟩
    exact ⟨of_decide_eq_true hb, of_decide_eq_true hs, he,
      of_decide_eq_true ho, of_decide_eq_true hi, of_decide_eq_true hf⟩
  · rintro ⟨hb, hs, he, ho, hi, hf⟩
    exact ⟨decide_eq_true hb, decide_eq_true hs, he,
      decide_eq_true ho, decide_eq_true hi, decide_eq_true hf⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem world_eq_of_fields (left right : World P A D)
    (balance : ∀ cell, left.state.balance cell = right.state.balance cell)
    (store : left.capabilities = right.capabilities) : left = right := by
  rcases left with ⟨⟨lb, ln⟩, lc⟩
  rcases right with ⟨⟨rb, rn⟩, rc⟩
  have hb : lb = rb := funext balance
  cases hb
  cases store
  rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.world {left right : Cursor P A D}
    (h : CursorEquivalent left right) : left.world = right.world :=
  world_eq_of_fields _ _ h.1 h.2.1

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.refl (cursor : Cursor P A D) : CursorEquivalent cursor cursor :=
  ⟨fun _ ↦ rfl, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.symm {left right : Cursor P A D} (h : CursorEquivalent left right) :
    CursorEquivalent right left := ⟨fun cell ↦ (h.1 cell).symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.trans {first middle last : Cursor P A D}
    (h : CursorEquivalent first middle) (g : CursorEquivalent middle last) :
    CursorEquivalent first last :=
  ⟨fun cell ↦ (h.1 cell).trans (g.1 cell), h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem cursorEquivalent_iff_fields (left right : Cursor P A D) :
    CursorEquivalent left right ↔
      left.world = right.world ∧
      left.events.map observeEvent = right.events.map observeEvent ∧
      left.outputs = right.outputs ∧ left.nextIndex = right.nextIndex ∧
      left.failure = right.failure := by
  constructor
  · intro h
    refine ⟨h.world, ?_⟩
    simpa only [observeBranch, BranchObservation.mk.injEq] using h.2.2
  · rintro ⟨hw, he, ho, hi, hf⟩
    exact ⟨fun cell ↦ congrArg (fun w ↦ w.state.balance cell) hw,
      congrArg (fun w ↦ w.capabilities) hw, by simp only [observeBranch, he, ho, hi, hf]⟩

/-- Every actual invocation, issue and revoke preserves the chosen observation equivalence. -/
theorem advance_preserves (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (left right : Cursor P A D) (action : Step P A D) (h : CursorEquivalent left right) :
    CursorEquivalent (Composition.advance cfg boundaries left action)
      (Composition.advance cfg boundaries right action) := by
  obtain ⟨hw, he, ho, hi, hf⟩ := (cursorEquivalent_iff_fields left right).mp h
  apply (cursorEquivalent_iff_fields _ _).mpr
  rcases left with ⟨lw, le, lo, li, lf⟩
  rcases right with ⟨rw, re, ro, ri, rf⟩
  dsimp only at hw he ho hi hf
  cases hw
  cases ho
  cases hi
  cases hf
  cases lf with
  | some failure =>
    simp [Composition.advance, he]
  | none =>
    cases hx : Composition.executeStep cfg (boundaries li) li lo action lw with
    | error reason => simp [Composition.advance, hx, he]
    | ok result => simp [Composition.advance, hx, List.map_append, he]

theorem runGroup_preserves (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (left right : Cursor P A D) (group : SeqGroup P A D) (h : CursorEquivalent left right) :
    CursorEquivalent (runGroup cfg boundaries left group)
      (runGroup cfg boundaries right group) := by
  induction group generalizing left right with
  | empty => exact h
  | step action => exact advance_preserves cfg boundaries left right action h
  | seq first second firstIH secondIH =>
    exact secondIH _ _ (firstIH left right h)

end DefiKernel.Metatheory
