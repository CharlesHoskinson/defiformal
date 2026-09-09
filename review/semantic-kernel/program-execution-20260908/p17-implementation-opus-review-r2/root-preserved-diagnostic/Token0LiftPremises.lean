/- Reviewer-authored R-2 round diagnostic (native Claude Opus P17 repair review).
   NOT candidate source. Grants the candidate no credit; it only checks that the
   R-1 binding is a real premise chain rather than an unused lemma. -/
import DefiKernel.ConcentratedLiquidity.Token0Bridge

set_option relaxedAutoImplicit false
set_option autoImplicit false

namespace ReviewOpusDiagR2
open DefiKernel.Typed
open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.Token0Bridge

/-- postQ is the scale-1 lift of the ACTUAL successful library word, for any
    word the library actually returns -- not a coincidental numeric literal. -/
theorem diag_postQ_is_lift_of_actual_library_result
    (w : U160) (h : libraryWord sqrtP_Q96 L1 amt1 true = .ok w) :
    postQ = (lift w).amount := by
  rw [library_ordinary_add] at h
  have hw : postWord = w := Except.ok.inj h
  rw [← hw]
  exact postQ_eq_lift_library_result

/-- preQ is the scale-1 lift of the ACTUAL library input sqrtPX96. -/
theorem diag_preQ_is_lift_of_library_input : preQ = (lift sqrtP_Q96).amount :=
  preQ_eq_lift_input

/-- The pre-register cell consumed by execute_ok_iff_quote holds the lifted input. -/
theorem diag_preRegister_cell_is_lifted_input :
    (preRegister preQ preQ_nonneg).balance (.quote, .quoteHolder, .quoteSqrtP)
      = (lift sqrtP_Q96).amount :=
  preRegister_binds_library_input

/-- A successful execute forces the observed post balance to be the lifted
    library result, with a nonzero ordinary-add effect. This routes through
    execute_ok_iff_quote, so the lift is load-bearing in the witness. -/
theorem diag_execute_forces_lifted_library_post
    (post : ExecutionResult Party Asset Domain)
    (h : execute (registry preQ postQ) store ctx env 0 req
      (preRegister preQ preQ_nonneg) = .ok post) :
    post.state.balance (.quote, .quoteHolder, .quoteSqrtP) = (lift postWord).amount
      ∧ postQ - preQ ≠ 0 := by
  obtain ⟨hbal, hne⟩ := ordinary_add_nonzero_debit post h
  refine ⟨?_, hne⟩
  rw [hbal, preRegister_binds_library_input, ← preQ_eq_lift_input]
  have : preQ + (postQ - preQ) = postQ := by ring
  rw [this, postQ_eq_lift_library_result]

/-- The e.Valid premise really is about the lifted quantities. -/
theorem diag_valid_premise_is_on_lifted_quantities :
    (evaluated (lift sqrtP_Q96).amount (lift postWord).amount).Valid
      store ctx req (preRegister preQ preQ_nonneg) := by
  rw [← preQ_eq_lift_input, ← postQ_eq_lift_library_result]
  exact evaluated_Valid

/-- scale1 is raw Q96: the lift does not rescale. -/
theorem diag_scale_is_one : scale1 = 1 := rfl
theorem diag_preQ_is_raw_q96 : preQ = ((2 ^ 96 : Nat) : ℚ) := by
  rw [preQ_eq_lift_input, lift_scale_one]; rfl

-- Axiom provenance of the load-bearing candidate theorems.
#print axioms DefiKernel.ConcentratedLiquidity.Token0Bridge.execute_ok_iff_quote
#print axioms DefiKernel.ConcentratedLiquidity.Token0Bridge.evaluated_Valid
#print axioms DefiKernel.ConcentratedLiquidity.Token0Bridge.library_ordinary_add
#print axioms DefiKernel.ConcentratedLiquidity.Token0Bridge.ordinary_add_nonzero_debit
#print axioms DefiKernel.ConcentratedLiquidity.Token0Bridge.preRegister_binds_library_input
#print axioms diag_postQ_is_lift_of_actual_library_result
#print axioms diag_execute_forces_lifted_library_post

end ReviewOpusDiagR2
