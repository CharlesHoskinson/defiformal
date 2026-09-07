import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Interleaving.Recovery.Reference

/-! One-token cursor correspondence and admitted dependency frames. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def footprint (lf rf : Footprint P A D) : BranchId → Footprint P A D
  | .left => lf
  | .right => rf

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem admitted_analysis (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId) :
    analyzeBranch cfg (boundaries b) (selectBranch left right b) = .ok (footprint lf rf b) := by
  obtain ⟨_, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  cases b <;> assumption

omit [Fintype P] [Fintype A] [Fintype D] in
theorem selected_footprint (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId)
    (n : Nat) (inv : Invocation P A D) (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries b n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ (footprint lf rf b).reads) ∧
      (∀ c ∈ part.writes, c ∈ (footprint lf rf b).writes) := by
  simpa using analyzeBranchFrom_member cfg (boundaries b) 0 (selectBranch left right b)
    (footprint lf rf b) (admitted_analysis cfg boundaries left right lf rf hp b) n inv selected

theorem advance_own_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world =
      Composition.advance cfg (boundaries b) ((m.local b).toCursor m.world) (.invoke inv) := by
  cases hf : (m.local b).failure with
  | some failure =>
    cases b <;> simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor, Composition.advance]
  | none =>
    cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world <;>
      cases b <;> simp_all [Interleaving.advance, Machine.refuse, Machine.accept,
        Machine.setLocal, Machine.local, LocalState.toCursor, Composition.advance]

theorem advance_peer_local (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b peer : BranchId) (hne : b ≠ peer) :
    (Interleaving.advance cfg boundaries left right m b).local peer = m.local peer := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs <;> cases b <;> cases peer <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_exhausted_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world = (m.local b).toCursor m.world := by
  cases hf : (m.local b).failure <;> cases b <;>
    simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor]

theorem cursor_advance_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (inv : Invocation P A D) (index : Nat) (part : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeInvocation cfg (boundary index) inv = .ok part)
    (hin : ∀ c ∈ part.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (Composition.advance cfg boundary left (.invoke inv))
      (Composition.advance cfg boundary right (.invoke inv)) := by
  have hs : analyzeBranchFrom cfg boundary index [inv] = .ok (part.append .empty) := by
    simp [analyzeBranchFrom, hf, bind, Except.bind, pure, Except.pure, Except.mapError]
  have hh := continueRun_congr cfg boundary [inv] index (part.append .empty) region
    left right hs (by simpa [Footprint.append, Footprint.empty] using hin) hi ha
  exact hh

theorem advance_branch_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId) :
    ∀ c, c ∉ (footprint lf rf b).writes →
      (Interleaving.advance cfg boundaries left right m b).world.state.balance c =
        m.world.state.balance c := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs with
  | halted => intro c hc; rw [skip_world]
  | exhausted => intro c hc; rw [skip_world]
  | refused => intro c hc; rw [refuse_world]
  | accepted inv result active selected executed =>
    obtain ⟨part, hf, _, hw⟩ := selected_footprint cfg boundaries left right lf rf hp b
      (m.local b).consumed inv selected
    rw [← reach.attempt_index b active inv selected] at hf
    have frame := executeStep_target_frame cfg (boundaries b (m.local b).nextIndex)
      (m.local b).nextIndex (m.local b).outputs inv m.world result part hf executed
    intro c hc
    exact frame.1 c (fun h ↦ hc (hw c h))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem compatible_peer_reads (lf rf : Footprint P A D) (hc : Compatible lf rf)
    (b peer : BranchId) (hne : b ≠ peer) (c : Cell P A D)
    (hr : c ∈ (footprint lf rf peer).reads) : c ∉ (footprint lf rf b).writes := by
  cases b <;> cases peer
  · exact (hne rfl).elim
  · exact fun hw ↦ hc.2.1 c hw hr
  · exact fun hw ↦ hc.2.2 c hw hr
  · exact (hne rfl).elim

end DefiKernel.Interleaving.Recovery
