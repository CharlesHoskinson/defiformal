import DefiKernel.Vault.Conversion

/-! Native Opus diagnostic r1, attempt 3 -- REPRODUCTION of the frozen snapshot scripts.

Self-contained reviewer copy.  Definitions below are copied verbatim from the frozen
snapshot `snapshot/Operations.lean` (sha256 73b7cc49...) and live in the reviewer's own
namespace `DefiKernel.Vault.OpusDiagR1`.  Nothing here is production.

Goal: run the *frozen snapshot's own* `withdraw_success_shares` /
`redeem_success_assets` tactic scripts, byte-for-byte, against the same reviewer copy of
the definitions used in attempt 2, and record the exact failure. -/

namespace DefiKernel.Vault.OpusDiagR1Frozen
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

-- ============ FROZEN SNAPSHOT SCRIPTS, VERBATIM (Operations.lean L344-404) ============

theorem redeem_success_assets (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (assets : Word 256)
    (hred : redeem st shares receiver owner caller = .ok (st', assets)) :
    convertToAssets shares chi = .ok assets := by
  unfold redeem at hred
  rw [hchi] at hred
  cases hc : convertToAssets shares chi with
  | error e =>
    rw [hc] at hred
    contradiction
  | ok a =>
    rw [hc] at hred
    cases hb : burnShares st owner caller shares.value with
    | error e =>
      rw [hb] at hred
      contradiction
    | ok st1 =>
      rw [hb] at hred
      cases ht : usdsTransfer st1 .vault receiver a.value with
      | error e =>
        rw [ht] at hred
        contradiction
      | ok st2 =>
        rw [ht] at hred
        have ha : a = assets := congrArg Prod.snd (Except.ok.inj hred)
        rw [ha]

theorem withdraw_success_shares (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (shares : Word 256)
    (hwd : withdraw st assets receiver owner caller = .ok (st', shares)) :
    previewWithdraw assets chi = .ok shares := by
  unfold withdraw at hwd
  rw [hchi] at hwd
  cases hp : previewWithdraw assets chi with
  | error e =>
    rw [hp] at hwd
    contradiction
  | ok s =>
    rw [hp] at hwd
    cases hb : burnShares st owner caller s.value with
    | error e =>
      rw [hb] at hwd
      contradiction
    | ok st1 =>
      rw [hb] at hwd
      cases ht : usdsTransfer st1 .vault receiver assets.value with
      | error e =>
        rw [ht] at hwd
        contradiction
      | ok st2 =>
        rw [ht] at hwd
        have hs : s = shares := congrArg Prod.snd (Except.ok.inj hwd)
        rw [hs]

end DefiKernel.Vault.OpusDiagR1Frozen
