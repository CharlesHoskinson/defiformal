import DefiKernel.Certificates.Tests

namespace DefiKernel.Certificates.Audit

def runtimeChecks : List (String × Bool) := Tests.runtimeChecks

def main : IO Unit := do
  let checks := runtimeChecks
  if checks.isEmpty then throw (IO.userError "Certificate runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Certificate runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Certificate runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Certificates.Audit
