import DefiKernel.Interface.Accounting
import DefiKernel.Interleaving.Soundness

/-! Region accounting over the actual globally ordered attempt suffix. Failed attempts
contribute zero; skipped slots append no attempt. The entry machine may have a history. -/
namespace DefiKernel.Interface
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def attemptDelta (region : Region P A D) (attempt : Interleaving.Attempt P A D) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => receiptDelta region result.receipt

def attemptDeltaSum (region : Region P A D)
    (attempts : List (Interleaving.Attempt P A D)) : ℚ :=
  (attempts.map (attemptDelta region)).sum

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
@[simp] theorem attemptDeltaSum_nil (region : Region P A D) :
    attemptDeltaSum region [] = 0 := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
@[simp] theorem attemptDeltaSum_append (region : Region P A D)
    (xs ys : List (Interleaving.Attempt P A D)) :
    attemptDeltaSum region (xs ++ ys) =
      attemptDeltaSum region xs + attemptDeltaSum region ys := by
  simp [attemptDeltaSum, List.sum_append]

theorem interleaving_advance_accounting_suffix (region : Region P A D)
    (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (entry : Interleaving.Machine P A D) (branch : BranchId) :
    ∃ suffix : List (Interleaving.Attempt P A D),
      (Interleaving.advance cfg boundaries left right entry branch).attempts =
        entry.attempts ++ suffix ∧
      balanceSum region (Interleaving.advance cfg boundaries left right entry branch).world.state =
        balanceSum region entry.world.state + attemptDeltaSum region suffix := by
  have sound := Interleaving.advance_sound cfg boundaries left right entry branch
  generalize he : Interleaving.advance cfg boundaries left right entry branch = post at sound ⊢
  cases sound with
  | halted =>
    exact ⟨[], by simp [Interleaving.skip_attempts], by simp [Interleaving.skip_world]⟩
  | exhausted =>
    exact ⟨[], by simp [Interleaving.skip_attempts], by simp [Interleaving.skip_world]⟩
  | refused inv reason active selected rejected =>
    refine ⟨[⟨branch, (entry.local branch).nextIndex, inv, entry.world, .error reason⟩], rfl, ?_⟩
    simp [Interleaving.refuse_world, attemptDeltaSum, attemptDelta]
  | accepted inv result active selected executed =>
    refine ⟨[⟨branch, (entry.local branch).nextIndex, inv, entry.world, .ok result⟩], rfl, ?_⟩
    simpa [Interleaving.accept_world, attemptDeltaSum, attemptDelta] using
      step_receipt_region region executed

theorem interleaving_continueRun_accounting_suffix (region : Region P A D)
    (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (entry : Interleaving.Machine P A D)
    (schedule : Interleaving.Schedule) :
    ∃ suffix : List (Interleaving.Attempt P A D),
      (Interleaving.continueRun cfg boundaries left right entry schedule).attempts =
        entry.attempts ++ suffix ∧
      balanceSum region
          (Interleaving.continueRun cfg boundaries left right entry schedule).world.state =
        balanceSum region entry.world.state + attemptDeltaSum region suffix := by
  induction schedule generalizing entry with
  | nil => exact ⟨[], by simp [Interleaving.continueRun], by simp [Interleaving.continueRun]⟩
  | cons branch schedule ih =>
    obtain ⟨first, he, hb⟩ :=
      interleaving_advance_accounting_suffix region cfg boundaries left right entry branch
    obtain ⟨tail, ht, hbt⟩ := ih (Interleaving.advance cfg boundaries left right entry branch)
    refine ⟨first ++ tail, ?_, ?_⟩
    · simpa [Interleaving.continueRun, List.foldl_cons, he, List.append_assoc] using ht
    · change balanceSum region (Interleaving.continueRun cfg boundaries left right
        (Interleaving.advance cfg boundaries left right entry branch) schedule).world.state = _
      rw [hbt, hb, attemptDeltaSum_append]
      ring

theorem interleaving_continueRun_accounting (region : Region P A D)
    (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (entry : Interleaving.Machine P A D)
    (schedule : Interleaving.Schedule) :
    balanceSum region
        (Interleaving.continueRun cfg boundaries left right entry schedule).world.state =
      balanceSum region entry.world.state + attemptDeltaSum region
        ((Interleaving.continueRun cfg boundaries left right entry schedule).attempts.drop
          entry.attempts.length) := by
  obtain ⟨suffix, he, hb⟩ :=
    interleaving_continueRun_accounting_suffix region cfg boundaries left right entry schedule
  simpa [he] using hb

theorem interleaving_runPrefix_accounting (region : Region P A D)
    (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule) :
    balanceSum region
        (Interleaving.runPrefix cfg boundaries initial left right schedule).world.state =
      balanceSum region initial.state + attemptDeltaSum region
        (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts := by
  simpa [Interleaving.runPrefix, Interleaving.start] using
    interleaving_continueRun_accounting region cfg boundaries left right
      (Interleaving.start initial) schedule

end DefiKernel.Interface
