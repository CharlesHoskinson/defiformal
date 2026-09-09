import DefiKernel.Arithmetic.Word
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.NormNum

/-! Vault campaign types. Accrual, UUPS, permit and deployed identity are out of scope. -/
namespace DefiKernel.Vault

open DefiKernel.Arithmetic

def RAY : Nat := 10 ^ 27
def WAD : Nat := 10 ^ 18

theorem RAY_lt_u90 : RAY < 2 ^ 90 := by
  unfold RAY
  decide

theorem RAY_lt_u192 : RAY < 2 ^ 192 :=
  Nat.lt_trans RAY_lt_u90 (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 90 < 192))

theorem RAY_lt_u256 : RAY < 2 ^ 256 :=
  Nat.lt_trans RAY_lt_u90 (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 90 < 256))

theorem WAD_lt_u64 : WAD < 2 ^ 64 := by
  unfold WAD
  decide

theorem WAD_lt_u256 : WAD < 2 ^ 256 :=
  Nat.lt_trans WAD_lt_u64 (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 64 < 256))

theorem two_pow_192_lt_256 : 2 ^ 192 < 2 ^ 256 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 192 < 256)

def rayWord : Word 256 := ⟨RAY, RAY_lt_u256⟩
def rayChi : Word 192 := ⟨RAY, RAY_lt_u192⟩

/-- Keep overflow bounds symbolic; do not reduce `2 ^ 256` in kernel proofs. -/
@[irreducible] def uint256Bound : Nat := 2 ^ 256
@[irreducible] def uint256Max : Nat := 2 ^ 256 - 1

inductive Addr
  | S | R | O | P | vault | zero | usds
  deriving DecidableEq, Repr

instance : Fintype Addr :=
  ⟨{.S, .R, .O, .P, .vault, .zero, .usds}, by intro a; cases a <;> simp⟩

inductive Asset
  | usds | susds
  deriving DecidableEq, Repr

instance : Fintype Asset := ⟨{.usds, .susds}, by intro a; cases a <;> simp⟩

inductive Domain
  | vault
  deriving DecidableEq, Repr

instance : Fintype Domain := ⟨{.vault}, by intro d; cases d; simp⟩

inductive Failure
  | invalidAddress
  | insufficientBalance
  | insufficientAllowance
  | mulOverflow
  | addOverflow
  | divisionByZero
  | quotientOverflow
  deriving DecidableEq, Repr

def ofArith : Arithmetic.Failure → Failure
  | .mulOverflow => .mulOverflow
  | .addOverflow => .addOverflow
  | .divisionByZero => .divisionByZero
  | .quotientOverflow => .quotientOverflow
  | .subUnderflow | .inputOverflow | .invalidRate
  | .nonPositiveScale | .negativeQuantity | .nonIntegralQuantity => .mulOverflow

def sourceLabel : Failure → String
  | .invalidAddress => "SUsds/invalid-address"
  | .insufficientBalance => "SUsds/insufficient-balance"
  | .insufficientAllowance => "SUsds/insufficient-allowance"
  | .mulOverflow => "Panic(0x11)"
  | .addOverflow => "Panic(0x11)"
  | .divisionByZero => "Panic(0x12)"
  | .quotientOverflow => "Panic(0x11)"

-- BEGIN PROOFS

theorem RAY_pos : 0 < RAY := by
  unfold RAY
  exact Nat.pow_pos (by decide : 0 < 10)

theorem WAD_pos : 0 < WAD := by
  unfold WAD
  exact Nat.pow_pos (by decide : 0 < 10)

theorem rayWord_value : rayWord.value = RAY := rfl

theorem rayChi_value : rayChi.value = RAY := rfl

end DefiKernel.Vault
