import DefiKernel.Metatheory.Configuration
import DefiKernel.Parallel.Execution
import DefiKernel.Interleaving.Execution
import DefiKernel.Atomic.Execution

/-! Exact configuration congruence through the unchanged invocation-only operators. Equality keeps
all machine data, attempts, admission errors and Atomic outcomes; schedules are not reordered. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

-- BEGIN PROOFS

theorem analyzeInvocation_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (inv : Invocation P A D)
    (supported : SupportedStep refs (.invoke inv)) :
    analyzeInvocation old boundary inv = analyzeInvocation new boundary inv := by
  unfold analyzeInvocation
  rw [h.lookup inv.component inv.operation supported.1, h.registry inv.operation supported.2]

theorem analyzeBranchFrom_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Nat → Boundary P A D) (index : Nat)
    (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    analyzeBranchFrom old boundary index branch = analyzeBranchFrom new boundary index branch := by
  induction branch generalizing index with
  | nil => rfl
  | cons inv tail ih =>
    obtain ⟨head, rest⟩ := (supportedBranch_cons refs inv tail).mp supported
    simp only [analyzeBranchFrom, analyzeInvocation_config_eq h (boundary index) inv head,
      ih (index + 1) rest]

theorem analyzeBranch_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    analyzeBranch old boundary branch = analyzeBranch new boundary branch :=
  analyzeBranchFrom_config_eq h boundary 0 branch supported

theorem parallel_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Parallel.admit old boundaries left right = Parallel.admit new boundaries left right := by
  simp only [Parallel.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

theorem interleaving_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.admit old boundaries left right schedule =
      Interleaving.admit new boundaries left right schedule := by
  simp only [Interleaving.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

theorem atomic_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.admit old boundaries policy left right schedule =
      Atomic.admit new boundaries policy left right schedule := by
  simp only [Atomic.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

variable [Fintype P] [Fintype A] [Fintype D]

theorem runBranch_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    runBranch old boundaries initial branch = runBranch new boundaries initial branch :=
  run_config_eq h boundaries initial (branch.map Step.invoke)
    ((supportedBranch_map refs branch).mpr supported)

theorem runParallel_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runParallel old boundaries initial left right =
      runParallel new boundaries initial left right := by
  simp only [runParallel, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .left) initial left hl,
    runBranch_config_eq h (boundaries .right) initial right hr]

theorem runSerialLR_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runSerialLR old boundaries initial left right =
      runSerialLR new boundaries initial left right := by
  simp only [runSerialLR, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .left) initial left hl,
    runBranch_config_eq h (boundaries .right) _ right hr]

theorem runSerialRL_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runSerialRL old boundaries initial left right =
      runSerialRL new boundaries initial left right := by
  simp only [runSerialRL, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .right) initial right hr,
    runBranch_config_eq h (boundaries .left) _ left hl]

/-- Arbitrary common machines need no reachability or success premise for configuration equality. -/
theorem interleaving_advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Interleaving.Machine P A D) (branch : BranchId)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.advance old boundaries left right m branch =
      Interleaving.advance new boundaries left right m branch := by
  have hs : SupportedBranch refs (Interleaving.selectBranch left right branch) := by
    cases branch with
    | left => exact hl
    | right => exact hr
  unfold Interleaving.advance
  simp only []
  cases hf : (m.local branch).failure with
  | some failure => rfl
  | none =>
    cases hi : (Interleaving.selectBranch left right branch)[(m.local branch).consumed]? with
    | none => rfl
    | some inv =>
      have hm := List.mem_of_getElem? hi
      simp only []
      rw [executeStep_config_eq h (boundaries branch (m.local branch).nextIndex)
        (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world (hs inv hm)]

theorem interleaving_continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.continueRun old boundaries left right m schedule =
      Interleaving.continueRun new boundaries left right m schedule := by
  induction schedule generalizing m with
  | nil => rfl
  | cons branch tail ih =>
    simpa only [Interleaving.continueRun, List.foldl_cons,
      interleaving_advance_config_eq h boundaries left right m branch hl hr] using
        ih (Interleaving.advance new boundaries left right m branch)

theorem interleaving_runPrefix_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.runPrefix old boundaries initial left right schedule =
      Interleaving.runPrefix new boundaries initial left right schedule :=
  interleaving_continueRun_config_eq h boundaries left right
    (Interleaving.start initial) schedule hl hr

theorem runInterleaving_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.runInterleaving old boundaries initial left right schedule =
      Interleaving.runInterleaving new boundaries initial left right schedule := by
  simp only [Interleaving.runInterleaving,
    interleaving_admit_config_eq h boundaries left right schedule hl hr,
    interleaving_runPrefix_config_eq h boundaries initial left right schedule hl hr]

theorem atomic_advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (m : Atomic.Machine P A D)
    (branch : BranchId) (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.advance old boundaries policy left right m branch =
      Atomic.advance new boundaries policy left right m branch := by
  unfold Atomic.advance
  rw [interleaving_advance_config_eq h boundaries left right m.speculative branch hl hr]

theorem atomic_continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (m : Atomic.Machine P A D)
    (schedule : Interleaving.Schedule) (hl : SupportedBranch refs left)
    (hr : SupportedBranch refs right) :
    Atomic.continueRun old boundaries policy left right m schedule =
      Atomic.continueRun new boundaries policy left right m schedule := by
  induction schedule generalizing m with
  | nil => rfl
  | cons branch tail ih =>
    simpa only [Atomic.continueRun, List.foldl_cons,
      atomic_advance_config_eq h boundaries policy left right m branch hl hr] using
        ih (Atomic.advance new boundaries policy left right m branch)

theorem atomic_runPrefix_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (initial : World P A D)
    (left right : Branch P A D)
    (schedule : Interleaving.Schedule) (hl : SupportedBranch refs left)
    (hr : SupportedBranch refs right) :
    Atomic.runPrefix old boundaries policy initial left right schedule =
      Atomic.runPrefix new boundaries policy initial left right schedule :=
  atomic_continueRun_config_eq h boundaries policy left right
    (Atomic.start initial) schedule hl hr

/-- Preserves admission refusal, kernel/supply abort, unsettled residuals and committed data. -/
theorem runAtomic_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Atomic.Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.runAtomic old boundaries label policy initial left right schedule =
      Atomic.runAtomic new boundaries label policy initial left right schedule := by
  simp only [Atomic.runAtomic, atomic_admit_config_eq h boundaries policy left right schedule hl hr,
    atomic_runPrefix_config_eq h boundaries policy initial left right schedule hl hr]

end DefiKernel.Metatheory
