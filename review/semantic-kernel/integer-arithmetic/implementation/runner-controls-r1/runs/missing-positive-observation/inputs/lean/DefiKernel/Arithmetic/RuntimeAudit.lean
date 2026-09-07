import DefiKernel.Arithmetic.RunnerInput

namespace DefiKernel.Arithmetic

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := [("runner_sensitivity", !runnerAllows 5)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Arithmetic runtime comparisons failed: {failures}"

end DefiKernel.Arithmetic
