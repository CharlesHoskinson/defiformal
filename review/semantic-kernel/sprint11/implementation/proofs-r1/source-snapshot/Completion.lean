import DefiKernel.Nary.Trace

/-! Complete-schedule outcome laws. Admission refusals are already identified in Execution.
Complete active streams exhaust their invocations; failed streams retain the first located
refusal recorded by the actual trace. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (h : Complete branches schedule) (b : B) :
    ((runPrefix cfg boundaries initial branches schedule).locals b).consumed =
      (branches b).length :=
  (runPrefix_consumed cfg boundaries initial branches schedule b).trans (h b)

theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (complete : Complete branches schedule) (b : B)
    (active : ((runPrefix cfg boundaries initial branches schedule).locals b).failure = none) :
    ((runPrefix cfg boundaries initial branches schedule).locals b).nextIndex =
      (branches b).length := by
  have h := (runPrefix_reachable cfg boundaries initial branches schedule).active_index b active
  rw [runPrefix_consumed, complete b, Nat.min_self] at h
  exact h

theorem runPrefix_complete_exhausted_or_refused (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (complete : Complete branches schedule) (b : B) :
    (((runPrefix cfg boundaries initial branches schedule).locals b).failure = none ∧
      ((runPrefix cfg boundaries initial branches schedule).locals b).nextIndex =
        (branches b).length) ∨
    ∃ failure,
      ((runPrefix cfg boundaries initial branches schedule).locals b).failure = some failure ∧
      failure.index =
        ((runPrefix cfg boundaries initial branches schedule).locals b).nextIndex := by
  cases h : ((runPrefix cfg boundaries initial branches schedule).locals b).failure with
  | none =>
    exact .inl ⟨rfl, runPrefix_complete_active_exhaustion cfg boundaries initial branches
      schedule complete b h⟩
  | some failure =>
    exact .inr ⟨failure, rfl,
      (runPrefix_reachable cfg boundaries initial branches schedule).failure_index b failure h⟩

end DefiKernel.Nary
