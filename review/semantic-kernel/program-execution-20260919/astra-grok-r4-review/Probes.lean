import DefiKernel.Certificates.Tests
open DefiKernel.Certificates DefiKernel.Certificates.Tests

def tagged : EnvelopeEnc := { defaultEnvelope with
  libraries := [⟨"DefiKernel.Arithmetic.Operations.add_ok_iff", some "Wrong.Module"⟩]
  require_library_discharge := true
  source_pin := { defaultSourcePin with compiler_record := TrustedHost.compilerRecords.head? } }
#eval libraryJudgment tagged
#eval (checkTyped tagged defaultPayload).judgments.filter (fun j => j.family == "libraryTheoremsInstantiated")
#eval (checkTyped { defaultEnvelope with source_pin := { defaultSourcePin with lean_toolchain := "wrong", mathlib_rev := "wrong", compiler_record := some "wrong" } } defaultPayload).status
#eval match configToTyped? defaultConfig with
 | none => false
 | some cfg => compositionCompatibleOutcome cfg defaultStepPayload.boundary.toBoundary (invokeSteps [defaultStep, defaultStep]) == JudgmentOutcome.«true»
#eval match configToTyped? defaultConfig with
 | none => false
 | some cfg => compositionCompatibleOutcome cfg defaultStepPayload.boundary.toBoundary [] == JudgmentOutcome.«true»
#print axioms DefiKernel.Certificates.LibraryInstantiation.instantiated_add_ok_iff
