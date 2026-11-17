import Examples
set_option synthInstance.maxSize 100000
set_option maxRecDepth 10000
namespace Benchmark
def missingDebit (b : Ledger) (t : Instruction) : Ledger := fun i =>
  if i = t.recipient then add (b i) t.amount else b i
def ceilingSwap (x y d : Word) : Word × Word :=
  (add x d, sub y (valueOrZero (DefiKernel.Arithmetic.Rounding.mulDiv .up y d (add x d).value)))
def badRun (j : Nat) (b : Ledger) : List Instruction → Ledger
  | [] => b
  | t :: ts => badRun (j+1) (if j = 1 then missingDebit b t else transfer b t) ts
def badValid (j : Nat) (b : Ledger) : List Instruction → Prop
  | [] => True
  | t :: ts => valid b t ∧ badValid (j+1) (if j = 1 then missingDebit b t else transfer b t) ts
theorem mutantWitness :
  total (missingDebit (balances 10 3 7) (instruction 0 1 4)) = 24 ∧
  (ceilingSwap (word 100) (word 100) (word 10)).1.value *
    (ceilingSwap (word 100) (word 100) (word 10)).2.value = 9900 ∧
  total (badRun 0 (balances 10 0 0) four) = 12 ∧
  total (badRun 0 (balances 10 0 0) sixteen) = 11 ∧
  badValid 0 (balances 10 0 0) four ∧ badValid 0 (balances 10 0 0) sixteen := by
    simp only [badValid,valid,domain,four,sixteen,Fin.forall_fin_succ,Fin.forall_fin_zero]
    decide
#print axioms mutantWitness
end Benchmark
