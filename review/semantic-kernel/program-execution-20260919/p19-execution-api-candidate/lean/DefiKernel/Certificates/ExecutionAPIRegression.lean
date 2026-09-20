import DefiKernel.Certificates.ExecutionAPI
import DefiKernel.Certificates.Tests
import DefiKernel.Certificates.Decode

/-!
Focused SF10/S97 regression for the execution-only public API.

Historical `Check.checkIR` / `Delivered.checkIR` have type `DecodedIR → Outcome`.
A `DecodedExecution → Report` ascription of those names is a type mismatch
(reproduced independently; not compiled here so this module stays green).
The designated public entry is `Delivered.Execution.checkIR`.
-/
namespace DefiKernel.Certificates.ExecutionAPIRegression

open DefiKernel.Certificates
open DefiKernel.Certificates.Tests
open DefiKernel.Certificates.Delivered

set_option linter.style.longLine false

#check (_root_.DefiKernel.Certificates.checkIR : DecodedIR → Outcome)
#check (Delivered.checkIR : DecodedIR → Outcome)
#check (Execution.checkIR : DecodedExecution → Report)
#check (Execution.checkBytes : ByteArray → Outcome)

theorem checkIR_typed (env : EnvelopeEnc) (p : TypedExecutePayloadEnc) :
    Execution.checkIR (.typed env p) = Delivered.checkTyped env p := rfl

theorem checkIR_step (env : EnvelopeEnc) (p : CompositionStepPayloadEnc) :
    Execution.checkIR (.step env p) = Delivered.checkStep env p := rfl

theorem checkIR_run (env : EnvelopeEnc) (p : CompositionRunPayloadEnc) :
    Execution.checkIR (.run env p) = Delivered.checkRun env p := rfl

theorem checkIR_compat (exec : DecodedExecution) :
    Delivered.checkIR (.execution exec) = .execution (Execution.checkIR exec) := by
  cases exec <;> rfl

theorem checkBytes_compat (bytes : ByteArray) :
    Execution.checkBytes bytes = Delivered.checkBytes bytes := by
  dsimp [Execution.checkBytes, Delivered.checkBytes, Delivered.checkIR]
  cases h : decodeBytes bytes with
  | error e =>
    cases e <;> rfl
  | ok ir =>
    cases ir with
    | execution exec => cases exec <;> rfl
    | audit a => rfl
    | codec doc => rfl

def defaultRunPayload : CompositionRunPayloadEnc := {
  config := defaultConfig
  boundaries := [defaultStepPayload.boundary]
  world := defaultStepPayload.pre
  steps := [defaultStep]
}

def typedExec : DecodedExecution := .typed defaultEnvelope defaultPayload
def stepExec : DecodedExecution := .step { defaultEnvelope with mode := "composition-step" } defaultStepPayload
def runExec : DecodedExecution := .run { defaultEnvelope with mode := "composition-run" } defaultRunPayload

def emptyBytes : ByteArray := ByteArray.empty

def deepBytes : ByteArray :=
  (String.ofList (List.replicate 65 '{' ++ List.replicate 65 '}')).toUTF8

def sampleAudit : DecodedAudit := {
  envelope := { defaultEnvelope with mode := "audit" }
  imported_theorems := some 0
}

def sampleCodec : DecodedCodecDocument := ⟨none, ""⟩

def checkTypedEq : Bool :=
  Execution.checkIR typedExec == Delivered.checkTyped defaultEnvelope defaultPayload

def checkStepEq : Bool :=
  Execution.checkIR stepExec ==
    Delivered.checkStep { defaultEnvelope with mode := "composition-step" } defaultStepPayload

def checkRunEq : Bool :=
  Execution.checkIR runExec ==
    Delivered.checkRun { defaultEnvelope with mode := "composition-run" } defaultRunPayload

def checkCompatWrap : Bool :=
  Delivered.checkIR (.execution typedExec) == .execution (Execution.checkIR typedExec) &&
    Delivered.checkIR (.execution stepExec) == .execution (Execution.checkIR stepExec) &&
    Delivered.checkIR (.execution runExec) == .execution (Execution.checkIR runExec)

def checkBytesTyped : Bool :=
  let bytes := encodeModule (.execution typedExec)
  Execution.checkBytes bytes == Delivered.checkBytes bytes &&
    match Execution.checkBytes bytes with
    | .execution _ => true
    | _ => false

def checkBytesStep : Bool :=
  let bytes := encodeModule (.execution stepExec)
  Execution.checkBytes bytes == Delivered.checkBytes bytes &&
    match Execution.checkBytes bytes with
    | .execution _ => true
    | _ => false

def checkBytesRun : Bool :=
  let bytes := encodeModule (.execution runExec)
  Execution.checkBytes bytes == Delivered.checkBytes bytes &&
    match Execution.checkBytes bytes with
    | .execution _ => true
    | _ => false

def checkMalformed : Bool :=
  Execution.checkBytes emptyBytes == Delivered.checkBytes emptyBytes &&
    match Execution.checkBytes emptyBytes with
    | .codec (.malformed .emptyDocument) => true
    | _ => false

def checkResourceBlocked : Bool :=
  Execution.checkBytes deepBytes == Delivered.checkBytes deepBytes &&
    match Execution.checkBytes deepBytes with
    | .codec (.blocked "maxDepth") => true
    | _ => false

def checkAuditSeparated : Bool :=
  let bytes := encodeModule (.audit sampleAudit)
  Execution.checkBytes bytes == Delivered.checkBytes bytes &&
    match Execution.checkBytes bytes with
    | .audit _ => true
    | _ => false

def checkCodecSeparated : Bool :=
  let bytes := encodeModule (.codec sampleCodec)
  Execution.checkBytes bytes == Delivered.checkBytes bytes &&
    match Execution.checkBytes bytes with
    | .codec _ => true
    | _ => false

def runtimeChecks : List (String × Bool) := [
  ("exec.typed.eq", checkTypedEq),
  ("exec.step.eq", checkStepEq),
  ("exec.run.eq", checkRunEq),
  ("exec.compat.wrap", checkCompatWrap),
  ("exec.bytes.typed", checkBytesTyped),
  ("exec.bytes.step", checkBytesStep),
  ("exec.bytes.run", checkBytesRun),
  ("exec.malformed", checkMalformed),
  ("exec.resource", checkResourceBlocked),
  ("exec.audit.separated", checkAuditSeparated),
  ("exec.codec.separated", checkCodecSeparated)
]

def allPass : Bool := runtimeChecks.all (·.2)

def main (args : List String) : IO UInt32 := do
  match args with
  | "write-typed" :: path :: _ =>
    IO.FS.writeBinFile path (encodeModule (.execution typedExec))
    IO.println s!"wrote {path}"
    return 0
  | _ =>
    IO.println "ExecutionAPIRegression"
    for (name, ok) in runtimeChecks do
      IO.println s!"{name}: {ok}"
    if !allPass then
      IO.eprintln "execution-only API regression failed"
      return 1
    IO.println "execution-only API regression passed"
    return 0

end DefiKernel.Certificates.ExecutionAPIRegression

def main (args : List String) : IO UInt32 :=
  DefiKernel.Certificates.ExecutionAPIRegression.main args
