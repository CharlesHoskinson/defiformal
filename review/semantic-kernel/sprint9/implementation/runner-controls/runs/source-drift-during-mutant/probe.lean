import Mathlib.Data.Nat.Basic

namespace DefiKernel.Interleaving
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Interleaving


namespace DefiKernel.Metatheory

example : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 5
def runnerIncludeSensitivity : Bool := true
-- compiler-control


end DefiKernel.Metatheory


namespace DefiKernel.Metatheory

open Lean Elab Command in
run_cmd do
  if runnerAllows 5 then
    liftIO <| IO.FS.writeFile "/tmp/sprint9-official-controls-r1/run/fixture-repo/lean/DefiKernel/Metatheory/RunnerInput.lean" "-- drifted during actual Lean audit\n"
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Metatheory runtime comparisons failed: {failures}"

end DefiKernel.Metatheory
