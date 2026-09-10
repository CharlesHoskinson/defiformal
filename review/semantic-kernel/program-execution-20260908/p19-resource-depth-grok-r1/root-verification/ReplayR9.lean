import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
open DefiKernel.Certificates

/-- Focused R9 runtime probe. Labels are plain IO strings. -/

def q : Char := '"'
def bs : Char := '\\'
def quoted : String := String.ofList ['a', q, 'b']
def bslashS : String := String.ofList ['a', bs, 'b']
def nulS : String := String.singleton (Char.ofNat 0)
def lfS : String := String.singleton (Char.ofNat 10)
def tabS : String := String.singleton (Char.ofNat 9)
def lambdaS : String := String.singleton (Char.ofNat 0x03BB)
def rocketS : String := String.singleton (Char.ofNat 0x1F680)

def withKey (key : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := [(key, "pin")] } payload)
  | ir => ir

def withKeys (sm : List (String × String)) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_map := sm } payload)
  | ir => ir

def withChecker (value : String) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed { env with source_pin :=
      { env.source_pin with checker_candidate := value } } payload)
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

def nestMax (s : String) : Nat :=
  Id.run do
    let mut cur : Nat := 0
    let mut mx : Nat := 0
    let mut inS : Bool := false
    let mut esc : Bool := false
    for c in s.toList do
      if inS then
        if esc then
          esc := false
        else if c == '\\' then
          esc := true
        else if c == '"' then
          inS := false
      else if c == '"' then
        inS := true
      else if c == '{' || c == '[' then
        cur := cur + 1
        if cur > mx then mx := cur
      else if c == '}' || c == ']' then
        if cur > 0 then cur := cur - 1
    return mx

def wrapNow : Nat → ExprEnc
  | 0 => .now
  | n + 1 => .unary .not (wrapNow n)

def emptyTpl (g : ExprEnc) (ds : List CellDeltaEnc) : TemplateEnc :=
  { signature := []
    domain := .main
    partyArity := 0
    guard := g
    deltas := ds
    supplyDeltas := []
    stateReads := []
    envReads := []
    writes := [] }

def usdDelta (amount : ExprEnc) : CellDeltaEnc :=
  ⟨.usd, ⟨.main, .caller⟩, amount⟩

def withRegistry (entries : List RegistryEntryEnc) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed env { payload with registry := ⟨entries⟩ })
  | ir => ir

def stepEnv : EnvelopeEnc :=
  match canonicalWitnessIR with
  | .execution (.typed env _) => { env with mode := "composition-step" }
  | _ =>
    { schema_version := 1
      mode := "composition-step"
      source_pin :=
        { git := "a12b7cac05a818cc8d35c2ca440b7170a2807e92"
          lean_toolchain := "leanprover/lean4:v4.33.0-rc2"
          mathlib_rev := "51e6992efd06126df61a496bebf8f49482a4e129"
          checker_candidate := "" }
      audit_roots := ["DefiKernel.Certificates"]
      types :=
        { parties := [.alice, .bob, .vault, .pool]
          assets := [.usd, .share, .collateral, .debt]
          domains := [.main, .other] }
      assumptions := ["environment-authenticity"] }

def oneCell : CellEnc := ⟨.main, .alice, .usd⟩

def bigPrivate : ComponentEnc :=
  { id := 0
    privateCells := List.replicate 4097 oneCell
    exports := []
    imports := []
    operations := [] }

def bigOps : ComponentEnc :=
  { id := 0
    privateCells := []
    exports := []
    imports := []
    operations := [{ operation := 0, inputs := List.replicate 4097 ⟨0, .bool⟩, outputs := [] }] }

def stepIR (catalog : List ComponentEnc) : DecodedIR :=
  .execution (.step stepEnv
    { config := { registry := ⟨[]⟩, domainAdmin := [], catalog := catalog }
      boundary := ⟨⟨.alice, .main⟩, ⟨[]⟩, 100⟩
      index := 0
      history := []
      step := .revoke 0
      pre := ⟨⟨standard32Cells⟩, ⟨[]⟩⟩ })

def caps4097 : List CapabilityEnc :=
  (List.range 4097).map fun n =>
    ⟨.alice, .main, n, .invoke, true⟩

def claimedCapsIR : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed
      { env with claimed_next_state := some ⟨⟨standard32Cells⟩, ⟨caps4097⟩⟩ }
      payload)
  | ir => ir

def showScan : Except DecodeFailure Unit → String
  | .ok () => "ok"
  | .error e => encodeDecodeFailure e

def showParse : Except DecodeFailure Lean.Json → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def utf8! (b : ByteArray) : String :=
  match String.fromUTF8? b with
  | some s => s
  | none => "NOTUTF8"

#eval IO.println "jsonObj-quoted-key"
#eval IO.println (jsonObj [(quoted, "1")])
#eval IO.println "quoted-key-jsonparse"
#eval IO.println (toString (parseOk (utf8! (encodeModule (withKey quoted)))))
#eval IO.println "quoted-key-decode"
#eval IO.println (showEq (withKey quoted) (decodeBytes (encodeModule (withKey quoted))))
#eval IO.println "plain-key-decode"
#eval IO.println (showEq (withKey "plain") (decodeBytes (encodeModule (withKey "plain"))))
#eval IO.println "bs-key-jsonparse"
#eval IO.println (toString (parseOk (utf8! (encodeModule (withKey bslashS)))))
#eval IO.println "bs-key-decode"
#eval IO.println (showEq (withKey bslashS) (decodeBytes (encodeModule (withKey bslashS))))
#eval IO.println "nul-key-decode"
#eval IO.println (showEq (withKey nulS) (decodeBytes (encodeModule (withKey nulS))))
#eval IO.println "lf-key-decode"
#eval IO.println (showEq (withKey lfS) (decodeBytes (encodeModule (withKey lfS))))
#eval IO.println "tab-key-decode"
#eval IO.println (showEq (withKey tabS) (decodeBytes (encodeModule (withKey tabS))))
#eval IO.println "lambda-key-decode"
#eval IO.println (showEq (withKey lambdaS) (decodeBytes (encodeModule (withKey lambdaS))))
#eval IO.println "rocket-key-decode"
#eval IO.println (showEq (withKey rocketS) (decodeBytes (encodeModule (withKey rocketS))))
#eval IO.println "nul-value-decode"
#eval IO.println (showEq (withChecker nulS) (decodeBytes (encodeModule (withChecker nulS))))
#eval IO.println "lf-value-decode"
#eval IO.println (showEq (withChecker lfS) (decodeBytes (encodeModule (withChecker lfS))))
#eval IO.println "quote-value-decode"
#eval IO.println (showEq (withChecker quoted) (decodeBytes (encodeModule (withChecker quoted))))
#eval IO.println "bs-value-decode"
#eval IO.println (showEq (withChecker bslashS) (decodeBytes (encodeModule (withChecker bslashS))))
#eval IO.println "lambda-value-decode"
#eval IO.println (showEq (withChecker lambdaS) (decodeBytes (encodeModule (withChecker lambdaS))))
#eval IO.println "rocket-value-decode"
#eval IO.println (showEq (withChecker rocketS) (decodeBytes (encodeModule (withChecker rocketS))))
#eval IO.println "unsorted-keys-decode"
#eval IO.println (showEq (withKeys [("b", "2"), ("a", "1")]) (decodeBytes (encodeModule (withKeys [("b", "2"), ("a", "1")]))))
def afterSourceMap : String :=
  ((utf8! (encodeModule (withKeys [("b", "2"), ("a", "1")]))).splitOn "source_map").getD 1 "missing"

#eval IO.println "unsorted-encoded-source-map-prefix"
#eval IO.println (afterSourceMap.take 40)
#eval IO.println "dup-keys-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withKeys [("a", "1"), ("a", "2")]))))
#eval IO.println "space-after-colon-decode"
#eval IO.println (showDec (decodeBytes ((utf8! (encodeModule canonicalWitnessIR)).replace "\"mode\":" "\"mode\": ").toUTF8))
#eval IO.println "witness-bytes"
#eval IO.println (toString (encodeModule canonicalWitnessIR).size)
#eval IO.println "witness-nest"
#eval IO.println (toString (nestMax (utf8! (encodeModule canonicalWitnessIR))))
#eval IO.println "guard56-depth"
#eval IO.println (toString (exprDepth (wrapNow 55)))
#eval IO.println "guard56-le55"
#eval IO.println (toString ((exprDepth (wrapNow 55)).ble 55))
#eval IO.println "guard56-bytes"
#eval IO.println (toString (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 55) []⟩])).size)
#eval IO.println "guard56-nest"
#eval IO.println (toString (nestMax (utf8! (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 55) []⟩])))))
#eval IO.println "guard56-decode"
#eval IO.println (showEq (withRegistry [⟨0, emptyTpl (wrapNow 55) []⟩]) (decodeBytes (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 55) []⟩]))))
#eval IO.println "guard58-depth"
#eval IO.println (toString (exprDepth (wrapNow 57)))
#eval IO.println "guard58-le55"
#eval IO.println (toString ((exprDepth (wrapNow 57)).ble 55))
#eval IO.println "guard58-nest"
#eval IO.println (toString (nestMax (utf8! (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 57) []⟩])))))
#eval IO.println "guard58-decode"
#eval IO.println (showEq (withRegistry [⟨0, emptyTpl (wrapNow 57) []⟩]) (decodeBytes (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 57) []⟩]))))
#eval IO.println "guard59-depth"
#eval IO.println (toString (exprDepth (wrapNow 58)))
#eval IO.println "guard59-nest"
#eval IO.println (toString (nestMax (utf8! (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 58) []⟩])))))
#eval IO.println "guard59-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withRegistry [⟨0, emptyTpl (wrapNow 58) []⟩]))))
#eval IO.println "delta64-guard-depth"
#eval IO.println (toString (exprDepth (emptyTpl .now [usdDelta (wrapNow 63)]).guard))
#eval IO.println "delta64-amount-depth"
#eval IO.println (toString (exprDepth (wrapNow 63)))
#eval IO.println "delta64-guard-le55"
#eval IO.println (toString ((exprDepth (emptyTpl .now [usdDelta (wrapNow 63)]).guard).ble 55))
#eval IO.println "delta64-amount-le55"
#eval IO.println (toString ((exprDepth (wrapNow 63)).ble 55))
#eval IO.println "delta64-bytes"
#eval IO.println (toString (encodeModule (withRegistry [⟨0, emptyTpl .now [usdDelta (wrapNow 63)]⟩])).size)
#eval IO.println "delta64-nest"
#eval IO.println (toString (nestMax (utf8! (encodeModule (withRegistry [⟨0, emptyTpl .now [usdDelta (wrapNow 63)]⟩])))))
#eval IO.println "delta64-scan"
#eval IO.println (showScan (scanLexical (encodeModule (withRegistry [⟨0, emptyTpl .now [usdDelta (wrapNow 63)]⟩]))))
#eval IO.println "delta64-parse"
#eval IO.println (showParse (parseCanonicalJson (utf8! (encodeModule (withRegistry [⟨0, emptyTpl .now [usdDelta (wrapNow 63)]⟩])))))
#eval IO.println "delta64-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (withRegistry [⟨0, emptyTpl .now [usdDelta (wrapNow 63)]⟩]))))
#eval IO.println "priv4097-len"
#eval IO.println (toString bigPrivate.privateCells.length)
#eval IO.println "priv4097-catalog-len"
#eval IO.println (toString (match stepIR [bigPrivate] with
  | .execution (.step _ p) => p.config.catalog.length
  | _ => 0))
#eval IO.println "priv4097-bytes"
#eval IO.println (toString (encodeModule (stepIR [bigPrivate])).size)
#eval IO.println "priv4097-scan"
#eval IO.println (showScan (scanLexical (encodeModule (stepIR [bigPrivate]))))
#eval IO.println "priv4097-parse"
#eval IO.println (showParse (parseCanonicalJson (utf8! (encodeModule (stepIR [bigPrivate])))))
#eval IO.println "priv4097-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (stepIR [bigPrivate]))))
#eval IO.println "ops4097-inputs-len"
#eval IO.println (toString (bigOps.operations.head!.inputs.length))
#eval IO.println "ops4097-bytes"
#eval IO.println (toString (encodeModule (stepIR [bigOps])).size)
#eval IO.println "ops4097-scan"
#eval IO.println (showScan (scanLexical (encodeModule (stepIR [bigOps]))))
#eval IO.println "ops4097-parse"
#eval IO.println (showParse (parseCanonicalJson (utf8! (encodeModule (stepIR [bigOps])))))
#eval IO.println "ops4097-decode"
#eval IO.println (showDec (decodeBytes (encodeModule (stepIR [bigOps]))))
#eval IO.println "claimed4097-len"
#eval IO.println (toString caps4097.length)
#eval IO.println "claimed4097-bytes"
#eval IO.println (toString (encodeModule claimedCapsIR).size)
#eval IO.println "claimed4097-scan"
#eval IO.println (showScan (scanLexical (encodeModule claimedCapsIR)))
#eval IO.println "claimed4097-parse"
#eval IO.println (showParse (parseCanonicalJson (utf8! (encodeModule claimedCapsIR))))
#eval IO.println "claimed4097-decode"
#eval IO.println (showDec (decodeBytes (encodeModule claimedCapsIR)))
#eval IO.println "done"
