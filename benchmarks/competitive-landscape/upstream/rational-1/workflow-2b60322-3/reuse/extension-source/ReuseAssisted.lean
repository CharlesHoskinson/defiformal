import R3N4Assisted
import ReuseModel
namespace RationalReuse
-- The checked generic theorem is imported from the frozen R3 foundation.
-- This applies the same theorem to the second vault without copying its proof.
theorem canonical : Canonical := RationalWorkflow.generic_compose true 4
#print axioms canonical
#print canonical
end RationalReuse
