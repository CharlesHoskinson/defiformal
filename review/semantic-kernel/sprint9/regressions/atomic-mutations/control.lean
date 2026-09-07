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


end DefiKernel.Atomic


/-! A single atomic publication boundary around actual interleaving steps. Diagnostic
receipts describe speculation; only a committed result publishes them. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | policy (failure : PolicyFailure P A D)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq

inductive AbortReason (P A D : Type) where
  | kernel (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (reason : Composition.Failure)
  | laneSupply (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (lane : Lane P A D) (amount : ℚ)
  | unsettled (residual : List (Residual P A D))
  deriving DecidableEq

structure Machine (P A D : Type) where
  entryWorld : World P A D
  speculative : Interleaving.Machine P A D
  outstanding : Outstanding P A D
  position : Nat := 0
  abort : Option (AbortReason P A D) := none

inductive Result (P A D : Type) where
  | refused (label : Nat) (schedule : Schedule) (reason : AdmissionFailure P A D)
      (entry : World P A D)
  | aborted (label : Nat) (schedule : Schedule) (reason : AbortReason P A D)
      (machine : Machine P A D)
  | committed (label : Nat) (schedule : Schedule) (machine : Machine P A D)

structure InnerObservation (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

/-- One event is published even when the admitted atomic request contains no calls. -/
structure EventObservation (P A D : Type) where
  label : Nat
  schedule : Schedule
  inner : List (InnerObservation P A D)
  deriving DecidableEq

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkPolicy policy boundaries left right).mapError .policy
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

def start (initial : World P A D) : Machine P A D :=
  ⟨initial, Interleaving.start initial, zeroOutstanding, 0, none⟩

def observeAttempt (attempt : Attempt P A D) : Option (InnerObservation P A D) :=
  match attempt.outcome with
  | .error _ => none
  | .ok result => some ⟨attempt.branch, attempt.index, attempt.invocation,
      result.receipt, result.outputs⟩

def diagnosticEvent (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    EventObservation P A D :=
  ⟨label, schedule, m.speculative.attempts.filterMap observeAttempt⟩

def Result.publicWorld : Result P A D → World P A D
  | .refused _ _ _ entry => entry
  | .aborted _ _ _ m => m.entryWorld
  | .committed _ _ m => m.speculative.world

/-- This production accessor is consumed by the public projection. -/
def committedHistory : Result P A D → List (EventObservation P A D)
  | .refused _ _ _ _ => []
  | .aborted _ _ _ _ => []
  | .committed label schedule m => [diagnosticEvent label schedule m]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Supply is the actual committed receipt sum, never the tentative aborted sum. -/
def committedSupply : Result P A D → D → A → ℚ
  | .refused _ _ _ _ => fun _ _ => 0
  | .aborted _ _ _ _ => fun _ _ => 0
  | .committed _ _ m => m.speculative.supply

def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) : Machine P A D :=
  match m.abort with
  | some _ => m
  | none =>
    let next := Interleaving.advance cfg boundaries left right m.speculative branch
    let running := { m with speculative := next, position := m.position + 1 }
    match next.attempts[m.speculative.attempts.length]? with
    | none => running
    | some attempt =>
      match attempt.outcome with
      | .error reason =>
        { running with abort := some (.kernel attempt.branch attempt.index m.position
            attempt.invocation reason) }
      | .ok result =>
        let owed := updateOutstanding policy m.outstanding
          (boundaries attempt.branch attempt.index).ctx.principal result.receipt
        let accepted := { running with outstanding := owed }
        match checkSupply policy result.receipt with
        | none => accepted
        | some (lane, amount) =>
          { accepted with abort := some (.laneSupply attempt.branch attempt.index m.position
              attempt.invocation lane amount) }

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries policy left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries policy left right (start initial) schedule

def finish (label : Nat) (schedule : Schedule) (policy : Policy P A D)
    (m : Machine P A D) : Result P A D :=
  match m.abort with
  | some reason => .aborted label schedule reason m
  | none =>
    match residuals policy m.outstanding with
    | [] => .committed label schedule m
    | remaining => .aborted label schedule (.unsettled remaining) m

def runAtomic (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) : Result P A D :=
  match Atomic.admit cfg boundaries policy left right schedule with
  | .error reason => .refused label schedule reason initial
  | .ok _ => finish label schedule policy
      (runPrefix cfg boundaries policy initial left right schedule)


end DefiKernel.Atomic


/-! Public equality retains the atomic event label, schedule, exact refusal, full
world and every committed receipt/output/supply field. Diagnostics are separate. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive Outcome (P A D : Type) where
  | refused (reason : AdmissionFailure P A D)
  | aborted (reason : AbortReason P A D)
  | committed
  deriving DecidableEq

structure Observation (P A D : Type) where
  label : Nat
  schedule : Schedule
  outcome : Outcome P A D
  world : World P A D
  events : List (EventObservation P A D)
  supply : D → A → ℚ

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def observe (result : Result P A D) : Observation P A D :=
  let (label, schedule, outcome) := match result with
    | .refused label schedule reason _ => (label, schedule, Outcome.refused reason)
    | .aborted label schedule reason _ => (label, schedule, Outcome.aborted reason)
    | .committed label schedule _ => (label, schedule, Outcome.committed)
  ⟨label, schedule, outcome, result.publicWorld,
    committedHistory result, committedSupply result⟩

def Observation.Equivalent (left right : Observation P A D) : Prop :=
  left.label = right.label ∧ left.schedule = right.schedule ∧
    left.outcome = right.outcome ∧ WorldEquivalent left.world right.world ∧
    left.events = right.events ∧ ∀ d a, left.supply d a = right.supply d a

def observationEq (left right : Observation P A D) : Bool :=
  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&
    decide (left.outcome = right.outcome) && worldEq left.world right.world &&
    decide (left.events = right.events) && decide (∀ d a, left.supply d a = right.supply d a)

def observationsEqual (left right : Result P A D) : Bool :=
  observationEq (observe left) (observe right)


end DefiKernel.Atomic


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


/-! Independent financial fixtures for binary parallel composition. Expected receipts and complete
ledger tables are written directly, without evaluating templates or selecting executor results. -/
namespace DefiKernel.Parallel.Examples
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev I := Invocation Party Asset Domain
abbrev B := Branch Party Asset Domain
abbrev Evt := EventObservation Party Asset Domain
abbrev Obs := BranchObservation Party Asset Domain
abbrev R := Parallel.Result Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultUSD : C := (.main, .vault, .usd)
def poolUSD : C := (.main, .pool, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def protectedCell : C := (.main, .alice, .collateral)
def cells : List C := [Domain.main, .other].flatMap fun d ↦
  [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩

/-- Both numerical ports are zero, but their components differ. The provider grants exact
access to every cell so access checks cannot mask the intended compatibility controls. -/
def config (lt rt : Op) (lo ro : List C := []) : Config Party Asset Domain where
  registry id := if id = ⟨10⟩ then some lt else if id = ⟨11⟩ then some rt else none
  domainAdmin := domainAdmin
  catalog := [
    ⟨⟨0⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨10⟩, lt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        lo.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨1⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨11⟩, rt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        ro.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨2⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

def transferTemplate (a : Asset) (sender recipient : PartyRef Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, ref a sender, negate a (.arg .here)⟩,
    ⟨a, ref a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a sender, packedRef a recipient]
def usdTransfer := transferTemplate .usd (.literal .alice) (.literal .bob)
def shareTransfer := transferTemplate .share (.literal .vault) (.literal .alice)
def peerUSDTransfer := transferTemplate .usd (.literal .vault) (.literal .pool)
def cfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def sameAssetCfg := config usdTransfer peerUSDTransfer [bobUSD] [poolUSD]

def store : Store := ⟨[
  ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .debit bobUSD⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit vaultUSD⟩, true⟩]⟩
def caps : List CapabilityId := (List.range 12).map CapabilityId.mk

def balanceTable (au bu vs ash : ℚ) (vu : ℚ := 20) (pu : ℚ := 1) : C → ℚ := fun c ↦
  if c = aliceUSD then au else if c = bobUSD then bu else if c = vaultShare then vs
  else if c = aliceShare then ash else if c = vaultUSD then vu else if c = poolUSD then pu
  else if c = protectedCell then 9 else 0

def initial : W := ⟨⟨balanceTable 10 0 20 0, by
  intro c
  simp only [balanceTable]
  repeat' split
  all_goals decide⟩, store⟩
def boundaries (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩

def invoke (component op : Nat) (a : Asset) (q : ℚ) : I :=
  ⟨⟨component⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], caps, none⟩
def usd (q : ℚ) := invoke 0 10 .usd q
def shares (q : ℚ) := invoke 1 11 .share q
def peerUSD (q : ℚ) := invoke 1 11 .usd q

def source (inv : I) (component : Nat) : I :=
  { inv with inputs := [.priorOutput 0 ⟨⟨component⟩, ⟨0⟩⟩] }

def output (index component : Nat) (a : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨0⟩⟩, ⟨.amount a, q⟩⟩

def evaluatedTransfer (sender recipient : C) (q : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [(sender, -q), (recipient, q)], [], [], [], [], [], [sender, recipient]⟩
def event (index : Nat) (inv : I) (args : List (PackedValue Asset))
    (evaluated : Evaluated Party Asset Domain) (outputs : List (OutputObservation Asset)) : Evt :=
  ⟨index, .invoke inv,
    .invoked ⟨inv.operation, inv.parties, args, inv.capabilityIds, inv.claimedActor⟩ evaluated,
    outputs⟩
def transferEvent (index : Nat) (inv : I) (sender recipient : C) (q : ℚ)
    (outputs : List (OutputObservation Asset)) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩] (evaluatedTransfer sender recipient q) outputs

def observed (events : List Evt)
    (failure : Option (LocatedFailure Party Asset Domain) := none) : Obs :=
  ⟨events, events.flatMap EventObservation.outputs, events.length, failure⟩
def failure (index : Nat) (inv : I) (reason : Composition.Failure) :
    Option (LocatedFailure Party Asset Domain) := some ⟨index, some (.invoke inv), reason⟩
def leftEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (usd q) aliceUSD bobUSD q [output index 0 .usd after]
def rightEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (shares q) vaultShare aliceShare q [output index 1 .share after]
def peerEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (peerUSD q) vaultUSD poolUSD q [output index 1 .usd after]

def matchesExpected (actual : R) (balance : C → ℚ) (expectedLeft expectedRight : Obs)
    (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed result =>
    decide ((∀ c, result.world.state.balance c = balance c) ∧
      result.world.capabilities = expectedStore ∧
      result.left.world.capabilities = expectedStore ∧
      result.right.world.capabilities = expectedStore ∧
      observeBranch result.left = expectedLeft ∧ observeBranch result.right = expectedRight)

def basicLeft : Obs := observed [leftEvent 0 3 3]
def basicRight : Obs := observed [rightEvent 0 4 4]

def supplyTemplate (a : Asset) (owner : Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal owner), .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal owner)]
def supplyCfg := config (supplyTemplate .usd .alice) (supplyTemplate .share .vault)
  [aliceUSD] [vaultShare]
def supplyEvent (index : Nat) (inv : I) (cell : C) (q post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, q⟩]
    ⟨true, [(cell, q)], [((cell.1, cell.2.2), q)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]

def statefulTransfer : Op := { usdTransfer with
  guard := .binary (.le (.amount .usd)) (.lit 4) (.balance (cellRef aliceUSD))
  deltas := [⟨.usd, cellRef aliceUSD, .binary (.scale (.amount Asset.usd))
    (.lit (-1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩,
    ⟨.usd, cellRef bobUSD, .binary (.scale (.amount Asset.usd))
      (.lit (1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def statefulCfg := config statefulTransfer shareTransfer [bobUSD] [aliceShare]
def statefulEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (usd 0) [⟨.amount .usd, 0⟩]
    { evaluatedTransfer aliceUSD bobUSD amount with
      requiredStateReads := [aliceUSD, aliceUSD, aliceUSD]
      declaredStateReads := [aliceUSD] }
    [output index 0 .usd post]

/-- State-dependent mint amount appears independently in both delta and supply evaluation. -/
def statefulSupply : Op := { supplyTemplate .share .vault with
  deltas := [⟨.share, cellRef vaultShare,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  supplyDeltas := [⟨.main, .share,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  stateReads := [packed vaultShare] }
def statefulSupplyEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (shares 0) [⟨.amount .share, 0⟩]
    ⟨true, [(vaultShare, amount)], [((.main, .share), amount)],
      [vaultShare, vaultShare], [], [vaultShare], [], [vaultShare]⟩
    [output index 1 .share post]

/-- Temporal values constrain the trusted invocation boundary; they do not set a price. -/
def timedTemplate (a : Asset) : Op where
  signature := [.amount a, .scalar]
  domain := .main
  partyArity := 1
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨a, ref a .caller, negate a (.arg .here)⟩,
    ⟨a, ref a (.argument 0), .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedRef a .caller, packedRef a (.argument 0)]
def timedCfg := config (timedTemplate .usd) (timedTemplate .share) [bobUSD] [aliceShare]
def timedBoundaries (branch : BranchId) (index : Nat) : Boundary Party Asset Domain :=
  match branch with
  | .left => ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100 + index⟩
  | .right => ⟨⟨.vault, .main⟩, fresh, 200 + index⟩
def timedInvocation (component op : Nat) (a : Asset) (q time : ℚ) (recipient : Party) : I :=
  ⟨⟨component⟩, ⟨op⟩, [recipient],
    [.literal ⟨.amount a, q⟩, .literal ⟨.scalar, time⟩], caps, none⟩
def timedLeft : B := [timedInvocation 0 10 .usd 3 100 .bob,
  timedInvocation 0 10 .usd 1 101 .alice]
def timedRight : B := [timedInvocation 1 11 .share 4 200 .alice,
  timedInvocation 1 11 .share 2 201 .alice]
def timedEvent (index : Nat) (inv : I) (sender recipient : C) (q time post : ℚ) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩, ⟨.scalar, time⟩]
    { evaluatedTransfer sender recipient q with
      requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] }
    [output index inv.component.value sender.2.2 post]
def timedExpectedLeft := observed [
  timedEvent 0 (timedInvocation 0 10 .usd 3 100 .bob) aliceUSD bobUSD 3 100 3,
  timedEvent 1 (timedInvocation 0 10 .usd 1 101 .alice) bobUSD aliceUSD 1 101 2]
def timedExpectedRight := observed [
  timedEvent 0 (timedInvocation 1 11 .share 4 200 .alice) vaultShare aliceShare 4 200 4,
  timedEvent 1 (timedInvocation 1 11 .share 2 201 .alice) vaultShare aliceShare 2 201 6]


def noOp : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []
def noOpInvocation : I := { usd 0 with inputs := [] }
def noOpEvaluated : Evaluated Party Asset Domain := ⟨true, [], [], [], [], [], [], []⟩
def sharedReadCfg := config noOp noOp [protectedCell] []
def sharedReadExpected := observed [event 0 noOpInvocation [] noOpEvaluated
  [output 0 0 .collateral 9]]
def paramTemplate : Op := { transferTemplate .usd (.argument 0) (.argument 1) with
  partyArity := 2 }
def reusableCfg := config paramTemplate shareTransfer

def revokedStore : Store := ⟨store.entries.set 2 ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, false⟩⟩
def revokedInitial : W := ⟨initial.state, revokedStore⟩

def cancelling : Op := { noOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 1⟩, ⟨.usd, cellRef aliceUSD, .lit (-1)⟩] }
def cancellingInvocation : I := { shares 0 with inputs := [] }
def cancellingExpected : Obs := observed [event 0 cancellingInvocation []
  ⟨true, [(aliceUSD, 1), (aliceUSD, -1)], [], [], [], [], [], []⟩ []]

end DefiKernel.Parallel.Examples


/-! Independent exact-rational Atomic fixture data. Expected worlds, receipts and outputs never
select an Atomic or Interleaving execution result. These are development examples, not fidelity. -/
namespace DefiKernel.Atomic.Examples
open Typed Composition Parallel Typed.Examples
open Parallel.Examples (C W I B Evt Obs cells cellRef packed output event transferEvent observed)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain

def usdVault : C := (.main, .vault, .usd)
def usdAlice : C := (.main, .alice, .usd)
def usdBob : C := (.main, .bob, .usd)
def shareVault : C := (.main, .vault, .share)
def shareAlice : C := (.main, .alice, .share)
def otherVault : C := (.other, .vault, .usd)
def otherAlice : C := (.other, .alice, .usd)
def collateral : C := (.main, .alice, .collateral)
def refAt (d : D) (a : A) (p : PartyRef P) : CellRef P A D a := ⟨d, p⟩
def packedAt (d : D) (a : A) (p : PartyRef P) : PackedCellRef P A D := ⟨a, refAt d a p⟩

def transferAt (d : D) (a : A) (sender recipient : PartyRef P) : Op where
  signature := [.amount a]
  domain := d
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, refAt d a sender, negate a (.arg .here)⟩,
    ⟨a, refAt d a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedAt d a sender, packedAt d a recipient]

def drawTemplate := transferAt .main .usd (.literal .vault) .caller
def repayTemplate := transferAt .main .usd .caller (.literal .vault)
def drawShareTemplate := transferAt .main .share (.literal .vault) .caller
def repayShareTemplate := transferAt .main .share .caller (.literal .vault)
def drawOtherTemplate := transferAt .other .usd (.literal .vault) .caller
def repayOtherTemplate := transferAt .other .usd .caller (.literal .vault)
def noopTemplate : Op := { drawTemplate with deltas := [], writes := [] }
def repeatedTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.add (.amount Asset.usd)) (.arg .here) (.arg .here)⟩] }
def mintAt (a : A) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, refAt .main a .caller, .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main a .caller]
def timedDrawTemplate : Op where
  signature := [.amount .usd, .scalar]
  domain := .main
  partyArity := 0
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedAt .main .usd (.literal .vault), packedAt .main .usd .caller]
def liveDrawTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, cellRef usdVault,
    .binary (.scale (.amount Asset.usd)) (.lit (-1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.scale (.amount Asset.usd)) (.lit (1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩]
  stateReads := [packed usdVault] }

structure FixtureOp where
  id : Nat
  template : Op
  output : C

def operations : List FixtureOp := [
  ⟨100, drawTemplate, usdVault⟩, ⟨101, repayTemplate, usdVault⟩,
  ⟨102, drawShareTemplate, shareVault⟩, ⟨103, repayShareTemplate, shareVault⟩,
  ⟨104, drawOtherTemplate, otherVault⟩, ⟨105, repayOtherTemplate, otherVault⟩,
  ⟨106, noopTemplate, usdVault⟩, ⟨107, repeatedTemplate, usdVault⟩,
  ⟨108, mintAt .usd, usdAlice⟩, ⟨109, mintAt .share, shareAlice⟩,
  ⟨110, timedDrawTemplate, usdVault⟩, ⟨111, liveDrawTemplate, usdVault⟩]

def fixtureComponent (op : FixtureOp) : Component P A D :=
  ⟨⟨op.id⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨999⟩, ⟨n⟩⟩, c, true⟩),
    [⟨⟨op.id⟩, op.template.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨10 + n⟩, u⟩),
      [⟨⟨0⟩, op.output⟩]⟩]⟩
def atomCfg : Config P A D where
  registry id := (operations.find? (fun op ↦ id = ⟨op.id⟩)).map FixtureOp.template
  domainAdmin := domainAdmin
  catalog := operations.map fixtureComponent ++
    [⟨⟨999⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

/-- Exact grants for funded Alice/Bob controls. First entry authorizes Alice's USD draw. -/
def atomStore : Store := ⟨operations.flatMap fun op ↦
  [Party.alice, .bob].flatMap fun actor ↦
    ([Right.invoke, .debit (op.template.domain, .alice, op.output.2.2),
      .debit (op.template.domain, .bob, op.output.2.2),
      .debit (op.template.domain, .vault, op.output.2.2),
      .changeSupply op.template.domain op.output.2.2]).map fun right ↦
        ⟨⟨actor, op.template.domain, ⟨op.id⟩, right⟩, true⟩⟩
def atomCaps : List CapabilityId := (List.range 120).map CapabilityId.mk
def revokedStore : Store := ⟨atomStore.entries.set 0
  ⟨⟨.alice, .main, ⟨100⟩, .invoke⟩, false⟩⟩

/-- Complete tables retain protected collateral9 and set every unlisted cell to zero. -/
def balanceTable (alice bob vault ash vsh oa ov : ℚ) : C → ℚ := fun c ↦
  if c = usdAlice then alice else if c = usdBob then bob else if c = usdVault then vault
  else if c = shareAlice then ash else if c = shareVault then vsh
  else if c = otherAlice then oa else if c = otherVault then ov
  else if c = collateral then 9 else 0

def atomWorld (alice bob vault ash vsh oa ov : Nat) (store : Store := atomStore) : W :=
  ⟨⟨balanceTable alice bob vault ash vsh oa ov, by
    intro c
    simp only [balanceTable]
    repeat' split
    all_goals positivity⟩, store⟩
def atomInitial := atomWorld 1 7 10 8 10 8 10
def afterDraw := atomWorld 8 7 3 8 10 8 10
def afterUnder := atomWorld 2 7 9 8 10 8 10
def afterOver := atomWorld 0 7 11 8 10 8 10
def afterPeerReturn := atomWorld 8 0 10 8 10 8 10
def afterAssetReturn := atomWorld 8 7 3 1 17 8 10
def afterDomainReturn := atomWorld 8 7 3 8 10 1 17
def afterLastLane := atomWorld 1 7 10 9 9 8 10
def afterLastParticipant := atomWorld 1 14 3 8 10 8 10
def afterLaneMint := atomWorld 4 7 10 8 10 8 10
def afterNonlaneMint := atomWorld 1 7 10 11 10 8 10
def afterDrawNonlaneMint := atomWorld 8 7 3 11 10 8 10
def revokedInitial := atomWorld 1 7 10 8 10 8 10 revokedStore

def atomBoundary (_ : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, .main⟩, fresh, 100⟩
def peerBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨if branch = .left then .alice else .bob, .main⟩, fresh, 100⟩
def otherBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, if branch = .left then .main else .other⟩, fresh, 100⟩
def localBoundary (branch : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if branch = .right then .bob else .alice, .main⟩, fresh,
    (if branch = .left then 100 else 200) + index⟩

def invocation (op : Nat) (a : A) (q : ℚ) : I :=
  ⟨⟨op⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], atomCaps, none⟩
def draw (q : ℚ) := invocation 100 .usd q
def repay (q : ℚ) := invocation 101 .usd q
def drawShare (q : ℚ) := invocation 102 .share q
def repayShare (q : ℚ) := invocation 103 .share q
def drawOther (q : ℚ) := invocation 104 .usd q
def repayOther (q : ℚ) := invocation 105 .usd q
def noop := invocation 106 .usd 0
def repeatedDraw := invocation 107 .usd (7 / 2)
def mintUSD := invocation 108 .usd 3
def mintShare := invocation 109 .share 3
def timedDraw (q time : ℚ) : I :=
  ⟨⟨110⟩, ⟨110⟩, [], [.literal ⟨.amount .usd, q⟩, .literal ⟨.scalar, time⟩], atomCaps, none⟩
def liveDraw := invocation 111 .usd 0

def drawReturnLeft : B := [draw 7, repay 7]
def underLeft : B := [draw 7, repay 6]
def overLeft : B := [draw 7, repay 8]
def creditLeft : B := [draw 7, repay 8, draw 1]
def noOpLeft : B := [draw 7, noop]
def nonlaneLeft : B := [draw 7, mintShare, repay 7]

def expectedTransfer (index : Nat) (inv : I) (sender recipient : C) (q cash : ℚ) : Evt :=
  transferEvent index inv sender recipient q [output index inv.component.value sender.2.2 cash]
def drawEvent (index : Nat := 0) (actor : P := .alice) : Evt :=
  expectedTransfer index (draw 7) usdVault (.main, actor, .usd) 7 3
def repayEvent (index : Nat) (q cash : ℚ) (actor : P := .alice) : Evt :=
  expectedTransfer index (repay q) (.main, actor, .usd) usdVault q cash
def drawReturnEvents : List Evt := [drawEvent, repayEvent 1 7 10]
def underEvents : List Evt := [drawEvent, repayEvent 1 6 9]
def overEvents : List Evt := [drawEvent, repayEvent 1 8 11]
def creditEvents : List Evt := overEvents ++
  [expectedTransfer 2 (draw 1) usdVault usdAlice 1 10]
def peerReturnEvents : List Evt := [drawEvent, repayEvent 0 7 10 .bob]
def assetReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17]
def domainReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17]
def lastLaneEvents : List Evt := [expectedTransfer 0 (drawShare 1) shareVault shareAlice 1 9]
def lastParticipantEvents : List Evt := [drawEvent 0 .bob]
def noOpEvent : Evt := event 1 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 1 106 .usd 3]
def repeatedEvent : Evt := event 0 repeatedDraw [⟨.amount .usd, 7 / 2⟩]
  ⟨true, [(usdVault, -7 / 2), (usdVault, -7 / 2), (usdAlice, 7)],
    [], [], [], [], [], [usdVault, usdAlice]⟩ [output 0 107 .usd 3]
def mintEvent (index : Nat) (inv : I) (cell : C) (amount post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, amount⟩]
    ⟨true, [(cell, amount)], [((cell.1, cell.2.2), amount)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]
def laneMintEvent := mintEvent 0 mintUSD usdAlice 3 4
def nonlaneMintEvent := mintEvent 1 mintShare shareAlice 3 11
def nonlaneEvents : List Evt := [drawEvent, nonlaneMintEvent, repayEvent 2 7 10]


def usdLane : Lane P A D := ⟨.main, .usd, .vault⟩
def shareLane : Lane P A D := ⟨.main, .share, .vault⟩
def otherLane : Lane P A D := ⟨.other, .usd, .vault⟩
def basePolicy : Policy P A D := ⟨[usdLane], [.alice]⟩
def multiLanePolicy : Policy P A D := ⟨[usdLane, shareLane], [.alice]⟩
def domainPolicy : Policy P A D := ⟨[usdLane, otherLane], [.alice]⟩
def multiParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob]⟩
def batchPolicy : Policy P A D := ⟨[], [.alice, .bob]⟩
def duplicateLanePolicy : Policy P A D := ⟨[usdLane, ⟨.main, .usd, .pool⟩], [.alice]⟩
def duplicateParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob, .alice]⟩

def drawResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩]
def underResiduals : List (Residual P A D) := [⟨usdLane, .alice, 1⟩]
def overResiduals : List (Residual P A D) := [⟨usdLane, .alice, -1⟩]
def peerResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]
def assetResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨shareLane, .alice, -7⟩]
def domainResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨otherLane, .alice, -7⟩]
def lastLaneResiduals : List (Residual P A D) := [⟨shareLane, .alice, 1⟩]
def lastParticipantResiduals : List (Residual P A D) := [⟨usdLane, .bob, 7⟩]

/-- A direct finite expected table, independent of production update and residual enumeration. -/
def expectedOutstanding (entries : List (Residual P A D)) : Outstanding P A D :=
  fun lane principal ↦ match entries.find? (fun entry ↦
      decide (entry.lane = lane ∧ entry.principal = principal)) with
    | some entry => entry.amount
    | none => 0


end DefiKernel.Atomic.Examples


/-! Exact rational development fixtures. Expected ledgers, receipts and outputs are direct tables;
none is extracted from `runInterleaving`. These fixtures make no deployed-protocol fidelity claim.
-/
namespace DefiKernel.Interleaving.Examples
open Typed Composition Parallel Typed.Examples Parallel.Examples

abbrev R := Interleaving.Result Party Asset Domain
abbrev M := Machine Party Asset Domain

def matchesExpected (actual : R) (balance : C → ℚ) (left right : Obs)
    (consumedLeft consumedRight : Nat) (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => decide ((∀ c, m.world.state.balance c = balance c) ∧
      m.world.capabilities = expectedStore ∧ m.left.observe = left ∧ m.right.observe = right ∧
      m.left.consumed = consumedLeft ∧ m.right.consumed = consumedRight)

def admissionRefused (actual : R) (reason : Interleaving.AdmissionFailure Party Asset Domain)
    (schedule : Schedule) (expected : W := initial) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && worldEq w expected
  | .executed _ _ => false

def sharedBalance (alice bob vault : ℚ) : C → ℚ := fun c ↦
  if c = aliceUSD then alice else if c = bobUSD then bob else if c = vaultUSD then vault
  else if c = protectedCell then 9 else 0

def sharedInitial : W := ⟨⟨sharedBalance 0 0 10, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def sharedCfg := config (transferTemplate .usd (.literal .vault) (.literal .alice))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [aliceUSD] [bobUSD]
def sharedLeft : B := [usd 7]
def sharedRight : B := [peerUSD 6]
def sharedLR := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.left, .right]
def sharedRL := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.right, .left]
def withdrawalLeft := observed [transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7]]
def withdrawalRight := observed
  [transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6]]

def replenishInitial : W := ⟨⟨sharedBalance 10 0 0, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def replenishCfg := config (transferTemplate .usd (.literal .alice) (.literal .vault))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [vaultUSD] [bobUSD]
def depositExpected := observed [transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7]]
def replenishLR := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.left, .right, .right]
def replenishRL := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.right, .left, .right]

/-- Both branches invoke component 0, so the fully qualified output key is identical. -/
def snapshotCfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def snapshotConsumer := source (usd 0) 0
def snapshotRun := runInterleaving snapshotCfg boundaries initial
  [usd 3, snapshotConsumer] [usd 1] [.left, .right, .left]
def snapshotLeft := observed [leftEvent 0 3 3,
  transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 7]]
def snapshotRight := observed [leftEvent 0 1 4]

/-- The peer transfers four dollars into Alice's balance between the two live reads. -/
def liveCfg := config statefulTransfer
  (transferTemplate .usd (.literal .vault) (.literal .alice)) [bobUSD] [aliceUSD]
def liveRun := runInterleaving liveCfg boundaries initial [usd 0, usd 0] [peerUSD 4]
  [.left, .right, .left]
def liveLeft := observed [statefulEvent 0 5 5, statefulEvent 1 (9 / 2) (19 / 2)]
def liveRight := observed [transferEvent 0 (peerUSD 4) vaultUSD aliceUSD 4 [output 0 1 .usd 9]]

def peerOnly := source (usd 0) 1
def peerOnlyRun := runInterleaving sameAssetCfg boundaries initial [usd 3, peerOnly]
  [peerUSD 4] [.left, .right, .left]
def peerOnlyLeft := observed [leftEvent 0 3 3]
  (failure 1 peerOnly (.interface .unavailableOutput))
def peerOnlyRight := observed [peerEvent 0 4 5]

def immediateRun := runInterleaving cfg boundaries initial [usd 11, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right]
def middleRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right, .left]
def dualRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 17, shares 1] [.left, .right, .left, .right, .left, .right]
def middleLeft := observed [leftEvent 0 3 3]
  (failure 1 (usd 8) (.kernel .insufficientFunds))
def continuedRight := observed [rightEvent 0 4 4, rightEvent 1 2 6]

def supplyRun := runInterleaving supplyCfg boundaries initial [usd 2, usd (-13), usd 1]
  [shares (-3)] [.left, .right, .left, .left]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
  (failure 1 (usd (-13)) (.kernel .insufficientFunds))
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]

def schedules : List (String × Schedule) := [
  ("llrr", [.left, .left, .right, .right]), ("lrlr", [.left, .right, .left, .right]),
  ("lrrl", [.left, .right, .right, .left]), ("rllr", [.right, .left, .left, .right]),
  ("rlrl", [.right, .left, .right, .left]), ("rrll", [.right, .right, .left, .left])]
def disjointLeft : B := [usd 3, usd 2]
def disjointRight : B := [shares 4, shares 2]
def disjointLeftExpected := observed [leftEvent 0 3 3, leftEvent 1 2 5]

/-- Directly supplied attempt oracles include all pre/post cells and the entire capability store. -/
structure ExpectedAttempt where
  branch : BranchId
  index : Nat
  invocation : I
  before : C → ℚ
  after : C → ℚ
  outcome : Except Composition.Failure Evt

def attemptMatches (actual : Attempt Party Asset Domain) (expected : ExpectedAttempt) : Bool :=
  decide (actual.branch = expected.branch ∧ actual.index = expected.index ∧
    actual.invocation = expected.invocation ∧
    (∀ c, actual.before.state.balance c = expected.before c) ∧
    actual.before.capabilities = store) &&
  match actual.outcome, expected.outcome with
  | .error actualReason, .error expectedReason => decide (actualReason = expectedReason)
  | .ok result, .ok event => decide
      ((∀ c, result.world.state.balance c = expected.after c) ∧
        result.world.capabilities = store ∧ result.receipt = event.receipt ∧
        result.outputs = event.outputs)
  | _, _ => false

def attemptsMatch (actual : R) (expected : List ExpectedAttempt) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => m.attempts.length == expected.length &&
      (m.attempts.zip expected).all fun (a, e) ↦ attemptMatches a e

def sharedLRAttempts : List ExpectedAttempt := [
  ⟨.left, 0, usd 7, sharedBalance 0 0 10, sharedBalance 7 0 3,
    .ok (transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7])⟩,
  ⟨.right, 0, peerUSD 6, sharedBalance 7 0 3, sharedBalance 7 0 3,
    .error (.kernel .insufficientFunds)⟩]
def replenishRLAttempts : List ExpectedAttempt := [
  ⟨.right, 0, peerUSD 6, sharedBalance 10 0 0, sharedBalance 10 0 0,
    .error (.kernel .insufficientFunds)⟩,
  ⟨.left, 0, usd 7, sharedBalance 10 0 0, sharedBalance 3 0 7,
    .ok (transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7])⟩]

end DefiKernel.Interleaving.Examples


/-! Induction over actual successful prefixes. Supply is taken from evaluated receipts;
framing requires explicit ledger support, and invariant reasoning requires local premises. -/
namespace DefiKernel.Composition
open Typed

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def traceSupply (events : List (Event P A D)) (domain : D) (asset : A) : ℚ :=
  (events.map (fun event ↦ event.result.receipt.supply domain asset)).sum

def traceWrites (events : List (Event P A D)) : List (Cell P A D) :=
  events.flatMap (fun event ↦ event.result.receipt.writes)

-- BEGIN PROOFS

theorem TraceSound.accounting {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) (d : D) (a : A) :
    total final.state d a = total initial.state d a + traceSupply events d a := by
  induction h with
  | nil => simp [traceSupply]
  | snoc previous step result accepted ih =>
    rw [accepted.accounting, ih]
    simp [traceSupply, List.map_append, List.sum_append, add_assoc]

theorem TraceSound.locality {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (cell : Cell P A D) (untouched : cell ∉ traceWrites events) :
    final.state.balance cell = initial.state.balance cell := by
  induction h with
  | nil => rfl
  | snoc previous step result accepted ih =>
    simp only [traceWrites, List.flatMap_append, List.flatMap_singleton, List.mem_append,
      not_or] at untouched
    exact (accepted.locality cell untouched.2).trans (ih untouched.1)

theorem TraceSound.steps {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∃ priorOutputs,
      StepSound cfg (boundaries event.index) event.index priorOutputs
        event.step event.before event.result := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · exact ⟨_, accepted⟩

theorem TraceSound.authority {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events,
      ReceiptAuthorized event.before (boundaries event.index) event.result.receipt := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  exact accepted.authorized

theorem TraceSound.component_locality {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∀ inv, event.step = .invoke inv →
      ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
          event.result.world.state.balance cell = event.before.state.balance cell := by
  intro event member inv he
  obtain ⟨prior, accepted⟩ := h.steps event member
  rw [he] at accepted
  exact accepted.component_locality

/-- Administrative authorization is separate from invocation receipt rights. -/
theorem TraceSound.administration {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, match event.step with
    | .invoke _ => True
    | .issue grant => (boundaries event.index).ctx.domain = grant.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin grant.domain
    | .revoke id => ∃ cap, event.before.capabilities.lookup id = some cap ∧
        (boundaries event.index).ctx.domain = cap.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin cap.domain := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  cases he : event.step with
  | invoke inv => trivial
  | issue grant =>
    rw [he] at accepted
    exact accepted.issue_admin
  | revoke id =>
    rw [he] at accepted
    exact accepted.revoke_admin

theorem TraceSound.invariant {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    invariant final := by
  induction h with
  | nil => exact initialized
  | snoc previous step result accepted ih => exact preserves _ _ _ _ _ accepted ih

theorem TraceSound.event_invariants {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    ∀ event ∈ events, invariant event.before ∧ invariant event.result.world := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · have hp := previous.invariant invariant initialized preserves
      exact ⟨hp, preserves _ _ _ _ _ accepted hp⟩

theorem TraceSound.frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    AgreeOn region initial.state final.state := by
  intro cell member
  exact (h.locality cell (untouched cell member)).symm

theorem TraceSound.predicate_frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    predicate initial.state ↔ predicate final.state :=
  supported_frame support (h.frame region untouched)

theorem run_accounting (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (d : D) (a : A) :
    total (run cfg boundaries initial steps).world.state d a =
      total initial.state d a + traceSupply (run cfg boundaries initial steps).events d a :=
  (run_trace_sound cfg boundaries initial steps).accounting d a

theorem run_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (cell : Cell P A D) :
    0 ≤ (run cfg boundaries initial steps).world.state.balance cell :=
  (run cfg boundaries initial steps).world.state.nonneg cell

theorem run_prefix_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∀ event ∈ (run cfg boundaries initial steps).events, ∀ cell,
      0 ≤ event.before.state.balance cell ∧ 0 ≤ event.result.world.state.balance cell := by
  intro event member cell
  exact ⟨event.before.state.nonneg cell, event.result.world.state.nonneg cell⟩

theorem run_frame (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ cell ∈ region, cell ∉ traceWrites (run cfg boundaries initial steps).events) :
    predicate initial.state ↔ predicate (run cfg boundaries initial steps).world.state :=
  (run_trace_sound cfg boundaries initial steps).predicate_frame region predicate support untouched

theorem run_contract (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (contract : ComponentContract P A D (Boundary P A D))
    (obligations : ContractObligations contract) (initialized : contract.initial initial)
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      contract.invariant pre → contract.assumes (boundaries n) pre ∧
        contract.guarantees (boundaries n) pre result.world) :
    contract.invariant (run cfg boundaries initial steps).world := by
  apply (run_trace_sound cfg boundaries initial steps).invariant contract.invariant
    (obligations.initialized initial initialized)
  intro n outputs step pre result accepted inv
  obtain ⟨assumes, guarantees⟩ := localGuarantee n outputs step pre result accepted inv
  exact obligations.preserved (boundaries n) pre result.world inv assumes guarantees

end DefiKernel.Composition

namespace DefiKernel.Composition.Examples
open Typed Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev S := Step Party Asset Domain
def aliceUsd : C := (.main, .alice, .usd)
def bobUsd : C := (.main, .bob, .usd)
def vaultUsd : C := (.main, .vault, .usd)
def aliceShare : C := (.main, .alice, .share)
def collateral : C := (.main, .alice, .collateral)
def transferInterface : OperationInterface Party Asset Domain :=
  ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, aliceUsd⟩]⟩
def depositInterface : OperationInterface Party Asset Domain :=
  ⟨depositId, [⟨⟨2⟩, .amount .usd⟩], [⟨⟨3⟩, aliceShare⟩, ⟨⟨4⟩, aliceUsd⟩]⟩
def withdrawInterface : OperationInterface Party Asset Domain :=
  ⟨withdrawId, [⟨⟨5⟩, .amount .share⟩], [⟨⟨6⟩, aliceUsd⟩]⟩
def catalog : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [bobUsd], [⟨⟨10⟩, aliceUsd, true⟩], [], [transferInterface]⟩,
  ⟨⟨1⟩, [vaultUsd, aliceShare], [], [⟨⟨⟨0⟩, ⟨10⟩⟩, aliceUsd, true⟩],
    [depositInterface, withdrawInterface]⟩,
  ⟨⟨2⟩, [collateral], [], [], []⟩]
def cfg : Config Party Asset Domain := ⟨registry, domainAdmin, catalog⟩
def boundary (_ : Nat) : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
/-- Independent table: no call to administrative execution. -/
def expectedStore : Store := ⟨[
  ⟨⟨.alice, .main, ⟨0⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨0⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit vaultUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit aliceShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .debit (.main, .pool, .usd)⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .changeSupply .main .debt⟩, true⟩]⟩
def initialWorld : W := ⟨initial, expectedStore⟩
def transferStep (q : ℚ) : S := .invoke
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositSource (source : InputSource Asset) : S := .invoke
  ⟨⟨1⟩, depositId, [], [source], allCapabilityIds, none⟩
def depositStep (q : ℚ) : S := depositSource (.literal ⟨.amount .usd, q⟩)
def withdrawStep (q : ℚ) : S := .invoke
  ⟨⟨1⟩, withdrawId, [], [.literal ⟨.amount .share, q⟩], allCapabilityIds, none⟩
def routedDeposit (index : Nat := 0) : S := depositSource (.priorOutput index ⟨⟨0⟩, ⟨1⟩⟩)
def workflow : List S := [transferStep 3, depositStep 4, withdrawStep 2]
/-- Boundary truth is an explicit premise, independent of structural validation. -/
def collateralContract : ComponentContract Party Asset Domain ℚ where
  initial w := w.state.balance collateral = 10
  assumes price _ := 1 ≤ price
  invariant w := 10 ≤ w.state.balance collateral
  guarantees price pre post := price * pre.state.balance collateral ≤ post.state.balance collateral
/-- Concrete post-transfer ledger for the support counterexample. -/
def transferred : Ledger where
  balance c := if c = aliceUsd then 7 else if c = bobUsd then 3 else initial.balance c
  nonneg c := by
    split
    · decide
    · split
      · decide
      · exact initial.nonneg c
def boundaryContract : ComponentContract Party Asset Domain (Boundary Party Asset Domain) where
  initial := collateralContract.initial
  assumes b _ := b.now = 100
  invariant := collateralContract.invariant
  guarantees _ pre post := pre.state.balance collateral ≤ post.state.balance collateral
-- BEGIN PROOFS
theorem collateralContract_obligations : ContractObligations collateralContract := by
  constructor
  · intro w h
    exact le_of_eq h.symm
  · intro price pre post hi ha hg
    change 10 ≤ post.state.balance collateral
    change 10 ≤ pre.state.balance collateral at hi
    change 1 ≤ price at ha
    change price * pre.state.balance collateral ≤ post.state.balance collateral at hg
    have hm : pre.state.balance collateral ≤ price * pre.state.balance collateral := by
      simpa using mul_le_mul_of_nonneg_right ha (pre.state.nonneg collateral)
    exact hi.trans (hm.trans hg)
theorem collateral_initialized : collateralContract.initial initialWorld := by rfl
theorem collateral_supported : Supports {collateral}
    (fun s : Ledger ↦ 10 ≤ s.balance collateral) := supports_balance collateral _
theorem unsupported_predicate_counterexample :
    ¬ Supports {collateral} (fun s : Ledger ↦ s.balance aliceUsd = 10) := by
  intro h
  have agree : AgreeOn {collateral} initial transferred := by
    intro cell hc
    have he : cell = collateral := hc
    subst cell
    rfl
  have bad := (h initial transferred agree).mp (show initial.balance aliceUsd = 10 from rfl)
  change (7 : ℚ) = 10 at bad
  exact (by decide : (7 : ℚ) ≠ 10) bad

theorem dropping_disjointness_counterexample :
    Supports {aliceUsd} (fun s : Ledger ↦ s.balance aliceUsd = 10) ∧
    initial.balance aliceUsd = 10 ∧ transferred.balance aliceUsd ≠ 10 := by
  exact ⟨supports_balance aliceUsd (fun q ↦ q = 10), rfl, by decide⟩

theorem workflow_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld workflow).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld workflow).events d a :=
  run_accounting cfg boundary initialWorld workflow d a

theorem refused_mint_prefix_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld
      [depositStep 4, transferStep 8]).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld
        [depositStep 4, transferStep 8]).events d a :=
  run_accounting cfg boundary initialWorld [depositStep 4,transferStep 8] d a

theorem workflow_nonnegative (c : C) :
    0 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance c :=
  run_nonnegative cfg boundary initialWorld workflow c

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
-- Kernel reduction expands the complete finite workflow, including authority and footprint checks.
theorem workflow_protected_writes :
    collateral ∉ traceWrites (Composition.run cfg boundary initialWorld workflow).events := by
  decide +kernel

theorem workflow_collateral_frame :
    (10 ≤ initialWorld.state.balance collateral) ↔
    10 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance collateral := by
  apply run_frame cfg boundary initialWorld workflow {collateral}
    (fun s ↦ 10 ≤ s.balance collateral) collateral_supported
  intro cell member
  have eq : cell = collateral := member
  subst cell
  exact workflow_protected_writes

theorem boundaryContract_obligations : ContractObligations boundaryContract :=
  ⟨collateralContract_obligations.initialized,
    fun _ _ _ hi _ hg ↦ hi.trans hg⟩

theorem workflow_conditional_invariant
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundary n) n outputs step pre result →
      boundaryContract.invariant pre → boundaryContract.assumes (boundary n) pre ∧
        boundaryContract.guarantees (boundary n) pre result.world) :
    boundaryContract.invariant (Composition.run cfg boundary initialWorld workflow).world :=
  run_contract cfg boundary initialWorld workflow boundaryContract boundaryContract_obligations
    collateral_initialized localGuarantee

end DefiKernel.Composition.Examples


namespace DefiKernel.Parallel.ObservationTests
open Typed Typed.Examples Composition Composition.Examples

def emptyCursor : Cursor Party Asset Domain := startCursor cfg initialWorld

def refusal (index : Nat) (reason : Failure) : Cursor Party Asset Domain :=
  { emptyCursor with failure := some ⟨index, none, reason⟩ }

def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def request : Request Party Asset Domain :=
  ⟨transferId, [.bob], [⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def evaluated : Evaluated Party Asset Domain :=
  ⟨true, [(aliceUsd, -3), (bobUsd, 3)], [], [], [], [], [], [aliceUsd, bobUsd]⟩

def output : OutputObservation Asset := ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩

def event : Event Party Asset Domain :=
  ⟨0, .invoke invocation, initialWorld, ⟨initialWorld, .invoked request evaluated, [output]⟩⟩

def changedWorld : World Party Asset Domain := ⟨transferred, expectedStore⟩

def receiptChanges : List (String × Receipt Party Asset Domain) := [
  ("kind", .issued ⟨0⟩),
  ("request", .invoked { request with claimedActor := some .bob } evaluated),
  ("guard", .invoked request { evaluated with guard := false }),
  ("deltas", .invoked request { evaluated with deltas := [(aliceUsd, -4), (bobUsd, 4)] }),
  ("supplies", .invoked request { evaluated with supplies := [((.main, .usd), 1)] }),
  ("required-state", .invoked request { evaluated with requiredStateReads := [aliceUsd] }),
  ("required-env", .invoked request { evaluated with requiredEnvReads := [.currentTime] }),
  ("declared-state", .invoked request { evaluated with declaredStateReads := [aliceUsd] }),
  ("declared-env", .invoked request { evaluated with declaredEnvReads := [.currentTime] }),
  ("writes", .invoked request { evaluated with writes := [aliceUsd] })]

def checks : List (String × Bool) := [
  ("parallel.observe.empty", decide (observeBranch emptyCursor = ⟨[], [], 0, none⟩)),
  ("parallel.observe.refusal-reason", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 0 (.kernel .insufficientFunds)))),
  ("parallel.observe.refusal-index", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 1 (.kernel .guard)))),
  ("parallel.observe.refusal-step", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch { emptyCursor with failure := some ⟨0, some (.invoke invocation),
        .kernel .guard⟩ })),
  ("parallel.observe.local-index", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with nextIndex := 1 })),
  ("parallel.observe.history", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with outputs := [output] })),
  ("parallel.observe.event-index", decide
    (observeEvent event ≠ observeEvent { event with index := 1 })),
  ("parallel.observe.event-step", decide
    (observeEvent event ≠ observeEvent { event with step :=
      (.invoke { invocation with parties := [.vault] }) })),
  ("parallel.observe.event-outputs", decide
    (observeEvent event ≠ observeEvent
      { event with result := { event.result with outputs := [] } })),
  ("parallel.observe.output-unit", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .share, 7⟩ }] } })),
  ("parallel.observe.output-value", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .usd, 8⟩ }] } })),
  ("parallel.observe.raw-world-context", decide
    (observeEvent event = observeEvent { event with
      before := changedWorld
      result := { event.result with world := changedWorld } })),
  ("parallel.observe.final-ledger", !(worldEq initialWorld changedWorld)),
  ("parallel.observe.final-store", !(worldEq initialWorld
    { initialWorld with capabilities := ⟨[]⟩ }))] ++
  receiptChanges.map fun (label, receipt) ↦
    ("parallel.observe.receipt." ++ label, decide
      (observeEvent event ≠ observeEvent { event with result := { event.result with receipt } }))

end DefiKernel.Parallel.ObservationTests


/-! Named bounded checks compare production execution with independent complete expectations. -/
namespace DefiKernel.Atomic.Tests
open Typed Composition Parallel Typed.Examples Atomic.Examples
open Parallel.Examples (C W I B Evt output observed event)

abbrev O := Observation P A D
abbrev R := Atomic.Result P A D
abbrev Inner := InnerObservation P A D

def expectedInner (branch : BranchId) (e : Evt) : Inner :=
  ⟨branch, e.index, match e.step with | .invoke inv => inv | _ => draw 0,
    e.receipt, e.outputs⟩
def inners (branch : BranchId) (events : List Evt) : List Inner :=
  events.map (expectedInner branch)
def supplyZero : D → A → ℚ := fun _ _ ↦ 0
def shareSupply : D → A → ℚ := fun d a ↦ if d = .main ∧ a = .share then 3 else 0

def expectedCommit (schedule : Interleaving.Schedule) (world : W) (events : List Inner)
    (supply : D → A → ℚ := supplyZero) : O :=
  ⟨42, schedule, .committed, world, [⟨42, schedule, events⟩], supply⟩
def expectedAbort (schedule : Interleaving.Schedule) (reason : AbortReason P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .aborted reason, world, [], supplyZero⟩
def expectedRefused (schedule : Interleaving.Schedule) (reason : Atomic.AdmissionFailure P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .refused reason, world, [], supplyZero⟩
def run (left right : B) (schedule : Interleaving.Schedule)
    (policy : Policy P A D := basePolicy) (boundary : ParallelBoundary P A D := atomBoundary)
    (world : W := atomInitial) : R := runAtomic atomCfg boundary 42 policy world left right schedule

def checkExpected (actual : R) (expected : O) : Bool := observationEq (observe actual) expected

def allLanes : List (Lane P A D) := Parallel.Examples.cells.map fun c ↦ ⟨c.1, c.2.2, c.2.1⟩
def tableMatches (actual : Outstanding P A D) (expected : List (Residual P A D)) : Bool :=
  allLanes.all fun lane ↦ [Party.alice, .bob, .vault, .pool].all fun p ↦
    decide (actual lane p = expectedOutstanding expected lane p)
def machineMatches (m : Atomic.Machine P A D) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  worldEq m.speculative.world world && worldEq m.entryWorld atomInitial &&
    decide (m.speculative.attempts.length = count ∧ m.position = position) &&
    tableMatches m.outstanding owed && decide ((diagnosticEvent 42 [] m).inner = events)
def diagnosticMatches (actual : R) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  match actual with
  | .refused _ _ _ _ => false
  | .aborted _ _ _ m | .committed _ _ m => machineMatches m count position world owed events

def drawReturn := run drawReturnLeft [] [.left, .left]
def underReturn := run underLeft [] [.left, .left]
def overReturn := run overLeft [] [.left, .left]
def creditReturn := run creditLeft [] [.left, .left, .left]
def peerReturn := run [draw 7] [repay 7] [.left, .right] multiParticipantPolicy peerBoundary
def assetReturn := run [draw 7] [repayShare 7] [.left, .right] multiLanePolicy
def domainReturn := run [draw 7] [repayOther 7] [.left, .right] domainPolicy otherBoundary
def noOpRun := run noOpLeft [] [.left, .left]
def repeatedRun := run [repeatedDraw, repay 7] [] [.left, .left]
def nonlaneRun := run nonlaneLeft [] [.left, .left, .left]
def firstFail := run [draw 11, draw 1] [mintShare] [.left, .right, .left]
def middleFail := run [draw 7, draw 6, draw 1] [mintShare] [.left, .right, .left, .left]
def mintFail := run [mintShare, draw 11] [] [.left, .left]
def abortFirst : AbortReason P A D := .kernel .left 0 0 (draw 11) (.kernel .insufficientFunds)
def abortMiddle : AbortReason P A D := .kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)
def abortMint : AbortReason P A D := .kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)
def mintFirstEvent := mintEvent 0 mintShare shareAlice 3 11

def settlementChecks : List (String × Bool) := [
  ("atomic.fixture.catalog", validateCatalog atomCfg.registry atomCfg.catalog),
  ("atomic.fixture.store", decide (atomStore.entries.length = 120)),
  ("atomic.fixture.empty", checkExpected (run [] [] []) (expectedCommit [] atomInitial [])),
  ("atomic.fixture.empty.batch", checkExpected (run [] [] [] batchPolicy)
    (expectedCommit [] atomInitial [])),
  ("atomic.fixture.settlement.draw.return", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))),
  ("atomic.fixture.settlement.draw.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial drawReturnLeft [] [.left])
    1 1 afterDraw drawResiduals (inners .left [drawEvent])),
  ("atomic.fixture.settlement.initial.table", machineMatches (Atomic.start atomInitial)
    0 0 atomInitial [] []),
  ("atomic.fixture.settlement.clear.table", diagnosticMatches drawReturn
    2 2 atomInitial [] (inners .left drawReturnEvents)),
  ("atomic.fixture.settlement.under", checkExpected underReturn
    (expectedAbort [.left, .left] (.unsettled underResiduals))),
  ("atomic.fixture.settlement.under.diagnostic", diagnosticMatches underReturn
    2 2 afterUnder underResiduals (inners .left underEvents)),
  ("atomic.fixture.settlement.over", checkExpected overReturn
    (expectedAbort [.left, .left] (.unsettled overResiduals))),
  ("atomic.fixture.settlement.credit.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial creditLeft [] [.left, .left])
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.credit.commit", checkExpected creditReturn
    (expectedCommit [.left, .left, .left] atomInitial (inners .left creditEvents))),
  ("atomic.fixture.settlement.cross.principal", checkExpected peerReturn
    (expectedAbort [.left, .right] (.unsettled peerResiduals))),
  ("atomic.fixture.settlement.cross.principal.table", diagnosticMatches peerReturn
    2 2 afterPeerReturn peerResiduals
    [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10 .bob)]),
  ("atomic.fixture.settlement.cross.asset", checkExpected assetReturn
    (expectedAbort [.left, .right] (.unsettled assetResiduals))),
  ("atomic.fixture.settlement.cross.domain", checkExpected domainReturn
    (expectedAbort [.left, .right] (.unsettled domainResiduals))),
  ("atomic.fixture.settlement.last.lane", checkExpected
    (run [drawShare 1] [] [.left] multiLanePolicy)
    (expectedAbort [.left] (.unsettled lastLaneResiduals))),
  ("atomic.fixture.settlement.last.participant", checkExpected
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    (expectedAbort [.right] (.unsettled lastParticipantResiduals))),
  ("atomic.fixture.settlement.noop", checkExpected noOpRun
    (expectedAbort [.left, .left] (.unsettled drawResiduals))),
  ("atomic.fixture.settlement.noop.table", diagnosticMatches noOpRun
    2 2 afterDraw drawResiduals (inners .left [drawEvent, noOpEvent])),
  ("atomic.fixture.settlement.repeated.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial [repeatedDraw, repay 7] [] [.left])
    1 1 afterDraw drawResiduals (inners .left [repeatedEvent])),
  ("atomic.fixture.settlement.repeated.commit", checkExpected repeatedRun
    (expectedCommit [.left, .left] atomInitial (inners .left [repeatedEvent, repayEvent 1 7 10]))),
  ("atomic.fixture.supply.lane.nonvault", checkExpected (run [mintUSD] [] [.left])
    (expectedAbort [.left] (.laneSupply .left 0 0 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.diagnostic", diagnosticMatches (run [mintUSD] [] [.left])
    1 1 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.supply.nonlane", checkExpected nonlaneRun
    (expectedCommit [.left, .left, .left] afterNonlaneMint
      (inners .left nonlaneEvents) shareSupply)),
  ("atomic.fixture.abort.first.public", checkExpected firstFail
    (expectedAbort [.left, .right, .left] abortFirst)),
  ("atomic.fixture.abort.first.stopped", diagnosticMatches firstFail 1 1 atomInitial [] []),
  ("atomic.fixture.abort.middle.public", checkExpected middleFail
    (expectedAbort [.left, .right, .left, .left] abortMiddle)),
  ("atomic.fixture.abort.middle.stopped", diagnosticMatches middleFail 3 3 afterDrawNonlaneMint
    drawResiduals [expectedInner .left drawEvent, expectedInner .right mintFirstEvent]),
  ("atomic.fixture.abort.outputs", decide ((observe middleFail).events = [])),
  ("atomic.fixture.abort.supply", checkExpected mintFail
    (expectedAbort [.left, .left] abortMint)),
  ("atomic.fixture.abort.supply.diagnostic", diagnosticMatches mintFail 2 2 afterNonlaneMint []
    (inners .left [mintFirstEvent])),
  ("atomic.fixture.collateral", decide ((observe nonlaneRun).world.state.balance collateral = 9 ∧
    (observe middleFail).world.state.balance collateral = 9)),
  ("atomic.fixture.capability.revoked", checkExpected
    (run drawReturnLeft [] [.left, .left] basePolicy atomBoundary revokedInitial)
    (expectedAbort [.left, .left]
      (.kernel .left 0 0 (draw 7) (.kernel .unauthorizedInvoke)) revokedInitial)),
  ("atomic.fixture.capability.live", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

/-- Earlier reference fixtures retain independent complete event expectations. -/
def oldRun (cfg : Config P A D) (boundary : ParallelBoundary P A D) (world : W)
    (left right : B) (schedule : Interleaving.Schedule) : R :=
  runAtomic cfg boundary 42 ⟨[], [.alice, .bob, .vault, .pool]⟩ world left right schedule

def liveRun := oldRun Interleaving.Examples.liveCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 0, Parallel.Examples.usd 0]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def liveWorld : W := ⟨⟨Parallel.Examples.balanceTable (9 / 2) (19 / 2) 20 0 16 1, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals norm_num⟩, Parallel.Examples.store⟩
def liveEvents : List Inner := [
  expectedInner .left (Parallel.Examples.statefulEvent 0 5 5),
  expectedInner .right (Parallel.Examples.transferEvent 0 (Parallel.Examples.peerUSD 4)
    Parallel.Examples.vaultUSD Parallel.Examples.aliceUSD 4 [output 0 1 .usd 9]),
  expectedInner .left (Parallel.Examples.statefulEvent 1 (9 / 2) (19 / 2))]
def peerOnlyRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.peerOnly]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.snapshotConsumer]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownWorld : W := ⟨⟨Parallel.Examples.balanceTable 4 6 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def timedRun := oldRun Parallel.Examples.timedCfg Parallel.Examples.timedBoundaries
  Parallel.Examples.initial Parallel.Examples.timedLeft Parallel.Examples.timedRight
  [.right, .left, .left, .right]
def timedWorld : W := ⟨⟨Parallel.Examples.balanceTable 8 2 14 6, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def historyChecks : List (String × Bool) := [
  ("atomic.fixture.live.complete", checkExpected liveRun
    (expectedCommit [.left, .right, .left] liveWorld liveEvents)),
  ("atomic.fixture.history.peer.only", checkExpected peerOnlyRun
    (expectedAbort [.left, .right, .left]
      (.kernel .left 1 2 Interleaving.Examples.peerOnly (.interface .unavailableOutput))
      Parallel.Examples.initial)),
  ("atomic.fixture.history.own", checkExpected ownRun
    (expectedCommit [.left, .right, .left] ownWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.transferEvent 1
        Interleaving.Examples.snapshotConsumer Parallel.Examples.aliceUSD Parallel.Examples.bobUSD
        3 [output 1 0 .usd 6])])),
  ("atomic.fixture.boundary.local", checkExpected timedRun
    (expectedCommit [.right, .left, .left, .right] timedWorld [
      expectedInner .right (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 1 11 .share 4 200 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 4 200 4),
      expectedInner .left (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 0 10 .usd 3 100 .bob)
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 100 3),
      expectedInner .left (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 0 10 .usd 1 101 .alice)
        Parallel.Examples.bobUSD Parallel.Examples.aliceUSD 1 101 2),
      expectedInner .right (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 1 11 .share 2 201 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 2 201 6)])) ]

def invalidCfg : Config P A D := { atomCfg with catalog := atomCfg.catalog ++ atomCfg.catalog }
def unknown : I := { draw 1 with operation := ⟨9999⟩ }
def laterBoundary (_ : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100⟩
def missingCap : I := { draw 7 with capabilityIds := [] }
def debitMissing : I := { draw 7 with capabilityIds := [⟨0⟩] }
def batchSingle := run [draw 7] [] [.left] batchPolicy

def admissionChecks : List (String × Bool) := [
  ("atomic.fixture.batch.single", checkExpected batchSingle
    (expectedCommit [.left] afterDraw (inners .left [drawEvent]))),
  ("atomic.fixture.order.commit", checkExpected (run [draw 7] [repay 7] [.left, .right])
    (expectedCommit [.left, .right] atomInitial
      [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10)])),
  ("atomic.fixture.order.abort", checkExpected (run [draw 7] [repay 7] [.right, .left])
    (expectedAbort [.right, .left]
      (.kernel .right 0 0 (repay 7) (.kernel .insufficientFunds)))),
  ("atomic.fixture.capability.missing", checkExpected (run [missingCap] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 missingCap (.kernel .unauthorizedInvoke)))),
  ("atomic.fixture.capability.debit", checkExpected (run [debitMissing] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 debitMissing (.kernel .unauthorizedDebit)))),
  ("atomic.admission.configuration", checkExpected
    (runAtomic invalidCfg atomBoundary 42 duplicateLanePolicy atomInitial [unknown] [] [])
    (expectedRefused [] .configuration)),
  ("atomic.admission.left", checkExpected
    (run [draw 11, unknown] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("atomic.admission.right", checkExpected (run [draw 7] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .right ⟨0, .interface .unknownOperation⟩))),
  ("atomic.admission.lane.alternate.vault", checkExpected
    (run [draw 7] [] [] duplicateLanePolicy)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane ⟨.main, .usd, .pool⟩)))),
  ("atomic.admission.lane.same.vault", checkExpected
    (run [] [] [] ⟨[usdLane, usdLane], [.alice]⟩)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane usdLane)))),
  ("atomic.admission.participant.duplicate", checkExpected
    (run [] [] [] duplicateParticipantPolicy)
    (expectedRefused [] (.policy (.duplicateParticipant 0 2 .alice)))),
  ("atomic.admission.participant.peer", checkExpected
    (run [draw 7] [repay 7] [] basePolicy peerBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .right 0 .bob)))),
  ("atomic.admission.participant.suffix", checkExpected
    (run [draw 11, draw 0] [] [] basePolicy laterBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .left 1 .bob)))),
  ("atomic.admission.schedule.missing", checkExpected (run [draw 7] [repay 7] [.left])
    (expectedRefused [.left] (.schedule ⟨1, 1, 1, 0⟩))),
  ("atomic.admission.schedule.excess", checkExpected (run [] [] [.right])
    (expectedRefused [.right] (.schedule ⟨0, 0, 0, 1⟩))),
  ("atomic.admission.extra.participant", checkExpected
    (run drawReturnLeft [] [.left, .left] multiParticipantPolicy)
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

def baselineObservation : O := expectedCommit [.left] afterDraw (inners .left [drawEvent])
def baselineInner : Inner := expectedInner .left drawEvent
def differentObservation (changed : O) : Bool := !observationEq baselineObservation changed
def changedInner (f : Inner → Inner) : O :=
  { baselineObservation with events := [⟨42, [.left], [f baselineInner]⟩] }
def changedOutput (output : OutputObservation A) : Bool :=
  differentObservation (changedInner fun e ↦ {e with outputs := [output]})
def abortObservation (reason : AbortReason P A D) : O :=
  expectedAbort [.left, .right, .left, .left] reason
def abortDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (abortObservation abortMiddle) (abortObservation reason)
def residualObservation (entries : List (Residual P A D)) : O :=
  expectedAbort [.left, .right] (.unsettled entries)
def residualDifference (entries : List (Residual P A D)) : Bool :=
  !observationEq (residualObservation peerResiduals) (residualObservation entries)
def supplyObservation (reason : AbortReason P A D) : O := expectedAbort [.left] reason
def supplyDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (supplyObservation (.laneSupply .left 0 0 mintUSD usdLane 3))
    (supplyObservation reason)

def observationChecks : List (String × Bool) := [
  ("atomic.observe.equal", observationEq baselineObservation
    ⟨42, [.left], .committed, atomWorld 8 7 3 8 10 8 10,
      [⟨42, [.left], [⟨.left, 0, draw 7,
        (Parallel.Examples.transferEvent 0 (draw 7) usdVault usdAlice 7
          [output 0 100 .usd 3]).receipt, [output 0 100 .usd 3]⟩]⟩], fun _ _ ↦ 0⟩),
  ("atomic.observe.kind", differentObservation {baselineObservation with
    outcome := .aborted (.unsettled drawResiduals)}),
  ("atomic.observe.label", differentObservation {baselineObservation with label := 43}),
  ("atomic.observe.schedule", differentObservation {baselineObservation with schedule := [.right]}),
  ("atomic.observe.world", differentObservation {baselineObservation with world := atomInitial}),
  ("atomic.observe.store", differentObservation {baselineObservation with
    world := {afterDraw with capabilities := revokedStore}}),
  ("atomic.observe.supply", differentObservation {baselineObservation with supply := shareSupply}),
  ("atomic.observe.events", differentObservation {baselineObservation with events := []}),
  ("atomic.observe.event.label", differentObservation {baselineObservation with
    events := [⟨43, [.left], [baselineInner]⟩]}),
  ("atomic.observe.event.schedule", differentObservation {baselineObservation with
    events := [⟨42, [.right], [baselineInner]⟩]}),
  ("atomic.observe.event.inner", differentObservation {baselineObservation with
    events := [⟨42, [.left], []⟩]}),
  ("atomic.observe.inner.branch",
    differentObservation (changedInner fun e ↦ {e with branch := .right})),
  ("atomic.observe.inner.index", differentObservation (changedInner fun e ↦ {e with index := 1})),
  ("atomic.observe.inner.invocation", differentObservation
    (changedInner fun e ↦ {e with invocation := draw 8})),
  ("atomic.observe.inner.outputs",
    differentObservation (changedInner fun e ↦ {e with outputs := []})),
  ("atomic.observe.output.index", changedOutput (output 1 100 .usd 3)),
  ("atomic.observe.output.component", changedOutput (output 0 101 .usd 3)),
  ("atomic.observe.output.port", changedOutput ⟨0, ⟨⟨100⟩, ⟨1⟩⟩, ⟨.amount .usd, 3⟩⟩),
  ("atomic.observe.output.asset", changedOutput (output 0 100 .share 3)),
  ("atomic.observe.output.amount", changedOutput (output 0 100 .usd 4)),
  ("atomic.observe.abort.equal", observationEq (abortObservation abortMiddle)
    (expectedAbort [.left, .right, .left, .left]
      (.kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)))),
  ("atomic.observe.abort.reason", abortDifference (.kernel .left 1 2 (draw 6) (.kernel .guard))),
  ("atomic.observe.abort.branch", abortDifference
    (.kernel .right 1 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.index", abortDifference
    (.kernel .left 0 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.position", abortDifference
    (.kernel .left 1 1 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.invocation", abortDifference
    (.kernel .left 1 2 (draw 7) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.label", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with label := 43}),
  ("atomic.observe.abort.schedule", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with schedule := [.left]}),
  ("atomic.observe.residual.equal", observationEq (residualObservation peerResiduals)
    (residualObservation [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩])),
  ("atomic.observe.residual.amount", residualDifference
    [⟨usdLane, .alice, 8⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.principal", residualDifference
    [⟨usdLane, .vault, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.asset", residualDifference
    [⟨shareLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.domain", residualDifference
    [⟨otherLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.vault", residualDifference
    [⟨⟨.main, .usd, .pool⟩, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.order", residualDifference
    [⟨usdLane, .bob, -7⟩, ⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.residual.omitted", residualDifference [⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.supply.abort.amount",
    supplyDifference (.laneSupply .left 0 0 mintUSD usdLane 4)),
  ("atomic.observe.supply.abort.lane",
    supplyDifference (.laneSupply .left 0 0 mintUSD shareLane 3)),
  ("atomic.observe.supply.abort.branch",
    supplyDifference (.laneSupply .right 0 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.index", supplyDifference (.laneSupply .left 1 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.position",
    supplyDifference (.laneSupply .left 0 1 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.invocation", supplyDifference
    (.laneSupply .left 0 0 mintShare usdLane 3)),
  ("atomic.observe.admission.reason", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [] (.policy (.duplicateParticipant 0 1 .alice)))),
  ("atomic.observe.admission.label", !observationEq (expectedRefused [] .configuration)
    {expectedRefused [] .configuration with label := 43}),
  ("atomic.observe.admission.schedule", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [.left] .configuration)),
  ("atomic.observe.diagnostic.erased", observationsEqual
    (.aborted 42 [.left] abortFirst (Atomic.start atomInitial))
    (.aborted 42 [.left] abortFirst
      {Atomic.start atomInitial with speculative := Interleaving.start afterDraw})) ]

def receiptRequest : Request P A D := ⟨⟨100⟩, [], [⟨.amount .usd, 7⟩], atomCaps, none⟩
def receiptEvaluated := Parallel.Examples.evaluatedTransfer usdVault usdAlice 7

def requestChanges : List (String × Request P A D) := [
  ("operation", {receiptRequest with operation := ⟨101⟩}),
  ("parties", {receiptRequest with parties := [.bob]}),
  ("arguments", {receiptRequest with arguments := [⟨.amount .usd, 8⟩]}),
  ("capabilities", {receiptRequest with capabilityIds := []}),
  ("actor", {receiptRequest with claimedActor := some .bob}) ]
def evaluatedChanges : List (String × Evaluated P A D) := [
  ("guard", {receiptEvaluated with guard := false}),
  ("deltas", {receiptEvaluated with deltas := [(usdVault, -6), (usdAlice, 6)]}),
  ("supply", {receiptEvaluated with supplies := [((.main, .usd), 1)]}),
  ("required.state", {receiptEvaluated with requiredStateReads := [usdAlice]}),
  ("required.environment", {receiptEvaluated with requiredEnvReads := [.currentTime]}),
  ("declared.state", {receiptEvaluated with declaredStateReads := [usdAlice]}),
  ("declared.environment", {receiptEvaluated with declaredEnvReads := [.currentTime]}),
  ("writes", {receiptEvaluated with writes := [usdVault]}) ]
def receiptChecks : List (String × Bool) :=
  requestChanges.map (fun (name, request) ↦ ("atomic.observe.request." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked request receiptEvaluated}))) ++
  evaluatedChanges.map (fun (name, evaluated) ↦ ("atomic.observe.receipt." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked receiptRequest evaluated}))) ++
  [("atomic.observe.receipt.constructor", differentObservation
    (changedInner fun e ↦ {e with receipt := .revoked ⟨0⟩}))]

def afterDrawLaneMint := atomWorld 11 7 3 8 10 8 10
def laneMintAfterDrawEvent := mintEvent 1 mintUSD usdAlice 3 11
def laneMintAfterDraw := run [draw 7, mintUSD, repay 7] [noop]
  [.left, .left, .right, .left]
def fundedWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def snapshotWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def extendedChecks : List (String × Bool) := [
  ("atomic.fixture.settlement.over.diagnostic", diagnosticMatches overReturn
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.cross.asset.table", diagnosticMatches assetReturn
    2 2 afterAssetReturn assetResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17)]),
  ("atomic.fixture.settlement.cross.domain.table", diagnosticMatches domainReturn
    2 2 afterDomainReturn domainResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17)]),
  ("atomic.fixture.settlement.last.lane.table", diagnosticMatches
    (run [drawShare 1] [] [.left] multiLanePolicy) 1 1 afterLastLane lastLaneResiduals
    (inners .left lastLaneEvents)),
  ("atomic.fixture.settlement.last.participant.table", diagnosticMatches
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    1 1 afterLastParticipant lastParticipantResiduals (inners .right lastParticipantEvents)),
  ("atomic.fixture.supply.lane.after.draw", checkExpected laneMintAfterDraw
    (expectedAbort [.left, .left, .right, .left]
      (.laneSupply .left 1 1 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.after.draw.table", diagnosticMatches laneMintAfterDraw
    2 2 afterDrawLaneMint drawResiduals (inners .left [drawEvent, laneMintAfterDrawEvent])),
  ("atomic.fixture.history.funded.literal", checkExpected
    (oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 3, Parallel.Examples.usd 5] [Parallel.Examples.peerUSD 4]
      [.left, .right, .left])
    (expectedCommit [.left, .right, .left] fundedWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.leftEvent 1 5 8)])),
  ("atomic.fixture.history.both.own", checkExpected
    (oldRun Interleaving.Examples.snapshotCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 2, Interleaving.Examples.snapshotConsumer]
      [Parallel.Examples.usd 1, Interleaving.Examples.snapshotConsumer]
      [.left, .right, .left, .right])
    (expectedCommit [.left, .right, .left, .right] snapshotWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 2 2),
      expectedInner .right (Parallel.Examples.leftEvent 0 1 3),
      expectedInner .left (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 2 [output 1 0 .usd 5]),
      expectedInner .right (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 [output 1 0 .usd 8])])) ]

/-- Public-world chaining starts a fresh history even after a speculative USD snapshot. -/
def abortedProducer := run [mintUSD, draw 11] [] [.left, .left] batchPolicy
def abortedSnapshotConsumer : I :=
  { draw 4 with inputs := [.priorOutput 0 ⟨⟨108⟩, ⟨0⟩⟩] }
def followup := run [noop, abortedSnapshotConsumer] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def followupFunded := run [noop, draw 4] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def initialNoOpEvent : Evt := event 0 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 0 106 .usd 10]
def followupChecks : List (String × Bool) := [
  ("atomic.fixture.followup.producer.aborted", checkExpected abortedProducer
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)))),
  ("atomic.fixture.followup.producer.diagnostic", diagnosticMatches abortedProducer
    2 2 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.followup.fresh.history", checkExpected followup
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 abortedSnapshotConsumer (.interface .unavailableOutput)))),
  ("atomic.fixture.followup.funded.literal", checkExpected followupFunded
    (expectedCommit [.left, .left] (atomWorld 5 7 6 8 10 8 10)
      (inners .left [initialNoOpEvent, expectedTransfer 1 (draw 4) usdVault usdAlice 4 6]))) ]

def dualSupplyTemplate : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨.usd, refAt .main .usd .caller, .lit (3 : ℚ)⟩,
    ⟨.share, refAt .main .share .caller, .lit (4 : ℚ)⟩]
  supplyDeltas := [⟨.main, .usd, .lit (3 : ℚ)⟩, ⟨.main, .share, .lit (4 : ℚ)⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main .usd .caller, packedAt .main .share .caller]
def dualSupplyCfg : Config P A D := { atomCfg with
  registry := fun id ↦ if id = ⟨112⟩ then some dualSupplyTemplate else atomCfg.registry id
  catalog := atomCfg.catalog ++ [fixtureComponent ⟨112, dualSupplyTemplate, usdAlice⟩] }
def dualSupplyStore : Store := ⟨atomStore.entries ++
  [⟨⟨.alice, .main, ⟨112⟩, .invoke⟩, true⟩,
   ⟨⟨.alice, .main, ⟨112⟩, .changeSupply .main .usd⟩, true⟩,
   ⟨⟨.alice, .main, ⟨112⟩, .changeSupply .main .share⟩, true⟩]⟩
def dualSupplyInitial : W := atomWorld 1 7 10 8 10 8 10 dualSupplyStore
def dualSupplyInvocation : I := ⟨⟨112⟩, ⟨112⟩, [], [], [⟨120⟩, ⟨121⟩, ⟨122⟩], none⟩
def dualSupplyRun (lanes : List (Lane P A D)) : R :=
  runAtomic dualSupplyCfg atomBoundary 42 ⟨lanes, [.alice]⟩ dualSupplyInitial
    [draw 7, dualSupplyInvocation, draw 1] [] [.left, .left, .left]
def dualSupplyEvent : Evt := event 1 dualSupplyInvocation []
  ⟨true, [(usdAlice, 3), (shareAlice, 4)], [((.main, .usd), 3), ((.main, .share), 4)],
    [], [], [], [], [usdAlice, shareAlice]⟩ [output 1 112 .usd 11]
def dualSupplyDiagnostic (actual : R) : Bool := match actual with
  | .refused _ _ _ _ => false
  | .aborted _ _ _ m | .committed _ _ m =>
    worldEq m.entryWorld dualSupplyInitial &&
    worldEq m.speculative.world (atomWorld 11 7 3 12 10 8 10 dualSupplyStore) &&
    decide (m.speculative.attempts.length = 2 ∧ m.position = 2) &&
    tableMatches m.outstanding drawResiduals &&
    decide ((diagnosticEvent 42 [] m).inner = inners .left [drawEvent, dualSupplyEvent])

def precedenceChecks : List (String × Bool) := [
  ("atomic.admission.precedence.lane.participant.uncovered.count", checkExpected
    (run [draw 11, draw 0] [] [] ⟨[usdLane, usdLane], [.alice, .alice]⟩ laterBoundary)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane usdLane)))),
  ("atomic.admission.precedence.participant.uncovered.count", checkExpected
    (run [draw 11, draw 0] [] [] ⟨[usdLane], [.alice, .alice]⟩ laterBoundary)
    (expectedRefused [] (.policy (.duplicateParticipant 0 1 .alice)))),
  ("atomic.fixture.supply.first.lane.usd", checkExpected (dualSupplyRun [usdLane, shareLane])
    (expectedAbort [.left, .left, .left]
      (.laneSupply .left 1 1 dualSupplyInvocation usdLane 3) dualSupplyInitial)),
  ("atomic.fixture.supply.first.lane.share", checkExpected (dualSupplyRun [shareLane, usdLane])
    (expectedAbort [.left, .left, .left]
      (.laneSupply .left 1 1 dualSupplyInvocation shareLane 4) dualSupplyInitial)),
  ("atomic.fixture.supply.first.lane.diagnostic.usd",
    dualSupplyDiagnostic (dualSupplyRun [usdLane, shareLane])),
  ("atomic.fixture.supply.first.lane.diagnostic.share",
    dualSupplyDiagnostic (dualSupplyRun [shareLane, usdLane])) ]

def runtimeChecks : List (String × Bool) :=
  settlementChecks ++ historyChecks ++ admissionChecks ++ observationChecks ++
    receiptChecks ++ extendedChecks ++ followupChecks ++ precedenceChecks


end DefiKernel.Atomic.Tests


namespace DefiKernel.Atomic.Audit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Atomic runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Atomic runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Atomic runtime comparisons failed: {failures.length}")

#eval main


end DefiKernel.Atomic.Audit
