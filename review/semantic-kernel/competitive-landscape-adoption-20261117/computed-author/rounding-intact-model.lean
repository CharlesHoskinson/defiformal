import DefiKernel.Vault.ConversionDomain
import DefiKernel.Vault.Adapter

/-! Native checked conversion drives the exact-rational deposit at raw scale 1.
Zero fees are explicit in the full sender debit and vault credit. This is not native-Ledger
or Solidity refinement; the Typed invocation uses the accepted fixed parties/capability layout. -/
namespace DefiKernel.Vault.ComputedDeposit
open DefiKernel.Arithmetic DefiKernel.Typed

abbrev P := Addr
abbrev A := Asset
abbrev D := Domain
abbrev W := ExecutionResult P A D
abbrev Store := CapabilityStore P A D
abbrev S := State P A D

def assetsQ (assets : Word 256) : ℚ :=
  (Arithmetic.Quantity.toQuantity Asset.usds 1 (by decide) assets).amount
def sharesQ (shares : Word 256) : ℚ :=
  (Arithmetic.Quantity.toQuantity Asset.susds 1 (by decide) shares).amount

theorem assetsQ_value (assets : Word 256) : assetsQ assets = (assets.value : ℚ) := by
  simp [assetsQ, Arithmetic.Quantity.toQuantity_amount]
theorem sharesQ_value (shares : Word 256) : sharesQ shares = (shares.value : ℚ) := by
  simp [sharesQ, Arithmetic.Quantity.toQuantity_amount]

/-- Arithmetic refusals and execution refusals are disjoint constructors. -/
def run (assets : Word 256) (chi : Word 192) (store : Store) (pre : S) :
    Except (Vault.Failure ⊕ Typed.Refusal) W := do
  let shares ← (convertToShares assets chi).mapError Sum.inl
  (Typed.execute (Adapter.registry (assetsQ assets) (sharesQ shares)) store
    Adapter.ctx Adapter.env 0 Adapter.req pre).mapError Sum.inr


end DefiKernel.Vault.ComputedDeposit
namespace DefiKernel.Vault.RoundingControl
open DefiKernel.Arithmetic
def three : Word 256 := ⟨3, by decide⟩
def twiceRay : Word 192 := ⟨2 * RAY, by decide⟩
#eval do
  let observed := ComputedDeposit.run three twiceRay Adapter.store
    (Adapter.fundedState 3 (by decide))
  match observed with
  | .error _ => throw (IO.userError "unexpected refusal in rounding probe")
  | .ok post =>
    let q := post.state.balance (.vault, .R, .susds)
    IO.println s!"ROUNDING expected_floor {decide (q = 1)}"
    IO.println s!"ROUNDING expected_ceil {decide (q = 2)}"
end DefiKernel.Vault.RoundingControl
