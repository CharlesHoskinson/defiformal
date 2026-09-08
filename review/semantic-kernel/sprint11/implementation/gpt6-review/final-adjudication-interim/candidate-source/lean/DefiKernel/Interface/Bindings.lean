import DefiKernel.Interface.Regions

/-! Ordered queries over live resource exports. Structural catalog validation and
balance equality are separate checks; failures retain the original edge position. -/
namespace DefiKernel.Interface
open Typed Composition

abbrev Binding := QualifiedPort × QualifiedPort

inductive EndpointSide where
  | left | right
  deriving DecidableEq, Repr

inductive EndpointFailure where
  | missingComponent (name : QualifiedPort)
  | missingPort (name : QualifiedPort)
  deriving DecidableEq, Repr

inductive BindingFailure (P A D : Type) where
  | configuration
  | endpoint (index : Nat) (side : EndpointSide) (reason : EndpointFailure)
  | domainMismatch (index : Nat) (left right : Cell P A D)
  | assetMismatch (index : Nat) (left right : Cell P A D)
  | unequal (index : Nat) (left right : QualifiedPort) (leftAmount rightAmount : ℚ)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def resolveExport (catalog : Catalog P A D) (name : QualifiedPort) :
    Except EndpointFailure (Cell P A D) :=
  match catalog.find? (fun component ↦ decide (component.id = name.component)) with
  | none => .error (.missingComponent name)
  | some component =>
    match component.exports.find? (fun port ↦ decide (port.id = name.port)) with
    | none => .error (.missingPort name)
    | some port => .ok port.cell

def checkEdge (catalog : Catalog P A D) (edge : Binding) (state : Typed.State P A D)
    (index : Nat) : Except (BindingFailure P A D) (PUnit : Type) :=
  match resolveExport catalog edge.1 with
  | .error reason => .error (.endpoint index .left reason)
  | .ok left =>
    match resolveExport catalog edge.2 with
    | .error reason => .error (.endpoint index .right reason)
    | .ok right =>
      if left.1 ≠ right.1 then .error (.domainMismatch index left right)
      else if left.2.2 ≠ right.2.2 then .error (.assetMismatch index left right)
      else if state.balance left ≠ state.balance right then
        .error (.unequal index edge.1 edge.2 (state.balance left) (state.balance right))
      else .ok PUnit.unit

def checkEdgesFrom (catalog : Catalog P A D) (state : Typed.State P A D)
    (index : Nat) : List Binding → Except (BindingFailure P A D) (PUnit : Type)
  | [] => .ok PUnit.unit
  | edge :: rest =>
    match checkEdge catalog edge state index with
    | .error reason => .error reason
    | .ok _ => checkEdgesFrom catalog state (index + 1) rest

def checkBindings (cfg : Config P A D) (edges : List Binding) (state : Typed.State P A D) :
    Except (BindingFailure P A D) (PUnit : Type) :=
  if validateCatalog cfg.registry cfg.catalog then checkEdgesFrom cfg.catalog state 0 edges
  else .error .configuration

def bindingsHold (cfg : Config P A D) (edges : List Binding) (state : Typed.State P A D) : Bool :=
  match checkBindings cfg edges state with
  | .ok _ => true
  | .error _ => false

def EdgeAgrees (catalog : Catalog P A D) (edge : Binding) (state : Typed.State P A D) : Prop :=
  ∃ left right, resolveExport catalog edge.1 = .ok left ∧
    resolveExport catalog edge.2 = .ok right ∧ left.1 = right.1 ∧
    left.2.2 = right.2.2 ∧ state.balance left = state.balance right

def Agrees (catalog : Catalog P A D) (edges : List Binding) (state : Typed.State P A D) : Prop :=
  ∀ edge ∈ edges, EdgeAgrees catalog edge state

def reverseBinding (edge : Binding) : Binding := (edge.2, edge.1)

def symClosure (edges : List Binding) : Finset Binding :=
  (edges ++ edges.map reverseBinding).toFinset

-- BEGIN PROOFS

omit [DecidableEq P] in
theorem checkEdge_ok_iff (catalog : Catalog P A D) (edge : Binding)
    (state : Typed.State P A D) (index : Nat) :
    checkEdge catalog edge state index = .ok PUnit.unit ↔ EdgeAgrees catalog edge state := by
  cases hl : resolveExport catalog edge.1 with
  | error reason => simp [checkEdge, EdgeAgrees, hl]
  | ok left =>
    cases hr : resolveExport catalog edge.2 with
    | error reason => simp [checkEdge, EdgeAgrees, hl, hr]
    | ok right =>
      by_cases hd : left.1 = right.1 <;>
        by_cases ha : left.2.2 = right.2.2 <;>
        by_cases hb : state.balance left = state.balance right <;>
        simp [checkEdge, EdgeAgrees, hl, hr, hd, ha, hb]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_nil (catalog : Catalog P A D) (state : Typed.State P A D) :
    Agrees catalog [] state := by simp [Agrees]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_cons (catalog : Catalog P A D) (edge : Binding) (edges : List Binding)
    (state : Typed.State P A D) :
    Agrees catalog (edge :: edges) state ↔
      EdgeAgrees catalog edge state ∧ Agrees catalog edges state := by
  simp [Agrees]

omit [DecidableEq P] in
theorem checkEdgesFrom_ok_iff (catalog : Catalog P A D) (state : Typed.State P A D)
    (index : Nat) (edges : List Binding) :
    checkEdgesFrom catalog state index edges = .ok PUnit.unit ↔ Agrees catalog edges state := by
  induction edges generalizing index with
  | nil => simp [checkEdgesFrom, Agrees]
  | cons edge rest ih =>
    rw [agrees_cons]
    cases h : checkEdge catalog edge state index with
    | error reason =>
      have failed : ¬EdgeAgrees catalog edge state := by
        intro ok
        have := (checkEdge_ok_iff catalog edge state index).mpr ok
        simp [h] at this
      simp [checkEdgesFrom, h, failed]
    | ok token =>
      cases token
      have accepted := (checkEdge_ok_iff catalog edge state index).mp h
      simp [checkEdgesFrom, h, accepted, ih]

theorem checkBindings_ok_iff (cfg : Config P A D) (edges : List Binding)
    (state : Typed.State P A D) :
    checkBindings cfg edges state = .ok PUnit.unit ↔
      validateCatalog cfg.registry cfg.catalog = true ∧ Agrees cfg.catalog edges state := by
  by_cases valid : validateCatalog cfg.registry cfg.catalog = true
  · simp [checkBindings, valid, checkEdgesFrom_ok_iff]
  · simp [checkBindings, valid]

theorem bindingsHold_iff (cfg : Config P A D) (edges : List Binding)
    (state : Typed.State P A D) :
    bindingsHold cfg edges state = true ↔
      validateCatalog cfg.registry cfg.catalog = true ∧ Agrees cfg.catalog edges state := by
  rw [← checkBindings_ok_iff]
  cases h : checkBindings cfg edges state with
  | error reason => simp [bindingsHold, h]
  | ok token => cases token; simp [bindingsHold, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_append (catalog : Catalog P A D) (left right : List Binding)
    (state : Typed.State P A D) :
    Agrees catalog (left ++ right) state ↔
      Agrees catalog left state ∧ Agrees catalog right state := by
  constructor
  · intro h
    exact ⟨fun e he ↦ h e (List.mem_append_left _ he),
      fun e he ↦ h e (List.mem_append_right _ he)⟩
  · rintro ⟨hl, hr⟩ e he
    exact (List.mem_append.mp he).elim (hl e) (hr e)

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem edgeAgrees_reverse (catalog : Catalog P A D) (edge : Binding)
    (state : Typed.State P A D) :
    EdgeAgrees catalog (reverseBinding edge) state ↔ EdgeAgrees catalog edge state := by
  constructor <;> rintro ⟨left, right, hl, hr, hd, ha, hb⟩
  · exact ⟨right, left, hr, hl, hd.symm, ha.symm, hb.symm⟩
  · exact ⟨right, left, hr, hl, hd.symm, ha.symm, hb.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_reverse_edges (catalog : Catalog P A D) (edges : List Binding)
    (state : Typed.State P A D) :
    Agrees catalog (edges.map reverseBinding) state ↔ Agrees catalog edges state := by
  constructor
  · intro h e he
    exact (edgeAgrees_reverse catalog e state).mp (h _ (List.mem_map.mpr ⟨e, he, rfl⟩))
  · intro h e he
    obtain ⟨original, member, rfl⟩ := List.mem_map.mp he
    exact (edgeAgrees_reverse catalog original state).mpr (h original member)

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_duplicate (catalog : Catalog P A D) (edge : Binding) (edges : List Binding)
    (state : Typed.State P A D) :
    Agrees catalog (edge :: edge :: edges) state ↔ Agrees catalog (edge :: edges) state := by
  simp [agrees_cons]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_perm (catalog : Catalog P A D) (left right : List Binding)
    (state : Typed.State P A D) (h : left.Perm right) :
    Agrees catalog left state ↔ Agrees catalog right state := by
  exact ⟨fun hl e he ↦ hl e (h.mem_iff.mpr he), fun hr e he ↦ hr e (h.mem_iff.mp he)⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_assoc (catalog : Catalog P A D) (first second third : List Binding)
    (state : Typed.State P A D) :
    Agrees catalog ((first ++ second) ++ third) state ↔
      Agrees catalog (first ++ (second ++ third)) state := by rw [List.append_assoc]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_symClosure (catalog : Catalog P A D) (edges : List Binding)
    (state : Typed.State P A D) :
    (∀ edge ∈ symClosure edges, EdgeAgrees catalog edge state) ↔ Agrees catalog edges state := by
  change (∀ edge ∈ (edges ++ edges.map reverseBinding).toFinset,
    EdgeAgrees catalog edge state) ↔ _
  simp only [List.mem_toFinset]
  change Agrees catalog (edges ++ edges.map reverseBinding) state ↔ _
  rw [agrees_append, agrees_reverse_edges]
  exact ⟨And.left, fun h ↦ ⟨h, h⟩⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_of_symClosure_eq (catalog : Catalog P A D) (left right : List Binding)
    (state : Typed.State P A D) (h : symClosure left = symClosure right) :
    Agrees catalog left state ↔ Agrees catalog right state := by
  rw [← agrees_symClosure, ← agrees_symClosure, h]

end DefiKernel.Interface
