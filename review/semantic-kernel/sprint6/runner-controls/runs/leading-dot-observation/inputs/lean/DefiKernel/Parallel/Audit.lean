import DefiKernel.Parallel.RunnerInput

namespace DefiKernel.Parallel

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  liftIO <| IO.println ".runner_bad: true"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Parallel runtime comparisons failed: {failures}"

end DefiKernel.Parallel
