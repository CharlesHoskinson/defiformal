import DefiKernel.Vault.ComputedDeposit
import DefiKernel.AxiomAudit

/-! Bounded execution controls, separate from the quantified correspondence proofs.
A refusal returns no post-world; the supplied prestate is not an observed rollback. -/
namespace DefiKernel.Vault.ComputedDepositAudit
open DefiKernel.Arithmetic DefiKernel.Typed

def zeroAssets : Word 256 := ⟨0, by decide⟩
def oneAsset : Word 256 := ⟨1, by decide⟩
def threeAssets : Word 256 := ⟨3, by decide⟩
def fourAssets : Word 256 := ⟨4, by decide⟩
def zeroRate : Word 192 := ⟨0, by decide⟩
def doubleRate : Word 192 := ⟨2 * RAY, by decide⟩
def overflowAssets : Word 256 :=
  ⟨2 ^ 255, Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 255 < 256)⟩

/-- Independent complete expected Typed ledger: no template/effect function is called. -/
def expectedBalance (assets shares : Nat) (c : Cell Addr Asset Domain) : ℚ :=
  if c = (.vault, .vault, .usds) then assets else
    if c = (.vault, .R, .susds) then shares else 0

def successMatches (observed : Except (Vault.Failure ⊕ Typed.Refusal) ComputedDeposit.W)
    (assets shares : Nat) : Bool :=
  match observed with
  | .error _ => false
  | .ok post => decide (post.capabilities = Adapter.store) &&
      decide (∀ c, post.state.balance c = expectedBalance assets shares c)

def arithmeticError (observed : Except (Vault.Failure ⊕ Typed.Refusal) ComputedDeposit.W)
    (expected : Vault.Failure) : Bool :=
  match observed with
  | .error (.inl actual) => decide (actual = expected)
  | _ => false

def executionError (observed : Except (Vault.Failure ⊕ Typed.Refusal) ComputedDeposit.W)
    (expected : Typed.Refusal) : Bool :=
  match observed with
  | .error (.inr actual) => decide (actual = expected)
  | _ => false

def checks : List (String × Bool) := [
  ("zero_assets_positive_rate", successMatches
    (ComputedDeposit.run zeroAssets doubleRate Adapter.store (ComputedDeposit.fundedPre zeroAssets)) 0 0),
  ("raw_unit_rate", successMatches
    (ComputedDeposit.run oneAsset rayChi Adapter.store (ComputedDeposit.fundedPre oneAsset)) 1 1),
  ("nonunit_exact", successMatches
    (ComputedDeposit.run fourAssets doubleRate Adapter.store (ComputedDeposit.fundedPre fourAssets)) 4 2),
  ("nonunit_floor_inexact", successMatches
    (ComputedDeposit.run threeAssets doubleRate Adapter.store (ComputedDeposit.fundedPre threeAssets)) 3 1),
  ("floor_zero_shares_not_asset_fee", successMatches
    (ComputedDeposit.run oneAsset doubleRate Adapter.store (ComputedDeposit.fundedPre oneAsset)) 1 0),
  ("fixed_wad_corollary", successMatches
    (ComputedDeposit.run Adapter.libraryAssets rayChi Adapter.store
      (ComputedDeposit.fundedPre Adapter.libraryAssets)) WAD WAD),
  ("bounded_product_zero_rate", arithmeticError
    (ComputedDeposit.run threeAssets zeroRate Adapter.store (ComputedDeposit.fundedPre threeAssets))
      .divisionByZero),
  ("zero_assets_zero_rate", arithmeticError
    (ComputedDeposit.run zeroAssets zeroRate Adapter.store (ComputedDeposit.fundedPre zeroAssets))
      .divisionByZero),
  ("checked_product_overflow", arithmeticError
    (ComputedDeposit.run overflowAssets rayChi Adapter.store (ComputedDeposit.fundedPre overflowAssets))
      .mulOverflow),
  ("overflow_precedes_zero_rate", arithmeticError
    (ComputedDeposit.run overflowAssets zeroRate Adapter.store (ComputedDeposit.fundedPre overflowAssets))
      .mulOverflow),
  ("typed_insufficient_funds", executionError
    (ComputedDeposit.run threeAssets rayChi Adapter.store (ComputedDeposit.fundedPre zeroAssets))
      .insufficientFunds),
  ("typed_authority_refusal", executionError
    (ComputedDeposit.run oneAsset rayChi CapabilityStore.empty (ComputedDeposit.fundedPre oneAsset))
      .unauthorizedInvoke)]

#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty computed-deposit checks")
  if !decide (checks.map Prod.fst).Nodup then
    throw (IO.userError "FAILED: duplicate computed-deposit check labels")
  for (name, passed) in checks do
    IO.println s!"COMPUTED-DEPOSIT {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAILED: computed-deposit check")
  IO.println s!"COMPUTED-DEPOSIT PASSED {checks.length}/{checks.length}"

end DefiKernel.Vault.ComputedDepositAudit

#audit_axioms DefiKernel.Vault.ConversionDomain
#audit_axioms DefiKernel.Vault.ComputedDeposit
