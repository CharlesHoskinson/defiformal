import DefiKernel.Nary.Soundness
import DefiKernel.Nary.LocalOrder

/-! The global attempt chain and its participant projections are derived from real execution.
Refusal witnesses refer to the world at that attempt, not a later peer-updated final world. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AttemptChain (initial : World P A D) :
    List (Attempt B P A D) → World P A D → Prop
  | empty : AttemptChain initial [] initial
  | success {attempts : List (Attempt B P A D)} {pre : World P A D}
      {attempt : Attempt B P A D} {result : StepResult P A D}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .ok result) :
      AttemptChain initial (attempts ++ [attempt]) result.world
  | refusal {attempts : List (Attempt B P A D)} {pre : World P A D}
      {attempt : Attempt B P A D} {reason : Composition.Failure}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .error reason) :
      AttemptChain initial (attempts ++ [attempt]) pre

def successfulEvent (b : B) (attempt : Attempt B P A D) : Option (Event P A D) :=
  if attempt.participant = b then
    match attempt.outcome with
    | .error _ => none
    | .ok result => some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩
  else none

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem successfulEvent_ok (b : B) (attempt : Attempt B P A D) (result : StepResult P A D)
    (hp : attempt.participant = b) (ho : attempt.outcome = .ok result) :
    successfulEvent b attempt =
      some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩ := by
  simp [successfulEvent, hp, ho]

theorem successfulEvent_error (b : B) (attempt : Attempt B P A D)
    (reason : Composition.Failure) (hp : attempt.participant = b)
    (ho : attempt.outcome = .error reason) :
    successfulEvent b attempt = none := by
  simp [successfulEvent, hp, ho]

theorem successfulEvent_other (b : B) (attempt : Attempt B P A D)
    (h : attempt.participant ≠ b) : successfulEvent b attempt = none := by
  simp [successfulEvent, h]

theorem Reachable.attempt_chain {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
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
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).events = m.attempts.filterMap (successfulEvent b) := by
  induction h with
  | start =>
    intro b
    simp [start]
  | next b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected, skip_attempts] using ih b
      · simpa [skip_away m b own ho, skip_attempts] using ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected, skip_attempts] using ih b
      · simpa [skip_away m b own ho, skip_attempts] using ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simp [refuse_selected, refuse_attempts, List.filterMap_append, ih b,
          successfulEvent]
      · simp [refuse_away m b own inv reason ho, refuse_attempts, List.filterMap_append,
          ih own, successfulEvent, Ne.symm ho]
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected, accept_attempts, List.filterMap_append, ih b,
          successfulEvent]
      · simp [accept_away m b own inv result ho, accept_attempts, List.filterMap_append,
          ih own, successfulEvent, Ne.symm ho]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).outputs =
      (m.locals b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start =>
    intro b
    simp [start]
  | next b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away m b own ho] using ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away m b own ho] using ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · simpa [refuse_away m b own inv reason ho] using ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected, ih b]
      · simpa [accept_away m b own inv result ho] using ih own

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).nextIndex = (m.locals b).events.length := by
  induction h with
  | start =>
    intro b
    simp [start]
  | next b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away m b own ho] using ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away m b own ho] using ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · simpa [refuse_away m b own inv reason ho] using ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simpa [accept_selected] using ih b
      · simpa [accept_away m b own inv result ho] using ih own

theorem Reachable.local_order {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).events.map Event.step =
      ((branches b).take (m.locals b).nextIndex).map Step.invoke := by
  induction h with
  | start =>
    intro b
    simp [start]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away pre b own ho] using ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · simpa [skip_away pre b own ho] using ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · simpa [refuse_away pre b own inv reason ho] using ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        have hi := previous.attempt_index b active inv selected
        have ht : (branches b).take ((pre.locals b).nextIndex + 1) =
            (branches b).take (pre.locals b).nextIndex ++ [inv] := by
          rw [hi, List.take_add_one]
          simp [selected]
        simp [accept_selected, ih b, ht]
      · simpa [accept_away pre b own inv result ho] using ih own

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b failure, (m.locals b).failure = some failure →
      failure.index = (m.locals b).nextIndex := by
  induction h with
  | start =>
    intro b failure hf
    simp [start] at hf
  | next b previous step ih =>
    intro own failure hf
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simp [skip_selected] at hf ⊢
        exact ih b failure hf
      · rw [skip_away m b own ho] at hf ⊢
        exact ih own failure hf
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simp [skip_selected] at hf ⊢
        exact ih b failure hf
      · rw [skip_away m b own ho] at hf ⊢
        exact ih own failure hf
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simp [refuse_selected] at hf ⊢
        cases hf
        rfl
      · rw [refuse_away m b own inv reason ho] at hf ⊢
        exact ih own failure hf
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected] at hf
      · rw [accept_away m b own inv result ho] at hf ⊢
        exact ih own failure hf

theorem AdvanceSound.refusal_stable {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) (own : B)
    (failure : LocatedFailure P A D) (failed : (m.locals own).failure = some failure) :
    (post.locals own).failure = some failure ∧
      (post.locals own).events = (m.locals own).events ∧
      (post.locals own).outputs = (m.locals own).outputs ∧
      (post.locals own).nextIndex = (m.locals own).nextIndex := by
  cases h with
  | halted =>
    by_cases ho : own = b
    · subst own
      simp [skip_selected, failed]
    · simp [skip_away m b own ho, failed]
  | exhausted oldActive =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · simp [skip_away m b own ho, failed]
  | refused inv reason oldActive selected rejected =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · simp [refuse_away m b own inv reason ho, failed]
  | accepted inv result oldActive selected executed =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · simp [accept_away m b own inv result ho, failed]

theorem advance_refusal_stable (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b own : B)
    (failure : LocatedFailure P A D) (failed : (m.locals own).failure = some failure) :
    let post := advance cfg boundaries branches m b
    (post.locals own).failure = some failure ∧
      (post.locals own).events = (m.locals own).events ∧
      (post.locals own).outputs = (m.locals own).outputs ∧
      (post.locals own).nextIndex = (m.locals own).nextIndex :=
  (advance_sound cfg boundaries branches m b).refusal_stable own failure failed

theorem continueRun_refusal_stable (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (m : Machine B P A D) (schedule : Schedule B) (own : B)
    (failure : LocatedFailure P A D) (failed : (m.locals own).failure = some failure) :
    let post := continueRun cfg boundaries branches m schedule
    (post.locals own).failure = some failure ∧
      (post.locals own).events = (m.locals own).events ∧
      (post.locals own).outputs = (m.locals own).outputs ∧
      (post.locals own).nextIndex = (m.locals own).nextIndex := by
  induction schedule generalizing m with
  | nil => exact ⟨failed, rfl, rfl, rfl⟩
  | cons b tail ih =>
    have first := advance_refusal_stable cfg boundaries branches m b own failure failed
    have rest := ih _ first.1
    exact ⟨rest.1, rest.2.1.trans first.2.1,
      rest.2.2.1.trans first.2.2.1, rest.2.2.2.trans first.2.2.2⟩

end DefiKernel.Nary
