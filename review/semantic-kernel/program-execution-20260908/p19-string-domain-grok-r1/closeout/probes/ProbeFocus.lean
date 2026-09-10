import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
open DefiKernel.Certificates

/-- Focused exit-0 runtime probe. Labels are plain IO strings; no interpolations. -/

def q : Char := '"'
def bs : Char := '\\'
def quoted : String := String.ofList ['a', q, 'b']
def bslashS : String := String.ofList ['a', bs, 'b']
def nulS : String := String.singleton (Char.ofNat 0)
def lfS : String := String.singleton (Char.ofNat 10)
def xs4097 : String := String.ofList (List.replicate 4097 'x')

def withKey (key : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := [(key, "pin")] } payload)
  | ir => ir

def withChecker (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker_candidate := value } } payload)
  | ir => ir

def withOneLib : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with libraries := [⟨xs4097, none⟩] } payload)
  | ir => ir

def withCompiler : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with compiler_record := some xs4097 } } payload)
  | ir => ir

def showDec : Except DecodeFailure DecodedIR → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def showEq (want : DecodedIR) : Except DecodeFailure DecodedIR → String
  | .ok ir => if ir == want then "ok-eq" else "ok-neq"
  | .error e => encodeDecodeFailure e

def parseOk (s : String) : Bool :=
  match Lean.Json.parse s with
  | .ok _ => true
  | .error _ => false

def showLex : Except DecodeFailure (String × List Char) → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def c0Canonical : Bool :=
  (List.range 32).all fun n =>
    String.ofList (escapeChar (Char.ofNat n)) ==
      String.ofList [bs, 'u', '0', '0', hexDigit (n / 16), hexDigit (n % 16)]

#eval IO.println "c0-canonical"
#eval IO.println (toString c0Canonical)
#eval IO.println "lex-unknown-q"
#eval IO.println (showLex (lexString [] [bs, 'q', q]))
#eval IO.println "lex-truncated-u"
#eval IO.println (showLex (lexString [] [bs, 'u', '0', '0', '1']))
#eval IO.println "lex-literal-lf"
#eval IO.println (showLex (lexString [] [Char.ofNat 10, q]))
#eval IO.println "lex-literal-nul"
#eval IO.println (showLex (lexString [] [Char.ofNat 0, q]))
#eval IO.println "lex-short-n"
#eval IO.println (showLex (lexString [] [bs, 'n', q]))
#eval IO.println "lex-upper-u000A"
#eval IO.println (showLex (lexString [] [bs, 'u', '0', '0', '0', 'A', q]))
#eval IO.println "jsonObj-quoted-key"
#eval IO.println (jsonObj [(quoted, "1")])
#eval IO.println "quoted-key-jsonparse"
#eval IO.println (toString (parseOk (String.fromUTF8! (encodeModule (withKey quoted)))))
#eval IO.println "quoted-key-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withKey quoted))))
#eval IO.println "plain-key-decode"
#eval IO.println (showEq (withKey "plain") (decodeBytes (encodeModule (withKey "plain"))))
#eval IO.println "nul-key-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withKey nulS))))
#eval IO.println "lf-key-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withKey lfS))))
#eval IO.println "bs-key-jsonparse"
#eval IO.println (toString (parseOk (String.fromUTF8! (encodeModule (withKey bslashS)))))
#eval IO.println "bs-key-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withKey bslashS))))
#eval IO.println "nul-value-decode"
#eval IO.println (showEq (withChecker nulS) (decodeBytes (encodeModule (withChecker nulS))))
#eval IO.println "lf-value-decode"
#eval IO.println (showEq (withChecker lfS) (decodeBytes (encodeModule (withChecker lfS))))
#eval IO.println "quote-value-decode"
#eval IO.println (showEq (withChecker quoted) (decodeBytes (encodeModule (withChecker quoted))))
#eval IO.println "bs-value-decode"
#eval IO.println (showEq (withChecker bslashS) (decodeBytes (encodeModule (withChecker bslashS))))
#eval IO.println "checker4097-length"
#eval IO.println (toString xs4097.length)
#eval IO.println "checker4097-bytes"
#eval IO.println (toString (encodeModule (withChecker xs4097)).size)
#eval IO.println "checker4097-over-maxBytes"
#eval IO.println (toString ((encodeModule (withChecker xs4097)).size > 1048576))
#eval IO.println "checker4097-decode"
#eval IO.println (showEq (withChecker xs4097) (decodeBytes (encodeModule (withChecker xs4097))))
#eval IO.println "witness-cost"
#eval IO.println (toString (irStructuralByteCost canonicalWitnessIR))
#eval IO.println "onelib-cost-eq-witness"
#eval IO.println (toString (irStructuralByteCost withOneLib == irStructuralByteCost canonicalWitnessIR))
#eval IO.println "onelib-bytes"
#eval IO.println (toString (encodeModule withOneLib).size)
#eval IO.println "compiler-cost-eq-witness"
#eval IO.println (toString (irStructuralByteCost withCompiler == irStructuralByteCost canonicalWitnessIR))
#eval IO.println "compiler-bytes"
#eval IO.println (toString (encodeModule withCompiler).size)
#eval IO.println "done"
