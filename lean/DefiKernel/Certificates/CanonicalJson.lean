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

def hexDigit (n : Nat) : Char :=
  if n = 0 then '0'
  else if n = 1 then '1'
  else if n = 2 then '2'
  else if n = 3 then '3'
  else if n = 4 then '4'
  else if n = 5 then '5'
  else if n = 6 then '6'
  else if n = 7 then '7'
  else if n = 8 then '8'
  else if n = 9 then '9'
  else if n = 10 then 'a'
  else if n = 11 then 'b'
  else if n = 12 then 'c'
  else if n = 13 then 'd'
  else if n = 14 then 'e'
  else 'f'

def hexVal (c : Char) : Option Nat :=
  if c >= '0' && c <= '9' then some (c.toNat - '0'.toNat)
  else if c >= 'a' && c <= 'f' then some (c.toNat - 'a'.toNat + 10)
  else if c >= 'A' && c <= 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

def escapeChar (c : Char) : List Char :=
  if c = '"' then ['\\', '"']
  else if c = '\\' then ['\\', '\\']
  else if c.toNat < 32 then
    ['\\', 'u', '0', '0', hexDigit (c.toNat / 16), hexDigit (c.toNat % 16)]
  else [c]

def escapeChars : List Char → List Char
  | [] => []
  | c :: cs => escapeChar c ++ escapeChars cs

/-- Structurally recursive string literal parser on character list.
    Enforces canonical C0 unicode escaping, accepts standard JSON escapes,
    rejects malformed/unknown escapes, and rejects literal unescaped control characters. -/
def lexString (acc : List Char) : List Char → Except DecodeFailure (String × List Char)
  | [] => .error .notJsonObject
  | '"' :: rest => .ok (String.ofList acc.reverse, rest)
  | '\\' :: 'u' :: h1 :: h2 :: h3 :: h4 :: rest =>
    match hexVal h1, hexVal h2, hexVal h3, hexVal h4 with
    | some v1, some v2, some v3, some v4 =>
      let val := ((v1 * 16 + v2) * 16 + v3) * 16 + v4
      if val < 0x110000 && !(0xd800 ≤ val && val < 0xe000) then
        lexString (Char.ofNat val :: acc) rest
      else .error .notJsonObject
    | _, _, _, _ => .error .notJsonObject
  | '\\' :: '"' :: rest => lexString ('"' :: acc) rest
  | '\\' :: '\\' :: rest => lexString ('\\' :: acc) rest
  | '\\' :: '/' :: rest => lexString ('/' :: acc) rest
  | '\\' :: 'b' :: rest => lexString ('\x08' :: acc) rest
  | '\\' :: 'f' :: rest => lexString ('\x0c' :: acc) rest
  | '\\' :: 'n' :: rest => lexString ('\n' :: acc) rest
  | '\\' :: 'r' :: rest => lexString ('\x0d' :: acc) rest
  | '\\' :: 't' :: rest => lexString ('\t' :: acc) rest
  | '\\' :: _ => .error .notJsonObject
  | c :: rest =>
    if c.toNat < 32 then .error .notJsonObject
    else lexString (c :: acc) rest

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

theorem hexVal_hexDigit (n : Nat) (h : n < 16) : hexVal (hexDigit n) = some n := by
  match n, h with
  | 0, _ => rfl
  | 1, _ => rfl
  | 2, _ => rfl
  | 3, _ => rfl
  | 4, _ => rfl
  | 5, _ => rfl
  | 6, _ => rfl
  | 7, _ => rfl
  | 8, _ => rfl
  | 9, _ => rfl
  | 10, _ => rfl
  | 11, _ => rfl
  | 12, _ => rfl
  | 13, _ => rfl
  | 14, _ => rfl
  | 15, _ => rfl
  | _ + 16, h => omega

theorem bool_cond_of_lt32 (n : Nat) (h : n < 32) :
    (decide (n < 1114112) && !(decide (55296 ≤ n) && decide (n < 57344))) = true := by
  have h1 : n < 1114112 := by omega
  have h2 : ¬ (55296 ≤ n) := by omega
  rw [decide_eq_true h1, decide_eq_false h2]
  rfl

theorem lexString_quote (acc rest : List Char) :
    lexString acc ('\\' :: '"' :: rest) = lexString ('"' :: acc) rest := by
  rfl

theorem lexString_slash (acc rest : List Char) :
    lexString acc ('\\' :: '\\' :: rest) = lexString ('\\' :: acc) rest := by
  rfl

theorem lexString_u00 (c : Char) (h_lt : c.toNat < 32) (acc rest : List Char) :
    lexString acc ('\\' :: 'u' :: '0' :: '0' :: hexDigit (c.toNat / 16) :: hexDigit (c.toNat % 16) :: rest) =
      lexString (c :: acc) rest := by
  change (match hexVal '0', hexVal '0', hexVal (hexDigit (c.toNat / 16)), hexVal (hexDigit (c.toNat % 16)) with
    | some v1, some v2, some v3, some v4 =>
      let val := ((v1 * 16 + v2) * 16 + v3) * 16 + v4
      if val < 0x110000 && !(0xd800 ≤ val && val < 0xe000) then
        lexString (Char.ofNat val :: acc) rest
      else .error .notJsonObject
    | _, _, _, _ => .error .notJsonObject) = lexString (c :: acc) rest
  have h1 : hexVal '0' = some 0 := rfl
  have h3 : hexVal (hexDigit (c.toNat / 16)) = some (c.toNat / 16) := by
    apply hexVal_hexDigit; omega
  have h4 : hexVal (hexDigit (c.toNat % 16)) = some (c.toNat % 16) := by
    apply hexVal_hexDigit; omega
  rw [h1, h3, h4]
  dsimp
  have h_val : ((0 * 16 + 0) * 16 + c.toNat / 16) * 16 + c.toNat % 16 = c.toNat := by
    omega
  rw [h_val]
  have hb := bool_cond_of_lt32 c.toNat h_lt
  rw [hb]
  dsimp
  rw [Char.ofNat_toNat]

set_option linter.style.multiGoal false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

theorem lexString_normal (c : Char) (h_q : c ≠ '"') (h_s : c ≠ '\\') (h_ge : ¬ (c.toNat < 32))
    (acc rest : List Char) :
    lexString acc (c :: rest) = lexString (c :: acc) rest := by
  rw [lexString]
  split
  · contradiction
  · rfl
  all_goals
    try (intro h; subst h; contradiction)
    try (intro _ _ _ _ _ h _; subst h; contradiction)
    try (intro _ h _; subst h; contradiction)
    try (intro _ h; subst h; contradiction)
    try contradiction

theorem lexString_char (c : Char) (acc rest : List Char) :
    lexString acc (escapeChar c ++ rest) = lexString (c :: acc) rest := by
  dsimp [escapeChar]
  split
  · rename_i hc
    subst hc
    exact lexString_quote acc rest
  · split
    · rename_i _ hc
      subst hc
      exact lexString_slash acc rest
    · split
      · rename_i _ _ h_lt
        exact lexString_u00 c h_lt acc rest
      · rename_i h_not_q h_not_s h_not_lt
        exact lexString_normal c h_not_q h_not_s h_not_lt acc rest

theorem lexString_escapeChars (cs : List Char) (acc rest : List Char) :
    lexString acc (escapeChars cs ++ ('"' :: rest)) = .ok (String.ofList (acc.reverse ++ cs), rest) := by
  induction cs generalizing acc with
  | nil =>
    simp only [escapeChars, List.nil_append, List.append_nil]
    rfl
  | cons c cs ih =>
    simp only [escapeChars, List.append_assoc]
    rw [lexString_char]
    have h := ih (c :: acc)
    simp only [List.reverse_cons, List.append_assoc, List.singleton_append] at h
    exact h

/-- General string lexing inversion theorem: for any string s, lexing its canonical escaped form returns s. -/
theorem lexString_escapeJsonString (s : String) (rest : List Char) :
    lexString [] (escapeChars s.toList ++ ('"' :: rest)) = .ok (s, rest) := by
  have h := lexString_escapeChars s.toList [] rest
  simp only [List.reverse_nil, List.nil_append] at h
  rw [String.ofList_toList] at h
  exact h

/-- UTF-8 byte serialization inverse: decoding the UTF-8 bytes of any string returns the string. -/
theorem string_fromUTF8?_toUTF8 (s : String) : String.fromUTF8? s.toUTF8 = some s := by
  dsimp [String.fromUTF8?, String.toUTF8]
  have h : s.toByteArray.IsValidUTF8 := s.isValidUTF8
  rw [dif_pos h]
  rfl

/-- Generic string tokenization theorem: tokenizing an escaped string literal produces a string token. -/
theorem tokenizeFuel_string (fuel : Nat) (str : String) (rest : List Char) :
    tokenizeFuel (fuel + 1) ('"' :: (escapeChars str.toList ++ ('"' :: rest))) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.str str :: toks)) := by
  change (do
      let (s, rest') ← lexString [] (escapeChars str.toList ++ ('"' :: rest))
      let toks ← tokenizeFuel fuel rest'
      .ok (JsonToken.str s :: toks)) = (do
      let toks ← tokenizeFuel fuel rest
      .ok (JsonToken.str str :: toks))
  have h_lex := lexString_escapeJsonString str rest
  rw [h_lex]
  rfl

/-- Pushdown parser base token inversion: string token decodes to Json.str. -/
theorem parseTokens_str (s : String) : parseTokens [JsonToken.str s] = .ok (Lean.Json.str s) := rfl

/-- Pushdown parser base token inversion: num token decodes to Json.num. -/
theorem parseTokens_num (n : Lean.JsonNumber) : parseTokens [JsonToken.num n] = .ok (Lean.Json.num n) := rfl

/-- Pushdown parser base token inversion: bool token decodes to Json.bool. -/
theorem parseTokens_bool (b : Bool) : parseTokens [JsonToken.bool b] = .ok (Lean.Json.bool b) := rfl

/-- Pushdown parser base token inversion: null token decodes to Json.null. -/
theorem parseTokens_null : parseTokens [JsonToken.null] = .ok Lean.Json.null := rfl

/-- Pushdown parser empty array inversion. -/
theorem parseTokens_empty_arr : parseTokens [JsonToken.lbracket, JsonToken.rbracket] = .ok (Lean.Json.arr #[]) := rfl

/-- Pushdown parser empty object inversion. -/
theorem parseTokens_empty_obj : parseTokens [JsonToken.lbrace, JsonToken.rbrace] = .ok (Lean.Json.mkObj []) := rfl

/-- Direct canonical parsing on true literal. -/
theorem parseCanonicalJson_true : parseCanonicalJson "true" = .ok (Lean.Json.bool true) := rfl

/-- Direct canonical parsing on false literal. -/
theorem parseCanonicalJson_false : parseCanonicalJson "false" = .ok (Lean.Json.bool false) := rfl

/-- Direct canonical parsing on null literal. -/
theorem parseCanonicalJson_null : parseCanonicalJson "null" = .ok Lean.Json.null := rfl

/-- Direct canonical parsing on empty array literal. -/
theorem parseCanonicalJson_empty_arr : parseCanonicalJson "[]" = .ok (Lean.Json.arr #[]) := rfl

/-- Direct canonical parsing on empty object literal. -/
theorem parseCanonicalJson_empty_obj : parseCanonicalJson "{}" = .ok (Lean.Json.mkObj []) := rfl

/-- Empty string fuel step helper. -/
theorem tokenizeFuel_empty (fuel : Nat) : tokenizeFuel (fuel + 1) [] = .ok [] := rfl

/-- Pushdown parser step equivalence on null token. -/
theorem parseStep_null (st : ParserState) : parseStep st .null = feedValue st .null := rfl

/-- Pushdown parser step equivalence on bool token. -/
theorem parseStep_bool (st : ParserState) (b : Bool) : parseStep st (.bool b) = feedValue st (.bool b) := rfl

/-- Pushdown parser step equivalence on num token. -/
theorem parseStep_num (st : ParserState) (n : Lean.JsonNumber) : parseStep st (.num n) = feedValue st (.num n) := rfl

/-- Pushdown parser step on string token in empty stack state. -/
theorem parseStep_str_empty (s : String) :
    parseStep { stack := [], result := none } (.str s) = feedValue { stack := [], result := none } (.str s) := rfl

/-- Pushdown parser step on string token when expecting a value in an object. -/
theorem parseStep_str_expectVal (acc : List (String × Lean.Json)) (key s : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } (.str s) =
    feedValue { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } (.str s) := rfl

/-- Pushdown parser step on string token in initial array state. -/
theorem parseStep_str_arr_empty (acc : Array Lean.Json) (s : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } (.str s) =
    feedValue { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } (.str s) := rfl

/-- Pushdown parser step on string token when expecting array element. -/
theorem parseStep_str_arr_val (acc : Array Lean.Json) (s : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } (.str s) =
    feedValue { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } (.str s) := rfl

/-- Pushdown parser feeding value into object frame expecting value. -/
theorem feedValue_obj_expectVal (acc : List (String × Lean.Json)) (key : String) (v : Lean.Json) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    feedValue { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } v =
    .ok { stack := StackFrame.obj ((key, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [feedValue]
  split
  · rename_i h
    rw [h_not_dup] at h
    contradiction
  · rfl

/-- Pushdown parser feeding value into array frame expecting value. -/
theorem feedValue_arr_expectVal (acc : Array Lean.Json) (v : Lean.Json) (rest : List StackFrame)
    (h_len : ¬ (acc.size ≥ 4096)) :
    feedValue { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } v =
    .ok { stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  dsimp [feedValue]
  split
  · rename_i h; contradiction
  · rfl

/-- Pushdown parser feeding value into initial array frame. -/
theorem feedValue_arr_emptyOrVal (acc : Array Lean.Json) (v : Lean.Json) (rest : List StackFrame)
    (h_len : ¬ (acc.size ≥ 4096)) :
    feedValue { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } v =
    .ok { stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  dsimp [feedValue]
  split
  · rename_i h; contradiction
  · rfl

/-- Pushdown parser step opening object on empty stack. -/
theorem parseStep_lbrace_empty :
    parseStep { stack := [], result := none } .lbrace =
    .ok { stack := [StackFrame.obj [] ObjState.emptyOrKey], result := none } := rfl

/-- Pushdown parser step opening array on empty stack. -/
theorem parseStep_lbracket_empty :
    parseStep { stack := [], result := none } .lbracket =
    .ok { stack := [StackFrame.arr #[] ArrState.emptyOrVal], result := none } := rfl

/-- Pushdown parser step opening nested object when expecting object value. -/
theorem parseStep_lbrace_expectVal (acc : List (String × Lean.Json)) (key : String) (rest : List StackFrame)
    (h_depth : rest.length + 2 ≤ 64) :
    parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } .lbrace =
    .ok { stack := StackFrame.obj [] ObjState.emptyOrKey :: StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } := by
  dsimp [parseStep]
  split
  · rename_i h
    have : rest.length + 1 < 64 := by omega
    omega
  · rfl

/-- Pushdown parser step transitioning key in initial object state. -/
theorem parseStep_str_emptyOrKey (acc : List (String × Lean.Json)) (s : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc ObjState.emptyOrKey :: rest, result := none } (.str s) =
    .ok { stack := StackFrame.obj acc (ObjState.expectColon s) :: rest, result := none } := rfl

/-- Pushdown parser step transitioning key in subsequent object state. -/
theorem parseStep_str_expectKey (acc : List (String × Lean.Json)) (s : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc ObjState.expectKey :: rest, result := none } (.str s) =
    .ok { stack := StackFrame.obj acc (ObjState.expectColon s) :: rest, result := none } := rfl

/-- Pushdown parser step transitioning on colon in object state. -/
theorem parseStep_colon (acc : List (String × Lean.Json)) (k : String) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc (ObjState.expectColon k) :: rest, result := none } .colon =
    .ok { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } := rfl

/-- Pushdown parser step transitioning on comma in object state. -/
theorem parseStep_comma_obj (acc : List (String × Lean.Json)) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc ObjState.expectCommaOrRbrace :: rest, result := none } .comma =
    .ok { stack := StackFrame.obj acc ObjState.expectKey :: rest, result := none } := rfl

/-- Pushdown parser step transitioning on comma in array state. -/
theorem parseStep_comma_arr (acc : Array Lean.Json) (rest : List StackFrame) :
    parseStep { stack := StackFrame.arr acc ArrState.expectCommaOrRbracket :: rest, result := none } .comma =
    .ok { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } := rfl

/-- Pushdown parser feeding one element into an array frame followed by comma. -/
theorem parse_arr_feed_elem (toks : List JsonToken) (acc : Array Lean.Json) (rest : List StackFrame)
    (v : Lean.Json)
    (h_feed : toks.foldlM parseStep { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } =
              .ok { stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest, result := none }) :
    (toks ++ [JsonToken.comma]).foldlM parseStep { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } =
    .ok { stack := StackFrame.arr (acc.push v) ArrState.expectVal :: rest, result := none } := by
  rw [List.foldlM_append]
  dsimp [bind, Except.bind]
  rw [h_feed]
  rfl

/-- Pushdown parser transition for key and colon in object frame. -/
theorem parse_obj_field_step (k : String) (v_toks : List JsonToken) (v : Lean.Json)
    (acc : List (String × Lean.Json)) (rest : List StackFrame)
    (_h_not_dup : acc.any (fun (k', _) => k' == k) = false)
    (h_val : v_toks.foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } =
             .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none }) :
    (JsonToken.str k :: JsonToken.colon :: v_toks).foldlM parseStep { stack := StackFrame.obj acc ObjState.expectKey :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  have h_split : (JsonToken.str k :: JsonToken.colon :: v_toks) = [JsonToken.str k, JsonToken.colon] ++ v_toks := rfl
  rw [h_split, List.foldlM_append]
  dsimp [bind, Except.bind, parseStep]
  exact h_val

/-- Pushdown parser transition for key, colon, value and trailing comma in object frame. -/
theorem parse_obj_field_comma (k : String) (v_toks : List JsonToken) (v : Lean.Json)
    (acc : List (String × Lean.Json)) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k', _) => k' == k) = false)
    (h_val : v_toks.foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } =
             .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none }) :
    ((JsonToken.str k :: JsonToken.colon :: v_toks) ++ [JsonToken.comma]).foldlM parseStep { stack := StackFrame.obj acc ObjState.expectKey :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectKey :: rest, result := none } := by
  rw [List.foldlM_append]
  have h_step := parse_obj_field_step k v_toks v acc rest h_not_dup h_val
  rw [h_step]
  rfl

/-- Pushdown parser closing object on rbrace. -/
theorem parse_obj_rbrace (acc : List (String × Lean.Json)) (rest : List StackFrame) :
    parseStep { stack := StackFrame.obj acc ObjState.expectCommaOrRbrace :: rest, result := none } .rbrace =
    feedValue { stack := rest, result := none } (Lean.Json.mkObj acc.reverse) := rfl

/-- Pushdown parser closing array on rbracket. -/
theorem parse_arr_rbracket (acc : Array Lean.Json) (rest : List StackFrame) :
    parseStep { stack := StackFrame.arr acc ArrState.expectCommaOrRbracket :: rest, result := none } .rbracket =
    feedValue { stack := rest, result := none } (Lean.Json.arr acc) := rfl

/-- Top-level parseTokens reduction from successful foldlM. -/
theorem parseTokens_of_foldlM (toks : List JsonToken) (j : Lean.Json)
    (h : toks.foldlM parseStep { stack := [], result := none } = .ok { stack := [], result := some j }) :
    parseTokens toks = .ok j := by
  dsimp [parseTokens]
  rw [h]
  rfl

/-- Modular parsing equivalence combining tokenizer and pushdown parser. -/
theorem parseCanonicalJson_of_tokenize_parseTokens (s : String) (toks : List JsonToken) (j : Lean.Json)
    (h_tok : tokenize s = .ok toks)
    (h_parse : parseTokens toks = .ok j) :
    parseCanonicalJson s = .ok j := by
  dsimp [parseCanonicalJson]
  rw [h_tok]
  dsimp [bind, Except.bind]
  exact h_parse

/-- Tokenizer step on lbrace delimiter. -/
theorem tokenizeFuel_lbrace (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) ('{' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.lbrace :: toks)) := rfl

/-- Tokenizer step on rbrace delimiter. -/
theorem tokenizeFuel_rbrace (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) ('}' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.rbrace :: toks)) := rfl

/-- Tokenizer step on colon delimiter. -/
theorem tokenizeFuel_colon (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) (':' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.colon :: toks)) := rfl

/-- Tokenizer step on comma delimiter. -/
theorem tokenizeFuel_comma (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) (',' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.comma :: toks)) := rfl

/-- Tokenizer step on lbracket delimiter. -/
theorem tokenizeFuel_lbracket (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) ('[' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.lbracket :: toks)) := rfl

/-- Tokenizer step on rbracket delimiter. -/
theorem tokenizeFuel_rbracket (fuel : Nat) (rest : List Char) :
    tokenizeFuel (fuel + 1) (']' :: rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.rbracket :: toks)) := rfl

/-- Character step equation for lexDigits. -/
theorem lexDigits_step_eq (c : Char) (acc : Nat) (rest : List Char) :
    lexDigits acc (c :: rest) =
      if c.isDigit then lexDigits (acc * 10 + (c.toNat - '0'.toNat)) rest
      else (acc, c :: rest) := rfl

/-- General digits parsing induction: lexDigits on any all-digit list reconstructs ofDigitChars. -/
theorem lexDigits_of_all_digits (l : List Char) (hl : ∀ c ∈ l, c.isDigit = true)
    (acc : Nat) (rest : List Char) (h_end : match rest with | [] => True | c :: _ => c.isDigit = false) :
    lexDigits acc (l ++ rest) = (Nat.ofDigitChars 10 l acc, rest) := by
  induction l generalizing acc with
  | nil =>
    simp only [List.nil_append, Nat.ofDigitChars_nil]
    cases rest with
    | nil => rfl
    | cons c cs =>
      rw [lexDigits_step_eq]
      dsimp at h_end
      rw [h_end]
      rfl
  | cons c cs ih =>
    simp only [List.cons_append, Nat.ofDigitChars_cons]
    have hc := hl c (by simp)
    have hcs : ∀ c' ∈ cs, c'.isDigit = true := fun c' hc' => hl c' (by simp [hc'])
    rw [lexDigits_step_eq]
    rw [hc]
    dsimp
    have h_comm : acc * 10 = 10 * acc := Nat.mul_comm _ _
    rw [h_comm]
    exact ih hcs (10 * acc + (c.toNat - '0'.toNat))

/-- Head/tail decomposition for lexDigits on decimal representation of natural numbers. -/
theorem lexDigits_head_tl (c : Char) (tl : List Char) (n : Nat)
    (h_eq : Nat.toDigits 10 n = c :: tl) (rest : List Char)
    (h_end : match rest with | [] => True | c :: _ => c.isDigit = false) :
    c.isDigit = true ∧
    lexDigits (c.toNat - '0'.toNat) (tl ++ rest) = (n, rest) := by
  have hl : ∀ x ∈ Nat.toDigits 10 n, x.isDigit = true := by
    intro x hx
    exact Nat.isDigit_of_mem_toDigits (by decide) (by decide) hx
  have hc : c.isDigit = true := by
    have : c ∈ Nat.toDigits 10 n := by simp [h_eq]
    exact hl c this
  have htl : ∀ x ∈ tl, x.isDigit = true := by
    intro x hx
    have : x ∈ Nat.toDigits 10 n := by simp [h_eq, hx]
    exact hl x this
  refine ⟨hc, ?_⟩
  rw [lexDigits_of_all_digits tl htl (c.toNat - '0'.toNat) rest h_end]
  have h_cons : Nat.ofDigitChars 10 (c :: tl) 0 = Nat.ofDigitChars 10 tl (10 * 0 + (c.toNat - '0'.toNat)) := rfl
  simp only [Nat.mul_zero, Nat.zero_add] at h_cons
  rw [← h_cons, ← h_eq]
  rw [Nat.ofDigitChars_ten_toDigits]

/-- Nonemptiness of natural decimal digit representation. -/
theorem toDigits_nonempty (n : Nat) : ∃ c tl, Nat.toDigits 10 n = c :: tl := by
  cases h : Nat.toDigits 10 n with
  | nil =>
    have h_len : 0 < (Nat.toDigits 10 n).length := Nat.length_toDigits_pos
    rw [h] at h_len
    contradiction
  | cons c tl =>
    exact ⟨c, tl, rfl⟩

/-- Fuel-bounded tokenizer transition on initial digit character. -/
theorem tokenizeFuel_digit_step (fuel : Nat) (c : Char) (tl : List Char) (rest : List Char)
    (hc : c.isDigit = true)
    (n : Nat)
    (h_lex : lexDigits (c.toNat - '0'.toNat) (tl ++ rest) = (n, rest)) :
    tokenizeFuel (fuel + 1) (c :: (tl ++ rest)) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.num ⟨(n : Int), 0⟩ :: toks)) := by
  rw [tokenizeFuel]
  split
  · rw [h_lex]
  · rename_i h_not
    have hc_cond : (decide (c ≥ '0') && decide (c ≤ '9')) = true := hc
    contradiction
  all_goals
    try (intro h1; subst h1; revert hc; decide)
    try (intro _ h1 _; subst h1; revert hc; decide)
    try (intro _ h1; subst h1; revert hc; decide)
    try (intro _ _ h1 _; subst h1; revert hc; decide)

/-- General decimal tokenization for arbitrary natural numbers followed by non-digit delimiter. -/
theorem tokenizeFuel_nat (fuel : Nat) (n : Nat) (rest : List Char)
    (h_end : match rest with | [] => True | c :: _ => c.isDigit = false) :
    tokenizeFuel (fuel + 1) ((toString n).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.num ⟨(n : Int), 0⟩ :: toks)) := by
  have h_repr : (toString n).toList = Nat.toDigits 10 n := by
    change (Nat.repr n).toList = Nat.toDigits 10 n
    exact Nat.toList_repr
  rw [h_repr]
  rcases toDigits_nonempty n with ⟨c, tl, h_digits⟩
  rw [h_digits]
  have ⟨hc, h_lex⟩ := lexDigits_head_tl c tl n h_digits rest h_end
  simp only [List.cons_append]
  exact tokenizeFuel_digit_step fuel c tl rest hc n h_lex

/-- General decimal tokenization for arbitrary integers (positive, zero, or negative). -/
theorem tokenizeFuel_int (fuel : Nat) (i : Int) (rest : List Char)
    (h_end : match rest with | [] => True | c :: _ => c.isDigit = false) :
    tokenizeFuel (fuel + 1) ((toString i).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.num ⟨i, 0⟩ :: toks)) := by
  cases i with
  | ofNat n =>
    exact tokenizeFuel_nat fuel n rest h_end
  | negSucc n =>
    have h_repr : (toString (Int.negSucc n)).toList = '-' :: (Nat.repr (n + 1)).toList := by
      change ("-" ++ Nat.repr (n + 1)).toList = '-' :: (Nat.repr (n + 1)).toList
      rw [String.toList_append]
      rfl
    rw [h_repr]
    have h_nat_repr : (Nat.repr (n + 1)).toList = Nat.toDigits 10 (n + 1) := Nat.toList_repr
    rw [h_nat_repr]
    rcases toDigits_nonempty (n + 1) with ⟨c, tl, h_digits⟩
    rw [h_digits]
    have ⟨hc, h_lex⟩ := lexDigits_head_tl c tl (n + 1) h_digits rest h_end
    simp only [List.cons_append]
    rw [tokenizeFuel]
    have hc_cond : (decide (c ≥ '0') && decide (c ≤ '9')) = true := hc
    rw [hc_cond]
    dsimp
    have h_lex' : lexDigits (c.toNat - 48) (tl ++ rest) = (n + 1, rest) := h_lex
    rw [h_lex']
    have : (-↑(n + 1) : Int) = Int.negSucc n := rfl
    rw [this]

/-- Generic pushdown parser step inverse on canonical rational token sequence. -/
theorem parseTokens_rat (r : RatEnc) :
    parseTokens [
      JsonToken.lbrace,
      JsonToken.str "num", JsonToken.colon, JsonToken.num ⟨r.num, 0⟩,
      JsonToken.comma,
      JsonToken.str "den", JsonToken.colon, JsonToken.num ⟨(r.den : Int), 0⟩,
      JsonToken.rbrace
    ] = .ok (Lean.Json.mkObj [("num", Lean.Json.num r.num), ("den", Lean.Json.num (r.den : Int))]) := rfl

/-- Pushdown parser transition for first key and colon in empty/initial object frame. -/
theorem parse_obj_first_field_step (k : String) (v_toks : List JsonToken) (v : Lean.Json)
    (acc : List (String × Lean.Json)) (rest : List StackFrame)
    (h_val : v_toks.foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } =
             .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none }) :
    (JsonToken.str k :: JsonToken.colon :: v_toks).foldlM parseStep { stack := StackFrame.obj acc ObjState.emptyOrKey :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  have h_split : (JsonToken.str k :: JsonToken.colon :: v_toks) = [JsonToken.str k, JsonToken.colon] ++ v_toks := rfl
  rw [h_split, List.foldlM_append]
  dsimp [bind, Except.bind, parseStep]
  exact h_val

/-- Pushdown parser transition for first key, colon, value and trailing comma in empty/initial object frame. -/
theorem parse_obj_first_field_comma (k : String) (v_toks : List JsonToken) (v : Lean.Json)
    (acc : List (String × Lean.Json)) (rest : List StackFrame)
    (h_val : v_toks.foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } =
             .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none }) :
    ((JsonToken.str k :: JsonToken.colon :: v_toks) ++ [JsonToken.comma]).foldlM parseStep { stack := StackFrame.obj acc ObjState.emptyOrKey :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, v) :: acc) ObjState.expectKey :: rest, result := none } := by
  rw [List.foldlM_append]
  have h_step := parse_obj_first_field_step k v_toks v acc rest h_val
  rw [h_step]
  rfl

/-- Feeding scalar string property into object frame expecting value. -/
theorem parse_field_str_val (acc : List (String × Lean.Json)) (key s : String) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    [JsonToken.str s].foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } =
    .ok { stack := StackFrame.obj ((key, Lean.Json.str s) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [List.foldlM, parseStep, bind, Except.bind]
  rw [feedValue_obj_expectVal acc key (.str s) rest h_not_dup]
  rfl

/-- Feeding scalar number property into object frame expecting value. -/
theorem parse_field_num_val (acc : List (String × Lean.Json)) (key : String) (n : Lean.JsonNumber) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    [JsonToken.num n].foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } =
    .ok { stack := StackFrame.obj ((key, Lean.Json.num n) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [List.foldlM, parseStep, bind, Except.bind]
  rw [feedValue_obj_expectVal acc key (.num n) rest h_not_dup]
  rfl

/-- Feeding scalar boolean property into object frame expecting value. -/
theorem parse_field_bool_val (acc : List (String × Lean.Json)) (key : String) (b : Bool) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    [JsonToken.bool b].foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } =
    .ok { stack := StackFrame.obj ((key, Lean.Json.bool b) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [List.foldlM, parseStep, bind, Except.bind]
  rw [feedValue_obj_expectVal acc key (.bool b) rest h_not_dup]
  rfl

/-- Feeding null property into object frame expecting value. -/
theorem parse_field_null_val (acc : List (String × Lean.Json)) (key : String) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    [JsonToken.null].foldlM parseStep { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } =
    .ok { stack := StackFrame.obj ((key, Lean.Json.null) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [List.foldlM, parseStep, bind, Except.bind]
  rw [feedValue_obj_expectVal acc key .null rest h_not_dup]
  rfl

/-- Canonical JSON tree representation for recursive parser and serializer inversion. -/
inductive TreeJson where
  | null
  | bool (b : Bool)
  | num (n : Int)
  | str (s : String)
  | arr (elements : List TreeJson)
  | obj (fields : List (String × TreeJson))
  deriving Repr, Inhabited

mutual
  /-- Semantic JSON mapping for TreeJson values. -/
  def TreeJson.toJson : TreeJson → Lean.Json
    | .null => Lean.Json.null
    | .bool b => Lean.Json.bool b
    | .num n => Lean.Json.num ⟨n, 0⟩
    | .str s => Lean.Json.str s
    | .arr xs => Lean.Json.arr (TreeJson.toJsonList xs).toArray
    | .obj kvs => Lean.Json.mkObj (TreeJson.toJsonObj kvs)

  /-- Semantic JSON element mapping for list of TreeJson values. -/
  def TreeJson.toJsonList : List TreeJson → List Lean.Json
    | [] => []
    | x :: xs => TreeJson.toJson x :: TreeJson.toJsonList xs

  /-- Semantic JSON field mapping for object key-value pairs. -/
  def TreeJson.toJsonObj : List (String × TreeJson) → List (String × Lean.Json)
    | [] => []
    | (k, v) :: kvs => (k, TreeJson.toJson v) :: TreeJson.toJsonObj kvs
end

mutual
  /-- Canonical token sequence produced by TreeJson. -/
  def TreeJson.tokens : TreeJson → List JsonToken
    | .null => [JsonToken.null]
    | .bool b => [JsonToken.bool b]
    | .num n => [JsonToken.num ⟨n, 0⟩]
    | .str s => [JsonToken.str s]
    | .arr xs => [JsonToken.lbracket] ++ TreeJson.tokensList xs ++ [JsonToken.rbracket]
    | .obj kvs => [JsonToken.lbrace] ++ TreeJson.tokensObj kvs ++ [JsonToken.rbrace]

  /-- Token sequence for elements of an array. -/
  def TreeJson.tokensList : List TreeJson → List JsonToken
    | [] => []
    | [x] => TreeJson.tokens x
    | x :: xs => TreeJson.tokens x ++ [JsonToken.comma] ++ TreeJson.tokensList xs

  /-- Token sequence for fields of an object. -/
  def TreeJson.tokensObj : List (String × TreeJson) → List JsonToken
    | [] => []
    | [(k, v)] => [JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v
    | (k, v) :: kvs => [JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v ++ [JsonToken.comma] ++ TreeJson.tokensObj kvs
end

/-- Helper to format an escaped JSON string. -/
def escapeTreeString (s : String) : String :=
  String.ofList ('"' :: (escapeChars s.toList ++ ['"']))

mutual
  /-- Canonical string encoding of TreeJson. -/
  def TreeJson.encode : TreeJson → String
    | .null => "null"
    | .bool true => "true"
    | .bool false => "false"
    | .num n => toString n
    | .str s => escapeTreeString s
    | .arr xs => "[" ++ TreeJson.encodeList xs ++ "]"
    | .obj kvs => "{" ++ TreeJson.encodeObj kvs ++ "}"

  /-- Canonical string encoding for array elements. -/
  def TreeJson.encodeList : List TreeJson → String
    | [] => ""
    | [x] => TreeJson.encode x
    | x :: xs => TreeJson.encode x ++ "," ++ TreeJson.encodeList xs

  /-- Canonical string encoding for object fields. -/
  def TreeJson.encodeObj : List (String × TreeJson) → String
    | [] => ""
    | [(k, v)] => escapeTreeString k ++ ":" ++ TreeJson.encode v
    | (k, v) :: kvs => escapeTreeString k ++ ":" ++ TreeJson.encode v ++ "," ++ TreeJson.encodeObj kvs
end

/-- Pushdown parser foldlM equivalence on null tree value. -/
theorem parseStep_foldlM_tokens_null (st : ParserState) :
    (TreeJson.tokens .null).foldlM parseStep st = feedValue st .null := by
  dsimp [TreeJson.tokens, List.foldlM, parseStep, bind, Except.bind]
  cases feedValue st .null <;> rfl

/-- Pushdown parser foldlM equivalence on boolean tree value. -/
theorem parseStep_foldlM_tokens_bool (st : ParserState) (b : Bool) :
    (TreeJson.tokens (.bool b)).foldlM parseStep st = feedValue st (.bool b) := by
  dsimp [TreeJson.tokens, List.foldlM, parseStep, bind, Except.bind]
  cases feedValue st (.bool b) <;> rfl

/-- Pushdown parser foldlM equivalence on number tree value. -/
theorem parseStep_foldlM_tokens_num (st : ParserState) (n : Int) :
    (TreeJson.tokens (.num n)).foldlM parseStep st = feedValue st (.num ⟨n, 0⟩) := by
  dsimp [TreeJson.tokens, List.foldlM, parseStep, bind, Except.bind]
  cases feedValue st (.num ⟨n, 0⟩) <;> rfl

/-- Pushdown parser step equivalence on empty array token list. -/
theorem parseTokensList_nil (acc : Array Lean.Json) (rest : List StackFrame) :
    (TreeJson.tokensList []).foldlM parseStep { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } =
    .ok { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } := rfl

/-- Pushdown parser step equivalence on empty object token list. -/
theorem parseTokensObj_nil (acc : List (String × Lean.Json)) (rest : List StackFrame) :
    (TreeJson.tokensObj []).foldlM parseStep { stack := StackFrame.obj acc ObjState.emptyOrKey :: rest, result := none } =
    .ok { stack := StackFrame.obj acc ObjState.emptyOrKey :: rest, result := none } := rfl

/-- Top-level pushdown parser foldlM inversion on empty TreeJson object. -/
theorem parseTokens_empty_tree_obj (st : ParserState) (h_stack : st.stack = []) (h_res : st.result = none) :
    (TreeJson.tokens (.obj [])).foldlM parseStep st = feedValue st (Lean.Json.mkObj []) := by
  cases st with | mk stack res =>
  dsimp at h_stack h_res
  subst h_stack h_res
  dsimp [TreeJson.tokens, TreeJson.tokensObj, List.foldlM, parseStep, bind, Except.bind]
  cases feedValue { stack := [], result := none } (Lean.Json.mkObj []) <;> rfl

/-- Top-level pushdown parser foldlM inversion on empty TreeJson array. -/
theorem parseTokens_empty_tree_arr (st : ParserState) (h_stack : st.stack = []) (h_res : st.result = none) :
    (TreeJson.tokens (.arr [])).foldlM parseStep st = feedValue st (Lean.Json.arr #[]) := by
  cases st with | mk stack res =>
  dsimp at h_stack h_res
  subst h_stack h_res
  dsimp [TreeJson.tokens, TreeJson.tokensList, List.foldlM, parseStep, bind, Except.bind]
  cases feedValue { stack := [], result := none } (Lean.Json.arr #[]) <;> rfl

/-- Top-level parseTokens inversion on TreeJson.null. -/
theorem parseTokens_tree_null : parseTokens (TreeJson.tokens .null) = .ok Lean.Json.null := rfl

/-- Top-level parseTokens inversion on TreeJson.bool. -/
theorem parseTokens_tree_bool (b : Bool) : parseTokens (TreeJson.tokens (.bool b)) = .ok (Lean.Json.bool b) := rfl

/-- Top-level parseTokens inversion on TreeJson.num. -/
theorem parseTokens_tree_num (n : Int) : parseTokens (TreeJson.tokens (.num n)) = .ok (Lean.Json.num ⟨n, 0⟩) := rfl

/-- Top-level parseTokens inversion on TreeJson.str. -/
theorem parseTokens_tree_str (s : String) : parseTokens (TreeJson.tokens (.str s)) = .ok (Lean.Json.str s) := rfl

/-- Top-level parseTokens inversion on empty TreeJson.arr. -/
theorem parseTokens_tree_empty_arr : parseTokens (TreeJson.tokens (.arr [])) = .ok (Lean.Json.arr #[]) := rfl

/-- Top-level parseTokens inversion on empty TreeJson.obj. -/
theorem parseTokens_tree_empty_obj : parseTokens (TreeJson.tokens (.obj [])) = .ok (Lean.Json.mkObj []) := rfl

/-- Predicate characterizing parser states that are structurally ready to receive an evaluated value. -/
def IsValueContext (st : ParserState) : Prop :=
  st.result = none ∧
  match st.stack with
  | [] => True
  | StackFrame.arr _ ArrState.emptyOrVal :: _ => True
  | StackFrame.arr _ ArrState.expectVal :: _ => True
  | StackFrame.obj _ (ObjState.expectVal _) :: _ => True
  | _ => False

mutual
  /-- Syntactic container nesting depth of a TreeJson document. -/
  def TreeJson.depth : TreeJson → Nat
    | .null | .bool _ | .num _ | .str _ => 0
    | .arr xs => 1 + TreeJson.depthList xs
    | .obj kvs => 1 + TreeJson.depthObj kvs

  /-- Maximal syntactic nesting depth across a list of array elements. -/
  def TreeJson.depthList : List TreeJson → Nat
    | [] => 0
    | x :: xs => max (TreeJson.depth x) (TreeJson.depthList xs)

  /-- Maximal syntactic nesting depth across key-value fields of an object. -/
  def TreeJson.depthObj : List (String × TreeJson) → Nat
    | [] => 0
    | (_, v) :: kvs => max (TreeJson.depth v) (TreeJson.depthObj kvs)
end

mutual
  /-- Structural node size measure for well-founded tree induction. -/
  def TreeJson.size : TreeJson → Nat
    | .null | .bool _ | .num _ | .str _ => 1
    | .arr xs => 1 + TreeJson.sizeList xs
    | .obj kvs => 1 + TreeJson.sizeObj kvs

  /-- Structural node size across an array element list. -/
  def TreeJson.sizeList : List TreeJson → Nat
    | [] => 0
    | x :: xs => TreeJson.size x + TreeJson.sizeList xs

  /-- Structural node size across an object field list. -/
  def TreeJson.sizeObj : List (String × TreeJson) → Nat
    | [] => 0
    | (_, v) :: kvs => TreeJson.size v + TreeJson.sizeObj kvs
end

mutual
  /-- Proof-level structural admissibility for canonical JSON trees:
      arrays obey the 4096-element budget and objects have pairwise distinct keys. -/
  def TreeJson.Valid : TreeJson → Prop
    | .null | .bool _ | .num _ | .str _ => True
    | .arr xs => xs.length ≤ 4096 ∧ TreeJson.ValidList xs
    | .obj kvs => (kvs.map Prod.fst).Nodup ∧ TreeJson.ValidObj kvs

  /-- Structural admissibility across array element lists. -/
  def TreeJson.ValidList : List TreeJson → Prop
    | [] => True
    | x :: xs => TreeJson.Valid x ∧ TreeJson.ValidList xs

  /-- Structural admissibility across object field lists. -/
  def TreeJson.ValidObj : List (String × TreeJson) → Prop
    | [] => True
    | (_, v) :: kvs => TreeJson.Valid v ∧ TreeJson.ValidObj kvs
end

/-- Positive size lower bound for all TreeJson nodes. -/
theorem TreeJson.size_pos (t : TreeJson) : 0 < TreeJson.size t := by
  cases t <;> dsimp [TreeJson.size] <;> omega

/-- Element size is bounded by aggregate size of the enclosing array list. -/
theorem TreeJson.mem_sizeList (x : TreeJson) (xs : List TreeJson) (h : x ∈ xs) :
    TreeJson.size x ≤ TreeJson.sizeList xs := by
  induction xs with
  | nil => contradiction
  | cons y ys ih =>
    dsimp [TreeJson.sizeList]
    cases h with
    | head => omega
    | tail _ h_in =>
      have := ih h_in
      omega

/-- Value size is bounded by aggregate size of the enclosing object field list. -/
theorem TreeJson.mem_sizeObj (k : String) (v : TreeJson) (kvs : List (String × TreeJson)) (h : (k, v) ∈ kvs) :
    TreeJson.size v ≤ TreeJson.sizeObj kvs := by
  induction kvs with
  | nil => contradiction
  | cons f fs ih =>
    rcases f with ⟨k', v'⟩
    dsimp [TreeJson.sizeObj]
    cases h with
    | head => omega
    | tail _ h_in =>
      have := ih h_in
      omega

/-- Validity propagates to any member of an admissible array element list. -/
theorem TreeJson.valid_of_mem_validList (x : TreeJson) (xs : List TreeJson)
    (h_vl : TreeJson.ValidList xs) (h_in : x ∈ xs) : TreeJson.Valid x := by
  induction xs with
  | nil => contradiction
  | cons y ys ih =>
    dsimp [TreeJson.ValidList] at h_vl
    cases h_in with
    | head => exact h_vl.1
    | tail _ h_tl => exact ih h_vl.2 h_tl

/-- Validity propagates to any field value of an admissible object field list. -/
theorem TreeJson.valid_of_mem_validObj (k : String) (v : TreeJson) (kvs : List (String × TreeJson))
    (h_vo : TreeJson.ValidObj kvs) (h_in : (k, v) ∈ kvs) : TreeJson.Valid v := by
  induction kvs with
  | nil => contradiction
  | cons f fs ih =>
    rcases f with ⟨k', v'⟩
    dsimp [TreeJson.ValidObj] at h_vo
    cases h_in with
    | head => exact h_vo.1
    | tail _ h_tl => exact ih h_vo.2 h_tl

/-- Pushdown automaton step on string token in any value-expecting context. -/
theorem parseStep_str_of_isValueContext (st : ParserState) (h_ctx : IsValueContext st) (s : String) :
    parseStep st (.str s) = feedValue st (.str s) := by
  rcases st with ⟨stack, res⟩
  rcases h_ctx with ⟨h_res, h_stack⟩
  dsimp at h_res h_stack ⊢
  dsimp [parseStep]
  cases stack with
  | nil => rfl
  | cons frame rest =>
    cases frame with
    | obj acc ost =>
      cases ost with
      | expectVal k => rfl
      | emptyOrKey => contradiction
      | expectKey => contradiction
      | expectColon _ => contradiction
      | expectCommaOrRbrace => contradiction
    | arr acc ast =>
      cases ast with
      | emptyOrVal => rfl
      | expectVal => rfl
      | expectCommaOrRbracket => contradiction

/-- Pushdown automaton step on lbrace delimiter in any value-expecting context. -/
theorem parseStep_lbrace_of_isValueContext (st : ParserState)
    (h_ctx : IsValueContext st) (h_depth : st.stack.length < 64) :
    parseStep st .lbrace = .ok { stack := StackFrame.obj [] ObjState.emptyOrKey :: st.stack, result := none } := by
  rcases st with ⟨stack, res⟩
  rcases h_ctx with ⟨h_res, h_stack⟩
  dsimp at h_res h_stack h_depth ⊢
  subst h_res
  dsimp [parseStep]
  split
  · rename_i h_ge; omega
  · cases stack with
    | nil => rfl
    | cons frame rest =>
      cases frame with
      | obj acc ost =>
        cases ost with
        | expectVal k => rfl
        | emptyOrKey => contradiction
        | expectKey => contradiction
        | expectColon _ => contradiction
        | expectCommaOrRbrace => contradiction
      | arr acc ast =>
        cases ast with
        | emptyOrVal => rfl
        | expectVal => rfl
        | expectCommaOrRbracket => contradiction

/-- Pushdown automaton step on lbracket delimiter in any value-expecting context. -/
theorem parseStep_lbracket_of_isValueContext (st : ParserState)
    (h_ctx : IsValueContext st) (h_depth : st.stack.length < 64) :
    parseStep st .lbracket = .ok { stack := StackFrame.arr #[] ArrState.emptyOrVal :: st.stack, result := none } := by
  rcases st with ⟨stack, res⟩
  rcases h_ctx with ⟨h_res, h_stack⟩
  dsimp at h_res h_stack h_depth ⊢
  subst h_res
  dsimp [parseStep]
  split
  · rename_i h_ge; omega
  · cases stack with
    | nil => rfl
    | cons frame rest =>
      cases frame with
      | obj acc ost =>
        cases ost with
        | expectVal k => rfl
        | emptyOrKey => contradiction
        | expectKey => contradiction
        | expectColon _ => contradiction
        | expectCommaOrRbrace => contradiction
      | arr acc ast =>
        cases ast with
        | emptyOrVal => rfl
        | expectVal => rfl
        | expectCommaOrRbracket => contradiction

/-- Successful value ingestion into an initial array frame with capacity. -/
theorem feedValue_arr_emptyOrVal_ok (acc : Array Lean.Json) (v : Lean.Json) (rest : List StackFrame)
    (h_len : acc.size < 4096) :
    feedValue { stack := StackFrame.arr acc ArrState.emptyOrVal :: rest, result := none } v =
    .ok { stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  dsimp [feedValue]
  split
  · rename_i h; omega
  · rfl

/-- Successful value ingestion into an expecting array frame with capacity. -/
theorem feedValue_arr_expectVal_ok (acc : Array Lean.Json) (v : Lean.Json) (rest : List StackFrame)
    (h_len : acc.size < 4096) :
    feedValue { stack := StackFrame.arr acc ArrState.expectVal :: rest, result := none } v =
    .ok { stack := StackFrame.arr (acc.push v) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  dsimp [feedValue]
  split
  · rename_i h; omega
  · rfl

/-- Successful value ingestion into an expecting object frame without duplicate key collision. -/
theorem feedValue_obj_expectVal_ok (acc : List (String × Lean.Json)) (key : String) (v : Lean.Json) (rest : List StackFrame)
    (h_not_dup : acc.any (fun (k, _) => k == key) = false) :
    feedValue { stack := StackFrame.obj acc (ObjState.expectVal key) :: rest, result := none } v =
    .ok { stack := StackFrame.obj ((key, v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [feedValue]
  rw [h_not_dup]
  rfl

/-- Base singleton pushdown reduction for array element list. -/
theorem parse_arr_tokensList_cons_nil (x : TreeJson)
    (h_val : ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth x ≤ 64 →
      (TreeJson.tokens x).foldlM parseStep st = feedValue st (TreeJson.toJson x))
    (acc : Array Lean.Json) (state : ArrState) (rest : List StackFrame)
    (h_state : state = ArrState.emptyOrVal ∨ state = ArrState.expectVal)
    (h_cap : acc.size < 4096)
    (h_depth : rest.length + 1 + TreeJson.depth x ≤ 64) :
    (TreeJson.tokensList [x]).foldlM parseStep { stack := StackFrame.arr acc state :: rest, result := none } =
    .ok { stack := StackFrame.arr (acc.push (TreeJson.toJson x)) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  dsimp [TreeJson.tokensList]
  have h_ctx : IsValueContext { stack := StackFrame.arr acc state :: rest, result := none } := by
    dsimp [IsValueContext]
    refine ⟨rfl, ?_⟩
    rcases h_state with rfl | rfl <;> trivial
  have h_d : ({ stack := StackFrame.arr acc state :: rest, result := none } : ParserState).stack.length + TreeJson.depth x ≤ 64 := by
    dsimp; omega
  rw [h_val { stack := StackFrame.arr acc state :: rest, result := none } h_ctx h_d]
  rcases h_state with rfl | rfl
  · exact feedValue_arr_emptyOrVal_ok acc (TreeJson.toJson x) rest h_cap
  · exact feedValue_arr_expectVal_ok acc (TreeJson.toJson x) rest h_cap

/-- Step transition pushdown reduction for array element followed by comma. -/
theorem parse_arr_tokensList_cons_cons (x : TreeJson) (y : TreeJson) (ys : List TreeJson)
    (h_val : ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth x ≤ 64 →
      (TreeJson.tokens x).foldlM parseStep st = feedValue st (TreeJson.toJson x))
    (acc : Array Lean.Json) (state : ArrState) (rest : List StackFrame)
    (h_state : state = ArrState.emptyOrVal ∨ state = ArrState.expectVal)
    (h_cap : acc.size < 4096)
    (h_depth : rest.length + 1 + TreeJson.depth x ≤ 64)
    (finalSt : ParserState)
    (h_rest : (TreeJson.tokensList (y :: ys)).foldlM parseStep
        { stack := StackFrame.arr (acc.push (TreeJson.toJson x)) ArrState.expectVal :: rest, result := none } =
      .ok finalSt) :
    (TreeJson.tokensList (x :: y :: ys)).foldlM parseStep { stack := StackFrame.arr acc state :: rest, result := none } =
    .ok finalSt := by
  have h_eq : TreeJson.tokensList (x :: y :: ys) = (TreeJson.tokens x ++ [JsonToken.comma]) ++ TreeJson.tokensList (y :: ys) := rfl
  rw [h_eq, List.foldlM_append, List.foldlM_append]
  have h_ctx : IsValueContext { stack := StackFrame.arr acc state :: rest, result := none } := by
    dsimp [IsValueContext]
    refine ⟨rfl, ?_⟩
    rcases h_state with rfl | rfl <;> trivial
  have h_d : ({ stack := StackFrame.arr acc state :: rest, result := none } : ParserState).stack.length + TreeJson.depth x ≤ 64 := by
    dsimp; omega
  have h_x := h_val { stack := StackFrame.arr acc state :: rest, result := none } h_ctx h_d
  rw [h_x]
  dsimp [bind, Except.bind]
  rcases h_state with rfl | rfl
  · rw [feedValue_arr_emptyOrVal_ok acc (TreeJson.toJson x) rest h_cap]
    dsimp [List.foldlM, bind, Except.bind, parseStep]
    exact h_rest
  · rw [feedValue_arr_expectVal_ok acc (TreeJson.toJson x) rest h_cap]
    dsimp [List.foldlM, bind, Except.bind, parseStep]
    exact h_rest

/-- Array push equivalent to appending singleton array. -/
theorem array_push_eq_append_singleton (acc : Array Lean.Json) (v : Lean.Json) :
    acc.push v = acc ++ #[v] := by
  rcases acc with ⟨l⟩
  apply Array.ext'
  simp

/-- Associativity of array append. -/
theorem array_append_assoc (a b c : Array Lean.Json) :
    (a ++ b) ++ c = a ++ (b ++ c) := by
  rcases a with ⟨la⟩
  rcases b with ⟨lb⟩
  rcases c with ⟨lc⟩
  apply Array.ext'
  simp

/-- Head cons decomposition of array conversion on lists. -/
theorem toArray_cons (x : Lean.Json) (xs : List Lean.Json) :
    (x :: xs).toArray = #[x] ++ xs.toArray := by
  apply Array.ext'
  simp

/-- General pushdown reduction folding an arbitrary non-empty list of array elements. -/
theorem parse_arr_tokensList (xs : List TreeJson)
    (h_val : ∀ x ∈ xs, ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth x ≤ 64 →
      (TreeJson.tokens x).foldlM parseStep st = feedValue st (TreeJson.toJson x))
    (acc : Array Lean.Json) (state : ArrState) (rest : List StackFrame)
    (h_state : state = ArrState.emptyOrVal ∨ state = ArrState.expectVal)
    (h_nonempty : xs ≠ [])
    (h_cap : acc.size + xs.length ≤ 4096)
    (h_depth : rest.length + 1 + TreeJson.depthList xs ≤ 64) :
    (TreeJson.tokensList xs).foldlM parseStep { stack := StackFrame.arr acc state :: rest, result := none } =
    .ok { stack := StackFrame.arr (acc ++ (TreeJson.toJsonList xs).toArray) ArrState.expectCommaOrRbracket :: rest, result := none } := by
  induction xs generalizing acc state with
  | nil => contradiction
  | cons x tl ih =>
    cases tl with
    | nil =>
      have h_val_x := h_val x (List.Mem.head [])
      have h_cap_x : acc.size < 4096 := by
        dsimp at h_cap
        omega
      have h_d_x : rest.length + 1 + x.depth ≤ 64 := by
        dsimp [TreeJson.depthList] at h_depth
        omega
      have h_res := parse_arr_tokensList_cons_nil x h_val_x acc state rest h_state h_cap_x h_d_x
      rw [h_res]
      dsimp [TreeJson.toJsonList]
      rw [array_push_eq_append_singleton]
    | cons y ys =>
      have h_val_x := h_val x (by simp)
      have h_cap_x : acc.size < 4096 := by
        dsimp at h_cap
        omega
      have h_d_x : rest.length + 1 + x.depth ≤ 64 := by
        dsimp [TreeJson.depthList] at h_depth
        omega
      have h_val_tl : ∀ z ∈ (y :: ys), ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth z ≤ 64 →
          (TreeJson.tokens z).foldlM parseStep st = feedValue st (TreeJson.toJson z) := by
        intro z hz
        exact h_val z (by simp [hz])
      have h_cap_tl : (acc.push (TreeJson.toJson x)).size + (y :: ys).length ≤ 4096 := by
        simp only [Array.size_push, List.length_cons] at h_cap ⊢
        omega
      have h_d_tl : rest.length + 1 + TreeJson.depthList (y :: ys) ≤ 64 := by
        have : TreeJson.depthList (y :: ys) ≤ TreeJson.depthList (x :: y :: ys) := by
          dsimp [TreeJson.depthList]
          omega
        omega
      have h_ih := ih h_val_tl (acc.push (TreeJson.toJson x)) ArrState.expectVal (Or.inr rfl) (by intro h; contradiction) h_cap_tl h_d_tl
      have h_step := parse_arr_tokensList_cons_cons x y ys h_val_x acc state rest h_state h_cap_x h_d_x _ h_ih
      rw [h_step]
      dsimp [TreeJson.toJsonList]
      rw [array_push_eq_append_singleton]
      rw [array_append_assoc]
      rw [← toArray_cons]

/-- Universal pushdown parser reduction for arbitrary admissible array trees. -/
theorem parse_tokens_arr (xs : List TreeJson)
    (h_val : ∀ x ∈ xs, ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth x ≤ 64 →
      (TreeJson.tokens x).foldlM parseStep st = feedValue st (TreeJson.toJson x))
    (h_len : xs.length ≤ 4096)
    (st : ParserState) (h_ctx : IsValueContext st)
    (h_depth : st.stack.length + TreeJson.depth (.arr xs) ≤ 64) :
    (TreeJson.tokens (.arr xs)).foldlM parseStep st = feedValue st (TreeJson.toJson (.arr xs)) := by
  rcases st with ⟨stack, res⟩
  rcases h_ctx with ⟨h_res, h_stack⟩
  dsimp at h_res h_stack h_depth ⊢
  subst h_res
  have h_ctx' : IsValueContext { stack := stack, result := none } := ⟨rfl, h_stack⟩
  have h_split : TreeJson.tokens (.arr xs) = JsonToken.lbracket :: (TreeJson.tokensList xs ++ [JsonToken.rbracket]) := rfl
  rw [h_split]
  simp only [List.foldlM_cons]
  have h_d_lbracket : stack.length < 64 := by
    dsimp [TreeJson.depth] at h_depth
    omega
  have h_lb := parseStep_lbracket_of_isValueContext { stack := stack, result := none } h_ctx' h_d_lbracket
  rw [h_lb]
  dsimp [bind, Except.bind]
  rw [List.foldlM_append]
  cases xs with
  | nil =>
    dsimp [TreeJson.tokensList, List.foldlM, bind, Except.bind, pure, Except.pure, parseStep, TreeJson.toJson, TreeJson.toJsonList]
    generalize feedValue { stack := stack, result := none } (Lean.Json.arr #[]) = res_fv
    cases res_fv <;> rfl
  | cons y ys =>
    have h_nonempty : y :: ys ≠ [] := by intro h; contradiction
    have h_cap : (#[] : Array Lean.Json).size + (y :: ys).length ≤ 4096 := by
      simp only [Array.size_empty, Nat.zero_add]
      exact h_len
    have h_d_tl : stack.length + 1 + TreeJson.depthList (y :: ys) ≤ 64 := by
      dsimp [TreeJson.depth] at h_depth
      omega
    have h_fold := parse_arr_tokensList (y :: ys) h_val #[] ArrState.emptyOrVal stack (Or.inl rfl) h_nonempty h_cap h_d_tl
    rw [h_fold]
    dsimp [List.foldlM, bind, Except.bind, pure, Except.pure, parseStep]
    have h_empty_app : #[] ++ (TreeJson.toJsonList (y :: ys)).toArray = (TreeJson.toJsonList (y :: ys)).toArray := by
      apply Array.ext'
      simp
    rw [h_empty_app]
    dsimp [TreeJson.toJson]
    generalize feedValue { stack := stack, result := none } (Lean.Json.arr (TreeJson.toJsonList (y :: ys)).toArray) = res_fv
    cases res_fv <;> rfl

/-- Pushdown reduction for a single key-colon-value field sequence. -/
theorem parse_obj_tokens_field (k : String) (v : TreeJson)
    (h_val : ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v ≤ 64 →
      (TreeJson.tokens v).foldlM parseStep st = feedValue st (TreeJson.toJson v))
    (acc : List (String × Lean.Json)) (state : ObjState) (rest : List StackFrame)
    (h_state : state = ObjState.emptyOrKey ∨ state = ObjState.expectKey)
    (h_not_dup : acc.any (fun (k', _) => k' == k) = false)
    (h_depth : rest.length + 1 + TreeJson.depth v ≤ 64) :
    ([JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v).foldlM parseStep
        { stack := StackFrame.obj acc state :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, TreeJson.toJson v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  have h_split : ([JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v) =
      JsonToken.str k :: (JsonToken.colon :: TreeJson.tokens v) := rfl
  rw [h_split]
  simp only [List.foldlM_cons]
  dsimp [parseStep]
  rcases h_state with rfl | rfl <;> dsimp [bind, Except.bind]
  · have h_ctx : IsValueContext { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } := ⟨rfl, trivial⟩
    have h_d : ({ stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } : ParserState).stack.length + TreeJson.depth v ≤ 64 := by
      dsimp; omega
    have h_v := h_val { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } h_ctx h_d
    rw [h_v]
    exact feedValue_obj_expectVal_ok acc k (TreeJson.toJson v) rest h_not_dup
  · have h_ctx : IsValueContext { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } := ⟨rfl, trivial⟩
    have h_d : ({ stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } : ParserState).stack.length + TreeJson.depth v ≤ 64 := by
      dsimp; omega
    have h_v := h_val { stack := StackFrame.obj acc (ObjState.expectVal k) :: rest, result := none } h_ctx h_d
    rw [h_v]
    exact feedValue_obj_expectVal_ok acc k (TreeJson.toJson v) rest h_not_dup

/-- Base singleton pushdown reduction for object field list. -/
theorem parse_obj_tokensObj_cons_nil (k : String) (v : TreeJson)
    (h_val : ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v ≤ 64 →
      (TreeJson.tokens v).foldlM parseStep st = feedValue st (TreeJson.toJson v))
    (acc : List (String × Lean.Json)) (state : ObjState) (rest : List StackFrame)
    (h_state : state = ObjState.emptyOrKey ∨ state = ObjState.expectKey)
    (h_not_dup : acc.any (fun (k', _) => k' == k) = false)
    (h_depth : rest.length + 1 + TreeJson.depth v ≤ 64) :
    (TreeJson.tokensObj [(k, v)]).foldlM parseStep { stack := StackFrame.obj acc state :: rest, result := none } =
    .ok { stack := StackFrame.obj ((k, TreeJson.toJson v) :: acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  dsimp [TreeJson.tokensObj]
  exact parse_obj_tokens_field k v h_val acc state rest h_state h_not_dup h_depth

/-- Step transition pushdown reduction for object field followed by comma. -/
theorem parse_obj_tokensObj_cons_cons (k : String) (v : TreeJson) (f2 : String × TreeJson) (kvs : List (String × TreeJson))
    (h_val : ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v ≤ 64 →
      (TreeJson.tokens v).foldlM parseStep st = feedValue st (TreeJson.toJson v))
    (acc : List (String × Lean.Json)) (state : ObjState) (rest : List StackFrame)
    (h_state : state = ObjState.emptyOrKey ∨ state = ObjState.expectKey)
    (h_not_dup : acc.any (fun (k', _) => k' == k) = false)
    (h_depth : rest.length + 1 + TreeJson.depth v ≤ 64)
    (finalSt : ParserState)
    (h_rest : (TreeJson.tokensObj (f2 :: kvs)).foldlM parseStep
        { stack := StackFrame.obj ((k, TreeJson.toJson v) :: acc) ObjState.expectKey :: rest, result := none } =
      .ok finalSt) :
    (TreeJson.tokensObj ((k, v) :: f2 :: kvs)).foldlM parseStep { stack := StackFrame.obj acc state :: rest, result := none } =
    .ok finalSt := by
  have h_eq : TreeJson.tokensObj ((k, v) :: f2 :: kvs) =
      ([JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v ++ [JsonToken.comma]) ++ TreeJson.tokensObj (f2 :: kvs) := rfl
  rw [h_eq, List.foldlM_append]
  have h_field_split : ([JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v ++ [JsonToken.comma]) =
      ([JsonToken.str k, JsonToken.colon] ++ TreeJson.tokens v) ++ [JsonToken.comma] := rfl
  rw [h_field_split, List.foldlM_append]
  have h_field := parse_obj_tokens_field k v h_val acc state rest h_state h_not_dup h_depth
  rw [h_field]
  dsimp [List.foldlM, bind, Except.bind, parseStep]
  exact h_rest

/-- General pushdown reduction folding an arbitrary non-empty list of object fields. -/
theorem parse_obj_tokensObj (kvs : List (String × TreeJson))
    (h_val : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v ≤ 64 →
      (TreeJson.tokens v).foldlM parseStep st = feedValue st (TreeJson.toJson v))
    (acc : List (String × Lean.Json)) (state : ObjState) (rest : List StackFrame)
    (h_state : state = ObjState.emptyOrKey ∨ state = ObjState.expectKey)
    (h_nonempty : kvs ≠ [])
    (h_not_dup : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → acc.any (fun (k', _) => k' == k) = false)
    (h_nodup_kvs : (kvs.map Prod.fst).Nodup)
    (h_depth : rest.length + 1 + TreeJson.depthObj kvs ≤ 64) :
    (TreeJson.tokensObj kvs).foldlM parseStep { stack := StackFrame.obj acc state :: rest, result := none } =
    .ok { stack := StackFrame.obj ((TreeJson.toJsonObj kvs).reverse ++ acc) ObjState.expectCommaOrRbrace :: rest, result := none } := by
  induction kvs generalizing acc state with
  | nil => contradiction
  | cons f tl ih =>
    rcases f with ⟨k, v⟩
    cases tl with
    | nil =>
      have h_val_kv := h_val k v (List.Mem.head [])
      have h_not_dup_kv := h_not_dup k v (List.Mem.head [])
      have h_d_kv : rest.length + 1 + v.depth ≤ 64 := by
        dsimp [TreeJson.depthObj] at h_depth
        omega
      have h_res := parse_obj_tokensObj_cons_nil k v h_val_kv acc state rest h_state h_not_dup_kv h_d_kv
      rw [h_res]
      dsimp [TreeJson.toJsonObj]
      rfl
    | cons f2 kvs' =>
      have h_val_kv := h_val k v (by simp)
      have h_not_dup_kv := h_not_dup k v (by simp)
      have h_d_kv : rest.length + 1 + v.depth ≤ 64 := by
        dsimp [TreeJson.depthObj] at h_depth
        omega
      have h_val_tl : ∀ (k' : String) (v' : TreeJson), (k', v') ∈ f2 :: kvs' → ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v' ≤ 64 →
          (TreeJson.tokens v').foldlM parseStep st = feedValue st (TreeJson.toJson v') := by
        intro k' v' h_mem
        exact h_val k' v' (by simp [h_mem])
      have h_not_dup_tl : ∀ (k' : String) (v' : TreeJson), (k', v') ∈ f2 :: kvs' → ((k, TreeJson.toJson v) :: acc).any (fun (k'', _) => k'' == k') = false := by
        intro k' v' h_mem
        dsimp [List.any]
        have h_k_neq : ¬ (k = k') := by
          intro h_eq
          subst h_eq
          have h_nodup_fst := List.nodup_cons.mp h_nodup_kvs
          have h_k_in : k ∈ (f2 :: kvs').map Prod.fst := List.mem_map.mpr ⟨(k, v'), h_mem, rfl⟩
          exact h_nodup_fst.1 h_k_in
        have h_k_b : (k == k') = false := by
          cases h_c : (k == k')
          · rfl
          · exfalso
            have h_eq : k = k' := beq_iff_eq.mp h_c
            exact h_k_neq h_eq
        rw [h_k_b]
        dsimp [Bool.or]
        exact h_not_dup k' v' (by simp [h_mem])
      have h_nodup_tl : ((f2 :: kvs').map Prod.fst).Nodup := (List.nodup_cons.mp h_nodup_kvs).2
      have h_d_tl : rest.length + 1 + TreeJson.depthObj (f2 :: kvs') ≤ 64 := by
        have : TreeJson.depthObj (f2 :: kvs') ≤ TreeJson.depthObj ((k, v) :: f2 :: kvs') := by
          dsimp [TreeJson.depthObj]
          omega
        omega
      have h_ih := ih h_val_tl ((k, TreeJson.toJson v) :: acc) ObjState.expectKey (Or.inr rfl) (by intro h; contradiction) h_not_dup_tl h_nodup_tl h_d_tl
      have h_step := parse_obj_tokensObj_cons_cons k v f2 kvs' h_val_kv acc state rest h_state h_not_dup_kv h_d_kv _ h_ih
      rw [h_step]
      rcases f2 with ⟨k2, v2⟩
      dsimp [TreeJson.toJsonObj]
      simp only [List.reverse_cons, List.append_assoc, List.cons_append, List.nil_append]

/-- Universal pushdown parser reduction for arbitrary admissible object trees. -/
theorem parse_tokens_obj (kvs : List (String × TreeJson))
    (h_val : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (st : ParserState), IsValueContext st → st.stack.length + TreeJson.depth v ≤ 64 →
      (TreeJson.tokens v).foldlM parseStep st = feedValue st (TreeJson.toJson v))
    (h_nodup : (kvs.map Prod.fst).Nodup)
    (st : ParserState) (h_ctx : IsValueContext st)
    (h_depth : st.stack.length + TreeJson.depth (.obj kvs) ≤ 64) :
    (TreeJson.tokens (.obj kvs)).foldlM parseStep st = feedValue st (TreeJson.toJson (.obj kvs)) := by
  rcases st with ⟨stack, res⟩
  rcases h_ctx with ⟨h_res, h_stack⟩
  dsimp at h_res h_stack h_depth ⊢
  subst h_res
  have h_ctx' : IsValueContext { stack := stack, result := none } := ⟨rfl, h_stack⟩
  have h_split : TreeJson.tokens (.obj kvs) = JsonToken.lbrace :: (TreeJson.tokensObj kvs ++ [JsonToken.rbrace]) := rfl
  rw [h_split]
  simp only [List.foldlM_cons]
  have h_d_lbrace : stack.length < 64 := by
    dsimp [TreeJson.depth] at h_depth
    omega
  have h_lb := parseStep_lbrace_of_isValueContext { stack := stack, result := none } h_ctx' h_d_lbrace
  rw [h_lb]
  dsimp [bind, Except.bind]
  rw [List.foldlM_append]
  cases kvs with
  | nil =>
    dsimp [TreeJson.tokensObj, List.foldlM, bind, Except.bind, pure, Except.pure, parseStep, TreeJson.toJson, TreeJson.toJsonObj]
    generalize feedValue { stack := stack, result := none } (Lean.Json.mkObj []) = res_fv
    cases res_fv <;> rfl
  | cons f tl =>
    rcases f with ⟨k, v⟩
    have h_nonempty : (k, v) :: tl ≠ [] := by intro h; contradiction
    have h_not_dup_empty : ∀ (k' : String) (v' : TreeJson), (k', v') ∈ (k, v) :: tl → ([] : List (String × Lean.Json)).any (fun (k'', _) => k'' == k') = false := by
      intro _ _ _
      rfl
    have h_d_tl : stack.length + 1 + TreeJson.depthObj ((k, v) :: tl) ≤ 64 := by
      dsimp [TreeJson.depth] at h_depth
      omega
    have h_fold := parse_obj_tokensObj ((k, v) :: tl) h_val [] ObjState.emptyOrKey stack (Or.inl rfl) h_nonempty h_not_dup_empty h_nodup h_d_tl
    rw [h_fold]
    dsimp [List.foldlM, bind, Except.bind, pure, Except.pure, parseStep]
    simp only [List.append_nil, List.reverse_reverse]
    dsimp [TreeJson.toJson]
    generalize feedValue { stack := stack, result := none } (Lean.Json.mkObj (TreeJson.toJsonObj ((k, v) :: tl))) = res_fv
    cases res_fv <;> rfl

/-- Universal pushdown parser reduction for all admissible TreeJson values in any value-expecting context. -/
theorem parse_tokens_tree (t : TreeJson)
    (h_valid : TreeJson.Valid t)
    (st : ParserState) (h_ctx : IsValueContext st)
    (h_depth : st.stack.length + TreeJson.depth t ≤ 64) :
    (TreeJson.tokens t).foldlM parseStep st = feedValue st (TreeJson.toJson t) := by
  match t with
  | .null =>
    dsimp [TreeJson.tokens, List.foldlM, bind, Except.bind, parseStep, TreeJson.toJson]
    cases feedValue st Lean.Json.null <;> rfl
  | .bool b =>
    dsimp [TreeJson.tokens, List.foldlM, bind, Except.bind, parseStep, TreeJson.toJson]
    cases feedValue st (Lean.Json.bool b) <;> rfl
  | .num n =>
    dsimp [TreeJson.tokens, List.foldlM, bind, Except.bind, parseStep, TreeJson.toJson]
    cases feedValue st (Lean.Json.num ⟨n, 0⟩) <;> rfl
  | .str s =>
    dsimp [TreeJson.tokens, List.foldlM, bind, Except.bind, TreeJson.toJson]
    rw [parseStep_str_of_isValueContext st h_ctx s]
    cases feedValue st (Lean.Json.str s) <;> rfl
  | .arr xs =>
    dsimp [TreeJson.Valid] at h_valid
    have h_ih : ∀ x ∈ xs, ∀ (st' : ParserState), IsValueContext st' → st'.stack.length + TreeJson.depth x ≤ 64 →
        (TreeJson.tokens x).foldlM parseStep st' = feedValue st' (TreeJson.toJson x) := by
      intro x h_in st' h_ctx' h_d'
      have h_x_valid := TreeJson.valid_of_mem_validList x xs h_valid.2 h_in
      have h_x_size : TreeJson.size x < TreeJson.size (.arr xs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeList x xs h_in
        omega
      exact parse_tokens_tree x h_x_valid st' h_ctx' h_d'
    exact parse_tokens_arr xs h_ih h_valid.1 st h_ctx h_depth
  | .obj kvs =>
    dsimp [TreeJson.Valid] at h_valid
    have h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (st' : ParserState), IsValueContext st' → st'.stack.length + TreeJson.depth v ≤ 64 →
        (TreeJson.tokens v).foldlM parseStep st' = feedValue st' (TreeJson.toJson v) := by
      intro k v h_in st' h_ctx' h_d'
      have h_v_valid := TreeJson.valid_of_mem_validObj k v kvs h_valid.2 h_in
      have h_v_size : TreeJson.size v < TreeJson.size (.obj kvs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeObj k v kvs h_in
        omega
      exact parse_tokens_tree v h_v_valid st' h_ctx' h_d'
    exact parse_tokens_obj kvs h_ih h_valid.1 st h_ctx h_depth
termination_by TreeJson.size t

/-- General bounded ordered TreeJson parser inversion:
    every structurally admissible TreeJson within the 64 depth bound parses to its semantic Lean.Json. -/
theorem parseTokens_tree_valid (t : TreeJson) (h_valid : TreeJson.Valid t)
    (h_depth : TreeJson.depth t ≤ 64) :
    parseTokens (TreeJson.tokens t) = .ok (TreeJson.toJson t) := by
  have h_ctx : IsValueContext { stack := [], result := none } := ⟨rfl, trivial⟩
  have h_d : ({ stack := [], result := none } : ParserState).stack.length + TreeJson.depth t ≤ 64 := by
    dsimp; omega
  have h_fold := parse_tokens_tree t h_valid { stack := [], result := none } h_ctx h_d
  dsimp [feedValue] at h_fold
  exact parseTokens_of_foldlM (TreeJson.tokens t) (TreeJson.toJson t) h_fold

/-- Predicate for character suffixes whose head is not a decimal digit.
    Required for exact numeric tokenization boundary in canonical JSON. -/
def NonDigitHead (cs : List Char) : Prop :=
  match cs with
  | [] => True
  | c :: _ => c.isDigit = false

theorem nonDigitHead_nil : NonDigitHead [] := trivial
theorem nonDigitHead_comma (rest : List Char) : NonDigitHead (',' :: rest) := rfl
theorem nonDigitHead_colon (rest : List Char) : NonDigitHead (':' :: rest) := rfl
theorem nonDigitHead_rbracket (rest : List Char) : NonDigitHead (']' :: rest) := rfl
theorem nonDigitHead_rbrace (rest : List Char) : NonDigitHead ('}' :: rest) := rfl

theorem escapeTreeString_eq (s : String) :
    (escapeTreeString s).toList = '"' :: (escapeChars s.toList ++ ['"']) := by
  dsimp [escapeTreeString]
  rw [String.toList_ofList]

theorem tokenizeFuel_escapeTreeString (fuel : Nat) (s : String) (rest : List Char) :
    tokenizeFuel (fuel + 1) ((escapeTreeString s).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (JsonToken.str s :: toks)) := by
  rw [escapeTreeString_eq]
  have h_append : ('"' :: (escapeChars s.toList ++ ['"'])) ++ rest =
      '"' :: (escapeChars s.toList ++ ('"' :: rest)) := by
    dsimp [List.cons_append]
    rw [List.append_assoc]
    rfl
  rw [h_append]
  exact tokenizeFuel_string fuel s rest

theorem toList_comma : ",".toList = [','] := rfl
theorem toList_colon : ":".toList = [':'] := rfl
theorem toList_lbracket : "[".toList = ['['] := rfl
theorem toList_rbracket : "]".toList = [']'] := rfl
theorem toList_lbrace : "{".toList = ['{'] := rfl
theorem toList_rbrace : "}".toList = ['}'] := rfl

theorem encode_arr_toList (xs : List TreeJson) (rest : List Char) :
    (TreeJson.encode (.arr xs)).toList ++ rest =
    '[' :: ((TreeJson.encodeList xs).toList ++ (']' :: rest)) := by
  dsimp [TreeJson.encode]
  repeat rw [String.toList_append]
  rw [toList_lbracket, toList_rbracket]
  simp only [List.cons_append, List.nil_append, List.append_assoc]

theorem encode_obj_toList (kvs : List (String × TreeJson)) (rest : List Char) :
    (TreeJson.encode (.obj kvs)).toList ++ rest =
    '{' :: ((TreeJson.encodeObj kvs).toList ++ ('}' :: rest)) := by
  dsimp [TreeJson.encode]
  repeat rw [String.toList_append]
  rw [toList_lbrace, toList_rbrace]
  simp only [List.cons_append, List.nil_append, List.append_assoc]

theorem encodeList_cons_cons_toList (x x2 : TreeJson) (xs' : List TreeJson) (rest : List Char) :
    (TreeJson.encodeList (x :: x2 :: xs')).toList ++ rest =
    (TreeJson.encode x).toList ++ (',' :: ((TreeJson.encodeList (x2 :: xs')).toList ++ rest)) := by
  dsimp [TreeJson.encodeList]
  repeat rw [String.toList_append]
  rw [toList_comma]
  simp only [List.cons_append, List.nil_append, List.append_assoc]

theorem encodeObj_singleton_toList (k : String) (v : TreeJson) (rest : List Char) :
    (TreeJson.encodeObj [(k, v)]).toList ++ rest =
    (escapeTreeString k).toList ++ (':' :: ((TreeJson.encode v).toList ++ rest)) := by
  dsimp [TreeJson.encodeObj]
  repeat rw [String.toList_append]
  rw [toList_colon]
  simp only [List.cons_append, List.nil_append, List.append_assoc]

theorem encodeObj_cons_cons_toList (k : String) (v : TreeJson) (f2 : String × TreeJson) (kvs' : List (String × TreeJson)) (rest : List Char) :
    (TreeJson.encodeObj ((k, v) :: f2 :: kvs')).toList ++ rest =
    (escapeTreeString k).toList ++ (':' :: ((TreeJson.encode v).toList ++ (',' :: ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest)))) := by
  dsimp [TreeJson.encodeObj]
  repeat rw [String.toList_append]
  rw [toList_colon, toList_comma]
  simp only [List.cons_append, List.nil_append, List.append_assoc]

theorem toDigits_nonempty_length (n : Nat) : 1 ≤ (Nat.toDigits 10 n).length := by
  have := Nat.length_toDigits_pos (b := 10) (n := n)
  omega

theorem toString_nat_length_ge_one (n : Nat) : 1 ≤ (toString n).toList.length := by
  have h_repr : (toString n).toList = Nat.toDigits 10 n := by
    change (Nat.repr n).toList = Nat.toDigits 10 n
    exact Nat.toList_repr
  rw [h_repr]
  exact toDigits_nonempty_length n

theorem toString_int_length_ge_one (i : Int) : 1 ≤ (toString i).toList.length := by
  cases i with
  | ofNat n => exact toString_nat_length_ge_one n
  | negSucc n =>
    have h_repr : (toString (Int.negSucc n)).toList = '-' :: (Nat.repr (n + 1)).toList := by
      change ("-" ++ Nat.repr (n + 1)).toList = '-' :: (Nat.repr (n + 1)).toList
      rw [String.toList_append]
      rfl
    rw [h_repr]
    dsimp [List.length]
    omega

theorem escapeTreeString_length_ge_two (s : String) : 2 ≤ (escapeTreeString s).toList.length := by
  rw [escapeTreeString_eq]
  dsimp [List.length]
  rw [List.length_append]
  simp only [List.length_cons, List.length_nil]
  omega

theorem tokensList_length_le_encodeList_length (xs : List TreeJson)
    (h_ih : ∀ x ∈ xs, (TreeJson.tokens x).length ≤ (TreeJson.encode x).toList.length) :
    (TreeJson.tokensList xs).length ≤ (TreeJson.encodeList xs).toList.length := by
  induction xs with
  | nil => rfl
  | cons x tl ih =>
    cases tl with
    | nil =>
      dsimp [TreeJson.tokensList, TreeJson.encodeList]
      exact h_ih x (List.Mem.head [])
    | cons x2 xs' =>
      dsimp [TreeJson.tokensList, TreeJson.encodeList]
      repeat rw [String.toList_append]
      rw [toList_comma]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have h_x := h_ih x (List.Mem.head _)
      have h_ih_tl := ih (fun y hy => h_ih y (List.Mem.tail x hy))
      omega

theorem tokensObj_length_le_encodeObj_length (kvs : List (String × TreeJson))
    (h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → (TreeJson.tokens v).length ≤ (TreeJson.encode v).toList.length) :
    (TreeJson.tokensObj kvs).length ≤ (TreeJson.encodeObj kvs).toList.length := by
  induction kvs with
  | nil => rfl
  | cons f tl ih =>
    rcases f with ⟨k, v⟩
    cases tl with
    | nil =>
      dsimp [TreeJson.tokensObj, TreeJson.encodeObj]
      repeat rw [String.toList_append]
      rw [toList_colon]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have h_v := h_ih k v (List.Mem.head [])
      have h_k := escapeTreeString_length_ge_two k
      omega
    | cons f2 kvs' =>
      dsimp [TreeJson.tokensObj, TreeJson.encodeObj]
      repeat rw [String.toList_append]
      rw [toList_colon, toList_comma]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have h_v := h_ih k v (List.Mem.head _)
      have h_k := escapeTreeString_length_ge_two k
      have h_ih_tl := ih (fun k' v' hy => h_ih k' v' (List.Mem.tail (k, v) hy))
      omega

/-- Non-circular length bound: the number of produced JSON tokens is bounded by serialized characters. -/
theorem tokens_length_le_encode_length (t : TreeJson) :
    (TreeJson.tokens t).length ≤ (TreeJson.encode t).toList.length := by
  match t with
  | .null => decide
  | .bool true => decide
  | .bool false => decide
  | .num n =>
    dsimp [TreeJson.tokens, TreeJson.encode]
    exact toString_int_length_ge_one n
  | .str s =>
    dsimp [TreeJson.tokens, TreeJson.encode]
    have := escapeTreeString_length_ge_two s
    omega
  | .arr xs =>
    dsimp [TreeJson.tokens, TreeJson.encode]
    repeat rw [String.toList_append]
    rw [toList_lbracket, toList_rbracket]
    simp only [List.length_append, List.length_cons, List.length_nil]
    have h_ih : ∀ x ∈ xs, (TreeJson.tokens x).length ≤ (TreeJson.encode x).toList.length := by
      intro x hx
      have : TreeJson.size x < TreeJson.size (.arr xs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeList x xs hx
        omega
      exact tokens_length_le_encode_length x
    have h_list := tokensList_length_le_encodeList_length xs h_ih
    omega
  | .obj kvs =>
    dsimp [TreeJson.tokens, TreeJson.encode]
    repeat rw [String.toList_append]
    rw [toList_lbrace, toList_rbrace]
    simp only [List.length_append, List.length_cons, List.length_nil]
    have h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → (TreeJson.tokens v).length ≤ (TreeJson.encode v).toList.length := by
      intro k v hv
      have : TreeJson.size v < TreeJson.size (.obj kvs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeObj k v kvs hv
        omega
      exact tokens_length_le_encode_length v
    have h_obj := tokensObj_length_le_encodeObj_length kvs h_ih
    omega
termination_by TreeJson.size t

/-- Fuel-bounded tokenization inversion for array element sequences. -/
theorem tokenizeFuel_encodeList (xs : List TreeJson)
    (h_ih : ∀ x ∈ xs, ∀ (fuel : Nat) (rest : List Char), NonDigitHead rest →
      tokenizeFuel ((TreeJson.tokens x).length + fuel) ((TreeJson.encode x).toList ++ rest) =
        (do let toks ← tokenizeFuel fuel rest; .ok (TreeJson.tokens x ++ toks)))
    (fuel : Nat) (rest : List Char) (h_end : NonDigitHead rest) :
    tokenizeFuel ((TreeJson.tokensList xs).length + fuel) ((TreeJson.encodeList xs).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (TreeJson.tokensList xs ++ toks)) := by
  induction xs with
  | nil =>
    dsimp [TreeJson.tokensList, TreeJson.encodeList]
    have : 0 + fuel = fuel := by omega
    rw [this]
    cases tokenizeFuel fuel rest <;> rfl
  | cons x tl ih =>
    cases tl with
    | nil =>
      dsimp [TreeJson.tokensList, TreeJson.encodeList]
      exact h_ih x (List.Mem.head []) fuel rest h_end
    | cons x2 xs' =>
      rw [encodeList_cons_cons_toList]
      have h_fuel : (TreeJson.tokensList (x :: x2 :: xs')).length + fuel =
          (TreeJson.tokens x).length + (((TreeJson.tokensList (x2 :: xs')).length + fuel) + 1) := by
        dsimp [TreeJson.tokensList]
        simp only [List.length_append, List.length_cons, List.length_nil]
        omega
      rw [h_fuel]
      have h_x := h_ih x (List.Mem.head _) (((TreeJson.tokensList (x2 :: xs')).length + fuel) + 1)
          (',' :: ((TreeJson.encodeList (x2 :: xs')).toList ++ rest)) (nonDigitHead_comma _)
      rw [h_x]
      dsimp [bind, Except.bind]
      rw [tokenizeFuel_comma]
      dsimp [bind, Except.bind]
      have h_ih_tl : ∀ y ∈ x2 :: xs', ∀ (fuel : Nat) (rest : List Char), NonDigitHead rest →
          tokenizeFuel ((TreeJson.tokens y).length + fuel) ((TreeJson.encode y).toList ++ rest) =
            (do let toks ← tokenizeFuel fuel rest; .ok (TreeJson.tokens y ++ toks)) := by
        intro y hy f r he
        exact h_ih y (List.Mem.tail x hy) f r he
      rw [ih h_ih_tl]
      dsimp [bind, Except.bind]
      cases tokenizeFuel fuel rest with
      | error _ => rfl
      | ok toks => simp [TreeJson.tokensList]

/-- Fuel-bounded tokenization inversion for object field sequences. -/
theorem tokenizeFuel_encodeObj (kvs : List (String × TreeJson))
    (h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (fuel : Nat) (rest : List Char), NonDigitHead rest →
      tokenizeFuel ((TreeJson.tokens v).length + fuel) ((TreeJson.encode v).toList ++ rest) =
        (do let toks ← tokenizeFuel fuel rest; .ok (TreeJson.tokens v ++ toks)))
    (fuel : Nat) (rest : List Char) (h_end : NonDigitHead rest) :
    tokenizeFuel ((TreeJson.tokensObj kvs).length + fuel) ((TreeJson.encodeObj kvs).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (TreeJson.tokensObj kvs ++ toks)) := by
  induction kvs with
  | nil =>
    dsimp [TreeJson.tokensObj, TreeJson.encodeObj]
    have : 0 + fuel = fuel := by omega
    rw [this]
    cases tokenizeFuel fuel rest <;> rfl
  | cons f tl ih =>
    rcases f with ⟨k, v⟩
    cases tl with
    | nil =>
      rw [encodeObj_singleton_toList]
      have h_fuel : (TreeJson.tokensObj [(k, v)]).length + fuel =
          ((TreeJson.tokens v).length + fuel + 1) + 1 := by
        simp [TreeJson.tokensObj]
        omega
      rw [h_fuel]
      rw [tokenizeFuel_escapeTreeString]
      dsimp [bind, Except.bind]
      rw [tokenizeFuel_colon]
      dsimp [bind, Except.bind]
      have h_v := h_ih k v (List.Mem.head []) fuel rest h_end
      rw [h_v]
      dsimp [bind, Except.bind]
      cases tokenizeFuel fuel rest <;> rfl
    | cons f2 kvs' =>
      rw [encodeObj_cons_cons_toList]
      have h_fuel : (TreeJson.tokensObj ((k, v) :: f2 :: kvs')).length + fuel =
          ((TreeJson.tokens v).length + (((TreeJson.tokensObj (f2 :: kvs')).length + fuel) + 1) + 1) + 1 := by
        dsimp [TreeJson.tokensObj]
        simp only [List.length_append, List.length_cons, List.length_nil]
        omega
      rw [h_fuel]
      rw [tokenizeFuel_escapeTreeString]
      dsimp [bind, Except.bind]
      rw [tokenizeFuel_colon]
      dsimp [bind, Except.bind]
      have h_v := h_ih k v (List.Mem.head _) (((TreeJson.tokensObj (f2 :: kvs')).length + fuel) + 1)
          (',' :: ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest)) (nonDigitHead_comma _)
      rw [h_v]
      dsimp [bind, Except.bind]
      rw [tokenizeFuel_comma]
      dsimp [bind, Except.bind]
      have h_ih_tl : ∀ (k' : String) (v' : TreeJson), (k', v') ∈ f2 :: kvs' → ∀ (fuel : Nat) (rest : List Char), NonDigitHead rest →
          tokenizeFuel ((TreeJson.tokens v').length + fuel) ((TreeJson.encode v').toList ++ rest) =
            (do let toks ← tokenizeFuel fuel rest; .ok (TreeJson.tokens v' ++ toks)) := by
        intro k' v' h_mem f r he
        exact h_ih k' v' (List.Mem.tail (k, v) h_mem) f r he
      rw [ih h_ih_tl]
      dsimp [bind, Except.bind]
      cases tokenizeFuel fuel rest with
      | error _ => rfl
      | ok toks => simp [TreeJson.tokensObj]

/-- Universal fuel-bounded tokenization theorem:
    tokenizing the serialized characters of any TreeJson consumes exactly its token count in fuel
    and prepends its canonical token sequence. -/
theorem tokenizeFuel_tree (t : TreeJson) (fuel : Nat) (rest : List Char) (h_end : NonDigitHead rest) :
    tokenizeFuel ((TreeJson.tokens t).length + fuel) ((TreeJson.encode t).toList ++ rest) =
      (do
        let toks ← tokenizeFuel fuel rest
        .ok (TreeJson.tokens t ++ toks)) := by
  match t with
  | .null =>
    have h_fuel : (TreeJson.tokens .null).length + fuel = fuel + 1 := by
      dsimp [TreeJson.tokens]; omega
    rw [h_fuel]
    dsimp [TreeJson.tokens, TreeJson.encode]
    rfl
  | .bool true =>
    have h_fuel : (TreeJson.tokens (.bool true)).length + fuel = fuel + 1 := by
      dsimp [TreeJson.tokens]; omega
    rw [h_fuel]
    dsimp [TreeJson.tokens, TreeJson.encode]
    rfl
  | .bool false =>
    have h_fuel : (TreeJson.tokens (.bool false)).length + fuel = fuel + 1 := by
      dsimp [TreeJson.tokens]; omega
    rw [h_fuel]
    dsimp [TreeJson.tokens, TreeJson.encode]
    rfl
  | .num n =>
    have h_fuel : (TreeJson.tokens (.num n)).length + fuel = fuel + 1 := by
      dsimp [TreeJson.tokens]; omega
    rw [h_fuel]
    dsimp [TreeJson.tokens, TreeJson.encode]
    have h_tok := tokenizeFuel_int fuel n rest h_end
    rw [h_tok]
  | .str s =>
    have h_fuel : (TreeJson.tokens (.str s)).length + fuel = fuel + 1 := by
      dsimp [TreeJson.tokens]; omega
    rw [h_fuel]
    dsimp [TreeJson.tokens, TreeJson.encode]
    have h_tok := tokenizeFuel_escapeTreeString fuel s rest
    rw [h_tok]
  | .arr xs =>
    rw [encode_arr_toList]
    have h_fuel : (TreeJson.tokens (.arr xs)).length + fuel =
        ((TreeJson.tokensList xs).length + (fuel + 1)) + 1 := by
      dsimp [TreeJson.tokens]
      simp only [List.length_append, List.length_cons, List.length_nil]
      omega
    rw [h_fuel]
    rw [tokenizeFuel_lbracket]
    dsimp [bind, Except.bind]
    have h_ih : ∀ x ∈ xs, ∀ (fuel' : Nat) (rest' : List Char), NonDigitHead rest' →
        tokenizeFuel ((TreeJson.tokens x).length + fuel') ((TreeJson.encode x).toList ++ rest') =
          (do let toks ← tokenizeFuel fuel' rest'; .ok (TreeJson.tokens x ++ toks)) := by
      intro x hx f' r' he'
      have : TreeJson.size x < TreeJson.size (.arr xs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeList x xs hx
        omega
      exact tokenizeFuel_tree x f' r' he'
    rw [tokenizeFuel_encodeList xs h_ih (fuel + 1) (']' :: rest) (nonDigitHead_rbracket _)]
    dsimp [bind, Except.bind]
    rw [tokenizeFuel_rbracket]
    dsimp [bind, Except.bind]
    cases tokenizeFuel fuel rest with
    | error _ => rfl
    | ok toks => simp [TreeJson.tokens]
  | .obj kvs =>
    rw [encode_obj_toList]
    have h_fuel : (TreeJson.tokens (.obj kvs)).length + fuel =
        ((TreeJson.tokensObj kvs).length + (fuel + 1)) + 1 := by
      dsimp [TreeJson.tokens]
      simp only [List.length_append, List.length_cons, List.length_nil]
      omega
    rw [h_fuel]
    rw [tokenizeFuel_lbrace]
    dsimp [bind, Except.bind]
    have h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (fuel' : Nat) (rest' : List Char), NonDigitHead rest' →
        tokenizeFuel ((TreeJson.tokens v).length + fuel') ((TreeJson.encode v).toList ++ rest') =
          (do let toks ← tokenizeFuel fuel' rest'; .ok (TreeJson.tokens v ++ toks)) := by
      intro k v hv f' r' he'
      have : TreeJson.size v < TreeJson.size (.obj kvs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeObj k v kvs hv
        omega
      exact tokenizeFuel_tree v f' r' he'
    rw [tokenizeFuel_encodeObj kvs h_ih (fuel + 1) ('}' :: rest) (nonDigitHead_rbrace _)]
    dsimp [bind, Except.bind]
    rw [tokenizeFuel_rbrace]
    dsimp [bind, Except.bind]
    cases tokenizeFuel fuel rest with
    | error _ => rfl
    | ok toks => simp [TreeJson.tokens]
termination_by TreeJson.size t

/-- Universal canonical tokenizer inversion theorem:
    for any TreeJson value, tokenizing its serialized text produces exactly its canonical token sequence. -/
theorem tokenize_tree (t : TreeJson) :
    tokenize (TreeJson.encode t) = .ok (TreeJson.tokens t) := by
  dsimp [tokenize]
  have h_le := tokens_length_le_encode_length t
  have h_eq_fuel : (TreeJson.encode t).toList.length + 1 =
      (TreeJson.tokens t).length + ((TreeJson.encode t).toList.length - (TreeJson.tokens t).length + 1) := by
    omega
  rw [h_eq_fuel]
  have h_step := tokenizeFuel_tree t ((TreeJson.encode t).toList.length - (TreeJson.tokens t).length + 1) [] nonDigitHead_nil
  simp only [List.append_nil] at h_step
  rw [h_step]
  rw [tokenizeFuel_empty]
  dsimp [bind, Except.bind]
  simp only [List.append_nil]

/-- Universal canonical parser inversion theorem:
    any structurally admissible TreeJson within the 64 depth bound parses directly from its serialized characters
    to its semantic Lean.Json representation. -/
theorem parseCanonicalJson_tree (t : TreeJson) (h_valid : TreeJson.Valid t)
    (h_depth : TreeJson.depth t ≤ 64) :
    parseCanonicalJson (TreeJson.encode t) = .ok (TreeJson.toJson t) := by
  dsimp [parseCanonicalJson]
  rw [tokenize_tree t]
  dsimp [bind, Except.bind]
  exact parseTokens_tree_valid t h_valid h_depth

end DefiKernel.Certificates
