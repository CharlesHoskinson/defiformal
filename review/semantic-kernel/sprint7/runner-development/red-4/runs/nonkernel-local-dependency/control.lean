import SharedFixture.RunnerDependency


namespace DefiKernel.Interleaving

example : SharedFixture.runnerDependency = 4 := SharedFixture.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control


end DefiKernel.Interleaving


namespace DefiKernel.Interleaving

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Interleaving runtime comparisons failed: {failures}"

end DefiKernel.Interleaving
