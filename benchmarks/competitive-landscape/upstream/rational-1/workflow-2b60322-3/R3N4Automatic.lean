import ComposeModel
set_option maxHeartbeats 20000
namespace RationalComposeN4
theorem canonical : RationalWorkflow.ComposeCanonical false 4 := by aesop
#print axioms canonical
end RationalComposeN4
