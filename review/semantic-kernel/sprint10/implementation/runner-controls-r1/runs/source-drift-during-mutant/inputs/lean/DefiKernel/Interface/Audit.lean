import DefiKernel.Interface.RunnerInput

namespace DefiKernel.Interface

open Lean Elab Command in
run_cmd do
  if runnerAllows 5 then
    liftIO <| IO.FS.writeFile "/tmp/sprint10-official-controls-r1/run/fixture-repo/lean/DefiKernel/Interface/RunnerInput.lean" "-- drifted during actual Lean audit\n"
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Interface runtime comparisons failed: {failures}"

end DefiKernel.Interface
