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
def printRep (name : String) (rep : Report) : IO Unit :=
  IO.println (name ++ ": " ++ encodeReport rep)
#eval printRep "overlap_run" (Delivered.checkRun runEnv runPayload)
#eval printRep "library_positive" (Delivered.checkTyped libEnv defaultPayload)
#eval printRep "wrong_mathlib" (Delivered.checkTyped { defaultEnvelope with source_pin := { defaultSourcePin with mathlib_rev := "wrong" } } defaultPayload)
#eval printRep "wrong_compiler" (Delivered.checkTyped { defaultEnvelope with source_pin := { defaultSourcePin with compiler_record := some "wrong" } } defaultPayload)
#eval printRep "wrong_audit" (Delivered.checkTyped { defaultEnvelope with source_pin := { defaultSourcePin with audit_record := some "wrong" } } defaultPayload)
#eval printRep "wrong_module" (Delivered.checkTyped { libEnv with libraries := [⟨addOkIffLib.theoremName, some "Wrong.Module"⟩] } defaultPayload)
#eval printRep "changed_amount" (Delivered.checkTyped libEnv { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .usd),4,false⟩] } })
#eval do
  let base := "/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-grok-r5-review/"
  IO.FS.writeBinFile (base ++ "overlap-run.json") (encodeModule (.execution (.run runEnv runPayload)))
  IO.FS.writeBinFile (base ++ "library-positive.json") (encodeModule (.execution (.typed libEnv defaultPayload)))
  IO.FS.writeBinFile (base ++ "wrong-toolchain.json") (encodeModule (.execution (.typed { defaultEnvelope with source_pin := { defaultSourcePin with lean_toolchain := "wrong" } } defaultPayload)))
end ReviewR5
