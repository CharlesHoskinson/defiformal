import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.Tests
open DefiKernel.Certificates
open DefiKernel.Certificates.Tests
def env : EnvelopeEnc := { defaultEnvelope with assumptions := [] }
def payload : CompositionRunPayloadEnc := ⟨defaultConfig, [defaultStepPayload.boundary], defaultStepPayload.pre, [defaultStep]⟩
def main : IO Unit := do
  for (label, rep) in [("Check.step", checkStep env defaultStepPayload),
      ("Delivered.step", Delivered.checkStep env defaultStepPayload),
      ("Check.run", checkRun env payload), ("Delivered.run", Delivered.checkRun env payload)] do
    IO.println s!"{label}: status={repr rep.status} failure={repr rep.failure} assumptionsDeclared={repr ((rep.judgments.find? (·.family == "assumptionsDeclared")).map (·.outcome))} labels={repr rep.assumptions}"
