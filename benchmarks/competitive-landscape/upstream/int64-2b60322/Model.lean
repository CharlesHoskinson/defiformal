import Procedure
import Mathlib.Data.Fintype.Fin
namespace Benchmark
abbrev Word := DefiKernel.Arithmetic.Word 64
abbrev Account := Fin 3
abbrev Ledger := Account → Word
def M : Nat := 2^64 - 1
def zero : Word := ⟨0, by decide⟩
def valueOrZero : Except DefiKernel.Arithmetic.Failure Word → Word
  | .ok x => x
  | .error _ => zero
def add (a b : Word) : Word := valueOrZero (DefiKernel.Arithmetic.Operations.add a b)
def sub (a b : Word) : Word := valueOrZero (DefiKernel.Arithmetic.Operations.sub a b)
def domain (b : Ledger) : Prop := ∀ i, (b i).value ≤ M
structure Instruction where
  sender : Account
  recipient : Account
  amount : Word
def valid (b : Ledger) (t : Instruction) : Prop :=
  domain b ∧ t.sender ≠ t.recipient ∧ t.amount.value ≤ (b t.sender).value ∧
    (b t.recipient).value + t.amount.value ≤ M
def transfer (b : Ledger) (t : Instruction) : Ledger := fun i =>
  if i = t.sender then sub (b i) t.amount
  else if i = t.recipient then add (b i) t.amount else b i
def total (b : Ledger) : Nat := (b 0).value + (b 1).value + (b 2).value
def traceValid (b : Ledger) : List Instruction → Prop
  | [] => True
  | t :: ts => valid b t ∧ traceValid (transfer b t) ts
def run (b : Ledger) : List Instruction → Ledger
  | [] => b
  | t :: ts => run (transfer b t) ts
def P1 (b : Ledger) (t : Instruction) : Prop :=
  valid b t → total (transfer b t) = total b ∧
    ∀ i, i ≠ t.sender → i ≠ t.recipient → transfer b t i = b i
def P3 (n : Nat) (b : Ledger) (ts : List Instruction) : Prop :=
  domain b → ts.length = n → traceValid b ts → total (run b ts) = total b
def swapDomain (x y d : Word) : Prop :=
  0 < x.value ∧ x.value ≤ M ∧ 0 < y.value ∧ y.value ≤ M ∧
  0 < d.value ∧ d.value ≤ M ∧ x.value + d.value ≤ M
def quote (x y d : Word) : Word :=
  valueOrZero (DefiKernel.Arithmetic.Rounding.mulDiv .down y d (add x d).value)
def swap (x y d : Word) : Word × Word := (add x d, sub y (quote x y d))
def P2 (x y d : Word) : Prop := swapDomain x y d →
  x.value * y.value ≤ (swap x y d).1.value * (swap x y d).2.value
end Benchmark
