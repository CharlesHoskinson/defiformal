import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
import DefiKernel.Vault.Types

/-! Directed share/asset conversion under overflow premises. chi>0 excludes `_divup(0,0)`. -/
namespace DefiKernel.Vault
open DefiKernel.Arithmetic

def widenChi (chi : Word 192) : Word 256 :=
  ⟨chi.value, Nat.lt_trans chi.bound two_pow_192_lt_256⟩

def divUp (x y : Nat) : Except Failure Nat :=
  (Rounding.divideNat .up x y).mapError ofArith

/-- Checked 0.8.21 `assets * RAY` then floor division by chi. -/
def convertToShares (assets : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul assets rayWord).mapError ofArith
  let q ← (Rounding.divideNat .down prod.value chi.value).mapError ofArith
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

/-- Checked `shares * chi` then floor division by RAY. -/
def convertToAssets (shares : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul shares (widenChi chi)).mapError ofArith
  let q ← (Rounding.divideNat .down prod.value rayWord.value).mapError ofArith
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

/-- Checked `shares * chi` then `_divup` / RAY. -/
def previewMint (shares : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul shares (widenChi chi)).mapError ofArith
  let q ← divUp prod.value rayWord.value
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

/-- Checked `assets * RAY` then `_divup` / chi. -/
def previewWithdraw (assets : Word 256) (chi : Word 192) : Except Failure (Word 256) := do
  let prod ← (Operations.mul assets rayWord).mapError ofArith
  let q ← divUp prod.value chi.value
  (Word.checked (w := 256) .quotientOverflow q).mapError ofArith

-- BEGIN PROOFS

theorem ofArith_mulOverflow : ofArith .mulOverflow = .mulOverflow := rfl
theorem ofArith_div0 : ofArith .divisionByZero = .divisionByZero := rfl
theorem ofArith_quot : ofArith .quotientOverflow = .quotientOverflow := rfl

theorem mapError_ok {α} (a : α) : (Except.ok a).mapError ofArith = .ok a := rfl

theorem mapError_error {α} (e : Arithmetic.Failure) :
    (Except.error e : Except Arithmetic.Failure α).mapError ofArith = .error (ofArith e) := rfl

theorem mapError_checked_ok (n : Nat) (q : Word 256) :
    ((Word.checked (w := 256) .quotientOverflow n).mapError ofArith) = .ok q ↔
      n = q.value := by
  cases hc : Word.checked (w := 256) .quotientOverflow n with
  | error e =>
    simp [Except.mapError]
    intro hn
    have := (Word.checked_ok_iff (w := 256) .quotientOverflow n q).mpr hn
    simp [hc] at this
  | ok w =>
    simp [Except.mapError]
    constructor
    · intro h
      subst h
      exact (Word.checked_ok_iff (w := 256) .quotientOverflow n w).mp hc
    · intro hn
      have := (Word.checked_ok_iff (w := 256) .quotientOverflow n q).mpr hn
      simp [hc] at this
      exact this

theorem widenChi_value (chi : Word 192) : (widenChi chi).value = chi.value := rfl

theorem divUp_eq_divideNat_up (x y q : Nat) :
    divUp x y = .ok q ↔ Rounding.divideNat .up x y = .ok q := by
  unfold divUp
  cases h : Rounding.divideNat .up x y <;> simp [Except.mapError]

theorem divUp_zero (y : Nat) (hy : 0 < y) : divUp 0 y = .ok 0 :=
  (divUp_eq_divideNat_up 0 y 0).mpr (Rounding.divideNat_zero .up y hy)

theorem mul_ray_ok (assets : Word 256)
    (hprod : assets.value * rayWord.value < 2 ^ 256) :
    Operations.mul assets rayWord = .ok ⟨assets.value * rayWord.value, hprod⟩ :=
  (Operations.mul_ok_iff assets rayWord ⟨assets.value * rayWord.value, hprod⟩).mpr rfl

theorem mul_chi_ok (shares : Word 256) (chi : Word 192)
    (hprod : shares.value * chi.value < 2 ^ 256) :
    Operations.mul shares (widenChi chi) = .ok ⟨shares.value * chi.value, hprod⟩ :=
  (Operations.mul_ok_iff shares (widenChi chi) ⟨shares.value * chi.value, hprod⟩).mpr
    (by rw [widenChi_value])

/-- Same shape as `Rounding.mulDiv_ok_iff`: unfold, discharge the product, then
`simp [bind, Except.bind]` so the `do` notation reduces. -/
theorem convertToShares_ok (assets : Word 256) (chi : Word 192) (q : Word 256)
    (_hchi : 0 < chi.value) (hprod : assets.value * rayWord.value < 2 ^ 256) :
    convertToShares assets chi = .ok q ↔
      Rounding.divideNat .down (assets.value * rayWord.value) chi.value = .ok q.value := by
  unfold convertToShares
  rw [mul_ray_ok assets hprod, mapError_ok]
  cases hd : Rounding.divideNat .down (assets.value * rayWord.value) chi.value with
  | error e => simp [bind, Except.bind, Except.mapError, hd]
  | ok n =>
    simp [bind, Except.bind, hd]
    exact mapError_checked_ok n q

theorem convertToShares_eq_divideNat (assets : Word 256) (chi : Word 192)
    (_hchi : 0 < chi.value) (hprod : assets.value * rayWord.value < 2 ^ 256) :
    convertToShares assets chi =
      ((Rounding.divideNat .down (assets.value * rayWord.value) chi.value).mapError ofArith).bind
        fun n => (Word.checked (w := 256) .quotientOverflow n).mapError ofArith := by
  unfold convertToShares
  rw [mul_ray_ok assets hprod, mapError_ok]
  simp [bind, Except.bind]

theorem convertToShares_floor (assets : Word 256) (chi : Word 192) (q : Word 256)
    (hchi : 0 < chi.value) (hprod : assets.value * rayWord.value < 2 ^ 256) :
    convertToShares assets chi = .ok q ↔
      q.value * chi.value ≤ assets.value * rayWord.value ∧
        assets.value * rayWord.value < (q.value + 1) * chi.value := by
  rw [convertToShares_ok assets chi q hchi hprod, Rounding.divideNat_down_ok_iff]
  exact ⟨fun h => And.intro h.2.1 h.2.2, fun h => ⟨hchi, h.1, h.2⟩⟩

theorem convertToAssets_ok (shares : Word 256) (chi : Word 192) (q : Word 256)
    (hprod : shares.value * chi.value < 2 ^ 256) :
    convertToAssets shares chi = .ok q ↔
      Rounding.divideNat .down (shares.value * chi.value) rayWord.value = .ok q.value := by
  unfold convertToAssets
  rw [mul_chi_ok shares chi hprod, mapError_ok]
  cases hd : Rounding.divideNat .down (shares.value * chi.value) rayWord.value with
  | error e => simp [bind, Except.bind, Except.mapError, hd]
  | ok n =>
    simp [bind, Except.bind, hd]
    exact mapError_checked_ok n q

theorem previewMint_ok (shares : Word 256) (chi : Word 192) (q : Word 256)
    (hprod : shares.value * chi.value < 2 ^ 256) :
    previewMint shares chi = .ok q ↔
      Rounding.divideNat .up (shares.value * chi.value) rayWord.value = .ok q.value := by
  unfold previewMint
  rw [mul_chi_ok shares chi hprod, mapError_ok]
  cases hd : Rounding.divideNat .up (shares.value * chi.value) rayWord.value with
  | error e => simp [divUp, bind, Except.bind, Except.mapError, hd]
  | ok n =>
    simp [divUp, bind, Except.bind, Except.mapError, hd]
    exact mapError_checked_ok n q

theorem previewWithdraw_ok (assets : Word 256) (chi : Word 192) (q : Word 256)
    (_hchi : 0 < chi.value) (hprod : assets.value * rayWord.value < 2 ^ 256) :
    previewWithdraw assets chi = .ok q ↔
      Rounding.divideNat .up (assets.value * rayWord.value) chi.value = .ok q.value := by
  unfold previewWithdraw
  rw [mul_ray_ok assets hprod, mapError_ok]
  cases hd : Rounding.divideNat .up (assets.value * rayWord.value) chi.value with
  | error e => simp [divUp, bind, Except.bind, Except.mapError, hd]
  | ok n =>
    simp [divUp, bind, Except.bind, Except.mapError, hd]
    exact mapError_checked_ok n q

theorem mulRay_error_iff (assets : Word 256) :
    Operations.mul assets rayWord = .error .mulOverflow ↔
      2 ^ 256 ≤ assets.value * rayWord.value := by
  rw [Operations.mul_error_iff]
  constructor
  · exact And.left
  · intro h
    exact ⟨h, rfl⟩

theorem convertToShares_mulOverflow (assets : Word 256) (chi : Word 192)
    (hov : 2 ^ 256 ≤ assets.value * rayWord.value) :
    convertToShares assets chi = .error .mulOverflow := by
  unfold convertToShares
  have hm : Operations.mul assets rayWord = .error .mulOverflow :=
    (mulRay_error_iff assets).mpr hov
  rw [hm, mapError_error, ofArith_mulOverflow]
  simp [bind, Except.bind]

end DefiKernel.Vault
