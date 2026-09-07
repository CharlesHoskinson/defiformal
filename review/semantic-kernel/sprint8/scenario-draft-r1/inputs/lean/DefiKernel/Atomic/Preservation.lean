import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Observation
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Interference

/-! Public macro laws follow from actual speculative reachability and complete rollback.
Authority statements retain the authenticated boundary and initial-store trust premises. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem runAtomic_noncommit_identity (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (noncommit : ∀ m, runAtomic cfg boundaries label policy initial left right schedule ≠
      .committed label schedule m) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld = initial ∧
      committedHistory
        (runAtomic cfg boundaries label policy initial left right schedule) = [] ∧
      ∀ d a, committedSupply (runAtomic cfg boundaries label policy initial left right schedule)
        d a = 0 := by
  have entry := (runPrefix_reachable cfg boundaries policy initial left right schedule).entry
  cases ha : admit cfg boundaries policy left right schedule with
  | error reason => simp [runAtomic, ha, Result.publicWorld, committedHistory, committedSupply]
  | ok pair =>
    cases hb : (runPrefix cfg boundaries policy initial left right schedule).abort with
    | some reason =>
      simp [runAtomic, ha, finish, hb, Result.publicWorld, committedHistory, committedSupply, entry]
    | none =>
      cases hr : residuals policy
          (runPrefix cfg boundaries policy initial left right schedule).outstanding with
      | nil => exact False.elim (noncommit
          (runPrefix cfg boundaries policy initial left right schedule)
          (by simp [runAtomic, ha, finish, hb, hr]))
      | cons r rest =>
        simp [runAtomic, ha, finish, hb, hr, Result.publicWorld,
          committedHistory, committedSupply, entry]

theorem runAtomic_commit_reachable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) : Reachable cfg boundaries policy left right initial m := by
  obtain ⟨_, _, _, rfl, _, _⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ h
  exact runPrefix_reachable _ _ _ _ _ _ _

/-- Actual receipt accounting includes authorized nonlane supply and zero aborted supply. -/
theorem runAtomic_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state d a =
    total initial.state d a + committedSupply
      (runAtomic cfg boundaries label policy initial left right schedule) d a := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.accounting d a
  · have hi := runAtomic_noncommit_identity cfg boundaries label policy initial left right
      schedule (by simpa using hc)
    rw [hi.1, hi.2.2 d a, add_zero]

theorem runAtomic_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.capabilities =
      initial.capabilities := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.store
  · exact congrArg (fun w : World P A D => w.capabilities)
      (runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1

theorem runAtomic_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.balance
        c :=
  (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.nonneg c

theorem runAtomic_commit_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (attempt : Attempt P A D) (member : attempt ∈ m.speculative.attempts)
    (result : StepResult P A D) (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.authority
    attempt member result success

theorem runAtomic_commit_before_store (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (attempt : Attempt P A D) (member : attempt ∈ m.speculative.attempts) :
    attempt.before.capabilities = initial.capabilities :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.before_stores
    attempt member

theorem runAtomic_commit_locality (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (c : Cell P A D) (untouched : c ∉ m.speculative.writes) :
    m.speculative.world.state.balance c = initial.state.balance c :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.locality c untouched

theorem runAtomic_commit_predicate_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ c ∈ region, c ∉ m.speculative.writes) :
    predicate initial.state ↔ predicate m.speculative.world.state :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.predicate_frame
    region predicate support untouched

theorem runAtomic_analyzed_locality (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.balance
      c =
      initial.state.balance c := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.analyzed_locality lf rf hl hr c untouched
  · rw [(runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1]

theorem runAtomic_analyzed_predicate_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state := by
  apply supported_frame support
  intro c hc
  exact (runAtomic_analyzed_locality _ _ _ _ _ _ _ _ _ _ hl hr c (untouched c hc)).symm

/-- Initialization and actual per-call obligations establish a ledger invariant through
nonzero transient obligations as well as public rollback. No whole-result premise is used. -/
theorem runAtomic_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.two_invariants invariant guarantee rely initialized
      localObligation cross stable
  · rw [(runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1]
    exact initialized

end DefiKernel.Atomic
