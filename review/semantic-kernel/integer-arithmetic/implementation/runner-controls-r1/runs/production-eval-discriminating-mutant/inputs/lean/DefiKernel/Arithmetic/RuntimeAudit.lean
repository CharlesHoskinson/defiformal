import DefiKernel.Arithmetic.RunnerInput
namespace DefiKernel.Arithmetic.RuntimeAudit
def main : IO Unit := do
  let checks : List (String × Bool) := if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]
  if checks.isEmpty then throw (IO.userError "Arithmetic runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Arithmetic runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Arithmetic runtime comparisons failed: {failures.length}")
#eval main

-- BEGIN PROOFS

end DefiKernel.Arithmetic.RuntimeAudit
