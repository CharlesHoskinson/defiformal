import DefiKernel.Lending.Types
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

namespace DefiKernel.Lending.Support
open DefiKernel.Typed
/-- Real administrative capability issuance, parameterized by the implemented operation registry. -/
def provision (registry : Registry Party Asset Domain) (grants : List (Grant Party Asset Domain)) :
    Except AuthorityFailure Store :=
  grants.foldlM (fun store grant => do
    let (_, next) ← issueCapability (registryAuthorityConfig registry (fun _ => .admin))
      ⟨.admin,.lending⟩ store grant
    return next) .empty
theorem sum_if_party (party : Party) (value : ℚ) :
    ∑ p : Party, (if party = p then value else 0) = value := by
  simp [Finset.sum_ite_eq, Finset.mem_univ]
end DefiKernel.Lending.Support
