import WorkflowControl

namespace RationalWorkflow.Net

structure Instruction where
  actor : Principal
  source : Account
  target : Account
  asset : Asset
  amount : ℚ
  deriving DecidableEq, Repr

def Instruction.call (t : Instruction) : Call :=
  .transfer t.actor t.source t.target t.asset t.amount

def Instruction.delta (t : Instruction) : Cell → ℚ :=
  DefiKernel.Examples.move t.asset.native t.source t.target t.amount

def aggregate : List Instruction → Cell → ℚ
  | [] => fun _ => 0
  | t :: ts => fun c => t.delta c + aggregate ts c

def netTransition (actor : Principal) (ts : List Instruction) : DefiKernel.Transition Unit where
  actor := actor
  effect := aggregate ts
  supplyChange := fun _ => 0
  writes := Finset.univ
  guard := fun _ _ => true

def netEvent (ts : List Instruction) : Event :=
  ⟨ts.map Instruction.call, aggregate ts, fun _ => 0, fun _ => 0⟩

def netPublish (s : PublicState) (ledger : DefiKernel.State) (ts : List Instruction) : PublicState :=
  { s with ledger := ledger, history := s.history ++ [netEvent ts] }

def RecordValid (actor : Principal) (ts : List Instruction) : Prop :=
  ∀ t ∈ ts, t.actor = actor ∧ 0 ≤ t.amount

-- Declarative raw-input relation: exact encodings, matching actor and valid domains.
inductive RawMatches (actor : Principal) : RawCall → Instruction → Prop
  | exact (p source target asset : String) (s t : Account) (e : Asset) (q : ℚ)
      (principal : decodePrincipal p = some actor)
      (source_id : decodeAccount source = some s) (target_id : decodeAccount target = some t)
      (asset_id : decodeAsset asset = some e) (amount : 0 ≤ q) :
      RawMatches actor (.transfer p source target asset (.exact q)) ⟨actor, s, t, e, q⟩

def NetAuthorized (s : PublicState) (actor : Principal) (ts : List Instruction) : Prop :=
  .invoke actor .transfer ∈ s.capabilities ∧
  DefiKernel.DebitAuthorized (policy s.capabilities) (netTransition actor ts)

def GrossAuthority (caps : Finset Capability) (actor : Principal) (ts : List Instruction) : Prop :=
  .invoke actor .transfer ∈ caps ∧ ∀ t ∈ ts, .debit actor t.source t.asset ∈ caps

def PrefixFunds (b : Cell → ℚ) : List Instruction → Prop
  | [] => True
  | t :: ts => t.amount ≤ b (t.source, t.asset.native) ∧
      PrefixFunds (fun c => b c + t.delta c) ts

instance (caps : Finset Capability) (actor : Principal) (ts : List Instruction) :
    Decidable (GrossAuthority caps actor ts) := inferInstanceAs (Decidable (_ ∧ _))
instance (b : Cell → ℚ) (ts : List Instruction) : Decidable (PrefixFunds b ts) := by
  induction ts generalizing b with
  | nil => exact isTrue trivial
  | cons t ts ih => exact inferInstanceAs (Decidable (_ ∧ _))

def NetFunded (s : PublicState) (ts : List Instruction) : Prop :=
  ∀ c, 0 ≤ s.ledger.balance c + aggregate ts c

instance (s : PublicState) (actor : Principal) (ts : List Instruction) :
    Decidable (NetAuthorized s actor ts) := inferInstanceAs (Decidable (_ ∧ _))
instance (s : PublicState) (ts : List Instruction) : Decidable (NetFunded s ts) :=
  inferInstanceAs (Decidable (∀ c, 0 ≤ s.ledger.balance c + aggregate ts c))

inductive NetResult where
  | success (state : PublicState)
  | refused (reason : Reason) (instructionIndex : Option Nat) (state : PublicState)

def NetResult.publicState : NetResult → PublicState
  | .success s | .refused _ _ s => s

-- Called only after all instruction-record validation. Authority is on net debits.
def settle (s : PublicState) (actor : Principal) (ts : List Instruction) : NetResult :=
  if ¬ NetAuthorized s actor ts then .refused .unauthorized none s
  else if ¬ NetFunded s ts then .refused .insufficientFunds none s
  else match DefiKernel.execute (policy s.capabilities) () (netTransition actor ts) s.ledger with
    | .error reason => .refused (.nativeFailure reason) none s
    | .ok ledger => .success (netPublish s ledger ts)

def validateOne (actor : Principal) : RawCall → Except Reason Instruction
  | .transfer p s t e q =>
    match decodePrincipal p, decodeAccount s, decodeAccount t, decodeAsset e with
    | some p, some s, some t, some e =>
      if p ≠ actor then .error .badTarget
      else match q with
        | .malformed _ => .error .badNumber
        | .exact q => if q < 0 then .error .badAmount else .ok ⟨p, s, t, e, q⟩
    | _, _, _, _ => .error .badTarget
  | _ => .error .badOperation

def validate (actor : Principal) : List RawCall → Except (Reason × Nat) (List Instruction)
  | [] => .ok []
  | raw :: raws => match validateOne actor raw with
    | .error reason => .error (reason, 0)
    | .ok t => match validate actor raws with
      | .error (reason, index) => .error (reason, index + 1)
      | .ok ts => .ok (t :: ts)

def executeNet (s : PublicState) (requestActor : String) (raws : List RawCall) : NetResult :=
  match decodePrincipal requestActor with
  | none => .refused .badTarget none s
  | some actor => match validate actor raws with
    | .error (reason, index) => .refused reason (some index) s
    | .ok ts => settle s actor ts

-- Algebraic prefixes are computed from the input, without executing any call.
def prefixBalances (b : Cell → ℚ) : List Instruction → Cell → ℚ
  | [] => b
  | t :: ts => prefixBalances (fun c => b c + t.delta c) ts

def PrefixDomain (b : Cell → ℚ) (caps : Finset Capability) : List Instruction → Prop
  | [] => True
  | t :: ts =>
      0 ≤ t.amount ∧ Authorized caps t.call ∧ t.amount ≤ b (t.source, t.asset.native) ∧
      PrefixDomain (fun c => b c + t.delta c) caps ts


structure NetClaims (pre post : PublicState) (actor : Principal) (ts : List Instruction) : Prop where
  native : DefiKernel.execute (policy pre.capabilities) () (netTransition actor ts) pre.ledger = .ok post.ledger
  balances : ∀ c, post.ledger.balance c = pre.ledger.balance c + aggregate ts c
  nonnegative : ∀ c, 0 ≤ post.ledger.balance c
  supply : ∀ e, post.supply e = pre.supply e
  rates : post.rates = pre.rates
  capabilities : post.capabilities = pre.capabilities
  history : post.history = pre.history ++ [netEvent ts]
  frame : ∀ c, aggregate ts c = 0 → post.ledger.balance c = pre.ledger.balance c
  accounting : ∀ e, post.supply e = pre.supply e + (netEvent ts).issued e - (netEvent ts).burned e
  valid : ValidState pre → ValidState post

def SettlementCanonical : Prop := ∀ s actor ts,
  ((NetAuthorized s actor ts ∧ NetFunded s ts) →
    ∃ post, settle s actor ts = .success post ∧ NetClaims s post actor ts) ∧
  (¬ NetAuthorized s actor ts → settle s actor ts = .refused .unauthorized none s) ∧
  (NetAuthorized s actor ts → ¬ NetFunded s ts →
    settle s actor ts = .refused .insufficientFunds none s)

structure SequenceClaims (pre post : PublicState) (ts : List Instruction) : Prop where
  balances : ∀ c, post.ledger.balance c = pre.ledger.balance c + aggregate ts c
  supply : ∀ e, post.supply e = pre.supply e
  rates : post.rates = pre.rates
  capabilities : post.capabilities = pre.capabilities
  history : post.history = pre.history ++ ts.map (fun t => event pre.rates t.call)
  valid : ValidState post

def SequentialCanonical : Prop := ∀ s actor ts, ValidState s → ts.length = 4 → RecordValid actor ts →
  ((runCalls s (ts.map Instruction.call)).failure = none ↔
    GrossAuthority s.capabilities actor ts ∧ PrefixFunds s.ledger.balance ts) ∧
  (GrossAuthority s.capabilities actor ts ∧ PrefixFunds s.ledger.balance ts →
    (runCalls s (ts.map Instruction.call)).committed = 4 ∧
    SequenceClaims s (runCalls s (ts.map Instruction.call)).state ts ∧
    ∃ post, settle s actor ts = .success post ∧ NetClaims s post actor ts ∧
      (∀ c, post.ledger.balance c = (runCalls s (ts.map Instruction.call)).state.ledger.balance c) ∧
      (∀ e, post.supply e = (runCalls s (ts.map Instruction.call)).state.supply e) ∧
      post.rates = (runCalls s (ts.map Instruction.call)).state.rates ∧
      post.capabilities = (runCalls s (ts.map Instruction.call)).state.capabilities)

def ValidationCanonical : Prop :=
  (∀ s requestActor raws, decodePrincipal requestActor = none →
    executeNet s requestActor raws = .refused .badTarget none s) ∧
  (∀ actor tag, validateOne actor (.unsupported tag) = .error .badOperation) ∧
  (∀ actor p s t e q,
    (decodePrincipal p = none ∨ decodeAccount s = none ∨ decodeAccount t = none ∨ decodeAsset e = none) →
    validateOne actor (.transfer p s t e q) = .error .badTarget) ∧
  (∀ actor p s t e p' s' t' e' q,
    decodePrincipal p = some p' → decodeAccount s = some s' → decodeAccount t = some t' →
    decodeAsset e = some e' → p' ≠ actor →
    validateOne actor (.transfer p s t e q) = .error .badTarget) ∧
  (∀ actor p s t e s' t' e' bad,
    decodePrincipal p = some actor → decodeAccount s = some s' → decodeAccount t = some t' →
    decodeAsset e = some e' →
    validateOne actor (.transfer p s t e (.malformed bad)) = .error .badNumber) ∧
  (∀ actor p s t e s' t' e' q,
    decodePrincipal p = some actor → decodeAccount s = some s' → decodeAccount t = some t' →
    decodeAsset e = some e' → q < 0 →
    validateOne actor (.transfer p s t e (.exact q)) = .error .badAmount) ∧
  (∀ actor p s t e s' t' e' q,
    decodePrincipal p = some actor → decodeAccount s = some s' → decodeAccount t = some t' →
    decodeAsset e = some e' → 0 ≤ q →
    validateOne actor (.transfer p s t e (.exact q)) = .ok ⟨actor, s', t', e', q⟩) ∧
  (∀ s requestActor actor before checked raw suffix reason,
    decodePrincipal requestActor = some actor → validate actor before = .ok checked →
    validateOne actor raw = .error reason →
    executeNet s requestActor (before ++ raw :: suffix) = .refused reason (some before.length) s) ∧
  (∀ s requestActor actor raws ts,
    decodePrincipal requestActor = some actor → validate actor raws = .ok ts →
    RecordValid actor ts ∧ ts.length = raws.length ∧ executeNet s requestActor raws = settle s actor ts)

def RawSuccessDomain (s : PublicState) (requestActor : String) (raws : List RawCall) : Prop :=
  ∃ actor ts, decodePrincipal requestActor = some actor ∧
    List.Forall₂ (RawMatches actor) raws ts ∧ NetAuthorized s actor ts ∧ NetFunded s ts

def RawTotalCanonical : Prop :=
  (∀ s requestActor raws, (∃ post, executeNet s requestActor raws = .success post) ↔
    RawSuccessDomain s requestActor raws) ∧
  (∀ actor raw, (∀ p s t e q, raw ≠ .transfer p s t e q) →
    validateOne actor raw = .error .badOperation)

def AggregateCanonical : Prop := ∀ ts c,
  aggregate ts c = (ts.map (fun t =>
    -t.amount * (if c = (t.source, t.asset.native) then 1 else 0) +
      t.amount * (if c = (t.target, t.asset.native) then 1 else 0))).sum

def Canonical : Prop := SettlementCanonical ∧ ValidationCanonical ∧ RawTotalCanonical ∧
  SequentialCanonical ∧ AggregateCanonical ∧
  (∀ s actor ts, NetAuthorized s actor ts ↔ .invoke actor .transfer ∈ s.capabilities ∧
    ∀ a e, aggregate ts (a, e.native) < 0 → .debit actor a e ∈ s.capabilities)

end RationalWorkflow.Net
