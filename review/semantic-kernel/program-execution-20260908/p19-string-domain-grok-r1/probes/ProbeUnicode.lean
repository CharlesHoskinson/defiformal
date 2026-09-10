import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
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

def roundtripIR (ir : DecodedIR) : String :=
  match decodeBytes (encodeModule ir) with
  | .ok ir2 => if ir2 == ir then "ok-eq" else "ok-neq"
  | .error e => encodeDecodeFailure e

def jsonParseOk (s : String) : Bool :=
  match Lean.Json.parse (String.fromUTF8! (encodeModule (withSourceMapKey s))) with
  | .ok _ => true
  | .error _ => false

def eacute : String := "é"
def grin : String := "😀"
def plain : String := "plain"

#eval IO.println s!"plain-value-rt={roundtripIR (withChecker plain)}"
#eval IO.println s!"eacute-value-rt={roundtripIR (withChecker eacute)}"
#eval IO.println s!"grin-value-rt={roundtripIR (withChecker grin)}"
#eval IO.println s!"plain-key-rt={roundtripIR (withSourceMapKey plain)}"
#eval IO.println s!"eacute-key-rt={roundtripIR (withSourceMapKey eacute)}"
#eval IO.println s!"grin-key-rt={roundtripIR (withSourceMapKey grin)}"
#eval IO.println s!"plain-key-jsonparse={jsonParseOk plain}"
#eval IO.println s!"eacute-key-jsonparse={jsonParseOk eacute}"
#eval IO.println s!"grin-key-jsonparse={jsonParseOk grin}"
#eval IO.println s!"plain-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey plain))}"
#eval IO.println s!"quoted-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey (String.ofList ['a', '\"', 'b'])))}"
#eval IO.println s!"bs-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey (String.ofList ['a', '\\\\', 'b'])))}"
#eval IO.println s!"lf-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey \"\\n\"))}"
#eval IO.println s!"nul-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey (String.singleton (Char.ofNat 0))))}"
#eval IO.println s!"eacute-key-admissible={decide (StructurallyAdmissibleIR (withSourceMapKey eacute))}"
#eval IO.println "=== done ==="
