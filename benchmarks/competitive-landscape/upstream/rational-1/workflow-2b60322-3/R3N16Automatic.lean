import ComposeModel
set_option maxHeartbeats 20000
namespace RationalComposeN16
theorem canonical : RationalWorkflow.ComposeCanonical false 16 := by aesop
#print axioms canonical
end RationalComposeN16
