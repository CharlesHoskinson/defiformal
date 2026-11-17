import NativeHelper
namespace Benchmark
theorem established (x y d : Word) : P2 x y d := by
  intro h
  rcases h with ⟨hx,hxM,hy,hyM,hd,hdM,hxd⟩
  have hsum : (add x d).value = x.value + d.value := add_value x d hxd
  have hden : 0 < x.value + d.value := by omega
  have hqNat : y.value * d.value / (x.value + d.value) < y.value := by
    apply (Nat.div_lt_iff_lt_mul hden).2
    nlinarith
  have hq : (quote x y d).value = y.value * d.value / (x.value + d.value) := by
    unfold quote
    rw [hsum]
    exact floor_value y d _ hden (lt_trans hqNat y.bound)
  have hqLt : (quote x y d).value < y.value := by omega
  have hsub : (sub y (quote x y d)).value = y.value - (quote x y d).value :=
    sub_value y (quote x y d) (Nat.le_of_lt hqLt)
  have hdefined : 0 < (sub y (quote x y d)).value := by rw [hsub]; omega
  have hfloor : (x.value+d.value) * (quote x y d).value ≤ y.value*d.value := by
    rw [hq]
    simpa [Nat.mul_comm] using Nat.div_mul_le_self (y.value*d.value) (x.value+d.value)
  have heq := congrArg (fun z => (x.value+d.value)*z) (Nat.sub_add_cancel (Nat.le_of_lt hqLt))
  change x.value*y.value ≤ (add x d).value*(sub y (quote x y d)).value
  rw [hsum,hsub]
  nlinarith
#print axioms established
end Benchmark
