import DefiKernel.Interface.Preservation

/-! Transport of initialized local obligations through binding predicate algebra.
These results preserve query acceptance; they do not equate ordered failure diagnostics. -/
namespace DefiKernel.Interface
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem localPreserves_equiv (cfg : Config P A D) (allowed : Step P A D → Prop)
    (first second : State P A D → Prop) (equivalent : ∀ state, first state ↔ second state) :
    LocalPreserves cfg allowed first ↔ LocalPreserves cfg allowed second := by
  constructor
  · intro rule boundary index history step pre result ha hi he
    exact (equivalent result.world.state).mp
      (rule boundary index history step pre result ha ((equivalent pre.state).mpr hi) he)
  · intro rule boundary index history step pre result ha hi he
    exact (equivalent result.world.state).mpr
      (rule boundary index history step pre result ha ((equivalent pre.state).mp hi) he)

theorem localPreserves_and (cfg : Config P A D) (allowed : Step P A D → Prop)
    (first second : State P A D → Prop) (left : LocalPreserves cfg allowed first)
    (right : LocalPreserves cfg allowed second) :
    LocalPreserves cfg allowed (fun state ↦ first state ∧ second state) := by
  intro boundary index history step pre result ha hi he
  exact ⟨left boundary index history step pre result ha hi.1 he,
    right boundary index history step pre result ha hi.2 he⟩

theorem localBindings_append (cfg : Config P A D) (allowed : Step P A D → Prop)
    (left right : List Binding) (hl : LocalPreserves cfg allowed (Agrees cfg.catalog left))
    (hr : LocalPreserves cfg allowed (Agrees cfg.catalog right)) :
    LocalPreserves cfg allowed (Agrees cfg.catalog (left ++ right)) :=
  (localPreserves_equiv cfg allowed _ _ (agrees_append cfg.catalog left right)).mpr
    (localPreserves_and cfg allowed _ _ hl hr)

theorem localBindings_reverse (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edges : List Binding) :
    LocalPreserves cfg allowed (Agrees cfg.catalog (edges.map reverseBinding)) ↔
      LocalPreserves cfg allowed (Agrees cfg.catalog edges) :=
  localPreserves_equiv cfg allowed _ _ (agrees_reverse_edges cfg.catalog edges)

theorem localBindings_duplicate (cfg : Config P A D) (allowed : Step P A D → Prop)
    (edge : Binding) (edges : List Binding) :
    LocalPreserves cfg allowed (Agrees cfg.catalog (edge :: edge :: edges)) ↔
      LocalPreserves cfg allowed (Agrees cfg.catalog (edge :: edges)) :=
  localPreserves_equiv cfg allowed _ _ (agrees_duplicate cfg.catalog edge edges)

theorem localBindings_perm (cfg : Config P A D) (allowed : Step P A D → Prop)
    (left right : List Binding) (permutation : left.Perm right) :
    LocalPreserves cfg allowed (Agrees cfg.catalog left) ↔
      LocalPreserves cfg allowed (Agrees cfg.catalog right) :=
  localPreserves_equiv cfg allowed _ _
    (fun state ↦ agrees_perm cfg.catalog left right state permutation)

theorem localBindings_assoc (cfg : Config P A D) (allowed : Step P A D → Prop)
    (first second third : List Binding) :
    LocalPreserves cfg allowed (Agrees cfg.catalog ((first ++ second) ++ third)) ↔
      LocalPreserves cfg allowed (Agrees cfg.catalog (first ++ (second ++ third))) :=
  localPreserves_equiv cfg allowed _ _ (agrees_assoc cfg.catalog first second third)

theorem localBindings_symClosure (cfg : Config P A D) (allowed : Step P A D → Prop)
    (left right : List Binding) (same : symClosure left = symClosure right) :
    LocalPreserves cfg allowed (Agrees cfg.catalog left) ↔
      LocalPreserves cfg allowed (Agrees cfg.catalog right) :=
  localPreserves_equiv cfg allowed _ _
    (fun state ↦ agrees_of_symClosure_eq cfg.catalog left right state same)

theorem sequential_prefix_query_transport (cfg : Config P A D)
    (allowed : Step P A D → Prop) (left right : List Binding)
    (equivalent : ∀ state, Agrees cfg.catalog left state ↔ Agrees cfg.catalog right state)
    (rule : LocalPreserves cfg allowed (Agrees cfg.catalog left))
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (steps : List (Step P A D)) (permitted : ∀ step ∈ steps, allowed step)
    (initial : bindingsHold cfg right entry.world.state = true) (count : Nat) :
    bindingsHold cfg right
      (Composition.continueRun cfg boundaries entry (steps.take count)).world.state = true := by
  obtain ⟨valid, initialized⟩ := (bindingsHold_iff _ _ _).mp initial
  exact (bindingsHold_iff _ _ _).mpr ⟨valid,
    sequential_prefix_preserves cfg allowed _
      ((localPreserves_equiv cfg allowed _ _ equivalent).mp rule)
      boundaries entry steps permitted initialized count⟩

theorem interleaving_prefix_query_transport (cfg : Config P A D)
    (allowed : Step P A D → Prop) (source target : List Binding)
    (equivalent : ∀ state, Agrees cfg.catalog source state ↔ Agrees cfg.catalog target state)
    (rule : LocalPreserves cfg allowed (Agrees cfg.catalog source))
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (permittedLeft : ∀ inv ∈ left, allowed (.invoke inv))
    (permittedRight : ∀ inv ∈ right, allowed (.invoke inv))
    (initial : World P A D) (schedule : Interleaving.Schedule)
    (initialized : bindingsHold cfg target initial.state = true) (count : Nat) :
    bindingsHold cfg target (Interleaving.runPrefix cfg boundaries initial left right
      (schedule.take count)).world.state = true := by
  obtain ⟨valid, agrees⟩ := (bindingsHold_iff _ _ _).mp initialized
  exact (bindingsHold_iff _ _ _).mpr ⟨valid,
    interleaving_prefix_preserves cfg allowed _
      ((localPreserves_equiv cfg allowed _ _ equivalent).mp rule)
      boundaries left right permittedLeft permittedRight initial schedule agrees count⟩

theorem group_query_transport (cfg : Config P A D) (allowed : Step P A D → Prop)
    (left right : List Binding)
    (equivalent : ∀ state, Agrees cfg.catalog left state ↔ Agrees cfg.catalog right state)
    (rule : LocalPreserves cfg allowed (Agrees cfg.catalog left))
    (boundaries : Nat → Boundary P A D) (entry : Cursor P A D)
    (group : Metatheory.SeqGroup P A D)
    (permitted : ∀ step ∈ Metatheory.flatten group, allowed step)
    (initial : bindingsHold cfg right entry.world.state = true) :
    bindingsHold cfg right (Metatheory.runGroup cfg boundaries entry group).world.state = true := by
  obtain ⟨valid, initialized⟩ := (bindingsHold_iff _ _ _).mp initial
  exact (bindingsHold_iff _ _ _).mpr ⟨valid,
    group_preserves cfg allowed _ ((localPreserves_equiv cfg allowed _ _ equivalent).mp rule)
      boundaries entry group permitted initialized⟩

end DefiKernel.Interface
