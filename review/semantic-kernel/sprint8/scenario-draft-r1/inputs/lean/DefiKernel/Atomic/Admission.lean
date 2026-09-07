import DefiKernel.Atomic.Execution

/-! Admission decomposition keeps all structural checks ahead of policy and counts. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

-- BEGIN PROOFS

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (h : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧
    checkPolicy policy boundaries left right = .ok ⟨⟩ ∧ Complete left right schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i policyToken hp
  split at h
  · contradiction
  rename_i scheduleToken hs
  cases policyToken
  cases scheduleToken
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr, unmap _ _ _ hp,
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hs)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hp : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (hs : Complete left right schedule) :
    admit cfg boundaries policy left right schedule = .ok (lf, rf) := by
  have hc := (checkSchedule_ok_iff left.length right.length schedule).mpr hs
  simp [admit, hv, hl, hr, hp, hc, bind, Except.bind, Except.mapError, pure, Except.pure]

theorem admit_interleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (h : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    Interleaving.admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _, hs⟩ := admit_ok _ _ _ _ _ _ _ _ h
  exact Interleaving.admit_of_checks _ _ _ _ _ _ _ hv hl hr hs

end DefiKernel.Atomic
