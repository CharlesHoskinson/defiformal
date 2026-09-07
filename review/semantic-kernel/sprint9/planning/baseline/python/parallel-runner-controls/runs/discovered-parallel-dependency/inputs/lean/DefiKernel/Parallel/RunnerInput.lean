import DefiKernel.Parallel.SplitComputation

namespace DefiKernel.Parallel

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4 + (splitLimit - 4)
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Parallel
