import DefiKernel.Certificates.Schema

namespace DefiKernel.Certificates

set_option linter.style.longLine false

/-- Escape string for JSON representation. -/
def escapeJsonString (s : String) : String :=
  let rec loop (chars : List Char) (acc : List Char) : List Char :=
    match chars with
    | [] => acc
    | c :: cs =>
      match c with
      | '"' => loop cs ('"' :: '\\' :: acc)
      | '\\' => loop cs ('\\' :: '\\' :: acc)
      | '\n' => loop cs ('n' :: '\\' :: acc)
      | '\r' => loop cs ('r' :: '\\' :: acc)
      | '\t' => loop cs ('t' :: '\\' :: acc)
      | _ => loop cs (c :: acc)
  "\"" ++ String.ofList (loop s.toList []).reverse ++ "\""

def jsonArr (items : List String) : String :=
  "[" ++ String.intercalate "," items ++ "]"

def jsonObj (fields : List (String × String)) : String :=
  "{" ++ String.intercalate "," (fields.map (fun (k, v) => "\"" ++ k ++ "\":" ++ v)) ++ "}"

def encodeParty : Party → String
  | .alice => "\"alice\""
  | .bob => "\"bob\""
  | .vault => "\"vault\""
  | .pool => "\"pool\""

def encodeAsset : Asset → String
  | .usd => "\"usd\""
  | .share => "\"share\""
  | .collateral => "\"collateral\""
  | .debt => "\"debt\""

def encodeDomain : Domain → String
  | .main => "\"main\""
  | .other => "\"other\""

def encodeRat (r : RatEnc) : String :=
  jsonObj [("num", toString r.num), ("den", toString r.den)]

def encodeNumericUnit : NumericUnitEnc → String
  | .amount a => jsonObj [("tag", "\"amount\""), ("asset", encodeAsset a)]
  | .price b q => jsonObj [("tag", "\"price\""), ("base", encodeAsset b), ("quote", encodeAsset q)]
  | .scalar => "{\"tag\":\"scalar\"}"

def encodeUnit : UnitEnc → String
  | .numeric u => encodeNumericUnit u
  | .bool => "{\"tag\":\"bool\"}"

def encodePackedValue (v : PackedValueEnc) : String :=
  match v.unit with
  | .bool => jsonObj [("unit", "{\"tag\":\"bool\"}"), ("value", if v.valBool then "true" else "false")]
  | .numeric nu => jsonObj [("unit", encodeNumericUnit nu), ("value", encodeRat ⟨v.valRat.num, v.valRat.den⟩)]

def encodePartyRef : PartyRefEnc → String
  | .caller => "{\"tag\":\"caller\"}"
  | .argument idx => jsonObj [("tag", "\"argument\""), ("index", toString idx)]
  | .literal p => jsonObj [("tag", "\"literal\""), ("party", encodeParty p)]

def encodeCellRef (c : CellRefEnc) : String :=
  jsonObj [("domain", encodeDomain c.domain), ("owner", encodePartyRef c.owner)]

def encodePackedCellRef (c : PackedCellRefEnc) : String :=
  jsonObj [("asset", encodeAsset c.asset), ("cell", encodeCellRef c.cell)]

def encodeObservationKey (k : ObservationKeyEnc) : String :=
  jsonObj [("domain", encodeDomain k.domain), ("id", toString k.id)]

def encodeObservationRef (r : ObservationRefEnc) : String :=
  jsonObj [("key", encodeObservationKey r.key), ("unit", encodeUnit r.unit)]

def encodeEnvRead : EnvReadEnc → String
  | .observation k => jsonObj [("tag", "\"observation\""), ("key", encodeObservationKey k)]
  | .currentTime => "{\"tag\":\"currentTime\"}"

def encodeUnaryOp : UnaryOpEnc → String
  | .neg nu => jsonObj [("tag", "\"neg\""), ("numeric", encodeNumericUnit nu)]
  | .not => "{\"tag\":\"not\"}"

def encodeBinaryOp : BinaryOpEnc → String
  | .add nu => jsonObj [("tag", "\"add\""), ("numeric", encodeNumericUnit nu)]
  | .sub nu => jsonObj [("tag", "\"sub\""), ("numeric", encodeNumericUnit nu)]
  | .scale nu => jsonObj [("tag", "\"scale\""), ("numeric", encodeNumericUnit nu)]
  | .divide nu => jsonObj [("tag", "\"divide\""), ("numeric", encodeNumericUnit nu)]
  | .ratio nu => jsonObj [("tag", "\"ratio\""), ("numeric", encodeNumericUnit nu)]
  | .convert b q => jsonObj [("tag", "\"convert\""), ("base", encodeAsset b), ("quote", encodeAsset q)]
  | .unconvert b q => jsonObj [("tag", "\"unconvert\""), ("base", encodeAsset b), ("quote", encodeAsset q)]
  | .le nu => jsonObj [("tag", "\"le\""), ("numeric", encodeNumericUnit nu)]
  | .lt nu => jsonObj [("tag", "\"lt\""), ("numeric", encodeNumericUnit nu)]
  | .eq u => jsonObj [("tag", "\"eq\""), ("unit", encodeUnit u)]
  | .and => "{\"tag\":\"and\"}"
  | .or => "{\"tag\":\"or\"}"

def encodeExpr : ExprEnc → String
  | .lit v =>
    match v.unit with
    | .bool => jsonObj [("tag", "\"lit\""), ("unit", "{\"tag\":\"bool\"}"), ("value", if v.valBool then "true" else "false")]
    | .numeric nu => jsonObj [("tag", "\"lit\""), ("unit", encodeNumericUnit nu), ("value", encodeRat ⟨v.valRat.num, v.valRat.den⟩)]
  | .arg idx u =>
    jsonObj [("tag", "\"arg\""), ("index", toString idx), ("unit", encodeUnit u)]
  | .balance c =>
    jsonObj [("tag", "\"balance\""), ("cell", encodePackedCellRef c)]
  | .observe r =>
    jsonObj [("tag", "\"observe\""), ("ref", encodeObservationRef r)]
  | .timestamp k =>
    jsonObj [("tag", "\"timestamp\""), ("key", encodeObservationKey k)]
  | .now =>
    "{\"tag\":\"now\"}"
  | .unary op x =>
    jsonObj [("tag", "\"unary\""), ("op", encodeUnaryOp op), ("x", encodeExpr x)]
  | .binary op x y =>
    jsonObj [("tag", "\"binary\""), ("op", encodeBinaryOp op), ("x", encodeExpr x), ("y", encodeExpr y)]
  | .ite c y n =>
    jsonObj [("tag", "\"ite\""), ("condition", encodeExpr c), ("yes", encodeExpr y), ("no", encodeExpr n)]

def encodeCellDelta (d : CellDeltaEnc) : String :=
  jsonObj [("asset", encodeAsset d.asset), ("target", encodeCellRef d.target), ("amount", encodeExpr d.amount)]

def encodeSupplyDelta (d : SupplyDeltaEnc) : String :=
  jsonObj [("domain", encodeDomain d.domain), ("asset", encodeAsset d.asset), ("amount", encodeExpr d.amount)]

def encodeTemplate (t : TemplateEnc) : String :=
  let sig := jsonArr (t.signature.map encodeUnit)
  let deltas := jsonArr (t.deltas.map encodeCellDelta)
  let sDeltas := jsonArr (t.supplyDeltas.map encodeSupplyDelta)
  let sReads := jsonArr (t.stateReads.map encodePackedCellRef)
  let eReads := jsonArr (t.envReads.map encodeEnvRead)
  let wrs := jsonArr (t.writes.map encodePackedCellRef)
  jsonObj [
    ("signature", sig),
    ("domain", encodeDomain t.domain),
    ("partyArity", toString t.partyArity),
    ("guard", encodeExpr t.guard),
    ("deltas", deltas),
    ("supplyDeltas", sDeltas),
    ("stateReads", sReads),
    ("envReads", eReads),
    ("writes", wrs)
  ]

def encodeRegistryEntry (e : RegistryEntryEnc) : String :=
  jsonObj [("id", toString e.id), ("template", encodeTemplate e.template)]

def encodeRegistry (r : RegistryEnc) : String :=
  jsonObj [("entries", jsonArr (r.entries.map encodeRegistryEntry))]

def encodeCell (c : CellEnc) : String :=
  jsonObj [("domain", encodeDomain c.domain), ("party", encodeParty c.party), ("asset", encodeAsset c.asset)]

def encodeRight : RightEnc → String
  | .invoke => "{\"tag\":\"invoke\"}"
  | .debit c => jsonObj [("tag", "\"debit\""), ("cell", encodeCell c)]
  | .changeSupply d a => jsonObj [("tag", "\"changeSupply\""), ("domain", encodeDomain d), ("asset", encodeAsset a)]

def encodeGrant (g : GrantEnc) : String :=
  jsonObj [("holder", encodeParty g.holder), ("domain", encodeDomain g.domain), ("operation", toString g.operation), ("right", encodeRight g.right)]

def encodeCapability (c : CapabilityEnc) : String :=
  jsonObj [("holder", encodeParty c.holder), ("domain", encodeDomain c.domain), ("operation", toString c.operation), ("right", encodeRight c.right), ("live", if c.live then "true" else "false")]

def encodeStore (s : StoreEnc) : String :=
  jsonObj [("entries", jsonArr (s.entries.map encodeCapability))]

def encodeStateCell (c : StateCellEnc) : String :=
  jsonObj [("domain", encodeDomain c.domain), ("party", encodeParty c.party), ("asset", encodeAsset c.asset), ("amount", encodeRat c.amount)]

def encodeState (s : StateEnc) : String :=
  jsonObj [("cells", jsonArr (s.cells.map encodeStateCell))]

def encodeContext (ctx : ContextEnc) : String :=
  jsonObj [("principal", encodeParty ctx.principal), ("domain", encodeDomain ctx.domain)]

def encodeObservation (o : ObservationEnc) : String :=
  jsonObj [("value", encodePackedValue o.value), ("timestamp", toString o.timestamp)]

def encodeEnvironmentEntry (e : EnvironmentEntryEnc) : String :=
  jsonObj [("key", encodeObservationKey e.key), ("observation", encodeObservation e.observation)]

def encodeEnvironment (env : EnvironmentEnc) : String :=
  jsonObj [("entries", jsonArr (env.entries.map encodeEnvironmentEntry))]

def encodeRequest (r : RequestEnc) : String :=
  let ps := jsonArr (r.parties.map encodeParty)
  let args := jsonArr (r.arguments.map encodePackedValue)
  let caps := jsonArr (r.capabilityIds.map toString)
  let actor := match r.claimedActor with
    | some a => encodeParty a
    | none => "null"
  jsonObj [("operation", toString r.operation), ("parties", ps), ("arguments", args), ("capabilityIds", caps), ("claimedActor", actor)]

def encodeBoundary (b : BoundaryEnc) : String :=
  jsonObj [("ctx", encodeContext b.ctx), ("env", encodeEnvironment b.env), ("now", toString b.now)]

def encodeDomainAdmin (d : DomainAdminEnc) : String :=
  jsonObj [("domain", encodeDomain d.domain), ("party", encodeParty d.party)]

def encodeInputPort (p : InputPortEnc) : String :=
  jsonObj [("id", toString p.id), ("unit", encodeUnit p.unit)]

def encodeOutputPort (p : OutputPortEnc) : String :=
  jsonObj [("id", toString p.id), ("cell", encodeCell p.cell)]

def encodeResourcePort (p : ResourcePortEnc) : String :=
  jsonObj [("id", toString p.id), ("cell", encodeCell p.cell), ("writable", if p.writable then "true" else "false")]

def encodeQualifiedPort (p : QualifiedPortEnc) : String :=
  jsonObj [("component", toString p.component), ("port", toString p.port)]

def encodeResourceImport (p : ResourceImportEnc) : String :=
  jsonObj [("source", encodeQualifiedPort p.source), ("cell", encodeCell p.cell), ("writable", if p.writable then "true" else "false")]

def encodeOperationInterface (op : OperationInterfaceEnc) : String :=
  let ins := jsonArr (op.inputs.map encodeInputPort)
  let outs := jsonArr (op.outputs.map encodeOutputPort)
  jsonObj [("operation", toString op.operation), ("inputs", ins), ("outputs", outs)]

def encodeComponent (c : ComponentEnc) : String :=
  let privs := jsonArr (c.privateCells.map encodeCell)
  let exps := jsonArr (c.exports.map encodeResourcePort)
  let imps := jsonArr (c.imports.map encodeResourceImport)
  let ops := jsonArr (c.operations.map encodeOperationInterface)
  jsonObj [("id", toString c.id), ("privateCells", privs), ("exports", exps), ("imports", imps), ("operations", ops)]

def encodeConfig (c : ConfigEnc) : String :=
  let admins := jsonArr (c.domainAdmin.map encodeDomainAdmin)
  let cats := jsonArr (c.catalog.map encodeComponent)
  jsonObj [("registry", encodeRegistry c.registry), ("domainAdmin", admins), ("catalog", cats)]

def encodeInputSource : InputSourceEnc → String
  | .literal v => jsonObj [("tag", "\"literal\""), ("value", encodePackedValue v)]
  | .priorOutput step port => jsonObj [("tag", "\"priorOutput\""), ("step", toString step), ("port", encodeQualifiedPort port)]

def encodeInvocation (inv : InvocationEnc) : String :=
  let ps := jsonArr (inv.parties.map encodeParty)
  let ins := jsonArr (inv.inputs.map encodeInputSource)
  let caps := jsonArr (inv.capabilityIds.map toString)
  let actor := match inv.claimedActor with
    | some a => encodeParty a
    | none => "null"
  jsonObj [("component", toString inv.component), ("operation", toString inv.operation), ("parties", ps), ("inputs", ins), ("capabilityIds", caps), ("claimedActor", actor)]

def encodeStep : StepEnc → String
  | .invoke inv => jsonObj [("tag", "\"invoke\""), ("invocation", encodeInvocation inv)]
  | .issue g => jsonObj [("tag", "\"issue\""), ("grant", encodeGrant g)]
  | .revoke id => jsonObj [("tag", "\"revoke\""), ("id", toString id)]
  | .unsupported tag => jsonObj [("tag", "\"" ++ tag ++ "\"")]

def encodeWorld (w : WorldEnc) : String :=
  jsonObj [("state", encodeState w.state), ("capabilities", encodeStore w.capabilities)]

def encodeOutputObservation (o : OutputObservationEnc) : String :=
  jsonObj [("step", toString o.step), ("port", encodeQualifiedPort o.port), ("value", encodePackedValue o.value)]

def encodeSourcePin (pin : SourcePinEnc) : String :=
  let cr := match pin.compiler_record with
    | some r => escapeJsonString r
    | none => "null"
  let ar := match pin.audit_record with
    | some r => escapeJsonString r
    | none => "null"
  jsonObj [
    ("git", escapeJsonString pin.git),
    ("lean_toolchain", escapeJsonString pin.lean_toolchain),
    ("mathlib_rev", escapeJsonString pin.mathlib_rev),
    ("checker_candidate", escapeJsonString pin.checker_candidate),
    ("compiler_record", cr),
    ("audit_record", ar)
  ]

def encodeTypesEnum (t : TypesEnumEnc) : String :=
  let ps := jsonArr (t.parties.map encodeParty)
  let as := jsonArr (t.assets.map encodeAsset)
  let ds := jsonArr (t.domains.map encodeDomain)
  jsonObj [("parties", ps), ("assets", as), ("domains", ds)]

def encodeLibraryRef (lib : LibraryRefEnc) : String :=
  match lib.moduleName with
  | some m => jsonObj [("theorem", escapeJsonString lib.theoremName), ("module", escapeJsonString m)]
  | none => jsonObj [("theorem", escapeJsonString lib.theoremName)]

def encodeSourceMap (entries : List (String × String)) : String :=
  let sorted := entries.toArray.qsort (fun a b => a.1 < b.1) |>.toList
  let pairs := sorted.map (fun (k, v) => (k, escapeJsonString v))
  jsonObj pairs

def encodeEnvelope (env : EnvelopeEnc) (payloadStr : String) : String :=
  let roots := jsonArr (env.audit_roots.map escapeJsonString)
  let asms := jsonArr (env.assumptions.map escapeJsonString)
  let invs := jsonArr (env.invariants.map escapeJsonString)
  let libs := jsonArr (env.libraries.map encodeLibraryRef)
  let sm := encodeSourceMap env.source_map
  let cj := jsonArr (env.claimed_judgments.map escapeJsonString)
  let cns := match env.claimed_next_state with
    | some w => encodeWorld w
    | none => "null"
  let rld := if env.require_library_discharge then "true" else "false"
  let rid := if env.require_invariant_discharge then "true" else "false"
  jsonObj [
    ("schema_version", toString env.schema_version),
    ("mode", escapeJsonString env.mode),
    ("source_pin", encodeSourcePin env.source_pin),
    ("audit_roots", roots),
    ("types", encodeTypesEnum env.types),
    ("assumptions", asms),
    ("invariants", invs),
    ("libraries", libs),
    ("source_map", sm),
    ("payload", payloadStr),
    ("claimed_judgments", cj),
    ("claimed_next_state", cns),
    ("require_library_discharge", rld),
    ("require_invariant_discharge", rid)
  ]

def encodeTypedExecutePayload (p : TypedExecutePayloadEnc) : String :=
  jsonObj [
    ("registry", encodeRegistry p.registry),
    ("store", encodeStore p.store),
    ("ctx", encodeContext p.ctx),
    ("env", encodeEnvironment p.env),
    ("now", toString p.now),
    ("request", encodeRequest p.request),
    ("state", encodeState p.state)
  ]

def encodeCompositionStepPayload (p : CompositionStepPayloadEnc) : String :=
  let hist := jsonArr (p.history.map encodeOutputObservation)
  jsonObj [
    ("config", encodeConfig p.config),
    ("boundary", encodeBoundary p.boundary),
    ("index", toString p.index),
    ("history", hist),
    ("step", encodeStep p.step),
    ("pre", encodeWorld p.pre)
  ]

def encodeCompositionRunPayload (p : CompositionRunPayloadEnc) : String :=
  let bs := jsonArr (p.boundaries.map encodeBoundary)
  let ss := jsonArr (p.steps.map encodeStep)
  jsonObj [
    ("config", encodeConfig p.config),
    ("boundaries", bs),
    ("world", encodeWorld p.world),
    ("steps", ss)
  ]

def encodeAuditPayload (a : DecodedAudit) : String :=
  let f_cmds : List (String × String) :=
    if !a.commands.isEmpty then [("commands", jsonArr (a.commands.map escapeJsonString))] else []
  let f_forb : List (String × String) :=
    match a.forbidden_claimed_roots with
    | some rs => [("forbidden_claimed_roots", jsonArr (rs.map escapeJsonString))]
    | none => []
  let f_imp : List (String × String) :=
    match a.imported_theorems with | some n => [("imported_theorems", toString n)] | none => []
  let f_min : List (String × String) :=
    match a.imported_theorems_min with | some n => [("imported_theorems_min", toString n)] | none => []
  let f_pfx : List (String × String) :=
    match a.auditPrefix with | some pfx => [("prefix", escapeJsonString pfx)] | none => []
  let allFields := f_cmds ++ f_forb ++ f_imp ++ f_min ++ f_pfx
  let sorted := allFields.toArray.qsort (fun a b => a.1 < b.1) |>.toList
  jsonObj sorted

/-- Canonical serialization of any DecodedIR to compact UTF-8 ByteArray. -/
def encodeModuleCanonical (ir : DecodedIR) : ByteArray :=
  let s : String := match ir with
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
  s.toUTF8

def encodeFailurePath (f : FailurePath) : String :=
  let pl := match f.payload with | some p => escapeJsonString p | none => "null"
  let cls := match f.class with
    | .kernel => "\"kernel\""
    | .interface => "\"interface\""
    | .configuration => "\"configuration\""
    | .authority => "\"authority\""
    | .internalReceipt => "\"internalReceipt\""
    | .staleSource => "\"staleSource\""
    | .observationMismatch => "\"observationMismatch\""
    | .incompleteObligation => "\"incompleteObligation\""
  jsonObj [("class", cls), ("ctor", escapeJsonString f.ctor), ("payload", pl)]

def encodeJudgmentOutcome : JudgmentOutcome → String
  | .«true» => "\"true\""
  | .«false» => "\"false\""
  | .notReached => "\"not_reached\""
  | .notApplicable => "\"not_applicable\""

def encodeJudgmentResult (j : JudgmentResult) : String :=
  jsonObj [
    ("family", escapeJsonString j.family),
    ("outcome", encodeJudgmentOutcome j.outcome),
    ("claimed", if j.claimed then "true" else "false"),
    ("match", if j.«match» then "true" else "false")
  ]

def encodeEvaluated (eval : EvaluatedEnc) : String :=
  let ds := jsonArr (eval.deltas.map fun (c, r) => jsonObj [("cell", encodeCell c), ("amount", encodeRat r)])
  let ss := jsonArr (eval.supplies.map fun ((d, a), r) => jsonObj [("domain", encodeDomain d), ("asset", encodeAsset a), ("amount", encodeRat r)])
  let rsr := jsonArr (eval.requiredStateReads.map encodeCell)
  let rer := jsonArr (eval.requiredEnvReads.map encodeObservationKey)
  let dsr := jsonArr (eval.declaredStateReads.map encodeCell)
  let der := jsonArr (eval.declaredEnvReads.map encodeObservationKey)
  let ws := jsonArr (eval.writes.map encodeCell)
  jsonObj [
    ("guard", if eval.guard then "true" else "false"),
    ("deltas", ds),
    ("supplies", ss),
    ("requiredStateReads", rsr),
    ("requiredEnvReads", rer),
    ("declaredStateReads", dsr),
    ("declaredEnvReads", der),
    ("writes", ws)
  ]

def encodeReceipt : ReceiptEnc → String
  | .invoked req eval =>
    jsonObj [
      ("tag", "\"invoked\""),
      ("request", encodeRequest req),
      ("evaluated", encodeEvaluated eval)
    ]
  | .issued id => jsonObj [("tag", "\"issued\""), ("id", toString id)]
  | .revoked id => jsonObj [("tag", "\"revoked\""), ("id", toString id)]

def encodeSequentialEvent (e : SequentialEventEnc) : String :=
  jsonObj [
    ("index", toString e.index),
    ("step", encodeStep e.step),
    ("before", encodeWorld e.before),
    ("result", jsonObj [
      ("world", encodeWorld e.result.world),
      ("receipt", encodeReceipt e.result.receipt),
      ("outputs", jsonArr (e.result.outputs.map encodeOutputObservation))
    ])
  ]

def encodeLocatedFailure (lf : LocatedFailureEnc) : String :=
  let s := match lf.step with | some st => encodeStep st | none => "null"
  let rStr := match lf.reason.class with
    | .configuration => jsonObj [("class", "\"configuration\"")]
    | _ => encodeFailurePath lf.reason
  jsonObj [
    ("index", toString lf.index),
    ("step", s),
    ("reason", rStr)
  ]

def encodeAssumptions (ass : List (String × String)) : String :=
  jsonObj (ass.map (fun (k, v) => (k, escapeJsonString v)))

def encodeReport (r : Report) : String :=
  let failStr := match r.failure with | some f => encodeFailurePath f | none => "null"
  let recStr := match r.receipt with | some rc => encodeReceipt rc | none => "null"
  let cfStr := match r.cursorFailure with | some cf => encodeLocatedFailure cf | none => "null"
  let stStr := match r.status with | .accepted => "\"accepted\"" | .refused => "\"refused\"" | .incomplete => "\"incomplete\""
  jsonObj [
    ("status", stStr),
    ("failure", failStr),
    ("judgments", jsonArr (r.judgments.map encodeJudgmentResult)),
    ("world", encodeWorld r.world),
    ("receipt", recStr),
    ("outputs", jsonArr (r.outputs.map encodeOutputObservation)),
    ("events", jsonArr (r.events.map encodeSequentialEvent)),
    ("nextIndex", toString r.nextIndex),
    ("cursorFailure", cfStr),
    ("assumptions", encodeAssumptions r.assumptions),
    ("outstanding", jsonArr (r.outstanding.map escapeJsonString)),
    ("source_pin", encodeSourcePin r.source_pin),
    ("audit_roots", jsonArr (r.audit_roots.map escapeJsonString)),
    ("unsupported", "null")
  ]

def encodeRawObservation (ro : RawObservation) : String :=
  let recStr := match ro.receipt with | some rc => encodeReceipt rc | none => "null"
  let cfStr := match ro.cursorFailure with | some cf => encodeLocatedFailure cf | none => "null"
  let kfStr := match ro.kernelFailure with | some f => encodeFailurePath f | none => "null"
  jsonObj [
    ("world", encodeWorld ro.world),
    ("receipt", recStr),
    ("outputs", jsonArr (ro.outputs.map encodeOutputObservation)),
    ("events", jsonArr (ro.events.map encodeSequentialEvent)),
    ("nextIndex", toString ro.nextIndex),
    ("cursorFailure", cfStr),
    ("kernelFailure", kfStr)
  ]

def encodeAuditResult (a : AuditResult) : String :=
  let stStr := match a.status with | .passed => "\"passed\"" | .failed => "\"failed\"" | .blocked => "\"blocked\""
  let failStr := match a.failure with | some f => escapeJsonString f | none => "null"
  let covStr := match a.claimed_covered with | some b => if b then "true" else "false" | none => "null"
  let f_cov := match a.claimed_covered with
    | some _ => [("claimed_covered", covStr)]
    | none => []
  let f_pfx := if !a.prefixes.isEmpty then [("prefixes", jsonArr (a.prefixes.map escapeJsonString))] else []
  jsonObj ([("status", stStr), ("failure", failStr)] ++ f_pfx ++ f_cov)

def encodeDecodeFailure (f : DecodeFailure) : String :=
  match f with
  | .emptyDocument => jsonObj [("ctor", "\"emptyDocument\"")]
  | .resourceLimit r => jsonObj [("ctor", "\"resourceLimit\""), ("limit", escapeJsonString r)]
  | .lexicalScientificOrFloat => jsonObj [("ctor", "\"lexicalScientificOrFloat\"")]
  | .notJsonObject => jsonObj [("ctor", "\"notJsonObject\"")]
  | .duplicateKey k => jsonObj [("ctor", "\"duplicateKey\""), ("name", escapeJsonString k)]
  | .noncanonicalWhitespace => jsonObj [("ctor", "\"noncanonicalWhitespace\"")]
  | .schemaVersion => jsonObj [("ctor", "\"schemaVersion\"")]
  | .missingField m => jsonObj [("ctor", "\"missingField\""), ("name", escapeJsonString m)]
  | .jsonType p => jsonObj [("ctor", "\"jsonType\""), ("path", escapeJsonString p)]
  | .unknownIdentifier u => jsonObj [("ctor", "\"unknownIdentifier\""), ("name", escapeJsonString u)]
  | .uniqueness k => jsonObj [("ctor", "\"uniqueness\""), ("kind", escapeJsonString k)]
  | .illegalRational r =>
    let rStr := match r with | .zeroDenominator => "\"zeroDenominator\"" | .noncanonical => "\"noncanonical\""
    jsonObj [("ctor", "\"illegalRational\""), ("reason", rStr)]
  | .stateNonneg => jsonObj [("ctor", "\"stateNonneg\"")]
  | .unknownExecutableField f => jsonObj [("ctor", "\"unknownExecutableField\""), ("name", escapeJsonString f)]
  | .unsupportedForm r => jsonObj [("ctor", "\"unsupportedForm\""), ("reason", escapeJsonString r)]

def encodeCodecResult (c : CodecResult) : String :=
  match c with
  | .ok _ => jsonObj [("status", "\"ok\""), ("failure", "null"), ("ir", "{}")]
  | .malformed f => jsonObj [("status", "\"malformed\""), ("failure", encodeDecodeFailure f), ("ir", "null")]
  | .blocked b => jsonObj [("status", "\"blocked\""), ("failure", jsonObj [("ctor", "\"resourceLimit\""), ("limit", escapeJsonString b)]), ("ir", "null")]

def encodeOutcome (o : Outcome) : String :=
  match o with
  | .execution rep => jsonObj [("mode", "\"execution\""), ("result", encodeReport rep)]
  | .codec c => jsonObj [("mode", "\"codec\""), ("result", encodeCodecResult c)]
  | .audit a => jsonObj [("mode", "\"audit\""), ("result", encodeAuditResult a)]

end DefiKernel.Certificates
