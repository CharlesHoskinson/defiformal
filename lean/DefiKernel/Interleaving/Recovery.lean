import DefiKernel.Interleaving.Recovery.Simulation

/-! Every complete disjoint schedule recovers the full existing canonical parallel observation.
The simulation includes refusals and retained prefixes; raw foreign event worlds are not equated. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel Recovery

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem runPrefix_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule)
      ⟨mergeWorld lf rf initial l.world r.world, l, r⟩ := by
  have sim := runPrefix_simulates cfg boundaries initial left right lf rf hp schedule
  have counts := runPrefix_complete_counts cfg boundaries initial left right schedule complete
  have hl := sim .left
  have hr := sim .right
  simp only [Machine.local, footprint, selectBranch, counts.1, counts.2, isolated_full] at hl hr
  obtain ⟨_, al, ar, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  refine ⟨⟨?_, ?_⟩, hl.observation, hr.observation⟩
  · intro c
    by_cases hcl : c ∈ lf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .left) 0 left lf al c hcl
      simpa [mergeWorld, hcl, LocalState.toCursor] using hl.state c hread
    · by_cases hcr : c ∈ rf.writes
      · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf ar c hcr
        simpa [mergeWorld, hcl, hcr, LocalState.toCursor] using hr.state c hread
      · simpa [mergeWorld, hcl, hcr, runPrefix, Interleaving.start] using
          continue_outside cfg boundaries initial left right lf rf hp (start initial)
            .start schedule c hcl hcr
  · exact (runPrefix_reachable cfg boundaries initial left right schedule).store

/-- The actual public evaluator and existing parallel evaluator return related executed results. -/
theorem runInterleaving_recovers (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    ∃ joined, Parallel.runParallel cfg boundaries initial left right = .executed joined ∧
      runInterleaving cfg boundaries initial left right schedule =
        .executed schedule (runPrefix cfg boundaries initial left right schedule) ∧
      ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule) joined := by
  refine ⟨_, ?_, ?_,
    runPrefix_parallel cfg boundaries initial left right lf rf hp schedule complete⟩
  · simp [Parallel.runParallel, hp]
  · simp [runInterleaving, admit_of_parallel cfg boundaries left right schedule lf rf hp complete]

theorem runInterleaving_matchesParallel (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runParallel cfg boundaries initial left right) = true := by
  obtain ⟨joined, hp', hs, related⟩ :=
    runInterleaving_recovers cfg boundaries initial left right lf rf hp schedule complete
  rw [hp', hs, matchesParallel_iff]
  exact related

theorem matchesParallel_transport (shared : Interleaving.Result P A D)
    (first second : Parallel.Result P A D)
    (h : matchesParallel shared first = true)
    (equiv : Parallel.ObservationallyEquivalent first second) :
    matchesParallel shared second = true := by
  cases shared with
  | refused => simp [matchesParallel] at h
  | executed schedule m =>
    cases first with
    | refused => simp [matchesParallel] at h
    | executed a =>
      cases second with
      | refused => exact equiv.elim
      | executed b =>
        rw [matchesParallel_iff] at h ⊢
        exact ⟨h.1.trans equiv.1, h.2.1.trans equiv.2.1, h.2.2.trans equiv.2.2⟩

theorem runInterleaving_matchesSerialLR (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialLR cfg boundaries initial left right)

theorem runInterleaving_matchesSerialRL (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialRL cfg boundaries initial left right)

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockLR (left right : Branch P A D) :
    Complete left right
      (List.replicate left.length .left ++ List.replicate right.length .right) := by
  simp [Complete, List.count_replicate]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockRL (left right : Branch P A D) :
    Complete left right
      (List.replicate right.length .right ++ List.replicate left.length .left) := by
  simp [Complete, List.count_replicate]

theorem runInterleaving_blockLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate left.length .left ++ List.replicate right.length .right))
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialLR cfg boundaries initial left right lf rf hp _
    (complete_blockLR left right)

theorem runInterleaving_blockRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate right.length .right ++ List.replicate left.length .left))
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialRL cfg boundaries initial left right lf rf hp _
    (complete_blockRL left right)

theorem runInterleaving_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left [] = .ok (lf, .empty)) (schedule : Schedule)
    (complete : Complete left [] schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left [] schedule)
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left [] lf .empty hp schedule complete)
    (Parallel.runParallel_empty_right cfg boundaries initial left lf hp)

theorem runInterleaving_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries [] right = .ok (.empty, rf)) (schedule : Schedule)
    (complete : Complete [] right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial [] right schedule)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial [] right .empty rf hp schedule complete)
    (Parallel.runParallel_empty_left cfg boundaries initial right rf hp)

theorem runInterleaving_empty (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (hv : validateCatalog cfg.registry cfg.catalog = true) :
    runInterleaving cfg boundaries initial [] [] [] = .executed [] (start initial) := by
  simp [runInterleaving, Interleaving.admit, hv, analyzeBranch, analyzeBranchFrom,
    checkSchedule, Except.mapError, bind, Except.bind, pure, Except.pure,
    runPrefix, Interleaving.continueRun]

end DefiKernel.Interleaving
