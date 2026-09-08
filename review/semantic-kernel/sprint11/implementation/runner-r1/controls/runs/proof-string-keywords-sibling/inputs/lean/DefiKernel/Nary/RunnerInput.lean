import DefiKernel.Interleaving.RunnerDependency

namespace DefiKernel.Nary

example : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS
theorem runtimeWords : "def macro initialize" = "def macro initialize" := rfl

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Nary
