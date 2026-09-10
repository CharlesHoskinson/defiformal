import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Tests
import Lean.Data.Json

open DefiKernel.Certificates
open DefiKernel.Certificates.Tests

/-- Diagnostic-only Bool mirrors of Correspondence predicates. Not a proof. -/
def nonnegPos (c : StateCellEnc) : Bool :=
  decide (c.amount.den > 0 ∧ c.amount.num ≥ 0)

def canonicalRat (c : StateCellEnc) : Bool :=
  decide (c.amount.den > 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1)

def nodupIds (ids : List Nat) : Bool :=
  decide ids.Nodup

def supportedIRB (ir : DecodedIR) : Bool :=
  match ir with
  | .execution (.typed env payload) =>
    env.mode == "typed-execute" &&
    payload.state.cells.length == 32 &&
    payload.state.cells.all nonnegPos &&
    nodupIds (payload.registry.entries.map (·.id))
  | .execution (.step env payload) =>
    env.mode == "composition-step" &&
    (match payload.step with | .unsupported _ => false | _ => true) &&
    payload.pre.state.cells.length == 32 &&
    payload.pre.state.cells.all nonnegPos &&
    nodupIds (payload.config.registry.entries.map (·.id))
  | .execution (.run env payload) =>
    env.mode == "composition-run" &&
    payload.steps.all (fun s ↦ match s with | .unsupported _ => false | _ => true) &&
    payload.world.state.cells.length == 32 &&
    payload.world.state.cells.all nonnegPos &&
    nodupIds (payload.config.registry.entries.map (·.id))
  | .audit _ => false
  | .codec _ => false

def canonicalIRB (ir : DecodedIR) : Bool :=
  match ir with
  | .execution (.typed _ payload) => payload.state.cells.all canonicalRat
  | .execution (.step _ payload) => payload.pre.state.cells.all canonicalRat
  | .execution (.run _ payload) => payload.world.state.cells.all canonicalRat
  | .audit _ => false
  | .codec _ => false

def failToString : DecodeFailure → String
  | .emptyDocument => "emptyDocument"
  | .resourceLimit r => s!"resourceLimit:{r}"
  | .lexicalScientificOrFloat => "lexicalScientificOrFloat"
  | .notJsonObject => "notJsonObject"
  | .duplicateKey k => s!"duplicateKey:{k}"
  | .noncanonicalWhitespace => "noncanonicalWhitespace"
  | .schemaVersion => "schemaVersion"
  | .missingField m => s!"missingField:{m}"
  | .jsonType p => s!"jsonType:{p}"
  | .unknownIdentifier u => s!"unknownIdentifier:{u}"
  | .uniqueness k => s!"uniqueness:{k}"
  | .illegalRational .zeroDenominator => "illegalRational.zeroDenominator"
  | .illegalRational .noncanonical => "illegalRational.noncanonical"
  | .stateNonneg => "stateNonneg"
  | .unknownExecutableField f => s!"unknownExecutableField:{f}"
  | DecodeFailure.unsupportedForm r => s!"unsupportedForm:{r}"

def exceptIR (e : Except DecodeFailure DecodedIR) : String :=
  match e with
  | .ok _ => "ok"
  | .error err => s!"error:{failToString err}"

def firstDiff (a b : ByteArray) : Option (Nat × UInt8 × UInt8) :=
  let n := min a.size b.size
  Id.run do
    let mut i := 0
    while i < n do
      if a[i]! != b[i]! then
        return some (i, a[i]!, b[i]!)
      i := i + 1
    if a.size != b.size then
      return some (n, 0, 0)
    none

def snippet (b : ByteArray) (i : Nat) : String :=
  let start := if i < 24 then 0 else i - 24
  let stop := min b.size (i + 24)
  String.fromUTF8! (b.extract start stop)

def hex8 (x : UInt8) : String :=
  toString x.toNat

def reportBytesEq (label : String) (a b : ByteArray) : IO Unit := do
  if a == b then
    IO.println s!"{label}: EQUAL bytes={a.size}"
  else
    match firstDiff a b with
    | none => IO.println s!"{label}: UNEQUAL size {a.size} vs {b.size} (no index)"
    | some (i, xa, xb) =>
      IO.println s!"{label}: UNEQUAL size {a.size} vs {b.size} firstDiff@{i} {hex8 xa} vs {hex8 xb}"
      IO.println s!"  a_snip={snippet a i}"
      IO.println s!"  b_snip={snippet b i}"

def loadUTF8 (p : System.FilePath) : IO ByteArray := do
  let s ← IO.FS.readFile p
  pure s.toUTF8

def envelopeOf : DecodedIR → Option EnvelopeEnc
  | .execution e => some e.envelope
  | .audit a => some a.envelope
  | .codec c => c.envelope

def cellCount : DecodedIR → Nat
  | .execution (.typed _ p) => p.state.cells.length
  | .execution (.step _ p) => p.pre.state.cells.length
  | .execution (.run _ p) => p.world.state.cells.length
  | _ => 0

def storeCount : DecodedIR → Nat
  | .execution (.typed _ p) => p.store.entries.length
  | .execution (.step _ p) => p.pre.capabilities.entries.length
  | .execution (.run _ p) => p.world.capabilities.entries.length
  | _ => 0

def registryIds : DecodedIR → List Nat
  | .execution (.typed _ p) => p.registry.entries.map (·.id)
  | .execution (.step _ p) => p.config.registry.entries.map (·.id)
  | .execution (.run _ p) => p.config.registry.entries.map (·.id)
  | _ => []

def sourceMapKeys : DecodedIR → List String
  | ir => match envelopeOf ir with
    | some env => env.source_map.map (·.1)
    | none => []

def summarizeIR (label : String) (ir : DecodedIR) : IO Unit := do
  IO.println s!"{label}: ctor={match ir with | .execution (.typed _ _) => "typed" | .execution (.step _ _) => "step" | .execution (.run _ _) => "run" | .audit _ => "audit" | .codec _ => "codec"}"
  IO.println s!"{label}: supportedIRB={supportedIRB ir} canonicalIRB={canonicalIRB ir}"
  IO.println s!"{label}: cells={cellCount ir} store={storeCount ir} registryIds={registryIds ir}"
  IO.println s!"{label}: source_map_keys={sourceMapKeys ir}"
  match envelopeOf ir with
  | some env =>
    IO.println s!"{label}: mode={env.mode} invariants={env.invariants.length} libraries={env.libraries.length} claimed_next_state={env.claimed_next_state.isSome}"
  | none => pure ()

def probeFile (label : String) (path : System.FilePath) : IO Unit := do
  IO.println s!"===== FILE {label} path={path} ====="
  let raw ← loadUTF8 path
  IO.println s!"raw_bytes={raw.size}"
  let dec := decodeBytes raw
  IO.println s!"decodeBytes={exceptIR dec}"
  match dec with
  | .error _ => pure ()
  | .ok ir =>
    summarizeIR label ir
    let enc := encodeModule ir
    IO.println s!"encode_bytes={enc.size}"
    reportBytesEq s!"{label}.encode_vs_raw" enc raw
    let dec2 := decodeBytes enc
    IO.println s!"decode(encode)={exceptIR dec2}"
    match dec2 with
    | .ok ir2 =>
      IO.println s!"{label}.decode(encode)==ir : {decide (ir2 == ir)}"
      IO.println s!"{label}.supportedIRB(ir2)={supportedIRB ir2} canonicalIRB(ir2)={canonicalIRB ir2}"
    | .error _ => pure ()
    let stmtA := supportedIRB ir && canonicalIRB ir && !(decide (decodeBytes (encodeModule ir) == .ok ir))
    let stmtB := canonicalIRB ir && !(enc == raw)
    IO.println s!"{label}.counterexample_EncodeDecodeRoundtripStatement_bounded={stmtA}"
    IO.println s!"{label}.counterexample_DecodeEncodeCanonicalBytesStatement_bounded={stmtB}"

def testsTypedIR : DecodedIR :=
  .execution (.typed defaultEnvelope defaultPayload)

def testsStepIR : DecodedIR :=
  .execution (.step { defaultEnvelope with mode := "composition-step" } defaultStepPayload)

def dirtyBoolGuardIR : DecodedIR :=
  let t : TemplateEnc := { transferTemplate with guard := .lit ⟨.bool, 5, true⟩ }
  let payload : TypedExecutePayloadEnc := { defaultPayload with registry := ⟨[⟨0, t⟩]⟩ }
  .execution (.typed defaultEnvelope payload)

def unsortedSourceMapIR : DecodedIR :=
  .execution (.typed { defaultEnvelope with source_map := [("z", "Z"), ("a", "A")] } defaultPayload)

def claimedNoncanonicalIR : DecodedIR :=
  let w : WorldEnc := ⟨⟨[⟨.main, .alice, .usd, ⟨2, 4⟩⟩]⟩, defaultStore12⟩
  .execution (.typed { defaultEnvelope with claimed_next_state := some w } defaultPayload)

def duplicateCellsIR : DecodedIR :=
  let cells : List StateCellEnc := List.replicate 32 ⟨.main, .alice, .usd, ⟨0, 1⟩⟩
  .execution (.typed defaultEnvelope { defaultPayload with state := ⟨cells⟩ })

def shuffledCellsIR : DecodedIR :=
  match initialCells.reverse with
  | cells => .execution (.typed defaultEnvelope { defaultPayload with state := ⟨cells⟩ })

def emptyTypesIR : DecodedIR :=
  let types : TypesEnumEnc := ⟨[], [], []⟩
  .execution (.typed { defaultEnvelope with types := types } defaultPayload)

def probeConstructed (label : String) (ir : DecodedIR) : IO Unit := do
  IO.println s!"===== CONSTRUCTED {label} ====="
  summarizeIR label ir
  let enc := encodeModule ir
  IO.println s!"encode_bytes={enc.size}"
  let dec := decodeBytes enc
  IO.println s!"decode(encode)={exceptIR dec}"
  match dec with
  | .ok ir2 =>
    IO.println s!"{label}.decode(encode)==ir : {decide (ir2 == ir)}"
    if ir2 != ir then
      let enc2 := encodeModule ir2
      reportBytesEq s!"{label}.encode(ir)_vs_encode(ir2)" enc enc2
      IO.println s!"{label}.source_map ir={sourceMapKeys ir} ir2={sourceMapKeys ir2}"
      match ir, ir2 with
      | .execution (.typed _ p1), .execution (.typed _ p2) =>
        IO.println s!"{label}.registry_eq={decide (p1.registry == p2.registry)}"
        IO.println s!"{label}.state_eq={decide (p1.state == p2.state)}"
        IO.println s!"{label}.request_eq={decide (p1.request == p2.request)}"
        IO.println s!"{label}.store_eq={decide (p1.store == p2.store)}"
        match p1.registry.entries.head?, p2.registry.entries.head? with
        | some e1, some e2 =>
          IO.println s!"{label}.guard_eq={decide (e1.template.guard == e2.template.guard)}"
          IO.println s!"{label}.guard1={repr e1.template.guard}"
          IO.println s!"{label}.guard2={repr e2.template.guard}"
        | _, _ => pure ()
      | _, _ => pure ()
  | .error _ => pure ()
  let stmtA := supportedIRB ir && canonicalIRB ir && !(decide (decodeBytes (encodeModule ir) == .ok ir))
  IO.println s!"{label}.counterexample_EncodeDecodeRoundtripStatement_bounded={stmtA}"

def fxDir : System.FilePath :=
  "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-roundtrip-domain-grok-r1/probes/fixtures"

def main : IO UInt32 := do
  IO.println "PROBE_START"
  IO.println s!"EncodeDecodeRoundtripStatement is a def Prop, not a theorem"
  IO.println s!"DecodeEncodeCanonicalBytesStatement is a def Prop, not a theorem"
  probeConstructed "testsTyped_F25like" testsTypedIR
  probeConstructed "testsStep_F27like" testsStepIR
  probeConstructed "dirtyBoolGuard" dirtyBoolGuardIR
  probeConstructed "unsortedSourceMap" unsortedSourceMapIR
  probeConstructed "claimedNoncanonicalRat" claimedNoncanonicalIR
  probeConstructed "duplicate32Cells" duplicateCellsIR
  probeConstructed "shuffledCells" shuffledCellsIR
  probeConstructed "emptyTypes" emptyTypesIR
  probeFile "F13_F25_raw" (fxDir / "F13.raw.json")
  probeFile "F28_raw" (fxDir / "F28.raw.json")
  probeFile "F27_python_compact" (fxDir / "F27.python-compact.json")
  let muts := [
    "reorder_envelope",
    "space_after_colon",
    "omit_invariants",
    "extra_caller_index",
    "unknown_envelope_field",
    "unreduced_arg",
    "unreduced_state",
    "reorder_source_map",
    "omit_claimedActor",
    "newline_after_brace",
    "extra_unit_quote",
    "unknown_party"
  ]
  for m in muts do
    probeFile s!"F13.mut.{m}" (fxDir / s!"F13.mut.{m}.json")
  -- rational unit checks
  IO.println "===== rational unit ====="
  IO.println s!"decodeRational 1 2 = {match decodeRational 1 2 with | .ok r => s!"ok {r.num}/{r.den}" | .error e => failToString e}"
  IO.println s!"decodeRational 2 4 = {match decodeRational 2 4 with | .ok r => s!"ok {r.num}/{r.den}" | .error e => failToString e}"
  IO.println s!"decodeRational 1 0 = {match decodeRational 1 0 with | .ok r => s!"ok {r.num}/{r.den}" | .error e => failToString e}"
  IO.println "PROBE_END"
  return 0


set_option maxRecDepth 100000
set_option maxHeartbeats 1000000

theorem root_dirtyBoolGuard_domain :
    SupportedIR dirtyBoolGuardIR ∧ CanonicalIR dirtyBoolGuardIR := by
  dsimp [dirtyBoolGuardIR, SupportedIR, CanonicalIR]
  decide

theorem root_unsortedSourceMap_domain :
    SupportedIR unsortedSourceMapIR ∧ CanonicalIR unsortedSourceMapIR := by
  dsimp [unsortedSourceMapIR, SupportedIR, CanonicalIR]
  decide

theorem root_claimedNoncanonical_domain :
    SupportedIR claimedNoncanonicalIR ∧ CanonicalIR claimedNoncanonicalIR := by
  dsimp [claimedNoncanonicalIR, SupportedIR, CanonicalIR]
  decide

#print axioms root_dirtyBoolGuard_domain
#print axioms root_unsortedSourceMap_domain
#print axioms root_claimedNoncanonical_domain
