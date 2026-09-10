import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000
def mixedErrorInputs : List (String × String) := [
("bad_escape_then_scientific", "{\"a\":\"\\x\",\"b\":1e2}"),
("whitespace_then_bad_escape", "{\"a\": \"\\x\"}"),
("bad_escape_then_duplicate", "{\"a\":\"\\x\",\"b\":1,\"b\":2}"),
("bad_escape_then_depth", "{\"a\":\"\\x\",\"b\":[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]}"),
("scientific_then_bad_escape", "{\"b\":1e2,\"a\":\"\\x\"}"),
("duplicate_then_bad_escape", "{\"b\":1,\"b\":2,\"a\":\"\\x\"}")]
#eval mixedErrorInputs.map fun (name, s) =>
  let scan := match scanLexical s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e
  let dec := match decodeBytes s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e
  s!"{name};scan={scan};decode={dec}"
end DefiKernel.Certificates
