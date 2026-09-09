import DefiKernel.Vault.Conversion

/-! D0/D1 deposit/mint/withdraw/redeem. Unchecked source wrap is refused here under overflow
premises; that mismatch is named G-UNCHECKED-SUPPLY-WRAP. -/
namespace DefiKernel.Vault
open DefiKernel.Arithmetic

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

def validReceiver (receiver : Addr) : Bool :=
  decide (receiver ≠ .zero ∧ receiver ≠ .vault)

def usdsTransferFrom (st : Ledger) (src spender dst : Addr) (value : Nat) :
    Except Failure Ledger := do
  if st.usds src < value then throw .insufficientBalance
  if src ≠ spender then
    let allowed := st.usdsAllow src spender
    if allowed ≠ uint256Max then
      if allowed < value then throw .insufficientAllowance
      -- finite branch is entered even at value 0; 0 >= 0 passes and consumes zero
      pure {
        st with
          usds := fun a =>
            if a = src then st.usds src - value
            else if a = dst then st.usds dst + value
            else st.usds a
          usdsAllow := fun o s =>
            if o = src ∧ s = spender then allowed - value else st.usdsAllow o s
      }
    else
      pure {
        st with
          usds := fun a =>
            if a = src then st.usds src - value
            else if a = dst then st.usds dst + value
            else st.usds a
      }
  else
    pure {
      st with
        usds := fun a =>
          if a = src then st.usds src - value
          else if a = dst then st.usds dst + value
          else st.usds a
    }

def usdsTransfer (st : Ledger) (src dst : Addr) (value : Nat) : Except Failure Ledger := do
  if st.usds src < value then throw .insufficientBalance
  pure {
    st with
      usds := fun a =>
        if a = src then st.usds src - value
        else if a = dst then st.usds dst + value
        else st.usds a
  }

def mintShares (st : Ledger) (receiver : Addr) (shares : Nat) : Except Failure Ledger := do
  if validReceiver receiver = false then throw .invalidAddress
  if uint256Bound ≤ st.totalSupply.value + shares then throw .addOverflow
  if uint256Bound ≤ st.susds receiver + shares then throw .addOverflow
  let ts ← (Word.checked (w := 256) .addOverflow (st.totalSupply.value + shares)).mapError ofArith
  pure { st with
    totalSupply := ts
    susds := fun a => if a = receiver then st.susds receiver + shares else st.susds a }

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

/-- Stable-time drip: timestamp == rho, nChi = chi, no suck/exit. -/
def dripChi (st : Ledger) : Except Failure (Word 192) :=
  if st.timestamp = st.rho then
    if st.chi.value = 0 then .error .divisionByZero else .ok st.chi
  else
    .error .divisionByZero

def guardReceiver (receiver : Addr) : Except Failure Unit :=
  if validReceiver receiver = false then .error .invalidAddress else .ok ()

/-- Transfer/mint body. Kept behind this binder so address-refusal proofs do not
unfold `Word.checked` at width 256. -/
@[irreducible] def mintAfterGuard (st : Ledger) (assets shares : Word 256)
    (receiver sender : Addr) : Except Failure (Ledger × Word 256) :=
  match usdsTransferFrom st sender .vault .vault assets.value with
  | .error e => .error e
  | .ok st1 =>
    match mintShares st1 receiver shares.value with
    | .error e => .error e
    | .ok st2 => .ok (st2, shares)

/-- Address refusal is the first `_mint` guard and precedes `transferFrom`. -/
def depositImpl (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    convertToShares assets chi >>= fun shares =>
      guardReceiver receiver >>= fun _ =>
        mintAfterGuard st assets shares receiver sender

def deposit (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  depositImpl st assets receiver sender

def mint (st : Ledger) (shares : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    previewMint shares chi >>= fun assets =>
      guardReceiver receiver >>= fun _ =>
        match mintAfterGuard st assets shares receiver sender with
        | .error e => .error e
        | .ok (st2, _) => .ok (st2, assets)

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

-- BEGIN PROOFS

theorem validReceiver_zero : validReceiver .zero = false := by
  simp [validReceiver]

theorem validReceiver_self : validReceiver .vault = false := by
  simp [validReceiver]

theorem validReceiver_R : validReceiver .R = true := by
  simp [validReceiver]

theorem dripChi_stable (st : Ledger) (h : st.timestamp = st.rho) (hchi : 0 < st.chi.value) :
    dripChi st = .ok st.chi := by
  unfold dripChi
  simp [h, Nat.ne_of_gt hchi]

theorem guardReceiver_zero : guardReceiver .zero = .error .invalidAddress := by
  unfold guardReceiver
  rw [validReceiver_zero]
  exact if_pos rfl

theorem guardReceiver_self : guardReceiver .vault = .error .invalidAddress := by
  unfold guardReceiver
  rw [validReceiver_self]
  exact if_pos rfl

theorem bind_ok {α β} (a : α) (f : α → Except Failure β) :
    bind (Except.ok a) f = f a := rfl

theorem bind_error {α β} (e : Failure) (f : α → Except Failure β) :
    bind (Except.error e : Except Failure α) f = .error e := rfl

theorem deposit_eq_impl (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    deposit st assets receiver sender = depositImpl st assets receiver sender := rfl

theorem deposit_after_drip (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    deposit st assets receiver sender =
      convertToShares assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          mintAfterGuard st assets shares receiver sender := by
  rw [deposit_eq_impl]
  unfold depositImpl
  rw [hchi]
  exact bind_ok chi _

theorem deposit_invalid_zero (st : Ledger) (assets : Word 256) (sender : Addr)
    (hchi : dripChi st = .ok st.chi)
    (hconv : ∃ shares, convertToShares assets st.chi = .ok shares) :
    deposit st assets .zero sender = .error .invalidAddress := by
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip st assets .zero sender st.chi hchi, hs, bind_ok, guardReceiver_zero,
    bind_error]

theorem deposit_invalid_self (st : Ledger) (assets : Word 256) (sender : Addr)
    (hchi : dripChi st = .ok st.chi)
    (hconv : ∃ shares, convertToShares assets st.chi = .ok shares) :
    deposit st assets .vault sender = .error .invalidAddress := by
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip st assets .vault sender st.chi hchi, hs, bind_ok, guardReceiver_self,
    bind_error]

theorem deposit_mulOverflow (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hov : 2 ^ 256 ≤ assets.value * rayWord.value) :
    deposit st assets receiver sender = .error .mulOverflow := by
  rw [deposit_after_drip st assets receiver sender chi hchi]
  rw [convertToShares_mulOverflow assets chi hov]
  exact bind_error .mulOverflow _

theorem mintAfterGuard_ok_shares (st : Ledger) (assets shares : Word 256)
    (receiver sender : Addr) (st' : Ledger) (resShares : Word 256)
    (h : mintAfterGuard st assets shares receiver sender = .ok (st', resShares)) :
    resShares = shares := by
  unfold mintAfterGuard at h
  cases ht : usdsTransferFrom st sender .vault .vault assets.value with
  | error e =>
    rw [ht] at h
    contradiction
  | ok st1 =>
    rw [ht] at h
    dsimp at h
    cases hm : mintShares st1 receiver shares.value with
    | error e =>
      rw [hm] at h
      contradiction
    | ok st2 =>
      rw [hm] at h
      dsimp at h
      injection h with h1
      injection h1 with _ hres
      exact hres.symm

theorem deposit_success_shares (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (shares : Word 256)
    (hdep : deposit st assets receiver sender = .ok (st', shares)) :
    convertToShares assets chi = .ok shares := by
  rw [deposit_after_drip st assets receiver sender chi hchi] at hdep
  cases hc : convertToShares assets chi with
  | error e =>
    rw [hc] at hdep
    contradiction
  | ok s =>
    rw [hc] at hdep
    change (guardReceiver receiver >>= fun _ => mintAfterGuard st assets s receiver sender) =
      .ok (st', shares) at hdep
    cases hg : guardReceiver receiver with
    | error e =>
      rw [hg] at hdep
      contradiction
    | ok u =>
      rw [hg] at hdep
      change mintAfterGuard st assets s receiver sender = .ok (st', shares) at hdep
      have hs := mintAfterGuard_ok_shares st assets s receiver sender st' shares hdep
      subst hs
      rfl

theorem deposit_floor_shares (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (hpos : 0 < chi.value)
    (hprod : assets.value * rayWord.value < 2 ^ 256) (st' : Ledger) (shares : Word 256)
    (hdep : deposit st assets receiver sender = .ok (st', shares)) :
    shares.value * chi.value ≤ assets.value * rayWord.value ∧
      assets.value * rayWord.value < (shares.value + 1) * chi.value := by
  have hc := deposit_success_shares st assets receiver sender chi hchi st' shares hdep
  exact (convertToShares_floor assets chi shares hpos hprod).mp hc

theorem mint_after_drip (st : Ledger) (shares : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    mint st shares receiver sender =
      previewMint shares chi >>= fun assets =>
        guardReceiver receiver >>= fun _ =>
          match mintAfterGuard st assets shares receiver sender with
          | .error e => .error e
          | .ok (st2, _) => .ok (st2, assets) := by
  unfold mint
  rw [hchi]
  exact bind_ok chi _

theorem mint_invalid_zero (st : Ledger) (shares : Word 256) (sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hprev : ∃ assets, previewMint shares chi = .ok assets) :
    mint st shares .zero sender = .error .invalidAddress := by
  obtain ⟨assets, ha⟩ := hprev
  rw [mint_after_drip st shares .zero sender chi hchi, ha, bind_ok, guardReceiver_zero,
    bind_error]

theorem mint_invalid_self (st : Ledger) (shares : Word 256) (sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hprev : ∃ assets, previewMint shares chi = .ok assets) :
    mint st shares .vault sender = .error .invalidAddress := by
  obtain ⟨assets, ha⟩ := hprev
  rw [mint_after_drip st shares .vault sender chi hchi, ha, bind_ok, guardReceiver_self,
    bind_error]

theorem mint_success_assets (st : Ledger) (shares : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (assets : Word 256)
    (hmint : mint st shares receiver sender = .ok (st', assets)) :
    previewMint shares chi = .ok assets := by
  rw [mint_after_drip st shares receiver sender chi hchi] at hmint
  cases hp : previewMint shares chi with
  | error e =>
    rw [hp] at hmint
    contradiction
  | ok a =>
    rw [hp] at hmint
    dsimp [bind, Except.bind] at hmint
    cases hg : guardReceiver receiver with
    | error e =>
      rw [hg] at hmint
      contradiction
    | ok u =>
      rw [hg] at hmint
      dsimp [bind, Except.bind] at hmint
      cases hm : mintAfterGuard st a shares receiver sender with
      | error e =>
        rw [hm] at hmint
        contradiction
      | ok pair =>
        rw [hm] at hmint
        dsimp at hmint
        injection hmint with h1
        injection h1 with _ ha
        rw [ha]

theorem mint_ceil_assets (st : Ledger) (shares : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hprod : shares.value * chi.value < 2 ^ 256) (st' : Ledger) (assets : Word 256)
    (hmint : mint st shares receiver sender = .ok (st', assets)) :
    Rounding.divideNat .up (shares.value * chi.value) rayWord.value = .ok assets.value := by
  have hp := mint_success_assets st shares receiver sender chi hchi st' assets hmint
  exact (previewMint_ok shares chi assets hprod).mp hp

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

theorem redeem_floor_assets (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (hprod : shares.value * chi.value < 2 ^ 256) (st' : Ledger) (assets : Word 256)
    (hred : redeem st shares receiver owner caller = .ok (st', assets)) :
    Rounding.divideNat .down (shares.value * chi.value) rayWord.value = .ok assets.value := by
  have hc := redeem_success_assets st shares receiver owner caller chi hchi st' assets hred
  exact (convertToAssets_ok shares chi assets hprod).mp hc

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

theorem withdraw_ceil_shares (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (hpos : 0 < chi.value)
    (hprod : assets.value * rayWord.value < 2 ^ 256) (st' : Ledger) (shares : Word 256)
    (hwd : withdraw st assets receiver owner caller = .ok (st', shares)) :
    Rounding.divideNat .up (assets.value * rayWord.value) chi.value = .ok shares.value := by
  have hp := withdraw_success_shares st assets receiver owner caller chi hchi st' shares hwd
  exact (previewWithdraw_ok assets chi shares hpos hprod).mp hp

theorem mintAfterGuard_transfer_error (st : Ledger) (assets shares : Word 256)
    (receiver sender : Addr) (e : Failure)
    (htf : usdsTransferFrom st sender .vault .vault assets.value = .error e) :
    mintAfterGuard st assets shares receiver sender = .error e := by
  unfold mintAfterGuard
  rw [htf]

theorem deposit_transfer_error (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (shares : Word 256) (hconv : convertToShares assets chi = .ok shares)
    (hrec : validReceiver receiver = true) (e : Failure)
    (htf : usdsTransferFrom st sender .vault .vault assets.value = .error e) :
    deposit st assets receiver sender = .error e := by
  rw [deposit_after_drip st assets receiver sender chi hchi, hconv, bind_ok]
  unfold guardReceiver
  rw [hrec]
  change (bind (Except.ok ()) _) = .error e
  rw [bind_ok]
  exact mintAfterGuard_transfer_error st assets shares receiver sender e htf

theorem mintShares_success (st : Ledger) (receiver : Addr) (shares : Nat)
    (hrec : validReceiver receiver = true)
    (hts : st.totalSupply.value + shares < uint256Bound)
    (hbal : st.susds receiver + shares < uint256Bound) :
    mintShares st receiver shares = .ok { st with
      totalSupply := ⟨st.totalSupply.value + shares, by unfold uint256Bound at hts; exact hts⟩
      susds := fun a => if a = receiver then st.susds receiver + shares else st.susds a } := by
  unfold mintShares
  rw [hrec]
  change (if (true = false) then _ else _) = _
  rw [if_neg (fun h => Bool.noConfusion h)]
  have h1 : ¬ (uint256Bound ≤ st.totalSupply.value + shares) := not_le_of_gt hts
  have h2 : ¬ (uint256Bound ≤ st.susds receiver + shares) := not_le_of_gt hbal
  rw [if_neg h1, if_neg h2]
  have hchk : Word.checked (w := 256) .addOverflow (st.totalSupply.value + shares) =
      .ok ⟨st.totalSupply.value + shares, by unfold uint256Bound at hts; exact hts⟩ := by
    exact (Word.checked_ok_iff (w := 256) .addOverflow (st.totalSupply.value + shares)
      ⟨st.totalSupply.value + shares, by unfold uint256Bound at hts; exact hts⟩).mpr rfl
  rw [hchk, mapError_ok]
  rfl

theorem mintAfterGuard_success (st : Ledger) (assets shares : Word 256)
    (receiver sender : Addr) (st1 : Ledger)
    (htf : usdsTransferFrom st sender .vault .vault assets.value = .ok st1)
    (hrec : validReceiver receiver = true)
    (hts : st1.totalSupply.value + shares.value < uint256Bound)
    (hbal : st1.susds receiver + shares.value < uint256Bound) :
    mintAfterGuard st assets shares receiver sender =
      .ok ({ st1 with
        totalSupply := ⟨st1.totalSupply.value + shares.value,
          by unfold uint256Bound at hts; exact hts⟩
        susds := fun a => if a = receiver then st1.susds receiver + shares.value else st1.susds a },
        shares) := by
  unfold mintAfterGuard
  rw [htf]
  have hms := mintShares_success st1 receiver shares.value hrec hts hbal
  dsimp
  rw [hms]

theorem burnShares_insufficientBalance (st : Ledger) (owner caller : Addr) (shares : Nat)
    (hbal : st.susds owner < shares) :
    burnShares st owner caller shares = .error .insufficientBalance := by
  unfold burnShares
  rw [if_pos hbal]
  rfl

theorem burnShares_insufficientAllowance (st : Ledger) (owner caller : Addr) (shares : Nat)
    (hbal : shares ≤ st.susds owner) (hne : owner ≠ caller)
    (hfinite : st.susdsAllow owner caller ≠ uint256Max)
    (hallow : st.susdsAllow owner caller < shares) :
    burnShares st owner caller shares = .error .insufficientAllowance := by
  unfold burnShares
  rw [if_neg (not_lt_of_ge hbal), if_pos hne, if_pos hfinite, if_pos hallow]
  rfl

theorem redeem_burn_error (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (assets : Word 256) (hconv : convertToAssets shares chi = .ok assets)
    (e : Failure) (hburn : burnShares st owner caller shares.value = .error e) :
    redeem st shares receiver owner caller = .error e := by
  unfold redeem
  rw [hchi, bind_ok, hconv, bind_ok, hburn]
  rfl

theorem withdraw_burn_error (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi)
    (shares : Word 256) (hprev : previewWithdraw assets chi = .ok shares)
    (e : Failure) (hburn : burnShares st owner caller shares.value = .error e) :
    withdraw st assets receiver owner caller = .error e := by
  unfold withdraw
  rw [hchi, bind_ok, hprev, bind_ok, hburn]
  rfl

theorem burnShares_success_self (st : Ledger) (owner : Addr) (shares : Nat)
    (hbal : shares ≤ st.susds owner)
    (hts : shares ≤ st.totalSupply.value) :
    burnShares st owner owner shares = .ok { st with
      totalSupply := ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩
      susds := fun a => if a = owner then st.susds owner - shares else st.susds a } := by
  unfold burnShares
  rw [if_neg (not_lt_of_ge hbal), if_neg (fun h => h rfl)]
  rw [if_neg (not_lt_of_ge hts)]
  have hchk : Word.checked (w := 256) .subUnderflow (st.totalSupply.value - shares) =
      .ok ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩ := by
    exact (Word.checked_ok_iff (w := 256) .subUnderflow (st.totalSupply.value - shares)
      ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩).mpr rfl
  rw [hchk, mapError_ok]

theorem burnShares_success_delegated (st : Ledger) (owner caller : Addr) (shares : Nat)
    (hbal : shares ≤ st.susds owner) (hne : owner ≠ caller)
    (hfinite : st.susdsAllow owner caller ≠ uint256Max)
    (hallow : shares ≤ st.susdsAllow owner caller)
    (hts : shares ≤ st.totalSupply.value) :
    burnShares st owner caller shares = .ok { st with
      susdsAllow := fun o s =>
        if o = owner ∧ s = caller then st.susdsAllow owner caller - shares else st.susdsAllow o s
      totalSupply := ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩
      susds := fun a => if a = owner then st.susds owner - shares else st.susds a } := by
  unfold burnShares
  rw [if_neg (not_lt_of_ge hbal), if_pos hne, if_pos hfinite, if_neg (not_lt_of_ge hallow)]
  rw [if_neg (not_lt_of_ge hts)]
  have hchk : Word.checked (w := 256) .subUnderflow (st.totalSupply.value - shares) =
      .ok ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩ := by
    exact (Word.checked_ok_iff (w := 256) .subUnderflow (st.totalSupply.value - shares)
      ⟨st.totalSupply.value - shares,
        Nat.lt_of_le_of_lt (Nat.sub_le _ _) st.totalSupply.bound⟩).mpr rfl
  rw [hchk, mapError_ok]

end DefiKernel.Vault
