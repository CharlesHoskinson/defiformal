import DefiKernel.Atomic.RunnerInput

namespace DefiKernel.Atomic

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := [("runner_positive", true), ("runner_sensitivity", false)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Atomic runtime comparisons failed: {failures}"

end DefiKernel.Atomic
