import Aesop

set_option maxHeartbeats 20000

-- This unrelated elementary proposition selects the automatic procedure before targets.
theorem unrelated_procedure_example (P Q : Prop) (h : P ∧ Q) : Q ∧ P := by
  aesop

#print axioms unrelated_procedure_example
