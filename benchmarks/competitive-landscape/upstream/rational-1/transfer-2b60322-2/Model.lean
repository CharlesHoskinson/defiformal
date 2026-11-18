import DefiKernel.Examples
import Aesop

namespace RationalTransfer

abbrev Account := DefiKernel.Account
abbrev Principal := DefiKernel.Account
abbrev Cell := DefiKernel.Cell

inductive Asset where
  | cash | shareA | shareB
  deriving DecidableEq, Repr

def Asset.native : Asset → DefiKernel.Asset
  | .cash => .usd
  | .shareA => .share
  | .shareB => .collateral

inductive Operation where
  | transfer | deposit | withdraw
  deriving DecidableEq, Repr

inductive Capability where
  | invoke (actor : Principal) (operation : Operation)
  | debit (actor : Principal) (account : Account) (asset : Asset)
  | supply (actor : Principal) (vaultB : Bool)
  deriving DecidableEq, Repr

inductive RecordedCall where
  | transfer (actor : Principal) (source target : Account) (asset : Asset) (amount : ℚ)
  | deposit (actor : Principal) (user : Account) (vaultB : Bool) (amount : ℚ)
  | withdraw (actor : Principal) (user : Account) (vaultB : Bool) (amount : ℚ)
  | grant (actor : Principal) (capability : Capability)
  | revoke (actor : Principal) (capability : Capability)
  deriving DecidableEq, Repr

structure Event where
  call : RecordedCall
  delta : Cell → ℚ
  issued : Asset → ℚ
  burned : Asset → ℚ

-- The fourth native asset is unused. Canonical encodings set its four cells to zero.
-- The theorem below is stronger: those cells may be arbitrary and remain framed.
structure PublicState where
  ledger : DefiKernel.State
  rates : Bool → ℚ
  capabilities : Finset Capability
  history : List Event

-- Supply is a derived field, which is equivalent to the canonical valid-state equality.
def PublicState.supply (state : PublicState) (asset : Asset) : ℚ :=
  DefiKernel.total state.ledger asset.native

def ValidState (state : PublicState) : Prop :=
  (∀ vault, 0 < state.rates vault) ∧
  (∀ account, state.ledger.balance (account, .debt) = 0)

inductive Number where
  | exact (value : ℚ)
  | malformed (description : String)

inductive RawCall where
  | transfer (actor source target asset : String) (amount : Number)
  | unsupported (tag : String)

inductive Reason where
  | badOperation | badTarget | badNumber | badAmount | unauthorized | insufficientFunds
  | nativeFailure (reason : DefiKernel.Refusal)
  deriving DecidableEq, Repr

inductive Result where
  | success (state : PublicState)
  | refused (reason : Reason) (state : PublicState)

def Result.publicState : Result → PublicState
  | .success state | .refused _ state => state

def decodePrincipal : String → Option Principal
  | "alice" => some .alice
  | "bob" => some .bob
  | "operator" => some .vault
  | "admin" => some .pool
  | _ => none

def decodeAccount : String → Option Account
  | "alice" => some .alice
  | "bob" => some .bob
  | "vaultA" => some .vault
  | "vaultB" => some .pool
  | _ => none

def decodeAsset : String → Option Asset
  | "cash" => some .cash
  | "shareA" => some .shareA
  | "shareB" => some .shareB
  | _ => none

def nativeAsset : DefiKernel.Asset → Option Asset
  | .usd => some .cash
  | .share => some .shareA
  | .collateral => some .shareB
  | .debt => none

def policy (state : PublicState) : DefiKernel.Policy where
  debit actor cell := match nativeAsset cell.2 with
    | some asset => decide (.debit actor cell.1 asset ∈ state.capabilities)
    | none => false
  supply _ _ := false

-- This generalizes the upstream USD-only transfer constructor to the three canonical assets.
-- The native move, check, execute, application, accounting, and frame definitions are unchanged.
def transition (actor : Principal) (source target : Account) (asset : Asset) (amount : ℚ) :
    DefiKernel.Transition Unit where
  actor := actor
  effect := DefiKernel.Examples.move asset.native source target amount
  supplyChange := fun _ => 0
  writes := {(source, asset.native), (target, asset.native)}
  guard := fun _ _ => true

def event (actor : Principal) (source target : Account) (asset : Asset) (amount : ℚ) : Event where
  call := .transfer actor source target asset amount
  delta := (transition actor source target asset amount).effect
  issued := fun _ => 0
  burned := fun _ => 0

def Authorized (state : PublicState) (actor : Principal) (source : Account) (asset : Asset) : Prop :=
  .invoke actor .transfer ∈ state.capabilities ∧ .debit actor source asset ∈ state.capabilities

instance (state : PublicState) (actor : Principal) (source : Account) (asset : Asset) :
    Decidable (Authorized state actor source asset) := inferInstanceAs (Decidable (_ ∧ _))

def publish (state : PublicState) (ledger : DefiKernel.State)
    (actor : Principal) (source target : Account) (asset : Asset) (amount : ℚ) : PublicState :=
  { state with ledger := ledger, history := state.history ++ [event actor source target asset amount] }

def transfer (state : PublicState) (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) : Result :=
  if amount < 0 then .refused .badAmount state
  else if ¬ Authorized state actor source asset then .refused .unauthorized state
  else if state.ledger.balance (source, asset.native) < amount then .refused .insufficientFunds state
  else match DefiKernel.execute (policy state) () (transition actor source target asset amount) state.ledger with
    | .error reason => .refused (.nativeFailure reason) state
    | .ok ledger => .success (publish state ledger actor source target asset amount)

def execute (state : PublicState) : RawCall → Result
  | .unsupported _ => .refused .badOperation state
  | .transfer actor source target asset amount =>
    match decodePrincipal actor, decodeAccount source, decodeAccount target, decodeAsset asset with
    | some p, some s, some t, some e =>
      match amount with
      | .malformed _ => .refused .badNumber state
      | .exact q => transfer state p s t e q
    | _, _, _, _ => .refused .badTarget state

-- BEGIN SPECIFICATION

def SuccessDomain (state : PublicState) (actor : Principal) (source : Account)
    (asset : Asset) (amount : ℚ) : Prop :=
  0 ≤ amount ∧ Authorized state actor source asset ∧ amount ≤ state.ledger.balance (source, asset.native)

def SuccessClaims (state post : PublicState) (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) : Prop :=
  DefiKernel.execute (policy state) () (transition actor source target asset amount) state.ledger = .ok post.ledger ∧
  (∀ cell, post.ledger.balance cell = state.ledger.balance cell +
    (-amount * (if cell = (source, asset.native) then 1 else 0) +
      amount * (if cell = (target, asset.native) then 1 else 0))) ∧
  (∀ cell, 0 ≤ post.ledger.balance cell) ∧
  (∀ e, post.supply e = state.supply e) ∧
  post.rates = state.rates ∧ post.capabilities = state.capabilities ∧
  post.history = state.history ++ [event actor source target asset amount] ∧
  (∀ cell, cell ≠ (source, asset.native) → cell ≠ (target, asset.native) →
    post.ledger.balance cell = state.ledger.balance cell) ∧
  (∀ e, post.supply e = state.supply e + (event actor source target asset amount).issued e -
      (event actor source target asset amount).burned e) ∧
  (ValidState state → ValidState post)

def TypedCanonical : Prop := ∀ state actor source target asset amount,
  (SuccessDomain state actor source asset amount →
    ∃ post, transfer state actor source target asset amount = .success post ∧
      SuccessClaims state post actor source target asset amount) ∧
  (amount < 0 → transfer state actor source target asset amount = .refused .badAmount state) ∧
  (0 ≤ amount → ¬ Authorized state actor source asset →
    transfer state actor source target asset amount = .refused .unauthorized state) ∧
  (0 ≤ amount → Authorized state actor source asset → state.ledger.balance (source, asset.native) < amount →
    transfer state actor source target asset amount = .refused .insufficientFunds state)

def RawCanonical : Prop :=
  (∀ state tag, execute state (.unsupported tag) = .refused .badOperation state) ∧
  (∀ state actor source target asset amount,
    (decodePrincipal actor = none ∨ decodeAccount source = none ∨
      decodeAccount target = none ∨ decodeAsset asset = none) →
    execute state (.transfer actor source target asset amount) = .refused .badTarget state) ∧
  (∀ state actor source target asset p s t e bad,
    decodePrincipal actor = some p → decodeAccount source = some s →
    decodeAccount target = some t → decodeAsset asset = some e →
    execute state (.transfer actor source target asset (.malformed bad)) = .refused .badNumber state) ∧
  (∀ state actor source target asset p s t e q,
    decodePrincipal actor = some p → decodeAccount source = some s →
    decodeAccount target = some t → decodeAsset asset = some e →
    execute state (.transfer actor source target asset (.exact q)) = transfer state p s t e q)

def Canonical : Prop := TypedCanonical ∧ RawCanonical

end RationalTransfer
