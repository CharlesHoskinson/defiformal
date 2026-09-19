import DefiKernel.Certificates.Tests
open DefiKernel.Certificates DefiKernel.Certificates.Tests
namespace ReviewR5

def sharedCells : List CellEnc := [⟨.main, .alice, .usd⟩, ⟨.main, .bob, .usd⟩]
def component (id op : Nat) : ComponentEnc := {
  id := id
  privateCells := []
  exports := []
  imports := sharedCells.zipIdx.map fun (c,i) => ⟨⟨2,i⟩,c,true⟩
  operations := [⟨op,[⟨0,.numeric (.amount .usd)⟩],[]⟩]
}
def cfg : ConfigEnc := {
  registry := ⟨[⟨0,transferTemplate⟩,⟨1,transferTemplate⟩]⟩
  domainAdmin := defaultConfig.domainAdmin
  catalog := [component 0 0,component 1 1,⟨2,[],sharedCells.zipIdx.map (fun (c,i) => ⟨i,c,true⟩),[],[]⟩]
}
def inv (id op : Nat) : StepEnc := .invoke {
  component := id
  operation := op
  parties := [.bob]
  inputs := [.literal ⟨.numeric (.amount .usd),3,false⟩]
  capabilityIds := defaultRequest.capabilityIds
  claimedActor := none
}
def runPayload : CompositionRunPayloadEnc := {
  config := cfg
  boundaries := [defaultStepPayload.boundary, defaultStepPayload.boundary]
  world := defaultStepPayload.pre
  steps := [inv 0 0, inv 1 1]
}
def runEnv := { defaultEnvelope with mode := "composition-run" }
def libEnv := { defaultEnvelope with libraries := [addOkIffLib], require_library_discharge := true, source_pin := pinWithLibraryRecord }
#eval match configToTyped? cfg with
 | none => "configuration refused"
 | some c => reprStr (Delivered.compositionCompatibleFromSteps c (fun _ => boundaryToTyped defaultStepPayload.boundary) runPayload.steps)
#eval match configToTyped? cfg with
 | none => "configuration refused"
 | some c => reprStr (Delivered.compositionCompatibleFromSteps c (fun _ => boundaryToTyped defaultStepPayload.boundary) [inv 0 0,inv 0 0])
#eval match configToTyped? cfg with
 | none => "configuration refused"
 | some c => reprStr (Delivered.compositionCompatibleFromSteps c (fun _ => boundaryToTyped defaultStepPayload.boundary) [.revoke 0])
#eval match CompatibilityExamples.conflictAdmit with
 | .error (.conflict _ _) => true
 | _ => false

def actorCells : List CellEnc := sharedCells ++ [⟨.main,.vault,.usd⟩,⟨.main,.pool,.usd⟩]
def actorCfg : ConfigEnc := { cfg with catalog := [
 { component 0 0 with imports := actorCells.zipIdx.map fun (c,i) => ⟨⟨2,i⟩,c,true⟩ },
 { component 1 1 with imports := actorCells.zipIdx.map fun (c,i) => ⟨⟨2,i⟩,c,true⟩ },
 ⟨2,[],actorCells.zipIdx.map (fun (c,i) => ⟨i,c,true⟩),[],[]⟩] }
def actorRight : StepEnc := .invoke { component := 1,operation := 1,parties := [.pool],inputs := [.literal ⟨.numeric (.amount .usd),3,false⟩],capabilityIds := [],claimedActor := none }
def actorBoundary (i : Nat) := boundaryToTyped { defaultStepPayload.boundary with ctx := ⟨if i == 0 then .alice else .vault,.main⟩ }
#eval match configToTyped? actorCfg with
 | none => "configuration refused"
 | some c => reprStr (Delivered.compositionCompatibleFromSteps c actorBoundary [inv 0 0,actorRight])
#eval match configToTyped? actorCfg with
 | none => "configuration refused"
 | some c => reprStr (Delivered.compositionCompatibleFromSteps c (fun _ => actorBoundary 0) [inv 0 0,actorRight])
end ReviewR5
