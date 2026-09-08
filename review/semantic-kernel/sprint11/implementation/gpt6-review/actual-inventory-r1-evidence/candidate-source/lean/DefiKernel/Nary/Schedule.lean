import DefiKernel.Parallel.Compatibility

/-! Explicit finite roster, ordered branch analysis and complete occurrence counts.
Overlapping footprints are admitted; the roster is a typed contract, not a malformed-roster
runtime checker, and B is never enumerated through noncomputable Finset.toList. -/
namespace DefiKernel.Nary
open Typed Composition

structure Roster (B : Type) [DecidableEq B] where
  order : List B
  nodup : order.Nodup
  complete : ∀ b, b ∈ order

abbrev Branches (B P A D : Type) := B → Parallel.Branch P A D
abbrev Boundaries (B P A D : Type) := B → Nat → Boundary P A D
abbrev Schedule (B : Type) := List B

structure ScheduleMismatch (B : Type) where
  participant : B
  expected : Nat
  observed : Nat
  deriving DecidableEq, Repr

inductive AdmissionFailure (B P A D : Type) where
  | configuration
  | structural (participant : B) (failure : Parallel.LocalFailure)
  | schedule (mismatch : ScheduleMismatch B)
  deriving DecidableEq, Repr

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Roster.empty (uninhabited : B → False) : Roster B where
  order := []
  nodup := List.nodup_nil
  complete := fun b => (uninhabited b).elim

def Roster.singleton (b : B) (univ : ∀ x : B, x = b) : Roster B where
  order := [b]
  nodup := List.nodup_singleton b
  complete := fun x => List.mem_singleton.mpr (univ x)

def Complete (branches : Branches B P A D) (schedule : Schedule B) : Prop :=
  ∀ b, schedule.count b = (branches b).length

def checkCountsFrom (branches : Branches B P A D) (schedule : Schedule B) :
    List B → Except (ScheduleMismatch B) PUnit
  | [] => .ok ⟨⟩
  | b :: rest =>
    if schedule.count b = (branches b).length then
      checkCountsFrom branches schedule rest
    else
      .error ⟨b, (branches b).length, schedule.count b⟩

def checkSchedule (roster : Roster B) (branches : Branches B P A D)
    (schedule : Schedule B) : Except (ScheduleMismatch B) PUnit :=
  checkCountsFrom branches schedule roster.order

def analyzeAll (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) : List B →
    Except (AdmissionFailure B P A D) (List (B × Parallel.Footprint P A D))
  | [] => .ok []
  | b :: rest =>
    match (Parallel.analyzeBranch cfg (boundaries b) (branches b)).mapError
        (AdmissionFailure.structural b) with
    | .error reason => .error reason
    | .ok footprint =>
      match analyzeAll cfg boundaries branches rest with
      | .error reason => .error reason
      | .ok footprints => .ok (⟨b, footprint⟩ :: footprints)

def admit (cfg : Config P A D) (roster : Roster B) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (schedule : Schedule B) :
    Except (AdmissionFailure B P A D) (List (B × Parallel.Footprint P A D)) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let footprints ← analyzeAll cfg boundaries branches roster.order
  let _ ← (checkSchedule roster branches schedule).mapError .schedule
  return footprints

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkCountsFrom_nil (branches : Branches B P A D) (schedule : Schedule B) :
    checkCountsFrom branches schedule [] = .ok ⟨⟩ := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkCountsFrom_ok_iff (branches : Branches B P A D) (schedule : Schedule B) :
    ∀ order, checkCountsFrom branches schedule order = .ok ⟨⟩ ↔
      ∀ b ∈ order, schedule.count b = (branches b).length
  | [] => by simp [checkCountsFrom]
  | b :: rest => by
    by_cases h : schedule.count b = (branches b).length
    · simp [checkCountsFrom, h, checkCountsFrom_ok_iff branches schedule rest]
    · constructor
      · intro hok
        simp [checkCountsFrom, h] at hok
      · intro hall
        exact (h (hall b (by simp))).elim

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkCountsFrom_error_head (branches : Branches B P A D) (schedule : Schedule B)
    (b : B) (rest : List B) (h : schedule.count b ≠ (branches b).length) :
    checkCountsFrom branches schedule (b :: rest) =
      .error ⟨b, (branches b).length, schedule.count b⟩ := by
  simp [checkCountsFrom, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkCountsFrom_ok_cons (branches : Branches B P A D) (schedule : Schedule B)
    (b : B) (rest : List B) (h : schedule.count b = (branches b).length) :
    checkCountsFrom branches schedule (b :: rest) =
      checkCountsFrom branches schedule rest := by
  simp [checkCountsFrom, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkSchedule_ok_iff (roster : Roster B) (branches : Branches B P A D)
    (schedule : Schedule B) :
    checkSchedule roster branches schedule = .ok ⟨⟩ ↔ Complete branches schedule := by
  simp only [checkSchedule, checkCountsFrom_ok_iff, Complete]
  constructor
  · intro h b
    exact h b (roster.complete b)
  · intro h b _
    exact h b

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem count_append (b : B) (first second : Schedule B) :
    (first ++ second).count b = first.count b + second.count b :=
  List.count_append

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem nodup_sum_ite (order : List B) (nodup : order.Nodup) (a : B) :
    (order.map fun b => if b = a then (1 : Nat) else 0).sum = if a ∈ order then 1 else 0 := by
  induction order with
  | nil => simp
  | cons x xs ih =>
    have hx : x ∉ xs := (List.nodup_cons.mp nodup).1
    have hxs : xs.Nodup := (List.nodup_cons.mp nodup).2
    simp [ih hxs]
    by_cases hxa : x = a
    · subst hxa
      simp [hx]
    · have hax : a ≠ x := Ne.symm hxa
      simp [hxa, hax]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem sum_count_cons (order : List B) (h : order.Nodup) (head : B) (tail : Schedule B) :
    (order.map fun b => (head :: tail).count b).sum =
      (order.map fun b => tail.count b).sum + if head ∈ order then 1 else 0 := by
  induction order with
  | nil => simp
  | cons x xs ih =>
    have hx : x ∉ xs := (List.nodup_cons.mp h).1
    have hxs : xs.Nodup := (List.nodup_cons.mp h).2
    simp only [List.map_cons, List.sum_cons]
    rw [List.count_cons, ih hxs]
    by_cases hxeq : x = head
    · subst hxeq
      simp [hx, Nat.add_assoc, Nat.add_left_comm, Nat.add_comm]
    · have hbeq : (head == x) = false :=
        (beq_eq_false_iff_ne (a := head) (b := x)).mpr (Ne.symm hxeq)
      have hmem : head ∈ x :: xs ↔ head ∈ xs := by
        simp [List.mem_cons, Ne.symm hxeq]
      simp [hbeq, hmem, Nat.add_assoc, Nat.add_left_comm, Nat.add_comm]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem count_sum_length (roster : Roster B) (schedule : Schedule B) :
    (roster.order.map fun b => schedule.count b).sum = schedule.length := by
  induction schedule with
  | nil => simp
  | cons head tail ih =>
    rw [sum_count_cons roster.order roster.nodup, ih, List.length_cons]
    simp [roster.complete head]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.length {branches : Branches B P A D} {schedule : Schedule B}
    (roster : Roster B) (h : Complete branches schedule) :
    schedule.length = (roster.order.map fun b => (branches b).length).sum := by
  have hs := count_sum_length roster schedule
  have hmap :
      roster.order.map (fun b => schedule.count b) =
        roster.order.map (fun b => (branches b).length) :=
    List.map_congr_left fun b _ => h b
  rw [hmap] at hs
  exact hs.symm

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.eq_nil {branches : Branches B P A D} {schedule : Schedule B}
    (h : Complete branches schedule) (hz : ∀ b, (branches b).length = 0) :
    schedule = [] := by
  apply List.eq_nil_iff_forall_not_mem.mpr
  intro b hb
  have hb' : schedule.count b = 0 := (h b).trans (hz b)
  exact (List.count_eq_zero.mp hb') hb

omit [DecidableEq B] in
theorem analyzeAll_nil (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) :
    analyzeAll cfg boundaries branches [] = .ok [] := rfl

omit [DecidableEq B] in
theorem mapError_ok {E F X : Type} (f : E → F) (x : Except E X) (v : X) :
    x.mapError f = .ok v ↔ x = .ok v := by
  cases x <;> simp [Except.mapError]

omit [DecidableEq B] in
theorem throw_error {ε α : Type} (e : ε) : (throw e : Except ε α) = .error e := rfl

omit [DecidableEq B] in
theorem analyzeAll_error_head (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (b : B) (rest : List B) (failure : Parallel.LocalFailure)
    (h : Parallel.analyzeBranch cfg (boundaries b) (branches b) = .error failure) :
    analyzeAll cfg boundaries branches (b :: rest) = .error (.structural b failure) := by
  simp [analyzeAll, h, Except.mapError]

theorem admit_invalid_catalog (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    admit cfg roster boundaries branches schedule = .error .configuration := by
  unfold admit
  simp only [bind, Except.bind, pure, Except.pure, h]
  split
  · simp [throw_error]
  · contradiction

theorem admit_analyze_error (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (reason : AdmissionFailure B P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (he : analyzeAll cfg boundaries branches roster.order = .error reason) :
    admit cfg roster boundaries branches schedule = .error reason := by
  simp [admit, hv, he, bind, Except.bind]

theorem admit_ok (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (footprints : List (B × Parallel.Footprint P A D))
    (h : admit cfg roster boundaries branches schedule = .ok footprints) :
    validateCatalog cfg.registry cfg.catalog = true ∧
      analyzeAll cfg boundaries branches roster.order = .ok footprints ∧
      Complete branches schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw_error] at h
  rename_i hv
  split at h
  · contradiction
  rename_i fps hfps
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain rfl := Except.ok.inj h
  exact ⟨by simpa using hv, hfps, (checkSchedule_ok_iff _ _ _).mp ((mapError_ok _ _ _).mp hc)⟩

theorem admit_of_checks (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (footprints : List (B × Parallel.Footprint P A D))
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (ha : analyzeAll cfg boundaries branches roster.order = .ok footprints)
    (hs : Complete branches schedule) :
    admit cfg roster boundaries branches schedule = .ok footprints := by
  have hs' : checkSchedule roster branches schedule = .ok ⟨⟩ :=
    (checkSchedule_ok_iff roster branches schedule).mpr hs
  simp [admit, hv, ha, bind, Except.bind, pure, Except.pure]
  rw [hs']
  rfl

end DefiKernel.Nary
