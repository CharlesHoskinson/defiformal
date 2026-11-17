import SwapModel

namespace RationalSwap.Witnesses

def run (x y d : ℚ) : Result := swap (.exact x) (.exact y) (.exact d)

def checks : List (String × Bool) := [
  ("swap_fractional", decide (run (1/3) (7/5) (2/9) = .success (14/25) (5/9) (21/25))),
  ("swap_unbounded", let x : ℚ := 2^200; let y : ℚ := 3^140/7; let d : ℚ := 1/11;
    decide (run x y d = .success (y*d/(x+d)) (x+d) (y-y*d/(x+d)))),
  ("bad_number_priority", decide (swap (.exact (-1)) (.malformed "0.5") (.exact (-1)) = .refused .badNumber)),
  ("bad_reserve_priority", decide (run 0 1 (-1) = .refused .badReserve)),
  ("negative_reserve", decide (run 1 (-1) 1 = .refused .badReserve)),
  ("zero_amount", decide (run 1 1 0 = .refused .badAmount)),
  ("negative_amount", decide (run 1 1 (-1) = .refused .badAmount))
]

def main : IO Unit := do
  for (name, passed) in checks do
    if passed then IO.println s!"WITNESS {name} passed"
    else throw (IO.userError s!"WITNESS {name} FAILED")
  IO.println s!"FRACTIONAL {repr (run (1/3) (7/5) (2/9))}"

#eval main

end RationalSwap.Witnesses
