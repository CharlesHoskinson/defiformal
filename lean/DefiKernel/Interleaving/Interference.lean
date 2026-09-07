import DefiKernel.Interleaving.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over arbitrary histories and worlds; they never assume the peer invariant or run result. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each branch proves its own invariant and guarantee from its own invariant alone. -/
def LocalObligation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (invariant : BranchId → LedgerPredicate P A D)
    (guarantee : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (selectBranch left right b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      StepSound cfg (boundaries b index) index history (.invoke inv) pre result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : BranchId → LedgerPredicate P A D)
    (rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

theorem Reachable.two_invariants {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    cases step with
    | halted => simpa only [skip_world] using ih
    | exhausted => simpa only [skip_world] using ih
    | refused => simpa only [refuse_world] using ih
    | accepted inv result active selected executed =>
      have index := previous.attempt_index b active inv selected
      have selected' : (selectBranch left right b)[_]? = some inv := selected
      rw [← index] at selected'
      have own := localObligation b _ inv selected' _ _ _ (ih b)
        (executeStep_sound _ _ _ _ _ _ _ executed)
      intro other
      change invariant other result.world.state
      by_cases same : b = other
      · subst other
        exact own.1
      · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem runPrefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).two_invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains both initialized invariants, including stopped branches. -/
theorem every_prefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial left right (schedule.take length)).world.state :=
  runPrefix_two_invariants cfg boundaries initial left right (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Interleaving
