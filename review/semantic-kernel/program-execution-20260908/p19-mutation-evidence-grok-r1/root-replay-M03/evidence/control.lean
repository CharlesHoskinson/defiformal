import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Tactic.Linarith
import Lean.Data.Json


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


end DefiKernel.Typed


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


end DefiKernel.Typed


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


end DefiKernel.Typed


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


end DefiKernel.Typed


/-! Finite component declarations, concrete access checks and immutable value snapshots.
Catalog validation is structural; it does not discharge semantic contracts or kernel authority. -/
namespace DefiKernel.Composition
open Typed

structure ComponentId where
  value : Nat
  deriving DecidableEq, Repr

structure PortId where
  value : Nat
  deriving DecidableEq, Repr

structure QualifiedPort where
  component : ComponentId
  port : PortId
  deriving DecidableEq, Repr

structure InputPort (Asset : Type) where
  id : PortId
  unit : Typed.Unit Asset
  deriving DecidableEq, Repr

structure OutputPort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  deriving DecidableEq, Repr

structure ResourcePort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure ResourceImport (Party Asset Domain : Type) where
  source : QualifiedPort
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure OperationInterface (Party Asset Domain : Type) where
  operation : OperationId
  inputs : List (InputPort Asset)
  outputs : List (OutputPort Party Asset Domain)
  deriving DecidableEq, Repr

structure Component (Party Asset Domain : Type) where
  id : ComponentId
  privateCells : List (Cell Party Asset Domain)
  exports : List (ResourcePort Party Asset Domain)
  imports : List (ResourceImport Party Asset Domain)
  operations : List (OperationInterface Party Asset Domain)
  deriving DecidableEq, Repr

abbrev Catalog (Party Asset Domain : Type) := List (Component Party Asset Domain)

inductive InterfaceFailure where
  | unknownOperation
  | resolution (reason : EvalFailure)
  | readAccess
  | writeAccess
  | inputCount
  | inputUnit
  | unavailableOutput
  deriving DecidableEq, Repr

inductive InputSource (Asset : Type) where
  | literal (value : PackedValue Asset)
  | priorOutput (step : Nat) (port : QualifiedPort)

structure OutputObservation (Asset : Type) where
  step : Nat
  port : QualifiedPort
  value : PackedValue Asset

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Component.canRead (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell)) ||
    component.imports.any (fun p ↦ decide (p.cell = cell))

def Component.canWrite (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell) && p.writable) ||
    component.imports.any (fun p ↦ decide (p.cell = cell) && p.writable)

def lookupOperation (catalog : Catalog Party Asset Domain) (componentId : ComponentId)
    (operationId : OperationId) :
    Option (Component Party Asset Domain × OperationInterface Party Asset Domain) := do
  let component ← catalog.find? (fun c ↦ decide (c.id = componentId))
  let interface ← component.operations.find? (fun i ↦ decide (i.operation = operationId))
  return (component, interface)

def Component.portIds (component : Component Party Asset Domain) : List PortId :=
  component.exports.map ResourcePort.id ++ component.operations.flatMap
    (fun i ↦ i.inputs.map InputPort.id ++ i.outputs.map OutputPort.id)

/-- Private ownership excludes all shared ports, including the owner's own exports.
An import may reduce write access, but cannot grant more rights than its exact export. -/
def validateCatalog (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) : Bool :=
  decide ((catalog.map Component.id).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.operations.map OperationInterface.operation)).Nodup) &&
  decide ((catalog.flatMap Component.privateCells).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.exports.map ResourcePort.cell)).Nodup) &&
  catalog.all (fun c ↦
    decide (c.portIds.Nodup) && decide ((c.imports.map ResourceImport.source).Nodup) &&
    c.exports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells)))) &&
    c.imports.all (fun p ↦
      !(c.exports.any (fun e ↦ decide (e.cell = p.cell))) &&
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells))) &&
      catalog.any (fun source ↦ decide (source.id = p.source.component) &&
        source.exports.any (fun e ↦ decide (e.id = p.source.port) &&
          decide (e.cell = p.cell) && (!p.writable || e.writable)))) &&
    c.operations.all (fun i ↦
      (match registry i.operation with
       | none => false
       | some template => decide (i.inputs.map InputPort.unit = template.signature) &&
         i.outputs.all (fun o ↦ decide (o.cell.1 = template.domain))) &&
      i.outputs.all (fun o ↦ c.canRead o.cell)))

/-- Resolve references without evaluating financial expressions. Both expression branches,
supply/guard reads, declared reads, declared writes and every delta target are checked. -/
def checkAccess (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) : Except InterfaceFailure PUnit := do
  let reads ← (resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads)).mapError .resolution
  let writes ← (resolveRefs ctx.principal parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError .resolution
  if !(reads.all component.canRead) then throw .readAccess
  if !(writes.all component.canWrite) then throw .writeAccess
  return ⟨⟩

/-- Earlier absolute positions are necessary even if an untrusted history contains a future key.
The runner additionally ensures history contains only actual successful snapshots. -/
def resolveSource (index : Nat) (history : List (OutputObservation Asset)) :
    InputSource Asset → Except InterfaceFailure (PackedValue Asset)
  | .literal value => .ok value
  | .priorOutput step port =>
    if step < index then
      match history.find? (fun o ↦ decide (o.step = step ∧ o.port = port)) with
      | some output => .ok output.value
      | none => .error .unavailableOutput
    else .error .unavailableOutput

def resolveInputs (index : Nat) (history : List (OutputObservation Asset))
    (interface : OperationInterface Party Asset Domain) (sources : List (InputSource Asset)) :
    Except InterfaceFailure (List (PackedValue Asset)) := do
  if sources.length != interface.inputs.length then throw .inputCount
  let values ← sources.mapM (resolveSource index history)
  if values.map Sigma.fst != interface.inputs.map InputPort.unit then throw .inputUnit
  return values

/-- Output units are intrinsic to the selected cell and balances are copied after commitment. -/
def snapshots (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    List (OutputObservation Asset) :=
  interface.outputs.map (fun o ↦
    ⟨index, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩)


end DefiKernel.Composition


/-! Proof-level contracts and ledger support. These predicates are not executable certificates;
initialization, environment truth, and local guarantees require separate proof premises. -/
namespace DefiKernel.Composition

open Typed

abbrev World (Party Asset Domain : Type) := ExecutionResult Party Asset Domain

/-- Semantic obligations are separate from finite interface validation. -/
structure ComponentContract (Party Asset Domain Boundary : Type) where
  initial : World Party Asset Domain → Prop
  assumes : Boundary → World Party Asset Domain → Prop
  invariant : World Party Asset Domain → Prop
  guarantees : Boundary → World Party Asset Domain → World Party Asset Domain → Prop

variable {Party Asset Domain Boundary : Type}

/-- Initialization and the inductive rule must actually be proved by a contract instance. -/
structure ContractObligations
    (contract : ComponentContract Party Asset Domain Boundary) : Prop where
  initialized : ∀ w, contract.initial w → contract.invariant w
  preserved : ∀ b pre post, contract.invariant pre → contract.assumes b pre →
    contract.guarantees b pre post → contract.invariant post

def Initial (contracts : List (ComponentContract Party Asset Domain Boundary))
    (world : World Party Asset Domain) : Prop :=
  ∀ contract ∈ contracts, contract.initial world

def AgreeOn (region : Set (Cell Party Asset Domain))
    (pre post : State Party Asset Domain) : Prop :=
  ∀ cell ∈ region, pre.balance cell = post.balance cell

/-- Only ledger predicates are framed; this definition does not cover capability-store reads. -/
def Supports (region : Set (Cell Party Asset Domain))
    (predicate : State Party Asset Domain → Prop) : Prop :=
  ∀ pre post, AgreeOn region pre post → (predicate pre ↔ predicate post)


end DefiKernel.Composition


/-! Single-step adaptation of registered execution. Receipts are re-evaluated against the
same pre-state, and are returned only after both execution and extraction succeed. -/
namespace DefiKernel.Composition
open Typed

structure Boundary (Party Asset Domain : Type) where
  ctx : InvocationContext Party Domain
  env : Environment Asset Domain
  now : Nat

structure Config (Party Asset Domain : Type) where
  registry : Registry Party Asset Domain
  domainAdmin : Domain → Party
  catalog : Catalog Party Asset Domain

structure Invocation (Party Asset Domain : Type) where
  component : ComponentId
  operation : OperationId
  parties : List Party
  inputs : List (InputSource Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Step (Party Asset Domain : Type) where
  | invoke (invocation : Invocation Party Asset Domain)
  | issue (grant : Grant Party Asset Domain)
  | revoke (id : CapabilityId)

inductive Failure where
  | configuration
  | interface (reason : InterfaceFailure)
  | kernel (reason : Typed.Refusal)
  | authority (reason : AuthorityFailure)
  | internalReceipt
  deriving DecidableEq, Repr

inductive Receipt (Party Asset Domain : Type) where
  | invoked (request : Request Party Asset Domain) (evaluated : Evaluated Party Asset Domain)
  | issued (id : CapabilityId)
  | revoked (id : CapabilityId)

structure StepResult (Party Asset Domain : Type) where
  world : World Party Asset Domain
  receipt : Receipt Party Asset Domain
  outputs : List (OutputObservation Asset)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def Config.authority (cfg : Config P A D) := registryAuthorityConfig cfg.registry cfg.domainAdmin

def Receipt.supply (receipt : Receipt P A D) (d : D) (a : A) : ℚ :=
  match receipt with
  | .invoked _ e => e.supply d a
  | _ => 0

def Receipt.writes (receipt : Receipt P A D) : List (Cell P A D) :=
  match receipt with
  | .invoked _ e => e.writes
  | _ => []

def prepareInvocation (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D) :
    Except Failure (OperationInterface P A D × Request P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let arguments ← (resolveInputs index history iface inv.inputs).mapError Failure.interface
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError Failure.interface
  return (iface, ⟨inv.operation, inv.parties, arguments, inv.capabilityIds, inv.claimedActor⟩)

def extractReceipt (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) : Except Failure (Evaluated P A D) := do
  let template ← match cfg.registry request.operation with
    | none => .error .internalReceipt
    | some template => .ok template
  let args ← (Args.check template.signature request.arguments).mapError (fun _ ↦ .internalReceipt)
  (template.evaluate ⟨pre.state, boundary.env, boundary.ctx.principal,
    request.parties, args, boundary.now⟩).mapError (fun _ ↦ .internalReceipt)

def executeStep (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D) :
    Except Failure (StepResult P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  match step with
  | .invoke inv =>
    let (iface, request) ← prepareInvocation cfg boundary index history inv
    let post ← (Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state).mapError Failure.kernel
    let e ← extractReceipt cfg boundary request pre
    return ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | .issue grant =>
    let (id, store) ← (issueCapability cfg.authority boundary.ctx pre.capabilities grant)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .issued id, []⟩
  | .revoke id =>
    let store ← (revokeCapability cfg.authority boundary.ctx pre.capabilities id)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .revoked id, []⟩


end DefiKernel.Composition


/-! Finite ordered execution. A refusal commits no new event, preserves the successful prefix,
and makes every continuation inert. Trusted boundary positions are absolute. -/
namespace DefiKernel.Composition
open Typed

structure Event (Party Asset Domain : Type) where
  index : Nat
  step : Step Party Asset Domain
  before : World Party Asset Domain
  result : StepResult Party Asset Domain

structure LocatedFailure (Party Asset Domain : Type) where
  index : Nat
  step : Option (Step Party Asset Domain)
  reason : Failure

structure Cursor (Party Asset Domain : Type) where
  world : World Party Asset Domain
  events : List (Event Party Asset Domain)
  outputs : List (OutputObservation Asset)
  nextIndex : Nat
  failure : Option (LocatedFailure Party Asset Domain)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def startCursor (cfg : Config P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, [], [], 0, if validateCatalog cfg.registry cfg.catalog then none
    else some ⟨0, none, .configuration⟩⟩

def advance (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) : Cursor P A D :=
  match cursor.failure with
  | some _ => cursor
  | none =>
    match executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | .error reason => { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ }
    | .ok result =>
      ⟨result.world, cursor.events ++ [⟨cursor.nextIndex, step, cursor.world, result⟩],
        cursor.outputs ++ result.outputs, cursor.nextIndex + 1, none⟩

def continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) : Cursor P A D :=
  steps.foldl (advance cfg boundaries) cursor

def run (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) : Cursor P A D :=
  continueRun cfg boundaries (startCursor cfg world) steps


end DefiKernel.Composition


namespace DefiKernel.Certificates

/-- Universe party enumeration matching baseline universe. -/
inductive Party where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr, Inhabited

/-- Universe asset enumeration matching baseline universe. -/
inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr, Inhabited

/-- Universe domain enumeration matching baseline universe. -/
inductive Domain where
  | main | other
  deriving DecidableEq, Repr, Inhabited

instance : Fintype Party := ⟨{.alice, .bob, .vault, .pool}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.main, .other}, by intro d; cases d <;> simp⟩

def partyToString : Party → String
  | .alice => "alice"
  | .bob => "bob"
  | .vault => "vault"
  | .pool => "pool"

def parseParty? : String → Option Party
  | "alice" => some .alice
  | "bob" => some .bob
  | "vault" => some .vault
  | "pool" => some .pool
  | _ => none

def assetToString : Asset → String
  | .usd => "usd"
  | .share => "share"
  | .collateral => "collateral"
  | .debt => "debt"

def parseAsset? : String → Option Asset
  | "usd" => some .usd
  | "share" => some .share
  | "collateral" => some .collateral
  | "debt" => some .debt
  | _ => none

def domainToString : Domain → String
  | .main => "main"
  | .other => "other"

def parseDomain? : String → Option Domain
  | "main" => some .main
  | "other" => some .other
  | _ => none

/-- Exact rational numbers in canonical form. -/
structure RatEnc where
  num : Int
  den : Nat
  deriving DecidableEq, Repr, Inhabited

def RatEnc.toRat (r : RatEnc) : ℚ :=
  Rat.divInt r.num r.den

def RatEnc.fromRat (q : ℚ) : RatEnc :=
  ⟨q.num, q.den⟩

inductive NumericUnitEnc where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  deriving DecidableEq, Repr, Inhabited

inductive UnitEnc where
  | numeric (u : NumericUnitEnc)
  | bool
  deriving DecidableEq, Repr, Inhabited

def NumericUnitEnc.toNumericUnit : NumericUnitEnc → Typed.NumericUnit Asset
  | .amount a => .amount a
  | .price a b => .price a b
  | .scalar => .scalar

def UnitEnc.toUnit : UnitEnc → Typed.Unit Asset
  | .numeric u => u.toNumericUnit.toUnit
  | .bool => .bool

structure PackedValueEnc where
  unit : UnitEnc
  valRat : ℚ := 0
  valBool : Bool := false
  deriving DecidableEq, Repr, Inhabited

def PackedValueEnc.toPackedValue (pv : PackedValueEnc) : Typed.PackedValue Asset :=
  match pv.unit with
  | .numeric u => ⟨u.toNumericUnit.toUnit, Typed.numericValue u.toNumericUnit pv.valRat⟩
  | .bool => ⟨.bool, pv.valBool⟩

inductive PartyRefEnc where
  | caller
  | literal (party : Party)
  | argument (index : Nat)
  deriving DecidableEq, Repr, Inhabited

def PartyRefEnc.toPartyRef : PartyRefEnc → Typed.PartyRef Party
  | .caller => .caller
  | .literal p => .literal p
  | .argument idx => .argument idx

structure CellRefEnc where
  domain : Domain
  owner : PartyRefEnc
  deriving DecidableEq, Repr, Inhabited

def CellRefEnc.toCellRef (c : CellRefEnc) (a : Asset) : Typed.CellRef Party Asset Domain a :=
  ⟨c.domain, c.owner.toPartyRef⟩

structure PackedCellRefEnc where
  asset : Asset
  cell : CellRefEnc
  deriving DecidableEq, Repr, Inhabited

def PackedCellRefEnc.toPackedCellRef (p : PackedCellRefEnc) : Typed.PackedCellRef Party Asset Domain :=
  ⟨p.asset, p.cell.toCellRef p.asset⟩

structure ObservationKeyEnc where
  domain : Domain
  id : Nat
  deriving DecidableEq, Repr, Inhabited

def ObservationKeyEnc.toObservationKey (k : ObservationKeyEnc) : Typed.ObservationKey Domain :=
  ⟨k.domain, ⟨k.id⟩⟩

structure ObservationRefEnc where
  key : ObservationKeyEnc
  unit : UnitEnc
  deriving DecidableEq, Repr, Inhabited

def ObservationRefEnc.toObservationRef (r : ObservationRefEnc) :
    Typed.ObservationRef Asset Domain r.unit.toUnit :=
  ⟨r.key.toObservationKey⟩

inductive EnvReadEnc where
  | observation (key : ObservationKeyEnc)
  | currentTime
  deriving DecidableEq, Repr, Inhabited

def EnvReadEnc.toEnvRead : EnvReadEnc → Typed.EnvRead Domain
  | .observation k => .observation k.toObservationKey
  | .currentTime => .currentTime

inductive UnaryOpEnc where
  | neg (u : NumericUnitEnc)
  | not
  deriving DecidableEq, Repr, Inhabited

inductive BinaryOpEnc where
  | add (u : NumericUnitEnc)
  | sub (u : NumericUnitEnc)
  | scale (u : NumericUnitEnc)
  | divide (u : NumericUnitEnc)
  | ratio (u : NumericUnitEnc)
  | convert (base quote : Asset)
  | unconvert (base quote : Asset)
  | le (u : NumericUnitEnc)
  | lt (u : NumericUnitEnc)
  | eq (u : UnitEnc)
  | and
  | or
  deriving DecidableEq, Repr, Inhabited

inductive ExprEnc where
  | lit (val : PackedValueEnc)
  | arg (index : Nat) (unit : UnitEnc)
  | balance (cell : PackedCellRefEnc)
  | observe (ref : ObservationRefEnc)
  | timestamp (key : ObservationKeyEnc)
  | now
  | unary (op : UnaryOpEnc) (x : ExprEnc)
  | binary (op : BinaryOpEnc) (x y : ExprEnc)
  | ite (condition yes no : ExprEnc)
  deriving DecidableEq, Repr, Inhabited

structure CellDeltaEnc where
  asset : Asset
  target : CellRefEnc
  amount : ExprEnc
  deriving DecidableEq, Repr, Inhabited

structure SupplyDeltaEnc where
  domain : Domain
  asset : Asset
  amount : ExprEnc
  deriving DecidableEq, Repr, Inhabited

structure TemplateEnc where
  signature : List UnitEnc
  domain : Domain
  partyArity : Nat
  guard : ExprEnc
  deltas : List CellDeltaEnc
  supplyDeltas : List SupplyDeltaEnc
  stateReads : List PackedCellRefEnc
  envReads : List EnvReadEnc
  writes : List PackedCellRefEnc
  deriving DecidableEq, Repr, Inhabited

structure RegistryEntryEnc where
  id : Nat
  template : TemplateEnc
  deriving DecidableEq, Repr, Inhabited

structure RegistryEnc where
  entries : List RegistryEntryEnc
  deriving DecidableEq, Repr, Inhabited

structure RequestEnc where
  operation : Nat
  parties : List Party
  arguments : List PackedValueEnc
  capabilityIds : List Nat
  claimedActor : Option Party := none
  deriving DecidableEq, Repr, Inhabited

def RequestEnc.toRequest (r : RequestEnc) : Typed.Request Party Asset Domain :=
  ⟨⟨r.operation⟩, r.parties, r.arguments.map PackedValueEnc.toPackedValue,
   r.capabilityIds.map (fun id ↦ ⟨id⟩), r.claimedActor⟩

structure CellEnc where
  domain : Domain
  party : Party
  asset : Asset
  deriving DecidableEq, Repr, Inhabited

def CellEnc.toCell (c : CellEnc) : Typed.Cell Party Asset Domain :=
  (c.domain, c.party, c.asset)

inductive RightEnc where
  | invoke
  | debit (cell : CellEnc)
  | changeSupply (domain : Domain) (asset : Asset)
  deriving DecidableEq, Repr, Inhabited

def RightEnc.toRight : RightEnc → Typed.Right Party Asset Domain
  | .invoke => .invoke
  | .debit c => .debit c.toCell
  | .changeSupply d a => .changeSupply d a

structure GrantEnc where
  holder : Party
  domain : Domain
  operation : Nat
  right : RightEnc
  deriving DecidableEq, Repr, Inhabited

def GrantEnc.toGrant (g : GrantEnc) : Typed.Grant Party Asset Domain :=
  ⟨g.holder, g.domain, ⟨g.operation⟩, g.right.toRight⟩

structure CapabilityEnc where
  holder : Party
  domain : Domain
  operation : Nat
  right : RightEnc
  live : Bool
  deriving DecidableEq, Repr, Inhabited

def CapabilityEnc.toCapability (c : CapabilityEnc) : Typed.Capability Party Asset Domain :=
  ⟨⟨c.holder, c.domain, ⟨c.operation⟩, c.right.toRight⟩, c.live⟩

structure StoreEnc where
  entries : List CapabilityEnc
  deriving DecidableEq, Repr, Inhabited

def StoreEnc.toCapabilityStore (s : StoreEnc) : Typed.CapabilityStore Party Asset Domain :=
  ⟨s.entries.map CapabilityEnc.toCapability⟩

structure StateCellEnc where
  domain : Domain
  party : Party
  asset : Asset
  amount : RatEnc
  deriving DecidableEq, Repr, Inhabited

structure StateEnc where
  cells : List StateCellEnc
  deriving DecidableEq, Repr, Inhabited

def StateEnc.cellLookup (s : StateEnc) (c : Typed.Cell Party Asset Domain) : ℚ :=
  match s.cells.find? (fun row ↦ row.domain == c.1 && row.party == c.2.1 && row.asset == c.2.2) with
  | some row => row.amount.toRat
  | none => 0

def StateEnc.isNonneg (s : StateEnc) : Bool :=
  decide (∀ c : Typed.Cell Party Asset Domain, 0 ≤ s.cellLookup c)

def StateEnc.toState? (s : StateEnc) : Option (Typed.State Party Asset Domain) :=
  if h : ∀ c : Typed.Cell Party Asset Domain, 0 ≤ s.cellLookup c then
    some ⟨s.cellLookup, h⟩
  else none

structure ContextEnc where
  principal : Party
  domain : Domain
  deriving DecidableEq, Repr, Inhabited

def ContextEnc.toContext (c : ContextEnc) : Typed.InvocationContext Party Domain :=
  ⟨c.principal, c.domain⟩

structure ObservationEnc where
  value : PackedValueEnc
  timestamp : Nat
  deriving DecidableEq, Repr, Inhabited

structure EnvironmentEntryEnc where
  key : ObservationKeyEnc
  observation : ObservationEnc
  deriving DecidableEq, Repr, Inhabited

structure EnvironmentEnc where
  entries : List EnvironmentEntryEnc
  deriving DecidableEq, Repr, Inhabited

def EnvironmentEnc.toEnvironment (e : EnvironmentEnc) : Typed.Environment Asset Domain :=
  fun k ↦ match e.entries.find? (fun entry ↦ entry.key.toObservationKey == k) with
    | some entry => some ⟨entry.observation.value.toPackedValue, entry.observation.timestamp⟩
    | none => none

structure BoundaryEnc where
  ctx : ContextEnc
  env : EnvironmentEnc
  now : Nat
  deriving DecidableEq, Repr, Inhabited

def BoundaryEnc.toBoundary (b : BoundaryEnc) : Composition.Boundary Party Asset Domain :=
  ⟨b.ctx.toContext, b.env.toEnvironment, b.now⟩

structure DomainAdminEnc where
  domain : Domain
  party : Party
  deriving DecidableEq, Repr, Inhabited

structure InputPortEnc where
  id : Nat
  unit : UnitEnc
  deriving DecidableEq, Repr, Inhabited

def InputPortEnc.toInputPort (p : InputPortEnc) : Composition.InputPort Asset :=
  ⟨⟨p.id⟩, p.unit.toUnit⟩

structure OutputPortEnc where
  id : Nat
  cell : CellEnc
  deriving DecidableEq, Repr, Inhabited

def OutputPortEnc.toOutputPort (p : OutputPortEnc) : Composition.OutputPort Party Asset Domain :=
  ⟨⟨p.id⟩, p.cell.toCell⟩

structure ResourcePortEnc where
  id : Nat
  cell : CellEnc
  writable : Bool
  deriving DecidableEq, Repr, Inhabited

def ResourcePortEnc.toResourcePort (p : ResourcePortEnc) : Composition.ResourcePort Party Asset Domain :=
  ⟨⟨p.id⟩, p.cell.toCell, p.writable⟩

structure QualifiedPortEnc where
  component : Nat
  port : Nat
  deriving DecidableEq, Repr, Inhabited

def QualifiedPortEnc.toQualifiedPort (p : QualifiedPortEnc) : Composition.QualifiedPort :=
  ⟨⟨p.component⟩, ⟨p.port⟩⟩

structure ResourceImportEnc where
  source : QualifiedPortEnc
  cell : CellEnc
  writable : Bool
  deriving DecidableEq, Repr, Inhabited

def ResourceImportEnc.toResourceImport (i : ResourceImportEnc) : Composition.ResourceImport Party Asset Domain :=
  ⟨i.source.toQualifiedPort, i.cell.toCell, i.writable⟩

structure OperationInterfaceEnc where
  operation : Nat
  inputs : List InputPortEnc
  outputs : List OutputPortEnc
  deriving DecidableEq, Repr, Inhabited

def OperationInterfaceEnc.toOperationInterface (i : OperationInterfaceEnc) :
    Composition.OperationInterface Party Asset Domain :=
  ⟨⟨i.operation⟩, i.inputs.map InputPortEnc.toInputPort, i.outputs.map OutputPortEnc.toOutputPort⟩

structure ComponentEnc where
  id : Nat
  privateCells : List CellEnc
  exports : List ResourcePortEnc
  imports : List ResourceImportEnc
  operations : List OperationInterfaceEnc
  deriving DecidableEq, Repr, Inhabited

def ComponentEnc.toComponent (c : ComponentEnc) : Composition.Component Party Asset Domain :=
  ⟨⟨c.id⟩, c.privateCells.map CellEnc.toCell,
   c.exports.map ResourcePortEnc.toResourcePort,
   c.imports.map ResourceImportEnc.toResourceImport,
   c.operations.map OperationInterfaceEnc.toOperationInterface⟩

structure ConfigEnc where
  registry : RegistryEnc
  domainAdmin : List DomainAdminEnc
  catalog : List ComponentEnc
  deriving DecidableEq, Repr, Inhabited

inductive InputSourceEnc where
  | literal (value : PackedValueEnc)
  | priorOutput (step : Nat) (port : QualifiedPortEnc)
  deriving DecidableEq, Repr, Inhabited

def InputSourceEnc.toInputSource (s : InputSourceEnc) : Composition.InputSource Asset :=
  match s with
  | .literal pv => .literal pv.toPackedValue
  | .priorOutput step port => .priorOutput step port.toQualifiedPort

structure InvocationEnc where
  component : Nat
  operation : Nat
  parties : List Party
  inputs : List InputSourceEnc
  capabilityIds : List Nat
  claimedActor : Option Party := none
  deriving DecidableEq, Repr, Inhabited

def InvocationEnc.toInvocation (inv : InvocationEnc) : Composition.Invocation Party Asset Domain :=
  ⟨⟨inv.component⟩, ⟨inv.operation⟩, inv.parties,
   inv.inputs.map InputSourceEnc.toInputSource,
   inv.capabilityIds.map (fun id ↦ ⟨id⟩), inv.claimedActor⟩

inductive StepEnc where
  | invoke (invocation : InvocationEnc)
  | issue (grant : GrantEnc)
  | revoke (id : Nat)
  | unsupported (tag : String)
  deriving DecidableEq, Repr, Inhabited

def StepEnc.toStep? (s : StepEnc) : Option (Composition.Step Party Asset Domain) :=
  match s with
  | .invoke inv => some (.invoke inv.toInvocation)
  | .issue g => some (.issue g.toGrant)
  | .revoke id => some (.revoke ⟨id⟩)
  | .unsupported _ => none

structure WorldEnc where
  state : StateEnc
  capabilities : StoreEnc
  deriving DecidableEq, Repr, Inhabited

def WorldEnc.toWorld? (w : WorldEnc) : Option (Composition.World Party Asset Domain) := do
  let st ← w.state.toState?
  return ⟨st, w.capabilities.toCapabilityStore⟩

structure OutputObservationEnc where
  step : Nat
  port : QualifiedPortEnc
  value : PackedValueEnc
  deriving DecidableEq, Repr, Inhabited

def OutputObservationEnc.toOutputObservation (o : OutputObservationEnc) :
    Composition.OutputObservation Asset :=
  ⟨o.step, o.port.toQualifiedPort, o.value.toPackedValue⟩

def OutputObservationEnc.fromOutputObservation (o : Composition.OutputObservation Asset) :
    OutputObservationEnc :=
  match o.value with
  | ⟨.bool, v⟩ =>
    ⟨o.step, ⟨o.port.component.value, o.port.port.value⟩, ⟨.bool, 0, v⟩⟩
  | ⟨.amount a, v⟩ =>
    ⟨o.step, ⟨o.port.component.value, o.port.port.value⟩, ⟨.numeric (.amount a), Typed.numericRat (.amount a) v, false⟩⟩
  | ⟨.price a b, v⟩ =>
    ⟨o.step, ⟨o.port.component.value, o.port.port.value⟩, ⟨.numeric (.price a b), Typed.numericRat (.price a b) v, false⟩⟩
  | ⟨.scalar, v⟩ =>
    ⟨o.step, ⟨o.port.component.value, o.port.port.value⟩, ⟨.numeric .scalar, Typed.numericRat .scalar v, false⟩⟩

structure EvaluatedEnc where
  guard : Bool
  deltas : List (CellEnc × RatEnc)
  supplies : List ((Domain × Asset) × RatEnc)
  requiredStateReads : List CellEnc
  requiredEnvReads : List ObservationKeyEnc
  declaredStateReads : List CellEnc
  declaredEnvReads : List ObservationKeyEnc
  writes : List CellEnc
  deriving DecidableEq, Repr, Inhabited

inductive ReceiptEnc where
  | invoked (request : RequestEnc) (evaluated : EvaluatedEnc)
  | issued (id : Nat)
  | revoked (id : Nat)
  deriving DecidableEq, Repr, Inhabited

structure StepResultEnc where
  world : WorldEnc
  receipt : ReceiptEnc
  outputs : List OutputObservationEnc
  deriving DecidableEq, Repr, Inhabited

structure SequentialEventEnc where
  index : Nat
  step : StepEnc
  before : WorldEnc
  result : StepResultEnc
  deriving DecidableEq, Repr, Inhabited

inductive FailureClass where
  | kernel
  | interface
  | authority
  | configuration
  | internalReceipt
  | staleSource
  | observationMismatch
  | incompleteObligation
  deriving DecidableEq, Repr, Inhabited

structure FailurePath where
  «class» : FailureClass
  ctor : String
  payload : Option String := none
  deriving DecidableEq, Repr, Inhabited

structure LocatedFailureEnc where
  index : Nat
  step : Option StepEnc
  reason : FailurePath
  deriving DecidableEq, Repr, Inhabited

inductive JudgmentOutcome where
  | «true»
  | «false»
  | notReached
  | notApplicable
  deriving DecidableEq, Repr, Inhabited

structure JudgmentResult where
  family : String
  outcome : JudgmentOutcome
  claimed : Bool
  «match» : Bool
  deriving DecidableEq, Repr, Inhabited

structure SourcePinEnc where
  git : String
  lean_toolchain : String
  mathlib_rev : String
  checker_candidate : String
  compiler_record : Option String := none
  audit_record : Option String := none
  deriving DecidableEq, Repr, Inhabited

structure TypesEnumEnc where
  parties : List Party
  assets : List Asset
  domains : List Domain
  deriving DecidableEq, Repr, Inhabited

structure LibraryRefEnc where
  theoremName : String
  moduleName : Option String := none
  deriving DecidableEq, Repr, Inhabited

structure EnvelopeEnc where
  schema_version : Nat
  mode : String
  source_pin : SourcePinEnc
  audit_roots : List String
  types : TypesEnumEnc
  assumptions : List String
  invariants : List String := []
  libraries : List LibraryRefEnc := []
  source_map : List (String × String) := []
  claimed_judgments : List String := []
  claimed_next_state : Option WorldEnc := none
  require_library_discharge : Bool := false
  require_invariant_discharge : Bool := false
  deriving DecidableEq, Repr, Inhabited

structure TypedExecutePayloadEnc where
  registry : RegistryEnc
  store : StoreEnc
  ctx : ContextEnc
  env : EnvironmentEnc
  now : Nat
  request : RequestEnc
  state : StateEnc
  deriving DecidableEq, Repr, Inhabited

structure CompositionStepPayloadEnc where
  config : ConfigEnc
  boundary : BoundaryEnc
  index : Nat
  history : List OutputObservationEnc
  step : StepEnc
  pre : WorldEnc
  deriving DecidableEq, Repr, Inhabited

structure CompositionRunPayloadEnc where
  config : ConfigEnc
  boundaries : List BoundaryEnc
  world : WorldEnc
  steps : List StepEnc
  deriving DecidableEq, Repr, Inhabited

inductive ReportStatus where
  | accepted
  | refused
  | incomplete
  deriving DecidableEq, Repr, Inhabited

structure Report where
  status : ReportStatus
  failure : Option FailurePath
  judgments : List JudgmentResult
  world : WorldEnc
  receipt : Option ReceiptEnc
  outputs : List OutputObservationEnc
  events : List SequentialEventEnc
  nextIndex : Nat
  cursorFailure : Option LocatedFailureEnc
  assumptions : List (String × String)
  outstanding : List String
  source_pin : SourcePinEnc
  audit_roots : List String
  unsupported : Option String := none
  deriving DecidableEq, Repr, Inhabited

structure RawObservation where
  world : WorldEnc
  receipt : Option ReceiptEnc
  outputs : List OutputObservationEnc
  events : List SequentialEventEnc
  nextIndex : Nat
  cursorFailure : Option LocatedFailureEnc
  kernelFailure : Option FailurePath
  deriving DecidableEq, Repr, Inhabited

inductive IllegalRationalReason where
  | zeroDenominator
  | noncanonical
  deriving DecidableEq, Repr, Inhabited

inductive DecodeFailure where
  | emptyDocument
  | resourceLimit (reason : String)
  | lexicalScientificOrFloat
  | notJsonObject
  | duplicateKey (name : String)
  | noncanonicalWhitespace
  | schemaVersion
  | missingField (name : String)
  | jsonType (path : String)
  | unknownIdentifier (name : String)
  | uniqueness (kind : String)
  | illegalRational (reason : IllegalRationalReason)
  | stateNonneg
  | unknownExecutableField (name : String)
  | unsupportedForm (reason : String)
  deriving DecidableEq, Repr, Inhabited

inductive DecodedExecution where
  | typed (envelope : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
  | step (envelope : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
  | run (envelope : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
  deriving DecidableEq, Repr, Inhabited

def DecodedExecution.envelope : DecodedExecution → EnvelopeEnc
  | .typed env _ => env
  | .step env _ => env
  | .run env _ => env

structure DecodedAudit where
  envelope : EnvelopeEnc
  commands : List String := []
  imported_theorems_min : Nat := 1
  forbidden_claimed_roots : List String := []
  imported_theorems : Option Nat := none
  auditPrefix : Option String := none
  deriving DecidableEq, Repr, Inhabited

structure DecodedCodecDocument where
  envelope : Option EnvelopeEnc := none
  rawText : String := ""
  deriving DecidableEq, Repr, Inhabited

inductive DecodedIR where
  | execution (ir : DecodedExecution)
  | audit (ir : DecodedAudit)
  | codec (ir : DecodedCodecDocument)
  deriving DecidableEq, Repr, Inhabited

inductive CodecResult where
  | ok (ir : DecodedIR)
  | malformed (failure : DecodeFailure)
  | blocked (limit : String)
  deriving DecidableEq, Repr, Inhabited

inductive AuditStatus where
  | passed
  | failed
  | blocked
  deriving DecidableEq, Repr, Inhabited

structure AuditResult where
  status : AuditStatus
  failure : Option String := none
  prefixes : List String := []
  claimed_covered : Option Bool := none
  deriving DecidableEq, Repr, Inhabited

inductive Outcome where
  | codec (res : CodecResult)
  | execution (rep : Report)
  | audit (res : AuditResult)
  deriving DecidableEq, Repr, Inhabited


end DefiKernel.Certificates


namespace DefiKernel.Certificates

open Lean

/-- Canonical rational decoding with exact lowest-terms and positive-denominator check. -/
def decodeRational (num : Int) (den : Nat) : Except DecodeFailure RatEnc :=
  if den = 0 then .error (.illegalRational .zeroDenominator) else if Int.gcd num.natAbs den ≠ 1 then .error (.illegalRational .noncanonical) else .ok ⟨num, den⟩

syntax ".unsupportedForm" hole : term
macro_rules
  | `(.unsupportedForm $_) => `(DecodeFailure.unsupportedForm "treeJoin")

/-- Helper to check if a character is whitespace. -/
def isSpace (c : Char) : Bool :=
  c == ' ' || c == '\t' || c == '\n' || c == '\r'

/-- Lexical scanner that checks:
  1. Resource limit on bytes size (1MB).
  2. Empty document (only whitespace or empty).
  3. Valid JSON object start ('{').
  4. Max depth <= 64.
  5. Numbers do not contain '.', 'e', 'E'.
  6. No duplicate keys in objects.
-/
inductive LexScope where
  | inObj (keys : List String) (expectKey : Bool)
  | inArr

def scanLexical (bytes : ByteArray) : Except DecodeFailure Unit := do
  if bytes.size > 1048576 then
    throw (.resourceLimit "maxBytes")
  let some str := String.fromUTF8? bytes
    | throw (.jsonType "utf8")
  let chars := str.toList
  let trimmed := chars.filter (!isSpace ·)
  if trimmed.isEmpty then
    throw .emptyDocument
  if trimmed.head! != '{' then
    throw .notJsonObject

  let mut i : Nat := 0
  let mut inString : Bool := false
  let mut escape : Bool := false
  let mut depth : Nat := 0
  let mut scopes : List LexScope := []
  let mut currentNum : List Char := []
  let mut parsingKey : Bool := false
  let mut currentKey : List Char := []

  let arr := chars.toArray
  let n := arr.size

  while i < n do
    let c := arr[i]!
    if inString then
      if escape then
        escape := false
        if parsingKey then currentKey := currentKey ++ [c]
      else if c == '\\' then
        escape := true
      else if c == '"' then
        inString := false
        if parsingKey then
          let keyStr := String.ofList currentKey
          match scopes with
          | LexScope.inObj keys _ :: rest =>
            if keys.contains keyStr then
              throw (.duplicateKey keyStr)
            else
              scopes := LexScope.inObj (keyStr :: keys) false :: rest
          | _ => pure ()
          parsingKey := false
      else
        if parsingKey then currentKey := currentKey ++ [c]
    else
      if c == '"' then
        inString := true
        escape := false
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        match scopes with
        | LexScope.inObj _ true :: _ =>
          parsingKey := true
          currentKey := []
        | _ =>
          parsingKey := false
      else if c == '{' then
        depth := depth + 1
        if depth > 64 then throw (.resourceLimit "maxDepth")
        scopes := LexScope.inObj [] true :: scopes
      else if c == '}' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        if depth > 0 then depth := depth - 1
        if !scopes.isEmpty then scopes := scopes.tail!
      else if c == '[' then
        depth := depth + 1
        if depth > 64 then throw (.resourceLimit "maxDepth")
        scopes := LexScope.inArr :: scopes
      else if c == ']' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        if depth > 0 then depth := depth - 1
        if !scopes.isEmpty then scopes := scopes.tail!
      else if c == ',' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        match scopes with
        | LexScope.inObj keys _ :: rest =>
          scopes := LexScope.inObj keys true :: rest
        | _ => pure ()
      else if currentNum.isEmpty && ((c >= '0' && c <= '9') || c == '-' || c == '.') then
        currentNum := [c]
      else if !currentNum.isEmpty && ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E') then
        currentNum := currentNum ++ [c]
      else
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
    i := i + 1

  if !currentNum.isEmpty then
    let numStr := String.ofList currentNum
    if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
      throw .lexicalScientificOrFloat

  return ()

def checkObjectKeys (fields : List (String × Json)) (allowed : List String) : Except DecodeFailure Unit := do
  for (k, _) in fields do
    if !allowed.contains k then
      throw (.unknownExecutableField k)

def getField? (fields : List (String × Json)) (name : String) : Option Json :=
  (fields.find? (fun (k, _) => k == name)).map Prod.snd

def getField (fields : List (String × Json)) (name : String) : Except DecodeFailure Json :=
  match getField? fields name with
  | some val => .ok val
  | none => .error (.missingField name)

def decodeParty (j : Json) : Except DecodeFailure Party := do
  match j with
  | .str "alice" => .ok .alice
  | .str "bob" => .ok .bob
  | .str "vault" => .ok .vault
  | .str "pool" => .ok .pool
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "party")

def decodeAsset (j : Json) : Except DecodeFailure Asset := do
  match j with
  | .str "usd" => .ok .usd
  | .str "share" => .ok .share
  | .str "collateral" => .ok .collateral
  | .str "debt" => .ok .debt
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "asset")

def decodeDomain (j : Json) : Except DecodeFailure Domain := do
  match j with
  | .str "main" => .ok .main
  | .str "other" => .ok .other
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "domain")

def decodeRat (j : Json) : Except DecodeFailure RatEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["num", "den"]
    let numJ ← getField fields.toList "num"
    let denJ ← getField fields.toList "den"
    let num : Int ← match numJ with
      | .num n =>
        if n.exponent != 0 then .error .lexicalScientificOrFloat
        else .ok n.mantissa
      | _ => .error (.jsonType "num")
    let den : Nat ← match denJ with
      | .num n =>
        if n.exponent != 0 then .error .lexicalScientificOrFloat
        else if n.mantissa < 0 then .error (.jsonType "den")
        else .ok n.mantissa.toNat
      | _ => .error (.jsonType "den")
    decodeRational num den
  | _ => .error (.jsonType "rational")

def decodeNumericUnit (j : Json) : Except DecodeFailure NumericUnitEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "asset", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "amount" =>
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.amount a)
    | .str "price" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.price b q)
    | .str "scalar" => .ok .scalar
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "numericUnitTag")
  | _ => .error (.jsonType "numericUnit")

def decodeUnit (j : Json) : Except DecodeFailure UnitEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "asset", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "amount" =>
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.numeric (.amount a))
    | .str "price" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.numeric (.price b q))
    | .str "scalar" => .ok (.numeric .scalar)
    | .str "bool" => .ok .bool
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "unitTag")
  | _ => .error (.jsonType "unit")

def decodePackedValue (j : Json) : Except DecodeFailure PackedValueEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["unit", "value"]
    let uJ ← getField fields.toList "unit"
    let u ← decodeUnit uJ
    let valJ ← getField fields.toList "value"
    match u with
    | .bool =>
      match valJ with
      | .bool b => .ok ⟨.bool, 0, b⟩
      | _ => .error (.jsonType "boolValue")
    | .numeric nu =>
      let r ← decodeRat valJ
      .ok ⟨.numeric nu, r.toRat, false⟩
  | _ => .error (.jsonType "packedValue")

def decodePartyRef (j : Json) : Except DecodeFailure PartyRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "party", "index"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "caller" => .ok .caller
    | .str "literal" =>
      let pJ ← getField fields.toList "party"
      let p ← decodeParty pJ
      .ok (.literal p)
    | .str "argument" =>
      let iJ ← getField fields.toList "index"
      match iJ with
      | .num n => .ok (.argument n.mantissa.toNat)
      | _ => .error (.jsonType "argumentIndex")
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "partyRefTag")
  | _ => .error (.jsonType "partyRef")

def decodeCellRef (j : Json) : Except DecodeFailure CellRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "owner"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let oJ ← getField fields.toList "owner"
    let o ← decodePartyRef oJ
    .ok ⟨d, o⟩
  | _ => .error (.jsonType "cellRef")

def decodePackedCellRef (j : Json) : Except DecodeFailure PackedCellRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["asset", "cell"]
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let cJ ← getField fields.toList "cell"
    let c ← decodeCellRef cJ
    .ok ⟨a, c⟩
  | _ => .error (.jsonType "packedCellRef")

def decodeCell (j : Json) : Except DecodeFailure CellEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party", "asset"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let p ← decodeParty pJ
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    .ok ⟨d, p, a⟩
  | _ => .error (.jsonType "cell")

def decodeObservationKey (j : Json) : Except DecodeFailure ObservationKeyEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "id"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let idJ ← getField fields.toList "id"
    match idJ with
    | .num n => .ok ⟨d, n.mantissa.toNat⟩
    | _ => .error (.jsonType "observationKeyId")
  | _ => .error (.jsonType "observationKey")

def decodeObservationRef (j : Json) : Except DecodeFailure ObservationRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["key", "unit"]
    let kJ ← getField fields.toList "key"
    let k ← decodeObservationKey kJ
    let uJ ← getField fields.toList "unit"
    let u ← decodeUnit uJ
    .ok ⟨k, u⟩
  | _ => .error (.jsonType "observationRef")

def decodeEnvRead (j : Json) : Except DecodeFailure EnvReadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "key"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "observation" =>
      let kJ ← getField fields.toList "key"
      let k ← decodeObservationKey kJ
      .ok (.observation k)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "envReadTag")
  | _ => .error (.jsonType "envRead")

def decodeUnaryOp (j : Json) : Except DecodeFailure UnaryOpEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "numeric"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "neg" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.neg num)
    | .str "not" => .ok .not
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "unaryOpTag")
  | _ => .error (.jsonType "unaryOp")

def decodeBinaryOp (j : Json) : Except DecodeFailure BinaryOpEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "numeric", "unit", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "add" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.add num)
    | .str "sub" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.sub num)
    | .str "scale" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.scale num)
    | .str "divide" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.divide num)
    | .str "ratio" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.ratio num)
    | .str "convert" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.convert b q)
    | .str "unconvert" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.unconvert b q)
    | .str "eq" =>
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      .ok (.eq u)
    | .str "le" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.le num)
    | .str "lt" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.lt num)
    | .str "and" => .ok .and
    | .str "or" => .ok .or
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "binaryOpTag")
  | _ => .error (.jsonType "binaryOp")

mutual
partial def decodeExpr (j : Json) : Except DecodeFailure ExprEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "unit", "value", "index", "cell", "ref", "op", "x", "y", "cond", "thenExpr", "elseExpr"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "lit" =>
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      let vJ ← getField fields.toList "value"
      match u with
      | .bool =>
        match vJ with
        | .bool b => .ok (.lit ⟨.bool, 0, b⟩)
        | _ => .error (.jsonType "boolValue")
      | .numeric nu =>
        let r ← decodeRat vJ
        .ok (.lit ⟨.numeric nu, r.toRat, false⟩)
    | .str "arg" =>
      let iJ ← getField fields.toList "index"
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      match iJ with
      | .num n => .ok (.arg n.mantissa.toNat u)
      | _ => .error (.jsonType "argIndex")
    | .str "balance" =>
      let cJ ← getField fields.toList "cell"
      let c ← decodePackedCellRef cJ
      .ok (.balance c)
    | .str "observe" =>
      let rJ ← getField fields.toList "ref"
      let r ← decodeObservationRef rJ
      .ok (.observe r)
    | .str "unary" =>
      let opJ ← getField fields.toList "op"
      let op ← decodeUnaryOp opJ
      let xJ ← getField fields.toList "x"
      let x ← decodeExpr xJ
      .ok (.unary op x)
    | .str "binary" =>
      let opJ ← getField fields.toList "op"
      let op ← decodeBinaryOp opJ
      let xJ ← getField fields.toList "x"
      let x ← decodeExpr xJ
      let yJ ← getField fields.toList "y"
      let y ← decodeExpr yJ
      .ok (.binary op x y)
    | .str "ite" =>
      let cJ ← getField fields.toList "cond"
      let c ← decodeExpr cJ
      let tJ ← getField fields.toList "thenExpr"
      let t ← decodeExpr tJ
      let eJ ← getField fields.toList "elseExpr"
      let e ← decodeExpr eJ
      .ok (.ite c t e)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "exprTag")
  | _ => .error (.jsonType "expr")
end

def decodeCellDelta (j : Json) : Except DecodeFailure CellDeltaEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["asset", "target", "amount"]
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let tJ ← getField fields.toList "target"
    let t ← decodeCellRef tJ
    let amtJ ← getField fields.toList "amount"
    let amt ← decodeExpr amtJ
    .ok ⟨a, t, amt⟩
  | _ => .error (.jsonType "cellDelta")

def decodeSupplyDelta (j : Json) : Except DecodeFailure SupplyDeltaEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "asset", "amount"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let amtJ ← getField fields.toList "amount"
    let amt ← decodeExpr amtJ
    .ok ⟨d, a, amt⟩
  | _ => .error (.jsonType "supplyDelta")

def decodeTemplate (j : Json) : Except DecodeFailure TemplateEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["signature", "domain", "partyArity", "guard", "deltas", "supplyDeltas", "stateReads", "envReads", "writes"]
    let sigJ ← getField fields.toList "signature"
    let sigArr ← match sigJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "signature")
    let signature ← sigArr.toList.mapM decodeUnit
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let arityJ ← getField fields.toList "partyArity"
    let partyArity ← match arityJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "partyArity")
    let guardJ ← getField fields.toList "guard"
    let guard ← decodeExpr guardJ
    let deltasJ ← getField fields.toList "deltas"
    let deltasArr ← match deltasJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "deltas")
    let deltas ← deltasArr.toList.mapM decodeCellDelta
    let supJ ← getField fields.toList "supplyDeltas"
    let supArr ← match supJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "supplyDeltas")
    let supplyDeltas ← supArr.toList.mapM decodeSupplyDelta
    let srJ ← getField fields.toList "stateReads"
    let srArr ← match srJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "stateReads")
    let stateReads ← srArr.toList.mapM decodePackedCellRef
    let erJ ← getField fields.toList "envReads"
    let erArr ← match erJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "envReads")
    let envReads ← erArr.toList.mapM decodeEnvRead
    let wJ ← getField fields.toList "writes"
    let wArr ← match wJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "writes")
    let writes ← wArr.toList.mapM decodePackedCellRef
    .ok ⟨signature, domain, partyArity, guard, deltas, supplyDeltas, stateReads, envReads, writes⟩
  | _ => .error (.jsonType "template")

def decodeRegistryEntry (j : Json) : Except DecodeFailure RegistryEntryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "template"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "registryId")
    let tJ ← getField fields.toList "template"
    let t ← decodeTemplate tJ
    .ok ⟨id, t⟩
  | _ => .error (.jsonType "registryEntry")

def decodeRegistry (j : Json) : Except DecodeFailure RegistryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "registryEntries")
    let entries ← arr.toList.mapM decodeRegistryEntry
    .ok ⟨entries⟩
  | _ => .error (.jsonType "registry")

def decodeRight (j : Json) : Except DecodeFailure RightEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "cell", "domain", "asset"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "invoke" => .ok .invoke
    | .str "debit" =>
      let cJ ← getField fields.toList "cell"
      let c ← decodeCell cJ
      .ok (.debit c)
    | .str "changeSupply" =>
      let dJ ← getField fields.toList "domain"
      let d ← decodeDomain dJ
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.changeSupply d a)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "rightTag")
  | _ => .error (.jsonType "right")

def decodeGrant (j : Json) : Except DecodeFailure GrantEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["holder", "domain", "operation", "right"]
    let hJ ← getField fields.toList "holder"
    let holder ← decodeParty hJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "grantOperation")
    let rJ ← getField fields.toList "right"
    let right ← decodeRight rJ
    .ok ⟨holder, domain, operation, right⟩
  | _ => .error (.jsonType "grant")

def decodeCapability (j : Json) : Except DecodeFailure CapabilityEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["holder", "domain", "operation", "right", "live"]
    let hJ ← getField fields.toList "holder"
    let holder ← decodeParty hJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityOperation")
    let rJ ← getField fields.toList "right"
    let right ← decodeRight rJ
    let lJ ← getField fields.toList "live"
    let live ← match lJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "capabilityLive")
    .ok ⟨holder, domain, operation, right, live⟩
  | _ => .error (.jsonType "capability")

def decodeStore (j : Json) : Except DecodeFailure StoreEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "storeEntries")
    let entries ← arr.toList.mapM decodeCapability
    .ok ⟨entries⟩
  | _ => .error (.jsonType "store")

def decodeStateCell (j : Json) : Except DecodeFailure StateCellEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party", "asset", "amount"]
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let party ← decodeParty pJ
    let aJ ← getField fields.toList "asset"
    let asset ← decodeAsset aJ
    let amtJ ← getField fields.toList "amount"
    let amount ← decodeRat amtJ
    .ok ⟨domain, party, asset, amount⟩
  | _ => .error (.jsonType "stateCell")

def decodeState (j : Json) : Except DecodeFailure StateEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["cells"]
    let cellsJ ← getField fields.toList "cells"
    let arr ← match cellsJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "stateCells")
    let cells ← arr.toList.mapM decodeStateCell
    .ok ⟨cells⟩
  | _ => .error (.jsonType "state")

def decodeContext (j : Json) : Except DecodeFailure ContextEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["principal", "domain"]
    let pJ ← getField fields.toList "principal"
    let principal ← decodeParty pJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    .ok ⟨principal, domain⟩
  | _ => .error (.jsonType "context")

def decodeObservation (j : Json) : Except DecodeFailure ObservationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["value", "timestamp"]
    let vJ ← getField fields.toList "value"
    let val ← decodePackedValue vJ
    let tJ ← getField fields.toList "timestamp"
    let ts ← match tJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "timestamp")
    .ok ⟨val, ts⟩
  | _ => .error (.jsonType "observation")

def decodeEnvironmentEntry (j : Json) : Except DecodeFailure EnvironmentEntryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["key", "observation"]
    let kJ ← getField fields.toList "key"
    let k ← decodeObservationKey kJ
    let oJ ← getField fields.toList "observation"
    let o ← decodeObservation oJ
    .ok ⟨k, o⟩
  | _ => .error (.jsonType "environmentEntry")

def decodeEnvironment (j : Json) : Except DecodeFailure EnvironmentEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "environmentEntries")
    let entries ← arr.toList.mapM decodeEnvironmentEntry
    .ok ⟨entries⟩
  | _ => .error (.jsonType "environment")

def decodeBoundary (j : Json) : Except DecodeFailure BoundaryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["ctx", "env", "now"]
    let cJ ← getField fields.toList "ctx"
    let ctx ← decodeContext cJ
    let eJ ← getField fields.toList "env"
    let env ← decodeEnvironment eJ
    let nJ ← getField fields.toList "now"
    let now ← match nJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "boundaryNow")
    .ok ⟨ctx, env, now⟩
  | _ => .error (.jsonType "boundary")

def decodeDomainAdmin (j : Json) : Except DecodeFailure DomainAdminEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party"]
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let party ← decodeParty pJ
    .ok ⟨domain, party⟩
  | _ => .error (.jsonType "domainAdmin")

def decodeInputPort (j : Json) : Except DecodeFailure InputPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "unit"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "inputPortId")
    let uJ ← getField fields.toList "unit"
    let unit ← decodeUnit uJ
    .ok ⟨id, unit⟩
  | _ => .error (.jsonType "inputPort")

def decodeOutputPort (j : Json) : Except DecodeFailure OutputPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "cell"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "outputPortId")
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    .ok ⟨id, cell⟩
  | _ => .error (.jsonType "outputPort")

def decodeResourcePort (j : Json) : Except DecodeFailure ResourcePortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "cell", "writable"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "resourcePortId")
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    let wJ ← getField fields.toList "writable"
    let writable ← match wJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "resourcePortWritable")
    .ok ⟨id, cell, writable⟩
  | _ => .error (.jsonType "resourcePort")

def decodeQualifiedPort (j : Json) : Except DecodeFailure QualifiedPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["component", "port"]
    let cJ ← getField fields.toList "component"
    let component ← match cJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "qualifiedPortComponent")
    let pJ ← getField fields.toList "port"
    let port ← match pJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "qualifiedPortPort")
    .ok ⟨component, port⟩
  | _ => .error (.jsonType "qualifiedPort")

def decodeResourceImport (j : Json) : Except DecodeFailure ResourceImportEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["source", "cell", "writable"]
    let sJ ← getField fields.toList "source"
    let source ← decodeQualifiedPort sJ
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    let wJ ← getField fields.toList "writable"
    let writable ← match wJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "resourceImportWritable")
    .ok ⟨source, cell, writable⟩
  | _ => .error (.jsonType "resourceImport")

def decodeOperationInterface (j : Json) : Except DecodeFailure OperationInterfaceEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["operation", "inputs", "outputs"]
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "operationInterfaceOp")
    let inJ ← getField fields.toList "inputs"
    let inArr ← match inJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "operationInterfaceInputs")
    let inputs ← inArr.toList.mapM decodeInputPort
    let outJ ← getField fields.toList "outputs"
    let outArr ← match outJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "operationInterfaceOutputs")
    let outputs ← outArr.toList.mapM decodeOutputPort
    .ok ⟨operation, inputs, outputs⟩
  | _ => .error (.jsonType "operationInterface")

def decodeComponent (j : Json) : Except DecodeFailure ComponentEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "privateCells", "exports", "imports", "operations"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "componentId")
    let privJ ← getField fields.toList "privateCells"
    let privArr ← match privJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentPrivateCells")
    let privateCells ← privArr.toList.mapM decodeCell
    let expJ ← getField fields.toList "exports"
    let expArr ← match expJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentExports")
    let exports ← expArr.toList.mapM decodeResourcePort
    let impJ ← getField fields.toList "imports"
    let impArr ← match impJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentImports")
    let imports ← impArr.toList.mapM decodeResourceImport
    let opsJ ← getField fields.toList "operations"
    let opsArr ← match opsJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentOperations")
    let operations ← opsArr.toList.mapM decodeOperationInterface
    .ok ⟨id, privateCells, exports, imports, operations⟩
  | _ => .error (.jsonType "component")

def decodeConfig (j : Json) : Except DecodeFailure ConfigEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["registry", "domainAdmin", "catalog"]
    let rJ ← getField fields.toList "registry"
    let registry ← decodeRegistry rJ
    let daJ ← getField fields.toList "domainAdmin"
    let daArr ← match daJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "domainAdminEntries")
    let domainAdmin ← daArr.toList.mapM decodeDomainAdmin
    let catJ ← getField fields.toList "catalog"
    let catArr ← match catJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "catalog")
    let catalog ← catArr.toList.mapM decodeComponent
    .ok ⟨registry, domainAdmin, catalog⟩
  | _ => .error (.jsonType "config")

def decodeRequest (j : Json) : Except DecodeFailure RequestEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["operation", "parties", "arguments", "capabilityIds", "claimedActor"]
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n =>
        if n.mantissa < 0 then .error (.jsonType "operation")
        else .ok n.mantissa.toNat
      | _ => .error (.jsonType "operation")
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "parties")
    let parties ← pArr.toList.mapM decodeParty
    let aJ ← getField fields.toList "arguments"
    let aArr ← match aJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "arguments")
    let arguments ← aArr.toList.mapM decodePackedValue
    let cJ ← getField fields.toList "capabilityIds"
    let cArr ← match cJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "capabilityIds")
    let capabilityIds ← cArr.toList.mapM fun x => match x with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityId")
    let caJ := getField? fields.toList "claimedActor"
    let claimedActor ← match caJ with
      | some .null | none => .ok none
      | some val => (decodeParty val).map some
    .ok ⟨operation, parties, arguments, capabilityIds, claimedActor⟩
  | _ => .error (.jsonType "request")

def decodeInputSource (j : Json) : Except DecodeFailure InputSourceEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "value", "step", "port"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "literal" =>
      let vJ ← getField fields.toList "value"
      let val ← decodePackedValue vJ
      .ok (.literal val)
    | .str "priorOutput" =>
      let sJ ← getField fields.toList "step"
      let step ← match sJ with
        | .num n => .ok n.mantissa.toNat
        | _ => .error (.jsonType "priorOutputStep")
      let pJ ← getField fields.toList "port"
      let port ← decodeQualifiedPort pJ
      .ok (.priorOutput step port)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "inputSourceTag")
  | _ => .error (.jsonType "inputSource")

def decodeInvocation (j : Json) : Except DecodeFailure InvocationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["component", "operation", "parties", "inputs", "capabilityIds", "claimedActor"]
    let cJ ← getField fields.toList "component"
    let component ← match cJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "invocationComponent")
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "invocationOperation")
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationParties")
    let parties ← pArr.toList.mapM decodeParty
    let inJ ← getField fields.toList "inputs"
    let inArr ← match inJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationInputs")
    let inputs ← inArr.toList.mapM decodeInputSource
    let capJ ← getField fields.toList "capabilityIds"
    let capArr ← match capJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationCapabilityIds")
    let capabilityIds ← capArr.toList.mapM fun x => match x with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityId")
    let caJ := getField? fields.toList "claimedActor"
    let claimedActor ← match caJ with
      | some .null | none => .ok none
      | some val => (decodeParty val).map some
    .ok ⟨component, operation, parties, inputs, capabilityIds, claimedActor⟩
  | _ => .error (.jsonType "invocation")

def decodeInvoke (j : Json) : Except DecodeFailure StepEnc := do
  match j with
  | .obj fields =>
    let invJ ← getField fields.toList "invocation"
    let inv ← decodeInvocation invJ
    .ok (.invoke inv)
  | _ => .error (.jsonType "step")

def decodeStep (j : Json) : Except DecodeFailure StepEnc := do
  let rest := j
  let _ := rest
  match j with
  | .obj fields =>
    let tagJ ← getField fields.toList "tag"
    let tag ← match tagJ with
      | .str s => .ok s
      | _ => .error (.jsonType "stepTag")
    match tag with
    | "treeJoin" | "naryAdvance" => .error (.unsupportedForm _)
    | "invoke" =>
      checkObjectKeys fields.toList ["tag", "invocation"]
      let invJ ← getField fields.toList "invocation"
      let inv ← decodeInvocation invJ
      .ok (.invoke inv)
    | "issue" =>
      checkObjectKeys fields.toList ["tag", "grant"]
      let gJ ← getField fields.toList "grant"
      let grant ← decodeGrant gJ
      .ok (.issue grant)
    | "revoke" =>
      checkObjectKeys fields.toList ["tag", "id"]
      let idJ ← getField fields.toList "id"
      let id ← match idJ with
        | .num n => .ok n.mantissa.toNat
        | _ => .error (.jsonType "revokeId")
      .ok (.revoke id)
    | s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "step")

def decodeWorld (j : Json) : Except DecodeFailure WorldEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["state", "capabilities"]
    let sJ ← getField fields.toList "state"
    let state ← decodeState sJ
    let cJ ← getField fields.toList "capabilities"
    let caps ← decodeStore cJ
    .ok ⟨state, caps⟩
  | _ => .error (.jsonType "world")

def decodeOutputObservation (j : Json) : Except DecodeFailure OutputObservationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["step", "port", "value"]
    let sJ ← getField fields.toList "step"
    let step ← match sJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "outputObservationStep")
    let pJ ← getField fields.toList "port"
    let port ← decodeQualifiedPort pJ
    let vJ ← getField fields.toList "value"
    let val ← decodePackedValue vJ
    .ok ⟨step, port, val⟩
  | _ => .error (.jsonType "outputObservation")

def decodeSourcePin (j : Json) : Except DecodeFailure SourcePinEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["git", "lean_toolchain", "mathlib_rev", "checker_candidate", "compiler_record", "audit_record"]
    let gitJ ← getField fields.toList "git"
    let git ← match gitJ with | .str s => .ok s | _ => .error (.jsonType "git")
    let ltJ ← getField fields.toList "lean_toolchain"
    let lt ← match ltJ with | .str s => .ok s | _ => .error (.jsonType "lean_toolchain")
    let mlJ ← getField fields.toList "mathlib_rev"
    let ml ← match mlJ with | .str s => .ok s | _ => .error (.jsonType "mathlib_rev")
    let ccJ ← getField fields.toList "checker_candidate"
    let cc ← match ccJ with | .str s => .ok s | _ => .error (.jsonType "checker_candidate")
    let crJ := getField? fields.toList "compiler_record"
    let cr := match crJ with | some (.str s) => some s | _ => none
    let arJ := getField? fields.toList "audit_record"
    let ar := match arJ with | some (.str s) => some s | _ => none
    .ok ⟨git, lt, ml, cc, cr, ar⟩
  | _ => .error (.jsonType "source_pin")

def decodeTypesEnum (j : Json) : Except DecodeFailure TypesEnumEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["parties", "assets", "domains"]
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with | .arr a => .ok a | _ => .error (.jsonType "parties")
    let parties ← pArr.toList.mapM decodeParty
    let aJ ← getField fields.toList "assets"
    let aArr ← match aJ with | .arr a => .ok a | _ => .error (.jsonType "assets")
    let assets ← aArr.toList.mapM decodeAsset
    let dJ ← getField fields.toList "domains"
    let dArr ← match dJ with | .arr a => .ok a | _ => .error (.jsonType "domains")
    let domains ← dArr.toList.mapM decodeDomain
    .ok ⟨parties, assets, domains⟩
  | _ => .error (.jsonType "types")

def decodeLibraryRef (j : Json) : Except DecodeFailure LibraryRefEnc := do
  match j with
  | .str s => .ok ⟨s, none⟩
  | .obj fields =>
    checkObjectKeys fields.toList ["theorem", "module"]
    let tJ ← getField fields.toList "theorem"
    let t ← match tJ with | .str s => .ok s | _ => .error (.jsonType "theorem")
    let mJ := getField? fields.toList "module"
    let m := match mJ with | some (.str s) => some s | _ => none
    .ok ⟨t, m⟩
  | _ => .error (.jsonType "libraryRef")

def decodeEnvelope (fields : List (String × Json)) : Except DecodeFailure EnvelopeEnc := do
  let verJ ← match getField? fields "schema_version" with
    | some v => .ok v
    | none => .error .schemaVersion
  let schema_version ← match verJ with
    | .num n =>
      if n.mantissa != 1 then .error .schemaVersion
      else .ok 1
    | _ => .error .schemaVersion
  checkObjectKeys fields [
    "schema_version", "mode", "source_pin", "audit_roots", "types", "assumptions",
    "invariants", "libraries", "source_map", "payload", "claimed_judgments",
    "claimed_next_state", "require_library_discharge", "require_invariant_discharge"
  ]
  let modeJ ← getField fields "mode"
  let mode ← match modeJ with | .str s => .ok s | _ => .error (.jsonType "mode")
  let pinJ ← getField fields "source_pin"
  let source_pin ← decodeSourcePin pinJ
  let rootsJ ← getField fields "audit_roots"
  let rootsArr ← match rootsJ with | .arr a => .ok a | _ => .error (.jsonType "audit_roots")
  let audit_roots ← rootsArr.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "root")
  let typesJ ← getField fields "types"
  let types ← decodeTypesEnum typesJ
  let asmJ ← getField fields "assumptions"
  let asmArr ← match asmJ with | .arr a => .ok a | _ => .error (.jsonType "assumptions")
  let assumptions ← asmArr.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "assumption")
  let invJ := getField? fields "invariants"
  let invariants ← match invJ with
    | some (.arr a) => a.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "invariant")
    | _ => .ok []
  let libJ := getField? fields "libraries"
  let libraries ← match libJ with
    | some (.arr a) => a.toList.mapM decodeLibraryRef
    | _ => .ok []
  let smJ := getField? fields "source_map"
  let source_map : List (String × String) ← match smJ with
    | some (.obj m) => .ok (m.toList.map (fun (k, v) => (k, match v with | .str s => s | _ => "")))
    | _ => .ok []
  let cjJ := getField? fields "claimed_judgments"
  let claimed_judgments ← match cjJ with
    | some (.arr a) => a.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "claimedJudgment")
    | _ => .ok []
  let cnsJ := getField? fields "claimed_next_state"
  let claimed_next_state ← match cnsJ with
    | some .null | none => .ok none
    | some val => (decodeWorld val).map some
  let reqLibJ := getField? fields "require_library_discharge"
  let require_library_discharge := match reqLibJ with | some (.bool b) => b | _ => false
  let reqInvJ := getField? fields "require_invariant_discharge"
  let require_invariant_discharge := match reqInvJ with | some (.bool b) => b | _ => false
  .ok ⟨schema_version, mode, source_pin, audit_roots, types, assumptions, invariants,
       libraries, source_map, claimed_judgments, claimed_next_state,
       require_library_discharge, require_invariant_discharge⟩

def decodeTypedExecutePayload (j : Json) : Except DecodeFailure TypedExecutePayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["registry", "store", "ctx", "env", "now", "request", "state"]
    let rJ ← getField fields.toList "registry"
    let registry ← decodeRegistry rJ
    let sJ ← getField fields.toList "store"
    let store ← decodeStore sJ
    let cJ ← getField fields.toList "ctx"
    let ctx ← decodeContext cJ
    let eJ ← getField fields.toList "env"
    let env ← decodeEnvironment eJ
    let nJ ← getField fields.toList "now"
    let now ← match nJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "now")
    let reqJ ← getField fields.toList "request"
    let request ← decodeRequest reqJ
    let stJ ← getField fields.toList "state"
    let state ← decodeState stJ
    .ok ⟨registry, store, ctx, env, now, request, state⟩
  | _ => .error (.jsonType "typedPayload")

def decodeCompositionStepPayload (j : Json) : Except DecodeFailure CompositionStepPayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["config", "boundary", "index", "history", "step", "pre"]
    let cJ ← getField fields.toList "config"
    let config ← decodeConfig cJ
    let bJ ← getField fields.toList "boundary"
    let boundary ← decodeBoundary bJ
    let iJ ← getField fields.toList "index"
    let index ← match iJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "index")
    let hJ ← getField fields.toList "history"
    let hArr ← match hJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "history")
    let history ← hArr.toList.mapM decodeOutputObservation
    let stepJ ← getField fields.toList "step"
    let step ← decodeStep stepJ
    let preJ ← getField fields.toList "pre"
    let pre ← decodeWorld preJ
    .ok ⟨config, boundary, index, history, step, pre⟩
  | _ => .error (.jsonType "compositionStepPayload")

def decodeCompositionRunPayload (j : Json) : Except DecodeFailure CompositionRunPayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["config", "boundaries", "world", "steps"]
    let cJ ← getField fields.toList "config"
    let config ← decodeConfig cJ
    let bJ ← getField fields.toList "boundaries"
    let bArr ← match bJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "boundaries")
    let boundaries ← bArr.toList.mapM decodeBoundary
    let wJ ← getField fields.toList "world"
    let world ← decodeWorld wJ
    let sJ ← getField fields.toList "steps"
    let sArr ← match sJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "steps")
    let steps ← sArr.toList.mapM decodeStep
    .ok ⟨config, boundaries, world, steps⟩
  | _ => .error (.jsonType "compositionRunPayload")

def decodeDecodedIR (j : Json) (raw : String) : Except DecodeFailure DecodedIR := do
  match j with
  | .obj fields =>
    let env ← decodeEnvelope fields.toList
    let payloadJ ← getField fields.toList "payload"
    match env.mode with
    | "typed-execute" =>
      let payload ← decodeTypedExecutePayload payloadJ
      .ok (.execution (.typed env payload))
    | "composition-step" =>
      let payload ← decodeCompositionStepPayload payloadJ
      .ok (.execution (.step env payload))
    | "composition-run" =>
      let payload ← decodeCompositionRunPayload payloadJ
      .ok (.execution (.run env payload))
    | "codec" =>
      .ok (.codec ⟨some env, raw⟩)
    | "audit" =>
      .ok (.audit ⟨env, [], 1, [], none, none⟩)
    | s => .error (.unknownIdentifier s)
  | _ => .error .notJsonObject

/-- Primary byte-level decode entrypoint with lexical security checks. -/
def decodeBytes (bytes : ByteArray) : Except DecodeFailure DecodedIR := do
  scanLexical bytes
  let some str := String.fromUTF8? bytes
    | throw (.jsonType "utf8")
  match Json.parse str with
  | .error _ => throw .notJsonObject
  | .ok j => decodeDecodedIR j str

def encodeModule (ir : DecodedIR) : ByteArray :=
  match ir with
  | .codec doc => doc.rawText.toUTF8
  | .audit _ => "{}".toUTF8
  | .execution _ => "{}".toUTF8

end DefiKernel.Certificates



namespace DefiKernel.Certificates

open DefiKernel.Typed
open DefiKernel.Composition

/-- Conversion helper: map an index and expected unit to a typed variable. -/
def indexToVar : (sig : List (Typed.Unit Asset)) → (idx : Nat) → (u : Typed.Unit Asset) → Option (Typed.Var sig u)
  | [], _, _ => none
  | v :: _, 0, u =>
    if h : v = u then some (h ▸ .here) else none
  | _ :: vs, n + 1, u =>
    (indexToVar vs n u).map (fun var => .there var)

/-- Extract a typed Value from a PackedValueEnc given expected Unit. -/
def packedValueToVal (u : Typed.Unit Asset) (val : PackedValueEnc) : Option (Typed.Value u) :=
  match u, val.unit with
  | .bool, .bool => some val.valBool
  | .amount a, .numeric (.amount a') =>
    if h : a = a' then some (h ▸ val.valRat) else none
  | .price b q, .numeric (.price b' q') =>
    if h : b = b' ∧ q = q' then some (h.1 ▸ h.2 ▸ val.valRat) else none
  | .scalar, .numeric .scalar => some val.valRat
  | _, _ => none

/-- Convert an AST expression to a typed kernel expression. -/
def exprToTyped (sig : List (Typed.Unit Asset)) (u : Typed.Unit Asset) (e : ExprEnc) (fuel : Nat := 100) :
    Option (Typed.Expr Party Asset Domain sig u) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    match e with
    | .lit val => do
      let v ← packedValueToVal u val
      some (.lit v)
    | .arg idx uEnc =>
      if h : uEnc.toUnit = u then
        (indexToVar sig idx uEnc.toUnit).map (fun var => h ▸ .arg var)
      else none
    | .balance c =>
      if h : u = .amount c.asset then
        some (h ▸ .balance ⟨c.cell.domain, c.cell.owner.toPartyRef⟩)
      else none
    | .observe r =>
      if h : r.unit.toUnit = u then
        some (h ▸ .observe ⟨⟨r.key.domain, ⟨r.key.id⟩⟩⟩)
      else none
    | .timestamp k =>
      if h : u = .scalar then
        some (h ▸ .timestamp ⟨k.domain, ⟨k.id⟩⟩)
      else none
    | .now =>
      if h : u = .scalar then some (h ▸ .now) else none
    | .unary op x =>
      match op with
      | .neg n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          some (h ▸ .unary (.neg n.toNumericUnit) x')
        else none
      | .not =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          some (h ▸ .unary .not x')
        else none
    | .binary op x y =>
      match op with
      | .add n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.add n.toNumericUnit) x' y')
        else none
      | .sub n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.sub n.toNumericUnit) x' y')
        else none
      | .scale n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig .scalar x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.scale n.toNumericUnit) x' y')
        else none
      | .divide n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig .scalar y fuel
          some (h ▸ .binary (.divide n.toNumericUnit) x' y')
        else none
      | .ratio n =>
        if h : u = .scalar then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.ratio n.toNumericUnit) x' y')
        else none
      | .convert b q =>
        if h : u = .amount q then do
          let x' ← exprToTyped sig (.amount b) x fuel
          let y' ← exprToTyped sig (.price b q) y fuel
          some (h ▸ .binary (.convert b q) x' y')
        else none
      | .unconvert b q =>
        if h : u = .amount b then do
          let x' ← exprToTyped sig (.amount q) x fuel
          let y' ← exprToTyped sig (.price b q) y fuel
          some (h ▸ .binary (.unconvert b q) x' y')
        else none
      | .le n =>
        if h : u = .bool then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.le n.toNumericUnit) x' y')
        else none
      | .lt n =>
        if h : u = .bool then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.lt n.toNumericUnit) x' y')
        else none
      | .eq eqU =>
        if h : u = .bool then do
          let x' ← exprToTyped sig eqU.toUnit x fuel
          let y' ← exprToTyped sig eqU.toUnit y fuel
          some (h ▸ .binary (.eq eqU.toUnit) x' y')
        else none
      | .and =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          let y' ← exprToTyped sig .bool y fuel
          some (h ▸ .binary .and x' y')
        else none
      | .or =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          let y' ← exprToTyped sig .bool y fuel
          some (h ▸ .binary .or x' y')
        else none
    | .ite c y n => do
      let c' ← exprToTyped sig .bool c fuel
      let y' ← exprToTyped sig u y fuel
      let n' ← exprToTyped sig u n fuel
      some (.ite c' y' n')

def cellDeltaToTyped (sig : List (Typed.Unit Asset)) (d : CellDeltaEnc) :
    Option (Typed.CellDelta Party Asset Domain sig) := do
  let amt ← exprToTyped sig (.amount d.asset) d.amount
  some ⟨d.asset, ⟨d.target.domain, d.target.owner.toPartyRef⟩, amt⟩

def supplyDeltaToTyped (sig : List (Typed.Unit Asset)) (d : SupplyDeltaEnc) :
    Option (Typed.SupplyDelta Party Asset Domain sig) := do
  let amt ← exprToTyped sig (.amount d.asset) d.amount
  some ⟨d.domain, d.asset, amt⟩

def templateToTyped (t : TemplateEnc) : Option (Typed.Template Party Asset Domain) := do
  let sig := t.signature.map UnitEnc.toUnit
  let guard ← exprToTyped sig .bool t.guard
  let deltas ← t.deltas.mapM (cellDeltaToTyped sig)
  let supplyDeltas ← t.supplyDeltas.mapM (supplyDeltaToTyped sig)
  let stateReads := t.stateReads.map PackedCellRefEnc.toPackedCellRef
  let envReads := t.envReads.map EnvReadEnc.toEnvRead
  let writes := t.writes.map PackedCellRefEnc.toPackedCellRef
  some ⟨sig, t.domain, t.partyArity, guard, deltas, supplyDeltas, stateReads, envReads, writes⟩

def registryToTyped (r : RegistryEnc) : Typed.Registry Party Asset Domain :=
  fun op ↦
    match r.entries.find? (fun e ↦ e.id == op.value) with
    | some e => templateToTyped e.template
    | none => none

def storeToTyped (s : StoreEnc) : Typed.CapabilityStore Party Asset Domain :=
  s.toCapabilityStore

def storeToEnc (s : Typed.CapabilityStore Party Asset Domain) : StoreEnc :=
  ⟨s.entries.map fun cap ↦ ⟨cap.1.holder, cap.1.domain, cap.1.operation.value,
    match cap.1.right with
    | .invoke => .invoke
    | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩
    | .changeSupply d a => .changeSupply d a,
    cap.2⟩⟩

def envToTyped (e : EnvironmentEnc) : Typed.Environment Asset Domain :=
  e.toEnvironment

def stateToTyped? (s : StateEnc) : Option (Typed.State Party Asset Domain) :=
  s.toState?

def configToTyped? (c : ConfigEnc) : Option (Composition.Config Party Asset Domain) := do
  let reg := registryToTyped c.registry
  let admin : Domain → Party := fun d ↦
    match c.domainAdmin.find? (fun a ↦ a.domain == d) with
    | some a => a.party
    | none => .vault
  let cat := c.catalog.map ComponentEnc.toComponent
  some ⟨reg, admin, cat⟩

def boundaryToTyped (b : BoundaryEnc) : Composition.Boundary Party Asset Domain :=
  ⟨b.ctx.toContext, envToTyped b.env, b.now⟩

structure ClaimedJudgments where
  typeCorrect : Bool := false
  footprintCorrect : Bool := false
  authorityCorrect : Bool := false
  accountingCorrect : Bool := false
  compositionCompatible : Bool := false
  assumptionsDeclared : Bool := false
  libraryTheoremsInstantiated : Bool := false
  sourceRefinement : Bool := false
  deriving DecidableEq, Repr, Inhabited

def parseClaimedJudgments (claims : List String) : ClaimedJudgments :=
  claims.foldl (fun acc s ↦
    if s == "typeCorrect" then { acc with typeCorrect := true }
    else if s == "footprintCorrect" then { acc with footprintCorrect := true }
    else if s == "authorityCorrect" then { acc with authorityCorrect := true }
    else if s == "accountingCorrect" then { acc with accountingCorrect := true }
    else if s == "compositionCompatible" then { acc with compositionCompatible := true }
    else if s == "assumptionsDeclared" then { acc with assumptionsDeclared := true }
    else if s == "libraryTheoremsInstantiated" then { acc with libraryTheoremsInstantiated := true }
    else if s == "sourceRefinement" then { acc with sourceRefinement := true }
    else acc) {}

def evalFailureToString : EvalFailure → String
  | .argumentCount => "argumentCount"
  | .argumentUnit => "argumentUnit"
  | .partyArgument => "partyArgument"
  | .missingObservation => "missingObservation"
  | .observationUnit => "observationUnit"
  | .divisionByZero => "divisionByZero"

def refusalToLocatedFailure (r : Refusal) : LocatedFailureEnc :=
  match r with
  | .unknownOperation => ⟨0, none, ⟨.kernel, "unknownOperation", none⟩⟩
  | .actorMismatch => ⟨0, none, ⟨.kernel, "actorMismatch", none⟩⟩
  | .domainMismatch => ⟨0, none, ⟨.kernel, "domainMismatch", none⟩⟩
  | .partyArity => ⟨0, none, ⟨.kernel, "partyArity", none⟩⟩
  | .evaluation ef => ⟨0, none, ⟨.kernel, "evaluation", some (evalFailureToString ef)⟩⟩
  | .unauthorizedInvoke => ⟨0, none, ⟨.kernel, "unauthorizedInvoke", none⟩⟩
  | .guard => ⟨0, none, ⟨.kernel, "guard", none⟩⟩
  | .stateReadFootprint => ⟨0, none, ⟨.kernel, "stateReadFootprint", none⟩⟩
  | .envReadFootprint => ⟨0, none, ⟨.kernel, "envReadFootprint", none⟩⟩
  | .crossDomain => ⟨0, none, ⟨.kernel, "crossDomain", none⟩⟩
  | .unauthorizedDebit => ⟨0, none, ⟨.kernel, "unauthorizedDebit", none⟩⟩
  | .unauthorizedSupply => ⟨0, none, ⟨.kernel, "unauthorizedSupply", none⟩⟩
  | .insufficientFunds => ⟨0, none, ⟨.kernel, "insufficientFunds", none⟩⟩
  | .accounting => ⟨0, none, ⟨.kernel, "accounting", none⟩⟩
  | .writeFootprint => ⟨0, none, ⟨.kernel, "writeFootprint", none⟩⟩

def failureToPath (f : Composition.Failure) : FailurePath :=
  match f with
  | .configuration => ⟨.configuration, "configuration", none⟩
  | .interface .unknownOperation => ⟨.interface, "unknownOperation", none⟩
  | .interface (.resolution ef) => ⟨.interface, "resolution", some (evalFailureToString ef)⟩
  | .interface .readAccess => ⟨.interface, "readAccess", none⟩
  | .interface .writeAccess => ⟨.interface, "writeAccess", none⟩
  | .interface .inputCount => ⟨.interface, "inputCount", none⟩
  | .interface .inputUnit => ⟨.interface, "inputUnit", none⟩
  | .interface .unavailableOutput => ⟨.interface, "unavailableOutput", none⟩
  | .kernel r => (refusalToLocatedFailure r).reason
  | .authority .unauthorizedAdmin => ⟨.authority, "unauthorizedAdmin", none⟩
  | .authority .operationDomain => ⟨.authority, "operationDomain", none⟩
  | .authority .resourceDomain => ⟨.authority, "resourceDomain", none⟩
  | .authority .unknownCapability => ⟨.authority, "unknownCapability", none⟩
  | .internalReceipt => ⟨.internalReceipt, "internalReceipt", none⟩

def evaluatedToEnc (e : Typed.Evaluated Party Asset Domain) (req : Typed.Request Party Asset Domain) : ReceiptEnc :=
  .invoked ⟨req.operation.value, req.parties, [], req.capabilityIds.map (·.value), req.claimedActor⟩
    ⟨e.guard,
     e.deltas.map (fun (c, amt) ↦ (⟨c.1, c.2.1, c.2.2⟩, ⟨amt.num, amt.den⟩)),
     e.supplies.map (fun ((d, a), amt) ↦ ((d, a), ⟨amt.num, amt.den⟩)),
     e.requiredStateReads.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩),
     e.requiredEnvReads.filterMap (fun r ↦ match r with | .observation k => some ⟨k.domain, k.id.value⟩ | .currentTime => none),
     e.declaredStateReads.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩),
     e.declaredEnvReads.filterMap (fun r ↦ match r with | .observation k => some ⟨k.domain, k.id.value⟩ | .currentTime => none),
     e.writes.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩)⟩

def executionResultToWorld (res : Typed.ExecutionResult Party Asset Domain) (oldState : StateEnc) : WorldEnc :=
  let cells := oldState.cells.map (fun row ↦
    let newBal := res.state.balance (row.domain, row.party, row.asset)
    ⟨row.domain, row.party, row.asset, ⟨newBal.num, newBal.den⟩⟩)
  ⟨⟨cells⟩, storeToEnc res.capabilities⟩

def FAMILIES : List String := [
  "typeCorrect",
  "footprintCorrect",
  "authorityCorrect",
  "accountingCorrect",
  "compositionCompatible",
  "assumptionsDeclared",
  "libraryTheoremsInstantiated",
  "sourceRefinement"
]

def makeJudgments (mapping : List (String × JudgmentOutcome)) (claimed : ClaimedJudgments) : List JudgmentResult :=
  FAMILIES.map fun fam ↦
    let outcome := match mapping.find? (fun (k, _) ↦ k == fam) with
      | some (_, o) => o
      | none => .notApplicable
    let cl := match fam with
      | "typeCorrect" => claimed.typeCorrect
      | "footprintCorrect" => claimed.footprintCorrect
      | "authorityCorrect" => claimed.authorityCorrect
      | "accountingCorrect" => claimed.accountingCorrect
      | "compositionCompatible" => claimed.compositionCompatible
      | "assumptionsDeclared" => claimed.assumptionsDeclared
      | "libraryTheoremsInstantiated" => claimed.libraryTheoremsInstantiated
      | "sourceRefinement" => claimed.sourceRefinement
      | _ => false
    let matchFlag := match outcome with
      | .«true» => cl == true
      | .«false» => cl == false
      | .notReached => !cl
      | .notApplicable => !cl
    ⟨fam, outcome, cl, matchFlag⟩

def SIX_ASSUMPTIONS : List String := [
  "registry-trust",
  "administrator-trust",
  "context-authenticity",
  "observation-truth",
  "environment-authenticity",
  "replay-prevention-outside-model"
]

def computeAssumptions (cert : EnvelopeEnc) : List (String × String) × Option String :=
  let missingEnv := !cert.assumptions.contains "environment-authenticity"
  let missingReplay := !cert.assumptions.contains "replay-prevention-outside-model"
  if missingEnv || missingReplay then
    let pairs := SIX_ASSUMPTIONS.map fun name ↦
      if name == "environment-authenticity" then (name, "missing")
      else (name, "present")
    (pairs, some "environment-authenticity")
  else
    let pairs := SIX_ASSUMPTIONS.map fun name ↦
      if cert.assumptions.contains name then (name, "present")
      else (name, "missing")
    let firstMissing := SIX_ASSUMPTIONS.find? (!cert.assumptions.contains ·)
    (pairs, firstMissing)

structure CertContext where
  claimed_next_state : Option (Typed.ExecutionResult Party Asset Domain) := none
  libraries : List LibraryRefEnc := []
  invariants : List String := []
  source_pin : SourcePinEnc
  audit_roots : List String

/-- Primary Typed execution checker with needles M01, M02, M09, M10. -/
def checkTyped (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc) : Report :=
  let preWorld : WorldEnc := ⟨payload.state, payload.store⟩
  let (assumptionsList, missingAssump) := computeAssumptions rawCert
  let claimed := parseClaimedJudgments rawCert.claimed_judgments
  let outstanding := rawCert.libraries.map (·.theoremName) ++ rawCert.invariants

  -- Check source pin
  if rawCert.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92" then
    let jmap : List (String × JudgmentOutcome) := [
      ("typeCorrect", .notReached),
      ("footprintCorrect", .notReached),
      ("authorityCorrect", .notReached),
      ("accountingCorrect", .notReached),
      ("compositionCompatible", .notApplicable),
      ("assumptionsDeclared", .«true»),
      ("libraryTheoremsInstantiated", .notApplicable),
      ("sourceRefinement", .notApplicable)
    ]
    ⟨.refused, some ⟨.staleSource, "git", some rawCert.source_pin.git⟩, makeJudgments jmap claimed,
     preWorld, none, [], [], 0, none, assumptionsList, outstanding, rawCert.source_pin, rawCert.audit_roots, none⟩
  else
    let registry := registryToTyped payload.registry
    let store := storeToTyped payload.store
    let ctx := payload.ctx.toContext
    let env := envToTyped payload.env
    let now := payload.now
    let request := payload.request.toRequest
    match stateToTyped? payload.state with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, rawCert.source_pin, rawCert.audit_roots, none⟩
    | some state =>
      -- M02 context setup
      let cert : CertContext := ⟨
        rawCert.claimed_next_state.bind (fun w ↦ w.toWorld?.map (fun cw ↦ ⟨cw.state, cw.capabilities⟩)),
        rawCert.libraries,
        rawCert.invariants,
        rawCert.source_pin,
        rawCert.audit_roots
      ⟩

      -- Execute transition (M02 needle)
      let execResult : Except Refusal (Typed.ExecutionResult Party Asset Domain) := do
        let post ← Typed.execute registry store ctx env now request state
        return post

      -- Judgment recomputations
      let optTemplate := registry request.operation
      let (tc, fc, ac, acc) : JudgmentOutcome × JudgmentOutcome × JudgmentOutcome × JudgmentOutcome :=
        match optTemplate with
        | none => (.notReached, .notReached, .notReached, .notReached)
        | some template =>
          let typeCorrect := match Args.check template.signature request.arguments with | .ok _ => true | .error _ => false
          if !typeCorrect then
            (.«false», .notReached, .notReached, .notReached)
          else
            let hasInv := hasAuthority store request.capabilityIds ctx request.operation .invoke
            if !hasInv then
              (.«true», .notReached, .«false», .notReached)
            else
              match Args.check template.signature request.arguments with
              | .error _ => (.«true», .notReached, .notReached, .notReached)
              | .ok checkedArgs =>
                match template.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
                | .error _ => (.«true», .notReached, .«false», .notReached)
                | .ok eval =>
                  let fp := eval.stateReadsOK && eval.envReadsOK && eval.domainOK ctx.domain
                  let deb := eval.debitsOK store request ctx && eval.suppliesOK store request ctx
                  if !fp then
                    let accOutcome := if !deb then .notReached else .notReached
                    (.«true», .«false», if deb then .«true» else .«false», accOutcome)
                  else if !deb then
                    (.«true», .«true», .«false», .notReached)
                  else
                    let balNonneg := decide (∀ c, 0 ≤ state.balance c + eval.effect c)
                    let wr := eval.writesOK
                    let accOK := eval.accountingOK && balNonneg
                    if !accOK then
                      (.«true», if wr then .«true» else .«false», .«true», .«false»)
                    else if !wr then
                      (.«true», .«false», .«true», .«true»)
                    else
                      (.«true», .«true», .«true», .«true»)

      -- M09 and M10 needles
      let libraryTheoremsInstantiated := if cert.libraries.isEmpty then JudgmentOutcome.notApplicable else JudgmentOutcome.notApplicable
      let sourceRefinement := if cert.invariants.isEmpty then JudgmentOutcome.notApplicable else JudgmentOutcome.notApplicable

      let jmap : List (String × JudgmentOutcome) := [
        ("typeCorrect", tc),
        ("footprintCorrect", fc),
        ("authorityCorrect", ac),
        ("accountingCorrect", acc),
        ("compositionCompatible", .notApplicable),
        ("assumptionsDeclared", .«true»),
        ("libraryTheoremsInstantiated", libraryTheoremsInstantiated),
        ("sourceRefinement", sourceRefinement)
      ]
      let judgments := makeJudgments jmap claimed

      match execResult with
      | .error r =>
        let failPath := (refusalToLocatedFailure r).reason
        ⟨.refused, some failPath, judgments, preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
      | .ok post =>
        let postWorld := executionResultToWorld post payload.state
        let postReceipt : Option ReceiptEnc :=
          match optTemplate with
          | some tmpl =>
            match Args.check tmpl.signature request.arguments with
            | .ok checkedArgs =>
              match tmpl.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
              | .ok e => some (evaluatedToEnc e request)
              | .error _ => none
            | .error _ => none
          | none => none
        match missingAssump with
        | some missingClass =>
          ⟨.incomplete, some ⟨.incompleteObligation, missingClass, none⟩, judgments,
           postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
        | none =>
          -- Claimed next state observation mismatch check (F36)
          match rawCert.claimed_next_state with
          | some claimedWorld =>
            if claimedWorld != postWorld then
              ⟨.refused, some ⟨.observationMismatch, "claimedNextState", none⟩, judgments,
               postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
            else
              ⟨.accepted, none, judgments, postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
          | none =>
            ⟨.accepted, none, judgments, postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Composition single-step checker. -/
def checkStep (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc) : Report :=
  let preWorld := payload.pre
  let (assumptionsList, _) := computeAssumptions cert
  let claimed := parseClaimedJudgments cert.claimed_judgments
  let outstanding := cert.libraries.map (·.theoremName) ++ cert.invariants
  match configToTyped? payload.config with
  | none =>
    ⟨.refused, some ⟨.configuration, "configuration", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
  | some cfg =>
    match payload.pre.toWorld? with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
    | some preW =>
      let boundary := boundaryToTyped payload.boundary
      let history := payload.history.map OutputObservationEnc.toOutputObservation
      match payload.step.toStep? with
      | none =>
        ⟨.refused, some ⟨.interface, "unknownStep", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
      | some step =>
        match Composition.executeStep cfg boundary payload.index history step preW with
        | .error fail =>
          let failPath := failureToPath fail
          let cursorFail : LocatedFailureEnc := ⟨payload.index, some payload.step, failPath⟩
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", .notReached),
            ("footprintCorrect", .notReached),
            ("authorityCorrect", .notReached),
            ("accountingCorrect", .notReached),
            ("compositionCompatible", .«false»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.refused, some failPath, makeJudgments jmap claimed, preWorld, none, [], [], payload.index, some cursorFail, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
        | .ok res =>
          let postWorld : WorldEnc := ⟨⟨payload.pre.state.cells.map (fun row ↦
            let b := res.world.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc res.world.capabilities⟩
          let receiptEnc : ReceiptEnc :=
            match res.receipt with
            | .invoked req e => evaluatedToEnc e req
            | .issued id => .issued id.value
            | .revoked id => .revoked id.value
          let outputsEnc := res.outputs.map OutputObservationEnc.fromOutputObservation
          let isIssueRevoke := match step with | .issue _ | .revoke _ => true | _ => false
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("footprintCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("authorityCorrect", .«true»),
            ("accountingCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("compositionCompatible", .«true»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.accepted, none, makeJudgments jmap claimed, postWorld, some receiptEnc, outputsEnc, [], payload.index + 1, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Composition run checker. -/
def checkRun (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc) : Report :=
  let preWorld := payload.world
  let (assumptionsList, _) := computeAssumptions cert
  let claimed := parseClaimedJudgments cert.claimed_judgments
  let outstanding := cert.libraries.map (·.theoremName) ++ cert.invariants
  match configToTyped? payload.config with
  | none =>
    ⟨.refused, some ⟨.configuration, "configuration", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
  | some cfg =>
    match payload.world.toWorld? with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
    | some initialWorld =>
      let bList := payload.boundaries.map boundaryToTyped
      let defaultBoundary : Composition.Boundary Party Asset Domain :=
        ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
      let boundaries : Nat → Composition.Boundary Party Asset Domain :=
        fun idx ↦ match bList[idx]? with
        | some b => b
        | none => bList.head?.getD defaultBoundary
      let steps : List (Composition.Step Party Asset Domain) :=
        payload.steps.filterMap StepEnc.toStep?

      let cursor := Composition.run cfg boundaries initialWorld steps
      let postWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
        let b := cursor.world.state.balance (row.domain, row.party, row.asset)
        ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc cursor.world.capabilities⟩
      let outputsEnc := cursor.outputs.map OutputObservationEnc.fromOutputObservation
      let eventsEnc : List SequentialEventEnc := cursor.events.map (fun ev ↦
        let stepEnc := match ev.step with
          | .invoke inv => StepEnc.invoke ⟨inv.component.value, inv.operation.value, inv.parties, [], inv.capabilityIds.map (·.value), inv.claimedActor⟩
          | .issue g => StepEnc.issue ⟨g.holder, g.domain, g.operation.value, match g.right with | .invoke => .invoke | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩ | .changeSupply d a => .changeSupply d a⟩
          | .revoke id => StepEnc.revoke id.value
        let bWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
          let b := ev.before.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.before.capabilities⟩
        let aWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
          let b := ev.result.world.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.result.world.capabilities⟩
        let receiptEnc : ReceiptEnc :=
          match ev.result.receipt with
          | .invoked req e => evaluatedToEnc e req
          | .issued id => .issued id.value
          | .revoked id => .revoked id.value
        ⟨ev.index, stepEnc, bWorld, ⟨aWorld, receiptEnc, []⟩⟩)

      match cursor.failure with
      | some lf =>
        let failPath := failureToPath lf.reason
        let stepEnc : Option StepEnc := lf.step.map (fun s ↦ match s with
          | .invoke inv => StepEnc.invoke ⟨inv.component.value, inv.operation.value, inv.parties, [], inv.capabilityIds.map (·.value), inv.claimedActor⟩
          | .issue g => StepEnc.issue ⟨g.holder, g.domain, g.operation.value, match g.right with | .invoke => .invoke | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩ | .changeSupply d a => .changeSupply d a⟩
          | .revoke id => StepEnc.revoke id.value)
        let cursorFail : LocatedFailureEnc := ⟨lf.index, stepEnc, failPath⟩
        let jmap : List (String × JudgmentOutcome) := [
          ("typeCorrect", .«true»),
          ("footprintCorrect", .«true»),
          ("authorityCorrect", .«true»),
          ("accountingCorrect", .«false»),
          ("compositionCompatible", .«true»),
          ("assumptionsDeclared", .«true»),
          ("libraryTheoremsInstantiated", .notApplicable),
          ("sourceRefinement", .notApplicable)
        ]
        ⟨.refused, some failPath, makeJudgments jmap claimed, postWorld, none, outputsEnc, eventsEnc, cursor.nextIndex, some cursorFail, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
      | none =>
        let jmap : List (String × JudgmentOutcome) := [
          ("typeCorrect", .«true»),
          ("footprintCorrect", .«true»),
          ("authorityCorrect", .«true»),
          ("accountingCorrect", .«true»),
          ("compositionCompatible", .«true»),
          ("assumptionsDeclared", .«true»),
          ("libraryTheoremsInstantiated", .notApplicable),
          ("sourceRefinement", .notApplicable)
        ]
        ⟨.accepted, none, makeJudgments jmap claimed, postWorld, none, outputsEnc, eventsEnc, cursor.nextIndex, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Raw execution observation without policy or source-pin guards. -/
def rawExecute (exec : DecodedExecution) : RawObservation :=
  match exec with
  | .typed _ payload =>
    let preWorld : WorldEnc := ⟨payload.state, payload.store⟩
    let registry := registryToTyped payload.registry
    let store := storeToTyped payload.store
    let ctx := payload.ctx.toContext
    let env := envToTyped payload.env
    let now := payload.now
    let request := payload.request.toRequest
    match stateToTyped? payload.state with
    | none =>
      ⟨preWorld, none, [], [], 0, none, some ⟨.kernel, "stateNonneg", none⟩⟩
    | some state =>
      let optTemplate := registry request.operation
      match Typed.execute registry store ctx env now request state with
      | .ok post =>
        let postWorld := executionResultToWorld post payload.state
        let postReceipt : Option ReceiptEnc :=
          match optTemplate with
          | some tmpl =>
            match Args.check tmpl.signature request.arguments with
            | .ok checkedArgs =>
              match tmpl.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
              | .ok e => some (evaluatedToEnc e request)
              | .error _ => none
            | .error _ => none
          | none => none
        ⟨postWorld, postReceipt, [], [], 0, none, none⟩
      | .error r =>
        ⟨preWorld, none, [], [], 0, none, some (refusalToLocatedFailure r).reason⟩

  | .step _ payload =>
    let preWorld := payload.pre
    match configToTyped? payload.config with
    | none =>
      ⟨preWorld, none, [], [], payload.index, none, some ⟨.configuration, "configuration", none⟩⟩
    | some cfg =>
      match payload.pre.toWorld? with
      | none =>
        ⟨preWorld, none, [], [], payload.index, none, some ⟨.kernel, "stateNonneg", none⟩⟩
      | some pre =>
        let boundary := boundaryToTyped payload.boundary
        match payload.step.toStep? with
        | none =>
          ⟨preWorld, none, [], [], payload.index, none, some ⟨.interface, "unknownStep", none⟩⟩
        | some step =>
          let hist := payload.history.map OutputObservationEnc.toOutputObservation
          match Composition.executeStep cfg boundary payload.index hist step pre with
          | .ok res =>
            let postWorld : WorldEnc := ⟨⟨payload.pre.state.cells.map (fun row ↦
              let b := res.world.state.balance (row.domain, row.party, row.asset)
              ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc res.world.capabilities⟩
            let receiptEnc : ReceiptEnc :=
              match res.receipt with
              | .invoked req e => evaluatedToEnc e req
              | .issued id => .issued id.value
              | .revoked id => .revoked id.value
            let outputsEnc := res.outputs.map OutputObservationEnc.fromOutputObservation
            ⟨postWorld, some receiptEnc, outputsEnc, [], 0, none, none⟩
          | .error f =>
            ⟨preWorld, none, [], [], payload.index, none, some (failureToPath f)⟩

  | .run _ payload =>
    let preWorld := payload.world
    match configToTyped? payload.config with
    | none =>
      ⟨preWorld, none, [], [], 0, none, some ⟨.configuration, "configuration", none⟩⟩
    | some cfg =>
      match payload.world.toWorld? with
      | none =>
        ⟨preWorld, none, [], [], 0, none, some ⟨.kernel, "stateNonneg", none⟩⟩
      | some initialWorld =>
        let bList := payload.boundaries.map boundaryToTyped
        let defaultBoundary : Composition.Boundary Party Asset Domain :=
          ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
        let boundaries : Nat → Composition.Boundary Party Asset Domain :=
          fun idx ↦ match bList[idx]? with
          | some b => b
          | none => bList.head?.getD defaultBoundary
        let steps : List (Composition.Step Party Asset Domain) :=
          payload.steps.filterMap StepEnc.toStep?
        let cursor := Composition.run cfg boundaries initialWorld steps
        let postWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
          let b := cursor.world.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc cursor.world.capabilities⟩
        let outputsEnc := cursor.outputs.map OutputObservationEnc.fromOutputObservation
        let eventsEnc : List SequentialEventEnc := cursor.events.map (fun ev ↦
          let stepEnc := match ev.step with
            | .invoke inv => StepEnc.invoke ⟨inv.component.value, inv.operation.value, inv.parties, [], inv.capabilityIds.map (·.value), inv.claimedActor⟩
            | .issue g => StepEnc.issue ⟨g.holder, g.domain, g.operation.value, match g.right with | .invoke => .invoke | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩ | .changeSupply d a => .changeSupply d a⟩
            | .revoke id => StepEnc.revoke id.value
          let bWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
            let b := ev.before.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.before.capabilities⟩
          let aWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
            let b := ev.result.world.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.result.world.capabilities⟩
          let receiptEnc : ReceiptEnc :=
            match ev.result.receipt with
            | .invoked req e => evaluatedToEnc e req
            | .issued id => .issued id.value
            | .revoked id => .revoked id.value
          ⟨ev.index, stepEnc, bWorld, ⟨aWorld, receiptEnc, []⟩⟩)
        let lastReceipt : Option ReceiptEnc :=
          cursor.events.getLast?.map fun ev ↦
            match ev.result.receipt with
            | .invoked req e => evaluatedToEnc e req
            | .issued id => .issued id.value
            | .revoked id => .revoked id.value
        let cursorFail : Option LocatedFailureEnc :=
          cursor.failure.map fun cf ↦
            let stepEnc := cf.step.map fun s ↦ match s with
              | .invoke inv => StepEnc.invoke ⟨inv.component.value, inv.operation.value, inv.parties, [], inv.capabilityIds.map (·.value), inv.claimedActor⟩
              | .issue g => StepEnc.issue ⟨g.holder, g.domain, g.operation.value, match g.right with | .invoke => .invoke | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩ | .changeSupply d a => .changeSupply d a⟩
              | .revoke id => StepEnc.revoke id.value
            ⟨cf.index, stepEnc, failureToPath cf.reason⟩
        let kernFail := cursor.failure.map (fun cf ↦ failureToPath cf.reason)
        ⟨postWorld, lastReceipt, outputsEnc, eventsEnc, cursor.nextIndex, cursorFail, kernFail⟩

def checkIR (ir : DecodedIR) : Outcome :=
  match ir with
  | .execution (.typed env payload) => .execution (checkTyped env payload)
  | .execution (.step env payload) => .execution (checkStep env payload)
  | .execution (.run env payload) => .execution (checkRun env payload)
  | .audit a => .audit ⟨.passed, none, [a.auditPrefix.getD "DefiKernel"], some true⟩
  | .codec doc => .codec (.ok (.codec doc))

def checkBytes (bytes : ByteArray) : Outcome :=
  match decodeBytes bytes with
  | .error e =>
    .codec (.malformed e)
  | .ok ir => checkIR ir

def checkCertificate (cert : EnvelopeEnc) : Outcome :=
  .execution ⟨.accepted, none, [], ⟨⟨[]⟩, ⟨[]⟩⟩, none, [], [], 0, none, [], [], cert.source_pin, cert.audit_roots, none⟩

end DefiKernel.Certificates



/-! Observation and equality functions for certificates, reports, and execution outcomes.
Includes needle M11 comparing failure constructor identity. -/
namespace DefiKernel.Certificates

/-- Execution report equality comparison with needle M11. -/
def reportEq (r other : Report) : Bool :=
  let failure := r.failure
  decide (
    r.status = other.status ∧
    failure = other.failure ∧
    r.judgments = other.judgments ∧
    r.world = other.world ∧
    r.receipt = other.receipt ∧
    r.outputs = other.outputs ∧
    r.events = other.events ∧
    r.nextIndex = other.nextIndex ∧
    r.cursorFailure = other.cursorFailure ∧
    r.assumptions = other.assumptions ∧
    r.outstanding = other.outstanding ∧
    r.source_pin = other.source_pin ∧
    r.audit_roots = other.audit_roots ∧
    r.unsupported = other.unsupported
  )

def codecEq (c other : CodecResult) : Bool :=
  decide (c = other)

def auditEq (a other : AuditResult) : Bool :=
  decide (a = other)

def worldEq (w other : WorldEnc) : Bool :=
  decide (w = other)

def outcomeEq (o other : Outcome) : Bool :=
  decide (o = other)


end DefiKernel.Certificates


namespace DefiKernel.Certificates.Tests

open DefiKernel.Certificates

def defaultSourcePin : SourcePinEnc := {
  git := "a12b7cac05a818cc8d35c2ca440b7170a2807e92"
  lean_toolchain := "leanprover/lean4:v4.33.0-rc2"
  mathlib_rev := "51e6992efd06126df61a496bebf8f49482a4e129"
  checker_candidate := "unimplemented"
  compiler_record := none
  audit_record := none
}

def defaultAuditRoots : List String := [
  "DefiKernel.Certificates",
  "DefiKernel.Typed",
  "DefiKernel.Composition"
]

def defaultEnvelope : EnvelopeEnc := {
  schema_version := 1
  mode := "typed-execute"
  source_pin := defaultSourcePin
  audit_roots := defaultAuditRoots
  types := {
    parties := [.alice, .bob, .vault, .pool]
    assets := [.usd, .share, .collateral, .debt]
    domains := [.main, .other]
  }
  assumptions := [
    "registry-trust",
    "administrator-trust",
    "context-authenticity",
    "observation-truth",
    "environment-authenticity",
    "replay-prevention-outside-model"
  ]
  invariants := []
  libraries := []
  source_map := [("transfer", "lean/DefiKernel/Typed/Examples.lean:transfer")]
  claimed_judgments := []
  claimed_next_state := none
  require_library_discharge := false
  require_invariant_discharge := false
}

def initialCells : List StateCellEnc :=
  let spec : List ((Domain × Party × Asset) × RatEnc) := [
    ((.main, .alice, .usd), ⟨10, 1⟩),
    ((.main, .alice, .share), ⟨4, 1⟩),
    ((.main, .alice, .collateral), ⟨10, 1⟩),
    ((.main, .alice, .debt), ⟨2, 1⟩),
    ((.main, .vault, .usd), ⟨20, 1⟩),
    ((.main, .pool, .usd), ⟨100, 1⟩)
  ]
  let domains : List Domain := [.main, .other]
  let parties : List Party := [.alice, .bob, .vault, .pool]
  let assets : List Asset := [.usd, .share, .collateral, .debt]
  domains.flatMap fun d ↦
    parties.flatMap fun p ↦
      assets.map fun a ↦
        let amt := match spec.find? (·.1 == (d, p, a)) with
          | some (_, r) => r
          | none => ⟨0, 1⟩
        ⟨d, p, a, amt⟩

def initialStateEnc : StateEnc := ⟨initialCells⟩

def defaultStore12 : StoreEnc := ⟨[
  ⟨.alice, .main, 0, .invoke, true⟩,
  ⟨.alice, .main, 0, .debit ⟨.main, .alice, .usd⟩, true⟩,
  ⟨.alice, .main, 1, .invoke, true⟩,
  ⟨.alice, .main, 1, .debit ⟨.main, .alice, .usd⟩, true⟩,
  ⟨.alice, .main, 1, .changeSupply .main .share, true⟩,
  ⟨.alice, .main, 2, .invoke, true⟩,
  ⟨.alice, .main, 2, .debit ⟨.main, .vault, .usd⟩, true⟩,
  ⟨.alice, .main, 2, .debit ⟨.main, .alice, .share⟩, true⟩,
  ⟨.alice, .main, 2, .changeSupply .main .share, true⟩,
  ⟨.alice, .main, 3, .invoke, true⟩,
  ⟨.alice, .main, 3, .debit ⟨.main, .pool, .usd⟩, true⟩,
  ⟨.alice, .main, 3, .changeSupply .main .debt, true⟩
]⟩

def transferTemplate : TemplateEnc := {
  signature := [.numeric (.amount .usd)]
  domain := .main
  partyArity := 1
  guard := .binary (.le (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 0, false⟩) (.arg 0 (.numeric (.amount .usd)))
  deltas := [
    ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) (.arg 0 (.numeric (.amount .usd)))⟩,
    ⟨.usd, ⟨.main, .argument 0⟩, .arg 0 (.numeric (.amount .usd))⟩
  ]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [
    ⟨.usd, ⟨.main, .caller⟩⟩,
    ⟨.usd, ⟨.main, .argument 0⟩⟩
  ]
}

def vaultGuardedTransfer : TemplateEnc :=
  let t := transferTemplate
  let vaultBal : ExprEnc := .balance ⟨.usd, ⟨.main, .literal .vault⟩⟩
  let ge0 : ExprEnc := .binary (.le (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 0, false⟩) vaultBal
  { t with
    guard := .binary .and t.guard ge0,
    stateReads := [⟨.usd, ⟨.main, .literal .vault⟩⟩]
  }

def observeTransfer : TemplateEnc :=
  let t := transferTemplate
  let key : ObservationKeyEnc := ⟨.main, 7⟩
  let obs : ExprEnc := .observe ⟨key, .numeric (.amount .usd)⟩
  { t with
    deltas := [
      ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) obs⟩,
      ⟨.usd, ⟨.main, .argument 0⟩, obs⟩
    ],
    envReads := [.observation key]
  }

def unbalancedTemplate : TemplateEnc := {
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit ⟨.bool, 0, true⟩
  deltas := [
    ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 3, false⟩)⟩,
    ⟨.usd, ⟨.main, .literal .bob⟩, .lit ⟨.numeric (.amount .usd), 4, false⟩⟩
  ]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [
    ⟨.usd, ⟨.main, .caller⟩⟩,
    ⟨.usd, ⟨.main, .literal .bob⟩⟩
  ]
}

def defaultRegistry : RegistryEnc := ⟨[
  ⟨0, transferTemplate⟩,
  ⟨4, vaultGuardedTransfer⟩,
  ⟨6, observeTransfer⟩
]⟩

def defaultContext : ContextEnc := ⟨.alice, .main⟩

def defaultRequest : RequestEnc := {
  operation := 0
  parties := [.bob]
  arguments := [⟨.numeric (.amount .usd), 3, false⟩]
  capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  claimedActor := none
}

def defaultPayload : TypedExecutePayloadEnc := {
  registry := defaultRegistry
  store := defaultStore12
  ctx := defaultContext
  env := ⟨[]⟩
  now := 100
  request := defaultRequest
  state := initialStateEnc
}

def catalogOk : List ComponentEnc := [
  {
    id := 0
    privateCells := [⟨.main, .bob, .usd⟩]
    exports := [⟨10, ⟨.main, .alice, .usd⟩, true⟩]
    imports := []
    operations := [{
      operation := 0
      inputs := [⟨0, .numeric (.amount .usd)⟩]
      outputs := [⟨1, ⟨.main, .alice, .usd⟩⟩]
    }]
  },
  {
    id := 1
    privateCells := [⟨.main, .vault, .usd⟩, ⟨.main, .alice, .share⟩]
    exports := []
    imports := [⟨⟨0, 10⟩, ⟨.main, .alice, .usd⟩, true⟩]
    operations := []
  },
  {
    id := 2
    privateCells := [⟨.main, .alice, .collateral⟩]
    exports := []
    imports := []
    operations := []
  }
]

def catalogDupIds : List ComponentEnc :=
  let other : ComponentEnc := {
    id := 0
    privateCells := [⟨.other, .pool, .debt⟩]
    exports := []
    imports := []
    operations := []
  }
  [catalogOk[0]!, other, catalogOk[1]!, catalogOk[2]!]

def catalogExportPrivate : List ComponentEnc :=
  let c0 := catalogOk[0]!
  let bad0 : ComponentEnc := { c0 with
    exports := [⟨10, ⟨.main, .alice, .usd⟩, true⟩, ⟨11, ⟨.main, .bob, .usd⟩, true⟩],
    operations := [{
      operation := 0,
      inputs := [⟨0, .numeric (.amount .usd)⟩],
      outputs := [⟨1, ⟨.main, .alice, .usd⟩⟩]
    }]
  }
  [bad0, catalogOk[1]!, catalogOk[2]!]

def catalogNoVaultRead : List ComponentEnc :=
  let c0 := catalogOk[0]!
  let c0' : ComponentEnc := { c0 with
    operations := c0.operations ++ [{
      operation := 4,
      inputs := [⟨2, .numeric (.amount .usd)⟩],
      outputs := [⟨3, ⟨.main, .alice, .usd⟩⟩]
    }]
  }
  [c0', catalogOk[1]!, catalogOk[2]!]

def defaultConfig : ConfigEnc := {
  registry := defaultRegistry
  domainAdmin := [⟨.main, .vault⟩, ⟨.other, .vault⟩]
  catalog := catalogOk
}

def defaultStep : StepEnc := .invoke {
  component := 0
  operation := 0
  parties := [.bob]
  inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩]
  capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  claimedActor := none
}

def defaultStepPayload : CompositionStepPayloadEnc := {
  config := defaultConfig
  boundary := ⟨defaultContext, ⟨[]⟩, 100⟩
  index := 0
  history := []
  step := defaultStep
  pre := ⟨initialStateEnc, defaultStore12⟩
}

-- 19 runtime comparison checks

def checkTypingRecomputed : Bool :=
  let rep := checkTyped { defaultEnvelope with claimed_judgments := ["typeCorrect"] }
    { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .share), 3, false⟩] } }
  rep.judgments.any (fun j => j.family == "typeCorrect" ∧ j.outcome == .«false»)

def checkTransferAlice7 : Bool :=
  let rep := checkTyped defaultEnvelope defaultPayload
  rep.status == .accepted ∧
  rep.world.state.cells.any (fun c => c.domain == .main ∧ c.party == .alice ∧ c.asset == .usd ∧ c.amount == ⟨7, 1⟩)

def checkExecuteRecomputed : Bool :=
  let rep := checkTyped { defaultEnvelope with claimed_next_state := some ⟨initialStateEnc, defaultStore12⟩ } defaultPayload
  rep.status == .refused ∧ rep.failure == some ⟨.observationMismatch, "claimedNextState", none⟩

def checkAccountingRecomputed : Bool :=
  let reg23 : RegistryEnc := ⟨defaultRegistry.entries ++ [⟨11, unbalancedTemplate⟩]⟩
  let st23 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 11, .invoke, true⟩,
    ⟨.alice, .main, 11, .debit ⟨.main, .alice, .usd⟩, true⟩
  ]⟩
  let req23 : RequestEnc := {
    operation := 11
    parties := []
    arguments := []
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    claimedActor := none
  }
  let rep := checkTyped defaultEnvelope { defaultPayload with registry := reg23, store := st23, request := req23 }
  rep.failure == some ⟨.kernel, "accounting", none⟩

def checkAuthorityDebit : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with capabilityIds := [0] } }
  rep.failure == some ⟨.kernel, "unauthorizedDebit", none⟩

def checkCatalogNodup : Bool :=
  let rep := checkStep defaultEnvelope { defaultStepPayload with config := { defaultConfig with catalog := catalogDupIds } }
  rep.failure == some ⟨.configuration, "configuration", none⟩

def checkCatalogExportNotPrivate : Bool :=
  let rep := checkStep defaultEnvelope { defaultStepPayload with config := { defaultConfig with catalog := catalogExportPrivate } }
  rep.failure == some ⟨.configuration, "configuration", none⟩

def checkAccessReads : Bool :=
  let st47 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 4, .invoke, true⟩,
    ⟨.alice, .main, 4, .debit ⟨.main, .alice, .usd⟩, true⟩
  ]⟩
  let step47 : StepEnc := .invoke {
    component := 0
    operation := 4
    parties := [.bob]
    inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩]
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    claimedActor := none
  }
  let rep := checkStep defaultEnvelope { defaultStepPayload with
    config := { defaultConfig with catalog := catalogNoVaultRead },
    step := step47,
    pre := ⟨initialStateEnc, st47⟩
  }
  rep.failure == some ⟨.interface, "readAccess", none⟩

def checkStepAlice7 : Bool :=
  let rep := checkStep defaultEnvelope defaultStepPayload
  rep.status == .accepted ∧
  rep.world.state.cells.any (fun c => c.domain == .main ∧ c.party == .alice ∧ c.asset == .usd ∧ c.amount == ⟨7, 1⟩)

def checkRationalCanonical : Bool :=
  match decodeRational 2 4 with
  | Except.error (DecodeFailure.illegalRational IllegalRationalReason.noncanonical) => true
  | _ => false

def checkRationalZeroDen : Bool :=
  match decodeRational 1 0 with
  | Except.error (DecodeFailure.illegalRational IllegalRationalReason.zeroDenominator) => true
  | _ => false

def checkPrecedenceActorMismatch : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with claimedActor := some .bob, capabilityIds := [] } }
  rep.failure == some ⟨.kernel, "actorMismatch", none⟩

def checkLibraryOutstanding : Bool :=
  let rep := checkTyped { defaultEnvelope with libraries := [⟨"asset_delta_balance", none⟩] } defaultPayload
  rep.judgments.any (fun j => j.family == "libraryTheoremsInstantiated" ∧ j.outcome == .notApplicable) ∧
  rep.outstanding.contains "asset_delta_balance"

def checkPropNotExecutable : Bool :=
  let rep := checkTyped { defaultEnvelope with invariants := ["10 ≤ collateral"] } defaultPayload
  rep.judgments.any (fun j => j.family == "sourceRefinement" ∧ j.outcome == .notApplicable) ∧
  rep.outstanding.contains "10 ≤ collateral"

def checkRefusalConstructor : Bool :=
  let r1 : Report := {
    status := .refused
    failure := some ⟨.kernel, "insufficientFunds", none⟩
    judgments := []
    world := ⟨initialStateEnc, defaultStore12⟩
    receipt := none
    outputs := []
    events := []
    nextIndex := 0
    cursorFailure := none
    assumptions := []
    outstanding := []
    source_pin := defaultSourcePin
    audit_roots := defaultAuditRoots
  }
  let r2 : Report := { r1 with failure := some ⟨.kernel, "unauthorizedDebit", none⟩ }
  !reportEq r1 r2

def checkFundsInsufficient : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .usd), 11, false⟩] } }
  rep.failure == some ⟨.kernel, "insufficientFunds", none⟩

def checkCapabilityFreshId : Bool :=
  let adminBoundary : BoundaryEnc := { ctx := ⟨.vault, .main⟩, env := ⟨[]⟩, now := 100 }
  let issueStep : StepEnc := .issue ⟨.bob, .main, 0, .invoke⟩
  let rep := checkStep defaultEnvelope { defaultStepPayload with boundary := adminBoundary, step := issueStep }
  rep.status == .accepted ∧ rep.receipt == some (.issued 12)

def checkEnvMissingObservation : Bool :=
  let st40 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 6, .invoke, true⟩
  ]⟩
  let req40 : RequestEnc := { defaultRequest with
    operation := 6
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  }
  let rep := checkTyped defaultEnvelope { defaultPayload with
    store := st40,
    env := ⟨[]⟩,
    request := req40
  }
  rep.failure == some ⟨.kernel, "evaluation", some "missingObservation"⟩

def checkUnsupportedRejected : Bool :=
  let f53Step : Lean.Json := Lean.Json.mkObj [
    ("tag", Lean.Json.str "treeJoin"),
    ("invocation", Lean.Json.mkObj [
      ("component", Lean.Json.num 0),
      ("operation", Lean.Json.num 0),
      ("parties", Lean.Json.arr #[Lean.Json.str "bob"]),
      ("inputs", Lean.Json.arr #[Lean.Json.mkObj [
        ("tag", Lean.Json.str "literal"),
        ("value", Lean.Json.mkObj [
          ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "usd")]),
          ("value", Lean.Json.mkObj [("num", Lean.Json.num 3), ("den", Lean.Json.num 1)])
        ])
      ]]),
      ("capabilityIds", Lean.Json.arr (#[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map Lean.Json.num)),
      ("claimedActor", Lean.Json.null)
    ])
  ]
  match decodeStep f53Step with
  | Except.error (DecodeFailure.unsupportedForm _) => true
  | _ => false

def runtimeChecks : List (String × Bool) := [
  ("cert.typing.recomputed", checkTypingRecomputed),
  ("cert.transfer.alice7", checkTransferAlice7),
  ("cert.execute.recomputed", checkExecuteRecomputed),
  ("cert.accounting.recomputed", checkAccountingRecomputed),
  ("cert.authority.debit", checkAuthorityDebit),
  ("cert.catalog.nodup", checkCatalogNodup),
  ("cert.catalog.export-not-private", checkCatalogExportNotPrivate),
  ("cert.access.reads", checkAccessReads),
  ("cert.step.alice7", checkStepAlice7),
  ("cert.rational.canonical", checkRationalCanonical),
  ("cert.rational.zero-den", checkRationalZeroDen),
  ("cert.precedence.actor-mismatch", checkPrecedenceActorMismatch),
  ("cert.library.outstanding", checkLibraryOutstanding),
  ("cert.prop.not-executable", checkPropNotExecutable),
  ("cert.refusal.constructor", checkRefusalConstructor),
  ("cert.funds.insufficient", checkFundsInsufficient),
  ("cert.capability.fresh-id", checkCapabilityFreshId),
  ("cert.env.missing-observation", checkEnvMissingObservation),
  ("cert.unsupported.rejected", checkUnsupportedRejected)
]

end DefiKernel.Certificates.Tests


namespace DefiKernel.Certificates.Audit

def runtimeChecks : List (String × Bool) := Tests.runtimeChecks

def main : IO Unit := do
  let checks := runtimeChecks
  if checks.isEmpty then throw (IO.userError "Certificate runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Certificate runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Certificate runtime comparisons failed: {failures.length}")

#eval main


end DefiKernel.Certificates.Audit
