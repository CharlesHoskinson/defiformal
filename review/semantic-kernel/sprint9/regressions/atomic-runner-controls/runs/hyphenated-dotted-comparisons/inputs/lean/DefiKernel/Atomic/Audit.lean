import DefiKernel.Atomic.RunnerInput

namespace DefiKernel.Atomic

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner.permitted-sibling", runnerAllows 0), ("runner.expected-failure", !runnerAllows 5)]
    else [("runner.permitted-sibling", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Atomic runtime comparisons failed: {failures}"

end DefiKernel.Atomic
