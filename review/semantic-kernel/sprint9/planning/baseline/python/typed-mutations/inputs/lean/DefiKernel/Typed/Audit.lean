import DefiKernel.Typed.ExprTests
import DefiKernel.Typed.AuthorityTests
import DefiKernel.Typed.TransitionTests
import DefiKernel.Typed.Acceptance

/-! One named, nonempty runtime inventory for the typed kernel and reference libraries.
Source mutation replay uses this same driver with proof-only suffixes removed from
temporary dependency copies. Accepted sources retain all proofs. -/
namespace DefiKernel.Typed

def runtimeChecks : List (String × Bool) :=
  ExprTests.checks ++ AuthorityTests.checks ++ TransitionTests.checks ++ Acceptance.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty typed runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate typed runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

end DefiKernel.Typed
