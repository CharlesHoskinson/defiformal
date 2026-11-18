import TransferHelper
namespace Benchmark
 theorem established (b : Ledger) (t : Instruction) : P1 b t := by
  exact transferLaw b t
#print axioms established
end Benchmark
