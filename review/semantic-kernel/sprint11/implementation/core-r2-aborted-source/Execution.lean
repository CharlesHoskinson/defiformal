import DefiKernel.Nary.Schedule
import DefiKernel.Interleaving.Execution

/-! Actual shared-state dispatch over an explicit finite roster. Each selected token calls
executeStep with that stream's history, index and trusted boundary; unselected locals stay
unchanged. Failed and exhausted tokens consume a slot without appending an attempt. -/
namespace DefiKernel.Nary
open Typed Composition

structure Attempt (B P A D : Type) where
  participant : B
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (B P A D : Type) where
  world : World P A D
  locals : B → Interleaving.LocalState P A D
  attempts : List (Attempt B P A D) := []

inductive Result (B P A D : Type) where
  | refused (reason : AdmissionFailure B P A D) (world : World P A D) (schedule : Schedule B)
  | executed (schedule : Schedule B) (machine : Machine B P A D)

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.setLocal (m : Machine B P A D) (b : B)
    (localState : Interleaving.LocalState P A D) : Machine B P A D :=
  { m with locals := fun peer ↦ if peer = b then localState else m.locals peer }

def start (initial : World P A D) : Machine B P A D :=
  ⟨initial, fun _ ↦ {}, []⟩

def failedAttempt (attempt : Attempt B P A D) : Bool :=
  match attempt.outcome with
  | .error _ => true
  | .ok _ => false

def Machine.skip (m : Machine B P A D) (b : B) : Machine B P A D :=
  let own := m.locals b
  m.setLocal b { own with consumed := own.consumed + 1 }

def Machine.refuse (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine B P A D :=
  let own := m.locals b
  let stopped : Interleaving.LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++ [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine B P A D :=
  let own := m.locals b
  let storedReceipt := result.receipt
  let acceptedWorld := result.world
  let advanced : Interleaving.LocalState P A D :=
    ⟨own.consumed + 1,
      own.events ++ [⟨own.nextIndex, .invoke inv, m.world,
        { result with receipt := storedReceipt }⟩],
      own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := acceptedWorld, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

def advance (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B) : Machine B P A D :=
  let own := m.locals b
  if own.failure.isSome then m.skip b
  else
    match (branches b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (schedule : Schedule B) :
    Machine B P A D :=
  schedule.foldl (advance cfg boundaries branches) m

def runPrefix (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) :
    Machine B P A D :=
  continueRun cfg boundaries branches (start initial) schedule

def runNary (cfg : Config P A D) (roster : Roster B) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) :
    Result B P A D :=
  match admit cfg roster boundaries branches schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial branches schedule)

inductive AdvanceSound (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B) : Machine B P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.locals b).failure = some failure) :
      AdvanceSound cfg boundaries branches m b (m.skip b)
  | exhausted (active : (m.locals b).failure = none)
      (absent : (branches b)[(m.locals b).consumed]? = none) :
      AdvanceSound cfg boundaries branches m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.locals b).failure = none)
      (selected : (branches b)[(m.locals b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
        (m.locals b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries branches m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.locals b).failure = none)
      (selected : (branches b)[(m.locals b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
        (m.locals b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries branches m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (initial : World P A D) : Machine B P A D → Prop
  | start : Reachable cfg boundaries branches initial (Nary.start initial)
  | next {pre post : Machine B P A D} (b : B)
      (previous : Reachable cfg boundaries branches initial pre)
      (step : AdvanceSound cfg boundaries branches pre b post) :
      Reachable cfg boundaries branches initial post

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

omit [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_at (m : Machine B P A D) (b : B) (l : Interleaving.LocalState P A D) :
    (m.setLocal b l).locals b = l := by
  simp [Machine.setLocal]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_away (m : Machine B P A D) (b peer : B) (l : Interleaving.LocalState P A D)
    (h : peer ≠ b) : (m.setLocal b l).locals peer = m.locals peer := by
  simp [Machine.setLocal, h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine B P A D) (b : B) (l : Interleaving.LocalState P A D) :
    (m.setLocal b l).world = m.world := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_attempts (m : Machine B P A D) (b : B) (l : Interleaving.LocalState P A D) :
    (m.setLocal b l).attempts = m.attempts := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine B P A D) (b : B) : (m.skip b).world = m.world := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine B P A D) (b : B) : (m.skip b).attempts = m.attempts := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem skip_selected (m : Machine B P A D) (b : B) :
    (m.skip b).locals b = { m.locals b with consumed := (m.locals b).consumed + 1 } := by
  simp [Machine.skip, setLocal_at]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem skip_away (m : Machine B P A D) (b peer : B) (h : peer ≠ b) :
    (m.skip b).locals peer = m.locals peer := by
  simp [Machine.skip, setLocal_away _ _ _ _ h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  simp [Machine.refuse, Machine.setLocal]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_attempts (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure) :
    (m.refuse b inv reason).attempts =
      m.attempts ++ [⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩] := by
  simp [Machine.refuse, Machine.setLocal]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_away (m : Machine B P A D) (b peer : B) (inv : Invocation P A D)
    (reason : Composition.Failure) (h : peer ≠ b) :
    (m.refuse b inv reason).locals peer = m.locals peer := by
  simp [Machine.refuse, setLocal_away _ _ _ _ h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem accept_attempts (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D) :
    (m.accept b inv result).attempts =
      m.attempts ++ [⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩] := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem accept_stored_receipt (result : StepResult P A D) :
    { result with receipt := result.receipt } = result := by
  cases result
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem accept_away (m : Machine B P A D) (b peer : B) (inv : Invocation P A D)
    (result : StepResult P A D) (h : peer ≠ b) :
    (m.accept b inv result).locals peer = m.locals peer := by
  simp [Machine.accept, setLocal_away _ _ _ _ h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem failedAttempt_error (attempt : Attempt B P A D) (reason : Composition.Failure)
    (h : attempt.outcome = .error reason) : failedAttempt attempt = true := by
  simp [failedAttempt, h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem failedAttempt_ok (attempt : Attempt B P A D) (result : StepResult P A D)
    (h : attempt.outcome = .ok result) : failedAttempt attempt = false := by
  simp [failedAttempt, h]

theorem advance_sound (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B) :
    AdvanceSound cfg boundaries branches m b (advance cfg boundaries branches m b) := by
  cases hf : (m.locals b).failure with
  | some failure =>
    have : (m.locals b).failure.isSome = true := by simp [hf]
    simpa [advance, hf, this] using
      AdvanceSound.halted (cfg := cfg) (boundaries := boundaries) (branches := branches)
        (m := m) (b := b) failure hf
  | none =>
    have : (m.locals b).failure.isSome = false := by simp [hf]
    cases hs : (branches b)[(m.locals b).consumed]? with
    | none =>
      simpa [advance, hf, this, hs] using
        AdvanceSound.exhausted (cfg := cfg) (boundaries := boundaries) (branches := branches)
          (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
          (m.locals b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, this, hs, he] using
          AdvanceSound.refused (cfg := cfg) (boundaries := boundaries) (branches := branches)
            (m := m) (b := b) inv reason hf hs he
      | ok result =>
        simpa [advance, hf, this, hs, he] using
          AdvanceSound.accepted (cfg := cfg) (boundaries := boundaries) (branches := branches)
            (m := m) (b := b) inv result hf hs he

theorem continueRun_nil (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) :
    continueRun cfg boundaries branches m [] = m := rfl

theorem continueRun_cons (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B) (rest : Schedule B) :
    continueRun cfg boundaries branches m (b :: rest) =
      continueRun cfg boundaries branches (advance cfg boundaries branches m b) rest :=
  rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (s t : Schedule B) :
    continueRun cfg boundaries branches m (s ++ t) =
      continueRun cfg boundaries branches (continueRun cfg boundaries branches m s) t :=
  List.foldl_append

theorem continueRun_reachable (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (initial : World P A D) (m : Machine B P A D)
    (h : Reachable cfg boundaries branches initial m) (schedule : Schedule B) :
    Reachable cfg boundaries branches initial
      (continueRun cfg boundaries branches m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries branches m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) :
    Reachable cfg boundaries branches initial
      (runPrefix cfg boundaries initial branches schedule) :=
  continueRun_reachable cfg boundaries branches initial (start initial) .start schedule

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) (own : B) :
    (post.locals own).consumed =
      (m.locals own).consumed + if b = own then 1 else 0 := by
  cases h with
  | halted =>
    by_cases ho : b = own
    · subst ho; simp [skip_selected]
    · simp [skip_away _ _ _ (Ne.symm ho), ho]
  | exhausted =>
    by_cases ho : b = own
    · subst ho; simp [skip_selected]
    · simp [skip_away _ _ _ (Ne.symm ho), ho]
  | refused =>
    by_cases ho : b = own
    · subst ho; simp [Machine.refuse, setLocal_at]
    · simp [refuse_away _ _ _ _ _ (Ne.symm ho), ho]
  | accepted =>
    by_cases ho : b = own
    · subst ho; simp [Machine.accept, setLocal_at]
    · simp [accept_away _ _ _ _ _ (Ne.symm ho), ho]

theorem advance_consumed (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b own : B) :
    ((advance cfg boundaries branches m b).locals own).consumed =
      (m.locals own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries branches m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (schedule : Schedule B) (b : B) :
    ((continueRun cfg boundaries branches m schedule).locals b).consumed =
      (m.locals b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [continueRun_cons, ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) (b : B) :
    ((runPrefix cfg boundaries initial branches schedule).locals b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  simp [start]

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem runNary_admission_refusal (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (reason : AdmissionFailure B P A D)
    (h : admit cfg roster boundaries branches schedule = .error reason) :
    runNary cfg roster boundaries initial branches schedule =
      .refused reason initial schedule := by
  simp [runNary, h]

theorem runNary_executed (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (footprints : List (B × Parallel.Footprint P A D))
    (h : admit cfg roster boundaries branches schedule = .ok footprints) :
    runNary cfg roster boundaries initial branches schedule =
      .executed schedule (runPrefix cfg boundaries initial branches schedule) := by
  simp [runNary, h]

end DefiKernel.Nary
