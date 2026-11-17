import Model
namespace Benchmark
 theorem established (x y d : Word) : P2 x y d := by benchmark_auto
#print axioms established
end Benchmark
