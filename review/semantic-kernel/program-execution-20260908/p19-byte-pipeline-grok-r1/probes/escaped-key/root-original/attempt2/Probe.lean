import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000
def withSourceMap (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) => .execution (.typed { env with source_map := sm } payload)
  | ir => ir
def collisionIR : DecodedIR := withSourceMap [("a\n", "1"), ("au000a", "2")]
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
#eval (encodeModule collisionIR).size
#eval jsonDepth (decodedIRToJson collisionIR)
#eval jsonMaxArrayLength (decodedIRToJson collisionIR)
#eval isSortedStrictAscending (["a\n", "au000a"] : List String)
end DefiKernel.Certificates
