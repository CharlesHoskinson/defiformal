import DefiKernel.Certificates.Roundtrip
open DefiKernel DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 0

def witnessEnv : EnvelopeEnc := match canonicalWitnessIR with
  | .execution (.typed e _) => e
  | _ => default

def witnessWorld : WorldEnc := ⟨⟨standard32Cells⟩, ⟨[]⟩⟩
def witnessBoundary : BoundaryEnc := ⟨⟨.alice, .main⟩, ⟨[]⟩, 100⟩
def stepWitness : DecodedIR := .execution (.step
  { witnessEnv with mode := "composition-step" }
  ⟨⟨⟨[]⟩, [], []⟩, witnessBoundary, 0, [], .revoke 0, witnessWorld⟩)
def runWitness : DecodedIR := .execution (.run
  { witnessEnv with mode := "composition-run" }
  ⟨⟨⟨[]⟩, [], []⟩, [witnessBoundary], witnessWorld, [.revoke 0]⟩)

-- Runtime evidence of the concrete lexical premise, using the actual implementation.
#eval scanLexical (encodeModule canonicalWitnessIR)
#eval scanLexical (encodeModule stepWitness)
#eval scanLexical (encodeModule runWitness)

-- Kernel-checked admissibility of concrete empty-registry step and nonempty run.
theorem stepWitness_admissible : StructurallyAdmissibleIR stepWitness := by
  simp [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, stepWitness, witnessEnv,
    witnessWorld, witnessBoundary, canonicalWitnessIR, StandardTypesEnum, SourceMapSorted,
    ClaimedNextStateCanonical, StoreCanonical, StepCanonical, HistoryCanonical,
    BoundaryCanonical, EnvironmentCanonical, EnvelopeLengthBounds, StepPayloadLengthBounds,
    ConfigLengthBounds, StepLengthBounds, isSortedStrictAscending]
  decide

theorem runWitness_admissible : StructurallyAdmissibleIR runWitness := by
  simp [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, runWitness, witnessEnv,
    witnessWorld, witnessBoundary, canonicalWitnessIR, StandardTypesEnum, SourceMapSorted,
    ClaimedNextStateCanonical, StoreCanonical, StepCanonical, HistoryCanonical,
    BoundaryCanonical, EnvironmentCanonical, EnvelopeLengthBounds, RunPayloadLengthBounds,
    ConfigLengthBounds, StepLengthBounds, isSortedStrictAscending]
  decide
#print axioms stepWitness_admissible
#print axioms runWitness_admissible
