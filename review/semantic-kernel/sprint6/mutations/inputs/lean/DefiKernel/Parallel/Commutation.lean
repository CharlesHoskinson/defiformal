import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.Dependency.Adapter

/-! Congruence of full local histories and exact refusals, then correspondence to actual
serial branch re-execution. Dependency premises are discharged from checked admission. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

structure CursorAgrees (region : Set (Cell P A D)) (left right : Cursor P A D) : Prop where
  state : AgreeOn region left.world.state right.world.state
  capabilities : left.world.capabilities = right.world.capabilities
  events : left.events.map observeEvent = right.events.map observeEvent
  outputs : left.outputs = right.outputs
  nextIndex : left.nextIndex = right.nextIndex
  failure : left.failure = right.failure

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorAgrees.observation {region : Set (Cell P A D)} {left right : Cursor P A D}
    (h : CursorAgrees region left right) : observeBranch left = observeBranch right := by
  simp only [observeBranch, h.events, h.outputs, h.nextIndex, h.failure]

theorem continueRun_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (continueRun cfg boundary left (branch.map Step.invoke))
      (continueRun cfg boundary right (branch.map Step.invoke)) := by
  induction branch generalizing index fp left right with
  | nil => exact ha
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    have hhead : ∀ c ∈ head.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hrest : ∀ c ∈ rest.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hir : right.nextIndex = index := ha.nextIndex.symm.trans hi
    cases hfl : left.failure with
    | some failure =>
      have hfr : right.failure = some failure := ha.failure.symm.trans hfl
      simpa [continueRun_failed cfg boundary left failure hfl,
        continueRun_failed cfg boundary right failure hfr] using ha
    | none =>
      have hfr : right.failure = none := ha.failure.symm.trans hfl
      have hs := executeStep_congr cfg (boundary index) index left.outputs inv
        left.world right.world head region hh hhead ha.state ha.capabilities
      change CursorAgrees region
        (continueRun cfg boundary (advance cfg boundary left (.invoke inv))
          (tail.map Step.invoke))
        (continueRun cfg boundary (advance cfg boundary right (.invoke inv))
          (tail.map Step.invoke))
      cases hl : executeStep cfg (boundary index) index left.outputs (.invoke inv) left.world with
      | error le =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | ok rr => simp [hl, hr, StepAgrees] at hs
        | error re =>
          simp only [hl, hr, StepAgrees] at hs
          subst re
          have hal : advance cfg boundary left (.invoke inv) =
              { left with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfl, hi, hl]
          have har : advance cfg boundary right (.invoke inv) =
              { right with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfr, hir, ← ha.outputs, hr]
          rw [hal, har]
          rw [continueRun_failed cfg boundary _ _ rfl,
            continueRun_failed cfg boundary _ _ rfl]
          exact ⟨ha.state, ha.capabilities, ha.events, ha.outputs, ha.nextIndex, rfl⟩
      | ok lr =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | error re => simp [hl, hr, StepAgrees] at hs
        | ok rr =>
          simp only [hl, hr, StepAgrees] at hs
          let nl : Cursor P A D :=
            ⟨lr.world, left.events ++ [⟨index, .invoke inv, left.world, lr⟩],
              left.outputs ++ lr.outputs, index + 1, none⟩
          let nr : Cursor P A D :=
            ⟨rr.world, right.events ++ [⟨index, .invoke inv, right.world, rr⟩],
              right.outputs ++ rr.outputs, index + 1, none⟩
          have hal : advance cfg boundary left (.invoke inv) = nl := by
            simp [advance, hfl, hi, hl, nl]
          have har : advance cfg boundary right (.invoke inv) = nr := by
            simp [advance, hfr, hir, ← ha.outputs, hr, nr]
          rw [hal, har]
          apply ih (index + 1) rest nl nr ht hrest rfl
          refine ⟨hs.1, hs.2.1, ?_, ?_, rfl, rfl⟩
          · simp [nl, nr, List.map_append, observeEvent, ha.events, hs.2.2.1, hs.2.2.2]
          · simp [nl, nr, ha.outputs, hs.2.2.2]

theorem runBranch_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (left right : World P A D) (hf : analyzeBranch cfg boundary branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hc : left.capabilities = right.capabilities) :
    CursorAgrees region (runBranch cfg boundary left branch)
      (runBranch cfg boundary right branch) := by
  apply continueRun_congr cfg boundary branch 0 fp region _ _ hf hin rfl
  exact ⟨ha, hc, rfl, rfl, rfl, rfl⟩

theorem continueRun_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D) (cursor : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hi : cursor.nextIndex = index) :
    (∀ c, c ∉ fp.writes →
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.state.balance c =
        cursor.world.state.balance c) ∧
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.capabilities =
        cursor.world.capabilities := by
  induction branch generalizing index fp cursor with
  | nil => exact ⟨fun _ _ ↦ rfl, rfl⟩
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    cases hfl : cursor.failure with
    | some failure =>
      rw [continueRun_failed cfg boundary cursor failure hfl]
      exact ⟨fun _ _ ↦ rfl, rfl⟩
    | none =>
      change (∀ c, c ∉ fp.writes →
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.state.balance c = cursor.world.state.balance c) ∧
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.capabilities = cursor.world.capabilities
      cases hx : executeStep cfg (boundary index) index cursor.outputs
          (.invoke inv) cursor.world with
      | error reason =>
        have hadv : advance cfg boundary cursor (.invoke inv) =
            { cursor with failure := some ⟨index, some (.invoke inv), reason⟩ } := by
          simp [advance, hfl, hi, hx]
        rw [hadv, continueRun_failed cfg boundary _ _ rfl]
        exact ⟨fun _ _ ↦ rfl, rfl⟩
      | ok result =>
        let next : Cursor P A D :=
          ⟨result.world, cursor.events ++ [⟨index, .invoke inv, cursor.world, result⟩],
            cursor.outputs ++ result.outputs, index + 1, none⟩
        have hadv : advance cfg boundary cursor (.invoke inv) = next := by
          simp [advance, hfl, hi, hx, next]
        rw [hadv]
        have hs := executeStep_target_frame cfg (boundary index) index cursor.outputs inv
          cursor.world result head hh hx
        have htail := ih (index + 1) rest next ht rfl
        refine ⟨?_, htail.2.trans hs.2⟩
        intro c hc
        have hhead : c ∉ head.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        have hrest : c ∉ rest.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        exact (htail.1 c hrest).trans (hs.1 c hhead)

theorem runBranch_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (fp : Footprint P A D)
    (hf : analyzeBranch cfg boundary branch = .ok fp) :
    (∀ c, c ∉ fp.writes → (runBranch cfg boundary initial branch).world.state.balance c =
      initial.state.balance c) ∧
      (runBranch cfg boundary initial branch).world.capabilities = initial.capabilities := by
  exact continueRun_frame cfg boundary branch 0 fp (startCursor cfg initial) hf rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzeBranchFrom_writes_read (cfg : Config P A D)
    (boundary : Nat → Boundary P A D) (index : Nat) (branch : Branch P A D)
    (fp : Footprint P A D) (hf : analyzeBranchFrom cfg boundary index branch = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  induction branch generalizing index fp with
  | nil =>
    have he : fp = Footprint.empty := by simpa [analyzeBranchFrom] using hf.symm
    simp [he, Footprint.empty]
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    intro c hc
    rcases List.mem_append.mp hc with hc | hc
    · exact List.mem_append_left _ (analyzeInvocation_writes_read _ _ _ _ hh c hc)
    · exact List.mem_append_right _ (ih (index + 1) rest ht c hc)

/-- The real second run has the same local observations, including exact refusal. -/
theorem rerun_after_peer (cfg : Config P A D) (ownBoundary peerBoundary : Nat → Boundary P A D)
    (initial : World P A D) (own peer : Branch P A D) (ownFp peerFp : Footprint P A D)
    (ho : analyzeBranch cfg ownBoundary own = .ok ownFp)
    (hp : analyzeBranch cfg peerBoundary peer = .ok peerFp)
    (hd : ∀ c ∈ peerFp.writes, c ∉ ownFp.reads) :
    CursorAgrees {c | c ∈ ownFp.reads} (runBranch cfg ownBoundary initial own)
      (runBranch cfg ownBoundary (runBranch cfg peerBoundary initial peer).world own) := by
  have frame := runBranch_frame cfg peerBoundary initial peer peerFp hp
  apply runBranch_congr cfg ownBoundary own ownFp _ _ _ ho (fun _ h ↦ h)
  · intro c hc
    exact (frame.1 c (fun hw ↦ hd c hw hc)).symm
  · exact frame.2.symm

/-- Region merge equals a fresh right execution after the real left retained prefix. -/
theorem merge_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hc : Compatible lf rf) :
    WorldEquivalent
      (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
        (runBranch cfg (boundaries .right) initial right).world)
      (runBranch cfg (boundaries .right)
        (runBranch cfg (boundaries .left) initial left).world right).world := by
  have le := runBranch_frame cfg (boundaries .left) initial left lf hl
  have re := runBranch_frame cfg (boundaries .right)
    (runBranch cfg (boundaries .left) initial left).world right rf hr
  have ra := rerun_after_peer cfg (boundaries .right) (boundaries .left)
    initial right left rf lf hr hl hc.2.1
  refine ⟨?_, (re.2.trans le.2).symm⟩
  intro c
  by_cases hcl : c ∈ lf.writes
  · have hcr := hc.1 c hcl
    simpa [mergeWorld, hcl] using (re.1 c hcr).symm
  · by_cases hcr : c ∈ rf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf hr c hcr
      simpa [mergeWorld, hcl, hcr] using ra.state c hread
    · simpa [mergeWorld, hcl, hcr] using ((re.1 c hcr).trans (le.1 c hcl)).symm

theorem runParallel_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialLR cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialLR, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    simp only [runParallel, runSerialLR, ha, ObservationallyEquivalent]
    exact ⟨merge_serialLR cfg boundaries initial left right lf rf hl hr hc, True.intro,
      (rerun_after_peer cfg (boundaries .right) (boundaries .left)
        initial right left rf lf hr hl hc.2.1).observation⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_swap (lf rf : Footprint P A D) (initial left right : World P A D)
    (hc : Compatible lf rf) :
    WorldEquivalent (mergeWorld lf rf initial left right)
      (mergeWorld rf lf initial right left) := by
  refine ⟨?_, rfl⟩
  intro c
  by_cases hl : c ∈ lf.writes
  · simp [mergeWorld, hl, hc.1 c hl]
  · by_cases hr : c ∈ rf.writes <;> simp [mergeWorld, hl, hr]

theorem runParallel_serialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialRL, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    let swapped : ParallelBoundary P A D := fun side ↦
      match side with | .left => boundaries .right | .right => boundaries .left
    have hm := merge_serialLR cfg swapped initial right left rf lf hr hl (compatible_symm hc)
    have hs := mergeWorld_swap lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world hc
    simp only [runParallel, runSerialRL, ha, ObservationallyEquivalent]
    exact ⟨⟨fun c ↦ (hs.1 c).trans (hm.1 c), hs.2.trans hm.2⟩,
      (rerun_after_peer cfg (boundaries .left) (boundaries .right)
        initial left right lf rf hl hr hc.2.2).observation, True.intro⟩

/-- Singleton calls inherit exact refusal-aware sequential correspondence. -/
theorem singleton_commutation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Invocation P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialLR cfg boundaries initial [left] [right]) ∧
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialRL cfg boundaries initial [left] [right]) :=
  ⟨runParallel_serialLR _ _ _ _ _, runParallel_serialRL _ _ _ _ _⟩

theorem runBranch_empty (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) : runBranch cfg boundary initial [] = startCursor cfg initial := rfl

/-- An admitted empty peer has no events or outputs and contributes no ledger change. -/
theorem runParallel_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (ha : admit cfg boundaries left [] = .ok (lf, .empty)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left [])
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) := by
  obtain ⟨_, hl, _, _⟩ := admit_ok cfg boundaries left [] lf .empty ha
  have hf := runBranch_frame cfg (boundaries .left) initial left lf hl
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ lf.writes
  · simp [mergeWorld, hc]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

theorem runParallel_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (ha : admit cfg boundaries [] right = .ok (.empty, rf)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [] right)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) := by
  obtain ⟨_, _, hr, _⟩ := admit_ok cfg boundaries [] right .empty rf ha
  have hf := runBranch_frame cfg (boundaries .right) initial right rf hr
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ rf.writes
  · simp [mergeWorld, hc, Footprint.empty]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

/-- Both real sequential schedules yield the same complete canonical observation. -/
theorem serial_orders_equivalent (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runSerialLR cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) :=
  (runParallel_serialLR cfg boundaries initial left right).symm.trans
    (runParallel_serialRL cfg boundaries initial left right)

end DefiKernel.Parallel
