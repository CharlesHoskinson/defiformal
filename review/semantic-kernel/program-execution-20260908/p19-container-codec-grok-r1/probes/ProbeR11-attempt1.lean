import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.Tests
open DefiKernel.Certificates

/-- Focused R11 runtime probe: jsonDepth scalar, guard AST58 vs ≤64, sourcePin keys,
    decodeBytes resourceLimit preservation, helper vs production serializers. -/

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

def emptyTpl (g : ExprEnc) : TemplateEnc :=
  { signature := []
    domain := .main
    partyArity := 0
    guard := g
    deltas := []
    supplyDeltas := []
    stateReads := []
    envReads := []
    writes := [] }

def withRegistry (entries : List RegistryEntryEnc) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env payload) =>
    .execution (.typed env { payload with registry := ⟨entries⟩ })
  | ir => ir

def utf8! (b : ByteArray) : String :=
  match String.fromUTF8? b with
  | some s => s
  | none => "NOTUTF8"

def showDec : Except DecodeFailure DecodedIR → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def showEq (want : DecodedIR) : Except DecodeFailure DecodedIR → String
  | .ok ir => if ir == want then "ok-eq" else "ok-neq"
  | .error e => encodeDecodeFailure e

def showScan : Except DecodeFailure Unit → String
  | .ok () => "ok"
  | .error e => encodeDecodeFailure e

def showParse : Except DecodeFailure Lean.Json → String
  | .ok _ => "ok"
  | .error e => encodeDecodeFailure e

def showParseDepth : Except DecodeFailure Lean.Json → String
  | .ok j => s!"ok depth={jsonDepth j} arr={jsonMaxArrayLength j}"
  | .error e => encodeDecodeFailure e

def showCheck : Outcome → String
  | .codec (.blocked lim) => s!"blocked:{lim}"
  | .codec (.malformed e) => s!"malformed:{encodeDecodeFailure e}"
  | .codec (.ok _) => "codec-ok"
  | .execution _ => "execution"
  | .audit _ => "audit"

def nestJson : Nat → Lean.Json
  | 0 => Lean.Json.num 1
  | n + 1 => Lean.Json.mkObj [("a", nestJson n)]

def pinNone : SourcePinEnc :=
  ⟨"g", "t", "m", "c", none, none⟩

def pinSome : SourcePinEnc :=
  ⟨"g", "t", "m", "c", some "cr", some "ar"⟩

def jsonKeys : Lean.Json → String
  | .obj kvs => String.intercalate "," (kvs.toArray.toList.map (fun p => p.1))
  | .str _ => "STR"
  | _ => "OTHER"

def showSrc : Except DecodeFailure SourcePinEnc → String
  | .ok sp =>
    let cr := match sp.compiler_record with | none => "none" | some s => s!"some:{s}"
    let ar := match sp.audit_record with | none => "none" | some s => s!"some:{s}"
    s!"ok cr={cr} ar={ar}"
  | .error e => encodeDecodeFailure e

def showLib : Except DecodeFailure LibraryRefEnc → String
  | .ok lr =>
    let m := match lr.moduleName with | none => "none" | some s => s!"some:{s}"
    s!"ok thm={lr.theoremName} mod={m}"
  | .error e => encodeDecodeFailure e

def makeArrDoc (n : Nat) : String :=
  let zeros := String.intercalate "," (List.replicate n "0")
  "{\"arr\":[" ++ zeros ++ "]}"

def makeNestedDoc (depth : Nat) : String :=
  let openBraces := String.intercalate "" (List.replicate depth "{\"a\":")
  let closeBraces := String.intercalate "" (List.replicate depth "}")
  openBraces ++ "1" ++ closeBraces

def reportBoundary (label : String) (s : String) : IO Unit := do
  IO.println label
  IO.println s!"  scan={showScan (scanLexical s.toUTF8)}"
  IO.println s!"  parse={showParse (parseCanonicalJson s)}"
  IO.println s!"  parseDepth={showParseDepth (parseCanonicalJson s)}"
  IO.println s!"  decode={showDec (decodeBytes s.toUTF8)}"
  IO.println s!"  check={showCheck (checkBytes s.toUTF8)}"

#eval (do
  IO.println "jsonDepth-str"
  IO.println (toString (jsonDepth (Lean.Json.str "x")))
  IO.println "jsonDepth-num"
  IO.println (toString (jsonDepth (Lean.Json.num 1)))
  IO.println "jsonDepth-null"
  IO.println (toString (jsonDepth Lean.Json.null))
  IO.println "jsonDepth-bool"
  IO.println (toString (jsonDepth (Lean.Json.bool true)))
  IO.println "jsonDepth-empty-obj"
  IO.println (toString (jsonDepth (Lean.Json.mkObj [])))
  IO.println "jsonDepth-empty-arr"
  IO.println (toString (jsonDepth (Lean.Json.arr #[])))
  IO.println "jsonDepth-nestJson0"
  IO.println (toString (jsonDepth (nestJson 0)))
  IO.println "jsonDepth-nestJson1"
  IO.println (toString (jsonDepth (nestJson 1)))
  IO.println "jsonDepth-nestJson63"
  IO.println (toString (jsonDepth (nestJson 63)))
  IO.println "jsonDepth-nestJson64"
  IO.println (toString (jsonDepth (nestJson 64)))
  IO.println "jsonDepth-nestJson65"
  IO.println (toString (jsonDepth (nestJson 65)))
  IO.println "jsonDepth-le64-nestJson63"
  IO.println (toString ((jsonDepth (nestJson 63)).ble 64))
  IO.println "jsonDepth-le64-nestJson64"
  IO.println (toString ((jsonDepth (nestJson 64)).ble 64))
  IO.println "fuel-jsonDepth"
  IO.println "100"
  IO.println "fuel-jsonMaxArrayLength"
  IO.println "100"
  let g58 := withRegistry [⟨0, emptyTpl (wrapNow 57)⟩]
  IO.println "guard58-ast"
  IO.println (toString (ExprEnc.depth (wrapNow 57)))
  IO.println "guard58-encode-nest"
  IO.println (toString (nestMax (utf8! (encodeModule g58))))
  IO.println "guard58-decode"
  IO.println (showEq g58 (decodeBytes (encodeModule g58)))
  IO.println "guard58-helper-jsonDepth"
  IO.println (toString (jsonDepth (decodedIRToJson g58)))
  IO.println "guard58-helper-le64"
  IO.println (toString ((jsonDepth (decodedIRToJson g58)).ble 64))
  IO.println "guard58-prod-parseDepth"
  IO.println (showParseDepth (parseCanonicalJson (utf8! (encodeModule g58))))
  IO.println "witness-helper-jsonDepth"
  IO.println (toString (jsonDepth (decodedIRToJson canonicalWitnessIR)))
  IO.println "witness-encode-nest"
  IO.println (toString (nestMax (utf8! (encodeModule canonicalWitnessIR))))
  IO.println "sourcePin-helper-keys-none"
  IO.println (jsonKeys (sourcePinToJson pinNone))
  IO.println "sourcePin-helper-keys-some"
  IO.println (jsonKeys (sourcePinToJson pinSome))
  IO.println "sourcePin-prod-none"
  IO.println (encodeSourcePin pinNone)
  IO.println "sourcePin-prod-some"
  IO.println (encodeSourcePin pinSome)
  IO.println "sourcePin-decode-helper-none"
  IO.println (showSrc (decodeSourcePin (sourcePinToJson pinNone)))
  IO.println "sourcePin-decode-helper-some"
  IO.println (showSrc (decodeSourcePin (sourcePinToJson pinSome)))
  let libNone : LibraryRefEnc := ⟨"T", none⟩
  let libSome : LibraryRefEnc := ⟨"T", some "M"⟩
  IO.println "libraryRef-helper-none"
  IO.println (jsonKeys (libraryRefToJson libNone))
  IO.println "libraryRef-prod-none"
  IO.println (encodeLibraryRef libNone)
  IO.println "libraryRef-helper-some"
  IO.println (jsonKeys (libraryRefToJson libSome))
  IO.println "libraryRef-prod-some"
  IO.println (encodeLibraryRef libSome)
  IO.println "libraryRef-decode-helper-none"
  IO.println (showLib (decodeLibraryRef (libraryRefToJson libNone)))
  reportBoundary "arr4095" (makeArrDoc 4095)
  reportBoundary "arr4096" (makeArrDoc 4096)
  reportBoundary "arr4097" (makeArrDoc 4097)
  reportBoundary "nest63" (makeNestedDoc 63)
  reportBoundary "nest64" (makeNestedDoc 64)
  reportBoundary "nest65" (makeNestedDoc 65)
  IO.println "tests-array-reg"
  IO.println (toString checkArrayLengthBoundaryRegression)
  IO.println "tests-depth-reg"
  IO.println (toString checkDepthBoundaryRegression)
  IO.println "done"
  : IO Unit)
