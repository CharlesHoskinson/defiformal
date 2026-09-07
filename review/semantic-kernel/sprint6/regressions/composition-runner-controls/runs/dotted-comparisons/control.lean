import Mathlib.Data.Nat.Basic

namespace DefiKernel.Typed
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Typed


namespace DefiKernel.Composition

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control


end DefiKernel.Composition


namespace DefiKernel.Composition

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner.positive", runnerAllows 0), ("runner.sensitivity", !runnerAllows 5)]
    else [("runner.positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Composition runtime comparisons failed: {failures}"

end DefiKernel.Composition
