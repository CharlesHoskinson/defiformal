import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000
def withSourceMap (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) => .execution (.typed { env with source_map := sm } payload)
  | ir => ir
def collisionIR : DecodedIR := withSourceMap [("a\n", "1"), ("au000a", "2")]
theorem escapedKeyCollision_admissible : StructurallyAdmissibleIR collisionIR := by
  dsimp [StructurallyAdmissibleIR, SupportedIR, CanonicalIR, collisionIR, withSourceMap, canonicalWitnessIR, StandardTypesEnum,
         SourceMapSorted, ClaimedNextStateCanonical, standard32Cells, standard32CellKeys,
         isSortedStrictAscending, StoreCanonical, RequestCanonical, EnvironmentCanonical,
         WorldCanonical, StateCellsMatchStandard32, EnvelopeLengthBounds, TypedPayloadLengthBounds,
         TemplateLengthBounds, SerializedByteBound, WholeDocumentDepthBounded, WholeDocumentArrayBounded]
  refine ⟨⟨by decide, by decide, by decide, ⟨rfl, rfl, ⟨rfl, rfl, rfl⟩, rfl, rfl, by decide, List.nodup_nil, List.nodup_nil, by decide, ?_⟩⟩, ?_⟩
  · refine ⟨rfl, by decide, ?_, by decide, by decide, by decide, by decide, by decide⟩
    intro _ h; contradiction
  · refine ⟨rfl, trivial, by decide, ?_, ?_, ?_⟩
    · intro _ h; contradiction
    · intro _ h; contradiction
    · intro _ h; contradiction


#print axioms escapedKeyCollision_admissible
#eval encodeSourceMap [("a\n", "1"), ("au000a", "2")]
#eval repr (scanLexical (encodeModule collisionIR))
#eval match decodeBytes (encodeModule collisionIR) with
  | .ok _ => "decodeBytes:ok"
  | .error e => "decodeBytes:error:" ++ reprStr e
#eval match parseCanonicalJson (encodeModuleString collisionIR) with
  | .ok j => match decodeDecodedIR j (encodeModuleString collisionIR) with
    | .ok _ => "parser+objectDecoder:ok"
    | .error e => "objectDecoder:error:" ++ reprStr e
  | .error e => "parser:error:" ++ reprStr e
end DefiKernel.Certificates
