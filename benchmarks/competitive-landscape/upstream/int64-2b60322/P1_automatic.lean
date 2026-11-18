import Model
namespace Benchmark
 theorem established (b : Ledger) (t : Instruction) : P1 b t := by benchmark_auto
#print axioms established
end Benchmark
