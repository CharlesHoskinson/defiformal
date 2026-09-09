import DefiKernel.Vault.Examples

namespace DefiKernel.Vault.Tests

def runtimeChecks : List (String × Bool) := Examples.runtimeChecks

-- BEGIN PROOFS

theorem runtimeChecks_named : (runtimeChecks.map Prod.fst).Nodup := by
  decide

end DefiKernel.Vault.Tests
