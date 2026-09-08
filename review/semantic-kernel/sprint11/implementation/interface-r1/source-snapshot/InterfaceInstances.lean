import DefiKernel.Nary.Interference
import DefiKernel.Nary.Observation
import DefiKernel.Nary.Examples
import DefiKernel.Interface.TypedPreservation

/-! Proof-only accepted-M2 bridges for finite three-stream instances and material
counterexamples. Runtime fixtures stay in Examples; this module does not import
Interface.Tests or Interface.Fixtures. -/
namespace DefiKernel.Nary.InterfaceInstances
open Typed Composition Interface
open DefiKernel.Nary
open DefiKernel.Nary.Examples
open Interface.Examples (alice bob carol)

def f18ValueFn : State IP IA ID → ℚ := fun _ => f18Value
def f18Support : Set (Cell IP IA ID) := ∅
def f18Allowed (step : Step IP IA ID) : Prop := step = .invoke f18Op

/-- Shared initialized total and the entire fixed global edge set. -/
def f18Invariant (_b : Fin 3) (s : State IP IA ID) : Prop :=
  TypedTotalContract f18Region f18ValueFn s ∧ Agrees f18Cfg.catalog f18Edges s

/-- Region sum unchanged and alice/bob increments equal, from actual receipt effects. -/
def f18Guarantee (_b : Fin 3) (pre post : State IP IA ID) : Prop :=
  balanceSum f18Region post = balanceSum f18Region pre ∧
    post.balance alice - pre.balance alice = post.balance bob - pre.balance bob

def f18Result1 : StepResult IP IA ID := Interface.Examples.expected102
def f18Result2 : StepResult IP IA ID := ⟨f18WorldAfter 2, f18Receipt, []⟩
def f18Result3 : StepResult IP IA ID := ⟨f18WorldAfter 3, f18Receipt, []⟩

def vaultReserve (q : ℚ) (_b : Fin 3) (s : State P A D) : Prop :=
  q ≤ s.balance vaultC

def identityGuarantee (_b : Fin 3) (pre post : State P A D) : Prop :=
  pre.balance vaultC = post.balance vaultC

def depositRely (_b : Fin 3) (pre post : State P A D) : Prop :=
  pre.balance vaultC ≤ post.balance vaultC

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem f18_op_eq : f18Op = Interface.Examples.op102 := rfl
theorem f18_receipt_eq : f18Receipt = Interface.Examples.receipt102 := rfl
theorem f18_cfg_eq : f18Cfg = Interface.Examples.cfg := rfl
theorem f18_initial_eq : f18Initial = Interface.Examples.initial55 := rfl
theorem f18_bounds_boundary (b : Fin 3) (n : Nat) :
    f18Bounds b n = Interface.Examples.boundary 0 := rfl
theorem f18_branches_singleton (b : Fin 3) : f18Branches b = [f18Op] := rfl
theorem f18_edges_fixed :
    f18Edges = [(Interface.Examples.name 0, Interface.Examples.name 1)] := rfl
theorem f18_empty_edges : f18EmptyEdges = [] := rfl
theorem f18_worldAfter0 : f18WorldAfter 0 = f18Initial := rfl
theorem f18_worldAfter1 : f18WorldAfter 1 = Interface.Examples.paired1 := rfl
theorem f18_worldAfter2 : f18WorldAfter 2 = Interface.Examples.paired2 := rfl
theorem f18_worldAfter3 : f18WorldAfter 3 = Interface.Examples.world 2 2 6 := rfl
theorem f18_result1_eq : f18Result1 = ⟨f18WorldAfter 1, f18Receipt, []⟩ := rfl

theorem f18_region_wellFormed : f18Region.WellFormed := by
  intro c hc
  simp [Region.WellFormed, f18Region, alice, bob, carol] at hc ⊢
  rcases hc with h | h | h <;> subst c <;> simp [alice, bob, carol]

theorem f18_value_supported : ValueSupports f18Support f18ValueFn :=
  valueSupports_const _ _

theorem f18_catalog_valid : validateCatalog f18Cfg.registry f18Cfg.catalog = true := by
  decide

theorem f18_initialized_sum : balanceSum f18Region f18Initial.state = 10 := by
  decide +kernel

theorem f18_initialized_total : TypedTotalContract f18Region f18ValueFn f18Initial.state :=
  ⟨f18_region_wellFormed, by simpa [f18ValueFn, f18Value] using f18_initialized_sum⟩

theorem f18_initialized_agrees : Agrees f18Cfg.catalog f18Edges f18Initial.state := by
  have h : checkBindings f18Cfg f18Edges f18Initial.state = .ok PUnit.unit := by decide
  exact (checkBindings_ok_iff f18Cfg f18Edges f18Initial.state).mp h |>.2

theorem f18_initialized : ∀ b, f18Invariant b f18Initial.state := fun _ =>
  ⟨f18_initialized_total, f18_initialized_agrees⟩

theorem f18_op102_receipt {b : Boundary IP IA ID} {index : Nat}
    {history : List (OutputObservation IA)} {pre : IW} {result : Interface.Examples.SR}
    (h : executeStep f18Cfg b index history (.invoke f18Op) pre = .ok result) :
    result.receipt = f18Receipt := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation f18Cfg b index history f18Op =
        .ok (⟨⟨102⟩, [], []⟩,
          ⟨⟨102⟩, [], [], Interface.Examples.ids [4, 5, 6], none⟩) := by rfl
    rw [hp] at prepared
    cases prepared
    have he : extractReceipt f18Cfg b
        ⟨⟨102⟩, [], [], Interface.Examples.ids [4, 5, 6], none⟩ pre =
        .ok (Interface.Examples.evaluated [(alice, -1), (bob, -1), (carol, 2)]
          [alice, bob, carol]) := by rfl
    rw [he] at extracted
    cases extracted
    rfl

theorem f18_receipt_effects :
    receiptCellEffect f18Receipt alice = -1 ∧
      receiptCellEffect f18Receipt bob = -1 ∧
      receiptCellEffect f18Receipt carol = 2 := by
  decide +kernel

theorem f18_alice_bob_effects :
    receiptCellEffect f18Receipt alice = receiptCellEffect f18Receipt bob :=
  f18_receipt_effects.1.trans f18_receipt_effects.2.1.symm

theorem f18_receipt_delta_zero : receiptDelta f18Region f18Receipt = 0 := by
  decide +kernel

theorem f18_writes_within : WritesWithin f18Region.cells f18Receipt := by
  simp [WritesWithin, f18Region, f18Receipt, Interface.Examples.receipt102, Receipt.writes,
    Interface.Examples.evaluated, alice, bob, carol]

theorem f18_neutral : NeutralOn f18Region f18Region.cells f18Receipt := by
  change (f18Region.cells ∩ f18Region.cells).sum (receiptCellEffect f18Receipt) = 0
  rw [Finset.inter_self]
  exact f18_receipt_delta_zero

theorem f18_separate : ∀ c ∈ f18Receipt.writes, c ∉ f18Support := by
  intro _ _ h
  cases h

theorem f18_paired_effects : EffectPaired f18Cfg.catalog f18Edges f18Receipt := by
  intro edge member left right hl hr
  have edge_eq : edge = (Interface.Examples.name 0, Interface.Examples.name 1) := by
    simpa [f18Edges] using member
  subst edge
  have r0 : resolveExport f18Cfg.catalog (Interface.Examples.name 0) = .ok alice := by rfl
  have r1 : resolveExport f18Cfg.catalog (Interface.Examples.name 1) = .ok bob := by rfl
  rw [r0] at hl
  rw [r1] at hr
  cases hl
  cases hr
  exact f18_alice_bob_effects

theorem f18_region_obligations :
    RegionObligations f18Cfg f18Allowed f18Region f18Region.cells f18Support f18ValueFn := by
  intro boundary index history step pre result allowed _ executed
  cases allowed
  rw [f18_op102_receipt executed]
  exact ⟨f18_writes_within, f18_neutral, f18_separate⟩

theorem f18_binding_obligations : BindingObligations f18Cfg f18Allowed f18Edges := by
  intro boundary index history step pre result allowed _ executed
  cases allowed
  rw [f18_op102_receipt executed]
  exact f18_paired_effects

theorem f18_selected {b : Fin 3} {index : Nat} {inv : Invocation IP IA ID}
    (h : (f18Branches b)[index]? = some inv) : index = 0 ∧ inv = f18Op := by
  rw [f18_branches_singleton] at h
  cases index with
  | zero =>
    simp at h
    exact ⟨rfl, h.symm⟩
  | succ n => simp at h

theorem f18_guarantee_of_step {b : Boundary IP IA ID} {index : Nat}
    {history : List (OutputObservation IA)} {pre : IW} {result : Interface.Examples.SR}
    (executed : executeStep f18Cfg b index history (.invoke f18Op) pre = .ok result) :
    f18Guarantee 0 pre.state result.world.state := by
  have hrec := f18_op102_receipt executed
  have hsum := step_receipt_region f18Region executed
  have ha := step_receipt_cell executed alice
  have hb := step_receipt_cell executed bob
  refine ⟨?_, ?_⟩
  · rw [hsum, hrec, f18_receipt_delta_zero, add_zero]
  · rw [ha, hb, hrec, add_sub_cancel_left, add_sub_cancel_left]
    exact f18_alice_bob_effects

theorem f18_local_obligation :
    LocalObligation f18Cfg f18Bounds f18Branches f18Invariant f18Guarantee := by
  intro b index inv selected history pre result initialized executed
  obtain ⟨rfl, rfl⟩ := f18_selected selected
  have hrec := f18_op102_receipt executed
  have tot : TypedTotalContract f18Region f18ValueFn result.world.state := by
    refine step_typed_total_preserved f18Region f18Region.cells f18Support f18ValueFn
      f18_value_supported initialized.1 executed ?_ ?_ ?_
    · rw [hrec]; exact f18_writes_within
    · rw [hrec]; exact f18_neutral
    · rw [hrec]; exact f18_separate
  have agr : Agrees f18Cfg.catalog f18Edges result.world.state := by
    refine step_binding_preserved f18Edges initialized.2 executed ?_
    rw [hrec]
    exact f18_paired_effects
  exact ⟨⟨tot, agr⟩, f18_guarantee_of_step executed⟩

theorem f18_cross : CrossInclusion f18Guarantee f18Guarantee := by
  intro _ _ _ _ _ h
  exact h

theorem f18_stable : Stable f18Invariant f18Guarantee := by
  intro b pre post initialized ⟨hsum, hinc⟩
  obtain ⟨⟨hwf, htot⟩, hagrees⟩ := initialized
  refine ⟨⟨hwf, ?_⟩, ?_⟩
  · simpa [f18ValueFn, f18Value] using hsum.trans htot
  · intro edge member
    have hedge : edge = (Interface.Examples.name 0, Interface.Examples.name 1) := by
      simpa [f18Edges] using member
    subst edge
    obtain ⟨left, right, hl, hr, hd, ha, hb⟩ :=
      hagrees (Interface.Examples.name 0, Interface.Examples.name 1) (by simp [f18Edges])
    have r0 : resolveExport f18Cfg.catalog (Interface.Examples.name 0) = .ok alice := by rfl
    have r1 : resolveExport f18Cfg.catalog (Interface.Examples.name 1) = .ok bob := by rfl
    rw [r0] at hl
    cases hl
    rw [r1] at hr
    cases hr
    refine ⟨alice, bob, r0, r1, hd, ha, ?_⟩
    calc post.balance alice
        = pre.balance alice + (post.balance alice - pre.balance alice) := by ring
      _ = pre.balance alice + (post.balance bob - pre.balance bob) := by rw [hinc]
      _ = pre.balance bob + (post.balance bob - pre.balance bob) := by rw [hb]
      _ = post.balance bob := by ring

theorem f18_every_prefix (schedule : Schedule (Fin 3)) (length : Nat) :
    ∀ b, f18Invariant b
      (runPrefix f18Cfg f18Bounds f18Initial f18Branches
        (schedule.take length)).world.state :=
  every_prefix_invariants f18Cfg f18Bounds f18Initial f18Branches schedule
    f18Invariant f18Guarantee f18Guarantee f18_initialized f18_local_obligation
    f18_cross f18_stable length

theorem f18_all_tokens (schedule : Schedule (Fin 3)) :
    ∀ b, f18Invariant b
      (runPrefix f18Cfg f18Bounds f18Initial f18Branches schedule).world.state :=
  runPrefix_invariants f18Cfg f18Bounds f18Initial f18Branches schedule
    f18Invariant f18Guarantee f18Guarantee f18_initialized f18_local_obligation
    f18_cross f18_stable

theorem f18_schedules_length : f18Schedules.length = 6 := rfl

theorem f18_complete_of_mem {s : List (Fin 3)} (hs : s ∈ f18Schedules) :
    s.length = 3 ∧ Complete f18Branches s ∧ s.Nodup := by
  have hlist : f18Schedules =
      [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]] := rfl
  rw [hlist] at hs
  simp at hs
  rcases hs with h | h | h | h | h | h
  all_goals
    subst s
    refine ⟨rfl, ?_, by decide⟩
    intro b
    match b with
    | ⟨0, _⟩ => simp [f18Branches]
    | ⟨1, _⟩ => simp [f18Branches]
    | ⟨2, _⟩ => simp [f18Branches]

theorem f18_complete_schedules_invariants {s : List (Fin 3)} (hs : s ∈ f18Schedules) :
    Complete f18Branches s ∧
      ∀ b, f18Invariant b
        (runPrefix f18Cfg f18Bounds f18Initial f18Branches s).world.state :=
  ⟨(f18_complete_of_mem hs).2.1, f18_all_tokens s⟩

set_option maxHeartbeats 800000 in
/-- Kernel reduction of the accepted op102 step at initial55. -/
theorem f18_execute_initial :
    executeStep f18Cfg (Interface.Examples.boundary 0) 0 [] (.invoke f18Op) f18Initial =
      .ok f18Result1 := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
/-- Kernel reduction of the accepted op102 step at paired1. -/
theorem f18_execute_after1 :
    executeStep f18Cfg (Interface.Examples.boundary 0) 0 [] (.invoke f18Op)
      (f18WorldAfter 1) = .ok f18Result2 := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
/-- Kernel reduction of the accepted op102 step at paired2. -/
theorem f18_execute_after2 :
    executeStep f18Cfg (Interface.Examples.boundary 0) 0 [] (.invoke f18Op)
      (f18WorldAfter 2) = .ok f18Result3 := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f18_advance_eq {m : Machine (Fin 3) IP IA ID} {b : Fin 3}
    {result : StepResult IP IA ID}
    (hfail : (m.locals b).failure = none)
    (hsel : (f18Branches b)[(m.locals b).consumed]? = some f18Op)
    (hex : executeStep f18Cfg (f18Bounds b (m.locals b).nextIndex)
      (m.locals b).nextIndex (m.locals b).outputs (.invoke f18Op) m.world = .ok result) :
    advance f18Cfg f18Bounds f18Branches m b = m.accept b f18Op result := by
  have his : (m.locals b).failure.isSome = false := by simp [hfail]
  simp [advance, his, hsel, hex]

theorem f18_start_accept (a : Fin 3) :
    advance f18Cfg f18Bounds f18Branches (start f18Initial) a =
      (start f18Initial).accept a f18Op f18Result1 := by
  apply f18_advance_eq
  · simp [start_locals]
  · simp [start_locals, f18Branches]
  · simp [start_locals, start_world, f18Bounds]
    exact f18_execute_initial

theorem f18_second_accept (a b : Fin 3) (hab : a ≠ b) :
    advance f18Cfg f18Bounds f18Branches
        ((start f18Initial).accept a f18Op f18Result1) b =
      ((start f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2 := by
  apply f18_advance_eq
  · have h := accept_away (start (B := Fin 3) f18Initial) a b f18Op f18Result1 hab.symm
    simpa [start_locals] using congrArg (fun l => l.failure) h
  · have h := accept_away (start (B := Fin 3) f18Initial) a b f18Op f18Result1 hab.symm
    have hl : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals b = {} := by
      simpa [start_locals] using h
    simp [hl, f18Branches]
  · have h := accept_away (start (B := Fin 3) f18Initial) a b f18Op f18Result1 hab.symm
    have hl : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals b = {} := by
      simpa [start_locals] using h
    have hw : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).world =
        f18WorldAfter 1 := by
      simp [accept_world, f18Result1, Interface.Examples.expected102, f18WorldAfter]
    simp [hl, hw, f18Bounds]
    exact f18_execute_after1

theorem f18_third_accept (a b c : Fin 3) (_hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    advance f18Cfg f18Bounds f18Branches
        (((start f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2) c =
      (((start f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2).accept
        c f18Op f18Result3 := by
  apply f18_advance_eq
  · have h1 := accept_away (start (B := Fin 3) f18Initial) a c f18Op f18Result1 hac.symm
    have hl1 : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals c = {} := by
      simpa [start_locals] using h1
    have h2 := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b c f18Op f18Result2 hbc.symm
    simpa [hl1] using congrArg (fun l => l.failure) h2
  · have h1 := accept_away (start (B := Fin 3) f18Initial) a c f18Op f18Result1 hac.symm
    have hl1 : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals c = {} := by
      simpa [start_locals] using h1
    have h2 := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b c f18Op f18Result2 hbc.symm
    have hl2 :
        (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op
          f18Result2).locals c = {} := by
      simpa [hl1] using h2
    simp [hl2, f18Branches]
  · have h1 := accept_away (start (B := Fin 3) f18Initial) a c f18Op f18Result1 hac.symm
    have hl1 : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals c = {} := by
      simpa [start_locals] using h1
    have h2 := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b c f18Op f18Result2 hbc.symm
    have hl2 :
        (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op
          f18Result2).locals c = {} := by
      simpa [hl1] using h2
    have hw :
        (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op
          f18Result2).world = f18WorldAfter 2 := by
      simp [accept_world, f18Result2]
    simp [hl2, hw, f18Bounds]
    exact f18_execute_after2

theorem f18_three_run (a b c : Fin 3) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c] =
      (((start f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2).accept
        c f18Op f18Result3 := by
  rw [runPrefix, continueRun_cons, f18_start_accept, continueRun_cons, f18_second_accept a b hab,
    continueRun_cons, f18_third_accept a b c hab hac hbc, continueRun_nil]

theorem f18_result1_outputs : f18Result1.outputs = [] := rfl

theorem f18_first_local (a : Fin 3) :
    ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals a =
      ⟨1, [⟨0, .invoke f18Op, f18Initial, f18Result1⟩], [], 1, none⟩ := by
  simp [accept_selected, start_locals, start_world, f18_result1_outputs]

theorem f18_three_outcome (a b c : Fin 3) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals a).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals b).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals c).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals a).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals b).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [a, b, c]).locals c).events.head?.map
        (fun e => e.index) = some 0 := by
  rw [f18_three_run a b c hab hac hbc]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [accept_world, f18Result3]
  · have ha := f18_first_local a
    have hba := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b a f18Op f18Result2 hab
    have hca := accept_away
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c a f18Op f18Result3 hac
    simp [hca, hba, ha]
  · have hb0 := accept_away (start (B := Fin 3) f18Initial) a b f18Op f18Result1 hab.symm
    have hb : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals b = {} := by
      simpa [start_locals] using hb0
    have hbsel := accept_selected
      ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1) b f18Op f18Result2
    have hcb := accept_away
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c b f18Op f18Result3 hbc
    simp [hcb, hbsel, hb]
  · have hc0 := accept_away (start (B := Fin 3) f18Initial) a c f18Op f18Result1 hac.symm
    have hc1 : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals c = {} := by
      simpa [start_locals] using hc0
    have hc2 := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b c f18Op f18Result2 hbc.symm
    have hc : (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op
        f18Result2).locals c = {} := by
      simpa [hc1] using hc2
    have hcsel := accept_selected
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c f18Op f18Result3
    simp [hcsel, hc]
  · have ha := f18_first_local a
    have hba := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b a f18Op f18Result2 hab
    have hca := accept_away
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c a f18Op f18Result3 hac
    simp [hca, hba, ha]
  · have hb0 := accept_away (start (B := Fin 3) f18Initial) a b f18Op f18Result1 hab.symm
    have hb : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals b = {} := by
      simpa [start_locals] using hb0
    have hbsel := accept_selected
      ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1) b f18Op f18Result2
    have hcb := accept_away
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c b f18Op f18Result3 hbc
    simp [hcb, hbsel, hb]
  · have hc0 := accept_away (start (B := Fin 3) f18Initial) a c f18Op f18Result1 hac.symm
    have hc1 : ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).locals c = {} := by
      simpa [start_locals] using hc0
    have hc2 := accept_away ((start (B := Fin 3) f18Initial).accept a f18Op f18Result1)
      b c f18Op f18Result2 hbc.symm
    have hc : (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op
        f18Result2).locals c = {} := by
      simpa [hc1] using hc2
    have hcsel := accept_selected
      (((start (B := Fin 3) f18Initial).accept a f18Op f18Result1).accept b f18Op f18Result2)
      c f18Op f18Result3
    simp [hcsel, hc]

theorem f18_world_balances :
    (f18WorldAfter 0).state.balance alice = 5 ∧
      (f18WorldAfter 0).state.balance bob = 5 ∧
      (f18WorldAfter 0).state.balance carol = 0 ∧
      (f18WorldAfter 1).state.balance alice = 4 ∧
      (f18WorldAfter 1).state.balance bob = 4 ∧
      (f18WorldAfter 1).state.balance carol = 2 ∧
      (f18WorldAfter 2).state.balance alice = 3 ∧
      (f18WorldAfter 2).state.balance bob = 3 ∧
      (f18WorldAfter 2).state.balance carol = 4 ∧
      (f18WorldAfter 3).state.balance alice = 2 ∧
      (f18WorldAfter 3).state.balance bob = 2 ∧
      (f18WorldAfter 3).state.balance carol = 6 := by
  decide +kernel

theorem f18_schedule_012 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 0).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 1).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 1, 2]).locals 2).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 0 1 2 (by decide) (by decide) (by decide)

theorem f18_schedule_021 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 0).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 2).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [0, 2, 1]).locals 1).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 0 2 1 (by decide) (by decide) (by decide)

theorem f18_schedule_102 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 1).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 0).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 0, 2]).locals 2).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 1 0 2 (by decide) (by decide) (by decide)

theorem f18_schedule_120 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 1).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 2).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [1, 2, 0]).locals 0).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 1 2 0 (by decide) (by decide) (by decide)

theorem f18_schedule_201 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 2).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 0).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 0, 1]).locals 1).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 2 0 1 (by decide) (by decide) (by decide)

theorem f18_schedule_210 :
    (runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).world = f18WorldAfter 3 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 2).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 1).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 2).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 1).events.head?.map
        (fun e => e.index) = some 0 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f18Branches [2, 1, 0]).locals 0).events.head?.map
        (fun e => e.index) = some 0 :=
  f18_three_outcome 2 1 0 (by decide) (by decide) (by decide)

set_option maxHeartbeats 800000 in
/-- Kernel reduction of the accepted op103 step at initial55. -/
theorem f19_execute :
    executeStep f18Cfg (Interface.Examples.boundary 0) 0 [] (.invoke f19Op) f18Initial =
      .ok Interface.Examples.expected103 := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f19_op_eq : f19Op = Interface.Examples.op103 := rfl
theorem f19_receipt_eq : f19Receipt = Interface.Examples.receipt103 := rfl
theorem f19_world_eq : f19World = Interface.Examples.world 4 5 1 := rfl

theorem f19_receipt_effects :
    receiptCellEffect f19Receipt alice = -1 ∧
      receiptCellEffect f19Receipt bob = 0 ∧
      receiptCellEffect f19Receipt carol = 1 := by
  decide +kernel

theorem f19_not_effect_paired :
    ¬ EffectPaired f18Cfg.catalog f18Edges f19Receipt := by
  intro h
  have heq : receiptCellEffect f19Receipt alice = receiptCellEffect f19Receipt bob :=
    h (Interface.Examples.name 0, Interface.Examples.name 1) (by simp [f18Edges])
      alice bob (by rfl) (by rfl)
  rw [f19_receipt_effects.1, f19_receipt_effects.2.1] at heq
  exact absurd heq (by decide)

theorem f19_empty_agrees (s : State IP IA ID) :
    Agrees f18Cfg.catalog f18EmptyEdges s :=
  agrees_nil _ _

theorem f19_total_holds :
    TypedTotalContract f18Region f18ValueFn f19World.state :=
  ⟨f18_region_wellFormed, by decide +kernel⟩

theorem f19_checkBindings :
    checkBindings f18Cfg f18Edges f19World.state = f19BindingError := by
  decide

theorem f19_bindingsHold_false :
    bindingsHold f18Cfg f18Edges f19World.state = false := by
  decide

theorem f19_empty_bindingsHold :
    bindingsHold f18Cfg f18EmptyEdges f19World.state = true := by
  decide

theorem f19_not_agrees : ¬ Agrees f18Cfg.catalog f18Edges f19World.state := by
  intro h
  have hold : bindingsHold f18Cfg f18Edges f19World.state = true :=
    (bindingsHold_iff f18Cfg f18Edges f19World.state).mpr ⟨f18_catalog_valid, h⟩
  rw [f19_bindingsHold_false] at hold
  cases hold

theorem f19_advance :
    advance f18Cfg f18Bounds f19Branches (start f18Initial) 0 =
      (start f18Initial).accept 0 f19Op Interface.Examples.expected103 := by
  have hfail : ((start (B := Fin 3) f18Initial).locals 0).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f18Initial).locals 0).failure.isSome = false := by
    simp [hfail]
  have hsel : (f19Branches 0)[((start (B := Fin 3) f18Initial).locals 0).consumed]? =
      some f19Op := by
    simp [start_locals, f19Branches]
  have hex : executeStep f18Cfg
      (f18Bounds 0 ((start (B := Fin 3) f18Initial).locals 0).nextIndex)
      ((start (B := Fin 3) f18Initial).locals 0).nextIndex
      ((start (B := Fin 3) f18Initial).locals 0).outputs (.invoke f19Op)
      (start (B := Fin 3) f18Initial).world = .ok Interface.Examples.expected103 := by
    simp [start_locals, start_world, f18Bounds]
    exact f19_execute
  simp [advance, his, hsel, hex]

theorem f19_runPrefix :
    runPrefix f18Cfg f18Bounds f18Initial f19Branches [0] =
      (start f18Initial).accept 0 f19Op Interface.Examples.expected103 := by
  rw [runPrefix, continueRun_cons, f19_advance, continueRun_nil]

theorem f19_balances :
    (runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).world.state.balance alice = 4 ∧
      (runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).world.state.balance bob = 5 ∧
      (runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).world.state.balance carol = 1 ∧
      balanceSum f18Region
        (runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).world.state = 10 := by
  rw [f19_runPrefix, accept_world]
  simpa [Interface.Examples.expected103, f19World] using
    (by decide +kernel :
      f19World.state.balance alice = 4 ∧ f19World.state.balance bob = 5 ∧
        f19World.state.balance carol = 1 ∧ balanceSum f18Region f19World.state = 10)

theorem f19_local_index0 :
    ((runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).locals 0).nextIndex = 1 ∧
      ((runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).locals 0).events.head?.map
        (fun e => e.index) = some 0 := by
  rw [f19_runPrefix]
  simp [accept_selected, start_locals, start_world]

theorem f19_query :
    checkBindings f18Cfg f18Edges
        (runPrefix f18Cfg f18Bounds f18Initial f19Branches [0]).world.state =
      .error (.unequal 0 (Interface.Examples.name 0) (Interface.Examples.name 1) 4 5) := by
  rw [f19_runPrefix, accept_world]
  simpa [Interface.Examples.expected103, f19World, f19BindingError] using f19_checkBindings

set_option maxHeartbeats 800000 in
/-- Kernel reduction of authorized transfer7 at vault10. -/
theorem f11_execute :
    executeStep fundedCfg vaultBound 0 [] (.invoke inv14) f11Initial =
      .ok (sr f11After rec14) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
/-- Kernel reduction of authorized peer withdrawal7 at vault10. -/
theorem f13_execute :
    executeStep fundedCfg vaultBound 0 [] (.invoke inv21) f13Initial =
      .ok (sr f13After rec21) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

set_option maxHeartbeats 800000 in
/-- Kernel reduction of the identity operation at vault3. -/
theorem f14_execute :
    executeStep fundedCfg vaultBound 0 [] (.invoke inv17) f14Initial =
      .ok (sr f14Initial rec17) := by
  apply (outcomeEq_iff _ _).mp
  decide +kernel

theorem f11_catalog_valid : validateCatalog fundedCfg.registry fundedCfg.catalog = true := by
  decide

theorem f11_vaults :
    f11Initial.state.balance vaultC = 10 ∧ f11After.state.balance vaultC = 3 ∧
      f11After.state.balance recipientC = 7 := by
  decide +kernel

theorem f11_initialized_reserve : vaultReserve 4 0 f11Initial.state := by
  change 4 ≤ f11Initial.state.balance vaultC
  decide +kernel

theorem f11_post_not_reserve : ¬ vaultReserve 4 0 f11After.state := by
  change ¬ (4 ≤ f11After.state.balance vaultC)
  decide +kernel

theorem f11_nonneg : 0 ≤ f11After.state.balance vaultC ∧
    0 ≤ f11After.state.balance recipientC := by
  decide +kernel

theorem f11_advance :
    advance fundedCfg f11Bounds f11Branches (start f11Initial) 0 =
      (start f11Initial).accept 0 inv14 (sr f11After rec14) := by
  have hfail : ((start (B := Fin 3) f11Initial).locals 0).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f11Initial).locals 0).failure.isSome = false := by
    simp [hfail]
  have hsel : (f11Branches 0)[((start (B := Fin 3) f11Initial).locals 0).consumed]? =
      some inv14 := by
    simp [start_locals, f11Branches]
  have hex : executeStep fundedCfg
      (f11Bounds 0 ((start (B := Fin 3) f11Initial).locals 0).nextIndex)
      ((start (B := Fin 3) f11Initial).locals 0).nextIndex
      ((start (B := Fin 3) f11Initial).locals 0).outputs (.invoke inv14)
      (start (B := Fin 3) f11Initial).world = .ok (sr f11After rec14) := by
    simp [start_locals, start_world, f11Bounds]
    exact f11_execute
  simp [advance, his, hsel, hex]

theorem f11_runPrefix :
    runPrefix fundedCfg f11Bounds f11Initial f11Branches [0] =
      (start f11Initial).accept 0 inv14 (sr f11After rec14) := by
  rw [runPrefix, continueRun_cons, f11_advance, continueRun_nil]

theorem f11_outcome :
    (runPrefix fundedCfg f11Bounds f11Initial f11Branches [0]).world.state.balance vaultC = 3 ∧
      (runPrefix fundedCfg f11Bounds f11Initial f11Branches [0]).world.state.balance
        recipientC = 7 := by
  rw [f11_runPrefix, accept_world]
  exact ⟨f11_vaults.2.1, f11_vaults.2.2⟩

/-- Authorization and ordinary sufficient-balance success do not supply the reserve
local obligation used by the generic theorem. -/
theorem f11_not_reserve_obligation :
    ¬ LocalObligation fundedCfg f11Bounds f11Branches (vaultReserve 4)
      (fun _ _ _ => True) := by
  intro h
  have selected : (f11Branches (0 : Fin 3))[0]? = some inv14 := by simp [f11Branches]
  have hex : executeStep fundedCfg (f11Bounds 0 0) 0 [] (.invoke inv14) f11Initial =
      .ok (sr f11After rec14) := by
    simpa [f11Bounds] using f11_execute
  have post := (h 0 0 inv14 selected [] f11Initial (sr f11After rec14)
    f11_initialized_reserve hex).1
  exact f11_post_not_reserve post

theorem f13_vaults :
    f13Initial.state.balance vaultC = 10 ∧ f13After.state.balance vaultC = 3 := by
  decide +kernel

theorem f13_deposit_stable : Stable (vaultReserve 4) depositRely := by
  intro _ pre post hres hrel
  exact le_trans hres hrel

theorem f13_not_deposit_rely : ¬ depositRely 1 f13Initial.state f13After.state := by
  change ¬ (f13Initial.state.balance vaultC ≤ f13After.state.balance vaultC)
  decide +kernel

theorem f13_advance :
    advance fundedCfg f13Bounds f13Branches (start f13Initial) 1 =
      (start f13Initial).accept 1 inv21 (sr f13After rec21) := by
  have hfail : ((start (B := Fin 3) f13Initial).locals 1).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f13Initial).locals 1).failure.isSome = false := by
    simp [hfail]
  have hsel : (f13Branches 1)[((start (B := Fin 3) f13Initial).locals 1).consumed]? =
      some inv21 := by
    simp [start_locals, f13Branches]
  have hex : executeStep fundedCfg
      (f13Bounds 1 ((start (B := Fin 3) f13Initial).locals 1).nextIndex)
      ((start (B := Fin 3) f13Initial).locals 1).nextIndex
      ((start (B := Fin 3) f13Initial).locals 1).outputs (.invoke inv21)
      (start (B := Fin 3) f13Initial).world = .ok (sr f13After rec21) := by
    simp [start_locals, start_world, f13Bounds]
    exact f13_execute
  simp [advance, his, hsel, hex]

theorem f13_runPrefix :
    runPrefix fundedCfg f13Bounds f13Initial f13Branches [1] =
      (start f13Initial).accept 1 inv21 (sr f13After rec21) := by
  rw [runPrefix, continueRun_cons, f13_advance, continueRun_nil]

theorem f13_post_not_reserve : ¬ vaultReserve 4 0 f13After.state := by
  change ¬ (4 ≤ f13After.state.balance vaultC)
  decide +kernel

theorem f13_outcome :
    (runPrefix fundedCfg f13Bounds f13Initial f13Branches [1]).world.state.balance vaultC = 3 ∧
      ¬ vaultReserve 4 0
        (runPrefix fundedCfg f13Bounds f13Initial f13Branches [1]).world.state := by
  rw [f13_runPrefix, accept_world]
  exact ⟨f13_vaults.2, f13_post_not_reserve⟩

theorem f13_peer_not_covered :
    vaultReserve 4 0 f13Initial.state ∧
      Stable (vaultReserve 4) depositRely ∧
      ¬ depositRely 1 f13Initial.state
        (runPrefix fundedCfg f13Bounds f13Initial f13Branches [1]).world.state := by
  refine ⟨?_, f13_deposit_stable, ?_⟩
  · change 4 ≤ f13Initial.state.balance vaultC
    decide +kernel
  · rw [f13_runPrefix, accept_world]
    exact f13_not_deposit_rely

theorem f14_vault : f14Initial.state.balance vaultC = 3 := by
  decide +kernel

theorem f14_not_initialized : ¬ vaultReserve 4 0 f14Initial.state := by
  change ¬ (4 ≤ f14Initial.state.balance vaultC)
  decide +kernel

theorem f14_identity_receipt {b : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : SR}
    (h : executeStep fundedCfg b index history (.invoke inv17) pre = .ok result) :
    result.receipt = rec17 := by
  cases executeStep_sound _ _ _ _ _ _ _ h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have hp : prepareInvocation fundedCfg b index history inv17 =
        .ok (⟨⟨17⟩, [], []⟩, ⟨⟨17⟩, [], [], ids [0], none⟩) := by rfl
    rw [hp] at prepared
    cases prepared
    have he : extractReceipt fundedCfg b ⟨⟨17⟩, [], [], ids [0], none⟩ pre =
        .ok (evaluated true [] [] []) := by rfl
    rw [he] at extracted
    cases extracted
    rfl

theorem f14_identity_cell {b : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {pre : W} {result : SR}
    (h : executeStep fundedCfg b index history (.invoke inv17) pre = .ok result)
    (cell : Cell P A D) :
    result.world.state.balance cell = pre.state.balance cell := by
  have hrec := f14_identity_receipt h
  have hc := step_receipt_cell h cell
  have hz : receiptCellEffect rec17 cell = 0 := by
    simp [rec17, recIdentity, receiptCellEffect, evaluated]
  rw [hrec, hz, add_zero] at hc
  exact hc

theorem f14_branch_inv (b : Fin 3) : f14Branches b = [inv17] := by
  match b with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl

theorem f14_identity_obligation :
    LocalObligation fundedCfg f14Bounds f14Branches (vaultReserve 4) identityGuarantee := by
  intro b index inv selected history pre result initialized executed
  rw [f14_branch_inv] at selected
  have hidx : index = 0 ∧ inv = inv17 := by
    cases index with
    | zero =>
      simp at selected
      exact ⟨rfl, selected.symm⟩
    | succ n => simp at selected
  obtain ⟨rfl, rfl⟩ := hidx
  have hvault := f14_identity_cell executed vaultC
  exact ⟨by simpa [vaultReserve, hvault] using initialized, hvault.symm⟩

theorem f14_identity_cross : CrossInclusion identityGuarantee identityGuarantee := by
  intro _ _ _ _ _ h
  exact h

theorem f14_identity_stable : Stable (vaultReserve 4) identityGuarantee := by
  intro _ pre post hres hrel
  simpa [vaultReserve, hrel.symm] using hres

theorem f14_advance (b : Fin 3) :
    advance fundedCfg f14Bounds f14Branches (start f14Initial) b =
      (start f14Initial).accept b inv17 (sr f14Initial rec17) := by
  have hfail : ((start (B := Fin 3) f14Initial).locals b).failure = none := by
    simp [start_locals]
  have his : ((start (B := Fin 3) f14Initial).locals b).failure.isSome = false := by
    simp [hfail]
  have hsel : (f14Branches b)[((start (B := Fin 3) f14Initial).locals b).consumed]? =
      some inv17 := by
    simp [start_locals, f14_branch_inv]
  have hex : executeStep fundedCfg
      (f14Bounds b ((start (B := Fin 3) f14Initial).locals b).nextIndex)
      ((start (B := Fin 3) f14Initial).locals b).nextIndex
      ((start (B := Fin 3) f14Initial).locals b).outputs (.invoke inv17)
      (start (B := Fin 3) f14Initial).world = .ok (sr f14Initial rec17) := by
    simp [start_locals, start_world, f14Bounds]
    exact f14_execute
  simp [advance, his, hsel, hex]

theorem f14_first :
    runPrefix fundedCfg f14Bounds f14Initial f14Branches [0] =
      (start f14Initial).accept 0 inv17 (sr f14Initial rec17) := by
  rw [runPrefix, continueRun_cons, f14_advance 0, continueRun_nil]

theorem f14_stays_uninitialized :
    (runPrefix fundedCfg f14Bounds f14Initial f14Branches [0]).world.state.balance vaultC = 3 ∧
      ¬ vaultReserve 4 0
        (runPrefix fundedCfg f14Bounds f14Initial f14Branches [0]).world.state := by
  rw [f14_first, accept_world]
  exact ⟨f14_vault, f14_not_initialized⟩

/-- Local identity obligations, cross-inclusion and stability all hold; the generic
initialized theorem still does not apply because reserve 4 is false at entry 3. -/
theorem f14_remaining_premises :
    LocalObligation fundedCfg f14Bounds f14Branches (vaultReserve 4) identityGuarantee ∧
      CrossInclusion identityGuarantee identityGuarantee ∧
      Stable (vaultReserve 4) identityGuarantee ∧
      ¬ vaultReserve 4 0 f14Initial.state ∧
      (runPrefix fundedCfg f14Bounds f14Initial f14Branches []).world.state.balance vaultC = 3 :=
  ⟨f14_identity_obligation, f14_identity_cross, f14_identity_stable, f14_not_initialized, by
    simp [runPrefix, continueRun_nil, start_world, f14_vault]⟩

theorem f15_false_circular :
    (f15Left → f15Right) ∧ (f15Right → f15Left) ∧ ¬ f15Left ∧ ¬ f15Right := by
  refine ⟨?_, ?_, id, id⟩
  · intro h; exact h.elim
  · intro h; exact h.elim

theorem f15_implications_do_not_initialize :
    (f15Left → f15Right) ∧ (f15Right → f15Left) ∧
      ¬ f15Left ∧ ¬ vaultReserve 4 0 f14Initial.state :=
  ⟨f15_false_circular.1, f15_false_circular.2.1, f15_false_circular.2.2.1, f14_not_initialized⟩

end DefiKernel.Nary.InterfaceInstances
