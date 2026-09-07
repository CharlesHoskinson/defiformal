Independently review DeFiFormal Sprint4 FOUNDATION scope at revision 5107c7fda408958bfbc01062e317797e77b81606. You are reviewing supplied exact source and evidence; no independent execution is claimed. Use the supplied bundle; do not load skills, tools, other filesystem content or web pages. If this prompt is offloaded you may read only that prompt file. Return <=900 words: verdict ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES; severity-ranked actionable findings with exact file/declaration; distinguish actual bugs from declared future work. Review proofs for stated theorem scope, executable semantics, test sensitivity/masking and trust-boundary claims. Do not approve missing evidence as though it ran.

Approved scope: reusable parametric Party/Asset/Domain identities; closed first-order dimension-indexed AST, exact rational arithmetic and explicit undefined division refusal; dynamic argument and observation unit checks; conservative expression reads including inactive branches; proof of expression-result locality including refusals. Separate authenticated actor/domain context, immutable admin/operation-domain mapping; issue/use/revoke capabilities with live/holder/domain/operation/exact resource binding, fresh permanent list IDs and tombstones. Duplicate presented IDs confer no extra authority. No unrestricted function constructor in expressions/operation bodies. Capability-store authenticity, registry/admin truth and context authentication are trusted boundary inputs; this is not digital-signature verification, allowance consumption, delegation, replay prevention or operation-wide noninterference. Amount expressions may be signed; explicit Quantity and State carry nonnegativity; operation libraries must guard requested quantity separately. Claims are vocabulary only, lifecycle deferred. Task3 executor and Task4 financial examples are separate reviews and are not yet claimed accepted here.

Evidence: fresh lake build ExprTests AuthorityTests exit0 (901 jobs); 32 expression comparisons and37 authority comparisons true; 3 #check_failure terms reject mixed assets, reversed price and implicit debt conversion. Such diagnostic text can pretty-print sorry placeholders but creates no accepted proof. Imported-module axiom audit via existing #audit_axioms DefiKernel.Typed: 389/389 theorem declarations and610/610 supplemental declarations, forbidden0; allowlist only propext, Classical.choice, Quot.sound. 9 named type/expr and16 named authority theorem endpoints, generated declarations explain higher totals. Runtime mutation evidence is pending and will be reviewed with final integration, not assumed from current source. No old proof or corpus files changed.


Source SHA256 inventory:
{
  "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
  "lean/DefiKernel/Typed/Expr.lean": "8b88e80b9cd05b7e134a443507d010c268a553fdcbcaf8f24b6c81a5c0236595",
  "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
  "lean/DefiKernel/Typed/ExprTests.lean": "821b02c27c9dfd7b7591af43c7a18d1c5f8fa79196cb8c438087ee058df38842",
  "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77"
}

===== lean/DefiKernel/Typed/Types.lean =====
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

-- BEGIN PROOFS

theorem numericRat_numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) :
    numericRat u (numericValue u q) = q := by cases u <;> rfl

theorem numericValue_numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) :
    numericValue u (numericRat u v) = v := by cases u <;> rfl

end DefiKernel.Typed


===== lean/DefiKernel/Typed/Expr.lean =====
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


===== lean/DefiKernel/Typed/Authority.lean =====
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


===== lean/DefiKernel/Typed/ExprTests.lean =====
import DefiKernel.Typed.Expr
import Mathlib.Tactic.NormNum

/-! Executed expression checks and kernel-checked examples. These are reference examples,
not deployed-protocol fidelity tests. -/
namespace DefiKernel.Typed
namespace ExprTests

inductive TestAsset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

instance : Fintype TestAsset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩

abbrev E := Expr Bool TestAsset Bool []
abbrev Context := EvalContext Bool TestAsset Bool []

def priceKey : ObservationKey Bool := ⟨false, ⟨0⟩⟩
def otherKey : ObservationKey Bool := ⟨false, ⟨1⟩⟩
def usdCell : CellRef Bool TestAsset Bool TestAsset.usd := ⟨false, .caller⟩

def initialState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, false, TestAsset.usd) then 10 else 0, by
    intro c; split <;> decide⟩

def changedState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, true, TestAsset.usd) then 99 else initialState.balance c, by
    intro c; split
    · decide
    · exact initialState.nonneg c⟩

def environment : Environment TestAsset Bool := fun key ↦
  if key = priceKey then some ⟨⟨.price TestAsset.collateral TestAsset.usd, 2⟩, 20⟩ else none

def context : Context := ⟨initialState, environment, false, [true], .nil, 25⟩
def changedContext : Context := { context with state := changedState }
def missingContext : Context := { context with env := fun _ ↦ none }
def wrongUnitContext : Context :=
  { context with env := fun _ ↦ some ⟨⟨.scalar, 2⟩, 20⟩ }

def priced : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.collateral TestAsset.usd) (.lit 3) (.observe ⟨priceKey⟩)

def debtValued : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.debt TestAsset.usd) (.lit 7) (.lit 1)

def shares : E (.amount TestAsset.share) :=
  .binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 2)

def freshness : E .bool :=
  .binary (.le .scalar) (.binary (.sub .scalar) .now (.timestamp priceKey)) (.lit 10)

def ledgerRead : E (.amount TestAsset.usd) := .balance usdCell

def withInactiveRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.observe ⟨otherKey⟩)

def withInactiveStateRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.balance ⟨false, .literal true⟩)

def badParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 2⟩
def validParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 0⟩

def argumentValue (values : List (PackedValue TestAsset)) : Except EvalFailure ℚ := do
  let args ← Args.check [.amount TestAsset.usd] values
  return args.get .here

def checks : List (String × Bool) := [
  ("expr_exact_price_conversion", decide (priced.eval context = .ok 6)),
  ("expr_explicit_debt_valuation", decide (debtValued.eval context = .ok 7)),
  ("expr_inverse_price_conversion", decide (shares.eval context = .ok 5)),
  ("expr_exact_fractional_conversion", decide
    ((Expr.binary (.convert TestAsset.collateral TestAsset.usd) (.lit (1 / 3)) (.lit (3 / 2)) :
      E (.amount TestAsset.usd)).eval context = .ok (1 / 2))),
  ("expr_same_unit_addition", decide
    ((Expr.binary (.add (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 5)),
  ("expr_scalar_scaling", decide
    ((Expr.binary (.scale (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 6)),
  ("expr_signed_negation", decide
    ((Expr.unary (.neg (.amount TestAsset.usd)) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (-2))),
  ("expr_safe_scalar_division", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (3 / 2))),
  ("expr_zero_scalar_division_refused", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero)),
  ("expr_safe_ratio", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E .scalar).eval context = .ok (3 / 2))),
  ("expr_zero_ratio_refused", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E .scalar).eval context = .error .divisionByZero)),
  ("expr_zero_inverse_price_refused", decide
    ((Expr.binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 0) :
      E (.amount TestAsset.share)).eval context = .error .divisionByZero)),
  ("expr_missing_observation_refused", decide
    (priced.eval missingContext = .error .missingObservation)),
  ("expr_wrong_observation_unit_refused", decide
    (priced.eval wrongUnitContext = .error .observationUnit)),
  ("expr_tracked_freshness", decide (freshness.eval context = .ok true)),
  ("expr_stale_observation", decide (freshness.eval { context with now := 40 } = .ok false)),
  ("expr_missing_timestamp_refused", decide
    ((Expr.timestamp priceKey : E .scalar).eval missingContext = .error .missingObservation)),
  ("expr_fresh_time_tracked", decide (.currentTime ∈ freshness.envReads)),
  ("expr_timestamp_observation_tracked", decide (.observation priceKey ∈ freshness.envReads)),
  ("expr_inactive_environment_branch_tracked", decide
    (.observation otherKey ∈ withInactiveRead.envReads)),
  ("expr_inactive_state_branch_tracked", decide (withInactiveStateRead.stateReads.length = 2)),
  ("expr_inactive_missing_branch_not_evaluated", decide (withInactiveRead.eval context = .ok 10)),
  ("expr_successful_party_lookup", decide (validParty.eval context = .ok 0)),
  ("expr_failed_party_lookup_refused", decide (badParty.eval context = .error .partyArgument)),
  ("expr_concrete_read_resolution", decide
    (ledgerRead.resolveStateReads false [] = .ok [(false, false, TestAsset.usd)])),
  ("expr_footprint_party_lookup_refused", decide
    (badParty.resolveStateReads false [true] = .error .partyArgument)),
  ("expr_checked_argument", decide (argumentValue [⟨.amount TestAsset.usd, 7⟩] = .ok 7)),
  ("expr_wrong_argument_unit_refused", decide
    (argumentValue [⟨.amount TestAsset.debt, 7⟩] = .error .argumentUnit)),
  ("expr_missing_argument_refused", decide (argumentValue [] = .error .argumentCount)),
  ("expr_excess_argument_refused", decide
    (argumentValue [⟨.amount TestAsset.usd, 7⟩, ⟨.amount TestAsset.usd, 8⟩] =
      .error .argumentCount)),
  ("expr_unrelated_balance_change", decide
    (ledgerRead.eval changedContext = ledgerRead.eval context)),
  ("expr_read_change_observed", decide
    (ledgerRead.eval { context with caller := true } = .ok 0))
]

end ExprTests

-- BEGIN PROOFS

namespace ExprTests

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

/-- This is a kernel-checked exact arithmetic fact, separate from the executed comparisons. -/
theorem price_conversion_exact : priced.eval context = .ok 6 := by
  norm_num [priced, Expr.eval, readObservation, context, environment, BinaryOp.eval,
    bind, Except.bind]

theorem inverse_price_exact : shares.eval context = .ok 5 := by
  norm_num [shares, Expr.eval, BinaryOp.eval, bind, Except.bind]

theorem zero_division_refused :
    (Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero := by decide

/-- Read dependence transports the result without evaluating the arithmetic expression. -/
theorem unrelated_balance_preserved : ledgerRead.eval context = ledgerRead.eval changedContext := by
  apply ledgerRead.eval_congr context changedContext rfl
  · intro ref href
    simp only [ledgerRead, Expr.stateReads, List.mem_singleton] at href
    subst ref
    rfl
  · intro key hkey
    simp [ledgerRead, Expr.envReads] at hkey

-- These commands must fail to elaborate their terms. Runtime unit checks are separate above.
#check_failure (Expr.binary (.add (.amount TestAsset.usd)) ledgerRead
  (.lit 1 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.convert TestAsset.collateral TestAsset.usd)
  (.lit 1 : E (.amount TestAsset.collateral))
  (.lit 2 : E (.price TestAsset.usd TestAsset.collateral)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.scale (.amount TestAsset.debt)) (.lit 1)
  (.lit 2 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

end ExprTests
end DefiKernel.Typed


===== lean/DefiKernel/Typed/AuthorityTests.lean =====
import DefiKernel.Typed.Authority

namespace DefiKernel.Typed
namespace AuthorityTests

abbrev P := Fin 3
abbrev A := Fin 2
abbrev D := Fin 2

def config : AuthorityConfig P D :=
  ⟨fun d ↦ if d = 0 then 0 else 2,
   fun op ↦ if op = ⟨0⟩ ∨ op = ⟨2⟩ then some 0 else if op = ⟨1⟩ then some 1 else none⟩

def admin : InvocationContext P D := ⟨0, 0⟩
def holder : InvocationContext P D := ⟨1, 0⟩
def foreignAdmin : InvocationContext P D := ⟨2, 1⟩
def empty : CapabilityStore P A D := .empty

def grant (right : Right P A D := .invoke) : Grant P A D := ⟨1, 0, ⟨0⟩, right⟩

def issued := issueCapability config admin empty (grant .invoke)

def store : CapabilityStore P A D :=
  match issued with
  | .ok (_, s) => s
  | .error _ => empty

def debit : Right P A D := .debit (0, 1, 0)
def supply : Right P A D := .changeSupply 0 0

def issueMore : Except AuthorityFailure (CapabilityStore P A D) := do
  let (_, s) ← issueCapability config admin store (grant debit)
  let (_, s) ← issueCapability config admin s (grant supply)
  return s

def full : CapabilityStore P A D := issueMore.toOption.getD empty

def revoked := revokeCapability config admin full ⟨1⟩
def afterRevoke : CapabilityStore P A D := revoked.toOption.getD empty

def reissued := issueCapability config admin afterRevoke (grant debit)
def afterReissue : CapabilityStore P A D :=
  match reissued with
  | .ok (_, s) => s
  | .error _ => empty

def sameRequest (s : CapabilityStore P A D) : Bool :=
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ .invoke &&
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ debit

def foreignIssue := issueCapability config foreignAdmin empty
  (⟨1, 1, ⟨1⟩, .invoke⟩ : Grant P A D)

def wrongOperationIssue := issueCapability config admin empty
  { grant .invoke with operation := ⟨2⟩ }

def issueUse (result : Except AuthorityFailure (CapabilityId × CapabilityStore P A D))
    (ctx : InvocationContext P D) (op : OperationId) (right : Right P A D) : Bool :=
  match result with
  | .error _ => false
  | .ok (id, s) => hasAuthority s [id] ctx op right

/-- Named comparisons run public issue/revoke/use definitions. These are development tests. -/
def checks : List (String × Bool) := [
  ("authority_issue_succeeds_with_id_zero", decide (issued = .ok (⟨0⟩, ⟨[⟨grant .invoke, true⟩]⟩))),
  ("authority_unauthorized_issuer", decide (issueCapability config holder empty (grant .invoke) =
    .error .unauthorizedAdmin)),
  ("authority_issuer_wrong_authenticated_domain", decide
    (issueCapability config ⟨0, 1⟩ empty (grant .invoke) = .error .unauthorizedAdmin)),
  ("authority_unknown_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨99⟩ } = .error .operationDomain)),
  ("authority_foreign_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨1⟩ } = .error .operationDomain)),
  ("authority_foreign_debit_resource_grant", decide (issueCapability config admin empty
    (grant (.debit (1, 1, 0))) = .error .resourceDomain)),
  ("authority_foreign_supply_resource_grant", decide (issueCapability config admin empty
    (grant (.changeSupply 1 0)) = .error .resourceDomain)),
  ("authority_invoke_live_holder", hasAuthority full [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_debit_live_holder", hasAuthority full [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_supply_live_holder", hasAuthority full [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_wrong_holder", !hasAuthority full [⟨0⟩] ⟨2, 0⟩ ⟨0⟩ .invoke),
  ("authority_wrong_authenticated_domain", !hasAuthority full [⟨0⟩] ⟨1, 1⟩ ⟨0⟩ .invoke),
  ("authority_unknown_capability", !hasAuthority full [⟨99⟩] holder ⟨0⟩ .invoke),
  ("authority_empty_capability_request", !hasAuthority full [] holder ⟨0⟩ .invoke),
  ("authority_wrong_operation", !hasAuthority full [⟨0⟩] holder ⟨2⟩ .invoke),
  ("authority_wrong_debit_owner", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 2, 0))),
  ("authority_wrong_debit_asset", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 1, 1))),
  ("authority_wrong_supply_asset", !hasAuthority full [⟨2⟩] holder ⟨0⟩ (.changeSupply 0 1)),
  ("authority_right_kind_mismatch", !hasAuthority full [⟨0⟩] holder ⟨0⟩ debit),
  ("authority_duplicates_preserve_success", hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_duplicates_add_no_right", !hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ debit),
  ("authority_unauthorized_revoker", decide (revokeCapability config holder full ⟨1⟩ =
    .error .unauthorizedAdmin)),
  ("authority_revoker_wrong_authenticated_domain", decide
    (revokeCapability config ⟨0, 1⟩ full ⟨1⟩ = .error .unauthorizedAdmin)),
  ("authority_unknown_revocation", decide (revokeCapability config admin full ⟨99⟩ =
    .error .unknownCapability)),
  ("authority_same_request_before_revoke", sameRequest full),
  ("authority_revoke_accepted", decide (revoked = .ok
    ⟨[⟨grant .invoke, true⟩, ⟨grant debit, false⟩, ⟨grant supply, true⟩]⟩)),
  ("authority_same_request_after_revoke", !sameRequest afterRevoke),
  ("authority_revoke_keeps_invoke_sibling", hasAuthority afterRevoke [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_revoke_keeps_supply_sibling", hasAuthority afterRevoke [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_revoke_is_idempotent", decide
    (revokeCapability config admin afterRevoke ⟨1⟩ = .ok afterRevoke)),
  ("authority_reissue_receives_fresh_id_three", decide
    (reissued = .ok (⟨3⟩, ⟨afterRevoke.entries ++ [⟨grant debit, true⟩]⟩))),
  ("authority_reissued_right_usable_by_new_id", hasAuthority afterReissue [⟨3⟩] holder ⟨0⟩ debit),
  ("authority_old_revoked_id_remains_unusable", !hasAuthority afterReissue [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_foreign_grant_positive_sibling", issueUse foreignIssue ⟨1, 1⟩ ⟨1⟩ .invoke),
  ("authority_foreign_grant_cannot_authorize_local_context",
    !issueUse foreignIssue holder ⟨1⟩ .invoke),
  ("authority_other_operation_positive_sibling", issueUse wrongOperationIssue holder ⟨2⟩ .invoke),
  ("authority_other_operation_cannot_authorize_original",
    !issueUse wrongOperationIssue holder ⟨0⟩ .invoke)]

end AuthorityTests

-- BEGIN PROOFS

#eval AuthorityTests.checks
#eval AuthorityTests.checks.length

theorem authority_checks_pass : AuthorityTests.checks.all Prod.snd = true := by decide

end DefiKernel.Typed
