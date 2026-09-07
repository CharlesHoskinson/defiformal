import DefiKernel.Parallel.RunnerDependency

namespace DefiKernel.Interleaving

example : DefiKernel.Parallel.runnerDependency = 4 := DefiKernel.Parallel.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS
def hiddenRuntime : Bool := true

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Interleaving
