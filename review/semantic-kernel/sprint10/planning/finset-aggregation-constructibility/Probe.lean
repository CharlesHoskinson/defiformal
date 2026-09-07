import DefiKernel.Composition.Execution

-- Planning probe of existing mathlib functions, not Interface implementation.
#eval ({(6 : ℚ), 4} : Finset ℚ).sum id
#eval ({(6 : ℚ), 4} : Finset ℚ).fold max 0 id
#eval (∅ : Finset ℚ).sum id
#eval (∅ : Finset ℚ).fold max 0 id
