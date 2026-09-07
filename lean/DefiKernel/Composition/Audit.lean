import DefiKernel.Composition.InterfaceTests
import DefiKernel.Composition.ExecutionTests
import DefiKernel.Composition.Tests

/-! One named inventory for interface, adapter and complete composed workflow comparisons.
Mutation projections execute this driver over freshly captured dependency sources. -/
namespace DefiKernel.Composition

def runtimeChecks : List (String × Bool) :=
  InterfaceTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty composition runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate composition runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Composition runtime comparisons failed: {failed}")

end DefiKernel.Composition
