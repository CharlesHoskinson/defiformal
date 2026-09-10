import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000
def controlIR (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) => .execution (.typed { env with source_map := sm } payload)
  | ir => ir
def runControl (n : Nat) : String := Id.run do
  let k := "k" ++ String.singleton (Char.ofNat n)
  let aliasKey := String.ofList ['k', 'u', '0', '0', hexDigit (n / 16), hexDigit (n % 16)]
  let ir := controlIR [(k, "v1"), (aliasKey, "v2")]
  let raw := encodeModule ir
  let str := (String.fromUTF8? raw).getD ""
  let scan := match scanLexical raw with | .ok _ => "ok" | .error e => reprStr e
  let dec := match decodeBytes raw with | .ok _ => "ok" | .error e => reprStr e
  let parser := match parseCanonicalJson str with
    | .ok j => match decodeDecodedIR j str with | .ok _ => "ok" | .error e => reprStr e
    | .error e => reprStr e
  return s!"C0={n};size={raw.size};depth={jsonDepth (decodedIRToJson ir)};maxArray={jsonMaxArrayLength (decodedIRToJson ir)};sorted={isSortedStrictAscending [k,aliasKey]};scan={scan};decode={dec};parserObject={parser}"
#eval List.range 32 |>.map runControl
#eval ["{\"a\":\"1\",\"a\":\"2\"}", "{\"a\":\"1\",\"\\u0061\":\"2\"}", "{\"q\\\"\":\"1\",\"q\":\"2\"}", "{\"b\\\\\":\"1\",\"b\":\"2\"}"].map fun s =>
  let scan := match scanLexical s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e
  let parser := match parseCanonicalJson s with | .ok _ => "ok" | .error e => reprStr e
  s!"raw={s};scan={scan};parser={parser}"
end DefiKernel.Certificates
