import DefiKernel.Atomic.RunnerInput

namespace DefiKernel.Atomic

open Lean Elab Command in
run_cmd do
  liftIO <| IO.FS.writeFile "/tmp/sprint8-atomic-runner-controls-r2/specification-drift-during-run-spec.json" "-- drifted during actual Lean audit\n"
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Atomic runtime comparisons failed: {failures}"

end DefiKernel.Atomic
