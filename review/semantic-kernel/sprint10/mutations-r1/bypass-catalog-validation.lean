import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Tactic.Linarith


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

-- BEGIN PROOFS

theorem numericRat_numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) :
    numericRat u (numericValue u q) = q := by cases u <;> rfl

theorem numericValue_numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) :
    numericValue u (numericRat u v) = v := by cases u <;> rfl

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

-- BEGIN PROOFS

/-- Equality on all recorded reads and typed arguments preserves the entire evaluation result,
including missing-input, wrong-unit and zero-division refusal behavior. -/
theorem Expr.eval_congr {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args)
    (hs : ∀ ref ∈ expression.stateReads, readBalance left ref = readBalance right ref)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  induction expression with
  | lit value => rfl
  | arg v => simp only [Expr.eval, ha]
  | balance ref => exact hs ⟨_, ref⟩ (by simp [Expr.stateReads])
  | observe ref =>
    have h := he (.observation ref.key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, readObservation, h]
  | timestamp key =>
    have h := he (.observation key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | now =>
    have h := he .currentTime (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | unary op x ih =>
    have hx := ih hs he
    simp only [Expr.eval, hx]
  | binary op x y ihx ihy =>
    have hx := ihx
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hx, hy]
  | ite condition yes no ihc ihy ihn =>
    have hc := ihc
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hn := ihn
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hc, hy, hn]

/-- Equal caller/party inputs and equal balances at successfully resolved references suffice
for state-read agreement. Invalid party indices produce the same refusal on both sides. -/
theorem readBalance_congr {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain)
    (hc : left.caller = right.caller) (hp : left.parties = right.parties)
    (hs : ∀ c, ref.2.resolve left.caller left.parties = .ok c →
      left.state.balance c = right.state.balance c) :
    readBalance left ref = readBalance right ref := by
  simp only [readBalance, ← hc, ← hp]
  cases h : ref.2.resolve left.caller left.parties with
  | error reason => rfl
  | ok c => simp [hs c h]

/-- A concrete ledger formulation of read dependence. Only successfully resolved cells need
equal balances; the same caller and party arguments also preserve resolution failures. -/
theorem Expr.eval_congr_of_resolved {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args) (hc : left.caller = right.caller)
    (hp : left.parties = right.parties)
    (hs : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve left.caller left.parties = .ok c →
        left.state.balance c = right.state.balance c)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  apply expression.eval_congr left right ha _ he
  intro ref href
  exact readBalance_congr left right ref hc hp (hs ref href)

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

-- BEGIN PROOFS

omit [DecidableEq Asset] in
theorem issueCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain) :
    issueCapability config ctx store grant = .ok (id, post) ↔
      isDomainAdmin config ctx grant.domain = true ∧
      config.operationDomain grant.operation = some grant.domain ∧
      grant.right.inDomain grant.domain = true ∧
      id = store.nextId ∧ post = ⟨store.entries ++ [⟨grant, true⟩]⟩ := by
  unfold issueCapability
  split <;> simp_all
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem issueCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    ctx.domain = grant.domain ∧ ctx.principal = config.domainAdmin grant.domain := by
  simpa [isDomainAdmin] using (issueCapability_ok_iff ..).mp h |>.1

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem lookup_nextId (store : CapabilityStore Party Asset Domain) :
    store.lookup store.nextId = none := by simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_fresh (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    store.lookup id = none ∧ post.lookup id = some ⟨grant, true⟩ ∧
      post.nextId.value = store.nextId.value + 1 := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id other : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  have hn : other.value ≠ store.entries.length := by
    intro he
    apply hne
    cases other
    simp_all [CapabilityStore.nextId]
  simp only [CapabilityStore.lookup, List.getElem?_append]
  split
  · rfl
  · rename_i hge
    have ht : store.entries.length < other.value := by omega
    have hz : other.value - store.entries.length ≠ 0 := by omega
    simp [List.getElem?_eq_none (by omega : store.entries.length ≤ other.value), hz]

omit [DecidableEq Asset] in
theorem issueCapability_ne_existing (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) : id ≠ old := by
  intro he
  have hf := (issueCapability_fresh config ctx store grant id post h).1
  rw [he, hold] at hf
  contradiction

omit [DecidableEq Asset] in
theorem revokeCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain) :
    revokeCapability config ctx store id = .ok post ↔
      ∃ cap, store.lookup id = some cap ∧ isDomainAdmin config ctx cap.domain = true ∧
        post = ⟨store.entries.set id.value { cap with live := false }⟩ := by
  unfold revokeCapability
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem revokeCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧ ctx.domain = cap.domain ∧
      ctx.principal = config.domainAdmin cap.domain := by
  obtain ⟨cap, hc, ha, _⟩ := (revokeCapability_ok_iff ..).mp h
  exact ⟨cap, hc, by simpa [isDomainAdmin] using ha⟩

omit [DecidableEq Asset] in
theorem revokeCapability_tombstone (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧
      post.lookup id = some { cap with live := false } ∧ post.nextId = store.nextId := by
  obtain ⟨cap, hc, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hi : id.value < store.entries.length := by
    by_contra hn
    have hn' : store.entries.length ≤ id.value := by omega
    simp [CapabilityStore.lookup, List.getElem?_eq_none hn'] at hc
  exact ⟨cap, hc, by simp [CapabilityStore.lookup, hi], by simp [CapabilityStore.nextId]⟩

omit [DecidableEq Asset] in
theorem revokeCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id other : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨cap, _, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hn : id.value ≠ other.value := by
    intro he
    apply hne
    cases id
    cases other
    simp_all
  simp [CapabilityStore.lookup, List.getElem?_set_ne hn]

theorem authorizesId_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) :
    authorizesId store ctx operation right id = true ↔
      ∃ cap, store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
        cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
        right.inDomain ctx.domain = true := by
  unfold authorizesId
  split <;> simp_all

theorem hasAuthority_iff (store : CapabilityStore Party Asset Domain) (ids : List CapabilityId)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) :
    hasAuthority store ids ctx operation right = true ↔
      ∃ id ∈ ids, authorizesId store ctx operation right id = true := by
  simp [hasAuthority]

theorem hasAuthority_duplicate (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (id : CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) :
    hasAuthority store (id :: id :: ids) ctx operation right =
      hasAuthority store (id :: ids) ctx operation right := by
  simp [hasAuthority]

theorem revokeCapability_cannot_use (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : revokeCapability config adminCtx store id = .ok post) :
    authorizesId post ctx operation right id = false := by
  obtain ⟨cap, _, hc, _⟩ := revokeCapability_tombstone config adminCtx store id post h
  simp [authorizesId, hc]

/-- Reissuing authority leaves every existing revoked ID unusable. -/
theorem issueCapability_keeps_revoked (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : issueCapability config adminCtx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) (hdead : cap.live = false) :
    authorizesId post ctx operation right old = false := by
  have hne := issueCapability_ne_existing config adminCtx store grant id old post cap h hold
  have hp := issueCapability_preserves_other config adminCtx store grant id old post h hne.symm
  simp [authorizesId, hp, hold, hdead]

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

-- BEGIN PROOFS

theorem applyEvaluated_ok_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain) :
    applyEvaluated store ctx request state e = .ok post ↔
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  rcases post with ⟨⟨balance, nonneg⟩, capabilities⟩
  unfold applyEvaluated
  split_ifs <;> simp_all [Evaluated.Valid, funext_iff]
  aesop

/-- Success binds the selected template, typed arguments and actual evaluation result to all
checks and the exact post-state. No caller-supplied validity certificate occurs here. -/
theorem execute_ok_iff (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (post : ExecutionResult Party Asset Domain) :
    execute registry store ctx env now request state = .ok post ↔
      ∃ template, registry request.operation = some template ∧
      (request.claimedActor = none ∨ request.claimedActor = some ctx.principal) ∧
      ctx.domain = template.domain ∧ request.parties.length = template.partyArity ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      hasAuthority store request.capabilityIds ctx request.operation .invoke = true ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  unfold execute
  cases hr : registry request.operation with
  | none => simp [bind, Except.bind]
  | some template =>
    simp only [bind, Except.bind, Option.some.injEq, exists_eq_left']
    cases hc : request.claimedActor <;>
      simp only [Option.isSome, Bool.false_and, Bool.true_and] <;>
      split_ifs <;> simp_all [throw, throwThe]
    all_goals
      cases ha : Args.check template.signature request.arguments <;>
        simp_all [Except.mapError]
    all_goals
      rename_i args
      cases he : template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ <;>
        simp_all [applyEvaluated_ok_iff]

theorem applyEvaluated_accounting (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset) :
    total post.state d a = total state d a + e.supply d a := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have ha : ∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.1
  simp only [total, hu, Finset.sum_add_distrib, ha]

theorem applyEvaluated_locality (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : c ∉ e.writes) :
    post.state.balance c = state.balance c := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hw : ∀ c, c ∉ e.writes → e.effect c = 0 :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.2
  simp [hu, hw c hc]

theorem applyEvaluated_debit_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hd : ∀ c, e.effect c < 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true :=
    of_decide_eq_true hv.2.2.2.2.1
  apply hd c
  rw [hu] at hc
  linarith

theorem applyEvaluated_supply_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true := by
  obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp h
  have hs : ∀ d a, e.supply d a ≠ 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true :=
    of_decide_eq_true hv.2.2.2.2.2.1
  apply hs d a
  intro hz
  exact hc (by simpa [hz] using applyEvaluated_accounting store ctx request state e post h d a)

/-- Every successful execution has a selected registered template and a checked evaluation
whose concrete application produced the post-state. -/
theorem execute_evaluated
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        applyEvaluated store ctx request state e = .ok post := by
  obtain ⟨t, ht, _, _, _, args, ha, _, e, he, hv, hcap, hu⟩ := (execute_ok_iff ..).mp h
  exact ⟨t, ht, args, ha, e, he, (applyEvaluated_ok_iff ..).mpr ⟨hv, hcap, hu⟩⟩

theorem execute_preserves_capabilities
    (h : execute registry store ctx env now request state = .ok post) :
    post.capabilities = store := by
  obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hcap, _⟩ := (execute_ok_iff ..).mp h
  exact hcap

theorem execute_nonnegative
    (h : execute registry store ctx env now request state = .ok post) :
    ∀ c, 0 ≤ post.state.balance c := by
  obtain ⟨_, _, _, _, _, _, _, _, e, _, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  intro c
  rw [hu]
  exact hv.2.2.2.2.2.2.1 c

theorem execute_invocation_authority
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke := by
  obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp h
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_debit_authority
    (h : execute registry store ctx env now request state = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .debit c := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_debit_authority store ctx request state e post he c hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_supply_authority
    (h : execute registry store ctx env now request state = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧
      cap.right = .changeSupply d a := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_supply_authority store ctx request state e post he d a hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_accounting_and_locality
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ d a, total post.state d a = total state d a + e.supply d a) ∧
        (∀ c, c ∉ e.writes → post.state.balance c = state.balance c) := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request state post h
  exact ⟨t, ht, args, ha, e, he,
    applyEvaluated_accounting store ctx request state e post happly,
    applyEvaluated_locality store ctx request state e post happly⟩

/-- Successfully recorded reads are declared and domain-local, and all changed balances stay
in the authenticated invocation domain. -/
theorem execute_reads_and_domain
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ctx.domain = template.domain ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads ∧ c.1 = ctx.domain) ∧
        (∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads) ∧
        (∀ c, post.state.balance c ≠ state.balance c → c.1 = ctx.domain) := by
  obtain ⟨t, ht, _, hd, _, args, ha, _, e, he, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  have hs : ∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads := by
    simpa [Evaluated.stateReadsOK] using hv.2.1
  have hen : ∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads := by
    simpa [Evaluated.envReadsOK] using hv.2.2.1
  have hdom : (∀ c ∈ e.requiredStateReads, c.1 = ctx.domain) ∧
      (∀ c, e.effect c ≠ 0 → c.1 = ctx.domain) ∧
      ∀ d a, e.supply d a ≠ 0 → d = ctx.domain := of_decide_eq_true hv.2.2.2.1
  refine ⟨t, ht, hd, args, ha, e, he, ?_, hen, ?_⟩
  · exact fun c hc ↦ ⟨hs c hc, hdom.1 c hc⟩
  · intro c hc
    apply hdom.2.1 c
    intro hz
    exact hc (by simp [hu, hz])

omit [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.effect_cons (e : Evaluated Party Asset Domain)
    (entry : Cell Party Asset Domain × ℚ) (c : Cell Party Asset Domain) :
    ({ e with deltas := entry :: e.deltas } : Evaluated Party Asset Domain).effect c =
      (if entry.1 = c then entry.2 else 0) + e.effect c := by
  simp [Evaluated.effect]

omit [DecidableEq Party] [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.supply_cons (e : Evaluated Party Asset Domain)
    (entry : (Domain × Asset) × ℚ) (d : Domain) (a : Asset) :
    ({ e with supplies := entry :: e.supplies } : Evaluated Party Asset Domain).supply d a =
      (if entry.1 = (d, a) then entry.2 else 0) + e.supply d a := by
  simp [Evaluated.supply]

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

-- BEGIN PROOFS

/-- Successful prechecks resolve the complete conservative reference inventories and
accept every concrete read and write; no financial expression evaluation is assumed. -/
theorem checkAccess_ok_iff (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) :
    checkAccess component template ctx parties = .ok PUnit.unit ↔
      ∃ reads writes,
        resolveRefs ctx.principal parties
          (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
        resolveRefs ctx.principal parties
          (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
        reads.all component.canRead = true ∧ writes.all component.canWrite = true := by
  unfold checkAccess
  cases hr : resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads) with
  | error e => simp [Except.mapError, bind, Except.bind]
  | ok reads =>
    cases hw : resolveRefs ctx.principal parties
      (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) with
    | error e => simp [Except.mapError, bind, Except.bind]
    | ok writes =>
      simp only [Except.mapError, bind, Except.bind]
      by_cases r : reads.all component.canRead = true <;>
        by_cases w : writes.all component.canWrite = true <;>
        simp [r, w, -List.all_eq_true, throw, throwThe, pure, Except.pure]


/-- In particular every resolved declared write accepted by the precheck is writable. -/
theorem checkAccess_declaredWrites (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) (writes : List (Cell Party Asset Domain))
    (accepted : checkAccess component template ctx parties = .ok PUnit.unit)
    (resolved : resolveRefs ctx.principal parties template.writes = .ok writes) :
    writes.all component.canWrite = true := by
  obtain ⟨reads, allWrites, _, hw, _, allowed⟩ :=
    (checkAccess_ok_iff component template ctx parties).mp accepted
  simp only [resolveRefs, List.mapM_append] at hw
  change (template.writes.mapM (fun ref ↦ ref.2.resolve ctx.principal parties)) =
    .ok writes at resolved
  rw [resolved] at hw
  cases ht : (template.deltas.map
      (fun d ↦ (⟨d.asset, d.target⟩ : PackedCellRef Party Asset Domain))).mapM
      (fun ref ↦ ref.2.resolve ctx.principal parties) with
  | error e => simp [ht, bind, Except.bind] at hw
  | ok targets =>
    simp only [ht, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
    subst allWrites
    simp only [List.all_append, Bool.and_eq_true] at allowed
    exact allowed.1

/-- A validated catalog keeps every export away from every private owner. -/
theorem validateCatalog_export_not_private (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) (valid : validateCatalog registry catalog = true)
    (component owner : Component Party Asset Domain) (hc : component ∈ catalog)
    (ho : owner ∈ catalog) (port : ResourcePort Party Asset Domain)
    (hp : port ∈ component.exports) : port.cell ∉ owner.privateCells := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have componentValid := List.all_eq_true.mp valid.2 component hc
  simp only [Bool.and_eq_true] at componentValid
  have exportValid := List.all_eq_true.mp componentValid.1.1.2 port hp
  simpa using (show ¬port.cell ∈ owner.privateCells from by
    intro h
    have : catalog.any (fun c ↦ decide (port.cell ∈ c.privateCells)) = true :=
      List.any_eq_true.mpr ⟨owner, ho, by simpa using h⟩
    simp [this] at exportValid)

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshots_length (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    (snapshots index component interface state).length = interface.outputs.length := by
  simp [snapshots]

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshot_of_selected (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain)
    (output : OutputPort Party Asset Domain) (h : output ∈ interface.outputs) :
    (⟨index, ⟨component, output.id⟩,
      ⟨.amount output.cell.2.2, state.balance output.cell⟩⟩ : OutputObservation Asset) ∈
      snapshots index component interface state := by
  exact List.mem_map.mpr ⟨output, h, rfl⟩

omit [DecidableEq Asset] in
theorem resolveSource_literal (index : Nat) (history : List (OutputObservation Asset))
    (value : PackedValue Asset) : resolveSource index history (.literal value) = .ok value := rfl

omit [DecidableEq Asset] in
theorem resolveSource_not_prior (index step : Nat) (history : List (OutputObservation Asset))
    (port : QualifiedPort) (h : ¬step < index) :
    resolveSource index history (.priorOutput step port) = .error .unavailableOutput := by
  simp [resolveSource, h]

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

-- BEGIN PROOFS

theorem AgreeOn.refl (region : Set (Cell Party Asset Domain))
    (state : State Party Asset Domain) : AgreeOn region state state := by
  intro cell hc
  rfl

theorem AgreeOn.symm {region : Set (Cell Party Asset Domain)}
    {s t : State Party Asset Domain} (h : AgreeOn region s t) : AgreeOn region t s := by
  intro cell hc
  exact (h cell hc).symm

theorem AgreeOn.trans {region : Set (Cell Party Asset Domain)}
    {s t u : State Party Asset Domain} (hst : AgreeOn region s t)
    (htu : AgreeOn region t u) : AgreeOn region s u := by
  intro cell hc
  exact (hst cell hc).trans (htu cell hc)

theorem supported_frame {region : Set (Cell Party Asset Domain)}
    {predicate : State Party Asset Domain → Prop} (support : Supports region predicate)
    {pre post : State Party Asset Domain} (unchanged : AgreeOn region pre post) :
    predicate pre ↔ predicate post := support pre post unchanged

theorem supports_balance (cell : Cell Party Asset Domain) (predicate : ℚ → Prop) :
    Supports {cell} (fun state ↦ predicate (state.balance cell)) := by
  intro pre post h
  change predicate (pre.balance cell) ↔ predicate (post.balance cell)
  rw [h cell (Set.mem_singleton cell)]

theorem initialized_invariants
    (contracts : List (ComponentContract Party Asset Domain Boundary))
    (obligations : ∀ c ∈ contracts, ContractObligations c)
    (world : World Party Asset Domain) (initial : Initial contracts world) :
    ∀ c ∈ contracts, c.invariant world := by
  intro c hc
  exact (obligations c hc).initialized world (initial c hc)

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

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
/-- The emitted write footprint is exactly the template's resolved declared footprint. -/
theorem evaluated_writes (template : Template P A D)
    (context : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate context = .ok e) :
    resolveRefs context.caller context.parties template.writes = .ok e.writes := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  have hp := Except.ok.inj h
  rw [← hp]
  assumption

omit [Fintype P] [Fintype A] [Fintype D] in
/-- The component and access check are selected from the trusted catalog and registry. -/
theorem prepareInvocation_access (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    ∃ component template, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ cfg.registry request.operation = some template ∧
      checkAccess component template boundary.ctx request.parties = .ok PUnit.unit := by
  cases hl : lookupOperation cfg.catalog inv.component inv.operation with
  | none => simp [prepareInvocation, hl, bind, Except.bind] at h
  | some pair =>
    rcases pair with ⟨component, selected⟩
    cases ha : resolveInputs index history selected inv.inputs with
    | error reason => simp [prepareInvocation, hl, ha, bind, Except.bind, Except.mapError] at h
    | ok arguments =>
      cases ht : cfg.registry inv.operation with
      | none => simp [prepareInvocation, hl, ha, ht, bind, Except.bind, Except.mapError] at h
      | some template =>
        cases hc : checkAccess component template boundary.ctx inv.parties with
        | error reason =>
          simp [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError] at h
        | ok token =>
          cases token
          simp only [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError,
            pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          exact ⟨component, template, rfl, ht, hc⟩

theorem extractReceipt_total (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ := execute_evaluated _ _ _ _ _ _ _ _ h
  exact ⟨e, by simp [extractReceipt, ht, ha, he, Except.mapError, bind, Except.bind], happly⟩

theorem extractReceipt_correspondence (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D) (e : Evaluated P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) (he : extractReceipt cfg boundary request pre = .ok e) :
    applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨e', he', happly⟩ := extractReceipt_total cfg boundary request pre post h
  rw [he] at he'
  cases he'
  exact happly

inductive StepSound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) : Step P A D → World P A D → StepResult P A D → Prop
  | invoke (inv : Invocation P A D) (pre post : World P A D)
      (iface : OperationInterface P A D) (request : Request P A D) (e : Evaluated P A D)
      (prepared : prepareInvocation cfg boundary index history inv = .ok (iface, request))
      (executed : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
        request pre.state = .ok post)
      (extracted : extractReceipt cfg boundary request pre = .ok e)
      (applied : applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post) :
      StepSound cfg boundary index history (.invoke inv) pre
        ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | issue (grant : Grant P A D) (pre : World P A D) (id : CapabilityId)
      (store : CapabilityStore P A D)
      (issued : issueCapability cfg.authority boundary.ctx pre.capabilities grant =
        .ok (id, store)) :
      StepSound cfg boundary index history (.issue grant) pre ⟨⟨pre.state, store⟩, .issued id, []⟩
  | revoke (id : CapabilityId) (pre : World P A D) (store : CapabilityStore P A D)
      (revoked : revokeCapability cfg.authority boundary.ctx pre.capabilities id = .ok store) :
      StepSound cfg boundary index history (.revoke id) pre ⟨⟨pre.state, store⟩, .revoked id, []⟩

theorem executeStep_sound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (result : StepResult P A D) (h : executeStep cfg boundary index history step pre = .ok result) :
    StepSound cfg boundary index history step pre result := by
  cases hv : validateCatalog cfg.registry cfg.catalog with
  | false => cases step <;> simp [executeStep, hv, throw, throwThe, bind, Except.bind] at h
  | true =>
    cases step with
    | invoke inv =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hp : prepareInvocation cfg boundary index history inv with
      | error err => simp [hp] at h
      | ok pair =>
        rcases pair with ⟨iface, request⟩
        simp only [hp] at h
        cases hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env
            boundary.now
            request pre.state with
        | error err => simp [hx, Except.mapError] at h
        | ok post =>
          simp only [hx, Except.mapError] at h
          cases he : extractReceipt cfg boundary request pre with
          | error err => simp [he] at h
          | ok e =>
            simp only [he, Except.ok.injEq] at h
            subst result
            exact .invoke inv pre post iface request e hp hx he
              (extractReceipt_correspondence cfg boundary request pre post e hx he)
    | issue grant =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hi : issueCapability cfg.authority boundary.ctx pre.capabilities grant with
      | error err => simp [hi, Except.mapError] at h
      | ok pair =>
        rcases pair with ⟨id, store⟩
        simp only [hi, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .issue grant pre id store hi
    | revoke id =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hr : revokeCapability cfg.authority boundary.ctx pre.capabilities id with
      | error err => simp [hr, Except.mapError] at h
      | ok store =>
        simp only [hr, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .revoke id pre store hr

theorem StepSound.accounting {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (d : D) (a : A) :
    total result.world.state d a = total pre.state d a + result.receipt.supply d a := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_accounting _ _ _ _ _ _ ha d a
  | issue => simp [Receipt.supply]
  | revoke => simp [Receipt.supply]

theorem StepSound.locality {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (c : Cell P A D) (hc : c ∉ result.receipt.writes) :
    result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_locality _ _ _ _ _ _ ha c hc
  | issue => rfl
  | revoke => rfl

/-- Every declared receipt write is allowed by the selected component interface. -/
theorem StepSound.component_writes {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell ∈ result.receipt.writes, component.canWrite cell = true := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨component, template, hl, ht, hc⟩ := prepareInvocation_access _ _ _ _ _ _ _ hp
    obtain ⟨selected, hs, args, hargs, actual, evaluated, applied⟩ :=
      execute_evaluated _ _ _ _ _ _ _ _ hx
    rw [ht] at hs
    cases hs
    have extracted : extractReceipt cfg boundary request pre = .ok actual := by
      simp [extractReceipt, ht, hargs, evaluated, bind, Except.bind, Except.mapError]
    rw [he] at extracted
    cases extracted
    have writes := evaluated_writes _ _ _ evaluated
    have allowed := checkAccess_declaredWrites component template boundary.ctx
      request.parties e.writes hc writes
    exact ⟨component, iface, hl, by simpa [Receipt.writes] using List.all_eq_true.mp allowed⟩

theorem StepSound.component_locality {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
        result.world.state.balance cell = pre.state.balance cell := by
  obtain ⟨component, iface, selected, writes⟩ := h.component_writes
  refine ⟨component, iface, selected, ?_⟩
  intro cell denied
  apply h.locality cell
  intro member
  have allowed := writes cell member
  rw [denied] at allowed
  contradiction

theorem StepSound.invoke_preserves_capabilities {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {inv : Invocation P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    result.world.capabilities = pre.capabilities := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact execute_preserves_capabilities _ _ _ _ _ _ _ _ hx

theorem StepSound.issue_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {grant : Grant P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    result.world.state = pre.state := by cases h; rfl

theorem StepSound.revoke_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {id : CapabilityId} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.revoke id) pre result) :
    result.world.state = pre.state := by cases h; rfl

def ReceiptAuthorized (pre : World P A D) (boundary : Boundary P A D)
    (receipt : Receipt P A D) : Prop :=
  match receipt with
  | .invoked request e =>
    hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation .invoke = true ∧
    (∀ c, e.effect c < 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.debit c) = true) ∧
    (∀ d a, e.supply d a ≠ 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.changeSupply d a) = true)
  | _ => True

theorem StepSound.issue_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {grant : Grant P A D} {pre : World P A D}
    {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    boundary.ctx.domain = grant.domain ∧
      boundary.ctx.principal = cfg.domainAdmin grant.domain := by
  cases h with
  | issue grant pre id store hi => exact issueCapability_admin _ _ _ _ _ _ hi

theorem StepSound.revoke_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {id : CapabilityId} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.revoke id) pre result) :
    ∃ cap, pre.capabilities.lookup id = some cap ∧ boundary.ctx.domain = cap.domain ∧
      boundary.ctx.principal = cfg.domainAdmin cap.domain := by
  cases h with
  | revoke id pre store hr => exact revokeCapability_admin _ _ _ _ _ hr

theorem StepSound.authorized {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result) :
    ReceiptAuthorized pre boundary result.receipt := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp hx
    obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp ha
    exact ⟨hi, of_decide_eq_true hv.2.2.2.2.1, of_decide_eq_true hv.2.2.2.2.2.1⟩
  | issue => trivial
  | revoke => trivial

theorem StepSound.domain {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.invoke inv) pre result)
    (c : Cell P A D) (hc : result.world.state.balance c ≠ pre.state.balance c) :
    c.1 = boundary.ctx.domain := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, _, _, hdom⟩ := execute_reads_and_domain _ _ _ _ _ _ _ _ hx
    exact hdom c hc

theorem executeStep_configuration (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    executeStep cfg boundary index history step pre = .error .configuration := by
  cases step <;> simp [executeStep, h, throw, throwThe, bind, Except.bind] <;> rfl

theorem executeStep_delegated_refusal (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (reason : Typed.Refusal) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .error reason) :
    executeStep cfg boundary index history (.invoke inv) pre = .error (.kernel reason) := by
  simp [executeStep, hv, hp, hx, Except.mapError, bind, Except.bind]

theorem executeStep_delegated_success (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre post : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      executeStep cfg boundary index history (.invoke inv) pre =
        .ok ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩ := by
  obtain ⟨e, he, _⟩ := extractReceipt_total cfg boundary request pre post hx
  exact ⟨e, he, by
    simp [executeStep, hv, hp, hx, he, Except.mapError, bind, Except.bind, pure, Except.pure]⟩

end DefiKernel.Composition


/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel


/-! Complete finite schedules and ordered structural admission. Overlapping footprints are
admitted here; compatibility remains a separate premise for disjoint recovery. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev Schedule := List BranchId

structure ScheduleMismatch where
  expectedLeft : Nat
  observedLeft : Nat
  expectedRight : Nat
  observedRight : Nat
  deriving DecidableEq, Repr

def checkSchedule (leftLength rightLength : Nat) (schedule : Schedule) :
    Except ScheduleMismatch (PUnit : Type) :=
  if schedule.count .left = leftLength ∧ schedule.count .right = rightLength then .ok ⟨⟩
  else .error ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩

def Complete {P A D : Type} (left right : Branch P A D) (schedule : Schedule) : Prop :=
  schedule.count .left = left.length ∧ schedule.count .right = right.length

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

-- BEGIN PROOFS

theorem checkSchedule_ok_iff (leftLength rightLength : Nat) (schedule : Schedule) :
    checkSchedule leftLength rightLength schedule = .ok ⟨⟩ ↔
      schedule.count .left = leftLength ∧ schedule.count .right = rightLength := by
  simp [checkSchedule]

theorem checkSchedule_error_iff (leftLength rightLength : Nat) (schedule : Schedule)
    (mismatch : ScheduleMismatch) :
    checkSchedule leftLength rightLength schedule = .error mismatch ↔
      ¬ (schedule.count .left = leftLength ∧ schedule.count .right = rightLength) ∧
      mismatch = ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩ := by
  by_cases h : schedule.count .left = leftLength ∧ schedule.count .right = rightLength
  · simp [checkSchedule, h]
  · simp only [checkSchedule, h, if_false, Except.error.injEq, not_false_eq_true, true_and]
    exact eq_comm

theorem count_sum_length (schedule : Schedule) :
    schedule.count .left + schedule.count .right = schedule.length := by
  induction schedule with
  | nil => rfl
  | cons branch schedule ih =>
    cases branch <;> simp at * <;> omega

theorem count_append (branch : BranchId) (first second : Schedule) :
    (first ++ second).count branch = first.count branch + second.count branch :=
  List.count_append

theorem count_left_cons (schedule : Schedule) :
    (BranchId.left :: schedule).count .left = schedule.count .left + 1 := by simp

theorem count_right_cons (schedule : Schedule) :
    (BranchId.right :: schedule).count .right = schedule.count .right + 1 := by simp

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.length {left right : Branch P A D} {schedule : Schedule}
    (h : Complete left right schedule) : schedule.length = left.length + right.length := by
  rw [← count_sum_length, h.1, h.2]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_empty_iff (schedule : Schedule) :
    Complete ([] : Branch P A D) [] schedule ↔ schedule = [] := by
  constructor
  · intro h
    exact List.length_eq_zero_iff.mp h.length
  · rintro rfl
    exact ⟨rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_left_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete (inv :: left) right (.left :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_right_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete left (inv :: right) (.right :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.prefix_counts {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ suffix)) :
    preTokens.count .left ≤ left.length ∧ preTokens.count .right ≤ right.length := by
  obtain ⟨hl, hr⟩ := h
  simp only [List.count_append] at hl hr
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.left_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .left :: suffix)) :
    preTokens.count .left < left.length := by
  have hl := h.1
  simp only [List.count_append, List.count_cons_self] at hl
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.right_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .right :: suffix)) :
    preTokens.count .right < right.length := by
  have hr := h.2
  simp only [List.count_append, List.count_cons_self] at hr
  omega

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Complete left right schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hc)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  simp [admit, hv, hl, hr, checkSchedule, hs.1, hs.2, Except.mapError,
    bind, Except.bind, pure, Except.pure]

theorem admit_of_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf))
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  exact admit_of_checks cfg boundaries left right schedule lf rf hv hl hr hs

theorem admit_left_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : left[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .left n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ lf.reads) ∧ (∀ c ∈ part.writes, c ∈ lf.writes) := by
  have hl := (admit_ok cfg boundaries left right schedule lf rf h).2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .left) 0 left lf hl n inv hi

theorem admit_right_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : right[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .right n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ rf.reads) ∧ (∀ c ∈ part.writes, c ∈ rf.writes) := by
  have hr := (admit_ok cfg boundaries left right schedule lf rf h).2.2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .right) 0 right rf hr n inv hi

end DefiKernel.Interleaving


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

-- BEGIN PROOFS

/-- The trace relates actual step evidence at each preceding world and output history. -/
inductive TraceSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) :
    List (Event P A D) → World P A D → List (OutputObservation A) → Nat → Prop
  | nil : TraceSound cfg boundaries initial [] initial [] 0
  | snoc {events : List (Event P A D)} {pre : World P A D}
      {history : List (OutputObservation A)} {index : Nat}
      (previous : TraceSound cfg boundaries initial events pre history index)
      (step : Step P A D) (result : StepResult P A D)
      (accepted : StepSound cfg (boundaries index) index history step pre result) :
      TraceSound cfg boundaries initial (events ++ [⟨index, step, pre, result⟩])
        result.world (history ++ result.outputs) (index + 1)

def RefusalSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : Prop :=
  ∀ failure, cursor.failure = some failure → failure.index = cursor.nextIndex ∧
    match failure.step with
    | none => failure.reason = .configuration ∧ validateCatalog cfg.registry cfg.catalog = false
    | some step => executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex
        cursor.outputs step cursor.world = .error failure.reason

theorem continueRun_nil (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : continueRun cfg boundaries cursor [] = cursor := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (firstSteps suffix : List (Step P A D)) :
    continueRun cfg boundaries cursor (firstSteps ++ suffix) =
      continueRun cfg boundaries (continueRun cfg boundaries cursor firstSteps) suffix := by
  exact List.foldl_append

theorem continueRun_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (steps : List (Step P A D)) :
    continueRun cfg boundaries cursor steps = cursor := by
  induction steps with
  | nil => rfl
  | cons step steps ih =>
    simpa [continueRun, List.foldl_cons, advance, failed] using ih

/-- Recorded invocations/admin steps are an ordered prefix of the submitted list. -/
theorem continueRun_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (continueRun cfg boundaries cursor steps).events.map Event.step =
        cursor.events.map Event.step ++ accepted := by
  induction steps generalizing cursor with
  | nil => exact ⟨[], [], rfl, by simp [continueRun]⟩
  | cons step steps ih =>
    cases hf : cursor.failure with
    | some failure =>
      exact ⟨[], step :: steps, rfl, by rw [continueRun_failed _ _ _ _ hf]; simp⟩
    | none =>
      cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : (advance cfg boundaries cursor step).failure =
            some ⟨cursor.nextIndex, some step, reason⟩ := by simp [advance, hf, he]
        refine ⟨[], step :: steps, rfl, ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ []
        rw [continueRun_failed _ _ _ _ ha]
        simp [advance, hf, he]
      | ok result =>
        obtain ⟨accepted, remaining, hs, hout⟩ := ih (advance cfg boundaries cursor step)
        refine ⟨step :: accepted, remaining, by simp [hs], ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ step :: accepted
        rw [hout]
        simp [advance, hf, he, List.map_append, List.append_assoc]

theorem run_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (run cfg boundaries initial steps).events.map Event.step = accepted := by
  simpa [run, startCursor] using continueRun_order cfg boundaries (startCursor cfg initial) steps

theorem advance_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (step : Step P A D)
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (advance cfg boundaries cursor step).events
      (advance cfg boundaries cursor step).world (advance cfg boundaries cursor step).outputs
      (advance cfg boundaries cursor step).nextIndex := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason => simpa [advance, hf, he] using h
    | ok result =>
      simpa [advance, hf, he] using h.snoc step result (executeStep_sound _ _ _ _ _ _ _ he)

theorem continueRun_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (continueRun cfg boundaries cursor steps).events
      (continueRun cfg boundaries cursor steps).world
      (continueRun cfg boundaries cursor steps).outputs
      (continueRun cfg boundaries cursor steps).nextIndex := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_trace_sound cfg boundaries initial cursor step h)

theorem run_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    TraceSound cfg boundaries initial (run cfg boundaries initial steps).events
      (run cfg boundaries initial steps).world (run cfg boundaries initial steps).outputs
      (run cfg boundaries initial steps).nextIndex := by
  apply continueRun_trace_sound
  exact .nil

theorem advance_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (advance cfg boundaries cursor step) := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason =>
      intro failure hh
      simp only [advance, hf, he, Option.some.injEq] at hh
      subst failure
      simp [advance, hf, he]
    | ok result =>
      intro failure hh
      simp [advance, hf, he] at hh

theorem continueRun_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (continueRun cfg boundaries cursor steps) := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_refusal_sound cfg boundaries cursor step h)

theorem run_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    RefusalSound cfg boundaries (run cfg boundaries initial steps) := by
  apply continueRun_refusal_sound
  intro failure h
  simp only [startCursor] at h ⊢
  split at h
  · contradiction
  · simp only [Option.some.injEq] at h
    subst failure
    rename_i hv
    exact ⟨rfl, rfl, by simpa using hv⟩

end DefiKernel.Composition


/-! Branch observations retain every request, receipt, output, and refusal field.
Raw event worlds belong to execution evidence and are deliberately not equated across orders. -/
namespace DefiKernel.Parallel
open Typed Composition

-- These computational equality instances do not alter the existing execution definitions.
deriving instance DecidableEq for Composition.InputSource
deriving instance DecidableEq for Composition.Invocation
deriving instance DecidableEq for Composition.Step
deriving instance DecidableEq for Typed.Request
deriving instance DecidableEq for Typed.Evaluated
deriving instance DecidableEq for Composition.Receipt
deriving instance DecidableEq for Composition.OutputObservation
deriving instance DecidableEq for Composition.LocatedFailure

structure EventObservation (P A D : Type) where
  index : Nat
  step : Step P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

structure BranchObservation (P A D : Type) where
  events : List (EventObservation P A D)
  outputs : List (OutputObservation A)
  nextIndex : Nat
  failure : Option (LocatedFailure P A D)
  deriving DecidableEq

def observeEvent {P A D : Type} (event : Event P A D) : EventObservation P A D :=
  ⟨event.index, event.step, event.result.receipt, event.result.outputs⟩

def observeBranch {P A D : Type} (cursor : Cursor P A D) : BranchObservation P A D :=
  ⟨cursor.events.map observeEvent, cursor.outputs, cursor.nextIndex, cursor.failure⟩

-- BEGIN PROOFS

/-- Equality of canonical branch observations includes the exact failure location and step. -/
theorem observeBranch_failure {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.failure = right.failure :=
  congrArg BranchObservation.failure h

/-- Histories are compared as ordered, typed snapshots, not as an unqualified value multiset. -/
theorem observeBranch_outputs {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.outputs = right.outputs :=
  congrArg BranchObservation.outputs h

end DefiKernel.Parallel


/-! Binary fork/join over invocation-only branches. Each branch retains its own successful
prefix and refusal. Serial references rerun the existing executor with fresh local histories. -/
namespace DefiKernel.Parallel
open Typed Composition

structure Joined (P A D : Type) where
  world : World P A D
  left : Cursor P A D
  right : Cursor P A D

inductive Result (P A D : Type) where
  | refused (reason : AdmissionFailure P A D) (world : World P A D)
  | executed (joined : Joined P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- An admitted region chooses one complete balance, never a sum of branch base balances. -/
def mergeWorld (leftFootprint rightFootprint : Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c
      else if c ∈ rightFootprint.writes then right.state.balance c
      else initial.state.balance c,
    fun c ↦ by
      split
      · exact left.state.nonneg c
      · split
        · exact right.state.nonneg c
        · exact initial.state.nonneg c⟩,
    initial.capabilities⟩

def runBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) : Cursor P A D :=
  Composition.run cfg boundary initial (branch.map Step.invoke)

def runParallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok (leftFootprint, rightFootprint) =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    .executed ⟨mergeWorld leftFootprint rightFootprint initial l.world r.world, l, r⟩

/-- Right always runs after left's retained prefix, including when left has refused. -/
def runSerialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) l.world right
    .executed ⟨r.world, l, r⟩

/-- Evaluation order changes; branch labels, local history and trusted positions do not. -/
def runSerialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let r := runBranch cfg (boundaries .right) initial right
    let l := runBranch cfg (boundaries .left) r.world left
    .executed ⟨l.world, l, r⟩

/-- Pointwise full-ledger equality plus exact capability-store equality. -/
def WorldEquivalent (left right : World P A D) : Prop :=
  (∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities

/-- Raw event worlds are omitted, but every financial and local refusal observation is kept. -/
def ObservationallyEquivalent (left right : Result P A D) : Prop :=
  match left, right with
  | .refused le lw, .refused re rw => le = re ∧ WorldEquivalent lw rw
  | .executed l, .executed r => WorldEquivalent l.world r.world ∧
      observeBranch l.left = observeBranch r.left ∧
      observeBranch l.right = observeBranch r.right
  | _, _ => False

def worldEq (left right : World P A D) : Bool :=
  decide ((∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities)

def observationsEqual (left right : Result P A D) : Bool :=
  match left, right with
  | .refused le lw, .refused re rw => decide (le = re) && worldEq lw rw
  | .executed l, .executed r => worldEq l.world r.world &&
      decide (observeBranch l.left = observeBranch r.left) &&
      decide (observeBranch l.right = observeBranch r.right)
  | _, _ => false

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_store (lf rf : Footprint P A D) (initial left right : World P A D) :
    (mergeWorld lf rf initial left right).capabilities = initial.capabilities := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_nonnegative (lf rf : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ (mergeWorld lf rf initial left right).state.balance c :=
  (mergeWorld lf rf initial left right).state.nonneg c

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_outside (lf rf : Footprint P A D) (initial left right : World P A D)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (mergeWorld lf rf initial left right).state.balance c = initial.state.balance c := by
  simp [mergeWorld, hl, hr]

theorem worldEq_iff (left right : World P A D) :
    worldEq left right = true ↔ WorldEquivalent left right := by simp [worldEq, WorldEquivalent]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ ObservationallyEquivalent left right := by
  cases left <;> cases right <;>
    simp [observationsEqual, ObservationallyEquivalent, worldEq, WorldEquivalent, and_assoc]

theorem runParallel_refuses (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (reason : AdmissionFailure P A D)
    (h : admit cfg boundaries left right = .error reason) :
    runParallel cfg boundaries initial left right = .refused reason initial := by
  simp [runParallel, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.refl (world : World P A D) : WorldEquivalent world world :=
  ⟨fun _ ↦ rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.symm {left right : World P A D} (h : WorldEquivalent left right) :
    WorldEquivalent right left := ⟨fun c ↦ (h.1 c).symm, h.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.trans {first middle last : World P A D}
    (h : WorldEquivalent first middle) (g : WorldEquivalent middle last) :
    WorldEquivalent first last := ⟨fun c ↦ (h.1 c).trans (g.1 c), h.2.trans g.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.refl (result : Result P A D) :
    ObservationallyEquivalent result result := by
  cases result with
  | refused reason world => exact ⟨rfl, .refl world⟩
  | executed joined => exact ⟨.refl joined.world, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.symm {left right : Result P A D}
    (h : ObservationallyEquivalent left right) : ObservationallyEquivalent right left := by
  cases left <;> cases right
  · exact ⟨h.1.symm, h.2.symm⟩
  · exact h.elim
  · exact h.elim
  · exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.trans {first middle last : Result P A D}
    (h : ObservationallyEquivalent first middle) (g : ObservationallyEquivalent middle last) :
    ObservationallyEquivalent first last := by
  cases first <;> cases middle <;> cases last
  · exact ⟨h.1.trans g.1, h.2.trans g.2⟩
  · exact g.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact g.elim
  · exact ⟨h.1.trans g.1, h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

end DefiKernel.Parallel


/-! Finite replay over one evolving world. Local histories and permanent refusals stay separate;
consumed static slots advance even when a failed suffix produces no further attempt. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

structure LocalState (P A D : Type) where
  consumed : Nat := 0
  events : List (Event P A D) := []
  outputs : List (OutputObservation A) := []
  nextIndex : Nat := 0
  failure : Option (LocatedFailure P A D) := none

structure Attempt (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (P A D : Type) where
  world : World P A D
  left : LocalState P A D := {}
  right : LocalState P A D := {}
  attempts : List (Attempt P A D) := []

inductive Result (P A D : Type) where
  | refused (reason : Interleaving.AdmissionFailure P A D) (world : World P A D)
      (schedule : Schedule)
  | executed (schedule : Schedule) (machine : Machine P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.local (m : Machine P A D) : BranchId → LocalState P A D
  | .left => m.left
  | .right => m.right

def Machine.setLocal (m : Machine P A D) (b : BranchId)
    (localState : LocalState P A D) : Machine P A D :=
  match b with
  | .left => { m with left := localState }
  | .right => { m with right := localState }

def selectBranch (left right : Branch P A D) : BranchId → Branch P A D
  | .left => left
  | .right => right

def start (initial : World P A D) : Machine P A D := ⟨initial, {}, {}, []⟩

/-- The new public projection owns every preserved field, including exact located failure. -/
def LocalState.observe (localState : LocalState P A D) : BranchObservation P A D :=
  ⟨localState.events.map observeEvent, localState.outputs,
    localState.nextIndex, localState.failure⟩

def LocalState.toCursor (localState : LocalState P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, localState.events, localState.outputs, localState.nextIndex, localState.failure⟩

def Attempt.supply (attempt : Attempt P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

/-- Executable aggregation of actual successful attempts; refusals contribute zero. -/
def Machine.supply (m : Machine P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def Machine.skip (m : Machine P A D) (b : BranchId) : Machine P A D :=
  m.setLocal b { m.local b with consumed := (m.local b).consumed + 1 }

def Machine.refuse (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine P A D :=
  let own := m.local b
  let stopped : LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine P A D :=
  let own := m.local b
  let advanced : LocalState P A D := ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, m.world, result⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := result.world, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

/-- Advance exactly one static branch slot, preserving the peer's local state. -/
def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D :=
  let own := m.local b
  match own.failure with
  | some _ => m.skip b
  | none =>
    match (selectBranch left right b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries left right (start initial) schedule

def runInterleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Interleaving.Result P A D :=
  match Interleaving.admit cfg boundaries left right schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial left right schedule)

/-- Exact financial fields, without raw foreign event worlds or global scheduling order. -/
def ProjectedEquivalent (m : Machine P A D) (joined : Parallel.Joined P A D) : Prop :=
  Parallel.WorldEquivalent m.world joined.world ∧
    m.left.observe = observeBranch joined.left ∧ m.right.observe = observeBranch joined.right

def observationsEqual (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw _, .refused rr rw _ => decide (lr = rr) && Parallel.worldEq lw rw
  | .executed _ l, .executed _ r => Parallel.worldEq l.world r.world &&
      decide (l.left.observe = r.left.observe) && decide (l.right.observe = r.right.observe)
  | _, _ => false

def matchesParallel (result : Interleaving.Result P A D) (parallel : Parallel.Result P A D) :
    Bool :=
  match result, parallel with
  | .executed _ m, .executed joined => Parallel.worldEq m.world joined.world &&
      decide (m.left.observe = observeBranch joined.left) &&
      decide (m.right.observe = observeBranch joined.right)
  | _, _ => false

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem local_setLocal (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).local b = l := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).world = m.world := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_toCursor (l : LocalState P A D) (w : World P A D) :
    observeBranch (l.toCursor w) = l.observe := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (s t : Schedule) :
    continueRun cfg boundaries left right m (s ++ t) =
      continueRun cfg boundaries left right (continueRun cfg boundaries left right m s) t :=
  List.foldl_append

theorem matchesParallel_iff (schedule : Schedule) (m : Machine P A D)
    (joined : Parallel.Joined P A D) :
    matchesParallel (.executed schedule m) (.executed joined) = true ↔
      ProjectedEquivalent m joined := by
  simp [matchesParallel, ProjectedEquivalent, Parallel.worldEq, Parallel.WorldEquivalent, and_assoc]

end DefiKernel.Interleaving


/-! Typed clearing policy and receipt-derived signed obligations. Lane uniqueness uses the
entire domain/asset key, so changing the vault does not remove an ambiguity. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

structure Lane (P A D : Type) where
  domain : D
  asset : A
  vault : P
  deriving DecidableEq, Repr

def Lane.cell {P A D : Type} (lane : Lane P A D) : Cell P A D :=
  (lane.domain, lane.vault, lane.asset)

structure Policy (P A D : Type) where
  lanes : List (Lane P A D)
  participants : List P

abbrev Outstanding (P A D : Type) := Lane P A D → P → ℚ

structure Residual (P A D : Type) where
  lane : Lane P A D
  principal : P
  amount : ℚ
  deriving DecidableEq, Repr

inductive PolicyFailure (P A D : Type) where
  | duplicateLane (firstIndex secondIndex : Nat) (first second : Lane P A D)
  | duplicateParticipant (firstIndex secondIndex : Nat) (principal : P)
  | uncoveredParticipant (branch : BranchId) (index : Nat) (principal : P)
  deriving DecidableEq, Repr

/-- Search in first-index then second-index order, retaining both original values. -/
def firstDuplicate {X K : Type} [DecidableEq K] (key : X → K) (index : Nat) :
    List X → Option (Nat × Nat × X × X)
  | [] => none
  | x :: xs =>
    match (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | some (y, j) => some (index, j, x, y)
    | none => firstDuplicate key (index + 1) xs

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Coverage visits every static invocation, including suffixes that might never execute. -/
def uncoveredFrom (participants : List P) (branch : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) :
    Branch P A D → Option (PolicyFailure P A D)
  | [] => none
  | _ :: xs =>
    if (boundary index).ctx.principal ∈ participants then
      uncoveredFrom participants branch boundary (index + 1) xs
    else some (.uncoveredParticipant branch index (boundary index).ctx.principal)

def checkPolicy (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (PolicyFailure P A D) (PUnit : Type) := do
  match firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes with
  | some (i, j, first, second) => throw (.duplicateLane i j first second)
  | none => pure ()
  match firstDuplicate id 0 policy.participants with
  | some (i, j, principal, _) => throw (.duplicateParticipant i j principal)
  | none => pure ()
  match uncoveredFrom policy.participants .left (boundaries .left) 0 left with
  | some failure => throw failure
  | none => pure ()
  match uncoveredFrom policy.participants .right (boundaries .right) 0 right with
  | some failure => throw failure
  | none => pure ()
  return ⟨⟩

def receiptEffect (receipt : Receipt P A D) (cell : Cell P A D) : ℚ :=
  match receipt with
  | .invoked _ e => e.effect cell
  | _ => 0

def zeroOutstanding : Outstanding P A D := fun _ _ ↦ 0

def updateOutstanding (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) : Outstanding P A D :=
  fun lane p ↦ if lane ∈ policy.lanes ∧ p = principal then
    owed lane p - receiptEffect receipt lane.cell else owed lane p

/-- Canonical lane-major, participant-minor enumeration of every nonzero table entry. -/
def residuals (policy : Policy P A D) (owed : Outstanding P A D) : List (Residual P A D) :=
  policy.lanes.flatMap fun lane ↦ policy.participants.filterMap fun principal ↦
    if owed lane principal = 0 then none else some ⟨lane, principal, owed lane principal⟩

def checkSupply (policy : Policy P A D) (receipt : Receipt P A D) : Option (Lane P A D × ℚ) :=
  (policy.lanes.find? (fun lane ↦ receipt.supply lane.domain lane.asset != 0)).map
    (fun lane ↦ (lane, receipt.supply lane.domain lane.asset))

-- BEGIN PROOFS

end DefiKernel.Atomic


/-! Finite region observations of the existing ledger and actual receipts. These functions
introduce no executor or admission check. Mixed regions have an exact sum; dimensioned
contracts separately require `Region.WellFormed`. -/
namespace DefiKernel.Interface
open Typed Composition

structure Region (P A D : Type) where
  domain : D
  asset : A
  cells : Finset (Cell P A D)

variable {P A D : Type}

def Region.WellFormed (region : Region P A D) : Prop :=
  ∀ c ∈ region.cells, c.1 = region.domain ∧ c.2.2 = region.asset

def balanceSum (region : Region P A D) (state : State P A D) : ℚ :=
  region.cells.sum state.balance

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Every repeated target contributes its signed amount. Administrative receipts contribute zero. -/
def receiptCellEffect (receipt : Receipt P A D) (cell : Cell P A D) : ℚ :=
  match receipt with
  | .invoked _ e => (e.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum
  | .issued _ | .revoked _ => 0

def receiptDelta (region : Region P A D) (receipt : Receipt P A D) : ℚ :=
  region.cells.sum (receiptCellEffect receipt)

def ValueSupports (support : Set (Cell P A D)) (value : State P A D → ℚ) : Prop :=
  ∀ s t, Composition.AgreeOn support s t → value s = value t

def WritesWithin (cells : Finset (Cell P A D)) (receipt : Receipt P A D) : Prop :=
  ∀ c ∈ receipt.writes, c ∈ cells

def NeutralOn (region : Region P A D) (cells : Finset (Cell P A D))
    (receipt : Receipt P A D) : Prop :=
  (region.cells ∩ cells).sum (receiptCellEffect receipt) = 0


end DefiKernel.Interface


/-! Ordered queries over live resource exports. Structural catalog validation and
balance equality are separate checks; failures retain the original edge position. -/
namespace DefiKernel.Interface
open Typed Composition

abbrev Binding := QualifiedPort × QualifiedPort

inductive EndpointSide where
  | left | right
  deriving DecidableEq, Repr

inductive EndpointFailure where
  | missingComponent (name : QualifiedPort)
  | missingPort (name : QualifiedPort)
  deriving DecidableEq, Repr

inductive BindingFailure (P A D : Type) where
  | configuration
  | endpoint (index : Nat) (side : EndpointSide) (reason : EndpointFailure)
  | domainMismatch (index : Nat) (left right : Cell P A D)
  | assetMismatch (index : Nat) (left right : Cell P A D)
  | unequal (index : Nat) (left right : QualifiedPort) (leftAmount rightAmount : ℚ)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def resolveExport (catalog : Catalog P A D) (name : QualifiedPort) :
    Except EndpointFailure (Cell P A D) :=
  match catalog.find? (fun component ↦ decide (component.id = name.component)) with
  | none => .error (.missingComponent name)
  | some component =>
    match component.exports.find? (fun port ↦ decide (port.id = name.port)) with
    | none => .error (.missingPort name)
    | some port => .ok port.cell

def checkEdge (catalog : Catalog P A D) (edge : Binding) (state : Typed.State P A D)
    (index : Nat) : Except (BindingFailure P A D) (PUnit : Type) :=
  match resolveExport catalog edge.1 with
  | .error reason => .error (.endpoint index .left reason)
  | .ok left =>
    match resolveExport catalog edge.2 with
    | .error reason => .error (.endpoint index .right reason)
    | .ok right =>
      if left.1 ≠ right.1 then .error (.domainMismatch index left right)
      else if left.2.2 ≠ right.2.2 then .error (.assetMismatch index left right)
      else if state.balance left ≠ state.balance right then
        .error (.unequal index edge.1 edge.2 (state.balance left) (state.balance right))
      else .ok PUnit.unit

def checkEdgesFrom (catalog : Catalog P A D) (state : Typed.State P A D)
    (index : Nat) : List Binding → Except (BindingFailure P A D) (PUnit : Type)
  | [] => .ok PUnit.unit
  | edge :: rest =>
    match checkEdge catalog edge state index with
    | .error reason => .error reason
    | .ok _ => checkEdgesFrom catalog state (index + 1) rest

def checkBindings (cfg : Config P A D) (edges : List Binding) (state : Typed.State P A D) :
    Except (BindingFailure P A D) (PUnit : Type) :=
  if true then checkEdgesFrom cfg.catalog state 0 edges
  else .error .configuration

def bindingsHold (cfg : Config P A D) (edges : List Binding) (state : Typed.State P A D) : Bool :=
  match checkBindings cfg edges state with
  | .ok _ => true
  | .error _ => false

def EdgeAgrees (catalog : Catalog P A D) (edge : Binding) (state : Typed.State P A D) : Prop :=
  ∃ left right, resolveExport catalog edge.1 = .ok left ∧
    resolveExport catalog edge.2 = .ok right ∧ left.1 = right.1 ∧
    left.2.2 = right.2.2 ∧ state.balance left = state.balance right

def Agrees (catalog : Catalog P A D) (edges : List Binding) (state : Typed.State P A D) : Prop :=
  ∀ edge ∈ edges, EdgeAgrees catalog edge state

def reverseBinding (edge : Binding) : Binding := (edge.2, edge.1)

def symClosure (edges : List Binding) : Finset Binding :=
  (edges ++ edges.map reverseBinding).toFinset


end DefiKernel.Interface


/-! Recursive ordered groups continue the complete actual cursor. `SupportedGroup` deliberately
uses `flatten` only as a Prop-valued specification of static support. The recursive `runGroup`
interpreter never delegates execution to the list executor. -/
namespace DefiKernel.Metatheory
open Typed Composition

inductive SeqGroup (P A D : Type) where
  | empty
  | step (action : Step P A D)
  | seq (first second : SeqGroup P A D)

def flatten {P A D : Type} : SeqGroup P A D → List (Step P A D)
  | .empty => []
  | .step action => [action]
  | .seq first second => flatten first ++ flatten second

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def runGroup (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : SeqGroup P A D → Cursor P A D
  | .empty => cursor
  | .step action => Composition.advance cfg boundaries cursor action
  | .seq first second =>
    let middle := runGroup cfg boundaries cursor first
    runGroup cfg boundaries middle second

-- BEGIN PROOFS

/-- Simulation includes all raw event worlds, administrative stores, absolute positions and
existing failures; there is no successful-only or initial-cursor premise. -/
theorem runGroup_eq_continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group =
      Composition.continueRun cfg boundaries cursor (flatten group) := by
  induction group generalizing cursor with
  | empty => rfl
  | step action => rfl
  | seq first second firstIH secondIH =>
    simp only [runGroup, flatten, Composition.continueRun_append, firstIH, secondIH]

theorem runGroup_empty (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : runGroup cfg boundaries cursor .empty = cursor := rfl

theorem runGroup_empty_left (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq .empty group) =
      runGroup cfg boundaries cursor group := rfl

theorem runGroup_empty_right (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq group .empty) =
      runGroup cfg boundaries cursor group := rfl

/-- A previously located refusal makes every submitted recursive group inert. -/
theorem runGroup_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group = cursor := by
  rw [runGroup_eq_continueRun]
  exact Composition.continueRun_failed cfg boundaries cursor failure failed (flatten group)

/-- Regrouping three ordered sequential groups preserves the entire returned cursor. -/
theorem runGroup_assoc (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (first second third : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq (.seq first second) third) =
      runGroup cfg boundaries cursor (.seq first (.seq second third)) := by
  rw [runGroup_eq_continueRun, runGroup_eq_continueRun]
  simp only [flatten, List.append_assoc]

end DefiKernel.Metatheory


/-! Literal financial data for F01–F20. Expected receipts, events, worlds and cursors are
constructed independently of executors and Interface queries. Every unspecified cell is zero. -/
namespace DefiKernel.Interface.Examples
open Typed Composition

inductive Party | alice | bob | carol | total | admin
  deriving DecidableEq, Repr
inductive Asset | usd | eur
  deriving DecidableEq, Repr
inductive Domain | home | away
  deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice, .bob, .carol, .total, .admin}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .eur}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.home, .away}, by intro d; cases d <;> simp⟩

abbrev P := Party
abbrev A := Asset
abbrev D := Domain
abbrev C := Cell P A D
abbrev W := World P A D
abbrev Store := CapabilityStore P A D
abbrev Inv := Invocation P A D
abbrev Cur := Cursor P A D
abbrev SR := StepResult P A D
abbrev Ev := Event P A D

def alice : C := (.home, .alice, .usd)
def bob : C := (.home, .bob, .usd)
def carol : C := (.home, .carol, .usd)
def totalCell : C := (.home, .total, .usd)
def eurCell : C := (.home, .alice, .eur)
def awayCell : C := (.away, .alice, .usd)
def awayEur : C := (.away, .alice, .eur)
def allCells : Finset C := Finset.univ

def cap (op : Nat) (right : Right P A D) : Capability P A D :=
  ⟨⟨.alice, .home, ⟨op⟩, right⟩, true⟩
def initialStore : Store := ⟨[
  cap 100 .invoke, cap 100 (.debit alice),
  cap 101 .invoke, cap 101 (.changeSupply .home .usd),
  cap 102 .invoke, cap 102 (.debit alice), cap 102 (.debit bob),
  cap 103 .invoke, cap 103 (.debit alice),
  cap 104 .invoke, cap 104 (.debit alice),
  cap 105 .invoke, cap 105 (.changeSupply .home .usd),
  cap 106 .invoke, cap 106 (.debit alice),
  cap 107 .invoke, cap 107 (.debit bob)]⟩

def balances (a b c t u v w : Nat) : C → ℚ := fun cell ↦
  if cell = alice then a else if cell = bob then b else if cell = carol then c
  else if cell = totalCell then t else if cell = eurCell then u
  else if cell = awayCell then v else if cell = awayEur then w else 0

def world (a b : Nat) (c : Nat := 0) (t : Nat := 0) (u : Nat := 0)
    (v : Nat := 0) (w : Nat := 0) (store : Store := initialStore) : W :=
  ⟨⟨balances a b c t u v w, by
    intro cell
    simp only [balances]
    repeat' split
    all_goals positivity⟩, store⟩
def initial64 := world 6 4
def initial55 := world 5 5
def paired1 := world 4 4 2
def paired2 := world 3 3 4

def ref (p : P) : CellRef P A D .usd := ⟨.home, .literal p⟩
def packed (p : P) : PackedCellRef P A D := ⟨.usd, ref p⟩
def delta (p : P) (q : ℚ) : CellDelta P A D [] := ⟨.usd, ref p, .lit q⟩
def constantTemplate (deltas : List (CellDelta P A D [])) (writes : List P)
    (supplies : List (SupplyDelta P A D []) := []) : Template P A D :=
  ⟨[], .home, 0, .lit true, deltas, supplies, [], [], writes.map packed⟩
def transfer2 := constantTemplate [delta .alice (-2), delta .bob 2] [.alice, .bob]
def mint3 := constantTemplate [delta .bob 3] [.bob] [⟨.home, .usd, .lit 3⟩]
def paired := constantTemplate [delta .alice (-1), delta .bob (-1), delta .carol 2]
  [.alice, .bob, .carol]
def oneSided := constantTemplate [delta .alice (-1), delta .carol 1] [.alice, .carol]
def repeated := constantTemplate [delta .alice (-1), delta .alice (-2), delta .bob 3]
  [.alice, .bob]
def increment := constantTemplate [delta .total 1] [.total] [⟨.home, .usd, .lit 1⟩]
def transfer7 := constantTemplate [delta .alice (-7), delta .carol 7] [.alice, .carol]
def halfInput : Expr P A D [.amount .usd] (.amount .usd) :=
  .binary (.divide (.amount Asset.usd)) (.arg .here) (.lit 2)
def returnHalf : Template P A D :=
  ⟨[.amount .usd], .home, 0, .lit true,
    [⟨.usd, ref .bob, .unary (.neg (.amount Asset.usd)) halfInput⟩,
     ⟨.usd, ref .alice, halfInput⟩], [], [], [], [packed .bob, packed .alice]⟩
def registry (op : OperationId) : Option (Template P A D) :=
  match op.value with
  | 100 => some transfer2 | 101 => some mint3 | 102 => some paired
  | 103 => some oneSided | 104 => some repeated | 105 => some increment
  | 106 => some transfer7 | 107 => some returnHalf | _ => none

def name (component : Nat) (port : Nat := 0) : QualifiedPort := ⟨⟨component⟩, ⟨port⟩⟩
def interfaces (snapshot : Bool := false) : List (OperationInterface P A D) := [
  ⟨⟨100⟩, [], if snapshot then [⟨⟨10⟩, alice⟩] else []⟩,
  ⟨⟨101⟩, [], []⟩, ⟨⟨102⟩, [], []⟩, ⟨⟨103⟩, [], []⟩,
  ⟨⟨104⟩, [], []⟩, ⟨⟨105⟩, [], []⟩, ⟨⟨106⟩, [], []⟩,
  ⟨⟨107⟩, [⟨⟨11⟩, .amount .usd⟩], []⟩]
def exporter (id : Nat) (cell : C) : Component P A D :=
  ⟨⟨id⟩, [], [⟨⟨0⟩, cell, true⟩], [], []⟩
def catalog (exposed : Bool := false) (snapshot : Bool := false) : Catalog P A D := [
  ⟨⟨0⟩, [], [⟨⟨0⟩, alice, true⟩],
    [⟨name 1, bob, true⟩, ⟨name 2, carol, true⟩] ++
      if exposed then [⟨name 6, totalCell, true⟩] else [], interfaces snapshot⟩,
  exporter 1 bob, exporter 2 carol, exporter 3 eurCell,
  exporter 4 awayCell, exporter 5 awayEur,
  if exposed then exporter 6 totalCell else ⟨⟨6⟩, [totalCell], [], [], []⟩,
  ⟨⟨7⟩, [], [], [⟨name 0, alice, true⟩], []⟩]
def config (exposed : Bool := false) (snapshot : Bool := false) : Config P A D :=
  ⟨registry, fun _ ↦ .admin, catalog exposed snapshot⟩
def cfg := config
def exposedCfg := config true
def snapshotCfg := config false true

def ids (values : List Nat) : List CapabilityId := values.map (⟨·⟩)
def invocation (op : Nat) (caps : List Nat) (inputs : List (InputSource A) := []) : Inv :=
  ⟨⟨0⟩, ⟨op⟩, [], inputs, ids caps, none⟩
def op100 := invocation 100 [0, 1]
def op101 := invocation 101 [2, 3]
def op102 := invocation 102 [4, 5, 6]
def op103 := invocation 103 [7, 8]
def op104 := invocation 104 [9, 10]
def op105 := invocation 105 [11, 12]
def op106 := invocation 106 [13, 14]
def op107 := invocation 107 [15, 16] [.priorOutput 2 (name 0 10)]
def boundary (_ : Nat) : Boundary P A D := ⟨⟨.alice, .home⟩, fun _ ↦ none, 0⟩
def adminBoundary (_ : Nat) : Boundary P A D := ⟨⟨.admin, .home⟩, fun _ ↦ none, 0⟩
def sharedBoundary (_ : Parallel.BranchId) : Nat → Boundary P A D := boundary

/-- Expected evaluated records use their own literal lists, never template.evaluate. -/
def evaluated (deltas : List (C × ℚ)) (writes : List C)
    (supplies : List ((D × A) × ℚ) := []) : Evaluated P A D :=
  ⟨true, deltas, supplies, [], [], [], [], writes⟩
def receipt100 : Receipt P A D := .invoked ⟨⟨100⟩, [], [], ids [0, 1], none⟩
  (evaluated [(alice, -2), (bob, 2)] [alice, bob])
def receipt101 : Receipt P A D := .invoked ⟨⟨101⟩, [], [], ids [2, 3], none⟩
  (evaluated [(bob, 3)] [bob] [((.home, .usd), 3)])
def receipt102 : Receipt P A D := .invoked ⟨⟨102⟩, [], [], ids [4, 5, 6], none⟩
  (evaluated [(alice, -1), (bob, -1), (carol, 2)] [alice, bob, carol])
def receipt103 : Receipt P A D := .invoked ⟨⟨103⟩, [], [], ids [7, 8], none⟩
  (evaluated [(alice, -1), (carol, 1)] [alice, carol])
def receipt104 : Receipt P A D := .invoked ⟨⟨104⟩, [], [], ids [9, 10], none⟩
  (evaluated [(alice, -1), (alice, -2), (bob, 3)] [alice, bob])
def receipt105 : Receipt P A D := .invoked ⟨⟨105⟩, [], [], ids [11, 12], none⟩
  (evaluated [(totalCell, 1)] [totalCell] [((.home, .usd), 1)])
def receipt107 : Receipt P A D := .invoked
  ⟨⟨107⟩, [], [⟨.amount .usd, 4⟩], ids [15, 16], none⟩
  (evaluated [(bob, -2), (alice, 2)] [bob, alice])
def expected100 : SR := ⟨world 4 6, receipt100, []⟩
def expected101 : SR := ⟨world 6 7, receipt101, []⟩
def expected104 : SR := ⟨world 3 7, receipt104, []⟩
def expected102 : SR := ⟨paired1, receipt102, []⟩
def expected103 : SR := ⟨world 4 5 1, receipt103, []⟩
def expected105 : SR := ⟨world 6 4 0 11, receipt105, []⟩
def firstPaired : Ev := ⟨0, .invoke op102, initial55, expected102⟩
def secondPaired : Ev := ⟨1, .invoke op102, paired1, ⟨paired2, receipt102, []⟩⟩
def initialCursor : Cur := ⟨initial55, [], [], 0, none⟩
def firstCursor : Cur := ⟨paired1, [firstPaired], [], 1, none⟩
def secondCursor : Cur := ⟨paired2, [firstPaired, secondPaired], [], 2, none⟩
def refusedCursor : Cur := { firstCursor with
  failure := some ⟨1, some (.invoke op106), .kernel .insufficientFunds⟩ }
def pairedGroup : Metatheory.SeqGroup P A D :=
  .seq (.step (.invoke op102)) (.step (.invoke op102))

def output (index port : Nat) (value : ℚ) : OutputObservation A :=
  ⟨index, name 0 port, ⟨.amount .usd, value⟩⟩
def priorOutput := output 1 12 9
def snapshotOutput := output 2 10 4
def arbitraryEntry : Cur := ⟨initial64, [], [priorOutput], 2, none⟩
def snapshotFirst : Ev :=
  ⟨2, .invoke op100, initial64, ⟨world 4 6, receipt100, [snapshotOutput]⟩⟩
def snapshotSecond : Ev :=
  ⟨3, .invoke op107, world 4 6, ⟨initial64, receipt107, []⟩⟩
def snapshotPrefix : Cur :=
  ⟨world 4 6, [snapshotFirst], [priorOutput, snapshotOutput], 3, none⟩
def snapshotFinal : Cur :=
  ⟨initial64, [snapshotFirst, snapshotSecond], [priorOutput, snapshotOutput], 4, none⟩
def snapshotGroup : Metatheory.SeqGroup P A D :=
  .seq (.step (.invoke op100)) (.step (.invoke op107))

def grant : Grant P A D := ⟨.bob, .home, ⟨100⟩, .invoke⟩
def issuedStore : Store := ⟨initialStore.entries ++ [⟨grant, true⟩]⟩
def revokedStore : Store := ⟨initialStore.entries ++ [⟨grant, false⟩]⟩
def issuedWorld := world 6 4 0 0 0 0 0 issuedStore
def revokedWorld := world 6 4 0 0 0 0 0 revokedStore
def issuedResult : SR := ⟨issuedWorld, .issued ⟨17⟩, []⟩
def revokedResult : SR := ⟨revokedWorld, .revoked ⟨17⟩, []⟩
def issueEvent : Ev := ⟨0, .issue grant, initial64, issuedResult⟩
def revokeEvent : Ev := ⟨1, .revoke ⟨17⟩, issuedWorld, revokedResult⟩
def adminFinal : Cur := ⟨revokedWorld, [issueEvent, revokeEvent], [], 2, none⟩

/-- Literal shared machines preserve each raw world and the actual attempt order. -/
def leftFailure : LocatedFailure P A D :=
  ⟨1, some (.invoke op106), .kernel .insufficientFunds⟩
def rightPaired : Ev := ⟨0, .invoke op102, paired1, ⟨paired2, receipt102, []⟩⟩
def leftLocal (consumed : Nat) : Interleaving.LocalState P A D :=
  ⟨consumed, [firstPaired], [], 1, some leftFailure⟩
def rightLocal : Interleaving.LocalState P A D := ⟨1, [rightPaired], [], 1, none⟩
def acceptedLeft : Interleaving.Attempt P A D :=
  ⟨.left, 0, op102, initial55, .ok expected102⟩
def acceptedRight : Interleaving.Attempt P A D :=
  ⟨.right, 0, op102, paired1, .ok ⟨paired2, receipt102, []⟩⟩
def refusedLeft (pre : W) : Interleaving.Attempt P A D :=
  ⟨.left, 1, op106, pre, .error (.kernel .insufficientFunds)⟩
def expectedF17 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 2, rightLocal, [acceptedLeft, acceptedRight, refusedLeft paired2]⟩
def expectedF19 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 2, rightLocal, [acceptedLeft, refusedLeft paired1, acceptedRight]⟩
def expectedF20 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 3, rightLocal, [acceptedLeft, refusedLeft paired1, acceptedRight]⟩
def expectedSharedFirst : Interleaving.Machine P A D :=
  ⟨paired1, ⟨1, [firstPaired], [], 1, none⟩, {}, [acceptedLeft]⟩
def expectedSharedRefused : Interleaving.Machine P A D :=
  ⟨paired1, leftLocal 2, {}, [acceptedLeft, refusedLeft paired1]⟩
def expectedSharedSkipped : Interleaving.Machine P A D :=
  ⟨paired1, leftLocal 3, {}, [acceptedLeft, refusedLeft paired1]⟩


end DefiKernel.Interface.Examples


/-! Executed full-data financial comparisons. All expected worlds/receipts/events come from
literal Examples data; query expectations are written exact constructors. -/
namespace DefiKernel.Interface.Tests
open Typed Composition Examples

def pairRegion : Region P A D := ⟨.home, .usd, {alice, bob}⟩
def singleRegion : Region P A D := ⟨.home, .usd, {alice}⟩
def tripleRegion : Region P A D := ⟨.home, .usd, {alice, bob, carol}⟩
def emptyRegion : Region P A D := ⟨.home, .usd, ∅⟩
def duplicateRegion : Region P A D := ⟨.home, .usd, {alice, alice, bob}⟩
def mixedRegion : Region P A D := ⟨.home, .usd, {alice, awayEur}⟩
def wellFormed (region : Region P A D) : Bool :=
  decide (∀ c ∈ region.cells, c.1 = region.domain ∧ c.2.2 = region.asset)
def equalEdge : List Binding := [(name 0, name 1)]
def transitiveEdges : List Binding := [(name 0, name 1), (name 1, name 2)]
def redundantEdges := transitiveEdges ++ [(name 0, name 2)]
/-- Fixture-only extraction of cross-cut edges: both A and C are on the first side.
The production query always receives the global list; this is the omitted-edge counterexample. -/
def cutSide : Finset QualifiedPort := {name 0, name 2}
def cutExtracted : List Binding := [(name 0, name 2)].filter (fun edge ↦
  decide ((edge.1 ∈ cutSide ∧ edge.2 ∉ cutSide) ∨
    (edge.1 ∉ cutSide ∧ edge.2 ∈ cutSide)))
def invalidCfg : Config P A D := { cfg with catalog := cfg.catalog ++ [exporter 0 alice] }

def worldEq (x y : W) : Bool :=
  decide ((∀ c, x.state.balance c = y.state.balance c) ∧ x.capabilities = y.capabilities)
def resultEq (x y : SR) : Bool :=
  worldEq x.world y.world && decide (x.receipt = y.receipt ∧ x.outputs = y.outputs)
def outcomeEq (x y : Except Composition.Failure SR) : Bool :=
  match x, y with
  | .error a, .error b => decide (a = b)
  | .ok a, .ok b => resultEq a b
  | _, _ => false
def eventEq (x y : Ev) : Bool :=
  decide (x.index = y.index ∧ x.step = y.step) && worldEq x.before y.before &&
    resultEq x.result y.result
def eventsEq (xs ys : List Ev) : Bool :=
  decide (xs.length = ys.length) && (xs.zip ys).all (fun (x, y) ↦ eventEq x y)
def cursorEq (x y : Cur) : Bool :=
  worldEq x.world y.world && eventsEq x.events y.events &&
    decide (x.outputs = y.outputs ∧ x.nextIndex = y.nextIndex ∧ x.failure = y.failure)
def localEq (x y : Interleaving.LocalState P A D) : Bool :=
  eventsEq x.events y.events && decide (x.consumed = y.consumed ∧
    x.outputs = y.outputs ∧ x.nextIndex = y.nextIndex ∧ x.failure = y.failure)
def attemptEq (x y : Interleaving.Attempt P A D) : Bool :=
  decide (x.branch = y.branch ∧ x.index = y.index ∧ x.invocation = y.invocation) &&
    worldEq x.before y.before && outcomeEq x.outcome y.outcome
def machineEq (x y : Interleaving.Machine P A D) : Bool :=
  worldEq x.world y.world && localEq x.left y.left && localEq x.right y.right &&
    decide (x.attempts.length = y.attempts.length) &&
      (x.attempts.zip y.attempts).all (fun (a, b) ↦ attemptEq a b)
def sharedEq (x : Interleaving.Result P A D) (schedule : Interleaving.Schedule)
    (expected : Interleaving.Machine P A D) : Bool :=
  match x with
  | .refused _ _ _ => false
  | .executed actual machine => decide (actual = schedule) && machineEq machine expected

def execute (inv : Inv) (entry : W := initial64) (config : Config P A D := cfg) :=
  executeStep config (boundary 0) 0 [] (.invoke inv) entry

def transfer := execute op100
def minted := execute op101
def repeatedRun := execute op104
def pairedRun := execute op102 initial55
def oneSidedRun := execute op103 initial55

def resultHas (actual : Except Composition.Failure SR) (predicate : SR → Bool) : Bool :=
  match actual with | .ok result => predicate result | .error _ => false

def groupFirst := Metatheory.runGroup cfg boundary initialCursor (.step (.invoke op102))
def groupBoth := Metatheory.runGroup cfg boundary initialCursor pairedGroup
def snapshotFirstRun := Metatheory.runGroup snapshotCfg boundary arbitraryEntry
  (.step (.invoke op100))
def snapshotRun := Metatheory.runGroup snapshotCfg boundary arbitraryEntry snapshotGroup

def catalogChecks : List (String × Bool) := [
  ("interface.catalog.valid", validateCatalog cfg.registry cfg.catalog),
  ("interface.catalog.private-total", validateCatalog cfg.registry (catalog false)),
  ("interface.catalog.exposed-total", validateCatalog exposedCfg.registry exposedCfg.catalog),
  ("interface.catalog.snapshot", validateCatalog snapshotCfg.registry snapshotCfg.catalog),
  ("interface.catalog.invalid", !validateCatalog invalidCfg.registry invalidCfg.catalog),
  ("interface.fixture.twenty-cells", decide (allCells.card = 20)),
  ("interface.fixture.seventeen-capabilities", decide (initialStore.entries.length = 17))
]

/-- This global positive deliberately uses production receiptDelta on an invoked neutral
receipt. It avoids balanceSum/checkBindings. Its zero is preserved by M02–05 and M14. -/
def positiveTransfer : Bool := outcomeEq transfer (.ok expected100) &&
  resultHas transfer (fun r ↦ decide (receiptDelta pairRegion r.receipt = 0))

def regionChecks : List (String × Bool) := [
  ("interface.positive.transfer", positiveTransfer),
  ("interface.region.sum", decide (balanceSum pairRegion initial64.state = 10)),
  ("interface.region.empty", decide (balanceSum emptyRegion initial64.state = 0)),
  ("interface.region.duplicate-insertion", decide
    (balanceSum duplicateRegion initial64.state = 10 ∧ duplicateRegion.cells.card = 2)),
  ("interface.region.mixed-dimensions", !wellFormed mixedRegion && decide
    (balanceSum mixedRegion (world 5 0 0 0 0 0 5).state = 10)),
  ("interface.region.missing-initialization", resultHas transfer (fun r ↦
    decide (balanceSum pairRegion initial64.state = 10 ∧
      balanceSum pairRegion r.world.state = 10 ∧ receiptDelta pairRegion r.receipt = 0 ∧
      balanceSum pairRegion initial64.state ≠ 11 ∧ balanceSum pairRegion r.world.state ≠ 11))),
  ("interface.region.transfer-full", outcomeEq transfer (.ok expected100)),
  ("interface.region.transfer-total", resultHas transfer (fun r ↦
    decide (balanceSum pairRegion r.world.state = 10))),
  ("interface.region.neutral-delta", resultHas transfer (fun r ↦
    decide (receiptDelta pairRegion r.receipt = 0))),
  ("interface.region.transfer-out", resultHas transfer (fun r ↦
    decide (receiptDelta singleRegion r.receipt = -2))),
  ("interface.region.single-target-delta", resultHas transfer (fun r ↦
    decide (receiptCellEffect r.receipt alice = -2))),
  ("interface.region.transfer-effects", resultHas transfer (fun r ↦
    decide (receiptCellEffect r.receipt alice = -2 ∧ receiptCellEffect r.receipt bob = 2))),
  ("interface.region.singleton-total", resultHas transfer (fun r ↦
    decide (balanceSum singleRegion initial64.state = 6 ∧
      balanceSum singleRegion r.world.state = 4))),
  ("interface.region.transfer-supply", resultHas transfer (fun r ↦
    decide (r.receipt.supply .home .usd = 0))),
  ("interface.region.mint-full", outcomeEq minted (.ok expected101)),
  ("interface.region.mint", resultHas minted (fun r ↦
    decide (receiptDelta pairRegion r.receipt = 3))),
  ("interface.region.mint-total", resultHas minted (fun r ↦
    decide (balanceSum pairRegion r.world.state = 13 ∧ r.receipt.supply .home .usd = 3))),
  ("interface.region.repeated-full", outcomeEq repeatedRun (.ok expected104)),
  ("interface.region.repeated", resultHas repeatedRun (fun r ↦
    decide (receiptDelta singleRegion r.receipt = -3))),
  ("interface.region.repeated-total", resultHas repeatedRun (fun r ↦
    decide (balanceSum singleRegion r.world.state = 3))),
  ("interface.region.private-total-full", outcomeEq (execute op100 (world 6 4 0 10))
    (.ok ⟨world 4 6 0 10, receipt100, []⟩)),
  ("interface.region.private-total", resultHas (execute op100 (world 6 4 0 10)) (fun r ↦
    decide (balanceSum pairRegion r.world.state = 10 ∧ r.world.state.balance totalCell = 10))),
  ("interface.region.exposed-total-full", outcomeEq
    (execute op105 (world 6 4 0 10) exposedCfg) (.ok expected105)),
  ("interface.region.exposed-total-counterexample", resultHas
    (execute op105 (world 6 4 0 10) exposedCfg) (fun r ↦
      decide (balanceSum pairRegion r.world.state = 10 ∧
        r.world.state.balance totalCell = 11 ∧ receiptDelta pairRegion r.receipt = 0 ∧
        r.receipt.supply .home .usd = 1 ∧
        balanceSum pairRegion r.world.state ≠ r.world.state.balance totalCell)))
]

def unequal (index : Nat) (left right : QualifiedPort) (a b : ℚ) :
    Except (BindingFailure P A D) PUnit := .error (.unequal index left right a b)
def query (edges : List Binding) (entry : W) (config : Config P A D := cfg) :=
  checkBindings config edges entry.state
def queryEq (edges : List Binding) (entry : W)
    (expected : Except (BindingFailure P A D) PUnit) (config : Config P A D := cfg) : Bool :=
  decide (query edges entry config = expected)
def dimensionalWorld := world 5 0 0 0 5 5 5

def bindingChecks : List (String × Bool) := [
  ("interface.binding.paired-full", outcomeEq pairedRun (.ok expected102)),
  ("interface.binding.equal", resultHas pairedRun (fun r ↦
    queryEq equalEdge r.world (.ok ⟨⟩))),
  ("interface.binding.paired-effects", resultHas pairedRun (fun r ↦
    decide (receiptCellEffect r.receipt alice = -1 ∧ receiptCellEffect r.receipt bob = -1))),
  ("interface.binding.one-sided-full", outcomeEq oneSidedRun (.ok expected103)),
  ("interface.binding.unequal", resultHas oneSidedRun (fun r ↦
    queryEq equalEdge r.world (unequal 0 (name 0) (name 1) 4 5))),
  ("interface.binding.global-edge", queryEq [(name 0, name 2)] (world 4 5 5)
    (unequal 0 (name 0) (name 2) 4 5)),
  ("interface.binding.cut-extraction", decide (cutExtracted = [])),
  ("interface.binding.cut-omission-counterexample", queryEq cutExtracted (world 4 5 5) (.ok ⟨⟩) &&
    queryEq [(name 0, name 2)] (world 4 5 5) (unequal 0 (name 0) (name 2) 4 5)),
  ("interface.binding.existing-port", queryEq transitiveEdges (world 5 5 5) (.ok ⟨⟩)),
  ("interface.binding.transitive-redundant", queryEq redundantEdges (world 5 5 5) (.ok ⟨⟩)),
  ("interface.binding.distinct-closures", decide
    (symClosure transitiveEdges ≠ symClosure redundantEdges)),
  ("interface.binding.transitive-negative", queryEq equalEdge (world 4 5 5)
    (unequal 0 (name 0) (name 1) 4 5)),
  ("interface.binding.asset", queryEq [(name 0, name 3)] dimensionalWorld
    (.error (.assetMismatch 0 alice eurCell))),
  ("interface.binding.domain", queryEq [(name 0, name 4)] dimensionalWorld
    (.error (.domainMismatch 0 alice awayCell))),
  ("interface.binding.domain-before-asset", queryEq [(name 0, name 5)] dimensionalWorld
    (.error (.domainMismatch 0 alice awayEur))),
  ("interface.binding.dimension-amounts", decide
    (dimensionalWorld.state.balance alice = 5 ∧ dimensionalWorld.state.balance eurCell = 5 ∧
      dimensionalWorld.state.balance awayCell = 5 ∧ dimensionalWorld.state.balance awayEur = 5)),
  ("interface.binding.missing-port", queryEq [(name 0, name 0 99)] (world 4 5 5)
    (.error (.endpoint 0 .right (.missingPort (name 0 99))))),
  ("interface.binding.missing-component-left", queryEq [(name 99, name 0)] (world 4 5 5)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.missing-component-right", queryEq [(name 0, name 99)] (world 4 5 5)
    (.error (.endpoint 0 .right (.missingComponent (name 99))))),
  ("interface.binding.left-before-right", queryEq [(name 99, name 0 99)] (world 4 5 5)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.first-failure", queryEq [(name 0, name 1), (name 0, name 99)]
    (world 4 5 5) (unequal 0 (name 0) (name 1) 4 5)),
  ("interface.binding.later-index", queryEq [(name 0, name 0), (name 0, name 99)]
    (world 4 5 5) (.error (.endpoint 1 .right (.missingComponent (name 99))))),
  ("interface.binding.input-not-resource", decide
    (resolveExport cfg.catalog (name 0 11) = .error (.missingPort (name 0 11)))),
  ("interface.binding.output-not-resource", decide
    (resolveExport snapshotCfg.catalog (name 0 10) = .error (.missingPort (name 0 10)))),
  ("interface.binding.invalid-empty", queryEq [] (world 0 0) (.error .configuration) invalidCfg),
  ("interface.binding.invalid-nonempty", queryEq equalEdge (world 0 0)
    (.error .configuration) invalidCfg),
  ("interface.positive.empty-query", queryEq [] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.valid-empty", queryEq [] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.self-edge", queryEq [(name 0, name 0)] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.unresolved-self-edge", queryEq [(name 99, name 99)] (world 0 0)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.duplicate", queryEq (equalEdge ++ equalEdge) (world 5 5) (.ok ⟨⟩)),
  ("interface.binding.reverse", queryEq [(name 1, name 0)] (world 4 5)
    (unequal 0 (name 1) (name 0) 5 4)),
  ("interface.binding.import-source", decide (resolveExport cfg.catalog (name 0) = .ok alice)),
  ("interface.binding.import-after-write", resultHas transfer (fun r ↦
    match cfg.catalog.find? (fun c ↦ c.id = ⟨7⟩) with
    | none => false
    | some c => decide (c.imports = [⟨name 0, alice, true⟩]) &&
      decide (r.world.state.balance alice = 4) &&
      c.canWrite alice && decide (resolveExport cfg.catalog (name 0) = .ok alice))),
  ("interface.binding.hold-success", bindingsHold cfg equalEdge (world 5 5).state),
  ("interface.binding.hold-failure", !bindingsHold cfg equalEdge (world 4 5).state)
]

def groupChecks : List (String × Bool) := [
  ("interface.group.paired-entry", queryEq equalEdge initial55 (.ok ⟨⟩)),
  ("interface.group.paired-first", cursorEq groupFirst firstCursor),
  ("interface.group.paired-complete", cursorEq groupBoth secondCursor),
  ("interface.group.paired-first-binding", queryEq equalEdge groupFirst.world (.ok ⟨⟩)),
  ("interface.group.paired-complete-binding", queryEq equalEdge groupBoth.world (.ok ⟨⟩)),
  ("interface.group.refusal-suffix", cursorEq
    (Composition.run cfg boundary initial55 [.invoke op102, .invoke op106, .invoke op101])
    refusedCursor),
  ("interface.group.refusal-total", decide (balanceSum tripleRegion
    (Composition.run cfg boundary initial55
      [.invoke op102, .invoke op106, .invoke op101]).world.state
      = 10)),
  ("interface.group.snapshot-first", cursorEq snapshotFirstRun snapshotPrefix),
  ("interface.group.snapshot-complete", cursorEq snapshotRun snapshotFinal),
  ("interface.group.snapshot-total",
    decide (balanceSum pairRegion snapshotRun.world.state = 10)),
  ("interface.group.snapshot-new-receipts",
    decide
    ((snapshotRun.events.drop arbitraryEntry.events.length).map (fun e ↦ e.result.receipt) =
      [receipt100, receipt107])),
  ("interface.group.snapshot-flow", decide
    (((snapshotRun.events.drop arbitraryEntry.events.length).map
      (fun e ↦ receiptDelta pairRegion e.result.receipt)).sum = 0)),
  ("interface.group.snapshot-not-binding",
    !bindingsHold snapshotCfg equalEdge snapshotRun.world.state)
]

def schedule17 : Interleaving.Schedule := [.left, .right, .left]
def schedule19 : Interleaving.Schedule := [.left, .left, .right]
def schedule20 : Interleaving.Schedule := [.left, .left, .left, .right]
def shared (schedule : Interleaving.Schedule) (suffix : Bool := false) :=
  Interleaving.runInterleaving cfg sharedBoundary initial55
    ([op102, op106] ++ if suffix then [op101] else []) [op102] schedule
def sharedPrefix (schedule : Interleaving.Schedule) (suffix : Bool := false) :=
  Interleaving.runPrefix cfg sharedBoundary initial55
    ([op102, op106] ++ if suffix then [op101] else []) [op102] schedule

def sharedReceipts (m : Interleaving.Machine P A D) : List (Receipt P A D) :=
  m.attempts.filterMap (fun a ↦ match a.outcome with | .ok r => some r.receipt | .error _ => none)
def sharedChecks : List (String × Bool) := [
  ("interface.shared.refusal-last", sharedEq (shared schedule17) schedule17 expectedF17),
  ("interface.shared.peer-after-refusal", sharedEq (shared schedule19) schedule19 expectedF19),
  ("interface.shared.failed-suffix-skipped",
    sharedEq (shared schedule20 true) schedule20 expectedF20),
  ("interface.shared.first-prefix", machineEq (sharedPrefix [.left]) expectedSharedFirst),
  ("interface.shared.refused-prefix",
    machineEq (sharedPrefix [.left, .left]) expectedSharedRefused),
  ("interface.shared.skipped-prefix", machineEq (sharedPrefix [.left, .left, .left] true)
    expectedSharedSkipped),
  ("interface.shared.receipts", decide (sharedReceipts (sharedPrefix schedule19) =
    [receipt102, receipt102])),
  ("interface.shared.receipt-flow", decide (((sharedReceipts (sharedPrefix schedule20 true)).map
    (receiptDelta tripleRegion)).sum = 0)),
  ("interface.shared.no-mint-supply", decide
    ((sharedPrefix schedule20 true).supply .home .usd = 0)),
  ("interface.shared.all-prefix-totals", (List.range 5).all (fun n ↦
    decide (balanceSum tripleRegion (sharedPrefix (schedule20.take n) true).world.state = 10))),
  ("interface.shared.all-prefix-bindings", (List.range 5).all (fun n ↦
    bindingsHold cfg equalEdge (sharedPrefix (schedule20.take n) true).world.state))
]

def actualIssue := executeStep cfg (adminBoundary 0) 0 [] (.issue grant) initial64
def actualRevoke := executeStep cfg (adminBoundary 1) 1 [] (.revoke ⟨17⟩) issuedWorld
def adminChecks : List (String × Bool) := [
  ("interface.admin.issue-full", outcomeEq actualIssue (.ok issuedResult)),
  ("interface.admin.revoke-full", outcomeEq actualRevoke (.ok revokedResult)),
  ("interface.admin.issued-delta", resultHas actualIssue (fun r ↦
    decide (receiptDelta singleRegion r.receipt = 0))),
  ("interface.admin.revoked-delta", resultHas actualRevoke (fun r ↦
    decide (receiptDelta singleRegion r.receipt = 0))),
  ("interface.admin.complete-cursor", cursorEq
    (Composition.run cfg adminBoundary initial64 [.issue grant, .revoke ⟨17⟩]) adminFinal),
  ("interface.admin.unauthorized", outcomeEq
    (executeStep cfg (boundary 0) 0 [] (.issue grant) initial64)
    (.error (.authority .unauthorizedAdmin))),
  ("interface.admin.unauthorized-cursor", cursorEq
    (Composition.run cfg boundary initial64 [.issue grant])
    ⟨initial64, [], [], 0, some ⟨0, some (.issue grant), .authority .unauthorizedAdmin⟩⟩),
  ("interface.admin.balance", resultHas actualRevoke (fun r ↦
    decide (balanceSum singleRegion r.world.state = 6)))
]

def runtimeChecks : List (String × Bool) := catalogChecks ++ regionChecks ++ bindingChecks ++
  groupChecks ++ sharedChecks ++ adminChecks


end DefiKernel.Interface.Tests


namespace DefiKernel.Interface.Audit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Interface runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Interface runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Interface runtime comparisons failed: {failures.length}")

#eval main


end DefiKernel.Interface.Audit
