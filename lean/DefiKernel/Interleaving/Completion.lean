import DefiKernel.Interleaving.Trace

/-! Public refusal and complete-schedule outcome laws. Admission refusals contain the exact
reason, unchanged initial world and supplied schedule; their constructor has no attempts or
outputs. The canonical comparator intentionally ignores the supplied schedule even for refused
results. It compares their exact reasons and full worlds instead; raw Result equality retains
that schedule. Complete active branches exhaust their invocations; failed branches retain the
exact failure recorded by the actual trace. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- A preflight refusal returns the unchanged initial world without an execution payload. -/
theorem runInterleaving_admission_refusal (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (reason : DefiKernel.Interleaving.AdmissionFailure P A D)
    (h : DefiKernel.Interleaving.admit cfg boundaries left right schedule = .error reason) :
    runInterleaving cfg boundaries initial left right schedule =
      .refused reason initial schedule := by
  simp only [runInterleaving, h]

/-- Every active branch of a complete schedule has successfully exhausted its static slots. -/
theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId)
    (active : ((runPrefix cfg boundaries initial left right schedule).local b).failure = none) :
    ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
      (selectBranch left right b).length := by
  have h := (runPrefix_reachable cfg boundaries initial left right schedule).active_index b active
  rw [runPrefix_consumed] at h
  cases b <;> simpa only [selectBranch, complete.1, complete.2, Nat.min_self] using h

/-- Every branch is either exhausted without failure or retains its exact located refusal. -/
theorem runPrefix_complete_exhausted_or_refused (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId) :
    (((runPrefix cfg boundaries initial left right schedule).local b).failure = none ∧
      ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
        (selectBranch left right b).length) ∨
    ∃ failure,
      ((runPrefix cfg boundaries initial left right schedule).local b).failure = some failure ∧
      failure.index =
        ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex := by
  cases h : ((runPrefix cfg boundaries initial left right schedule).local b).failure with
  | none => exact .inl ⟨rfl,
      runPrefix_complete_active_exhaustion cfg boundaries initial left right schedule complete b h⟩
  | some failure => exact .inr ⟨failure, rfl,
      (runPrefix_reachable cfg boundaries initial left right schedule).failure_index b failure h⟩

end DefiKernel.Interleaving
