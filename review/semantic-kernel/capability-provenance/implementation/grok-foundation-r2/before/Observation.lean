import DefiKernel.CapabilityProvenance.Origins
import DefiKernel.Composition.Contracts

/-! Finite world-observation policy. Selected capability lookups and optional allocation length
are part of support. Ledger-only `Composition.Supports` is not reused here. Repeated list
positions are retained. Read-only privacy is not confidentiality. Full-store equality is
strictly stronger than selected support. -/
namespace DefiKernel.CapabilityProvenance

open Typed Composition

/-- Finite ordered observation policy. Repeated entries are preserved, not silently
deduplicated. A selected ID may currently be absent. -/
structure SupportPolicy (P A D : Type) where
  cells : List (Cell P A D)
  capabilityIds : List CapabilityId
  observeNextId : Bool

/-- Selected ledger cells, exact `Option Capability` lookups (complete grant and live bit),
and optional `nextId`. This is not full-store equality. -/
def WorldAgrees {P A D : Type} (policy : SupportPolicy P A D)
    (pre post : World P A D) : Prop :=
  (∀ c ∈ policy.cells, pre.state.balance c = post.state.balance c) ∧
    (∀ id ∈ policy.capabilityIds,
      pre.capabilities.lookup id = post.capabilities.lookup id) ∧
    (policy.observeNextId = true →
      pre.capabilities.nextId = post.capabilities.nextId)

/-- Value-valued support: the observer is fixed before worlds are compared. -/
def SupportsObservation {P A D : Type} {α : Type} (policy : SupportPolicy P A D)
    (observer : World P A D → α) : Prop :=
  ∀ pre post, WorldAgrees policy pre post → observer pre = observer post

structure ObservedWorld (P A D : Type) where
  ledger : List (Cell P A D × ℚ)
  store : List (CapabilityId × Option (Capability P A D))
  nextId : Option CapabilityId
  deriving DecidableEq, Repr

def observeWorld {P A D : Type} (policy : SupportPolicy P A D) (world : World P A D) :
    ObservedWorld P A D :=
  { ledger := policy.cells.map (fun c ↦ (c, world.state.balance c))
    store := policy.capabilityIds.map (fun id ↦ (id, world.capabilities.lookup id))
    nextId := if policy.observeNextId then some world.capabilities.nextId else none }

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Compares holder, domain, operation, right and live as distinct fields. -/
def capEq (left right : Capability P A D) : Bool :=
  decide (left.holder = right.holder) &&
    decide (left.domain = right.domain) &&
    decide (left.operation = right.operation) &&
    decide (left.right = right.right) &&
    decide (left.live = right.live)

def capOptionEq : Option (Capability P A D) → Option (Capability P A D) → Bool
  | none, none => true
  | some left, some right => capEq left right
  | _, _ => false

def storeEntryEq :
    CapabilityId × Option (Capability P A D) →
      CapabilityId × Option (Capability P A D) → Bool
  | (idLeft, capLeft), (idRight, capRight) =>
    decide (idLeft = idRight) && capOptionEq capLeft capRight

def storeListEq :
    List (CapabilityId × Option (Capability P A D)) →
      List (CapabilityId × Option (Capability P A D)) → Bool
  | [], [] => true
  | left :: lefts, right :: rights => storeEntryEq left right && storeListEq lefts rights
  | _, _ => false

def ledgerEq : List (Cell P A D × ℚ) → List (Cell P A D × ℚ) → Bool
  | [], [] => true
  | left :: lefts, right :: rights =>
    decide (left.1 = right.1) && decide (left.2 = right.2) && ledgerEq lefts rights
  | _, _ => false

/-- Complete selected ledger list, selected-store list (IDs/presence/order/length) and
optional allocation value. -/
def viewEq (left right : ObservedWorld P A D) : Bool :=
  ledgerEq left.ledger right.ledger &&
    storeListEq left.store right.store &&
    decide (left.nextId = right.nextId)

-- BEGIN PROOFS

theorem capEq_iff (left right : Capability P A D) :
    capEq left right = true ↔
      left.holder = right.holder ∧ left.domain = right.domain ∧
      left.operation = right.operation ∧ left.right = right.right ∧
      left.live = right.live := by
  simp only [capEq, Bool.and_eq_true, decide_eq_true_eq]
  tauto

theorem capEq_eq (left right : Capability P A D) :
    capEq left right = true ↔ left = right := by
  constructor
  · intro h
    obtain ⟨hh, hd, ho, hr, hl⟩ := (capEq_iff left right).mp h
    rcases left with ⟨⟨lholder, ldomain, loperation, lright⟩, llive⟩
    rcases right with ⟨⟨rholder, rdomain, roperation, rright⟩, rlive⟩
    simp_all
  · intro h
    subst h
    simp [capEq]

theorem capOptionEq_iff (left right : Option (Capability P A D)) :
    capOptionEq left right = true ↔ left = right := by
  cases left <;> cases right <;> simp [capOptionEq, capEq_eq]

theorem storeEntryEq_iff (left right : CapabilityId × Option (Capability P A D)) :
    storeEntryEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [storeEntryEq, capOptionEq_iff, Bool.and_eq_true, Prod.mk.injEq]

theorem storeListEq_iff (left right : List (CapabilityId × Option (Capability P A D))) :
    storeListEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [storeListEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [storeListEq]
    | cons other rest => simp [storeListEq, storeEntryEq_iff, ih]

theorem ledgerEq_iff (left right : List (Cell P A D × ℚ)) :
    ledgerEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [ledgerEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [ledgerEq]
    | cons other rest =>
      cases head
      cases other
      simp [ledgerEq, ih, Bool.and_eq_true, Prod.mk.injEq]

theorem viewEq_iff (left right : ObservedWorld P A D) :
    viewEq left right = true ↔ left = right := by
  cases left
  cases right
  constructor
  · intro h
    simp only [viewEq, Bool.and_eq_true, ledgerEq_iff, storeListEq_iff,
      decide_eq_true_eq] at h
    rcases h with ⟨⟨hl, hs⟩, hn⟩
    simp [hl, hs, hn]
  · intro h
    cases h
    simp [viewEq, ledgerEq_iff, storeListEq_iff]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_ledger (policy : SupportPolicy P A D) (world : World P A D) :
    (observeWorld policy world).ledger =
      policy.cells.map (fun c ↦ (c, world.state.balance c)) := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_store (policy : SupportPolicy P A D) (world : World P A D) :
    (observeWorld policy world).store =
      policy.capabilityIds.map (fun id ↦ (id, world.capabilities.lookup id)) :=
  rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_nextId_true (policy : SupportPolicy P A D) (world : World P A D)
    (h : policy.observeNextId = true) :
    (observeWorld policy world).nextId = some world.capabilities.nextId := by
  simp [observeWorld, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_nextId_false (policy : SupportPolicy P A D) (world : World P A D)
    (h : policy.observeNextId = false) :
    (observeWorld policy world).nextId = none := by
  simp [observeWorld, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem map_selected_balances {cells : List (Cell P A D)} {pre post : World P A D}
    (h : ∀ c ∈ cells, pre.state.balance c = post.state.balance c) :
    cells.map (fun c ↦ (c, pre.state.balance c)) =
      cells.map (fun c ↦ (c, post.state.balance c)) := by
  induction cells with
  | nil => rfl
  | cons c rest ih =>
    have hc : pre.state.balance c = post.state.balance c :=
      h c (List.mem_cons.mpr (Or.inl rfl))
    have hr : ∀ x ∈ rest, pre.state.balance x = post.state.balance x := by
      intro x hx
      exact h x (List.mem_cons.mpr (Or.inr hx))
    simp [hc, ih hr]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem map_selected_lookups {ids : List CapabilityId} {pre post : World P A D}
    (h : ∀ id ∈ ids, pre.capabilities.lookup id = post.capabilities.lookup id) :
    ids.map (fun id ↦ (id, pre.capabilities.lookup id)) =
      ids.map (fun id ↦ (id, post.capabilities.lookup id)) := by
  induction ids with
  | nil => rfl
  | cons id rest ih =>
    have hid : pre.capabilities.lookup id = post.capabilities.lookup id :=
      h id (List.mem_cons.mpr (Or.inl rfl))
    have hr : ∀ x ∈ rest, pre.capabilities.lookup x = post.capabilities.lookup x := by
      intro x hx
      exact h x (List.mem_cons.mpr (Or.inr hx))
    simp [hid, ih hr]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem balances_of_mapped {cells : List (Cell P A D)} {pre post : World P A D}
    (h : cells.map (fun c ↦ (c, pre.state.balance c)) =
      cells.map (fun c ↦ (c, post.state.balance c))) :
    ∀ c ∈ cells, pre.state.balance c = post.state.balance c := by
  induction cells with
  | nil => intro c hc; cases hc
  | cons c rest ih =>
    intro x hx
    simp only [List.map_cons, List.cons.injEq] at h
    obtain ⟨hhead, hrest⟩ := h
    have hbal : pre.state.balance c = post.state.balance c :=
      congrArg Prod.snd hhead
    simp only [List.mem_cons] at hx
    rcases hx with rfl | hx
    · exact hbal
    · exact ih hrest x hx

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem lookups_of_mapped {ids : List CapabilityId} {pre post : World P A D}
    (h : ids.map (fun id ↦ (id, pre.capabilities.lookup id)) =
      ids.map (fun id ↦ (id, post.capabilities.lookup id))) :
    ∀ id ∈ ids, pre.capabilities.lookup id = post.capabilities.lookup id := by
  induction ids with
  | nil => intro id hid; cases hid
  | cons id rest ih =>
    intro x hx
    simp only [List.map_cons, List.cons.injEq] at h
    obtain ⟨hhead, hrest⟩ := h
    have hlook : pre.capabilities.lookup id = post.capabilities.lookup id :=
      congrArg Prod.snd hhead
    simp only [List.mem_cons] at hx
    rcases hx with rfl | hx
    · exact hlook
    · exact ih hrest x hx

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_eq_iff {policy : SupportPolicy P A D} {pre post : World P A D} :
    observeWorld policy pre = observeWorld policy post ↔ WorldAgrees policy pre post := by
  constructor
  · intro h
    have hl := congrArg ObservedWorld.ledger h
    have hs := congrArg ObservedWorld.store h
    have hn := congrArg ObservedWorld.nextId h
    simp only [observeWorld] at hl hs hn
    refine ⟨balances_of_mapped hl, lookups_of_mapped hs, ?_⟩
    intro hobs
    simp only [hobs, ite_true, Option.some.injEq] at hn
    exact hn
  · intro h
    simp [observeWorld, map_selected_balances h.1, map_selected_lookups h.2.1]
    cases hobs : policy.observeNextId
    · rfl
    · simp [h.2.2 hobs]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem observeWorld_supported (policy : SupportPolicy P A D) :
    SupportsObservation policy (observeWorld policy) := by
  intro pre post h
  exact (observeWorld_eq_iff.mpr h)

theorem viewEq_observeWorld_iff (policy : SupportPolicy P A D)
    (pre post : World P A D) :
    viewEq (observeWorld policy pre) (observeWorld policy post) = true ↔
      WorldAgrees policy pre post := by
  simp [viewEq_iff, observeWorld_eq_iff]

end DefiKernel.CapabilityProvenance
