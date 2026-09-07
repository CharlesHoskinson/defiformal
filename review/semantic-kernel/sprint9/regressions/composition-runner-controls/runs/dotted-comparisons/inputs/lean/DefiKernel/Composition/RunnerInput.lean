import DefiKernel.Typed.RunnerDependency

namespace DefiKernel.Composition

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Composition
