import DefiKernel.Interface.AccountingInterleaving
import DefiKernel.Interface.BindingPreservation
import DefiKernel.Interleaving.Soundness
import DefiKernel.Metatheory.SequentialGroups

/-! Initialized invariants lift through actual sequential and shared execution. Local
obligations quantify over every current history, position, boundary and pre-world. -/
namespace DefiKernel.Interface
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def LocalPreserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) : Prop :=
  ∀ boundary index history step pre result, allowed step → invariant pre.state →
    executeStep cfg boundary index history step pre = .ok result → invariant result.world.state

def RegionObligations (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ) : Prop :=
  ∀ boundary index history step pre result, allowed step →
    balanceSum region pre.state = value pre.state →
    executeStep cfg boundary index history step pre = .ok result →
    WritesWithin cells result.receipt ∧ NeutralOn region cells result.receipt ∧
      ∀ c ∈ result.receipt.writes, c ∉ support

/-- Paired actual endpoint effects, required at the current initialized state only. -/
def BindingObligations (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) : Prop :=
  ∀ boundary index history step pre result, allowed step → Agrees cfg.catalog edges pre.state →
    executeStep cfg boundary index history step pre = .ok result →
    EffectPaired cfg.catalog edges result.receipt

-- BEGIN PROOFS

theorem region_localPreserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value) :
    LocalPreserves cfg allowed (fun state ↦ balanceSum region state = value state) := by
  intro boundary index history step pre result ha hi he
  obtain ⟨hw, hn, hs⟩ := obligations boundary index history step pre result ha hi he
  exact step_total_preserved region cells support value supported hi he hw hn hs

theorem advance_preserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) (localRule : LocalPreserves cfg allowed invariant)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D) (step : Step P A D)
    (permitted : allowed step) (initial : invariant entry.world.state) :
    invariant (Composition.advance cfg boundaries entry step).world.state := by
  cases hf : entry.failure with
  | some failure => simpa [Composition.advance, hf] using initial
  | none =>
    cases he : executeStep cfg (boundaries entry.nextIndex) entry.nextIndex
        entry.outputs step entry.world with
    | error reason => simpa [Composition.advance, hf, he] using initial
    | ok result =>
      simpa [Composition.advance, hf, he] using
        localRule _ _ _ _ _ _ permitted initial he

theorem continueRun_preserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) (localRule : LocalPreserves cfg allowed invariant)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : invariant entry.world.state) :
    invariant (Composition.continueRun cfg boundaries entry steps).world.state := by
  induction steps generalizing entry with
  | nil => exact initial
  | cons step steps ih =>
    exact ih (Composition.advance cfg boundaries entry step)
      (fun s hs ↦ permitted s (List.mem_cons_of_mem _ hs))
      (advance_preserves cfg allowed invariant localRule boundaries entry step
        (permitted step (List.mem_cons_self)) initial)

theorem sequential_prefix_preserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) (localRule : LocalPreserves cfg allowed invariant)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : invariant entry.world.state) (count : Nat) :
    invariant (Composition.continueRun cfg boundaries entry (steps.take count)).world.state :=
  continueRun_preserves cfg allowed invariant localRule boundaries entry (steps.take count)
    (fun step hs ↦ permitted step (List.mem_of_mem_take hs)) initial

theorem run_preserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) (localRule : LocalPreserves cfg allowed invariant)
    (boundaries : Nat → Boundary P A D) (initial : World P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initialized : invariant initial.state) :
    invariant (Composition.run cfg boundaries initial steps).world.state :=
  continueRun_preserves cfg allowed invariant localRule boundaries
    (startCursor cfg initial) steps permitted initialized

theorem group_preserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (invariant : State P A D → Prop) (localRule : LocalPreserves cfg allowed invariant)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D)
    (permitted : ∀ step ∈ Metatheory.flatten group, allowed step)
    (initial : invariant entry.world.state) :
    invariant (Metatheory.runGroup cfg boundaries entry group).world.state := by
  rw [Metatheory.runGroup_eq_continueRun]
  exact continueRun_preserves cfg allowed invariant localRule boundaries entry _ permitted initial

theorem group_accounting (region : Region P A D) (cfg : Config P A D)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D) :
    balanceSum region (Metatheory.runGroup cfg boundaries entry group).world.state =
      balanceSum region entry.world.state + eventDeltaSum region
        ((Metatheory.runGroup cfg boundaries entry group).events.drop entry.events.length) := by
  simp only [Metatheory.runGroup_eq_continueRun]
  exact continueRun_accounting region cfg boundaries entry _

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem selected_invocation_allowed (allowed : Step P A D → Prop)
    (left right : Branch P A D) (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv)) (branch : BranchId)
    (index : Nat) (inv : Invocation P A D)
    (selected : (Interleaving.selectBranch left right branch)[index]? = some inv) :
    allowed (.invoke inv) := by
  have member : inv ∈ Interleaving.selectBranch left right branch :=
    List.mem_of_getElem? selected
  cases branch with
  | left => exact permittedLeft inv member
  | right => exact permittedRight inv member

theorem interleaving_advance_preserves (cfg : Config P A D)
    (allowed : Step P A D → Prop) (invariant : State P A D → Prop)
    (localRule : LocalPreserves cfg allowed invariant) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (entry : Interleaving.Machine P A D) (branch : BranchId)
    (initial : invariant entry.world.state) :
    invariant (Interleaving.advance cfg boundaries left right entry branch).world.state := by
  have sound := Interleaving.advance_sound cfg boundaries left right entry branch
  generalize he : Interleaving.advance cfg boundaries left right entry branch = post at sound ⊢
  cases sound with
  | halted => simpa [Interleaving.skip_world] using initial
  | exhausted => simpa [Interleaving.skip_world] using initial
  | refused => simpa [Interleaving.refuse_world] using initial
  | accepted inv result active selected executed =>
    exact localRule _ _ _ _ _ _
      (selected_invocation_allowed allowed left right permittedLeft permittedRight _ _ inv selected)
      initial executed

theorem interleaving_continueRun_preserves (cfg : Config P A D)
    (allowed : Step P A D → Prop) (invariant : State P A D → Prop)
    (localRule : LocalPreserves cfg allowed invariant) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (entry : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (initial : invariant entry.world.state) :
    invariant (Interleaving.continueRun cfg boundaries left right entry schedule).world.state := by
  induction schedule generalizing entry with
  | nil => exact initial
  | cons branch schedule ih =>
    exact ih (Interleaving.advance cfg boundaries left right entry branch)
      (interleaving_advance_preserves cfg allowed invariant localRule boundaries left right
        permittedLeft permittedRight entry branch initial)

theorem interleaving_prefix_preserves (cfg : Config P A D)
    (allowed : Step P A D → Prop) (invariant : State P A D → Prop)
    (localRule : LocalPreserves cfg allowed invariant) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (initial : World P A D) (schedule : Interleaving.Schedule)
    (initialized : invariant initial.state) (count : Nat) :
    invariant (Interleaving.runPrefix cfg boundaries initial left right
      (schedule.take count)).world.state :=
  interleaving_continueRun_preserves cfg allowed invariant localRule boundaries left right
    permittedLeft permittedRight (Interleaving.start initial) (schedule.take count) initialized

theorem sequential_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : balanceSum region entry.world.state = value entry.world.state) :
    balanceSum region (Composition.continueRun cfg boundaries entry steps).world.state =
      value (Composition.continueRun cfg boundaries entry steps).world.state :=
  continueRun_preserves cfg allowed _
    (region_localPreserves cfg allowed region cells support value supported obligations)
    boundaries entry steps permitted initial

theorem interleaving_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (entry : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (initial : balanceSum region entry.world.state = value entry.world.state) :
    balanceSum region
        (Interleaving.continueRun cfg boundaries left right entry schedule).world.state =
      value (Interleaving.continueRun cfg boundaries left right entry schedule).world.state :=
  interleaving_continueRun_preserves cfg allowed _
    (region_localPreserves cfg allowed region cells support value supported obligations)
    boundaries left right permittedLeft permittedRight entry schedule initial

/-- A fixed reference quantity is a specialization of supported value preservation. -/
theorem sequential_ghost_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D)) (q : ℚ)
    (obligations : RegionObligations cfg allowed region cells ∅ (fun _ ↦ q))
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : balanceSum region entry.world.state = q) :
    balanceSum region (Composition.continueRun cfg boundaries entry steps).world.state = q :=
  sequential_total_preserved cfg allowed region cells ∅ (fun _ ↦ q)
    (valueSupports_const ∅ q) obligations boundaries entry steps permitted initial

theorem group_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D)
    (permitted : ∀ step ∈ Metatheory.flatten group, allowed step)
    (initial : balanceSum region entry.world.state = value entry.world.state) :
    balanceSum region (Metatheory.runGroup cfg boundaries entry group).world.state =
      value (Metatheory.runGroup cfg boundaries entry group).world.state :=
  group_preserves cfg allowed _
    (region_localPreserves cfg allowed region cells support value supported obligations)
    boundaries entry group permitted initial

theorem binding_localPreserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) (obligations : BindingObligations cfg allowed edges) :
    LocalPreserves cfg allowed (Agrees cfg.catalog edges) := by
  intro boundary index history step pre result ha hi he
  exact step_binding_preserved edges hi he
    (obligations boundary index history step pre result ha hi he)

theorem sequential_bindings_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) (obligations : BindingObligations cfg allowed edges)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : Agrees cfg.catalog edges entry.world.state) :
    Agrees cfg.catalog edges (Composition.continueRun cfg boundaries entry steps).world.state :=
  continueRun_preserves cfg allowed _ (binding_localPreserves cfg allowed edges obligations)
    boundaries entry steps permitted initial

theorem sequential_prefix_bindings_preserved (cfg : Config P A D)
    (allowed : Step P A D → Prop) (edges : List Binding)
    (obligations : BindingObligations cfg allowed edges)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : Agrees cfg.catalog edges entry.world.state) (count : Nat) :
    Agrees cfg.catalog edges
      (Composition.continueRun cfg boundaries entry (steps.take count)).world.state :=
  sequential_prefix_preserves cfg allowed _ (binding_localPreserves cfg allowed edges obligations)
    boundaries entry steps permitted initial count

theorem group_bindings_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) (obligations : BindingObligations cfg allowed edges)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D)
    (permitted : ∀ step ∈ Metatheory.flatten group, allowed step)
    (initial : Agrees cfg.catalog edges entry.world.state) :
    Agrees cfg.catalog edges (Metatheory.runGroup cfg boundaries entry group).world.state :=
  group_preserves cfg allowed _ (binding_localPreserves cfg allowed edges obligations)
    boundaries entry group permitted initial

theorem interleaving_bindings_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) (obligations : BindingObligations cfg allowed edges)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (entry : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (initial : Agrees cfg.catalog edges entry.world.state) :
    Agrees cfg.catalog edges
      (Interleaving.continueRun cfg boundaries left right entry schedule).world.state :=
  interleaving_continueRun_preserves cfg allowed _
    (binding_localPreserves cfg allowed edges obligations)
    boundaries left right permittedLeft permittedRight entry schedule initial

theorem interleaving_prefix_bindings_preserved (cfg : Config P A D)
    (allowed : Step P A D → Prop) (edges : List Binding)
    (obligations : BindingObligations cfg allowed edges)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (initial : World P A D) (schedule : Interleaving.Schedule)
    (initialized : Agrees cfg.catalog edges initial.state) (count : Nat) :
    Agrees cfg.catalog edges
      (Interleaving.runPrefix cfg boundaries initial left right
        (schedule.take count)).world.state :=
  interleaving_prefix_preserves cfg allowed _
    (binding_localPreserves cfg allowed edges obligations)
    boundaries left right permittedLeft permittedRight initial schedule initialized count

end DefiKernel.Interface
