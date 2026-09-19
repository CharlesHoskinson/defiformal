import DefiKernel.Certificates.Tests
open DefiKernel.Certificates DefiKernel.Certificates.Tests
namespace AdapterR5
open DefiKernel.Parallel
open DefiKernel.Parallel.Examples

def encodeInv (i : DefiKernel.Composition.Invocation Party Asset Domain) : StepEnc :=
 .invoke ⟨i.component.value, i.operation.value, i.parties,
   [.literal ⟨.numeric (.amount .usd), 3, false⟩], i.capabilityIds.map (·.value), i.claimedActor⟩
def steps : List StepEnc := [encodeInv (usd 3), encodeInv (invoke 1 11 .usd 3)]
def cfg := CompatibilityExamples.overlapCfg
#eval (admitIndexed cfg (fun n => boundaries .left n) steps).isOk
#eval (admitIndexed cfg (fun n => boundaries .left n) [encodeInv (usd 3),encodeInv (usd 3)]).isOk
#eval match CompatibilityExamples.conflictAdmit with
  | .error (.conflict _ _) => true
  | _ => false
#eval Delivered.compositionCompatibleFromSteps cfg (fun n => boundaries .left n) []
#eval (indexedInvokes [.revoke ⟨0, .main⟩]).length
end AdapterR5
