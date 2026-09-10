import DefiKernel.Certificates.Correspondence
import Lean.Data.Json.Parser
import DefiKernel.Certificates.Check
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


#eval IO.println (encodeOutcome (checkBytes (encodeModule (stepIR [bigPrivate]))))
