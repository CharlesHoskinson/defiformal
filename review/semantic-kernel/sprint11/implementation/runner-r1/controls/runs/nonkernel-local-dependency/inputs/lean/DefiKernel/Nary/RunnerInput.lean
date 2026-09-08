import SharedFixture.RunnerDependency

namespace DefiKernel.Nary

example : SharedFixture.runnerDependency = 4 := SharedFixture.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Nary
