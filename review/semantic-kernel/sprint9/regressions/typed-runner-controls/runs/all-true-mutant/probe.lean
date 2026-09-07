import Mathlib.Data.Nat.Basic


namespace DefiKernel.Typed

def runnerAllows (n : Nat) : Bool := n ≤ 3
def runnerIncludeSensitivity : Bool := true
-- compiler-control


end DefiKernel.Typed


namespace DefiKernel.Typed

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Typed runtime comparisons failed: {failures}"

end DefiKernel.Typed
