import DefiKernel.Interface.Tests
import DefiKernel.Interface.BindingPreservation
import DefiKernel.Interface.Preservation

/-! Concrete initialized and support witnesses. Universal local rules below still quantify
arbitrary current boundaries, indices, histories and worlds; they are not sampled runs. -/
namespace DefiKernel.Interface.Fixtures
open Typed Composition Examples

def region : Region P A D := ⟨.home, .usd, {alice, bob}⟩
def edges : List Binding := [(name 0, name 1)]
def totalSupport : Set C := {totalCell}
def totalValue (state : State P A D) : ℚ := state.balance totalCell

def pairedOnly (step : Step P A D) : Prop := step = .invoke op102
def transferOnly (step : Step P A D) : Prop := step = .invoke op100

-- BEGIN PROOFS

theorem catalog_valid : validateCatalog cfg.registry cfg.catalog = true := by decide

theorem region_wellFormed : region.WellFormed := by
  simp [Region.WellFormed, region, alice, bob]

theorem f10_all_state_equivalence (state : State P A D) :
    Agrees cfg.catalog [(name 0, name 1), (name 1, name 2)] state ↔
      Agrees cfg.catalog [(name 0, name 1), (name 1, name 2), (name 0, name 2)] state :=
  agrees_transitive_extension cfg.catalog (name 0) (name 1) (name 2) state

theorem f10_distinct_symmetric_closures :
    symClosure [(name 0, name 1), (name 1, name 2)] ≠
      symClosure [(name 0, name 1), (name 1, name 2), (name 0, name 2)] :=
  symClosure_transitive_extension_ne (name 0) (name 1) (name 2)
    (by decide) (by decide) (by decide)

theorem f07_initialized : Agrees cfg.catalog edges initial55.state :=
  (checkBindings_ok_iff cfg edges initial55.state).mp (by decide) |>.2

theorem paired_receipt {b : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : SR}
    (h : executeStep cfg b index history (.invoke op102) pre = .ok result) :
    result.receipt = receipt102 := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation cfg b index history op102 =
        .ok (⟨⟨102⟩, [], []⟩, ⟨⟨102⟩, [], [], ids [4, 5, 6], none⟩) := by rfl
    rw [hp] at prepared
    cases prepared
    have he : extractReceipt cfg b ⟨⟨102⟩, [], [], ids [4, 5, 6], none⟩ pre =
        .ok (evaluated [(alice, -1), (bob, -1), (carol, 2)] [alice, bob, carol]) := by rfl
    rw [he] at extracted
    cases extracted
    rfl

theorem paired_nonzero_effects :
    receiptCellEffect receipt102 alice = -1 ∧ receiptCellEffect receipt102 bob = -1 := by
  decide +kernel

theorem paired_effects : EffectPaired cfg.catalog edges receipt102 := by
  intro edge member left right hl hr
  have edge_eq : edge = (name 0, name 1) := by simpa [edges] using member
  subst edge
  have a : resolveExport cfg.catalog (name 0) = .ok alice := by rfl
  have b : resolveExport cfg.catalog (name 1) = .ok bob := by rfl
  rw [a] at hl
  rw [b] at hr
  cases hl
  cases hr
  exact paired_nonzero_effects.1.trans paired_nonzero_effects.2.symm

theorem f07_local_rule : LocalPreserves cfg pairedOnly (Agrees cfg.catalog edges) := by
  intro boundary index history step pre result allowed initialized executed
  cases allowed
  apply step_binding_preserved edges initialized executed
  rw [paired_receipt executed]
  exact paired_effects

theorem f07_group_initialized_preservation :
    Agrees cfg.catalog edges
      (Metatheory.runGroup cfg boundary initialCursor pairedGroup).world.state := by
  apply group_preserves cfg pairedOnly (Agrees cfg.catalog edges) f07_local_rule
  · intro step member
    simpa [pairedOnly, pairedGroup, Metatheory.flatten] using member
  · exact f07_initialized

theorem total_value_supported : ValueSupports totalSupport totalValue := by
  intro s t agree
  exact agree totalCell (by simp [totalSupport])

theorem f05_initialized : balanceSum region (world 6 4 0 10).state =
    totalValue (world 6 4 0 10).state := by decide +kernel

theorem transfer_receipt {b : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : SR}
    (h : executeStep cfg b index history (.invoke op100) pre = .ok result) :
    result.receipt = receipt100 := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation cfg b index history op100 =
        .ok (⟨⟨100⟩, [], []⟩, ⟨⟨100⟩, [], [], ids [0, 1], none⟩) := by rfl
    rw [hp] at prepared
    cases prepared
    have he : extractReceipt cfg b ⟨⟨100⟩, [], [], ids [0, 1], none⟩ pre =
        .ok (evaluated [(alice, -2), (bob, 2)] [alice, bob]) := by rfl
    rw [he] at extracted
    cases extracted
    rfl

theorem transfer_confined : WritesWithin region.cells receipt100 := by
  simp [WritesWithin, region, receipt100, Receipt.writes, evaluated]

theorem transfer_neutral : NeutralOn region region.cells receipt100 := by
  unfold NeutralOn
  decide +kernel

theorem transfer_total_separate : ∀ c ∈ receipt100.writes, c ∉ totalSupport := by
  simp [receipt100, Receipt.writes, evaluated, totalSupport, alice, bob, totalCell]

theorem f05_obligations :
    RegionObligations cfg transferOnly region region.cells totalSupport totalValue := by
  intro boundary index history step pre result permitted _ executed
  cases permitted
  rw [transfer_receipt executed]
  exact ⟨transfer_confined, transfer_neutral, transfer_total_separate⟩

theorem f05_local_rule :
    LocalPreserves cfg transferOnly (fun s ↦ balanceSum region s = totalValue s) :=
  region_localPreserves cfg transferOnly region region.cells totalSupport totalValue
    total_value_supported f05_obligations

theorem f05_every_prefix (steps : List (Step P A D))
    (permitted : ∀ step ∈ steps, transferOnly step) (count : Nat) :
    balanceSum region (Composition.run cfg boundary (world 6 4 0 10)
      (steps.take count)).world.state =
    totalValue (Composition.run cfg boundary (world 6 4 0 10) (steps.take count)).world.state :=
  run_preserves cfg transferOnly (fun s ↦ balanceSum region s = totalValue s) f05_local_rule
    boundary (world 6 4 0 10) (steps.take count)
    (fun step member ↦ permitted step (List.mem_of_mem_take member)) f05_initialized

/-- This soundness lemma connects the finite full-world comparison to actual record equality. -/
theorem worldEq_sound {x y : W} (h : Tests.worldEq x y = true) : x = y := by
  have hs : (∀ c, x.state.balance c = y.state.balance c) ∧
      x.capabilities = y.capabilities := of_decide_eq_true h
  rcases x with ⟨⟨xb, xn⟩, xc⟩
  rcases y with ⟨⟨yb, yn⟩, yc⟩
  have hb : xb = yb := funext hs.1
  have hc : xc = yc := hs.2
  cases hb
  cases hc
  rfl

theorem resultEq_sound {x y : SR} (h : Tests.resultEq x y = true) : x = y := by
  have hp : Tests.worldEq x.world y.world = true ∧
      decide (x.receipt = y.receipt ∧ x.outputs = y.outputs) = true := by
    simpa only [Tests.resultEq, Bool.and_eq_true] using h
  have hw := worldEq_sound hp.1
  have hs : x.receipt = y.receipt ∧ x.outputs = y.outputs := of_decide_eq_true hp.2
  rcases x with ⟨xw, xr, xo⟩
  rcases y with ⟨yw, yr, yo⟩
  cases hw
  obtain ⟨hr, ho⟩ := hs
  cases hr
  cases ho
  rfl

theorem outcomeEq_sound {x y : Except Composition.Failure SR}
    (h : Tests.outcomeEq x y = true) : x = y := by
  cases x with
  | error a =>
    cases y with
    | error b => exact congrArg Except.error (of_decide_eq_true h)
    | ok b => cases h
  | ok a =>
    cases y with
    | error b => cases h
    | ok b => exact congrArg Except.ok (resultEq_sound h)

theorem f01_actual_execution :
    executeStep cfg (boundary 0) 0 [] (.invoke op100) initial64 = .ok expected100 := by
  apply outcomeEq_sound
  decide +kernel

theorem f07_actual_execution :
    executeStep cfg (boundary 0) 0 [] (.invoke op102) initial55 = .ok expected102 := by
  apply outcomeEq_sound
  decide +kernel

theorem f06_actual_execution :
    executeStep exposedCfg (boundary 0) 0 [] (.invoke op105) (world 6 4 0 10) =
      .ok expected105 := by
  apply outcomeEq_sound
  decide +kernel

theorem f06_initialized : balanceSum region (world 6 4 0 10).state =
    totalValue (world 6 4 0 10).state := f05_initialized

theorem f06_actual_post_values : balanceSum region expected105.world.state = 10 ∧
    totalValue expected105.world.state = 11 := by decide +kernel

theorem f06_write_confined : WritesWithin {totalCell} expected105.receipt := by
  simp [WritesWithin, expected105, receipt105, Receipt.writes, evaluated]

theorem f06_region_neutral : NeutralOn region {totalCell} expected105.receipt := by
  unfold NeutralOn
  decide +kernel

theorem f06_missing_support_exclusion :
    ¬ (∀ c ∈ expected105.receipt.writes, c ∉ totalSupport) := by
  simp [expected105, receipt105, Receipt.writes, evaluated, totalSupport]

theorem duplicate_region_set_semantics : Tests.duplicateRegion.cells = region.cells := by
  simp [Tests.duplicateRegion, region]

theorem mixed_region_not_wellFormed : ¬ Tests.mixedRegion.WellFormed := by
  simp [Region.WellFormed, Tests.mixedRegion, alice, awayEur]

theorem fixed_ghost_missing_initialization :
    balanceSum region initial64.state ≠ 11 ∧
      balanceSum region expected100.world.state ≠ 11 := by decide +kernel

end DefiKernel.Interface.Fixtures
