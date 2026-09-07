import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! The global attempt chain and its branch projections are derived from real execution.
Refusal witnesses refer to the world at that attempt, not the later peer-updated final world. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AttemptChain (initial : World P A D) :
    List (Attempt P A D) → World P A D → Prop
  | empty : AttemptChain initial [] initial
  | success {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {result : StepResult P A D}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .ok result) :
      AttemptChain initial (attempts ++ [attempt]) result.world
  | refusal {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {reason : Composition.Failure}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .error reason) :
      AttemptChain initial (attempts ++ [attempt]) pre

def successfulEvent (b : BranchId) (attempt : Attempt P A D) : Option (Event P A D) :=
  if attempt.branch = b then
    match attempt.outcome with
    | .error _ => none
    | .ok result => some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩
  else none

-- BEGIN PROOFS

theorem Reachable.attempt_chain {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    AttemptChain initial m.attempts m.world := by
  induction h with
  | start => exact .empty
  | next b previous step ih =>
    cases step with
    | halted => simpa [skip_world, skip_attempts] using ih
    | exhausted => simpa [skip_world, skip_attempts] using ih
    | refused inv reason active selected rejected =>
      rw [refuse_world]
      exact .refusal ih rfl rfl
    | accepted inv result active selected executed => exact .success ih rfl rfl

theorem Reachable.branch_projection {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events = m.attempts.filterMap (successfulEvent b) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local,
        successfulEvent, List.filterMap_append]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).outputs = (m.local b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).nextIndex = (m.local b).events.length := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_order {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events.map Event.step =
      ((selectBranch left right b).take (m.local b).nextIndex).map Step.invoke := by
  induction h with
  | start => intro b; cases b <;> rfl
  | @next pre post b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    have ho := ih own
    cases step with
    | halted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | exhausted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | refused =>
      cases b <;> cases own <;>
        simpa [Machine.refuse, Machine.setLocal, Machine.local] using ho
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      have ht : (selectBranch left right b).take ((pre.local b).nextIndex + 1) =
          (selectBranch left right b).take (pre.local b).nextIndex ++ [inv] := by
        rw [hi, List.take_add_one]
        simp [selected]
      cases b <;> cases own <;>
        simp_all [Machine.accept, Machine.setLocal, Machine.local, selectBranch]

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b failure, (m.local b).failure = some failure → failure.index = (m.local b).nextIndex := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih =>
    intro own failure hf
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]
    all_goals cases hf; rfl

theorem AdvanceSound.refusal_stable {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  cases h <;> cases b <;> cases own <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_refusal_stable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := advance cfg boundaries left right m b
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex :=
  (advance_sound cfg boundaries left right m b).refusal_stable own failure failed

theorem continueRun_refusal_stable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Machine P A D) (schedule : Schedule) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := continueRun cfg boundaries left right m schedule
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  induction schedule generalizing m with
  | nil => exact ⟨failed, rfl, rfl, rfl⟩
  | cons b tail ih =>
    have first := advance_refusal_stable cfg boundaries left right m b own failure failed
    have rest := ih _ first.1
    exact ⟨rest.1, rest.2.1.trans first.2.1,
      rest.2.2.1.trans first.2.2.1, rest.2.2.2.trans first.2.2.2⟩

end DefiKernel.Interleaving
