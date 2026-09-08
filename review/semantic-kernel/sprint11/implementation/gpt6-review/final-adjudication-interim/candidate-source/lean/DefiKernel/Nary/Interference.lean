import DefiKernel.Nary.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over an actual `executeStep = .ok` equation, arbitrary own history and current world;
they never assume a peer invariant or the desired whole-run conclusion. Refusal and skip use
world identity. Arbitrary `B` is not specialized to a fixed participant triple. -/
namespace DefiKernel.Nary
open Typed Composition

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each participant proves its own invariant and guarantee from its own invariant and an
actual successful invocation equation. The branch index is the successful local index. -/
def LocalObligation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (invariant : B → LedgerPredicate P A D)
    (guarantee : B → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (branches b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      executeStep cfg (boundaries b index) index history (.invoke inv) pre = .ok result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : B → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : B → LedgerPredicate P A D)
    (rely : B → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem AdvanceSound.preserves_invariants {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {m post : Machine B P A D} {b : B}
    (step : AdvanceSound cfg boundaries branches m b post)
    (ordered : ∀ own, (m.locals own).failure = none →
      (m.locals own).nextIndex = min (m.locals own).consumed (branches own).length)
    (invariant : B → LedgerPredicate P A D)
    (guarantee rely : B → LedgerRelation P A D)
    (ih : ∀ own, invariant own m.world.state)
    (localObligation : LocalObligation cfg boundaries branches invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ own, invariant own post.world.state := by
  cases step with
  | halted => simpa only [skip_world] using ih
  | exhausted => simpa only [skip_world] using ih
  | refused => simpa only [refuse_world] using ih
  | accepted inv result active selected executed =>
    have index := nextIndex_eq_consumed_of_selected branches m b inv (ordered b active) selected
    have selected' : (branches b)[(m.locals b).nextIndex]? = some inv := by
      rwa [index]
    have own := localObligation b (m.locals b).nextIndex inv selected'
      (m.locals b).outputs m.world result (ih b) executed
    intro other
    change invariant other result.world.state
    by_cases same : b = other
    · subst other
      exact own.1
    · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem Reachable.invariants {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m)
    (invariant : B → LedgerPredicate P A D)
    (guarantee rely : B → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries branches invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    exact step.preserves_invariants previous.active_index invariant guarantee rely ih
      localObligation cross stable

theorem runPrefix_invariants (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (invariant : B → LedgerPredicate P A D)
    (guarantee rely : B → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries branches invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial branches schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial branches schedule).invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains every initialized invariant, including stopped streams. -/
theorem every_prefix_invariants (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (invariant : B → LedgerPredicate P A D)
    (guarantee rely : B → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries branches invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial branches (schedule.take length)).world.state :=
  runPrefix_invariants cfg boundaries initial branches (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

theorem continueRun_invariants {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m)
    (invariant : B → LedgerPredicate P A D)
    (guarantee rely : B → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries branches invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely)
    (schedule : Schedule B) :
    ∀ b, invariant b (continueRun cfg boundaries branches m schedule).world.state :=
  (continueRun_reachable cfg boundaries branches initial m h schedule).invariants
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Nary
