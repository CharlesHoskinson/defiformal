import DefiKernel.Vault.Adapter
import DefiKernel.ConcentratedLiquidity.Token0Bridge

/-! Campaign fixture observations. Expected values are independent RAY-scaled literals.

Historical `runtimeaudit-diag2` printed 20 true rows, but three of those names were
literal `true` placeholders (`P17-POS-DEPOSIT-CREDIT`, `P17-NEG-MINT-NO-CREDIT`,
`P17-TOKEN0-BRIDGE`) and are not runtime evidence. Current rows with those names
evaluate the credit predicate on the deposit post-state, a no-credit perturbation
of that same post-state, and the token0 library add vs identity-zero results.
Proof-only Adapter/Token0Bridge theorems remain imported below; they are not the
runtime denominator. -/
namespace DefiKernel.Vault.Examples
open DefiKernel.Vault
open DefiKernel.Arithmetic

def wad : Word 256 := ⟨WAD, WAD_lt_u256⟩
def chi0 : Word 192 := rayChi
theorem RAY_succ_lt_u192 : RAY + 1 < 2 ^ 192 :=
  Nat.lt_of_le_of_lt (Nat.succ_le_of_lt RAY_lt_u90)
    (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 90 < 192))

def chi1 : Word 192 := ⟨RAY + 1, RAY_succ_lt_u192⟩

def emptyLedger : Ledger where
  chi := chi0
  rho := 1700000000
  ssr := rayWord
  timestamp := 1700000000
  totalSupply := ⟨0, by decide⟩
  susds := fun _ => 0
  susdsAllow := fun _ _ => 0
  usds := fun _ => 0
  usdsAllow := fun _ _ => 0
  usdsSupply := 0

def fundedDeposit : Ledger :=
  { emptyLedger with
    usds := fun a => if a = .S then WAD else 0
    usdsAllow := fun o s => if o = .S ∧ s = .vault then WAD else 0
    usdsSupply := WAD }

def fundedDepositD1 : Ledger :=
  { fundedDeposit with chi := chi1 }

def fundedMintD1 : Ledger :=
  { emptyLedger with
    chi := chi1
    usds := fun a => if a = .S then WAD + 1 else 0
    usdsAllow := fun o s => if o = .S ∧ s = .vault then WAD + 1 else 0
    usdsSupply := WAD + 1 }

def fundedRedeem : Ledger :=
  { emptyLedger with
    totalSupply := wad
    susds := fun a => if a = .O then WAD else 0
    usds := fun a => if a = .vault then WAD else 0
    usdsSupply := WAD }

def fundedRedeemD1 : Ledger :=
  { fundedRedeem with chi := chi1 }

def fundedDelegated : Ledger :=
  { fundedRedeem with
    susdsAllow := fun o s => if o = .O ∧ s = .P then WAD else 0 }

def ovfNat : Nat := 115792089237316195423570985008687907853269984665641

theorem ovfNat_lt_u170 : ovfNat < 2 ^ 170 := by
  unfold ovfNat
  decide

def ovfAssets : Word 256 :=
  ⟨ovfNat, Nat.lt_trans ovfNat_lt_u170
    (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 170 < 256))⟩

def statusOk {α} : Except Failure α → Bool
  | .ok _ => true
  | .error _ => false

def statusErr (label : Failure) : Except Failure α → Bool
  | .error e => decide (e = label)
  | .ok _ => false

def sharesOf : Except Failure (Ledger × Word 256) → Option Nat
  | .ok (_, w) => some w.value
  | .error _ => none

def assetsOf : Except Failure (Ledger × Word 256) → Option Nat
  | .ok (_, w) => some w.value
  | .error _ => none

def vaultUsds : Except Failure (Ledger × Word 256) → Option Nat
  | .ok (st, _) => some (st.usds .vault)
  | .error _ => none

/-- Same credit predicate used by the honest post and the no-credit perturbation. -/
def creditPredicate (st : Ledger) (assets : Nat) : Bool :=
  decide (st.usds .vault = assets)

def noCreditPerturb (st : Ledger) : Ledger :=
  { st with usds := fun a => if a = .vault then 0 else st.usds a }

def runtimeChecks : List (String × Bool) :=
  let dep0 := deposit fundedDeposit wad .R .S
  let mint0 := mint fundedDeposit wad .R .S
  let red0 := redeem fundedRedeem wad .R .O .O
  let wd0 := withdraw fundedRedeem wad .R .O .O
  let dep1 := deposit fundedDepositD1 wad .R .S
  let mint1 := mint fundedMintD1 wad .R .S
  let red1 := redeem fundedRedeemD1 wad .R .O .O
  let wd1 := withdraw fundedRedeemD1 wad .R .O .O
  let zero := deposit emptyLedger ⟨0, Nat.succ_pos _⟩ .R .S
  let bad := deposit fundedDeposit wad .zero .S
  let self := deposit fundedDeposit wad .vault .S
  let tfBal := deposit emptyLedger wad .R .S
  let tfAllow := deposit { emptyLedger with
    usds := fun a => if a = .S then WAD else 0
    usdsSupply := WAD } wad .R .S
  let redBal := redeem emptyLedger ⟨1, by decide⟩ .R .O .O
  let redAllow := redeem fundedRedeem wad .R .O .P
  let ovf := deposit emptyLedger ovfAssets .R .S
  let del := redeem fundedDelegated wad .R .O .P
  [("P17-DEP-D0", statusOk dep0 && decide (sharesOf dep0 = some WAD)),
    ("P17-MINT-D0", statusOk mint0 && decide (assetsOf mint0 = some WAD)),
    ("P17-RED-D0", statusOk red0 && decide (assetsOf red0 = some WAD)),
    ("P17-WD-D0", statusOk wd0 && decide (sharesOf wd0 = some WAD)),
    ("P17-DEP-D1", statusOk dep1 && decide (sharesOf dep1 = some (WAD - 1))),
    ("P17-MINT-D1", statusOk mint1 && decide (assetsOf mint1 = some (WAD + 1))),
    ("P17-RED-D1", statusOk red1 && decide (assetsOf red1 = some WAD)),
    ("P17-WD-D1", statusOk wd1 && decide (sharesOf wd1 = some WAD)),
    ("P17-DEP-ZERO", statusOk zero && decide (sharesOf zero = some 0)),
    ("P17-DEP-BAD-RECV", statusErr .invalidAddress bad),
    ("P17-DEP-SELF", statusErr .invalidAddress self),
    ("P17-DEP-TF-BAL", statusErr .insufficientBalance tfBal),
    ("P17-DEP-TF-ALLOW", statusErr .insufficientAllowance tfAllow),
    ("P17-RED-BAL", statusErr .insufficientBalance redBal),
    ("P17-RED-ALLOW", statusErr .insufficientAllowance redAllow),
    ("P17-DEP-MUL-OVF", statusErr .mulOverflow ovf),
    ("P17-RED-DELEGATED", statusOk del && decide (assetsOf del = some WAD)),
    ("P17-POS-DEPOSIT-CREDIT",
      match dep0 with
      | .ok (st, _) => creditPredicate st WAD && decide (vaultUsds dep0 = some WAD)
      | .error _ => false),
    ("P17-NEG-MINT-NO-CREDIT",
      match dep0 with
      | .ok (st, _) =>
        creditPredicate st WAD && !creditPredicate (noCreditPerturb st) WAD
      | .error _ => false),
    ("P17-TOKEN0-BRIDGE",
      match ConcentratedLiquidity.Token0Bridge.libraryWord
          ConcentratedLiquidity.Token0Bridge.sqrtP_Q96
          ConcentratedLiquidity.Token0Bridge.L1
          ConcentratedLiquidity.Token0Bridge.amt1 true,
        ConcentratedLiquidity.Token0Bridge.libraryWord
          ConcentratedLiquidity.Token0Bridge.sqrtP_Q96
          ConcentratedLiquidity.Token0Bridge.L1
          ConcentratedLiquidity.Token0Bridge.amt0 true with
      | .ok moved, .ok ident =>
        decide (moved.value ≠ ident.value) &&
          decide (ident.value = ConcentratedLiquidity.Token0Bridge.sqrtP_Q96.value)
      | _, _ => false)]

-- BEGIN PROOFS

theorem chi1_value : chi1.value = RAY + 1 := rfl

example := Adapter.wad_Valid
example := Adapter.no_credit_mismatch
example := ConcentratedLiquidity.Token0Bridge.ordinary_effect_nonzero

end DefiKernel.Vault.Examples
