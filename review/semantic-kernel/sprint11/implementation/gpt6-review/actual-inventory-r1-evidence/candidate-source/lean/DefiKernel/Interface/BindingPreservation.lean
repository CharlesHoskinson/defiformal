import DefiKernel.Interface.BindingResolution
import DefiKernel.Interface.Accounting

/-! Equal actual endpoint effects preserve initialized balance constraints.
Constraint algebra transports meaning, without equating reordered diagnostics. -/
namespace DefiKernel.Interface
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def EffectPaired (catalog : Catalog P A D) (edges : List Binding)
    (receipt : Receipt P A D) : Prop :=
  ∀ edge ∈ edges, ∀ left right,
    resolveExport catalog edge.1 = .ok left → resolveExport catalog edge.2 = .ok right →
      receiptCellEffect receipt left = receiptCellEffect receipt right

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem edgeAgrees_self (catalog : Catalog P A D) (name : QualifiedPort)
    (state : State P A D) :
    EdgeAgrees catalog (name, name) state ↔ ∃ cell, resolveExport catalog name = .ok cell := by
  constructor
  · rintro ⟨left, right, hl, _, _, _, _⟩
    exact ⟨left, hl⟩
  · rintro ⟨cell, h⟩
    exact ⟨cell, cell, h, h, rfl, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem edgeAgrees_trans (catalog : Catalog P A D) (a b c : QualifiedPort)
    (state : State P A D) (ab : EdgeAgrees catalog (a, b) state)
    (bc : EdgeAgrees catalog (b, c) state) : EdgeAgrees catalog (a, c) state := by
  obtain ⟨left, middle, hl, hm, hd, ha, hb⟩ := ab
  obtain ⟨middle', right, hm', hr, hd', ha', hb'⟩ := bc
  have same : middle = middle' := Except.ok.inj (hm.symm.trans hm')
  subst middle'
  exact ⟨left, right, hl, hr, hd.trans hd', ha.trans ha', hb.trans hb'⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem agrees_transitive_extension (catalog : Catalog P A D) (a b c : QualifiedPort)
    (state : State P A D) :
    Agrees catalog [(a, b), (b, c)] state ↔ Agrees catalog [(a, b), (b, c), (a, c)] state := by
  simp only [agrees_cons]
  constructor
  · rintro ⟨ab, bc, _⟩
    exact ⟨ab, bc, edgeAgrees_trans catalog a b c state ab bc, agrees_nil _ _⟩
  · rintro ⟨ab, bc, _⟩
    exact ⟨ab, bc, agrees_nil _ _⟩

theorem symClosure_transitive_extension_ne (a b c : QualifiedPort)
    (ab : a ≠ b) (bc : b ≠ c) (ac : a ≠ c) :
    symClosure [(a, b), (b, c)] ≠ symClosure [(a, b), (b, c), (a, c)] := by
  intro same
  have member : (a, c) ∈ symClosure [(a, b), (b, c), (a, c)] := by
    simp [symClosure]
  rw [← same] at member
  simp [symClosure, reverseBinding, ab, ac, Ne.symm bc, Ne.symm ac] at member

theorem effectPaired_issued (catalog : Catalog P A D) (edges : List Binding) (id : CapabilityId) :
    EffectPaired catalog edges (.issued id) := by simp [EffectPaired, receiptCellEffect]

theorem effectPaired_revoked (catalog : Catalog P A D) (edges : List Binding) (id : CapabilityId) :
    EffectPaired catalog edges (.revoked id) := by simp [EffectPaired, receiptCellEffect]

theorem effectPaired_append (catalog : Catalog P A D) (left right : List Binding)
    (receipt : Receipt P A D) :
    EffectPaired catalog (left ++ right) receipt ↔
      EffectPaired catalog left receipt ∧ EffectPaired catalog right receipt := by
  constructor
  · intro h
    exact ⟨fun e he ↦ h e (List.mem_append_left _ he),
      fun e he ↦ h e (List.mem_append_right _ he)⟩
  · rintro ⟨hl, hr⟩ e he
    exact (List.mem_append.mp he).elim (hl e) (hr e)

theorem effectPaired_reverse (catalog : Catalog P A D) (edges : List Binding)
    (receipt : Receipt P A D) :
    EffectPaired catalog (edges.map reverseBinding) receipt ↔
      EffectPaired catalog edges receipt := by
  constructor
  · intro h e he left right hl hr
    exact (h _ (List.mem_map.mpr ⟨e, he, rfl⟩) right left hr hl).symm
  · intro h e he left right hl hr
    obtain ⟨original, member, rfl⟩ := List.mem_map.mp he
    exact (h original member right left hr hl).symm

theorem effectPaired_perm (catalog : Catalog P A D) (left right : List Binding)
    (receipt : Receipt P A D) (h : left.Perm right) :
    EffectPaired catalog left receipt ↔ EffectPaired catalog right receipt :=
  ⟨fun hl e he ↦ hl e (h.mem_iff.mpr he), fun hr e he ↦ hr e (h.mem_iff.mp he)⟩

theorem bindingsHold_perm (cfg : Config P A D) (left right : List Binding)
    (state : State P A D) (h : left.Perm right) :
    bindingsHold cfg left state = true ↔ bindingsHold cfg right state = true := by
  rw [bindingsHold_iff, bindingsHold_iff, agrees_perm cfg.catalog left right state h]

theorem bindingsHold_reverse (cfg : Config P A D) (edges : List Binding)
    (state : State P A D) :
    bindingsHold cfg (edges.map reverseBinding) state = true ↔
      bindingsHold cfg edges state = true := by
  rw [bindingsHold_iff, bindingsHold_iff, agrees_reverse_edges]

variable [Fintype P] [Fintype A] [Fintype D]

theorem step_binding_preserved {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D} (edges : List Binding)
    (initial : Agrees cfg.catalog edges pre.state)
    (executed : executeStep cfg boundary index history step pre = .ok result)
    (paired : EffectPaired cfg.catalog edges result.receipt) :
    Agrees cfg.catalog edges result.world.state := by
  intro edge member
  obtain ⟨left, right, hl, hr, hd, ha, hb⟩ := initial edge member
  refine ⟨left, right, hl, hr, hd, ha, ?_⟩
  rw [step_receipt_cell executed left, step_receipt_cell executed right, hb,
    paired edge member left right hl hr]

theorem step_binding_framed {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D} (edges : List Binding)
    (initial : Agrees cfg.catalog edges pre.state)
    (executed : executeStep cfg boundary index history step pre = .ok result)
    (untouched : ∀ edge ∈ edges, ∀ left right,
      resolveExport cfg.catalog edge.1 = .ok left → resolveExport cfg.catalog edge.2 = .ok right →
        left ∉ result.receipt.writes ∧ right ∉ result.receipt.writes) :
    Agrees cfg.catalog edges result.world.state := by
  apply step_binding_preserved edges initial executed
  intro edge member left right hl hr
  obtain ⟨leftOutside, rightOutside⟩ := untouched edge member left right hl hr
  rw [step_effect_outside_writes executed left leftOutside,
    step_effect_outside_writes executed right rightOutside]

theorem step_bindingsHold_preserved {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D} (edges : List Binding)
    (initial : bindingsHold cfg edges pre.state = true)
    (executed : executeStep cfg boundary index history step pre = .ok result)
    (paired : EffectPaired cfg.catalog edges result.receipt) :
    bindingsHold cfg edges result.world.state = true := by
  obtain ⟨valid, agrees⟩ := (bindingsHold_iff _ _ _).mp initial
  exact (bindingsHold_iff _ _ _).mpr ⟨valid, step_binding_preserved edges agrees executed paired⟩

end DefiKernel.Interface
