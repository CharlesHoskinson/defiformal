import DefiKernel.Interface.Tests

namespace DefiKernel.Interface.Audit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Interface runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Interface runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Interface runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Interface.Audit
