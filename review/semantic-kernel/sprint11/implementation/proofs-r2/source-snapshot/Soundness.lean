import DefiKernel.Nary.Execution

/-! Attempt equations and selected/unselected local identities derived from the actual
`advance` constructors. `AdvanceSound`/`Reachable`/`advance_sound` live in Execution;
this module does not assume a desired trace. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each stored attempt is an actual `executeStep` equation at its recorded pre-world. -/
def AttemptSound (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (attempt : Attempt B P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.participant attempt.index) attempt.index
    history (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

omit [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_selected (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure) :
    (m.refuse b inv reason).locals b =
      { m.locals b with
        consumed := (m.locals b).consumed + 1
        failure := some ⟨(m.locals b).nextIndex, some (.invoke inv), reason⟩ } := by
  simp [Machine.refuse, setLocal_at]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem accept_selected (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D) :
    (m.accept b inv result).locals b =
      ⟨(m.locals b).consumed + 1,
        (m.locals b).events ++
          [⟨(m.locals b).nextIndex, .invoke inv, m.world, result⟩],
        (m.locals b).outputs ++ result.outputs,
        (m.locals b).nextIndex + 1, none⟩ := by
  simp [Machine.accept, setLocal_at]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem start_locals (initial : World P A D) (b : B) :
    (start (B := B) initial).locals b = {} :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem start_attempts (initial : World P A D) :
    (start (B := B) initial).attempts = [] :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem start_world (initial : World P A D) :
    (start (B := B) initial).world = initial :=
  rfl

theorem AdvanceSound.away {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) (own : B) (ho : own ≠ b) :
    post.locals own = m.locals own := by
  cases h with
  | halted => exact skip_away m b own ho
  | exhausted => exact skip_away m b own ho
  | refused inv reason _ _ _ => exact refuse_away m b own inv reason ho
  | accepted inv result _ _ _ => exact accept_away m b own inv result ho

theorem AdvanceSound.none_attempt {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post)
    (skipped : (m.locals b).failure.isSome = true ∨
      ((m.locals b).failure = none ∧ (branches b)[(m.locals b).consumed]? = none)) :
    post.attempts = m.attempts := by
  cases h with
  | halted => exact skip_attempts m b
  | exhausted => exact skip_attempts m b
  | refused _ _ active selected _ =>
    rcases skipped with hf | ⟨_, absent⟩
    · simp [active] at hf
    · simp [selected] at absent
  | accepted _ _ active selected _ =>
    rcases skipped with hf | ⟨_, absent⟩
    · simp [active] at hf
    · simp [selected] at absent

theorem AdvanceSound.error_attempt {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m : Machine B P A D} {b : B}
    {inv : Invocation P A D} {reason : Composition.Failure}
    (_active : (m.locals b).failure = none)
    (_selected : (branches b)[(m.locals b).consumed]? = some inv)
    (_rejected : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .error reason) :
    (m.refuse b inv reason).attempts =
      m.attempts ++ [⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩] :=
  refuse_attempts m b inv reason

theorem AdvanceSound.success_attempt {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m : Machine B P A D} {b : B}
    {inv : Invocation P A D} {result : StepResult P A D}
    (_active : (m.locals b).failure = none)
    (_selected : (branches b)[(m.locals b).consumed]? = some inv)
    (_executed : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result) :
    (m.accept b inv result).attempts =
      m.attempts ++ [⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩] :=
  accept_attempts m b inv result

/-- Every AdvanceSound constructor yields skip (no attempt), an error attempt, or a
successful attempt, matching the actual `advance` equations. -/
theorem AdvanceSound.appended_outcome {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) :
    post.attempts = m.attempts ∨
      (∃ inv reason,
        (m.locals b).failure = none ∧
        (branches b)[(m.locals b).consumed]? = some inv ∧
        executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
          (m.locals b).outputs (.invoke inv) m.world = .error reason ∧
        post.attempts = m.attempts ++
          [⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩]) ∨
      (∃ inv result,
        (m.locals b).failure = none ∧
        (branches b)[(m.locals b).consumed]? = some inv ∧
        executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
          (m.locals b).outputs (.invoke inv) m.world = .ok result ∧
        post.attempts = m.attempts ++
          [⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩]) := by
  cases h with
  | halted => exact Or.inl (skip_attempts m b)
  | exhausted => exact Or.inl (skip_attempts m b)
  | refused inv reason active selected rejected =>
    exact Or.inr (Or.inl ⟨inv, reason, active, selected, rejected, refuse_attempts m b inv reason⟩)
  | accepted inv result active selected executed =>
    exact Or.inr (Or.inr ⟨inv, result, active, selected, executed, accept_attempts m b inv result⟩)

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted =>
    intro attempt member
    exact previous attempt (by simpa [skip_attempts] using member)
  | exhausted =>
    intro attempt member
    exact previous attempt (by simpa [skip_attempts] using member)
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [refuse_attempts, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [accept_attempts, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start =>
    intro attempt member
    cases member
  | next b previous step ih => exact step.attempts ih

end DefiKernel.Nary
