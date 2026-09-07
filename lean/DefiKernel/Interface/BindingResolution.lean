import DefiKernel.Interface.Bindings
import Mathlib.Data.List.Nodup

/-! Exact first-error positions and uniqueness of qualified resource exports. -/
namespace DefiKernel.Interface
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def EdgeFailureAt (catalog : Catalog P A D) (edge : Binding) (state : State P A D)
    (index : Nat) (failure : BindingFailure P A D) : Prop :=
  (∃ reason, resolveExport catalog edge.1 = .error reason ∧
    failure = .endpoint index .left reason) ∨
  (∃ left reason, resolveExport catalog edge.1 = .ok left ∧
    resolveExport catalog edge.2 = .error reason ∧ failure = .endpoint index .right reason) ∨
  (∃ left right, resolveExport catalog edge.1 = .ok left ∧
    resolveExport catalog edge.2 = .ok right ∧
    ((left.1 ≠ right.1 ∧ failure = .domainMismatch index left right) ∨
      (left.1 = right.1 ∧ left.2.2 ≠ right.2.2 ∧ failure = .assetMismatch index left right) ∨
      (left.1 = right.1 ∧ left.2.2 = right.2.2 ∧ state.balance left ≠ state.balance right ∧
        failure = .unequal index edge.1 edge.2 (state.balance left) (state.balance right))))

-- BEGIN PROOFS

omit [DecidableEq P] in
theorem checkEdge_error_iff (catalog : Catalog P A D) (edge : Binding) (state : State P A D)
    (index : Nat) (failure : BindingFailure P A D) :
    checkEdge catalog edge state index = .error failure ↔
      EdgeFailureAt catalog edge state index failure := by
  cases hl : resolveExport catalog edge.1 with
  | error reason => simp [checkEdge, EdgeFailureAt, hl, eq_comm]
  | ok left =>
    cases hr : resolveExport catalog edge.2 with
    | error reason => simp [checkEdge, EdgeFailureAt, hl, hr, eq_comm]
    | ok right =>
      by_cases hd : left.1 = right.1 <;>
        by_cases ha : left.2.2 = right.2.2 <;>
        by_cases hb : state.balance left = state.balance right <;>
        simp [checkEdge, EdgeFailureAt, hl, hr, hd, ha, hb, eq_comm]

omit [DecidableEq P] in
theorem checkEdgesFrom_error_iff (catalog : Catalog P A D) (state : State P A D)
    (index : Nat) (edges : List Binding) (failure : BindingFailure P A D) :
    checkEdgesFrom catalog state index edges = .error failure ↔
      ∃ before edge after, edges = before ++ edge :: after ∧ Agrees catalog before state ∧
        checkEdge catalog edge state (index + before.length) = .error failure := by
  induction edges generalizing index with
  | nil => simp [checkEdgesFrom]
  | cons current rest ih =>
    cases hc : checkEdge catalog current state index with
    | error reason =>
      constructor
      · intro h
        have same : reason = failure := by simpa [checkEdgesFrom, hc] using h
        subst failure
        exact ⟨[], current, rest, rfl, agrees_nil _ _, by simpa using hc⟩
      · rintro ⟨before, edge, after, eq, previous, failed⟩
        cases before with
        | nil =>
          simp only [List.nil_append, List.cons.injEq] at eq
          obtain ⟨rfl, rfl⟩ := eq
          simpa [checkEdgesFrom, hc] using failed
        | cons first before =>
          simp only [List.cons_append, List.cons.injEq] at eq
          obtain ⟨rfl, _⟩ := eq
          have ok := (checkEdge_ok_iff catalog current state index).mpr
            ((agrees_cons _ _ _ _).mp previous).1
          simp [hc] at ok
    | ok token =>
      cases token
      have currentGood := (checkEdge_ok_iff catalog current state index).mp hc
      constructor
      · intro h
        have tail : checkEdgesFrom catalog state (index + 1) rest = .error failure := by
          simpa [checkEdgesFrom, hc] using h
        obtain ⟨before, edge, after, eq, previous, failed⟩ := (ih (index + 1)).mp tail
        refine ⟨current :: before, edge, after, by simp [eq],
          (agrees_cons _ _ _ _).mpr ⟨currentGood, previous⟩, ?_⟩
        simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using failed
      · rintro ⟨before, edge, after, eq, previous, failed⟩
        cases before with
        | nil =>
          simp only [List.nil_append, List.cons.injEq] at eq
          obtain ⟨rfl, rfl⟩ := eq
          simp [hc] at failed
        | cons first before =>
          simp only [List.cons_append, List.cons.injEq] at eq
          obtain ⟨rfl, eq⟩ := eq
          have tail := (ih (index + 1)).mpr
            ⟨before, edge, after, eq, ((agrees_cons _ _ _ _).mp previous).2,
              by simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using failed⟩
          simpa [checkEdgesFrom, hc] using tail

theorem checkBindings_error_iff (cfg : Config P A D) (edges : List Binding)
    (state : State P A D) (failure : BindingFailure P A D) :
    checkBindings cfg edges state = .error failure ↔
      (validateCatalog cfg.registry cfg.catalog = false ∧ failure = .configuration) ∨
      (validateCatalog cfg.registry cfg.catalog = true ∧
        ∃ before edge after, edges = before ++ edge :: after ∧
          Agrees cfg.catalog before state ∧
          checkEdge cfg.catalog edge state before.length = .error failure) := by
  cases valid : validateCatalog cfg.registry cfg.catalog with
  | false => simp [checkBindings, valid, eq_comm]
  | true =>
    simpa [checkBindings, valid] using
      (checkEdgesFrom_error_iff cfg.catalog state 0 edges failure)

theorem checkBindings_first_failure (cfg : Config P A D) (edges : List Binding)
    (state : State P A D) (failure : BindingFailure P A D) :
    checkBindings cfg edges state = .error failure ↔
      (validateCatalog cfg.registry cfg.catalog = false ∧ failure = .configuration) ∨
      (validateCatalog cfg.registry cfg.catalog = true ∧
        ∃ before edge after, edges = before ++ edge :: after ∧
          Agrees cfg.catalog before state ∧
          EdgeFailureAt cfg.catalog edge state before.length failure) := by
  simp only [checkBindings_error_iff, checkEdge_error_iff]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveExport_witness (catalog : Catalog P A D) (name : QualifiedPort)
    (cell : Cell P A D) (h : resolveExport catalog name = .ok cell) :
    ∃ component ∈ catalog, component.id = name.component ∧
      ∃ port ∈ component.exports, port.id = name.port ∧ port.cell = cell := by
  cases hc : catalog.find? (fun component ↦ decide (component.id = name.component)) with
  | none => simp [resolveExport, hc] at h
  | some component =>
    cases hp : component.exports.find? (fun port ↦ decide (port.id = name.port)) with
    | none => simp [resolveExport, hc, hp] at h
    | some port =>
      exact ⟨component, List.mem_of_find?_eq_some hc, by simpa using List.find?_some hc,
        port, List.mem_of_find?_eq_some hp, by simpa using List.find?_some hp,
        by simpa [resolveExport, hc, hp] using h⟩

theorem find_unique {X : Type} (predicate : X → Bool) (items : List X) (item : X)
    (member : item ∈ items) (accepted : predicate item = true)
    (unique : ∀ other ∈ items, predicate other = true → other = item) :
    items.find? predicate = some item := by
  cases h : items.find? predicate with
  | none =>
    have rejected := List.find?_eq_none.mp h item member
    simp [accepted] at rejected
  | some other =>
    have same := unique other (List.mem_of_find?_eq_some h) (List.find?_some h)
    simpa [same] using h

theorem valid_component_ids (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) : (catalog.map Component.id).Nodup := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  exact of_decide_eq_true valid.1.1.1.1

theorem valid_export_ids (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (component : Component P A D)
    (member : component ∈ catalog) : (component.exports.map ResourcePort.id).Nodup := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have hc := List.all_eq_true.mp valid.2 component member
  simp only [Bool.and_eq_true] at hc
  have ports : component.portIds.Nodup := of_decide_eq_true hc.1.1.1.1
  exact (List.nodup_append.mp ports).1

theorem resolveExport_of_member (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (component : Component P A D)
    (member : component ∈ catalog) (port : ResourcePort P A D) (exported : port ∈ component.exports)
    (name : QualifiedPort) (componentId : component.id = name.component)
    (portId : port.id = name.port) : resolveExport catalog name = .ok port.cell := by
  have componentFound :
      catalog.find? (fun c ↦ decide (c.id = name.component)) = some component := by
    apply find_unique _ _ _ member (by simpa using componentId)
    intro other ho same
    exact List.inj_on_of_nodup_map (valid_component_ids registry catalog valid) ho member
      ((of_decide_eq_true same).trans componentId.symm)
  have portFound :
      component.exports.find? (fun p ↦ decide (p.id = name.port)) = some port := by
    apply find_unique _ _ _ exported (by simpa using portId)
    intro other ho same
    exact List.inj_on_of_nodup_map (valid_export_ids registry catalog valid component member)
      ho exported ((of_decide_eq_true same).trans portId.symm)
  simp [resolveExport, componentFound, portFound]

theorem resolveExport_iff (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (name : QualifiedPort) (cell : Cell P A D) :
    resolveExport catalog name = .ok cell ↔
      ∃ component ∈ catalog, component.id = name.component ∧
        ∃ port ∈ component.exports, port.id = name.port ∧ port.cell = cell := by
  constructor
  · exact resolveExport_witness catalog name cell
  · rintro ⟨component, member, componentId, port, exported, portId, rfl⟩
    exact resolveExport_of_member registry catalog valid component member port exported
      name componentId portId

theorem exported_cell_unique (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true)
    (left right : Component P A D) (hl : left ∈ catalog) (hr : right ∈ catalog)
    (lp rp : ResourcePort P A D) (hlp : lp ∈ left.exports) (hrp : rp ∈ right.exports)
    (same : lp.cell = rp.cell) : left = right ∧ lp = rp := by
  have nodup : (catalog.flatMap (fun c ↦ c.exports.map ResourcePort.cell)).Nodup := by
    simp only [validateCatalog, Bool.and_eq_true] at valid
    exact of_decide_eq_true valid.1.2
  let tagged := catalog.flatMap (fun c ↦ c.exports.map (fun p ↦ (c, p)))
  have mapped : (tagged.map (fun pair ↦ pair.2.cell)).Nodup := by
    simpa [tagged, List.map_flatMap, List.map_map, Function.comp_def] using nodup
  have leftMember : (left, lp) ∈ tagged :=
    List.mem_flatMap.mpr ⟨left, hl, List.mem_map.mpr ⟨lp, hlp, rfl⟩⟩
  have rightMember : (right, rp) ∈ tagged :=
    List.mem_flatMap.mpr ⟨right, hr, List.mem_map.mpr ⟨rp, hrp, rfl⟩⟩
  exact Prod.mk.inj (List.inj_on_of_nodup_map mapped leftMember rightMember same)

theorem resolved_names_unique (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (left right : QualifiedPort)
    (cell : Cell P A D) (hl : resolveExport catalog left = .ok cell)
    (hr : resolveExport catalog right = .ok cell) : left = right := by
  obtain ⟨lc, hlc, lcid, lp, hlp, lpid, hcell⟩ := resolveExport_witness catalog left cell hl
  obtain ⟨rc, hrc, rcid, rp, hrp, rpid, hcell'⟩ := resolveExport_witness catalog right cell hr
  obtain ⟨rfl, rfl⟩ := exported_cell_unique registry catalog valid lc rc hlc hrc lp rp hlp hrp
    (hcell.trans hcell'.symm)
  cases left
  cases right
  simp_all

theorem distinct_exports_nonalias (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (left right : QualifiedPort)
    (leftCell rightCell : Cell P A D) (distinct : left ≠ right)
    (hl : resolveExport catalog left = .ok leftCell)
    (hr : resolveExport catalog right = .ok rightCell) : leftCell ≠ rightCell := by
  intro same
  subst rightCell
  exact distinct (resolved_names_unique registry catalog valid left right leftCell hl hr)

theorem valid_import_resolution (registry : Registry P A D) (catalog : Catalog P A D)
    (valid : validateCatalog registry catalog = true) (component : Component P A D)
    (member : component ∈ catalog) (imported : ResourceImport P A D)
    (hi : imported ∈ component.imports) :
    resolveExport catalog imported.source = .ok imported.cell := by
  have original := valid
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have hc := List.all_eq_true.mp valid.2 component member
  simp only [Bool.and_eq_true] at hc
  have importedValid := List.all_eq_true.mp hc.1.2 imported hi
  simp only [Bool.and_eq_true] at importedValid
  obtain ⟨source, hs, validSource⟩ := List.any_eq_true.mp importedValid.2
  simp only [Bool.and_eq_true, decide_eq_true_eq] at validSource
  obtain ⟨port, hp, validPort⟩ := List.any_eq_true.mp validSource.2
  simp only [Bool.and_eq_true, decide_eq_true_eq] at validPort
  rw [← validPort.1.2]
  exact resolveExport_of_member registry catalog original source hs port hp imported.source
    validSource.1 validPort.1.1

end DefiKernel.Interface
