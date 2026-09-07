import DefiKernel.Composition.Sequence

/-! Branch observations retain every request, receipt, output, and refusal field.
Raw event worlds belong to execution evidence and are deliberately not equated across orders. -/
namespace DefiKernel.Parallel
open Typed Composition

-- These computational equality instances do not alter the existing execution definitions.
deriving instance DecidableEq for Composition.InputSource
deriving instance DecidableEq for Composition.Invocation
deriving instance DecidableEq for Composition.Step
deriving instance DecidableEq for Typed.Request
deriving instance DecidableEq for Typed.Evaluated
deriving instance DecidableEq for Composition.Receipt
deriving instance DecidableEq for Composition.OutputObservation
deriving instance DecidableEq for Composition.LocatedFailure

structure EventObservation (P A D : Type) where
  index : Nat
  step : Step P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

structure BranchObservation (P A D : Type) where
  events : List (EventObservation P A D)
  outputs : List (OutputObservation A)
  nextIndex : Nat
  failure : Option (LocatedFailure P A D)
  deriving DecidableEq

def observeEvent {P A D : Type} (event : Event P A D) : EventObservation P A D :=
  ⟨event.index, event.step, event.result.receipt, event.result.outputs⟩

def observeBranch {P A D : Type} (cursor : Cursor P A D) : BranchObservation P A D :=
  ⟨cursor.events.map observeEvent, cursor.outputs, cursor.nextIndex, cursor.failure⟩

-- BEGIN PROOFS

/-- Equality of canonical branch observations includes the exact failure location and step. -/
theorem observeBranch_failure {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.failure = right.failure :=
  congrArg BranchObservation.failure h

/-- Histories are compared as ordered, typed snapshots, not as an unqualified value multiset. -/
theorem observeBranch_outputs {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.outputs = right.outputs :=
  congrArg BranchObservation.outputs h

end DefiKernel.Parallel
