import Mathlib.Data.Nat.Basic
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Rat.Floor
import Mathlib.Tactic.Positivity
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring


/-! Checked unsigned values. Width zero contains only zero. -/
namespace DefiKernel.Arithmetic

structure Word (w : Nat) where
  value : Nat
  bound : value < 2^w
  deriving DecidableEq, Repr

inductive Failure
  | inputOverflow | addOverflow | subUnderflow | mulOverflow
  | divisionByZero | quotientOverflow | invalidRate
  | nonPositiveScale | negativeQuantity | nonIntegralQuantity
  deriving DecidableEq, Repr

inductive Rounding | down | up
  deriving DecidableEq, Repr

variable {w : Nat}

def Word.checked (error : Failure) (n : Nat) : Except Failure (Word w) :=
  if h : n < 2^w then .ok ⟨n, h⟩ else .error error

def ofNat (w n : Nat) : Except Failure (Word w) :=
  Word.checked .inputOverflow n


end DefiKernel.Arithmetic


/-! Checked addition, subtraction and multiplication without modular wraparound. -/
namespace DefiKernel.Arithmetic.Operations

variable {w : Nat}

def add (a b : Word w) : Except Failure (Word w) :=
  Word.checked .addOverflow ((a.value + b.value) % (2^w))

def sub (a b : Word w) : Except Failure (Word w) :=
  if b.value ≤ a.value then Word.checked .subUnderflow (a.value - b.value)
  else .error .subUnderflow

def mul (a b : Word w) : Except Failure (Word w) :=
  Word.checked .mulOverflow (a.value * b.value)


end DefiKernel.Arithmetic.Operations


/-! Directed natural division and checked full-product multiplication/division.
The independent specifications expose floor inequalities and ceiling leastness. -/
namespace DefiKernel.Arithmetic.Rounding

variable {w : Nat}

def divideNat (mode : Arithmetic.Rounding) (numerator denominator : Nat) : Except Failure Nat :=
  if denominator = 0 then .error .divisionByZero
  else .ok (match mode with
    | .down => numerator / denominator
    | .up => numerator / denominator + (if numerator % denominator = 0 then 0 else 1))

def mulDiv (mode : Arithmetic.Rounding) (a b : Word w) (denominator : Nat) :
    Except Failure (Word w) := do
  let q ← divideNat mode (a.value * b.value) denominator
  Word.checked .quotientOverflow q


end DefiKernel.Arithmetic.Rounding


/-! Gross-based and on-top fee quotes. Natural rate parameters are never word-truncated. -/
namespace DefiKernel.Arithmetic.Fees

structure FeeQuote (w : Nat) where
  principal : Word w
  fee : Word w
  charged : Word w
  received : Word w
  deriving DecidableEq, Repr

variable {w : Nat}

def validatedRate (num den : Nat) : Except Failure Nat :=
  if den = 0 ∨ num > den then .error .invalidRate else .ok num

def feeFromGross (mode : Rounding) (gross : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (gross.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let received ← Word.checked .subUnderflow (gross.value - fee.value)
  return ⟨gross, fee, gross, received⟩

def feeOnTop (mode : Rounding) (principal : Word w) (num den : Nat) :
    Except Failure (FeeQuote w) := do
  let rate ← validatedRate num den
  let rounded ← Rounding.divideNat mode (principal.value * rate) den
  let fee ← Word.checked .quotientOverflow rounded
  let charged ← Word.checked .addOverflow (principal.value + fee.value)
  return ⟨principal, fee, charged, principal⟩


end DefiKernel.Arithmetic.Fees


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


/-! Explicit positive-scale conversion. Inverse conversion never truncates a fraction. -/
namespace DefiKernel.Arithmetic.Quantity

variable {A : Type} {w : Nat}

def toQuantity (asset : A) (scale : ℚ) (hscale : 0 < scale) (q : Word w) :
    DefiKernel.Typed.Quantity asset where
  amount := (q.value : ℚ) * scale
  nonneg := by positivity

def fromRat (w : Nat) (scale amount : ℚ) : Except Failure (Word w) :=
  if scale ≤ 0 then .error .nonPositiveScale
  else if amount < 0 then .error .negativeQuantity
  else if (⌊amount / scale⌋₊ : ℚ) ≠ amount / scale then .error .nonIntegralQuantity
  else Word.checked .inputOverflow ⌊amount / scale⌋₊


end DefiKernel.Arithmetic.Quantity


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


/-! Registered constant fee-quote transfers. This adapter uses the existing typed executor's
aggregate net effects, including coincident parties; it does not model sequential debit order. -/
namespace DefiKernel.Arithmetic.Reference
open Typed

variable {P A D : Type} {w : Nat}

def payerDelta (quote : Fees.FeeQuote w) (scale : ℚ) (payer : Cell P A D) :
    CellDelta P A D [] :=
  ⟨payer.2.2, ⟨payer.1, .literal payer.2.1⟩, .lit (-(quote.charged.value : ℚ) * scale)⟩

def recipientDelta (quote : Fees.FeeQuote w) (scale : ℚ) (recipient : Cell P A D) :
    CellDelta P A D [] :=
  ⟨recipient.2.2, ⟨recipient.1, .literal recipient.2.1⟩,
    .lit ((quote.received.value : ℚ) * scale)⟩

def collectorDelta (quote : Fees.FeeQuote w) (scale : ℚ) (collector : Cell P A D) :
    CellDelta P A D [] :=
  ⟨collector.2.2, ⟨collector.1, .literal collector.2.1⟩, .lit ((quote.fee.value : ℚ) * scale)⟩

def template (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) : Template P A D :=
  let payer := (domain, payer, asset)
  let recipient := (domain, recipient, asset)
  let collector := (domain, collector, asset)
  { signature := [], domain := domain, partyArity := 0, guard := .lit true
    deltas := [payerDelta quote scale payer, recipientDelta quote scale recipient,
    collectorDelta quote scale collector]
    supplyDeltas := [], stateReads := [], envReads := []
    writes := [⟨asset, ⟨domain, .literal payer.2.1⟩⟩,
      ⟨asset, ⟨domain, .literal recipient.2.1⟩⟩, ⟨asset, ⟨domain, .literal collector.2.1⟩⟩] }

def registry (operation : OperationId) (quote : Fees.FeeQuote w) (scale : ℚ)
    (domain : D) (asset : A) (payer recipient collector : P) : Registry P A D :=
  fun selected ↦ if selected = operation then
    some (template quote scale domain asset payer recipient collector) else none

def request (operation : OperationId) (capabilityIds : List CapabilityId) : Request P A D :=
  ⟨operation, [], [], capabilityIds, none⟩

/-- Explicit evaluated data used in the correspondence statement, not a caller input to execute. -/
def evaluated (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) : Evaluated P A D :=
  ⟨true, [((domain, payer, asset), -(quote.charged.value : ℚ) * scale),
    ((domain, recipient, asset), (quote.received.value : ℚ) * scale),
    ((domain, collector, asset), (quote.fee.value : ℚ) * scale)], [], [], [], [], [],
    [(domain, payer, asset), (domain, recipient, asset), (domain, collector, asset)]⟩

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- The three scalar contributions are added even when their target cells coincide. -/
def netEffect (quote : Fees.FeeQuote w) (scale : ℚ) (domain : D) (asset : A)
    (payer recipient collector : P) (cell : Cell P A D) : ℚ :=
  (if (domain, payer, asset) = cell then -(quote.charged.value : ℚ) * scale else 0) +
    (if (domain, recipient, asset) = cell then (quote.received.value : ℚ) * scale else 0) +
    (if (domain, collector, asset) = cell then (quote.fee.value : ℚ) * scale else 0)

variable [Fintype P] [Fintype A] [Fintype D]

/-- Refusal has no post-world: retain the supplied input separately from the actual result. -/
def observeExecution (operations : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (req : Request P A D) (state : State P A D) :
    (State P A D × CapabilityStore P A D) × Except Refusal (ExecutionResult P A D) :=
  ((state, store), Typed.execute operations store ctx env now req state)


end DefiKernel.Arithmetic.Reference


/-! Frozen F01–F45 literal fixtures. Expected values are separate literal tables.
All reference ledgers cover sixteen cells, including protected cells with balance nine.
F40/F41 use aggregate net effects with payer coincidence, not gross debit-order semantics. -/
namespace DefiKernel.Arithmetic.Examples
open Typed

inductive Party | alice | bob | treasury | observer
  deriving DecidableEq, Repr
inductive Asset | usd | alt
  deriving DecidableEq, Repr
inductive Domain | «local» | remote
  deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice, .bob, .treasury, .observer}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .alt}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.local, .remote}, by intro d; cases d <;> simp⟩

abbrev C := Cell Party Asset Domain
abbrev WordResult := Except Arithmetic.Failure Nat
abbrev QuoteResult := Except Arithmetic.Failure (Nat × Nat × Nat × Nat)
abbrev ReferenceObservation := (State Party Asset Domain × CapabilityStore Party Asset Domain) ×
  Except Refusal (ExecutionResult Party Asset Domain)

inductive PureObservation
  | word (result : WordResult)
  | quote (result : QuoteResult)
  | quantity (amount : ℚ) (result : WordResult)

def allCells : List C :=
  [(.local, .alice, .usd),
    (.local, .alice, .alt),
    (.local, .bob, .usd),
    (.local, .bob, .alt),
    (.local, .treasury, .usd),
    (.local, .treasury, .alt),
    (.local, .observer, .usd),
    (.local, .observer, .alt),
    (.remote, .alice, .usd),
    (.remote, .alice, .alt),
    (.remote, .bob, .usd),
    (.remote, .bob, .alt),
    (.remote, .treasury, .usd),
    (.remote, .treasury, .alt),
    (.remote, .observer, .usd),
    (.remote, .observer, .alt)]

def literalInputs : List String :=
  ["arithmetic.fixture.f01",
    "arithmetic.fixture.f02",
    "arithmetic.fixture.f03",
    "arithmetic.fixture.f04",
    "arithmetic.fixture.f05",
    "arithmetic.fixture.f06",
    "arithmetic.fixture.f07",
    "arithmetic.fixture.f08",
    "arithmetic.fixture.f09",
    "arithmetic.fixture.f10",
    "arithmetic.fixture.f11",
    "arithmetic.fixture.f12",
    "arithmetic.fixture.f13",
    "arithmetic.fixture.f14",
    "arithmetic.fixture.f15",
    "arithmetic.fixture.f16",
    "arithmetic.fixture.f17",
    "arithmetic.fixture.f18",
    "arithmetic.fixture.f19",
    "arithmetic.fixture.f20",
    "arithmetic.fixture.f21",
    "arithmetic.fixture.f22",
    "arithmetic.fixture.f23",
    "arithmetic.fixture.f24",
    "arithmetic.fixture.f25",
    "arithmetic.fixture.f26",
    "arithmetic.fixture.f27",
    "arithmetic.fixture.f28",
    "arithmetic.fixture.f29",
    "arithmetic.fixture.f30",
    "arithmetic.fixture.f31",
    "arithmetic.fixture.f32",
    "arithmetic.fixture.f33",
    "arithmetic.fixture.f34",
    "arithmetic.fixture.f35",
    "arithmetic.fixture.f36",
    "arithmetic.fixture.f37",
    "arithmetic.fixture.f38",
    "arithmetic.fixture.f39",
    "arithmetic.fixture.f40",
    "arithmetic.fixture.f41",
    "arithmetic.fixture.f42",
    "arithmetic.fixture.f43",
    "arithmetic.fixture.f44",
    "arithmetic.fixture.f45"]

def entryStore : CapabilityStore Party Asset Domain :=
  ⟨[⟨⟨.alice, .local, ⟨7⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .local, ⟨7⟩, .debit (.local, .alice, .usd)⟩, true⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, false⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, true⟩]⟩

def expectedStore : CapabilityStore Party Asset Domain :=
  ⟨[⟨⟨.alice, .local, ⟨7⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .local, ⟨7⟩, .debit (.local, .alice, .usd)⟩, true⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, false⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, true⟩]⟩

def referenceContext : InvocationContext Party Domain := ⟨.alice, .local⟩

def referenceEnvironment : Environment Asset Domain := fun _ ↦ none

def pureCases : List (String × PureObservation) :=
  [("arithmetic.fixture.f01",
      .word ((ofNat 8 255).map Word.value)),
    ("arithmetic.fixture.f02",
      .word ((ofNat 8 256).map Word.value)),
    ("arithmetic.fixture.f03",
      .word ((Operations.add
        (⟨254, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f04",
      .word ((Operations.add
        (⟨255, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f05",
      .word ((Operations.sub
        (⟨0, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f06",
      .word ((Operations.mul
        (⟨16, by decide⟩ : Word 8) (⟨16, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f07",
      .word ((Rounding.mulDiv .down
        (⟨200, by decide⟩ : Word 8) (⟨2, by decide⟩ : Word 8) 2).map Word.value)),
    ("arithmetic.fixture.f08",
      .word ((Rounding.mulDiv .down
        (⟨255, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 0).map Word.value)),
    ("arithmetic.fixture.f09",
      .word ((Rounding.mulDiv .down
        (⟨7, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f10",
      .word ((Rounding.mulDiv .up
        (⟨7, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f11",
      .word ((Rounding.mulDiv .up
        (⟨6, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f12",
      .word ((Rounding.mulDiv .down
        (⟨254, by decide⟩ : Word 8) (⟨254, by decide⟩ : Word 8) 253).map Word.value)),
    ("arithmetic.fixture.f13",
      .word ((Rounding.mulDiv .up
        (⟨254, by decide⟩ : Word 8) (⟨254, by decide⟩ : Word 8) 253).map Word.value)),
    ("arithmetic.fixture.f14",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f15",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f16",
      .quote ((Fees.feeOnTop .up (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f17",
      .quote ((Fees.feeOnTop .up (⟨255, by decide⟩ : Word 8) 1 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f18",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 0 0).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f19",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 2 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f20",
      .quote ((Fees.feeFromGross .up (⟨0, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f21",
      let q := Quantity.toQuantity Asset.usd (1/4) (by norm_num) (⟨7, by decide⟩ : Word 8)
      .quantity q.amount ((Quantity.fromRat 8 (1/4) q.amount).map Word.value)),
    ("arithmetic.fixture.f22",
      .word ((Quantity.fromRat 8 (1/4) (7/8)).map Word.value)),
    ("arithmetic.fixture.f23",
      .word ((Quantity.fromRat 8 (0) (-1)).map Word.value)),
    ("arithmetic.fixture.f24",
      .word ((Quantity.fromRat 8 (1) (-1)).map Word.value)),
    ("arithmetic.fixture.f29",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 300 600).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f30",
      .word ((ofNat 0 0).map Word.value)),
    ("arithmetic.fixture.f31",
      .word ((ofNat 0 1).map Word.value)),
    ("arithmetic.fixture.f32",
      .word ((Operations.mul
        (⟨15, by decide⟩ : Word 8) (⟨17, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f33",
      .word ((Operations.sub
        (⟨255, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f34",
      .word ((Rounding.mulDiv .up
        (⟨0, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f35",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 0 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f36",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 1 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f37",
      .quote ((Fees.feeFromGross .up (⟨1, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f38",
      .word ((Quantity.fromRat 8 (1/4) (64)).map Word.value)),
    ("arithmetic.fixture.f39",
      .word ((Rounding.mulDiv .down
        (⟨255, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 300).map Word.value)),
    ("arithmetic.fixture.f44",
      .word (Rounding.divideNat .up 65025 1)),
    ("arithmetic.fixture.f45",
      .word (Rounding.divideNat .down 0 0))]

def expectedPureCases : List (String × PureObservation) :=
  [("arithmetic.fixture.f01", .word (.ok 255)),
    ("arithmetic.fixture.f02", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f03", .word (.ok 255)),
    ("arithmetic.fixture.f04", .word (.error .addOverflow)),
    ("arithmetic.fixture.f05", .word (.error .subUnderflow)),
    ("arithmetic.fixture.f06", .word (.error .mulOverflow)),
    ("arithmetic.fixture.f07", .word (.ok 200)),
    ("arithmetic.fixture.f08", .word (.error .divisionByZero)),
    ("arithmetic.fixture.f09", .word (.ok 11)),
    ("arithmetic.fixture.f10", .word (.ok 12)),
    ("arithmetic.fixture.f11", .word (.ok 10)),
    ("arithmetic.fixture.f12", .word (.ok 255)),
    ("arithmetic.fixture.f13", .word (.error .quotientOverflow)),
    ("arithmetic.fixture.f14", .quote (.ok (100, 33, 100, 67))),
    ("arithmetic.fixture.f15", .quote (.ok (100, 34, 100, 66))),
    ("arithmetic.fixture.f16", .quote (.ok (100, 34, 134, 100))),
    ("arithmetic.fixture.f17", .quote (.error .addOverflow)),
    ("arithmetic.fixture.f18", .quote (.error .invalidRate)),
    ("arithmetic.fixture.f19", .quote (.error .invalidRate)),
    ("arithmetic.fixture.f20", .quote (.ok (0, 0, 0, 0))),
    ("arithmetic.fixture.f21", .quantity (7/4) (.ok 7)),
    ("arithmetic.fixture.f22", .word (.error .nonIntegralQuantity)),
    ("arithmetic.fixture.f23", .word (.error .nonPositiveScale)),
    ("arithmetic.fixture.f24", .word (.error .negativeQuantity)),
    ("arithmetic.fixture.f29", .quote (.ok (100, 50, 100, 50))),
    ("arithmetic.fixture.f30", .word (.ok 0)),
    ("arithmetic.fixture.f31", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f32", .word (.ok 255)),
    ("arithmetic.fixture.f33", .word (.ok 254)),
    ("arithmetic.fixture.f34", .word (.ok 0)),
    ("arithmetic.fixture.f35", .quote (.ok (100, 0, 100, 100))),
    ("arithmetic.fixture.f36", .quote (.ok (100, 100, 100, 0))),
    ("arithmetic.fixture.f37", .quote (.ok (1, 1, 1, 0))),
    ("arithmetic.fixture.f38", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f39", .word (.ok 216)),
    ("arithmetic.fixture.f44", .word (.ok 65025)),
    ("arithmetic.fixture.f45", .word (.error .divisionByZero))]

def inputF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (100)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (67)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (100)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (100)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF27 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (99)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF27 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (99)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF28 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF28 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (33)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (33)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (50)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (50)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (25)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (67/4)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33/4)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (66)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (100)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (34)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def referenceCases : List (String × Except Arithmetic.Failure ReferenceObservation) :=
  [("arithmetic.fixture.f25", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .bob .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF25)),
    ("arithmetic.fixture.f26", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .bob .bob)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF26)),
    ("arithmetic.fixture.f27", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .bob .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF27)),
    ("arithmetic.fixture.f28", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .bob .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩]) inputF28)),
    ("arithmetic.fixture.f40", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .alice .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF40)),
    ("arithmetic.fixture.f41", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .alice .alice)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩]) inputF41)),
    ("arithmetic.fixture.f42", (do
      let quote ← Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1/4) .local .usd
          .alice .bob .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF42)),
    ("arithmetic.fixture.f43", (do
      let quote ← Fees.feeOnTop .up (⟨100, by decide⟩ : Word 8) 1 3
      return Reference.observeExecution
        (Reference.registry ⟨7⟩ quote (1) .local .usd
          .alice .bob .treasury)
        entryStore referenceContext referenceEnvironment 23
        (Reference.request ⟨7⟩ [⟨0⟩, ⟨1⟩]) inputF43))]

def expectedReferenceCases : List (String × Except Arithmetic.Failure ReferenceObservation) :=
  [("arithmetic.fixture.f25",
      .ok ((expectedInputF25, expectedStore), .ok ⟨expectedPostF25, expectedStore⟩)),
    ("arithmetic.fixture.f26",
      .ok ((expectedInputF26, expectedStore), .ok ⟨expectedPostF26, expectedStore⟩)),
    ("arithmetic.fixture.f27",
      .ok ((expectedInputF27, expectedStore), .error .insufficientFunds)),
    ("arithmetic.fixture.f28",
      .ok ((expectedInputF28, expectedStore), .error .unauthorizedDebit)),
    ("arithmetic.fixture.f40",
      .ok ((expectedInputF40, expectedStore), .ok ⟨expectedPostF40, expectedStore⟩)),
    ("arithmetic.fixture.f41",
      .ok ((expectedInputF41, expectedStore), .ok ⟨expectedPostF41, expectedStore⟩)),
    ("arithmetic.fixture.f42",
      .ok ((expectedInputF42, expectedStore), .ok ⟨expectedPostF42, expectedStore⟩)),
    ("arithmetic.fixture.f43",
      .ok ((expectedInputF43, expectedStore), .ok ⟨expectedPostF43, expectedStore⟩))]


end DefiKernel.Arithmetic.Examples


/-! Full observations are independent of production query/executor implementation. -/
namespace DefiKernel.Arithmetic.Tests
open Typed Examples

def wordResultEq (actual expected : WordResult) : Bool := decide (actual = expected)

def quoteResultEq (actual expected : QuoteResult) : Bool := decide (actual = expected)

def quantityEq (actualAmount expectedAmount : ℚ) (actualWord expectedWord : WordResult) : Bool :=
  decide (actualAmount = expectedAmount) && wordResultEq actualWord expectedWord

def pureObservationEq (actual expected : PureObservation) : Bool :=
  match actual, expected with
  | .word a, .word e => wordResultEq a e
  | .quote a, .quote e => quoteResultEq a e
  | .quantity a aw, .quantity e ew => quantityEq a e aw ew
  | _, _ => false

def stateEq (actual expected : State Party Asset Domain) : Bool :=
  allCells.all (fun cell ↦ decide (actual.balance cell = expected.balance cell))

def executionResultEq (actual expected : Except Refusal (ExecutionResult Party Asset Domain)) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.state e.state && decide (a.capabilities = e.capabilities)
  | _, _ => false

def referenceObservationEq (actual expected : Except Arithmetic.Failure ReferenceObservation) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.1.1 e.1.1 && decide (a.1.2 = e.1.2) &&
      executionResultEq a.2 e.2
  | _, _ => false

def runtimeChecks : List (String × Bool) :=
  literalInputs.map fun name ↦
    (name, match pureCases.lookup name, expectedPureCases.lookup name with
      | some actual, some expected => pureObservationEq actual expected
      | none, none => match referenceCases.lookup name, expectedReferenceCases.lookup name with
        | some actual, some expected => referenceObservationEq actual expected
        | _, _ => false
      | _, _ => false)


end DefiKernel.Arithmetic.Tests


namespace DefiKernel.Arithmetic.RuntimeAudit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Arithmetic runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Arithmetic runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Arithmetic runtime comparisons failed: {failures.length}")

#eval main


end DefiKernel.Arithmetic.RuntimeAudit
