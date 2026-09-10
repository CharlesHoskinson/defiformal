import Lean.Data.Json.Basic
import DefiKernel.Certificates.Schema

namespace DefiKernel.Certificates

set_option linter.style.longLine false

/-- Tokens produced by the canonical JSON lexer. -/
inductive JsonToken where
  | lbrace
  | rbrace
  | lbracket
  | rbracket
  | colon
  | comma
  | str (s : String)
  | num (n : Lean.JsonNumber)
  | bool (b : Bool)
  | null
  deriving Inhabited, BEq

/-- Structurally recursive string literal parser on character list. -/
def lexString (acc : List Char) : List Char → Except DecodeFailure (String × List Char)
  | [] => .error .notJsonObject
  | '"' :: rest => .ok (String.ofList acc.reverse, rest)
  | '\\' :: c :: rest =>
    let esc := match c with
      | '"' => '"'
      | '\\' => '\\'
      | '/' => '/'
      | 'b' => '\x08'
      | 'f' => '\x0c'
      | 'n' => '\n'
      | 'r' => '\x0d'
      | 't' => '\t'
      | other => other
    lexString (esc :: acc) rest
  | '\\' :: [] => .error .notJsonObject
  | c :: rest => lexString (c :: acc) rest

/-- Structurally recursive integer digit parser on character list. -/
def lexDigits (acc : Nat) : List Char → Nat × List Char
  | [] => (acc, [])
  | c :: rest =>
    if c >= '0' && c <= '9' then
      lexDigits (acc * 10 + (c.toNat - '0'.toNat)) rest
    else
      (acc, c :: rest)

/-- Fuel-bounded total canonical tokenizer. Guaranteed terminating on fuel. -/
def tokenizeFuel (fuel : Nat) (chars : List Char) : Except DecodeFailure (List JsonToken) :=
  match fuel with
  | 0 => .error (.resourceLimit "tokenizeFuel")
  | fuel' + 1 =>
    match chars with
    | [] => .ok []
    | ' ' :: rest | '\t' :: rest | '\n' :: rest | '\r' :: rest =>
      tokenizeFuel fuel' rest
    | '{' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.lbrace :: toks)
    | '}' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.rbrace :: toks)
    | '[' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.lbracket :: toks)
    | ']' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.rbracket :: toks)
    | ':' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.colon :: toks)
    | ',' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.comma :: toks)
    | '"' :: rest => do
      let (s, rest') ← lexString [] rest
      let toks ← tokenizeFuel fuel' rest'
      .ok (.str s :: toks)
    | 't' :: 'r' :: 'u' :: 'e' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.bool true :: toks)
    | 'f' :: 'a' :: 'l' :: 's' :: 'e' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.bool false :: toks)
    | 'n' :: 'u' :: 'l' :: 'l' :: rest => do
      let toks ← tokenizeFuel fuel' rest
      .ok (.null :: toks)
    | '-' :: c :: rest =>
      if c >= '0' && c <= '9' then do
        let (n, rest') := lexDigits (c.toNat - '0'.toNat) rest
        let toks ← tokenizeFuel fuel' rest'
        .ok (.num ⟨- (n : Int), 0⟩ :: toks)
      else
        .error .notJsonObject
    | c :: rest =>
      if c >= '0' && c <= '9' then do
        let (n, rest') := lexDigits (c.toNat - '0'.toNat) rest
        let toks ← tokenizeFuel fuel' rest'
        .ok (.num ⟨(n : Int), 0⟩ :: toks)
      else
        .error .notJsonObject

/-- Entrypoint for canonical JSON tokenization. -/
def tokenize (s : String) : Except DecodeFailure (List JsonToken) :=
  let cs := s.toList
  tokenizeFuel (cs.length + 1) cs

/-- State within an object frame during pushdown parsing. -/
inductive ObjState where
  | emptyOrKey
  | expectKey
  | expectColon (key : String)
  | expectVal (key : String)
  | expectCommaOrRbrace

/-- State within an array frame during pushdown parsing. -/
inductive ArrState where
  | emptyOrVal
  | expectVal
  | expectCommaOrRbracket

/-- Stack frame for pushdown automaton parsing nested structures. -/
inductive StackFrame where
  | obj (acc : List (String × Lean.Json)) (st : ObjState)
  | arr (acc : Array Lean.Json) (st : ArrState)

/-- State of the pushdown parser. -/
structure ParserState where
  stack : List StackFrame
  result : Option Lean.Json

/-- Feeds a completed JSON value into the enclosing stack frame. -/
def feedValue (st : ParserState) (v : Lean.Json) : Except DecodeFailure ParserState :=
  match st.stack with
  | [] =>
    if st.result.isSome then .error .notJsonObject
    else .ok { stack := [], result := some v }
  | StackFrame.arr acc ArrState.emptyOrVal :: rest =>
    if acc.size >= 4096 then .error (.resourceLimit "max_array_length")
    else .ok { st with stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest }
  | StackFrame.arr acc ArrState.expectVal :: rest =>
    if acc.size >= 4096 then .error (.resourceLimit "max_array_length")
    else .ok { st with stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest }
  | StackFrame.obj acc (ObjState.expectVal key) :: rest =>
    if acc.any (fun (k, _) => k == key) then .error (.duplicateKey key)
    else .ok { st with stack := StackFrame.obj ((key, v) :: acc) ObjState.expectCommaOrRbrace :: rest }
  | _ => .error .notJsonObject

/-- Single transition step for the pushdown parser on one token. -/
def parseStep (st : ParserState) (tok : JsonToken) : Except DecodeFailure ParserState :=
  match tok with
  | .null => feedValue st .null
  | .bool b => feedValue st (.bool b)
  | .num n => feedValue st (.num n)
  | .str s =>
    match st.stack with
    | StackFrame.obj acc ObjState.emptyOrKey :: rest =>
      .ok { st with stack := StackFrame.obj acc (ObjState.expectColon s) :: rest }
    | StackFrame.obj acc ObjState.expectKey :: rest =>
      .ok { st with stack := StackFrame.obj acc (ObjState.expectColon s) :: rest }
    | _ =>
      feedValue st (.str s)
  | .colon =>
    match st.stack with
    | StackFrame.obj acc (ObjState.expectColon k) :: rest =>
      .ok { st with stack := StackFrame.obj acc (ObjState.expectVal k) :: rest }
    | _ => .error .notJsonObject
  | .comma =>
    match st.stack with
    | StackFrame.obj acc ObjState.expectCommaOrRbrace :: rest =>
      .ok { st with stack :=StackFrame.obj acc ObjState.expectKey :: rest }
    | StackFrame.arr acc ArrState.expectCommaOrRbracket :: rest =>
      .ok { st with stack := StackFrame.arr acc ArrState.expectVal :: rest }
    | _ => .error .notJsonObject
  | .lbrace =>
    if st.stack.length >= 64 then .error (.resourceLimit "maxDepth")
    else match st.stack with
    | [] =>
      if st.result.isSome then .error .notJsonObject
      else .ok { st with stack := [StackFrame.obj [] ObjState.emptyOrKey] }
    | StackFrame.arr _ ArrState.emptyOrVal :: _
    | StackFrame.arr _ ArrState.expectVal :: _
    | StackFrame.obj _ (ObjState.expectVal _) :: _ =>
      .ok { st with stack := StackFrame.obj [] ObjState.emptyOrKey :: st.stack }
    | _ => .error .notJsonObject
  | .rbrace =>
    match st.stack with
    | StackFrame.obj acc ObjState.emptyOrKey :: rest =>
      let objVal := Lean.Json.mkObj acc.reverse
      feedValue { st with stack := rest } objVal
    | StackFrame.obj acc ObjState.expectCommaOrRbrace :: rest =>
      let objVal := Lean.Json.mkObj acc.reverse
      feedValue { st with stack := rest } objVal
    | _ => .error .notJsonObject
  | .lbracket =>
    if st.stack.length >= 64 then .error (.resourceLimit "maxDepth")
    else match st.stack with
    | [] =>
      if st.result.isSome then .error .notJsonObject
      else .ok { st with stack := [StackFrame.arr #[] ArrState.emptyOrVal] }
    | StackFrame.arr _ ArrState.emptyOrVal :: _
    | StackFrame.arr _ ArrState.expectVal :: _
    | StackFrame.obj _ (ObjState.expectVal _) :: _ =>
      .ok { st with stack := StackFrame.arr #[] ArrState.emptyOrVal :: st.stack }
    | _ => .error .notJsonObject
  | .rbracket =>
    match st.stack with
    | StackFrame.arr acc ArrState.emptyOrVal :: rest =>
      let arrVal := Lean.Json.arr acc
      feedValue { st with stack := rest } arrVal
    | StackFrame.arr acc ArrState.expectCommaOrRbracket :: rest =>
      let arrVal := Lean.Json.arr acc
      feedValue { st with stack := rest } arrVal
    | _ => .error .notJsonObject

/-- Total pushdown parser over a token list. Guaranteed terminating by structural recursion. -/
def parseTokens (toks : List JsonToken) : Except DecodeFailure Lean.Json := do
  let finalSt ← toks.foldlM parseStep { stack := [], result := none }
  match finalSt.stack, finalSt.result with
  | [], some j => .ok j
  | _, _ => .error .notJsonObject

/-- Total canonical JSON parser. Converts string to Lean.Json with zero partiality. -/
def parseCanonicalJson (s : String) : Except DecodeFailure Lean.Json := do
  let toks ← tokenize s
  parseTokens toks

end DefiKernel.Certificates
