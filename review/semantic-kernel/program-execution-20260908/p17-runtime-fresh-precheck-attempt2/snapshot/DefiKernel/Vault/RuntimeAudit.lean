import DefiKernel.Vault.Tests

namespace DefiKernel.Vault.RuntimeAudit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Vault runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Vault runtime comparison names are duplicated")
  IO.println s!"runtime_denominator={checks.length}"
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Vault runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Vault.RuntimeAudit
