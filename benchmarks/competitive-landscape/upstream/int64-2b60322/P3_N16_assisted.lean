import SequenceHelper
namespace Benchmark
 theorem established (b : Ledger) (ts : List Instruction) : P3 16 b ts := by
  intro _ _ h
  exact sequenceLaw b ts h
#print axioms established
end Benchmark
