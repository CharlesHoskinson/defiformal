import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
open DefiKernel.Certificates

def withSourceMapKey (key : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := [(key, "pin")] } payload)
  | ir => ir

theorem withSourceMapKey_admissible (key : String) :
    StructurallyAdmissibleIR (withSourceMapKey key) := by
  simpa [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, withSourceMapKey,
    canonicalWitnessIR, EnvelopeLengthBounds, SourceMapSorted, isSortedStrictAscending]
    using structurallyAdmissible_nonempty

#print axioms withSourceMapKey_admissible
#eval match decodeBytes (encodeModule (withSourceMapKey "plain")) with
  | .ok ir => ir == withSourceMapKey "plain"
  | _ => false
#eval match decodeBytes (encodeModule (withSourceMapKey "a\"b")) with
  | .ok ir => ir == withSourceMapKey "a\"b"
  | _ => false
#eval match Lean.Json.parse (String.fromUTF8! (encodeModule (withSourceMapKey "a\"b"))) with
  | .ok _ => true
  | .error _ => false
#eval match decodeBytes (encodeModule (withSourceMapKey "a\"b")) with
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e
