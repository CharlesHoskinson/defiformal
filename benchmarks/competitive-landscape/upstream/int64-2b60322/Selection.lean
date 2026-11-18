import Procedure
namespace Selection
example (a b : Nat) (h : a ≤ b) : a + (b - a) = b := by benchmark_auto
end Selection
