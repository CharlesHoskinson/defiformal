import DefiKernel.Vault.Conversion

/-! Native Opus diagnostic r1, attempt 2 (attempt 1 + one-line fix in `bind_eq_ok`).

Self-contained reviewer copy.  Definitions below are copied verbatim from the frozen
snapshot `snapshot/Operations.lean` (sha256 73b7cc49...) and live in the reviewer's own
namespace `DefiKernel.Vault.OpusDiagR1`.  Nothing here is production.

Goal: verify a statement-preserving repair for `withdraw_success_shares` and
`redeem_success_assets` that never lets the kernel whnf an arithmetic scrutinee. -/

namespace DefiKernel.Vault.OpusDiagR1
open DefiKernel.Arithmetic

-- ============ verbatim frozen definitions (reviewer copy) ============

structure Ledger where
  chi : Word 192
  rho : Nat
  ssr : Word 256
  timestamp : Nat
  totalSupply : Word 256
  susds : Addr → Nat
  susdsAllow : Addr → Addr → Nat
  usds : Addr → Nat
  usdsAllow : Addr → Addr → Nat
  usdsSupply : Nat

def usdsTransfer (st : Ledger) (src dst : Addr) (value : Nat) : Except Failure Ledger := do
  if st.usds src < value then throw .insufficientBalance
  pure {
    st with
      usds := fun a =>
        if a = src then st.usds src - value
        else if a = dst then st.usds dst + value
        else st.usds a
  }

def burnShares (st : Ledger) (owner caller : Addr) (shares : Nat) : Except Failure Ledger := do
  if st.susds owner < shares then throw .insufficientBalance
  let st ←
    if owner ≠ caller then
      let allowed := st.susdsAllow owner caller
      if allowed ≠ uint256Max then
        if allowed < shares then throw .insufficientAllowance
        pure { st with
          susdsAllow := fun o s =>
            if o = owner ∧ s = caller then allowed - shares else st.susdsAllow o s }
      else pure st
    else pure st
  if st.totalSupply.value < shares then throw .insufficientBalance
  let ts ← (Word.checked (w := 256) .subUnderflow (st.totalSupply.value - shares)).mapError ofArith
  pure { st with
    totalSupply := ts
    susds := fun a => if a = owner then st.susds owner - shares else st.susds a }

def dripChi (st : Ledger) : Except Failure (Word 192) :=
  if st.timestamp = st.rho then
    if st.chi.value = 0 then .error .divisionByZero else .ok st.chi
  else
    .error .divisionByZero

def withdraw (st : Ledger) (assets : Word 256) (receiver owner caller : Addr) :
    Except Failure (Ledger × Word 256) := do
  let chi ← dripChi st
  let shares ← previewWithdraw assets chi
  let st ← burnShares st owner caller shares.value
  let st ← usdsTransfer st .vault receiver assets.value
  return (st, shares)

def redeem (st : Ledger) (shares : Word 256) (receiver owner caller : Addr) :
    Except Failure (Ledger × Word 256) := do
  let chi ← dripChi st
  let assets ← convertToAssets shares chi
  let st ← burnShares st owner caller shares.value
  let st ← usdsTransfer st .vault receiver assets.value
  return (st, assets)

-- verbatim frozen helper lemmas
theorem bind_ok {α β} (a : α) (f : α → Except Failure β) :
    bind (Except.ok a) f = f a := rfl

theorem bind_error {α β} (e : Failure) (f : α → Except Failure β) :
    bind (Except.error e : Except Failure α) f = .error e := rfl

-- ============ PROPOSED NEW GENERIC LEMMAS ============

/-- Generic `Except` success inversion.  Proved at fully abstract `{ε α β}` with a
*variable* scrutinee `e`, so the kernel checks it without ever reducing arithmetic.
Every later use is a cheap instantiation. -/
theorem bind_eq_ok {ε α β} {e : Except ε α} {f : α → Except ε β} {b : β}
    (h : e >>= f = .ok b) : ∃ a, e = .ok a ∧ f a = .ok b := by
  cases e with
  | error x =>
      have h' : (Except.error x : Except ε β) = .ok b := h
      contradiction
  | ok a => exact ⟨a, rfl, h⟩

/-- Companion: generic `Except` error inversion (same abstractness discipline). -/
theorem bind_eq_error {ε α β} {e : Except ε α} {f : α → Except ε β} {x : ε}
    (h : e >>= f = .error x) :
    e = .error x ∨ ∃ a, e = .ok a ∧ f a = .error x := by
  cases e with
  | error y =>
      have h' : (Except.error y : Except ε β) = .error x := h
      exact Or.inl (congrArg Except.error (Except.error.inj h'))
  | ok a => exact Or.inr ⟨a, rfl, h⟩

-- ============ PROPOSED continuation lemmas (deposit_after_drip pattern) ============

theorem withdraw_after_drip (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    withdraw st assets receiver owner caller =
      (previewWithdraw assets chi >>= fun shares =>
        burnShares st owner caller shares.value >>= fun st1 =>
          usdsTransfer st1 .vault receiver assets.value >>= fun st2 =>
            pure (st2, shares)) := by
  unfold withdraw
  rw [hchi]
  exact bind_ok chi _

theorem redeem_after_drip (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    redeem st shares receiver owner caller =
      (convertToAssets shares chi >>= fun assets =>
        burnShares st owner caller shares.value >>= fun st1 =>
          usdsTransfer st1 .vault receiver assets.value >>= fun st2 =>
            pure (st2, assets)) := by
  unfold redeem
  rw [hchi]
  exact bind_ok chi _

-- ============ REPAIRED PROJECTION PROOFS (statements verbatim frozen) ============

theorem withdraw_success_shares (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (shares : Word 256)
    (hwd : withdraw st assets receiver owner caller = .ok (st', shares)) :
    previewWithdraw assets chi = .ok shares := by
  rw [withdraw_after_drip st assets receiver owner caller chi hchi] at hwd
  obtain ⟨s, hs, hwd⟩ := bind_eq_ok hwd
  obtain ⟨st1, _hb, hwd⟩ := bind_eq_ok hwd
  obtain ⟨st2, _ht, hwd⟩ := bind_eq_ok hwd
  have hfin : (Except.ok (st2, s) : Except Failure (Ledger × Word 256)) = .ok (st', shares) := hwd
  have hss : s = shares := congrArg Prod.snd (Except.ok.inj hfin)
  rw [hs, hss]

theorem redeem_success_assets (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (assets : Word 256)
    (hred : redeem st shares receiver owner caller = .ok (st', assets)) :
    convertToAssets shares chi = .ok assets := by
  rw [redeem_after_drip st shares receiver owner caller chi hchi] at hred
  obtain ⟨a, ha, hred⟩ := bind_eq_ok hred
  obtain ⟨st1, _hb, hred⟩ := bind_eq_ok hred
  obtain ⟨st2, _ht, hred⟩ := bind_eq_ok hred
  have hfin : (Except.ok (st2, a) : Except Failure (Ledger × Word 256)) = .ok (st', assets) := hred
  have haa : a = assets := congrArg Prod.snd (Except.ok.inj hfin)
  rw [ha, haa]

-- ============ downstream consumers still go through (statements verbatim frozen) ============

theorem withdraw_ceil_shares (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (hpos : 0 < chi.value)
    (hprod : assets.value * rayWord.value < 2 ^ 256) (st' : Ledger) (shares : Word 256)
    (hwd : withdraw st assets receiver owner caller = .ok (st', shares)) :
    Rounding.divideNat .up (assets.value * rayWord.value) chi.value = .ok shares.value := by
  have hp := withdraw_success_shares st assets receiver owner caller chi hchi st' shares hwd
  exact (previewWithdraw_ok assets chi shares hpos hprod).mp hp

theorem redeem_floor_assets (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hprod : shares.value * chi.value < 2 ^ 256) (st' : Ledger) (assets : Word 256)
    (hred : redeem st shares receiver owner caller = .ok (st', assets)) :
    Rounding.divideNat .down (shares.value * chi.value) rayWord.value = .ok assets.value := by
  have hc := redeem_success_assets st shares receiver owner caller chi hchi st' assets hred
  exact (convertToAssets_ok shares chi assets hprod).mp hc

#print axioms bind_eq_ok
#print axioms bind_eq_error
#print axioms withdraw_after_drip
#print axioms redeem_after_drip
#print axioms withdraw_success_shares
#print axioms redeem_success_assets
#print axioms withdraw_ceil_shares
#print axioms redeem_floor_assets

end DefiKernel.Vault.OpusDiagR1
