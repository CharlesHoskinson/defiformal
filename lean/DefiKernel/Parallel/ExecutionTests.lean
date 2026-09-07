import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.CompatibilityTests
import DefiKernel.Composition.Examples

namespace DefiKernel.Parallel.ExecutionTests
open Typed Typed.Examples Composition Composition.Examples

def boundaries (_ : BranchId) : Nat → Boundary Party Asset Domain := boundary

def emptyExpected : BranchObservation Party Asset Domain := ⟨[], [], 0, none⟩

def refusedUnchanged (config : Config Party Asset Domain)
    (left right : Branch Party Asset Domain) (reason : AdmissionFailure Party Asset Domain) : Bool :=
  match runParallel config CompatibilityTests.boundary CompatibilityTests.initial left right with
  | .refused actual world =>
    decide (actual = reason) && worldEq world CompatibilityTests.initial
  | .executed _ => false

def checks : List (String × Bool) := [
  ("parallel.empty", match runParallel cfg boundaries initialWorld [] [] with
    | .refused _ _ => false
    | .executed result =>
      worldEq result.world initialWorld &&
      decide (observeBranch result.left = emptyExpected ∧
        observeBranch result.right = emptyExpected)),
  ("parallel.empty.lr", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialLR cfg boundaries initialWorld [] [])),
  ("parallel.empty.rl", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialRL cfg boundaries initialWorld [] [])),
  ("parallel.refused.catalog-unchanged", refusedUnchanged
    { CompatibilityTests.cfg with catalog :=
      CompatibilityTests.cfg.catalog ++ CompatibilityTests.cfg.catalog } [] [] .configuration),
  ("parallel.refused.conflict-unchanged", refusedUnchanged CompatibilityTests.cfg
    [CompatibilityTests.left] [CompatibilityTests.left]
    (.conflict .writeWrite CompatibilityTests.aliceUSD)),
  ("parallel.refused.structural-unchanged", refusedUnchanged CompatibilityTests.cfg
    [{ CompatibilityTests.left with operation := ⟨999⟩ }] [CompatibilityTests.right]
    (.structural .left ⟨0, .interface .unknownOperation⟩))]

end DefiKernel.Parallel.ExecutionTests
