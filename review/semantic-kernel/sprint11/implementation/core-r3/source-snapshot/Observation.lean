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
