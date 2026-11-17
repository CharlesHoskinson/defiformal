import DefiKernel.Examples
import Aesop
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

namespace RationalWorkflow

abbrev Account := DefiKernel.Account
abbrev Principal := DefiKernel.Account
abbrev Cell := DefiKernel.Cell
abbrev User := Bool
abbrev Vault := Bool

inductive Asset where
  | cash | shareA | shareB
  deriving DecidableEq, Repr

def Asset.native : Asset → DefiKernel.Asset
  | .cash => .usd | .shareA => .share | .shareB => .collateral

def userAccount : User → Account
  | false => .alice | true => .bob
def vaultAccount : Vault → Account
  | false => .vault | true => .pool
def shareAsset : Vault → Asset
  | false => .shareA | true => .shareB

inductive Operation where
  | transfer | deposit | withdraw
  deriving DecidableEq, Repr
inductive Capability where
  | invoke (actor : Principal) (operation : Operation)
  | debit (actor : Principal) (account : Account) (asset : Asset)
  | supply (actor : Principal) (vault : Vault)
  deriving DecidableEq, Repr
inductive Call where
  | transfer (actor : Principal) (source target : Account) (asset : Asset) (amount : ℚ)
  | deposit (actor : Principal) (user : User) (vault : Vault) (amount : ℚ)
  | withdraw (actor : Principal) (user : User) (vault : Vault) (amount : ℚ)
  | grant (actor : Principal) (capability : Capability)
  | revoke (actor : Principal) (capability : Capability)
  deriving DecidableEq, Repr

def Call.actor : Call → Principal
  | .transfer p _ _ _ _ | .deposit p _ _ _ | .withdraw p _ _ _
  | .grant p _ | .revoke p _ => p

def effect (rates : Vault → ℚ) : Call → Cell → ℚ
  | .transfer _ s t e q => DefiKernel.Examples.move e.native s t q
  | .deposit _ u v q => fun c =>
      DefiKernel.Examples.move .usd (userAccount u) (vaultAccount v) q c +
      DefiKernel.Examples.pulse (userAccount u, (shareAsset v).native) (q / rates v) c
  | .withdraw _ u v q => fun c =>
      DefiKernel.Examples.move .usd (vaultAccount v) (userAccount u) (q * rates v) c -
      DefiKernel.Examples.pulse (userAccount u, (shareAsset v).native) q c
  | .grant _ _ | .revoke _ _ => fun _ => 0

def issued (rates : Vault → ℚ) : Call → Asset → ℚ
  | .deposit _ _ v q => fun e => if e = shareAsset v then q / rates v else 0
  | _ => fun _ => 0
def burned (_rates : Vault → ℚ) : Call → Asset → ℚ
  | .withdraw _ _ v q => fun e => if e = shareAsset v then q else 0
  | _ => fun _ => 0

def writes : Call → Finset Cell
  | .transfer _ s t e _ => {(s, e.native), (t, e.native)}
  | .deposit _ u v _ | .withdraw _ u v _ =>
      {(userAccount u, .usd), (vaultAccount v, .usd), (userAccount u, (shareAsset v).native)}
  | .grant _ _ | .revoke _ _ => ∅

structure Event where
  calls : List Call
  delta : Cell → ℚ
  issued : Asset → ℚ
  burned : Asset → ℚ

def event (rates : Vault → ℚ) (call : Call) : Event :=
  ⟨[call], effect rates call, issued rates call, burned rates call⟩

structure PublicState where
  ledger : DefiKernel.State
  rates : Vault → ℚ
  capabilities : Finset Capability
  history : List Event

def PublicState.supply (state : PublicState) (asset : Asset) : ℚ :=
  DefiKernel.total state.ledger asset.native
def surplus (state : PublicState) (vault : Vault) : ℚ :=
  state.ledger.balance (vaultAccount vault, .usd) - state.rates vault * state.supply (shareAsset vault)
def ValidState (state : PublicState) : Prop :=
  (∀ v, 0 < state.rates v) ∧ (∀ a, state.ledger.balance (a, .debt) = 0)

def nextCapabilities (caps : Finset Capability) : Call → Finset Capability
  | .grant _ c => insert c caps | .revoke _ c => caps.erase c | _ => caps

def requiredCapabilities : Call → Finset Capability
  | .transfer p s _ e _ => {.invoke p .transfer, .debit p s e}
  | .deposit p u v _ => {.invoke p .deposit, .debit p (userAccount u) .cash, .supply p v}
  | .withdraw p u v _ => {.invoke p .withdraw, .debit p (userAccount u) (shareAsset v),
      .debit p (vaultAccount v) .cash, .supply p v}
  | _ => ∅

def Authorized (caps : Finset Capability) : Call → Prop
  | .transfer p s _ e _ => .invoke p .transfer ∈ caps ∧ .debit p s e ∈ caps
  | .deposit p u v _ => .invoke p .deposit ∈ caps ∧
      .debit p (userAccount u) .cash ∈ caps ∧ .supply p v ∈ caps
  | .withdraw p u v _ => .invoke p .withdraw ∈ caps ∧
      .debit p (userAccount u) (shareAsset v) ∈ caps ∧
      .debit p (vaultAccount v) .cash ∈ caps ∧ .supply p v ∈ caps
  | .grant p _ | .revoke p _ => p = .pool
def AmountValid : Call → Prop
  | .transfer _ _ _ _ q | .deposit _ _ _ q | .withdraw _ _ _ q => 0 ≤ q
  | _ => True
def Funded (balances : Cell → ℚ) (rates : Vault → ℚ) : Call → Prop
  | .transfer _ s _ e q => q ≤ balances (s, e.native)
  | .deposit _ u _ q => q ≤ balances (userAccount u, .usd)
  | .withdraw _ u v q => q ≤ balances (userAccount u, (shareAsset v).native) ∧
      q * rates v ≤ balances (vaultAccount v, .usd)
  | _ => True

instance (caps : Finset Capability) (call : Call) : Decidable (Authorized caps call) := by
  cases call <;> unfold Authorized <;> infer_instance
instance (call : Call) : Decidable (AmountValid call) := by
  cases call <;> unfold AmountValid <;> infer_instance
instance (b : Cell → ℚ) (r : Vault → ℚ) (call : Call) : Decidable (Funded b r call) := by
  cases call <;> unfold Funded <;> infer_instance

def SuccessDomain (state : PublicState) (call : Call) : Prop :=
  AmountValid call ∧ Authorized state.capabilities call ∧ Funded state.ledger.balance state.rates call

def nativeAsset : DefiKernel.Asset → Option Asset
  | .usd => some .cash | .share => some .shareA | .collateral => some .shareB | .debt => none
def policy (caps : Finset Capability) : DefiKernel.Policy where
  debit actor cell := match nativeAsset cell.2 with
    | some asset => decide (.debit actor cell.1 asset ∈ caps)
    | none => false
  supply actor asset := match asset with
    | .share => decide (.supply actor false ∈ caps)
    | .collateral => decide (.supply actor true ∈ caps)
    | _ => false
def transition (rates : Vault → ℚ) (call : Call) : DefiKernel.Transition Unit where
  actor := call.actor
  effect := effect rates call
  supplyChange := fun a => match nativeAsset a with
    | some e => issued rates call e - burned rates call e
    | none => 0
  writes := writes call
  guard := fun _ _ => true

inductive Reason where
  | badOperation | badTarget | badNumber | badAmount | unauthorized | insufficientFunds
  | nativeFailure (reason : DefiKernel.Refusal)
  deriving DecidableEq, Repr
inductive Result where
  | success (state : PublicState)
  | refused (reason : Reason) (state : PublicState)
def Result.publicState : Result → PublicState
  | .success s | .refused _ s => s

def publish (state : PublicState) (ledger : DefiKernel.State) (call : Call) : PublicState :=
  { state with
    ledger := ledger
    capabilities := nextCapabilities state.capabilities call
    history := state.history ++ [event state.rates call] }

-- Guards are the explicit source-domain requirements, never the desired postconditions.
-- The financial state update and finite accounting/authority/locality checks execute upstream.
def execute (state : PublicState) (call : Call) : Result :=
  if ¬ AmountValid call then .refused .badAmount state
  else if ¬ Authorized state.capabilities call then .refused .unauthorized state
  else if ¬ Funded state.ledger.balance state.rates call then .refused .insufficientFunds state
  else match DefiKernel.execute (policy state.capabilities) () (transition state.rates call) state.ledger with
    | .error reason => .refused (.nativeFailure reason) state
    | .ok ledger => .success (publish state ledger call)

inductive Number where
  | exact (value : ℚ) | malformed (description : String)
inductive RawCapability where
  | invoke (actor operation : String)
  | debit (actor account asset : String)
  | supply (actor vault : String)
inductive RawCall where
  | transfer (actor source target asset : String) (amount : Number)
  | deposit (actor user vault : String) (amount : Number)
  | withdraw (actor user vault : String) (amount : Number)
  | grant (actor : String) (capability : RawCapability)
  | revoke (actor : String) (capability : RawCapability)
  | unsupported (tag : String)

def decodePrincipal : String → Option Principal
  | "alice" => some .alice | "bob" => some .bob
  | "operator" => some .vault | "admin" => some .pool | _ => none
def decodeAccount : String → Option Account
  | "alice" => some .alice | "bob" => some .bob
  | "vaultA" => some .vault | "vaultB" => some .pool | _ => none
def decodeAsset : String → Option Asset
  | "cash" => some .cash | "shareA" => some .shareA | "shareB" => some .shareB | _ => none
def decodeUser : String → Option User
  | "alice" => some false | "bob" => some true | _ => none
def decodeVault : String → Option Vault
  | "vaultA" => some false | "vaultB" => some true | _ => none
def decodeOperation : String → Option Operation
  | "transfer" => some .transfer | "deposit" => some .deposit | "withdraw" => some .withdraw | _ => none
def decodeCapability : RawCapability → Option Capability
  | .invoke p k => return .invoke (← decodePrincipal p) (← decodeOperation k)
  | .debit p a e => return .debit (← decodePrincipal p) (← decodeAccount a) (← decodeAsset e)
  | .supply p v => return .supply (← decodePrincipal p) (← decodeVault v)

def withNumber (state : PublicState) (make : ℚ → Call) : Number → Result
  | .exact q => execute state (make q)
  | .malformed _ => .refused .badNumber state
def rawExecute (state : PublicState) : RawCall → Result
  | .unsupported _ => .refused .badOperation state
  | .transfer p s t e q =>
    match decodePrincipal p, decodeAccount s, decodeAccount t, decodeAsset e with
    | some p, some s, some t, some e => withNumber state (.transfer p s t e) q
    | _, _, _, _ => .refused .badTarget state
  | .deposit p u v q =>
    match decodePrincipal p, decodeUser u, decodeVault v with
    | some p, some u, some v => withNumber state (.deposit p u v) q
    | _, _, _ => .refused .badTarget state
  | .withdraw p u v q =>
    match decodePrincipal p, decodeUser u, decodeVault v with
    | some p, some u, some v => withNumber state (.withdraw p u v) q
    | _, _, _ => .refused .badTarget state
  | .grant p c => match decodePrincipal p, decodeCapability c with
    | some p, some c => execute state (.grant p c)
    | _, _ => .refused .badTarget state
  | .revoke p c => match decodePrincipal p, decodeCapability c with
    | some p, some c => execute state (.revoke p c)
    | _, _ => .refused .badTarget state

-- BEGIN SPECIFICATION
structure LocalClaims (pre post : PublicState) (call : Call) : Prop where
  native : DefiKernel.execute (policy pre.capabilities) () (transition pre.rates call) pre.ledger = .ok post.ledger
  balances : ∀ c, post.ledger.balance c = pre.ledger.balance c + effect pre.rates call c
  nonnegative : ∀ c, 0 ≤ post.ledger.balance c
  accounting : ∀ e, post.supply e = pre.supply e + issued pre.rates call e - burned pre.rates call e
  rates : post.rates = pre.rates
  capabilities : post.capabilities = nextCapabilities pre.capabilities call
  history : post.history = pre.history ++ [event pre.rates call]
  frame : ∀ c, c ∉ writes call → post.ledger.balance c = pre.ledger.balance c
  valid : ValidState pre → ValidState post
  issuance_nonnegative : AmountValid call → (∀ v, 0 < pre.rates v) → ∀ e,
    0 ≤ issued pre.rates call e ∧ 0 ≤ burned pre.rates call e

end RationalWorkflow
