import DefiKernel.Parallel.CompatibilityTests
open DefiKernel.Parallel.CompatibilityTests
#eval do
  if checks.isEmpty then throw (IO.userError "Empty compatibility inventory")
  if (checks.map Prod.fst).eraseDups.length != checks.length then
    throw (IO.userError "Duplicate compatibility check")
  let mut failed := 0
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
    unless passed do failed := failed + 1
  IO.println s!"Compatibility comparisons: {checks.length}; failures: {failed}"
  if failed != 0 then throw (IO.userError "Compatibility comparison failure")
