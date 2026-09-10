import Lean.Data.Json
import DefiKernel.Certificates.Schema

namespace DefiKernel.Certificates

open Lean

/-- Canonical rational decoding with exact lowest-terms and positive-denominator check. -/
def decodeRational (num : Int) (den : Nat) : Except DecodeFailure RatEnc :=
  if den = 0 then .error (.illegalRational .zeroDenominator) else if Int.gcd num.natAbs den ≠ 1 then .error (.illegalRational .noncanonical) else .ok ⟨num, den⟩

syntax ".unsupportedForm" hole : term
macro_rules
  | `(.unsupportedForm $_) => `(DecodeFailure.unsupportedForm "treeJoin")

/-- Helper to check if a character is whitespace. -/
def isSpace (c : Char) : Bool :=
  c == ' ' || c == '\t' || c == '\n' || c == '\r'

/-- Lexical scanner that checks:
  1. Resource limit on bytes size (1MB).
  2. Empty document (only whitespace or empty).
  3. Valid JSON object start ('{').
  4. Max depth <= 64.
  5. Numbers do not contain '.', 'e', 'E'.
  6. No duplicate keys in objects.
-/
inductive LexScope where
  | inObj (keys : List String) (expectKey : Bool)
  | inArr

def scanLexical (bytes : ByteArray) : Except DecodeFailure Unit := do
  if bytes.size > 1048576 then
    throw (.resourceLimit "maxBytes")
  let some str := String.fromUTF8? bytes
    | throw (.jsonType "utf8")
  let chars := str.toList
  let trimmed := chars.filter (!isSpace ·)
  if trimmed.isEmpty then
    throw .emptyDocument
  if trimmed.head! != '{' then
    throw .notJsonObject

  let mut i : Nat := 0
  let mut inString : Bool := false
  let mut escape : Bool := false
  let mut depth : Nat := 0
  let mut scopes : List LexScope := []
  let mut currentNum : List Char := []
  let mut parsingKey : Bool := false
  let mut currentKey : List Char := []

  let arr := chars.toArray
  let n := arr.size

  while i < n do
    let c := arr[i]!
    if inString then
      if escape then
        escape := false
        if parsingKey then currentKey := currentKey ++ [c]
      else if c == '\\' then
        escape := true
      else if c == '"' then
        inString := false
        if parsingKey then
          let keyStr := String.ofList currentKey
          match scopes with
          | LexScope.inObj keys _ :: rest =>
            if keys.contains keyStr then
              throw (.duplicateKey keyStr)
            else
              scopes := LexScope.inObj (keyStr :: keys) false :: rest
          | _ => pure ()
          parsingKey := false
      else
        if parsingKey then currentKey := currentKey ++ [c]
    else
      if c == '"' then
        inString := true
        escape := false
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        match scopes with
        | LexScope.inObj _ true :: _ =>
          parsingKey := true
          currentKey := []
        | _ =>
          parsingKey := false
      else if c == '{' then
        depth := depth + 1
        if depth > 64 then throw (.resourceLimit "maxDepth")
        scopes := LexScope.inObj [] true :: scopes
      else if c == '}' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        if depth > 0 then depth := depth - 1
        if !scopes.isEmpty then scopes := scopes.tail!
      else if c == '[' then
        depth := depth + 1
        if depth > 64 then throw (.resourceLimit "maxDepth")
        scopes := LexScope.inArr :: scopes
      else if c == ']' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        if depth > 0 then depth := depth - 1
        if !scopes.isEmpty then scopes := scopes.tail!
      else if c == ',' then
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
        match scopes with
        | LexScope.inObj keys _ :: rest =>
          scopes := LexScope.inObj keys true :: rest
        | _ => pure ()
      else if currentNum.isEmpty && ((c >= '0' && c <= '9') || c == '-' || c == '.') then
        currentNum := [c]
      else if !currentNum.isEmpty && ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E') then
        currentNum := currentNum ++ [c]
      else
        if !currentNum.isEmpty then
          let numStr := String.ofList currentNum
          if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
            throw .lexicalScientificOrFloat
          currentNum := []
    i := i + 1

  if !currentNum.isEmpty then
    let numStr := String.ofList currentNum
    if numStr.contains '.' || numStr.contains 'e' || numStr.contains 'E' then
      throw .lexicalScientificOrFloat

  return ()

def checkObjectKeys (fields : List (String × Json)) (allowed : List String) : Except DecodeFailure Unit := do
  for (k, _) in fields do
    if !allowed.contains k then
      throw (.unknownExecutableField k)

def getField? (fields : List (String × Json)) (name : String) : Option Json :=
  (fields.find? (fun (k, _) => k == name)).map Prod.snd

def getField (fields : List (String × Json)) (name : String) : Except DecodeFailure Json :=
  match getField? fields name with
  | some val => .ok val
  | none => .error (.missingField name)

def decodeParty (j : Json) : Except DecodeFailure Party := do
  match j with
  | .str "alice" => .ok .alice
  | .str "bob" => .ok .bob
  | .str "vault" => .ok .vault
  | .str "pool" => .ok .pool
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "party")

def decodeAsset (j : Json) : Except DecodeFailure Asset := do
  match j with
  | .str "usd" => .ok .usd
  | .str "share" => .ok .share
  | .str "collateral" => .ok .collateral
  | .str "debt" => .ok .debt
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "asset")

def decodeDomain (j : Json) : Except DecodeFailure Domain := do
  match j with
  | .str "main" => .ok .main
  | .str "other" => .ok .other
  | .str s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "domain")

def decodeRat (j : Json) : Except DecodeFailure RatEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["num", "den"]
    let numJ ← getField fields.toList "num"
    let denJ ← getField fields.toList "den"
    let num : Int ← match numJ with
      | .num n =>
        if n.exponent != 0 then .error .lexicalScientificOrFloat
        else .ok n.mantissa
      | _ => .error (.jsonType "num")
    let den : Nat ← match denJ with
      | .num n =>
        if n.exponent != 0 then .error .lexicalScientificOrFloat
        else if n.mantissa < 0 then .error (.jsonType "den")
        else .ok n.mantissa.toNat
      | _ => .error (.jsonType "den")
    decodeRational num den
  | _ => .error (.jsonType "rational")

def decodeNumericUnit (j : Json) : Except DecodeFailure NumericUnitEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "asset", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "amount" =>
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.amount a)
    | .str "price" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.price b q)
    | .str "scalar" => .ok .scalar
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "numericUnitTag")
  | _ => .error (.jsonType "numericUnit")

def decodeUnit (j : Json) : Except DecodeFailure UnitEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "asset", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "amount" =>
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.numeric (.amount a))
    | .str "price" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.numeric (.price b q))
    | .str "scalar" => .ok (.numeric .scalar)
    | .str "bool" => .ok .bool
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "unitTag")
  | _ => .error (.jsonType "unit")

def decodePackedValue (j : Json) : Except DecodeFailure PackedValueEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["unit", "value"]
    let uJ ← getField fields.toList "unit"
    let u ← decodeUnit uJ
    let valJ ← getField fields.toList "value"
    match u with
    | .bool =>
      match valJ with
      | .bool b => .ok ⟨.bool, 0, b⟩
      | _ => .error (.jsonType "boolValue")
    | .numeric nu =>
      let r ← decodeRat valJ
      .ok ⟨.numeric nu, r.toRat, false⟩
  | _ => .error (.jsonType "packedValue")

def decodePartyRef (j : Json) : Except DecodeFailure PartyRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "party", "index"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "caller" => .ok .caller
    | .str "literal" =>
      let pJ ← getField fields.toList "party"
      let p ← decodeParty pJ
      .ok (.literal p)
    | .str "argument" =>
      let iJ ← getField fields.toList "index"
      match iJ with
      | .num n => .ok (.argument n.mantissa.toNat)
      | _ => .error (.jsonType "argumentIndex")
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "partyRefTag")
  | _ => .error (.jsonType "partyRef")

def decodeCellRef (j : Json) : Except DecodeFailure CellRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "owner"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let oJ ← getField fields.toList "owner"
    let o ← decodePartyRef oJ
    .ok ⟨d, o⟩
  | _ => .error (.jsonType "cellRef")

def decodePackedCellRef (j : Json) : Except DecodeFailure PackedCellRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["asset", "cell"]
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let cJ ← getField fields.toList "cell"
    let c ← decodeCellRef cJ
    .ok ⟨a, c⟩
  | _ => .error (.jsonType "packedCellRef")

def decodeCell (j : Json) : Except DecodeFailure CellEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party", "asset"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let p ← decodeParty pJ
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    .ok ⟨d, p, a⟩
  | _ => .error (.jsonType "cell")

def decodeObservationKey (j : Json) : Except DecodeFailure ObservationKeyEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "id"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let idJ ← getField fields.toList "id"
    match idJ with
    | .num n => .ok ⟨d, n.mantissa.toNat⟩
    | _ => .error (.jsonType "observationKeyId")
  | _ => .error (.jsonType "observationKey")

def decodeObservationRef (j : Json) : Except DecodeFailure ObservationRefEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["key", "unit"]
    let kJ ← getField fields.toList "key"
    let k ← decodeObservationKey kJ
    let uJ ← getField fields.toList "unit"
    let u ← decodeUnit uJ
    .ok ⟨k, u⟩
  | _ => .error (.jsonType "observationRef")

def decodeEnvRead (j : Json) : Except DecodeFailure EnvReadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "key"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "observation" =>
      let kJ ← getField fields.toList "key"
      let k ← decodeObservationKey kJ
      .ok (.observation k)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "envReadTag")
  | _ => .error (.jsonType "envRead")

def decodeUnaryOp (j : Json) : Except DecodeFailure UnaryOpEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "numeric"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "neg" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.neg num)
    | .str "not" => .ok .not
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "unaryOpTag")
  | _ => .error (.jsonType "unaryOp")

def decodeBinaryOp (j : Json) : Except DecodeFailure BinaryOpEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "numeric", "unit", "base", "quote"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "add" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.add num)
    | .str "sub" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.sub num)
    | .str "scale" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.scale num)
    | .str "divide" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.divide num)
    | .str "ratio" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.ratio num)
    | .str "convert" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.convert b q)
    | .str "unconvert" =>
      let bJ ← getField fields.toList "base"
      let qJ ← getField fields.toList "quote"
      let b ← decodeAsset bJ
      let q ← decodeAsset qJ
      .ok (.unconvert b q)
    | .str "eq" =>
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      .ok (.eq u)
    | .str "le" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.le num)
    | .str "lt" =>
      let numJ ← getField fields.toList "numeric"
      let num ← decodeNumericUnit numJ
      .ok (.lt num)
    | .str "and" => .ok .and
    | .str "or" => .ok .or
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "binaryOpTag")
  | _ => .error (.jsonType "binaryOp")

mutual
partial def decodeExpr (j : Json) : Except DecodeFailure ExprEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "unit", "value", "index", "cell", "ref", "op", "x", "y", "cond", "thenExpr", "elseExpr"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "lit" =>
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      let vJ ← getField fields.toList "value"
      match u with
      | .bool =>
        match vJ with
        | .bool b => .ok (.lit ⟨.bool, 0, b⟩)
        | _ => .error (.jsonType "boolValue")
      | .numeric nu =>
        let r ← decodeRat vJ
        .ok (.lit ⟨.numeric nu, r.toRat, false⟩)
    | .str "arg" =>
      let iJ ← getField fields.toList "index"
      let uJ ← getField fields.toList "unit"
      let u ← decodeUnit uJ
      match iJ with
      | .num n => .ok (.arg n.mantissa.toNat u)
      | _ => .error (.jsonType "argIndex")
    | .str "balance" =>
      let cJ ← getField fields.toList "cell"
      let c ← decodePackedCellRef cJ
      .ok (.balance c)
    | .str "observe" =>
      let rJ ← getField fields.toList "ref"
      let r ← decodeObservationRef rJ
      .ok (.observe r)
    | .str "unary" =>
      let opJ ← getField fields.toList "op"
      let op ← decodeUnaryOp opJ
      let xJ ← getField fields.toList "x"
      let x ← decodeExpr xJ
      .ok (.unary op x)
    | .str "binary" =>
      let opJ ← getField fields.toList "op"
      let op ← decodeBinaryOp opJ
      let xJ ← getField fields.toList "x"
      let x ← decodeExpr xJ
      let yJ ← getField fields.toList "y"
      let y ← decodeExpr yJ
      .ok (.binary op x y)
    | .str "ite" =>
      let cJ ← getField fields.toList "cond"
      let c ← decodeExpr cJ
      let tJ ← getField fields.toList "thenExpr"
      let t ← decodeExpr tJ
      let eJ ← getField fields.toList "elseExpr"
      let e ← decodeExpr eJ
      .ok (.ite c t e)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "exprTag")
  | _ => .error (.jsonType "expr")
end

def decodeCellDelta (j : Json) : Except DecodeFailure CellDeltaEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["asset", "target", "amount"]
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let tJ ← getField fields.toList "target"
    let t ← decodeCellRef tJ
    let amtJ ← getField fields.toList "amount"
    let amt ← decodeExpr amtJ
    .ok ⟨a, t, amt⟩
  | _ => .error (.jsonType "cellDelta")

def decodeSupplyDelta (j : Json) : Except DecodeFailure SupplyDeltaEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "asset", "amount"]
    let dJ ← getField fields.toList "domain"
    let d ← decodeDomain dJ
    let aJ ← getField fields.toList "asset"
    let a ← decodeAsset aJ
    let amtJ ← getField fields.toList "amount"
    let amt ← decodeExpr amtJ
    .ok ⟨d, a, amt⟩
  | _ => .error (.jsonType "supplyDelta")

def decodeTemplate (j : Json) : Except DecodeFailure TemplateEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["signature", "domain", "partyArity", "guard", "deltas", "supplyDeltas", "stateReads", "envReads", "writes"]
    let sigJ ← getField fields.toList "signature"
    let sigArr ← match sigJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "signature")
    let signature ← sigArr.toList.mapM decodeUnit
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let arityJ ← getField fields.toList "partyArity"
    let partyArity ← match arityJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "partyArity")
    let guardJ ← getField fields.toList "guard"
    let guard ← decodeExpr guardJ
    let deltasJ ← getField fields.toList "deltas"
    let deltasArr ← match deltasJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "deltas")
    let deltas ← deltasArr.toList.mapM decodeCellDelta
    let supJ ← getField fields.toList "supplyDeltas"
    let supArr ← match supJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "supplyDeltas")
    let supplyDeltas ← supArr.toList.mapM decodeSupplyDelta
    let srJ ← getField fields.toList "stateReads"
    let srArr ← match srJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "stateReads")
    let stateReads ← srArr.toList.mapM decodePackedCellRef
    let erJ ← getField fields.toList "envReads"
    let erArr ← match erJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "envReads")
    let envReads ← erArr.toList.mapM decodeEnvRead
    let wJ ← getField fields.toList "writes"
    let wArr ← match wJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "writes")
    let writes ← wArr.toList.mapM decodePackedCellRef
    .ok ⟨signature, domain, partyArity, guard, deltas, supplyDeltas, stateReads, envReads, writes⟩
  | _ => .error (.jsonType "template")

def decodeRegistryEntry (j : Json) : Except DecodeFailure RegistryEntryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "template"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "registryId")
    let tJ ← getField fields.toList "template"
    let t ← decodeTemplate tJ
    .ok ⟨id, t⟩
  | _ => .error (.jsonType "registryEntry")

def decodeRegistry (j : Json) : Except DecodeFailure RegistryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "registryEntries")
    let entries ← arr.toList.mapM decodeRegistryEntry
    .ok ⟨entries⟩
  | _ => .error (.jsonType "registry")

def decodeRight (j : Json) : Except DecodeFailure RightEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "cell", "domain", "asset"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "invoke" => .ok .invoke
    | .str "debit" =>
      let cJ ← getField fields.toList "cell"
      let c ← decodeCell cJ
      .ok (.debit c)
    | .str "changeSupply" =>
      let dJ ← getField fields.toList "domain"
      let d ← decodeDomain dJ
      let aJ ← getField fields.toList "asset"
      let a ← decodeAsset aJ
      .ok (.changeSupply d a)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "rightTag")
  | _ => .error (.jsonType "right")

def decodeGrant (j : Json) : Except DecodeFailure GrantEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["holder", "domain", "operation", "right"]
    let hJ ← getField fields.toList "holder"
    let holder ← decodeParty hJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "grantOperation")
    let rJ ← getField fields.toList "right"
    let right ← decodeRight rJ
    .ok ⟨holder, domain, operation, right⟩
  | _ => .error (.jsonType "grant")

def decodeCapability (j : Json) : Except DecodeFailure CapabilityEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["holder", "domain", "operation", "right", "live"]
    let hJ ← getField fields.toList "holder"
    let holder ← decodeParty hJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityOperation")
    let rJ ← getField fields.toList "right"
    let right ← decodeRight rJ
    let lJ ← getField fields.toList "live"
    let live ← match lJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "capabilityLive")
    .ok ⟨holder, domain, operation, right, live⟩
  | _ => .error (.jsonType "capability")

def decodeStore (j : Json) : Except DecodeFailure StoreEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "storeEntries")
    let entries ← arr.toList.mapM decodeCapability
    .ok ⟨entries⟩
  | _ => .error (.jsonType "store")

def decodeStateCell (j : Json) : Except DecodeFailure StateCellEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party", "asset", "amount"]
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let party ← decodeParty pJ
    let aJ ← getField fields.toList "asset"
    let asset ← decodeAsset aJ
    let amtJ ← getField fields.toList "amount"
    let amount ← decodeRat amtJ
    .ok ⟨domain, party, asset, amount⟩
  | _ => .error (.jsonType "stateCell")

def decodeState (j : Json) : Except DecodeFailure StateEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["cells"]
    let cellsJ ← getField fields.toList "cells"
    let arr ← match cellsJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "stateCells")
    let cells ← arr.toList.mapM decodeStateCell
    .ok ⟨cells⟩
  | _ => .error (.jsonType "state")

def decodeContext (j : Json) : Except DecodeFailure ContextEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["principal", "domain"]
    let pJ ← getField fields.toList "principal"
    let principal ← decodeParty pJ
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    .ok ⟨principal, domain⟩
  | _ => .error (.jsonType "context")

def decodeObservation (j : Json) : Except DecodeFailure ObservationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["value", "timestamp"]
    let vJ ← getField fields.toList "value"
    let val ← decodePackedValue vJ
    let tJ ← getField fields.toList "timestamp"
    let ts ← match tJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "timestamp")
    .ok ⟨val, ts⟩
  | _ => .error (.jsonType "observation")

def decodeEnvironmentEntry (j : Json) : Except DecodeFailure EnvironmentEntryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["key", "observation"]
    let kJ ← getField fields.toList "key"
    let k ← decodeObservationKey kJ
    let oJ ← getField fields.toList "observation"
    let o ← decodeObservation oJ
    .ok ⟨k, o⟩
  | _ => .error (.jsonType "environmentEntry")

def decodeEnvironment (j : Json) : Except DecodeFailure EnvironmentEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["entries"]
    let entJ ← getField fields.toList "entries"
    let arr ← match entJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "environmentEntries")
    let entries ← arr.toList.mapM decodeEnvironmentEntry
    .ok ⟨entries⟩
  | _ => .error (.jsonType "environment")

def decodeBoundary (j : Json) : Except DecodeFailure BoundaryEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["ctx", "env", "now"]
    let cJ ← getField fields.toList "ctx"
    let ctx ← decodeContext cJ
    let eJ ← getField fields.toList "env"
    let env ← decodeEnvironment eJ
    let nJ ← getField fields.toList "now"
    let now ← match nJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "boundaryNow")
    .ok ⟨ctx, env, now⟩
  | _ => .error (.jsonType "boundary")

def decodeDomainAdmin (j : Json) : Except DecodeFailure DomainAdminEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["domain", "party"]
    let dJ ← getField fields.toList "domain"
    let domain ← decodeDomain dJ
    let pJ ← getField fields.toList "party"
    let party ← decodeParty pJ
    .ok ⟨domain, party⟩
  | _ => .error (.jsonType "domainAdmin")

def decodeInputPort (j : Json) : Except DecodeFailure InputPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "unit"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "inputPortId")
    let uJ ← getField fields.toList "unit"
    let unit ← decodeUnit uJ
    .ok ⟨id, unit⟩
  | _ => .error (.jsonType "inputPort")

def decodeOutputPort (j : Json) : Except DecodeFailure OutputPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "cell"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "outputPortId")
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    .ok ⟨id, cell⟩
  | _ => .error (.jsonType "outputPort")

def decodeResourcePort (j : Json) : Except DecodeFailure ResourcePortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "cell", "writable"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "resourcePortId")
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    let wJ ← getField fields.toList "writable"
    let writable ← match wJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "resourcePortWritable")
    .ok ⟨id, cell, writable⟩
  | _ => .error (.jsonType "resourcePort")

def decodeQualifiedPort (j : Json) : Except DecodeFailure QualifiedPortEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["component", "port"]
    let cJ ← getField fields.toList "component"
    let component ← match cJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "qualifiedPortComponent")
    let pJ ← getField fields.toList "port"
    let port ← match pJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "qualifiedPortPort")
    .ok ⟨component, port⟩
  | _ => .error (.jsonType "qualifiedPort")

def decodeResourceImport (j : Json) : Except DecodeFailure ResourceImportEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["source", "cell", "writable"]
    let sJ ← getField fields.toList "source"
    let source ← decodeQualifiedPort sJ
    let cJ ← getField fields.toList "cell"
    let cell ← decodeCell cJ
    let wJ ← getField fields.toList "writable"
    let writable ← match wJ with
      | .bool b => .ok b
      | _ => .error (.jsonType "resourceImportWritable")
    .ok ⟨source, cell, writable⟩
  | _ => .error (.jsonType "resourceImport")

def decodeOperationInterface (j : Json) : Except DecodeFailure OperationInterfaceEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["operation", "inputs", "outputs"]
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "operationInterfaceOp")
    let inJ ← getField fields.toList "inputs"
    let inArr ← match inJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "operationInterfaceInputs")
    let inputs ← inArr.toList.mapM decodeInputPort
    let outJ ← getField fields.toList "outputs"
    let outArr ← match outJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "operationInterfaceOutputs")
    let outputs ← outArr.toList.mapM decodeOutputPort
    .ok ⟨operation, inputs, outputs⟩
  | _ => .error (.jsonType "operationInterface")

def decodeComponent (j : Json) : Except DecodeFailure ComponentEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["id", "privateCells", "exports", "imports", "operations"]
    let idJ ← getField fields.toList "id"
    let id ← match idJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "componentId")
    let privJ ← getField fields.toList "privateCells"
    let privArr ← match privJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentPrivateCells")
    let privateCells ← privArr.toList.mapM decodeCell
    let expJ ← getField fields.toList "exports"
    let expArr ← match expJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentExports")
    let exports ← expArr.toList.mapM decodeResourcePort
    let impJ ← getField fields.toList "imports"
    let impArr ← match impJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentImports")
    let imports ← impArr.toList.mapM decodeResourceImport
    let opsJ ← getField fields.toList "operations"
    let opsArr ← match opsJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "componentOperations")
    let operations ← opsArr.toList.mapM decodeOperationInterface
    .ok ⟨id, privateCells, exports, imports, operations⟩
  | _ => .error (.jsonType "component")

def decodeConfig (j : Json) : Except DecodeFailure ConfigEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["registry", "domainAdmin", "catalog"]
    let rJ ← getField fields.toList "registry"
    let registry ← decodeRegistry rJ
    let daJ ← getField fields.toList "domainAdmin"
    let daArr ← match daJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "domainAdminEntries")
    let domainAdmin ← daArr.toList.mapM decodeDomainAdmin
    let catJ ← getField fields.toList "catalog"
    let catArr ← match catJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "catalog")
    let catalog ← catArr.toList.mapM decodeComponent
    .ok ⟨registry, domainAdmin, catalog⟩
  | _ => .error (.jsonType "config")

def decodeRequest (j : Json) : Except DecodeFailure RequestEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["operation", "parties", "arguments", "capabilityIds", "claimedActor"]
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n =>
        if n.mantissa < 0 then .error (.jsonType "operation")
        else .ok n.mantissa.toNat
      | _ => .error (.jsonType "operation")
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "parties")
    let parties ← pArr.toList.mapM decodeParty
    let aJ ← getField fields.toList "arguments"
    let aArr ← match aJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "arguments")
    let arguments ← aArr.toList.mapM decodePackedValue
    let cJ ← getField fields.toList "capabilityIds"
    let cArr ← match cJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "capabilityIds")
    let capabilityIds ← cArr.toList.mapM fun x => match x with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityId")
    let caJ := getField? fields.toList "claimedActor"
    let claimedActor ← match caJ with
      | some .null | none => .ok none
      | some val => (decodeParty val).map some
    .ok ⟨operation, parties, arguments, capabilityIds, claimedActor⟩
  | _ => .error (.jsonType "request")

def decodeInputSource (j : Json) : Except DecodeFailure InputSourceEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["tag", "value", "step", "port"]
    let tagJ ← getField fields.toList "tag"
    match tagJ with
    | .str "literal" =>
      let vJ ← getField fields.toList "value"
      let val ← decodePackedValue vJ
      .ok (.literal val)
    | .str "priorOutput" =>
      let sJ ← getField fields.toList "step"
      let step ← match sJ with
        | .num n => .ok n.mantissa.toNat
        | _ => .error (.jsonType "priorOutputStep")
      let pJ ← getField fields.toList "port"
      let port ← decodeQualifiedPort pJ
      .ok (.priorOutput step port)
    | .str s => .error (.unknownIdentifier s)
    | _ => .error (.jsonType "inputSourceTag")
  | _ => .error (.jsonType "inputSource")

def decodeInvocation (j : Json) : Except DecodeFailure InvocationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["component", "operation", "parties", "inputs", "capabilityIds", "claimedActor"]
    let cJ ← getField fields.toList "component"
    let component ← match cJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "invocationComponent")
    let opJ ← getField fields.toList "operation"
    let operation ← match opJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "invocationOperation")
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationParties")
    let parties ← pArr.toList.mapM decodeParty
    let inJ ← getField fields.toList "inputs"
    let inArr ← match inJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationInputs")
    let inputs ← inArr.toList.mapM decodeInputSource
    let capJ ← getField fields.toList "capabilityIds"
    let capArr ← match capJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "invocationCapabilityIds")
    let capabilityIds ← capArr.toList.mapM fun x => match x with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "capabilityId")
    let caJ := getField? fields.toList "claimedActor"
    let claimedActor ← match caJ with
      | some .null | none => .ok none
      | some val => (decodeParty val).map some
    .ok ⟨component, operation, parties, inputs, capabilityIds, claimedActor⟩
  | _ => .error (.jsonType "invocation")

def decodeInvoke (j : Json) : Except DecodeFailure StepEnc := do
  match j with
  | .obj fields =>
    let invJ ← getField fields.toList "invocation"
    let inv ← decodeInvocation invJ
    .ok (.invoke inv)
  | _ => .error (.jsonType "step")

def decodeStep (j : Json) : Except DecodeFailure StepEnc := do
  let rest := j
  let _ := rest
  match j with
  | .obj fields =>
    let tagJ ← getField fields.toList "tag"
    let tag ← match tagJ with
      | .str s => .ok s
      | _ => .error (.jsonType "stepTag")
    match tag with
    | "treeJoin" | "naryAdvance" => .error (.unsupportedForm _)
    | "invoke" =>
      checkObjectKeys fields.toList ["tag", "invocation"]
      let invJ ← getField fields.toList "invocation"
      let inv ← decodeInvocation invJ
      .ok (.invoke inv)
    | "issue" =>
      checkObjectKeys fields.toList ["tag", "grant"]
      let gJ ← getField fields.toList "grant"
      let grant ← decodeGrant gJ
      .ok (.issue grant)
    | "revoke" =>
      checkObjectKeys fields.toList ["tag", "id"]
      let idJ ← getField fields.toList "id"
      let id ← match idJ with
        | .num n => .ok n.mantissa.toNat
        | _ => .error (.jsonType "revokeId")
      .ok (.revoke id)
    | s => .error (.unknownIdentifier s)
  | _ => .error (.jsonType "step")

def decodeWorld (j : Json) : Except DecodeFailure WorldEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["state", "capabilities"]
    let sJ ← getField fields.toList "state"
    let state ← decodeState sJ
    let cJ ← getField fields.toList "capabilities"
    let caps ← decodeStore cJ
    .ok ⟨state, caps⟩
  | _ => .error (.jsonType "world")

def decodeOutputObservation (j : Json) : Except DecodeFailure OutputObservationEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["step", "port", "value"]
    let sJ ← getField fields.toList "step"
    let step ← match sJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "outputObservationStep")
    let pJ ← getField fields.toList "port"
    let port ← decodeQualifiedPort pJ
    let vJ ← getField fields.toList "value"
    let val ← decodePackedValue vJ
    .ok ⟨step, port, val⟩
  | _ => .error (.jsonType "outputObservation")

def decodeSourcePin (j : Json) : Except DecodeFailure SourcePinEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["git", "lean_toolchain", "mathlib_rev", "checker_candidate", "compiler_record", "audit_record"]
    let gitJ ← getField fields.toList "git"
    let git ← match gitJ with | .str s => .ok s | _ => .error (.jsonType "git")
    let ltJ ← getField fields.toList "lean_toolchain"
    let lt ← match ltJ with | .str s => .ok s | _ => .error (.jsonType "lean_toolchain")
    let mlJ ← getField fields.toList "mathlib_rev"
    let ml ← match mlJ with | .str s => .ok s | _ => .error (.jsonType "mathlib_rev")
    let ccJ ← getField fields.toList "checker_candidate"
    let cc ← match ccJ with | .str s => .ok s | _ => .error (.jsonType "checker_candidate")
    let crJ := getField? fields.toList "compiler_record"
    let cr := match crJ with | some (.str s) => some s | _ => none
    let arJ := getField? fields.toList "audit_record"
    let ar := match arJ with | some (.str s) => some s | _ => none
    .ok ⟨git, lt, ml, cc, cr, ar⟩
  | _ => .error (.jsonType "source_pin")

def decodeTypesEnum (j : Json) : Except DecodeFailure TypesEnumEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["parties", "assets", "domains"]
    let pJ ← getField fields.toList "parties"
    let pArr ← match pJ with | .arr a => .ok a | _ => .error (.jsonType "parties")
    let parties ← pArr.toList.mapM decodeParty
    let aJ ← getField fields.toList "assets"
    let aArr ← match aJ with | .arr a => .ok a | _ => .error (.jsonType "assets")
    let assets ← aArr.toList.mapM decodeAsset
    let dJ ← getField fields.toList "domains"
    let dArr ← match dJ with | .arr a => .ok a | _ => .error (.jsonType "domains")
    let domains ← dArr.toList.mapM decodeDomain
    .ok ⟨parties, assets, domains⟩
  | _ => .error (.jsonType "types")

def decodeLibraryRef (j : Json) : Except DecodeFailure LibraryRefEnc := do
  match j with
  | .str s => .ok ⟨s, none⟩
  | .obj fields =>
    checkObjectKeys fields.toList ["theorem", "module"]
    let tJ ← getField fields.toList "theorem"
    let t ← match tJ with | .str s => .ok s | _ => .error (.jsonType "theorem")
    let mJ := getField? fields.toList "module"
    let m := match mJ with | some (.str s) => some s | _ => none
    .ok ⟨t, m⟩
  | _ => .error (.jsonType "libraryRef")

def decodeEnvelope (fields : List (String × Json)) : Except DecodeFailure EnvelopeEnc := do
  let verJ ← match getField? fields "schema_version" with
    | some v => .ok v
    | none => .error .schemaVersion
  let schema_version ← match verJ with
    | .num n =>
      if n.mantissa != 1 then .error .schemaVersion
      else .ok 1
    | _ => .error .schemaVersion
  checkObjectKeys fields [
    "schema_version", "mode", "source_pin", "audit_roots", "types", "assumptions",
    "invariants", "libraries", "source_map", "payload", "claimed_judgments",
    "claimed_next_state", "require_library_discharge", "require_invariant_discharge"
  ]
  let modeJ ← getField fields "mode"
  let mode ← match modeJ with | .str s => .ok s | _ => .error (.jsonType "mode")
  let pinJ ← getField fields "source_pin"
  let source_pin ← decodeSourcePin pinJ
  let rootsJ ← getField fields "audit_roots"
  let rootsArr ← match rootsJ with | .arr a => .ok a | _ => .error (.jsonType "audit_roots")
  let audit_roots ← rootsArr.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "root")
  let typesJ ← getField fields "types"
  let types ← decodeTypesEnum typesJ
  let asmJ ← getField fields "assumptions"
  let asmArr ← match asmJ with | .arr a => .ok a | _ => .error (.jsonType "assumptions")
  let assumptions ← asmArr.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "assumption")
  let invJ := getField? fields "invariants"
  let invariants ← match invJ with
    | some (.arr a) => a.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "invariant")
    | _ => .ok []
  let libJ := getField? fields "libraries"
  let libraries ← match libJ with
    | some (.arr a) => a.toList.mapM decodeLibraryRef
    | _ => .ok []
  let smJ := getField? fields "source_map"
  let source_map : List (String × String) ← match smJ with
    | some (.obj m) => .ok (m.toList.map (fun (k, v) => (k, match v with | .str s => s | _ => "")))
    | _ => .ok []
  let cjJ := getField? fields "claimed_judgments"
  let claimed_judgments ← match cjJ with
    | some (.arr a) => a.toList.mapM fun x => match x with | .str s => .ok s | _ => .error (.jsonType "claimedJudgment")
    | _ => .ok []
  let cnsJ := getField? fields "claimed_next_state"
  let claimed_next_state ← match cnsJ with
    | some .null | none => .ok none
    | some val => (decodeWorld val).map some
  let reqLibJ := getField? fields "require_library_discharge"
  let require_library_discharge := match reqLibJ with | some (.bool b) => b | _ => false
  let reqInvJ := getField? fields "require_invariant_discharge"
  let require_invariant_discharge := match reqInvJ with | some (.bool b) => b | _ => false
  .ok ⟨schema_version, mode, source_pin, audit_roots, types, assumptions, invariants,
       libraries, source_map, claimed_judgments, claimed_next_state,
       require_library_discharge, require_invariant_discharge⟩

def decodeTypedExecutePayload (j : Json) : Except DecodeFailure TypedExecutePayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["registry", "store", "ctx", "env", "now", "request", "state"]
    let rJ ← getField fields.toList "registry"
    let registry ← decodeRegistry rJ
    let sJ ← getField fields.toList "store"
    let store ← decodeStore sJ
    let cJ ← getField fields.toList "ctx"
    let ctx ← decodeContext cJ
    let eJ ← getField fields.toList "env"
    let env ← decodeEnvironment eJ
    let nJ ← getField fields.toList "now"
    let now ← match nJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "now")
    let reqJ ← getField fields.toList "request"
    let request ← decodeRequest reqJ
    let stJ ← getField fields.toList "state"
    let state ← decodeState stJ
    .ok ⟨registry, store, ctx, env, now, request, state⟩
  | _ => .error (.jsonType "typedPayload")

def decodeCompositionStepPayload (j : Json) : Except DecodeFailure CompositionStepPayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["config", "boundary", "index", "history", "step", "pre"]
    let cJ ← getField fields.toList "config"
    let config ← decodeConfig cJ
    let bJ ← getField fields.toList "boundary"
    let boundary ← decodeBoundary bJ
    let iJ ← getField fields.toList "index"
    let index ← match iJ with
      | .num n => .ok n.mantissa.toNat
      | _ => .error (.jsonType "index")
    let hJ ← getField fields.toList "history"
    let hArr ← match hJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "history")
    let history ← hArr.toList.mapM decodeOutputObservation
    let stepJ ← getField fields.toList "step"
    let step ← decodeStep stepJ
    let preJ ← getField fields.toList "pre"
    let pre ← decodeWorld preJ
    .ok ⟨config, boundary, index, history, step, pre⟩
  | _ => .error (.jsonType "compositionStepPayload")

def decodeCompositionRunPayload (j : Json) : Except DecodeFailure CompositionRunPayloadEnc := do
  match j with
  | .obj fields =>
    checkObjectKeys fields.toList ["config", "boundaries", "world", "steps"]
    let cJ ← getField fields.toList "config"
    let config ← decodeConfig cJ
    let bJ ← getField fields.toList "boundaries"
    let bArr ← match bJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "boundaries")
    let boundaries ← bArr.toList.mapM decodeBoundary
    let wJ ← getField fields.toList "world"
    let world ← decodeWorld wJ
    let sJ ← getField fields.toList "steps"
    let sArr ← match sJ with
      | .arr a => .ok a
      | _ => .error (.jsonType "steps")
    let steps ← sArr.toList.mapM decodeStep
    .ok ⟨config, boundaries, world, steps⟩
  | _ => .error (.jsonType "compositionRunPayload")

def decodeDecodedIR (j : Json) (raw : String) : Except DecodeFailure DecodedIR := do
  match j with
  | .obj fields =>
    let env ← decodeEnvelope fields.toList
    let payloadJ ← getField fields.toList "payload"
    match env.mode with
    | "typed-execute" =>
      let payload ← decodeTypedExecutePayload payloadJ
      .ok (.execution (.typed env payload))
    | "composition-step" =>
      let payload ← decodeCompositionStepPayload payloadJ
      .ok (.execution (.step env payload))
    | "composition-run" =>
      let payload ← decodeCompositionRunPayload payloadJ
      .ok (.execution (.run env payload))
    | "codec" =>
      .ok (.codec ⟨some env, raw⟩)
    | "audit" =>
      .ok (.audit ⟨env, [], 1, [], none, none⟩)
    | s => .error (.unknownIdentifier s)
  | _ => .error .notJsonObject

/-- Primary byte-level decode entrypoint with lexical security checks. -/
def decodeBytes (bytes : ByteArray) : Except DecodeFailure DecodedIR := do
  scanLexical bytes
  let some str := String.fromUTF8? bytes
    | throw (.jsonType "utf8")
  match Json.parse str with
  | .error _ => throw .notJsonObject
  | .ok j => decodeDecodedIR j str

def encodeModule (ir : DecodedIR) : ByteArray :=
  match ir with
  | .codec doc => doc.rawText.toUTF8
  | .audit _ => "{}".toUTF8
  | .execution _ => "{}".toUTF8

end DefiKernel.Certificates

