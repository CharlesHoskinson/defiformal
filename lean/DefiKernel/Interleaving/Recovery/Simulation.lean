import DefiKernel.Interleaving.Recovery.Step

/-! Prefix simulation against independently executed branch prefixes, including exact refusals. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

def Simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (m : Machine P A D) : Prop :=
  ∀ b, CursorAgrees {c | c ∈ (footprint lf rf b).reads}
    ((m.local b).toCursor m.world)
    (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)

theorem advance_own_agrees (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId)
    (ha : CursorAgrees {c | c ∈ (footprint lf rf b).reads}
      ((m.local b).toCursor m.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)) :
    let post := Interleaving.advance cfg boundaries left right m b
    CursorAgrees {c | c ∈ (footprint lf rf b).reads} ((post.local b).toCursor post.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b)
        (post.local b).consumed) := by
  dsimp only
  rw [advance_consumed]
  simp only [ite_true]
  cases selected : (selectBranch left right b)[(m.local b).consumed]? with
  | none =>
    rw [isolated_exhausted cfg (boundaries b) initial _ _ selected,
      advance_exhausted_cursor cfg boundaries left right m b selected]
    exact ha
  | some inv =>
    rw [isolated_step cfg (boundaries b) initial _ _ inv selected,
      advance_own_cursor cfg boundaries left right m b inv selected]
    cases hf : (m.local b).failure with
    | some failure =>
      have hr : (isolated cfg (boundaries b) initial (selectBranch left right b)
          (m.local b).consumed).failure = some failure := ha.failure.symm.trans hf
      simpa [Composition.advance, LocalState.toCursor, hf, hr] using ha
    | none =>
      have hi := reach.attempt_index b hf inv selected
      obtain ⟨part, hp', hin, _⟩ := selected_footprint cfg boundaries left right lf rf hp b
        (m.local b).consumed inv selected
      exact cursor_advance_congr cfg (boundaries b) inv (m.local b).consumed part
        {c | c ∈ (footprint lf rf b).reads} _ _ hp' hin hi ha

theorem advance_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (ha : Simulates cfg boundaries
      initial left right lf rf m) (b : BranchId) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.advance cfg boundaries left right m b) := by
  intro own
  by_cases heq : b = own
  · subst own
    exact advance_own_agrees cfg boundaries initial left right lf rf hp m reach b (ha b)
  · rw [advance_peer_local cfg boundaries left right m b own heq]
    have old := ha own
    have hc := (Parallel.admit_ok cfg boundaries left right lf rf hp).2.2.2
    refine ⟨?_, ?_, old.events, old.outputs, old.nextIndex, old.failure⟩
    · intro c hr
      exact (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (compatible_peer_reads lf rf hc b own heq c hr)).trans (old.state c hr)
    · exact (advance_sound cfg boundaries left right m b).store.trans old.capabilities

theorem continue_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m)
    (ha : Simulates cfg boundaries initial left right lf rf m) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact ha
  | cons b tail ih =>
    exact ih _ (.next b reach (advance_sound cfg boundaries left right m b))
      (advance_simulates cfg boundaries initial left right lf rf hp m reach ha b)

theorem runPrefix_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (runPrefix cfg boundaries initial left right schedule) := by
  apply continue_simulates cfg boundaries initial left right lf rf hp (start initial) .start
  have hv := (Parallel.admit_ok cfg boundaries left right lf rf hp).1
  intro b
  cases b <;>
    exact ⟨fun _ _ ↦ rfl, rfl, rfl, rfl, rfl, by simp [isolated, Composition.run,
      startCursor, Composition.continueRun, Interleaving.start, Machine.local,
      LocalState.toCursor, hv]⟩

theorem continue_outside (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (schedule : Schedule)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (Interleaving.continueRun cfg boundaries left right m schedule).world.state.balance c =
      m.world.state.balance c := by
  induction schedule generalizing m with
  | nil => rfl
  | cons b tail ih =>
    exact (ih _ (.next b reach (advance_sound cfg boundaries left right m b))).trans
      (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (by cases b <;> assumption))

end DefiKernel.Interleaving.Recovery
