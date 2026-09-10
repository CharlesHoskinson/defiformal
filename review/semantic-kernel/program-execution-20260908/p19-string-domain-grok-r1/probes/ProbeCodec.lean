import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
open DefiKernel.Certificates

/-- Helpers that only pretty-print existing production functions. -/
def showFail : Except DecodeFailure α → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def showLex : Except DecodeFailure (String × List Char) → String
  | .ok (s, rest) => s!"ok:{s}:{rest.length}"
  | .error e => encodeDecodeFailure e

def withChecker (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker_candidate := value } } payload)
  | ir => ir

def withSourceMapKey (key : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := [(key, "pin")] } payload)
  | ir => ir

def utf8Field (ir : DecodedIR) : String :=
  String.fromUTF8! (encodeModule ir)

def jsonParseOk (s : String) : Bool :=
  match Lean.Json.parse s with
  | .ok _ => true
  | .error _ => false

def hasSub (s needle : String) : Bool :=
  (s.splitOn needle).length > 1

def roundtripIR (ir : DecodedIR) : String :=
  match decodeBytes (encodeModule ir) with
  | .ok ir2 => if ir2 == ir then "ok-eq" else "ok-neq"
  | .error e => encodeDecodeFailure e

def c0Escape (n : Nat) : String :=
  String.ofList (escapeChar (Char.ofNat n))

def allC0Canonical : Bool :=
  (List.range 32).all fun n =>
    let s := c0Escape n
    let hi := hexDigit (n / 16)
    let lo := hexDigit (n % 16)
    s == String.ofList ['\\', 'u', '0', '0', hi, lo]

#eval IO.println "=== escapeChar C0 ==="
#eval IO.println s!"allC0Canonical={allC0Canonical}"
#eval IO.println s!"nul={c0Escape 0}"
#eval IO.println s!"tab={c0Escape 9}"
#eval IO.println s!"lf={c0Escape 10}"
#eval IO.println s!"cr={c0Escape 13}"
#eval IO.println s!"us={c0Escape 31}"
#eval IO.println s!"space={String.ofList (escapeChar ' ')}"
#eval IO.println s!"quote={String.ofList (escapeChar '\"')}"
#eval IO.println s!"backslash={String.ofList (escapeChar '\\\\')}"
#eval IO.println s!"slash={String.ofList (escapeChar '/')}"
#eval IO.println s!"A={String.ofList (escapeChar 'A')}"
#eval IO.println s!"e-acute={String.ofList (escapeChar 'é')}"
#eval IO.println s!"grin={String.ofList (escapeChar '😀')}"

#eval IO.println "=== lexString helper ==="
#eval IO.println s!"plain={showLex (lexString [] ['a', 'b', '\"'])}"
#eval IO.println s!"quote-esc={showLex (lexString [] ['\\\\', '\"', '\"'])}"
#eval IO.println s!"backslash-esc={showLex (lexString [] ['\\\\', '\\\\', '\"'])}"
#eval IO.println s!"u0000={showLex (lexString [] ['\\\\', 'u', '0', '0', '0', '0', '\"'])}"
#eval IO.println s!"u000a={showLex (lexString [] ['\\\\', 'u', '0', '0', '0', 'a', '\"'])}"
#eval IO.println s!"u001f={showLex (lexString [] ['\\\\', 'u', '0', '0', '1', 'f', '\"'])}"
#eval IO.println s!"short-n={showLex (lexString [] ['\\\\', 'n', '\"'])}"
#eval IO.println s!"short-t={showLex (lexString [] ['\\\\', 't', '\"'])}"
#eval IO.println s!"short-slash={showLex (lexString [] ['\\\\', '/', '\"'])}"
#eval IO.println s!"upper-u000A={showLex (lexString [] ['\\\\', 'u', '0', '0', '0', 'A', '\"'])}"
#eval IO.println s!"u0041-A={showLex (lexString [] ['\\\\', 'u', '0', '0', '4', '1', '\"'])}"
#eval IO.println s!"unknown-q={showLex (lexString [] ['\\\\', 'q', '\"'])}"
#eval IO.println s!"truncated-u={showLex (lexString [] ['\\\\', 'u', '0', '0', '1', '\"'])}"
#eval IO.println s!"truncated-slash={showLex (lexString [] ['\\\\'])}"
#eval IO.println s!"literal-lf={showLex (lexString [] ['\\n', '\"'])}"
#eval IO.println s!"literal-nul={showLex (lexString [] [Char.ofNat 0, '\"'])}"
#eval IO.println s!"bad-hex={showLex (lexString [] ['\\\\', 'u', '0', '0', '0', 'g', '\"'])}"
#eval IO.println s!"surrogate={showLex (lexString [] ['\\\\', 'u', 'd', '8', '0', '0', '\"'])}"

#eval IO.println "=== production checker_candidate encode/decode ==="
#eval IO.println s!"plain-rt={roundtripIR (withChecker \"hello\")}"
#eval IO.println s!"lf-field={utf8Field (withChecker \"\\n\")}"
#eval IO.println s!"nul-contains-u0000={hasSub (utf8Field (withChecker (String.singleton (Char.ofNat 0)))) \"\\\\u0000\"}"
#eval IO.println s!"lf-contains-u000a={hasSub (utf8Field (withChecker \"\\n\")) \"\\\\u000a\"}"
#eval IO.println s!"lf-contains-short-n={hasSub (utf8Field (withChecker \"\\n\")) \"\\\\n\"}"
#eval IO.println s!"quote-field={utf8Field (withChecker \"a\\\"b\")}"
#eval IO.println s!"bs-field={utf8Field (withChecker \"a\\\\b\")}"
#eval IO.println s!"us-rt={roundtripIR (withChecker (String.singleton (Char.ofNat 31)))}"
#eval IO.println s!"nul-rt={roundtripIR (withChecker (String.singleton (Char.ofNat 0)))}"
#eval IO.println s!"quote-rt={roundtripIR (withChecker \"a\\\"b\")}"
#eval IO.println s!"bs-rt={roundtripIR (withChecker \"a\\\\b\")}"
#eval IO.println s!"eacute-rt={roundtripIR (withChecker \"é\")}"
#eval IO.println s!"grin-rt={roundtripIR (withChecker \"😀\")}"
#eval IO.println s!"lf-jsonparse={jsonParseOk (utf8Field (withChecker \"\\n\"))}"
#eval IO.println s!"nul-jsonparse={jsonParseOk (utf8Field (withChecker (String.singleton (Char.ofNat 0))))}"

#eval IO.println "=== source_map keys ==="
#eval IO.println s!"plain-key-rt={roundtripIR (withSourceMapKey \"plain\")}"
#eval IO.println s!"quoted-key-rt={roundtripIR (withSourceMapKey \"a\\\"b\")}"
#eval IO.println s!"quoted-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey \"a\\\"b\"))}"
#eval IO.println s!"quoted-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey \"a\\\"b\")))}"
#eval IO.println s!"quoted-key-bytes={utf8Field (withSourceMapKey \"a\\\"b\")}"
#eval IO.println s!"bs-key-rt={roundtripIR (withSourceMapKey \"a\\\\b\")}"
#eval IO.println s!"bs-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey \"a\\\\b\"))}"
#eval IO.println s!"lf-key-rt={roundtripIR (withSourceMapKey \"\\n\")}"
#eval IO.println s!"lf-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey \"\\n\"))}"
#eval IO.println s!"nul-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey (String.singleton (Char.ofNat 0))))}"
#eval IO.println s!"nul-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey (String.singleton (Char.ofNat 0)))))}"
#eval IO.println s!"eacute-key-rt={roundtripIR (withSourceMapKey \"é\")}"
#eval IO.println s!"grin-key-rt={roundtripIR (withSourceMapKey \"😀\")}"
#eval IO.println s!"jsonObj-raw-quote={jsonObj [(\"a\\\"b\", \"1\")]}"
#eval IO.println "=== done ==="
