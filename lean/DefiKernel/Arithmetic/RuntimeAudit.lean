import DefiKernel.Arithmetic.Tests

namespace DefiKernel.Arithmetic.RuntimeAudit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
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
