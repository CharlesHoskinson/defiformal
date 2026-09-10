import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates

def largeStringIR : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker := String.ofList (List.replicate 1048577 'x') } } payload)
  | ir => ir

theorem largeStringIR_admissible : StructurallyAdmissibleIR largeStringIR := by
  change StructurallyAdmissibleIR canonicalWitnessIR
  exact structurallyAdmissible_nonempty

#print axioms largeStringIR_admissible
#eval (encodeModule largeStringIR).size > 1048576
#eval match decodeBytes (encodeModule largeStringIR) with
  | .error (.resourceLimit "maxBytes") => true
  | _ => false
