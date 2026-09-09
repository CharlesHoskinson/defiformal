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
def deposit (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    convertToShares assets chi >>= fun shares =>
      guardReceiver receiver >>= fun _ =>
        mintAfterGuard st assets shares receiver sender

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

theorem deposit_def (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    deposit st assets receiver sender =
      dripChi st >>= fun chi =>
        convertToShares assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            mintAfterGuard st assets shares receiver sender := rfl

-- ===================== OPUS DIAGNOSTIC: MECHANISM + REPAIR (not production) =========

@[irreducible] def convStub (assets : Word 256) (_chi : Word 192) :
    Except Failure (Word 256) := .ok assets

/-- Generic Except congruence lemmas, proved once at fully abstract type. -/
theorem bindOkGen {ε α β} (a : α) (f : α → Except ε β) :
    (Except.ok a : Except ε α) >>= f = f a := rfl

theorem bindErrorGen {ε α β} (e : ε) (f : α → Except ε β) :
    (Except.error e : Except ε α) >>= f = (Except.error e : Except ε β) := rfl

-- P1 control: no Ledger, no guard, no tail; stub scrutinee under `simp [bind, Except.bind]`
theorem probe_control (e : Except Failure (Word 192)) (c : Word 192) (h : e = .ok c)
    (a : Word 256) (f : Word 256 → Except Failure (Word 256)) :
    (e >>= fun c => convStub a c >>= f) = (convStub a c >>= f) := by
  rw [h]
  simp [bind, Except.bind]

-- P2 bomb: identical, only the scrutinee is the arithmetic-carrying `convertToShares`
theorem probe_bomb (e : Except Failure (Word 192)) (c : Word 192) (h : e = .ok c)
    (a : Word 256) (f : Word 256 → Except Failure (Word 256)) :
    (e >>= fun c => convertToShares a c >>= f) = (convertToShares a c >>= f) := by
  rw [h]
  simp [bind, Except.bind]

-- P3 same minimal shape, repaired with the generic lemma
theorem probe_repair (e : Except Failure (Word 192)) (c : Word 192) (h : e = .ok c)
    (a : Word 256) (f : Word 256 → Except Failure (Word 256)) :
    (e >>= fun c => convertToShares a c >>= f) = (convertToShares a c >>= f) := by
  rw [h]
  exact bindOkGen c _

-- P4 mechanism probe: bind-vs-matcher defeq with arithmetic scrutinee, no tactic at all
theorem probe_matcher_stub (a : Word 256) (c : Word 192)
    (f : Word 256 → Except Failure (Word 256)) :
    (convStub a c >>= f) =
      (match convStub a c with | .error e => .error e | .ok s => f s) := rfl

theorem probe_matcher_bomb (a : Word 256) (c : Word 192)
    (f : Word 256 → Except Failure (Word 256)) :
    (convertToShares a c >>= f) =
      (match convertToShares a c with | .error e => .error e | .ok s => f s) := rfl

-- ===================== REPAIRED DEPOSIT CHAIN =====================

theorem deposit_def' (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    deposit st assets receiver sender =
      dripChi st >>= fun chi =>
        convertToShares assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            mintAfterGuard st assets shares receiver sender := rfl

theorem deposit_after_drip' (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    deposit st assets receiver sender =
      convertToShares assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          mintAfterGuard st assets shares receiver sender := by
  rw [deposit_def', hchi]
  exact bindOkGen chi _

theorem deposit_invalid_zero' (st : Ledger) (assets : Word 256) (sender : Addr)
    (hchi : dripChi st = .ok st.chi)
    (hconv : ∃ shares, convertToShares assets st.chi = .ok shares) :
    deposit st assets .zero sender = .error .invalidAddress := by
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip' st assets .zero sender st.chi hchi, hs, bindOkGen,
    guardReceiver_zero, bindErrorGen]

theorem deposit_invalid_self' (st : Ledger) (assets : Word 256) (sender : Addr)
    (hchi : dripChi st = .ok st.chi)
    (hconv : ∃ shares, convertToShares assets st.chi = .ok shares) :
    deposit st assets .vault sender = .error .invalidAddress := by
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip' st assets .vault sender st.chi hchi, hs, bindOkGen,
    guardReceiver_self, bindErrorGen]

-- simp only variant (no `Except.bind` unfolding) for the same two facts
theorem deposit_invalid_zero_simponly (st : Ledger) (assets : Word 256) (sender : Addr)
    (hchi : dripChi st = .ok st.chi)
    (hconv : ∃ shares, convertToShares assets st.chi = .ok shares) :
    deposit st assets .zero sender = .error .invalidAddress := by
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip' st assets .zero sender st.chi hchi]
  simp only [hs, bindOkGen, guardReceiver_zero, bindErrorGen]

end DefiKernel.Vault
