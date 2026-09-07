import DefiKernel.Metatheory.Configuration
import DefiKernel.Metatheory.SequentialGroups

/-! Full static group support and configuration lifting through actual recursive simulation. -/
namespace DefiKernel.Metatheory
open Typed Composition

def SupportedGroup {P A D : Type} (refs : ReferenceSet) (group : SeqGroup P A D) : Prop :=
  SupportedList refs (flatten group)

-- BEGIN PROOFS

variable {P A D : Type}

@[simp] theorem supportedGroup_empty (refs : ReferenceSet) :
    SupportedGroup (P := P) (A := A) (D := D) refs .empty := by
  simp [SupportedGroup, flatten]

@[simp] theorem supportedGroup_step (refs : ReferenceSet) (action : Step P A D) :
    SupportedGroup refs (.step action) ↔ SupportedStep refs action := by
  simp [SupportedGroup, flatten]

@[simp] theorem supportedGroup_seq (refs : ReferenceSet) (a b : SeqGroup P A D) :
    SupportedGroup refs (.seq a b) ↔ SupportedGroup refs a ∧ SupportedGroup refs b := by
  simp [SupportedGroup, flatten]

theorem SupportedGroup.union_left {refs other : ReferenceSet} {group : SeqGroup P A D}
    (h : SupportedGroup refs group) : SupportedGroup (refs.union other) group :=
  SupportedList.union_left h

theorem SupportedGroup.union_right {refs other : ReferenceSet} {group : SeqGroup P A D}
    (h : SupportedGroup other group) : SupportedGroup (refs.union other) group :=
  SupportedList.union_right h

theorem supportedGroup_union_seq {a b : ReferenceSet} {first second : SeqGroup P A D}
    (ha : SupportedGroup a first) (hb : SupportedGroup b second) :
    SupportedGroup (a.union b) (.seq first second) :=
  (supportedGroup_seq _ _ _).mpr ⟨ha.union_left, hb.union_right⟩

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Both sides use the separately implemented recursive interpreter, not a new flat wrapper. -/
theorem runGroup_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) (supported : SupportedGroup refs group) :
    runGroup old boundaries cursor group = runGroup new boundaries cursor group := by
  rw [runGroup_eq_continueRun, runGroup_eq_continueRun]
  exact continueRun_config_eq h boundaries cursor (flatten group) supported

end DefiKernel.Metatheory
