import DefiKernel.Interleaving.Soundness

/-! Active local indices count successful static slots. Exhausted internal tokens consume slots
without increasing the successful index; before any real attempt the two indices agree. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (step : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ own, (m.local own).failure = none →
      (m.local own).nextIndex = min (m.local own).consumed
        (selectBranch left right own).length) :
    ∀ own, (post.local own).failure = none →
      (post.local own).nextIndex = min (post.local own).consumed
        (selectBranch left right own).length := by
  intro own active
  have hl := previous .left
  have hr := previous .right
  cases step with
  | halted failure failed =>
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch]
  | exhausted oldActive absent =>
    have hb := List.getElem?_eq_none_iff.mp absent
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch] <;> omega
  | refused inv reason oldActive selected rejected =>
    cases b <;> cases own <;>
      simp_all [Machine.refuse, Machine.setLocal, Machine.local, selectBranch]
  | accepted inv result oldActive selected executed =>
    obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
    cases b <;> cases own <;>
      dsimp [Machine.accept, Machine.setLocal, Machine.local, selectBranch] at * <;>
      simp_all <;>
      have hb' := hb <;>
      simp only [Machine.local, selectBranch] at hb' <;> omega

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).failure = none →
      (m.local b).nextIndex = min (m.local b).consumed (selectBranch left right b).length := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (b : BranchId)
    (active : (m.local b).failure = none) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    (m.local b).nextIndex = (m.local b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [h.active_index b active, min_eq_left (Nat.le_of_lt hb)]

end DefiKernel.Interleaving
