import DefiKernel.Nary.Tests

namespace DefiKernel.Nary.Audit

def runtimeComparisons : List (String × Bool) := Tests.runtimeComparisons

def main : IO Unit := do
  let checks := runtimeComparisons
  if checks.isEmpty then
    throw (IO.userError "Nary runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Nary runtime comparison names are duplicated")
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Nary runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Nary.Audit
