import DefiKernel.Certificates.Check
import DefiKernel.Certificates.LibraryInstantiation
import DefiKernel.Certificates.TrustedHost
import DefiKernel.Parallel.Compatibility

/-!
Delivered production checker for P19/P20.

Historical `checkTyped` / `checkIR` / `checkBytes` remain in `DefiKernel.Certificates`
with their original statements. This namespace is the routed production entry:
full source-identity fields, payload-bound library instantiation, and per-step
Parallel.admit footprints. CLI `RunFixtures` check/raw/observation-pair use these
entrypoints.
-/
namespace DefiKernel.Certificates.Delivered

open DefiKernel.Certificates
open DefiKernel.Typed
open DefiKernel.Composition
open DefiKernel.Parallel

/-- All trusted identity fields. Envelope git alone is not source identity. -/
def sourceIdentity (pin : SourcePinEnc) : Bool :=
  pin.git == TrustedHost.gitSha &&
    pin.lean_toolchain == TrustedHost.leanToolchain &&
    pin.mathlib_rev == TrustedHost.mathlibRev &&
    TrustedHost.recordsMatch pin

def sourceIdentityFailure (pin : SourcePinEnc) : FailurePath :=
  if pin.git != TrustedHost.gitSha then
    ⟨.staleSource, "git", some pin.git⟩
  else if pin.lean_toolchain != TrustedHost.leanToolchain then
    ⟨.staleSource, "lean_toolchain", some pin.lean_toolchain⟩
  else if pin.mathlib_rev != TrustedHost.mathlibRev then
    ⟨.staleSource, "mathlib_rev", some pin.mathlib_rev⟩
  else
    ⟨.staleSource, "compiler_record", pin.compiler_record⟩

def sixClassPresence (env : EnvelopeEnc) : Bool :=
  SIX_ASSUMPTIONS.all (fun n => env.assumptions.contains n)

def claimedWorldAgreement (env : EnvelopeEnc) (post : WorldEnc) : Bool :=
  match env.claimed_next_state with
  | none => true
  | some w => decide (w = post)

/-- Invariants remain outstanding Prop; require_invariant_discharge cannot pass. -/
def recordedInvariantCompilerCheck (_env : EnvelopeEnc) : Bool := false

def requestedDischargeOk
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc) (claimWorld : WorldEnc) : Bool :=
  (!env.require_library_discharge ||
      LibraryInstantiation.instantiatedOverCertificate env.libraries env.source_pin payload claimWorld) &&
    (!env.require_invariant_discharge || recordedInvariantCompilerCheck env)

def requestedDischargeOkEnvelope (env : EnvelopeEnc) (claimWorld : WorldEnc)
    (payload? : Option TypedExecutePayloadEnc) : Bool :=
  match payload? with
  | some p => requestedDischargeOk env p claimWorld
  | none =>
    !env.require_library_discharge && !env.require_invariant_discharge

/-- Kernel fields of a report. Policy failures are not kernelFailure. -/
def kernelProjection (rep : Report) : RawObservation :=
  let kf : Option FailurePath :=
    match rep.failure with
    | some ⟨.kernel, _, _⟩ => rep.failure
    | some ⟨.interface, _, _⟩ => rep.failure
    | some ⟨.authority, _, _⟩ => rep.failure
    | some ⟨.configuration, _, _⟩ => rep.failure
    | some ⟨.internalReceipt, _, _⟩ => rep.failure
    | _ => none
  ⟨rep.world, rep.receipt, rep.outputs, rep.events, rep.nextIndex, rep.cursorFailure, kf⟩

def staleJudgments (claimed : ClaimedJudgments) : List JudgmentResult :=
  makeJudgments [
    ("typeCorrect", .notReached),
    ("footprintCorrect", .notReached),
    ("authorityCorrect", .notReached),
    ("accountingCorrect", .notReached),
    ("compositionCompatible", .notApplicable),
    ("assumptionsDeclared", .«true»),
    ("libraryTheoremsInstantiated", .notApplicable),
    ("sourceRefinement", .notApplicable)
  ] claimed

/-- Declared branch semantics: catalog component 0 versus remaining components,
each invoke analyzed at its original step index / boundary. Issue/revoke are
not Parallel branches; an invoke-free sequence is notApplicable rather than a
vacuous empty-empty admit success. -/
def compositionCompatibleFromSteps
    (cfg : Config Party Asset Domain)
    (boundaries : Nat → Boundary Party Asset Domain)
    (steps : List StepEnc) : JudgmentOutcome :=
  if (indexedInvokes steps).isEmpty then
    JudgmentOutcome.notApplicable
  else
    compositionCompatibleIndexed cfg boundaries steps

def notReachedFamilies (compat : JudgmentOutcome) (lib : JudgmentOutcome)
    (claimed : ClaimedJudgments) : List JudgmentResult :=
  makeJudgments [
    ("typeCorrect", .notReached),
    ("footprintCorrect", .notReached),
    ("authorityCorrect", .notReached),
    ("accountingCorrect", .notReached),
    ("compositionCompatible", compat),
    ("assumptionsDeclared", .«true»),
    ("libraryTheoremsInstantiated", lib),
    ("sourceRefinement", .notApplicable)
  ] claimed

def replaceFamily (rep : Report) (fam : String) (out : JudgmentOutcome) : Report :=
  { rep with judgments := rep.judgments.map (fun j =>
      if j.family == fam then { j with outcome := out } else j) }

/-- Required reached families are those with outcome true. A false family blocks accepted. -/
def requiredReachedFamiliesTrue (js : List JudgmentResult) : Bool :=
  js.all (fun j =>
    match j.outcome with
    | .«false» => false
    | _ => true)

def firstFalseFamily (js : List JudgmentResult) : String :=
  match js.find? (fun j =>
      match j.outcome with
      | .«false» => true
      | _ => false) with
  | some j => j.family
  | none => "family"

def claimedMismatch? (env : EnvelopeEnc) (world : WorldEnc) : Bool :=
  match env.claimed_next_state with
  | none => false
  | some w => decide (w ≠ world)

/-- Identity of an unmet requested discharge. Does not decide whether discharge fails. -/
def incompleteDischargeCtor (env : EnvelopeEnc) (js : List JudgmentResult) : String :=
  let libTrue : Bool :=
    match js.find? (fun j => j.family == "libraryTheoremsInstantiated") with
    | some j =>
      match j.outcome with
      | .«true» => true
      | _ => false
    | none => false
  if env.require_library_discharge && !libTrue then
    "libraryTheoremsInstantiated"
  else if env.require_invariant_discharge then
    "proof.ComponentContract.invariant"
  else
    "libraryTheoremsInstantiated"

/-- Production acceptance policy. Kernel world/receipt/outputs stay the raw observation.
A false required family or claimed-world mismatch is refused, not accepted. -/
def overlayPolicy (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (dischargeOk : Bool) (cursor : Option LocatedFailureEnc)
    (missingAssump : Option String) : Report :=
  match raw.kernelFailure with
  | some kf =>
    ⟨.refused, some kf, base.judgments, raw.world, raw.receipt, raw.outputs, raw.events,
      raw.nextIndex, cursor, base.assumptions, base.outstanding, base.source_pin,
      base.audit_roots, base.unsupported⟩
  | none =>
    if claimedMismatch? env raw.world then
      ⟨.refused, some ⟨.observationMismatch, "claimedNextState", none⟩, base.judgments,
        raw.world, raw.receipt, raw.outputs, raw.events, raw.nextIndex, cursor,
        base.assumptions, base.outstanding, base.source_pin, base.audit_roots,
        base.unsupported⟩
    else if missingAssump.isSome then
      ⟨.incomplete, some ⟨.incompleteObligation, missingAssump.getD "assumptionsDeclared", none⟩,
        base.judgments, raw.world, raw.receipt, raw.outputs, raw.events, raw.nextIndex, cursor,
        base.assumptions, base.outstanding, base.source_pin, base.audit_roots, base.unsupported⟩
    else if !dischargeOk then
      ⟨.incomplete, some ⟨.incompleteObligation, incompleteDischargeCtor env base.judgments, none⟩,
        base.judgments, raw.world, raw.receipt, raw.outputs, raw.events, raw.nextIndex, cursor,
        base.assumptions, base.outstanding, base.source_pin, base.audit_roots, base.unsupported⟩
    else if !requiredReachedFamiliesTrue base.judgments then
      ⟨.refused, some ⟨.configuration, firstFalseFamily base.judgments, none⟩, base.judgments,
        raw.world, raw.receipt, raw.outputs, raw.events, raw.nextIndex, cursor,
        base.assumptions, base.outstanding, base.source_pin, base.audit_roots, base.unsupported⟩
    else
      ⟨.accepted, none, base.judgments, raw.world, raw.receipt, raw.outputs, raw.events,
        raw.nextIndex, cursor, base.assumptions, base.outstanding, base.source_pin,
        base.audit_roots, base.unsupported⟩

/-- Production typed checker. Source identity first; kernel fields from rawExecute;
executable families from the legacy stage map; library/discharge overlay. -/
def checkTyped (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc) : Report :=
  let preWorld : WorldEnc := ⟨payload.state, payload.store⟩
  let (assumptionsList, missingAssump) := computeAssumptions env
  let claimed := parseClaimedJudgments env.claimed_judgments
  let outstanding := outstandingFamilies env
  if !sourceIdentity env.source_pin then
    ⟨.refused, some (sourceIdentityFailure env.source_pin), staleJudgments claimed,
     preWorld, none, [], [], 0, none, assumptionsList, outstanding, env.source_pin, env.audit_roots, none⟩
  else
    let raw := rawExecute (.typed env payload)
    let base := _root_.DefiKernel.Certificates.checkTyped env payload
    let claimWorld := env.claimed_next_state.getD raw.world
    let libOut := LibraryInstantiation.familyBound env.libraries env.source_pin payload claimWorld
    let overlaid := replaceFamily base "libraryTheoremsInstantiated" libOut
    overlayPolicy env overlaid raw (requestedDischargeOk env payload claimWorld)
      raw.cursorFailure missingAssump

def checkStep (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc) : Report :=
  let preWorld := payload.pre
  let (assumptionsList, missingAssump) := computeAssumptions env
  let claimed := parseClaimedJudgments env.claimed_judgments
  let outstanding := outstandingFamilies env
  if !sourceIdentity env.source_pin then
    ⟨.refused, some (sourceIdentityFailure env.source_pin), staleJudgments claimed,
     preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, env.source_pin, env.audit_roots, none⟩
  else
    let raw := rawExecute (.step env payload)
    let base := _root_.DefiKernel.Certificates.checkStep env payload
    overlayPolicy env base raw (requestedDischargeOkEnvelope env raw.world none)
      base.cursorFailure missingAssump

def checkRun (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc) : Report :=
  let preWorld := payload.world
  let (assumptionsList, missingAssump) := computeAssumptions env
  let claimed := parseClaimedJudgments env.claimed_judgments
  let outstanding := outstandingFamilies env
  if !sourceIdentity env.source_pin then
    ⟨.refused, some (sourceIdentityFailure env.source_pin), staleJudgments claimed,
     preWorld, none, [], [], 0, none, assumptionsList, outstanding, env.source_pin, env.audit_roots, none⟩
  else
    let raw := rawExecute (.run env payload)
    let base := _root_.DefiKernel.Certificates.checkRun env payload
    overlayPolicy env base raw (requestedDischargeOkEnvelope env raw.world none)
      raw.cursorFailure missingAssump

def checkIR (ir : DecodedIR) : Outcome :=
  match ir with
  | .execution (.typed env payload) => .execution (checkTyped env payload)
  | .execution (.step env payload) => .execution (checkStep env payload)
  | .execution (.run env payload) => .execution (checkRun env payload)
  | .audit a => .audit (checkAudit a)
  | .codec doc => .codec (.ok (.codec doc))

def checkBytes (bytes : ByteArray) : Outcome :=
  match decodeBytes bytes with
  | .error (.resourceLimit limit) => .codec (.blocked limit)
  | .error e => .codec (.malformed e)
  | .ok ir => checkIR ir

end DefiKernel.Certificates.Delivered
