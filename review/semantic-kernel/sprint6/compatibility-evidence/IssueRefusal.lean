import DefiKernel.Parallel.CompatibilityTests
open DefiKernel DefiKernel.Typed.Examples DefiKernel.Parallel
example (grant : Typed.Grant Party Asset Domain) : Branch Party Asset Domain :=
  [Composition.Step.issue grant]
