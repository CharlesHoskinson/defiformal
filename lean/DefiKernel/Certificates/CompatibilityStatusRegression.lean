import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Tests

/-!
Focused compatibility-status regression for the delivered checker.

The overlapping payload is the sealed R5 / grok-r6-overlap-run case: two catalog
components each transfer USD 3 across the same alice/bob cells. Sequential
execution succeeds (alice=4, bob=6); Parallel.admit reports a write conflict.
Delivered must refuse that failed required family and must not rewrite the
raw world/receipt. Historical `Certificates.checkRun` still accepts — that
statement is preserved.

The positive control is the same world and sequential runner with disjoint
writes (USD transfer vs SHARE transfer).
-/
namespace DefiKernel.Certificates.CompatibilityStatusRegression

open DefiKernel.Certificates
open DefiKernel.Certificates.Tests

set_option linter.style.longLine false

def runEnvelope : EnvelopeEnc := { defaultEnvelope with mode := "composition-run" }

def overlapRegistry : RegistryEnc := ⟨[⟨0, transferTemplate⟩, ⟨1, transferTemplate⟩]⟩

def aliceUSD : CellEnc := ⟨.main, .alice, .usd⟩
def bobUSD : CellEnc := ⟨.main, .bob, .usd⟩
def aliceShare : CellEnc := ⟨.main, .alice, .share⟩
def vaultShare : CellEnc := ⟨.main, .vault, .share⟩

/-- Exact overlapping catalog from grok-r6-overlap-run.json. -/
def overlapCatalog : List ComponentEnc := [
  {
    id := 0, privateCells := [], exports := [],
    imports := [
      ⟨⟨2, 0⟩, aliceUSD, true⟩,
      ⟨⟨2, 1⟩, bobUSD, true⟩
    ],
    operations := [{ operation := 0, inputs := [⟨0, .numeric (.amount .usd)⟩], outputs := [] }]
  },
  {
    id := 1, privateCells := [], exports := [],
    imports := [
      ⟨⟨2, 0⟩, aliceUSD, true⟩,
      ⟨⟨2, 1⟩, bobUSD, true⟩
    ],
    operations := [{ operation := 1, inputs := [⟨0, .numeric (.amount .usd)⟩], outputs := [] }]
  },
  {
    id := 2, privateCells := [],
    exports := [⟨0, aliceUSD, true⟩, ⟨1, bobUSD, true⟩],
    imports := [], operations := []
  }
]

def overlapConfig : ConfigEnc := {
  registry := overlapRegistry
  domainAdmin := [⟨.main, .vault⟩, ⟨.other, .vault⟩]
  catalog := overlapCatalog
}

def caps12 : List Nat := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

def overlapStep0 : StepEnc := .invoke {
  component := 0, operation := 0, parties := [.bob],
  inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩],
  capabilityIds := caps12, claimedActor := none
}

def overlapStep1 : StepEnc := .invoke {
  component := 1, operation := 1, parties := [.bob],
  inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩],
  capabilityIds := caps12, claimedActor := none
}

def overlapBoundary : BoundaryEnc := ⟨defaultContext, ⟨[]⟩, 100⟩

def overlapPayload : CompositionRunPayloadEnc := {
  config := overlapConfig
  boundaries := [overlapBoundary, overlapBoundary]
  world := ⟨initialStateEnc, defaultStore12⟩
  steps := [overlapStep0, overlapStep1]
}

def shareTransferTemplate : TemplateEnc := {
  signature := [.numeric (.amount .share)]
  domain := .main
  partyArity := 0
  guard := .binary (.le (.amount .share))
    (.lit ⟨.numeric (.amount .share), 0, false⟩)
    (.arg 0 (.numeric (.amount .share)))
  deltas := [
    ⟨.share, ⟨.main, .caller⟩, .unary (.neg (.amount .share)) (.arg 0 (.numeric (.amount .share)))⟩,
    ⟨.share, ⟨.main, .literal .vault⟩, .arg 0 (.numeric (.amount .share))⟩
  ]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [⟨.share, ⟨.main, .caller⟩⟩, ⟨.share, ⟨.main, .literal .vault⟩⟩]
}

def disjointRegistry : RegistryEnc := ⟨[⟨0, transferTemplate⟩, ⟨1, shareTransferTemplate⟩]⟩

def disjointCatalog : List ComponentEnc := [
  {
    id := 0, privateCells := [], exports := [],
    imports := [
      ⟨⟨2, 0⟩, aliceUSD, true⟩,
      ⟨⟨2, 1⟩, bobUSD, true⟩
    ],
    operations := [{ operation := 0, inputs := [⟨0, .numeric (.amount .usd)⟩], outputs := [] }]
  },
  {
    id := 1, privateCells := [], exports := [],
    imports := [
      ⟨⟨2, 2⟩, aliceShare, true⟩,
      ⟨⟨2, 3⟩, vaultShare, true⟩
    ],
    operations := [{ operation := 1, inputs := [⟨0, .numeric (.amount .share)⟩], outputs := [] }]
  },
  {
    id := 2, privateCells := [],
    exports := [
      ⟨0, aliceUSD, true⟩, ⟨1, bobUSD, true⟩,
      ⟨2, aliceShare, true⟩, ⟨3, vaultShare, true⟩
    ],
    imports := [], operations := []
  }
]

def disjointStore : StoreEnc := ⟨defaultStore12.entries ++ [
  ⟨.alice, .main, 1, .debit aliceShare, true⟩
]⟩

def disjointStep1 : StepEnc := .invoke {
  component := 1, operation := 1, parties := [],
  inputs := [.literal ⟨.numeric (.amount .share), 1, false⟩],
  capabilityIds := caps12 ++ [12], claimedActor := none
}

def disjointPayload : CompositionRunPayloadEnc := {
  config := {
    registry := disjointRegistry
    domainAdmin := [⟨.main, .vault⟩, ⟨.other, .vault⟩]
    catalog := disjointCatalog
  }
  boundaries := [overlapBoundary, overlapBoundary]
  world := ⟨initialStateEnc, disjointStore⟩
  steps := [overlapStep0, disjointStep1]
}

def familyOutcome (rep : Report) (fam : String) : Option JudgmentOutcome :=
  (rep.judgments.find? (fun j => j.family == fam)).map (·.outcome)

def mainUsd (rep : Report) (p : Party) : Option RatEnc :=
  (rep.world.state.cells.find? (fun c =>
    c.domain == .main && c.party == p && c.asset == .usd)).map (·.amount)

def mainShare (rep : Report) (p : Party) : Option RatEnc :=
  (rep.world.state.cells.find? (fun c =>
    c.domain == .main && c.party == p && c.asset == .share)).map (·.amount)

def overlapDelivered : Report := Delivered.checkRun runEnvelope overlapPayload
def overlapHistorical : Report := _root_.DefiKernel.Certificates.checkRun runEnvelope overlapPayload
def overlapRaw : RawObservation := rawExecute (.run runEnvelope overlapPayload)
def disjointDelivered : Report := Delivered.checkRun runEnvelope disjointPayload

/-- Exact existing compatibility regression: overlapping USD writes are false, not accepted. -/
def checkOverlapDeliveredRefused : Bool :=
  overlapDelivered.status == .refused &&
    overlapDelivered.failure == some ⟨.configuration, "compositionCompatible", none⟩ &&
    familyOutcome overlapDelivered "compositionCompatible" == some .«false» &&
    Delivered.requiredReachedFamiliesTrue overlapDelivered.judgments == false

/-- Sequential observation is preserved: alice 4 / bob 6, invoked receipt, two events. -/
def checkOverlapWorldReceipt : Bool :=
  mainUsd overlapDelivered .alice == some ⟨4, 1⟩ &&
    mainUsd overlapDelivered .bob == some ⟨6, 1⟩ &&
    overlapDelivered.receipt.isSome &&
    overlapDelivered.events.length == 2 &&
    overlapDelivered.nextIndex == 2 &&
    overlapDelivered.cursorFailure == none &&
    overlapDelivered.world == overlapRaw.world &&
    overlapDelivered.receipt == overlapRaw.receipt

/-- Historical checkRun still accepts the overlapping sequential success. Do not weaken it. -/
def checkOverlapHistoricalAccepted : Bool :=
  overlapHistorical.status == .accepted &&
    familyOutcome overlapHistorical "compositionCompatible" == some .«false» &&
    mainUsd overlapHistorical .alice == some ⟨4, 1⟩ &&
    mainUsd overlapHistorical .bob == some ⟨6, 1⟩

/-- Legitimate nonconflicting control: USD vs SHARE writes, delivered accepts. -/
def checkDisjointDeliveredAccepted : Bool :=
  disjointDelivered.status == .accepted &&
    disjointDelivered.failure == none &&
    familyOutcome disjointDelivered "compositionCompatible" == some .«true» &&
    Delivered.requiredReachedFamiliesTrue disjointDelivered.judgments == true &&
    mainUsd disjointDelivered .alice == some ⟨7, 1⟩ &&
    mainUsd disjointDelivered .bob == some ⟨3, 1⟩ &&
    mainShare disjointDelivered .alice == some ⟨3, 1⟩ &&
    mainShare disjointDelivered .vault == some ⟨1, 1⟩ &&
    disjointDelivered.receipt.isSome &&
    disjointDelivered.events.length == 2

/-- Same production `checkBytes` path as RunFixtures check. -/
def checkOverlapViaBytes : Bool :=
  match Delivered.checkBytes (encodeModule (.execution (.run runEnvelope overlapPayload))) with
  | .execution rep =>
    rep.status == .refused &&
      familyOutcome rep "compositionCompatible" == some .«false» &&
      mainUsd rep .alice == some ⟨4, 1⟩ &&
      mainUsd rep .bob == some ⟨6, 1⟩ &&
      rep.receipt.isSome
  | _ => false

def checkDisjointViaBytes : Bool :=
  match Delivered.checkBytes (encodeModule (.execution (.run runEnvelope disjointPayload))) with
  | .execution rep =>
    rep.status == .accepted &&
      rep.failure == none &&
      familyOutcome rep "compositionCompatible" == some .«true» &&
      mainUsd rep .alice == some ⟨7, 1⟩ &&
      mainShare rep .alice == some ⟨3, 1⟩ &&
      rep.receipt.isSome
  | _ => false

def invariantOnlyEnv : EnvelopeEnc :=
  { defaultEnvelope with
    require_library_discharge := false
    require_invariant_discharge := true
    invariants := ["I"] }

def libraryOnlyEnv : EnvelopeEnc :=
  { defaultEnvelope with
    libraries := [addOkIffLib]
    require_library_discharge := true
    require_invariant_discharge := false
    source_pin := pinNameOnly }

def bothLibraryOkEnv : EnvelopeEnc :=
  { defaultEnvelope with
    libraries := [addOkIffLib]
    require_library_discharge := true
    require_invariant_discharge := true
    invariants := ["I"]
    source_pin := pinWithLibraryRecord }

def bothLibraryFailEnv : EnvelopeEnc :=
  { defaultEnvelope with
    libraries := [addOkIffLib]
    require_library_discharge := true
    require_invariant_discharge := true
    invariants := ["I"]
    source_pin := pinNameOnly }

def invariantOnlyReport : Report := Delivered.checkTyped invariantOnlyEnv defaultPayload
def libraryOnlyReport : Report := Delivered.checkTyped libraryOnlyEnv defaultPayload
def bothLibraryOkReport : Report := Delivered.checkTyped bothLibraryOkEnv defaultPayload
def bothLibraryFailReport : Report := Delivered.checkTyped bothLibraryFailEnv defaultPayload

/-- Astra invariant-only: unmet invariant obligation, not a library identity. -/
def checkInvariantOnlyCtor : Bool :=
  invariantOnlyReport.status == .incomplete &&
    invariantOnlyReport.failure ==
      some ⟨.incompleteObligation, "proof.ComponentContract.invariant", none⟩ &&
    invariantOnlyReport.receipt.isSome

/-- Library-only name-only pin still names the library obligation. -/
def checkLibraryOnlyCtor : Bool :=
  libraryOnlyReport.status == .incomplete &&
    libraryOnlyReport.failure ==
      some ⟨.incompleteObligation, "libraryTheoremsInstantiated", none⟩

/-- Both requested, library instantiated: remaining identity is the invariant. -/
def checkBothLibraryOkCtor : Bool :=
  bothLibraryOkReport.status == .incomplete &&
    bothLibraryOkReport.failure ==
      some ⟨.incompleteObligation, "proof.ComponentContract.invariant", none⟩ &&
    familyOutcome bothLibraryOkReport "libraryTheoremsInstantiated" == some .«true»

/-- Both requested, library unmet: library identity stays truthful. -/
def checkBothLibraryFailCtor : Bool :=
  bothLibraryFailReport.status == .incomplete &&
    bothLibraryFailReport.failure ==
      some ⟨.incompleteObligation, "libraryTheoremsInstantiated", none⟩

def runtimeChecks : List (String × Bool) := [
  ("compat.overlap.delivered-refused", checkOverlapDeliveredRefused),
  ("compat.overlap.world-receipt", checkOverlapWorldReceipt),
  ("compat.overlap.historical-accepted", checkOverlapHistoricalAccepted),
  ("compat.disjoint.delivered-accepted", checkDisjointDeliveredAccepted),
  ("compat.overlap.checkBytes", checkOverlapViaBytes),
  ("compat.disjoint.checkBytes", checkDisjointViaBytes),
  ("compat.discharge.invariant-only", checkInvariantOnlyCtor),
  ("compat.discharge.library-only", checkLibraryOnlyCtor),
  ("compat.discharge.both-library-ok", checkBothLibraryOkCtor),
  ("compat.discharge.both-library-fail", checkBothLibraryFailCtor)
]

def allPass : Bool := runtimeChecks.all (·.2)

def describeFileCheck (rep : Report) : String :=
  let compat := match familyOutcome rep "compositionCompatible" with
    | some .«false» => "false"
    | some .«true» => "true"
    | some .notReached => "not_reached"
    | some .notApplicable => "not_applicable"
    | none => "missing"
  let st := match rep.status with
    | .accepted => "accepted"
    | .refused => "refused"
    | .incomplete => "incomplete"
  let fail := match rep.failure with
    | none => "null"
    | some f => f.ctor
  s!"status={st} failure={fail} compositionCompatible={compat} events={rep.events.length}"

def describeDischarge (rep : Report) : String :=
  let st := match rep.status with
    | .accepted => "accepted"
    | .refused => "refused"
    | .incomplete => "incomplete"
  let fail := match rep.failure with
    | none => "null"
    | some f => f.ctor
  let lib := match familyOutcome rep "libraryTheoremsInstantiated" with
    | some .«true» => "true"
    | some .«false» => "false"
    | some .notReached => "not_reached"
    | some .notApplicable => "not_applicable"
    | none => "missing"
  s!"status={st} failure={fail} libraryTheoremsInstantiated={lib}"

def main (args : List String) : IO UInt32 := do
  IO.println "CompatibilityStatusRegression"
  IO.println s!"DIAG invariant-only: {describeDischarge invariantOnlyReport}"
  IO.println s!"DIAG library-only: {describeDischarge libraryOnlyReport}"
  IO.println s!"DIAG both-library-ok: {describeDischarge bothLibraryOkReport}"
  IO.println s!"DIAG both-library-fail: {describeDischarge bothLibraryFailReport}"
  IO.println s!"DIAG disjoint-accepted: {describeFileCheck disjointDelivered}"
  for (name, ok) in runtimeChecks do
    IO.println s!"{name}: {ok}"
  if !allPass then
    IO.eprintln "in-Lean compatibility status checks failed"
    return 1
  match args with
  | [] =>
    IO.println "no fixture path; in-Lean overlap/disjoint checks passed"
    return 0
  | path :: _ =>
    let bytes ← IO.FS.readBinFile path
    match Delivered.checkBytes bytes with
    | .execution rep =>
      IO.println s!"file {path}: {describeFileCheck rep}"
      let compatFalse := familyOutcome rep "compositionCompatible" == some .«false»
      if rep.status == .accepted && compatFalse then
        IO.eprintln "file check accepted a false compositionCompatible family"
        return 1
      if compatFalse && rep.status != .refused then
        IO.eprintln "file check did not refuse a false compositionCompatible family"
        return 1
      return 0
    | _ =>
      IO.eprintln "file check did not produce an execution report"
      return 1

end DefiKernel.Certificates.CompatibilityStatusRegression

def main (args : List String) : IO UInt32 :=
  DefiKernel.Certificates.CompatibilityStatusRegression.main args
