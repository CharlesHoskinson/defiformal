import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.Tests
open DefiKernel.Certificates
open DefiKernel.Certificates.Tests
def rp (step := defaultStep) : CompositionRunPayloadEnc := ⟨defaultConfig, [defaultStepPayload.boundary], defaultStepPayload.pre, [step]⟩
def badTyped : TypedExecutePayloadEnc := { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .usd), 11, false⟩] } }
def badStep : StepEnc := .invoke { component := 0, operation := 0, parties := [.bob], inputs := [.literal ⟨.numeric (.amount .usd), 11, false⟩], capabilityIds := [0,1,2,3,4,5,6,7,8,9,10,11], claimedActor := none }
def main : IO UInt32 := do
 let mut failures := 0
 for (label, checker, kernelChecker) in [
  ("typed", (fun env => Delivered.checkTyped env defaultPayload), (fun env => Delivered.checkTyped env badTyped)),
  ("step", (fun env => Delivered.checkStep env defaultStepPayload), (fun env => Delivered.checkStep env { defaultStepPayload with step := badStep })),
  ("run", (fun env => Delivered.checkRun env (rp)), (fun env => Delivered.checkRun env (rp badStep)))] do
  for (kind, run, env) in [
   ("stale", checker, { defaultEnvelope with source_pin := { defaultSourcePin with git := "bad" } }),
   ("claimed-world", checker, { defaultEnvelope with claimed_next_state := some defaultStepPayload.pre }),
   ("kernel", kernelChecker, defaultEnvelope)] do
   let complete := run env
   let missing := run { env with assumptions := [], claimed_judgments := ["assumptionsDeclared"] }
   let ok := complete.status == .refused && missing.status == .refused && complete.failure == missing.failure &&
    complete.world == missing.world && complete.receipt == missing.receipt && complete.outputs == missing.outputs && complete.events == missing.events && complete.nextIndex == missing.nextIndex && complete.cursorFailure == missing.cursorFailure &&
    missing.judgments.find? (·.family == "assumptionsDeclared") == some ⟨"assumptionsDeclared", .«false», true, false⟩
   IO.println s!"{label}/{kind}: {ok}; failure={repr missing.failure}"
   if !ok then failures := failures + 1
 return if failures == 0 then 0 else 1
