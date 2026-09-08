import DefiKernel.Interleaving.Execution

/-! Reachability witnesses for actual attempts, including refused calls at their original
pre-world. The final world may subsequently change through successful peer invocations. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AdvanceSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.local b).failure = some failure) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | exhausted (active : (m.local b).failure = none)
      (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries left right m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries left right m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) : Machine P A D → Prop
  | start : Reachable cfg boundaries left right initial (Interleaving.start initial)
  | next {pre post : Machine P A D} (b : BranchId)
      (previous : Reachable cfg boundaries left right initial pre)
      (step : AdvanceSound cfg boundaries left right pre b post) :
      Reachable cfg boundaries left right initial post

def AttemptSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (attempt : Attempt P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.branch attempt.index) attempt.index history
    (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

theorem advance_sound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) :
    AdvanceSound cfg boundaries left right m b (advance cfg boundaries left right m b) := by
  cases hf : (m.local b).failure with
  | some failure =>
    simpa [advance, hf] using AdvanceSound.halted (cfg := cfg) (boundaries := boundaries)
      (left := left) (right := right) (m := m) (b := b) failure hf
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none =>
      simpa [advance, hf, hs] using AdvanceSound.exhausted (cfg := cfg)
        (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
          (m.local b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, hs, he] using AdvanceSound.refused (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv reason hf hs he
      | ok result =>
        simpa [advance, hf, hs, he] using AdvanceSound.accepted (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv result hf hs he

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) (m : Machine P A D)
    (h : Reachable cfg boundaries left right initial m) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries left right m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (runPrefix cfg boundaries initial left right schedule) :=
  continueRun_reachable cfg boundaries left right initial (start initial) .start schedule

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine P A D) (b : BranchId) : (m.skip b).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine P A D) (b : BranchId) :
    (m.skip b).attempts = m.attempts := by cases b <;> rfl

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.attempts ih

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId) :
    (post.local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 := by
  cases h <;> cases b <;> cases own <;>
    simp [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId) :
    ((advance cfg boundaries left right m b).local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries left right m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) (b : BranchId) :
    ((continueRun cfg boundaries left right m schedule).local b).consumed =
      (m.local b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [show continueRun cfg boundaries left right m (next :: tail) =
      continueRun cfg boundaries left right
        (advance cfg boundaries left right m next) tail from rfl]
    rw [ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (b : BranchId) :
    ((runPrefix cfg boundaries initial left right schedule).local b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  cases b <;> simp [Interleaving.start, Machine.local]

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (h : Complete left right schedule) :
    (runPrefix cfg boundaries initial left right schedule).left.consumed = left.length ∧
    (runPrefix cfg boundaries initial left right schedule).right.consumed = right.length := by
  exact ⟨(runPrefix_consumed cfg boundaries initial left right schedule .left).trans h.1,
    (runPrefix_consumed cfg boundaries initial left right schedule .right).trans h.2⟩

end DefiKernel.Interleaving
