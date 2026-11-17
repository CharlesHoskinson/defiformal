import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases
import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
macro "benchmark_auto" : tactic => `(tactic| omega)
