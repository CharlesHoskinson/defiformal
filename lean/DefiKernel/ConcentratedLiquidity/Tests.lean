import DefiKernel.ConcentratedLiquidity.Examples

namespace DefiKernel.ConcentratedLiquidity.Tests
open Examples

def runtimeChecks : List (String × Bool) :=
  actual.map fun ⟨name, got⟩ =>
    (name, match expected.lookup name with
      | some want => decide (got = want)
      | none => false)

-- BEGIN PROOFS

theorem expected_unique : (expected.map Prod.fst).Nodup := by
  decide

theorem actual_unique : (actual.map Prod.fst).Nodup := by
  decide

theorem expected_keys_eq_actual :
    expected.map Prod.fst = actual.map Prod.fst := by
  decide

end DefiKernel.ConcentratedLiquidity.Tests
