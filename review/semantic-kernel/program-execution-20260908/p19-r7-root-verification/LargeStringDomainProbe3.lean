import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates

def withCheckerStringIR (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker_candidate := value } } payload)
  | ir => ir

theorem withCheckerStringIR_admissible (value : String) :
    StructurallyAdmissibleIR (withCheckerStringIR value) := by
  change StructurallyAdmissibleIR canonicalWitnessIR
  exact structurallyAdmissible_nonempty

def largeStringIR : DecodedIR :=
  withCheckerStringIR (String.ofList (List.replicate 1048577 'x'))

theorem largeStringIR_admissible : StructurallyAdmissibleIR largeStringIR :=
  withCheckerStringIR_admissible _

#print axioms largeStringIR_admissible
#eval (encodeModule largeStringIR).size > 1048576
#eval match decodeBytes (encodeModule largeStringIR) with
  | .error (.resourceLimit "maxBytes") => true
  | _ => false
