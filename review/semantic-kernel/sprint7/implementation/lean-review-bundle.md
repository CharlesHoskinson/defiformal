# Native independent Sprint 7 Lean implementation review

Candidate 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c; approved plan bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d.

Review actual implementation source against the complete specs/design below. User requires native Grok and Fable independent audits, stock GPT-6 implementation, no Foreman. This scope is Lean semantics, generic proofs, reference examples, runtime checks and imported axiom coverage. The new mutation runner and comprehensive final evidence receive a separate native evidence audit after their frozen runs finish; do not invent approval for that pending scope. No previous implementation reviews supplied.

Return a substantive plain-text final verdict ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES, material realistic blockers with exact file/declaration and smallest fix, then limits and scope. Source-only audit: no tools available; do not claim builds or proof execution you did not perform. No tool markup or hidden analysis. Advisory review is not mathematical proof. Budget initial + one targeted fix review; extend only for concrete unresolved finding. Threat model is collaborator mistakes, stale state/history/index, omitted obligations and false pass, not attacker rewriting every source/evidence.

Focus: one real evolving world and actual success/refusal attempts, permanent branchlocal refusal with peercontinuation, own histories and stable localboundaries; generic trace continuity/localorder; perasset accounting ofactual supply, pointofuse authority, fixedstore and supportedframe; initialized noncircular R/G with all ownworld/historypremises; UNIVERSAL disjointschedule recovery including failures (not just finite examples); complete canonical fields vs intentionallyignored foreignraw eventworlds/order; complete independent financialexpected values andnonvacuous counterexamples. Consumed static slots can exceedbranchlength in internal totalizedprefix runner; public schedulechecksreject. Successful index equals consumed before selectedactiveattempt, not afterrefusal/exhaustedskip. No claim of arbitrarysharedstate commutation, atomicrollback, capabilitieschanging insidebranches, fairness/liveness or deployedfidelity.

Fresh parent runtime/axiom logs below are supplied evidence, not independent reviewer execution. Assess exact statements/real input linkage. Fulllegacy checks andproductionmutations are pending separate evidence scope.

--- BEGIN FILE lean/DefiKernel/Typed/Types.lean ---
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

--- END FILE lean/DefiKernel/Typed/Types.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Expr.lean ---
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

--- END FILE lean/DefiKernel/Typed/Expr.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Authority.lean ---
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

--- END FILE lean/DefiKernel/Typed/Authority.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Transition.lean ---
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

--- END FILE lean/DefiKernel/Typed/Transition.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Interfaces.lean ---
import DefiKernel.Typed.Transition

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

--- END FILE lean/DefiKernel/Composition/Interfaces.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Contracts.lean ---
import DefiKernel.Typed.Transition

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

--- END FILE lean/DefiKernel/Composition/Contracts.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Execution.lean ---
import DefiKernel.Composition.Interfaces
import DefiKernel.Composition.Contracts

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

--- END FILE lean/DefiKernel/Composition/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Compatibility.lean ---
import DefiKernel.Composition.Execution

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

--- END FILE lean/DefiKernel/Parallel/Compatibility.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Schedule.lean ---
import DefiKernel.Parallel.Compatibility

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

--- END FILE lean/DefiKernel/Interleaving/Schedule.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Sequence.lean ---
import DefiKernel.Composition.Execution

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

--- END FILE lean/DefiKernel/Composition/Sequence.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Observation.lean ---
import DefiKernel.Composition.Sequence

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

--- END FILE lean/DefiKernel/Parallel/Observation.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Execution.lean ---
import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Observation

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

--- END FILE lean/DefiKernel/Parallel/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Examples.lean ---
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

--- END FILE lean/DefiKernel/Typed/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Examples.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Typed.Examples

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

--- END FILE lean/DefiKernel/Parallel/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/ScheduleTests.lean ---
import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Examples

/-! Exact schedule mismatch and ordered admission controls. Financial execution controls ensure
the accepted overlap example is funded and authorized; admission itself performs no transfer. -/
namespace DefiKernel.Interleaving.ScheduleTests
open Typed Composition Parallel Typed.Examples Parallel.Examples

def accepted {E X : Type} (result : Except E X) : Bool :=
  match result with
  | .ok _ => true
  | .error _ => false

def refused (actual : Except (Interleaving.AdmissionFailure Party Asset Domain)
    (Footprint Party Asset Domain × Footprint Party Asset Domain))
    (expected : Interleaving.AdmissionFailure Party Asset Domain) : Bool :=
  match actual with
  | .error reason => decide (reason = expected)
  | .ok _ => false

def unknown : I := { usd 0 with operation := ⟨99⟩ }
def invalidCfg : Config Party Asset Domain := { cfg with catalog := cfg.catalog ++ cfg.catalog }

def checks : List (String × Bool) := [
  ("interleaving.schedule.balanced", accepted (checkSchedule 2 2 [.left, .right, .left, .right])),
  ("interleaving.schedule.block-left", accepted (checkSchedule 2 2 [.left, .left, .right, .right])),
  ("interleaving.schedule.block-right", accepted
    (checkSchedule 2 2 [.right, .right, .left, .left])),
  ("interleaving.schedule.empty", accepted (checkSchedule 0 0 [])),
  ("interleaving.schedule.empty-left", accepted (checkSchedule 0 2 [.right, .right])),
  ("interleaving.schedule.empty-right", accepted (checkSchedule 2 0 [.left, .left])),
  ("interleaving.schedule.missing-right", decide
    (checkSchedule 2 2 [.left, .right, .left] = .error ⟨2, 2, 2, 1⟩)),
  ("interleaving.schedule.missing-left", decide
    (checkSchedule 2 2 [.right, .left, .right] = .error ⟨2, 1, 2, 2⟩)),
  ("interleaving.schedule.excess-left", decide
    (checkSchedule 1 1 [.left, .right, .left] = .error ⟨1, 2, 1, 1⟩)),
  ("interleaving.schedule.excess-right", decide
    (checkSchedule 1 1 [.right, .left, .right] = .error ⟨1, 1, 1, 2⟩)),
  ("interleaving.schedule.empty-extra-left", decide
    (checkSchedule 0 0 [.left] = .error ⟨0, 1, 0, 0⟩)),
  ("interleaving.schedule.empty-extra-right", decide
    (checkSchedule 0 0 [.right] = .error ⟨0, 0, 0, 1⟩)),
  ("interleaving.schedule.both-wrong-counts", decide
    (checkSchedule 1 2 [.left, .left] = .error ⟨1, 2, 2, 0⟩)),
  ("interleaving.schedule.disjoint-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] [.right, .left])),
  ("interleaving.schedule.overlap-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [usd 4] [.left, .right])),
  ("interleaving.schedule.overlap-left-funded", accepted
    (executeStep cfg (boundaries .left 0) 0 [] (.invoke (usd 3)) initial)),
  ("interleaving.schedule.overlap-right-funded", accepted
    (executeStep cfg (boundaries .right 0) 0 [] (.invoke (usd 4)) initial)),
  ("interleaving.schedule.unreachable-left-suffix", refused
    (Interleaving.admit cfg boundaries [usd 11, unknown] [shares 4] [.left, .right, .left])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.unreachable-right-suffix", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 21, unknown] [.right, .left, .right])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-configuration", refused
    (Interleaving.admit invalidCfg boundaries [unknown] [unknown] []) .configuration),
  ("interleaving.schedule.precedence-left", refused
    (Interleaving.admit cfg boundaries [usd 3, unknown] [unknown] [])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-right", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4, unknown] [])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-counts", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] []) (.schedule ⟨1, 0, 1, 0⟩)),
  ("interleaving.schedule.empty-admitted", accepted
    (Interleaving.admit cfg boundaries [] [] []))]

end DefiKernel.Interleaving.ScheduleTests

--- END FILE lean/DefiKernel/Interleaving/ScheduleTests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Execution.lean ---
import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Observation
import DefiKernel.Parallel.Execution

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

--- END FILE lean/DefiKernel/Interleaving/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Examples.lean ---
import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Examples

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

--- END FILE lean/DefiKernel/Interleaving/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Preservation.lean ---
import DefiKernel.Composition.Sequence

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

--- END FILE lean/DefiKernel/Composition/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Examples.lean ---
import DefiKernel.Composition.Preservation
import DefiKernel.Typed.Examples
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

--- END FILE lean/DefiKernel/Composition/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/ObservationTests.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Composition.Examples

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

--- END FILE lean/DefiKernel/Parallel/ObservationTests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Tests.lean ---
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.ObservationTests

/-! Named finite comparisons use direct complete expectations. They are bounded evidence. -/
namespace DefiKernel.Interleaving.Tests
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples
private def expected (actual : Interleaving.Result Party Asset Domain) (balance : C → ℚ)
    (left right : Obs) (lc rc : Nat) (s : Store := store) : Bool :=
  Interleaving.Examples.matchesExpected actual balance left right lc rc s

def observationEvent : Event Party Asset Domain := Parallel.ObservationTests.event
def observationMachine : M := ⟨initial,
  ⟨1, [observationEvent], observationEvent.result.outputs, 1, none⟩, {}, []⟩
def comparison (m : M) : Interleaving.Result Party Asset Domain := .executed [.left] m
def changedLeft (f : LocalState Party Asset Domain → LocalState Party Asset Domain) : M :=
  { observationMachine with left := f observationMachine.left }
def changedEvent (f : Event Party Asset Domain → Event Party Asset Domain) : M :=
  changedLeft fun l ↦ { l with events := [f observationEvent] }
def different (m : M) := !Interleaving.observationsEqual
  (comparison observationMachine) (comparison m)
def withFailure (n : Nat) (inv : I) (reason : Composition.Failure) :=
  changedLeft fun l ↦ {l with failure := failure n inv reason}
def compareFailures (n : Nat) (inv : I) (reason : Composition.Failure) :=
  !Interleaving.observationsEqual (comparison (withFailure 1 (usd 2) (.kernel .guard)))
    (comparison (withFailure n inv reason))
def changeOutput (out : OutputObservation Asset) :=
  different (changedEvent fun e ↦ {e with result := {e.result with outputs := [out]}})

def requestChanges : List (String × Request Party Asset Domain) := [
  ("operation", { Parallel.ObservationTests.request with operation := ⟨99⟩ }),
  ("parties", { Parallel.ObservationTests.request with parties := [.vault] }),
  ("arguments", { Parallel.ObservationTests.request with arguments := [⟨.amount .usd, 4⟩] }),
  ("capabilities", { Parallel.ObservationTests.request with capabilityIds := [] }),
  ("actor", { Parallel.ObservationTests.request with claimedActor := some .bob })]

def observationChecks : List (String × Bool) := [
  ("interleaving.observe.equal", Interleaving.observationsEqual
    (comparison observationMachine) (comparison observationMachine)),
  ("interleaving.observe.failure", different (withFailure 1 (usd 2) (.kernel .guard))),
  ("interleaving.observe.failure.reason", compareFailures 1 (usd 2) (.kernel .insufficientFunds)),
  ("interleaving.observe.failure.index", compareFailures 2 (usd 2) (.kernel .guard)),
  ("interleaving.observe.failure.step", compareFailures 1 (usd 3) (.kernel .guard)),
  ("interleaving.observe.failure.equal", !compareFailures 1 (usd 2) (.kernel .guard)),
  ("interleaving.observe.successful.index", different
    (changedLeft fun l ↦ {l with nextIndex := 2})),
  ("interleaving.observe.history", different (changedLeft fun l ↦ {l with outputs := []})),
  ("interleaving.observe.events", different (changedLeft fun l ↦ {l with events := []})),
  ("interleaving.observe.peer",
    different {observationMachine with right := observationMachine.left}),
  ("interleaving.observe.event.index", different (changedEvent fun e ↦ {e with index := 2})),
  ("interleaving.observe.event.step", different
    (changedEvent fun e ↦ {e with step := .invoke (usd 9)})),
  ("interleaving.observe.event.outputs", different (changedEvent fun e ↦
    {e with result := {e.result with outputs := []}})),
  ("interleaving.observe.output.unit", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .share, 7⟩⟩),
  ("interleaving.observe.output.value", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 8⟩⟩),
  ("interleaving.observe.output.producer", changeOutput ⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.component", changeOutput ⟨0, ⟨⟨2⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.port", changeOutput ⟨0, ⟨⟨0⟩, ⟨3⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.ledger", different {observationMachine with world := sharedInitial}),
  ("interleaving.observe.store", different {observationMachine with world := revokedInitial}),
  ("interleaving.observe.omitted.context", let altered := changedEvent fun e ↦
      { e with before := sharedInitial, result := { e.result with world := sharedInitial } }
    Interleaving.observationsEqual (comparison observationMachine)
      (.executed [.right] { altered with left := { altered.left with consumed := 9 } }))] ++
  Parallel.ObservationTests.receiptChanges.map fun (label, receipt) ↦
    ("interleaving.observe.receipt." ++ label.replace "-" ".",
      different (changedEvent fun e ↦ {e with result := {e.result with receipt}}))

def requestChecks : List (String × Bool) := requestChanges.map fun (label, request) ↦
  ("interleaving.observe.request." ++ label,
    different (changedEvent fun e ↦ { e with result :=
      { e.result with receipt := .invoked request Parallel.ObservationTests.evaluated } }))

def checks : List (String × Bool) := [
  ("interleaving.fixture.snapshot.both.own", expected
    (runInterleaving snapshotCfg boundaries initial [usd 2, snapshotConsumer]
      [usd 1, snapshotConsumer] [.left, .right, .left, .right])
    (balanceTable 2 8 20 0)
    (observed [leftEvent 0 2 2,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 2 [output 1 0 .usd 5]])
    (observed [leftEvent 0 1 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 8]]) 2 2),
  ("interleaving.fixture.shared.lr", expected sharedLR (sharedBalance 7 0 3) withdrawalLeft
    (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 1),
  ("interleaving.fixture.shared.rl", expected sharedRL (sharedBalance 0 6 4)
    (observed [] (failure 0 (usd 7) (.kernel .insufficientFunds))) withdrawalRight 1 1),
  ("interleaving.fixture.shared.order", !Interleaving.observationsEqual sharedLR sharedRL),
  ("interleaving.fixture.shared.attempts", attemptsMatch sharedLR sharedLRAttempts),
  ("interleaving.fixture.replenish.funded", expected replenishLR (sharedBalance 3 7 0)
    depositExpected (observed [
      transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6],
      transferEvent 1 (peerUSD 1) vaultUSD bobUSD 1 [output 1 1 .usd 7]]) 1 2),
  ("interleaving.fixture.replenish.halted", expected replenishRL (sharedBalance 3 0 7)
    depositExpected (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 2),
  ("interleaving.fixture.replenish.attempts", attemptsMatch replenishRL replenishRLAttempts),
  ("interleaving.fixture.live.complete", expected liveRun
    (balanceTable (9 / 2) (19 / 2) 20 0 16 1) liveLeft liveRight 2 1),
  ("interleaving.fixture.snapshot.own", expected snapshotRun (balanceTable 3 7 20 0)
    snapshotLeft snapshotRight 2 1),
  ("interleaving.fixture.snapshot.distinct", match snapshotRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (m.left.outputs.head? = some (output 0 0 .usd 3) ∧
        m.right.outputs.head? = some (output 0 0 .usd 4))),
  ("interleaving.fixture.history.peer.only", expected peerOnlyRun
    (balanceTable 7 3 20 0 16 5) peerOnlyLeft peerOnlyRight 2 1),
  ("interleaving.fixture.history.funded.literal", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 2 8 20 0 16 5)
    (observed [leftEvent 0 3 3, leftEvent 1 5 8]) peerOnlyRight 2 1),
  ("interleaving.fixture.history.own", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, snapshotConsumer] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 4 6 20 0 16 5)
    (observed [leftEvent 0 3 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 6]]) peerOnlyRight 2 1),
  ("interleaving.fixture.refusal.immediate", expected immediateRun (balanceTable 10 0 14 6)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) continuedRight 2 2),
  ("interleaving.fixture.refusal.middle", expected middleRun (balanceTable 7 3 14 6)
    middleLeft continuedRight 3 2),
  ("interleaving.fixture.refusal.dual", expected dualRun (balanceTable 7 3 16 4)
    middleLeft (observed [rightEvent 0 4 4]
      (failure 1 (shares 17) (.kernel .insufficientFunds))) 3 3),
  ("interleaving.fixture.refusal.skips", match immediateRun, middleRun, dualRun with
    | .executed _ i, .executed _ m, .executed _ d =>
      decide (i.attempts.length = 3 ∧ m.attempts.length = 4 ∧ d.attempts.length = 4)
    | _, _, _ => false),
  ("interleaving.fixture.empty.both", expected
    (runInterleaving cfg boundaries initial [] [] []) (balanceTable 10 0 20 0)
    (observed []) (observed []) 0 0),
  ("interleaving.fixture.empty.left", expected
    (runInterleaving cfg boundaries initial [] [shares 4] [.right]) (balanceTable 10 0 16 4)
    (observed []) basicRight 0 1),
  ("interleaving.fixture.empty.right", expected
    (runInterleaving cfg boundaries initial [usd 3] [] [.left]) (balanceTable 7 3 20 0)
    basicLeft (observed []) 1 0),
  ("interleaving.fixture.supply.complete", expected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight 3 1),
  ("interleaving.fixture.supply.aggregate", match supplyRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (∀ d a, m.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("interleaving.fixture.collateral.protected", match sharedLR, liveRun, supplyRun with
    | .executed _ a, .executed _ b, .executed _ c => decide
      (a.world.state.balance protectedCell = 9 ∧ b.world.state.balance protectedCell = 9 ∧
        c.world.state.balance protectedCell = 9)
    | _, _, _ => false),
  ("interleaving.fixture.boundary.local", expected
    (runInterleaving timedCfg timedBoundaries initial timedLeft timedRight
      [.right, .left, .left, .right]) (balanceTable 8 2 14 6)
    timedExpectedLeft timedExpectedRight 2 2),
  ("interleaving.fixture.capability.revoked", expected
    (runInterleaving cfg boundaries revokedInitial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) 1 1 revokedStore),
  ("interleaving.fixture.capability.live", expected
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 16 4) basicLeft basicRight 1 1),
  ("interleaving.fixture.capability.unauthorized", let missing := {usd 3 with capabilityIds := []}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight 1 1),
  ("interleaving.fixture.capability.debit", let missing := {usd 3 with capabilityIds := [⟨0⟩]}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedDebit))) basicRight 1 1),
  ("interleaving.fixture.history.unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    expected (runInterleaving cfg boundaries initial [wrong] [shares 4] [.right, .left])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight 1 1),
  ("interleaving.fixture.malformed.suffix", let bad := {usd 1 with operation := ⟨99⟩}
    Interleaving.Examples.admissionRefused
      (runInterleaving cfg boundaries initial [usd 11, bad] [shares 4] [.left, .right, .left])
      (.structural .left ⟨1, .interface .unknownOperation⟩) [.left, .right, .left]),
  ("interleaving.fixture.malformed.schedule", Interleaving.Examples.admissionRefused
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.left])
    (.schedule ⟨1, 1, 1, 0⟩) [.left])
  ] ++ schedules.flatMap (fun (label, schedule) ↦
    let actual := runInterleaving cfg boundaries initial disjointLeft disjointRight schedule
    let refused := runInterleaving cfg boundaries initial [usd 3, usd 8] disjointRight schedule
    [("interleaving.fixture.disjoint." ++ label ++ ".complete", expected actual
        (balanceTable 5 5 14 6) disjointLeftExpected continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".parallel", matchesParallel actual
        (runParallel cfg boundaries initial disjointLeft disjointRight)),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.complete", expected refused
        (balanceTable 7 3 14 6) middleLeft continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.parallel", matchesParallel refused
        (runParallel cfg boundaries initial [usd 3, usd 8] disjointRight))]) ++
  observationChecks ++ requestChecks

end DefiKernel.Interleaving.Tests

--- END FILE lean/DefiKernel/Interleaving/Tests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Audit.lean ---
import DefiKernel.Interleaving.ScheduleTests
import DefiKernel.Interleaving.Tests

/-! Complete named runtime inventory. These are finite development comparisons, separate from
the generic theorems and the imported axiom audit in Verify.lean. -/
namespace DefiKernel.Interleaving.Audit

def checks : List (String × Bool) := ScheduleTests.checks ++ Tests.checks

def main : IO Unit := do
  let names := checks.map Prod.fst
  if checks.isEmpty || names.eraseDups.length != names.length then
    throw (IO.userError "BLOCKED: empty or duplicate interleaving inventory")
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
  let failures := (checks.filter (fun row ↦ !row.2)).length
  if failures != 0 then
    throw (IO.userError s!"Interleaving runtime comparisons failed: {failures}")

#eval main

end DefiKernel.Interleaving.Audit

--- END FILE lean/DefiKernel/Interleaving/Audit.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Soundness.lean ---
import DefiKernel.Interleaving.Execution

/-! Reachability witnesses for actual attempts, including refused calls at their original
pre-world. The final world may subsequently change through successful peer invocations. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AdvanceSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.local b).failure = some failure) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | exhausted (active : (m.local b).failure = none)
      (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries left right m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries left right m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) : Machine P A D → Prop
  | start : Reachable cfg boundaries left right initial (Interleaving.start initial)
  | next {pre post : Machine P A D} (b : BranchId)
      (previous : Reachable cfg boundaries left right initial pre)
      (step : AdvanceSound cfg boundaries left right pre b post) :
      Reachable cfg boundaries left right initial post

def AttemptSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (attempt : Attempt P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.branch attempt.index) attempt.index history
    (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

theorem advance_sound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) :
    AdvanceSound cfg boundaries left right m b (advance cfg boundaries left right m b) := by
  cases hf : (m.local b).failure with
  | some failure =>
    simpa [advance, hf] using AdvanceSound.halted (cfg := cfg) (boundaries := boundaries)
      (left := left) (right := right) (m := m) (b := b) failure hf
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none =>
      simpa [advance, hf, hs] using AdvanceSound.exhausted (cfg := cfg)
        (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
          (m.local b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, hs, he] using AdvanceSound.refused (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv reason hf hs he
      | ok result =>
        simpa [advance, hf, hs, he] using AdvanceSound.accepted (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv result hf hs he

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) (m : Machine P A D)
    (h : Reachable cfg boundaries left right initial m) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries left right m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (runPrefix cfg boundaries initial left right schedule) :=
  continueRun_reachable cfg boundaries left right initial (start initial) .start schedule

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine P A D) (b : BranchId) : (m.skip b).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine P A D) (b : BranchId) :
    (m.skip b).attempts = m.attempts := by cases b <;> rfl

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.attempts ih

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId) :
    (post.local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 := by
  cases h <;> cases b <;> cases own <;>
    simp [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId) :
    ((advance cfg boundaries left right m b).local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries left right m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) (b : BranchId) :
    ((continueRun cfg boundaries left right m schedule).local b).consumed =
      (m.local b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [show continueRun cfg boundaries left right m (next :: tail) =
      continueRun cfg boundaries left right
        (advance cfg boundaries left right m next) tail from rfl]
    rw [ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (b : BranchId) :
    ((runPrefix cfg boundaries initial left right schedule).local b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  cases b <;> simp [Interleaving.start, Machine.local]

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (h : Complete left right schedule) :
    (runPrefix cfg boundaries initial left right schedule).left.consumed = left.length ∧
    (runPrefix cfg boundaries initial left right schedule).right.consumed = right.length := by
  exact ⟨(runPrefix_consumed cfg boundaries initial left right schedule .left).trans h.1,
    (runPrefix_consumed cfg boundaries initial left right schedule .right).trans h.2⟩

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Soundness.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/LocalOrder.lean ---
import DefiKernel.Interleaving.Soundness

/-! Active local indices count successful static slots. Exhausted internal tokens consume slots
without increasing the successful index; before any real attempt the two indices agree. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (step : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ own, (m.local own).failure = none →
      (m.local own).nextIndex = min (m.local own).consumed
        (selectBranch left right own).length) :
    ∀ own, (post.local own).failure = none →
      (post.local own).nextIndex = min (post.local own).consumed
        (selectBranch left right own).length := by
  intro own active
  have hl := previous .left
  have hr := previous .right
  cases step with
  | halted failure failed =>
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch]
  | exhausted oldActive absent =>
    have hb := List.getElem?_eq_none_iff.mp absent
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch] <;> omega
  | refused inv reason oldActive selected rejected =>
    cases b <;> cases own <;>
      simp_all [Machine.refuse, Machine.setLocal, Machine.local, selectBranch]
  | accepted inv result oldActive selected executed =>
    obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
    cases b <;> cases own <;>
      dsimp [Machine.accept, Machine.setLocal, Machine.local, selectBranch] at * <;>
      simp_all <;>
      have hb' := hb <;>
      simp only [Machine.local, selectBranch] at hb' <;> omega

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).failure = none →
      (m.local b).nextIndex = min (m.local b).consumed (selectBranch left right b).length := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (b : BranchId)
    (active : (m.local b).failure = none) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    (m.local b).nextIndex = (m.local b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [h.active_index b active, min_eq_left (Nat.le_of_lt hb)]

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/LocalOrder.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Trace.lean ---
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! The global attempt chain and its branch projections are derived from real execution.
Refusal witnesses refer to the world at that attempt, not the later peer-updated final world. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AttemptChain (initial : World P A D) :
    List (Attempt P A D) → World P A D → Prop
  | empty : AttemptChain initial [] initial
  | success {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {result : StepResult P A D}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .ok result) :
      AttemptChain initial (attempts ++ [attempt]) result.world
  | refusal {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {reason : Composition.Failure}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .error reason) :
      AttemptChain initial (attempts ++ [attempt]) pre

def successfulEvent (b : BranchId) (attempt : Attempt P A D) : Option (Event P A D) :=
  if attempt.branch = b then
    match attempt.outcome with
    | .error _ => none
    | .ok result => some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩
  else none

-- BEGIN PROOFS

theorem Reachable.attempt_chain {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    AttemptChain initial m.attempts m.world := by
  induction h with
  | start => exact .empty
  | next b previous step ih =>
    cases step with
    | halted => simpa [skip_world, skip_attempts] using ih
    | exhausted => simpa [skip_world, skip_attempts] using ih
    | refused inv reason active selected rejected =>
      rw [refuse_world]
      exact .refusal ih rfl rfl
    | accepted inv result active selected executed => exact .success ih rfl rfl

theorem Reachable.branch_projection {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events = m.attempts.filterMap (successfulEvent b) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local,
        successfulEvent, List.filterMap_append]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).outputs = (m.local b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).nextIndex = (m.local b).events.length := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_order {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events.map Event.step =
      ((selectBranch left right b).take (m.local b).nextIndex).map Step.invoke := by
  induction h with
  | start => intro b; cases b <;> rfl
  | @next pre post b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    have ho := ih own
    cases step with
    | halted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | exhausted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | refused =>
      cases b <;> cases own <;>
        simpa [Machine.refuse, Machine.setLocal, Machine.local] using ho
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      have ht : (selectBranch left right b).take ((pre.local b).nextIndex + 1) =
          (selectBranch left right b).take (pre.local b).nextIndex ++ [inv] := by
        rw [hi, List.take_add_one]
        simp [selected]
      cases b <;> cases own <;>
        simp_all [Machine.accept, Machine.setLocal, Machine.local, selectBranch]

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b failure, (m.local b).failure = some failure → failure.index = (m.local b).nextIndex := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih =>
    intro own failure hf
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]
    all_goals cases hf; rfl

theorem AdvanceSound.refusal_stable {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  cases h <;> cases b <;> cases own <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_refusal_stable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := advance cfg boundaries left right m b
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex :=
  (advance_sound cfg boundaries left right m b).refusal_stable own failure failed

theorem continueRun_refusal_stable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Machine P A D) (schedule : Schedule) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := continueRun cfg boundaries left right m schedule
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  induction schedule generalizing m with
  | nil => exact ⟨failed, rfl, rfl, rfl⟩
  | cons b tail ih =>
    have first := advance_refusal_stable cfg boundaries left right m b own failure failed
    have rest := ih _ first.1
    exact ⟨rest.1, rest.2.1.trans first.2.1,
      rest.2.2.1.trans first.2.2.1, rest.2.2.2.trans first.2.2.2⟩

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Trace.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Dependency.lean ---
import DefiKernel.Composition.Contracts

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

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] in
/-- Complete expression results agree on a resolved syntactic read region. -/
theorem expression_congr_of_region {signature : List (Unit A)} {u : Unit A}
    (expression : Expr P A D signature u) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P) (args : Args signature) (now : Nat)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hr : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve caller parties = .ok c → c ∈ region) :
    expression.eval ⟨left, env, caller, parties, args, now⟩ =
      expression.eval ⟨right, env, caller, parties, args, now⟩ := by
  apply expression.eval_congr_of_resolved
    ⟨left, env, caller, parties, args, now⟩
    ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
  · intro ref hm c hc
    exact ha c (hr ref hm c hc)
  · intro key hk
    cases key <;> rfl

theorem mapM_congr_on {α β ε : Type} (xs : List α) (f g : α → Except ε β)
    (h : ∀ x ∈ xs, f x = g x) : xs.mapM f = xs.mapM g := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.mapM_cons, h x (by simp), ih (fun y hy ↦ h y (by simp [hy]))]

theorem mapM_ok_mem {α β ε : Type} (xs : List α) (f : α → Except ε β)
    (ys : List β) (h : xs.mapM f = .ok ys) :
    ∀ y ∈ ys, ∃ x ∈ xs, f x = .ok y := by
  induction xs generalizing ys with
  | nil =>
    have hy : ys = [] := (Except.ok.inj h).symm
    subst ys
    simp
  | cons x xs ih =>
    rw [List.mapM_cons] at h
    cases hx : f x <;> simp only [hx, bind, Except.bind] at h
    · contradiction
    rename_i z
    cases ht : xs.mapM f <;> simp only [ht, bind, Except.bind, pure, Except.pure] at h
    · contradiction
    cases h
    intro y hy
    rcases List.mem_cons.mp hy with rfl | hy
    · exact ⟨x, by simp, hx⟩
    · obtain ⟨a, ha, hf⟩ := ih _ ht y hy
      exact ⟨a, by simp [ha], hf⟩

theorem evaluate_congr (template : Template P A D) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P)
    (args : Args template.signature) (now : Nat)
    (h : ResolvedReadsAgree template caller parties left right) :
    template.evaluate ⟨left, env, caller, parties, args, now⟩ =
      template.evaluate ⟨right, env, caller, parties, args, now⟩ := by
  have expr {u : Unit A} (e : Expr P A D template.signature u)
      (he : ∀ ref ∈ e.stateReads, ref ∈ template.requiredStateReads) :
      e.eval ⟨left, env, caller, parties, args, now⟩ =
        e.eval ⟨right, env, caller, parties, args, now⟩ := by
    apply e.eval_congr_of_resolved
      ⟨left, env, caller, parties, args, now⟩
      ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
    · intro ref hr c hc
      exact h ref (he ref hr) c hc
    · intro key hk
      cases key <;> rfl
  have hg := expr template.guard (by intros; simp_all [Template.requiredStateReads])
  have hd := mapM_congr_on template.deltas
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure (c, a))
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure (c, a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inl (Or.inr ⟨d, hd, hr⟩))])
  have hs := mapM_congr_on template.supplyDeltas
    (fun d ↦ do
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a))
    (fun d ↦ do
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inr ⟨d, hd, hr⟩)])
  unfold Template.evaluate
  rw [hg, hd, hs]

theorem evaluated_targets (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) :
    ∀ entry ∈ e.deltas, ∃ d ∈ template.deltas,
      d.target.resolve ctx.caller ctx.parties = .ok entry.1 := by
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
  rename_i deltas hd
  split at h
  · contradiction
  cases h
  intro entry he
  obtain ⟨d, hm, hv⟩ := mapM_ok_mem _ _ _ hd entry he
  refine ⟨d, hm, ?_⟩
  cases hc : d.target.resolve ctx.caller ctx.parties <;>
    simp only [hc, bind, Except.bind] at hv
  · contradiction
  cases ha : d.amount.eval ctx <;> simp only [ha, bind, Except.bind] at hv
  · contradiction
  cases hv
  rfl

theorem evaluated_effect_zero_outside (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) (region : Set (Cell P A D))
    (ht : TargetsWithin template ctx.caller ctx.parties region)
    (c : Cell P A D) (hc : c ∉ region) : e.effect c = 0 := by
  apply List.sum_eq_zero
  intro v hv
  obtain ⟨entry, he, rfl⟩ := List.mem_map.mp hv
  have hn : entry.1 ≠ c := by
    intro eq
    obtain ⟨d, hd, hr⟩ := evaluated_targets template ctx e h entry he
    exact hc (eq ▸ ht d hd entry.1 hr)
  simp [hn]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Equality on potential targets suffices even if accounting or writes later refuse. -/
theorem funds_iff (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    (∀ c, 0 ≤ left.balance c + e.effect c) ↔
      (∀ c, 0 ≤ right.balance c + e.effect c) := by
  constructor
  · intro h c
    by_cases hc : c ∈ region
    · rw [← ha c hc]
      exact h c
    · simpa [hz c hc] using right.nonneg c
  · intro h c
    by_cases hc : c ∈ region
    · rw [ha c hc]
      exact h c
    · simpa [hz c hc] using left.nonneg c

/-- Success compares the protected region and fixed store; errors compare exact constructors. -/
def ExecutionAgrees (region : Set (Cell P A D)) :
    Except Typed.Refusal (ExecutionResult P A D) →
    Except Typed.Refusal (ExecutionResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.state b.state ∧ a.capabilities = b.capabilities
  | _, _ => False

theorem applyEvaluated_congr (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (request : Request P A D)
    (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    ExecutionAgrees region (applyEvaluated store ctx request left e)
      (applyEvaluated store ctx request right e) := by
  have hf := funds_iff left right e region ha hz
  by_cases hl : ∀ c, 0 ≤ left.balance c + e.effect c
  · have hr := hf.mp hl
    unfold applyEvaluated
    simp only [dif_pos hl, dif_pos hr]
    split_ifs <;> try rfl
    exact ⟨fun c hc ↦ congrArg (fun q ↦ q + e.effect c) (ha c hc), rfl⟩
  · have hr : ¬ ∀ c, 0 ≤ right.balance c + e.effect c := fun h ↦ hl (hf.mpr h)
    unfold applyEvaluated
    simp only [dif_neg hl, dif_neg hr]
    split_ifs <;> rfl

/-- Complete registered execution dependence, including every exact refusal. -/
theorem execute_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) :
    ExecutionAgrees region (Typed.execute registry store ctx env now request left)
      (Typed.execute registry store ctx env now request right) := by
  unfold Typed.execute
  cases hs : registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    split_ifs <;> (try simp only [throw, throwThe, bind, Except.bind])
    all_goals try rfl
    all_goals
      cases argsOk : Args.check template.signature request.arguments <;>
        simp only [Except.mapError, bind, Except.bind]
    all_goals try rfl
    rename_i args
    have he := evaluate_congr template left right env ctx.principal request.parties args now
      (hr template hs)
    rw [← he]
    cases ev : template.evaluate ⟨left, env, ctx.principal, request.parties, args, now⟩ with
    | error reason => rfl
    | ok e =>
      simp only [Except.mapError, bind, Except.bind]
      exact applyEvaluated_congr store ctx request left right e region ha
        (evaluated_effect_zero_outside template _ e ev region (ht template hs))

theorem execute_refusal_iff (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) (reason : Typed.Refusal) :
    Typed.execute registry store ctx env now request left = .error reason ↔
      Typed.execute registry store ctx env now request right = .error reason := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  cases hl : Typed.execute registry store ctx env now request left <;>
    cases hh : Typed.execute registry store ctx env now request right <;>
    simp_all [ExecutionAgrees]

theorem execute_success_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (post : ExecutionResult P A D)
    (hx : Typed.execute registry store ctx env now request left = .ok post) :
    ∃ other, Typed.execute registry store ctx env now request right = .ok other ∧
      AgreeOn region post.state other.state ∧ post.capabilities = store ∧
      other.capabilities = store := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  rw [hx] at h
  cases hh : Typed.execute registry store ctx env now request right with
  | error reason => simp [hh, ExecutionAgrees] at h
  | ok other =>
    rw [hh] at h
    have hp := execute_preserves_capabilities registry store ctx env now request left post hx
    have ho := execute_preserves_capabilities registry store ctx env now request right other hh
    exact ⟨other, rfl, h.1, hp, ho⟩

/-- Each success frames its own input outside potential targets, regardless of foreign balances. -/
theorem execute_target_frame (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (pre : State P A D) (post : ExecutionResult P A D)
    (region : Set (Cell P A D))
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (hx : Typed.execute registry store ctx env now request pre = .ok post) :
    ∀ c, c ∉ region → post.state.balance c = pre.balance c := by
  obtain ⟨template, hs, args, _, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request pre post hx
  have hp := (applyEvaluated_ok_iff store ctx request pre e post).mp happly
  intro c hc
  rw [hp.2.2 c, evaluated_effect_zero_outside template _ e he region (ht template hs) c hc]
  exact add_zero _

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Dependency.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Dependency/Adapter.lean ---
import DefiKernel.Parallel.Dependency
import DefiKernel.Parallel.Compatibility

/-! State dependence for the existing composition adapter, with same-prestate receipts and
selected post-state snapshots. Boundaries and local histories are identical inputs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem prepareInvocation_shape (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    request.operation = inv.operation ∧ request.parties = inv.parties ∧
      ∃ component, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) := by
  unfold prepareInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, selected⟩
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  cases h
  exact ⟨rfl, rfl, component, hl⟩

theorem analyzed_dependencies (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (template : Template P A D) (hs : cfg.registry inv.operation = some template) :
    (∀ ref ∈ template.requiredStateReads, ∀ c,
      ref.2.resolve boundary.ctx.principal inv.parties = .ok c → c ∈ fp.reads) ∧
    TargetsWithin template boundary.ctx.principal inv.parties {c | c ∈ fp.writes} ∧
    (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, selected, reads, writes, hl, ht, hr, hw, hc, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hs] at ht
  cases ht
  refine ⟨?_, ?_, ?_⟩
  · intro ref hm c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hr ref (by simp [hm])
    rw [hres] at hres'
    cases hres'
    simp [hm']
  · intro d hd c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hw ⟨d.asset, d.target⟩
      (List.mem_append_right _ (List.mem_map.mpr ⟨d, hd, rfl⟩))
    rw [hres] at hres'
    cases hres'
    exact hm'
  · intros
    simp_all

theorem analyzed_outputs (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (component : Component P A D) (iface : OperationInterface P A D)
    (hl : lookupOperation cfg.catalog inv.component inv.operation = some (component, iface)) :
    ∀ output ∈ iface.outputs, output.cell ∈ fp.reads := by
  obtain ⟨selected, si, template, reads, writes, hs, _, _, _, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hl] at hs
  cases hs
  intro output ho
  simp only [List.mem_append, List.mem_map]
  exact Or.inr ⟨output, ho, rfl⟩

theorem snapshots_congr (index : Nat) (component : ComponentId)
    (iface : OperationInterface P A D) (left right : State P A D)
    (h : ∀ output ∈ iface.outputs, left.balance output.cell = right.balance output.cell) :
    snapshots index component iface left = snapshots index component iface right := by
  unfold snapshots
  apply List.map_congr_left
  intro output ho
  simp only [h output ho]

theorem extractReceipt_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (left right : World P A D)
    (hr : ∀ template, cfg.registry request.operation = some template →
      ResolvedReadsAgree template boundary.ctx.principal request.parties left.state right.state) :
    extractReceipt cfg boundary request left = extractReceipt cfg boundary request right := by
  unfold extractReceipt
  cases hs : cfg.registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    cases ha : Args.check template.signature request.arguments with
    | error reason => rfl
    | ok args =>
      simp only [Except.mapError, bind, Except.bind]
      rw [evaluate_congr template left.state right.state boundary.env boundary.ctx.principal
        request.parties args boundary.now (hr template hs)]

def StepAgrees (region : Set (Cell P A D)) :
    Except Failure (StepResult P A D) → Except Failure (StepResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.world.state b.world.state ∧
      a.world.capabilities = b.world.capabilities ∧ a.receipt = b.receipt ∧ a.outputs = b.outputs
  | _, _ => False

theorem executeStep_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) :
    StepAgrees region (executeStep cfg boundary index history (.invoke inv) left)
      (executeStep cfg boundary index history (.invoke inv) right) := by
  unfold executeStep
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · simp only [hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, bind, Except.bind]
    cases hp : prepareInvocation cfg boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      simp only [bind, Except.bind]
      obtain ⟨hop, hparties, component, hlookup⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
      have hr : ∀ template, cfg.registry request.operation = some template →
          ResolvedReadsAgree template boundary.ctx.principal request.parties
            left.state right.state := by
        intro template hs ref href c hc
        rw [hop] at hs
        rw [hparties] at hc
        exact ha c (hin c ((analyzed_dependencies _ _ _ _ hf template hs).1 ref href c hc))
      have ht : ∀ template, cfg.registry request.operation = some template →
          TargetsWithin template boundary.ctx.principal request.parties region := by
        intro template hs d hd c hc
        rw [hop] at hs
        rw [hparties] at hc
        have dep := analyzed_dependencies _ _ _ _ hf template hs
        exact hin c (dep.2.2 c (dep.2.1 d hd c hc))
      have he := extractReceipt_congr cfg boundary request left right hr
      have hx := execute_congr cfg.registry left.capabilities boundary.ctx boundary.env boundary.now
        request left.state right.state region ha hr ht
      rw [← hcap]
      cases hleft : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request left.state <;>
        cases hright : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request right.state <;>
        simp only [hleft, hright, ExecutionAgrees] at hx
      · cases hx
        rfl
      · rename_i post other
        simp only [Except.mapError, bind, Except.bind]
        rw [← he]
        cases hrp : extractReceipt cfg boundary request left with
        | error reason => rfl
        | ok e =>
          exact ⟨hx.1, hx.2, rfl, snapshots_congr index inv.component iface _ _
            (fun output ho ↦ hx.1 output.cell
              (hin _ (analyzed_outputs _ _ _ _ hf _ _ hlookup output ho)))⟩
  · have hfalse : validateCatalog cfg.registry cfg.catalog = false := Bool.eq_false_iff.mpr hv
    simp only [hfalse, Bool.not_false, ↓reduceIte, bind, Except.bind]
    rfl

/-- Successful adapter execution changes only the analyzed write region. -/
theorem executeStep_target_frame (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (result : StepResult P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hx : executeStep cfg boundary index history (.invoke inv) pre = .ok result) :
    (∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c) ∧
      result.world.capabilities = pre.capabilities := by
  have sound := executeStep_sound cfg boundary index history (.invoke inv) pre result hx
  cases sound with
  | invoke inv pre post iface request e hp he hex happly =>
    obtain ⟨hop, hparties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
    refine ⟨?_, execute_preserves_capabilities _ _ _ _ _ _ _ _ he⟩
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ he
    intro template hs
    rw [hop] at hs
    rw [hparties]
    exact (analyzed_dependencies _ _ _ _ hf template hs).2.1

theorem executeStep_refusal_iff (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) (reason : Failure) :
    executeStep cfg boundary index history (.invoke inv) left = .error reason ↔
      executeStep cfg boundary index history (.invoke inv) right = .error reason := by
  have h := executeStep_congr cfg boundary index history inv left right fp region hf hin ha hcap
  cases hl : executeStep cfg boundary index history (.invoke inv) left <;>
    cases hr : executeStep cfg boundary index history (.invoke inv) right <;>
    simp_all [StepAgrees]

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Dependency/Adapter.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Preservation.lean ---
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Composition.Preservation
import DefiKernel.Parallel.Dependency.Adapter

/-! Accounting and locality telescope actual scheduled effects. Authority is checked at each
attempt's real pre-world, with a separate proof that every capability store is the initial one. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (d : D) (a : A) :
    total post.world.state d a - total m.world.state d a = post.supply d a - m.supply d a := by
  cases h with
  | halted => simp [skip_world, Machine.supply, skip_attempts]
  | exhausted => simp [skip_world, Machine.supply, skip_attempts]
  | refused =>
    simp [Machine.supply, Machine.refuse, Attempt.supply, setLocal_world]
  | accepted inv result active selected executed =>
    have he := (executeStep_sound _ _ _ _ _ _ _ executed).accounting d a
    simp only [Machine.supply, Machine.accept, List.map_append,
      List.map_singleton, List.sum_append, List.sum_singleton, Attempt.supply]
    linarith

theorem Reachable.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (d : D) (a : A) :
    total m.world.state d a = total initial.state d a + m.supply d a := by
  induction h with
  | start => simp [Interleaving.start, Machine.supply]
  | next b previous step ih =>
    have he := step.accounting d a
    linarith

theorem AdvanceSound.before_stores {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (store : m.world.capabilities = initial.capabilities)
    (previous : ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities) :
    ∀ attempt ∈ post.attempts, attempt.before.capabilities = initial.capabilities := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store
  | accepted =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store

theorem Reachable.before_stores {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.before_stores previous.store ih

theorem Reachable.authority {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt := by
  obtain ⟨history, executed⟩ := h.attempts attempt member
  rw [success] at executed
  exact (executeStep_sound _ _ _ _ _ _ _ executed).authorized

theorem Reachable.initial_store_authority {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized ⟨attempt.before.state, initial.capabilities⟩
      (boundaries attempt.branch attempt.index) result.receipt := by
  have authorized := h.authority attempt member result success
  have store := h.before_stores attempt member
  cases hr : result.receipt <;> simp_all [ReceiptAuthorized]

theorem AdvanceSound.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (c : Cell P A D)
    (untouched : c ∉ post.writes) :
    post.world.state.balance c = m.world.state.balance c ∧ c ∉ m.writes := by
  cases h with
  | halted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | exhausted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | refused =>
    simpa [Machine.writes, Machine.refuse, Attempt.writes, setLocal_world] using untouched
  | accepted inv result active selected executed =>
    simp only [Machine.writes, Machine.accept, List.flatMap_append,
      List.flatMap_singleton, Attempt.writes, List.mem_append, not_or] at untouched
    exact ⟨(executeStep_sound _ _ _ _ _ _ _ executed).locality c untouched.2, untouched.1⟩

theorem Reachable.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (c : Cell P A D)
    (untouched : c ∉ m.writes) : m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | next b previous step ih =>
    obtain ⟨same, old⟩ := step.locality c untouched
    exact same.trans (ih old)

theorem Reachable.frame {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (untouched : ∀ c ∈ region, c ∉ m.writes) : AgreeOn region initial.state m.world.state := by
  intro c member
  exact (h.locality c (untouched c member)).symm

theorem Reachable.predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    predicate initial.state ↔ predicate m.world.state :=
  supported_frame support (h.frame region untouched)

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzed_selected (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (b : BranchId) (n : Nat) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ fp, analyzeInvocation cfg (boundaries b n) inv = .ok fp ∧
      ∀ c ∈ fp.writes, c ∈ lf.writes ++ rf.writes := by
  cases b with
  | left =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .left)
      0 left lf hl n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_left _ (hw c hc)⟩
  | right =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .right)
      0 right rf hr n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_right _ (hw c hc)⟩

theorem Reachable.analyzed_locality {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
    m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | @next pre post b previous step ih =>
    cases step with
    | halted => simpa [skip_world] using ih
    | exhausted => simpa [skip_world] using ih
    | refused => simpa [refuse_world] using ih
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      obtain ⟨fp, hf, hw⟩ := analyzed_selected cfg boundaries left right lf rf hl hr
        b (pre.local b).consumed inv selected
      rw [← hi] at hf
      have framed := (executeStep_target_frame cfg (boundaries b (pre.local b).nextIndex)
        (pre.local b).nextIndex (pre.local b).outputs inv pre.world result fp hf executed).1
      exact (framed c (fun hc ↦ untouched (hw c hc))).trans ih

theorem Reachable.analyzed_predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate m.world.state := by
  apply supported_frame support
  intro c hc
  exact (h.analyzed_locality lf rf hl hr c (untouched c hc)).symm

theorem runPrefix_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total (runPrefix cfg boundaries initial left right schedule).world.state d a =
      total initial.state d a + (runPrefix cfg boundaries initial left right schedule).supply d a :=
  (runPrefix_reachable cfg boundaries initial left right schedule).accounting d a

theorem runPrefix_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    (runPrefix cfg boundaries initial left right schedule).world.capabilities =
      initial.capabilities :=
  (runPrefix_reachable cfg boundaries initial left right schedule).store

theorem runPrefix_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤ (runPrefix cfg boundaries initial left right schedule).world.state.balance c :=
  (runPrefix cfg boundaries initial left right schedule).world.state.nonneg c

theorem runPrefix_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region,
      c ∉ (runPrefix cfg boundaries initial left right schedule).writes) :
    predicate initial.state ↔
      predicate (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).predicate_frame
    region predicate support untouched

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Interference.lean ---
import DefiKernel.Interleaving.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over arbitrary histories and worlds; they never assume the peer invariant or run result. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each branch proves its own invariant and guarantee from its own invariant alone. -/
def LocalObligation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (invariant : BranchId → LedgerPredicate P A D)
    (guarantee : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (selectBranch left right b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      StepSound cfg (boundaries b index) index history (.invoke inv) pre result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : BranchId → LedgerPredicate P A D)
    (rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

theorem Reachable.two_invariants {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    cases step with
    | halted => simpa only [skip_world] using ih
    | exhausted => simpa only [skip_world] using ih
    | refused => simpa only [refuse_world] using ih
    | accepted inv result active selected executed =>
      have index := previous.attempt_index b active inv selected
      have selected' : (selectBranch left right b)[_]? = some inv := selected
      rw [← index] at selected'
      have own := localObligation b _ inv selected' _ _ _ (ih b)
        (executeStep_sound _ _ _ _ _ _ _ executed)
      intro other
      change invariant other result.world.state
      by_cases same : b = other
      · subst other
        exact own.1
      · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem runPrefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).two_invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains both initialized invariants, including stopped branches. -/
theorem every_prefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial left right (schedule.take length)).world.state :=
  runPrefix_two_invariants cfg boundaries initial left right (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Interference.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Commutation.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.Dependency.Adapter

/-! Congruence of full local histories and exact refusals, then correspondence to actual
serial branch re-execution. Dependency premises are discharged from checked admission. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

structure CursorAgrees (region : Set (Cell P A D)) (left right : Cursor P A D) : Prop where
  state : AgreeOn region left.world.state right.world.state
  capabilities : left.world.capabilities = right.world.capabilities
  events : left.events.map observeEvent = right.events.map observeEvent
  outputs : left.outputs = right.outputs
  nextIndex : left.nextIndex = right.nextIndex
  failure : left.failure = right.failure

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorAgrees.observation {region : Set (Cell P A D)} {left right : Cursor P A D}
    (h : CursorAgrees region left right) : observeBranch left = observeBranch right := by
  simp only [observeBranch, h.events, h.outputs, h.nextIndex, h.failure]

theorem continueRun_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (continueRun cfg boundary left (branch.map Step.invoke))
      (continueRun cfg boundary right (branch.map Step.invoke)) := by
  induction branch generalizing index fp left right with
  | nil => exact ha
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    have hhead : ∀ c ∈ head.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hrest : ∀ c ∈ rest.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hir : right.nextIndex = index := ha.nextIndex.symm.trans hi
    cases hfl : left.failure with
    | some failure =>
      have hfr : right.failure = some failure := ha.failure.symm.trans hfl
      simpa [continueRun_failed cfg boundary left failure hfl,
        continueRun_failed cfg boundary right failure hfr] using ha
    | none =>
      have hfr : right.failure = none := ha.failure.symm.trans hfl
      have hs := executeStep_congr cfg (boundary index) index left.outputs inv
        left.world right.world head region hh hhead ha.state ha.capabilities
      change CursorAgrees region
        (continueRun cfg boundary (advance cfg boundary left (.invoke inv))
          (tail.map Step.invoke))
        (continueRun cfg boundary (advance cfg boundary right (.invoke inv))
          (tail.map Step.invoke))
      cases hl : executeStep cfg (boundary index) index left.outputs (.invoke inv) left.world with
      | error le =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | ok rr => simp [hl, hr, StepAgrees] at hs
        | error re =>
          simp only [hl, hr, StepAgrees] at hs
          subst re
          have hal : advance cfg boundary left (.invoke inv) =
              { left with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfl, hi, hl]
          have har : advance cfg boundary right (.invoke inv) =
              { right with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfr, hir, ← ha.outputs, hr]
          rw [hal, har]
          rw [continueRun_failed cfg boundary _ _ rfl,
            continueRun_failed cfg boundary _ _ rfl]
          exact ⟨ha.state, ha.capabilities, ha.events, ha.outputs, ha.nextIndex, rfl⟩
      | ok lr =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | error re => simp [hl, hr, StepAgrees] at hs
        | ok rr =>
          simp only [hl, hr, StepAgrees] at hs
          let nl : Cursor P A D :=
            ⟨lr.world, left.events ++ [⟨index, .invoke inv, left.world, lr⟩],
              left.outputs ++ lr.outputs, index + 1, none⟩
          let nr : Cursor P A D :=
            ⟨rr.world, right.events ++ [⟨index, .invoke inv, right.world, rr⟩],
              right.outputs ++ rr.outputs, index + 1, none⟩
          have hal : advance cfg boundary left (.invoke inv) = nl := by
            simp [advance, hfl, hi, hl, nl]
          have har : advance cfg boundary right (.invoke inv) = nr := by
            simp [advance, hfr, hir, ← ha.outputs, hr, nr]
          rw [hal, har]
          apply ih (index + 1) rest nl nr ht hrest rfl
          refine ⟨hs.1, hs.2.1, ?_, ?_, rfl, rfl⟩
          · simp [nl, nr, List.map_append, observeEvent, ha.events, hs.2.2.1, hs.2.2.2]
          · simp [nl, nr, ha.outputs, hs.2.2.2]

theorem runBranch_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (left right : World P A D) (hf : analyzeBranch cfg boundary branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hc : left.capabilities = right.capabilities) :
    CursorAgrees region (runBranch cfg boundary left branch)
      (runBranch cfg boundary right branch) := by
  apply continueRun_congr cfg boundary branch 0 fp region _ _ hf hin rfl
  exact ⟨ha, hc, rfl, rfl, rfl, rfl⟩

theorem continueRun_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D) (cursor : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hi : cursor.nextIndex = index) :
    (∀ c, c ∉ fp.writes →
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.state.balance c =
        cursor.world.state.balance c) ∧
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.capabilities =
        cursor.world.capabilities := by
  induction branch generalizing index fp cursor with
  | nil => exact ⟨fun _ _ ↦ rfl, rfl⟩
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    cases hfl : cursor.failure with
    | some failure =>
      rw [continueRun_failed cfg boundary cursor failure hfl]
      exact ⟨fun _ _ ↦ rfl, rfl⟩
    | none =>
      change (∀ c, c ∉ fp.writes →
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.state.balance c = cursor.world.state.balance c) ∧
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.capabilities = cursor.world.capabilities
      cases hx : executeStep cfg (boundary index) index cursor.outputs
          (.invoke inv) cursor.world with
      | error reason =>
        have hadv : advance cfg boundary cursor (.invoke inv) =
            { cursor with failure := some ⟨index, some (.invoke inv), reason⟩ } := by
          simp [advance, hfl, hi, hx]
        rw [hadv, continueRun_failed cfg boundary _ _ rfl]
        exact ⟨fun _ _ ↦ rfl, rfl⟩
      | ok result =>
        let next : Cursor P A D :=
          ⟨result.world, cursor.events ++ [⟨index, .invoke inv, cursor.world, result⟩],
            cursor.outputs ++ result.outputs, index + 1, none⟩
        have hadv : advance cfg boundary cursor (.invoke inv) = next := by
          simp [advance, hfl, hi, hx, next]
        rw [hadv]
        have hs := executeStep_target_frame cfg (boundary index) index cursor.outputs inv
          cursor.world result head hh hx
        have htail := ih (index + 1) rest next ht rfl
        refine ⟨?_, htail.2.trans hs.2⟩
        intro c hc
        have hhead : c ∉ head.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        have hrest : c ∉ rest.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        exact (htail.1 c hrest).trans (hs.1 c hhead)

theorem runBranch_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (fp : Footprint P A D)
    (hf : analyzeBranch cfg boundary branch = .ok fp) :
    (∀ c, c ∉ fp.writes → (runBranch cfg boundary initial branch).world.state.balance c =
      initial.state.balance c) ∧
      (runBranch cfg boundary initial branch).world.capabilities = initial.capabilities := by
  exact continueRun_frame cfg boundary branch 0 fp (startCursor cfg initial) hf rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzeBranchFrom_writes_read (cfg : Config P A D)
    (boundary : Nat → Boundary P A D) (index : Nat) (branch : Branch P A D)
    (fp : Footprint P A D) (hf : analyzeBranchFrom cfg boundary index branch = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  induction branch generalizing index fp with
  | nil =>
    have he : fp = Footprint.empty := by simpa [analyzeBranchFrom] using hf.symm
    simp [he, Footprint.empty]
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    intro c hc
    rcases List.mem_append.mp hc with hc | hc
    · exact List.mem_append_left _ (analyzeInvocation_writes_read _ _ _ _ hh c hc)
    · exact List.mem_append_right _ (ih (index + 1) rest ht c hc)

/-- The real second run has the same local observations, including exact refusal. -/
theorem rerun_after_peer (cfg : Config P A D) (ownBoundary peerBoundary : Nat → Boundary P A D)
    (initial : World P A D) (own peer : Branch P A D) (ownFp peerFp : Footprint P A D)
    (ho : analyzeBranch cfg ownBoundary own = .ok ownFp)
    (hp : analyzeBranch cfg peerBoundary peer = .ok peerFp)
    (hd : ∀ c ∈ peerFp.writes, c ∉ ownFp.reads) :
    CursorAgrees {c | c ∈ ownFp.reads} (runBranch cfg ownBoundary initial own)
      (runBranch cfg ownBoundary (runBranch cfg peerBoundary initial peer).world own) := by
  have frame := runBranch_frame cfg peerBoundary initial peer peerFp hp
  apply runBranch_congr cfg ownBoundary own ownFp _ _ _ ho (fun _ h ↦ h)
  · intro c hc
    exact (frame.1 c (fun hw ↦ hd c hw hc)).symm
  · exact frame.2.symm

/-- Region merge equals a fresh right execution after the real left retained prefix. -/
theorem merge_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hc : Compatible lf rf) :
    WorldEquivalent
      (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
        (runBranch cfg (boundaries .right) initial right).world)
      (runBranch cfg (boundaries .right)
        (runBranch cfg (boundaries .left) initial left).world right).world := by
  have le := runBranch_frame cfg (boundaries .left) initial left lf hl
  have re := runBranch_frame cfg (boundaries .right)
    (runBranch cfg (boundaries .left) initial left).world right rf hr
  have ra := rerun_after_peer cfg (boundaries .right) (boundaries .left)
    initial right left rf lf hr hl hc.2.1
  refine ⟨?_, (re.2.trans le.2).symm⟩
  intro c
  by_cases hcl : c ∈ lf.writes
  · have hcr := hc.1 c hcl
    simpa [mergeWorld, hcl] using (re.1 c hcr).symm
  · by_cases hcr : c ∈ rf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf hr c hcr
      simpa [mergeWorld, hcl, hcr] using ra.state c hread
    · simpa [mergeWorld, hcl, hcr] using ((re.1 c hcr).trans (le.1 c hcl)).symm

theorem runParallel_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialLR cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialLR, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    simp only [runParallel, runSerialLR, ha, ObservationallyEquivalent]
    exact ⟨merge_serialLR cfg boundaries initial left right lf rf hl hr hc, True.intro,
      (rerun_after_peer cfg (boundaries .right) (boundaries .left)
        initial right left rf lf hr hl hc.2.1).observation⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_swap (lf rf : Footprint P A D) (initial left right : World P A D)
    (hc : Compatible lf rf) :
    WorldEquivalent (mergeWorld lf rf initial left right)
      (mergeWorld rf lf initial right left) := by
  refine ⟨?_, rfl⟩
  intro c
  by_cases hl : c ∈ lf.writes
  · simp [mergeWorld, hl, hc.1 c hl]
  · by_cases hr : c ∈ rf.writes <;> simp [mergeWorld, hl, hr]

theorem runParallel_serialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialRL, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    let swapped : ParallelBoundary P A D := fun side ↦
      match side with | .left => boundaries .right | .right => boundaries .left
    have hm := merge_serialLR cfg swapped initial right left rf lf hr hl (compatible_symm hc)
    have hs := mergeWorld_swap lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world hc
    simp only [runParallel, runSerialRL, ha, ObservationallyEquivalent]
    exact ⟨⟨fun c ↦ (hs.1 c).trans (hm.1 c), hs.2.trans hm.2⟩,
      (rerun_after_peer cfg (boundaries .left) (boundaries .right)
        initial left right lf rf hl hr hc.2.2).observation, True.intro⟩

/-- Singleton calls inherit exact refusal-aware sequential correspondence. -/
theorem singleton_commutation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Invocation P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialLR cfg boundaries initial [left] [right]) ∧
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialRL cfg boundaries initial [left] [right]) :=
  ⟨runParallel_serialLR _ _ _ _ _, runParallel_serialRL _ _ _ _ _⟩

theorem runBranch_empty (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) : runBranch cfg boundary initial [] = startCursor cfg initial := rfl

/-- An admitted empty peer has no events or outputs and contributes no ledger change. -/
theorem runParallel_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (ha : admit cfg boundaries left [] = .ok (lf, .empty)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left [])
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) := by
  obtain ⟨_, hl, _, _⟩ := admit_ok cfg boundaries left [] lf .empty ha
  have hf := runBranch_frame cfg (boundaries .left) initial left lf hl
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ lf.writes
  · simp [mergeWorld, hc]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

theorem runParallel_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (ha : admit cfg boundaries [] right = .ok (.empty, rf)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [] right)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) := by
  obtain ⟨_, _, hr, _⟩ := admit_ok cfg boundaries [] right .empty rf ha
  have hf := runBranch_frame cfg (boundaries .right) initial right rf hr
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ rf.writes
  · simp [mergeWorld, hc, Footprint.empty]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

/-- Both real sequential schedules yield the same complete canonical observation. -/
theorem serial_orders_equivalent (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runSerialLR cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) :=
  (runParallel_serialLR cfg boundaries initial left right).symm.trans
    (runParallel_serialRL cfg boundaries initial left right)

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Commutation.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Preservation.lean ---
import DefiKernel.Parallel.Commutation
import DefiKernel.Composition.Preservation

/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset

-- BEGIN PROOFS

theorem mergeWorld_balance_sum (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (c : Cell P A D) :
    (mergeWorld lf rf initial left right).state.balance c =
      left.state.balance c + right.state.balance c - initial.state.balance c := by
  by_cases hcl : c ∈ lf.writes
  · simp [mergeWorld, hcl, hr c (hd c hcl)]
  · by_cases hcr : c ∈ rf.writes
    · simp [mergeWorld, hcl, hcr, hl c hcl]
    · simp [mergeWorld, hcl, hcr, hl c hcl, hr c hcr]

theorem mergeWorld_accounting (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (d : D) (a : A) :
    total (mergeWorld lf rf initial left right).state d a =
      total left.state d a + total right.state d a - total initial.state d a := by
  simp only [total, mergeWorld_balance_sum lf rf initial left right hd hl hr,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]

theorem runBranch_accounting (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (d : D) (a : A) :
    total (runBranch cfg boundary initial branch).world.state d a =
      total initial.state d a + traceSupply (runBranch cfg boundary initial branch).events d a :=
  run_accounting cfg boundary initial (branch.map Step.invoke) d a

/-- Actual successful receipt supplies from both independent runs determine joined accounting. -/
theorem runParallel_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf)) (d : D) (a : A) :
    total (mergeWorld lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state d a =
      total initial.state d a +
        traceSupply (runBranch cfg (boundaries .left) initial left).events d a +
        traceSupply (runBranch cfg (boundaries .right) initial right).events d a := by
  obtain ⟨hv, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf hadmit
  rw [mergeWorld_accounting lf rf initial _ _ hc.1
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1]
  rw [runBranch_accounting, runBranch_accounting]
  linarith

theorem runBranch_events_invoke (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv ∈ branch, event.step = .invoke inv := by
  obtain ⟨accepted, remaining, hs, he⟩ :=
    run_order cfg boundary initial (branch.map Step.invoke)
  intro event hm
  have hstep : event.step ∈ accepted := he ▸ List.mem_map.mpr ⟨event, hm, rfl⟩
  have hall : event.step ∈ branch.map Step.invoke := by
    rw [hs]
    exact List.mem_append_left _ hstep
  obtain ⟨inv, hi, hh⟩ := List.mem_map.mp hall
  exact ⟨inv, hi, hh.symm⟩

theorem trace_invoke_stores {cfg : Config P A D} {boundary : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundary initial events final history index)
    (hi : ∀ event ∈ events, ∃ inv, event.step = .invoke inv) :
    final.capabilities = initial.capabilities ∧
      ∀ event ∈ events, event.before.capabilities = initial.capabilities ∧
        event.result.world.capabilities = initial.capabilities := by
  induction h with
  | nil => exact ⟨rfl, by simp⟩
  | @snoc events pre history index previous step result sound ih =>
    obtain ⟨hp, he⟩ := ih (by
      intro event hm
      exact hi event (List.mem_append_left _ hm))
    obtain ⟨inv, hstep⟩ := hi ⟨index, step, pre, result⟩ (by simp)
    change step = .invoke inv at hstep
    have hcap : result.world.capabilities = pre.capabilities := by
      rw [hstep] at sound
      exact sound.invoke_preserves_capabilities
    refine ⟨hcap.trans hp, ?_⟩
    intro event hm
    rcases List.mem_append.mp hm with hm | hm
    · exact he event hm
    · have eq := List.mem_singleton.mp hm
      subst event
      exact ⟨hp, hcap.trans hp⟩

/-- Every successful invocation uses authority from the initial fixed store, including prefixes
whose later invocation refuses. The actual local boundary remains attached to each event. -/
theorem runBranch_authority (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ReceiptAuthorized initial (boundary event.index) event.result.receipt := by
  have ht := run_trace_sound cfg boundary initial (branch.map Step.invoke)
  have hi : ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv, event.step = .invoke inv := by
    intro event hm
    obtain ⟨inv, _, he⟩ := runBranch_events_invoke cfg boundary initial branch event hm
    exact ⟨inv, he⟩
  have hs := trace_invoke_stores ht hi
  intro event hm
  have ha := ht.authority event hm
  have hc := (hs.2 event hm).1
  cases hr : event.result.receipt <;> simp only [hr, ReceiptAuthorized] at ha ⊢
  simpa only [hc] using ha

theorem runBranch_prefix_nonnegative (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c :=
  run_prefix_nonnegative cfg boundary initial (branch.map Step.invoke)

/-- The join frames every predicate whose explicit support avoids both write regions. -/
theorem mergeWorld_supported_frame (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate (mergeWorld lf rf initial left right).state := by
  apply supported_frame support
  intro c hc
  exact (mergeWorld_outside lf rf initial left right c
    (untouched c hc).1 (untouched c hc).2).symm

theorem mergeWorld_agrees_left (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ rf.writes) :
    AgreeOn region left.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ lf.writes
  · simp [mergeWorld, hw]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_agrees_right (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ lf.writes) :
    AgreeOn region right.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ rf.writes
  · simp [mergeWorld, hw, peer c hc]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_two_invariants (lf rf : Footprint P A D)
    (initial left right : World P A D) (ls rs : Set (Cell P A D))
    (lp rp : State P A D → Prop) (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp left.state) (ri : rp right.state) :
    lp (mergeWorld lf rf initial left right).state ∧
      rp (mergeWorld lf rf initial left right).state :=
  ⟨(supported_frame lSupport (mergeWorld_agrees_left lf rf initial left right ls hl lpeer)).mp li,
    (supported_frame rSupport (mergeWorld_agrees_right lf rf initial left right rs hr rpeer)).mp ri⟩

/-- Non-circular initialized induction obligations for a branch's own ledger predicate. -/
def LocalPreservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (predicate : State P A D → Prop) : Prop :=
  ∀ n outputs step pre result, StepSound cfg (boundary n) n outputs step pre result →
    predicate pre.state → predicate result.world.state

theorem runBranch_invariant (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (predicate : State P A D → Prop)
    (initialized : predicate initial.state) (preserves : LocalPreservation cfg boundary predicate) :
    predicate (runBranch cfg boundary initial branch).world.state :=
  (run_trace_sound cfg boundary initial (branch.map Step.invoke)).invariant
    (fun w ↦ predicate w.state) initialized preserves

theorem evaluated_supplies_empty (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (hn : template.supplyDeltas = []) (he : template.evaluate ctx = .ok e) :
    e.supplies = [] := by
  unfold Template.evaluate at he
  rw [hn] at he
  simp only [List.mapM_nil, bind, Except.bind, pure, Except.pure] at he
  repeat' first | split at he | contradiction
  cases he
  rfl

theorem extractReceipt_supplies_empty (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) (e : Evaluated P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (he : extractReceipt cfg boundary request pre = .ok e) : e.supplies = [] := by
  unfold extractReceipt at he
  cases hs : cfg.registry request.operation with
  | none => simp [hs, bind, Except.bind] at he
  | some template =>
    simp only [hs, bind, Except.bind] at he
    cases ha : Args.check template.signature request.arguments with
    | error reason => simp [ha, Except.mapError] at he
    | ok args =>
      simp only [ha, Except.mapError, bind, Except.bind] at he
      cases hv : template.evaluate
          ⟨pre.state, boundary.env, boundary.ctx.principal, request.parties, args, boundary.now⟩
          <;> simp only [hv, Except.mapError] at he
      · contradiction
      · cases he
        exact evaluated_supplies_empty template _ _ (hn _ _ hs) hv

theorem step_no_supply {cfg : Config P A D} {boundary : Boundary P A D}
    {n : Nat} {outputs : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (hs : StepSound cfg boundary n outputs step pre result) (d : D) (a : A) :
    result.receipt.supply d a = 0 := by
  cases hs with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have he := extractReceipt_supplies_empty cfg boundary request pre e hn extracted
    simp [Receipt.supply, Evaluated.supply, he]
  | issue => rfl
  | revoke => rfl

theorem local_total_preservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (d : D) (a : A) (amount : ℚ) :
    LocalPreservation cfg boundary (fun s ↦ total s d a = amount) := by
  intro n outputs step pre result hs hi
  rw [hs.accounting d a, step_no_supply hn hs d a, add_zero]
  exact hi

theorem supports_total (d : D) (a : A) (predicate : ℚ → Prop) :
    Supports {c : Cell P A D | c.1 = d ∧ c.2.2 = a}
      (fun s ↦ predicate (total s d a)) := by
  intro pre post h
  have ht : total pre d a = total post d a := by
    apply Finset.sum_congr rfl
    intro party hp
    exact h (d, party, a) ⟨rfl, rfl⟩
  change predicate (total pre d a) ↔ predicate (total post d a)
  rw [ht]

/-- Both branch invariants are initialized and preserved individually before supported join. -/
theorem runParallel_two_invariants (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state ∧
    rp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state := by
  obtain ⟨_, hl, hr, _⟩ := admit_ok cfg boundaries left right lf rf hadmit
  exact mergeWorld_two_invariants lf rf initial _ _ ls rs lp rp lSupport rSupport
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1 lpeer rpeer
    (runBranch_invariant cfg (boundaries .left) initial left lp li lPreserves)
    (runBranch_invariant cfg (boundaries .right) initial right rp ri rPreserves)

/-- Accounting binds the public executed result to both of its actual receipt sequences. -/
theorem runParallel_executed_accounting (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) (d : D) (a : A) :
    total joined.world.state d a = total initial.state d a + joined.supply d a := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    simpa only [Joined.supply, add_assoc] using
      runParallel_accounting cfg boundaries initial left right lf rf hadmit d a

theorem runParallel_executed_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundaries .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundaries .right event.index) event.result.receipt) := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    exact ⟨runBranch_authority cfg (boundaries .left) initial left,
      runBranch_authority cfg (boundaries .right) initial right⟩

theorem runParallel_executed_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, c ∉ lf.writes → c ∉ rf.writes →
      joined.world.state.balance c = initial.state.balance c) ∧
      joined.world.capabilities = initial.capabilities := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact ⟨mergeWorld_outside lf rf initial _ _, rfl⟩

theorem runParallel_executed_nonnegative (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, 0 ≤ joined.world.state.balance c) ∧
    (∀ event ∈ joined.left.events ++ joined.right.events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c) := by
  exact ⟨joined.world.state.nonneg,
    fun event _ c ↦ ⟨event.before.state.nonneg c, event.result.world.state.nonneg c⟩⟩

theorem runParallel_executed_supported_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate joined.world.state := by
  apply supported_frame support
  intro c hc
  exact ((runParallel_executed_frame cfg boundaries initial left right lf rf joined hadmit hx).1
    c (untouched c hc).1 (untouched c hc).2).symm

theorem runParallel_executed_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp joined.world.state ∧ rp joined.world.state := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact runParallel_two_invariants cfg boundaries initial left right lf rf hadmit
    ls rs lp rp lSupport rSupport lpeer rpeer li ri lPreserves rPreserves

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/InterferenceFixtures.lean ---
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.Preservation

/-! Shared-liquidity development instances and counterexamples. Conservation has a local proof
independent of the invariant antecedent; the generic rely/guarantee rule still exposes it. -/
namespace DefiKernel.Interleaving.InterferenceFixtures
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples

abbrev Ledger := State Party Asset Domain

def dollars (amount : ℚ) (_ : BranchId) (s : Ledger) : Prop := total s .main .usd = amount
def sameDollars (_ : BranchId) (pre post : Ledger) : Prop :=
  total post .main .usd = total pre .main .usd

def leftFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, aliceUSD, vaultUSD, aliceUSD, aliceUSD], [vaultUSD, aliceUSD, vaultUSD, aliceUSD]⟩
def rightFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, bobUSD, vaultUSD, bobUSD, bobUSD], [vaultUSD, bobUSD, vaultUSD, bobUSD]⟩
def collateral (s : Ledger) : Prop := s.balance protectedCell = 9

def fragile : BranchId → Ledger → Prop
  | .left, s => s.balance bobUSD = 0
  | .right, s => total s .main .usd = 10

def rightPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.right]
def leftPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.left]

-- BEGIN PROOFS

theorem shared_supply_free : ∀ op template, sharedCfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template selected
  change (if op = ⟨10⟩ then some (transferTemplate .usd (.literal .vault) (.literal .alice))
    else if op = ⟨11⟩ then some (transferTemplate .usd (.literal .vault) (.literal .bob))
    else none) = some template at selected
  split_ifs at selected <;> cases selected <;> rfl

/-- The local total relation needs no invariant antecedent or peer assumption. -/
theorem shared_step_total (boundary : Boundary Party Asset Domain) (index : Nat)
    (history : List (OutputObservation Asset)) (inv : I) (pre : W)
    (result : StepResult Party Asset Domain)
    (h : StepSound sharedCfg boundary index history (.invoke inv) pre result) :
    total result.world.state .main .usd = total pre.state .main .usd := by
  rw [h.accounting, step_no_supply shared_supply_free h, add_zero]

theorem shared_local_obligation (amount : ℚ) :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars amount) sameDollars := by
  intro b index inv _ history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  exact ⟨totalEq.trans initialized, totalEq⟩

theorem shared_cross : CrossInclusion sameDollars sameDollars := by
  intro b peer _ pre post h
  exact h

theorem shared_stable (amount : ℚ) : Stable (dollars amount) sameDollars := by
  intro b pre post initialized same
  exact same.trans initialized

theorem shared_initialized : ∀ b, dollars 10 b sharedInitial.state := by
  intro b
  change total sharedInitial.state .main .usd = 10
  decide +kernel

theorem shared_every_prefix (schedule : Schedule) (length : Nat) :
    ∀ b, dollars 10 b (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight (schedule.take length)).world.state :=
  every_prefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) length

theorem shared_all_tokens (schedule : Schedule) :
    total (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule).world.state
      .main .usd = 10 :=
  runPrefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) .left

theorem shared_left_analyzed : analyzeBranch sharedCfg (boundaries .left) sharedLeft =
    .ok leftFP := by decide +kernel

theorem shared_right_analyzed : analyzeBranch sharedCfg (boundaries .right) sharedRight =
    .ok rightFP := by decide +kernel

theorem shared_overlap : vaultUSD ∈ leftFP.writes ∧ vaultUSD ∈ rightFP.writes := by decide

theorem collateral_supported : Supports {protectedCell} collateral :=
  supports_balance protectedCell (· = 9)

theorem protected_collateral_all_tokens (schedule : Schedule) :
    collateral (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight schedule).world.state := by
  have frame := (runPrefix_reachable sharedCfg boundaries sharedInitial sharedLeft sharedRight
    schedule).analyzed_predicate_frame leftFP rightFP shared_left_analyzed shared_right_analyzed
    {protectedCell} collateral collateral_supported
  have untouched : ∀ c ∈ ({protectedCell} : Set C), c ∉ leftFP.writes ++ rightFP.writes := by
    intro c member
    have eq := Set.mem_singleton_iff.mp member
    subst c
    decide
  apply (frame untouched).mp
  change sharedInitial.state.balance protectedCell = 9
  decide +kernel

/-- All noninitial premises hold for total USD11, but even the empty prefix has total USD10. -/
theorem missing_initialization_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars 11) sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ Stable (dollars 11) sameDollars ∧
    ¬ dollars 11 .left
      (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight []).world.state := by
  refine ⟨shared_local_obligation 11, shared_cross, shared_stable 11, ?_⟩
  change total sharedInitial.state .main .usd ≠ 11
  rw [shared_initialized .left]
  decide

/-- StepSound version of the analyzed target frame for local universal obligations. -/
theorem sound_target_frame {cfg : Config Party Asset Domain}
    {boundary : Boundary Party Asset Domain} {index : Nat}
    {history : List (OutputObservation Asset)} {inv : I} {pre : W}
    {result : StepResult Party Asset Domain} (fp : Footprint Party Asset Domain)
    (analyzed : analyzeInvocation cfg boundary inv = .ok fp)
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    obtain ⟨op, parties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ prepared
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ executed
    intro template selected
    rw [op] at selected
    rw [parties]
    exact (analyzed_dependencies _ _ _ _ analyzed template selected).2.1

theorem fragile_local_obligation :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars := by
  intro b index inv selected history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  refine ⟨?_, totalEq⟩
  cases b with
  | right => exact totalEq.trans initialized
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, sharedLeft, List.getElem?_cons_zero, Option.some.injEq] at selected
      subst inv
      have analyzed : analyzeInvocation sharedCfg (boundaries .left 0) (usd 7) =
          .ok leftFP := by decide +kernel
      exact (sound_target_frame leftFP analyzed step bobUSD (by decide)).trans initialized
    | succ n => simp [selectBranch, sharedLeft] at selected

theorem fragile_initialized : ∀ b, fragile b sharedInitial.state := by
  intro b
  cases b
  · change sharedInitial.state.balance bobUSD = 0
    decide +kernel
  · exact shared_initialized .right

/-- The peer transfers six dollars to Bob while conserving total USD; this breaks Bob=0. -/
theorem missing_peer_stability_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ (∀ b, fragile b sharedInitial.state) ∧
    sameDollars .left sharedInitial.state rightPrefix.world.state ∧
    ¬ fragile .left rightPrefix.world.state := by
  refine ⟨fragile_local_obligation, shared_cross, fragile_initialized, ?_, ?_⟩
  · exact (shared_all_tokens [.right]).trans (shared_initialized .left).symm
  · change rightPrefix.world.state.balance bobUSD ≠ 0
    decide +kernel

theorem fragile_not_stable : ¬ Stable fragile sameDollars := by
  intro stable
  have witness := missing_peer_stability_counterexample
  exact witness.2.2.2.2 (stable .left _ _ (fragile_initialized .left) witness.2.2.2.1)

/-- Empty region agreement alone cannot protect a financial predicate on a written cell. -/
theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set C) sharedInitial.state leftPrefix.world.state ∧
    sharedInitial.state.balance aliceUSD = 0 ∧ leftPrefix.world.state.balance aliceUSD ≠ 0 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c impossible
    cases impossible
  · decide +kernel
  · decide +kernel

theorem empty_support_is_false :
    ¬ Supports (∅ : Set C) (fun s : Ledger ↦ s.balance aliceUSD = 0) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

end DefiKernel.Interleaving.InterferenceFixtures

--- END FILE lean/DefiKernel/Interleaving/InterferenceFixtures.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Reference.lean ---
import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Commutation

/-! Isolated sequential prefix references used by shared-state recovery. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def isolated (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) : Cursor P A D :=
  Composition.run cfg boundary initial ((branch.take n).map Step.invoke)

-- BEGIN PROOFS

theorem isolated_zero (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch 0 = startCursor cfg initial := rfl

theorem isolated_step (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) (inv : Invocation P A D)
    (h : branch[n]? = some inv) :
    isolated cfg boundary initial branch (n + 1) =
      Composition.advance cfg boundary (isolated cfg boundary initial branch n) (.invoke inv) := by
  have ht : branch.take (n + 1) = branch.take n ++ [inv] := by
    rw [List.take_add_one]
    simp [h]
  simp only [isolated, ht, List.map_append, List.map_cons, List.map_nil, Composition.run]
  rw [Composition.continueRun_append]
  rfl

theorem isolated_exhausted (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : branch[n]? = none) :
    isolated cfg boundary initial branch (n + 1) = isolated cfg boundary initial branch n := by
  simp only [isolated, List.take_add_one, h, Option.toList_none, List.append_nil]

theorem continue_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : (Composition.continueRun cfg boundary cursor steps).failure = none) :
    (Composition.continueRun cfg boundary cursor steps).nextIndex =
      cursor.nextIndex + steps.length := by
  induction steps generalizing cursor with
  | nil => simp [Composition.continueRun]
  | cons step tail ih =>
    cases hf : cursor.failure with
    | some failure => simp [Composition.continueRun_failed _ _ _ _ hf, hf] at h
    | none =>
      cases he : executeStep cfg (boundary cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : Composition.advance cfg boundary cursor step =
            { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ } := by
          simp [Composition.advance, hf, he]
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).failure = none at h
        rw [ha, Composition.continueRun_failed _ _ _ _ rfl] at h
        contradiction
      | ok result =>
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).nextIndex = _
        rw [ih _ h]
        simp [Composition.advance, hf, he, Nat.add_assoc, Nat.add_comm]

theorem isolated_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : (isolated cfg boundary initial branch n).failure = none) :
    (isolated cfg boundary initial branch n).nextIndex = min n branch.length := by
  simpa [isolated, Composition.run, startCursor] using
    continue_active_index cfg boundary (startCursor cfg initial)
      ((branch.take n).map Step.invoke) h

theorem isolated_full (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch branch.length = runBranch cfg boundary initial branch := by
  simp [isolated, runBranch]

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Reference.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Step.lean ---
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Interleaving.Recovery.Reference

/-! One-token cursor correspondence and admitted dependency frames. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def footprint (lf rf : Footprint P A D) : BranchId → Footprint P A D
  | .left => lf
  | .right => rf

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem admitted_analysis (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId) :
    analyzeBranch cfg (boundaries b) (selectBranch left right b) = .ok (footprint lf rf b) := by
  obtain ⟨_, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  cases b <;> assumption

omit [Fintype P] [Fintype A] [Fintype D] in
theorem selected_footprint (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId)
    (n : Nat) (inv : Invocation P A D) (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries b n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ (footprint lf rf b).reads) ∧
      (∀ c ∈ part.writes, c ∈ (footprint lf rf b).writes) := by
  simpa using analyzeBranchFrom_member cfg (boundaries b) 0 (selectBranch left right b)
    (footprint lf rf b) (admitted_analysis cfg boundaries left right lf rf hp b) n inv selected

theorem advance_own_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world =
      Composition.advance cfg (boundaries b) ((m.local b).toCursor m.world) (.invoke inv) := by
  cases hf : (m.local b).failure with
  | some failure =>
    cases b <;> simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor, Composition.advance]
  | none =>
    cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world <;>
      cases b <;> simp_all [Interleaving.advance, Machine.refuse, Machine.accept,
        Machine.setLocal, Machine.local, LocalState.toCursor, Composition.advance]

theorem advance_peer_local (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b peer : BranchId) (hne : b ≠ peer) :
    (Interleaving.advance cfg boundaries left right m b).local peer = m.local peer := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs <;> cases b <;> cases peer <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_exhausted_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world = (m.local b).toCursor m.world := by
  cases hf : (m.local b).failure <;> cases b <;>
    simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor]

theorem cursor_advance_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (inv : Invocation P A D) (index : Nat) (part : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeInvocation cfg (boundary index) inv = .ok part)
    (hin : ∀ c ∈ part.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (Composition.advance cfg boundary left (.invoke inv))
      (Composition.advance cfg boundary right (.invoke inv)) := by
  have hs : analyzeBranchFrom cfg boundary index [inv] = .ok (part.append .empty) := by
    simp [analyzeBranchFrom, hf, bind, Except.bind, pure, Except.pure, Except.mapError]
  have hh := continueRun_congr cfg boundary [inv] index (part.append .empty) region
    left right hs (by simpa [Footprint.append, Footprint.empty] using hin) hi ha
  exact hh

theorem advance_branch_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId) :
    ∀ c, c ∉ (footprint lf rf b).writes →
      (Interleaving.advance cfg boundaries left right m b).world.state.balance c =
        m.world.state.balance c := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs with
  | halted => intro c hc; rw [skip_world]
  | exhausted => intro c hc; rw [skip_world]
  | refused => intro c hc; rw [refuse_world]
  | accepted inv result active selected executed =>
    obtain ⟨part, hf, _, hw⟩ := selected_footprint cfg boundaries left right lf rf hp b
      (m.local b).consumed inv selected
    rw [← reach.attempt_index b active inv selected] at hf
    have frame := executeStep_target_frame cfg (boundaries b (m.local b).nextIndex)
      (m.local b).nextIndex (m.local b).outputs inv m.world result part hf executed
    intro c hc
    exact frame.1 c (fun h ↦ hc (hw c h))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem compatible_peer_reads (lf rf : Footprint P A D) (hc : Compatible lf rf)
    (b peer : BranchId) (hne : b ≠ peer) (c : Cell P A D)
    (hr : c ∈ (footprint lf rf peer).reads) : c ∉ (footprint lf rf b).writes := by
  cases b <;> cases peer
  · exact (hne rfl).elim
  · exact fun hw ↦ hc.2.1 c hw hr
  · exact fun hw ↦ hc.2.2 c hw hr
  · exact (hne rfl).elim

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Step.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Simulation.lean ---
import DefiKernel.Interleaving.Recovery.Step

/-! Prefix simulation against independently executed branch prefixes, including exact refusals. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

def Simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (m : Machine P A D) : Prop :=
  ∀ b, CursorAgrees {c | c ∈ (footprint lf rf b).reads}
    ((m.local b).toCursor m.world)
    (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)

theorem advance_own_agrees (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId)
    (ha : CursorAgrees {c | c ∈ (footprint lf rf b).reads}
      ((m.local b).toCursor m.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)) :
    let post := Interleaving.advance cfg boundaries left right m b
    CursorAgrees {c | c ∈ (footprint lf rf b).reads} ((post.local b).toCursor post.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b)
        (post.local b).consumed) := by
  dsimp only
  rw [advance_consumed]
  simp only [ite_true]
  cases selected : (selectBranch left right b)[(m.local b).consumed]? with
  | none =>
    rw [isolated_exhausted cfg (boundaries b) initial _ _ selected,
      advance_exhausted_cursor cfg boundaries left right m b selected]
    exact ha
  | some inv =>
    rw [isolated_step cfg (boundaries b) initial _ _ inv selected,
      advance_own_cursor cfg boundaries left right m b inv selected]
    cases hf : (m.local b).failure with
    | some failure =>
      have hr : (isolated cfg (boundaries b) initial (selectBranch left right b)
          (m.local b).consumed).failure = some failure := ha.failure.symm.trans hf
      simpa [Composition.advance, LocalState.toCursor, hf, hr] using ha
    | none =>
      have hi := reach.attempt_index b hf inv selected
      obtain ⟨part, hp', hin, _⟩ := selected_footprint cfg boundaries left right lf rf hp b
        (m.local b).consumed inv selected
      exact cursor_advance_congr cfg (boundaries b) inv (m.local b).consumed part
        {c | c ∈ (footprint lf rf b).reads} _ _ hp' hin hi ha

theorem advance_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (ha : Simulates cfg boundaries
      initial left right lf rf m) (b : BranchId) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.advance cfg boundaries left right m b) := by
  intro own
  by_cases heq : b = own
  · subst own
    exact advance_own_agrees cfg boundaries initial left right lf rf hp m reach b (ha b)
  · rw [advance_peer_local cfg boundaries left right m b own heq]
    have old := ha own
    have hc := (Parallel.admit_ok cfg boundaries left right lf rf hp).2.2.2
    refine ⟨?_, ?_, old.events, old.outputs, old.nextIndex, old.failure⟩
    · intro c hr
      exact (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (compatible_peer_reads lf rf hc b own heq c hr)).trans (old.state c hr)
    · exact (advance_sound cfg boundaries left right m b).store.trans old.capabilities

theorem continue_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m)
    (ha : Simulates cfg boundaries initial left right lf rf m) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact ha
  | cons b tail ih =>
    exact ih _ (.next b reach (advance_sound cfg boundaries left right m b))
      (advance_simulates cfg boundaries initial left right lf rf hp m reach ha b)

theorem runPrefix_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (runPrefix cfg boundaries initial left right schedule) := by
  apply continue_simulates cfg boundaries initial left right lf rf hp (start initial) .start
  have hv := (Parallel.admit_ok cfg boundaries left right lf rf hp).1
  intro b
  cases b <;>
    exact ⟨fun _ _ ↦ rfl, rfl, rfl, rfl, rfl, by simp [isolated, Composition.run,
      startCursor, Composition.continueRun, Interleaving.start, Machine.local,
      LocalState.toCursor, hv]⟩

theorem continue_outside (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (schedule : Schedule)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (Interleaving.continueRun cfg boundaries left right m schedule).world.state.balance c =
      m.world.state.balance c := by
  induction schedule generalizing m with
  | nil => rfl
  | cons b tail ih =>
    exact (ih _ (.next b reach (advance_sound cfg boundaries left right m b))).trans
      (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (by cases b <;> assumption))

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Simulation.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery.lean ---
import DefiKernel.Interleaving.Recovery.Simulation

/-! Every complete disjoint schedule recovers the full existing canonical parallel observation.
The simulation includes refusals and retained prefixes; raw foreign event worlds are not equated. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel Recovery

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem runPrefix_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule)
      ⟨mergeWorld lf rf initial l.world r.world, l, r⟩ := by
  have sim := runPrefix_simulates cfg boundaries initial left right lf rf hp schedule
  have counts := runPrefix_complete_counts cfg boundaries initial left right schedule complete
  have hl := sim .left
  have hr := sim .right
  simp only [Machine.local, footprint, selectBranch, counts.1, counts.2, isolated_full] at hl hr
  obtain ⟨_, al, ar, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  refine ⟨⟨?_, ?_⟩, hl.observation, hr.observation⟩
  · intro c
    by_cases hcl : c ∈ lf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .left) 0 left lf al c hcl
      simpa [mergeWorld, hcl, LocalState.toCursor] using hl.state c hread
    · by_cases hcr : c ∈ rf.writes
      · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf ar c hcr
        simpa [mergeWorld, hcl, hcr, LocalState.toCursor] using hr.state c hread
      · simpa [mergeWorld, hcl, hcr, runPrefix, Interleaving.start] using
          continue_outside cfg boundaries initial left right lf rf hp (start initial)
            .start schedule c hcl hcr
  · exact (runPrefix_reachable cfg boundaries initial left right schedule).store

/-- The actual public evaluator and existing parallel evaluator return related executed results. -/
theorem runInterleaving_recovers (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    ∃ joined, Parallel.runParallel cfg boundaries initial left right = .executed joined ∧
      runInterleaving cfg boundaries initial left right schedule =
        .executed schedule (runPrefix cfg boundaries initial left right schedule) ∧
      ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule) joined := by
  refine ⟨_, ?_, ?_,
    runPrefix_parallel cfg boundaries initial left right lf rf hp schedule complete⟩
  · simp [Parallel.runParallel, hp]
  · simp [runInterleaving, admit_of_parallel cfg boundaries left right schedule lf rf hp complete]

theorem runInterleaving_matchesParallel (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runParallel cfg boundaries initial left right) = true := by
  obtain ⟨joined, hp', hs, related⟩ :=
    runInterleaving_recovers cfg boundaries initial left right lf rf hp schedule complete
  rw [hp', hs, matchesParallel_iff]
  exact related

theorem matchesParallel_transport (shared : Interleaving.Result P A D)
    (first second : Parallel.Result P A D)
    (h : matchesParallel shared first = true)
    (equiv : Parallel.ObservationallyEquivalent first second) :
    matchesParallel shared second = true := by
  cases shared with
  | refused => simp [matchesParallel] at h
  | executed schedule m =>
    cases first with
    | refused => simp [matchesParallel] at h
    | executed a =>
      cases second with
      | refused => exact equiv.elim
      | executed b =>
        rw [matchesParallel_iff] at h ⊢
        exact ⟨h.1.trans equiv.1, h.2.1.trans equiv.2.1, h.2.2.trans equiv.2.2⟩

theorem runInterleaving_matchesSerialLR (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialLR cfg boundaries initial left right)

theorem runInterleaving_matchesSerialRL (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialRL cfg boundaries initial left right)

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockLR (left right : Branch P A D) :
    Complete left right
      (List.replicate left.length .left ++ List.replicate right.length .right) := by
  simp [Complete, List.count_replicate]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockRL (left right : Branch P A D) :
    Complete left right
      (List.replicate right.length .right ++ List.replicate left.length .left) := by
  simp [Complete, List.count_replicate]

theorem runInterleaving_blockLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate left.length .left ++ List.replicate right.length .right))
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialLR cfg boundaries initial left right lf rf hp _
    (complete_blockLR left right)

theorem runInterleaving_blockRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate right.length .right ++ List.replicate left.length .left))
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialRL cfg boundaries initial left right lf rf hp _
    (complete_blockRL left right)

theorem runInterleaving_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left [] = .ok (lf, .empty)) (schedule : Schedule)
    (complete : Complete left [] schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left [] schedule)
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left [] lf .empty hp schedule complete)
    (Parallel.runParallel_empty_right cfg boundaries initial left lf hp)

theorem runInterleaving_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries [] right = .ok (.empty, rf)) (schedule : Schedule)
    (complete : Complete [] right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial [] right schedule)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial [] right .empty rf hp schedule complete)
    (Parallel.runParallel_empty_left cfg boundaries initial right rf hp)

theorem runInterleaving_empty (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (hv : validateCatalog cfg.registry cfg.catalog = true) :
    runInterleaving cfg boundaries initial [] [] [] = .executed [] (start initial) := by
  simp [runInterleaving, Interleaving.admit, hv, analyzeBranch, analyzeBranchFrom,
    checkSchedule, Except.mapError, bind, Except.bind, pure, Except.pure,
    runPrefix, Interleaving.continueRun]

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Recovery.lean ---

--- BEGIN FILE lean/DefiKernel/AxiomAudit.lean ---
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit

--- END FILE lean/DefiKernel/AxiomAudit.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Verify.lean ---
import DefiKernel.Interleaving.Audit
import DefiKernel.Interleaving.Trace
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.InterferenceFixtures
import DefiKernel.Interleaving.Recovery
import DefiKernel.AxiomAudit

/-! Audit every imported Interleaving theorem and supplemental declaration by module provenance.
Runtime comparisons and generic proofs remain separate evidence classes. -/
#audit_axioms DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Verify.lean ---

--- BEGIN FILE AGENTS.md ---
# Working instructions

The user approved the semantic-kernel pivot on 2026-09-06. Read
`docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
`docs/research/semantic-kernel-progress.md` before continuing work.

- The new migration supersedes the old publication-first runstate and the
  positive-program primitive-basis mandate. Historical documents remain
  evidence, not instructions to pursue a withdrawn objective.
- Use GPT-6 for implementation through the stock Codex harness. Have Grok and
  Fable independently check substantive results. Invoke their native CLIs
  directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
  label its response Grok or Fable.
- Record the exact reviewed revision, requested/reported model identity,
  result, findings, and fixes. An unavailable reviewer is an open review, not
  an approval. Review is advisory evidence, not a mathematical proof.
- Preserve existing proofs and negative results. Put new kernel work in a
  separate namespace. Do not change a historical theorem statement to make a
  new claim pass.
- Read `.claude/skills/defi-footguns/SKILL.md` and
  `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
  Empty checks are blocked. Keep proof, bounded execution, measurement and
  unchecked assumptions distinct, with exact input and tool identities.
- Lean is the mathematical authority. Any executable IR or Quint abstraction
  needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
  in accepted kernel proofs.
- Preserve the original corpus and versioned source evidence. Do not silently
  relabel development examples as untouched holdouts.
- User authorization to execute this migration is already present. Resolve
  routine implementation details without repeatedly requesting approval.

--- END FILE AGENTS.md ---

--- BEGIN FILE lean/lean-toolchain ---
leanprover/lean4:v4.33.0-rc2

--- END FILE lean/lean-toolchain ---

--- BEGIN FILE lean/lakefile.toml ---
name = "defialgebra"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["Defialgebra", "DefiKernel"]

[leanOptions]
pp.unicode.fun = true # pretty-prints `fun a ↦ b`
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.33.0-rc2"

[[lean_lib]]
name = "Defialgebra"

[[lean_lib]]
name = "DefiKernel"

--- END FILE lean/lakefile.toml ---

--- BEGIN FILE lean/lake-manifest.json ---
{"version": "1.2.0",
 "packagesDir": ".lake/packages",
 "packages":
 [{"url": "https://github.com/leanprover-community/mathlib4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "51e6992efd06126df61a496bebf8f49482a4e129",
   "name": "mathlib",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": false,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/plausible",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "123d15766ba49356c02ebad2a4462dfe12d79899",
   "name": "plausible",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/LeanSearchClient",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "f5c090429dff3cf66cb65562526c9ea6e8edfbcb",
   "name": "LeanSearchClient",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/import-graph",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "bb3469a87774349fe01898d8bf2fc6a1ce6411ca",
   "name": "importGraph",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/ProofWidgets4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "222c58dad7706a6e7cae46c0edd65ea881d3ee27",
   "name": "proofwidgets",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/aesop",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "7db8190085343afde2f5d2cdcc9bac719b6ec02c",
   "name": "aesop",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/quote4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "ef42f8944eaf5b6cbfbe75d1917d824c7dd6cf33",
   "name": "Qq",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/batteries",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "76e1c118b0700b4ceafe99532e887d6431625e1a",
   "name": "batteries",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover/lean4-cli",
   "type": "git",
   "subDir": null,
   "scope": "leanprover",
   "rev": "1319485273bf87833fa472afbcefdedecb16b45f",
   "name": "Cli",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": true,
   "configFile": "lakefile.toml"}],
 "name": "defialgebra",
 "lakeDir": ".lake",
 "fixedToolchain": false}

--- END FILE lean/lake-manifest.json ---

--- BEGIN FILE lean/DefiKernel.lean ---
import DefiKernel.VerifyAxioms
import DefiKernel.Typed.Verify
import DefiKernel.Composition.Verify
import DefiKernel.Parallel.Verify
import DefiKernel.Interleaving.Verify

/-! Entry point for the pilot, typed kernel, regressions and imported axiom audits. -/

--- END FILE lean/DefiKernel.lean ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/proposal.md ---
## Why

Sprint 6 proves composition for disjoint branches, but financial workflows often
compete for the same liquidity or observe balances changed by a peer. We need
explicit shared-state execution and conditional preservation across schedules,
including different success/refusal outcomes when order matters.

## What Changes

- Add finite binary invocation interleaving over one evolving world, with separate
  local histories, stable trusted boundaries and retained successful prefixes.
- Validate complete schedules and structural interfaces before execution; permit
  overlapping footprints. Keep runtime admission distinct from proof obligations.
- Define successful-event interference relations and initialized, noncircular
  rely/guarantee premises; prove accounting, authority, locality and invariants.
- Recover Sprint 6 canonical observations for every complete disjoint schedule.
- Add independently specified financial fixtures, production source mutations,
  axiom coverage, exact review records and a linked `wiki-llm/` decision record.

## Capabilities

### New Capabilities

- `interleaving-execution`: schedules, shared execution, refusal and observations.
- `interleaving-preservation`: sound traces, interference and preservation proofs.
- `interleaving-disjoint-recovery`: correspondence to disjoint parallel behavior.
- `interleaving-regression-evidence`: financial checks, mutations and review gates.

### Modified Capabilities

None. Existing sequential and disjoint parallel requirements remain intact.

## Impact

New Lean modules live in `lean/DefiKernel/Interleaving/`; the kernel import root
adds their verification driver. New scoped mutation tooling and evidence live in
`scripts/` and `review/semantic-kernel/sprint7/`. Roadmap/progress and wiki notes
track accepted work. Exact rational arithmetic and existing dependencies remain.

## Non-goals

Atomic synchronization, rollback, capability issue/revoke inside branches,
capability provenance, unbounded fairness/liveness, arbitrary shared-state
schedule equivalence, N-ary associativity and deployed-protocol fidelity are
separate work. These examples are development cases, not untouched holdouts.

--- END FILE openspec/changes/shared-state-interleaving/proposal.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/design.md ---
## Context

Base: `850d785d41dc311785dc33cdb3f65c368756434c`, branch
`semantic-kernel-pivot`. See [proposal](proposal.md). Existing
`Composition.executeStep` supplies exact refusal precedence, post-state snapshots,
receipts and `StepSound`. `Parallel.analyzeBranch` supplies whole-branch structural
checks and conservative footprints. `Parallel.runParallel` rejects overlapping
footprints and merges independent executions; it remains unchanged.

## Goals / Non-Goals

Build a deterministic evaluator for each finite supplied schedule and generic
proofs across all such schedules. Keep executable admission, proved conditional
invariants and bounded fixture enumeration separate. Trust in the catalog,
registry, authenticated boundaries, observations and initial capability store
remains explicit. Non-goals are in the proposal.

## Decisions

### 1. Schedules and preflight

Reuse `Parallel.BranchId`, invocation-only `Branch` and `ParallelBoundary`.
`Schedule := List BranchId`. A complete schedule contains exactly `left.length`
left tokens and `right.length` right tokens. Each token denotes the next static
slot of that branch, so local order is built into the representation. A branch
that has refused consumes later tokens as skipped slots without retrying.
This separates schedule validity from state-dependent success.

`checkSchedule` returns an exact count-mismatch record (expected/observed counts
for both branches) or success. `admit` checks catalog validity, complete left
structural analysis, complete right structural analysis, then schedule counts.
Structural refusals keep the existing local failure index and reason; schedule
refusal is a distinct constructor. Footprint overlap does not reject execution.
Any preflight refusal returns the initial world and no events or branch outputs.
Analyze unreachable suffixes just as Sprint 6 does.

Alternative A, chosen: explicit complete finite schedules with skipped failed
suffix slots. Alternative B: an adaptive scheduler selecting only live branches
would make replay and completion depend on runtime results. Alternative C:
transactions with rollback would conflate this increment with atomic settlement.

### 2. Shared execution and observations

`Machine` contains one `world`, left/right local branch state, and an ordered
global attempt log. Local branch state contains a static consumed-slot count,
successful `Composition.Event` list, local output history and first
`Composition.LocatedFailure`. The consumed count advances on each token, even
after refusal; successful `nextIndex` in canonical branch observations remains
the number of successful invocations, matching Sprint 6.

`advance` obtains the invocation at that branch's consumed slot. For an active
branch it calls `Composition.executeStep cfg (boundaries branch localIndex)
localIndex ownHistory (.invoke invocation) machine.world`. Success replaces the
one shared world, appends the real event and own post-state outputs, and increments
the branch's successful index. Refusal keeps the shared world and outputs,
records the exact located failure, and halts only that branch. A skipped token
changes only the consumed count; it has no attempt event. The internal evaluator
is total on arbitrary token lists: tokens beyond a branch length also skip;
the public evaluator admits only complete schedules. This totalization is not a
public acceptance of malformed schedules.

Every attempt records branch, local index, selected invocation, pre-world and
either the complete successful step result or exact refusal. Successful branch
events are the corresponding projection of that global log. Peer histories are
never concatenated. Snapshot values are frozen at their producing step; later
expressions reading ledger state see the current shared world. Fixed boundaries
are indexed by branch/local position, never global position. Boundary timestamps
are supplied observations; no monotonic global clock or oracle truth is inferred.

The full result exposes initial admission versus an executed machine, the supplied
schedule, complete final ledger/store, consumed slots, global attempts, and both
branch observations. Comparison for disjoint recovery deliberately projects away
global schedule/attempt order, consumed failed suffix slots, and raw foreign
pre/post worlds. It retains exact final ledger/store and the existing complete
`Parallel.BranchObservation` fields (events, requests, evaluated receipts, typed
outputs, successful next index and exact located failure). This projection is
named and never described as equality of the full shared execution trace.

### 3. Soundness and preservation

Define an inductive machine reachability relation mirroring successful attempts,
failed attempts and skipped slots, and prove the actual evaluator produces it.
Each successful transition includes the real `executeStep = .ok result` witness;
each refusal includes `executeStep = .error reason`. Prove branch-local order,
history isolation, attempt-prefix continuity, refusal stability, skipped-slot
inertia, immutable capability store, and completion of both static slot counts
for admitted schedules. The trace witness must connect actual initial/final worlds,
not merely certify unrelated individually valid receipts.

Use `executeStep_sound` and existing `StepSound` lemmas to prove, for every
evaluated schedule prefix, per-domain/asset final total equals initial total plus
the sum of actual successful receipt supplies. Failed/skipped slots contribute
zero. Prove every success is authorized at its actual pre-world and trusted local
boundary, hence under the fixed initial capability store. Record nonnegativity
as reuse of proof-carrying `State` witnesses for every reached world.

Prove final balance agreement outside the union of actual successful writes and
outside the union of both analyzed branch write footprints. Lift this to every
ledger predicate supported on a protected region disjoint from those writes.
Admission refusal has identity laws. Failure attempts and skipped slots preserve
the entire ledger, not just a protected region.

### 4. Explicit interference obligations

Use ledger predicates `I_left`, `I_right` and relations `G_left`, `G_right`,
`R_left`, `R_right` on pre/post ledgers. Relations describe successful invocations;
refusals/skips are identity cases and need no supplied relational witness.

For each branch b, require a local obligation over **all** branch positions,
histories and worlds with `I_b pre`, for the branch invocation at that position
and the fixed trusted local boundary: a real successful step implies both
`I_b post` and `G_b pre post`. This obligation is proved independently of the
peer's invariant and of the desired whole-run conclusion. Require
`G_left ⊆ R_right`, `G_right ⊆ R_left`, and separate stability
`I_b pre ∧ R_b pre post → I_b post`. Initial state satisfies both predicates.
Induction over real attempts then proves both invariants at every schedule prefix.
This is an explicit sufficient rule, not automatic invariant discovery or an
executable decision procedure for arbitrary predicates.

Instantiate a nontrivial overlapping-support example: two transfer branches use
the same source liquidity and preserve exact total USD10; each succeeds or refuses
depending on remaining balance. Choose guarantee/rely equality of total USD,
prove local obligations from the no-supply operation templates, and establish
initialization from the concrete ledger. Also show why initialization and peer
stability cannot be omitted using concrete counterexamples. A second protected-
collateral predicate demonstrates the supported frame rule.

### 5. Recovery of disjoint composition

For every pair accepted by existing `Parallel.admit` and every complete schedule,
prove the shared result's canonical projection equals `Parallel.runParallel`,
then derive equality with its actual LR/RL references. Do not assume this equality
or success of every invocation as a premise. Use a prefix simulation: track each
branch's isolated cursor, own history and region agreement; prior peer writes
frame its dependencies. Reuse `Parallel.Dependency.Adapter` step congruence and
the analyzed footprint lemmas. Raw event worlds may differ outside the dependency
region. Refusal equality and stopped branches are mandatory cases.

Prove empty/one-empty laws and full-block LR/RL schedule agreement. Include a
shared-source counterexample whose schedules produce different branch outcomes;
no equivalence theorem is claimed outside the compatibility premise.

### 6. Financial examples and discriminating evidence

All fixtures use exact rational arithmetic, funded and authorized controls,
complete expected worlds/stores and exact outcome fields. Required families:

1. USD10 shared-source transfers: left withdraws7 to Alice, right withdraws6 to
   Bob. LR leaves source3/Alice7/Bob0 and right insufficient-funds; RL leaves
   source4/Alice0/Bob6 and left insufficient-funds. All other cells remain fixed.
2. Replenish then withdraw: a branch deposits liquidity before a peer withdrawal;
   reversing order refuses the withdrawal, without retry after replenishment.
3. Multi-step state-dependent effects: a peer changes a ledger value between own
   steps; live reads use the new value while previously emitted outputs stay fixed.
   Independently expected full receipts discriminate stale-world evaluation.
4. Branch history isolation: identical fully qualified output keys may now have
   different values at different interleaved states. Own lookups retain the own
   snapshot. A peer-only producer is rejected beside a successful own/literal
   sibling. Check component qualification, typed units and local indices.
5. Immediate/middle/dual refusals, skipped suffix, successful peer continuation,
   empty branches, malformed schedules and malformed unreachable suffix.
6. Independent supply changes, protected collateral, local principal/time binding,
   unauthorized access and pre-fork revoked-capability siblings.
7. Disjoint 2+2 invocations: enumerate all six schedules, compare each with an
   independent expected world and existing parallel observations. Also include
   refused disjoint multi-step branches. These finite examples supplement the
   general Lean recovery proof.

Fourteen required semantic source mutants, each with a distinct designated
runtime oracle and a protected successful sibling: schedule-count bypass;
reintroduce overlap rejection; stale initial-world execution; replace shared world
with an isolated branch result; global cancellation on one refusal; prefix rollback;
retry halted suffix; peer-history leakage; output snapshot recomputation;
global-position boundary lookup; wrong branch-local invocation selection;
drop a successful peer receipt from accounting aggregation; resurrect revoked
capabilities; canonical observation omission of exact failure. Where a mutant has
overlapping oracle coverage, report that dependence. Mutation 14 must alter the
actual comparison/projection consumed by public recovery checks, and a negative
observation control must distinguish the changed failure beside an equal pair.

The runner uses fresh proof-stripped source projections, compiles actual mutant
production code, executes the entire named inventory, and requires designated
false comparisons plus protected true comparisons. A compile failure, malformed
log, absent/duplicate label, no-op edit, survivor or stale source is never counted
as detection. Include actual CLI accepted, failed and blocked controls following
the established Parallel runner pattern, without changing its accepted scope.

### 7. File and proof boundaries

New files under `lean/DefiKernel/Interleaving/`:
`Schedule.lean` (preflight/count laws), `Execution.lean` (machine/runner),
`Soundness.lean` (actual trace witness and structural laws), `Preservation.lean`
(accounting/authority/frame), `Interference.lean` (conditional rule),
`Recovery.lean` (disjoint simulation), `Examples.lean` (reference definitions),
`Tests.lean` (named comparisons/counterexamples), `Audit.lean` (runtime),
`Verify.lean` (automatic imported theorem/supplemental declaration audit).
Split a module further only at an independent responsibility boundary.

Add `scripts/check_interleaving_mutations.py`,
`scripts/test_interleaving_mutation_runner.py`, a frozen mutation spec and evidence
under `review/semantic-kernel/sprint7/`. Preserve every historical Lean/corpus file;
the import root and current documentation are intentional updates. If a reusable
new helper is needed for old code, place it in the new namespace initially.

## Risks / Trade-offs

- Strong local universal premises can be harder to instantiate than reachable-only
  assumptions → provide the concrete overlapping example and expose the strength.
- Generic disjoint recovery is the largest proof → implement its prefix simulation
  before declaring the scope achievable; finite tests cannot replace it.
- Exact shared output-key collisions were impossible in Sprint 6 → construct
  different snapshots via actual peer writes, not invented impossible fixtures.
- Extensive test counts can obscure oracle overlap → publish named inventories,
  individual mutation outcomes and separate generic proofs from examples.
- Fixed capabilities omit revocation races → retain this boundary explicitly.

## Migration Plan

Save and strictly validate proposal/design/specs/tasks. Freeze candidate and review
bundle in Git; obtain separate GPT-6 stock-harness and native Fable 5.1 planning
verdicts. Implement only after both pass and a current baseline succeeds. Initial
review plus one targeted revision is the default budget; extend only for a concrete
unresolved finding. Unavailable/incomplete reviews remain open.

Use the established branch, full legacy regressions, fresh axiom coverage and
native Grok/Fable implementation audits. Record exact candidate and model identity,
raw requests/responses, findings and fixes. Push the branch and verify the remote;
archive only after all tasks and gates pass. Wiki notes are a decision index, never
a replacement for specs or hash-bound evidence. Rollback is removal/revert of the
new namespace/import through a subsequent commit; no historical rewriting.

--- END FILE openspec/changes/shared-state-interleaving/design.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md ---
## Purpose

Relate shared execution to accepted disjoint parallel semantics without equating order-sensitive shared-state outcomes.

## ADDED Requirements

### Requirement: Universal disjoint recovery

For every pair admitted by existing disjoint parallel admission and every complete finite schedule, the named canonical projection of shared execution SHALL equal the existing parallel observation, including exact refusals and retained prefixes. The theorem SHALL derive this result from dependency/frame proofs rather than assume commutation or success-only premises.

#### Scenario: All disjoint schedules

- **WHEN** any complete schedule interleaves structurally accepted branches with compatible footprints
- **THEN** the generic theorem identifies its complete canonical observation with the existing parallel and LR/RL reference observations

#### Scenario: Disjoint refusal

- **WHEN** one disjoint branch refuses in the middle while its peer continues
- **THEN** recovery preserves the same local failure, own successful prefix and complete peer outcome

#### Scenario: Six concrete schedules

- **WHEN** two disjoint branches each have two invocations
- **THEN** all six complete schedules also match independent expected worlds and canonical branch observations in bounded execution

### Requirement: Empty and serial specializations

The system SHALL prove empty/one-empty identity laws and full-block LR/RL schedule correspondence under the same admission and canonical-observation boundaries. It SHALL retain concrete counterexamples to arbitrary shared-state schedule equivalence.

#### Scenario: Empty peer

- **WHEN** one branch is empty and the other succeeds or refuses
- **THEN** the shared observation agrees with its existing sequential branch behavior and empty peer observation

#### Scenario: Full-block schedules

- **WHEN** all left tokens precede all right tokens or vice versa for a disjoint pair
- **THEN** the canonical result equals the corresponding existing real serial evaluator

#### Scenario: Order-sensitive shared state

- **WHEN** two withdrawals compete for insufficient combined liquidity
- **THEN** LR and RL have different independently checked successful/refused branches, so unrestricted equivalence is refuted

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md ---
## Purpose

Define replayable shared-state execution with exact local histories, refusal outcomes and explicit schedule validity.

## ADDED Requirements

### Requirement: Complete finite schedules

The evaluator SHALL accept finite binary invocation-only branches and a schedule with exactly one token per static invocation slot of each branch. Tokens SHALL select branch-local slots in order. Invalid counts SHALL produce a typed preflight refusal with expected and observed counts for both branches.

#### Scenario: Balanced schedule

- **WHEN** both branches contain two invocations and the schedule is left,right,left,right
- **THEN** preflight accepts the schedule and each branch consumes its two slots in local order

#### Scenario: Missing and excess slots

- **WHEN** a schedule omits a right slot or adds a left slot, including extra tokens for an empty branch
- **THEN** preflight refuses with exact expected/observed counts before any execution

#### Scenario: Empty schedules

- **WHEN** both branches and the schedule are empty
- **THEN** execution returns the initial world, empty attempts and empty branch observations

### Requirement: Structural admission permits shared state

The evaluator SHALL check configuration, the complete left branch, the complete right branch, then schedule counts in that order. It SHALL preserve exact structural failure location and reason, including in unreachable suffixes. Overlapping footprints SHALL NOT itself refuse execution. Every admission refusal SHALL preserve the initial world and emit no attempts or outputs.

#### Scenario: Overlapping funded branches

- **WHEN** two structurally valid funded and authorized branches write the same cell
- **THEN** preflight admits them without requiring disjointness or proof of an invariant

#### Scenario: Unreachable malformed suffix

- **WHEN** an early invocation would financially refuse but its branch has an unknown operation later
- **THEN** the whole-branch structural check refuses at the later local index without executing the prefix

#### Scenario: Preflight precedence

- **WHEN** configuration, structural and schedule errors coexist
- **THEN** the first error in configuration-left-right-schedule order is returned

### Requirement: One evolving shared world

Each active scheduled invocation SHALL execute against the current shared world through the existing trusted single-step semantics. Successful attempts SHALL update that world and emit their actual complete receipts and post-state snapshots. Boundaries SHALL depend only on branch identity and local invocation index. The capability store SHALL remain equal to the initial store.

#### Scenario: Competing liquidity

- **WHEN** left withdraws7 and right withdraws6 from shared USD10 under LR and RL schedules
- **THEN** LR leaves source3/Alice7/Bob0 with right insufficient-funds; RL leaves source4/Alice0/Bob6 with left insufficient-funds, preserving all other cells and the full capability store

#### Scenario: Replenishment order

- **WHEN** one branch funds liquidity before or after a peer withdrawal
- **THEN** the withdrawal observes the balance at its actual attempt and a refused withdrawal is not retried after replenishment

#### Scenario: Local boundary identity

- **WHEN** a multi-step branch is shifted in global schedule position while local trusted inputs are fixed
- **THEN** each attempted step uses its original branch-local principal, environment and time

#### Scenario: Revoked authority

- **WHEN** the initial store differs only in a required grant being live versus revoked
- **THEN** the live funded invocation succeeds and the revoked one refuses for its exact authority reason

### Requirement: Branch-local refusal and history

The first runtime refusal SHALL halt only its own branch, retaining every earlier successful effect, receipt and output. Later tokens of that branch SHALL skip without another attempt. Peer execution SHALL continue. Input resolution SHALL use only the selected branch history with qualified keys and typed units; old snapshots SHALL remain fixed.

#### Scenario: Retained prefix and peer continuation

- **WHEN** a branch succeeds then refuses while its peer has remaining valid invocations
- **THEN** the prefix and peer effects remain, the first exact failure remains stable, and the failed suffix contributes no attempts

#### Scenario: Dual refusal

- **WHEN** both branches refuse at their own local indices
- **THEN** both exact failures remain visible and neither is replaced by the peer failure

#### Scenario: Different snapshots at the same key

- **WHEN** interleaved producers capture different balances at the same fully qualified output key in separate branches
- **THEN** each later local consumer resolves its own value and the stored snapshots do not change after peer writes

#### Scenario: Peer-only history

- **WHEN** only the peer has produced a requested output while an own-history or literal sibling supplies the correct unit and funding
- **THEN** the peer-only reference refuses for the intended missing-history reason and the sibling succeeds

### Requirement: Complete observations and prefix execution

Results SHALL expose the supplied schedule, one final world, consumed slot counts, ordered real success/refusal attempts and both branch observations. Internal finite-prefix execution SHALL be total, explicitly distinguishing skipped and attempted slots. Canonical comparison SHALL retain complete final balances/store, branch labels, ordered requests/receipts/typed outputs, successful indices and exact failures; only global order, consumed skipped slots and raw foreign event worlds SHALL be omitted by the named disjoint projection.

#### Scenario: Attempt continuity

- **WHEN** successes and refusals alternate across branches
- **THEN** every attempt begins at the previous attempt post-world or unchanged refused world and successful branch events are its branch projection

#### Scenario: Observation sensitivity

- **WHEN** two results differ only in one exact refusal, index, request, receipt, output, branch label, final balance or capability entry
- **THEN** canonical comparison distinguishes the changed field; an identical pair remains equal

#### Scenario: Skipped tokens

- **WHEN** a schedule prefix selects an already failed branch or exceeds its static length
- **THEN** internal execution changes only its consumed slot count, emits no attempt, and cannot make an invalid complete schedule publicly admitted

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md ---
## Purpose

Establish actual-trace preservation and initialized interference rules for every finite shared-state schedule prefix.

## ADDED Requirements

### Requirement: Actual trace soundness

Every evaluated prefix SHALL have an inductive witness connecting its actual initial and final machines. Each success SHALL carry real single-step execution and soundness witnesses; each refusal SHALL carry its real exact failed execution. Local order, history isolation, refusal stability and immutable capabilities SHALL be proved from the runner.

#### Scenario: Prefix soundness

- **WHEN** any finite token prefix executes, including first or middle refusals
- **THEN** the proof connects actual worlds, attempts and local histories without assuming the target runner result

#### Scenario: Complete slot consumption

- **WHEN** an admitted full schedule executes despite failed suffixes
- **THEN** both consumed counts equal their static branch lengths and each branch has exhausted its invocations or retains its first refusal

### Requirement: Accounting authority and nonnegativity

For every finite prefix, total final balance in each domain/asset SHALL equal initial total plus actual successful receipt supplies. Each success SHALL be authorized at its actual pre-world and trusted branch-local boundary under the fixed initial capability store. All reached balances SHALL be nonnegative with the proof-carrying state premise stated.

#### Scenario: Supply and refusal

- **WHEN** both branches emit nonzero supply changes and one later refuses
- **THEN** the equation includes each actual successful supply exactly once and contributes zero for refusals/skips

#### Scenario: Authority at execution

- **WHEN** a funded unauthorized attempt is interleaved with an authorized peer
- **THEN** the unauthorized attempt refuses and every accepted receipt has point-of-use authority evidence

#### Scenario: Reached worlds

- **WHEN** any schedule prefix reaches a success or refusal
- **THEN** initial, intermediate and final nonnegativity are established through the state witnesses

### Requirement: Locality and supported frames

Execution SHALL preserve cells outside actual successful write footprints and outside the union of admitted analyzed branch writes. A ledger predicate SHALL be framed only with explicit support on a protected region disjoint from the relevant writes. Refused and skipped attempts SHALL preserve the whole ledger.

#### Scenario: Protected collateral

- **WHEN** overlapping USD transfers leave a separately supported collateral region untouched
- **THEN** the concrete collateral predicate and every protected balance remain unchanged

#### Scenario: Missing support counterexample

- **WHEN** a purported protected predicate depends on a cell that a valid branch changes
- **THEN** a concrete counterexample shows that the predicate cannot be framed from the stated smaller region

### Requirement: Initialized interference composition

The system SHALL prove both branch invariants at every prefix from initialization, independently proved own-step invariant/guarantee obligations, each guarantee included in the peer rely relation, and stability of each invariant under its rely relation. Own-step obligations SHALL quantify over all own-invariant worlds, histories and applicable branch positions with the fixed local boundaries. They SHALL NOT assume the peer invariant, the final result, or the desired whole-run preservation theorem.

#### Scenario: Overlapping invariant instance

- **WHEN** two competing shared-source transfer branches start at total USD10 and each guarantees unchanged USD total
- **THEN** explicit equality-of-total rely relations, local guarantees and initialization instantiate preservation of total USD10 under every schedule prefix, even when one branch refuses

#### Scenario: Initialization is necessary

- **WHEN** a preserved total predicate is false in the initial ledger
- **THEN** a concrete counterexample prevents concluding that it becomes true merely from step preservation

#### Scenario: Peer stability is necessary

- **WHEN** a locally preserved predicate is changed by an otherwise valid peer invocation
- **THEN** a concrete counterexample shows why own preservation alone cannot discharge the interference theorem

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md ---
## Purpose

Bind shared-state proof and runtime claims to nonempty discriminating evidence, exact source revisions and independent reviews.

## ADDED Requirements

### Requirement: Independent financial evidence

Reference workflows SHALL check independent complete expected worlds/stores, receipts, outputs and exact failures. Evidence SHALL cover competing liquidity, replenishment, live reads versus snapshots, qualified local history, boundary identity, prefix refusal, supply, protected state, unauthorized/revoked capabilities and disjoint schedules. Development examples SHALL remain labeled as such.

#### Scenario: Full financial oracle

- **WHEN** all required example families run against the frozen source
- **THEN** every named comparison executes, full worlds/stores and intended errors match independent expected values, and the nonempty unique inventory is saved

#### Scenario: Live versus frozen values

- **WHEN** a peer changes shared state between a producer and a consumer
- **THEN** independent expected values distinguish current-ledger evaluation from own prior snapshots

### Requirement: Production mutation sensitivity

Fourteen semantic source mutations specified in the design SHALL compile and execute through the real production runner and complete named runtime inventory. Each SHALL cause its designated false comparison while protected positives remain true. Empty, partial, malformed, duplicate or unknown inventories, compile-only failures, no-op edits and survivors SHALL fail or block explicitly without being counted as detections.

#### Scenario: Semantic mutation

- **WHEN** each required production mutation is run in a fresh isolated projection
- **THEN** its actual edit, compile/run logs, designated failure and protected positives are saved with exact source and artifact hashes

#### Scenario: Runner controls

- **WHEN** actual runner CLI calls encounter empty/partial/duplicate/unknown results, missing/nonunique/no-op edits, compile failures, survivors, failed positives or unsafe output locations
- **THEN** each rejects for its intended diagnostic beside a valid accepted control

#### Scenario: Source drift

- **WHEN** an input differs from the frozen candidate or changes during execution
- **THEN** evidence blocks instead of attributing results to the wrong revision

### Requirement: Proof inventory and regression integrity

The sprint SHALL retain automatic imported theorem and supplemental declaration axiom audits, allowing no sorry, custom axioms or native_decide in accepted kernel proofs. Named inventories SHALL distinguish generic proofs, concrete instances, counterexamples, generated declarations and runtime checks. Existing kernel, corpus, compiler, mutation and runner regressions SHALL pass on the accepted source with historical bytes preserved.

#### Scenario: Imported proof coverage

- **WHEN** the full build and new verification root run
- **THEN** every in-scope imported declaration is inventoried with zero forbidden dependencies and named theorem premises are recorded

#### Scenario: Legacy preservation

- **WHEN** the current source is compared with the base and full legacy checks run
- **THEN** historical source/corpus bytes are unchanged apart from the declared import-root/documentation updates, and fresh command exits/logs are retained

### Requirement: Planning implementation and delivery gates

Implementation SHALL begin only after independent GPT-6 and native Fable planning reviews pass on the same frozen candidate and a current baseline passes. Substantive results SHALL receive native Grok and Fable reviews with exact requested/reported models, source identity, findings and fixes. An unavailable or incomplete review SHALL remain open. Stock Codex SHALL implement using GPT-6 without Foreman. Wiki notes SHALL record decision summaries and links without presenting plans as proved results. Archive SHALL require all tasks and acceptance gates complete.

#### Scenario: Planning gate

- **WHEN** candidate specs, design and tasks are frozen and both required reviewers pass
- **THEN** the recorded gate authorizes the already approved implementation; schema completeness alone does not authorize it

#### Scenario: Unavailable reviewer

- **WHEN** a native provider returns no substantive verdict or reports unavailable credits
- **THEN** the review remains open and dependent implementation or final acceptance does not proceed

#### Scenario: Accepted delivery

- **WHEN** proofs, execution, mutations, full regressions and native implementation audits pass with findings resolved
- **THEN** roadmap/wiki and task states reflect actual evidence, the branch is pushed and verified, and only this completed OpenSpec change is archived

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md ---

--- BEGIN EVIDENCE review/semantic-kernel/sprint7/integration/01.log ---
interleaving.schedule.balanced: true
interleaving.schedule.block-left: true
interleaving.schedule.block-right: true
interleaving.schedule.empty: true
interleaving.schedule.empty-left: true
interleaving.schedule.empty-right: true
interleaving.schedule.missing-right: true
interleaving.schedule.missing-left: true
interleaving.schedule.excess-left: true
interleaving.schedule.excess-right: true
interleaving.schedule.empty-extra-left: true
interleaving.schedule.empty-extra-right: true
interleaving.schedule.both-wrong-counts: true
interleaving.schedule.disjoint-admitted: true
interleaving.schedule.overlap-admitted: true
interleaving.schedule.overlap-left-funded: true
interleaving.schedule.overlap-right-funded: true
interleaving.schedule.unreachable-left-suffix: true
interleaving.schedule.unreachable-right-suffix: true
interleaving.schedule.precedence-configuration: true
interleaving.schedule.precedence-left: true
interleaving.schedule.precedence-right: true
interleaving.schedule.precedence-counts: true
interleaving.schedule.empty-admitted: true
interleaving.fixture.snapshot.both.own: true
interleaving.fixture.shared.lr: true
interleaving.fixture.shared.rl: true
interleaving.fixture.shared.order: true
interleaving.fixture.shared.attempts: true
interleaving.fixture.replenish.funded: true
interleaving.fixture.replenish.halted: true
interleaving.fixture.replenish.attempts: true
interleaving.fixture.live.complete: true
interleaving.fixture.snapshot.own: true
interleaving.fixture.snapshot.distinct: true
interleaving.fixture.history.peer.only: true
interleaving.fixture.history.funded.literal: true
interleaving.fixture.history.own: true
interleaving.fixture.refusal.immediate: true
interleaving.fixture.refusal.middle: true
interleaving.fixture.refusal.dual: true
interleaving.fixture.refusal.skips: true
interleaving.fixture.empty.both: true
interleaving.fixture.empty.left: true
interleaving.fixture.empty.right: true
interleaving.fixture.supply.complete: true
interleaving.fixture.supply.aggregate: true
interleaving.fixture.collateral.protected: true
interleaving.fixture.boundary.local: true
interleaving.fixture.capability.revoked: true
interleaving.fixture.capability.live: true
interleaving.fixture.capability.unauthorized: true
interleaving.fixture.capability.debit: true
interleaving.fixture.history.unit: true
interleaving.fixture.malformed.suffix: true
interleaving.fixture.malformed.schedule: true
interleaving.fixture.disjoint.llrr.complete: true
interleaving.fixture.disjoint.llrr.parallel: true
interleaving.fixture.disjoint.llrr.refused.complete: true
interleaving.fixture.disjoint.llrr.refused.parallel: true
interleaving.fixture.disjoint.lrlr.complete: true
interleaving.fixture.disjoint.lrlr.parallel: true
interleaving.fixture.disjoint.lrlr.refused.complete: true
interleaving.fixture.disjoint.lrlr.refused.parallel: true
interleaving.fixture.disjoint.lrrl.complete: true
interleaving.fixture.disjoint.lrrl.parallel: true
interleaving.fixture.disjoint.lrrl.refused.complete: true
interleaving.fixture.disjoint.lrrl.refused.parallel: true
interleaving.fixture.disjoint.rllr.complete: true
interleaving.fixture.disjoint.rllr.parallel: true
interleaving.fixture.disjoint.rllr.refused.complete: true
interleaving.fixture.disjoint.rllr.refused.parallel: true
interleaving.fixture.disjoint.rlrl.complete: true
interleaving.fixture.disjoint.rlrl.parallel: true
interleaving.fixture.disjoint.rlrl.refused.complete: true
interleaving.fixture.disjoint.rlrl.refused.parallel: true
interleaving.fixture.disjoint.rrll.complete: true
interleaving.fixture.disjoint.rrll.parallel: true
interleaving.fixture.disjoint.rrll.refused.complete: true
interleaving.fixture.disjoint.rrll.refused.parallel: true
interleaving.observe.equal: true
interleaving.observe.failure: true
interleaving.observe.failure.reason: true
interleaving.observe.failure.index: true
interleaving.observe.failure.step: true
interleaving.observe.failure.equal: true
interleaving.observe.successful.index: true
interleaving.observe.history: true
interleaving.observe.events: true
interleaving.observe.peer: true
interleaving.observe.event.index: true
interleaving.observe.event.step: true
interleaving.observe.event.outputs: true
interleaving.observe.output.unit: true
interleaving.observe.output.value: true
interleaving.observe.output.producer: true
interleaving.observe.output.component: true
interleaving.observe.output.port: true
interleaving.observe.ledger: true
interleaving.observe.store: true
interleaving.observe.omitted.context: true
interleaving.observe.receipt.kind: true
interleaving.observe.receipt.request: true
interleaving.observe.receipt.guard: true
interleaving.observe.receipt.deltas: true
interleaving.observe.receipt.supplies: true
interleaving.observe.receipt.required.state: true
interleaving.observe.receipt.required.env: true
interleaving.observe.receipt.declared.state: true
interleaving.observe.receipt.declared.env: true
interleaving.observe.receipt.writes: true
interleaving.observe.request.operation: true
interleaving.observe.request.parties: true
interleaving.observe.request.arguments: true
interleaving.observe.request.capabilities: true
interleaving.observe.request.actor: true

--- END EVIDENCE ---

--- BEGIN EVIDENCE review/semantic-kernel/sprint7/integration/02.log ---
AXIOM AUDIT scope: imported module prefix DefiKernel.Interleaving; modules=[DefiKernel.Interleaving.Schedule,
 DefiKernel.Interleaving.ScheduleTests,
 DefiKernel.Interleaving.Execution,
 DefiKernel.Interleaving.Examples,
 DefiKernel.Interleaving.Tests,
 DefiKernel.Interleaving.Audit,
 DefiKernel.Interleaving.Soundness,
 DefiKernel.Interleaving.LocalOrder,
 DefiKernel.Interleaving.Trace,
 DefiKernel.Interleaving.Preservation,
 DefiKernel.Interleaving.Interference,
 DefiKernel.Interleaving.InterferenceFixtures,
 DefiKernel.Interleaving.Recovery.Reference,
 DefiKernel.Interleaving.Recovery.Step,
 DefiKernel.Interleaving.Recovery.Simulation,
 DefiKernel.Interleaving.Recovery]
AXIOM AUDIT theorem: DefiKernel.Interleaving.accept_world; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit_left_member; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit_of_checks; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit_of_parallel; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit_ok; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit_right_member; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.advance_consumed; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.advance_refusal_stable; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.advance_sound; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.analyzed_selected; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.checkSchedule_error_iff; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.checkSchedule_ok_iff; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.complete_blockLR; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.complete_blockRL; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.complete_empty_iff; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.complete_left_cons_iff; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.complete_right_cons_iff; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.continueRun_append; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.continueRun_consumed; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.continueRun_reachable; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.continueRun_refusal_stable; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_append; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_left_cons; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_right_cons; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_sum_length; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.every_prefix_two_invariants; module=DefiKernel.Interleaving.Interference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.local_setLocal; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel_iff; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel_transport; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.observe_toCursor; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.refuse_world; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_blockLR; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_blockRL; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_empty; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_empty_left; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_empty_right; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_matchesParallel; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_matchesSerialLR; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_matchesSerialRL; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving_recovers; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_accounting; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_complete_counts; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_consumed; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_frame; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_nonnegative; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_parallel; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_reachable; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_store; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix_two_invariants; module=DefiKernel.Interleaving.Interference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.setLocal_world; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.skip_attempts; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.skip_world; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.congr_simp; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Composition.ReceiptAuthorized.eq_2; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.accounting; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.active_index; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.attempts; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.before_stores; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.congr_simp; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.consumed; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.locality; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.refusal_stable; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.store; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AttemptChain.brecOn; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AttemptSound.congr_simp; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.eq_1; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.left_slot; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.length; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.prefix_counts; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.right_slot; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.collateral_supported; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.empty_support_is_false; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.fragile_initialized; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.fragile_local_obligation; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.fragile_not_stable; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_frame_support_counterexample; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_initialization_counterexample; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_peer_stability_counterexample; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.protected_collateral_all_tokens; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_all_tokens; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_cross; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_every_prefix; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_initialized; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_left_analyzed; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_local_obligation; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_overlap; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_right_analyzed; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_stable; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_step_total; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_supply_free; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.sound_target_frame; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.ProjectedEquivalent.eq_1; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.accounting; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.active_index; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.analyzed_locality; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.analyzed_predicate_frame; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.attempt_chain; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.attempt_index; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.attempts; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.authority; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.before_stores; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.branch_projection; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.brecOn; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.congr_simp; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.failure_index; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.frame; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.initial_store_authority; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.local_event_index; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.local_history; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.local_order; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.locality; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.predicate_frame; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.store; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Reachable.two_invariants; module=DefiKernel.Interleaving.Interference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.admitted_analysis; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_branch_frame; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_exhausted_cursor; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_own_agrees; module=DefiKernel.Interleaving.Recovery.Simulation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_own_cursor; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_peer_local; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.advance_simulates; module=DefiKernel.Interleaving.Recovery.Simulation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.compatible_peer_reads; module=DefiKernel.Interleaving.Recovery.Step; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.continue_active_index; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.continue_outside; module=DefiKernel.Interleaving.Recovery.Simulation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.continue_simulates; module=DefiKernel.Interleaving.Recovery.Simulation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.cursor_advance_congr; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated_active_index; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated_exhausted; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated_full; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated_step; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated_zero; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.runPrefix_simulates; module=DefiKernel.Interleaving.Recovery.Simulation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.selected_footprint; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.admit.eq_1; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.advance.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.checkSchedule.eq_1; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.continueRun.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_sum_length._proof_1_1; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.count_sum_length._proof_1_2; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel.congr_simp; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel.eq_1; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel.eq_2; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel_iff._simp_1_6; module=DefiKernel.Interleaving.Execution; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runInterleaving.eq_1; module=DefiKernel.Interleaving.Recovery; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.runPrefix.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.selectBranch.eq_1; module=DefiKernel.Interleaving.LocalOrder; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.selectBranch.eq_2; module=DefiKernel.Interleaving.LocalOrder; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.start.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.successfulEvent.eq_1; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Parallel.analyzeBranch.eq_1; module=DefiKernel.Interleaving.Recovery; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Parallel.runBranch.eq_1; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Schedule.0.Except.map.match_1.eq_1; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Schedule.0.Except.map.match_1.eq_2; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.configuration.sizeOf_spec; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.schedule.inj; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.schedule.injEq; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.schedule.sizeOf_spec; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.structural.inj; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.structural.injEq; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdmissionFailure.structural.sizeOf_spec; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.active_index._proof_1_4; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.active_index._proof_1_5; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.active_index._proof_1_6; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.active_index._proof_1_7; module=DefiKernel.Interleaving.LocalOrder; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.attempts._simp_1_3; module=DefiKernel.Interleaving.Soundness; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.attempts._simp_1_4; module=DefiKernel.Interleaving.Soundness; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.before_stores._simp_1_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.before_stores._simp_1_2; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.locality._simp_1_4; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.AdvanceSound.locality._simp_1_5; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.mk.inj; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.mk.injEq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.mk.sizeOf_spec; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.supply.congr_simp; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.supply.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Attempt.writes.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.left_slot._proof_1_1; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.prefix_counts._proof_1_1; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Complete.right_slot._proof_1_1; module=DefiKernel.Interleaving.Schedule; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.replenishInitial._proof_1; module=DefiKernel.Interleaving.Examples; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.sharedBalance.eq_1; module=DefiKernel.Interleaving.Examples; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.sharedInitial._proof_1; module=DefiKernel.Interleaving.Examples; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.sharedLeft.eq_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.fragile_initialized._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.fragile_local_obligation._proof_1_2; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_frame_support_counterexample._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_frame_support_counterexample._proof_1_2; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.missing_peer_stability_counterexample._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.protected_collateral_all_tokens._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_initialized._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_left_analyzed._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.InterferenceFixtures.shared_right_analyzed._proof_1_1; module=DefiKernel.Interleaving.InterferenceFixtures; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.LocalState.mk.inj; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.LocalState.mk.injEq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.LocalState.mk.sizeOf_spec; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.LocalState.toCursor.eq_1; module=DefiKernel.Interleaving.Recovery.Step; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.accept.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.local.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.local.eq_2; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.mk.inj; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.mk.injEq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.mk.sizeOf_spec; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.refuse.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.setLocal.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.setLocal.eq_2; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.skip.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.supply.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Machine.writes.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.footprint.eq_1; module=DefiKernel.Interleaving.Recovery; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.footprint.eq_2; module=DefiKernel.Interleaving.Recovery; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Recovery.isolated.eq_1; module=DefiKernel.Interleaving.Recovery.Reference; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.executed.inj; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.executed.injEq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.executed.sizeOf_spec; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.refused.inj; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.refused.injEq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Result.refused.sizeOf_spec; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.ScheduleMismatch.mk.inj; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.ScheduleMismatch.mk.injEq; module=DefiKernel.Interleaving.Schedule; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.ScheduleMismatch.mk.sizeOf_spec; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_1; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_10; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_11; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_12; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_2; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_3; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_4; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_5; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_6; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_7; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_8; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq._proof_9; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq._proof_1; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq._proof_2; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq._proof_3; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq._proof_4; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq._proof_5; module=DefiKernel.Interleaving.Schedule; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.matchesParallel._sparseCasesOn_1.else_eq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.observationsEqual._sparseCasesOn_2.else_eq; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Execution.0.DefiKernel.Interleaving.matchesParallel.match_1.eq_1; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Execution.0.DefiKernel.Interleaving.matchesParallel.match_1.eq_2; module=DefiKernel.Interleaving.Execution; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.successfulEvent.match_1.eq_1; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.successfulEvent.match_1.eq_2; module=DefiKernel.Interleaving.Trace; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.ExpectedAttempt.mk.inj; module=DefiKernel.Interleaving.Examples; axioms=[]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.ExpectedAttempt.mk.injEq; module=DefiKernel.Interleaving.Examples; axioms=[propext]
AXIOM AUDIT theorem: DefiKernel.Interleaving.Examples.ExpectedAttempt.mk.sizeOf_spec; module=DefiKernel.Interleaving.Examples; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.LocalOrder.0.DefiKernel.Interleaving.Machine.local.match_1.eq_1; module=DefiKernel.Interleaving.LocalOrder; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.LocalOrder.0.DefiKernel.Interleaving.Machine.local.match_1.eq_2; module=DefiKernel.Interleaving.LocalOrder; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.eq_2; module=DefiKernel.Interleaving.Preservation; axioms=[propext]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Interleaving.Attempt.supply.match_1.eq_1; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Interleaving.Attempt.supply.match_1.eq_2; module=DefiKernel.Interleaving.Preservation; axioms=[propext,
 Quot.sound]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Recovery.0.DefiKernel.Interleaving.Recovery.footprint.match_1.eq_1; module=DefiKernel.Interleaving.Recovery; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Recovery.0.DefiKernel.Interleaving.Recovery.footprint.match_1.eq_2; module=DefiKernel.Interleaving.Recovery; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Soundness.0.DefiKernel.Interleaving.Machine.local.match_1.eq_1; module=DefiKernel.Interleaving.Soundness; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Soundness.0.DefiKernel.Interleaving.Machine.local.match_1.eq_2; module=DefiKernel.Interleaving.Soundness; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.Machine.local.match_1.eq_1; module=DefiKernel.Interleaving.Trace; axioms=[]
AXIOM AUDIT theorem: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.Machine.local.match_1.eq_2; module=DefiKernel.Interleaving.Trace; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AttemptSound; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Complete; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.CrossInclusion; module=DefiKernel.Interleaving.Interference; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LedgerPredicate; module=DefiKernel.Interleaving.Interference; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LedgerRelation; module=DefiKernel.Interleaving.Interference; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalObligation; module=DefiKernel.Interleaving.Interference; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ProjectedEquivalent; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Schedule; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Stable; module=DefiKernel.Interleaving.Interference; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.admit; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Interleaving.advance; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.checkSchedule; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.continueRun; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqAdmissionFailure; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqScheduleMismatch; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instReprAdmissionFailure; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instReprScheduleMismatch; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.matchesParallel; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.observationsEqual; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.runInterleaving; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.runPrefix; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.selectBranch; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.start; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.successfulEvent; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure._sizeOf_1; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure._sizeOf_inst; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.casesOn; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.ctorElim; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.ctorElimType; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.ctorIdx; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.noConfusion; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.noConfusionType; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.recOn; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdvanceSound.casesOn; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdvanceSound.recOn; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt._sizeOf_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt._sizeOf_inst; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.before; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.branch; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.casesOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.ctorIdx; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.index; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.invocation; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.noConfusionType; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.outcome; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.recOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.supply; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.writes; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AttemptChain.casesOn; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AttemptChain.recOn; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Audit.checks; module=DefiKernel.Interleaving.Audit; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Audit.main; module=DefiKernel.Interleaving.Audit; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.M; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.R; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.admissionRefused; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptMatches; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptsMatch; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.continuedRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.depositExpected; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.disjointLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.disjointLeftExpected; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.disjointRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.dualRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.immediateRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.liveCfg; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.liveLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.liveRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.liveRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.matchesExpected; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.middleLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.middleRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.peerOnly; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.peerOnlyLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.peerOnlyRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.peerOnlyRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.replenishCfg; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.replenishInitial; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.replenishLR; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.replenishRL; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.replenishRLAttempts; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.schedules; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedBalance; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedCfg; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedInitial; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedLR; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedLRAttempts; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedRL; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.sharedRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.snapshotCfg; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.snapshotConsumer; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.snapshotLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.snapshotRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.snapshotRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.supplyLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.supplyRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.supplyRun; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.withdrawalLeft; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.withdrawalRight; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.Ledger; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.collateral; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.dollars; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.fragile; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.leftFP; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.leftPrefix; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.rightFP; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.rightPrefix; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.sameDollars; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState._sizeOf_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState._sizeOf_inst; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.casesOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.consumed; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.ctorIdx; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.events; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.failure; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.nextIndex; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.noConfusionType; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.observe; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.outputs; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.recOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.toCursor; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine._sizeOf_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine._sizeOf_inst; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.accept; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.attempts; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.casesOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.ctorIdx; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.left; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.local; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.noConfusionType; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.recOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.refuse; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.right; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.setLocal; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.skip; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.supply; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.world; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.writes; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Reachable.casesOn; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Reachable.recOn; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Recovery.Simulates; module=DefiKernel.Interleaving.Recovery.Simulation; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Recovery.footprint; module=DefiKernel.Interleaving.Recovery.Step; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Recovery.isolated; module=DefiKernel.Interleaving.Recovery.Reference; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result._sizeOf_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result._sizeOf_inst; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.casesOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.ctorElim; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.ctorElimType; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.ctorIdx; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.noConfusionType; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.recOn; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch._sizeOf_1; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch._sizeOf_inst; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.casesOn; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.ctorIdx; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.expectedLeft; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.expectedRight; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.noConfusion; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.noConfusionType; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.observedLeft; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.observedRight; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.recOn; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.accepted; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.checks; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.invalidCfg; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.refused; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.unknown; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.changeOutput; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.changedEvent; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.changedLeft; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.checks; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.compareFailures; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.comparison; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.different; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.observationChecks; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.observationEvent; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.observationMachine; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.requestChanges; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.requestChecks; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.withFailure; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.advance.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.advance.match_3; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instReprAdmissionFailure.repr; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instReprScheduleMismatch.repr; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.matchesParallel._sparseCasesOn_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.matchesParallel.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.observationsEqual._sparseCasesOn_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.observationsEqual._sparseCasesOn_2; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.observationsEqual.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.runInterleaving.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.successfulEvent.match_1; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Schedule.0.Except.map.match_1.splitter; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Tests.0.DefiKernel.Interleaving.Tests.expected; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.configuration.elim; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.schedule.elim; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.schedule.noConfusion; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.structural.elim; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AdmissionFailure.structural.noConfusion; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.mk._flat_ctor; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.mk.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Attempt.supply.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.AttemptChain.below.casesOn; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Audit.main.match_1; module=DefiKernel.Interleaving.Audit; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt._sizeOf_1; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt._sizeOf_inst; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.after; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.before; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.branch; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.casesOn; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.ctorIdx; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.index; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.invocation; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.noConfusion; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.noConfusionType; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.outcome; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.recOn; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptMatches._sparseCasesOn_1; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptMatches._sparseCasesOn_2; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptMatches.match_1; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.attemptsMatch.match_1; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.matchesExpected.match_1; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.InterferenceFixtures.fragile.match_1; module=DefiKernel.Interleaving.InterferenceFixtures; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.consumed._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.events._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.failure._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.mk._flat_ctor; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.mk.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.nextIndex._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.LocalState.outputs._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.attempts._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.left._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.local.match_1; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.mk._flat_ctor; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.mk.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Machine.right._default; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Reachable.below.casesOn; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[propext,
 Classical.choice,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Recovery.footprint.match_1; module=DefiKernel.Interleaving.Recovery.Step; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.executed.elim; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.executed.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.refused.elim; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Result.refused.noConfusion; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.mk._flat_ctor; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleMismatch.mk.noConfusion; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.accepted.match_1; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.ScheduleTests.refused.match_1; module=DefiKernel.Interleaving.ScheduleTests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.checks._sparseCasesOn_3; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.checks.match_1; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.checks.match_3; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.checks.match_6; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.observationChecks.match_1; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Tests.requestChecks.match_1; module=DefiKernel.Interleaving.Tests; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqAdmissionFailure.decEq.match_1; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instDecidableEqScheduleMismatch.decEq.match_1; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.instReprAdmissionFailure.repr.match_1; module=DefiKernel.Interleaving.Schedule; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Execution.0.DefiKernel.Interleaving.matchesParallel.match_1.splitter; module=DefiKernel.Interleaving.Execution; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.successfulEvent.match_1.splitter; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.mk._flat_ctor; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: DefiKernel.Interleaving.Examples.ExpectedAttempt.mk.noConfusion; module=DefiKernel.Interleaving.Examples; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.LocalOrder.0.DefiKernel.Interleaving.Machine.local.match_1.splitter; module=DefiKernel.Interleaving.LocalOrder; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.splitter; module=DefiKernel.Interleaving.Preservation; kind=definition; axioms=[propext]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Interleaving.Attempt.supply.match_1.splitter; module=DefiKernel.Interleaving.Preservation; kind=definition; axioms=[propext,
 Quot.sound]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Recovery.0.DefiKernel.Interleaving.Recovery.footprint.match_1.splitter; module=DefiKernel.Interleaving.Recovery; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Soundness.0.DefiKernel.Interleaving.Machine.local.match_1.splitter; module=DefiKernel.Interleaving.Soundness; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Trace.0.DefiKernel.Interleaving.Machine.local.match_1.splitter; module=DefiKernel.Interleaving.Trace; kind=definition; axioms=[]
AXIOM AUDIT declaration: _private.DefiKernel.Interleaving.Preservation.0.DefiKernel.Composition.Receipt.supply.match_1.splitter._sparseCasesOn_2; module=DefiKernel.Interleaving.Preservation; kind=definition; axioms=[propext]
AXIOM AUDIT DECLARATIONS PASSED: 271/271 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 259/259 theorems; forbidden=0

--- END EVIDENCE ---
