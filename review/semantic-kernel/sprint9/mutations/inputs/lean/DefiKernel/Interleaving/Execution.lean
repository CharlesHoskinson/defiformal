import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Observation
import DefiKernel.Parallel.Execution

/-! Finite replay over one evolving world. Local histories and permanent refusals stay separate;
consumed static slots advance even when a failed suffix produces no further attempt. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

structure LocalState (P A D : Type) where
  consumed : Nat := 0
  events : List (Event P A D) := []
  outputs : List (OutputObservation A) := []
  nextIndex : Nat := 0
  failure : Option (LocatedFailure P A D) := none

structure Attempt (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (P A D : Type) where
  world : World P A D
  left : LocalState P A D := {}
  right : LocalState P A D := {}
  attempts : List (Attempt P A D) := []

inductive Result (P A D : Type) where
  | refused (reason : Interleaving.AdmissionFailure P A D) (world : World P A D)
      (schedule : Schedule)
  | executed (schedule : Schedule) (machine : Machine P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.local (m : Machine P A D) : BranchId → LocalState P A D
  | .left => m.left
  | .right => m.right

def Machine.setLocal (m : Machine P A D) (b : BranchId)
    (localState : LocalState P A D) : Machine P A D :=
  match b with
  | .left => { m with left := localState }
  | .right => { m with right := localState }

def selectBranch (left right : Branch P A D) : BranchId → Branch P A D
  | .left => left
  | .right => right

def start (initial : World P A D) : Machine P A D := ⟨initial, {}, {}, []⟩

/-- The new public projection owns every preserved field, including exact located failure. -/
def LocalState.observe (localState : LocalState P A D) : BranchObservation P A D :=
  ⟨localState.events.map observeEvent, localState.outputs,
    localState.nextIndex, localState.failure⟩

def LocalState.toCursor (localState : LocalState P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, localState.events, localState.outputs, localState.nextIndex, localState.failure⟩

def Attempt.supply (attempt : Attempt P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

/-- Executable aggregation of actual successful attempts; refusals contribute zero. -/
def Machine.supply (m : Machine P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def Machine.skip (m : Machine P A D) (b : BranchId) : Machine P A D :=
  m.setLocal b { m.local b with consumed := (m.local b).consumed + 1 }

def Machine.refuse (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine P A D :=
  let own := m.local b
  let stopped : LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine P A D :=
  let own := m.local b
  let advanced : LocalState P A D := ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, m.world, result⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := result.world, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

/-- Advance exactly one static branch slot, preserving the peer's local state. -/
def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D :=
  let own := m.local b
  match own.failure with
  | some _ => m.skip b
  | none =>
    match (selectBranch left right b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries left right (start initial) schedule

def runInterleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Interleaving.Result P A D :=
  match Interleaving.admit cfg boundaries left right schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial left right schedule)

/-- Exact financial fields, without raw foreign event worlds or global scheduling order. -/
def ProjectedEquivalent (m : Machine P A D) (joined : Parallel.Joined P A D) : Prop :=
  Parallel.WorldEquivalent m.world joined.world ∧
    m.left.observe = observeBranch joined.left ∧ m.right.observe = observeBranch joined.right

def observationsEqual (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw _, .refused rr rw _ => decide (lr = rr) && Parallel.worldEq lw rw
  | .executed _ l, .executed _ r => Parallel.worldEq l.world r.world &&
      decide (l.left.observe = r.left.observe) && decide (l.right.observe = r.right.observe)
  | _, _ => false

def matchesParallel (result : Interleaving.Result P A D) (parallel : Parallel.Result P A D) :
    Bool :=
  match result, parallel with
  | .executed _ m, .executed joined => Parallel.worldEq m.world joined.world &&
      decide (m.left.observe = observeBranch joined.left) &&
      decide (m.right.observe = observeBranch joined.right)
  | _, _ => false

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem local_setLocal (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).local b = l := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).world = m.world := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_toCursor (l : LocalState P A D) (w : World P A D) :
    observeBranch (l.toCursor w) = l.observe := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (s t : Schedule) :
    continueRun cfg boundaries left right m (s ++ t) =
      continueRun cfg boundaries left right (continueRun cfg boundaries left right m s) t :=
  List.foldl_append

theorem matchesParallel_iff (schedule : Schedule) (m : Machine P A D)
    (joined : Parallel.Joined P A D) :
    matchesParallel (.executed schedule m) (.executed joined) = true ↔
      ProjectedEquivalent m joined := by
  simp [matchesParallel, ProjectedEquivalent, Parallel.worldEq, Parallel.WorldEquivalent, and_assoc]

end DefiKernel.Interleaving
