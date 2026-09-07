import DefiKernel.Atomic.Policy
import Mathlib.Data.List.Nodup

/-! Policy admission is equivalent to complete typed uniqueness and static coverage.
Residual observations enumerate exactly the configured nonzero keys. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

-- BEGIN PROOFS

private theorem find_key_none {X K : Type} [DecidableEq K] (key : X → K)
    (x : X) (xs : List X) (index : Nat) :
    (xs.zipIdx index).find? (fun item ↦ key x == key item.1) = none ↔
      key x ∉ xs.map key := by
  rw [List.find?_eq_none]
  constructor
  · intro h hm
    rcases List.mem_map.mp hm with ⟨y, hy, heq⟩
    have hm' : y ∈ (xs.zipIdx index).map Prod.fst := by
      simpa only [List.zipIdx_map_fst] using hy
    rcases List.mem_map.mp hm' with ⟨pair, hp, hpy⟩
    have := h pair hp
    simp [hpy, heq] at this
  · intro h pair hp heq
    apply h
    exact List.mem_map.mpr ⟨pair.1, List.fst_mem_of_mem_zipIdx hp,
      (beq_iff_eq.mp heq).symm⟩

theorem firstDuplicate_none_iff {X K : Type} [DecidableEq K] (key : X → K)
    (index : Nat) (xs : List X) :
    firstDuplicate key index xs = none ↔ (xs.map key).Nodup := by
  induction xs generalizing index with
  | nil => simp [firstDuplicate]
  | cons x xs ih =>
    rw [firstDuplicate]
    cases h : (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | none =>
      have hn := (find_key_none key x xs (index + 1)).mp h
      simp [ih, hn]
    | some pair =>
      have hn : ¬ key x ∉ xs.map key := by
        intro hx
        have := (find_key_none key x xs (index + 1)).mpr hx
        rw [h] at this
        contradiction
      simp only [Option.some_ne_none, List.map_cons, List.nodup_cons, false_iff]
      exact fun hnodup ↦ hn hnodup.1

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

omit [DecidableEq A] [DecidableEq D] in
theorem uncoveredFrom_none_iff (participants : List P) (b : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) (xs : Branch P A D) :
    uncoveredFrom participants b boundary index xs = none ↔
      ∀ j, j < xs.length → (boundary (index + j)).ctx.principal ∈ participants := by
  induction xs generalizing index with
  | nil => simp [uncoveredFrom]
  | cons x xs ih =>
    simp only [uncoveredFrom]
    by_cases h : (boundary index).ctx.principal ∈ participants
    · simp only [h, ↓reduceIte, ih]
      constructor
      · intro hall j hj
        cases j with
        | zero => simpa using h
        | succ j =>
          have := hall j (by simpa using hj)
          simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
      · intro hall j hj
        have := hall (j + 1) (by simpa using Nat.succ_lt_succ hj)
        simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
    · simp only [h, ↓reduceIte, Option.some_ne_none, false_iff]
      intro hall
      exact h (by simpa using hall 0 (by simp))

/-- All four policy phases characterize acceptance, including unreachable static suffixes. -/
theorem checkPolicy_ok_iff (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) :
    checkPolicy policy boundaries left right = .ok ⟨⟩ ↔
      (policy.lanes.map (fun lane ↦ (lane.domain, lane.asset))).Nodup ∧
      policy.participants.Nodup ∧
      (∀ i, i < left.length → (boundaries .left i).ctx.principal ∈ policy.participants) ∧
      (∀ i, i < right.length → (boundaries .right i).ctx.principal ∈ policy.participants) := by
  have hl := firstDuplicate_none_iff (fun lane : Lane P A D ↦
    (lane.domain, lane.asset)) 0 policy.lanes
  have hp := firstDuplicate_none_iff id 0 policy.participants
  have hleft := uncoveredFrom_none_iff policy.participants .left (boundaries .left) 0 left
  have hright := uncoveredFrom_none_iff policy.participants .right (boundaries .right) 0 right
  simp only [List.map_id, Nat.zero_add] at hp hleft hright
  rw [← hl, ← hp, ← hleft, ← hright]
  unfold checkPolicy
  cases firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes <;>
    cases firstDuplicate id 0 policy.participants <;>
    cases uncoveredFrom policy.participants .left (boundaries .left) 0 left <;>
    cases uncoveredFrom policy.participants .right (boundaries .right) 0 right <;>
    simp [pure, Except.pure, bind, Except.bind, throw]

theorem checkPolicy_participants_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) :
    policy.participants.Nodup := (checkPolicy_ok_iff policy boundaries left right).mp h |>.2.1

theorem checkPolicy_covers (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (h : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (b : BranchId) (i : Nat) (hi : i < (Interleaving.selectBranch left right b).length) :
    (boundaries b i).ctx.principal ∈ policy.participants := by
  have hc := (checkPolicy_ok_iff policy boundaries left right).mp h
  cases b with
  | left => exact hc.2.2.1 i hi
  | right => exact hc.2.2.2 i hi

@[simp] theorem receiptEffect_invoked (request : Request P A D) (e : Evaluated P A D)
    (cell : Cell P A D) : receiptEffect (.invoked request e) cell = e.effect cell := rfl

@[simp] theorem receiptEffect_issued (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.issued id) cell = 0 := rfl

@[simp] theorem receiptEffect_revoked (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.revoked id) cell = 0 := rfl

theorem updateOutstanding_own (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) :
    updateOutstanding policy owed principal receipt lane principal =
      owed lane principal - receiptEffect receipt lane.cell := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_other (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D) (hp : p ≠ principal) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hp]

theorem updateOutstanding_unconfigured (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∉ policy.lanes) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_zero_effect (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hzero : receiptEffect receipt lane.cell = 0) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hzero]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Exact residual membership includes all three key qualifications and the signed value. -/
theorem mem_residuals_iff (policy : Policy P A D) (owed : Outstanding P A D)
    (r : Residual P A D) :
    r ∈ residuals policy owed ↔ r.lane ∈ policy.lanes ∧
      r.principal ∈ policy.participants ∧ r.amount = owed r.lane r.principal ∧ r.amount ≠ 0 := by
  rcases r with ⟨lane, principal, amount⟩
  simp only [residuals, List.mem_flatMap, List.mem_filterMap]
  constructor
  · rintro ⟨l, hl, p, hp, heq⟩
    split at heq
    · contradiction
    · cases Option.some.inj heq
      exact ⟨hl, hp, rfl, by assumption⟩
  · rintro ⟨hl, hp, heq, hne⟩
    refine ⟨lane, hl, principal, hp, ?_⟩
    simp [← heq, hne]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Clearance is pointwise over the entire configured rectangle, not a global net sum. -/
theorem residuals_eq_nil_iff (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = [] ↔
      ∀ lane ∈ policy.lanes, ∀ p ∈ policy.participants, owed lane p = 0 := by
  constructor
  · intro h lane hl p hp
    by_contra hn
    have hm := (mem_residuals_iff policy owed ⟨lane, p, owed lane p⟩).mpr
      ⟨hl, hp, rfl, hn⟩
    simp [h] at hm
  · intro h
    apply List.eq_nil_iff_forall_not_mem.mpr
    intro r hr
    have hm := (mem_residuals_iff policy owed r).mp hr
    exact hm.2.2.2 (hm.2.2.1.trans (h r.lane hm.1 r.principal hm.2.1))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem residuals_zero (policy : Policy P A D) :
    residuals policy zeroOutstanding = [] := by
  apply (residuals_eq_nil_iff policy zeroOutstanding).mpr
  intros
  rfl

omit [DecidableEq P] in
theorem checkSupply_none_iff (policy : Policy P A D) (receipt : Receipt P A D) :
    checkSupply policy receipt = none ↔
      ∀ lane ∈ policy.lanes, receipt.supply lane.domain lane.asset = 0 := by
  simp [checkSupply]

theorem checkPolicy_lanes_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) : policy.lanes.Nodup :=
  List.Nodup.of_map _ ((checkPolicy_ok_iff policy boundaries left right).mp h).1

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_eq_filterMap_product (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = (policy.lanes.product policy.participants).filterMap
      (fun key ↦ if owed key.1 key.2 = 0 then none
        else some ⟨key.1, key.2, owed key.1 key.2⟩) := by
  simp [residuals, List.product, List.filterMap_flatMap, List.filterMap_map]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_keys (policy : Policy P A D) (owed : Outstanding P A D) :
    (residuals policy owed).map (fun r ↦ (r.lane, r.principal)) =
      (policy.lanes.product policy.participants).filter (fun key ↦ owed key.1 key.2 != 0) := by
  rw [residuals_eq_filterMap_product, List.map_filterMap]
  simp only [← List.filterMap_eq_filter]
  congr 1
  funext key
  by_cases h : owed key.1 key.2 = 0 <;> simp [h, Option.guard]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Every nonzero lane/principal key appears exactly once under admitted uniqueness. -/
theorem residuals_keys_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    ((residuals policy owed).map (fun r ↦ (r.lane, r.principal))).Nodup := by
  rw [residuals_keys]
  exact (hl.product hp).filter _

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    (residuals policy owed).Nodup :=
  List.Nodup.of_map _ (residuals_keys_nodup policy owed hl hp)

private theorem sum_sub_at (participants : List P) (principal : P) (f : P → ℚ) (delta : ℚ)
    (hn : participants.Nodup) (hm : principal ∈ participants) :
    (participants.map (fun p ↦ if p = principal then f p - delta else f p)).sum =
      (participants.map f).sum - delta := by
  induction participants with
  | nil => simp at hm
  | cons p ps ih =>
    rcases List.nodup_cons.mp hn with ⟨hnot, htail⟩
    by_cases heq : p = principal
    · subst p
      have hmap : ps.map (fun p ↦ if p = principal then f p - delta else f p) = ps.map f := by
        apply List.map_congr_left
        intro q hq
        have hne : q ≠ principal := by intro h; subst q; exact hnot hq
        simp [hne]
      simp [hmap, sub_add_eq_add_sub]
    · have hmem : principal ∈ ps := (List.mem_cons.mp hm).resolve_left (Ne.symm heq)
      simp only [List.map_cons, List.sum_cons, heq, ↓reduceIte, ih htail hmem]
      exact (add_sub_assoc _ _ _).symm

/-- Complete duplicate-free participant sums decrease by precisely the lane receipt effect. -/
theorem updateOutstanding_sum (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hm : principal ∈ policy.participants) :
    (policy.participants.map (updateOutstanding policy owed principal receipt lane)).sum =
      (policy.participants.map (owed lane)).sum - receiptEffect receipt lane.cell := by
  unfold updateOutstanding
  simpa only [hlane, true_and] using
    sum_sub_at policy.participants principal (owed lane) (receiptEffect receipt lane.cell) hn hm

end DefiKernel.Atomic
