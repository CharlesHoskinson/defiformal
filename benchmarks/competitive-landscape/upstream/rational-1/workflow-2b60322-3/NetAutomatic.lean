import NetModel

set_option maxHeartbeats 20000

namespace RationalWorkflow.Net

-- Frozen procedure selected on the unrelated procedure-selection example.
theorem canonical : Canonical := by
  aesop

#print axioms canonical

end RationalWorkflow.Net
