import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.Tests

/-!
Focused PB03/S55 assumption-class regression.

`computeAssumptions` must label each of the six required classes from actual
membership. First missing class follows SIX_ASSUMPTIONS order. Empty input
labels all six missing. Complete input labels all six present. Presence is
classification, not truth.

Frozen F41 in `openspec/changes/serialized-kernel-certificates/fixtures.json`
(SHA-256 `ad1857ecf7269920a2169ab7e644d28da3311cad91be60df09a737cf94fe7742`)
includes environment-authenticity and omits replay-prevention-outside-model.
Its frozen expected report inverts those two labels. Original bytes stay.
After repair, original F41 comparison must expose that mismatch. Companion
labels live in `f41-assumption-companions.json` and below. They are not a
rewrite of the frozen fixture.
-/
namespace DefiKernel.Certificates.AssumptionsRegression

open DefiKernel.Certificates
open DefiKernel.Certificates.Tests

set_option linter.style.longLine false

def omitClass (name : String) : List String :=
  SIX_ASSUMPTIONS.filter (· != name)

def envWith (present : List String) : EnvelopeEnc :=
  { defaultEnvelope with assumptions := present }

def expectedLabels (present : List String) : List (String × String) :=
  SIX_ASSUMPTIONS.map fun name =>
    (name, if present.contains name then "present" else "missing")

def expectedFirstMissing (present : List String) : Option String :=
  SIX_ASSUMPTIONS.find? (!present.contains ·)

def helperMatches (present : List String) : Bool :=
  let (pairs, missing) := computeAssumptions (envWith present)
  pairs == expectedLabels present && missing == expectedFirstMissing present

def presentByMask (mask : Nat) : List String :=
  (List.range SIX_ASSUMPTIONS.length).filterMap fun i =>
    if mask.testBit i then SIX_ASSUMPTIONS[i]? else none

def checkAllSubsets : Bool :=
  (List.range 64).all fun mask => helperMatches (presentByMask mask)

def checkEmpty : Bool := helperMatches []

def checkComplete : Bool := helperMatches SIX_ASSUMPTIONS

def checkEachIndividuallyMissing : Bool :=
  SIX_ASSUMPTIONS.all fun name => helperMatches (omitClass name)

def checkMixedMissing : Bool :=
  helperMatches (omitClass "registry-trust" |>.filter (· != "replay-prevention-outside-model")) &&
    helperMatches ["observation-truth", "environment-authenticity"]

/-- Frozen F41 input: environment present, replay absent. -/
def f41OriginalAssumptions : List String := [
  "registry-trust",
  "administrator-trust",
  "context-authenticity",
  "observation-truth",
  "environment-authenticity"
]

/-- Frozen F41 expected labels. These invert environment and replay. -/
def f41FrozenExpectedLabels : List (String × String) := [
  ("registry-trust", "present"),
  ("administrator-trust", "present"),
  ("context-authenticity", "present"),
  ("observation-truth", "present"),
  ("environment-authenticity", "missing"),
  ("replay-prevention-outside-model", "present")
]

/-- Independently supplied replay-missing companion labels. -/
def f41ReplayMissingCorrectedLabels : List (String × String) := [
  ("registry-trust", "present"),
  ("administrator-trust", "present"),
  ("context-authenticity", "present"),
  ("observation-truth", "present"),
  ("environment-authenticity", "present"),
  ("replay-prevention-outside-model", "missing")
]

/-- Independently supplied S55 environment-missing companion labels. -/
def s55EnvironmentMissingLabels : List (String × String) := [
  ("registry-trust", "present"),
  ("administrator-trust", "present"),
  ("context-authenticity", "present"),
  ("observation-truth", "present"),
  ("environment-authenticity", "missing"),
  ("replay-prevention-outside-model", "present")
]

def s55EnvironmentMissingAssumptions : List String :=
  omitClass "environment-authenticity"

def checkF41InputMembership : Bool :=
  f41OriginalAssumptions.contains "environment-authenticity" &&
    !f41OriginalAssumptions.contains "replay-prevention-outside-model"

/-- Original frozen expectation does not match F41 input membership. -/
def checkF41FrozenExpectationMismatchesInput : Bool :=
  f41FrozenExpectedLabels != expectedLabels f41OriginalAssumptions &&
    f41FrozenExpectedLabels != f41ReplayMissingCorrectedLabels

def checkReplayMissingCompanionLabels : Bool :=
  let (pairs, missing) := computeAssumptions (envWith f41OriginalAssumptions)
  pairs == f41ReplayMissingCorrectedLabels &&
    missing == some "replay-prevention-outside-model"

def checkS55EnvironmentMissingCompanionLabels : Bool :=
  let (pairs, missing) := computeAssumptions (envWith s55EnvironmentMissingAssumptions)
  pairs == s55EnvironmentMissingLabels &&
    missing == some "environment-authenticity"

def labelOf (pairs : List (String × String)) (name : String) : Option String :=
  (pairs.find? (fun p => p.1 == name)).map (·.2)

def checkEmptyLabelsAllMissing : Bool :=
  let (pairs, missing) := computeAssumptions (envWith [])
  missing == some "registry-trust" &&
    SIX_ASSUMPTIONS.all fun name => labelOf pairs name == some "missing"

def checkCompleteLabelsAllPresent : Bool :=
  let (pairs, missing) := computeAssumptions (envWith SIX_ASSUMPTIONS)
  missing == none &&
    SIX_ASSUMPTIONS.all fun name => labelOf pairs name == some "present"

def incompleteObligation (name : String) : Option FailurePath :=
  some ⟨.incompleteObligation, name, none⟩

def defaultRunPayload : CompositionRunPayloadEnc := {
  config := defaultConfig
  boundaries := [defaultStepPayload.boundary]
  world := defaultStepPayload.pre
  steps := [defaultStep]
}

def declaredFamily (rep : Report) : Option JudgmentResult :=
  rep.judgments.find? (fun j => j.family == "assumptionsDeclared")

/-- Inspect the actual report family, not the helper as an oracle. -/
def declaredFieldsOK (rep : Report) (present : List String) (claimedDeclared : Bool) : Bool :=
  let missing := expectedFirstMissing present
  let expectedOut := if missing.isSome then JudgmentOutcome.«false» else .«true»
  let expectedMatch :=
    match expectedOut with
    | .«true» => claimedDeclared == true
    | .«false» => claimedDeclared == false
    | .notReached => !claimedDeclared
    | .notApplicable => !claimedDeclared
  match declaredFamily rep with
  | none => false
  | some j =>
    j.outcome == expectedOut &&
      j.claimed == claimedDeclared &&
      j.«match» == expectedMatch &&
      rep.assumptions == expectedLabels present

def kernelPreservedTyped (rep : Report) (env : EnvelopeEnc) : Bool :=
  let raw := rawExecute (.typed env defaultPayload)
  rep.world == raw.world && rep.receipt == raw.receipt &&
    rep.outputs == raw.outputs && rep.events == raw.events &&
    rep.nextIndex == raw.nextIndex && rep.cursorFailure == raw.cursorFailure

def kernelPreservedStep (rep : Report) (env : EnvelopeEnc) : Bool :=
  let raw := rawExecute (.step env defaultStepPayload)
  rep.world == raw.world && rep.receipt == raw.receipt &&
    rep.outputs == raw.outputs && rep.events == raw.events &&
    rep.nextIndex == raw.nextIndex && rep.cursorFailure == raw.cursorFailure

def kernelPreservedRun (rep : Report) (env : EnvelopeEnc) : Bool :=
  let raw := rawExecute (.run env defaultRunPayload)
  rep.world == raw.world && rep.receipt == raw.receipt &&
    rep.outputs == raw.outputs && rep.events == raw.events &&
    rep.nextIndex == raw.nextIndex && rep.cursorFailure == raw.cursorFailure

/-- Production typed: missing class is incomplete with that class. Complete is accepted. -/
def typedPolicyOK (rep : Report) (present : List String) : Bool :=
  match expectedFirstMissing present with
  | some name =>
    rep.status == .incomplete && rep.failure == incompleteObligation name
  | none =>
    rep.status == .accepted && rep.failure == none

/-- Historical Check.step/run keep accepted status on kernel success. -/
def historicalStepRunStatusOK (rep : Report) : Bool :=
  rep.status == .accepted && rep.failure == none

def inspectTyped (checker : EnvelopeEnc → TypedExecutePayloadEnc → Report)
    (present : List String) (claimedDeclared : Bool) : Bool :=
  let env0 := envWith present
  let env := if claimedDeclared then
    { env0 with claimed_judgments := ["assumptionsDeclared"] } else env0
  let rep := checker env defaultPayload
  declaredFieldsOK rep present claimedDeclared &&
    typedPolicyOK rep present &&
    kernelPreservedTyped rep env

def inspectDeliveredStep (present : List String) : Bool :=
  let env := envWith present
  let rep := Delivered.checkStep env defaultStepPayload
  declaredFieldsOK rep present false &&
    typedPolicyOK rep present &&
    kernelPreservedStep rep env

def inspectDeliveredRun (present : List String) : Bool :=
  let env := envWith present
  let rep := Delivered.checkRun env defaultRunPayload
  declaredFieldsOK rep present false &&
    typedPolicyOK rep present &&
    kernelPreservedRun rep env

def inspectCheckStep (present : List String) : Bool :=
  let env := envWith present
  let rep := checkStep env defaultStepPayload
  declaredFieldsOK rep present false &&
    historicalStepRunStatusOK rep &&
    kernelPreservedStep rep env

def inspectCheckRun (present : List String) : Bool :=
  let env := envWith present
  let rep := checkRun env defaultRunPayload
  declaredFieldsOK rep present false &&
    historicalStepRunStatusOK rep &&
    kernelPreservedRun rep env

def allPresentMasks (inspect : List String → Bool) : Bool :=
  (List.range 64).all fun mask => inspect (presentByMask mask)

def checkTypedReport64 : Bool :=
  allPresentMasks (fun p => inspectTyped checkTyped p false)

def deliveredTypedReport64 : Bool :=
  allPresentMasks (fun p => inspectTyped Delivered.checkTyped p false)

def deliveredStepReport64 : Bool :=
  allPresentMasks inspectDeliveredStep

def deliveredRunReport64 : Bool :=
  allPresentMasks inspectDeliveredRun

def checkStepReport64 : Bool :=
  allPresentMasks inspectCheckStep

def checkRunReport64 : Bool :=
  allPresentMasks inspectCheckRun

def checkClaimedDoesNotBecomeTruth : Bool :=
  inspectTyped checkTyped [] true &&
    inspectTyped Delivered.checkTyped [] true &&
    inspectTyped checkTyped SIX_ASSUMPTIONS true &&
    inspectTyped Delivered.checkTyped SIX_ASSUMPTIONS true &&
    inspectTyped checkTyped (omitClass "environment-authenticity") true &&
    inspectTyped Delivered.checkTyped f41OriginalAssumptions true

def checkTypedS55Companion : Bool :=
  inspectTyped checkTyped s55EnvironmentMissingAssumptions false &&
    inspectTyped Delivered.checkTyped s55EnvironmentMissingAssumptions false

def checkTypedReplayMissingCompanion : Bool :=
  inspectTyped checkTyped f41OriginalAssumptions false &&
    inspectTyped Delivered.checkTyped f41OriginalAssumptions false

def checkDeliveredStepRunEmpty : Bool :=
  inspectDeliveredStep [] && inspectDeliveredRun []

def checkDeliveredStepRunComplete : Bool :=
  inspectDeliveredStep SIX_ASSUMPTIONS && inspectDeliveredRun SIX_ASSUMPTIONS

def checkHistoricalStepRunEmptyAccepted : Bool :=
  inspectCheckStep [] && inspectCheckRun []

def runtimeChecks : List (String × Bool) := [
  ("assumptions.subsets.64", checkAllSubsets),
  ("assumptions.empty", checkEmpty),
  ("assumptions.complete", checkComplete),
  ("assumptions.individually-missing", checkEachIndividuallyMissing),
  ("assumptions.mixed-missing", checkMixedMissing),
  ("assumptions.empty.labels", checkEmptyLabelsAllMissing),
  ("assumptions.complete.labels", checkCompleteLabelsAllPresent),
  ("assumptions.f41.input-membership", checkF41InputMembership),
  ("assumptions.f41.frozen-mismatch", checkF41FrozenExpectationMismatchesInput),
  ("assumptions.f41.replay-companion-labels", checkReplayMissingCompanionLabels),
  ("assumptions.s55.env-companion-labels", checkS55EnvironmentMissingCompanionLabels),
  ("assumptions.checkTyped.report-64", checkTypedReport64),
  ("assumptions.delivered.typed-64", deliveredTypedReport64),
  ("assumptions.delivered.step-64", deliveredStepReport64),
  ("assumptions.delivered.run-64", deliveredRunReport64),
  ("assumptions.checkStep.report-64", checkStepReport64),
  ("assumptions.checkRun.report-64", checkRunReport64),
  ("assumptions.claimed-not-truth", checkClaimedDoesNotBecomeTruth),
  ("assumptions.checkTyped.s55-companion", checkTypedS55Companion),
  ("assumptions.checkTyped.replay-companion", checkTypedReplayMissingCompanion),
  ("assumptions.delivered.step-run-empty", checkDeliveredStepRunEmpty),
  ("assumptions.delivered.step-run-complete", checkDeliveredStepRunComplete),
  ("assumptions.check.step-run-empty-historical", checkHistoricalStepRunEmptyAccepted)
]

def allPass : Bool := runtimeChecks.all (·.2)

end DefiKernel.Certificates.AssumptionsRegression

open DefiKernel.Certificates.AssumptionsRegression

def main (_args : List String) : IO UInt32 := do
  IO.println "AssumptionsRegression"
  for (name, ok) in runtimeChecks do
    IO.println s!"{name}: {ok}"
  if allPass then
    IO.println "all assumption-class checks passed"
    return 0
  IO.eprintln "in-Lean assumption-class checks failed"
  return 1
