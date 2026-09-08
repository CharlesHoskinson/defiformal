import DefiKernel.Nary.Soundness

/-! Active local indices count successful static slots. Exhausted and failed tokens consume
slots without increasing the successful index; a selected live invocation has
`nextIndex = consumed`. Arbitrary `B` is decided by equality, not a fixed roster split. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem nextIndex_eq_consumed_of_selected (branches : Branches B P A D)
    (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (ordered : (m.locals b).nextIndex =
      min (m.locals b).consumed (branches b).length)
    (selected : (branches b)[(m.locals b).consumed]? = some inv) :
    (m.locals b).nextIndex = (m.locals b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [ordered, min_eq_left (Nat.le_of_lt hb)]

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {m post : Machine B P A D} {b : B}
    (step : AdvanceSound cfg boundaries branches m b post)
    (previous : ∀ own, (m.locals own).failure = none →
      (m.locals own).nextIndex = min (m.locals own).consumed (branches own).length) :
    ∀ own, (post.locals own).failure = none →
      (post.locals own).nextIndex = min (post.locals own).consumed (branches own).length := by
  intro own active
  cases step with
  | halted failure failed =>
    by_cases ho : own = b
    · subst own
      simp [skip_selected, failed] at active
    · rw [skip_away m b own ho] at active ⊢
      exact previous own active
  | exhausted oldActive absent =>
    by_cases ho : own = b
    · subst own
      have hb := List.getElem?_eq_none_iff.mp absent
      have hprev := previous b oldActive
      simp only [skip_selected] at active ⊢
      have hmin : min (m.locals b).consumed (branches b).length = (branches b).length :=
        min_eq_right hb
      have hnext : (m.locals b).nextIndex = (branches b).length := hprev.trans hmin
      have hle : (branches b).length ≤ (m.locals b).consumed + 1 :=
        Nat.le_trans hb (Nat.le_succ _)
      rw [hnext, min_eq_right hle]
    · rw [skip_away m b own ho] at active ⊢
      exact previous own active
  | refused inv reason oldActive selected rejected =>
    by_cases ho : own = b
    · subst own
      simp [refuse_selected] at active
    · rw [refuse_away m b own inv reason ho] at active ⊢
      exact previous own active
  | accepted inv result oldActive selected executed =>
    by_cases ho : own = b
    · subst own
      obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
      have hprev := previous b oldActive
      simp only [accept_selected] at active ⊢
      have hmin : min (m.locals b).consumed (branches b).length = (m.locals b).consumed :=
        min_eq_left (Nat.le_of_lt hb)
      have hnext : (m.locals b).nextIndex = (m.locals b).consumed := hprev.trans hmin
      rw [hnext, min_eq_left (Nat.succ_le_of_lt hb)]
    · rw [accept_away m b own inv result ho] at active ⊢
      exact previous own active

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ b, (m.locals b).failure = none →
      (m.locals b).nextIndex = min (m.locals b).consumed (branches b).length := by
  induction h with
  | start =>
    intro b _
    simp [start_locals]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (b : B)
    (active : (m.locals b).failure = none) (inv : Invocation P A D)
    (selected : (branches b)[(m.locals b).consumed]? = some inv) :
    (m.locals b).nextIndex = (m.locals b).consumed :=
  nextIndex_eq_consumed_of_selected branches m b inv (h.active_index b active) selected

end DefiKernel.Nary
