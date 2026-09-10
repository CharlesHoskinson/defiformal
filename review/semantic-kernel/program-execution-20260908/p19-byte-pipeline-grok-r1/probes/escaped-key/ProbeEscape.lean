import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000

/-- Replay helpers for the R15 escaped-key scanner diagnostic. -/
def withSourceMap (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) => .execution (.typed { env with source_map := sm } payload)
  | ir => ir

def collisionIR : DecodedIR := withSourceMap [("a\n", "1"), ("au000a", "2")]
def trueDupIR : DecodedIR := withSourceMap [("same", "1"), ("same", "2")]
def newlineOnlyIR : DecodedIR := withSourceMap [("a\n", "1")]
def literalOnlyIR : DecodedIR := withSourceMap [("au000a", "1")]

#eval IO.println "ENCODE_SOURCE_MAP"
#eval encodeSourceMap [("a\n", "1"), ("au000a", "2")]
#eval IO.println "ESCAPE_NEWLINE_KEY"
#eval escapeJsonString "a\n"
#eval IO.println "ESCAPE_LITERAL_KEY"
#eval escapeJsonString "au000a"
#eval IO.println "LEXSTRING_U000A"
#eval lexString [] ['u', '0', '0', '0', 'a', '"']
#eval IO.println "LEXSTRING_BACKSLASH_U000A"
#eval lexString [] ['\\', 'u', '0', '0', '0', 'a', '"']
#eval IO.println "SCAN_COLLISION"
#eval repr (scanLexical (encodeModule collisionIR))
#eval IO.println "DECODE_COLLISION"
#eval match decodeBytes (encodeModule collisionIR) with
  | .ok _ => "decodeBytes:ok"
  | .error e => "decodeBytes:error:" ++ reprStr e
#eval IO.println "PARSER_OBJECT_COLLISION"
#eval match parseCanonicalJson (encodeModuleString collisionIR) with
  | .ok j => match decodeDecodedIR j (encodeModuleString collisionIR) with
    | .ok _ => "parser+objectDecoder:ok"
    | .error e => "objectDecoder:error:" ++ reprStr e
  | .error e => "parser:error:" ++ reprStr e
#eval IO.println "STATS_COLLISION"
#eval (encodeModule collisionIR).size
#eval jsonDepth (decodedIRToJson collisionIR)
#eval jsonMaxArrayLength (decodedIRToJson collisionIR)
#eval isSortedStrictAscending (["a\n", "au000a"] : List String)
#eval IO.println "SCAN_TRUE_DUP"
#eval repr (scanLexical (encodeModule trueDupIR))
#eval IO.println "DECODE_TRUE_DUP"
#eval match decodeBytes (encodeModule trueDupIR) with
  | .ok _ => "decodeBytes:ok"
  | .error e => "decodeBytes:error:" ++ reprStr e
#eval IO.println "PARSER_TRUE_DUP"
#eval match parseCanonicalJson (encodeModuleString trueDupIR) with
  | .ok j => match decodeDecodedIR j (encodeModuleString trueDupIR) with
    | .ok _ => "parser+objectDecoder:ok"
    | .error e => "objectDecoder:error:" ++ reprStr e
  | .error e => "parser:error:" ++ reprStr e
#eval IO.println "SCAN_NEWLINE_ONLY"
#eval repr (scanLexical (encodeModule newlineOnlyIR))
#eval IO.println "SCAN_LITERAL_ONLY"
#eval repr (scanLexical (encodeModule literalOnlyIR))
#eval IO.println "JSONOBJ_ORDER"
#eval jsonObj [("b", "1"), ("a", "2")]
end DefiKernel.Certificates
