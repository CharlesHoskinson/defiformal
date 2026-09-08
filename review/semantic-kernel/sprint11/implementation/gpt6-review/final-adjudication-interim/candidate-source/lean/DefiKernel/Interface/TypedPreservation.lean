import DefiKernel.Interface.Preservation

/-! Dimensioned total contracts retain region well-formedness explicitly. The more general
accounting equalities remain applicable to arbitrary finite cell sets. -/
namespace DefiKernel.Interface
open Typed Composition Parallel

variable {P A D : Type}

def TypedTotalContract (region : Region P A D) (value : State P A D → ℚ)
    (state : State P A D) : Prop :=
  region.WellFormed ∧ balanceSum region state = value state

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem step_typed_total_preserved (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value) {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {step : Step P A D} {pre : World P A D} {result : StepResult P A D}
    (initial : TypedTotalContract region value pre.state)
    (executed : executeStep cfg boundary index history step pre = .ok result)
    (within : WritesWithin cells result.receipt) (neutral : NeutralOn region cells result.receipt)
    (separate : ∀ c ∈ result.receipt.writes, c ∉ support) :
    TypedTotalContract region value result.world.state :=
  ⟨initial.1, step_total_preserved region cells support value supported initial.2
    executed within neutral separate⟩

theorem typed_total_localPreserves (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value) :
    LocalPreserves cfg allowed (TypedTotalContract region value) := by
  intro boundary index history step pre result ha hi he
  exact ⟨hi.1, region_localPreserves cfg allowed region cells support value supported obligations
    boundary index history step pre result ha hi.2 he⟩

theorem sequential_typed_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : TypedTotalContract region value entry.world.state) :
    TypedTotalContract region value
      (Composition.continueRun cfg boundaries entry steps).world.state :=
  continueRun_preserves cfg allowed _
    (typed_total_localPreserves cfg allowed region cells support value supported obligations)
    boundaries entry steps permitted initial

theorem sequential_prefix_typed_total_preserved (cfg : Config P A D)
    (allowed : Step P A D → Prop) (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : TypedTotalContract region value entry.world.state) (count : Nat) :
    TypedTotalContract region value
      (Composition.continueRun cfg boundaries entry (steps.take count)).world.state :=
  sequential_prefix_preserves cfg allowed _
    (typed_total_localPreserves cfg allowed region cells support value supported obligations)
    boundaries entry steps permitted initial count

theorem group_typed_total_preserved (cfg : Config P A D) (allowed : Step P A D → Prop)
    (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D)
    (permitted : ∀ step ∈ Metatheory.flatten group, allowed step)
    (initial : TypedTotalContract region value entry.world.state) :
    TypedTotalContract region value (Metatheory.runGroup cfg boundaries entry group).world.state :=
  group_preserves cfg allowed _
    (typed_total_localPreserves cfg allowed region cells support value supported obligations)
    boundaries entry group permitted initial

theorem interleaving_typed_total_preserved (cfg : Config P A D)
    (allowed : Step P A D → Prop) (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (entry : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (initial : TypedTotalContract region value entry.world.state) :
    TypedTotalContract region value
      (Interleaving.continueRun cfg boundaries left right entry schedule).world.state :=
  interleaving_continueRun_preserves cfg allowed _
    (typed_total_localPreserves cfg allowed region cells support value supported obligations)
    boundaries left right permittedLeft permittedRight entry schedule initial

theorem interleaving_prefix_typed_total_preserved (cfg : Config P A D)
    (allowed : Step P A D → Prop) (region : Region P A D) (cells : Finset (Cell P A D))
    (support : Set (Cell P A D)) (value : State P A D → ℚ)
    (supported : ValueSupports support value)
    (obligations : RegionObligations cfg allowed region cells support value)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (initial : World P A D) (schedule : Interleaving.Schedule)
    (initialized : TypedTotalContract region value initial.state) (count : Nat) :
    TypedTotalContract region value
      (Interleaving.runPrefix cfg boundaries initial left right
        (schedule.take count)).world.state :=
  interleaving_prefix_preserves cfg allowed _
    (typed_total_localPreserves cfg allowed region cells support value supported obligations)
    boundaries left right permittedLeft permittedRight initial schedule initialized count

end DefiKernel.Interface
