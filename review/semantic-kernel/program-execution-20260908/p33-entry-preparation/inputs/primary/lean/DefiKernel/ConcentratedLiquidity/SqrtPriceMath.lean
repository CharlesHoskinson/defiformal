import DefiKernel.Arithmetic.Operations
import DefiKernel.ConcentratedLiquidity.FullMath

/-! Public token0 next-price helper. Denominator sum wraps; fallback add is checked. -/
namespace DefiKernel.ConcentratedLiquidity.SqrtPriceMath
open ConcentratedLiquidity
open FullMath

/-- Orient the concrete power as the first factor. `Nat.mul` recurses on its
second argument, so `L.value * Q96` would unfold a 2^96 recursive argument. -/
def numerator1 (liquidity : U128) : Nat := Q96 * liquidity.value

theorem numerator1_lt_u256 (L : U128) : numerator1 L < 2 ^ 256 := by
  unfold numerator1 Q96
  rw [Nat.mul_comm (2 ^ 96) L.value]
  have hmul : L.value * 2 ^ 96 < 2 ^ 128 * 2 ^ 96 :=
    Nat.mul_lt_mul_of_pos_right L.bound two_pow_pos_96
  have heq : 2 ^ 128 * 2 ^ 96 = 2 ^ 224 := (Nat.pow_add 2 128 96).symm
  have h224 : L.value * 2 ^ 96 < 2 ^ 224 := by
    rwa [heq] at hmul
  exact Nat.lt_trans h224 two_pow_224_lt_256

def numerator1Word (L : U128) : U256 := ⟨numerator1 L, numerator1_lt_u256 L⟩

def widen160 (x : U160) : U256 :=
  ⟨x.value, Nat.lt_trans x.bound two_pow_160_lt_256⟩

def product (amount : U256) (sqrtP : U160) : Nat := amount.value * sqrtP.value

def wrap256 (n : Nat) : Nat := n % 2 ^ 256

theorem wrap256_lt (n : Nat) : wrap256 n < 2 ^ 256 :=
  Nat.mod_lt n two_pow_pos_256

def wrapWord (n : Nat) : U256 := ⟨wrap256 n, wrap256_lt n⟩

/-- Source add-path bare `uint160` truncation. -/
def bareToUint160 (y : U256) : U160 :=
  ⟨y.value % 2 ^ 160, Nat.mod_lt y.value two_pow_pos_160⟩

def toUint160 (y : U256) : Except Failure U160 :=
  if h : y.value < 2 ^ 160 then .ok ⟨y.value, h⟩ else .error .uint160Overflow

/-- Assembly DIV/MOD by 0 return 0. The source comment leaves `y==0` unspecified. -/
def divRoundingUp (x y : Nat) : Nat :=
  if y = 0 then 0
  else x / y + if x % y = 0 then 0 else 1

def ofAddFailure (e : Arithmetic.Failure) : Failure :=
  match e with
  | .addOverflow => .addOverflow
  | .divisionByZero => .divisionByZero
  | .quotientOverflow => .quotientOverflow
  | .subUnderflow => .subUnderflow
  | .mulOverflow | .inputOverflow | .invalidRate
  | .nonPositiveScale | .negativeQuantity | .nonIntegralQuantity => .addOverflow

def checkedAdd (x y : U256) : Except Failure U256 :=
  match Arithmetic.Operations.add x y with
  | .ok z => .ok z
  | .error e => .error (ofAddFailure e)

def floorDivWord (n : Nat) (sqrtP : U160) (hn : n < 2 ^ 256) : U256 :=
  ⟨n / sqrtP.value, lt_of_le_of_lt (Nat.div_le_self n sqrtP.value) hn⟩

theorem divRoundingUp_le (x y : Nat) : divRoundingUp x y ≤ x := by
  unfold divRoundingUp
  split
  · exact Nat.zero_le _
  · split
    · exact Nat.div_le_self _ _
    · next hy hrem =>
        have hx : x ≠ 0 := fun hx => by simp [hx] at hrem
        have hy1 : y ≠ 1 := fun hy1 => by
          subst hy1
          exact hrem (Nat.mod_one x)
        have hygt : 1 < y := by
          cases y with
          | zero => exact (hy rfl).elim
          | succ y' =>
            cases y' with
            | zero => exact (hy1 rfl).elim
            | succ _ => exact Nat.succ_lt_succ (Nat.succ_pos _)
        have : x / y < x := Nat.div_lt_self (Nat.pos_of_ne_zero hx) hygt
        exact Nat.succ_le_of_lt this

theorem divRoundingUp_lt_u256 (x y : Nat) (hx : x < 2 ^ 256) :
    divRoundingUp x y < 2 ^ 256 :=
  lt_of_le_of_lt (divRoundingUp_le x y) hx

theorem numerator1_comm (L : U128) : numerator1 L = L.value * Q96 :=
  Nat.mul_comm _ _

theorem checkedAdd_ok_iff (x y q : U256) :
    checkedAdd x y = .ok q ↔ Arithmetic.Operations.add x y = .ok q := by
  unfold checkedAdd
  cases Arithmetic.Operations.add x y <;> simp

theorem divRoundingUp_eq_divideNat_up (x y : Nat) (hy : 0 < y) :
    Arithmetic.Rounding.divideNat .up x y = .ok (divRoundingUp x y) := by
  have hne : y ≠ 0 := Nat.ne_of_gt hy
  unfold Arithmetic.Rounding.divideNat divRoundingUp
  simp [hne]

theorem wrapWord_value_of_lt (n : Nat) (h : n < 2 ^ 256) :
    (wrapWord n).value = n :=
  Nat.mod_eq_of_lt h

theorem bareToUint160_value_of_lt (y : U256) (h : y.value < 2 ^ 160) :
    (bareToUint160 y).value = y.value :=
  Nat.mod_eq_of_lt h

def addPrimary (sqrtP : U160) (L : U128) (amount : U256) : Except Failure U160 :=
  match mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
      (wrapWord (numerator1 L + product amount sqrtP)) with
  | .ok q => .ok (bareToUint160 q)
  | .error e => .error e

theorem addPrimary_fullmath (sqrtP : U160) (L : U128) (amount : U256) :
    addPrimary sqrtP L amount =
      match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
          (wrapWord (numerator1 L + product amount sqrtP)) with
      | .ok q => .ok (bareToUint160 q)
      | .error e => .error e :=
  rfl

def addFallback (sqrtP : U160) (L : U128) (amount : U256) : Except Failure U160 :=
  match checkedAdd (floorDivWord (numerator1 L) sqrtP (numerator1_lt_u256 L)) amount with
  | .error e => .error e
  | .ok inner =>
      .ok (bareToUint160 ⟨divRoundingUp (numerator1 L) inner.value,
        divRoundingUp_lt_u256 _ _ (numerator1_lt_u256 L)⟩)

def removePrimary (sqrtP : U160) (L : U128) (amount : U256) : Except Failure U160 :=
  match mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
      ⟨numerator1 L - product amount sqrtP,
        lt_of_le_of_lt (Nat.sub_le _ _) (numerator1_lt_u256 L)⟩ with
  | .ok q => toUint160 q
  | .error e => .error e

theorem removePrimary_fullmath (sqrtP : U160) (L : U128) (amount : U256) :
    removePrimary sqrtP L amount =
      match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
          ⟨numerator1 L - product amount sqrtP,
            lt_of_le_of_lt (Nat.sub_le _ _) (numerator1_lt_u256 L)⟩ with
      | .ok q => toUint160 q
      | .error e => .error e :=
  rfl

def getNextSqrtPriceFromAmount0RoundingUp
    (sqrtPX96 : U160) (liquidity : U128) (amount : U256) (add : Bool) :
    Except Failure U160 :=
  if amount.value = 0 then
    .ok sqrtPX96
  else if add then
    if Nat.blt (product amount sqrtPX96) (2 ^ 256) then
      if Nat.ble (numerator1 liquidity)
          (wrap256 (numerator1 liquidity + product amount sqrtPX96)) then
        addPrimary sqrtPX96 liquidity amount
      else
        addFallback sqrtPX96 liquidity amount
    else
      addFallback sqrtPX96 liquidity amount
  else if Nat.blt (product amount sqrtPX96) (2 ^ 256) &&
      decide (numerator1 liquidity > product amount sqrtPX96) then
    removePrimary sqrtPX96 liquidity amount
  else
    .error .subUnderflow

end DefiKernel.ConcentratedLiquidity.SqrtPriceMath
