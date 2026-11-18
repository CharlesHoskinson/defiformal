import NativeHelper
namespace Benchmark
theorem transferLaw (b : Ledger) (t : Instruction) (h : valid b t) :
    total (transfer b t) = total b ∧
      ∀ i, i ≠ t.sender → i ≠ t.recipient → transfer b t i = b i := by
  rcases t with ⟨s,r,a⟩
  rcases h with ⟨hb,hne,hbal,hrec⟩
  have hsub := sub_value (b s) a hbal
  have hadd := add_value (b r) a hrec
  constructor
  · fin_cases s <;> fin_cases r <;> simp_all [transfer,total] <;> omega
  · intro i his hir
    simp [transfer,his,hir]
end Benchmark
