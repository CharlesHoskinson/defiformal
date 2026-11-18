import DefiKernel.Vault.Adapter
import DefiKernel.ConcentratedLiquidity.Token0Bridge

/-! Fixed raw-unit bridge: deposit conversion output is hypothetical sUSDS token0 input.
This is neither AMM settlement nor full vault/source refinement. chi=RAY is the unit rate. -/
namespace DefiKernel.Composition.ShareQuote

open DefiKernel.Arithmetic
open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.Token0Bridge

/-- One raw USDS unit converts to one raw sUSDS unit at chi=RAY. -/
theorem raw_share_conversion :
    Vault.convertToShares amt1 Vault.rayChi = .ok amt1 := by
  have hchi : 0 < Vault.rayChi.value := by
    simpa [Vault.rayChi] using Vault.RAY_pos
  have hprod : amt1.value * Vault.rayWord.value < 2 ^ 256 := by
    simpa [amt1, Vault.rayWord] using Vault.RAY_lt_u256
  rw [Vault.convertToShares_ok amt1 Vault.rayChi amt1 hchi hprod]
  have hd := Rounding.divideNat_exact .down Vault.RAY Vault.RAY Vault.RAY_pos
    (dvd_refl Vault.RAY)
  change Rounding.divideNat .down (1 * Vault.RAY) Vault.RAY = .ok 1
  simpa only [one_mul, Nat.div_self Vault.RAY_pos] using hd

/-- The quote consumes the actual Word returned by the vault's native conversion. -/
def convertedShareQuote : Except (Vault.Failure ⊕ ConcentratedLiquidity.Failure) U160 := do
  let shares ← (Vault.convertToShares amt1 Vault.rayChi).mapError Sum.inl
  (libraryWord sqrtP_Q96 L1 shares true).mapError Sum.inr

theorem converted_share_quote : convertedShareQuote = .ok postWord := by
  unfold convertedShareQuote
  rw [raw_share_conversion]
  simp [Except.mapError, bind, Except.bind, library_ordinary_add]

/-- A mismatched zero share input produces the identity quote, not this ordinary-add quote. -/
theorem zero_share_quote_differs :
    libraryWord sqrtP_Q96 L1 amt0 true ≠ .ok postWord := by
  rw [library_identity_zero]
  intro h
  have he : sqrtP_Q96 = postWord := Except.ok.inj h
  have hv := congrArg Word.value he
  change 2 ^ 96 = 2 ^ 95 at hv
  exact (ne_of_gt (Nat.pow_lt_pow_right (by decide : 1 < 2)
    (by decide : 95 < 96))) hv

#print axioms raw_share_conversion
#print axioms converted_share_quote
#print axioms zero_share_quote_differs

end DefiKernel.Composition.ShareQuote
