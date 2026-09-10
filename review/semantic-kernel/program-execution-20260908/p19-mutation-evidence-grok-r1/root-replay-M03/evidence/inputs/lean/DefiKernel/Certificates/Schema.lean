import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import DefiKernel.Typed.Types
import DefiKernel.Typed.Expr
import DefiKernel.Typed.Authority
import DefiKernel.Typed.Transition
import DefiKernel.Composition.Interfaces
import DefiKernel.Composition.Execution
import DefiKernel.Composition.Sequence

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

-- BEGIN PROOFS

end DefiKernel.Certificates
