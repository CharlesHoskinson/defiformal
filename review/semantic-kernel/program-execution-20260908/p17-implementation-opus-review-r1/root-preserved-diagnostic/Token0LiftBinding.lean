/- OPUS REVIEW DIAGNOSTIC (not candidate source, not part of the frozen candidate).
   Question: does the frozen candidate state a binding between the Token0Bridge
   template quantities preQ/postQ and the lifted library input/result words? -/
import DefiKernel.ConcentratedLiquidity.Token0Bridge

open DefiKernel.ConcentratedLiquidity.Token0Bridge

-- (1) Is the binding TRUE (i.e. only a stated-ness gap, not a soundness defect)?
theorem diag_preQ_is_lift_of_input : preQ = (lift sqrtP_Q96).amount := by
  rw [lift_scale_one]; rfl

theorem diag_postQ_is_lift_of_library_result : postQ = (lift postWord).amount := by
  rw [lift_scale_one]; rfl

-- (2) Does the candidate itself contain such a theorem? Checked by name search below.
#print axioms diag_preQ_is_lift_of_input
#print axioms diag_postQ_is_lift_of_library_result
