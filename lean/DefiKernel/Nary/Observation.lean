import DefiKernel.Nary.Execution

/-! Full finite machine and result comparison. Unlike the historical projected branch
comparator, this checker retains raw event worlds, consumed counts, complete attempt
outcomes and the exact supplied schedule plus admission reason. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def stepResultEq (left right : StepResult P A D) : Bool :=
  Parallel.worldEq left.world right.world && decide (left.receipt = right.receipt) &&
    decide (left.outputs = right.outputs)

def eventEq (left right : Event P A D) : Bool :=
  decide (left.index = right.index) && decide (left.step = right.step) &&
    Parallel.worldEq left.before right.before && stepResultEq left.result right.result

def eventsEq : List (Event P A D) → List (Event P A D) → Bool
  | [], [] => true
  | left :: lefts, right :: rights => eventEq left right && eventsEq lefts rights
  | _, _ => false

def localEq (left right : Interleaving.LocalState P A D) : Bool :=
  decide (left.consumed = right.consumed) && decide (left.nextIndex = right.nextIndex) &&
    decide (left.failure = right.failure) && decide (left.outputs = right.outputs) &&
    eventsEq left.events right.events

def localsEq : List B → (B → Interleaving.LocalState P A D) →
    (B → Interleaving.LocalState P A D) → Bool
  | [], _, _ => true
  | b :: rest, left, right => localEq (left b) (right b) && localsEq rest left right

def outcomeEq (left right : Except Composition.Failure (StepResult P A D)) : Bool :=
  match left, right with
  | .error a, .error b => decide (a = b)
  | .ok a, .ok b => stepResultEq a b
  | _, _ => false

def attemptEq (left right : Attempt B P A D) : Bool :=
  decide (left.participant = right.participant) && decide (left.index = right.index) &&
    decide (left.invocation = right.invocation) &&
    Parallel.worldEq left.before right.before && outcomeEq left.outcome right.outcome

def attemptsEq : List (Attempt B P A D) → List (Attempt B P A D) → Bool
  | [], [] => true
  | left :: lefts, right :: rights => attemptEq left right && attemptsEq lefts rights
  | _, _ => false

def machineEq (roster : Roster B) (left right : Machine B P A D) : Bool :=
  Parallel.worldEq left.world right.world &&
    localsEq roster.order left.locals right.locals &&
    attemptsEq left.attempts right.attempts

def resultEq (roster : Roster B) (left right : Result B P A D) : Bool :=
  match left, right with
  | .refused lr lw ls, .refused rr rw rs =>
    decide (lr = rr) && Parallel.worldEq lw rw && decide (ls = rs)
  | .executed ls lm, .executed rs rm =>
    decide (ls = rs) && machineEq roster lm rm
  | _, _ => false

def MachineEquivalent (roster : Roster B) (left right : Machine B P A D) : Prop :=
  Parallel.WorldEquivalent left.world right.world ∧
    (∀ b ∈ roster.order, left.locals b = right.locals b) ∧
    left.attempts = right.attempts

def ResultEquivalent (roster : Roster B) (left right : Result B P A D) : Prop :=
  match left, right with
  | .refused lr lw ls, .refused rr rw rs =>
    lr = rr ∧ Parallel.WorldEquivalent lw rw ∧ ls = rs
  | .executed ls lm, .executed rs rm =>
    ls = rs ∧ MachineEquivalent roster lm rm
  | _, _ => False

/-! Shared executable binary conversions and diagnostic projection. Proofs live in
`BinaryCorrespondence`; F03 must call these same definitions rather than a private copy. -/

def binaryParticipants : Roster Parallel.BranchId where
  order := [Parallel.BranchId.left, Parallel.BranchId.right]
  nodup := List.nodup_cons.mpr
    ⟨by simp, List.nodup_singleton Parallel.BranchId.right⟩
  complete := fun b =>
    match b with
    | Parallel.BranchId.left => List.Mem.head _
    | Parallel.BranchId.right => List.Mem.tail _ (List.Mem.head _)

def binaryLeft (branches : Branches Parallel.BranchId P A D) : Parallel.Branch P A D :=
  branches .left

def binaryRight (branches : Branches Parallel.BranchId P A D) : Parallel.Branch P A D :=
  branches .right

def ofBinaryBranches (left right : Parallel.Branch P A D) :
    Branches Parallel.BranchId P A D
  | .left => left
  | .right => right

def toBinaryBoundaries (boundaries : Boundaries Parallel.BranchId P A D) :
    Parallel.ParallelBoundary P A D :=
  boundaries

def ofBinaryBoundaries (boundaries : Parallel.ParallelBoundary P A D) :
    Boundaries Parallel.BranchId P A D :=
  boundaries

def toBinaryAttempt (attempt : Attempt Parallel.BranchId P A D) :
    Interleaving.Attempt P A D :=
  ⟨attempt.participant, attempt.index, attempt.invocation, attempt.before, attempt.outcome⟩

def ofBinaryAttempt (attempt : Interleaving.Attempt P A D) :
    Attempt Parallel.BranchId P A D :=
  ⟨attempt.branch, attempt.index, attempt.invocation, attempt.before, attempt.outcome⟩

def toBinaryAttempts (attempts : List (Attempt Parallel.BranchId P A D)) :
    List (Interleaving.Attempt P A D) :=
  attempts.map toBinaryAttempt

def ofBinaryAttempts (attempts : List (Interleaving.Attempt P A D)) :
    List (Attempt Parallel.BranchId P A D) :=
  attempts.map ofBinaryAttempt

def toBinaryLocals (locals : Parallel.BranchId → Interleaving.LocalState P A D) :
    Interleaving.LocalState P A D × Interleaving.LocalState P A D :=
  (locals .left, locals .right)

def ofBinaryLocals (left right : Interleaving.LocalState P A D) :
    Parallel.BranchId → Interleaving.LocalState P A D
  | .left => left
  | .right => right

def toBinaryMachine (m : Machine Parallel.BranchId P A D) :
    Interleaving.Machine P A D :=
  ⟨m.world, m.locals .left, m.locals .right, toBinaryAttempts m.attempts⟩

def ofBinaryMachine (m : Interleaving.Machine P A D) :
    Machine Parallel.BranchId P A D :=
  ⟨m.world, ofBinaryLocals m.left m.right, ofBinaryAttempts m.attempts⟩

/-- Recompute both binary counts from the original branches and schedule. The n-ary
first-mismatch payload is not copied; it lacks the peer count pair. -/
def projectBinaryCounts (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) : Interleaving.ScheduleMismatch :=
  ⟨(branches .left).length, schedule.count .left,
    (branches .right).length, schedule.count .right⟩

def projectScheduleMismatch (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId)
    (_mismatch : ScheduleMismatch Parallel.BranchId) : Interleaving.ScheduleMismatch :=
  projectBinaryCounts branches schedule

def projectAdmissionFailure (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId)
    (reason : AdmissionFailure Parallel.BranchId P A D) :
    Interleaving.AdmissionFailure P A D :=
  match reason with
  | .configuration => .configuration
  | .structural participant failure => .structural participant failure
  | .schedule mismatch => .schedule (projectScheduleMismatch branches schedule mismatch)

def projectAdmitSuccess (footprints : List (Parallel.BranchId × Parallel.Footprint P A D)) :
    Option (Parallel.Footprint P A D × Parallel.Footprint P A D) :=
  match footprints with
  | [⟨.left, lf⟩, ⟨.right, rf⟩] => some (lf, rf)
  | _ => none

def toBinaryResult (branches : Branches Parallel.BranchId P A D)
    (result : Result Parallel.BranchId P A D) : Interleaving.Result P A D :=
  match result with
  | .refused reason world schedule =>
    .refused (projectAdmissionFailure branches schedule reason) world schedule
  | .executed schedule machine =>
    .executed schedule (toBinaryMachine machine)

def interleavingAttemptEq (left right : Interleaving.Attempt P A D) : Bool :=
  attemptEq (ofBinaryAttempt left) (ofBinaryAttempt right)

def interleavingAttemptsEq :
    List (Interleaving.Attempt P A D) → List (Interleaving.Attempt P A D) → Bool
  | [], [] => true
  | left :: lefts, right :: rights =>
    interleavingAttemptEq left right && interleavingAttemptsEq lefts rights
  | _, _ => false

def interleavingMachineEq (left right : Interleaving.Machine P A D) : Bool :=
  Parallel.worldEq left.world right.world &&
    localEq left.left right.left && localEq left.right right.right &&
    interleavingAttemptsEq left.attempts right.attempts

def interleavingResultEq (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw ls, .refused rr rw rs =>
    decide (lr = rr) && Parallel.worldEq lw rw && decide (ls = rs)
  | .executed ls lm, .executed rs rm =>
    decide (ls = rs) && interleavingMachineEq lm rm
  | _, _ => false

def binaryMachineAgrees (nary : Machine Parallel.BranchId P A D)
    (binary : Interleaving.Machine P A D) : Bool :=
  interleavingMachineEq (toBinaryMachine nary) binary

def binaryResultAgrees (branches : Branches Parallel.BranchId P A D)
    (nary : Result Parallel.BranchId P A D) (binary : Interleaving.Result P A D) : Bool :=
  interleavingResultEq (toBinaryResult branches nary) binary

def existingBinaryAdmit (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) :=
  Interleaving.admit cfg (toBinaryBoundaries boundaries)
    (binaryLeft branches) (binaryRight branches) schedule

def existingBinaryAdvance (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (m : Interleaving.Machine P A D) (b : Parallel.BranchId) :=
  Interleaving.advance cfg (toBinaryBoundaries boundaries)
    (binaryLeft branches) (binaryRight branches) m b

def existingBinaryContinue (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (m : Interleaving.Machine P A D) (schedule : Schedule Parallel.BranchId) :=
  Interleaving.continueRun cfg (toBinaryBoundaries boundaries)
    (binaryLeft branches) (binaryRight branches) m schedule

def existingBinaryPrefix (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D) (initial : World P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) :=
  Interleaving.runPrefix cfg (toBinaryBoundaries boundaries) initial
    (binaryLeft branches) (binaryRight branches) schedule

def existingBinaryRun (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D) (initial : World P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) :=
  Interleaving.runInterleaving cfg (toBinaryBoundaries boundaries) initial
    (binaryLeft branches) (binaryRight branches) schedule

def binaryAdmitAgrees (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) : Bool :=
  match admit cfg binaryParticipants boundaries branches schedule,
      existingBinaryAdmit cfg boundaries branches schedule with
  | .error naryReason, .error binaryReason =>
    decide (projectAdmissionFailure branches schedule naryReason = binaryReason)
  | .ok naryOk, .ok binaryOk => decide (projectAdmitSuccess naryOk = some binaryOk)
  | _, _ => false

def binaryAdvanceAgrees (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (m : Machine Parallel.BranchId P A D) (b : Parallel.BranchId) : Bool :=
  binaryMachineAgrees (advance cfg boundaries branches m b)
    (existingBinaryAdvance cfg boundaries branches (toBinaryMachine m) b)

def binaryContinueAgrees (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D)
    (branches : Branches Parallel.BranchId P A D)
    (m : Machine Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) : Bool :=
  binaryMachineAgrees (continueRun cfg boundaries branches m schedule)
    (existingBinaryContinue cfg boundaries branches (toBinaryMachine m) schedule)

def binaryPrefixAgrees (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D) (initial : World P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) : Bool :=
  binaryMachineAgrees (runPrefix cfg boundaries initial branches schedule)
    (existingBinaryPrefix cfg boundaries initial branches schedule)

def binaryRunAgrees (cfg : Config P A D)
    (boundaries : Boundaries Parallel.BranchId P A D) (initial : World P A D)
    (branches : Branches Parallel.BranchId P A D)
    (schedule : Schedule Parallel.BranchId) : Bool :=
  binaryResultAgrees branches
    (runNary cfg binaryParticipants boundaries initial branches schedule)
    (existingBinaryRun cfg boundaries initial branches schedule)

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem world_eq_of_fields (left right : World P A D)
    (balance : ∀ cell, left.state.balance cell = right.state.balance cell)
    (store : left.capabilities = right.capabilities) : left = right := by
  rcases left with ⟨⟨lb, ln⟩, lc⟩
  rcases right with ⟨⟨rb, rn⟩, rc⟩
  have hb : lb = rb := funext balance
  cases hb
  cases store
  rfl

theorem world_eq_of_equivalent {left right : World P A D}
    (h : Parallel.WorldEquivalent left right) : left = right :=
  world_eq_of_fields left right h.1 h.2

theorem worldEq_iff (left right : World P A D) :
    Parallel.worldEq left right = true ↔ left = right := by
  constructor
  · intro h
    exact world_eq_of_equivalent ((Parallel.worldEq_iff left right).mp h)
  · rintro rfl
    exact (Parallel.worldEq_iff left left).mpr (Parallel.WorldEquivalent.refl left)

theorem stepResultEq_iff (left right : StepResult P A D) :
    stepResultEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [stepResultEq, StepResult.mk.injEq, Bool.and_eq_true, and_assoc, worldEq_iff]

theorem eventEq_iff (left right : Event P A D) :
    eventEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [eventEq, Event.mk.injEq, Bool.and_eq_true, and_assoc, worldEq_iff, stepResultEq_iff]

theorem eventsEq_iff (left right : List (Event P A D)) :
    eventsEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [eventsEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [eventsEq]
    | cons other rest => simp [eventsEq, eventEq_iff, ih]

theorem localEq_iff (left right : Interleaving.LocalState P A D) :
    localEq left right = true ↔ left = right := by
  cases left
  cases right
  constructor
  · intro h
    simp [localEq, Bool.and_eq_true, eventsEq_iff] at h
    obtain ⟨⟨⟨⟨hc, hi⟩, hf⟩, ho⟩, he⟩ := h
    simp [hc, he, ho, hi, hf]
  · intro h
    simp [Interleaving.LocalState.mk.injEq] at h
    obtain ⟨hc, he, ho, hi, hf⟩ := h
    simp [localEq, eventsEq_iff, hc, he, ho, hi, hf]

theorem localsEq_iff (order : List B) (left right : B → Interleaving.LocalState P A D) :
    localsEq order left right = true ↔ ∀ b ∈ order, left b = right b := by
  induction order with
  | nil => simp [localsEq]
  | cons b rest ih =>
    simp [localsEq, localEq_iff, ih]

theorem locals_ext (roster : Roster B) (left right : B → Interleaving.LocalState P A D)
    (h : ∀ b ∈ roster.order, left b = right b) : left = right :=
  funext fun b => h b (roster.complete b)

theorem outcomeEq_iff (left right : Except Composition.Failure (StepResult P A D)) :
    outcomeEq left right = true ↔ left = right := by
  cases left <;> cases right <;> simp [outcomeEq, stepResultEq_iff]

theorem attemptEq_iff (left right : Attempt B P A D) :
    attemptEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [attemptEq, Attempt.mk.injEq, Bool.and_eq_true, and_assoc, worldEq_iff, outcomeEq_iff]

theorem attemptsEq_iff (left right : List (Attempt B P A D)) :
    attemptsEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [attemptsEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [attemptsEq]
    | cons other rest => simp [attemptsEq, attemptEq_iff, ih]

theorem machineEquivalent_iff (roster : Roster B) (left right : Machine B P A D) :
    MachineEquivalent roster left right ↔ left = right := by
  constructor
  · intro h
    cases left
    cases right
    have hw := world_eq_of_equivalent h.1
    have hl := locals_ext roster _ _ h.2.1
    cases hw
    cases hl
    cases h.2.2
    rfl
  · rintro rfl
    exact ⟨Parallel.WorldEquivalent.refl _, fun _ _ => rfl, rfl⟩

theorem machineEq_iff (roster : Roster B) (left right : Machine B P A D) :
    machineEq roster left right = true ↔ left = right := by
  constructor
  · intro h
    simp only [machineEq, Bool.and_eq_true] at h
    obtain ⟨⟨hwb, hlb⟩, hab⟩ := h
    have hw := (worldEq_iff _ _).mp hwb
    have hl := (localsEq_iff _ _ _).mp hlb
    have ha := (attemptsEq_iff _ _).mp hab
    cases left
    cases right
    simp only at hw hl ha
    subst hw
    subst ha
    cases locals_ext roster _ _ hl
    rfl
  · intro h
    cases h
    simp [machineEq, worldEq_iff, localsEq_iff, attemptsEq_iff]

theorem resultEquivalent_iff (roster : Roster B) (left right : Result B P A D) :
    ResultEquivalent roster left right ↔ left = right := by
  cases left with
  | refused lr lw ls =>
    cases right with
    | refused rr rw rs =>
      constructor
      · intro h
        obtain ⟨rfl, hw, rfl⟩ := h
        cases world_eq_of_equivalent hw
        rfl
      · intro h
        obtain ⟨rfl, rfl, rfl⟩ := Result.refused.inj h
        exact ⟨rfl, Parallel.WorldEquivalent.refl _, rfl⟩
    | executed _ _ => simp [ResultEquivalent]
  | executed ls lm =>
    cases right with
    | refused _ _ _ => simp [ResultEquivalent]
    | executed rs rm =>
      constructor
      · intro h
        obtain ⟨rfl, hm⟩ := h
        cases (machineEquivalent_iff roster _ _).mp hm
        rfl
      · intro h
        obtain ⟨rfl, rfl⟩ := Result.executed.inj h
        exact ⟨rfl, (machineEquivalent_iff roster _ _).mpr rfl⟩

theorem resultEq_iff (roster : Roster B) (left right : Result B P A D) :
    resultEq roster left right = true ↔ left = right := by
  cases left with
  | refused lr lw ls =>
    cases right with
    | refused rr rw rs =>
      simp [resultEq, Bool.and_eq_true, worldEq_iff, Result.refused.injEq, and_assoc]
    | executed _ _ => simp [resultEq]
  | executed ls lm =>
    cases right with
    | refused _ _ _ => simp [resultEq]
    | executed rs rm =>
      simp [resultEq, machineEq_iff, Result.executed.injEq]

end DefiKernel.Nary
