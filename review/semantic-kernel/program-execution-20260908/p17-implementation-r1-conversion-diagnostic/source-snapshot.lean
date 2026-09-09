import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
import DefiKernel.Vault.Types

/-! Directed share/asset conversion under overflow premises. `_divup(0,0)=0` is excluded by chi>0. -/
namespace DefiKernel.Vault
open DefiKernel.Arithmetic

def divUp (x y : Nat) : Except Failure Nat :=
  (Rounding.divideNat .up x y).mapError ofArith

def convertToShares (assets : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul assets rayWord).mapError ofArith
  let q ← (Rounding.divideNat .down prod.value chi.value).mapError ofArith
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

def convertToAssets (shares : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let chi256 : Word 256 := ⟨chi.value, Nat.lt_trans chi.bound two_pow_192_lt_256⟩
  let prod ← (Operations.mul shares chi256).mapError ofArith
  let q ← (Rounding.divideNat .down prod.value RAY).mapError ofArith
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

def previewMint (shares : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let chi256 : Word 256 := ⟨chi.value, Nat.lt_trans chi.bound two_pow_192_lt_256⟩
  let prod ← (Operations.mul shares chi256).mapError ofArith
  let q ← divUp prod.value RAY
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

def previewWithdraw (assets : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul assets rayWord).mapError ofArith
  let q ← divUp prod.value chi.value
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

-- BEGIN PROOFS

theorem divUp_eq_divideNat_up (x y q : Nat) :
    divUp x y = .ok q ↔ Rounding.divideNat .up x y = .ok q := by
  unfold divUp
  cases h : Rounding.divideNat .up x y <;> simp [Except.mapError]

theorem divUp_zero (y : Nat) (hy : 0 < y) : divUp 0 y = .ok 0 := by
  exact (divUp_eq_divideNat_up 0 y 0).mpr (Rounding.divideNat_zero .up y hy)

theorem convertToShares_eq_divideNat (assets : Word 256) (chi : Word 192)
    (hchi : 0 < chi.value) (hprod : assets.value * RAY < 2 ^ 256) :
    convertToShares assets chi =
      (Rounding.divideNat .down (assets.value * RAY) chi.value).mapError ofArith >>=
        fun q => (Word.checked (w := 256) .quotientOverflow q).mapError ofArith := by
  unfold convertToShares
  have hm : Operations.mul assets rayWord = .ok ⟨assets.value * RAY, hprod⟩ := by
    simpa [Operations.mul_ok_iff, rayWord_value]
  simp [hm, Except.bind, Except.mapError]

theorem convertToShares_ok (assets : Word 256) (chi : Word 192) (q : Word 256)
    (hchi : 0 < chi.value) (hprod : assets.value * RAY < 2 ^ 256) :
    convertToShares assets chi = .ok q ↔
      Rounding.divideNat .down (assets.value * RAY) chi.value = .ok q.value := by
  rw [convertToShares_eq_divideNat assets chi hchi hprod]
  cases hd : Rounding.divideNat .down (assets.value * RAY) chi.value with
  | error e =>
    simp [Except.mapError, Except.bind]
  | ok n =>
    simp [Except.mapError, Except.bind, Word.checked_ok_iff]

theorem convertToShares_floor (assets : Word 256) (chi : Word 192) (q : Word 256)
    (hchi : 0 < chi.value) (hprod : assets.value * RAY < 2 ^ 256) :
    convertToShares assets chi = .ok q ↔
      q.value * chi.value ≤ assets.value * RAY ∧
        assets.value * RAY < (q.value + 1) * chi.value := by
  rw [convertToShares_ok assets chi q hchi hprod, Rounding.divideNat_down_ok_iff]
  simp [hchi]

theorem convertToAssets_ok (shares : Word 256) (chi : Word 192) (q : Word 256)
    (hprod : shares.value * chi.value < 2 ^ 256) :
    convertToAssets shares chi = .ok q ↔
      Rounding.divideNat .down (shares.value * chi.value) RAY = .ok q.value := by
  unfold convertToAssets
  have hm : Operations.mul shares ⟨chi.value, Nat.lt_trans chi.bound two_pow_192_lt_256⟩ =
      .ok ⟨shares.value * chi.value, hprod⟩ := by
    simpa [Operations.mul_ok_iff]
  simp [hm, Except.bind, Except.mapError]
  cases hd : Rounding.divideNat .down (shares.value * chi.value) RAY with
  | error e => simp [Except.mapError]
  | ok n => simp [Except.mapError, Word.checked_ok_iff]

theorem previewMint_ok (shares : Word 256) (chi : Word 192) (q : Word 256)
    (hprod : shares.value * chi.value < 2 ^ 256) :
    previewMint shares chi = .ok q ↔
      Rounding.divideNat .up (shares.value * chi.value) RAY = .ok q.value := by
  unfold previewMint
  have hm : Operations.mul shares ⟨chi.value, Nat.lt_trans chi.bound two_pow_192_lt_256⟩ =
      .ok ⟨shares.value * chi.value, hprod⟩ := by
    simpa [Operations.mul_ok_iff]
  simp [hm, Except.bind, Except.mapError, divUp_eq_divideNat_up]
  cases hd : Rounding.divideNat .up (shares.value * chi.value) RAY with
  | error e => simp [Except.mapError]
  | ok n => simp [Except.mapError, Word.checked_ok_iff]

theorem previewWithdraw_ok (assets : Word 256) (chi : Word 192) (q : Word 256)
    (hchi : 0 < chi.value) (hprod : assets.value * RAY < 2 ^ 256) :
    previewWithdraw assets chi = .ok q ↔
      Rounding.divideNat .up (assets.value * RAY) chi.value = .ok q.value := by
  unfold previewWithdraw
  have hm : Operations.mul assets rayWord = .ok ⟨assets.value * RAY, hprod⟩ := by
    simpa [Operations.mul_ok_iff, rayWord_value]
  simp [hm, Except.bind, Except.mapError, divUp_eq_divideNat_up]
  cases hd : Rounding.divideNat .up (assets.value * RAY) chi.value with
  | error e => simp [Except.mapError]
  | ok n => simp [Except.mapError, Word.checked_ok_iff]

theorem mulRay_error_iff (assets : Word 256) :
    Operations.mul assets rayWord = .error .mulOverflow ↔ 2 ^ 256 ≤ assets.value * RAY := by
  rw [Operations.mul_error_iff]
  simp [rayWord_value]

theorem convertToShares_mulOverflow (assets : Word 256) (chi : Word 192)
    (hov : 2 ^ 256 ≤ assets.value * RAY) :
    convertToShares assets chi = .error .mulOverflow := by
  unfold convertToShares
  have hm : Operations.mul assets rayWord = .error .mulOverflow :=
    (mulRay_error_iff assets).mpr hov
  simp [hm, Except.mapError, Except.bind]

end DefiKernel.Vault
