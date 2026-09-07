import DefiKernel.Typed.Examples

open DefiKernel.Typed.Examples

-- Alice starts with 10 USD; Bob starts with 0.
#eval (run (transferRequest 3)).map fun result =>
  (result.state.balance (.main, .alice, .usd),
   result.state.balance (.main, .bob, .usd))

-- A separate request from the same initial state exceeds Alice's balance.
#eval (run (transferRequest 11)).map fun result =>
  result.state.balance (.main, .alice, .usd)
