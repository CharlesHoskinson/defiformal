import DefiKernel.Parallel.CompatibilityTests
import DefiKernel.Parallel.ObservationTests
import DefiKernel.Parallel.ExecutionTests
import DefiKernel.Parallel.Tests

/-! Complete named runtime inventory. Source mutation projections execute this same driver. -/
namespace DefiKernel.Parallel

def runtimeChecks : List (String × Bool) :=
  CompatibilityTests.checks ++ ObservationTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty parallel runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate parallel runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Parallel runtime comparisons failed: {failed}")

end DefiKernel.Parallel
