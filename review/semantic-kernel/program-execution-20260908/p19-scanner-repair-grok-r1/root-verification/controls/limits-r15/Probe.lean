import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000

def showScan (bytes : ByteArray) : String :=
  match scanLexical bytes with | .ok _ => "ok" | .error e => reprStr e

def showParse (s : String) : String :=
  match parseCanonicalJson s with | .ok _ => "ok" | .error e => reprStr e

def showDecode (bytes : ByteArray) : String :=
  match decodeBytes bytes with | .ok _ => "ok" | .error e => reprStr e

def makeArrObj (n : Nat) : String :=
  "{\"k\":[" ++ String.intercalate "," (List.replicate n "1") ++ "]}"

def arrRow (n : Nat) : String :=
  let s := makeArrObj n
  let b := s.toUTF8
  let j := match parseCanonicalJson s with
    | .ok j => j
    | .error _ => Lean.Json.null
  s!"n={n};bytes={b.size};scan={showScan b};parse={showParse s};decode={showDecode b};jsonMaxArray={jsonMaxArrayLength j}"

/- Scanner comma-count vs parser acc.size vs whole-document jsonMaxArrayLength. -/
#eval [4095, 4096, 4097].map arrRow

/- Top-level array is a document-shape failure, not an array-length measurement. -/
#eval
  let s := "[" ++ String.intercalate "," (List.replicate 4097 "1") ++ "]"
  s!"toplevelArr4097;scan={showScan s.toUTF8};parse={showParse s};decode={showDecode s.toUTF8}"

/- Nested empty and singleton arrays. -/
#eval ["{\"k\":[]}", "{\"k\":[1]}"].map fun s =>
  s!"raw={s};scan={showScan s.toUTF8};parse={showParse s};decode={showDecode s.toUTF8}"

/- Malformed / invalid string escapes. Author report claimed a dedicated invalid-escape message. -/
#eval [
    "{\"a\":\"\\x\"}",
    "{\"a\":\"\\u00\"}",
    "{\"a\":\"\\u00zz\"}",
    "{\"a\":\"unterminated",
    "{\"a\":\"" ++ String.singleton (Char.ofNat 10) ++ "\"}",
    "{\"a\":\"\\u000a\"}"
  ].map fun s =>
    s!"raw={s};scan={showScan s.toUTF8};parse={showParse s};decode={showDecode s.toUTF8}"

/- Error precedence samples. Oversized document, empty, non-object, scientific, whitespace. -/
#eval Id.run do
  let over := ByteArray.mk (ByteArray.mk #[123]).data ++ ByteArray.mk (Array.replicate 1048576 97)
  let empty := "".toUTF8
  let spaces := "   ".toUTF8
  let arr := "[]".toUTF8
  let tru := "true".toUTF8
  let sci := "{\"a\":1e2}".toUTF8
  let ws := "{\"a\": 1}".toUTF8
  let badUtf := ByteArray.mk #[0x7b, 0xff, 0x7d]
  return [
    s!"oversize;size={over.size};scan={showScan over};decode={showDecode over}",
    s!"empty;scan={showScan empty};decode={showDecode empty}",
    s!"spaces;scan={showScan spaces};decode={showDecode spaces}",
    s!"topArr;scan={showScan arr};parse={showParse "[]"};decode={showDecode arr}",
    s!"true;scan={showScan tru};decode={showDecode tru}",
    s!"sci;scan={showScan sci};parse={showParse "{\"a\":1e2}"};decode={showDecode sci}",
    s!"ws;scan={showScan ws};parse={showParse "{\"a\": 1}"};decode={showDecode ws}",
    s!"badUtf;scan={showScan badUtf};decode={showDecode badUtf}"
  ]

end DefiKernel.Certificates
