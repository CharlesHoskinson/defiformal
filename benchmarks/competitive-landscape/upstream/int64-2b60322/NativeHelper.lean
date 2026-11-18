import Model
namespace Benchmark
theorem add_value (a b : Word) (h : a.value + b.value ≤ M) :
    (add a b).value = a.value + b.value := by
  have bound : a.value + b.value < 2^64 := by unfold M at h; omega
  let q : Word := ⟨a.value + b.value, bound⟩
  have success : DefiKernel.Arithmetic.Operations.add a b = .ok q :=
    (DefiKernel.Arithmetic.Operations.add_ok_iff a b q).mpr rfl
  simp only [add, success, valueOrZero, q]
theorem sub_value (a b : Word) (h : b.value ≤ a.value) :
    (sub a b).value = a.value - b.value := by
  let q : Word := ⟨a.value - b.value, lt_of_le_of_lt (Nat.sub_le _ _) a.bound⟩
  have success : DefiKernel.Arithmetic.Operations.sub a b = .ok q :=
    (DefiKernel.Arithmetic.Operations.sub_ok_iff a b q).mpr ⟨h, rfl⟩
  simp only [sub, success, valueOrZero, q]
theorem floor_value (a b : Word) (d : Nat) (hd : 0 < d)
    (hb : a.value * b.value / d < 2^64) :
    (valueOrZero (DefiKernel.Arithmetic.Rounding.mulDiv .down a b d)).value =
      a.value * b.value / d := by
  let q : Word := ⟨a.value * b.value / d, hb⟩
  have success : DefiKernel.Arithmetic.Rounding.mulDiv .down a b d = .ok q := by
    rw [DefiKernel.Arithmetic.Rounding.mulDiv_down_ok_iff]
    exact ⟨hd, (DefiKernel.Arithmetic.Rounding.floor_characterization _ d _ hd).mp rfl⟩
  simp only [success, valueOrZero, q]
end Benchmark
