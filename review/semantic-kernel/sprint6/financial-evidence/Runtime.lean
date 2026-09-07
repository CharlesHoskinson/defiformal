import DefiKernel.Parallel.Tests
open DefiKernel.Parallel.Tests
#eval do
  if checks.isEmpty then throw (IO.userError "Empty financial inventory")
  if (checks.map Prod.fst).eraseDups.length != checks.length then
    throw (IO.userError "Duplicate financial check")
  let mut failed := 0
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
    unless passed do failed := failed + 1
  IO.println s!"Financial comparisons: {checks.length}; failures: {failed}"
  if failed != 0 then throw (IO.userError "Financial comparison failure")
