import DefiKernel.Metatheory.Observation

/-! One-hole sequential contexts have fixed surrounding groups and cannot inspect diagnostics,
reset cursors, change configuration, add peers or insert atomic commit boundaries. -/
namespace DefiKernel.Metatheory
open Typed Composition

inductive SeqContext (P A D : Type) where
  | hole
  | before (fixed : SeqGroup P A D) (context : SeqContext P A D)
  | after (context : SeqContext P A D) (fixed : SeqGroup P A D)

def fill {P A D : Type} (context : SeqContext P A D) (group : SeqGroup P A D) :
    SeqGroup P A D :=
  match context with
  | .hole => group
  | .before fixed context => .seq fixed (fill context group)
  | .after context fixed => .seq (fill context group) fixed

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Equivalence quantifies over every pair of equivalent input cursors, including arbitrary
histories and existing failures. It is not equality at one particular entry state. -/
def GroupEquivalent (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (first second : SeqGroup P A D) : Prop :=
  ∀ left right, CursorEquivalent left right →
    CursorEquivalent (runGroup cfg boundaries left first) (runGroup cfg boundaries right second)

-- BEGIN PROOFS

theorem GroupEquivalent.refl (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries group group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem GroupEquivalent.symm {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first second : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first second) :
    GroupEquivalent cfg boundaries second first := by
  intro left right equivalent
  exact (h right left equivalent.symm).symm

theorem GroupEquivalent.trans {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first middle last : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first middle)
    (g : GroupEquivalent cfg boundaries middle last) :
    GroupEquivalent cfg boundaries first last := by
  intro left right equivalent
  exact (h left right equivalent).trans (g right right (CursorEquivalent.refl right))

/-- A fixed prefix uses universal-input equivalence at the actual returned prefix cursors;
a fixed suffix uses preservation after the substituted groups have run. -/
theorem GroupEquivalent.fill {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first second : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first second)
    (context : SeqContext P A D) :
    GroupEquivalent cfg boundaries (fill context first) (fill context second) := by
  induction context with
  | hole => exact h
  | before fixed context ih =>
    intro left right equivalent
    exact ih _ _ (runGroup_preserves cfg boundaries left right fixed equivalent)
  | after context fixed ih =>
    intro left right equivalent
    exact runGroup_preserves cfg boundaries _ _ fixed (ih left right equivalent)

theorem groupEquivalent_empty_left (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries (.seq .empty group) group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem groupEquivalent_empty_right (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries (.seq group .empty) group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem groupEquivalent_assoc (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (first second third : SeqGroup P A D) :
    GroupEquivalent cfg boundaries (.seq (.seq first second) third)
      (.seq first (.seq second third)) := by
  intro left right h
  rw [runGroup_assoc]
  exact runGroup_preserves cfg boundaries left right (.seq first (.seq second third)) h

end DefiKernel.Metatheory
