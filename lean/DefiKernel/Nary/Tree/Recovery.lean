import DefiKernel.Nary.Tree.Compatibility
import DefiKernel.Nary.Tree.Simulation
import DefiKernel.Nary.LocalOrder
import DefiKernel.Nary.Preservation
import DefiKernel.Parallel.Commutation
import DefiKernel.Interleaving.Recovery.Step

/-! Isolated consumed-prefix simulation and canonical recovery.
Does not assume a desired full-run equality or all-success. Genesis empty locals
and a complete compatible schedule are required for schedule independence.
Arbitrary populated-entry schedule independence is not claimed. -/
namespace DefiKernel.Nary.Tree
open Typed Composition Parallel

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Isolated sequential prefix of a submitted branch. Consumed count, not a
desired full run, selects the prefix. -/
def isolated (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) (n : Nat) : Cursor P A D :=
  Composition.run cfg boundary initial ((branch.take n).map Step.invoke)

def isolatedFootprint (assoc : List (B × Footprint P A D)) (b : B) : Footprint P A D :=
  footprintOf assoc b

def projected (roster : Roster B) (tm : TreeMachine B P A D) :
    CanonicalObservation B P A D :=
  canonicalOf roster tm

/-- Shared machine versus independently executed consumed prefixes. -/
def Simulates (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D)) (m : Nary.Machine B P A D) : Prop :=
  ∀ b, CursorAgrees {c | c ∈ (isolatedFootprint assoc b).reads}
    ((m.locals b).toCursor m.world)
    (isolated cfg (boundaries b) initial (branches b) (m.locals b).consumed)

/-- Identity lookup on a recursive or roster local list. DFS leaf order need not
equal roster order; callers compare by identity, not by raw list equality. -/
def lookupIsolatedLocal (pairs : List (B × CanonicalLocal P A D)) (b : B) :
    Option (CanonicalLocal P A D) :=
  match pairs.find? (fun pair => decide (pair.1 = b)) with
  | some pair => some pair.2
  | none => none

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
set_option linter.unusedVariables false

theorem isolated_zero (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) :
    isolated cfg boundary initial branch 0 = startCursor cfg initial :=
  rfl

theorem isolated_step (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) (n : Nat)
    (inv : Invocation P A D) (h : branch[n]? = some inv) :
    isolated cfg boundary initial branch (n + 1) =
      Composition.advance cfg boundary (isolated cfg boundary initial branch n)
        (.invoke inv) := by
  have ht : branch.take (n + 1) = branch.take n ++ [inv] := by
    rw [List.take_add_one]
    simp [h]
  simp only [isolated, ht, List.map_append, List.map_cons, List.map_nil, Composition.run]
  rw [Composition.continueRun_append]
  rfl

theorem isolated_exhausted (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) (n : Nat)
    (h : branch[n]? = none) :
    isolated cfg boundary initial branch (n + 1) =
      isolated cfg boundary initial branch n := by
  simp [isolated, List.take_add_one, h]

theorem isolated_full (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) :
    isolated cfg boundary initial branch branch.length =
      runBranch cfg boundary initial branch := by
  simp [isolated, runBranch]

theorem canonicalEventEq_iff (left right : EventObservation P A D) :
    canonicalEventEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [canonicalEventEq, canonicalReceiptEq, EventObservation.mk.injEq, and_assoc]

theorem canonicalEventsEq_iff :
    ∀ left right : List (EventObservation P A D),
      canonicalEventsEq left right = true ↔ left = right
  | [], [] => by simp [canonicalEventsEq]
  | _ :: _, [] => by simp [canonicalEventsEq]
  | [], _ :: _ => by simp [canonicalEventsEq]
  | a :: as, b :: bs => by
    simp [canonicalEventsEq, canonicalEventEq_iff, canonicalEventsEq_iff as bs,
      List.cons.injEq]

theorem canonicalBranchEq_iff (left right : BranchObservation P A D) :
    canonicalBranchEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [canonicalBranchEq, canonicalEventsEq_iff, BranchObservation.mk.injEq, and_assoc]

theorem canonicalLocalEq_iff (left right : CanonicalLocal P A D) :
    canonicalLocalEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [canonicalLocalEq, canonicalBranchEq_iff, CanonicalLocal.mk.injEq]

theorem canonicalLocalsEq_iff :
    ∀ left right : List (B × CanonicalLocal P A D),
      canonicalLocalsEq left right = true ↔ left = right
  | [], [] => by simp [canonicalLocalsEq]
  | _ :: _, [] => by simp [canonicalLocalsEq]
  | [], _ :: _ => by simp [canonicalLocalsEq]
  | a :: as, b :: bs => by
    cases a
    cases b
    simp [canonicalLocalsEq, canonicalLocalEq_iff, canonicalLocalsEq_iff as bs,
      List.cons.injEq]

theorem canonicalEq_iff (left right : CanonicalObservation B P A D) :
    canonicalEq left right = true ↔
      Parallel.WorldEquivalent left.world right.world ∧ left.locals = right.locals := by
  cases left
  cases right
  simp [canonicalEq, Parallel.worldEq_iff, canonicalLocalsEq_iff]

theorem competing_writes_not_compatible (left right : Footprint P A D)
    (c : Cell P A D) (hl : c ∈ left.writes) (hr : c ∈ right.writes) :
    ¬ Compatible left right := by
  intro hc
  exact hc.1 c hl hr

theorem mergeOwned_outside (leftFp rightFp : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D)
    (hl : c ∉ leftFp.writes) (hr : c ∉ rightFp.writes) :
    (mergeOwned leftFp rightFp initial left right).state.balance c =
      initial.state.balance c :=
  mergeBalance_outside leftFp rightFp initial left right c hl hr

theorem mergeOwned_eq_mergeWorld (leftFp rightFp : Footprint P A D)
    (initial left right : World P A D) :
    Parallel.WorldEquivalent
      (mergeOwned leftFp rightFp initial left right)
      (Parallel.mergeWorld leftFp rightFp initial left right) := by
  refine ⟨?_, rfl⟩
  intro c
  simp [mergeOwned, mergeBalance, Parallel.mergeWorld]

theorem nary_advance_own_cursor (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Nary.Machine B P A D) (b : B)
    (inv : Invocation P A D)
    (selected : (branches b)[(m.locals b).consumed]? = some inv) :
    let post := Nary.advance cfg boundaries branches m b
    (post.locals b).toCursor post.world =
      Composition.advance cfg (boundaries b) ((m.locals b).toCursor m.world)
        (.invoke inv) := by
  dsimp only
  cases hf : (m.locals b).failure with
  | some failure =>
    have hs : (m.locals b).failure.isSome = true := by simp [hf]
    have hadv := Nary.advance_eq_skip_of_isSome cfg boundaries branches m b hs
    rw [hadv]
    simp [Nary.skip_world, Nary.skip_selected, Interleaving.LocalState.toCursor,
      Composition.advance, hf]
  | none =>
    cases hex : executeStep cfg (boundaries b (m.locals b).nextIndex)
        (m.locals b).nextIndex (m.locals b).outputs (.invoke inv) m.world with
    | error reason =>
      have hadv := Nary.advance_eq_refuse cfg boundaries branches m b inv reason
        (by simp [hf]) selected hex
      rw [hadv]
      simp [Nary.refuse_world, Nary.refuse_selected, Interleaving.LocalState.toCursor,
        Composition.advance, hf, hex]
    | ok result =>
      have hadv := Nary.advance_eq_accept cfg boundaries branches m b inv result
        (by simp [hf]) selected hex
      rw [hadv]
      simp [Nary.accept_world, Nary.accept_selected, Interleaving.LocalState.toCursor,
        Composition.advance, hf, hex]

theorem nary_advance_exhausted_cursor (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (m : Nary.Machine B P A D) (b : B)
    (absent : (branches b)[(m.locals b).consumed]? = none) :
    let post := Nary.advance cfg boundaries branches m b
    (post.locals b).toCursor post.world = (m.locals b).toCursor m.world := by
  dsimp only
  cases hf : (m.locals b).failure with
  | some failure =>
    have hs : (m.locals b).failure.isSome = true := by simp [hf]
    have hadv := Nary.advance_eq_skip_of_isSome cfg boundaries branches m b hs
    rw [hadv]
    simp [Nary.skip_world, Nary.skip_selected, Interleaving.LocalState.toCursor]
  | none =>
    have hadv := Nary.advance_eq_skip_of_absent cfg boundaries branches m b
      (by simp [hf]) absent
    rw [hadv]
    simp [Nary.skip_world, Nary.skip_selected, Interleaving.LocalState.toCursor]

theorem nary_advance_peer (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Nary.Machine B P A D) (b peer : B)
    (hne : peer ≠ b) :
    (Nary.advance cfg boundaries branches m b).locals peer = m.locals peer :=
  (Nary.advance_sound cfg boundaries branches m b).away peer hne

theorem Simulates.start (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D))
    (hv : validateCatalog cfg.registry cfg.catalog = true) :
    Simulates cfg boundaries initial branches assoc (Nary.start initial) := by
  intro b
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro _ _; rfl
  · rfl
  · rfl
  · rfl
  · rfl
  · simp [isolated, Composition.run, startCursor, Composition.continueRun,
      Nary.start_locals, Interleaving.LocalState.toCursor, hv]

theorem analyzeAll_map_fst (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) :
    ∀ order fps, Nary.analyzeAll cfg boundaries branches order = .ok fps →
      fps.map Prod.fst = order := by
  intro order
  induction order with
  | nil =>
    intro fps h
    simp [Nary.analyzeAll] at h
    simp [h]
  | cons x rest ih =>
    intro fps h
    cases hx : (Parallel.analyzeBranch cfg (boundaries x) (branches x)).mapError
        (Nary.AdmissionFailure.structural x) with
    | error reason =>
      have herr : Nary.analyzeAll cfg boundaries branches (x :: rest) = .error reason := by
        simp [Nary.analyzeAll, hx]
      rw [herr] at h
      cases h
    | ok fp =>
      cases hr : Nary.analyzeAll cfg boundaries branches rest with
      | error reason =>
        have herr : Nary.analyzeAll cfg boundaries branches (x :: rest) = .error reason := by
          simp [Nary.analyzeAll, hx, hr]
        rw [herr] at h
        cases h
      | ok tail =>
        have hok : Nary.analyzeAll cfg boundaries branches (x :: rest) =
            .ok ((x, fp) :: tail) := by
          simp [Nary.analyzeAll, hx, hr]
        rw [hok] at h
        obtain rfl := Except.ok.inj h
        simp
        exact ih tail hr

theorem analyzeAll_nodup (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (order : List B)
    (assoc : List (B × Footprint P A D)) (hn : order.Nodup)
    (ha : Nary.analyzeAll cfg boundaries branches order = .ok assoc) :
    (assoc.map Prod.fst).Nodup := by
  simpa [analyzeAll_map_fst cfg boundaries branches order assoc ha] using hn

theorem footprintOf_of_mem (assoc : List (B × Footprint P A D)) (b : B)
    (fp : Footprint P A D) (hmem : (b, fp) ∈ assoc)
    (hn : (assoc.map Prod.fst).Nodup) :
    footprintOf assoc b = fp := by
  induction assoc with
  | nil => cases hmem
  | cons head rest ih =>
    have hkeys : (head.1 :: rest.map Prod.fst).Nodup := by simpa using hn
    have hnin := (List.nodup_cons.mp hkeys).1
    have hrest := (List.nodup_cons.mp hkeys).2
    simp only [List.mem_cons] at hmem
    rcases hmem with hhe | hre
    · cases head with
      | mk id f =>
        simp only [Prod.mk.injEq] at hhe
        rcases hhe with ⟨rfl, rfl⟩
        exact footprintOf_cons_eq b fp rest
    · have hne : head.1 ≠ b := by
        intro heq
        exact hnin (List.mem_map.mpr ⟨(b, fp), hre, heq.symm⟩)
      rw [footprintOf_cons_ne _ _ _ _ hne]
      exact ih hre hrest

theorem admitted_branch (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc) (b : B) :
    Parallel.analyzeBranch cfg (boundaries b) (branches b) =
      .ok (footprintOf assoc b) := by
  obtain ⟨fp, hmem, hbr⟩ := Nary.analyzeAll_lookup cfg boundaries branches
    roster.order assoc ha b (roster.complete b)
  have hfp := footprintOf_of_mem assoc b fp hmem
    (analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha)
  simpa [hfp] using hbr

theorem selected_part (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (b : B) (n : Nat) (inv : Invocation P A D)
    (selected : (branches b)[n]? = some inv) :
    ∃ part, Parallel.analyzeInvocation cfg (boundaries b n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ (footprintOf assoc b).reads) ∧
      (∀ c ∈ part.writes, c ∈ (footprintOf assoc b).writes) := by
  have hbr := admitted_branch cfg boundaries branches roster assoc ha b
  obtain ⟨part, hf, hr, hw⟩ := Parallel.analyzeBranchFrom_member cfg (boundaries b) 0
    (branches b) (footprintOf assoc b) (by simpa [Parallel.analyzeBranch] using hbr)
    n inv selected
  exact ⟨part, by simpa using hf, hr, hw⟩

theorem unique_writer (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (b1 b2 : B) (hne : b1 ≠ b2)
    (c : Cell P A D) (h1 : c ∈ (footprintOf assoc b1).writes)
    (h2 : c ∈ (footprintOf assoc b2).writes) : False := by
  obtain ⟨fp1, hm1, _⟩ := Nary.analyzeAll_lookup cfg boundaries branches
    roster.order assoc ha b1 (roster.complete b1)
  obtain ⟨fp2, hm2, _⟩ := Nary.analyzeAll_lookup cfg boundaries branches
    roster.order assoc ha b2 (roster.complete b2)
  have hf1 := footprintOf_of_mem assoc b1 fp1 hm1
    (analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha)
  have hf2 := footprintOf_of_mem assoc b2 fp2 hm2
    (analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha)
  rw [hf1] at h1
  rw [hf2] at h2
  exact (hc (b1, fp1) hm1 (b2, fp2) hm2 hne).1 c h1 h2

theorem compatible_peer_reads (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (b peer : B) (hne : b ≠ peer)
    (c : Cell P A D) (hr : c ∈ (footprintOf assoc peer).reads) :
    c ∉ (footprintOf assoc b).writes := by
  obtain ⟨fpb, hmb, _⟩ := Nary.analyzeAll_lookup cfg boundaries branches
    roster.order assoc ha b (roster.complete b)
  obtain ⟨fpp, hmp, _⟩ := Nary.analyzeAll_lookup cfg boundaries branches
    roster.order assoc ha peer (roster.complete peer)
  have hfb := footprintOf_of_mem assoc b fpb hmb
    (analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha)
  have hfp := footprintOf_of_mem assoc peer fpp hmp
    (analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha)
  intro hw
  rw [hfb] at hw
  rw [hfp] at hr
  exact (hc (b, fpb) hmb (peer, fpp) hmp hne).2.1 c hw hr

theorem advance_branch_frame (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (m : Nary.Machine B P A D)
    (reach : Nary.Reachable cfg boundaries branches initial m) (b : B) :
    ∀ c, c ∉ (footprintOf assoc b).writes →
      (Nary.advance cfg boundaries branches m b).world.state.balance c =
        m.world.state.balance c := by
  have hs := Nary.advance_sound cfg boundaries branches m b
  generalize he : Nary.advance cfg boundaries branches m b = post at hs ⊢
  cases hs with
  | halted => intro c hc; rw [Nary.skip_world]
  | exhausted => intro c hc; rw [Nary.skip_world]
  | refused => intro c hc; rw [Nary.refuse_world]
  | accepted inv result active selected executed =>
    obtain ⟨part, hf, _, hw⟩ := selected_part cfg boundaries branches roster assoc ha b
      (m.locals b).consumed inv selected
    rw [← reach.attempt_index b active inv selected] at hf
    have frame := Parallel.executeStep_target_frame cfg
      (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs inv m.world result part hf executed
    intro c hc
    exact frame.1 c (fun h ↦ hc (hw c h))

theorem advance_own_agrees (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (m : Nary.Machine B P A D)
    (reach : Nary.Reachable cfg boundaries branches initial m) (b : B)
    (hsim : CursorAgrees {c | c ∈ (isolatedFootprint assoc b).reads}
      ((m.locals b).toCursor m.world)
      (isolated cfg (boundaries b) initial (branches b) (m.locals b).consumed)) :
    let post := Nary.advance cfg boundaries branches m b
    CursorAgrees {c | c ∈ (isolatedFootprint assoc b).reads}
      ((post.locals b).toCursor post.world)
      (isolated cfg (boundaries b) initial (branches b)
        (post.locals b).consumed) := by
  dsimp only
  rw [Nary.advance_consumed cfg boundaries branches m b b]
  simp only [↓reduceIte]
  cases selected : (branches b)[(m.locals b).consumed]? with
  | none =>
    rw [isolated_exhausted cfg (boundaries b) initial (branches b) _ selected,
      nary_advance_exhausted_cursor cfg boundaries branches m b selected]
    exact hsim
  | some inv =>
    rw [isolated_step cfg (boundaries b) initial (branches b) _ inv selected,
      nary_advance_own_cursor cfg boundaries branches m b inv selected]
    cases hf : (m.locals b).failure with
    | some failure =>
      have hr : (isolated cfg (boundaries b) initial (branches b)
          (m.locals b).consumed).failure = some failure :=
        hsim.failure.symm.trans hf
      simpa [Composition.advance, Interleaving.LocalState.toCursor, hf, hr] using hsim
    | none =>
      have hi := reach.attempt_index b hf inv selected
      obtain ⟨part, hinv, hin, _⟩ :=
        selected_part cfg boundaries branches roster assoc ha b
          (m.locals b).consumed inv selected
      have hinv' : Parallel.analyzeInvocation cfg
          (boundaries b (m.locals b).nextIndex) inv = .ok part := by
        rw [hi]; exact hinv
      exact Interleaving.Recovery.cursor_advance_congr cfg (boundaries b) inv
        (m.locals b).nextIndex part
        {c | c ∈ (isolatedFootprint assoc b).reads}
        ((m.locals b).toCursor m.world)
        (isolated cfg (boundaries b) initial (branches b) (m.locals b).consumed)
        hinv' hin rfl hsim

theorem advance_simulates (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (m : Nary.Machine B P A D)
    (reach : Nary.Reachable cfg boundaries branches initial m)
    (hsim : Simulates cfg boundaries initial branches assoc m) (b : B) :
    Simulates cfg boundaries initial branches assoc
      (Nary.advance cfg boundaries branches m b) := by
  intro own
  by_cases heq : b = own
  · subst own
    exact advance_own_agrees cfg boundaries initial branches roster assoc ha m reach b (hsim b)
  · have hne : own ≠ b := Ne.symm heq
    rw [nary_advance_peer cfg boundaries branches m b own hne]
    have old := hsim own
    refine ⟨?_, ?_, old.events, old.outputs, old.nextIndex, old.failure⟩
    · intro c hr
      exact (advance_branch_frame cfg boundaries initial branches roster assoc ha m reach b c
        (compatible_peer_reads cfg boundaries branches roster assoc ha hc b own heq c hr)).trans
        (old.state c hr)
    · exact (Nary.advance_sound cfg boundaries branches m b).store.trans old.capabilities

theorem continue_simulates (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (m : Nary.Machine B P A D)
    (reach : Nary.Reachable cfg boundaries branches initial m)
    (hsim : Simulates cfg boundaries initial branches assoc m)
    (schedule : Schedule B) :
    Simulates cfg boundaries initial branches assoc
      (Nary.continueRun cfg boundaries branches m schedule) := by
  induction schedule generalizing m with
  | nil => exact hsim
  | cons b tail ih =>
    exact ih _ (.next b reach (Nary.advance_sound cfg boundaries branches m b))
      (advance_simulates cfg boundaries initial branches roster assoc ha hc m reach hsim b)

theorem runPrefix_simulates (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (schedule : Schedule B) :
    Simulates cfg boundaries initial branches assoc
      (Nary.runPrefix cfg boundaries initial branches schedule) :=
  continue_simulates cfg boundaries initial branches roster assoc ha hc
    (Nary.start initial) .start (Simulates.start cfg boundaries initial branches assoc hv)
    schedule

theorem wellFormed_mem_leaves (roster : Roster B) (tree : Tree B)
    (hwf : WellFormed roster tree) (b : B) :
    b ∈ Tree.leaves tree ↔ b ∈ roster.order := by
  constructor
  · intro _
    exact roster.complete b
  · intro hb
    have hc : Tree.count tree b = 1 := hwf b hb
    exact (mem_leaves_iff_count_pos tree b).mpr (by simp [hc])

theorem wellFormed_leaves_nodup (roster : Roster B) (tree : Tree B)
    (hwf : WellFormed roster tree) : (Tree.leaves tree).Nodup := by
  refine List.nodup_iff_count_le_one.mpr ?_
  intro b
  have h := hwf b (roster.complete b)
  exact le_of_eq (by simpa [Tree.count] using h)

theorem foldl_fork_leaves_from (acc : Tree B) :
    ∀ ids, Tree.leaves (ids.foldl (fun t x => t.fork (.leaf x)) acc) =
      Tree.leaves acc ++ ids
  | [] => by simp
  | x :: rest => by
    simp [List.foldl_cons, Tree.leaves,
      foldl_fork_leaves_from (acc.fork (.leaf x)) rest]

theorem foldl_fork_leaves (ids : List B) :
    Tree.leaves (ids.foldl (fun t x => t.fork (.leaf x)) (Tree.empty : Tree B)) = ids := by
  simpa [Tree.leaves] using foldl_fork_leaves_from (Tree.empty : Tree B) ids

theorem mem_analyzedWrites_iff (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (c : Cell P A D) :
    c ∈ Nary.analyzedWrites assoc ↔
      ∃ b ∈ roster.order, c ∈ (footprintOf assoc b).writes := by
  have hkeys := analyzeAll_map_fst cfg boundaries branches roster.order assoc ha
  have hn := analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha
  constructor
  · intro h
    obtain ⟨pair, hmem, hc⟩ := List.mem_flatMap.mp h
    refine ⟨pair.1, ?_, ?_⟩
    · have : pair.1 ∈ assoc.map Prod.fst := List.mem_map.mpr ⟨pair, hmem, rfl⟩
      simpa [hkeys] using this
    · have hfp := footprintOf_of_mem assoc pair.1 pair.2 hmem hn
      simpa [hfp] using hc
  · intro ⟨b, hb, hc⟩
    obtain ⟨fp, hmem, _⟩ := Nary.analyzeAll_lookup cfg boundaries branches
      roster.order assoc ha b hb
    have hfp := footprintOf_of_mem assoc b fp hmem hn
    rw [hfp] at hc
    exact Nary.mem_analyzedWrites hmem hc

theorem admitted_writes_read (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (b : B) (c : Cell P A D) (hw : c ∈ (footprintOf assoc b).writes) :
    c ∈ (footprintOf assoc b).reads :=
  Parallel.analyzeBranchFrom_writes_read cfg (boundaries b) 0 (branches b)
    (footprintOf assoc b)
    (by simpa [Parallel.analyzeBranch] using
      admitted_branch cfg boundaries branches roster assoc ha b) c hw

theorem runIsolatedLeaf_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) (fp : Footprint P A D)
    (hbr : Parallel.analyzeBranch cfg boundary branch = .ok fp)
    (c : Cell P A D) (hc : c ∉ fp.writes) :
    (runIsolatedLeaf cfg boundary initial branch).world.state.balance c =
      initial.state.balance c :=
  (Parallel.runBranch_frame cfg boundary initial branch fp hbr).1 c hc

theorem runIsolatedTree_store (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc) :
    ∀ tree, (runIsolatedTree cfg boundaries initial branches assoc tree).1.capabilities =
      initial.capabilities
  | .empty => rfl
  | .leaf b =>
    (Parallel.runBranch_frame cfg (boundaries b) initial (branches b)
      (footprintOf assoc b)
      (admitted_branch cfg boundaries branches roster assoc ha b)).2
  | .fork left right => by
    simp [runIsolatedTree, mergeOwned]

theorem foldIsolatedWorld_store (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D)) :
    ∀ order, (foldIsolatedWorld cfg boundaries initial branches assoc order).capabilities =
      initial.capabilities
  | [] => rfl
  | _ :: _ => by
    simp [foldIsolatedWorld, mergeOwned]

theorem runIsolatedTree_unowned (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc) :
    ∀ tree c, (∀ b ∈ Tree.leaves tree, c ∉ (footprintOf assoc b).writes) →
      (runIsolatedTree cfg boundaries initial branches assoc tree).1.state.balance c =
        initial.state.balance c
  | .empty, c, _ => rfl
  | .leaf b, c, hu =>
    runIsolatedLeaf_frame cfg (boundaries b) initial (branches b) (footprintOf assoc b)
      (admitted_branch cfg boundaries branches roster assoc ha b) c
      (hu b (by simp [Tree.leaves]))
  | .fork left right, c, hu => by
    have hl : c ∉ (unionLeaves assoc left).writes := by
      intro hw
      obtain ⟨b, hb, hwb⟩ := (mem_unionLeaves_writes assoc left c).mp hw
      exact hu b (by simp [Tree.leaves, hb]) hwb
    have hr : c ∉ (unionLeaves assoc right).writes := by
      intro hw
      obtain ⟨b, hb, hwb⟩ := (mem_unionLeaves_writes assoc right c).mp hw
      exact hu b (by simp [Tree.leaves, hb]) hwb
    simp [runIsolatedTree, mergeOwned, mergeBalance, hl, hr]

theorem runIsolatedTree_owner (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) :
    ∀ tree b, b ∈ Tree.leaves tree → ∀ c, c ∈ (footprintOf assoc b).writes →
      (runIsolatedTree cfg boundaries initial branches assoc tree).1.state.balance c =
        (runIsolatedLeaf cfg (boundaries b) initial (branches b)).world.state.balance c
  | .empty, b, hb, c, hw => by simp [Tree.leaves] at hb
  | .leaf x, b, hb, c, hw => by
    have hx : b = x := by simpa [Tree.leaves] using hb
    cases hx
    rfl
  | .fork left right, b, hb, c, hw => by
    simp only [Tree.leaves, List.mem_append] at hb
    by_cases hL : b ∈ Tree.leaves left
    · have hl : c ∈ (unionLeaves assoc left).writes :=
        (mem_unionLeaves_writes assoc left c).mpr ⟨b, hL, hw⟩
      simp [runIsolatedTree, mergeOwned, mergeBalance, hl]
      exact runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
        left b hL c hw
    · have hR : b ∈ Tree.leaves right := by
        rcases hb with hLb | hRb
        · exact (hL hLb).elim
        · exact hRb
      have hl : c ∉ (unionLeaves assoc left).writes := by
        intro hLw
        obtain ⟨b', hb', hw'⟩ := (mem_unionLeaves_writes assoc left c).mp hLw
        have hne : b' ≠ b := fun heq => hL (heq ▸ hb')
        exact unique_writer cfg boundaries branches roster assoc ha hc b' b hne c hw' hw
      have hr : c ∈ (unionLeaves assoc right).writes :=
        (mem_unionLeaves_writes assoc right c).mpr ⟨b, hR, hw⟩
      simp [runIsolatedTree, mergeOwned, mergeBalance, hl, hr]
      exact runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
        right b hR c hw

theorem runIsolatedTree_leaves_eq (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (left right : Tree B)
    (hs : ∀ b, b ∈ Tree.leaves left ↔ b ∈ Tree.leaves right) :
    Parallel.WorldEquivalent
      (runIsolatedTree cfg boundaries initial branches assoc left).1
      (runIsolatedTree cfg boundaries initial branches assoc right).1 := by
  refine ⟨?_, ?_⟩
  · intro cell
    by_cases hex : ∃ b ∈ Tree.leaves left, cell ∈ (footprintOf assoc b).writes
    · obtain ⟨b, hb, hw⟩ := hex
      have hb' : b ∈ Tree.leaves right := (hs b).mp hb
      exact (runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
          left b hb cell hw).trans
        (runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
          right b hb' cell hw).symm
    · have huL : ∀ b ∈ Tree.leaves left, cell ∉ (footprintOf assoc b).writes :=
        fun b hb hw => hex ⟨b, hb, hw⟩
      have huR : ∀ b ∈ Tree.leaves right, cell ∉ (footprintOf assoc b).writes :=
        fun b hb hw => hex ⟨b, (hs b).mpr hb, hw⟩
      exact (runIsolatedTree_unowned cfg boundaries initial branches roster assoc ha
          left cell huL).trans
        (runIsolatedTree_unowned cfg boundaries initial branches roster assoc ha
          right cell huR).symm
  · rw [runIsolatedTree_store cfg boundaries initial branches roster assoc ha left,
      runIsolatedTree_store cfg boundaries initial branches roster assoc ha right]

theorem runIsolatedTree_empty_left (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (tree : Tree B) :
    Parallel.WorldEquivalent
      (runIsolatedTree cfg boundaries initial branches assoc
        ((Tree.empty : Tree B).fork tree)).1
      (runIsolatedTree cfg boundaries initial branches assoc tree).1 :=
  runIsolatedTree_leaves_eq cfg boundaries initial branches roster assoc ha hc _ _
    (by intro b; simp [Tree.leaves])

theorem runIsolatedTree_empty_right (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (tree : Tree B) :
    Parallel.WorldEquivalent
      (runIsolatedTree cfg boundaries initial branches assoc
        (tree.fork (Tree.empty : Tree B))).1
      (runIsolatedTree cfg boundaries initial branches assoc tree).1 :=
  runIsolatedTree_leaves_eq cfg boundaries initial branches roster assoc ha hc _ _
    (by intro b; simp [Tree.leaves])

theorem runIsolatedTree_assoc (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (a b c : Tree B) :
    Parallel.WorldEquivalent
      (runIsolatedTree cfg boundaries initial branches assoc ((a.fork b).fork c)).1
      (runIsolatedTree cfg boundaries initial branches assoc (a.fork (b.fork c))).1 :=
  runIsolatedTree_leaves_eq cfg boundaries initial branches roster assoc ha hc _ _
    (fun x => by simp [Tree.leaves, List.mem_append]; try tauto)

theorem foldIsolatedWorld_unowned (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D)) :
    ∀ order c, (∀ b ∈ order, c ∉ (footprintOf assoc b).writes) →
      (foldIsolatedWorld cfg boundaries initial branches assoc order).state.balance c =
        initial.state.balance c
  | [], c, _ => rfl
  | x :: rest, c, hu => by
    have hl : c ∉ (footprintOf assoc x).writes := hu x (by simp)
    have hr : c ∉ (unionLeaves assoc
        (rest.foldl (fun t y => t.fork (.leaf y)) Tree.empty)).writes := by
      intro hw
      obtain ⟨b, hb, hwb⟩ := (mem_unionLeaves_writes assoc _ c).mp hw
      have hb' : b ∈ rest := by
        simpa [foldl_fork_leaves] using hb
      exact hu b (by simp [hb']) hwb
    simp [foldIsolatedWorld, mergeOwned, mergeBalance, hl, hr]

theorem foldIsolatedWorld_owner (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) :
    ∀ order, order.Nodup → ∀ b, b ∈ order → ∀ c, c ∈ (footprintOf assoc b).writes →
      (foldIsolatedWorld cfg boundaries initial branches assoc order).state.balance c =
        (runIsolatedLeaf cfg (boundaries b) initial (branches b)).world.state.balance c
  | [], hn, b, hb, c, hw => by cases hb
  | x :: rest, hn, b, hb, c, hw => by
    have hnin := (List.nodup_cons.mp hn).1
    have hrest := (List.nodup_cons.mp hn).2
    simp only [List.mem_cons] at hb
    rcases hb with hxe | hre
    · have hl : c ∈ (footprintOf assoc x).writes := by
        simpa [hxe] using hw
      simp [foldIsolatedWorld, mergeOwned, mergeBalance, hl]
      subst hxe
      rfl
    · have hne : x ≠ b := fun heq => hnin (heq ▸ hre)
      have hl : c ∉ (footprintOf assoc x).writes := fun hwx =>
        unique_writer cfg boundaries branches roster assoc ha hc x b hne c hwx hw
      have hr : c ∈ (unionLeaves assoc
          (rest.foldl (fun t y => t.fork (.leaf y)) Tree.empty)).writes := by
        refine (mem_unionLeaves_writes assoc _ c).mpr ⟨b, ?_, hw⟩
        simpa [foldl_fork_leaves] using hre
      simp [foldIsolatedWorld, mergeOwned, mergeBalance, hl, hr]
      exact foldIsolatedWorld_owner cfg boundaries initial branches roster assoc ha hc
        rest hrest b hre c hw

theorem runIsolatedTree_flat (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (hwf : WellFormed roster tree)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) :
    Parallel.WorldEquivalent
      (runIsolatedTree cfg boundaries initial branches assoc tree).1
      (foldIsolatedWorld cfg boundaries initial branches assoc roster.order) := by
  refine ⟨?_, ?_⟩
  · intro cell
    by_cases hex : ∃ b ∈ Tree.leaves tree, cell ∈ (footprintOf assoc b).writes
    · obtain ⟨b, hb, hw⟩ := hex
      have hb' : b ∈ roster.order := (wellFormed_mem_leaves roster tree hwf b).mp hb
      exact (runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
          tree b hb cell hw).trans
        (foldIsolatedWorld_owner cfg boundaries initial branches roster assoc ha hc
          roster.order roster.nodup b hb' cell hw).symm
    · have huT : ∀ b ∈ Tree.leaves tree, cell ∉ (footprintOf assoc b).writes :=
        fun b hb hw => hex ⟨b, hb, hw⟩
      have huO : ∀ b ∈ roster.order, cell ∉ (footprintOf assoc b).writes :=
        fun b hb hw => hex ⟨b, (wellFormed_mem_leaves roster tree hwf b).mpr hb, hw⟩
      exact (runIsolatedTree_unowned cfg boundaries initial branches roster assoc ha
          tree cell huT).trans
        (foldIsolatedWorld_unowned cfg boundaries initial branches assoc
          roster.order cell huO).symm
  · rw [runIsolatedTree_store cfg boundaries initial branches roster assoc ha tree,
      foldIsolatedWorld_store cfg boundaries initial branches assoc roster.order]

theorem runIsolatedTree_frame (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (c : Cell P A D) (hc : c ∉ (unionLeaves assoc tree).writes) :
    (runIsolatedTree cfg boundaries initial branches assoc tree).1.state.balance c =
      initial.state.balance c :=
  runIsolatedTree_unowned cfg boundaries initial branches roster assoc ha tree c
    (fun b hb hw => hc ((mem_unionLeaves_writes assoc tree c).mpr ⟨b, hb, hw⟩))

/-- Arbitrary populated-entry schedule independence is not claimed. Recovery theorems
start from genesis `Nary.start` / `runTreePrefix`. -/
theorem continue_outside (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (m : Nary.Machine B P A D)
    (reach : Nary.Reachable cfg boundaries branches initial m)
    (schedule : Schedule B) (c : Cell P A D)
    (hu : ∀ b, c ∉ (footprintOf assoc b).writes) :
    (Nary.continueRun cfg boundaries branches m schedule).world.state.balance c =
      m.world.state.balance c := by
  induction schedule generalizing m with
  | nil => rfl
  | cons b tail ih =>
    exact (ih _ (.next b reach (Nary.advance_sound cfg boundaries branches m b))).trans
      (advance_branch_frame cfg boundaries initial branches roster assoc ha m reach b c (hu b))

theorem complete_consumed (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (hC : Nary.Complete branches schedule) (b : B) :
    ((Nary.runPrefix cfg boundaries initial branches schedule).locals b).consumed =
      (branches b).length := by
  rw [Nary.runPrefix_consumed, hC b]

theorem complete_local_observation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D))
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (schedule : Schedule B)
    (hC : Nary.Complete branches schedule) (b : B) :
    toCanonicalLocal
        ((Nary.runPrefix cfg boundaries initial branches schedule).locals b)
        (Nary.runPrefix cfg boundaries initial branches schedule).world =
      isolatedCanonicalLocal
        (runIsolatedLeaf cfg (boundaries b) initial (branches b)).cursor
        (branches b) := by
  have hsim := runPrefix_simulates cfg boundaries initial branches roster assoc hv ha hc schedule
  have hcons := complete_consumed cfg boundaries initial branches schedule hC b
  have hagree : CursorAgrees {c | c ∈ (isolatedFootprint assoc b).reads}
      (((Nary.runPrefix cfg boundaries initial branches schedule).locals b).toCursor
        (Nary.runPrefix cfg boundaries initial branches schedule).world)
      (runBranch cfg (boundaries b) initial (branches b)) := by
    have h := hsim b
    rw [hcons] at h
    simpa [isolated_full] using h
  simp [toCanonicalLocal, isolatedCanonicalLocal, isolatedConsumed, runIsolatedLeaf_cursor]
  exact ⟨hcons, hagree.observation⟩

theorem complete_world (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B) (schedule : Schedule B)
    (hwf : WellFormed roster tree)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (hC : Nary.Complete branches schedule) :
    Parallel.WorldEquivalent
      (Nary.runPrefix cfg boundaries initial branches schedule).world
      (runIsolatedTree cfg boundaries initial branches assoc tree).1 := by
  refine ⟨?_, ?_⟩
  · intro cell
    have hreach := Nary.runPrefix_reachable cfg boundaries initial branches schedule
    have hsim := runPrefix_simulates cfg boundaries initial branches roster assoc hv ha hc schedule
    by_cases hw : cell ∈ Nary.analyzedWrites assoc
    · obtain ⟨b, hb, hwc⟩ := (mem_analyzedWrites_iff cfg boundaries branches roster assoc ha
        cell).mp hw
      have hleaf : b ∈ Tree.leaves tree := (wellFormed_mem_leaves roster tree hwf b).mpr hb
      have hcons := complete_consumed cfg boundaries initial branches schedule hC b
      have hagree : CursorAgrees {c | c ∈ (isolatedFootprint assoc b).reads}
          (((Nary.runPrefix cfg boundaries initial branches schedule).locals b).toCursor
            (Nary.runPrefix cfg boundaries initial branches schedule).world)
          (runBranch cfg (boundaries b) initial (branches b)) := by
        have h := hsim b
        rw [hcons] at h
        simpa [isolated_full] using h
      have hr := admitted_writes_read cfg boundaries branches roster assoc ha b cell hwc
      have hshared := hagree.state cell hr
      have hown := runIsolatedTree_owner cfg boundaries initial branches roster assoc ha hc
        tree b hleaf cell hwc
      change (Nary.runPrefix cfg boundaries initial branches schedule).world.state.balance cell =
        (runIsolatedTree cfg boundaries initial branches assoc tree).1.state.balance cell
      simpa [Interleaving.LocalState.toCursor, runIsolatedLeaf_world] using
        hshared.trans hown.symm
    · have huO : ∀ b ∈ roster.order, cell ∉ (footprintOf assoc b).writes := by
        intro b hb hwc
        exact hw ((mem_analyzedWrites_iff cfg boundaries branches roster assoc ha cell).mpr
          ⟨b, hb, hwc⟩)
      have huT : ∀ b ∈ Tree.leaves tree, cell ∉ (footprintOf assoc b).writes :=
        fun b hb hwc => huO b ((wellFormed_mem_leaves roster tree hwf b).mp hb) hwc
      exact (hreach.analyzed_locality roster.order assoc roster.complete ha cell hw).trans
        (runIsolatedTree_unowned cfg boundaries initial branches roster assoc ha
          tree cell huT).symm
  · have hreach := Nary.runPrefix_reachable cfg boundaries initial branches schedule
    exact hreach.store.trans
      (runIsolatedTree_store cfg boundaries initial branches roster assoc ha tree).symm

theorem complete_schedule_canonicalEq (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B) (schedule : Schedule B)
    (hwf : WellFormed roster tree)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (hC : Nary.Complete branches schedule) :
    canonicalEq
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches schedule))
      (isolatedCanonical roster cfg boundaries initial branches assoc tree) = true := by
  have hflat := flatten_runTreePrefix cfg boundaries roster initial tree branches schedule hwf
  have hworld : (runTreePrefix cfg boundaries initial tree branches schedule).world =
      (Nary.runPrefix cfg boundaries initial branches schedule).world := by
    have := congrArg Nary.Machine.world hflat
    simpa [flattenMachine_world] using this
  have hloc : ∀ b, lookupCollected
      (collectLocals (runTreePrefix cfg boundaries initial tree branches schedule).locals) b =
      (Nary.runPrefix cfg boundaries initial branches schedule).locals b := by
    intro b
    have := congrArg (fun m => m.locals b) hflat
    simpa [flattenMachine_locals] using this
  rw [canonicalEq_iff]
  refine ⟨?_, ?_⟩
  · simp [canonicalOf, isolatedCanonical, hworld]
    exact complete_world cfg boundaries initial branches roster assoc tree schedule
      hwf hv ha hc hC
  · simp only [canonicalOf, isolatedCanonical, canonicalLocals, isolatedLocals]
    refine List.map_congr_left ?_
    intro b _hb
    simp [hloc, hworld]
    exact complete_local_observation cfg boundaries initial branches roster assoc hv ha hc
      schedule hC b

theorem canonicalEq_trans (a b c : CanonicalObservation B P A D)
    (h1 : canonicalEq a b = true) (h2 : canonicalEq b c = true) :
    canonicalEq a c = true := by
  have ⟨he1, hl1⟩ := (canonicalEq_iff a b).mp h1
  have ⟨he2, hl2⟩ := (canonicalEq_iff b c).mp h2
  exact (canonicalEq_iff a c).mpr
    ⟨⟨fun cell => (he1.1 cell).trans (he2.1 cell), he1.2.trans he2.2⟩, hl1.trans hl2⟩

theorem canonicalEq_symm (a b : CanonicalObservation B P A D)
    (h : canonicalEq a b = true) : canonicalEq b a = true := by
  have ⟨he, hl⟩ := (canonicalEq_iff a b).mp h
  exact (canonicalEq_iff b a).mpr ⟨⟨fun cell => (he.1 cell).symm, he.2.symm⟩, hl.symm⟩

/-- Complete compatible schedules from genesis empty locals are canonically independent.
Raw intermediate worlds and attempt order stay outside this projection. -/
theorem complete_schedule_independence (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (s1 s2 : Schedule B) (hwf : WellFormed roster tree)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc)
    (h1 : Nary.Complete branches s1) (h2 : Nary.Complete branches s2) :
    canonicalEq
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches s1))
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches s2)) = true :=
  canonicalEq_trans
    (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches s1))
    (isolatedCanonical roster cfg boundaries initial branches assoc tree)
    (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches s2))
    (complete_schedule_canonicalEq cfg boundaries initial branches roster assoc tree s1
      hwf hv ha hc h1)
    (canonicalEq_symm
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches s2))
      (isolatedCanonical roster cfg boundaries initial branches assoc tree)
      (complete_schedule_canonicalEq cfg boundaries initial branches roster assoc tree s2
        hwf hv ha hc h2))

theorem complete_schedule_canonicalEq_of_admitIsolated (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B) (schedule : Schedule B)
    (hiso : admitIsolated cfg roster boundaries branches schedule tree = .ok assoc) :
    canonicalEq
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches schedule))
      (isolatedCanonical roster cfg boundaries initial branches assoc tree) = true := by
  cases hTree : admitTree cfg roster boundaries branches schedule tree with
  | error reason =>
    simp [admitIsolated_base cfg roster boundaries branches schedule tree reason hTree] at hiso
  | ok fps =>
    cases hPair : checkPairwise fps with
    | error conflict =>
      simp [admitIsolated_conflict cfg roster boundaries branches schedule tree fps
        conflict hTree hPair] at hiso
    | ok _ =>
      have hok := admitIsolated_ok cfg roster boundaries branches schedule tree fps hTree hPair
      have hfps : fps = assoc := Except.ok.inj (hok.symm.trans hiso)
      cases hN : Nary.admit cfg roster boundaries branches schedule with
      | error reason =>
        simp [admitTree_base cfg roster boundaries branches schedule tree reason hN] at hTree
      | ok fps2 =>
        cases hChk : checkTree roster tree with
        | error failure =>
          simp [admitTree_tree cfg roster boundaries branches schedule tree fps2 failure
            hN hChk] at hTree
        | ok _ =>
          have hT := admitTree_ok cfg roster boundaries branches schedule tree fps2 hN hChk
          have hf2 : fps2 = fps := Except.ok.inj (hT.symm.trans hTree)
          have hNassoc : Nary.admit cfg roster boundaries branches schedule = .ok assoc := by
            rw [hN, hf2, hfps]
          obtain ⟨hv, ha, hC⟩ :=
            Nary.admit_ok cfg roster boundaries branches schedule assoc hNassoc
          have hwf : WellFormed roster tree := (wellFormed_iff_check roster tree).mpr hChk
          have hn := analyzeAll_nodup cfg boundaries branches roster.order assoc roster.nodup ha
          have hPair' : checkPairwise assoc = .ok () := by
            simpa [hfps] using hPair
          have hc : PairwiseCompatible assoc := (checkPairwise_ok_iff assoc hn).mp hPair'
          exact complete_schedule_canonicalEq cfg boundaries initial branches roster assoc
            tree schedule hwf hv ha hc hC

theorem isolatedLocals_nil (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) :
    isolatedLocals cfg boundaries initial branches [] = [] :=
  rfl

theorem isolatedLocals_append (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (xs ys : List B) :
    isolatedLocals cfg boundaries initial branches (xs ++ ys) =
      isolatedLocals cfg boundaries initial branches xs ++
        isolatedLocals cfg boundaries initial branches ys := by
  simp [isolatedLocals, List.map_append]

/-- Recursive isolated `.2` is the actual leaf execution list, in DFS order. -/
theorem runIsolatedTree_locals (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D)) :
    ∀ tree, (runIsolatedTree cfg boundaries initial branches assoc tree).2 =
      isolatedLocals cfg boundaries initial branches (Tree.leaves tree)
  | .empty => rfl
  | .leaf b => rfl
  | .fork left right => by
    simp [runIsolatedTree, Tree.leaves, isolatedLocals_append,
      runIsolatedTree_locals cfg boundaries initial branches assoc left,
      runIsolatedTree_locals cfg boundaries initial branches assoc right]

theorem runIsolatedTree_locals_empty_left (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (assoc : List (B × Footprint P A D)) (tree : Tree B) :
    (runIsolatedTree cfg boundaries initial branches assoc
      ((Tree.empty : Tree B).fork tree)).2 =
      (runIsolatedTree cfg boundaries initial branches assoc tree).2 := by
  simp [runIsolatedTree]

theorem runIsolatedTree_locals_empty_right (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (assoc : List (B × Footprint P A D)) (tree : Tree B) :
    (runIsolatedTree cfg boundaries initial branches assoc
      (tree.fork (Tree.empty : Tree B))).2 =
      (runIsolatedTree cfg boundaries initial branches assoc tree).2 := by
  simp [runIsolatedTree]

theorem runIsolatedTree_locals_assoc (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (assoc : List (B × Footprint P A D))
    (a b c : Tree B) :
    (runIsolatedTree cfg boundaries initial branches assoc ((a.fork b).fork c)).2 =
      (runIsolatedTree cfg boundaries initial branches assoc (a.fork (b.fork c))).2 := by
  simp [runIsolatedTree, List.append_assoc]

theorem lookupIsolatedLocal_nil (b : B) :
    lookupIsolatedLocal ([] : List (B × CanonicalLocal P A D)) b = none :=
  rfl

theorem lookupIsolatedLocal_cons_eq (b : B) (loc : CanonicalLocal P A D)
    (rest : List (B × CanonicalLocal P A D)) :
    lookupIsolatedLocal ((b, loc) :: rest) b = some loc := by
  simp [lookupIsolatedLocal]

theorem lookupIsolatedLocal_cons_ne (id b : B) (loc : CanonicalLocal P A D)
    (rest : List (B × CanonicalLocal P A D)) (h : id ≠ b) :
    lookupIsolatedLocal ((id, loc) :: rest) b = lookupIsolatedLocal rest b := by
  simp [lookupIsolatedLocal, h]

theorem lookupIsolatedLocal_map (f : B → CanonicalLocal P A D)
    (order : List B) (b : B) (hb : b ∈ order) :
    lookupIsolatedLocal (List.map (fun x => (x, f x)) order) b = some (f b) := by
  induction order with
  | nil => cases hb
  | cons x rest ih =>
    simp only [List.map_cons, List.mem_cons] at hb ⊢
    by_cases hx : x = b
    · rw [hx]
      exact lookupIsolatedLocal_cons_eq b (f b) (List.map (fun y => (y, f y)) rest)
    · have hb' : b ∈ rest := by
        rcases hb with hxe | hre
        · exact (hx hxe.symm).elim
        · exact hre
      rw [lookupIsolatedLocal_cons_ne x b (f x) (List.map (fun y => (y, f y)) rest) hx]
      exact ih hb'

theorem isolatedLocals_lookup_mem (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (order : List B)
    (b : B) (hb : b ∈ order) :
    lookupIsolatedLocal (isolatedLocals cfg boundaries initial branches order) b =
      some (isolatedCanonicalLocal
        (runIsolatedLeaf cfg (boundaries b) initial (branches b)).cursor
        (branches b)) :=
  lookupIsolatedLocal_map
    (fun x => isolatedCanonicalLocal
      (runIsolatedLeaf cfg (boundaries x) initial (branches x)).cursor
      (branches x))
    order b hb

theorem runIsolatedTree_lookup_mem (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Footprint P A D)) (tree : Tree B) (b : B)
    (hb : b ∈ Tree.leaves tree) :
    lookupIsolatedLocal (runIsolatedTree cfg boundaries initial branches assoc tree).2 b =
      some (isolatedCanonicalLocal
        (runIsolatedLeaf cfg (boundaries b) initial (branches b)).cursor
        (branches b)) := by
  rw [runIsolatedTree_locals]
  exact isolatedLocals_lookup_mem cfg boundaries initial branches (Tree.leaves tree) b hb

/-- Well-formed trees: recursive DFS locals and roster-order locals agree by identity. -/
theorem wellFormed_isolated_lookup (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (hwf : WellFormed roster tree) (b : B) :
    lookupIsolatedLocal (runIsolatedTree cfg boundaries initial branches assoc tree).2 b =
      lookupIsolatedLocal (isolatedLocals cfg boundaries initial branches roster.order) b := by
  have hR : b ∈ roster.order := roster.complete b
  have hL : b ∈ Tree.leaves tree := (wellFormed_mem_leaves roster tree hwf b).mpr hR
  rw [runIsolatedTree_lookup_mem cfg boundaries initial branches assoc tree b hL,
    isolatedLocals_lookup_mem cfg boundaries initial branches roster.order b hR]

theorem isolatedCanonical_lookup (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (hwf : WellFormed roster tree) (b : B) :
    lookupIsolatedLocal
        (isolatedCanonical roster cfg boundaries initial branches assoc tree).locals b =
      lookupIsolatedLocal (runIsolatedTree cfg boundaries initial branches assoc tree).2 b := by
  simp [isolatedCanonical]
  exact (wellFormed_isolated_lookup cfg boundaries initial branches roster assoc tree hwf b).symm

/-- Full isolated reference: recursive world plus roster-normalized locals.
Does not claim DFS list equality with roster order. -/
theorem isolatedReference_roster_normalized (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B)
    (hwf : WellFormed roster tree) :
    Parallel.WorldEquivalent
        (runIsolatedTree cfg boundaries initial branches assoc tree).1
        (isolatedCanonical roster cfg boundaries initial branches assoc tree).world ∧
      ∀ b, lookupIsolatedLocal
          (runIsolatedTree cfg boundaries initial branches assoc tree).2 b =
        lookupIsolatedLocal
          (isolatedCanonical roster cfg boundaries initial branches assoc tree).locals b := by
  refine ⟨?_, ?_⟩
  · simp [isolatedCanonical]
    exact ⟨fun _ => rfl, rfl⟩
  · intro b
    exact (isolatedCanonical_lookup cfg boundaries initial branches roster assoc tree hwf b).symm

/-- Shared complete-schedule locals agree with the recursive isolated list by identity.
Derived from `complete_schedule_canonicalEq`; equality is not assumed. -/
theorem complete_schedule_recursive_lookup (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (assoc : List (B × Footprint P A D)) (tree : Tree B) (schedule : Schedule B)
    (hwf : WellFormed roster tree)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : Nary.analyzeAll cfg boundaries branches roster.order = .ok assoc)
    (hc : PairwiseCompatible assoc) (hC : Nary.Complete branches schedule) (b : B) :
    lookupIsolatedLocal
        (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches schedule)).locals
        b =
      lookupIsolatedLocal (runIsolatedTree cfg boundaries initial branches assoc tree).2 b := by
  have heq := complete_schedule_canonicalEq cfg boundaries initial branches roster assoc
    tree schedule hwf hv ha hc hC
  have hloc := (canonicalEq_iff
      (canonicalOf roster (runTreePrefix cfg boundaries initial tree branches schedule))
      (isolatedCanonical roster cfg boundaries initial branches assoc tree)).mp heq |>.2
  rw [hloc]
  exact isolatedCanonical_lookup cfg boundaries initial branches roster assoc tree hwf b

end DefiKernel.Nary.Tree
