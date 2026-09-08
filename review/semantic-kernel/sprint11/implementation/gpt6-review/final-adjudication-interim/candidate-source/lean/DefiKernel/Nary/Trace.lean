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

/-- Flattened successful outputs of one participant from a prefix of the global attempt list. -/
def ownHistory (attempts : List (Attempt B P A D)) (b : B) : List (OutputObservation A) :=
  (attempts.filterMap (successfulEvent b)).flatMap (fun event ↦ event.result.outputs)

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
    simp [start_locals, start_attempts]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected, skip_attempts] using ih b
      · rw [skip_away pre b own ho, skip_attempts]
        exact ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected, skip_attempts] using ih b
      · rw [skip_away pre b own ho, skip_attempts]
        exact ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simp [refuse_selected, refuse_attempts, List.filterMap_append, ih b,
          successfulEvent]
      · rw [refuse_away pre b own inv reason ho, refuse_attempts, List.filterMap_append,
          ih own]
        simp [successfulEvent, Ne.symm ho]
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected, accept_attempts, List.filterMap_append, ih b,
          successfulEvent]
      · rw [accept_away pre b own inv result ho, accept_attempts, List.filterMap_append,
          ih own]
        simp [successfulEvent, Ne.symm ho]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).outputs =
      (m.locals b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start =>
    intro b
    simp [start_locals]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · rw [refuse_away pre b own inv reason ho]
        exact ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected, ih b]
      · rw [accept_away pre b own inv result ho]
        exact ih own

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).nextIndex = (m.locals b).events.length := by
  induction h with
  | start =>
    intro b
    simp [start_locals]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · rw [refuse_away pre b own inv reason ho]
        exact ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simpa [accept_selected] using ih b
      · rw [accept_away pre b own inv result ho]
        exact ih own

theorem Reachable.local_order {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).events.map Event.step =
      ((branches b).take (m.locals b).nextIndex).map Step.invoke := by
  induction h with
  | start =>
    intro b
    simp [start_locals]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · rw [refuse_away pre b own inv reason ho]
        exact ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        have hi := previous.attempt_index b active inv selected
        have ht : (branches b).take ((pre.locals b).nextIndex + 1) =
            (branches b).take (pre.locals b).nextIndex ++ [inv] := by
          rw [hi, List.take_add_one]
          simp [selected]
        simp [accept_selected, ih b, ht]
      · rw [accept_away pre b own inv result ho]
        exact ih own

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b failure, (m.locals b).failure = some failure →
      failure.index = (m.locals b).nextIndex := by
  induction h with
  | start =>
    intro b failure hf
    simp [start_locals] at hf
  | @next pre post b previous step ih =>
    intro own failure hf
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simp [skip_selected] at hf ⊢
        exact ih b failure hf
      · rw [skip_away pre b own ho] at hf ⊢
        exact ih own failure hf
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simp [skip_selected] at hf ⊢
        exact ih b failure hf
      · rw [skip_away pre b own ho] at hf ⊢
        exact ih own failure hf
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simp [refuse_selected] at hf ⊢
        cases hf
        rfl
      · rw [refuse_away pre b own inv reason ho] at hf ⊢
        exact ih own failure hf
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        simp [accept_selected] at hf
      · rw [accept_away pre b own inv result ho] at hf ⊢
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
    · rw [skip_away m b own ho]
      exact ⟨failed, rfl, rfl, rfl⟩
  | exhausted oldActive =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · rw [skip_away m b own ho]
      exact ⟨failed, rfl, rfl, rfl⟩
  | refused inv reason oldActive selected rejected =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · rw [refuse_away m b own inv reason ho]
      exact ⟨failed, rfl, rfl, rfl⟩
  | accepted inv result oldActive selected executed =>
    by_cases ho : own = b
    · subst own
      simp [oldActive] at failed
    · rw [accept_away m b own inv result ho]
      exact ⟨failed, rfl, rfl, rfl⟩

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

/-- Genesis: local event indices are exactly `0 .. events.length - 1`.
`nextIndex = events.length` is a separate length identity. -/
theorem Reachable.event_index_seq {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).events.map Event.index = List.range (m.locals b).events.length := by
  induction h with
  | start =>
    intro b
    simp [start_locals]
  | @next pre post b previous step ih =>
    intro own
    cases step with
    | halted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | exhausted =>
      by_cases ho : own = b
      · subst own
        simpa [skip_selected] using ih b
      · rw [skip_away pre b own ho]
        exact ih own
    | refused inv reason active selected rejected =>
      by_cases ho : own = b
      · subst own
        simpa [refuse_selected] using ih b
      · rw [refuse_away pre b own inv reason ho]
        exact ih own
    | accepted inv result active selected executed =>
      by_cases ho : own = b
      · subst own
        have hlen := previous.local_event_index b
        simp [accept_selected, ih b, hlen, List.map_append, List.range_succ]
      · rw [accept_away pre b own inv result ho]
        exact ih own

theorem Reachable.event_index_at {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (b : B) (n : Nat)
    (event : Event P A D) (hn : (m.locals b).events[n]? = some event) :
    event.index = n := by
  have hs := h.event_index_seq b
  have hlt := (List.getElem?_eq_some_iff.mp hn).1
  have hmap : ((m.locals b).events.map Event.index)[n]? = some event.index := by
    simpa [List.getElem?_map] using congrArg (Option.map Event.index) hn
  rw [hs, List.getElem?_range hlt] at hmap
  exact Option.some.inj hmap.symm

theorem Reachable.own_history {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).outputs = ownHistory m.attempts b := by
  intro b
  rw [h.local_history b, h.branch_projection b]
  rfl

/-- The attempt-list prefix ending just before index `i` reconstructs that attempt's
pre-world. Genesis `AttemptChain` only; not a claim about synthetic entry machines. -/
theorem AttemptChain.prefix_before {initial : World P A D}
    {attempts : List (Attempt B P A D)} {world : World P A D}
    (h : AttemptChain initial attempts world) (i : Nat)
    (attempt : Attempt B P A D) (hi : attempts[i]? = some attempt) :
    AttemptChain initial (attempts.take i) attempt.before := by
  induction h generalizing i attempt with
  | empty =>
    simp at hi
  | @success attempts pre newAttempt result previous before outcome ih =>
    cases Nat.lt_or_ge i attempts.length with
    | inl hlt =>
      rw [List.getElem?_append_left hlt] at hi
      rw [List.take_append_of_le_length (Nat.le_of_lt hlt)]
      exact ih i attempt hi
    | inr hge =>
      have hlen : i = attempts.length := by
        obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
        simp [List.length_append] at hi_lt
        exact Nat.eq_of_le_of_lt_succ hge hi_lt
      subst i
      rw [List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
      simp at hi
      subst attempt
      rw [List.take_append_length]
      rwa [before]
  | @refusal attempts pre newAttempt reason previous before outcome ih =>
    cases Nat.lt_or_ge i attempts.length with
    | inl hlt =>
      rw [List.getElem?_append_left hlt] at hi
      rw [List.take_append_of_le_length (Nat.le_of_lt hlt)]
      exact ih i attempt hi
    | inr hge =>
      have hlen : i = attempts.length := by
        obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
        simp [List.length_append] at hi_lt
        exact Nat.eq_of_le_of_lt_succ hge hi_lt
      subst i
      rw [List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
      simp at hi
      subst attempt
      rw [List.take_append_length]
      rwa [before]

/-- Genesis: the stored attempt at global index `i` is the actual `executeStep` that used
that participant's own successful outputs from the strict attempt prefix, at the then-current
successful index. First-refusal and skip tokens do not invent a different history. -/
theorem Reachable.attempt_exact {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (i : Nat)
    (attempt : Attempt B P A D) (hi : m.attempts[i]? = some attempt) :
    executeStep cfg (boundaries attempt.participant attempt.index) attempt.index
        (ownHistory (m.attempts.take i) attempt.participant)
        (.invoke attempt.invocation) attempt.before = attempt.outcome ∧
      attempt.index =
        ((m.attempts.take i).filterMap (successfulEvent attempt.participant)).length ∧
      AttemptChain initial (m.attempts.take i) attempt.before := by
  refine ⟨?_, ?_, h.attempt_chain.prefix_before i attempt hi⟩
  · induction h generalizing i attempt with
    | start =>
      simp [start_attempts] at hi
    | @next pre post b previous step ih =>
      cases step with
      | halted =>
        simpa [skip_attempts] using ih i attempt hi
      | exhausted =>
        simpa [skip_attempts] using ih i attempt hi
      | refused inv reason active selected rejected =>
        cases Nat.lt_or_ge i pre.attempts.length with
        | inl hlt =>
          rw [refuse_attempts, List.getElem?_append_left hlt] at hi
          rw [refuse_attempts, List.take_append_of_le_length (Nat.le_of_lt hlt)]
          exact ih i attempt hi
        | inr hge =>
          have hlen : i = pre.attempts.length := by
            obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
            simp [refuse_attempts, List.length_append] at hi_lt
            exact Nat.eq_of_le_of_lt_succ hge hi_lt
          subst i
          rw [refuse_attempts, List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
          simp at hi
          subst attempt
          rw [refuse_attempts, List.take_append_length]
          have hout := previous.own_history b
          simpa [hout] using rejected
      | accepted inv result active selected executed =>
        cases Nat.lt_or_ge i pre.attempts.length with
        | inl hlt =>
          rw [accept_attempts, List.getElem?_append_left hlt] at hi
          rw [accept_attempts, List.take_append_of_le_length (Nat.le_of_lt hlt)]
          exact ih i attempt hi
        | inr hge =>
          have hlen : i = pre.attempts.length := by
            obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
            simp [accept_attempts, List.length_append] at hi_lt
            exact Nat.eq_of_le_of_lt_succ hge hi_lt
          subst i
          rw [accept_attempts, List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
          simp at hi
          subst attempt
          rw [accept_attempts, List.take_append_length]
          have hout := previous.own_history b
          simpa [hout] using executed
  · induction h generalizing i attempt with
    | start =>
      simp [start_attempts] at hi
    | @next pre post b previous step ih =>
      cases step with
      | halted =>
        simpa [skip_attempts] using ih i attempt hi
      | exhausted =>
        simpa [skip_attempts] using ih i attempt hi
      | refused inv reason active selected rejected =>
        cases Nat.lt_or_ge i pre.attempts.length with
        | inl hlt =>
          rw [refuse_attempts, List.getElem?_append_left hlt] at hi
          rw [refuse_attempts, List.take_append_of_le_length (Nat.le_of_lt hlt)]
          exact ih i attempt hi
        | inr hge =>
          have hlen : i = pre.attempts.length := by
            obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
            simp [refuse_attempts, List.length_append] at hi_lt
            exact Nat.eq_of_le_of_lt_succ hge hi_lt
          subst i
          rw [refuse_attempts, List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
          simp at hi
          subst attempt
          rw [refuse_attempts, List.take_append_length]
          have hidx := previous.local_event_index b
          have hproj := previous.branch_projection b
          simp [hidx, hproj]
      | accepted inv result active selected executed =>
        cases Nat.lt_or_ge i pre.attempts.length with
        | inl hlt =>
          rw [accept_attempts, List.getElem?_append_left hlt] at hi
          rw [accept_attempts, List.take_append_of_le_length (Nat.le_of_lt hlt)]
          exact ih i attempt hi
        | inr hge =>
          have hlen : i = pre.attempts.length := by
            obtain ⟨hi_lt, _⟩ := List.getElem?_eq_some_iff.mp hi
            simp [accept_attempts, List.length_append] at hi_lt
            exact Nat.eq_of_le_of_lt_succ hge hi_lt
          subst i
          rw [accept_attempts, List.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hi
          simp at hi
          subst attempt
          rw [accept_attempts, List.take_append_length]
          have hidx := previous.local_event_index b
          have hproj := previous.branch_projection b
          simp [hidx, hproj]

theorem runPrefix_event_index_seq (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) (b : B) :
    ((runPrefix cfg boundaries initial branches schedule).locals b).events.map Event.index =
      List.range
        ((runPrefix cfg boundaries initial branches schedule).locals b).events.length :=
  (runPrefix_reachable cfg boundaries initial branches schedule).event_index_seq b

theorem runPrefix_attempt_exact (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (i : Nat) (attempt : Attempt B P A D)
    (hi : (runPrefix cfg boundaries initial branches schedule).attempts[i]? = some attempt) :
    executeStep cfg (boundaries attempt.participant attempt.index) attempt.index
        (ownHistory
          ((runPrefix cfg boundaries initial branches schedule).attempts.take i)
          attempt.participant)
        (.invoke attempt.invocation) attempt.before = attempt.outcome ∧
      attempt.index =
        (((runPrefix cfg boundaries initial branches schedule).attempts.take i).filterMap
          (successfulEvent attempt.participant)).length ∧
      AttemptChain initial
        ((runPrefix cfg boundaries initial branches schedule).attempts.take i)
        attempt.before :=
  (runPrefix_reachable cfg boundaries initial branches schedule).attempt_exact i attempt hi

end DefiKernel.Nary
