import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates

/-- Focused R10 runtime probe: constructor JSON shape, remaining 52/55 cap, resource remap. -/

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

def showCheck : Outcome → String
  | .codec (.blocked lim) => s!"blocked:{lim}"
  | .codec (.malformed e) => s!"malformed:{encodeDecodeFailure e}"
  | .codec (.ok _) => "codec-ok"
  | .execution _ => "execution"
  | .audit _ => "audit"

def litNum : ExprEnc :=
  .lit ⟨.numeric .scalar, 0, false⟩

def litNeg : ExprEnc :=
  .lit ⟨.numeric .scalar, (RatEnc.mk (-3) 2).toRat, false⟩

def bal : ExprEnc :=
  .balance ⟨.usd, ⟨.main, .literal .alice⟩⟩

def obs : ExprEnc :=
  .observe ⟨⟨.main, 0⟩, .bool⟩

def arg0 : ExprEnc :=
  .arg 0 .bool

def ts : ExprEnc :=
  .timestamp ⟨.main, 0⟩

def unaryNegNow : ExprEnc :=
  .unary (.neg .scalar) .now

def unaryNotNow : ExprEnc :=
  .unary .not .now

def binAnd : ExprEnc :=
  .binary .and .now .now

def binAdd : ExprEnc :=
  .binary (.add .scalar) .now .now

def reportExpr (label : String) (e : ExprEnc) : IO Unit := do
  IO.println label
  IO.println s!"  ast={exprDepth e} stack={exprMaxStackDepth e} stackLe52={(exprMaxStackDepth e).ble 52} depthLe55={(exprDepth e).ble 55} encodeNest={nestMax (encodeExpr e)}"

def arr4097 : String :=
  "{\"a\":[" ++ String.intercalate "," (List.replicate 4097 "0") ++ "]}"

#eval (do
  IO.println "witness-bytes"
  IO.println (toString (encodeModule canonicalWitnessIR).size)
  IO.println "witness-nest"
  IO.println (toString (nestMax (utf8! (encodeModule canonicalWitnessIR))))
  reportExpr "shape-now" .now
  reportExpr "shape-litBool" (.lit ⟨.bool, 0, true⟩)
  reportExpr "shape-litNum0" litNum
  reportExpr "shape-litNeg" litNeg
  reportExpr "shape-arg" arg0
  reportExpr "shape-ts" ts
  reportExpr "shape-bal" bal
  reportExpr "shape-obs" obs
  reportExpr "shape-unaryNotNow" unaryNotNow
  reportExpr "shape-unaryNegNow" unaryNegNow
  reportExpr "shape-binAnd" binAnd
  reportExpr "shape-binAdd" binAdd
  reportExpr "wrapNow51" (wrapNow 51)
  reportExpr "wrapNow52" (wrapNow 52)
  reportExpr "wrapNow55" (wrapNow 55)
  reportExpr "wrapNow57" (wrapNow 57)
  let g52 := withRegistry [⟨0, emptyTpl (wrapNow 51) []⟩]
  let g53 := withRegistry [⟨0, emptyTpl (wrapNow 52) []⟩]
  let g56 := withRegistry [⟨0, emptyTpl (wrapNow 55) []⟩]
  let g58 := withRegistry [⟨0, emptyTpl (wrapNow 57) []⟩]
  IO.println "guard52-nest"
  IO.println (toString (nestMax (utf8! (encodeModule g52))))
  IO.println "guard52-decode"
  IO.println (showEq g52 (decodeBytes (encodeModule g52)))
  IO.println "guard53-nest"
  IO.println (toString (nestMax (utf8! (encodeModule g53))))
  IO.println "guard53-decode"
  IO.println (showEq g53 (decodeBytes (encodeModule g53)))
  IO.println "guard56-nest"
  IO.println (toString (nestMax (utf8! (encodeModule g56))))
  IO.println "guard56-decode"
  IO.println (showEq g56 (decodeBytes (encodeModule g56)))
  IO.println "guard58-nest"
  IO.println (toString (nestMax (utf8! (encodeModule g58))))
  IO.println "guard58-decode"
  IO.println (showEq g58 (decodeBytes (encodeModule g58)))
  IO.println "arr4097-len"
  IO.println (toString arr4097.length)
  IO.println "arr4097-scan"
  IO.println (showScan (scanLexical arr4097.toUTF8))
  IO.println "arr4097-parse"
  IO.println (showParse (parseCanonicalJson arr4097))
  IO.println "arr4097-decode"
  IO.println (showDec (decodeBytes arr4097.toUTF8))
  IO.println "arr4097-check"
  IO.println (showCheck (checkBytes arr4097.toUTF8))
  IO.println "done"
  : IO Unit)
