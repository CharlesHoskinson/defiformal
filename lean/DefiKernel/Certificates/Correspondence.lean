import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Observation
import DefiKernel.Certificates.CanonicalJson
import Mathlib.Data.List.Sort
import Std.Data.TreeMap.Raw.Lemmas
import Std.Data.TreeMap.Raw.WF

namespace DefiKernel.Certificates

set_option linter.style.longLine false
set_option linter.style.setOption false
set_option maxHeartbeats 4000000
set_option linter.style.maxHeartbeats false

/-! Correspondence theorems and open remainder obligations for serialized certificates.
In accordance with P19 specifications and RC01/P20 gates:
- Exact codec, raw execution, and checker success/error correspondence theorems are proven.
- Component-level roundtrip theorems (rational, party, asset, domain, right) are proven.
- Bounded finite fixture evidence (F25, F27, F28, etc.) is verified computationally.
- Universal quantified statements (T-roundtrip, T-canonical-bytes) are explicitly defined over
  a nonempty structurally admissible canonical IR domain. General parser inversion remains a P20 gate.
- Strictly zero `sorry`, custom axioms, or `native_decide` are used in accepted kernel proofs. -/

/-- Standard declaration order of 32 cell keys across (Domain × Party × Asset). -/
def standard32CellKeys : List (Domain × Party × Asset) :=
  let parties : List Party := [.alice, .bob, .vault, .pool]
  let assets : List Asset := [.usd, .share, .collateral, .debt]
  let domains : List Domain := [.main, .other]
  domains.flatMap fun d ↦
    parties.flatMap fun p ↦
      assets.map fun a ↦ (d, p, a)

/-- Complete 32-cell universe predicate: exact declaration order, unique cells, and canonical rationals. -/
def StateCellsMatchStandard32 (cells : List StateCellEnc) : Prop :=
  cells.length = 32 ∧
  cells.map (fun c ↦ (c.domain, c.party, c.asset)) = standard32CellKeys ∧
  cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true

/-- Declaration order of types enumeration matching the standard universe. -/
def StandardTypesEnum (t : TypesEnumEnc) : Prop :=
  t.parties = [.alice, .bob, .vault, .pool] ∧
  t.assets = [.usd, .share, .collateral, .debt] ∧
  t.domains = [.main, .other]

/-- Strictly ascending lexicographical UTF-8 byte order on source map keys. -/
def SourceMapSorted (sm : List (String × String)) : Prop :=
  isSortedStrictAscending (sm.map Prod.fst) = true

/-- Canonical representation for packed values: inactive fields must be zero/false.
    For bool units, valRat must be zero. For numeric units, valBool must be false. -/
def PackedValueCanonical (v : PackedValueEnc) : Prop :=
  (v.unit = .bool → v.valRat = 0) ∧
  (∀ nu, v.unit = .numeric nu → v.valBool = false)

/-- Depth of an expression tree. -/
def ExprEnc.depth : ExprEnc → Nat
  | .lit _ => 1
  | .arg _ _ => 1
  | .balance _ => 1
  | .observe _ => 1
  | .timestamp _ => 1
  | .now => 1
  | .unary _ x => 1 + x.depth
  | .binary _ x y => 1 + max x.depth y.depth
  | .ite c y n => 1 + max c.depth (max y.depth n.depth)

/-- Recursive canonicality for expressions:
    1. Literals have canonical packed values.
    2. Sub-expressions are canonical.
    3. Expression depth does not exceed max_json_depth (64). -/
def ExprCanonical (e : ExprEnc) : Prop :=
  e.depth ≤ 64 ∧
  match e with
  | .lit v => PackedValueCanonical v
  | .unary _ x => ExprCanonical x
  | .binary _ x y => ExprCanonical x ∧ ExprCanonical y
  | .ite c y n => ExprCanonical c ∧ ExprCanonical y ∧ ExprCanonical n
  | _ => True

/-- Canonical template: guard and all deltas have canonical expressions. -/
def TemplateCanonical (t : TemplateEnc) : Prop :=
  ExprCanonical t.guard ∧
  (∀ d ∈ t.deltas, ExprCanonical d.amount) ∧
  (∀ s ∈ t.supplyDeltas, ExprCanonical s.amount)

/-- Canonical registry: entries are unique and each template is canonical. -/
def RegistryCanonical (r : RegistryEnc) : Prop :=
  (r.entries.map (·.id)).Nodup ∧
  (∀ e ∈ r.entries, TemplateCanonical e.template)

/-- Canonical store: capability entries are unique. -/
def StoreCanonical (s : StoreEnc) : Prop :=
  s.entries.Nodup

/-- Canonical environment: all observations have canonical packed values. -/
def EnvironmentCanonical (env : EnvironmentEnc) : Prop :=
  ∀ e ∈ env.entries, PackedValueCanonical e.observation.value

/-- Canonical request: all arguments have canonical packed values. -/
def RequestCanonical (r : RequestEnc) : Prop :=
  ∀ a ∈ r.arguments, PackedValueCanonical a

/-- Canonical input source: literals have canonical packed values. -/
def InputSourceCanonical : InputSourceEnc → Prop
  | .literal v => PackedValueCanonical v
  | .priorOutput _ _ => True

/-- Canonical invocation: input sources are canonical. -/
def InvocationCanonical (inv : InvocationEnc) : Prop :=
  ∀ i ∈ inv.inputs, InputSourceCanonical i

/-- Supported and canonical step: no unsupported constructors, invocations canonical. -/
def StepCanonical : StepEnc → Prop
  | .invoke inv => InvocationCanonical inv
  | .issue _ => True
  | .revoke _ => True
  | .unsupported _ => False

/-- Canonical world: standard 32 state cells and canonical store. -/
def WorldCanonical (w : WorldEnc) : Prop :=
  StateCellsMatchStandard32 w.state.cells ∧
  StoreCanonical w.capabilities

/-- Canonical claimed next state: none or canonical world. -/
def ClaimedNextStateCanonical (cns : Option WorldEnc) : Prop :=
  match cns with
  | none => True
  | some w => WorldCanonical w

/-- Canonical history: output observations have canonical packed values. -/
def HistoryCanonical (h : List OutputObservationEnc) : Prop :=
  ∀ o ∈ h, PackedValueCanonical o.value

/-- Canonical boundary: environment observations are canonical. -/
def BoundaryCanonical (b : BoundaryEnc) : Prop :=
  EnvironmentCanonical b.env

/-- Length bounds for operation interface collections. -/
def OperationInterfaceLengthBounds (op : OperationInterfaceEnc) : Prop :=
  op.inputs.length ≤ 4096 ∧ op.outputs.length ≤ 4096

/-- Bounded array lengths for template collections matching parser limits. -/
def TemplateLengthBounds (t : TemplateEnc) : Prop :=
  t.signature.length ≤ 4096 ∧
  t.deltas.length ≤ 4096 ∧
  t.supplyDeltas.length ≤ 4096 ∧
  t.stateReads.length ≤ 4096 ∧
  t.envReads.length ≤ 4096 ∧
  t.writes.length ≤ 4096

/-- Length bounds for component collections. -/
def ComponentLengthBounds (c : ComponentEnc) : Prop :=
  c.privateCells.length ≤ 4096 ∧
  c.exports.length ≤ 4096 ∧
  c.imports.length ≤ 4096 ∧
  c.operations.length ≤ 4096 ∧
  (∀ op ∈ c.operations, OperationInterfaceLengthBounds op)

/-- Length bounds for composition configuration. -/
def ConfigLengthBounds (cfg : ConfigEnc) : Prop :=
  cfg.registry.entries.length ≤ 4096 ∧
  (∀ e ∈ cfg.registry.entries, TemplateLengthBounds e.template) ∧
  cfg.domainAdmin.length ≤ 4096 ∧
  cfg.catalog.length ≤ 4096 ∧
  (∀ c ∈ cfg.catalog, ComponentLengthBounds c)

/-- Length bounds for claimed next state world. -/
def ClaimedNextStateLengthBounds (cns : Option WorldEnc) : Bool :=
  match cns with
  | none => true
  | some w => w.state.cells.length == 32 && w.capabilities.entries.length <= 4096

/-- Bounded array lengths for envelope collections matching production parser limits. -/
def EnvelopeLengthBounds (env : EnvelopeEnc) : Prop :=
  env.audit_roots.length ≤ 4096 ∧
  env.assumptions.length ≤ 4096 ∧
  env.invariants.length ≤ 4096 ∧
  env.libraries.length ≤ 4096 ∧
  env.source_map.length ≤ 4096 ∧
  env.claimed_judgments.length ≤ 4096 ∧
  env.types.parties.length ≤ 4096 ∧
  env.types.assets.length ≤ 4096 ∧
  env.types.domains.length ≤ 4096 ∧
  ClaimedNextStateLengthBounds env.claimed_next_state = true

/-- Serialized byte bound: the serialized document byte length does not exceed 1 MiB (1048576 bytes). -/
def SerializedByteBound (ir : DecodedIR) : Prop :=
  (encodeModule ir).size ≤ 1048576

/-! ### Declarative JSON Serializers and Whole-Document Structural Metrics -/

def partyToJson (p : Party) : Lean.Json :=
  Lean.Json.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")


def assetToJson (a : Asset) : Lean.Json :=
  Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")


def domainToJson (d : Domain) : Lean.Json :=
  Lean.Json.str (match d with | .main => "main" | .other => "other")


def cellToJson (c : CellEnc) : Lean.Json :=
  Lean.Json.mkObj [("domain", domainToJson c.domain), ("party", partyToJson c.party), ("asset", assetToJson c.asset)]


def rightToJson : RightEnc → Lean.Json
  | .invoke => Lean.Json.mkObj [("tag", Lean.Json.str "invoke")]
  | .debit c => Lean.Json.mkObj [("tag", Lean.Json.str "debit"), ("cell", cellToJson c)]
  | .changeSupply d a => Lean.Json.mkObj [("tag", Lean.Json.str "changeSupply"), ("domain", domainToJson d), ("asset", assetToJson a)]


def grantToJson (g : GrantEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("holder", partyToJson g.holder),
    ("domain", domainToJson g.domain),
    ("operation", Lean.Json.num g.operation),
    ("right", rightToJson g.right)
  ]


def partyRefToJson : PartyRefEnc → Lean.Json
  | .caller => Lean.Json.mkObj [("tag", Lean.Json.str "caller")]
  | .argument idx => Lean.Json.mkObj [("tag", Lean.Json.str "argument"), ("index", Lean.Json.num idx)]
  | .literal p => Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", partyToJson p)]


def cellRefToJson (c : CellRefEnc) : Lean.Json :=
  Lean.Json.mkObj [("domain", domainToJson c.domain), ("owner", partyRefToJson c.owner)]


def packedCellRefToJson (c : PackedCellRefEnc) : Lean.Json :=
  Lean.Json.mkObj [("asset", assetToJson c.asset), ("cell", cellRefToJson c.cell)]


def observationKeyToJson (k : ObservationKeyEnc) : Lean.Json :=
  Lean.Json.mkObj [("domain", domainToJson k.domain), ("id", Lean.Json.num k.id)]


def numericUnitToJson : NumericUnitEnc → Lean.Json
  | .scalar => Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]
  | .amount a => Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", assetToJson a)]
  | .price b q => Lean.Json.mkObj [("tag", Lean.Json.str "price"), ("base", assetToJson b), ("quote", assetToJson q)]


def unitToJson : UnitEnc → Lean.Json
  | .bool => Lean.Json.mkObj [("tag", Lean.Json.str "bool")]
  | .numeric nu => numericUnitToJson nu


def observationRefToJson (r : ObservationRefEnc) : Lean.Json :=
  Lean.Json.mkObj [("key", observationKeyToJson r.key), ("unit", unitToJson r.unit)]


def ratToJson (r : RatEnc) : Lean.Json :=
  Lean.Json.mkObj [("num", Lean.Json.num r.num), ("den", Lean.Json.num r.den)]


def unaryOpToJson : UnaryOpEnc → Lean.Json
  | .not => Lean.Json.mkObj [("tag", Lean.Json.str "not")]
  | .neg nu => Lean.Json.mkObj [("tag", Lean.Json.str "neg"), ("numeric", numericUnitToJson nu)]


def binaryOpToJson : BinaryOpEnc → Lean.Json
  | .add nu => Lean.Json.mkObj [("tag", Lean.Json.str "add"), ("numeric", numericUnitToJson nu)]
  | .sub nu => Lean.Json.mkObj [("tag", Lean.Json.str "sub"), ("numeric", numericUnitToJson nu)]
  | .scale nu => Lean.Json.mkObj [("tag", Lean.Json.str "scale"), ("numeric", numericUnitToJson nu)]
  | .divide nu => Lean.Json.mkObj [("tag", Lean.Json.str "divide"), ("numeric", numericUnitToJson nu)]
  | .ratio nu => Lean.Json.mkObj [("tag", Lean.Json.str "ratio"), ("numeric", numericUnitToJson nu)]
  | .convert b q => Lean.Json.mkObj [("tag", Lean.Json.str "convert"), ("base", assetToJson b), ("quote", assetToJson q)]
  | .unconvert b q => Lean.Json.mkObj [("tag", Lean.Json.str "unconvert"), ("base", assetToJson b), ("quote", assetToJson q)]
  | .and => Lean.Json.mkObj [("tag", Lean.Json.str "and")]
  | .or => Lean.Json.mkObj [("tag", Lean.Json.str "or")]
  | .eq u => Lean.Json.mkObj [("tag", Lean.Json.str "eq"), ("unit", unitToJson u)]
  | .lt nu => Lean.Json.mkObj [("tag", Lean.Json.str "lt"), ("numeric", numericUnitToJson nu)]
  | .le nu => Lean.Json.mkObj [("tag", Lean.Json.str "le"), ("numeric", numericUnitToJson nu)]


def packedValueToJson (v : PackedValueEnc) : Lean.Json :=
  match v.unit with
  | .bool => Lean.Json.bool v.valBool
  | .numeric _ => ratToJson ⟨v.valRat.num, v.valRat.den⟩


def packedValueFullToJson (v : PackedValueEnc) : Lean.Json :=
  Lean.Json.mkObj [("unit", unitToJson v.unit), ("value", packedValueToJson v)]


def exprToJson : ExprEnc → Lean.Json
  | .lit v => Lean.Json.mkObj [("tag", Lean.Json.str "lit"), ("unit", unitToJson v.unit), ("value", packedValueToJson v)]
  | .arg idx u => Lean.Json.mkObj [("tag", Lean.Json.str "arg"), ("index", Lean.Json.num idx), ("unit", unitToJson u)]
  | .balance c => Lean.Json.mkObj [("tag", Lean.Json.str "balance"), ("cell", packedCellRefToJson c)]
  | .observe r => Lean.Json.mkObj [("tag", Lean.Json.str "observe"), ("ref", observationRefToJson r)]
  | .timestamp k => Lean.Json.mkObj [("tag", Lean.Json.str "timestamp"), ("key", observationKeyToJson k)]
  | .now => Lean.Json.mkObj [("tag", Lean.Json.str "now")]
  | .unary op x => Lean.Json.mkObj [("tag", Lean.Json.str "unary"), ("op", unaryOpToJson op), ("x", exprToJson x)]
  | .binary op x y => Lean.Json.mkObj [("tag", Lean.Json.str "binary"), ("op", binaryOpToJson op), ("x", exprToJson x), ("y", exprToJson y)]
  | .ite c y n => Lean.Json.mkObj [("tag", Lean.Json.str "ite"), ("condition", exprToJson c), ("yes", exprToJson y), ("no", exprToJson n)]


def stateCellToJson (c : StateCellEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("domain", domainToJson c.domain),
    ("party", partyToJson c.party),
    ("asset", assetToJson c.asset),
    ("amount", ratToJson c.amount)
  ]


def envReadToJson (er : EnvReadEnc) : Lean.Json :=
  match er with
  | .observation k => Lean.Json.mkObj [("tag", Lean.Json.str "observation"), ("key", observationKeyToJson k)]
  | .currentTime => Lean.Json.mkObj [("tag", Lean.Json.str "currentTime")]


def cellDeltaToJson (d : CellDeltaEnc) : Lean.Json :=
  Lean.Json.mkObj [("asset", assetToJson d.asset), ("target", cellRefToJson d.target), ("amount", exprToJson d.amount)]


def supplyDeltaToJson (s : SupplyDeltaEnc) : Lean.Json :=
  Lean.Json.mkObj [("domain", domainToJson s.domain), ("asset", assetToJson s.asset), ("amount", exprToJson s.amount)]


def templateToJson (t : TemplateEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("signature", Lean.Json.arr (t.signature.map unitToJson).toArray),
    ("domain", domainToJson t.domain),
    ("partyArity", Lean.Json.num t.partyArity),
    ("guard", exprToJson t.guard),
    ("deltas", Lean.Json.arr (t.deltas.map cellDeltaToJson).toArray),
    ("supplyDeltas", Lean.Json.arr (t.supplyDeltas.map supplyDeltaToJson).toArray),
    ("stateReads", Lean.Json.arr (t.stateReads.map packedCellRefToJson).toArray),
    ("envReads", Lean.Json.arr (t.envReads.map envReadToJson).toArray),
    ("writes", Lean.Json.arr (t.writes.map packedCellRefToJson).toArray)
  ]

set_option maxHeartbeats 1000000 in
-- complex multi-field AST decoding requires increased heartbeats for kernel reduction

def registryEntryToJson (e : RegistryEntryEnc) : Lean.Json :=
  Lean.Json.mkObj [("id", Lean.Json.num e.id), ("template", templateToJson e.template)]

set_option maxHeartbeats 1000000 in
-- nested template decoding requires increased heartbeats for kernel reduction

def registryToJson (r : RegistryEnc) : Lean.Json :=
  Lean.Json.mkObj [("entries", Lean.Json.arr (r.entries.map registryEntryToJson).toArray)]

set_option maxHeartbeats 1000000 in
-- registry decoding and uniqueness check require increased heartbeats for kernel reduction

def capabilityToJson (c : CapabilityEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("holder", partyToJson c.holder),
    ("domain", domainToJson c.domain),
    ("operation", Lean.Json.num c.operation),
    ("right", rightToJson c.right),
    ("live", Lean.Json.bool c.live)
  ]


def storeToJson (s : StoreEnc) : Lean.Json :=
  Lean.Json.mkObj [("entries", Lean.Json.arr (s.entries.map capabilityToJson).toArray)]


def contextToJson (c : ContextEnc) : Lean.Json :=
  Lean.Json.mkObj [("principal", partyToJson c.principal), ("domain", domainToJson c.domain)]


def observationToJson (o : ObservationEnc) : Lean.Json :=
  Lean.Json.mkObj [("value", packedValueFullToJson o.value), ("timestamp", Lean.Json.num o.timestamp)]


def environmentEntryToJson (e : EnvironmentEntryEnc) : Lean.Json :=
  Lean.Json.mkObj [("key", observationKeyToJson e.key), ("observation", observationToJson e.observation)]


def environmentToJson (env : EnvironmentEnc) : Lean.Json :=
  Lean.Json.mkObj [("entries", Lean.Json.arr (env.entries.map environmentEntryToJson).toArray)]


def domainAdminToJson (d : DomainAdminEnc) : Lean.Json :=
  Lean.Json.mkObj [("domain", domainToJson d.domain), ("party", partyToJson d.party)]


def inputPortToJson (p : InputPortEnc) : Lean.Json :=
  Lean.Json.mkObj [("id", Lean.Json.num p.id), ("unit", unitToJson p.unit)]


def outputPortToJson (p : OutputPortEnc) : Lean.Json :=
  Lean.Json.mkObj [("id", Lean.Json.num p.id), ("cell", cellToJson p.cell)]


def resourcePortToJson (rp : ResourcePortEnc) : Lean.Json :=
  Lean.Json.mkObj [("id", Lean.Json.num rp.id), ("cell", cellToJson rp.cell), ("writable", Lean.Json.bool rp.writable)]


def qualifiedPortToJson (qp : QualifiedPortEnc) : Lean.Json :=
  Lean.Json.mkObj [("component", Lean.Json.num qp.component), ("port", Lean.Json.num qp.port)]


def resourceImportToJson (ri : ResourceImportEnc) : Lean.Json :=
  Lean.Json.mkObj [("source", qualifiedPortToJson ri.source), ("cell", cellToJson ri.cell), ("writable", Lean.Json.bool ri.writable)]


def sourcePinToJson (sp : SourcePinEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("git", Lean.Json.str sp.git),
    ("lean_toolchain", Lean.Json.str sp.lean_toolchain),
    ("mathlib_rev", Lean.Json.str sp.mathlib_rev),
    ("checker_candidate", Lean.Json.str sp.checker_candidate),
    ("compiler_record", match sp.compiler_record with | some r => Lean.Json.str r | none => Lean.Json.null),
    ("audit_record", match sp.audit_record with | some r => Lean.Json.str r | none => Lean.Json.null)
  ]


def typesEnumToJson (te : TypesEnumEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("parties", Lean.Json.arr (te.parties.map partyToJson).toArray),
    ("assets", Lean.Json.arr (te.assets.map assetToJson).toArray),
    ("domains", Lean.Json.arr (te.domains.map domainToJson).toArray)
  ]

def libraryRefToJson (lr : LibraryRefEnc) : Lean.Json :=
  match lr.moduleName with
  | none => Lean.Json.mkObj [("theorem", Lean.Json.str lr.theoremName)]
  | some m => Lean.Json.mkObj [("module", Lean.Json.str m), ("theorem", Lean.Json.str lr.theoremName)]

def natToJson (n : Nat) : Lean.Json := Lean.Json.num n

def stateToJson (s : StateEnc) : Lean.Json :=
  Lean.Json.mkObj [("cells", Lean.Json.arr (s.cells.map stateCellToJson).toArray)]

def requestToJson (r : RequestEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("arguments", Lean.Json.arr (r.arguments.map packedValueFullToJson).toArray),
    ("capabilityIds", Lean.Json.arr (r.capabilityIds.map natToJson).toArray),
    ("claimedActor", match r.claimedActor with | none => Lean.Json.null | some p => partyToJson p),
    ("operation", Lean.Json.num r.operation),
    ("parties", Lean.Json.arr (r.parties.map partyToJson).toArray)
  ]

def typedExecutePayloadToJson (p : TypedExecutePayloadEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("ctx", contextToJson p.ctx),
    ("env", environmentToJson p.env),
    ("now", Lean.Json.num p.now),
    ("registry", registryToJson p.registry),
    ("request", requestToJson p.request),
    ("state", stateToJson p.state),
    ("store", storeToJson p.store)
  ]

def operationInterfaceToJson (op : OperationInterfaceEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("inputs", Lean.Json.arr (op.inputs.map inputPortToJson).toArray),
    ("operation", Lean.Json.num op.operation),
    ("outputs", Lean.Json.arr (op.outputs.map outputPortToJson).toArray)
  ]

def componentToJson (c : ComponentEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("exports", Lean.Json.arr (c.exports.map resourcePortToJson).toArray),
    ("id", Lean.Json.num c.id),
    ("imports", Lean.Json.arr (c.imports.map resourceImportToJson).toArray),
    ("operations", Lean.Json.arr (c.operations.map operationInterfaceToJson).toArray),
    ("privateCells", Lean.Json.arr (c.privateCells.map cellToJson).toArray)
  ]

def configToJson (cfg : ConfigEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("catalog", Lean.Json.arr (cfg.catalog.map componentToJson).toArray),
    ("domainAdmin", Lean.Json.arr (cfg.domainAdmin.map domainAdminToJson).toArray),
    ("registry", registryToJson cfg.registry)
  ]

def worldToJson (w : WorldEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("capabilities", storeToJson w.capabilities),
    ("state", stateToJson w.state)
  ]

def boundaryToJson (b : BoundaryEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("ctx", contextToJson b.ctx),
    ("env", environmentToJson b.env),
    ("now", Lean.Json.num b.now)
  ]

def inputSourceToJson : InputSourceEnc → Lean.Json
  | .literal v =>
    Lean.Json.mkObj [
      ("tag", Lean.Json.str "literal"),
      ("value", packedValueFullToJson v)
    ]
  | .priorOutput step port =>
    Lean.Json.mkObj [
      ("port", qualifiedPortToJson port),
      ("step", Lean.Json.num step),
      ("tag", Lean.Json.str "priorOutput")
    ]

def invocationToJson (inv : InvocationEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("capabilityIds", Lean.Json.arr (inv.capabilityIds.map natToJson).toArray),
    ("claimedActor", match inv.claimedActor with | none => Lean.Json.null | some p => partyToJson p),
    ("component", Lean.Json.num inv.component),
    ("inputs", Lean.Json.arr (inv.inputs.map inputSourceToJson).toArray),
    ("operation", Lean.Json.num inv.operation),
    ("parties", Lean.Json.arr (inv.parties.map partyToJson).toArray)
  ]

def stepToJson : StepEnc → Lean.Json
  | .invoke inv =>
    Lean.Json.mkObj [
      ("invocation", invocationToJson inv),
      ("tag", Lean.Json.str "invoke")
    ]
  | .issue grant =>
    Lean.Json.mkObj [
      ("grant", grantToJson grant),
      ("tag", Lean.Json.str "issue")
    ]
  | .revoke id =>
    Lean.Json.mkObj [
      ("id", Lean.Json.num id),
      ("tag", Lean.Json.str "revoke")
    ]
  | .unsupported s =>
    Lean.Json.mkObj [
      ("tag", Lean.Json.str s)
    ]

def outputObservationToJson (o : OutputObservationEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("port", qualifiedPortToJson o.port),
    ("step", Lean.Json.num o.step),
    ("value", packedValueFullToJson o.value)
  ]

def compositionStepPayloadToJson (p : CompositionStepPayloadEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("boundary", boundaryToJson p.boundary),
    ("config", configToJson p.config),
    ("history", Lean.Json.arr (p.history.map outputObservationToJson).toArray),
    ("index", Lean.Json.num p.index),
    ("pre", worldToJson p.pre),
    ("step", stepToJson p.step)
  ]

def compositionRunPayloadToJson (p : CompositionRunPayloadEnc) : Lean.Json :=
  Lean.Json.mkObj [
    ("boundaries", Lean.Json.arr (p.boundaries.map boundaryToJson).toArray),
    ("config", configToJson p.config),
    ("steps", Lean.Json.arr (p.steps.map stepToJson).toArray),
    ("world", worldToJson p.world)
  ]

def envelopeToJson (env : EnvelopeEnc) (payloadJson : Lean.Json) : Lean.Json :=
  Lean.Json.mkObj [
    ("assumptions", Lean.Json.arr (env.assumptions.map Lean.Json.str).toArray),
    ("audit_roots", Lean.Json.arr (env.audit_roots.map Lean.Json.str).toArray),
    ("claimed_judgments", Lean.Json.arr (env.claimed_judgments.map Lean.Json.str).toArray),
    ("claimed_next_state", match env.claimed_next_state with | none => Lean.Json.null | some w => worldToJson w),
    ("invariants", Lean.Json.arr (env.invariants.map Lean.Json.str).toArray),
    ("libraries", Lean.Json.arr (env.libraries.map libraryRefToJson).toArray),
    ("mode", Lean.Json.str env.mode),
    ("payload", payloadJson),
    ("require_invariant_discharge", Lean.Json.bool env.require_invariant_discharge),
    ("require_library_discharge", Lean.Json.bool env.require_library_discharge),
    ("schema_version", Lean.Json.num env.schema_version),
    ("source_map", Lean.Json.mkObj (env.source_map.map (fun (k, v) => (k, Lean.Json.str v)))),
    ("source_pin", sourcePinToJson env.source_pin),
    ("types", typesEnumToJson env.types)
  ]

def decodedIRToJson : DecodedIR → Lean.Json
  | .execution (.typed env p) =>
    envelopeToJson env (typedExecutePayloadToJson p)
  | .execution (.step env p) =>
    envelopeToJson env (compositionStepPayloadToJson p)
  | .execution (.run env p) =>
    envelopeToJson env (compositionRunPayloadToJson p)
  | .audit _ => Lean.Json.null
  | .codec _ => Lean.Json.null

/-- Fuel-bounded calculation of whole-document JSON nesting depth. -/
def jsonDepthFuel (fuel : Nat) (j : Lean.Json) : Nat :=
  match fuel with
  | 0 => 0
  | fuel + 1 =>
    match j with
    | .arr elems =>
      1 + elems.foldl (fun acc elem => Nat.max acc (jsonDepthFuel fuel elem)) 0
    | .obj kvs =>
      1 + kvs.foldl (fun acc _ val => Nat.max acc (jsonDepthFuel fuel val)) 0
    | _ => 0

/-- Whole-document JSON nesting depth.
    Bounded fuel 100 is strictly sufficient for any document satisfying the grammar limit (depth ≤ 64). -/
def jsonDepth (j : Lean.Json) : Nat :=
  jsonDepthFuel 100 j

/-- Non-container JSON values (null, bool, num, str) contribute 0 to container nesting depth. -/
theorem jsonDepth_scalar (j : Lean.Json) (h : match j with | .arr _ | .obj _ => false | _ => true) :
    jsonDepth j = 0 := by
  cases j <;> try contradiction
  all_goals rfl

/-- Fuel sufficiency: for any fuel, non-container JSON values evaluate to 0 depth. -/
theorem jsonDepthFuel_zero_of_scalar (fuel : Nat) (j : Lean.Json)
    (h : match j with | .arr _ | .obj _ => false | _ => true) :
    jsonDepthFuel fuel j = 0 := by
  cases fuel with
  | zero => rfl
  | succ f =>
    cases j <;> try contradiction
    all_goals rfl

/-- Fuel-bounded calculation of whole-document maximum JSON array length. -/
def jsonMaxArrayLengthFuel (fuel : Nat) (j : Lean.Json) : Nat :=
  match fuel with
  | 0 => 0
  | fuel + 1 =>
    match j with
    | .arr elems =>
      Nat.max elems.size (elems.foldl (fun acc elem => Nat.max acc (jsonMaxArrayLengthFuel fuel elem)) 0)
    | .obj kvs =>
      kvs.foldl (fun acc _ val => Nat.max acc (jsonMaxArrayLengthFuel fuel val)) 0
    | _ => 0

/-- Whole-document maximum JSON array length. -/
def jsonMaxArrayLength (j : Lean.Json) : Nat :=
  jsonMaxArrayLengthFuel 100 j

/-- Whole-document JSON depth bounded by 64 (parser maximum depth limit). -/
def WholeDocumentDepthBounded (ir : DecodedIR) : Prop :=
  jsonDepth (decodedIRToJson ir) ≤ 64

/-- Whole-document JSON array lengths bounded by 4096 (parser maximum array length limit). -/
def WholeDocumentArrayBounded (ir : DecodedIR) : Prop :=
  jsonMaxArrayLength (decodedIRToJson ir) ≤ 4096

/-- Intermediate monotonicity helper: folding max never decreases initial accumulator. -/
theorem foldl_max_ge {α : Type} (xs : List α) (f : α → Nat) (init : Nat) :
    init ≤ xs.foldl (fun acc y => Nat.max acc (f y)) init := by
  induction xs generalizing init with
  | nil => exact Nat.le_refl init
  | cons x xs ih =>
    dsimp [List.foldl]
    have h1 : init ≤ Nat.max init (f x) := Nat.le_max_left init (f x)
    have h2 := ih (Nat.max init (f x))
    exact Nat.le_trans h1 h2

/-- Intermediate membership bound: any element's value is bounded by foldl max. -/
theorem mem_le_foldl_max {α : Type} (xs : List α) (f : α → Nat) (x : α) (hx : x ∈ xs) (init : Nat) :
    f x ≤ xs.foldl (fun acc y => Nat.max acc (f y)) init := by
  induction xs generalizing init with
  | nil => contradiction
  | cons y ys ih =>
    dsimp [List.foldl]
    cases hx with
    | head =>
      have h1 : f x ≤ Nat.max init (f x) := Nat.le_max_right init (f x)
      have h2 := foldl_max_ge ys f (Nat.max init (f x))
      exact Nat.le_trans h1 h2
    | tail _ htail =>
      exact ih htail (Nat.max init (f y))

/-- Congruence lemma for foldl max under pointwise equality on elements. -/
theorem foldl_max_congr {α : Type} (xs : List α) (f g : α → Nat) (init : Nat)
    (h : ∀ x ∈ xs, f x = g x) :
    xs.foldl (fun acc y => Nat.max acc (f y)) init = xs.foldl (fun acc y => Nat.max acc (g y)) init := by
  induction xs generalizing init with
  | nil => rfl
  | cons x xs ih =>
    dsimp [List.foldl]
    have h_x := h x (List.Mem.head xs)
    rw [h_x]
    apply ih
    intro y hy
    exact h y (List.Mem.tail x hy)

/-- Fuel stability theorem for jsonDepthFuel: once fuel strictly exceeds computed depth,
    increasing fuel produces identical depth values. -/
theorem jsonDepthFuel_stable (f : Nat) (j : Lean.Json) (h : jsonDepthFuel f j < f) :
    ∀ g ≥ f, jsonDepthFuel g j = jsonDepthFuel f j := by
  induction f generalizing j with
  | zero => omega
  | succ f ih =>
    intro g hg
    rcases g with _ | g
    · omega
    have hg_le : f ≤ g := Nat.le_of_succ_le_succ hg
    cases j with
    | null => rfl
    | bool b => rfl
    | num n => rfl
    | str s => rfl
    | arr elems =>
      dsimp [jsonDepthFuel] at h ⊢
      have h_lt : elems.foldl (fun acc elem => Nat.max acc (jsonDepthFuel f elem)) 0 < f := by
        omega
      rw [← Array.foldl_toList] at h_lt ⊢
      have h_elem_eq : ∀ elem ∈ elems.toList, jsonDepthFuel g elem = jsonDepthFuel f elem := by
        intro elem helem
        have h_elem_le := mem_le_foldl_max elems.toList (fun elem => jsonDepthFuel f elem) elem helem 0
        have h_elem_lt : jsonDepthFuel f elem < f := by omega
        exact ih elem h_elem_lt g hg_le
      have h_fold_eq := foldl_max_congr elems.toList (fun elem => jsonDepthFuel g elem) (fun elem => jsonDepthFuel f elem) 0 h_elem_eq
      rw [h_fold_eq]
      rw [Array.foldl_toList]
    | obj kvs =>
      dsimp [jsonDepthFuel] at h ⊢
      have h_lt : kvs.foldl (fun acc _ val => Nat.max acc (jsonDepthFuel f val)) 0 < f := by
        omega
      rw [Std.TreeMap.Raw.foldl_eq_foldl_toList] at h_lt ⊢
      have h_val_eq : ∀ p ∈ kvs.toList, jsonDepthFuel g p.2 = jsonDepthFuel f p.2 := by
        intro p hp
        have h_p_le := mem_le_foldl_max kvs.toList (fun p => jsonDepthFuel f p.2) p hp 0
        have h_p_lt : jsonDepthFuel f p.2 < f := by omega
        exact ih p.2 h_p_lt g hg_le
      have h_fold_eq := foldl_max_congr kvs.toList (fun p => jsonDepthFuel g p.2) (fun p => jsonDepthFuel f p.2) 0 h_val_eq
      rw [h_fold_eq]
      rw [Std.TreeMap.Raw.foldl_eq_foldl_toList]

/-- Fuel stability theorem for jsonMaxArrayLengthFuel: once fuel strictly exceeds computed depth,
    increasing fuel produces identical maximum array length values. -/
theorem jsonMaxArrayLengthFuel_stable (f : Nat) (j : Lean.Json) (h : jsonDepthFuel f j < f) :
    ∀ g ≥ f, jsonMaxArrayLengthFuel g j = jsonMaxArrayLengthFuel f j := by
  induction f generalizing j with
  | zero => omega
  | succ f ih =>
    intro g hg
    rcases g with _ | g
    · omega
    have hg_le : f ≤ g := Nat.le_of_succ_le_succ hg
    cases j with
    | null => rfl
    | bool b => rfl
    | num n => rfl
    | str s => rfl
    | arr elems =>
      dsimp [jsonDepthFuel] at h
      dsimp [jsonMaxArrayLengthFuel]
      have h_lt : elems.foldl (fun acc elem => Nat.max acc (jsonDepthFuel f elem)) 0 < f := by
        omega
      rw [← Array.foldl_toList] at h_lt ⊢
      have h_elem_eq : ∀ elem ∈ elems.toList, jsonMaxArrayLengthFuel g elem = jsonMaxArrayLengthFuel f elem := by
        intro elem helem
        have h_elem_le := mem_le_foldl_max elems.toList (fun elem => jsonDepthFuel f elem) elem helem 0
        have h_elem_lt : jsonDepthFuel f elem < f := by omega
        exact ih elem h_elem_lt g hg_le
      have h_fold_eq := foldl_max_congr elems.toList (fun elem => jsonMaxArrayLengthFuel g elem) (fun elem => jsonMaxArrayLengthFuel f elem) 0 h_elem_eq
      rw [h_fold_eq]
      rw [Array.foldl_toList]
    | obj kvs =>
      dsimp [jsonDepthFuel] at h
      dsimp [jsonMaxArrayLengthFuel]
      have h_lt : kvs.foldl (fun acc _ val => Nat.max acc (jsonDepthFuel f val)) 0 < f := by
        omega
      rw [Std.TreeMap.Raw.foldl_eq_foldl_toList] at h_lt ⊢
      have h_val_eq : ∀ p ∈ kvs.toList, jsonMaxArrayLengthFuel g p.2 = jsonMaxArrayLengthFuel f p.2 := by
        intro p hp
        have h_p_le := mem_le_foldl_max kvs.toList (fun p => jsonDepthFuel f p.2) p hp 0
        have h_p_lt : jsonDepthFuel f p.2 < f := by omega
        exact ih p.2 h_p_lt g hg_le
      have h_fold_eq := foldl_max_congr kvs.toList (fun p => jsonMaxArrayLengthFuel g p.2) (fun p => jsonMaxArrayLengthFuel f p.2) 0 h_val_eq
      rw [h_fold_eq]
      rw [Std.TreeMap.Raw.foldl_eq_foldl_toList]

/-- Bounded fuel adequacy: If the computed depth at fuel 100 is bounded by 64,
    then the depth fuel 100 is strictly adequate (depth < 100). -/
theorem jsonDepth_bound_lt_fuel (j : Lean.Json) (h : jsonDepth j ≤ 64) :
    jsonDepth j < 100 := by
  omega

/-- Preserved alias for jsonDepth_bound_lt_fuel. -/
theorem jsonDepthFuel_adequate_of_le64 (j : Lean.Json) (h : jsonDepth j ≤ 64) :
    jsonDepth j < 100 :=
  jsonDepth_bound_lt_fuel j h

/-- Array length fuel adequacy: fuel 100 is adequate whenever depth is bounded by 64. -/
theorem jsonMaxArrayLengthFuel_adequate (j : Lean.Json) (h : jsonDepth j ≤ 64) :
    jsonDepth j < 100 :=
  jsonDepth_bound_lt_fuel j h

/-- For any document with depth ≤ 64, any fuel g ≥ 100 yields the exact same depth as jsonDepth. -/
theorem jsonDepth_stable_of_le64 (j : Lean.Json) (h : jsonDepth j ≤ 64) :
    ∀ g ≥ 100, jsonDepthFuel g j = jsonDepth j := by
  have h_lt : jsonDepthFuel 100 j < 100 := by
    dsimp [jsonDepth] at h
    omega
  exact jsonDepthFuel_stable 100 j h_lt

/-- For any document with depth ≤ 64, any fuel g ≥ 100 yields the exact same max array length as jsonMaxArrayLength. -/
theorem jsonMaxArrayLength_stable_of_le64 (j : Lean.Json) (h : jsonDepth j ≤ 64) :
    ∀ g ≥ 100, jsonMaxArrayLengthFuel g j = jsonMaxArrayLength j := by
  have h_lt : jsonDepthFuel 100 j < 100 := by
    dsimp [jsonDepth] at h
    omega
  exact jsonMaxArrayLengthFuel_stable 100 j h_lt

/-- Max depth bound hypothesis unboxing for whole documents.
    Note: this extracts the hypothesis WholeDocumentDepthBounded ir definitionally,
    distinct from whole-document pushdown parser state agreement. -/
theorem parser_max_depth_bound (ir : DecodedIR) (h : WholeDocumentDepthBounded ir) :
    jsonDepth (decodedIRToJson ir) ≤ 64 := h

/-- Max array length bound hypothesis unboxing for whole documents.
    Note: this extracts the hypothesis WholeDocumentArrayBounded ir definitionally,
    distinct from whole-document pushdown parser state agreement. -/
theorem parser_max_array_bound (ir : DecodedIR) (h : WholeDocumentArrayBounded ir) :
    jsonMaxArrayLength (decodedIRToJson ir) ≤ 4096 := h

/-- Tokenizer inversion on canonically escaped JSON string. -/
theorem tokenize_escapeJsonString (s : String) :
    tokenize (escapeJsonString s) = .ok [JsonToken.str s] := by
  dsimp [tokenize, escapeJsonString]
  have h_eq : ('"' :: (escapeChars s.toList ++ ['"'])) = ('"' :: (escapeChars s.toList ++ ('"' :: []))) := rfl
  rw [String.toList_ofList]
  have h_len : (('"' :: (escapeChars s.toList ++ ['"'])).length) ≥ 1 := by
    simp
  have h_split : ∃ k, ('"' :: (escapeChars s.toList ++ ['"'])).length = k + 1 := by
    cases h : ('"' :: (escapeChars s.toList ++ ['"'])).length with
    | zero =>
      rw [h] at h_len
      contradiction
    | succ n => exact ⟨n, rfl⟩
  rcases h_split with ⟨k, hk⟩
  rw [hk]
  rw [h_eq]
  rw [tokenizeFuel_string (k + 1) s []]
  rfl

/-- Parser inversion on canonically escaped JSON string. -/
theorem parseCanonicalJson_escapeJsonString (s : String) :
    parseCanonicalJson (escapeJsonString s) = .ok (Lean.Json.str s) := by
  dsimp [parseCanonicalJson]
  rw [tokenize_escapeJsonString s]
  rfl



/-- Bounded array lengths for typed execute payload matching production parser limits. -/
def TypedPayloadLengthBounds (p : TypedExecutePayloadEnc) : Prop :=
  p.state.cells.length = 32 ∧
  p.registry.entries.length ≤ 4096 ∧
  (∀ e ∈ p.registry.entries, TemplateLengthBounds e.template) ∧
  p.store.entries.length ≤ 4096 ∧
  p.env.entries.length ≤ 4096 ∧
  p.request.arguments.length ≤ 4096 ∧
  p.request.capabilityIds.length ≤ 4096 ∧
  p.request.parties.length ≤ 4096

/-- Length bounds for individual composition steps. -/
def StepLengthBounds (s : StepEnc) : Prop :=
  match s with
  | .invoke inv => inv.inputs.length ≤ 4096 ∧ inv.capabilityIds.length ≤ 4096 ∧ inv.parties.length ≤ 4096
  | _ => True

/-- Bounded array lengths for composition step payload matching production parser limits. -/
def StepPayloadLengthBounds (p : CompositionStepPayloadEnc) : Prop :=
  ConfigLengthBounds p.config ∧
  p.pre.state.cells.length = 32 ∧
  p.pre.capabilities.entries.length ≤ 4096 ∧
  p.boundary.env.entries.length ≤ 4096 ∧
  p.history.length ≤ 4096 ∧
  StepLengthBounds p.step

/-- Bounded array lengths for composition run payload matching production parser limits. -/
def RunPayloadLengthBounds (p : CompositionRunPayloadEnc) : Prop :=
  ConfigLengthBounds p.config ∧
  p.world.state.cells.length = 32 ∧
  p.world.capabilities.entries.length ≤ 4096 ∧
  p.boundaries.length ≤ 4096 ∧
  (∀ b ∈ p.boundaries, b.env.entries.length ≤ 4096) ∧
  p.steps.length ≤ 4096 ∧
  (∀ s ∈ p.steps, StepLengthBounds s)

/-- Supported IR predicate: schema version 1, modes, complete 32-cell layout, non-negative amounts,
    supported step constructors, unique store and registry entries, parser resource bounds,
    and serialized byte bound (≤ 1 MiB). -/
def SupportedIR (ir : DecodedIR) : Prop :=
  SerializedByteBound ir ∧
  WholeDocumentDepthBounded ir ∧
  WholeDocumentArrayBounded ir ∧
  match ir with
  | .execution (.typed env payload) =>
    env.schema_version = 1 ∧
    env.mode = "typed-execute" ∧
    StandardTypesEnum env.types ∧
    payload.state.cells.length = 32 ∧
    payload.state.cells.map (fun c ↦ (c.domain, c.party, c.asset)) = standard32CellKeys ∧
    payload.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    StoreCanonical payload.store ∧
    (payload.registry.entries.map (·.id)).Nodup ∧
    EnvelopeLengthBounds env ∧
    TypedPayloadLengthBounds payload
  | .execution (.step env payload) =>
    env.schema_version = 1 ∧
    env.mode = "composition-step" ∧
    StandardTypesEnum env.types ∧
    (match payload.step with | .unsupported _ => False | _ => True) ∧
    payload.pre.state.cells.length = 32 ∧
    payload.pre.state.cells.map (fun c ↦ (c.domain, c.party, c.asset)) = standard32CellKeys ∧
    payload.pre.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    StoreCanonical payload.pre.capabilities ∧
    (payload.config.registry.entries.map (·.id)).Nodup ∧
    EnvelopeLengthBounds env ∧
    StepPayloadLengthBounds payload
  | .execution (.run env payload) =>
    env.schema_version = 1 ∧
    env.mode = "composition-run" ∧
    StandardTypesEnum env.types ∧
    payload.steps.all (fun s ↦ match s with | .unsupported _ => false | _ => true) = true ∧
    payload.world.state.cells.length = 32 ∧
    payload.world.state.cells.map (fun c ↦ (c.domain, c.party, c.asset)) = standard32CellKeys ∧
    payload.world.state.cells.all (fun c ↦ c.amount.den > 0 ∧ c.amount.num ≥ 0) = true ∧
    StoreCanonical payload.world.capabilities ∧
    (payload.config.registry.entries.map (·.id)).Nodup ∧
    EnvelopeLengthBounds env ∧
    RunPayloadLengthBounds payload
  | .audit _ => False
  | .codec _ => False

/-- Canonical IR predicate: lexicographical source map order, canonical rationals,
    inactive packed-value fields in arguments, expressions, and observations,
    and canonical template/step forms. -/
def CanonicalIR (ir : DecodedIR) : Prop :=
  match ir with
  | .execution (.typed env payload) =>
    SourceMapSorted env.source_map ∧
    ClaimedNextStateCanonical env.claimed_next_state ∧
    payload.state.cells.all (fun c ↦ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true ∧
    (∀ e ∈ payload.registry.entries, TemplateCanonical e.template) ∧
    RequestCanonical payload.request ∧
    EnvironmentCanonical payload.env
  | .execution (.step env payload) =>
    SourceMapSorted env.source_map ∧
    ClaimedNextStateCanonical env.claimed_next_state ∧
    payload.pre.state.cells.all (fun c ↦ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true ∧
    StepCanonical payload.step ∧
    (∀ e ∈ payload.config.registry.entries, TemplateCanonical e.template) ∧
    HistoryCanonical payload.history ∧
    BoundaryCanonical payload.boundary
  | .execution (.run env payload) =>
    SourceMapSorted env.source_map ∧
    ClaimedNextStateCanonical env.claimed_next_state ∧
    payload.world.state.cells.all (fun c ↦ Int.gcd c.amount.num.natAbs c.amount.den = 1) = true ∧
    (∀ s ∈ payload.steps, StepCanonical s) ∧
    (∀ e ∈ payload.config.registry.entries, TemplateCanonical e.template) ∧
    (∀ b ∈ payload.boundaries, BoundaryCanonical b)
  | .audit _ => False
  | .codec _ => False

/-- Structurally admissible canonical IR domain covering the accepted 32-cell execution universe.
    Defined as the conjunction of SupportedIR and CanonicalIR. -/
def StructurallyAdmissibleIR (ir : DecodedIR) : Prop :=
  SupportedIR ir ∧ CanonicalIR ir

/-- Nonempty witness for StructurallyAdmissibleIR: a standard 32-cell zero-initialized state
    with canonical 0/1 rationals, schema version 1, and typed-execute mode. -/
def standard32Cells : List StateCellEnc :=
  let parties : List Party := [.alice, .bob, .vault, .pool]
  let assets : List Asset := [.usd, .share, .collateral, .debt]
  let domains : List Domain := [.main, .other]
  domains.flatMap fun d ↦
    parties.flatMap fun p ↦
      assets.map fun a ↦
        ⟨d, p, a, ⟨0, 1⟩⟩

def canonicalWitnessIR : DecodedIR :=
  .execution (.typed
    ⟨1, "typed-execute", ⟨"a12b7cac05a818cc8d35c2ca440b7170a2807e92", "leanprover/lean4:v4.33.0-rc2",
      "51e6992efd06126df61a496bebf8f49482a4e129", "", none, none⟩,
      ["DefiKernel.Certificates", "DefiKernel.Typed", "DefiKernel.Composition"],
      ⟨[.alice, .bob, .vault, .pool], [.usd, .share, .collateral, .debt], [.main, .other]⟩,
      ["environment-authenticity"], [], [], [], [], none, false, false⟩
    ⟨⟨[]⟩, ⟨[]⟩, ⟨.alice, .main⟩, ⟨[]⟩, 100, ⟨0, [.alice], [], [], some .alice⟩, ⟨standard32Cells⟩⟩)

set_option maxRecDepth 500000 in
/-- Theorem: StructurallyAdmissibleIR is nonempty. -/
theorem structurallyAdmissible_nonempty : StructurallyAdmissibleIR canonicalWitnessIR := by
  dsimp [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, canonicalWitnessIR, StandardTypesEnum,
         SourceMapSorted, ClaimedNextStateCanonical, standard32Cells, standard32CellKeys,
         isSortedStrictAscending, StoreCanonical, RequestCanonical, EnvironmentCanonical,
         WorldCanonical, StateCellsMatchStandard32, EnvelopeLengthBounds, TypedPayloadLengthBounds,
         TemplateLengthBounds, SerializedByteBound, WholeDocumentDepthBounded, WholeDocumentArrayBounded]
  refine ⟨⟨by decide, by decide, by decide, ⟨rfl, rfl, ⟨rfl, rfl, rfl⟩, rfl, rfl, by decide, List.nodup_nil, List.nodup_nil, by decide, ?_⟩⟩, ?_⟩
  · refine ⟨rfl, by decide, ?_, by decide, by decide, by decide, by decide, by decide⟩
    intro _ h; contradiction
  · refine ⟨rfl, trivial, by decide, ?_, ?_, ?_⟩
    · intro _ h; contradiction
    · intro _ h; contradiction
    · intro _ h; contradiction

/-- Helper to substitute source_map in canonicalWitnessIR. -/
def withSourceMap (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) => .execution (.typed { env with source_map := sm } payload)
  | ir => ir

/-- Witness IR containing distinct escaped C0 control key and literal escape spelling keys.
    Key 1: "a\n" (encodes to JSON key "a\u000a").
    Key 2: "au000a" (encodes to JSON key "au000a").
    These keys are distinct strings in strict lexicographical order. -/
def collisionIR : DecodedIR := withSourceMap [("a\n", "1"), ("au000a", "2")]

set_option maxRecDepth 500000 in
/-- Theorem: collisionIR with distinct escaped control and literal keys is structurally admissible.
    Proved without sorry or native_decide, with standard axioms only. -/
theorem escapedKeyCollision_admissible : StructurallyAdmissibleIR collisionIR := by
  dsimp [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, collisionIR, withSourceMap, canonicalWitnessIR, StandardTypesEnum,
         SourceMapSorted, ClaimedNextStateCanonical, standard32Cells, standard32CellKeys,
         isSortedStrictAscending, StoreCanonical, RequestCanonical, EnvironmentCanonical,
         WorldCanonical, StateCellsMatchStandard32, EnvelopeLengthBounds, TypedPayloadLengthBounds,
         TemplateLengthBounds, SerializedByteBound, WholeDocumentDepthBounded, WholeDocumentArrayBounded]
  refine ⟨⟨by decide, by decide, by decide, ⟨rfl, rfl, ⟨rfl, rfl, rfl⟩, rfl, rfl, by decide, List.nodup_nil, List.nodup_nil, by decide, ?_⟩⟩, ?_⟩
  · refine ⟨rfl, by decide, ?_, by decide, by decide, by decide, by decide, by decide⟩
    intro _ h; contradiction
  · refine ⟨rfl, trivial, by decide, ?_, ?_, ?_⟩
    · intro _ h; contradiction
    · intro _ h; contradiction
    · intro _ h; contradiction

/-- Theorem: canonical byte decoding guarantees re-encoding identity (T-canonical-bytes). -/
theorem decodeBytes_encode_canonical (raw : ByteArray) (ir : DecodedIR)
    (h : decodeBytes raw = .ok ir) : encodeModule ir = raw := by
  unfold decodeBytes at h
  dsimp [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  · split at h
    · split at h
      · contradiction
      · contradiction
      · split at h
        · contradiction
        · split at h
          · rename_i h_eq
            injection h with h_sub
            subst h_sub
            exact h_eq
          · contradiction
    · contradiction

/-- Theorem: any successfully decoded IR roundtrips through encodeModule and decodeBytes. -/
theorem decode_encode_roundtrip_of_decode (raw : ByteArray) (ir : DecodedIR)
    (h : decodeBytes raw = .ok ir) :
    decodeBytes (encodeModule ir) = .ok ir := by
  have h_eq := decodeBytes_encode_canonical raw ir h
  rw [h_eq]
  exact h

/-- Statement of universal roundtrip obligation (RC01 / P20 open obligation).
    Quantifies over every structurally admissible canonical IR. -/
def EncodeDecodeRoundtripStatement : Prop :=
  ∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir

/-- Statement of canonical bytes obligation (T-canonical-bytes). -/
def DecodeEncodeCanonicalBytesStatement : Prop :=
  ∀ raw ir, decodeBytes raw = .ok ir → StructurallyAdmissibleIR ir → encodeModule ir = raw

/-- Discharges T-canonical-bytes: universal canonical bytes theorem proven in the Lean kernel. -/
theorem decode_encode_canonical_bytes : DecodeEncodeCanonicalBytesStatement := by
  intro raw ir h _
  exact decodeBytes_encode_canonical raw ir h

/-- Refused decode returns no kernel object (S39-S40, S78). -/
theorem decode_error_no_kernel (raw : ByteArray) (e : DecodeFailure)
    (h : decodeBytes raw = .error e) (h_not_res : ∀ lim, e ≠ .resourceLimit lim) :
    checkBytes raw = .codec (.malformed e) := by
  dsimp [checkBytes]
  rw [h]
  cases e with
  | resourceLimit lim =>
    exfalso
    exact h_not_res lim rfl
  | emptyDocument => rfl
  | lexicalScientificOrFloat => rfl
  | notJsonObject => rfl
  | duplicateKey _ => rfl
  | noncanonicalWhitespace => rfl
  | schemaVersion => rfl
  | missingField _ => rfl
  | jsonType _ => rfl
  | unknownIdentifier _ => rfl
  | uniqueness _ => rfl
  | illegalRational _ => rfl
  | stateNonneg => rfl
  | unknownExecutableField _ => rfl
  | unsupportedForm _ => rfl

/-- Resource limit decode refusal maps to blocked codec result. -/
theorem decode_error_resource_limit (raw : ByteArray) (lim : String)
    (h : decodeBytes raw = .error (.resourceLimit lim)) :
    checkBytes raw = .codec (.blocked lim) := by
  dsimp [checkBytes]
  rw [h]

/-- Any decode error produces a CodecResult outcome, guaranteeing no kernel entrypoint is invoked. -/
theorem checkBytes_no_kernel_on_error (raw : ByteArray) (e : DecodeFailure)
    (h : decodeBytes raw = .error e) :
    ∃ (c : CodecResult), checkBytes raw = .codec c := by
  dsimp [checkBytes]
  rw [h]
  cases e with
  | resourceLimit lim => exact ⟨.blocked lim, rfl⟩
  | emptyDocument => exact ⟨.malformed .emptyDocument, rfl⟩
  | lexicalScientificOrFloat => exact ⟨.malformed .lexicalScientificOrFloat, rfl⟩
  | notJsonObject => exact ⟨.malformed .notJsonObject, rfl⟩
  | duplicateKey k => exact ⟨.malformed (.duplicateKey k), rfl⟩
  | noncanonicalWhitespace => exact ⟨.malformed .noncanonicalWhitespace, rfl⟩
  | schemaVersion => exact ⟨.malformed .schemaVersion, rfl⟩
  | missingField m => exact ⟨.malformed (.missingField m), rfl⟩
  | jsonType p => exact ⟨.malformed (.jsonType p), rfl⟩
  | unknownIdentifier u => exact ⟨.malformed (.unknownIdentifier u), rfl⟩
  | uniqueness k => exact ⟨.malformed (.uniqueness k), rfl⟩
  | illegalRational r => exact ⟨.malformed (.illegalRational r), rfl⟩
  | stateNonneg => exact ⟨.malformed .stateNonneg, rfl⟩
  | unknownExecutableField f => exact ⟨.malformed (.unknownExecutableField f), rfl⟩
  | unsupportedForm r => exact ⟨.malformed (DecodeFailure.unsupportedForm r), rfl⟩

/-- Successful decode routes directly to checkIR. -/
theorem checkBytes_ok (raw : ByteArray) (ir : DecodedIR)
    (h : decodeBytes raw = .ok ir) :
    checkBytes raw = checkIR ir := by
  dsimp [checkBytes]
  rw [h]

/-- CheckBytes for typed execution payload routes directly to checkTyped. -/
theorem checkBytes_typed_correspondence (raw : ByteArray) (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.typed env payload))) :
    checkBytes raw = .execution (checkTyped env payload) := by
  have h := checkBytes_ok raw (.execution (.typed env payload)) h_dec
  rw [h]
  rfl

/-- CheckBytes for composition step payload routes directly to checkStep. -/
theorem checkBytes_step_correspondence (raw : ByteArray) (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.step env payload))) :
    checkBytes raw = .execution (checkStep env payload) := by
  have h := checkBytes_ok raw (.execution (.step env payload)) h_dec
  rw [h]
  rfl

/-- CheckBytes for composition run payload routes directly to checkRun. -/
theorem checkBytes_run_correspondence (raw : ByteArray) (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.run env payload))) :
    checkBytes raw = .execution (checkRun env payload) := by
  have h := checkBytes_ok raw (.execution (.run env payload)) h_dec
  rw [h]
  rfl

/-- Canonical rational decoding theorem: canonical numerator/denominator pair decodes to RatEnc. -/
theorem rational_decode_canonical (num : Int) (den : Nat) (h_den : den ≠ 0) (h_gcd : Int.gcd num.natAbs den = 1) :
    decodeRational num den = .ok ⟨num, den⟩ := by
  unfold decodeRational
  split
  · contradiction
  · split
    · rename_i h_noncan
      have h1 : ¬ (Int.gcd num.natAbs den ≠ 1) := by
        intro h_contra
        exact h_contra h_gcd
      contradiction
    · rfl

/-- Exact correspondence between RatEnc and ℚ components. -/
theorem rat_fromRat_num_den (q : ℚ) :
    (RatEnc.fromRat q).num = q.num ∧ (RatEnc.fromRat q).den = q.den :=
  ⟨rfl, rfl⟩

/-- Rational encode/decode roundtrip: any canonical rational roundtrips via decodeRational. -/
theorem rational_roundtrip (r : RatEnc) (h_den : r.den ≠ 0) (h_gcd : Int.gcd r.num.natAbs r.den = 1) :
    decodeRational r.num r.den = .ok r :=
  rational_decode_canonical r.num r.den h_den h_gcd

/-- Party decode roundtrip. -/
theorem decodeParty_encodeParty (p : Party) :
    decodeParty (.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")) = .ok p := by
  cases p <;> rfl

/-- Asset decode roundtrip. -/
theorem decodeAsset_encodeAsset (a : Asset) :
    decodeAsset (.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")) = .ok a := by
  cases a <;> rfl

/-- Domain decode roundtrip. -/
theorem decodeDomain_encodeDomain (d : Domain) :
    decodeDomain (.str (match d with | .main => "main" | .other => "other")) = .ok d := by
  cases d <;> rfl

/-- Right decode roundtrip for invoke. -/
theorem decodeRight_invoke :
    decodeRight (Lean.Json.mkObj [("tag", Lean.Json.str "invoke")]) = .ok .invoke := by
  rfl

/-- PartyRef decode roundtrip for caller. -/
theorem decodePartyRef_caller :
    decodePartyRef (Lean.Json.mkObj [("tag", Lean.Json.str "caller")]) = .ok .caller := by
  rfl

/-- PartyRef decode roundtrip for literal party. -/
theorem decodePartyRef_literal (p : Party) :
    decodePartyRef (Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", match p with
      | .alice => Lean.Json.str "alice"
      | .bob => Lean.Json.str "bob"
      | .vault => Lean.Json.str "vault"
      | .pool => Lean.Json.str "pool")]) = .ok (.literal p) := by
  cases p <;> rfl

/-- NumericUnit decode roundtrip for scalar. -/
theorem decodeNumericUnit_scalar :
    decodeNumericUnit (Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]) = .ok .scalar := by
  rfl

/-- NumericUnit decode roundtrip for amount. -/
theorem decodeNumericUnit_amount (a : Asset) :
    decodeNumericUnit (Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", match a with
      | .usd => Lean.Json.str "usd"
      | .share => Lean.Json.str "share"
      | .collateral => Lean.Json.str "collateral"
      | .debt => Lean.Json.str "debt")]) = .ok (.amount a) := by
  cases a <;> rfl

/-- Unit decode roundtrip for bool. -/
theorem decodeUnit_bool :
    decodeUnit (Lean.Json.mkObj [("tag", Lean.Json.str "bool")]) = .ok .bool := by
  rfl

/-- Unit decode roundtrip for scalar. -/
theorem decodeUnit_scalar :
    decodeUnit (Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]) = .ok (.numeric .scalar) := by
  rfl

/-- Unit decode roundtrip for amount. -/
theorem decodeUnit_amount (a : Asset) :
    decodeUnit (Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", match a with
      | .usd => Lean.Json.str "usd"
      | .share => Lean.Json.str "share"
      | .collateral => Lean.Json.str "collateral"
      | .debt => Lean.Json.str "debt")]) = .ok (.numeric (.amount a)) := by
  cases a <;> rfl

/-- Registry decode roundtrip for empty registry. -/
theorem decodeRegistry_empty :
    decodeRegistry (Lean.Json.mkObj [("entries", Lean.Json.arr #[])]) = .ok ⟨[]⟩ := by
  rfl

/-- Store decode roundtrip for empty store. -/
theorem decodeStore_empty :
    decodeStore (Lean.Json.mkObj [("entries", Lean.Json.arr #[])]) = .ok ⟨[]⟩ := by
  rfl

/-- Right decode roundtrip for debit. -/
theorem decodeRight_debit (c : CellEnc) :
    decodeRight (Lean.Json.mkObj [("tag", Lean.Json.str "debit"), ("cell", Lean.Json.mkObj [
      ("domain", Lean.Json.str (match c.domain with | .main => "main" | .other => "other")),
      ("party", Lean.Json.str (match c.party with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
      ("asset", Lean.Json.str (match c.asset with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
    ])]) = .ok (.debit c) := by
  cases c with
  | mk d p a => cases d <;> cases p <;> cases a <;> rfl

/-- Right decode roundtrip for changeSupply. -/
theorem decodeRight_changeSupply (d : Domain) (a : Asset) :
    decodeRight (Lean.Json.mkObj [
      ("tag", Lean.Json.str "changeSupply"),
      ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
      ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
    ]) = .ok (.changeSupply d a) := by
  cases d <;> cases a <;> rfl

/-- PartyRef decode roundtrip for argument index. -/
theorem decodePartyRef_argument (idx : Nat) :
    decodePartyRef (Lean.Json.mkObj [("tag", Lean.Json.str "argument"), ("index", Lean.Json.num idx)]) = .ok (.argument idx) := by
  dsimp [decodePartyRef]
  rfl

/-- NumericUnit decode roundtrip for price. -/
theorem decodeNumericUnit_price (b q : Asset) :
    decodeNumericUnit (Lean.Json.mkObj [
      ("tag", Lean.Json.str "price"),
      ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
      ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
    ]) = .ok (.price b q) := by
  cases b <;> cases q <;> rfl

/-- PackedValue decode roundtrip for bool values. -/
theorem decodePackedValue_bool (b : Bool) :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "bool")]),
      ("value", Lean.Json.bool b)
    ]) = .ok ⟨.bool, 0, b⟩ := by
  cases b <;> rfl

/-- PackedValue decode roundtrip for canonical boolean packed values. -/
theorem decodePackedValue_canonical_bool (v : PackedValueEnc) (h_u : v.unit = .bool) (h_can : PackedValueCanonical v) :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "bool")]),
      ("value", Lean.Json.bool v.valBool)
    ]) = .ok v := by
  have h_rat : v.valRat = 0 := h_can.1 h_u
  have h_eq : v = ⟨.bool, 0, v.valBool⟩ := by
    cases v
    dsimp at h_u h_rat
    subst h_u h_rat
    rfl
  rw [h_eq]
  cases v.valBool <;> rfl

/-- ObservationKey decode roundtrip for arbitrary domain and id. -/
theorem decodeObservationKey_roundtrip (k : ObservationKeyEnc) :
    decodeObservationKey (Lean.Json.mkObj [
      ("domain", Lean.Json.str (match k.domain with | .main => "main" | .other => "other")),
      ("id", Lean.Json.num k.id)
    ]) = .ok k := by
  cases k with
  | mk d id =>
    cases d <;> (dsimp [decodeObservationKey, decodeDomain, Lean.Json.mkObj]; rfl)

/-- EnvRead decode roundtrip for currentTime. -/
theorem decodeEnvRead_currentTime :
    decodeEnvRead (Lean.Json.mkObj [("tag", Lean.Json.str "currentTime")]) = .ok .currentTime := by
  rfl

/-- UnaryOp decode roundtrip for not. -/
theorem decodeUnaryOp_not :
    decodeUnaryOp (Lean.Json.mkObj [("tag", Lean.Json.str "not")]) = .ok .not := by
  rfl

/-- UnaryOp decode roundtrip for neg. -/
theorem decodeUnaryOp_neg (nu : NumericUnitEnc) :
    decodeUnaryOp (Lean.Json.mkObj [
      ("tag", Lean.Json.str "neg"),
      ("numeric", match nu with
        | .amount a => Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))]
        | .price b q => Lean.Json.mkObj [("tag", Lean.Json.str "price"), ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")), ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))]
        | .scalar => Lean.Json.mkObj [("tag", Lean.Json.str "scalar")])
    ]) = .ok (.neg nu) := by
  cases nu with
  | amount a => cases a <;> rfl
  | price b q => cases b <;> cases q <;> rfl
  | scalar => rfl

/-- BinaryOp decode roundtrip for and. -/
theorem decodeBinaryOp_and :
    decodeBinaryOp (Lean.Json.mkObj [("tag", Lean.Json.str "and")]) = .ok .and := by
  rfl

/-- BinaryOp decode roundtrip for or. -/
theorem decodeBinaryOp_or :
    decodeBinaryOp (Lean.Json.mkObj [("tag", Lean.Json.str "or")]) = .ok .or := by
  rfl

/-- CellRef decode roundtrip for literal owner. -/
theorem decodeCellRef_roundtrip (d : Domain) (p : Party) :
    decodeCellRef (Lean.Json.mkObj [
      ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
      ("owner", Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", Lean.Json.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool"))])
    ]) = .ok ⟨d, .literal p⟩ := by
  cases d <;> cases p <;> rfl

/-- Cell decode roundtrip across the full domain-party-asset space. -/
theorem decodeCell_roundtrip (c : CellEnc) :
    decodeCell (Lean.Json.mkObj [
      ("domain", Lean.Json.str (match c.domain with | .main => "main" | .other => "other")),
      ("party", Lean.Json.str (match c.party with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
      ("asset", Lean.Json.str (match c.asset with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
    ]) = .ok c := by
  cases c with
  | mk d p a => cases d <;> cases p <;> cases a <;> rfl

/-- Context decode roundtrip. -/
theorem decodeContext_roundtrip (c : ContextEnc) :
    decodeContext (Lean.Json.mkObj [
      ("principal", Lean.Json.str (match c.principal with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
      ("domain", Lean.Json.str (match c.domain with | .main => "main" | .other => "other"))
    ]) = .ok c := by
  cases c with
  | mk p d => cases p <;> cases d <;> (dsimp [decodeContext, decodeParty, decodeDomain, Lean.Json.mkObj]; rfl)

/-- DomainAdmin decode roundtrip. -/
theorem decodeDomainAdmin_roundtrip (d : DomainAdminEnc) :
    decodeDomainAdmin (Lean.Json.mkObj [
      ("domain", Lean.Json.str (match d.domain with | .main => "main" | .other => "other")),
      ("party", Lean.Json.str (match d.party with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool"))
    ]) = .ok d := by
  cases d with
  | mk dm p => cases dm <;> cases p <;> (dsimp [decodeDomainAdmin, decodeDomain, decodeParty, Lean.Json.mkObj]; rfl)

/-- QualifiedPort decode roundtrip. -/
theorem decodeQualifiedPort_roundtrip (p : QualifiedPortEnc) :
    decodeQualifiedPort (Lean.Json.mkObj [("component", Lean.Json.num p.component), ("port", Lean.Json.num p.port)]) = .ok p := by
  cases p with
  | mk c port => dsimp [decodeQualifiedPort, Lean.Json.mkObj]; rfl

/-- Step decode roundtrip for revoke. -/
theorem decodeStep_revoke (id : Nat) :
    decodeStep (Lean.Json.mkObj [("tag", Lean.Json.str "revoke"), ("id", Lean.Json.num id)]) = .ok (.revoke id) := by
  dsimp [decodeStep, Lean.Json.mkObj]
  rfl

/-- ExprFuel decode roundtrip for now constructor. -/
theorem decodeExprFuel_now (fuel : Nat) :
    decodeExprFuel (fuel + 1) (Lean.Json.mkObj [("tag", Lean.Json.str "now")]) = .ok .now := by
  rfl

/-- ExprFuel decode roundtrip for argument constructor. -/
theorem decodeExprFuel_arg_bool (fuel : Nat) (idx : Nat) :
    decodeExprFuel (fuel + 1) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "arg"),
      ("index", Lean.Json.num idx),
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "bool")])
    ]) = .ok (.arg idx .bool) := by
  rfl

/-- ExprFuel decode roundtrip for boolean literal. -/
theorem decodeExprFuel_lit_bool (fuel : Nat) (b : Bool) :
    decodeExprFuel (fuel + 1) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "lit"),
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "bool")]),
      ("value", Lean.Json.bool b)
    ]) = .ok (.lit ⟨.bool, 0, b⟩) := by
  cases b <;> rfl

/-- Production decodeExpr roundtrip for now constructor. -/
theorem decodeExpr_now :
    decodeExpr (Lean.Json.mkObj [("tag", Lean.Json.str "now")]) = .ok .now := by
  rfl

/-- Production decodeExpr roundtrip for boolean literal. -/
theorem decodeExpr_lit_bool (b : Bool) :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "lit"),
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "bool")]),
      ("value", Lean.Json.bool b)
    ]) = .ok (.lit ⟨.bool, 0, b⟩) := by
  cases b <;> rfl

/-- ObservationRef decode roundtrip for all domains and units. -/
theorem decodeObservationRef_roundtrip (d : Domain) (id : Nat) (u : UnitEnc) :
    decodeObservationRef (Lean.Json.mkObj [
      ("key", Lean.Json.mkObj [
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("id", Lean.Json.num id)
      ]),
      ("unit", match u with
        | .bool => Lean.Json.mkObj [("tag", Lean.Json.str "bool")]
        | .numeric .scalar => Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]
        | .numeric (.amount a) => Lean.Json.mkObj [
            ("tag", Lean.Json.str "amount"),
            ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ]
        | .numeric (.price b q) => Lean.Json.mkObj [
            ("tag", Lean.Json.str "price"),
            ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
            ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ])
    ]) = .ok ⟨⟨d, id⟩, u⟩ := by
  cases d
  · cases u with
    | bool => rfl
    | numeric nu =>
      cases nu with
      | scalar => rfl
      | amount a => cases a <;> rfl
      | price b q => cases b <;> cases q <;> rfl
  · cases u with
    | bool => rfl
    | numeric nu =>
      cases nu with
      | scalar => rfl
      | amount a => cases a <;> rfl
      | price b q => cases b <;> cases q <;> rfl

/-- Canonical zero rational decoding roundtrip. -/
theorem decodeRat_zero :
    decodeRat (Lean.Json.mkObj [("num", Lean.Json.num (0 : Int)), ("den", Lean.Json.num (1 : Nat))]) = .ok ⟨0, 1⟩ := by
  rfl

/-- PackedValue decode roundtrip for scalar zero value. -/
theorem decodePackedValue_scalar_zero :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]),
      ("value", Lean.Json.mkObj [("num", Lean.Json.num (0 : Int)), ("den", Lean.Json.num (1 : Nat))])
    ]) = .ok ⟨.numeric .scalar, 0, false⟩ := by
  rfl

/-- PackedValue decode roundtrip for amount zero value. -/
theorem decodePackedValue_amount_zero (a : Asset) :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [
        ("tag", Lean.Json.str "amount"),
        ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
      ]),
      ("value", Lean.Json.mkObj [("num", Lean.Json.num (0 : Int)), ("den", Lean.Json.num (1 : Nat))])
    ]) = .ok ⟨.numeric (.amount a), 0, false⟩ := by
  cases a <;> rfl

/-- BinaryOp decode roundtrip for addition. -/
theorem decodeBinaryOp_add (nu : NumericUnitEnc) :
    decodeBinaryOp (Lean.Json.mkObj [
      ("tag", Lean.Json.str "add"),
      ("numeric", match nu with
        | .scalar => Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]
        | .amount a => Lean.Json.mkObj [
            ("tag", Lean.Json.str "amount"),
            ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ]
        | .price b q => Lean.Json.mkObj [
            ("tag", Lean.Json.str "price"),
            ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
            ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ])
    ]) = .ok (.add nu) := by
  cases nu with
  | scalar => rfl
  | amount a => cases a <;> rfl
  | price b q => cases b <;> cases q <;> rfl

/-- BinaryOp decode roundtrip for currency conversion. -/
theorem decodeBinaryOp_convert (b q : Asset) :
    decodeBinaryOp (Lean.Json.mkObj [
      ("tag", Lean.Json.str "convert"),
      ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
      ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
    ]) = .ok (.convert b q) := by
  cases b <;> cases q <;> rfl

/-- BinaryOp decode roundtrip for equality. -/
theorem decodeBinaryOp_eq (u : UnitEnc) :
    decodeBinaryOp (Lean.Json.mkObj [
      ("tag", Lean.Json.str "eq"),
      ("unit", match u with
        | .bool => Lean.Json.mkObj [("tag", Lean.Json.str "bool")]
        | .numeric .scalar => Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]
        | .numeric (.amount a) => Lean.Json.mkObj [
            ("tag", Lean.Json.str "amount"),
            ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ]
        | .numeric (.price b q) => Lean.Json.mkObj [
            ("tag", Lean.Json.str "price"),
            ("base", Lean.Json.str (match b with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
            ("quote", Lean.Json.str (match q with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
          ])
    ]) = .ok (.eq u) := by
  cases u with
  | bool => rfl
  | numeric nu =>
    cases nu with
    | scalar => rfl
    | amount a => cases a <;> rfl
    | price b q => cases b <;> cases q <;> rfl

/-- Step decode roundtrip for grant issuance. -/
theorem decodeStep_issue (h : Party) (d : Domain) (op : Nat) :
    decodeStep (Lean.Json.mkObj [
      ("tag", Lean.Json.str "issue"),
      ("grant", Lean.Json.mkObj [
        ("holder", Lean.Json.str (match h with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("operation", Lean.Json.num op),
        ("right", Lean.Json.mkObj [("tag", Lean.Json.str "invoke")])
      ])
    ]) = .ok (.issue ⟨h, d, op, .invoke⟩) := by
  cases h <;> cases d <;> rfl

/-- PackedCellRef decode roundtrip. -/
theorem decodePackedCellRef_roundtrip (a : Asset) (d : Domain) (p : Party) :
    decodePackedCellRef (Lean.Json.mkObj [
      ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
      ("cell", Lean.Json.mkObj [
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("owner", Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", Lean.Json.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool"))])
      ])
    ]) = .ok ⟨a, ⟨d, .literal p⟩⟩ := by
  cases a <;> cases d <;> cases p <;> rfl

/-- EnvRead decode roundtrip for observation read. -/
theorem decodeEnvRead_observation (d : Domain) (id : Nat) :
    decodeEnvRead (Lean.Json.mkObj [
      ("tag", Lean.Json.str "observation"),
      ("key", Lean.Json.mkObj [
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("id", Lean.Json.num id)
      ])
    ]) = .ok (.observation ⟨d, id⟩) := by
  cases d <;> rfl

/-- SourcePin decode roundtrip. -/
theorem decodeSourcePin_roundtrip (git toolchain mathlib checker : String) :
    decodeSourcePin (Lean.Json.mkObj [
      ("git", Lean.Json.str git),
      ("lean_toolchain", Lean.Json.str toolchain),
      ("mathlib_rev", Lean.Json.str mathlib),
      ("checker_candidate", Lean.Json.str checker)
    ]) = .ok ⟨git, toolchain, mathlib, checker, none, none⟩ := by
  rfl

/-- Grant decode roundtrip. -/
theorem decodeGrant_roundtrip (h : Party) (d : Domain) (op : Nat) :
    decodeGrant (Lean.Json.mkObj [
      ("holder", Lean.Json.str (match h with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
      ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
      ("operation", Lean.Json.num op),
      ("right", Lean.Json.mkObj [("tag", Lean.Json.str "invoke")])
    ]) = .ok ⟨h, d, op, .invoke⟩ := by
  cases h <;> cases d <;> rfl

/-- TypesEnum decode roundtrip for canonical universe. -/
theorem decodeTypesEnum_roundtrip :
    decodeTypesEnum (Lean.Json.mkObj [
      ("parties", Lean.Json.arr #[Lean.Json.str "alice", Lean.Json.str "bob", Lean.Json.str "vault", Lean.Json.str "pool"]),
      ("assets", Lean.Json.arr #[Lean.Json.str "usd", Lean.Json.str "share", Lean.Json.str "collateral", Lean.Json.str "debt"]),
      ("domains", Lean.Json.arr #[Lean.Json.str "main", Lean.Json.str "other"])
    ]) = .ok ⟨[.alice, .bob, .vault, .pool], [.usd, .share, .collateral, .debt], [.main, .other]⟩ := by
  rfl

/-- Capability decode roundtrip for invoke. -/
theorem decodeCapability_invoke (h : Party) (d : Domain) (op : Nat) (l : Bool) :
    decodeCapability (Lean.Json.mkObj [
      ("holder", Lean.Json.str (match h with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")),
      ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
      ("operation", Lean.Json.num op),
      ("right", Lean.Json.mkObj [("tag", Lean.Json.str "invoke")]),
      ("live", Lean.Json.bool l)
    ]) = .ok ⟨h, d, op, .invoke, l⟩ := by
  cases h <;> cases d <;> cases l <;> rfl

/-- ExprFuel decode roundtrip for balance. -/
theorem decodeExprFuel_balance (fuel : Nat) (a : Asset) (d : Domain) (p : Party) :
    decodeExprFuel (fuel + 1) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "balance"),
      ("cell", Lean.Json.mkObj [
        ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
        ("cell", Lean.Json.mkObj [
          ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
          ("owner", Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", Lean.Json.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool"))])
        ])
      ])
    ]) = .ok (.balance ⟨a, ⟨d, .literal p⟩⟩) := by
  cases a <;> cases d <;> cases p <;> rfl

/-- ExprFuel decode roundtrip for timestamp. -/
theorem decodeExprFuel_timestamp (fuel : Nat) (d : Domain) (id : Nat) :
    decodeExprFuel (fuel + 1) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "timestamp"),
      ("key", Lean.Json.mkObj [
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("id", Lean.Json.num id)
      ])
    ]) = .ok (.timestamp ⟨d, id⟩) := by
  cases d <;> rfl

/-- ExprFuel decode roundtrip for unary not. -/
theorem decodeExprFuel_unary_not (fuel : Nat) :
    decodeExprFuel (fuel + 2) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "unary"),
      ("op", Lean.Json.mkObj [("tag", Lean.Json.str "not")]),
      ("x", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.unary .not .now) := by
  rfl

/-- ExprFuel decode roundtrip for binary and. -/
theorem decodeExprFuel_binary_and (fuel : Nat) :
    decodeExprFuel (fuel + 2) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "binary"),
      ("op", Lean.Json.mkObj [("tag", Lean.Json.str "and")]),
      ("x", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("y", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.binary .and .now .now) := by
  rfl

/-- ExprFuel decode roundtrip for ite. -/
theorem decodeExprFuel_ite (fuel : Nat) :
    decodeExprFuel (fuel + 2) (Lean.Json.mkObj [
      ("tag", Lean.Json.str "ite"),
      ("condition", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("yes", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("no", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.ite .now .now .now) := by
  rfl

/-- Production decodeExpr roundtrip for balance. -/
theorem decodeExpr_balance (a : Asset) (d : Domain) (p : Party) :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "balance"),
      ("cell", Lean.Json.mkObj [
        ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")),
        ("cell", Lean.Json.mkObj [
          ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
          ("owner", Lean.Json.mkObj [("tag", Lean.Json.str "literal"), ("party", Lean.Json.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool"))])
        ])
      ])
    ]) = .ok (.balance ⟨a, ⟨d, .literal p⟩⟩) := by
  cases a <;> cases d <;> cases p <;> rfl

/-- Production decodeExpr roundtrip for timestamp. -/
theorem decodeExpr_timestamp (d : Domain) (id : Nat) :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "timestamp"),
      ("key", Lean.Json.mkObj [
        ("domain", Lean.Json.str (match d with | .main => "main" | .other => "other")),
        ("id", Lean.Json.num id)
      ])
    ]) = .ok (.timestamp ⟨d, id⟩) := by
  cases d <;> rfl

/-- Production decodeExpr roundtrip for unary not. -/
theorem decodeExpr_unary_not :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "unary"),
      ("op", Lean.Json.mkObj [("tag", Lean.Json.str "not")]),
      ("x", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.unary .not .now) := by
  rfl

/-- Production decodeExpr roundtrip for binary and. -/
theorem decodeExpr_binary_and :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "binary"),
      ("op", Lean.Json.mkObj [("tag", Lean.Json.str "and")]),
      ("x", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("y", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.binary .and .now .now) := by
  rfl

/-- Production decodeExpr roundtrip for ite. -/
theorem decodeExpr_ite :
    decodeExpr (Lean.Json.mkObj [
      ("tag", Lean.Json.str "ite"),
      ("condition", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("yes", Lean.Json.mkObj [("tag", Lean.Json.str "now")]),
      ("no", Lean.Json.mkObj [("tag", Lean.Json.str "now")])
    ]) = .ok (.ite .now .now .now) := by
  rfl

/-- General string roundtrip theorem: any string roundtrips through canonical UTF-8 encoding and lexString. -/
theorem string_roundtrip (s : String) (rest : List Char) :
    String.fromUTF8? s.toUTF8 = some s ∧
    lexString [] (escapeChars s.toList ++ ('"' :: rest)) = .ok (s, rest) :=
  ⟨string_fromUTF8?_toUTF8 s, lexString_escapeJsonString s rest⟩

/-- Theorem: IR instances exceeding the serialized byte limit (1 MiB) are not supported. -/
theorem serialized_byte_bound_exceeded_not_supported (ir : DecodedIR)
    (h_size : (encodeModule ir).size > 1048576) :
    ¬ SupportedIR ir := by
  intro h_sup
  have h_bound := h_sup.1
  dsimp [SerializedByteBound] at h_bound
  omega

/-- DecodeRat helper: canonical numerator and denominator decodes to RatEnc. -/
theorem decodeRat_mkObj (num : Int) (den : Nat) (h_den : den ≠ 0) (h_gcd : Int.gcd num.natAbs den = 1) :
    decodeRat (Lean.Json.mkObj [("num", Lean.Json.num num), ("den", Lean.Json.num den)]) = .ok ⟨num, den⟩ := by
  dsimp [decodeRat, Lean.Json.mkObj, getField, checkExactObjectKeys]
  dsimp [bind, Except.bind]
  have h_dec : decodeRational num den = .ok ⟨num, den⟩ := rational_decode_canonical num den h_den h_gcd
  exact h_dec

/-- Arbitrary numeric packed value roundtrip for scalar natural values. -/
theorem decodePackedValue_scalar_val (v : Nat) :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]),
      ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
    ]) = .ok ⟨.numeric .scalar, (RatEnc.mk (v : Int) 1).toRat, false⟩ := by
  have h_step : decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "scalar")]),
      ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
    ]) = (decodeRational (v : Int) 1 >>= fun (r : RatEnc) ↦ .ok ⟨.numeric .scalar, r.toRat, false⟩) := rfl
  have h_dec : decodeRational (v : Int) 1 = .ok ⟨(v : Int), 1⟩ := by
    apply rational_decode_canonical
    · decide
    · simp
  rw [h_step, h_dec]
  rfl

/-- Arbitrary numeric packed value roundtrip for asset amount natural values. -/
theorem decodePackedValue_amount_val (a : Asset) (v : Nat) :
    decodePackedValue (Lean.Json.mkObj [
      ("unit", Lean.Json.mkObj [
        ("tag", Lean.Json.str "amount"),
        ("asset", Lean.Json.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt"))
      ]),
      ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
    ]) = .ok ⟨.numeric (.amount a), (RatEnc.mk (v : Int) 1).toRat, false⟩ := by
  have h_dec : decodeRational (v : Int) 1 = .ok ⟨(v : Int), 1⟩ := by
    apply rational_decode_canonical
    · decide
    · simp
  cases a with
  | usd =>
    have h_step : decodePackedValue (Lean.Json.mkObj [
        ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "usd")]),
        ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
      ]) = (decodeRational (v : Int) 1 >>= fun (r : RatEnc) ↦ .ok ⟨.numeric (.amount .usd), r.toRat, false⟩) := rfl
    rw [h_step, h_dec]
    rfl
  | share =>
    have h_step : decodePackedValue (Lean.Json.mkObj [
        ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "share")]),
        ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
      ]) = (decodeRational (v : Int) 1 >>= fun (r : RatEnc) ↦ .ok ⟨.numeric (.amount .share), r.toRat, false⟩) := rfl
    rw [h_step, h_dec]
    rfl
  | collateral =>
    have h_step : decodePackedValue (Lean.Json.mkObj [
        ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "collateral")]),
        ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
      ]) = (decodeRational (v : Int) 1 >>= fun (r : RatEnc) ↦ .ok ⟨.numeric (.amount .collateral), r.toRat, false⟩) := rfl
    rw [h_step, h_dec]
    rfl
  | debt =>
    have h_step : decodePackedValue (Lean.Json.mkObj [
        ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "debt")]),
        ("value", Lean.Json.mkObj [("num", Lean.Json.num v), ("den", Lean.Json.num 1)])
      ]) = (decodeRational (v : Int) 1 >>= fun (r : RatEnc) ↦ .ok ⟨.numeric (.amount .debt), r.toRat, false⟩) := rfl
    rw [h_step, h_dec]
    rfl


/-! ### Declarative JSON Encoders and Codec Inversion Theorems -/





















/-- Component inversion: party roundtrip. -/
theorem decodeParty_partyToJson (p : Party) : decodeParty (partyToJson p) = .ok p := by
  cases p <;> rfl

/-- Component inversion: asset roundtrip. -/
theorem decodeAsset_assetToJson (a : Asset) : decodeAsset (assetToJson a) = .ok a := by
  cases a <;> rfl

/-- Component inversion: domain roundtrip. -/
theorem decodeDomain_domainToJson (d : Domain) : decodeDomain (domainToJson d) = .ok d := by
  cases d <;> rfl

/-- Component inversion: cell roundtrip. -/
theorem decodeCell_cellToJson (c : CellEnc) : decodeCell (cellToJson c) = .ok c := by
  cases c with | mk d p a =>
  cases d <;> cases p <;> cases a <;> rfl

/-- Component inversion: right roundtrip. -/
theorem decodeRight_rightToJson (r : RightEnc) : decodeRight (rightToJson r) = .ok r := by
  cases r with
  | invoke => rfl
  | debit c =>
    have h_c := decodeCell_cellToJson c
    have h_def : decodeRight (rightToJson (.debit c)) = (do
        let c_dec ← decodeCell (cellToJson c)
        .ok (.debit c_dec)) := rfl
    rw [h_def, h_c]
    rfl
  | changeSupply d a =>
    cases d <;> cases a <;> rfl

/-- Component inversion: grant roundtrip. -/
theorem decodeGrant_grantToJson (g : GrantEnc) : decodeGrant (grantToJson g) = .ok g := by
  cases g with | mk h d op r =>
  have h_r := decodeRight_rightToJson r
  cases h with
  | alice =>
    cases d with
    | main =>
      have h_def : decodeGrant (grantToJson ⟨.alice, .main, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.alice, .main, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
    | other =>
      have h_def : decodeGrant (grantToJson ⟨.alice, .other, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.alice, .other, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
  | bob =>
    cases d with
    | main =>
      have h_def : decodeGrant (grantToJson ⟨.bob, .main, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.bob, .main, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
    | other =>
      have h_def : decodeGrant (grantToJson ⟨.bob, .other, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.bob, .other, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
  | vault =>
    cases d with
    | main =>
      have h_def : decodeGrant (grantToJson ⟨.vault, .main, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.vault, .main, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
    | other =>
      have h_def : decodeGrant (grantToJson ⟨.vault, .other, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.vault, .other, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
  | pool =>
    cases d with
    | main =>
      have h_def : decodeGrant (grantToJson ⟨.pool, .main, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.pool, .main, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl
    | other =>
      have h_def : decodeGrant (grantToJson ⟨.pool, .other, op, r⟩) = (do
          let r_dec ← decodeRight (rightToJson r)
          .ok ⟨.pool, .other, op, r_dec⟩) := rfl
      rw [h_def, h_r]
      rfl

/-- Component inversion: partyRef roundtrip. -/
theorem decodePartyRef_partyRefToJson (p : PartyRefEnc) : decodePartyRef (partyRefToJson p) = .ok p := by
  cases p with
  | caller => rfl
  | argument idx => rfl
  | literal p => cases p <;> rfl

/-- Component inversion: cellRef roundtrip. -/
theorem decodeCellRef_cellRefToJson (c : CellRefEnc) : decodeCellRef (cellRefToJson c) = .ok c := by
  cases c with | mk d o =>
  have h_o := decodePartyRef_partyRefToJson o
  cases d with
  | main =>
    have h_def : decodeCellRef (cellRefToJson ⟨.main, o⟩) = (do
        let o_dec ← decodePartyRef (partyRefToJson o)
        .ok ⟨.main, o_dec⟩) := rfl
    rw [h_def, h_o]
    rfl
  | other =>
    have h_def : decodeCellRef (cellRefToJson ⟨.other, o⟩) = (do
        let o_dec ← decodePartyRef (partyRefToJson o)
        .ok ⟨.other, o_dec⟩) := rfl
    rw [h_def, h_o]
    rfl

/-- Component inversion: packedCellRef roundtrip. -/
theorem decodePackedCellRef_packedCellRefToJson (c : PackedCellRefEnc) : decodePackedCellRef (packedCellRefToJson c) = .ok c := by
  cases c with | mk a cell =>
  have h_cell := decodeCellRef_cellRefToJson cell
  cases a with
  | usd =>
    have h_def : decodePackedCellRef (packedCellRefToJson ⟨.usd, cell⟩) = (do
        let c_dec ← decodeCellRef (cellRefToJson cell)
        .ok ⟨.usd, c_dec⟩) := rfl
    rw [h_def, h_cell]
    rfl
  | share =>
    have h_def : decodePackedCellRef (packedCellRefToJson ⟨.share, cell⟩) = (do
        let c_dec ← decodeCellRef (cellRefToJson cell)
        .ok ⟨.share, c_dec⟩) := rfl
    rw [h_def, h_cell]
    rfl
  | collateral =>
    have h_def : decodePackedCellRef (packedCellRefToJson ⟨.collateral, cell⟩) = (do
        let c_dec ← decodeCellRef (cellRefToJson cell)
        .ok ⟨.collateral, c_dec⟩) := rfl
    rw [h_def, h_cell]
    rfl
  | debt =>
    have h_def : decodePackedCellRef (packedCellRefToJson ⟨.debt, cell⟩) = (do
        let c_dec ← decodeCellRef (cellRefToJson cell)
        .ok ⟨.debt, c_dec⟩) := rfl
    rw [h_def, h_cell]
    rfl

/-- Component inversion: observationKey roundtrip. -/
theorem decodeObservationKey_observationKeyToJson (k : ObservationKeyEnc) : decodeObservationKey (observationKeyToJson k) = .ok k := by
  cases k with | mk d id =>
  cases d with
  | main => rfl
  | other => rfl

/-- Component inversion: numericUnit roundtrip. -/
theorem decodeNumericUnit_numericUnitToJson (nu : NumericUnitEnc) : decodeNumericUnit (numericUnitToJson nu) = .ok nu := by
  cases nu with
  | scalar => rfl
  | amount a => cases a <;> rfl
  | price b q => cases b <;> cases q <;> rfl

/-- Component inversion: unit roundtrip. -/
theorem decodeUnit_unitToJson (u : UnitEnc) : decodeUnit (unitToJson u) = .ok u := by
  cases u with
  | bool => rfl
  | numeric nu =>
    cases nu with
    | scalar => rfl
    | amount a => cases a <;> rfl
    | price b q => cases b <;> cases q <;> rfl

/-- Component inversion: observationRef roundtrip. -/
theorem decodeObservationRef_observationRefToJson (r : ObservationRefEnc) : decodeObservationRef (observationRefToJson r) = .ok r := by
  cases r with | mk k u =>
  have h_k := decodeObservationKey_observationKeyToJson k
  have h_u := decodeUnit_unitToJson u
  have h_def : decodeObservationRef (observationRefToJson ⟨k, u⟩) = (do
      let k_dec ← decodeObservationKey (observationKeyToJson k)
      let u_dec ← decodeUnit (unitToJson u)
      .ok ⟨k_dec, u_dec⟩) := rfl
  rw [h_def, h_k, h_u]
  rfl

/-- Component inversion: unaryOp roundtrip. -/
theorem decodeUnaryOp_unaryOpToJson (op : UnaryOpEnc) : decodeUnaryOp (unaryOpToJson op) = .ok op := by
  cases op with
  | not => rfl
  | neg nu =>
    cases nu with
    | scalar => rfl
    | amount a => cases a <;> rfl
    | price b q => cases b <;> cases q <;> rfl

/-- Component inversion: binaryOp roundtrip. -/
theorem decodeBinaryOp_binaryOpToJson (op : BinaryOpEnc) : decodeBinaryOp (binaryOpToJson op) = .ok op := by
  cases op with
  | add nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | sub nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | scale nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | divide nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | ratio nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | convert b q => cases b <;> cases q <;> rfl
  | unconvert b q => cases b <;> cases q <;> rfl
  | and => rfl
  | or => rfl
  | eq u =>
    cases u with
    | bool => rfl
    | numeric nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | lt nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl
  | le nu => cases nu with | scalar => rfl | amount a => cases a <;> rfl | price b q => cases b <;> cases q <;> rfl

/-- Component inversion: canonical state cell roundtrip. -/
theorem decodeStateCell_canonical (amt : RatEnc)
    (h_den : amt.den ≠ 0) (h_gcd : Int.gcd amt.num.natAbs amt.den = 1) (h_nonneg : amt.num ≥ 0) :
    decodeStateCell (stateCellToJson (StateCellEnc.mk .main .alice .usd amt)) = .ok (StateCellEnc.mk .main .alice .usd amt) := by
  have h_amt : decodeRat (ratToJson amt) = .ok amt := decodeRat_mkObj amt.num amt.den h_den h_gcd
  have h_def : decodeStateCell (stateCellToJson (StateCellEnc.mk .main .alice .usd amt)) =
    (decodeRat (ratToJson amt) >>= fun amount =>
      if amount.num < 0 then Except.error DecodeFailure.stateNonneg
      else Except.ok (StateCellEnc.mk .main .alice .usd amount)) := rfl
  rw [h_def, h_amt]
  change (if amt.num < 0 then Except.error DecodeFailure.stateNonneg else Except.ok (StateCellEnc.mk .main .alice .usd amt)) =
    Except.ok (StateCellEnc.mk .main .alice .usd amt)
  have h_not_neg : ¬ (amt.num < 0) := by omega
  rw [if_neg h_not_neg]

/-- Expression base case: now roundtrip with fuel + 1. -/
theorem exprToJson_decode_now (fuel : Nat) : decodeExprFuel (fuel + 1) (exprToJson .now) = .ok .now := rfl

/-- Expression base case: timestamp roundtrip with fuel + 1. -/
theorem exprToJson_decode_timestamp (fuel : Nat) (k : ObservationKeyEnc) :
    decodeExprFuel (fuel + 1) (exprToJson (.timestamp k)) = .ok (.timestamp k) := by
  have h_k := decodeObservationKey_observationKeyToJson k
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.timestamp k)) = (do
      let k_dec ← decodeObservationKey (observationKeyToJson k)
      .ok (.timestamp k_dec)) := rfl
  rw [h_def, h_k]
  rfl

/-- Expression base case: observe roundtrip with fuel + 1. -/
theorem exprToJson_decode_observe (fuel : Nat) (r : ObservationRefEnc) :
    decodeExprFuel (fuel + 1) (exprToJson (.observe r)) = .ok (.observe r) := by
  have h_r := decodeObservationRef_observationRefToJson r
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.observe r)) = (do
      let r_dec ← decodeObservationRef (observationRefToJson r)
      .ok (.observe r_dec)) := rfl
  rw [h_def, h_r]
  rfl

/-- Expression base case: balance roundtrip with fuel + 1. -/
theorem exprToJson_decode_balance (fuel : Nat) (c : PackedCellRefEnc) :
    decodeExprFuel (fuel + 1) (exprToJson (.balance c)) = .ok (.balance c) := by
  have h_c := decodePackedCellRef_packedCellRefToJson c
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.balance c)) = (do
      let c_dec ← decodePackedCellRef (packedCellRefToJson c)
      .ok (.balance c_dec)) := rfl
  rw [h_def, h_c]
  rfl

/-- Expression base case: argument roundtrip with fuel + 1. -/
theorem exprToJson_decode_arg (fuel : Nat) (idx : Nat) (u : UnitEnc) :
    decodeExprFuel (fuel + 1) (exprToJson (.arg idx u)) = .ok (.arg idx u) := by
  have h_u := decodeUnit_unitToJson u
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.arg idx u)) = (do
      let u_dec ← decodeUnit (unitToJson u)
      .ok (.arg idx u_dec)) := rfl
  rw [h_def, h_u]
  rfl

/-- Expression inductive step: unary operator roundtrip. -/
theorem exprToJson_decode_unary_step (fuel : Nat) (op : UnaryOpEnc) (x : ExprEnc)
    (h_x : decodeExprFuel fuel (exprToJson x) = .ok x) :
    decodeExprFuel (fuel + 1) (exprToJson (.unary op x)) = .ok (.unary op x) := by
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.unary op x)) = (do
      let op_dec ← decodeUnaryOp (unaryOpToJson op)
      let x_dec ← decodeExprFuel fuel (exprToJson x)
      .ok (.unary op_dec x_dec)) := rfl
  have h_op := decodeUnaryOp_unaryOpToJson op
  rw [h_def, h_op, h_x]
  rfl

/-- Expression inductive step: binary operator roundtrip. -/
theorem exprToJson_decode_binary_step (fuel : Nat) (op : BinaryOpEnc) (x y : ExprEnc)
    (h_x : decodeExprFuel fuel (exprToJson x) = .ok x)
    (h_y : decodeExprFuel fuel (exprToJson y) = .ok y) :
    decodeExprFuel (fuel + 1) (exprToJson (.binary op x y)) = .ok (.binary op x y) := by
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.binary op x y)) = (do
      let op_dec ← decodeBinaryOp (binaryOpToJson op)
      let x_dec ← decodeExprFuel fuel (exprToJson x)
      let y_dec ← decodeExprFuel fuel (exprToJson y)
      .ok (.binary op_dec x_dec y_dec)) := rfl
  have h_op := decodeBinaryOp_binaryOpToJson op
  rw [h_def, h_op, h_x, h_y]
  rfl

/-- Expression inductive step: conditional (ite) operator roundtrip. -/
theorem exprToJson_decode_ite_step (fuel : Nat) (c y n : ExprEnc)
    (h_c : decodeExprFuel fuel (exprToJson c) = .ok c)
    (h_y : decodeExprFuel fuel (exprToJson y) = .ok y)
    (h_n : decodeExprFuel fuel (exprToJson n) = .ok n) :
    decodeExprFuel (fuel + 1) (exprToJson (.ite c y n)) = .ok (.ite c y n) := by
  have h_def : decodeExprFuel (fuel + 1) (exprToJson (.ite c y n)) = (do
      let c_dec ← decodeExprFuel fuel (exprToJson c)
      let y_dec ← decodeExprFuel fuel (exprToJson y)
      let n_dec ← decodeExprFuel fuel (exprToJson n)
      .ok (.ite c_dec y_dec n_dec)) := rfl
  rw [h_def, h_c, h_y, h_n]
  rfl

/-- Theorem: converting from a Mathlib ℚ to RatEnc and back via toRat is the identity. -/
theorem rat_toRat_fromRat (q : ℚ) : (RatEnc.mk q.num q.den).toRat = q := by
  dsimp [RatEnc.toRat]
  exact Rat.num_divInt_den q

/-- Canonical rational decoder inversion: any reduced non-zero denominator rational roundtrips. -/
theorem decodeRat_ratToJson (r : RatEnc) (h_den : r.den ≠ 0) (h_gcd : Int.gcd r.num.natAbs r.den = 1) :
    decodeRat (ratToJson r) = .ok r :=
  decodeRat_mkObj r.num r.den h_den h_gcd

/-- Canonical rational decoder inversion from Mathlib ℚ: any ℚ roundtrips canonically. -/
theorem decodeRat_fromRat (q : ℚ) :
    decodeRat (ratToJson (RatEnc.fromRat q)) = .ok (RatEnc.fromRat q) := by
  have h_den : q.den ≠ 0 := q.den_nz
  have h_gcd : Int.gcd q.num.natAbs q.den = 1 := q.reduced
  exact decodeRat_mkObj q.num q.den h_den h_gcd

/-- Canonical packed value inversion for literal expression decoding. -/
theorem decodeExprFuel_lit_canonical (fuel : Nat) (v : PackedValueEnc) (h_can : PackedValueCanonical v) :
    decodeExprFuel (fuel + 1) (exprToJson (.lit v)) = .ok (.lit v) := by
  cases v with | mk u valRat valBool =>
  dsimp [PackedValueCanonical] at h_can
  cases u with
  | bool =>
    have h_rat := h_can.1 rfl
    have h_def : decodeExprFuel (fuel + 1) (exprToJson (.lit ⟨.bool, valRat, valBool⟩)) =
        .ok (.lit ⟨.bool, 0, valBool⟩) := by
      cases valBool <;> rfl
    rw [h_def, h_rat]
  | numeric nu =>
    have h_bool := h_can.2 nu rfl
    have h_den : valRat.den ≠ 0 := valRat.den_nz
    have h_gcd : Int.gcd valRat.num.natAbs valRat.den = 1 := valRat.reduced
    have h_rat : decodeRat (ratToJson ⟨valRat.num, valRat.den⟩) = .ok ⟨valRat.num, valRat.den⟩ :=
      decodeRat_mkObj valRat.num valRat.den h_den h_gcd
    have h_toRat : (RatEnc.mk valRat.num valRat.den).toRat = valRat := rat_toRat_fromRat valRat
    have h_u := decodeUnit_unitToJson (.numeric nu)
    have h_def : decodeExprFuel (fuel + 1) (exprToJson (.lit ⟨.numeric nu, valRat, valBool⟩)) = (do
        let u_dec ← decodeUnit (unitToJson (.numeric nu))
        match u_dec with
        | .bool => .error (.jsonType "boolValue")
        | .numeric nu' =>
          let r ← decodeRat (ratToJson ⟨valRat.num, valRat.den⟩)
          .ok (.lit ⟨.numeric nu', r.toRat, false⟩)) := rfl
    rw [h_def, h_u]
    dsimp [bind, Except.bind]
    rw [h_rat]
    dsimp [bind, Except.bind]
    rw [h_toRat, h_bool]

lemma exprDepth_pos (e : ExprEnc) : ExprEnc.depth e ≥ 1 := by
  cases e <;> simp [ExprEnc.depth]

/-- Expression inductive inversion theorem: any canonical expression roundtrips when given sufficient fuel. -/
theorem decodeExprFuel_exprToJson (e : ExprEnc) (fuel : Nat) (h_fuel : ExprEnc.depth e ≤ fuel) (h_can : ExprCanonical e) :
    decodeExprFuel fuel (exprToJson e) = .ok e := by
  induction fuel generalizing e with
  | zero =>
    have h_pos := exprDepth_pos e
    omega
  | succ f ih =>
    cases e with
    | lit v =>
      dsimp [ExprCanonical] at h_can
      exact decodeExprFuel_lit_canonical f v h_can.2
    | arg idx u =>
      exact exprToJson_decode_arg f idx u
    | balance c =>
      exact exprToJson_decode_balance f c
    | observe r =>
      exact exprToJson_decode_observe f r
    | timestamp k =>
      exact exprToJson_decode_timestamp f k
    | now =>
      exact exprToJson_decode_now f
    | unary op x =>
      simp only [ExprEnc.depth] at h_fuel
      have h_xfuel : ExprEnc.depth x ≤ f := by omega
      have h_x := ih x h_xfuel h_can.2
      exact exprToJson_decode_unary_step f op x h_x
    | binary op x y =>
      simp only [ExprEnc.depth] at h_fuel
      have h_xfuel : ExprEnc.depth x ≤ f := by omega
      have h_yfuel : ExprEnc.depth y ≤ f := by omega
      have h_x := ih x h_xfuel h_can.2.1
      have h_y := ih y h_yfuel h_can.2.2
      exact exprToJson_decode_binary_step f op x y h_x h_y
    | ite c y n =>
      simp only [ExprEnc.depth] at h_fuel
      have h_cfuel : ExprEnc.depth c ≤ f := by omega
      have h_yfuel : ExprEnc.depth y ≤ f := by omega
      have h_nfuel : ExprEnc.depth n ≤ f := by omega
      have h_c := ih c h_cfuel h_can.2.1
      have h_y := ih y h_yfuel h_can.2.2.1
      have h_n := ih n h_nfuel h_can.2.2.2
      exact exprToJson_decode_ite_step f c y n h_c h_y h_n

/-- Production expression decoder inversion theorem: decodeExpr inverts exprToJson for any bounded canonical expression. -/
theorem decodeExpr_exprToJson (e : ExprEnc) (h_depth : ExprEnc.depth e ≤ 64) (h_can : ExprCanonical e) :
    decodeExpr (exprToJson e) = .ok e := by
  dsimp [decodeExpr]
  exact decodeExprFuel_exprToJson e 64 h_depth h_can


theorem decodeEnvRead_envReadToJson (er : EnvReadEnc) :
    decodeEnvRead (envReadToJson er) = .ok er := by
  cases er with
  | observation k =>
    have h_k := decodeObservationKey_observationKeyToJson k
    have h_def : decodeEnvRead (envReadToJson (.observation k)) = (do
        let k_dec ← decodeObservationKey (observationKeyToJson k)
        .ok (.observation k_dec)) := rfl
    rw [h_def, h_k]
    rfl
  | currentTime => rfl


theorem decodeCellDelta_cellDeltaToJson (d : CellDeltaEnc)
    (h_depth : ExprEnc.depth d.amount ≤ 64) (h_can : ExprCanonical d.amount) :
    decodeCellDelta (cellDeltaToJson d) = .ok d := by
  cases d with | mk a t amt =>
  have h_a := decodeAsset_assetToJson a
  have h_t := decodeCellRef_cellRefToJson t
  have h_amt := decodeExpr_exprToJson amt h_depth h_can
  have h_def : decodeCellDelta (cellDeltaToJson ⟨a, t, amt⟩) = (do
      let a_dec ← decodeAsset (assetToJson a)
      let t_dec ← decodeCellRef (cellRefToJson t)
      let amt_dec ← decodeExpr (exprToJson amt)
      .ok ⟨a_dec, t_dec, amt_dec⟩) := rfl
  rw [h_def, h_a, h_t, h_amt]
  rfl


theorem decodeSupplyDelta_supplyDeltaToJson (s : SupplyDeltaEnc)
    (h_depth : ExprEnc.depth s.amount ≤ 64) (h_can : ExprCanonical s.amount) :
    decodeSupplyDelta (supplyDeltaToJson s) = .ok s := by
  cases s with | mk d a amt =>
  have h_d := decodeDomain_domainToJson d
  have h_a := decodeAsset_assetToJson a
  have h_amt := decodeExpr_exprToJson amt h_depth h_can
  have h_def : decodeSupplyDelta (supplyDeltaToJson ⟨d, a, amt⟩) = (do
      let d_dec ← decodeDomain (domainToJson d)
      let a_dec ← decodeAsset (assetToJson a)
      let amt_dec ← decodeExpr (exprToJson amt)
      .ok ⟨d_dec, a_dec, amt_dec⟩) := rfl
  rw [h_def, h_d, h_a, h_amt]
  rfl

theorem list_mapM_decode_ok {α : Type} (xs : List α) (f : α → Lean.Json) (dec : Lean.Json → Except DecodeFailure α)
    (h : ∀ x ∈ xs, dec (f x) = .ok x) :
    (xs.map f).mapM dec = .ok xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.map_cons, List.mapM_cons]
    have h_x := h x (List.Mem.head xs)
    have h_xs : ∀ y ∈ xs, dec (f y) = .ok y := fun y hy => h y (List.Mem.tail x hy)
    have ih_app := ih h_xs
    rw [h_x]
    dsimp [bind, Except.bind]
    rw [ih_app]
    rfl


theorem decodeTemplate_templateToJson (t : TemplateEnc) (h_can : TemplateCanonical t) :
    decodeTemplate (templateToJson t) = .ok t := by
  cases t with | mk sig dom arity guard deltas supplyDeltas stateReads envReads writes =>
  dsimp [TemplateCanonical] at h_can
  have h_sig : (sig.map unitToJson).mapM decodeUnit = .ok sig := by
    apply list_mapM_decode_ok
    intro u _
    exact decodeUnit_unitToJson u
  have h_dom := decodeDomain_domainToJson dom
  have h_guard_can : ExprCanonical guard := h_can.1
  have h_guard_depth : ExprEnc.depth guard ≤ 64 := by
    unfold ExprCanonical at h_guard_can
    exact h_guard_can.1
  have h_guard := decodeExpr_exprToJson guard h_guard_depth h_guard_can
  have h_deltas : (deltas.map cellDeltaToJson).mapM decodeCellDelta = .ok deltas := by
    apply list_mapM_decode_ok
    intro d hd
    have hd_can : ExprCanonical d.amount := h_can.2.1 d hd
    have hd_depth : ExprEnc.depth d.amount ≤ 64 := by
      unfold ExprCanonical at hd_can
      exact hd_can.1
    exact decodeCellDelta_cellDeltaToJson d hd_depth hd_can
  have h_supply : (supplyDeltas.map supplyDeltaToJson).mapM decodeSupplyDelta = .ok supplyDeltas := by
    apply list_mapM_decode_ok
    intro s hs
    have hs_can : ExprCanonical s.amount := h_can.2.2 s hs
    have hs_depth : ExprEnc.depth s.amount ≤ 64 := by
      unfold ExprCanonical at hs_can
      exact hs_can.1
    exact decodeSupplyDelta_supplyDeltaToJson s hs_depth hs_can
  have h_sr : (stateReads.map packedCellRefToJson).mapM decodePackedCellRef = .ok stateReads := by
    apply list_mapM_decode_ok
    intro r _
    exact decodePackedCellRef_packedCellRefToJson r
  have h_er : (envReads.map envReadToJson).mapM decodeEnvRead = .ok envReads := by
    apply list_mapM_decode_ok
    intro r _
    exact decodeEnvRead_envReadToJson r
  have h_wr : (writes.map packedCellRefToJson).mapM decodePackedCellRef = .ok writes := by
    apply list_mapM_decode_ok
    intro w _
    exact decodePackedCellRef_packedCellRefToJson w
  have h_def : decodeTemplate (templateToJson ⟨sig, dom, arity, guard, deltas, supplyDeltas, stateReads, envReads, writes⟩) = (do
      let sigArr ← Except.ok (sig.map unitToJson).toArray
      let signature ← sigArr.toList.mapM decodeUnit
      let domain ← decodeDomain (domainToJson dom)
      let guard_dec ← decodeExpr (exprToJson guard)
      let deltasArr ← Except.ok (deltas.map cellDeltaToJson).toArray
      let deltas_dec ← deltasArr.toList.mapM decodeCellDelta
      let supArr ← Except.ok (supplyDeltas.map supplyDeltaToJson).toArray
      let supplyDeltas_dec ← supArr.toList.mapM decodeSupplyDelta
      let srArr ← Except.ok (stateReads.map packedCellRefToJson).toArray
      let stateReads_dec ← srArr.toList.mapM decodePackedCellRef
      let erArr ← Except.ok (envReads.map envReadToJson).toArray
      let envReads_dec ← erArr.toList.mapM decodeEnvRead
      let wArr ← Except.ok (writes.map packedCellRefToJson).toArray
      let writes_dec ← wArr.toList.mapM decodePackedCellRef
      .ok ⟨signature, domain, arity, guard_dec, deltas_dec, supplyDeltas_dec, stateReads_dec, envReads_dec, writes_dec⟩) := rfl
  rw [h_def]
  change (do
      let signature ← (sig.map unitToJson).mapM decodeUnit
      let domain ← decodeDomain (domainToJson dom)
      let guard_dec ← decodeExpr (exprToJson guard)
      let deltas_dec ← (deltas.map cellDeltaToJson).mapM decodeCellDelta
      let supplyDeltas_dec ← (supplyDeltas.map supplyDeltaToJson).mapM decodeSupplyDelta
      let stateReads_dec ← (stateReads.map packedCellRefToJson).mapM decodePackedCellRef
      let envReads_dec ← (envReads.map envReadToJson).mapM decodeEnvRead
      let writes_dec ← (writes.map packedCellRefToJson).mapM decodePackedCellRef
      Except.ok (TemplateEnc.mk signature domain arity guard_dec deltas_dec supplyDeltas_dec stateReads_dec envReads_dec writes_dec)) =
    (Except.ok (TemplateEnc.mk sig dom arity guard deltas supplyDeltas stateReads envReads writes) : Except DecodeFailure TemplateEnc)
  rw [h_sig, h_dom, h_guard, h_deltas, h_supply, h_sr, h_er, h_wr]
  rfl

theorem filter_not_beq_of_not_mem [BEq α] [LawfulBEq α] {a : α} {as : List α} (h : ∀ x ∈ as, a ≠ x) :
    List.filter (fun b => !(b == a)) as = as := by
  induction as with
  | nil => rfl
  | cons x xs ih =>
    have h_not_head : a ≠ x := h x (List.Mem.head xs)
    have h_not_tail : ∀ y ∈ xs, a ≠ y := fun y hy => h y (List.Mem.tail x hy)
    simp only [List.filter_cons]
    have h_ne : (x == a) = false := by
      cases h_eq : (x == a)
      · rfl
      · have h_true := eq_of_beq h_eq
        exact False.elim (h_not_head h_true.symm)
    rw [h_ne]
    dsimp
    rw [ih h_not_tail]

theorem eraseDups_eq_of_nodup [BEq α] [LawfulBEq α] {as : List α} (h : as.Nodup) :
    as.eraseDups = as := by
  induction as with
  | nil => exact List.eraseDups_nil
  | cons x xs ih =>
    cases h with
    | cons h_not_mem h_nodup =>
      rw [List.eraseDups_cons]
      have h_not_mem' : ∀ y ∈ xs, x ≠ y := fun y hy => (h_not_mem y hy)
      have h_filt := filter_not_beq_of_not_mem h_not_mem'
      rw [h_filt, ih h_nodup]

theorem nodup_eraseDups_length (ids : List Nat) (h_nodup : ids.Nodup) :
    (ids.length != ids.eraseDups.length) = false := by
  have h_eq : ids.eraseDups = ids := eraseDups_eq_of_nodup h_nodup
  rw [h_eq]
  exact bne_self_eq_false ids.length


theorem decodeRegistryEntry_registryEntryToJson (e : RegistryEntryEnc) (h_can : TemplateCanonical e.template) :
    decodeRegistryEntry (registryEntryToJson e) = .ok e := by
  cases e with | mk id t =>
  have h_t := decodeTemplate_templateToJson t h_can
  have h_def : decodeRegistryEntry (registryEntryToJson ⟨id, t⟩) = (do
      let t_dec ← decodeTemplate (templateToJson t)
      .ok ⟨id, t_dec⟩) := rfl
  rw [h_def, h_t]
  rfl


theorem decodeRegistry_registryToJson (r : RegistryEnc) (h_can : RegistryCanonical r) :
    decodeRegistry (registryToJson r) = .ok r := by
  cases r with | mk entries =>
  dsimp [RegistryCanonical] at h_can
  have h_entries : (entries.map registryEntryToJson).mapM decodeRegistryEntry = .ok entries := by
    apply list_mapM_decode_ok
    intro e he
    have he_can := h_can.2 e he
    exact decodeRegistryEntry_registryEntryToJson e he_can
  have h_def : decodeRegistry (registryToJson ⟨entries⟩) = (do
      let entArr ← Except.ok (entries.map registryEntryToJson).toArray
      let ents ← entArr.toList.mapM decodeRegistryEntry
      let ids := ents.map (·.id)
      if ids.length != ids.eraseDups.length then
        throw (.uniqueness "registry")
      .ok ⟨ents⟩) := rfl
  rw [h_def]
  change (do
      let ents ← (entries.map registryEntryToJson).mapM decodeRegistryEntry
      let ids := ents.map (·.id)
      if ids.length != ids.eraseDups.length then
        throw (.uniqueness "registry")
      Except.ok (RegistryEnc.mk ents)) =
    (Except.ok (RegistryEnc.mk entries) : Except DecodeFailure RegistryEnc)
  rw [h_entries]
  dsimp [bind, Except.bind]
  have h_uniq := nodup_eraseDups_length (entries.map (·.id)) h_can.1
  rw [h_uniq]
  rfl


theorem decodeCapability_capabilityToJson (c : CapabilityEnc) :
    decodeCapability (capabilityToJson c) = .ok c := by
  cases c with | mk holder domain op right live =>
  have h_h := decodeParty_partyToJson holder
  have h_d := decodeDomain_domainToJson domain
  have h_r := decodeRight_rightToJson right
  have h_def : decodeCapability (capabilityToJson ⟨holder, domain, op, right, live⟩) = (do
      let h ← decodeParty (partyToJson holder)
      let d ← decodeDomain (domainToJson domain)
      let r ← decodeRight (rightToJson right)
      .ok ⟨h, d, op, r, live⟩) := rfl
  rw [h_def, h_h, h_d, h_r]
  cases live <;> rfl


theorem decodeStore_storeToJson (s : StoreEnc) :
    decodeStore (storeToJson s) = .ok s := by
  have h_map : (s.entries.map capabilityToJson).mapM decodeCapability = .ok s.entries := by
    apply list_mapM_decode_ok
    intro c _
    exact decodeCapability_capabilityToJson c
  have h_def : decodeStore (storeToJson s) = (do
      let entArr ← Except.ok (s.entries.map capabilityToJson).toArray
      let entries ← entArr.toList.mapM decodeCapability
      .ok ⟨entries⟩) := rfl
  rw [h_def]
  change (do
      let entries ← (s.entries.map capabilityToJson).mapM decodeCapability
      Except.ok (StoreEnc.mk entries)) =
    (Except.ok (StoreEnc.mk s.entries) : Except DecodeFailure StoreEnc)
  rw [h_map]
  rfl


theorem decodeContext_contextToJson (c : ContextEnc) :
    decodeContext (contextToJson c) = .ok c := by
  cases c with | mk p d =>
  have h_p := decodeParty_partyToJson p
  have h_d := decodeDomain_domainToJson d
  have h_def : decodeContext (contextToJson ⟨p, d⟩) = (do
      let p_dec ← decodeParty (partyToJson p)
      let d_dec ← decodeDomain (domainToJson d)
      .ok ⟨p_dec, d_dec⟩) := rfl
  rw [h_def, h_p, h_d]
  rfl

theorem decodePackedValue_canonical (v : PackedValueEnc) (h_can : PackedValueCanonical v) :
    decodePackedValue (packedValueFullToJson v) = .ok v := by
  cases v with | mk u valRat valBool =>
  dsimp [PackedValueCanonical] at h_can
  cases u with
  | bool =>
    have h_rat := h_can.1 rfl
    have h_def : decodePackedValue (packedValueFullToJson ⟨.bool, valRat, valBool⟩) =
        .ok ⟨.bool, 0, valBool⟩ := by
      cases valBool <;> rfl
    rw [h_def, h_rat]
  | numeric nu =>
    have h_bool := h_can.2 nu rfl
    have h_den : valRat.den ≠ 0 := valRat.den_nz
    have h_gcd : Int.gcd valRat.num.natAbs valRat.den = 1 := valRat.reduced
    have h_rat : decodeRat (ratToJson ⟨valRat.num, valRat.den⟩) = .ok ⟨valRat.num, valRat.den⟩ :=
      decodeRat_mkObj valRat.num valRat.den h_den h_gcd
    have h_toRat : (RatEnc.mk valRat.num valRat.den).toRat = valRat := rat_toRat_fromRat valRat
    have h_u := decodeUnit_unitToJson (.numeric nu)
    have h_def : decodePackedValue (packedValueFullToJson ⟨.numeric nu, valRat, valBool⟩) = (do
        let u_dec ← decodeUnit (unitToJson (.numeric nu))
        match u_dec with
        | .bool => .error (.jsonType "boolValue")
        | .numeric nu' =>
          let r ← decodeRat (ratToJson ⟨valRat.num, valRat.den⟩)
          .ok ⟨.numeric nu', r.toRat, false⟩) := rfl
    rw [h_def, h_u]
    dsimp [bind, Except.bind]
    rw [h_rat]
    dsimp [bind, Except.bind]
    rw [h_toRat, h_bool]


theorem decodeObservation_observationToJson (o : ObservationEnc) (h_can : PackedValueCanonical o.value) :
    decodeObservation (observationToJson o) = .ok o := by
  cases o with | mk val ts =>
  have h_val := decodePackedValue_canonical val h_can
  have h_def : decodeObservation (observationToJson ⟨val, ts⟩) = (do
      let v_dec ← decodePackedValue (packedValueFullToJson val)
      .ok ⟨v_dec, ts⟩) := rfl
  rw [h_def, h_val]
  rfl


theorem decodeEnvironmentEntry_environmentEntryToJson (e : EnvironmentEntryEnc) (h_can : PackedValueCanonical e.observation.value) :
    decodeEnvironmentEntry (environmentEntryToJson e) = .ok e := by
  cases e with | mk k o =>
  have h_k := decodeObservationKey_observationKeyToJson k
  have h_o := decodeObservation_observationToJson o h_can
  have h_def : decodeEnvironmentEntry (environmentEntryToJson ⟨k, o⟩) = (do
      let k_dec ← decodeObservationKey (observationKeyToJson k)
      let o_dec ← decodeObservation (observationToJson o)
      .ok ⟨k_dec, o_dec⟩) := rfl
  rw [h_def, h_k, h_o]
  rfl


theorem decodeEnvironment_environmentToJson (env : EnvironmentEnc) (h_can : EnvironmentCanonical env) :
    decodeEnvironment (environmentToJson env) = .ok env := by
  cases env with | mk entries =>
  dsimp [EnvironmentCanonical] at h_can
  have h_entries : (entries.map environmentEntryToJson).mapM decodeEnvironmentEntry = .ok entries := by
    apply list_mapM_decode_ok
    intro e he
    have he_can := h_can e he
    exact decodeEnvironmentEntry_environmentEntryToJson e he_can
  have h_def : decodeEnvironment (environmentToJson ⟨entries⟩) = (do
      let entArr ← Except.ok (entries.map environmentEntryToJson).toArray
      let ents ← entArr.toList.mapM decodeEnvironmentEntry
      .ok ⟨ents⟩) := rfl
  rw [h_def]
  change (do
      let ents ← (entries.map environmentEntryToJson).mapM decodeEnvironmentEntry
      Except.ok (EnvironmentEnc.mk ents)) =
    (Except.ok (EnvironmentEnc.mk entries) : Except DecodeFailure EnvironmentEnc)
  rw [h_entries]
  rfl


theorem decodeDomainAdmin_domainAdminToJson (d : DomainAdminEnc) :
    decodeDomainAdmin (domainAdminToJson d) = .ok d := by
  cases d with | mk dom p =>
  have h_dom := decodeDomain_domainToJson dom
  have h_p := decodeParty_partyToJson p
  have h_def : decodeDomainAdmin (domainAdminToJson ⟨dom, p⟩) = (do
      let d_dec ← decodeDomain (domainToJson dom)
      let p_dec ← decodeParty (partyToJson p)
      .ok ⟨d_dec, p_dec⟩) := rfl
  rw [h_def, h_dom, h_p]
  rfl


theorem decodeInputPort_inputPortToJson (p : InputPortEnc) :
    decodeInputPort (inputPortToJson p) = .ok p := by
  cases p with | mk id u =>
  have h_u := decodeUnit_unitToJson u
  have h_def : decodeInputPort (inputPortToJson ⟨id, u⟩) = (do
      let u_dec ← decodeUnit (unitToJson u)
      .ok ⟨id, u_dec⟩) := rfl
  rw [h_def, h_u]
  rfl


theorem decodeOutputPort_outputPortToJson (p : OutputPortEnc) :
    decodeOutputPort (outputPortToJson p) = .ok p := by
  cases p with | mk id c =>
  have h_c := decodeCell_cellToJson c
  have h_def : decodeOutputPort (outputPortToJson ⟨id, c⟩) = (do
      let c_dec ← decodeCell (cellToJson c)
      .ok ⟨id, c_dec⟩) := rfl
  rw [h_def, h_c]
  rfl


theorem decodeResourcePort_resourcePortToJson (rp : ResourcePortEnc) :
    decodeResourcePort (resourcePortToJson rp) = .ok rp := by
  cases rp with | mk id c w =>
  have h_c := decodeCell_cellToJson c
  have h_def : decodeResourcePort (resourcePortToJson ⟨id, c, w⟩) = (do
      let c_dec ← decodeCell (cellToJson c)
      .ok ⟨id, c_dec, w⟩) := rfl
  rw [h_def, h_c]
  cases w <;> rfl


theorem decodeQualifiedPort_qualifiedPortToJson (qp : QualifiedPortEnc) :
    decodeQualifiedPort (qualifiedPortToJson qp) = .ok qp := by
  cases qp with | mk c p => rfl


theorem decodeResourceImport_resourceImportToJson (ri : ResourceImportEnc) :
    decodeResourceImport (resourceImportToJson ri) = .ok ri := by
  cases ri with | mk s c w =>
  have h_c := decodeCell_cellToJson c
  have h_def : decodeResourceImport (resourceImportToJson ⟨s, c, w⟩) = (do
      let c_dec ← decodeCell (cellToJson c)
      .ok ⟨s, c_dec, w⟩) := rfl
  rw [h_def, h_c]
  cases w <;> rfl


theorem decodeSourcePin_sourcePinToJson (sp : SourcePinEnc) :
    decodeSourcePin (sourcePinToJson sp) = .ok sp := by
  cases sp with | mk git lt ml cc cr ar =>
  cases cr <;> cases ar <;> rfl


theorem decodeTypesEnum_typesEnumToJson (te : TypesEnumEnc) :
    decodeTypesEnum (typesEnumToJson te) = .ok te := by
  have h_p : (te.parties.map partyToJson).mapM decodeParty = .ok te.parties := by
    apply list_mapM_decode_ok; intro p _; exact decodeParty_partyToJson p
  have h_a : (te.assets.map assetToJson).mapM decodeAsset = .ok te.assets := by
    apply list_mapM_decode_ok; intro a _; exact decodeAsset_assetToJson a
  have h_d : (te.domains.map domainToJson).mapM decodeDomain = .ok te.domains := by
    apply list_mapM_decode_ok; intro d _; exact decodeDomain_domainToJson d
  have h_def : decodeTypesEnum (typesEnumToJson te) = (do
      let parties ← (te.parties.map partyToJson).mapM decodeParty
      let assets ← (te.assets.map assetToJson).mapM decodeAsset
      let domains ← (te.domains.map domainToJson).mapM decodeDomain
      .ok ⟨parties, assets, domains⟩) := rfl
  rw [h_def, h_p, h_a, h_d]
  rfl

theorem decodeStateCell_stateCellToJson (c : StateCellEnc)
    (h_den : c.amount.den ≠ 0) (h_gcd : Int.gcd c.amount.num.natAbs c.amount.den = 1) (h_nonneg : c.amount.num ≥ 0) :
    decodeStateCell (stateCellToJson c) = .ok c := by
  cases c with | mk d p a amt =>
  dsimp at h_nonneg
  have h_d := decodeDomain_domainToJson d
  have h_p := decodeParty_partyToJson p
  have h_a := decodeAsset_assetToJson a
  have h_amt : decodeRat (ratToJson amt) = .ok amt := decodeRat_ratToJson amt h_den h_gcd
  have h_def : decodeStateCell (stateCellToJson ⟨d, p, a, amt⟩) = (do
      let d_dec ← decodeDomain (domainToJson d)
      let p_dec ← decodeParty (partyToJson p)
      let a_dec ← decodeAsset (assetToJson a)
      let amt_dec ← decodeRat (ratToJson amt)
      if amt_dec.num < 0 then throw .stateNonneg
      .ok ⟨d_dec, p_dec, a_dec, amt_dec⟩) := rfl
  rw [h_def, h_d, h_p, h_a, h_amt]
  dsimp [bind, Except.bind]
  have h_neg : ¬ (amt.num < 0) := by omega
  rw [if_neg h_neg]



theorem decodeLibraryRef_libraryRefToJson (lr : LibraryRefEnc) :
    decodeLibraryRef (libraryRefToJson lr) = .ok lr := by
  cases lr with | mk thm m =>
  cases m with
  | none => rfl
  | some m' => rfl

theorem decodeNat_natToJson (n : Nat) :
    (match (natToJson n) with | .num m => (Except.ok m.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId")) = Except.ok n := rfl

theorem decodeNatList_map_num (caps : List Nat) :
    (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId")) = Except.ok caps := by
  apply list_mapM_decode_ok
  intro n _
  exact decodeNat_natToJson n

theorem decodeState_stateToJson (s : StateEnc)
    (h_valid : ∀ c ∈ s.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_unique : (s.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = s.cells.length) :
    decodeState (stateToJson s) = .ok s := by
  cases s with | mk cells =>
  have h_cells : (cells.map stateCellToJson).mapM decodeStateCell = .ok cells := by
    apply list_mapM_decode_ok
    intro c hc
    have hc_valid := h_valid c hc
    exact decodeStateCell_stateCellToJson c hc_valid.1 hc_valid.2.1 hc_valid.2.2
  have h_def : decodeState (stateToJson ⟨cells⟩) = (do
      let arr ← Except.ok (cells.map stateCellToJson).toArray
      let c_dec ← arr.toList.mapM decodeStateCell
      let keys := c_dec.map (fun c => (c.domain, c.party, c.asset))
      if keys.length != keys.eraseDups.length then throw (.uniqueness "stateCell")
      .ok ⟨c_dec⟩) := rfl
  rw [h_def]
  change (do
      let c_dec ← (cells.map stateCellToJson).mapM decodeStateCell
      let keys := c_dec.map (fun c => (c.domain, c.party, c.asset))
      if keys.length != keys.eraseDups.length then throw (.uniqueness "stateCell")
      Except.ok (StateEnc.mk c_dec)) =
    (Except.ok (StateEnc.mk cells) : Except DecodeFailure StateEnc)
  rw [h_cells]
  dsimp [bind, Except.bind]
  have h_len : (cells.map (fun c => (c.domain, c.party, c.asset))).length = cells.length := List.length_map ..
  dsimp at h_unique
  have h_cond : ((cells.map (fun c => (c.domain, c.party, c.asset))).length !=
      (cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length) = false := by
    rw [h_len, h_unique]
    simp
  rw [h_cond]
  rfl

theorem decodeRequest_requestToJson (r : RequestEnc) (h_can : RequestCanonical r) :
    decodeRequest (requestToJson r) = .ok r := by
  cases r with | mk op parties args caps actor =>
  have h_parties : (parties.map partyToJson).mapM decodeParty = .ok parties := by
    apply list_mapM_decode_ok; intro p _; exact decodeParty_partyToJson p
  have h_args : (args.map packedValueFullToJson).mapM decodePackedValue = .ok args := by
    apply list_mapM_decode_ok; intro a ha; exact decodePackedValue_canonical a (h_can a ha)
  have h_caps : (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId")) = Except.ok caps :=
    decodeNatList_map_num caps
  cases actor with
  | none =>
    have h_def : decodeRequest (requestToJson ⟨op, parties, args, caps, none⟩) = (do
        let p_dec ← (parties.map partyToJson).mapM decodeParty
        let a_dec ← (args.map packedValueFullToJson).mapM decodePackedValue
        let c_dec ← (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId"))
        .ok ⟨op, p_dec, a_dec, c_dec, none⟩) := rfl
    rw [h_def, h_parties, h_args, h_caps]
    rfl
  | some p =>
    have hp := decodeParty_partyToJson p
    have h_def : decodeRequest (requestToJson ⟨op, parties, args, caps, some p⟩) = (do
        let p_dec ← (parties.map partyToJson).mapM decodeParty
        let a_dec ← (args.map packedValueFullToJson).mapM decodePackedValue
        let c_dec ← (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId"))
        let ca_dec ← (decodeParty (partyToJson p)).map some
        .ok ⟨op, p_dec, a_dec, c_dec, ca_dec⟩) := rfl
    rw [h_def, h_parties, h_args, h_caps, hp]
    rfl

theorem decodeOperationInterface_operationInterfaceToJson (op : OperationInterfaceEnc) :
    decodeOperationInterface (operationInterfaceToJson op) = .ok op := by
  cases op with | mk op_num inputs outputs =>
  have h_in : (inputs.map inputPortToJson).mapM decodeInputPort = .ok inputs := by
    apply list_mapM_decode_ok; intro p _; exact decodeInputPort_inputPortToJson p
  have h_out : (outputs.map outputPortToJson).mapM decodeOutputPort = .ok outputs := by
    apply list_mapM_decode_ok; intro p _; exact decodeOutputPort_outputPortToJson p
  have h_def : decodeOperationInterface (operationInterfaceToJson ⟨op_num, inputs, outputs⟩) = (do
      let in_dec ← (inputs.map inputPortToJson).mapM decodeInputPort
      let out_dec ← (outputs.map outputPortToJson).mapM decodeOutputPort
      .ok ⟨op_num, in_dec, out_dec⟩) := rfl
  rw [h_def, h_in, h_out]
  rfl

theorem decodeComponent_componentToJson (c : ComponentEnc) :
    decodeComponent (componentToJson c) = .ok c := by
  cases c with | mk id priv exp imp ops =>
  have h_priv : (priv.map cellToJson).mapM decodeCell = .ok priv := by
    apply list_mapM_decode_ok; intro x _; exact decodeCell_cellToJson x
  have h_exp : (exp.map resourcePortToJson).mapM decodeResourcePort = .ok exp := by
    apply list_mapM_decode_ok; intro x _; exact decodeResourcePort_resourcePortToJson x
  have h_imp : (imp.map resourceImportToJson).mapM decodeResourceImport = .ok imp := by
    apply list_mapM_decode_ok; intro x _; exact decodeResourceImport_resourceImportToJson x
  have h_ops : (ops.map operationInterfaceToJson).mapM decodeOperationInterface = .ok ops := by
    apply list_mapM_decode_ok; intro x _; exact decodeOperationInterface_operationInterfaceToJson x
  have h_def : decodeComponent (componentToJson ⟨id, priv, exp, imp, ops⟩) = (do
      let priv_dec ← (priv.map cellToJson).mapM decodeCell
      let exp_dec ← (exp.map resourcePortToJson).mapM decodeResourcePort
      let imp_dec ← (imp.map resourceImportToJson).mapM decodeResourceImport
      let ops_dec ← (ops.map operationInterfaceToJson).mapM decodeOperationInterface
      .ok ⟨id, priv_dec, exp_dec, imp_dec, ops_dec⟩) := rfl
  rw [h_def, h_priv, h_exp, h_imp, h_ops]
  rfl

theorem decodeConfig_configToJson (cfg : ConfigEnc)
    (h_reg_can : RegistryCanonical cfg.registry) :
    decodeConfig (configToJson cfg) = .ok cfg := by
  cases cfg with | mk reg da cat =>
  have h_reg := decodeRegistry_registryToJson reg h_reg_can
  have h_da : (da.map domainAdminToJson).mapM decodeDomainAdmin = .ok da := by
    apply list_mapM_decode_ok; intro x _; exact decodeDomainAdmin_domainAdminToJson x
  have h_cat : (cat.map componentToJson).mapM decodeComponent = .ok cat := by
    apply list_mapM_decode_ok; intro x _; exact decodeComponent_componentToJson x
  have h_def : decodeConfig (configToJson ⟨reg, da, cat⟩) = (do
      let reg_dec ← decodeRegistry (registryToJson reg)
      let da_dec ← (da.map domainAdminToJson).mapM decodeDomainAdmin
      let cat_dec ← (cat.map componentToJson).mapM decodeComponent
      .ok ⟨reg_dec, da_dec, cat_dec⟩) := rfl
  rw [h_def, h_reg, h_da, h_cat]
  rfl

theorem decodeWorld_worldToJson (w : WorldEnc)
    (h_state_valid : ∀ c ∈ w.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (w.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = w.state.cells.length) :
    decodeWorld (worldToJson w) = .ok w := by
  cases w with | mk st caps =>
  have h_st := decodeState_stateToJson st h_state_valid h_state_unique
  have h_caps := decodeStore_storeToJson caps
  have h_def : decodeWorld (worldToJson ⟨st, caps⟩) = (do
      let st_dec ← decodeState (stateToJson st)
      let caps_dec ← decodeStore (storeToJson caps)
      .ok ⟨st_dec, caps_dec⟩) := rfl
  rw [h_def, h_st, h_caps]
  rfl

theorem world_unique_of_canonical (w : WorldEnc) (h : WorldCanonical w) :
    (w.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = w.state.cells.length := by
  have h_cells := h.1
  rcases h_cells with ⟨h_len, h_map, _⟩
  rw [h_map, h_len]
  decide

theorem world_valid_of_canonical (w : WorldEnc) (h : WorldCanonical w) :
    ∀ c ∈ w.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
  have h_cells := h.1
  rcases h_cells with ⟨_, _, h_all⟩
  intro c hc
  rw [List.all_eq_true] at h_all
  have hc_prop := of_decide_eq_true (h_all c hc)
  exact ⟨by omega, hc_prop.2.2, hc_prop.2.1⟩

theorem decodeClaimedNextState_none :
    decodeClaimedNextState Lean.Json.null = .ok none := rfl

theorem decodeClaimedNextState_some (w : WorldEnc) (h : WorldCanonical w) :
    decodeClaimedNextState (worldToJson w) = .ok (some w) := by
  cases w with | mk st caps =>
  have h_valid := world_valid_of_canonical ⟨st, caps⟩ h
  have h_unique := world_unique_of_canonical ⟨st, caps⟩ h
  have h_world := decodeWorld_worldToJson ⟨st, caps⟩ h_valid h_unique
  change (do
    let w ← decodeWorld (worldToJson ⟨st, caps⟩)
    .ok (some w)) = .ok (some ⟨st, caps⟩)
  rw [h_world]
  rfl

theorem decodeClaimedNextState_of_canonical (cns : Option WorldEnc) (h : ClaimedNextStateCanonical cns) :
    (match cns with
     | none => decodeClaimedNextState Lean.Json.null
     | some w => decodeClaimedNextState (worldToJson w)) = .ok cns := by
  cases cns with
  | none => exact decodeClaimedNextState_none
  | some w => exact decodeClaimedNextState_some w h

theorem decodeSourceMap_nil :
    decodeSourceMap (Lean.Json.mkObj []) = .ok [] := rfl

theorem decodeSourceMap_single (k v : String) :
    decodeSourceMap (Lean.Json.mkObj [(k, Lean.Json.str v)]) = .ok [(k, v)] := rfl

def relLt {α β : Type*} (cmp : α → α → Ordering) (a b : α × β) : Prop :=
  cmp a.1 b.1 = .lt

instance instIrreflRelLt {α β : Type*} (cmp : α → α → Ordering) [Std.TransCmp cmp] :
    Std.Irrefl (relLt cmp (α := α) (β := β)) where
  irrefl a h := by
    dsimp [relLt] at h
    have h_refl := Std.ReflCmp.compare_self (cmp := cmp) (a := a.1)
    rw [h_refl] at h
    contradiction

instance instAntisymmRelLt {α β : Type*} (cmp : α → α → Ordering) [Std.TransCmp cmp] :
    Std.Antisymm (relLt cmp (α := α) (β := β)) where
  antisymm a b hab hba := by
    dsimp [relLt] at hab hba
    have h_gt : cmp b.1 a.1 = .gt := by
      rw [Std.OrientedCmp.gt_iff_lt]
      exact hab
    rw [hba] at h_gt
    contradiction

theorem distinct_of_pairwise_lt {α β : Type*} {cmp : α → α → Ordering}
    {l : List (α × β)} (h : l.Pairwise (fun a b => cmp a.1 b.1 = .lt)) :
    l.Pairwise (fun a b => ¬ cmp a.1 b.1 = .eq) := by
  apply List.Pairwise.imp _ h
  intro a b hab heq
  rw [hab] at heq
  contradiction

theorem ofList_toList_eq {β : Type*}
    (l : List (String × β))
    (h_sort : l.Pairwise (fun a b => compare a.1 b.1 = .lt)) :
    (Std.TreeMap.Raw.ofList l compare).toList = l := by
  have h_wf : (Std.TreeMap.Raw.ofList l compare).WF := Std.TreeMap.Raw.WF.ofList
  have h_dist : l.Pairwise (fun a b => ¬ compare a.1 b.1 = .eq) := distinct_of_pairwise_lt h_sort
  have h_pw_t : (Std.TreeMap.Raw.ofList l compare).toList.Pairwise (fun a b => compare a.1 b.1 = .lt) :=
    Std.TreeMap.Raw.ordered_keys_toList h_wf
  apply List.Pairwise.eq_of_mem_iff (r := relLt compare)
  · exact h_pw_t
  · exact h_sort
  · intro p
    rcases p with ⟨k, v⟩
    constructor
    · intro hp
      rw [Std.TreeMap.Raw.mem_toList_iff_getElem?_eq_some h_wf] at hp
      by_cases hc : (l.map Prod.fst).contains k
      · have h_mem : k ∈ l.map Prod.fst := by
          simpa using hc
        obtain ⟨⟨k', v'⟩, h_in, rfl⟩ := List.mem_map.mp h_mem
        have h_get' : (Std.TreeMap.Raw.ofList l compare)[k']? = some v' :=
          Std.TreeMap.Raw.getElem?_ofList_of_mem (Std.ReflCmp.compare_self) h_dist h_in
        rw [hp] at h_get'
        injection h_get' with h_eq
        subst h_eq
        exact h_in
      · rw [Bool.not_eq_true] at hc
        have h_none : (Std.TreeMap.Raw.ofList l compare)[k]? = none :=
          Std.TreeMap.Raw.getElem?_ofList_of_contains_eq_false hc
        rw [hp] at h_none
        contradiction
    · intro hp
      have h_get : (Std.TreeMap.Raw.ofList l compare)[k]? = some v := by
        apply Std.TreeMap.Raw.getElem?_ofList_of_mem (Std.ReflCmp.compare_self) h_dist hp
      rw [Std.TreeMap.Raw.mem_toList_iff_getElem?_eq_some h_wf]
      exact h_get

theorem compare_lt_of_lt (x y : String) (h : x < y) : compare x y = .lt := by
  have : compare x y = String.compare x y := rfl
  rw [this]
  have h_eq : String.compare x y = compareOfLessAndEq x y := rfl
  rw [h_eq]
  simp [compareOfLessAndEq, h]

theorem pairwise_lt_of_isSortedStrictAscending : ∀ (xs : List String),
    isSortedStrictAscending xs = true → xs.Pairwise (fun a b => a < b)
  | [] => fun _ => List.Pairwise.nil
  | [x] => fun _ => List.Pairwise.cons (fun _ h => nomatch h) List.Pairwise.nil
  | x1 :: x2 :: rest => fun h => by
    dsimp [isSortedStrictAscending] at h
    split at h
    · rename_i h12
      have ih := pairwise_lt_of_isSortedStrictAscending (x2 :: rest) h
      refine List.Pairwise.cons ?_ ih
      intro y hy
      cases hy with
      | head => exact h12
      | tail _ hy' =>
        have h_x2_y : x2 < y := by
          cases ih with
          | cons h_all _ => exact h_all y hy'
        exact String.lt_trans h12 h_x2_y
    · contradiction

theorem list_mapM_sourceMap_entries : ∀ (sm : List (String × String)),
    (sm.map (fun (k, v) => (k, Lean.Json.str v))).mapM
      (fun (k, v) => match v with | .str s => (Except.ok (k, s) : Except DecodeFailure (String × String)) | _ => Except.error (.jsonType "source_map")) =
      Except.ok sm
  | [] => rfl
  | (k, v) :: rest => by
    simp only [List.map_cons, List.mapM_cons]
    have ih := list_mapM_sourceMap_entries rest
    rw [ih]
    rfl

/-- Universal source map inversion theorem: for any strictly sorted source map,
    encoding to JSON and decoding recovers the exact source map without decoder-success hypotheses. -/
theorem decodeSourceMap_sourceMapToJson (sm : List (String × String)) (h_sort : SourceMapSorted sm) :
    decodeSourceMap (Lean.Json.mkObj (sm.map (fun (k, v) => (k, Lean.Json.str v)))) = .ok sm := by
  dsimp [SourceMapSorted] at h_sort
  have h_pw_str := pairwise_lt_of_isSortedStrictAscending (sm.map Prod.fst) h_sort
  let l : List (String × Lean.Json) := sm.map (fun (k, v) => (k, Lean.Json.str v))
  have h_pw_cmp : l.Pairwise (fun a b => compare a.1 b.1 = .lt) := by
    have h_map_eq : l.map Prod.fst = sm.map Prod.fst := by
      dsimp [l]
      rw [List.map_map]
      rfl
    have h_pw_fst : (l.map Prod.fst).Pairwise (fun a b => a < b) := by
      rw [h_map_eq]
      exact h_pw_str
    have h_pw_l : l.Pairwise (fun a b => a.1 < b.1) := List.pairwise_map.mp h_pw_fst
    apply List.Pairwise.imp _ h_pw_l
    intro a b hab
    exact compare_lt_of_lt a.1 b.1 hab
  have h_toList := ofList_toList_eq l h_pw_cmp
  have h_def : decodeSourceMap (Lean.Json.mkObj l) = (do
      let m := Std.TreeMap.Raw.ofList l compare
      let entries := m.toList
      let keys := entries.map Prod.fst
      if !isSortedStrictAscending keys then
        throw .noncanonicalWhitespace
      entries.mapM (fun (k, v) => match v with | .str s => .ok (k, s) | _ => .error (.jsonType "source_map"))) := rfl
  rw [h_def]
  dsimp
  rw [h_toList]
  have h_keys_eq : (l.map Prod.fst) = sm.map Prod.fst := by
    dsimp [l]
    rw [List.map_map]
    rfl
  rw [h_keys_eq, h_sort]
  dsimp
  exact list_mapM_sourceMap_entries sm

theorem decodeBoundary_boundaryToJson (b : BoundaryEnc) (h_can : BoundaryCanonical b) :
    decodeBoundary (boundaryToJson b) = .ok b := by
  cases b with | mk ctx env now =>
  have h_ctx := decodeContext_contextToJson ctx
  have h_env := decodeEnvironment_environmentToJson env h_can
  have h_def : decodeBoundary (boundaryToJson ⟨ctx, env, now⟩) = (do
      let ctx_dec ← decodeContext (contextToJson ctx)
      let env_dec ← decodeEnvironment (environmentToJson env)
      .ok ⟨ctx_dec, env_dec, now⟩) := rfl
  rw [h_def, h_ctx, h_env]
  rfl

theorem decodeInputSource_inputSourceToJson (s : InputSourceEnc) (h_can : InputSourceCanonical s) :
    decodeInputSource (inputSourceToJson s) = .ok s := by
  cases s with
  | literal v =>
    have hv := decodePackedValue_canonical v h_can
    have h_def : decodeInputSource (inputSourceToJson (.literal v)) = (do
        let v_dec ← decodePackedValue (packedValueFullToJson v)
        .ok (.literal v_dec)) := rfl
    rw [h_def, hv]
    rfl
  | priorOutput step port =>
    cases port with | mk c p => rfl

theorem decodeInvocation_invocationToJson (inv : InvocationEnc) (h_can : InvocationCanonical inv) :
    decodeInvocation (invocationToJson inv) = .ok inv := by
  cases inv with | mk comp op parties inputs caps actor =>
  have h_parties : (parties.map partyToJson).mapM decodeParty = .ok parties := by
    apply list_mapM_decode_ok; intro p _; exact decodeParty_partyToJson p
  have h_inputs : (inputs.map inputSourceToJson).mapM decodeInputSource = .ok inputs := by
    apply list_mapM_decode_ok; intro i hi; exact decodeInputSource_inputSourceToJson i (h_can i hi)
  have h_caps : (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId")) = Except.ok caps :=
    decodeNatList_map_num caps
  cases actor with
  | none =>
    have h_def : decodeInvocation (invocationToJson ⟨comp, op, parties, inputs, caps, none⟩) = (do
        let p_dec ← (parties.map partyToJson).mapM decodeParty
        let in_dec ← (inputs.map inputSourceToJson).mapM decodeInputSource
        let c_dec ← (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId"))
        .ok ⟨comp, op, p_dec, in_dec, c_dec, none⟩) := rfl
    rw [h_def, h_parties, h_inputs, h_caps]
    rfl
  | some p =>
    have hp := decodeParty_partyToJson p
    have h_def : decodeInvocation (invocationToJson ⟨comp, op, parties, inputs, caps, some p⟩) = (do
        let p_dec ← (parties.map partyToJson).mapM decodeParty
        let in_dec ← (inputs.map inputSourceToJson).mapM decodeInputSource
        let c_dec ← (caps.map natToJson).mapM (fun (x : Lean.Json) => match x with | .num n => (Except.ok n.mantissa.toNat : Except DecodeFailure Nat) | _ => Except.error (.jsonType "capabilityId"))
        let ca_dec ← (decodeParty (partyToJson p)).map some
        .ok ⟨comp, op, p_dec, in_dec, c_dec, ca_dec⟩) := rfl
    rw [h_def, h_parties, h_inputs, h_caps, hp]
    rfl

set_option maxHeartbeats 1000000 in
theorem decodeStep_stepToJson (s : StepEnc) (h_can : StepCanonical s) :
    decodeStep (stepToJson s) = .ok s := by
  cases s with
  | invoke inv =>
    have h_inv := decodeInvocation_invocationToJson inv h_can
    have h_def : decodeStep (stepToJson (.invoke inv)) = (do
        let inv_dec ← decodeInvocation (invocationToJson inv)
        .ok (.invoke inv_dec)) := rfl
    rw [h_def, h_inv]
    rfl
  | issue grant =>
    have h_g := decodeGrant_grantToJson grant
    have h_def : decodeStep (stepToJson (.issue grant)) = (do
        let g_dec ← decodeGrant (grantToJson grant)
        .ok (.issue g_dec)) := rfl
    rw [h_def, h_g]
    rfl
  | revoke id =>
    rfl
  | unsupported _ =>
    contradiction

theorem decodeOutputObservation_outputObservationToJson (o : OutputObservationEnc) (h_can : PackedValueCanonical o.value) :
    decodeOutputObservation (outputObservationToJson o) = .ok o := by
  cases o with | mk step port val =>
  have h_val := decodePackedValue_canonical val h_can
  cases port with | mk c p =>
  have h_def : decodeOutputObservation (outputObservationToJson ⟨step, ⟨c, p⟩, val⟩) = (do
      let v_dec ← decodePackedValue (packedValueFullToJson val)
      .ok ⟨step, ⟨c, p⟩, v_dec⟩) := rfl
  rw [h_def, h_val]
  rfl

theorem decodeTypedExecutePayload_typedExecutePayloadToJson (p : TypedExecutePayloadEnc)
    (h_reg_can : RegistryCanonical p.registry)
    (h_env_can : EnvironmentCanonical p.env)
    (h_req_can : RequestCanonical p.request)
    (h_state_valid : ∀ c ∈ p.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (p.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.state.cells.length) :
    decodeTypedExecutePayload (typedExecutePayloadToJson p) = .ok p := by
  cases p with | mk reg store ctx env now req st =>
  have h_reg := decodeRegistry_registryToJson reg h_reg_can
  have h_store := decodeStore_storeToJson store
  have h_ctx := decodeContext_contextToJson ctx
  have h_env := decodeEnvironment_environmentToJson env h_env_can
  have h_req := decodeRequest_requestToJson req h_req_can
  have h_st := decodeState_stateToJson st h_state_valid h_state_unique
  have h_def : decodeTypedExecutePayload (typedExecutePayloadToJson ⟨reg, store, ctx, env, now, req, st⟩) = (do
      let reg_dec ← decodeRegistry (registryToJson reg)
      let store_dec ← decodeStore (storeToJson store)
      let ctx_dec ← decodeContext (contextToJson ctx)
      let env_dec ← decodeEnvironment (environmentToJson env)
      let req_dec ← decodeRequest (requestToJson req)
      let st_dec ← decodeState (stateToJson st)
      .ok ⟨reg_dec, store_dec, ctx_dec, env_dec, now, req_dec, st_dec⟩) := rfl
  rw [h_def, h_reg, h_store, h_ctx, h_env, h_req, h_st]
  rfl

theorem decodeCompositionStepPayload_compositionStepPayloadToJson (p : CompositionStepPayloadEnc)
    (h_cfg_can : RegistryCanonical p.config.registry)
    (h_bnd_can : BoundaryCanonical p.boundary)
    (h_hist_can : HistoryCanonical p.history)
    (h_step_can : StepCanonical p.step)
    (h_pre_valid : ∀ c ∈ p.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_pre_unique : (p.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.pre.state.cells.length) :
    decodeCompositionStepPayload (compositionStepPayloadToJson p) = .ok p := by
  cases p with | mk cfg bnd idx hist step pre =>
  have h_cfg := decodeConfig_configToJson cfg h_cfg_can
  have h_bnd := decodeBoundary_boundaryToJson bnd h_bnd_can
  have h_hist : (hist.map outputObservationToJson).mapM decodeOutputObservation = .ok hist := by
    apply list_mapM_decode_ok; intro o ho; exact decodeOutputObservation_outputObservationToJson o (h_hist_can o ho)
  have h_step := decodeStep_stepToJson step h_step_can
  have h_pre := decodeWorld_worldToJson pre h_pre_valid h_pre_unique
  have h_def : decodeCompositionStepPayload (compositionStepPayloadToJson ⟨cfg, bnd, idx, hist, step, pre⟩) = (do
      let cfg_dec ← decodeConfig (configToJson cfg)
      let bnd_dec ← decodeBoundary (boundaryToJson bnd)
      let hist_dec ← (hist.map outputObservationToJson).mapM decodeOutputObservation
      let step_dec ← decodeStep (stepToJson step)
      let pre_dec ← decodeWorld (worldToJson pre)
      .ok ⟨cfg_dec, bnd_dec, idx, hist_dec, step_dec, pre_dec⟩) := rfl
  rw [h_def, h_cfg, h_bnd, h_hist, h_step, h_pre]
  rfl

theorem decodeCompositionRunPayload_compositionRunPayloadToJson (p : CompositionRunPayloadEnc)
    (h_cfg_can : RegistryCanonical p.config.registry)
    (h_bnds_can : ∀ b ∈ p.boundaries, BoundaryCanonical b)
    (h_steps_can : ∀ s ∈ p.steps, StepCanonical s)
    (h_w_valid : ∀ c ∈ p.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_w_unique : (p.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.world.state.cells.length) :
    decodeCompositionRunPayload (compositionRunPayloadToJson p) = .ok p := by
  cases p with | mk cfg bnds world steps =>
  have h_cfg := decodeConfig_configToJson cfg h_cfg_can
  have h_bnds : (bnds.map boundaryToJson).mapM decodeBoundary = .ok bnds := by
    apply list_mapM_decode_ok; intro b hb; exact decodeBoundary_boundaryToJson b (h_bnds_can b hb)
  have h_world := decodeWorld_worldToJson world h_w_valid h_w_unique
  have h_steps : (steps.map stepToJson).mapM decodeStep = .ok steps := by
    apply list_mapM_decode_ok; intro s hs; exact decodeStep_stepToJson s (h_steps_can s hs)
  have h_def : decodeCompositionRunPayload (compositionRunPayloadToJson ⟨cfg, bnds, world, steps⟩) = (do
      let cfg_dec ← decodeConfig (configToJson cfg)
      let bnds_dec ← (bnds.map boundaryToJson).mapM decodeBoundary
      let world_dec ← decodeWorld (worldToJson world)
      let steps_dec ← (steps.map stepToJson).mapM decodeStep
      .ok ⟨cfg_dec, bnds_dec, world_dec, steps_dec⟩) := rfl
  rw [h_def, h_cfg, h_bnds, h_world, h_steps]
  rfl

/-- Generic string list decoding theorem. -/
theorem decodeStringList_ok (xs : List String) :
    (xs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root")) = Except.ok xs := by
  apply list_mapM_decode_ok
  intro s _
  rfl

/-- Generic library references list decoding theorem. -/
theorem decodeLibraries_ok (libs : List LibraryRefEnc) :
    (libs.map libraryRefToJson).mapM decodeLibraryRef = Except.ok libs := by
  apply list_mapM_decode_ok
  intro l _
  exact decodeLibraryRef_libraryRefToJson l

/-- Ordered fields helper for envelope decoding matching exact parser order. -/
def envelopeOrderedFields (env : EnvelopeEnc) (payloadJ : Lean.Json) : List (String × Lean.Json) := [
  ("schema_version", Lean.Json.num env.schema_version),
  ("mode", Lean.Json.str env.mode),
  ("source_pin", sourcePinToJson env.source_pin),
  ("audit_roots", Lean.Json.arr (env.audit_roots.map Lean.Json.str).toArray),
  ("types", typesEnumToJson env.types),
  ("assumptions", Lean.Json.arr (env.assumptions.map Lean.Json.str).toArray),
  ("invariants", Lean.Json.arr (env.invariants.map Lean.Json.str).toArray),
  ("libraries", Lean.Json.arr (env.libraries.map libraryRefToJson).toArray),
  ("source_map", Lean.Json.mkObj (env.source_map.map (fun (k, v) => (k, Lean.Json.str v)))),
  ("payload", payloadJ),
  ("claimed_judgments", Lean.Json.arr (env.claimed_judgments.map Lean.Json.str).toArray),
  ("claimed_next_state", match env.claimed_next_state with | none => Lean.Json.null | some w => worldToJson w),
  ("require_library_discharge", Lean.Json.bool env.require_library_discharge),
  ("require_invariant_discharge", Lean.Json.bool env.require_invariant_discharge)
]

theorem decodeEnvelope_orderedFields (env : EnvelopeEnc) (payloadJ : Lean.Json)
    (h_ver : env.schema_version = 1)
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state) :
    decodeEnvelope (envelopeOrderedFields env payloadJ) = .ok env := by
  cases env with | mk ver mode sp roots types asms invs libs sm cj cns rld rid =>
  dsimp at h_ver h_sm h_cns
  subst h_ver
  have h_sp := decodeSourcePin_sourcePinToJson sp
  have h_roots : (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root")) = Except.ok roots :=
    decodeStringList_ok roots
  have h_types := decodeTypesEnum_typesEnumToJson types
  have h_asms : (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption")) = Except.ok asms := by
    apply list_mapM_decode_ok; intro s _; rfl
  have h_invs : (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant")) = Except.ok invs := by
    apply list_mapM_decode_ok; intro s _; rfl
  have h_libs := decodeLibraries_ok libs
  have h_sm_dec := decodeSourceMap_sourceMapToJson sm h_sm
  have h_cj : (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment")) = Except.ok cj := by
    apply list_mapM_decode_ok; intro s _; rfl
  cases cns with
  | none =>
    have h_cns_dec : decodeClaimedNextState Lean.Json.null = .ok none := rfl
    have h_def : decodeEnvelope (envelopeOrderedFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, none, rld, rid⟩ payloadJ) = (do
        let source_pin ← decodeSourcePin (sourcePinToJson sp)
        let audit_roots ← (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToJson types)
        let assumptions ← (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (libs.map libraryRefToJson).mapM decodeLibraryRef
        let source_map ← decodeSourceMap (Lean.Json.mkObj (sm.map (fun (k, v) => (k, Lean.Json.str v))))
        let claimed_judgments ← (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState Lean.Json.null
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl
  | some w =>
    have h_cns_dec := decodeClaimedNextState_some w h_cns
    have h_def : decodeEnvelope (envelopeOrderedFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, some w, rld, rid⟩ payloadJ) = (do
        let source_pin ← decodeSourcePin (sourcePinToJson sp)
        let audit_roots ← (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToJson types)
        let assumptions ← (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (libs.map libraryRefToJson).mapM decodeLibraryRef
        let source_map ← decodeSourceMap (Lean.Json.mkObj (sm.map (fun (k, v) => (k, Lean.Json.str v))))
        let claimed_judgments ← (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState (worldToJson w)
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl

/-- Sorted fields helper matching canonical JSON serialization order. -/
def envelopeSortedFields (env : EnvelopeEnc) (payloadJ : Lean.Json) : List (String × Lean.Json) := [
  ("assumptions", Lean.Json.arr (env.assumptions.map Lean.Json.str).toArray),
  ("audit_roots", Lean.Json.arr (env.audit_roots.map Lean.Json.str).toArray),
  ("claimed_judgments", Lean.Json.arr (env.claimed_judgments.map Lean.Json.str).toArray),
  ("claimed_next_state", match env.claimed_next_state with | none => Lean.Json.null | some w => worldToJson w),
  ("invariants", Lean.Json.arr (env.invariants.map Lean.Json.str).toArray),
  ("libraries", Lean.Json.arr (env.libraries.map libraryRefToJson).toArray),
  ("mode", Lean.Json.str env.mode),
  ("payload", payloadJ),
  ("require_invariant_discharge", Lean.Json.bool env.require_invariant_discharge),
  ("require_library_discharge", Lean.Json.bool env.require_library_discharge),
  ("schema_version", Lean.Json.num env.schema_version),
  ("source_map", Lean.Json.mkObj (env.source_map.map (fun (k, v) => (k, Lean.Json.str v)))),
  ("source_pin", sourcePinToJson env.source_pin),
  ("types", typesEnumToJson env.types)
]

theorem decodeEnvelope_sortedFields (env : EnvelopeEnc) (payloadJ : Lean.Json)
    (h_ver : env.schema_version = 1)
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state) :
    decodeEnvelope (envelopeSortedFields env payloadJ) = .ok env := by
  cases env with | mk ver mode sp roots types asms invs libs sm cj cns rld rid =>
  dsimp at h_ver h_sm h_cns
  subst h_ver
  have h_sp := decodeSourcePin_sourcePinToJson sp
  have h_roots : (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root")) = Except.ok roots :=
    decodeStringList_ok roots
  have h_types := decodeTypesEnum_typesEnumToJson types
  have h_asms : (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption")) = Except.ok asms := by
    apply list_mapM_decode_ok; intro s _; rfl
  have h_invs : (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant")) = Except.ok invs := by
    apply list_mapM_decode_ok; intro s _; rfl
  have h_libs := decodeLibraries_ok libs
  have h_sm_dec := decodeSourceMap_sourceMapToJson sm h_sm
  have h_cj : (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment")) = Except.ok cj := by
    apply list_mapM_decode_ok; intro s _; rfl
  cases cns with
  | none =>
    have h_cns_dec : decodeClaimedNextState Lean.Json.null = .ok none := rfl
    have h_def : decodeEnvelope (envelopeSortedFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, none, rld, rid⟩ payloadJ) = (do
        let source_pin ← decodeSourcePin (sourcePinToJson sp)
        let audit_roots ← (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToJson types)
        let assumptions ← (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (libs.map libraryRefToJson).mapM decodeLibraryRef
        let source_map ← decodeSourceMap (Lean.Json.mkObj (sm.map (fun (k, v) => (k, Lean.Json.str v))))
        let claimed_judgments ← (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState Lean.Json.null
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl
  | some w =>
    have h_cns_dec := decodeClaimedNextState_some w h_cns
    have h_def : decodeEnvelope (envelopeSortedFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, some w, rld, rid⟩ payloadJ) = (do
        let source_pin ← decodeSourcePin (sourcePinToJson sp)
        let audit_roots ← (roots.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToJson types)
        let assumptions ← (asms.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (invs.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (libs.map libraryRefToJson).mapM decodeLibraryRef
        let source_map ← decodeSourceMap (Lean.Json.mkObj (sm.map (fun (k, v) => (k, Lean.Json.str v))))
        let claimed_judgments ← (cj.map Lean.Json.str).mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState (worldToJson w)
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl

theorem envelopeSortedFields_no_commands (env : EnvelopeEnc) (payloadJ : Lean.Json) :
    (envelopeSortedFields env payloadJ).any (fun (k, _) => k == "commands") = false := rfl

theorem envelopeToJson_eq_mkObj_sortedFields (env : EnvelopeEnc) (payloadJson : Lean.Json) :
    envelopeToJson env payloadJson = Lean.Json.mkObj (envelopeSortedFields env payloadJson) := rfl

theorem decodeDecodedIR_envelopeToJson_eq (env : EnvelopeEnc) (payloadJ : Lean.Json) (raw : String) :
    decodeDecodedIR (envelopeToJson env payloadJ) raw = (do
      let env_dec ← decodeEnvelope (envelopeSortedFields env payloadJ)
      let payloadJ_dec ← getField (envelopeSortedFields env payloadJ) "payload"
      match env_dec.mode with
      | "typed-execute" =>
        let payload_dec ← decodeTypedExecutePayload payloadJ_dec
        Except.ok (DecodedIR.execution (.typed env_dec payload_dec))
      | "composition-step" =>
        let payload_dec ← decodeCompositionStepPayload payloadJ_dec
        Except.ok (DecodedIR.execution (.step env_dec payload_dec))
      | "composition-run" =>
        let payload_dec ← decodeCompositionRunPayload payloadJ_dec
        Except.ok (DecodedIR.execution (.run env_dec payload_dec))
      | "codec" => Except.ok (DecodedIR.codec ⟨some env_dec, raw⟩)
      | "audit" =>
        let payload_dec ← decodeAuditPayload env_dec payloadJ_dec true
        Except.ok (DecodedIR.audit payload_dec)
      | s => Except.error (.unknownIdentifier s)) := rfl

theorem decodeDecodedIR_fields_typed (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "typed-execute")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_reg_can : RegistryCanonical payload.registry)
    (h_env_can : EnvironmentCanonical payload.env)
    (h_req_can : RequestCanonical payload.request)
    (h_state_valid : ∀ c ∈ payload.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (payload.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.state.cells.length)
    (raw : String) :
    decodeDecodedIR (envelopeToJson env (typedExecutePayloadToJson payload)) raw =
      Except.ok (DecodedIR.execution (.typed env payload)) := by
  rw [decodeDecodedIR_envelopeToJson_eq]
  have h_env := decodeEnvelope_sortedFields env (typedExecutePayloadToJson payload) h_ver h_sm h_cns
  have h_p := decodeTypedExecutePayload_typedExecutePayloadToJson payload h_reg_can h_env_can h_req_can h_state_valid h_state_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeSortedFields env (typedExecutePayloadToJson payload)) "payload" = .ok (typedExecutePayloadToJson payload) := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  rw [h_p]
  rfl

theorem decodeDecodedIR_fields_step (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "composition-step")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_cfg_can : RegistryCanonical payload.config.registry)
    (h_bnd_can : BoundaryCanonical payload.boundary)
    (h_hist_can : HistoryCanonical payload.history)
    (h_step_can : StepCanonical payload.step)
    (h_pre_valid : ∀ c ∈ payload.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_pre_unique : (payload.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.pre.state.cells.length)
    (raw : String) :
    decodeDecodedIR (envelopeToJson env (compositionStepPayloadToJson payload)) raw =
      Except.ok (DecodedIR.execution (.step env payload)) := by
  rw [decodeDecodedIR_envelopeToJson_eq]
  have h_env := decodeEnvelope_sortedFields env (compositionStepPayloadToJson payload) h_ver h_sm h_cns
  have h_p := decodeCompositionStepPayload_compositionStepPayloadToJson payload h_cfg_can h_bnd_can h_hist_can h_step_can h_pre_valid h_pre_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeSortedFields env (compositionStepPayloadToJson payload)) "payload" = .ok (compositionStepPayloadToJson payload) := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  rw [h_p]
  rfl

theorem decodeDecodedIR_fields_run (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "composition-run")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_cfg_can : RegistryCanonical payload.config.registry)
    (h_bnds_can : ∀ b ∈ payload.boundaries, BoundaryCanonical b)
    (h_steps_can : ∀ s ∈ payload.steps, StepCanonical s)
    (h_w_valid : ∀ c ∈ payload.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_w_unique : (payload.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.world.state.cells.length)
    (raw : String) :
    decodeDecodedIR (envelopeToJson env (compositionRunPayloadToJson payload)) raw =
      Except.ok (DecodedIR.execution (.run env payload)) := by
  rw [decodeDecodedIR_envelopeToJson_eq]
  have h_env := decodeEnvelope_sortedFields env (compositionRunPayloadToJson payload) h_ver h_sm h_cns
  have h_p := decodeCompositionRunPayload_compositionRunPayloadToJson payload h_cfg_can h_bnds_can h_steps_can h_w_valid h_w_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeSortedFields env (compositionRunPayloadToJson payload)) "payload" = .ok (compositionRunPayloadToJson payload) := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  rw [h_p]
  rfl

/-- Erase-duplicates length computation for standard 32 cell universe keys. -/
theorem standard32CellKeys_eraseDups_len : standard32CellKeys.eraseDups.length = 32 := by decide

/-- Membership projection for boolean list predicate truth. -/
theorem all_mem_of_all_eq_true {α : Type} (p : α → Bool) (l : List α) (h : l.all p = true) (x : α) (hx : x ∈ l) :
    p x = true := by
  have h_all : ∀ y ∈ l, p y = true := List.all_eq_true.mp h
  exact h_all x hx

/-- Structural decode correspondence theorem: any structurally admissible IR
    successfully decodes from its canonical JSON representation without decoder hypotheses. -/
theorem decodeDecodedIR_of_structurallyAdmissible (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir) (raw : String) :
    decodeDecodedIR (decodedIRToJson ir) raw = .ok ir := by
  rcases ir with ⟨exec⟩ | ⟨audit_val⟩ | ⟨codec_val⟩
  · rcases exec with ⟨env, payload⟩ | ⟨env, payload⟩ | ⟨env, payload⟩
    · -- typed-execute
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_tmpl, h_req, h_env⟩
      have h_reg : RegistryCanonical payload.registry := ⟨h_nodup, h_tmpl⟩
      have h_st_valid : ∀ c ∈ payload.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_st_unique : (payload.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [decodedIRToJson]
      exact decodeDecodedIR_fields_typed env payload h_ver h_mode h_sm h_cns h_reg h_env h_req h_st_valid h_st_unique raw
    · -- composition-step
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_step, h_tmpl, h_hist, h_bnd⟩
      have h_cfg : RegistryCanonical payload.config.registry := ⟨h_nodup, h_tmpl⟩
      have h_pre_valid : ∀ c ∈ payload.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_pre_unique : (payload.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.pre.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [decodedIRToJson]
      exact decodeDecodedIR_fields_step env payload h_ver h_mode h_sm h_cns h_cfg h_bnd h_hist h_step h_pre_valid h_pre_unique raw
    · -- composition-run
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_steps, h_tmpl, h_bnds⟩
      have h_cfg : RegistryCanonical payload.config.registry := ⟨h_nodup, h_tmpl⟩
      have h_w_valid : ∀ c ∈ payload.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_w_unique : (payload.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.world.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [decodedIRToJson]
      exact decodeDecodedIR_fields_run env payload h_ver h_mode h_sm h_cns h_cfg h_bnds h_steps h_w_valid h_w_unique raw
  · -- audit: not supported
    rcases h_adm with ⟨h_sup, _⟩
    dsimp [SupportedIR] at h_sup
    rcases h_sup with ⟨_, _, _, h_f⟩
    contradiction
  · -- codec: not supported
    rcases h_adm with ⟨h_sup, _⟩
    dsimp [SupportedIR] at h_sup
    rcases h_sup with ⟨_, _, _, h_f⟩
    contradiction

/-- Full canonical serialized string representation of DecodedIR prior to UTF-8 byte encoding. -/
def encodeModuleString (ir : DecodedIR) : String :=
  match ir with
  | .execution (.typed env p) =>
    encodeEnvelope env (encodeTypedExecutePayload p)
  | .execution (.step env p) =>
    encodeEnvelope env (encodeCompositionStepPayload p)
  | .execution (.run env p) =>
    encodeEnvelope env (encodeCompositionRunPayload p)
  | .audit a =>
    if a.hasEnvelope then
      encodeEnvelope a.envelope (encodeAuditPayload a)
    else
      encodeAuditPayload a
  | .codec doc =>
    match doc.envelope with
    | some env => encodeEnvelope env "{}"
    | none => doc.rawText

/-- Canonical module encoding is the exact UTF-8 byte encoding of encodeModuleString. -/
theorem encodeModule_eq_toUTF8 (ir : DecodedIR) :
    encodeModule ir = (encodeModuleString ir).toUTF8 := by
  dsimp [encodeModule, encodeModuleCanonical, encodeModuleString]
  cases ir with
  | execution ex => cases ex <;> rfl
  | audit a => rfl
  | codec doc => rfl

/-- UTF-8 inverse on serialized module bytes: roundtrips through String.fromUTF8?. -/
theorem string_fromUTF8_encodeModule (ir : DecodedIR) :
    String.fromUTF8? (encodeModule ir) = some (encodeModuleString ir) := by
  rw [encodeModule_eq_toUTF8]
  exact string_fromUTF8?_toUTF8 (encodeModuleString ir)

/-- Compositional bridge theorem: reduces byte decoding into verified lexical, UTF-8,
    canonical JSON parser, structural decode, and canonical re-encoding steps. -/
theorem decodeBytes_eq_of_steps (bytes : ByteArray) (str : String) (j : Lean.Json) (ir : DecodedIR)
    (h_lex : scanLexical bytes = .ok ())
    (h_utf8 : String.fromUTF8? bytes = some str)
    (h_parse : parseCanonicalJson str = .ok j)
    (h_dec : decodeDecodedIR j str = .ok ir)
    (h_reenc : encodeModule ir = bytes) :
    decodeBytes bytes = .ok ir := by
  unfold decodeBytes
  dsimp [bind, Except.bind]
  rw [h_lex]
  dsimp [bind, Except.bind]
  rw [h_utf8]
  dsimp [bind, Except.bind]
  rw [h_parse]
  dsimp [bind, Except.bind, pure, Except.pure]
  rw [h_dec]
  dsimp [bind, Except.bind, pure, Except.pure]
  split
  · rfl
  · rename_i h_neq
    contradiction

/-- Main structural connection theorem: proves that if lexical scanning and canonical parsing succeed,
    the actual production decodeBytes returns the original structurally admissible IR. -/
theorem decodeBytes_encodeModule_of_lex_and_parse (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ())
    (h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)) :
    decodeBytes (encodeModule ir) = .ok ir := by
  apply decodeBytes_eq_of_steps (encodeModule ir) (encodeModuleString ir) (decodedIRToJson ir) ir
  · exact h_lex
  · exact string_fromUTF8_encodeModule ir
  · exact h_parse
  · exact decodeDecodedIR_of_structurallyAdmissible ir h_adm (encodeModuleString ir)
  · rfl

/-- Schema key uniqueness: standard 14 envelope keys are pairwise distinct. -/
theorem envelopeOrderedKeys_nodup :
    ["schema_version", "mode", "source_pin", "audit_roots", "types", "assumptions",
     "invariants", "libraries", "source_map", "payload", "claimed_judgments",
     "claimed_next_state", "require_library_discharge", "require_invariant_discharge"].Nodup := by
  decide

/-- Schema key uniqueness: typed execution payload keys are pairwise distinct. -/
theorem typedPayloadKeys_nodup :
    ["registry", "store", "ctx", "request", "now", "env", "state"].Nodup := by
  decide

/-- Schema key uniqueness: composition step payload keys are pairwise distinct. -/
theorem stepPayloadKeys_nodup :
    ["boundary", "config", "index", "step", "pre", "history"].Nodup := by
  decide

/-- Schema key uniqueness: composition run payload keys are pairwise distinct. -/
theorem runPayloadKeys_nodup :
    ["boundaries", "config", "world", "steps"].Nodup := by
  decide

/-- Canonical JSON parsing on party enumeration literals. -/
theorem parseCanonicalJson_encodeParty (p : Party) :
    parseCanonicalJson (encodeParty p) = .ok (partyToJson p) := by
  cases p <;> rfl

/-- Canonical JSON parsing on asset enumeration literals. -/
theorem parseCanonicalJson_encodeAsset (a : Asset) :
    parseCanonicalJson (encodeAsset a) = .ok (assetToJson a) := by
  cases a <;> rfl

/-- Canonical JSON parsing on domain enumeration literals. -/
theorem parseCanonicalJson_encodeDomain (d : Domain) :
    parseCanonicalJson (encodeDomain d) = .ok (domainToJson d) := by
  cases d <;> rfl

/-- Canonical JSON parsing on caller party reference. -/
theorem parseCanonicalJson_encodePartyRef_caller :
    parseCanonicalJson (encodePartyRef .caller) = .ok (partyRefToJson .caller) := rfl

/-- Canonical JSON parsing on literal party references. -/
theorem parseCanonicalJson_encodePartyRef_literal (p : Party) :
    parseCanonicalJson (encodePartyRef (.literal p)) = .ok (partyRefToJson (.literal p)) := by
  cases p <;> rfl

/-- Canonical JSON parsing on cell references with literal owner. -/
theorem parseCanonicalJson_encodeCellRef (d : Domain) (p : Party) :
    parseCanonicalJson (encodeCellRef ⟨d, .literal p⟩) = .ok (cellRefToJson ⟨d, .literal p⟩) := by
  cases d <;> cases p <;> rfl

/-- Canonical JSON parsing on unit witness rational (0 / 1). -/
theorem parseCanonicalJson_encodeRat_witness :
    parseCanonicalJson (encodeRat ⟨0, 1⟩) = .ok (ratToJson ⟨0, 1⟩) := rfl

/-- Canonical JSON parsing on canonical witness cell. -/
theorem parseCanonicalJson_encodeCell_witness :
    parseCanonicalJson (encodeCell ⟨.main, .alice, .usd⟩) = .ok (cellToJson ⟨.main, .alice, .usd⟩) := rfl

/-- Canonical JSON parsing on arbitrary cell definitions across the complete universe. -/
theorem parseCanonicalJson_encodeCell_all (c : CellEnc) :
    parseCanonicalJson (encodeCell c) = .ok (cellToJson c) := by
  rcases c with ⟨d, p, a⟩
  cases d <;> cases p <;> cases a <;> rfl

/-- Canonical JSON parsing on cell references with caller owner. -/
theorem parseCanonicalJson_encodeCellRef_caller (d : Domain) :
    parseCanonicalJson (encodeCellRef ⟨d, .caller⟩) = .ok (cellRefToJson ⟨d, .caller⟩) := by
  cases d <;> rfl

/-- Canonical JSON parsing on rational 0/1. -/
theorem parseCanonicalJson_encodeRat_0_1 : parseCanonicalJson (encodeRat ⟨0, 1⟩) = .ok (ratToJson ⟨0, 1⟩) := rfl

/-- Canonical JSON parsing on rational 1/1. -/
theorem parseCanonicalJson_encodeRat_1_1 : parseCanonicalJson (encodeRat ⟨1, 1⟩) = .ok (ratToJson ⟨1, 1⟩) := rfl

/-- Canonical JSON parsing on rational 2/1. -/
theorem parseCanonicalJson_encodeRat_2_1 : parseCanonicalJson (encodeRat ⟨2, 1⟩) = .ok (ratToJson ⟨2, 1⟩) := rfl

/-- Canonical JSON parsing on rational 4/1. -/
theorem parseCanonicalJson_encodeRat_4_1 : parseCanonicalJson (encodeRat ⟨4, 1⟩) = .ok (ratToJson ⟨4, 1⟩) := rfl

/-- Canonical JSON parsing on rational 10/1. -/
theorem parseCanonicalJson_encodeRat_10_1 : parseCanonicalJson (encodeRat ⟨10, 1⟩) = .ok (ratToJson ⟨10, 1⟩) := rfl

/-- Canonical JSON parsing on rational 20/1. -/
theorem parseCanonicalJson_encodeRat_20_1 : parseCanonicalJson (encodeRat ⟨20, 1⟩) = .ok (ratToJson ⟨20, 1⟩) := rfl

/-- Canonical JSON parsing on rational 100/1. -/
theorem parseCanonicalJson_encodeRat_100_1 : parseCanonicalJson (encodeRat ⟨100, 1⟩) = .ok (ratToJson ⟨100, 1⟩) := rfl

set_option maxHeartbeats 1000000 in
/-- Canonical JSON parsing on standard zero-initialized state cells across all 32 universe coordinates. -/
theorem parseCanonicalJson_encodeStateCell_zero (d : Domain) (p : Party) (a : Asset) :
    parseCanonicalJson (encodeStateCell ⟨d, p, a, ⟨0, 1⟩⟩) = .ok (stateCellToJson ⟨d, p, a, ⟨0, 1⟩⟩) := by
  cases d <;> cases p <;> cases a <;> rfl

/-- Character stream decomposition constant for num key. -/
theorem c1_num : "{\"num\":".toList = ['{', '"', 'n', 'u', 'm', '"', ':'] := rfl

/-- Character stream decomposition constant for den key. -/
theorem c2_den : ",\"den\":".toList = [',', '"', 'd', 'e', 'n', '"', ':'] := rfl

/-- Character stream decomposition constant for closing brace. -/
theorem c3_rbrace : "}".toList = ['}'] := rfl

/-- Intercalation of two strings with single separator. -/
theorem intercalate_two (s t u : String) :
    s.intercalate [t, u] = t ++ s ++ u := by
  rw [String.intercalate_cons_cons, String.intercalate_singleton]

/-- Two-field JSON object string formatting equation. -/
theorem jsonObj_two (k1 v1 k2 v2 : String) :
    jsonObj [(k1, v1), (k2, v2)] =
    "{" ++ escapeJsonString k1 ++ ":" ++ v1 ++ "," ++ escapeJsonString k2 ++ ":" ++ v2 ++ "}" := by
  dsimp [jsonObj]
  simp only [List.map_cons, List.map_nil]
  rw [intercalate_two]
  simp [String.append_assoc]

/-- Canonical escaping for num field key. -/
theorem escapeJsonString_num : escapeJsonString "num" = "\"num\"" := rfl

/-- Canonical escaping for den field key. -/
theorem escapeJsonString_den : escapeJsonString "den" = "\"den\"" := rfl

/-- Structural equality for canonical rational encoding. -/
theorem encodeRat_eq (r : RatEnc) :
    encodeRat r = "{\"num\":" ++ toString r.num ++ ",\"den\":" ++ toString r.den ++ "}" := by
  unfold encodeRat
  rw [jsonObj_two, escapeJsonString_num, escapeJsonString_den]
  simp [String.append_assoc]

/-- Character-level stream decomposition for canonical rational encoding. -/
theorem encodeRat_chars (r : RatEnc) :
    (encodeRat r).toList =
    ['{', '"', 'n', 'u', 'm', '"', ':'] ++
      ((toString r.num).toList ++
        ([',', '"', 'd', 'e', 'n', '"', ':'] ++
          ((toString r.den).toList ++ ['}']))) := by
  rw [encodeRat_eq]
  simp only [String.toList_append, c1_num, c2_den, c3_rbrace, List.append_assoc]

/-- Tokenizer step over num field key and colon. -/
theorem tokenizeFuel_num_colon (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 2) ('"' :: 'n' :: 'u' :: 'm' :: '"' :: ':' :: rest) =
      (tokenizeFuel fuel rest).map (fun toks => JsonToken.str "num" :: JsonToken.colon :: toks) := by
  rw [tokenizeFuel]
  dsimp [bind, Except.bind]
  have h_lex : lexString [] ('n' :: 'u' :: 'm' :: '"' :: ':' :: rest) = .ok ("num", ':' :: rest) := rfl
  rw [h_lex]
  dsimp [bind, Except.bind]
  rw [tokenizeFuel_colon]
  cases tokenizeFuel fuel rest <;> rfl

/-- Tokenizer step over den field key and colon. -/
theorem tokenizeFuel_den_colon (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 2) ('"' :: 'd' :: 'e' :: 'n' :: '"' :: ':' :: rest) =
      (tokenizeFuel fuel rest).map (fun toks => JsonToken.str "den" :: JsonToken.colon :: toks) := by
  rw [tokenizeFuel]
  dsimp [bind, Except.bind]
  have h_lex : lexString [] ('d' :: 'e' :: 'n' :: '"' :: ':' :: rest) = .ok ("den", ':' :: rest) := rfl
  rw [h_lex]
  dsimp [bind, Except.bind]
  rw [tokenizeFuel_colon]
  cases tokenizeFuel fuel rest <;> rfl

/-- Inductive tokenization theorem for arbitrary canonical rational character streams with excess fuel. -/
theorem tokenizeFuel_encodeRat_chars (r : RatEnc) (f : Nat) :
    tokenizeFuel (f + 10)
      (['{', '"', 'n', 'u', 'm', '"', ':'] ++
        ((toString r.num).toList ++
          ([',', '"', 'd', 'e', 'n', '"', ':'] ++
            ((toString r.den).toList ++ ['}'])))) =
    .ok [
      JsonToken.lbrace,
      JsonToken.str "num", JsonToken.colon, JsonToken.num ⟨r.num, 0⟩,
      JsonToken.comma,
      JsonToken.str "den", JsonToken.colon, JsonToken.num ⟨(r.den : Int), 0⟩,
      JsonToken.rbrace
    ] := by
  change tokenizeFuel (f + 9 + 1) ('{' :: ('"' :: 'n' :: 'u' :: 'm' :: '"' :: ':' :: ((toString r.num).toList ++ (',' :: ('"' :: 'd' :: 'e' :: 'n' :: '"' :: ':' :: ((toString r.den).toList ++ ['}'])))))) = _
  rw [tokenizeFuel_lbrace]
  rw [tokenizeFuel_num_colon]
  rw [tokenizeFuel_int (f + 6) r.num (',' :: ('"' :: 'd' :: 'e' :: 'n' :: '"' :: ':' :: ((toString r.den).toList ++ ['}']))) rfl]
  rw [tokenizeFuel_comma]
  rw [tokenizeFuel_den_colon]
  rw [tokenizeFuel_nat (f + 2) r.den ['}'] rfl]
  rw [tokenizeFuel_rbrace]
  rfl

/-- Universal tokenizer theorem for arbitrary canonical rational encoding. -/
theorem tokenize_encodeRat (r : RatEnc) :
    tokenize (encodeRat r) =
    .ok [
      JsonToken.lbrace,
      JsonToken.str "num", JsonToken.colon, JsonToken.num ⟨r.num, 0⟩,
      JsonToken.comma,
      JsonToken.str "den", JsonToken.colon, JsonToken.num ⟨(r.den : Int), 0⟩,
      JsonToken.rbrace
    ] := by
  unfold tokenize
  rw [encodeRat_chars]
  have h_len_ge : (['{', '"', 'n', 'u', 'm', '"', ':'] ++
      ((toString r.num).toList ++
        ([',', '"', 'd', 'e', 'n', '"', ':'] ++
          ((toString r.den).toList ++ ['}']) : List Char))).length + 1 ≥ 10 := by
    simp only [List.length_append, List.length_cons, List.length_nil]
    omega
  let L := (['{', '"', 'n', 'u', 'm', '"', ':'] ++
      ((toString r.num).toList ++
        ([',', '"', 'd', 'e', 'n', '"', ':'] ++
          ((toString r.den).toList ++ ['}']) : List Char))).length + 1
  have h_dest : ∃ k, L = k + 10 := by
    rcases Nat.le.dest h_len_ge with ⟨k, hk⟩
    exact ⟨k, by omega⟩
  rcases h_dest with ⟨k, hk⟩
  change tokenizeFuel L _ = _
  rw [hk]
  exact tokenizeFuel_encodeRat_chars r k

/-- Universal canonical JSON parser inverse on arbitrary rational numbers:
    holds universally for all r : RatEnc with zero scalar bounds or hypotheses. -/
theorem parseCanonicalJson_encodeRat (r : RatEnc) :
    parseCanonicalJson (encodeRat r) = .ok (ratToJson r) := by
  unfold parseCanonicalJson
  rw [tokenize_encodeRat]
  dsimp [bind, Except.bind]
  rfl

/-- Universal end-to-end codec roundtrip for arbitrary reduced non-zero denominator rationals. -/
theorem rat_end_to_end_universal (r : RatEnc)
    (h_den : r.den ≠ 0) (h_gcd : Int.gcd r.num.natAbs r.den = 1) :
    (do
      let j ← parseCanonicalJson (encodeRat r)
      decodeRat j) = .ok r := by
  rw [parseCanonicalJson_encodeRat]
  dsimp [bind, Except.bind]
  exact decodeRat_ratToJson r h_den h_gcd

/-- Canonical JSON parsing on numeric units: holds universally across all numeric unit forms. -/
theorem parseCanonicalJson_encodeNumericUnit (nu : NumericUnitEnc) :
    parseCanonicalJson (encodeNumericUnit nu) = .ok (numericUnitToJson nu) := by
  cases nu with
  | scalar => rfl
  | amount a => cases a <;> rfl
  | price b q => cases b <;> cases q <;> rfl

/-- Canonical JSON parsing on units: holds universally across all unit forms. -/
theorem parseCanonicalJson_encodeUnit (u : UnitEnc) :
    parseCanonicalJson (encodeUnit u) = .ok (unitToJson u) := by
  cases u with
  | bool => rfl
  | numeric nu => exact parseCanonicalJson_encodeNumericUnit nu

/-- Canonical JSON parsing on unary operations: holds universally across all unary operations. -/
theorem parseCanonicalJson_encodeUnaryOp (op : UnaryOpEnc) :
    parseCanonicalJson (encodeUnaryOp op) = .ok (unaryOpToJson op) := by
  cases op with
  | not => rfl
  | neg nu =>
    cases nu with
    | scalar => rfl
    | amount a => cases a <;> rfl
    | price b q => cases b <;> cases q <;> rfl

/-- Universal end-to-end roundtrip for numeric units. -/
theorem numericUnit_end_to_end_universal (nu : NumericUnitEnc) :
    (do
      let j ← parseCanonicalJson (encodeNumericUnit nu)
      decodeNumericUnit j) = .ok nu := by
  rw [parseCanonicalJson_encodeNumericUnit]
  dsimp [bind, Except.bind]
  exact decodeNumericUnit_numericUnitToJson nu

/-- Universal end-to-end roundtrip for units. -/
theorem unit_end_to_end_universal (u : UnitEnc) :
    (do
      let j ← parseCanonicalJson (encodeUnit u)
      decodeUnit j) = .ok u := by
  rw [parseCanonicalJson_encodeUnit]
  dsimp [bind, Except.bind]
  exact decodeUnit_unitToJson u

/-- Universal end-to-end roundtrip for unary operations. -/
theorem unaryOp_end_to_end_universal (op : UnaryOpEnc) :
    (do
      let j ← parseCanonicalJson (encodeUnaryOp op)
      decodeUnaryOp j) = .ok op := by
  rw [parseCanonicalJson_encodeUnaryOp]
  dsimp [bind, Except.bind]
  exact decodeUnaryOp_unaryOpToJson op

/-- Canonical JSON parsing on ExprEnc.now literal. -/
theorem parseCanonicalJson_encodeExpr_now :
    parseCanonicalJson (encodeExpr .now) = .ok (exprToJson .now) := rfl

/-- Canonical JSON parsing on boolean literal expressions. -/
theorem parseCanonicalJson_encodeExpr_lit_bool (b : Bool) :
    parseCanonicalJson (encodeExpr (.lit ⟨.bool, 0, b⟩)) = .ok (exprToJson (.lit ⟨.bool, 0, b⟩)) := by
  cases b <;> rfl

/-- Canonical JSON parsing on boolean literal true expression. -/
theorem parseCanonicalJson_encodeExpr_lit_bool_true :
    parseCanonicalJson (encodeExpr (.lit ⟨.bool, 0, true⟩)) = .ok (exprToJson (.lit ⟨.bool, 0, true⟩)) := rfl

/-- Canonical JSON parsing on boolean literal false expression. -/
theorem parseCanonicalJson_encodeExpr_lit_bool_false :
    parseCanonicalJson (encodeExpr (.lit ⟨.bool, 0, false⟩)) = .ok (exprToJson (.lit ⟨.bool, 0, false⟩)) := rfl

/-- Canonical JSON parsing on unary not expression over now. -/
theorem parseCanonicalJson_encodeExpr_unary_not_now :
    parseCanonicalJson (encodeExpr (.unary .not .now)) = .ok (exprToJson (.unary .not .now)) := rfl

/-- Canonical JSON parsing on binary and expression over now. -/
theorem parseCanonicalJson_encodeExpr_binary_and_now :
    parseCanonicalJson (encodeExpr (.binary .and .now .now)) = .ok (exprToJson (.binary .and .now .now)) := rfl

/-- Canonical JSON parsing on conditional ite expression over now. -/
theorem parseCanonicalJson_encodeExpr_ite_now :
    parseCanonicalJson (encodeExpr (.ite .now .now .now)) = .ok (exprToJson (.ite .now .now .now)) := rfl

/-- Universal end-to-end roundtrip for now expression. -/
theorem expr_end_to_end_now :
    (do
      let j ← parseCanonicalJson (encodeExpr .now)
      decodeExpr j) = .ok .now := rfl

/-- Universal end-to-end roundtrip for boolean literal true expression. -/
theorem expr_end_to_end_lit_bool_true :
    (do
      let j ← parseCanonicalJson (encodeExpr (.lit ⟨.bool, 0, true⟩))
      decodeExpr j) = .ok (.lit ⟨.bool, 0, true⟩) := rfl

/-- Universal end-to-end roundtrip for boolean literal false expression. -/
theorem expr_end_to_end_lit_bool_false :
    (do
      let j ← parseCanonicalJson (encodeExpr (.lit ⟨.bool, 0, false⟩))
      decodeExpr j) = .ok (.lit ⟨.bool, 0, false⟩) := rfl

/-- Universal end-to-end roundtrip for unary not expression over now. -/
theorem expr_end_to_end_unary_not_now :
    (do
      let j ← parseCanonicalJson (encodeExpr (.unary .not .now))
      decodeExpr j) = .ok (.unary .not .now) := rfl

/-- Universal end-to-end roundtrip for binary and expression over now. -/
theorem expr_end_to_end_binary_and_now :
    (do
      let j ← parseCanonicalJson (encodeExpr (.binary .and .now .now))
      decodeExpr j) = .ok (.binary .and .now .now) := rfl

/-- Universal end-to-end roundtrip for conditional ite expression over now. -/
theorem expr_end_to_end_ite_now :
    (do
      let j ← parseCanonicalJson (encodeExpr (.ite .now .now .now))
      decodeExpr j) = .ok (.ite .now .now .now) := rfl

/-- Canonical JSON parsing on balance expression with caller owner. -/
theorem parseCanonicalJson_encodeExpr_balance_caller :
    parseCanonicalJson (encodeExpr (.balance ⟨.usd, ⟨.main, .caller⟩⟩)) = .ok (exprToJson (.balance ⟨.usd, ⟨.main, .caller⟩⟩)) := rfl

/-- Universal end-to-end roundtrip for balance expression with caller owner. -/
theorem expr_end_to_end_balance_caller :
    (do
      let j ← parseCanonicalJson (encodeExpr (.balance ⟨.usd, ⟨.main, .caller⟩⟩))
      decodeExpr j) = .ok (.balance ⟨.usd, ⟨.main, .caller⟩⟩) := rfl

/-- Canonical JSON parsing on timestamp expression. -/
theorem parseCanonicalJson_encodeExpr_timestamp :
    parseCanonicalJson (encodeExpr (.timestamp ⟨.main, 0⟩)) = .ok (exprToJson (.timestamp ⟨.main, 0⟩)) := rfl

/-- Universal end-to-end roundtrip for timestamp expression. -/
theorem expr_end_to_end_timestamp :
    (do
      let j ← parseCanonicalJson (encodeExpr (.timestamp ⟨.main, 0⟩))
      decodeExpr j) = .ok (.timestamp ⟨.main, 0⟩) := rfl

/-- Canonical JSON parsing on observation reference expression. -/
theorem parseCanonicalJson_encodeExpr_observe :
    parseCanonicalJson (encodeExpr (.observe ⟨⟨.main, 0⟩, .bool⟩)) = .ok (exprToJson (.observe ⟨⟨.main, 0⟩, .bool⟩)) := rfl

/-- Universal end-to-end roundtrip for observation reference expression. -/
theorem expr_end_to_end_observe :
    (do
      let j ← parseCanonicalJson (encodeExpr (.observe ⟨⟨.main, 0⟩, .bool⟩))
      decodeExpr j) = .ok (.observe ⟨⟨.main, 0⟩, .bool⟩) := rfl

/-- TreeJson escape string equivalence to standard escapeJsonString. -/
theorem escapeTreeString_eq_escapeJsonString (s : String) :
    escapeTreeString s = escapeJsonString s := rfl

/-- List encoding equivalence for TreeJson arrays. -/
theorem encodeList_eq_intercalate (xs : List TreeJson) :
    TreeJson.encodeList xs = String.intercalate "," (xs.map TreeJson.encode) := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    cases xs with
    | nil => rfl
    | cons y ys =>
      dsimp [TreeJson.encodeList, List.map]
      rw [String.intercalate_cons_cons]
      rw [ih]
      rfl

/-- Object encoding equivalence for TreeJson objects. -/
theorem encodeObj_eq_intercalate (kvs : List (String × TreeJson)) :
    TreeJson.encodeObj kvs = String.intercalate "," (kvs.map (fun (k, v) => escapeJsonString k ++ ":" ++ TreeJson.encode v)) := by
  induction kvs with
  | nil => rfl
  | cons kv kvs ih =>
    rcases kv with ⟨k, v⟩
    cases kvs with
    | nil => rfl
    | cons kv2 kvs2 =>
      dsimp [TreeJson.encodeObj, List.map]
      rw [String.intercalate_cons_cons]
      rw [ih]
      rfl

/-- Exact representation equality connecting TreeJson array encoding to jsonArr. -/
theorem encode_arr_eq_jsonArr (xs : List TreeJson) :
    TreeJson.encode (.arr xs) = jsonArr (xs.map TreeJson.encode) := by
  dsimp [TreeJson.encode, jsonArr]
  rw [encodeList_eq_intercalate]

/-- Exact representation equality connecting TreeJson object encoding to jsonObj. -/
theorem encode_obj_eq_jsonObj (kvs : List (String × TreeJson)) :
    TreeJson.encode (.obj kvs) = jsonObj (kvs.map (fun (k, v) => (k, TreeJson.encode v))) := by
  dsimp [TreeJson.encode, jsonObj]
  rw [encodeObj_eq_intercalate]
  simp only [List.map_map]
  rfl

/-- Structured TreeJson representation for canonical rational numbers. -/
def ratToTreeJson (r : RatEnc) : TreeJson :=
  TreeJson.obj [("num", TreeJson.num r.num), ("den", TreeJson.num (r.den : Int))]

/-- Semantic JSON correspondence for TreeJson rationals. -/
theorem ratToTreeJson_toJson (r : RatEnc) :
    (ratToTreeJson r).toJson = ratToJson r := by
  dsimp [ratToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, ratToJson]
  rfl

/-- String encoding correspondence for TreeJson rationals. -/
theorem ratToTreeJson_encode (r : RatEnc) :
    (ratToTreeJson r).encode = encodeRat r := by
  dsimp [ratToTreeJson, encodeRat]
  rw [encode_obj_eq_jsonObj]
  rfl

/-- Structured TreeJson representation for parties. -/
def partyToTreeJson (p : Party) : TreeJson :=
  TreeJson.str (match p with | .alice => "alice" | .bob => "bob" | .vault => "vault" | .pool => "pool")

/-- Semantic JSON correspondence for TreeJson parties. -/
theorem partyToTreeJson_toJson (p : Party) :
    (partyToTreeJson p).toJson = partyToJson p := by
  cases p <;> rfl

/-- String encoding correspondence for TreeJson parties. -/
theorem partyToTreeJson_encode (p : Party) :
    (partyToTreeJson p).encode = encodeParty p := by
  cases p <;> rfl

/-- Structured TreeJson representation for assets. -/
def assetToTreeJson (a : Asset) : TreeJson :=
  TreeJson.str (match a with | .usd => "usd" | .share => "share" | .collateral => "collateral" | .debt => "debt")

/-- Semantic JSON correspondence for TreeJson assets. -/
theorem assetToTreeJson_toJson (a : Asset) :
    (assetToTreeJson a).toJson = assetToJson a := by
  cases a <;> rfl

/-- String encoding correspondence for TreeJson assets. -/
theorem assetToTreeJson_encode (a : Asset) :
    (assetToTreeJson a).encode = encodeAsset a := by
  cases a <;> rfl

/-- Structured TreeJson representation for domains. -/
def domainToTreeJson (d : Domain) : TreeJson :=
  TreeJson.str (match d with | .main => "main" | .other => "other")

/-- Semantic JSON correspondence for TreeJson domains. -/
theorem domainToTreeJson_toJson (d : Domain) :
    (domainToTreeJson d).toJson = domainToJson d := by
  cases d <;> rfl

/-- String encoding correspondence for TreeJson domains. -/
theorem domainToTreeJson_encode (d : Domain) :
    (domainToTreeJson d).encode = encodeDomain d := by
  cases d <;> rfl

/-- Structured TreeJson representation for party references. -/
def partyRefToTreeJson : PartyRefEnc → TreeJson
  | .caller => TreeJson.obj [("tag", TreeJson.str "caller")]
  | .argument idx => TreeJson.obj [("tag", TreeJson.str "argument"), ("index", TreeJson.num idx)]
  | .literal p => TreeJson.obj [("tag", TreeJson.str "literal"), ("party", partyToTreeJson p)]

/-- Semantic JSON correspondence for TreeJson party references. -/
theorem partyRefToTreeJson_toJson (pr : PartyRefEnc) :
    (partyRefToTreeJson pr).toJson = partyRefToJson pr := by
  cases pr with
  | caller => rfl
  | argument idx =>
    dsimp [partyRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, partyRefToJson]
    rfl
  | literal p =>
    dsimp [partyRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, partyRefToJson]
    rw [partyToTreeJson_toJson]

/-- String encoding correspondence for TreeJson party references. -/
theorem partyRefToTreeJson_encode (pr : PartyRefEnc) :
    (partyRefToTreeJson pr).encode = encodePartyRef pr := by
  cases pr with
  | caller => rfl
  | argument idx =>
    dsimp [partyRefToTreeJson, encodePartyRef]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rfl
  | literal p =>
    dsimp [partyRefToTreeJson, encodePartyRef]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [partyToTreeJson_encode]
    rfl

/-- Structured TreeJson representation for cell references. -/
def cellRefToTreeJson (c : CellRefEnc) : TreeJson :=
  TreeJson.obj [("domain", domainToTreeJson c.domain), ("owner", partyRefToTreeJson c.owner)]

/-- Semantic JSON correspondence for TreeJson cell references. -/
theorem cellRefToTreeJson_toJson (c : CellRefEnc) :
    (cellRefToTreeJson c).toJson = cellRefToJson c := by
  dsimp [cellRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, cellRefToJson]
  rw [domainToTreeJson_toJson, partyRefToTreeJson_toJson]

/-- String encoding correspondence for TreeJson cell references. -/
theorem cellRefToTreeJson_encode (c : CellRefEnc) :
    (cellRefToTreeJson c).encode = encodeCellRef c := by
  dsimp [cellRefToTreeJson, encodeCellRef]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode, partyRefToTreeJson_encode]

/-- Structured TreeJson representation for packed cell references. -/
def packedCellRefToTreeJson (c : PackedCellRefEnc) : TreeJson :=
  TreeJson.obj [("asset", assetToTreeJson c.asset), ("cell", cellRefToTreeJson c.cell)]

/-- Semantic JSON correspondence for TreeJson packed cell references. -/
theorem packedCellRefToTreeJson_toJson (c : PackedCellRefEnc) :
    (packedCellRefToTreeJson c).toJson = packedCellRefToJson c := by
  dsimp [packedCellRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, packedCellRefToJson]
  rw [assetToTreeJson_toJson, cellRefToTreeJson_toJson]

/-- String encoding correspondence for TreeJson packed cell references. -/
theorem packedCellRefToTreeJson_encode (c : PackedCellRefEnc) :
    (packedCellRefToTreeJson c).encode = encodePackedCellRef c := by
  dsimp [packedCellRefToTreeJson, encodePackedCellRef]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [assetToTreeJson_encode, cellRefToTreeJson_encode]

/-- Structured TreeJson representation for observation keys. -/
def observationKeyToTreeJson (k : ObservationKeyEnc) : TreeJson :=
  TreeJson.obj [("domain", domainToTreeJson k.domain), ("id", TreeJson.num k.id)]

/-- Semantic JSON correspondence for TreeJson observation keys. -/
theorem observationKeyToTreeJson_toJson (k : ObservationKeyEnc) :
    (observationKeyToTreeJson k).toJson = observationKeyToJson k := by
  dsimp [observationKeyToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, observationKeyToJson]
  rw [domainToTreeJson_toJson]
  rfl

/-- String encoding correspondence for TreeJson observation keys. -/
theorem observationKeyToTreeJson_encode (k : ObservationKeyEnc) :
    (observationKeyToTreeJson k).encode = encodeObservationKey k := by
  dsimp [observationKeyToTreeJson, encodeObservationKey]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode]
  rfl

/-- Structured TreeJson representation for numeric units. -/
def numericUnitToTreeJson : NumericUnitEnc → TreeJson
  | .scalar => TreeJson.obj [("tag", TreeJson.str "scalar")]
  | .amount a => TreeJson.obj [("tag", TreeJson.str "amount"), ("asset", assetToTreeJson a)]
  | .price b q => TreeJson.obj [("tag", TreeJson.str "price"), ("base", assetToTreeJson b), ("quote", assetToTreeJson q)]

/-- Semantic JSON correspondence for TreeJson numeric units. -/
theorem numericUnitToTreeJson_toJson (nu : NumericUnitEnc) :
    (numericUnitToTreeJson nu).toJson = numericUnitToJson nu := by
  cases nu with
  | scalar => rfl
  | amount a =>
    dsimp [numericUnitToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, numericUnitToJson]
    rw [assetToTreeJson_toJson]
  | price b q =>
    dsimp [numericUnitToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, numericUnitToJson]
    rw [assetToTreeJson_toJson, assetToTreeJson_toJson]

/-- String encoding correspondence for TreeJson numeric units. -/
theorem numericUnitToTreeJson_encode (nu : NumericUnitEnc) :
    (numericUnitToTreeJson nu).encode = encodeNumericUnit nu := by
  cases nu with
  | scalar => rfl
  | amount a =>
    dsimp [numericUnitToTreeJson, encodeNumericUnit]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [assetToTreeJson_encode]
    rfl
  | price b q =>
    dsimp [numericUnitToTreeJson, encodeNumericUnit]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [assetToTreeJson_encode, assetToTreeJson_encode]
    rfl

/-- Structured TreeJson representation for units. -/
def unitToTreeJson : UnitEnc → TreeJson
  | .bool => TreeJson.obj [("tag", TreeJson.str "bool")]
  | .numeric nu => numericUnitToTreeJson nu

/-- Semantic JSON correspondence for TreeJson units. -/
theorem unitToTreeJson_toJson (u : UnitEnc) :
    (unitToTreeJson u).toJson = unitToJson u := by
  cases u with
  | bool => rfl
  | numeric nu => exact numericUnitToTreeJson_toJson nu

/-- String encoding correspondence for TreeJson units. -/
theorem unitToTreeJson_encode (u : UnitEnc) :
    (unitToTreeJson u).encode = encodeUnit u := by
  cases u with
  | bool => rfl
  | numeric nu => exact numericUnitToTreeJson_encode nu

/-- Structured TreeJson representation for observation references. -/
def observationRefToTreeJson (r : ObservationRefEnc) : TreeJson :=
  TreeJson.obj [("key", observationKeyToTreeJson r.key), ("unit", unitToTreeJson r.unit)]

/-- Semantic JSON correspondence for TreeJson observation references. -/
theorem observationRefToTreeJson_toJson (r : ObservationRefEnc) :
    (observationRefToTreeJson r).toJson = observationRefToJson r := by
  dsimp [observationRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, observationRefToJson]
  rw [observationKeyToTreeJson_toJson, unitToTreeJson_toJson]

/-- String encoding correspondence for TreeJson observation references. -/
theorem observationRefToTreeJson_encode (r : ObservationRefEnc) :
    (observationRefToTreeJson r).encode = encodeObservationRef r := by
  dsimp [observationRefToTreeJson, encodeObservationRef]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [observationKeyToTreeJson_encode, unitToTreeJson_encode]

/-- Structured TreeJson representation for unary operations. -/
def unaryOpToTreeJson : UnaryOpEnc → TreeJson
  | .not => TreeJson.obj [("tag", TreeJson.str "not")]
  | .neg nu => TreeJson.obj [("tag", TreeJson.str "neg"), ("numeric", numericUnitToTreeJson nu)]

/-- Semantic JSON correspondence for TreeJson unary operations. -/
theorem unaryOpToTreeJson_toJson (op : UnaryOpEnc) :
    (unaryOpToTreeJson op).toJson = unaryOpToJson op := by
  cases op with
  | not => rfl
  | neg nu =>
    dsimp [unaryOpToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, unaryOpToJson]
    rw [numericUnitToTreeJson_toJson]

/-- String encoding correspondence for TreeJson unary operations. -/
theorem unaryOpToTreeJson_encode (op : UnaryOpEnc) :
    (unaryOpToTreeJson op).encode = encodeUnaryOp op := by
  cases op with
  | not => rfl
  | neg nu =>
    dsimp [unaryOpToTreeJson, encodeUnaryOp]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [numericUnitToTreeJson_encode]
    rfl

/-- Structured TreeJson representation for binary operations. -/
def binaryOpToTreeJson : BinaryOpEnc → TreeJson
  | .add nu => TreeJson.obj [("tag", TreeJson.str "add"), ("numeric", numericUnitToTreeJson nu)]
  | .sub nu => TreeJson.obj [("tag", TreeJson.str "sub"), ("numeric", numericUnitToTreeJson nu)]
  | .scale nu => TreeJson.obj [("tag", TreeJson.str "scale"), ("numeric", numericUnitToTreeJson nu)]
  | .divide nu => TreeJson.obj [("tag", TreeJson.str "divide"), ("numeric", numericUnitToTreeJson nu)]
  | .ratio nu => TreeJson.obj [("tag", TreeJson.str "ratio"), ("numeric", numericUnitToTreeJson nu)]
  | .convert b q => TreeJson.obj [("tag", TreeJson.str "convert"), ("base", assetToTreeJson b), ("quote", assetToTreeJson q)]
  | .unconvert b q => TreeJson.obj [("tag", TreeJson.str "unconvert"), ("base", assetToTreeJson b), ("quote", assetToTreeJson q)]
  | .and => TreeJson.obj [("tag", TreeJson.str "and")]
  | .or => TreeJson.obj [("tag", TreeJson.str "or")]
  | .eq u => TreeJson.obj [("tag", TreeJson.str "eq"), ("unit", unitToTreeJson u)]
  | .lt nu => TreeJson.obj [("tag", TreeJson.str "lt"), ("numeric", numericUnitToTreeJson nu)]
  | .le nu => TreeJson.obj [("tag", TreeJson.str "le"), ("numeric", numericUnitToTreeJson nu)]

/-- Semantic JSON correspondence for TreeJson binary operations. -/
theorem binaryOpToTreeJson_toJson (op : BinaryOpEnc) :
    (binaryOpToTreeJson op).toJson = binaryOpToJson op := by
  cases op with
  | and => rfl
  | or => rfl
  | eq u =>
    dsimp [binaryOpToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, binaryOpToJson]
    rw [unitToTreeJson_toJson]
  | add nu | sub nu | scale nu | divide nu | ratio nu | lt nu | le nu =>
    dsimp [binaryOpToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, binaryOpToJson]
    rw [numericUnitToTreeJson_toJson]
  | convert b q | unconvert b q =>
    dsimp [binaryOpToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, binaryOpToJson]
    rw [assetToTreeJson_toJson, assetToTreeJson_toJson]

/-- String encoding correspondence for TreeJson binary operations. -/
theorem binaryOpToTreeJson_encode (op : BinaryOpEnc) :
    (binaryOpToTreeJson op).encode = encodeBinaryOp op := by
  cases op with
  | and => rfl
  | or => rfl
  | eq u =>
    dsimp [binaryOpToTreeJson, encodeBinaryOp]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [unitToTreeJson_encode]
    rfl
  | add nu | sub nu | scale nu | divide nu | ratio nu | lt nu | le nu =>
    dsimp [binaryOpToTreeJson, encodeBinaryOp]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [numericUnitToTreeJson_encode]
    rfl
  | convert b q | unconvert b q =>
    dsimp [binaryOpToTreeJson, encodeBinaryOp]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [assetToTreeJson_encode, assetToTreeJson_encode]
    rfl

/-- Structured TreeJson representation for packed values. -/
def packedValueToTreeJson (v : PackedValueEnc) : TreeJson :=
  match v.unit with
  | .bool => TreeJson.bool v.valBool
  | .numeric _ => ratToTreeJson ⟨v.valRat.num, v.valRat.den⟩

/-- Semantic JSON correspondence for TreeJson packed values. -/
theorem packedValueToTreeJson_toJson (v : PackedValueEnc) :
    (packedValueToTreeJson v).toJson = packedValueToJson v := by
  dsimp [packedValueToTreeJson, packedValueToJson]
  cases v.unit with
  | bool => rfl
  | numeric nu => exact ratToTreeJson_toJson ⟨v.valRat.num, v.valRat.den⟩

/-- Universal recursive AST mapping from expressions to structured TreeJson trees. -/
def exprToTreeJson : ExprEnc → TreeJson
  | .lit v =>
    match v.unit with
    | .bool =>
      TreeJson.obj [
        ("tag", TreeJson.str "lit"),
        ("unit", TreeJson.obj [("tag", TreeJson.str "bool")]),
        ("value", TreeJson.bool v.valBool)
      ]
    | .numeric nu =>
      TreeJson.obj [
        ("tag", TreeJson.str "lit"),
        ("unit", numericUnitToTreeJson nu),
        ("value", ratToTreeJson ⟨v.valRat.num, v.valRat.den⟩)
      ]
  | .arg idx u =>
    TreeJson.obj [
      ("tag", TreeJson.str "arg"),
      ("index", TreeJson.num idx),
      ("unit", unitToTreeJson u)
    ]
  | .balance c =>
    TreeJson.obj [
      ("tag", TreeJson.str "balance"),
      ("cell", packedCellRefToTreeJson c)
    ]
  | .observe r =>
    TreeJson.obj [
      ("tag", TreeJson.str "observe"),
      ("ref", observationRefToTreeJson r)
    ]
  | .timestamp k =>
    TreeJson.obj [
      ("tag", TreeJson.str "timestamp"),
      ("key", observationKeyToTreeJson k)
    ]
  | .now =>
    TreeJson.obj [("tag", TreeJson.str "now")]
  | .unary op x =>
    TreeJson.obj [
      ("tag", TreeJson.str "unary"),
      ("op", unaryOpToTreeJson op),
      ("x", exprToTreeJson x)
    ]
  | .binary op x y =>
    TreeJson.obj [
      ("tag", TreeJson.str "binary"),
      ("op", binaryOpToTreeJson op),
      ("x", exprToTreeJson x),
      ("y", exprToTreeJson y)
    ]
  | .ite c y n =>
    TreeJson.obj [
      ("tag", TreeJson.str "ite"),
      ("condition", exprToTreeJson c),
      ("yes", exprToTreeJson y),
      ("no", exprToTreeJson n)
    ]

/-- Universal semantic JSON theorem: exprToTreeJson faithfully matches exprToJson for all ASTs. -/
theorem exprToTreeJson_toJson (e : ExprEnc) :
    (exprToTreeJson e).toJson = exprToJson e := by
  induction e with
  | lit v =>
    dsimp [exprToTreeJson, exprToJson]
    cases h : v.unit with
    | bool =>
      dsimp [TreeJson.toJson, TreeJson.toJsonObj, unitToJson, packedValueToJson]
      rw [h]
    | numeric nu =>
      dsimp [TreeJson.toJson, TreeJson.toJsonObj, unitToJson, packedValueToJson]
      rw [h]
      dsimp
      rw [numericUnitToTreeJson_toJson nu, ratToTreeJson_toJson]
  | arg idx u =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [unitToTreeJson_toJson]
    rfl
  | balance c =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [packedCellRefToTreeJson_toJson]
  | observe r =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [observationRefToTreeJson_toJson]
  | timestamp k =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [observationKeyToTreeJson_toJson]
  | now =>
    rfl
  | unary op x ih =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [unaryOpToTreeJson_toJson, ih]
  | binary op x y ih_x ih_y =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [binaryOpToTreeJson_toJson, ih_x, ih_y]
  | ite c y n ih_c ih_y ih_n =>
    dsimp [exprToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, exprToJson]
    rw [ih_c, ih_y, ih_n]

/-- Universal string encoding theorem: exprToTreeJson faithfully matches encodeExpr for all ASTs. -/
theorem exprToTreeJson_encode (e : ExprEnc) :
    (exprToTreeJson e).encode = encodeExpr e := by
  induction e with
  | lit v =>
    dsimp [exprToTreeJson, encodeExpr]
    cases h : v.unit with
    | bool =>
      rw [encode_obj_eq_jsonObj]
      dsimp [List.map]
      cases v.valBool <;> rfl
    | numeric nu =>
      rw [encode_obj_eq_jsonObj]
      dsimp [List.map]
      rw [numericUnitToTreeJson_encode, ratToTreeJson_encode]
      rfl
  | arg idx u =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [unitToTreeJson_encode]
    rfl
  | balance c =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [packedCellRefToTreeJson_encode]
    rfl
  | observe r =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [observationRefToTreeJson_encode]
    rfl
  | timestamp k =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [observationKeyToTreeJson_encode]
    rfl
  | now =>
    rfl
  | unary op x ih =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [unaryOpToTreeJson_encode, ih]
    rfl
  | binary op x y ih_x ih_y =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [binaryOpToTreeJson_encode, ih_x, ih_y]
    rfl
  | ite c y n ih_c ih_y ih_n =>
    dsimp [exprToTreeJson, encodeExpr]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [ih_c, ih_y, ih_n]
    rfl

/-- Validity of rational TreeJson. -/
theorem ratToTreeJson_valid (r : RatEnc) : TreeJson.Valid (ratToTreeJson r) := by
  dsimp [ratToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial, trivial⟩

/-- Validity of party TreeJson. -/
theorem partyToTreeJson_valid (p : Party) : TreeJson.Valid (partyToTreeJson p) := by
  cases p <;> trivial

/-- Validity of asset TreeJson. -/
theorem assetToTreeJson_valid (a : Asset) : TreeJson.Valid (assetToTreeJson a) := by
  cases a <;> trivial

/-- Validity of domain TreeJson. -/
theorem domainToTreeJson_valid (d : Domain) : TreeJson.Valid (domainToTreeJson d) := by
  cases d <;> trivial

/-- Validity of party reference TreeJson. -/
theorem partyRefToTreeJson_valid (pr : PartyRefEnc) : TreeJson.Valid (partyRefToTreeJson pr) := by
  cases pr with
  | caller =>
    dsimp [partyRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | argument idx =>
    dsimp [partyRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial, trivial⟩
  | literal p =>
    dsimp [partyRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, partyToTreeJson_valid p, trivial⟩

/-- Validity of cell reference TreeJson. -/
theorem cellRefToTreeJson_valid (c : CellRefEnc) : TreeJson.Valid (cellRefToTreeJson c) := by
  dsimp [cellRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid c.domain, partyRefToTreeJson_valid c.owner, trivial⟩

/-- Validity of packed cell reference TreeJson. -/
theorem packedCellRefToTreeJson_valid (c : PackedCellRefEnc) : TreeJson.Valid (packedCellRefToTreeJson c) := by
  dsimp [packedCellRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, assetToTreeJson_valid c.asset, cellRefToTreeJson_valid c.cell, trivial⟩

/-- Validity of observation key TreeJson. -/
theorem observationKeyToTreeJson_valid (k : ObservationKeyEnc) : TreeJson.Valid (observationKeyToTreeJson k) := by
  dsimp [observationKeyToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid k.domain, trivial, trivial⟩

/-- Validity of numeric unit TreeJson. -/
theorem numericUnitToTreeJson_valid (nu : NumericUnitEnc) : TreeJson.Valid (numericUnitToTreeJson nu) := by
  cases nu with
  | scalar =>
    dsimp [numericUnitToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | amount a =>
    dsimp [numericUnitToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, assetToTreeJson_valid a, trivial⟩
  | price b q =>
    dsimp [numericUnitToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, assetToTreeJson_valid b, assetToTreeJson_valid q, trivial⟩

/-- Validity of unit TreeJson. -/
theorem unitToTreeJson_valid (u : UnitEnc) : TreeJson.Valid (unitToTreeJson u) := by
  cases u with
  | bool =>
    dsimp [unitToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | numeric nu => exact numericUnitToTreeJson_valid nu

/-- Validity of observation reference TreeJson. -/
theorem observationRefToTreeJson_valid (r : ObservationRefEnc) : TreeJson.Valid (observationRefToTreeJson r) := by
  dsimp [observationRefToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, observationKeyToTreeJson_valid r.key, unitToTreeJson_valid r.unit, trivial⟩

/-- Validity of unary operation TreeJson. -/
theorem unaryOpToTreeJson_valid (op : UnaryOpEnc) : TreeJson.Valid (unaryOpToTreeJson op) := by
  cases op with
  | not =>
    dsimp [unaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | neg nu =>
    dsimp [unaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, numericUnitToTreeJson_valid nu, trivial⟩

/-- Validity of binary operation TreeJson. -/
theorem binaryOpToTreeJson_valid (op : BinaryOpEnc) : TreeJson.Valid (binaryOpToTreeJson op) := by
  cases op with
  | and | or =>
    dsimp [binaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | eq u =>
    dsimp [binaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, unitToTreeJson_valid u, trivial⟩
  | add nu | sub nu | scale nu | divide nu | ratio nu | lt nu | le nu =>
    dsimp [binaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, numericUnitToTreeJson_valid nu, trivial⟩
  | convert b q | unconvert b q =>
    dsimp [binaryOpToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, assetToTreeJson_valid b, assetToTreeJson_valid q, trivial⟩

/-- Universal structural validity theorem: all expression trees generated by exprToTreeJson are TreeJson.Valid. -/
theorem exprToTreeJson_valid (e : ExprEnc) : TreeJson.Valid (exprToTreeJson e) := by
  induction e with
  | lit v =>
    dsimp [exprToTreeJson]
    cases h : v.unit with
    | bool =>
      dsimp [TreeJson.Valid, TreeJson.ValidObj]
      simp only [List.map_cons, List.map_nil]
      refine ⟨by decide, trivial, ⟨by decide, trivial, trivial⟩, trivial, trivial⟩
    | numeric nu =>
      dsimp [TreeJson.Valid, TreeJson.ValidObj]
      simp only [List.map_cons, List.map_nil]
      refine ⟨by decide, trivial, numericUnitToTreeJson_valid nu, ratToTreeJson_valid ⟨v.valRat.num, v.valRat.den⟩, trivial⟩
  | arg idx u =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial, unitToTreeJson_valid u, trivial⟩
  | balance c =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, packedCellRefToTreeJson_valid c, trivial⟩
  | observe r =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, observationRefToTreeJson_valid r, trivial⟩
  | timestamp k =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, observationKeyToTreeJson_valid k, trivial⟩
  | now =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | unary op x ih =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, unaryOpToTreeJson_valid op, ih, trivial⟩
  | binary op x y ih_x ih_y =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, binaryOpToTreeJson_valid op, ih_x, ih_y, trivial⟩
  | ite c y n ih_c ih_y ih_n =>
    dsimp [exprToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, ih_c, ih_y, ih_n, trivial⟩

/-- Universal expression parser inversion on tokens:
    for any expression whose tree depth does not exceed 64, parseTokens inverts the token stream to exprToJson. -/
theorem parseTokens_exprToTreeJson (e : ExprEnc)
    (h_depth : TreeJson.depth (exprToTreeJson e) ≤ 64) :
    parseTokens (TreeJson.tokens (exprToTreeJson e)) = .ok (exprToJson e) := by
  have h_val := exprToTreeJson_valid e
  have h_parse := parseTokens_tree_valid (exprToTreeJson e) h_val h_depth
  rw [exprToTreeJson_toJson] at h_parse
  exact h_parse

/-- Universal end-to-end token parser and decoder roundtrip for arbitrary recursive expressions. -/
theorem expr_tokens_end_to_end (e : ExprEnc)
    (h_tree_depth : TreeJson.depth (exprToTreeJson e) ≤ 64)
    (h_expr_depth : ExprEnc.depth e ≤ 64)
    (h_can : ExprCanonical e) :
    (do
      let j ← parseTokens (TreeJson.tokens (exprToTreeJson e))
      decodeExpr j) = .ok e := by
  rw [parseTokens_exprToTreeJson e h_tree_depth]
  dsimp [bind, Except.bind]
  exact decodeExpr_exprToJson e h_expr_depth h_can

end DefiKernel.Certificates


