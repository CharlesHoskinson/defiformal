import DefiKernel.Interleaving.ScheduleTests
import DefiKernel.Interleaving.Tests

/-! Complete named runtime inventory. These are finite development comparisons, separate from
the generic theorems and the imported axiom audit in Verify.lean. -/
namespace DefiKernel.Interleaving.Audit

def checks : List (String × Bool) := ScheduleTests.checks ++ Tests.checks

def main : IO Unit := do
  let names := checks.map Prod.fst
  if checks.isEmpty || names.eraseDups.length != names.length then
    throw (IO.userError "BLOCKED: empty or duplicate interleaving inventory")
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
  let failures := (checks.filter (fun row ↦ !row.2)).length
  if failures != 0 then
    throw (IO.userError s!"Interleaving runtime comparisons failed: {failures}")

#eval main

end DefiKernel.Interleaving.Audit
