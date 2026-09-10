import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
open DefiKernel.Certificates

def showFail : Except DecodeFailure α → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def showLex : Except DecodeFailure (String × List Char) → String
  | .ok (s, rest) => s!"ok len={s.length} rest={rest.length} chars={s.toList}"
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

def q : Char := '"'
def bs : Char := '\\'
def quoted : String := String.ofList ['a', q, 'b']
def bslash : String := String.ofList ['a', bs, 'b']
def needleU0000 : String := String.ofList [bs, 'u', '0', '0', '0', '0']
def needleU000a : String := String.ofList [bs, 'u', '0', '0', '0', 'a']
def needleShortN : String := String.ofList [bs, 'n']
def lf : String := String.singleton '\n'
def nul : String := String.singleton (Char.ofNat 0)
def us : String := String.singleton (Char.ofNat 31)

def c0Escape (n : Nat) : String :=
  String.ofList (escapeChar (Char.ofNat n))

def allC0Canonical : Bool :=
  (List.range 32).all fun n =>
    let s := c0Escape n
    s == String.ofList [bs, 'u', '0', '0', hexDigit (n / 16), hexDigit (n % 16)]

#eval IO.println "=== escapeChar ==="
#eval IO.println s!"allC0Canonical={allC0Canonical}"
#eval IO.println s!"quote={String.ofList (escapeChar q)}"
#eval IO.println s!"backslash={String.ofList (escapeChar bs)}"
#eval IO.println s!"slash={String.ofList (escapeChar '/')}"
#eval IO.println s!"A={String.ofList (escapeChar 'A')}"
#eval IO.println s!"eacute={String.ofList (escapeChar 'é')}"
#eval IO.println s!"grin={String.ofList (escapeChar '😀')}"

#eval IO.println "=== lexString helper ==="
#eval IO.println s!"plain={showLex (lexString [] ['a', 'b', q])}"
#eval IO.println s!"quote-esc={showLex (lexString [] [bs, q, q])}"
#eval IO.println s!"backslash-esc={showLex (lexString [] [bs, bs, q])}"
#eval IO.println s!"u0000={showLex (lexString [] [bs, 'u', '0', '0', '0', '0', q])}"
#eval IO.println s!"u000a={showLex (lexString [] [bs, 'u', '0', '0', '0', 'a', q])}"
#eval IO.println s!"u001f={showLex (lexString [] [bs, 'u', '0', '0', '1', 'f', q])}"
#eval IO.println s!"short-n={showLex (lexString [] [bs, 'n', q])}"
#eval IO.println s!"short-t={showLex (lexString [] [bs, 't', q])}"
#eval IO.println s!"short-slash={showLex (lexString [] [bs, '/', q])}"
#eval IO.println s!"upper-u000A={showLex (lexString [] [bs, 'u', '0', '0', '0', 'A', q])}"
#eval IO.println s!"u0041-A={showLex (lexString [] [bs, 'u', '0', '0', '4', '1', q])}"
#eval IO.println s!"unknown-q={showLex (lexString [] [bs, 'q', q])}"
#eval IO.println s!"truncated-u={showLex (lexString [] [bs, 'u', '0', '0', '1', q])}"
#eval IO.println s!"truncated-slash={showLex (lexString [] [bs])}"
#eval IO.println s!"literal-lf={showLex (lexString [] ['\n', q])}"
#eval IO.println s!"literal-nul={showLex (lexString [] [Char.ofNat 0, q])}"
#eval IO.println s!"bad-hex={showLex (lexString [] [bs, 'u', '0', '0', '0', 'g', q])}"
#eval IO.println s!"surrogate={showLex (lexString [] [bs, 'u', 'd', '8', '0', '0', q])}"
#eval IO.println s!"escapeChars-plain={showLex (lexString [] (escapeChars "ab".toList ++ [q]))}"
#eval IO.println s!"escapeChars-quote={showLex (lexString [] (escapeChars quoted.toList ++ [q]))}"
#eval IO.println s!"escapeChars-c0={showLex (lexString [] (escapeChars ((List.range 32).map Char.ofNat) ++ [q]))}"

#eval IO.println "=== production values ==="
#eval IO.println s!"plain-rt={roundtripIR (withChecker \"hello\")}"
#eval IO.println s!"lf-contains-u000a={hasSub (utf8Field (withChecker lf)) needleU000a}"
#eval IO.println s!"lf-contains-short-n={hasSub (utf8Field (withChecker lf)) needleShortN}"
#eval IO.println s!"nul-contains-u0000={hasSub (utf8Field (withChecker nul)) needleU0000}"
#eval IO.println s!"quote-rt={roundtripIR (withChecker quoted)}"
#eval IO.println s!"bs-rt={roundtripIR (withChecker bslash)}"
#eval IO.println s!"us-rt={roundtripIR (withChecker us)}"
#eval IO.println s!"nul-rt={roundtripIR (withChecker nul)}"
#eval IO.println s!"lf-rt={roundtripIR (withChecker lf)}"
#eval IO.println s!"eacute-rt={roundtripIR (withChecker \"é\")}"
#eval IO.println s!"grin-rt={roundtripIR (withChecker \"😀\")}"
#eval IO.println s!"lf-jsonparse={jsonParseOk (utf8Field (withChecker lf))}"
#eval IO.println s!"nul-jsonparse={jsonParseOk (utf8Field (withChecker nul))}"
#eval IO.println s!"quote-jsonparse={jsonParseOk (utf8Field (withChecker quoted))}"

#eval IO.println "=== source_map keys ==="
#eval IO.println s!"plain-key-rt={roundtripIR (withSourceMapKey \"plain\")}"
#eval IO.println s!"quoted-key-rt={roundtripIR (withSourceMapKey quoted)}"
#eval IO.println s!"quoted-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey quoted))}"
#eval IO.println s!"quoted-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey quoted)))}"
#eval IO.println s!"quoted-key-has-raw-quote={hasSub (utf8Field (withSourceMapKey quoted)) quoted}"
#eval IO.println s!"bs-key-rt={roundtripIR (withSourceMapKey bslash)}"
#eval IO.println s!"bs-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey bslash))}"
#eval IO.println s!"bs-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey bslash)))}"
#eval IO.println s!"lf-key-rt={roundtripIR (withSourceMapKey lf)}"
#eval IO.println s!"lf-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey lf))}"
#eval IO.println s!"lf-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey lf)))}"
#eval IO.println s!"nul-key-jsonparse={jsonParseOk (utf8Field (withSourceMapKey nul))}"
#eval IO.println s!"nul-key-decode={showFail (decodeBytes (encodeModule (withSourceMapKey nul)))}"
#eval IO.println s!"eacute-key-rt={roundtripIR (withSourceMapKey \"é\")}"
#eval IO.println s!"grin-key-rt={roundtripIR (withSourceMapKey \"😀\")}"
#eval IO.println s!"jsonObj-raw-quote={jsonObj [(quoted, \"1\")]}"
#eval IO.println "=== done ==="
