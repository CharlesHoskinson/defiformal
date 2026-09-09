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


-- ===================== OPUS DIAGNOSTIC LADDER (not production) =====================
-- Stand-ins used only to bisect which subterm drives kernel defeq cost.

@[irreducible] def tailStub (st : Ledger) (_assets shares : Word 256)
    (_receiver _sender : Addr) : Except Failure (Ledger × Word 256) :=
  .ok (st, shares)

@[irreducible] def convStub (assets : Word 256) (_chi : Word 192) :
    Except Failure (Word 256) := .ok assets

def depositC (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    convStub assets chi >>= fun shares =>
      guardReceiver receiver >>= fun _ =>
        tailStub st assets shares receiver sender

def depositA (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    convertToShares assets chi >>= fun shares =>
      guardReceiver receiver >>= fun _ =>
        tailStub st assets shares receiver sender

def depositB (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    Except Failure (Ledger × Word 256) :=
  dripChi st >>= fun chi =>
    convStub assets chi >>= fun shares =>
      guardReceiver receiver >>= fun _ =>
        mintAfterGuard st assets shares receiver sender

-- Generic Except congruence lemma, proved at a fully abstract type.
theorem bindOkGen {ε α β} (a : α) (f : α → Except ε β) :
    (Except.ok a : Except ε α) >>= f = f a := rfl

-- L-C : both stubs, current-style proof script
theorem depositC_def (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    depositC st assets receiver sender =
      dripChi st >>= fun chi =>
        convStub assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            tailStub st assets shares receiver sender := rfl

theorem depositC_after_drip (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    depositC st assets receiver sender =
      convStub assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          tailStub st assets shares receiver sender := by
  rw [depositC_def, hchi]
  simp [bind, Except.bind]

-- L-A : real convertToShares, stub tail
theorem depositA_def (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    depositA st assets receiver sender =
      dripChi st >>= fun chi =>
        convertToShares assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            tailStub st assets shares receiver sender := rfl

theorem depositA_after_drip (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    depositA st assets receiver sender =
      convertToShares assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          tailStub st assets shares receiver sender := by
  rw [depositA_def, hchi]
  simp [bind, Except.bind]

-- L-B : stub conversion, real mintAfterGuard tail
theorem depositB_def (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    depositB st assets receiver sender =
      dripChi st >>= fun chi =>
        convStub assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            mintAfterGuard st assets shares receiver sender := rfl

theorem depositB_after_drip (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    depositB st assets receiver sender =
      convStub assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          mintAfterGuard st assets shares receiver sender := by
  rw [depositB_def, hchi]
  simp [bind, Except.bind]

-- L-D : REAL deposit, repair candidate: generic bind lemma instead of `simp [bind, Except.bind]`
theorem deposit_def' (st : Ledger) (assets : Word 256) (receiver sender : Addr) :
    deposit st assets receiver sender =
      dripChi st >>= fun chi =>
        convertToShares assets chi >>= fun shares =>
          guardReceiver receiver >>= fun _ =>
            mintAfterGuard st assets shares receiver sender := rfl

theorem deposit_after_drip_repair (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    deposit st assets receiver sender =
      convertToShares assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          mintAfterGuard st assets shares receiver sender := by
  rw [deposit_def', hchi]
  exact bindOkGen chi _

-- L-E : control, real deposit with the current frozen proof script
theorem deposit_after_drip_control (st : Ledger) (assets : Word 256) (receiver sender : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    deposit st assets receiver sender =
      convertToShares assets chi >>= fun shares =>
        guardReceiver receiver >>= fun _ =>
          mintAfterGuard st assets shares receiver sender := by
  rw [deposit_def', hchi]
  simp [bind, Except.bind]

end DefiKernel.Vault
