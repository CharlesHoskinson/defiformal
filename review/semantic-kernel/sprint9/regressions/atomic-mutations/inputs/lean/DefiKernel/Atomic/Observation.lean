import DefiKernel.Atomic.Execution

/-! Public equality retains the atomic event label, schedule, exact refusal, full
world and every committed receipt/output/supply field. Diagnostics are separate. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive Outcome (P A D : Type) where
  | refused (reason : AdmissionFailure P A D)
  | aborted (reason : AbortReason P A D)
  | committed
  deriving DecidableEq

structure Observation (P A D : Type) where
  label : Nat
  schedule : Schedule
  outcome : Outcome P A D
  world : World P A D
  events : List (EventObservation P A D)
  supply : D → A → ℚ

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def observe (result : Result P A D) : Observation P A D :=
  let (label, schedule, outcome) := match result with
    | .refused label schedule reason _ => (label, schedule, Outcome.refused reason)
    | .aborted label schedule reason _ => (label, schedule, Outcome.aborted reason)
    | .committed label schedule _ => (label, schedule, Outcome.committed)
  ⟨label, schedule, outcome, result.publicWorld,
    committedHistory result, committedSupply result⟩

def Observation.Equivalent (left right : Observation P A D) : Prop :=
  left.label = right.label ∧ left.schedule = right.schedule ∧
    left.outcome = right.outcome ∧ WorldEquivalent left.world right.world ∧
    left.events = right.events ∧ ∀ d a, left.supply d a = right.supply d a

def observationEq (left right : Observation P A D) : Bool :=
  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&
    decide (left.outcome = right.outcome) && worldEq left.world right.world &&
    decide (left.events = right.events) && decide (∀ d a, left.supply d a = right.supply d a)

def observationsEqual (left right : Result P A D) : Bool :=
  observationEq (observe left) (observe right)

-- BEGIN PROOFS

theorem observationEq_iff (left right : Observation P A D) :
    observationEq left right = true ↔ left.Equivalent right := by
  simp [observationEq, Observation.Equivalent, worldEq, WorldEquivalent, and_assoc]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ (observe left).Equivalent (observe right) :=
  observationEq_iff _ _

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_world (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).world = m.entryWorld := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_history (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_supply (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) (d : D) (a : A) :
    (observe (.aborted label schedule reason m)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_world (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).world = entry := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_history (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_supply (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) (d : D) (a : A) :
    (observe (.refused label schedule reason entry)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_one_event (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).events = [diagnosticEvent label schedule m] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_world (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).world = m.speculative.world := rfl

end DefiKernel.Atomic
