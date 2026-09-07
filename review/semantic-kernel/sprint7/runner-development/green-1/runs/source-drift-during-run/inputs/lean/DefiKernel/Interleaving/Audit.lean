import DefiKernel.Interleaving.RunnerInput

namespace DefiKernel.Interleaving

open Lean Elab Command in
run_cmd do
  liftIO <| IO.FS.writeFile "/tmp/sprint7-runner-green-1/fixture-repo/lean/DefiKernel/Interleaving/RunnerInput.lean" "-- drifted during actual Lean audit\n"
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Interleaving runtime comparisons failed: {failures}"

end DefiKernel.Interleaving
