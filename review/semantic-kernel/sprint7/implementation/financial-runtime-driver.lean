import DefiKernel.Interleaving.Tests
open DefiKernel.Interleaving
#eval do
  let checks := Tests.checks
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
  IO.println s!"TOTAL {checks.length}"
  if checks.isEmpty || !(checks.map Prod.fst).Nodup || !(checks.all Prod.snd) then
    throw (IO.userError "financial runtime inventory failed")
