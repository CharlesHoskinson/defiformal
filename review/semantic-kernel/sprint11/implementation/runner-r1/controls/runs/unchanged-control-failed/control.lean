import Mathlib.Data.Nat.Basic

namespace DefiKernel.Interleaving
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Interleaving


namespace DefiKernel.Nary

example : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control


end DefiKernel.Nary


namespace DefiKernel.Nary

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := [("runner_positive", true), ("runner_sensitivity", false)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Nary runtime comparisons failed: {failures}"

end DefiKernel.Nary
