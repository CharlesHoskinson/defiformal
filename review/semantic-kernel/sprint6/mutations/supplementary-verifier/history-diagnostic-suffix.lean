
#eval do
  match DefiKernel.Parallel.Tests.routeForeign with
  | .refused _ _ => IO.println "DIAGNOSTIC admission-refused"
  | .executed joined =>
    IO.println s!"DIAGNOSTIC peer-only left_failure={joined.left.failure.isSome} next_index={joined.left.nextIndex} alice_usd={joined.world.state.balance (.main, .alice, .usd)} bob_usd={joined.world.state.balance (.main, .bob, .usd)}"
