import Model
namespace Benchmark
 theorem established (b : Ledger) (ts : List Instruction) : P3 4 b ts := by benchmark_auto
#print axioms established
end Benchmark
