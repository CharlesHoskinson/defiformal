import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Settlement

/-! The converse uses only actual underlying attempts, their receipt supply checks, and
clearance of an independent receipt fold. It does not assume an atomic outcome or agreement. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Each actual underlying attempt succeeded and its actual receipt obeyed lane supply policy. -/
def GoodAttempts (policy : Policy P A D) (attempts : List (Attempt P A D)) : Prop :=
  ∀ attempt ∈ attempts, ∃ result, attempt.outcome = .ok result ∧
    checkSupply policy result.receipt = none

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem GoodAttempts.sublist {policy : Policy P A D} {xs ys : List (Attempt P A D)}
    (h : GoodAttempts policy ys) (sub : xs.Sublist ys) : GoodAttempts policy xs :=
  fun attempt member ↦ h attempt (sub.subset member)

theorem interleaving_advance_attempts_sublist (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (b : BranchId) :
    m.attempts.Sublist (Interleaving.advance cfg boundaries left right m b).attempts := by
  cases hf : (m.local b).failure with
  | some failure => simp [Interleaving.advance, hf, skip_attempts]
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none => simp [Interleaving.advance, hf, hs, skip_attempts]
    | some inv =>
      rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
      exact List.sublist_append_left _ _

theorem interleaving_continueRun_attempts_sublist (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (schedule : Schedule) :
    m.attempts.Sublist
      (Interleaving.continueRun cfg boundaries left right m schedule).attempts := by
  induction schedule generalizing m with
  | nil => exact List.Sublist.refl _
  | cons b tail ih =>
    exact (interleaving_advance_attempts_sublist _ _ _ _ _ _).trans (ih _)

/-- A successful, policy-compliant actual next attempt cannot create an atomic abort. -/
theorem advance_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (active : m.abort = none)
    (good : GoodAttempts policy
      (Interleaving.advance cfg boundaries left right m.speculative b).attempts) :
    (advance cfg boundaries policy left right m b).abort = none := by
  cases hg : (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
      m.speculative.attempts.length]? with
  | none => simp [advance, active, hg]
  | some attempt =>
    have hm := List.mem_of_getElem? hg
    obtain ⟨result, he, hs⟩ := good attempt hm
    simp [advance, active, hg, he, hs]

/-- Final actual-trace premises propagate backward to each prefix by attempt-list inclusion. -/
theorem continueRun_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule)
    (active : m.abort = none)
    (good : GoodAttempts policy
      (Interleaving.continueRun cfg boundaries left right m.speculative schedule).attempts) :
    (continueRun cfg boundaries policy left right m schedule).abort = none := by
  induction schedule generalizing m with
  | nil => exact active
  | cons b tail ih =>
    have hsub := interleaving_continueRun_attempts_sublist cfg boundaries left right
      (Interleaving.advance cfg boundaries left right m.speculative b) tail
    have hgood := good.sublist hsub
    have hactive := advance_no_abort_of_good_attempts cfg boundaries policy left right m b
      active hgood
    apply ih (advance cfg boundaries policy left right m b) hactive
    rw [advance_speculative _ _ _ _ _ _ _ active]
    exact good

theorem runPrefix_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (good : GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) :
    (runPrefix cfg boundaries policy initial left right schedule).abort = none :=
  continueRun_no_abort_of_good_attempts cfg boundaries policy left right (Atomic.start initial)
    schedule rfl good

/-- Noncircular converse: successful underlying receipts and full independent-fold clearance
suffice to commit an admitted atomic event. -/
theorem runAtomic_commit_of_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (admitted : admit cfg boundaries policy left right schedule = .ok (lf, rf))
    (good : GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts)
    (cleared : residuals policy (outstandingFromAttempts policy boundaries
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) = []) :
    runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule (runPrefix cfg boundaries policy initial left right schedule) := by
  have active := runPrefix_no_abort_of_good_attempts cfg boundaries policy initial left right
    schedule good
  have hf :=
    (runPrefix_reachable cfg boundaries policy initial left right schedule).outstanding_fold
  rw [runPrefix_active_interleaving _ _ _ _ _ _ _ active] at hf
  have hc : residuals policy
      (runPrefix cfg boundaries policy initial left right schedule).outstanding = [] := by
    rw [hf]
    exact cleared
  simp only [runAtomic, admitted]
  exact (finish_commit_iff _ _ _ _).mpr ⟨active, hc⟩

/-- Remaining active proves that an actual appended attempt succeeded and passed supply policy. -/
theorem advance_last_good (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (b : BranchId) (attempt : Attempt P A D)
    (active : (advance cfg boundaries policy left right m b).abort = none)
    (appended : getElem?
      (Interleaving.advance cfg boundaries left right m.speculative b).attempts
      m.speculative.attempts.length = some attempt) :
    ∃ result, attempt.outcome = .ok result ∧ checkSupply policy result.receipt = none := by
  have old := advance_none_before _ _ _ _ _ _ _ active
  cases he : attempt.outcome with
  | error reason => simp [advance, old, appended, he] at active
  | ok result =>
    refine ⟨result, rfl, ?_⟩
    cases hs : checkSupply policy result.receipt with
    | none => rfl
    | some pair => simp [advance, old, appended, he, hs] at active

theorem advance_goodAttempts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (old : GoodAttempts policy m.speculative.attempts)
    (active : (advance cfg boundaries policy left right m b).abort = none) :
    GoodAttempts policy (advance cfg boundaries policy left right m b).speculative.attempts := by
  have ha := advance_none_before _ _ _ _ _ _ _ active
  rw [advance_speculative _ _ _ _ _ _ _ ha]
  cases hf : (m.speculative.local b).failure with
  | some failure => simpa only [Interleaving.advance, hf, skip_attempts] using old
  | none =>
    cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
    | none => simpa only [Interleaving.advance, hf, hs, skip_attempts] using old
    | some inv =>
      have hg := interleaving_advance_attempt cfg boundaries left right m.speculative b inv hf hs
      have hlast := advance_last_good _ _ _ _ _ _ _ _ active hg
      rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
      intro attempt member
      rcases List.mem_append.mp member with earlier | latest
      · exact old attempt earlier
      · have he := List.mem_singleton.mp latest
        subst attempt
        exact hlast

theorem Reachable.goodAttempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m)
    (active : m.abort = none) : GoodAttempts policy m.speculative.attempts := by
  induction h with
  | start => simp [GoodAttempts, Atomic.start, Interleaving.start]
  | next b previous ih =>
    exact advance_goodAttempts _ _ _ _ _ _ _
      (ih (advance_none_before _ _ _ _ _ _ _ active)) active

/-- Bidirectional criterion on actual underlying execution and its independently derived debt. -/
theorem runAtomic_commit_iff_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (admitted : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule (runPrefix cfg boundaries policy initial left right schedule) ↔
    GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts ∧
      residuals policy (outstandingFromAttempts policy boundaries
        (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) = [] := by
  constructor
  · intro committed
    obtain ⟨_, _, _, _, active, cleared⟩ :=
      runAtomic_commit_data _ _ _ _ _ _ _ _ _ committed
    have reach := runPrefix_reachable cfg boundaries policy initial left right schedule
    have agreement := runPrefix_active_interleaving _ _ _ _ _ _ _ active
    have good := reach.goodAttempts active
    have fold := reach.outstanding_fold
    rw [agreement] at good fold
    exact ⟨good, by rwa [fold] at cleared⟩
  · rintro ⟨good, cleared⟩
    exact runAtomic_commit_of_interleaving _ _ _ _ _ _ _ _ _ _ admitted good cleared

/-- A committed event restores each configured lane vault exactly, for arbitrary typed policies. -/
theorem runAtomic_commit_cash (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell = initial.state.balance lane.cell := by
  obtain ⟨lf, rf, ha, rfl, _, hc⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ committed
  exact (runPrefix_reachable _ _ _ _ _ _ _).cleared_cash
    (admit_ok _ _ _ _ _ _ _ _ ha).2.2.2.1 hc lane hlane

end DefiKernel.Atomic
