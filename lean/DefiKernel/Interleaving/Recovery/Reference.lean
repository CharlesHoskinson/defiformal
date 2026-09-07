import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Commutation

/-! Isolated sequential prefix references used by shared-state recovery. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def isolated (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) : Cursor P A D :=
  Composition.run cfg boundary initial ((branch.take n).map Step.invoke)

-- BEGIN PROOFS

theorem isolated_zero (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch 0 = startCursor cfg initial := rfl

theorem isolated_step (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) (inv : Invocation P A D)
    (h : branch[n]? = some inv) :
    isolated cfg boundary initial branch (n + 1) =
      Composition.advance cfg boundary (isolated cfg boundary initial branch n) (.invoke inv) := by
  have ht : branch.take (n + 1) = branch.take n ++ [inv] := by
    rw [List.take_add_one]
    simp [h]
  simp only [isolated, ht, List.map_append, List.map_cons, List.map_nil, Composition.run]
  rw [Composition.continueRun_append]
  rfl

theorem isolated_exhausted (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : branch[n]? = none) :
    isolated cfg boundary initial branch (n + 1) = isolated cfg boundary initial branch n := by
  simp only [isolated, List.take_add_one, h, Option.toList_none, List.append_nil]

theorem continue_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : (Composition.continueRun cfg boundary cursor steps).failure = none) :
    (Composition.continueRun cfg boundary cursor steps).nextIndex =
      cursor.nextIndex + steps.length := by
  induction steps generalizing cursor with
  | nil => simp [Composition.continueRun]
  | cons step tail ih =>
    cases hf : cursor.failure with
    | some failure => simp [Composition.continueRun_failed _ _ _ _ hf, hf] at h
    | none =>
      cases he : executeStep cfg (boundary cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : Composition.advance cfg boundary cursor step =
            { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ } := by
          simp [Composition.advance, hf, he]
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).failure = none at h
        rw [ha, Composition.continueRun_failed _ _ _ _ rfl] at h
        contradiction
      | ok result =>
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).nextIndex = _
        rw [ih _ h]
        simp [Composition.advance, hf, he, Nat.add_assoc, Nat.add_comm]

theorem isolated_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : (isolated cfg boundary initial branch n).failure = none) :
    (isolated cfg boundary initial branch n).nextIndex = min n branch.length := by
  simpa [isolated, Composition.run, startCursor] using
    continue_active_index cfg boundary (startCursor cfg initial)
      ((branch.take n).map Step.invoke) h

theorem isolated_full (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch branch.length = runBranch cfg boundary initial branch := by
  simp [isolated, runBranch]

end DefiKernel.Interleaving.Recovery
