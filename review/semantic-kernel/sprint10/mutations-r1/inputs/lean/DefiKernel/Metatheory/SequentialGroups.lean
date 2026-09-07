import DefiKernel.Composition.Sequence

/-! Recursive ordered groups continue the complete actual cursor. `SupportedGroup` deliberately
uses `flatten` only as a Prop-valued specification of static support. The recursive `runGroup`
interpreter never delegates execution to the list executor. -/
namespace DefiKernel.Metatheory
open Typed Composition

inductive SeqGroup (P A D : Type) where
  | empty
  | step (action : Step P A D)
  | seq (first second : SeqGroup P A D)

def flatten {P A D : Type} : SeqGroup P A D → List (Step P A D)
  | .empty => []
  | .step action => [action]
  | .seq first second => flatten first ++ flatten second

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def runGroup (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : SeqGroup P A D → Cursor P A D
  | .empty => cursor
  | .step action => Composition.advance cfg boundaries cursor action
  | .seq first second =>
    let middle := runGroup cfg boundaries cursor first
    runGroup cfg boundaries middle second

-- BEGIN PROOFS

/-- Simulation includes all raw event worlds, administrative stores, absolute positions and
existing failures; there is no successful-only or initial-cursor premise. -/
theorem runGroup_eq_continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group =
      Composition.continueRun cfg boundaries cursor (flatten group) := by
  induction group generalizing cursor with
  | empty => rfl
  | step action => rfl
  | seq first second firstIH secondIH =>
    simp only [runGroup, flatten, Composition.continueRun_append, firstIH, secondIH]

theorem runGroup_empty (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : runGroup cfg boundaries cursor .empty = cursor := rfl

theorem runGroup_empty_left (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq .empty group) =
      runGroup cfg boundaries cursor group := rfl

theorem runGroup_empty_right (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq group .empty) =
      runGroup cfg boundaries cursor group := rfl

/-- A previously located refusal makes every submitted recursive group inert. -/
theorem runGroup_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group = cursor := by
  rw [runGroup_eq_continueRun]
  exact Composition.continueRun_failed cfg boundaries cursor failure failed (flatten group)

/-- Regrouping three ordered sequential groups preserves the entire returned cursor. -/
theorem runGroup_assoc (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (first second third : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq (.seq first second) third) =
      runGroup cfg boundaries cursor (.seq first (.seq second third)) := by
  rw [runGroup_eq_continueRun, runGroup_eq_continueRun]
  simp only [flatten, List.append_assoc]

end DefiKernel.Metatheory
