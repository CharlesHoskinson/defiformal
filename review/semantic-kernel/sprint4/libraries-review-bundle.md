Independently review DeFiFormal Sprint4 REGISTERED REFERENCE LIBRARIES and review-remediation scope at revision 1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f. Use only this supplied bundle; do not load skills, tools, other filesystem content or web pages. If prompt is offloaded, read only that prompt file. Return <=900 words: verdict ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES, severity-ranked actual findings, exact declarations and unmet evidence. This is native source review, no independent execution claim. Foundations and executor were reviewed separately by native Grok and Fable with ACCEPT WITH LIMITATIONS and no kernel bug; relevant computational dependencies and the exact follow-up diff are included here. Final mutation-runner/evidence review follows separately; do not assume pending mutations passed.

Approved requirements: ordinary registered templates for transfer3 USD, deposit4 USD at2 USD/share, withdraw2shares at2 USD/share, borrow3 USD with explicit1 USD/debt denomination and2x collateralization. Initial Alice USD10/share4/collateral10/debt2, vaultUSD20,poolUSD100,all other balances0. Required full posts: transfer AliceUSD7/BobUSD3; deposit AliceUSD6/share6,vaultUSD24; withdraw AliceUSD14/share2,vaultUSD16; borrow AliceUSD13/debt5,poolUSD97. All unspecified and other-domain cells unchanged. Exact rationals, not machine arithmetic/deployed fidelity/market solvency. Every quantity >=0 guard. Borrow feed7 only, price>0, observedAt<=now<=observedAt+5; convert debt/collateral toUSD explicitly. Price positivity must be independently tested without collateral guard masking. Frozen registry and adapter context/store/env are trusted; cell-owner consent is not a separate condition when administrator grants invoker exact-cell debit authority. Requests cannot choose body/guard/principal. Test-only development registry variants must issue grants from the same registry used in that test.

Lifecycle: real issue/use/revoke/retry unchanged request, using first poststate/store; live retry sibling ensures funds do not mask revocation. Fresh reissue keeps old ID revoked. Exact full-state comparisons include all32 cells with completeness/nodup proofs. Negative quantity, actor, scope, revoked, oracle, typing, accounting, read/write and liquidity cases through real executor. Concrete theorem outcomes use kernel-checked decide, never native_decide/sorry/custom axioms.

Prior findings/fixes: Expr inactive branch test now exact refs, eager and/or documented and tested; Transition transfer/mint positives now all finite cells/totals/store, provisioning+tombstone pinned, currentTime/timestamp+foreign supply/observations/netzero covered. Three combined refusal tests pin evaluation before falseguard, insufficient before accounting, guard before footprint. Correct intentional marker convention: comparison lists ABOVE BEGIN PROOFS; individual test drivers BELOW; central Audit is sole driver in executable-only mutated dependency copies. Accepted source keeps all proofs and drivers. Footprints/domain are successful-execution checks; refused paths may already have read undeclared/foreign cells. Argument shapes are checked before invoke; full evaluation after invoke; no refused-path confidentiality claim. General theorems characterize success, not a complete refusal taxonomy. Optional future wellformed store/dedup endpoint not claimed missing current soundness.

Fresh parent verification on these source bytes: full lake build exit0,1005jobs; direct Typed/Audit exit0 with189 unique comparisons (34Expr+37Authority+48Transition+70reference); direct Typed/Verify imported audit524/524theorems+978/978supplemental,forbidden0; old audit278+234,forbidden0; old33+43runtime stillpass; existing axiom-audit CLI controls99assertions pass. Standalone typing positive executes, three actual ill-typed files reject with Type mismatch. 24 mutation campaign running; deferred evidence review will assess final outcomes. The import source below resolves prior Fable foundation-closure question.


Source SHA256 inventory
{
  "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
  "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
  "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
  "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
  "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
  "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
  "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
  "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"
}

===== exact computational dependency lean/DefiKernel/Typed/Types.lean =====
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod

/-! Reusable finite-ledger identities and dimensioned values. Identity authentication,
observation truth and the finite deployment universe are external assumptions. -/
namespace DefiKernel.Typed

structure ClaimId where
  value : Nat
  deriving DecidableEq, Repr

structure CapabilityId where
  value : Nat
  deriving DecidableEq, Repr

structure OperationId where
  value : Nat
  deriving DecidableEq, Repr

structure ObservationId where
  value : Nat
  deriving DecidableEq, Repr

abbrev Cell (Party Asset Domain : Type) := Domain × Party × Asset

/-- Amount expressions can be signed; a quantity is explicitly nonnegative. -/
structure Quantity {Asset : Type} (asset : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

structure State (Party Asset Domain : Type) where
  balance : Cell Party Asset Domain → ℚ
  nonneg : ∀ c, 0 ≤ balance c

def total {Party Asset Domain : Type} [Fintype Party]
    (s : State Party Asset Domain) (domain : Domain) (asset : Asset) : ℚ :=
  ∑ party, s.balance (domain, party, asset)

/-- A price is quote-asset units per one base-asset unit. -/
inductive Unit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  | bool
  deriving DecidableEq, Repr

/-- Numeric dimensions exclude booleans without a user-supplied typeclass. -/
inductive NumericUnit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  deriving DecidableEq, Repr

abbrev NumericUnit.toUnit {Asset : Type} : NumericUnit Asset → Unit Asset
  | .amount a => .amount a
  | .price a b => .price a b
  | .scalar => .scalar

abbrev Value {Asset : Type} : Unit Asset → Type
  | .bool => Bool
  | .amount _ | .price _ _ | .scalar => ℚ

instance {Asset : Type} (u : Unit Asset) : DecidableEq (Value u) := by
  cases u <;> exact inferInstance

instance {Asset : Type} (u : Unit Asset) : Repr (Value u) := by
  cases u <;> exact inferInstance

def numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) : Value u.toUnit :=
  match u with
  | .amount _ | .price _ _ | .scalar => q

def numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) : ℚ :=
  match u with
  | .amount _ | .price _ _ | .scalar => v

abbrev PackedValue (Asset : Type) := (u : Unit Asset) × Value u

inductive EvalFailure where
  | argumentCount
  | argumentUnit
  | partyArgument
  | missingObservation
  | observationUnit
  | divisionByZero
  deriving DecidableEq, Repr

inductive PartyRef (Party : Type) where
  | caller
  | literal (party : Party)
  | argument (index : Nat)
  deriving DecidableEq, Repr

def PartyRef.resolve {Party : Type} (caller : Party) (parties : List Party) :
    PartyRef Party → Except EvalFailure Party
  | .caller => .ok caller
  | .literal p => .ok p
  | .argument n => match parties[n]? with
    | some p => .ok p
    | none => .error .partyArgument

structure CellRef (Party Asset Domain : Type) (asset : Asset) where
  domain : Domain
  owner : PartyRef Party
  deriving DecidableEq, Repr

def CellRef.resolve {Party Asset Domain : Type} {asset : Asset}
    (caller : Party) (parties : List Party) (c : CellRef Party Asset Domain asset) :
    Except EvalFailure (Cell Party Asset Domain) := do
  let party ← c.owner.resolve caller parties
  return (c.domain, party, asset)

structure ObservationKey (Domain : Type) where
  domain : Domain
  id : ObservationId
  deriving DecidableEq, Repr

/-- Expected unit is intrinsic; the environment's delivered unit is checked at lookup. -/
structure ObservationRef (Asset Domain : Type) (unit : Unit Asset) where
  key : ObservationKey Domain
  deriving DecidableEq, Repr

structure Observation (Asset : Type) where
  value : PackedValue Asset
  timestamp : Nat

abbrev Environment (Asset Domain : Type) := ObservationKey Domain → Option (Observation Asset)

/-- Adapter-supplied identity. Constructing this value is not signature verification. -/
structure InvocationContext (Party Domain : Type) where
  principal : Party
  domain : Domain
  deriving DecidableEq, Repr


===== exact computational dependency lean/DefiKernel/Typed/Expr.lean =====
import DefiKernel.Typed.Types

/-! A closed dimensioned expression language. All arithmetic is exact rational arithmetic.
Read sets conservatively include both conditional branches. Environment truth is assumed. -/
namespace DefiKernel.Typed

inductive Var {Asset : Type} : List (Unit Asset) → Unit Asset → Type where
  | here {u : Unit Asset} {signature : List (Unit Asset)} : Var (u :: signature) u
  | there {u v : Unit Asset} {signature : List (Unit Asset)} :
      Var signature u → Var (v :: signature) u

inductive Args {Asset : Type} : List (Unit Asset) → Type where
  | nil : Args []
  | cons {u : Unit Asset} {signature : List (Unit Asset)} :
      Value u → Args signature → Args (u :: signature)

def Args.get {Asset : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Args signature → Var signature u → Value u
  | .cons value _, .here => value
  | .cons _ rest, .there v => rest.get v

/-- Check arity and every delivered unit before exposing typed arguments to evaluation. -/
def Args.check {Asset : Type} [DecidableEq Asset] (signature : List (Unit Asset))
    (values : List (PackedValue Asset)) : Except EvalFailure (Args signature) :=
  match signature, values with
  | [], [] => .ok .nil
  | u :: us, ⟨v, value⟩ :: vs =>
    if h : v = u then do
      let rest ← Args.check us vs
      return .cons (h ▸ value) rest
    else .error .argumentUnit
  | _, _ => .error .argumentCount

inductive UnaryOp (Asset : Type) : Unit Asset → Unit Asset → Type where
  | neg (u : NumericUnit Asset) : UnaryOp Asset u.toUnit u.toUnit
  | not : UnaryOp Asset .bool .bool

inductive BinaryOp (Asset : Type) : Unit Asset → Unit Asset → Unit Asset → Type where
  | add (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | sub (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | scale (u : NumericUnit Asset) : BinaryOp Asset .scalar u.toUnit u.toUnit
  | divide (u : NumericUnit Asset) : BinaryOp Asset u.toUnit .scalar u.toUnit
  | ratio (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .scalar
  | convert (base quote : Asset) : BinaryOp Asset (.amount base) (.price base quote) (.amount quote)
  | unconvert (base quote : Asset) :
      BinaryOp Asset (.amount quote) (.price base quote) (.amount base)
  | le (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | lt (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | eq (u : Unit Asset) : BinaryOp Asset u u .bool
  | and : BinaryOp Asset .bool .bool .bool
  | or : BinaryOp Asset .bool .bool .bool

def UnaryOp.eval {Asset : Type} {u v : Unit Asset} :
    UnaryOp Asset u v → Value u → Value v
  | .neg n, x => numericValue n (- numericRat n x)
  | .not, x => !x

/-- Division checks its denominator explicitly; rational division is otherwise total at zero. -/
def BinaryOp.eval {Asset : Type} {u v w : Unit Asset} :
    BinaryOp Asset u v w → Value u → Value v → Except EvalFailure (Value w)
  | .add n, x, y => .ok (numericValue n (numericRat n x + numericRat n y))
  | .sub n, x, y => .ok (numericValue n (numericRat n x - numericRat n y))
  | .scale n, x, y => .ok (numericValue n (x * numericRat n y))
  | .divide n, x, y =>
    if y = 0 then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))
  | .ratio n, x, y =>
    if numericRat n y = 0 then .error .divisionByZero
    else .ok (numericRat n x / numericRat n y)
  | .convert _ _, x, y => .ok (x * y)
  | .unconvert _ _, x, y =>
    if y = 0 then .error .divisionByZero else .ok (x / y)
  | .le n, x, y => .ok (decide (numericRat n x ≤ numericRat n y))
  | .lt n, x, y => .ok (decide (numericRat n x < numericRat n y))
  | .eq _, x, y => .ok (decide (x = y))
  | .and, x, y => .ok (x && y)
  | .or, x, y => .ok (x || y)

inductive Expr (Party Asset Domain : Type) (signature : List (Unit Asset)) :
    Unit Asset → Type where
  | lit {u} (value : Value u) : Expr Party Asset Domain signature u
  | arg {u} (v : Var signature u) : Expr Party Asset Domain signature u
  | balance {a} (cell : CellRef Party Asset Domain a) :
      Expr Party Asset Domain signature (.amount a)
  | observe {u} (key : ObservationRef Asset Domain u) : Expr Party Asset Domain signature u
  | timestamp (key : ObservationKey Domain) : Expr Party Asset Domain signature .scalar
  | now : Expr Party Asset Domain signature .scalar
  | unary {u v} (op : UnaryOp Asset u v) (x : Expr Party Asset Domain signature u) :
      Expr Party Asset Domain signature v
  | binary {u v w} (op : BinaryOp Asset u v w)
      (x : Expr Party Asset Domain signature u) (y : Expr Party Asset Domain signature v) :
      Expr Party Asset Domain signature w
  | ite {u} (condition : Expr Party Asset Domain signature .bool)
      (yes no : Expr Party Asset Domain signature u) : Expr Party Asset Domain signature u

abbrev PackedCellRef (Party Asset Domain : Type) :=
  (asset : Asset) × CellRef Party Asset Domain asset

inductive EnvRead (Domain : Type) where
  | observation (key : ObservationKey Domain)
  | currentTime
  deriving DecidableEq, Repr

structure EvalContext (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  state : State Party Asset Domain
  env : Environment Asset Domain
  caller : Party
  parties : List Party
  args : Args signature
  now : Nat

def readBalance {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (ctx : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain) :
    Except EvalFailure ℚ := do
  let c ← ref.2.resolve ctx.caller ctx.parties
  return ctx.state.balance c

def readObservation {Asset Domain : Type} [DecidableEq Asset] {u : Unit Asset}
    (env : Environment Asset Domain) (ref : ObservationRef Asset Domain u) :
    Except EvalFailure (Value u) :=
  match env ref.key with
  | none => .error .missingObservation
  | some observation =>
    if h : observation.value.1 = u then .ok (h ▸ observation.value.2)
    else .error .observationUnit

/-- Binary operators, including boolean and/or, evaluate both operands. Only `ite`
selects a branch lazily. Read inventories conservatively include every branch. -/
def Expr.eval {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (ctx : EvalContext Party Asset Domain signature) :
    Expr Party Asset Domain signature u → Except EvalFailure (Value u)
  | .lit value => .ok value
  | .arg v => .ok (ctx.args.get v)
  | .balance ref => readBalance ctx ⟨_, ref⟩
  | .observe ref => readObservation ctx.env ref
  | .timestamp key => match ctx.env key with
    | none => .error .missingObservation
    | some observation => .ok observation.timestamp
  | .now => .ok ctx.now
  | .unary op x => do return op.eval (← x.eval ctx)
  | .binary op x y => do op.eval (← x.eval ctx) (← y.eval ctx)
  | .ite condition yes no => do
    if ← condition.eval ctx then yes.eval ctx else no.eval ctx

/-- Syntactic reads include inactive branches and all expression children. -/
def Expr.stateReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (PackedCellRef Party Asset Domain)
  | .balance ref => [⟨_, ref⟩]
  | .unary _ x => x.stateReads
  | .binary _ x y => x.stateReads ++ y.stateReads
  | .ite condition yes no => condition.stateReads ++ yes.stateReads ++ no.stateReads
  | .lit _ | .arg _ | .observe _ | .timestamp _ | .now => []

def Expr.envReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (EnvRead Domain)
  | .observe ref => [.observation ref.key]
  | .timestamp key => [.observation key]
  | .now => [.currentTime]
  | .unary _ x => x.envReads
  | .binary _ x y => x.envReads ++ y.envReads
  | .ite condition yes no => condition.envReads ++ yes.envReads ++ no.envReads
  | .lit _ | .arg _ | .balance _ => []

def Expr.resolveStateReads {Party Asset Domain : Type} {signature : List (Unit Asset)}
    {u : Unit Asset} (caller : Party) (parties : List Party)
    (expression : Expr Party Asset Domain signature u) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  expression.stateReads.mapM (fun ref ↦ ref.2.resolve caller parties)

def EnvRead.Agree {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) : EnvRead Domain → Prop
  | .observation key => left.env key = right.env key
  | .currentTime => left.now = right.now


===== exact computational dependency lean/DefiKernel/Typed/Authority.lean =====
import DefiKernel.Typed.Types

/-! Nondelegating capability administration under a trusted actor, domain administrator and
operation-domain lookup. List positions are permanent IDs: revoked entries remain as tombstones.
Authentication, registry truth, allowances and replay prevention are outside this model. -/
namespace DefiKernel.Typed

inductive Right (Party Asset Domain : Type) where
  | invoke
  | debit (cell : Cell Party Asset Domain)
  | changeSupply (domain : Domain) (asset : Asset)
  deriving DecidableEq, Repr

def Right.inDomain {Party Asset Domain : Type} [DecidableEq Domain]
    (right : Right Party Asset Domain) (domain : Domain) : Bool :=
  match right with
  | .invoke => true
  | .debit cell => decide (cell.1 = domain)
  | .changeSupply d _ => decide (d = domain)

structure Grant (Party Asset Domain : Type) where
  holder : Party
  domain : Domain
  operation : OperationId
  right : Right Party Asset Domain
  deriving DecidableEq, Repr

structure Capability (Party Asset Domain : Type) extends Grant Party Asset Domain where
  live : Bool
  deriving DecidableEq, Repr

/-- The adapter supplies this immutable configuration, separately from caller requests. -/
structure AuthorityConfig (Party Domain : Type) where
  domainAdmin : Domain → Party
  operationDomain : OperationId → Option Domain

/-- No entry is removed; length is the next fresh ID, so no separate counter invariant is needed. -/
structure CapabilityStore (Party Asset Domain : Type) where
  entries : List (Capability Party Asset Domain)
  deriving DecidableEq, Repr

def CapabilityStore.empty {Party Asset Domain : Type} : CapabilityStore Party Asset Domain := ⟨[]⟩

def CapabilityStore.nextId {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) : CapabilityId := ⟨store.entries.length⟩

def CapabilityStore.lookup {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) := store.entries[id.value]?

inductive AuthorityFailure where
  | unauthorizedAdmin
  | operationDomain
  | resourceDomain
  | unknownCapability
  deriving DecidableEq, Repr

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def isDomainAdmin (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (domain : Domain) : Bool :=
  decide (ctx.domain = domain ∧ ctx.principal = config.domainAdmin domain)

/-- A grant cannot choose its ID or reactivate an existing entry. -/
def issueCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (grant : Grant Party Asset Domain) :
    Except AuthorityFailure (CapabilityId × CapabilityStore Party Asset Domain) :=
  if isDomainAdmin config ctx grant.domain then
    if config.operationDomain grant.operation = some grant.domain then
      if grant.right.inDomain grant.domain then
        .ok (store.nextId, ⟨store.entries ++ [⟨grant, true⟩]⟩)
      else .error .resourceDomain
    else .error .operationDomain
  else .error .unauthorizedAdmin

/-- Revocation is idempotent and retains the ID permanently, including its original scope. -/
def revokeCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) :
    Except AuthorityFailure (CapabilityStore Party Asset Domain) :=
  match store.lookup id with
  | none => .error .unknownCapability
  | some cap =>
    if isDomainAdmin config ctx cap.domain then
      .ok ⟨store.entries.set id.value { cap with live := false }⟩
    else .error .unauthorizedAdmin

/-- Each supplied ID must itself pass all scope checks to contribute an exact right. -/
def authorizesId (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) : Bool :=
  match store.lookup id with
  | none => false
  | some cap => decide (cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
      right.inDomain ctx.domain = true)

/-- Existential use means duplicate request IDs confer no additional rights. -/
def hasAuthority (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) : Bool :=
  ids.any (authorizesId store ctx operation right)


===== exact computational dependency lean/DefiKernel/Typed/Transition.lean =====
import DefiKernel.Typed.Expr
import DefiKernel.Typed.Authority
import Mathlib.Tactic.Linarith

/-! Registered first-order transitions. Checks concern aggregate net effects; they do not model
intermediate debit order, consumable allowances, replay prevention, or observation truth. -/
namespace DefiKernel.Typed

structure CellDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  asset : Asset
  target : CellRef Party Asset Domain asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure SupplyDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  domain : Domain
  asset : Asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure Template (Party Asset Domain : Type) where
  signature : List (Unit Asset)
  domain : Domain
  partyArity : Nat
  guard : Expr Party Asset Domain signature .bool
  deltas : List (CellDelta Party Asset Domain signature)
  supplyDeltas : List (SupplyDelta Party Asset Domain signature)
  stateReads : List (PackedCellRef Party Asset Domain)
  envReads : List (EnvRead Domain)
  writes : List (PackedCellRef Party Asset Domain)

abbrev Registry (Party Asset Domain : Type) := OperationId → Option (Template Party Asset Domain)

/-- Issuance and execution use the same trusted registry to determine the operation domain. -/
def registryAuthorityConfig {Party Asset Domain : Type} (registry : Registry Party Asset Domain)
    (domainAdmin : Domain → Party) : AuthorityConfig Party Domain :=
  ⟨domainAdmin, fun operation ↦ (registry operation).map Template.domain⟩

structure Request (Party Asset Domain : Type) where
  operation : OperationId
  parties : List Party
  arguments : List (PackedValue Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Refusal where
  | unknownOperation
  | actorMismatch
  | domainMismatch
  | partyArity
  | evaluation (reason : EvalFailure)
  | unauthorizedInvoke
  | guard
  | stateReadFootprint
  | envReadFootprint
  | crossDomain
  | unauthorizedDebit
  | unauthorizedSupply
  | insufficientFunds
  | accounting
  | writeFootprint
  deriving DecidableEq, Repr

/-- Internal evaluated data; caller requests cannot supply this record to `execute`. -/
structure Evaluated (Party Asset Domain : Type) where
  guard : Bool
  deltas : List (Cell Party Asset Domain × ℚ)
  supplies : List ((Domain × Asset) × ℚ)
  requiredStateReads : List (Cell Party Asset Domain)
  requiredEnvReads : List (EnvRead Domain)
  declaredStateReads : List (Cell Party Asset Domain)
  declaredEnvReads : List (EnvRead Domain)
  writes : List (Cell Party Asset Domain)

structure ExecutionResult (Party Asset Domain : Type) where
  state : State Party Asset Domain
  capabilities : CapabilityStore Party Asset Domain

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Template.requiredStateReads (template : Template Party Asset Domain) :=
  template.guard.stateReads ++ template.deltas.flatMap (fun d ↦ d.amount.stateReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.stateReads)

def Template.requiredEnvReads (template : Template Party Asset Domain) :=
  template.guard.envReads ++ template.deltas.flatMap (fun d ↦ d.amount.envReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.envReads)

def resolveRefs (caller : Party) (parties : List Party)
    (refs : List (PackedCellRef Party Asset Domain)) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  refs.mapM (fun ref ↦ ref.2.resolve caller parties)

def Template.evaluate (template : Template Party Asset Domain)
    (ctx : EvalContext Party Asset Domain template.signature) :
    Except EvalFailure (Evaluated Party Asset Domain) := do
  let required ← resolveRefs ctx.caller ctx.parties template.requiredStateReads
  let declared ← resolveRefs ctx.caller ctx.parties template.stateReads
  let writes ← resolveRefs ctx.caller ctx.parties template.writes
  let guard ← template.guard.eval ctx
  let deltas ← template.deltas.mapM fun d ↦ do
    let cell ← d.target.resolve ctx.caller ctx.parties
    let amount ← d.amount.eval ctx
    return (cell, amount)
  let supplies ← template.supplyDeltas.mapM fun d ↦ do
    let amount ← d.amount.eval ctx
    return ((d.domain, d.asset), amount)
  return ⟨guard, deltas, supplies, required, template.requiredEnvReads, declared,
    template.envReads, writes⟩

/-- Every repeated entry contributes by addition, including repeated supply changes. -/
def Evaluated.effect (evaluated : Evaluated Party Asset Domain)
    (cell : Cell Party Asset Domain) : ℚ :=
  (evaluated.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum

def Evaluated.supply (evaluated : Evaluated Party Asset Domain)
    (domain : Domain) (asset : Asset) : ℚ :=
  (evaluated.supplies.map (fun d ↦ if d.1 = (domain, asset) then d.2 else 0)).sum

variable [Fintype Party] [Fintype Asset] [Fintype Domain]

def Evaluated.stateReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredStateReads.all (fun c ↦ decide (c ∈ e.declaredStateReads))

def Evaluated.envReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredEnvReads.all (fun k ↦ decide (k ∈ e.declaredEnvReads))

/-- Required state reads and actual net movement stay within the invocation domain.
Environment observations may explicitly refer to other domains; their truth is adapter supplied. -/
def Evaluated.domainOK (e : Evaluated Party Asset Domain) (domain : Domain) : Bool :=
  decide ((∀ c ∈ e.requiredStateReads, c.1 = domain) ∧
    (∀ c, e.effect c ≠ 0 → c.1 = domain) ∧ ∀ d a, e.supply d a ≠ 0 → d = domain)

def Evaluated.debitsOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ c, e.effect c < 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true)

def Evaluated.suppliesOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ d a, e.supply d a ≠ 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true)

def Evaluated.accountingOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a)

def Evaluated.writesOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ c, c ∉ e.writes → e.effect c = 0)

/-- All branches are computational. Only the nonnegativity witness enters the state value. -/
def applyEvaluated (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) :
    Except Refusal (ExecutionResult Party Asset Domain) :=
  if !e.guard then .error .guard
  else if !e.stateReadsOK then .error .stateReadFootprint
  else if !e.envReadsOK then .error .envReadFootprint
  else if !e.domainOK ctx.domain then .error .crossDomain
  else if !e.debitsOK store request ctx then .error .unauthorizedDebit
  else if !e.suppliesOK store request ctx then .error .unauthorizedSupply
  else if hn : ∀ c, 0 ≤ state.balance c + e.effect c then
    if !e.accountingOK then .error .accounting
    else if !e.writesOK then .error .writeFootprint
    else .ok ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩
  else .error .insufficientFunds

/-- Registry selection and actor/domain binding precede `Args.check`, which precedes invoke
checking. Template evaluation (including effect/supply expressions) precedes guard and footprint
checks. Successful read/domain conditions are not refused-path confidentiality guarantees. -/
def execute (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) : Except Refusal (ExecutionResult Party Asset Domain) := do
  let template ← match registry request.operation with
    | none => .error .unknownOperation
    | some template => .ok template
  if request.claimedActor.isSome && request.claimedActor != some ctx.principal then
    throw .actorMismatch
  if ctx.domain != template.domain then throw .domainMismatch
  if request.parties.length != template.partyArity then throw .partyArity
  let args ← (Args.check template.signature request.arguments).mapError Refusal.evaluation
  if !hasAuthority store request.capabilityIds ctx request.operation .invoke then
    throw .unauthorizedInvoke
  let evaluated ← (template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩)
    |>.mapError Refusal.evaluation
  applyEvaluated store ctx request state evaluated

/-- Logical view of the actual checks; this does not construct executable states. -/
def Evaluated.Valid (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) : Prop :=
  e.guard = true ∧ e.stateReadsOK = true ∧ e.envReadsOK = true ∧
  e.domainOK ctx.domain = true ∧ e.debitsOK store request ctx = true ∧
  e.suppliesOK store request ctx = true ∧ (∀ c, 0 ≤ state.balance c + e.effect c) ∧
  e.accountingOK = true ∧ e.writesOK = true

variable (registry : Registry Party Asset Domain) (store : CapabilityStore Party Asset Domain)
variable (ctx : InvocationContext Party Domain) (env : Environment Asset Domain) (now : Nat)
variable (request : Request Party Asset Domain) (state : State Party Asset Domain)
variable (post : ExecutionResult Party Asset Domain)


===== full source lean/DefiKernel/Typed/Examples.lean =====
import DefiKernel.Typed.Transition

/-! Registered reference financial libraries. Exact rates and declared locked collateral are
model assumptions, not deployed-contract fidelity or market-solvency claims. -/
namespace DefiKernel.Typed
namespace Examples

inductive Party where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

inductive Domain where
  | main | other
  deriving DecidableEq, Repr

instance : Fintype Party := ⟨{.alice, .bob, .vault, .pool}, by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.main, .other}, by intro d; cases d <;> simp⟩

abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev Call := Request Party Asset Domain
abbrev Result := ExecutionResult Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature

/-- Original reference balances on main; every other-domain balance is zero. -/
def initial : Ledger where
  balance c := match c with
    | (.main, .alice, .usd) => 10
    | (.main, .alice, .share) => 4
    | (.main, .alice, .collateral) => 10
    | (.main, .alice, .debt) => 2
    | (.main, .vault, .usd) => 20
    | (.main, .pool, .usd) => 100
    | _ => 0
  nonneg c := by
    rcases c with ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> decide

def ref (a : Asset) (owner : PartyRef Party) : CellRef Party Asset Domain a :=
  ⟨.main, owner⟩

def packedRef (a : Asset) (owner : PartyRef Party) : PackedCellRef Party Asset Domain :=
  ⟨a, ref a owner⟩

def allGuards {signature : List (Unit Asset)} : List (E signature .bool) → E signature .bool
  | [] => .lit true
  | g :: gs => .binary .and g (allGuards gs)

def nonnegative {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature .bool :=
  .binary (.le (.amount a)) (.lit 0) q

def negate {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature (.amount a) :=
  .unary (.neg (.amount a)) q

def usdSignature : List (Unit Asset) := [.amount .usd]
def shareSignature : List (Unit Asset) := [.amount .share]
def usdQuantity : E usdSignature (.amount .usd) := .arg .here
def shareQuantity : E shareSignature (.amount .share) := .arg .here

/-- Registered USD movement; zero and self transfer retain net-effect semantics. -/
def transfer : Op where
  signature := usdSignature
  domain := .main
  partyArity := 1
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), usdQuantity⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.argument 0)]

/-- Two USD per share is a dimensioned library price, not a unit-changing scalar. -/
def mintedShares : E usdSignature (.amount .share) :=
  .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 2)

def deposit : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller, mintedShares⟩]
  supplyDeltas := [⟨.main, .share, mintedShares⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.literal .vault), packedRef .share .caller]

def redeemedUsd : E shareSignature (.amount .usd) :=
  .binary (.convert Asset.share Asset.usd) shareQuantity (.lit 2)

def withdraw : Op where
  signature := shareSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .share shareQuantity
  deltas := [⟨.usd, ref .usd (.literal .vault), negate .usd redeemedUsd⟩,
    ⟨.usd, ref .usd .caller, redeemedUsd⟩,
    ⟨.share, ref .share .caller, negate .share shareQuantity⟩]
  supplyDeltas := [⟨.main, .share, negate .share shareQuantity⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd (.literal .vault), packedRef .usd .caller, packedRef .share .caller]

def priceKey : ObservationKey Domain := ⟨.main, ⟨7⟩⟩
def collateralPrice : E usdSignature (.price .collateral .usd) := .observe ⟨priceKey⟩

/-- One USD per debt token is the reference denomination, explicitly dimensioned. -/
def mintedDebt : E usdSignature (.amount .debt) :=
  .binary (.unconvert Asset.debt Asset.usd) usdQuantity (.lit 1)

def debtValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.debt Asset.usd)
    (.binary (.add (.amount Asset.debt)) (.balance (ref .debt .caller)) mintedDebt) (.lit 1)

def collateralValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.collateral Asset.usd) (.balance (ref .collateral .caller)) collateralPrice

def borrowGuard : E usdSignature .bool := allGuards [
  nonnegative .usd usdQuantity,
  .binary (.lt (.price Asset.collateral Asset.usd)) (.lit 0) collateralPrice,
  .binary (.le .scalar) (.timestamp priceKey) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp priceKey) (.lit 5)),
  .binary (.le (.amount Asset.usd))
    (.binary (.scale (.amount Asset.usd)) (.lit 2) debtValue) collateralValue]

def borrow : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := borrowGuard
  deltas := [⟨.usd, ref .usd (.literal .pool), negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd .caller, usdQuantity⟩,
    ⟨.debt, ref .debt .caller, mintedDebt⟩]
  supplyDeltas := [⟨.main, .debt, mintedDebt⟩]
  stateReads := [packedRef .debt .caller, packedRef .collateral .caller]
  envReads := [.observation priceKey, .currentTime]
  writes := [packedRef .usd (.literal .pool), packedRef .usd .caller, packedRef .debt .caller]

def transferId : OperationId := ⟨0⟩
def depositId : OperationId := ⟨1⟩
def withdrawId : OperationId := ⟨2⟩
def borrowId : OperationId := ⟨3⟩

def registry : Registry Party Asset Domain := fun id ↦ match id.value with
  | 0 => some transfer
  | 1 => some deposit
  | 2 => some withdraw
  | 3 => some borrow
  | _ => none

/-- Vault is the fixture's administrative principal; this does not move ledger balances. -/
def domainAdmin : Domain → Party := fun _ ↦ .vault
def authorityConfig : AuthorityConfig Party Domain := registryAuthorityConfig registry domainAdmin
def adminContext : InvocationContext Party Domain := ⟨.vault, .main⟩
def aliceContext : InvocationContext Party Domain := ⟨.alice, .main⟩
def bobContext : InvocationContext Party Domain := ⟨.bob, .main⟩

def grant (operation : OperationId) (right : Right Party Asset Domain) : Grant Party Asset Domain :=
  ⟨.alice, .main, operation, right⟩

/-- Every operation has its own invocation and exact resource grants. -/
def grants : List (Grant Party Asset Domain) := [
  grant transferId .invoke, grant transferId (.debit (.main, .alice, .usd)),
  grant depositId .invoke, grant depositId (.debit (.main, .alice, .usd)),
  grant depositId (.changeSupply .main .share),
  grant withdrawId .invoke, grant withdrawId (.debit (.main, .vault, .usd)),
  grant withdrawId (.debit (.main, .alice, .share)), grant withdrawId (.changeSupply .main .share),
  grant borrowId .invoke, grant borrowId (.debit (.main, .pool, .usd)),
  grant borrowId (.changeSupply .main .debt)]

def issueGrants (store : Store) : List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | g :: gs => do
    let (_, next) ← issueCapability authorityConfig adminContext store g
    issueGrants next gs

/-- Provisioning failure is propagated; execution never substitutes a fabricated store. -/
def provisioned : Except AuthorityFailure Store := issueGrants .empty grants
def allCapabilityIds : List CapabilityId := (List.range grants.length).map CapabilityId.mk

def transferRequest (q : ℚ) (recipient : Party := .bob) : Call :=
  ⟨transferId, [recipient], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositRequest (q : ℚ) : Call :=
  ⟨depositId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def withdrawRequest (q : ℚ) : Call :=
  ⟨withdrawId, [], [⟨.amount .share, q⟩], allCapabilityIds, none⟩
def borrowRequest (q : ℚ) : Call :=
  ⟨borrowId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩

/-- Supplying a different feed creates a different key; it cannot replace feed seven. -/
def oracle (feed : Nat) (price : ℚ) (observedAt : Nat) : Environment Asset Domain := fun key ↦
  if key = ⟨.main, ⟨feed⟩⟩ then some ⟨⟨.price .collateral .usd, price⟩, observedAt⟩ else none

def fresh : Environment Asset Domain := oracle 7 2 98

inductive ReferenceFailure where
  | authority (reason : AuthorityFailure)
  | execution (reason : Refusal)
  deriving DecidableEq, Repr

def runWith (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger := initial) :
    Except ReferenceFailure Result :=
  (execute registry store ctx env now request state).mapError .execution

def run (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 request

def runOracle (env : Environment Asset Domain) (now : Nat) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext env now request

def runContext (ctx : InvocationContext Party Domain) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store ctx fresh 100 request

def runRevoked (id : CapabilityId) (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  let revoked ← (revokeCapability authorityConfig adminContext store id).mapError .authority
  runWith revoked aliceContext fresh 100 request

def allCells : List (Cell Party Asset Domain) :=
  [Domain.main, .other].flatMap fun d ↦ [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)

def observe (result : Except ReferenceFailure Result) : Except ReferenceFailure (List ℚ) :=
  result.map fun post ↦ allCells.map post.state.balance

end Examples

-- BEGIN PROOFS

namespace Examples

theorem allCells_complete (cell : Cell Party Asset Domain) : cell ∈ allCells := by
  rcases cell with ⟨d, p, a⟩
  cases d <;> cases p <;> cases a <;> decide

theorem allCells_nodup : allCells.Nodup := by decide

end Examples
end DefiKernel.Typed


===== full source lean/DefiKernel/Typed/Acceptance.lean =====
import DefiKernel.Typed.Examples

/-! Executed reference outcomes, refused requests and kernel-checked concrete examples.
Development-template changes below are trusted test fixtures, not request payload features. -/
namespace DefiKernel.Typed
namespace Acceptance
open Examples

def expectedInitial : List ℚ :=
  [10, 4, 10, 2, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedTransfer : List ℚ :=
  [7, 4, 10, 2, 3, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedRepeatedTransfer : List ℚ :=
  [4, 4, 10, 2, 6, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedDeposit : List ℚ :=
  [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedWithdraw : List ℚ :=
  [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedBorrow : List ℚ :=
  [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0, 97, 0, 0, 0] ++ List.replicate 16 0
def expectedBoundaryBorrow : List ℚ :=
  [18, 4, 10, 10, 0, 0, 0, 0, 20, 0, 0, 0, 92, 0, 0, 0] ++ List.replicate 16 0
def expectedFractionalDeposit : List ℚ :=
  [9, 9 / 2, 10, 2, 0, 0, 0, 0, 21, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedZeroExposure : List ℚ :=
  [10, 4, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0

def refused (result : Except ReferenceFailure Result) (reason : Refusal) : Bool :=
  match result with
  | .error actual => decide (actual = .execution reason)
  | .ok _ => false

def postMatches (result : Except ReferenceFailure Result) (balances : List ℚ) : Bool :=
  decide (observe result = .ok balances)

def preservesCapabilities (request : Call) : Bool :=
  match provisioned, run request with
  | .ok before, .ok after => decide (after.capabilities = before)
  | _, _ => false

def provisionedIds : Except AuthorityFailure (List CapabilityId) :=
  provisioned.map fun store ↦ (List.range store.entries.length).map CapabilityId.mk

def revokedTransferInvoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig adminContext store ⟨0⟩

def issueAfterRevocation : Except AuthorityFailure (CapabilityId × Store) := do
  let revoked ← revokedTransferInvoke
  issueCapability authorityConfig adminContext revoked (grant transferId .invoke)

def runReissued (request : Call) : Except ReferenceFailure Result := do
  let (id, store) ← issueAfterRevocation.mapError .authority
  runWith store aliceContext fresh 100 { request with capabilityIds := id :: request.capabilityIds }

/-- Both calls use exactly the same request; the second uses the first call's state and store. -/
def repeatedTransfer : Except ReferenceFailure Result := do
  let first ← run (transferRequest 3)
  runWith first.capabilities aliceContext fresh 100 (transferRequest 3) first.state

/-- Actual issue/use/revoke/use: preserve the successful state and revoke in its capability store
before submitting the unchanged request again. A live repeat is separately checked above. -/
def transferLifecycle : Except ReferenceFailure (List ℚ × Except Refusal (List ℚ)) := do
  let first ← run (transferRequest 3)
  let revoked ← (revokeCapability authorityConfig adminContext first.capabilities ⟨0⟩)
    |>.mapError .authority
  let second := execute registry revoked aliceContext fresh 100 (transferRequest 3) first.state
  return (allCells.map first.state.balance, second.map fun post ↦ allCells.map post.state.balance)

def unauthorizedGrant : Except AuthorityFailure (CapabilityId × Store) :=
  issueCapability authorityConfig bobContext .empty (grant transferId .invoke)

def unauthorizedRevoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig bobContext store ⟨0⟩

/-- A trusted development registry variant; caller requests still contain no template. -/
def runDevelopmentTemplate (template : Op) (request : Call) : Except ReferenceFailure Result := do
  let developmentRegistry : Registry Party Asset Domain := fun id ↦
    if id = request.operation then some template else registry id
  let config := registryAuthorityConfig developmentRegistry domainAdmin
  let issued : Except AuthorityFailure Store := grants.foldlM
    (fun store g ↦ (issueCapability config adminContext store g).map Prod.snd) .empty
  let store ← issued.mapError .authority
  (execute developmentRegistry store aliceContext fresh 100 request initial).mapError .execution

def missingWrites : Op := { transfer with writes := [] }
def missingOracleReads : Op := { borrow with envReads := [] }
def missingBorrowStateReads : Op := { borrow with stateReads := [] }

def quantityWithRead : E usdSignature (.amount .usd) :=
  .binary (.add (.amount Asset.usd)) usdQuantity
    (.binary (.scale (.amount Asset.usd)) (.lit 0) (.balance (ref .usd .caller)))

def effectReadTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd quantityWithRead⟩,
    ⟨.usd, ref .usd (.argument 0), quantityWithRead⟩]
  stateReads := [packedRef .usd .caller] }

def missingEffectRead : Op := { effectReadTransfer with stateReads := [] }

def unbalancedTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), .binary (.add (.amount Asset.usd)) usdQuantity (.lit 1)⟩] }

def wrongAssetTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.share, ref .share (.argument 0), .lit 3⟩]
  writes := [packedRef .usd .caller, packedRef .share (.argument 0)] }

def zeroPriceDeposit : Op := { deposit with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller,
      .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 0)⟩] }

def illiquid : Ledger :=
  ⟨fun c ↦ if c = (.main, .pool, .usd) then 1 else initial.balance c, by
    intro c; split
    · decide
    · exact initial.nonneg c⟩

def illiquidBorrow : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 (borrowRequest 3) illiquid

/-- Both sides of the collateral inequality are zero, independently of the supplied price.
This isolates strict price positivity instead of letting the collateral guard mask it. -/
def zeroExposure : Ledger :=
  ⟨fun c ↦ if c = (.main, .alice, .debt) ∨ c = (.main, .alice, .collateral)
    then 0 else initial.balance c, by
      intro c; split
      · decide
      · exact initial.nonneg c⟩

def zeroExposureBorrow (price : ℚ) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext (oracle 7 price 98) 100 (borrowRequest 0) zeroExposure

def checks : List (String × Bool) := [
  ("reference_initial_all_cells", decide (allCells.map initial.balance = expectedInitial)),
  ("reference_provisioned_twelve_grants", decide
    (provisionedIds = .ok ((List.range 12).map CapabilityId.mk))),
  ("reference_transfer_full_post", postMatches (run (transferRequest 3)) expectedTransfer),
  ("reference_deposit_full_post", postMatches (run (depositRequest 4)) expectedDeposit),
  ("reference_withdraw_full_post", postMatches (run (withdrawRequest 2)) expectedWithdraw),
  ("reference_borrow_full_post", postMatches (run (borrowRequest 3)) expectedBorrow),
  ("reference_collateral_boundary_accept", postMatches
    (run (borrowRequest 8)) expectedBoundaryBorrow),
  ("reference_fractional_deposit", postMatches (run (depositRequest 1)) expectedFractionalDeposit),
  ("reference_zero_transfer", postMatches (run (transferRequest 0)) expectedInitial),
  ("reference_self_transfer", postMatches (run (transferRequest 3 .alice)) expectedInitial),
  ("reference_zero_deposit", postMatches (run (depositRequest 0)) expectedInitial),
  ("reference_zero_withdraw", postMatches (run (withdrawRequest 0)) expectedInitial),
  ("reference_zero_borrow", postMatches (run (borrowRequest 0)) expectedInitial),
  ("reference_negative_transfer", refused (run (transferRequest (-1))) .guard),
  ("reference_negative_deposit", refused (run (depositRequest (-1))) .guard),
  ("reference_negative_withdraw", refused (run (withdrawRequest (-1))) .guard),
  ("reference_negative_borrow", refused (run (borrowRequest (-1))) .guard),
  ("reference_transfer_capabilities_preserved", preservesCapabilities (transferRequest 3)),
  ("reference_deposit_capabilities_preserved", preservesCapabilities (depositRequest 4)),
  ("reference_withdraw_capabilities_preserved", preservesCapabilities (withdrawRequest 2)),
  ("reference_borrow_capabilities_preserved", preservesCapabilities (borrowRequest 3)),
  ("reference_unknown_operation", refused
    (run { transferRequest 3 with operation := ⟨99⟩ }) .unknownOperation),
  ("reference_wrong_holder", refused
    (runContext bobContext (transferRequest 3)) .unauthorizedInvoke),
  ("reference_claimed_actor_mismatch", refused
    (run { transferRequest 3 with claimedActor := some .bob }) .actorMismatch),
  ("reference_claimed_actor_correct", postMatches
    (run { transferRequest 3 with claimedActor := some .alice }) expectedTransfer),
  ("reference_wrong_domain", refused
    (runContext ⟨.alice, .other⟩ (transferRequest 3)) .domainMismatch),
  ("reference_wrong_operation_capabilities", refused
    (run { depositRequest 4 with capabilityIds := [⟨0⟩, ⟨1⟩] }) .unauthorizedInvoke),
  ("reference_unknown_capability", refused
    (run { transferRequest 3 with capabilityIds := [⟨99⟩] }) .unauthorizedInvoke),
  ("reference_missing_debit", refused
    (run { transferRequest 3 with capabilityIds := [⟨0⟩] }) .unauthorizedDebit),
  ("reference_missing_share_supply", refused
    (run { depositRequest 4 with capabilityIds := [⟨2⟩, ⟨3⟩] }) .unauthorizedSupply),
  ("reference_missing_debt_supply", refused
    (run { borrowRequest 3 with capabilityIds := [⟨9⟩, ⟨10⟩] }) .unauthorizedSupply),
  ("reference_duplicate_capabilities", postMatches
    (run { transferRequest 3 with capabilityIds := [⟨0⟩, ⟨0⟩, ⟨1⟩, ⟨1⟩] }) expectedTransfer),
  ("reference_revoked_invocation", refused
    (runRevoked ⟨0⟩ (transferRequest 3)) .unauthorizedInvoke),
  ("reference_live_repeat_same_request", postMatches repeatedTransfer expectedRepeatedTransfer),
  ("reference_issue_use_revoke_same_request", decide
    (transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke))),
  ("reference_resource_revoked_same_request", refused
    (runRevoked ⟨1⟩ (transferRequest 3)) .unauthorizedDebit),
  ("reference_unrelated_revocation", postMatches
    (runRevoked ⟨9⟩ (transferRequest 3)) expectedTransfer),
  ("reference_revocation_tombstone", decide
    ((revokedTransferInvoke.map fun s ↦ (s.lookup ⟨0⟩).map Capability.live) = .ok (some false))),
  ("reference_reissue_fresh_id", decide ((issueAfterRevocation.map Prod.fst) = .ok ⟨12⟩)),
  ("reference_reissued_new_id_works", postMatches
    (runReissued (transferRequest 3)) expectedTransfer),
  ("reference_old_id_stays_revoked", decide
    ((issueAfterRevocation.map fun p ↦
      authorizesId p.2 aliceContext transferId .invoke ⟨0⟩) = .ok false)),
  ("reference_unauthorized_issue", decide (unauthorizedGrant = .error .unauthorizedAdmin)),
  ("reference_unauthorized_revoke", decide (unauthorizedRevoke = .error .unauthorizedAdmin)),
  ("reference_oracle_age_boundary_accept", postMatches
    (runOracle (oracle 7 2 95) 100 (borrowRequest 3)) expectedBorrow),
  ("reference_oracle_stale", refused (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_zero", refused (runOracle (oracle 7 0 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_negative", refused
    (runOracle (oracle 7 (-1) 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_positive_zero_exposure", postMatches
    (zeroExposureBorrow 2) expectedZeroExposure),
  ("reference_oracle_zero_independent", refused (zeroExposureBorrow 0) .guard),
  ("reference_oracle_negative_independent", refused (zeroExposureBorrow (-1)) .guard),
  ("reference_oracle_future", refused (runOracle (oracle 7 2 101) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_wrong_feed", refused
    (runOracle (oracle 8 2 98) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_missing", refused
    (runOracle (fun _ ↦ none) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_wrong_dimension", refused
    (runOracle (fun _ ↦ some ⟨⟨.price .usd .collateral, 2⟩, 98⟩) 100 (borrowRequest 3))
    (.evaluation .observationUnit)),
  ("reference_collateral_exceeded", refused (run (borrowRequest 9)) .guard),
  ("reference_transfer_insufficient", refused (run (transferRequest 11)) .insufficientFunds),
  ("reference_deposit_insufficient", refused (run (depositRequest 11)) .insufficientFunds),
  ("reference_withdraw_insufficient", refused (run (withdrawRequest 5)) .insufficientFunds),
  ("reference_pool_illiquid", refused illiquidBorrow .insufficientFunds),
  ("reference_wrong_argument_dimension", refused
    (run { depositRequest 4 with arguments := [⟨.amount .share, 4⟩] }) (.evaluation .argumentUnit)),
  ("reference_missing_argument", refused
    (run { transferRequest 3 with arguments := [] }) (.evaluation .argumentCount)),
  ("reference_missing_party", refused (run { transferRequest 3 with parties := [] }) .partyArity),
  ("reference_missing_write", refused
    (runDevelopmentTemplate missingWrites (transferRequest 3)) .writeFootprint),
  ("reference_missing_guard_state_read", refused
    (runDevelopmentTemplate missingBorrowStateReads (borrowRequest 3)) .stateReadFootprint),
  ("reference_missing_guard_env_read", refused
    (runDevelopmentTemplate missingOracleReads (borrowRequest 3)) .envReadFootprint),
  ("reference_declared_effect_read", postMatches
    (runDevelopmentTemplate effectReadTransfer (transferRequest 3)) expectedTransfer),
  ("reference_missing_effect_read", refused
    (runDevelopmentTemplate missingEffectRead (transferRequest 3)) .stateReadFootprint),
  ("reference_unbalanced", refused
    (runDevelopmentTemplate unbalancedTransfer (transferRequest 3)) .accounting),
  ("reference_wrong_asset_accounting", refused
    (runDevelopmentTemplate wrongAssetTransfer (transferRequest 3)) .accounting),
  ("reference_zero_divisor", refused
    (runDevelopmentTemplate zeroPriceDeposit (depositRequest 4)) (.evaluation .divisionByZero))
]

end Acceptance

-- BEGIN PROOFS

namespace Acceptance
open Examples

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

set_option maxRecDepth 10000 in
theorem transfer_executed : observe (run (transferRequest 3)) = .ok expectedTransfer := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem deposit_executed : observe (run (depositRequest 4)) = .ok expectedDeposit := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem withdraw_executed : observe (run (withdrawRequest 2)) = .ok expectedWithdraw := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem borrow_executed : observe (run (borrowRequest 3)) = .ok expectedBorrow := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem revoked_request_refused :
    observe (runRevoked ⟨0⟩ (transferRequest 3)) = .error (.execution .unauthorizedInvoke) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem stale_oracle_refused :
    observe (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) = .error (.execution .guard) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem issued_used_revoked_refused :
    transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke) := by
  decide +kernel

/-- The reference registry inherits the actual executor's authority result, conditional on
the supplied authenticated context and successful execution. -/
theorem reference_invocation_authority (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke :=
  execute_invocation_authority registry store ctx env now request state post h

theorem reference_capabilities_preserved (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) : post.capabilities = store :=
  execute_preserves_capabilities registry store ctx env now request state post h

end Acceptance
end DefiKernel.Typed


===== full source lean/DefiKernel/Typed/Audit.lean =====
import DefiKernel.Typed.ExprTests
import DefiKernel.Typed.AuthorityTests
import DefiKernel.Typed.TransitionTests
import DefiKernel.Typed.Acceptance

/-! One named, nonempty runtime inventory for the typed kernel and reference libraries.
Source mutation replay uses this same driver with proof-only suffixes removed from
temporary dependency copies. Accepted sources retain all proofs. -/
namespace DefiKernel.Typed

def runtimeChecks : List (String × Bool) :=
  ExprTests.checks ++ AuthorityTests.checks ++ TransitionTests.checks ++ Acceptance.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty typed runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate typed runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

end DefiKernel.Typed


===== full source lean/DefiKernel/Typed/Verify.lean =====
import DefiKernel.Typed.Audit
import DefiKernel.AxiomAudit

/-! Audit the actual imported Typed closure: theorem declarations and supplemental
definitions, opaque constants and axioms. This is distinct from bounded runtime
checks and does not cover declarations added after this command. -/
#audit_axioms DefiKernel.Typed


===== exact review-remediation diff =====
diff --git a/lean/DefiKernel/Typed/Expr.lean b/lean/DefiKernel/Typed/Expr.lean
index 0c736c5..4142a77 100644
--- a/lean/DefiKernel/Typed/Expr.lean
+++ b/lean/DefiKernel/Typed/Expr.lean
@@ -123,6 +123,8 @@ def readObservation {Asset Domain : Type} [DecidableEq Asset] {u : Unit Asset}
     if h : observation.value.1 = u then .ok (h ▸ observation.value.2)
     else .error .observationUnit
 
+/-- Binary operators, including boolean and/or, evaluate both operands. Only `ite`
+selects a branch lazily. Read inventories conservatively include every branch. -/
 def Expr.eval {Party Asset Domain : Type} [DecidableEq Asset]
     {signature : List (Unit Asset)} {u : Unit Asset}
     (ctx : EvalContext Party Asset Domain signature) :
diff --git a/lean/DefiKernel/Typed/ExprTests.lean b/lean/DefiKernel/Typed/ExprTests.lean
index 97a10bf..f101da3 100644
--- a/lean/DefiKernel/Typed/ExprTests.lean
+++ b/lean/DefiKernel/Typed/ExprTests.lean
@@ -109,8 +109,15 @@ def checks : List (String × Bool) := [
   ("expr_timestamp_observation_tracked", decide (.observation priceKey ∈ freshness.envReads)),
   ("expr_inactive_environment_branch_tracked", decide
     (.observation otherKey ∈ withInactiveRead.envReads)),
-  ("expr_inactive_state_branch_tracked", decide (withInactiveStateRead.stateReads.length = 2)),
+  ("expr_inactive_state_branch_tracked", decide (withInactiveStateRead.stateReads =
+    [⟨TestAsset.usd, usdCell⟩, ⟨TestAsset.usd, ⟨false, .literal true⟩⟩])),
   ("expr_inactive_missing_branch_not_evaluated", decide (withInactiveRead.eval context = .ok 10)),
+  ("expr_boolean_and_is_eager", decide
+    ((Expr.binary .and (.lit false) (.observe ⟨otherKey⟩) : E .bool).eval context =
+      .error .missingObservation)),
+  ("expr_boolean_or_is_eager", decide
+    ((Expr.binary .or (.lit true) (.observe ⟨otherKey⟩) : E .bool).eval context =
+      .error .missingObservation)),
   ("expr_successful_party_lookup", decide (validParty.eval context = .ok 0)),
   ("expr_failed_party_lookup_refused", decide (badParty.eval context = .error .partyArgument)),
   ("expr_concrete_read_resolution", decide
diff --git a/lean/DefiKernel/Typed/Transition.lean b/lean/DefiKernel/Typed/Transition.lean
index e640e4d..344109d 100644
--- a/lean/DefiKernel/Typed/Transition.lean
+++ b/lean/DefiKernel/Typed/Transition.lean
@@ -165,7 +165,9 @@ def applyEvaluated (store : CapabilityStore Party Asset Domain)
     else .ok ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩
   else .error .insufficientFunds
 
-/-- Template selection, actor and domain binding precede checked argument/effect evaluation. -/
+/-- Registry selection and actor/domain binding precede `Args.check`, which precedes invoke
+checking. Template evaluation (including effect/supply expressions) precedes guard and footprint
+checks. Successful read/domain conditions are not refused-path confidentiality guarantees. -/
 def execute (registry : Registry Party Asset Domain)
     (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
     (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
diff --git a/lean/DefiKernel/Typed/TransitionTests.lean b/lean/DefiKernel/Typed/TransitionTests.lean
index 2478ded..09ecdc3 100644
--- a/lean/DefiKernel/Typed/TransitionTests.lean
+++ b/lean/DefiKernel/Typed/TransitionTests.lean
@@ -50,11 +50,16 @@ def refused (reason : Refusal) : Result → Bool
   | .error actual => actual == reason
   | .ok _ => false
 
+def allBalances (post : ExecutionResult Bool Bool Bool)
+    (expected : Cell Bool Bool Bool → ℚ) : Bool :=
+  [false, true].all fun d ↦ [false, true].all fun p ↦ [false, true].all fun a ↦
+    post.state.balance (d, p, a) == expected (d, p, a)
+
 def transferExact : Result → Bool
   | .error _ => false
-  | .ok post => post.state.balance (false, false, false) == 7 &&
-      post.state.balance (false, true, false) == 13 &&
-      post.state.balance (true, false, false) == 10 &&
+  | .ok post => allBalances post
+      (fun c ↦ if c = (false, false, false) then 7
+        else if c = (false, true, false) then 13 else 10) &&
       post.capabilities == capabilities transfer
 
 def guardRead : T :=
@@ -111,6 +116,40 @@ def revoked : C :=
   | .ok store => store
   | .error _ => .empty
 
+def mintExact : Result → Bool
+  | .error _ => false
+  | .ok post =>
+    allBalances post (fun c ↦ if c = (false, true, false) then 13 else 10) &&
+    ([false, true].all fun d ↦ [false, true].all fun a ↦
+      total post.state d a == if (d, a) = (false, false) then 23 else 20) &&
+    post.capabilities == capabilities mint
+
+def clockRead : T :=
+  { transfer with
+    guard := .binary (.le .scalar) (.timestamp key) .now
+    envReads := [.observation key, .currentTime] }
+
+def foreignObserved : T :=
+  { transfer with
+    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.observe ⟨⟨true, ⟨0⟩⟩⟩)⟩,
+      ⟨false, bob, .observe ⟨⟨true, ⟨0⟩⟩⟩⟩]
+    envReads := [.observation ⟨true, ⟨0⟩⟩] }
+
+def foreignNetZero : T :=
+  { transfer with deltas := transfer.deltas ++
+      [⟨false, ⟨true, .literal true⟩, .lit (-3)⟩, ⟨false, ⟨true, .literal true⟩, .lit 3⟩] }
+
+def revokedExact : Bool :=
+  decide (revoked.entries.length = 4) &&
+  revoked.lookup ⟨1⟩ == some ⟨⟨false, false, ⟨0⟩, .debit (false, false, false)⟩, false⟩ &&
+  revoked.lookup ⟨0⟩ == (capabilities transfer).lookup ⟨0⟩ &&
+  authorizesId revoked context request.operation .invoke ⟨0⟩
+
+def positiveProvisioning : Bool :=
+  [transfer, guardRead, effectRead, observed, mint, supplyRead, supplyOnlyRead, inactiveRead,
+    repeated, repeatedSupply, clockRead, foreignObserved, foreignNetZero].all
+    (fun t ↦ decide ((capabilities t).entries.length = 4))
+
 /-- Positive siblings use the same executor and expose the expected refusal precedence. -/
 def checks : List (String × Bool) :=
   [ ("transition_transfer_exact", transferExact (run transfer))
@@ -160,7 +199,7 @@ def checks : List (String × Bool) :=
         (capabilities transfer) context))
   , ("transition_revoked_debit", refused .unauthorizedDebit
       (runWith transfer request revoked context))
-  , ("transition_mint_ok", accepted (run mint))
+  , ("transition_mint_ok", mintExact (run mint))
   , ("transition_supply_required", refused .unauthorizedSupply
       (runWith mint { request with capabilityIds := [⟨0⟩, ⟨1⟩] } (capabilities mint) context))
   , ("transition_insufficient_funds", refused .insufficientFunds
@@ -174,10 +213,36 @@ def checks : List (String × Bool) :=
   , ("transition_missing_write", refused .writeFootprint
       (run { transfer with writes := [⟨false, alice⟩] }))
   , ("transition_repeated_effects_sum", transferExact (run repeated))
-  , ("transition_repeated_supply_sum", accepted (run repeatedSupply))
+  , ("transition_repeated_supply_sum", mintExact (run repeatedSupply))
   , ("transition_duplicate_cap_ids", transferExact
       (runWith transfer { request with capabilityIds := ⟨1⟩ :: request.capabilityIds }
         (capabilities transfer) context))
+  , ("transition_positive_provisioning", positiveProvisioning)
+  , ("transition_revoked_tombstone_exact", revokedExact)
+  , ("transition_clock_read_ok", transferExact (run clockRead))
+  , ("transition_now_read_missing", refused .envReadFootprint
+      (run { clockRead with envReads := [.observation key] }))
+  , ("transition_timestamp_read_missing", refused .envReadFootprint
+      (run { clockRead with envReads := [.currentTime] }))
+  , ("transition_foreign_supply", refused .crossDomain
+      (run { mint with supplyDeltas := [⟨true, false, .lit 3⟩] }))
+  , ("transition_foreign_observation_ok", transferExact (run foreignObserved))
+  , ("transition_foreign_netzero_ok", match run foreignNetZero with
+      | .error _ => false
+      | .ok post => allBalances post
+          (fun c ↦ if c = (false, false, false) then 7
+            else if c = (false, true, false) then 13 else 10) &&
+          post.capabilities == capabilities foreignNetZero)
+  , ("transition_false_guard_failing_effect_precedence", refused (.evaluation .divisionByZero)
+      (run { transfer with
+        guard := .lit false
+        deltas := [⟨false, bob, .binary (.divide (.amount false)) (.lit 3) (.lit 0)⟩] }))
+  , ("transition_underfunded_unbalanced_precedence", refused .insufficientFunds
+      (run { transfer with deltas := [⟨false, alice, .lit (-11)⟩, ⟨false, bob, .lit 12⟩] }))
+  , ("transition_false_guard_missing_read_precedence", refused .guard
+      (run { guardRead with
+        guard := .ite (.lit true) (.lit false) guardRead.guard
+        stateReads := [] }))
   ]
 
 end TransitionTests
