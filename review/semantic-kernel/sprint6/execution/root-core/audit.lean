import DefiKernel.Parallel.Commutation
import DefiKernel.Parallel.ExecutionTests
import DefiKernel.Parallel.ObservationTests
open DefiKernel.Parallel
#eval do
  let checks := ObservationTests.checks ++ ExecutionTests.checks
  unless !checks.isEmpty && (checks.map Prod.fst).eraseDups.length == checks.length do
    throw (IO.userError "Invalid root runtime inventory")
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
  unless checks.all Prod.snd do throw (IO.userError "Root runtime comparisons failed")
