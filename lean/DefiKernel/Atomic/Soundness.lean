import DefiKernel.Atomic.Execution
import DefiKernel.Interleaving.Soundness

/-! Actual atomic steps either preserve a halted machine or take one existing
interleaving step. Every diagnostic machine is an actual interleaving preTokens. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D) :
    Machine P A D → Prop
  | start : Reachable cfg boundaries policy left right initial (Atomic.start initial)
  | next {m : Machine P A D} (branch : BranchId)
      (previous : Reachable cfg boundaries policy left right initial m) :
      Reachable cfg boundaries policy left right initial
        (advance cfg boundaries policy left right m branch)

-- BEGIN PROOFS

/-- Selection of an active real call appends exactly one attempt with the actual result. -/
theorem interleaving_advance_appended (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts =
      m.attempts ++ [⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩] := by
  simp only [Interleaving.advance, active, selected]
  cases he : executeStep cfg (boundaries branch (m.local branch).nextIndex)
      (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world <;> rfl

theorem interleaving_advance_attempt (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts[m.attempts.length]? =
      some ⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩ := by
  rw [interleaving_advance_appended _ _ _ _ _ _ _ active selected]
  simp

theorem advance_entry (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) :
    (advance cfg boundaries policy left right m branch).entryWorld = m.entryWorld := by
  unfold advance
  split
  · rfl
  · dsimp only
    split
    · rfl
    · split
      · rfl
      · split <;> rfl

theorem advance_speculative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).speculative =
      Interleaving.advance cfg boundaries left right m.speculative branch := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_position (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).position = m.position + 1 := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_none_before (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    m.abort = none := by
  cases h : m.abort with
  | none => rfl
  | some reason => simp [advance_aborted _ _ _ _ _ _ _ reason h, h] at active

theorem advance_no_failures (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (old : ∀ b, (m.speculative.local b).failure = none)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    ∀ b, ((advance cfg boundaries policy left right m branch).speculative.local b).failure =
      none := by
  have ha := advance_none_before _ _ _ _ _ _ _ active
  have hl : m.speculative.left.failure = none := old .left
  have hr : m.speculative.right.failure = none := old .right
  intro b
  rw [advance_speculative _ _ _ _ _ _ _ ha]
  cases hs : (selectBranch left right branch)[(m.speculative.local branch).consumed]? with
  | none =>
    simp only [Interleaving.advance, old branch, hs]
    cases branch <;> cases b <;>
      simp [Interleaving.Machine.skip, Interleaving.Machine.setLocal,
        Interleaving.Machine.local, hl, hr]
  | some inv =>
    have hg := interleaving_advance_attempt cfg boundaries left right m.speculative
      branch inv (old branch) hs
    cases he : executeStep cfg (boundaries branch (m.speculative.local branch).nextIndex)
        (m.speculative.local branch).nextIndex (m.speculative.local branch).outputs
        (.invoke inv) m.speculative.world with
    | error reason =>
      rw [he] at hg
      simp only [advance, ha, hg] at active
      contradiction
    | ok result =>
      simp only [Interleaving.advance, old branch, hs, he]
      cases branch <;> cases b <;>
        simp [Interleaving.Machine.accept, Interleaving.Machine.setLocal,
          Interleaving.Machine.local, hl, hr]

theorem Reachable.entry {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    m.entryWorld = initial := by
  induction h with
  | start => rfl
  | next branch previous ih => exact (advance_entry _ _ _ _ _ _ _).trans ih

theorem Reachable.interleaving {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    Interleaving.Reachable cfg boundaries left right initial m.speculative := by
  induction h with
  | start => exact .start
  | @next m branch previous ih =>
    cases ha : m.abort with
    | none =>
      rw [advance_speculative _ _ _ _ _ _ _ ha]
      exact .next branch ih (Interleaving.advance_sound _ _ _ _ _ _)
    | some reason =>
      rw [advance_aborted _ _ _ _ _ _ _ reason ha]
      exact ih

theorem Reachable.no_failures {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m)
    (active : m.abort = none) : ∀ b, (m.speculative.local b).failure = none := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next branch previous ih =>
    exact advance_no_failures _ _ _ _ _ _ _
      (ih (advance_none_before _ _ _ _ _ _ _ active)) active

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D)
    (m : Machine P A D) (h : Reachable cfg boundaries policy left right initial m)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (continueRun cfg boundaries policy left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih => exact ih _ (.next b h)

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (runPrefix cfg boundaries policy initial left right schedule) :=
  continueRun_reachable _ _ _ _ _ _ _ .start _

/-- A witness is a literal preTokens of the supplied schedule, not a reordered trace. -/
theorem continueRun_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (continueRun cfg boundaries policy left right m schedule).speculative =
        Interleaving.continueRun cfg boundaries left right m.speculative preTokens ∧
      (continueRun cfg boundaries policy left right m schedule).position =
        m.position + preTokens.length ∧
      ((continueRun cfg boundaries policy left right m schedule).abort = none →
        suffix = []) := by
  induction schedule generalizing m with
  | nil => exact ⟨[], [], rfl, rfl, (Nat.add_zero _).symm, fun _ => rfl⟩
  | cons b tail ih =>
    cases ha : m.abort with
    | some reason =>
      rw [continueRun_aborted _ _ _ _ _ _ _ reason ha]
      exact ⟨[], b :: tail, rfl, rfl, (Nat.add_zero _).symm, by simp [ha]⟩
    | none =>
      let next := advance cfg boundaries policy left right m b
      obtain ⟨preTokens, suffix, hs, hw, hp, hf⟩ := ih next
      refine ⟨b :: preTokens, suffix, by simp [hs], ?_, ?_, hf⟩
      · change (continueRun cfg boundaries policy left right next tail).speculative = _
        rw [hw]
        rw [show next.speculative = Interleaving.advance cfg boundaries left right
          m.speculative b from advance_speculative _ _ _ _ _ _ _ ha]
        rfl
      · change (continueRun cfg boundaries policy left right next tail).position = _
        rw [hp, show next.position = m.position + 1 from advance_position _ _ _ _ _ _ _ ha]
        simp [Nat.add_comm, Nat.add_left_comm]

theorem runPrefix_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (runPrefix cfg boundaries policy initial left right schedule).speculative =
        Interleaving.runPrefix cfg boundaries initial left right preTokens ∧
      (runPrefix cfg boundaries policy initial left right schedule).position =
        preTokens.length ∧
      ((runPrefix cfg boundaries policy initial left right schedule).abort = none →
        suffix = []) := by
  simpa only [runPrefix, Interleaving.runPrefix, Atomic.start, Nat.zero_add] using
    continueRun_prefix cfg boundaries policy left right (Atomic.start initial) schedule

end DefiKernel.Atomic
