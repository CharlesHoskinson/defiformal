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
  return ⟨reads ++ writes, writes⟩
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


end DefiKernel.Parallel


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


end DefiKernel.Parallel


/-! Complete evaluation and execution dependence on resolved reads and potential delta targets.
No successful footprint check is assumed in the refusal proofs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def ResolvedReadsAgree (template : Template P A D) (caller : P) (parties : List P)
    (left right : State P A D) : Prop :=
  ∀ ref ∈ template.requiredStateReads, ∀ c,
    ref.2.resolve caller parties = .ok c → left.balance c = right.balance c

def TargetsWithin (template : Template P A D) (caller : P) (parties : List P)
    (region : Set (Cell P A D)) : Prop :=
  ∀ d ∈ template.deltas, ∀ c, d.target.resolve caller parties = .ok c → c ∈ region


end DefiKernel.Parallel


/-! State dependence for the existing composition adapter, with same-prestate receipts and
selected post-state snapshots. Boundaries and local histories are identical inputs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]


end DefiKernel.Parallel


/-! Congruence of full local histories and exact refusals, then correspondence to actual
serial branch re-execution. Dependency premises are discharged from checked admission. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]


end DefiKernel.Parallel


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


/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset


end DefiKernel.Parallel


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


/-! Bounded admission controls with independently specified footprint lists and financial siblings.
These are development fixtures; generic proof obligations are in Compatibility. -/
namespace DefiKernel.Parallel.CompatibilityTests
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev F := Footprint Party Asset Domain
abbrev I := Invocation Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def common : C := (.main, .alice, .collateral)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩
def transferOp (a : Asset) (sender recipient : Party) (q : ℚ) : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal sender), .lit (-q)⟩,
    ⟨a, ref a (.literal recipient), .lit q⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal sender), packedRef a (.literal recipient)]
def usdOp := transferOp .usd .alice .bob 3
def shareOp := transferOp .share .vault .alice 4
def readOnly (c : C) : Op := { usdOp with
  guard := .binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c))
  deltas := [], writes := [], stateReads := [packed c] }
def hidden (t : Op) (c : C) : Op := { t with
  guard := .ite (.lit true) t.guard
    (.binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c)))
  stateReads := [packed c] }
def cfg (left : Op := usdOp) (right : Op := shareOp)
    (leftOutput : List C := []) (rightOutput : List C := []) : Config Party Asset Domain where
  registry op := if op = ⟨10⟩ then some left else if op = ⟨11⟩ then some right else none
  domainAdmin := domainAdmin
  catalog := [⟨⟨0⟩, ([Domain.main, .other].flatMap fun d ↦
    [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
      [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)), [], [],
    [⟨⟨10⟩, [], leftOutput.map (fun c ↦ ⟨⟨0⟩, c⟩)⟩,
     ⟨⟨11⟩, [], rightOutput.map (fun c ↦ ⟨⟨1⟩, c⟩)⟩]⟩]
def boundary (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩
def left : I := ⟨⟨0⟩, ⟨10⟩, [], [], [⟨0⟩, ⟨1⟩], none⟩
def right : I := ⟨⟨0⟩, ⟨11⟩, [], [], [⟨2⟩, ⟨3⟩], none⟩
def leftFP : F := ⟨[aliceUSD, bobUSD, aliceUSD, bobUSD],
  [aliceUSD, bobUSD, aliceUSD, bobUSD]⟩
def rightFP : F := ⟨[vaultShare, aliceShare, vaultShare, aliceShare],
  [vaultShare, aliceShare, vaultShare, aliceShare]⟩
def initial : World Party Asset Domain := ⟨⟨fun c ↦
  if c = aliceUSD then 10 else if c = vaultShare then 20 else 0,
  by
    intro c
    split
    · decide
    · split <;> decide⟩,
  ⟨[⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩]⟩⟩
def accepted {E X : Type} : Except E X → Bool
  | .ok _ => true
  | .error _ => false
def resultEq {E X : Type} [DecidableEq E] [DecidableEq X]
    (actual expected : Except E X) : Bool := decide (actual = expected)
def funded (config : Config Party Asset Domain) (inv : I) : Bool :=
  accepted (executeStep config (boundary .left 0) 0 [] (.invoke inv) initial)
def fundedExact (inv : I) (expected : C → ℚ) : Bool :=
  match executeStep cfg (boundary .left 0) 0 [] (.invoke inv) initial with
  | .error _ => false
  | .ok result => decide ((∀ c, result.world.state.balance c = expected c) ∧
      result.world.capabilities = initial.capabilities)
def overlap (kind : ConflictKind) (cell : C) :
    Except (AdmissionFailure Party Asset Domain) (F × F) :=
  .error (.conflict kind cell)
def zeroTarget : Op := { (readOnly common) with
  guard := .lit true
  stateReads := []
  deltas := [⟨.usd, cellRef aliceUSD, .lit 0⟩] }
def hiddenDelta : Op := { shareOp with
  deltas := shareOp.deltas.map (fun d ↦ { d with
    amount := .ite (.lit true) d.amount
      (.binary (.unconvert d.asset .usd) (.balance (cellRef aliceUSD)) (.lit 1)) })
  stateReads := [packed aliceUSD] }
def hiddenSupply : Op := { shareOp with
  supplyDeltas := [⟨.main, .usd,
    .ite (.lit true) (.lit 0) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def malformed : Op := { usdOp with stateReads := [packedRef .usd (.argument 3)] }
def deniedCfg : Config Party Asset Domain := { cfg with
  catalog := (cfg.catalog.map fun c ↦ { c with privateCells := [vaultShare, aliceShare] }) }
def checks : List (String × Bool) := [
  ("parallel.compat.catalog-positive", validateCatalog cfg.registry cfg.catalog),
  ("parallel.compat.invocation-exact-left", resultEq
    (analyzeInvocation cfg (boundary .left 0) left) (.ok leftFP)),
  ("parallel.compat.invocation-exact-right", resultEq
    (analyzeInvocation cfg (boundary .right 0) right) (.ok rightFP)),
  ("parallel.compat.funded-left-complete", fundedExact left
    (fun c ↦ if c = aliceUSD then 7 else if c = bobUSD then 3 else initial.state.balance c)),
  ("parallel.compat.funded-right-complete", fundedExact right
    (fun c ↦ if c = vaultShare then 16 else if c = aliceShare then 4 else initial.state.balance c)),
  ("parallel.compat.independent", resultEq (admit cfg boundary [left] [right])
    (.ok (leftFP, rightFP))),
  ("parallel.compat.empty", resultEq (admit cfg boundary [] []) (.ok (.empty, .empty))),
  ("parallel.compat.left-empty", resultEq (admit cfg boundary [] [right])
    (.ok (.empty, rightFP))),
  ("parallel.compat.common-read", accepted
    (admit (cfg (hidden usdOp common) (hidden shareOp common)) boundary [left] [right])),
  ("parallel.compat.write-write-witness", resultEq (admit cfg boundary [left] [left])
    (overlap .writeWrite aliceUSD)),
  ("parallel.compat.forward-read", resultEq
    (admit (cfg usdOp (readOnly aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.reverse-read", resultEq
    (admit (cfg (readOnly vaultShare) shareOp) boundary [left] [right])
    (overlap .rightWriteLeftRead vaultShare)),
  ("parallel.compat.hidden-inactive-guard", resultEq
    (admit (cfg usdOp (hidden shareOp aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-inactive-guard-funded",
    funded (cfg usdOp (hidden shareOp aliceUSD)) right),
  ("parallel.compat.hidden-delta", resultEq
    (admit (cfg usdOp hiddenDelta) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-delta-funded", funded (cfg usdOp hiddenDelta) right),
  ("parallel.compat.hidden-supply", resultEq
    (admit (cfg usdOp hiddenSupply) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-supply-funded", funded (cfg usdOp hiddenSupply) right),
  ("parallel.compat.output-dependency", resultEq
    (admit (cfg usdOp shareOp [] [aliceUSD]) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.output-exact", resultEq
    (analyzeInvocation (cfg usdOp shareOp [] [aliceUSD]) (boundary .right 0) right)
    (.ok ⟨rightFP.reads ++ [aliceUSD], rightFP.writes⟩)),
  ("parallel.compat.zero-target", resultEq
    (admit (cfg usdOp zeroTarget) boundary [left] [right]) (overlap .writeWrite aliceUSD)),
  ("parallel.compat.zero-target-funded", funded (cfg usdOp zeroTarget) right),
  ("parallel.compat.zero-target-exact", resultEq
    (analyzeInvocation (cfg usdOp zeroTarget) (boundary .right 0) right)
    (.ok ⟨[aliceUSD], [aliceUSD]⟩)),
  ("parallel.compat.unreachable-suffix", resultEq
    (admit cfg boundary [{left with capabilityIds := []}, right] [right])
    (overlap .writeWrite vaultShare)),
  ("parallel.compat.numeric-input-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.literal ⟨.amount .usd, -500⟩]}) (.ok leftFP)),
  ("parallel.compat.prior-output-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.priorOutput 9 ⟨⟨99⟩, ⟨99⟩⟩]}) (.ok leftFP)),
  ("parallel.compat.capability-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0) {left with capabilityIds := []}) (.ok leftFP)),
  ("parallel.compat.catalog-first", resultEq
    (admit {cfg with catalog := cfg.catalog ++ cfg.catalog} boundary
      [{left with operation := ⟨99⟩}] []) (.error .configuration)),
  ("parallel.compat.left-before-right", resultEq
    (admit cfg boundary [{left with operation := ⟨99⟩}] [{right with operation := ⟨98⟩}])
    (.error (.structural .left ⟨0, .interface .unknownOperation⟩))),
  ("parallel.compat.local-order", resultEq
    (admit cfg boundary [left, {left with operation := ⟨99⟩}, {left with operation := ⟨98⟩}] [])
    (.error (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.structural-before-conflict", resultEq
    (admit cfg boundary [left] [left, {right with operation := ⟨99⟩}])
    (.error (.structural .right ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.malformed-reference", resultEq
    (admit (cfg malformed shareOp) boundary [left] [right])
    (.error (.structural .left ⟨0, .interface (.resolution .partyArgument)⟩))),
  ("parallel.compat.access-check", resultEq
    (admit deniedCfg boundary [left] [right])
    (.error (.structural .left ⟨0, .interface .writeAccess⟩))),
  ("parallel.compat.forward-funded", funded (cfg usdOp (readOnly aliceUSD)) right),
  ("parallel.compat.reverse-funded", funded (cfg (readOnly vaultShare) shareOp) left),
  ("parallel.compat.output-funded", funded (cfg usdOp shareOp [] [aliceUSD]) right),
  ("parallel.compat.guard-read-exact", resultEq
    (analyzeInvocation (cfg usdOp (hidden shareOp aliceUSD)) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.delta-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenDelta) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.supply-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenSupply) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.forward-before-reverse", resultEq
    (checkCompatibility (⟨[bobUSD], [aliceUSD]⟩ : F) ⟨[aliceUSD], [bobUSD]⟩)
    (.error (.conflict .leftWriteRightRead aliceUSD))),
  ("parallel.compat.common-read-no-writes", resultEq
    (admit (cfg (readOnly common) (readOnly common)) boundary [left] [right])
    (.ok (⟨[common, common], []⟩, ⟨[common, common], []⟩))),
  ("parallel.compat.first-list-witness", resultEq
    (checkCompatibility (⟨[bobUSD, aliceUSD], [bobUSD, aliceUSD]⟩ : F) leftFP)
    (.error (.conflict .writeWrite bobUSD))) ]

end DefiKernel.Parallel.CompatibilityTests


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


namespace DefiKernel.Parallel.ExecutionTests
open Typed Typed.Examples Composition Composition.Examples

def boundaries (_ : BranchId) : Nat → Boundary Party Asset Domain := boundary

def emptyExpected : BranchObservation Party Asset Domain := ⟨[], [], 0, none⟩

def refusedUnchanged (config : Config Party Asset Domain)
    (left right : Branch Party Asset Domain) (reason : AdmissionFailure Party Asset Domain) : Bool :=
  match runParallel config CompatibilityTests.boundary CompatibilityTests.initial left right with
  | .refused actual world =>
    decide (actual = reason) && worldEq world CompatibilityTests.initial
  | .executed _ => false

def checks : List (String × Bool) := [
  ("parallel.empty", match runParallel cfg boundaries initialWorld [] [] with
    | .refused _ _ => false
    | .executed result =>
      worldEq result.world initialWorld &&
      decide (observeBranch result.left = emptyExpected ∧
        observeBranch result.right = emptyExpected)),
  ("parallel.empty.lr", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialLR cfg boundaries initialWorld [] [])),
  ("parallel.empty.rl", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialRL cfg boundaries initialWorld [] [])),
  ("parallel.refused.catalog-unchanged", refusedUnchanged
    { CompatibilityTests.cfg with catalog :=
      CompatibilityTests.cfg.catalog ++ CompatibilityTests.cfg.catalog } [] [] .configuration),
  ("parallel.refused.conflict-unchanged", refusedUnchanged CompatibilityTests.cfg
    [CompatibilityTests.left] [CompatibilityTests.left]
    (.conflict .writeWrite CompatibilityTests.aliceUSD)),
  ("parallel.refused.structural-unchanged", refusedUnchanged CompatibilityTests.cfg
    [{ CompatibilityTests.left with operation := ⟨999⟩ }] [CompatibilityTests.right]
    (.structural .left ⟨0, .interface .unknownOperation⟩))]

end DefiKernel.Parallel.ExecutionTests


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


/-! Named bounded comparisons against direct complete ledger, capability, receipt and output
expectations. Equality between implementations is supplementary to the independent oracles. -/
namespace DefiKernel.Parallel.Tests
open Typed Composition Typed.Examples Parallel.Examples

def basic := runParallel cfg boundaries initial [usd 3] [shares 4]
def peerRuns := runParallel cfg boundaries initial [usd 11] [shares 4]
def prefixKept := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4]
def dualRefusal := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
def routingForeign := source (usd 0) 1
def routingOwn := source (usd 0) 0
def routingRightOwn := source (shares 0) 1

def routeExpected (consumer : I) (q finalBob : ℚ) : Obs := observed [leftEvent 0 3 3,
  transferEvent 1 consumer aliceUSD bobUSD q [output 1 0 .usd finalBob]]
def rightRouteExpected : Obs := observed [rightEvent 0 4 4,
  transferEvent 1 routingRightOwn vaultShare aliceShare 4 [output 1 1 .share 8]]
def routeForeignExpected : Obs := observed [leftEvent 0 3 3]
  (failure 1 routingForeign (.interface .unavailableOutput))
def routeForeign := runParallel sameAssetCfg boundaries initial [usd 3, routingForeign] [peerUSD 4]

def supplyRun := runParallel supplyCfg boundaries initial [usd 2] [shares (-3)]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]
def statefulRun := runParallel statefulCfg boundaries initial [usd 0, usd 0, usd 0] [shares 4]
def statefulExpected := observed [statefulEvent 0 5 5, statefulEvent 1 (5 / 2) (15 / 2)]
  (failure 2 (usd 0) (.kernel .guard))
def stateSupplyCfg := config usdTransfer statefulSupply [bobUSD] [vaultShare]
def stateSupplyExpected := observed [statefulSupplyEvent 0 10 30, statefulSupplyEvent 1 15 45]

def admissionRefused (actual : R) (reason : AdmissionFailure Party Asset Domain)
    (expected : W := initial) : Bool :=
  match actual with
  | .refused actualReason actualWorld =>
    decide (actualReason = reason) && worldEq actualWorld expected
  | .executed _ => false

def serialChecks (label : String) (config : Config Party Asset Domain)
    (binding : ParallelBoundary Party Asset Domain) (world : W) (left right : B)
    (balance : C → ℚ) (expectedLeft expectedRight : Obs) (expectedStore : Store := store) :
    List (String × Bool) := [
  (label ++ ".lr.complete", matchesExpected (runSerialLR config binding world left right)
    balance expectedLeft expectedRight expectedStore),
  (label ++ ".rl.complete", matchesExpected (runSerialRL config binding world left right)
    balance expectedLeft expectedRight expectedStore)]

def checks : List (String × Bool) := [
  ("parallel.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("parallel.fixture.basic.complete", matchesExpected basic (balanceTable 7 3 16 4)
    basicLeft basicRight),
  ("parallel.fixture.same-asset.complete", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3] [peerUSD 4])
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5])),
  ("parallel.fixture.refusal.peer-runs", matchesExpected peerRuns (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.prefix-kept", matchesExpected prefixKept (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.dual", matchesExpected dualRefusal (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds)))),
  ("parallel.fixture.refusal.guard", matchesExpected
    (runParallel cfg boundaries initial [usd (-1)] [shares 4]) (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd (-1)) (.kernel .guard))) basicRight),
  ("parallel.fixture.refusal.input-unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    matchesExpected (runParallel cfg boundaries initial [wrong] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight),
  ("parallel.fixture.refusal.missing-capability", let missing := {usd 3 with capabilityIds := []}
    matchesExpected (runParallel cfg boundaries initial [missing] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight),
  ("parallel.fixture.empty.right", matchesExpected
    (runParallel cfg boundaries initial [usd 3] []) (balanceTable 7 3 20 0)
      basicLeft (observed [])),
  ("parallel.fixture.empty.left", matchesExpected
    (runParallel cfg boundaries initial [] [shares 4]) (balanceTable 10 0 16 4)
      (observed []) basicRight),
  ("parallel.fixture.empty.both", matchesExpected
    (runParallel cfg boundaries initial [] []) (balanceTable 10 0 20 0)
      (observed []) (observed [])),
  ("parallel.fixture.routing.peer-only", matchesExpected routeForeign
    (balanceTable 7 3 20 0 16 5) routeForeignExpected (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.funded-literal", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4])
    (balanceTable 2 8 20 0 16 5) (observed [leftEvent 0 3 3, leftEvent 1 5 8])
      (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.own-history", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, routingOwn] [peerUSD 4])
    (balanceTable 4 6 20 0 16 5) (routeExpected routingOwn 3 6) (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.both-own-history", matchesExpected
    (runParallel cfg boundaries initial [usd 3, routingOwn] [shares 4, routingRightOwn])
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected),
  ("parallel.fixture.routing.shared-qualified-key", matchesExpected
    (runParallel sharedReadCfg boundaries initial [noOpInvocation] [noOpInvocation])
    (balanceTable 10 0 20 0) sharedReadExpected sharedReadExpected),
  ("parallel.fixture.boundary.local-identity", matchesExpected
    (runParallel timedCfg timedBoundaries initial timedLeft timedRight)
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight),
  ("parallel.fixture.capability.revoked", matchesExpected
    (runParallel cfg boundaries revokedInitial [usd 3] [shares 4])
    (balanceTable 7 3 20 0) basicLeft
      (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore),
  ("parallel.fixture.capability.actual-revoke", decide
    (revokeCapability cfg.authority adminContext store ⟨2⟩ = .ok revokedStore)),
  ("parallel.fixture.capability.reusable-shared-grant",
    let l := {usd 3 with parties := [.alice, .bob]}
    let r := {usd 4 with parties := [.vault, .pool]}
    matchesExpected (runParallel reusableCfg boundaries initial [l] [r])
      (balanceTable 7 3 20 0 16 5)
      (observed [transferEvent 0 l aliceUSD bobUSD 3 []])
      (observed [transferEvent 0 r vaultUSD poolUSD 4 []])),
  ("parallel.fixture.supply.complete", matchesExpected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight),
  ("parallel.fixture.supply.both-receipts", match supplyRun with
    | .refused _ _ => false
    | .executed result => decide (∀ d a, result.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("parallel.fixture.supply.prefix-refusal", matchesExpected
    (runParallel supplyCfg boundaries initial [usd 2, usd (-13)] [shares (-3)])
    (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight),
  ("parallel.fixture.stateful.prefix", matchesExpected statefulRun
    (balanceTable (5 / 2) (15 / 2) 16 4)
    statefulExpected basicRight),
  ("parallel.fixture.stateful.supply", matchesExpected
    (runParallel stateSupplyCfg boundaries initial [usd 3] [shares 0, shares 0])
    (balanceTable 7 3 45 0) basicLeft stateSupplyExpected),
  ("parallel.fixture.cancelling.admission", admissionRefused
    (runParallel (config usdTransfer cancelling) boundaries initial [usd 3] [cancellingInvocation])
    (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.cancelling.funded", matchesExpected
    (runParallel (config usdTransfer cancelling) boundaries initial [] [cancellingInvocation])
    (balanceTable 10 0 20 0) (observed []) cancellingExpected),
  ("parallel.fixture.refusal.world-preserved", admissionRefused
    (runParallel cfg boundaries initial [usd 3] [usd 3]) (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.refusal.suffix-world-preserved", let unknown := {usd 0 with operation := ⟨99⟩}
    admissionRefused (runParallel cfg boundaries initial [usd 3, unknown] [shares 4])
      (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("parallel.fixture.raw-context-differs", match basic,
      runSerialLR cfg boundaries initial [usd 3] [shares 4] with
    | .executed p, .executed s =>
      observationsEqual basic (runSerialLR cfg boundaries initial [usd 3] [shares 4]) &&
      match p.right.events, s.right.events with
      | pe :: _, se :: _ => !worldEq pe.before se.before
      | _, _ => false
    | _, _ => false)
  ] ++
  serialChecks "parallel.fixture.basic" cfg boundaries initial [usd 3] [shares 4]
    (balanceTable 7 3 16 4) basicLeft basicRight ++
  serialChecks "parallel.fixture.prefix" cfg boundaries initial [usd 3, usd 8] [shares 4]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.routing" sameAssetCfg boundaries initial
    [usd 3, routingForeign] [peerUSD 4] (balanceTable 7 3 20 0 16 5)
    routeForeignExpected (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.boundary" timedCfg timedBoundaries initial timedLeft timedRight
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight ++
  serialChecks "parallel.fixture.supply" supplyCfg boundaries initial [usd 2] [shares (-3)]
    (balanceTable 12 0 17 0) supplyLeft supplyRight ++
  serialChecks "parallel.fixture.stateful" statefulCfg boundaries initial [usd 0, usd 0, usd 0]
    [shares 4] (balanceTable (5 / 2) (15 / 2) 16 4) statefulExpected basicRight ++
  serialChecks "parallel.fixture.revoked" cfg boundaries revokedInitial [usd 3] [shares 4]
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore ++
  serialChecks "parallel.fixture.same-asset" sameAssetCfg boundaries initial [usd 3] [peerUSD 4]
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.peer-runs" cfg boundaries initial [usd 11] [shares 4]
    (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.dual" cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds))) ++
  serialChecks "parallel.fixture.both-own-history" cfg boundaries initial
    [usd 3, routingOwn] [shares 4, routingRightOwn]
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected ++
  serialChecks "parallel.fixture.stateful-supply" stateSupplyCfg boundaries initial
    [usd 3] [shares 0, shares 0] (balanceTable 7 3 45 0) basicLeft stateSupplyExpected ++
  serialChecks "parallel.fixture.shared-qualified-key" sharedReadCfg boundaries initial
    [noOpInvocation] [noOpInvocation] (balanceTable 10 0 20 0)
    sharedReadExpected sharedReadExpected ++
  serialChecks "parallel.fixture.supply-prefix" supplyCfg boundaries initial
    [usd 2, usd (-13)] [shares (-3)] (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight

end DefiKernel.Parallel.Tests


/-! Complete named runtime inventory. Source mutation projections execute this same driver. -/
namespace DefiKernel.Parallel

def runtimeChecks : List (String × Bool) :=
  CompatibilityTests.checks ++ ObservationTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty parallel runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate parallel runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Parallel runtime comparisons failed: {failed}")

end DefiKernel.Parallel
