import DefiKernel.Atomic.Soundness
import DefiKernel.Atomic.Admission
import DefiKernel.Interleaving.Completion

/-! Committing requires no earlier abort and full typed clearance. Complete active
atomic runs agree with the supplied complete interleaving, including local exhaustion. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem finish_commit_data (label label' : Nat) (schedule schedule' : Schedule)
    (policy : Policy P A D) (m m' : Machine P A D)
    (h : finish label schedule policy m = .committed label' schedule' m') :
    label = label' ∧ schedule = schedule' ∧ m = m' ∧
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  cases ha : m.abort with
  | some reason => simp [finish, ha] at h
  | none =>
    cases hr : residuals policy m.outstanding with
    | nil =>
      simp only [finish, ha, hr, Result.committed.injEq] at h
      exact ⟨h.1, h.2.1, h.2.2, rfl, rfl⟩
    | cons r rest => simp [finish, ha, hr] at h

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem finish_commit_iff (label : Nat) (schedule : Schedule)
    (policy : Policy P A D) (m : Machine P A D) :
    finish label schedule policy m = .committed label schedule m ↔
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  constructor
  · intro h
    exact (finish_commit_data _ _ _ _ _ _ _ h).2.2.2
  · rintro ⟨ha, hr⟩
    simp [finish, ha, hr]

theorem runAtomic_commit_data (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) :
    ∃ lf rf, admit cfg boundaries policy left right schedule = .ok (lf, rf) ∧
      m = runPrefix cfg boundaries policy initial left right schedule ∧
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  cases ha : admit cfg boundaries policy left right schedule with
  | error reason => simp [runAtomic, ha] at h
  | ok pair =>
    simp only [runAtomic, ha] at h
    obtain ⟨_, _, hm, habort, hr⟩ := finish_commit_data _ _ _ _ _ _ _ h
    subst m
    exact ⟨pair.1, pair.2, rfl, rfl, habort, hr⟩

theorem runPrefix_active_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (active : (runPrefix cfg boundaries policy initial left right schedule).abort = none) :
    (runPrefix cfg boundaries policy initial left right schedule).speculative =
      Interleaving.runPrefix cfg boundaries initial left right schedule := by
  obtain ⟨preTokens, suffix, hs, hm, _, hf⟩ :=
    runPrefix_prefix cfg boundaries policy initial left right schedule
  have empty := hf active
  subst suffix
  simp only [List.append_nil] at hs
  subst schedule
  exact hm

theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (complete : Complete left right schedule)
    (active : (runPrefix cfg boundaries policy initial left right schedule).abort = none)
    (b : BranchId) :
    ((runPrefix cfg boundaries policy initial left right schedule).speculative.local b).failure =
      none ∧
    ((runPrefix cfg boundaries policy initial left right schedule).speculative.local b).nextIndex =
      (selectBranch left right b).length := by
  have hf := (runPrefix_reachable cfg boundaries policy initial left right schedule).no_failures
    active b
  refine ⟨hf, ?_⟩
  rw [runPrefix_active_interleaving _ _ _ _ _ _ _ active] at hf ⊢
  exact Interleaving.runPrefix_complete_active_exhaustion _ _ _ _ _ _ complete b hf

theorem runAtomic_commit_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) :
    Interleaving.runInterleaving cfg boundaries initial left right schedule =
      .executed schedule m.speculative ∧
    ∀ b, (m.speculative.local b).failure = none ∧
      (m.speculative.local b).nextIndex = (selectBranch left right b).length := by
  obtain ⟨lf, rf, ha, rfl, active, _⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ h
  have hi := admit_interleaving _ _ _ _ _ _ _ _ ha
  have complete := (admit_ok _ _ _ _ _ _ _ _ ha).2.2.2.2
  constructor
  · rw [Interleaving.runInterleaving, hi, runPrefix_active_interleaving _ _ _ _ _ _ _ active]
  · exact runPrefix_complete_active_exhaustion _ _ _ _ _ _ _ complete active

end DefiKernel.Atomic
