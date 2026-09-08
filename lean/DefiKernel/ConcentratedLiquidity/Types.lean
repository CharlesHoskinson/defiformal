import DefiKernel.Arithmetic.Word

/-! Unsigned token0/FullMath substrate. Signed/tick/fee aliases remain P21. -/
namespace DefiKernel.ConcentratedLiquidity

abbrev U128 := Arithmetic.Word 128
abbrev U160 := Arithmetic.Word 160
abbrev U256 := Arithmetic.Word 256

def Q96 : Nat := 2 ^ 96

inductive Failure
  | divisionByZero
  | quotientOverflow
  | subUnderflow
  | addOverflow
  | uint160Overflow
  deriving DecidableEq, Repr

-- BEGIN PROOFS

theorem Q96_eq : Q96 = 79228162514264337593543950336 := by
  unfold Q96
  decide

theorem two_pow_160_lt_256 : 2 ^ 160 < 2 ^ 256 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 160 < 256)

theorem two_pow_128_lt_256 : 2 ^ 128 < 2 ^ 256 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 128 < 256)

theorem two_pow_224_lt_256 : 2 ^ 224 < 2 ^ 256 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 224 < 256)

theorem two_pow_pos_256 : 0 < 2 ^ 256 := Nat.pow_pos (by decide : 0 < 2)

theorem two_pow_pos_160 : 0 < 2 ^ 160 := Nat.pow_pos (by decide : 0 < 2)

theorem two_pow_pos_96 : 0 < 2 ^ 96 := Nat.pow_pos (by decide : 0 < 2)

end DefiKernel.ConcentratedLiquidity
