import DefiKernel.Composition.RunnerInput

namespace DefiKernel.Composition

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := []
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Composition runtime comparisons failed: {failures}"

end DefiKernel.Composition
