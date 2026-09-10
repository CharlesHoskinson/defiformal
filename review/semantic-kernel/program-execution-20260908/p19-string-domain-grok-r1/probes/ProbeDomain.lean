import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates

def withChecker (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker_candidate := value } } payload)
  | ir => ir

def withSourceMapKey (key : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := [(key, "pin")] } payload)
  | ir => ir

def withLibraries (n : Nat) (lib : LibraryRefEnc) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with libraries := List.replicate n lib } payload)
  | ir => ir

def withCompilerRecord (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with compiler_record := some value } } payload)
  | ir => ir

def withFirstCellAmount (num : Int) (den : Nat) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    let cells :=
      match payload.state.cells with
      | c :: rest => { c with amount := ⟨num, den⟩ } :: rest
      | [] => []
    .execution (.typed env { payload with state := ⟨cells⟩ })
  | ir => ir

def xs4096 : String := String.ofList (List.replicate 4096 'x')
def xs4097 : String := String.ofList (List.replicate 4097 'x')
def quotedKey : String := "a\"b"

theorem quotedKey_admissible :
    StructurallyAdmissibleIR (withSourceMapKey quotedKey) := by
  decide

theorem libraries_cost_independent (n : Nat) (lib : LibraryRefEnc) :
    irStructuralByteCost (withLibraries n lib) =
      irStructuralByteCost canonicalWitnessIR := by
  dsimp [withLibraries, canonicalWitnessIR, irStructuralByteCost, envelopeByteCost,
    sourcePinByteCost]
  rfl

theorem compiler_record_cost_independent (value : String) :
    irStructuralByteCost (withCompilerRecord value) =
      irStructuralByteCost canonicalWitnessIR := by
  dsimp [withCompilerRecord, canonicalWitnessIR, irStructuralByteCost, envelopeByteCost,
    sourcePinByteCost]
  rfl

#eval IO.println "=== witness cost ==="
#eval IO.println s!"witness-cost={irStructuralByteCost canonicalWitnessIR}"
#eval IO.println s!"witness-bytes={(encodeModule canonicalWitnessIR).size}"
#eval IO.println s!"witness-admissible={decide (StructurallyAdmissibleIR canonicalWitnessIR)}"

#eval IO.println "=== quoted key membership/runtime ==="
#eval IO.println s!"quoted-decide={decide (StructurallyAdmissibleIR (withSourceMapKey quotedKey))}"
#eval IO.println s!"quoted-cost={irStructuralByteCost (withSourceMapKey quotedKey)}"
#eval IO.println s!"quoted-bytes={(encodeModule (withSourceMapKey quotedKey)).size}"

#eval IO.println "=== 4097-char checker shrinking ==="
#eval IO.println s!"len4097={xs4097.length}"
#eval IO.println s!"len4096={xs4096.length}"
#eval IO.println s!"checker4097-supported={decide (SupportedIR (withChecker xs4097))}"
#eval IO.println s!"checker4096-supported={decide (SupportedIR (withChecker xs4096))}"
#eval IO.println s!"checker4097-cost={irStructuralByteCost (withChecker xs4097)}"
#eval IO.println s!"checker4097-bytes={(encodeModule (withChecker xs4097)).size}"
#eval IO.println s!"checker4097-over-maxbytes={(encodeModule (withChecker xs4097)).size > 1048576}"
#eval IO.println s!"checker4097-decode={match decodeBytes (encodeModule (withChecker xs4097)) with | .ok ir => if ir == withChecker xs4097 then \"ok-eq\" else \"ok-neq\" | .error e => encodeDecodeFailure e}"
#eval IO.println s!"checker4096-decode={match decodeBytes (encodeModule (withChecker xs4096)) with | .ok ir => if ir == withChecker xs4096 then \"ok-eq\" else \"ok-neq\" | .error e => encodeDecodeFailure e}"

#eval IO.println "=== 1e18+1 state rational shrinking ==="
#eval IO.println s!"big-supported={decide (SupportedIR (withFirstCellAmount 1000000000000000001 1))}"
#eval IO.println s!"bound-1e18-supported={decide (SupportedIR (withFirstCellAmount 1000000000000000000 1))}"
#eval IO.println s!"big-canonical={decide (CanonicalIR (withFirstCellAmount 1000000000000000001 1))}"
#eval IO.println s!"big-bytes={(encodeModule (withFirstCellAmount 1000000000000000001 1)).size}"
#eval IO.println s!"big-decode={match decodeBytes (encodeModule (withFirstCellAmount 1000000000000000001 1)) with | .ok ir => if ir == withFirstCellAmount 1000000000000000001 1 then \"ok-eq\" else \"ok-neq\" | .error e => encodeDecodeFailure e}"

#eval IO.println "=== estimator omissions ==="
#eval IO.println s!"libs1-cost={irStructuralByteCost (withLibraries 1 ⟨xs4096, none⟩)}"
#eval IO.println s!"libs1-bytes={(encodeModule (withLibraries 1 ⟨xs4096, none⟩)).size}"
#eval IO.println s!"libs8-cost={irStructuralByteCost (withLibraries 8 ⟨xs4096, none⟩)}"
#eval IO.println s!"libs8-bytes={(encodeModule (withLibraries 8 ⟨xs4096, none⟩)).size}"
#eval IO.println s!"comp4096-cost={irStructuralByteCost (withCompilerRecord xs4096)}"
#eval IO.println s!"comp4096-bytes={(encodeModule (withCompilerRecord xs4096)).size}"
#eval IO.println s!"libs260-cost={irStructuralByteCost (withLibraries 260 ⟨xs4096, none⟩)}"
#eval IO.println s!"libs260-bytes={(encodeModule (withLibraries 260 ⟨xs4096, none⟩)).size}"
#eval IO.println s!"libs260-over-maxbytes={(encodeModule (withLibraries 260 ⟨xs4096, none⟩)).size > 1048576}"
#eval IO.println s!"libs260-supported-decide={decide (SupportedIR (withLibraries 260 ⟨xs4096, none⟩))}"
#eval IO.println s!"libs260-admissible-decide={decide (StructurallyAdmissibleIR (withLibraries 260 ⟨xs4096, none⟩))}"
#eval IO.println "=== done ==="
