import Model
set_option synthInstance.maxSize 100000
set_option maxRecDepth 10000
namespace Benchmark
def word (n : Nat) : Word := valueOrZero (DefiKernel.Arithmetic.ofNat 64 n)
def balances (a b c : Nat) : Ledger := fun i => word (if i.val = 0 then a else if i.val = 1 then b else c)
def instruction (s r : Account) (a : Nat) : Instruction := ⟨s,r,word a⟩
def four : List Instruction := [instruction 0 1 3,instruction 1 2 2,instruction 2 0 1,instruction 0 2 4]
def sixteen : List Instruction := [instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1,instruction 0 1 1,instruction 1 0 1]
theorem examples_ok :
  valid (balances 10 3 7) (instruction 0 1 4) ∧
  total (transfer (balances 10 3 7) (instruction 0 1 4)) = 20 ∧
  (transfer (balances 10 3 7) (instruction 0 1 4) 0).value = 6 ∧
  (transfer (balances 10 3 7) (instruction 0 1 4) 1).value = 7 ∧
  (transfer (balances 10 3 7) (instruction 0 1 4) 2).value = 7 ∧
  valid (balances 10 3 7) (instruction 0 1 0) ∧
  total (transfer (balances 10 3 7) (instruction 0 1 0)) = 20 ∧
  valid (balances 10 3 7) (instruction 0 1 10) ∧
  (transfer (balances 10 3 7) (instruction 0 1 10) 0).value = 0 ∧
  (transfer (balances 10 3 7) (instruction 0 1 10) 1).value = 13 ∧
  valid (balances 1 (M-1) 0) (instruction 0 1 1) ∧
  total (transfer (balances 1 (M-1) 0) (instruction 0 1 1)) = M ∧
  valid (balances M (M-1) M) (instruction 0 1 1) ∧
  total (transfer (balances M (M-1) M) (instruction 0 1 1)) = 3*M-1 ∧
  ¬ valid (balances 10 3 7) (instruction 0 1 11) ∧
  ¬ valid (balances 10 3 7) (instruction 0 0 1) ∧
  ¬ valid (balances 1 M 0) (instruction 0 1 1) ∧
  DefiKernel.Arithmetic.ofNat 64 (M+1) = .error .inputOverflow ∧
  (quote (word 100) (word 100) (word 10)).value = 9 ∧
  (swap (word 100) (word 100) (word 10)).1.value * (swap (word 100) (word 100) (word 10)).2.value = 10010 ∧
  (quote (word 100) (word 1) (word 1)).value = 0 ∧
  (quote (word (M-1)) (word M) (word 1)).value = 1 ∧
  (swap (word (M-1)) (word M) (word 1)).1.value *
    (swap (word (M-1)) (word M) (word 1)).2.value = M*(M-1) ∧
  (quote (word 1) (word M) (word (M-1))).value = M-1 ∧
  (swap (word 1) (word M) (word (M-1))).1.value *
    (swap (word 1) (word M) (word (M-1))).2.value = M ∧
  ¬ swapDomain (word 0) (word 100) (word 1) ∧
  ¬ swapDomain (word 100) (word 0) (word 1) ∧
  ¬ swapDomain (word 100) (word 100) (word 0) ∧
  ¬ swapDomain (word M) (word 1) (word 1) ∧
  traceValid (balances 10 0 0) four ∧ four.length = 4 ∧
  (run (balances 10 0 0) four 0).value = 4 ∧
  (run (balances 10 0 0) four 1).value = 1 ∧
  (run (balances 10 0 0) four 2).value = 5 ∧
  traceValid (balances 10 0 0) sixteen ∧ sixteen.length = 16 ∧
  total (run (balances 10 0 0) sixteen) = 10 ∧
  (run (balances 10 0 0) sixteen 0).value = 10 ∧
  (run (balances 10 0 0) sixteen 1).value = 0 ∧
  (run (balances 10 0 0) sixteen 2).value = 0 := by
    simp only [traceValid,valid,domain,swapDomain,four,sixteen,Fin.forall_fin_succ,Fin.forall_fin_zero]
    decide
theorem representation_complete (n : Nat) (h : n ≤ M) : ∃ w : Word, w.value = n := by
  have hn : n < 2^64 := by unfold M at h; omega
  exact ⟨⟨n,hn⟩,rfl⟩
theorem representation_exclusions : (∀ w : Word, w.value ≤ M) ∧
    (¬ ∃ i : Account, i.val = 3) ∧ (∀ n : Nat, 0 ≤ n) := by
  constructor
  · intro w; have := w.bound; unfold M; omega
  · constructor
    · rintro ⟨i,hi⟩; have := i.isLt; omega
    · exact Nat.zero_le
#print axioms examples_ok
#print axioms representation_complete
#print axioms representation_exclusions
end Benchmark
