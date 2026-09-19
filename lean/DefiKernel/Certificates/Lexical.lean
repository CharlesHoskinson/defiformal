import DefiKernel.Certificates.Roundtrip
import DefiKernel.Certificates.CompositionDepth
import Mathlib.Tactic.IntervalCases

namespace DefiKernel.Certificates

set_option linter.style.longLine false
set_option linter.style.setOption false
set_option linter.style.maxHeartbeats false
set_option maxHeartbeats 4000000

open Lean

/-! Continuation lemmas for `scanLexicalFuel` on canonical `TreeJson.encode` fragments.
    Strings consume one outer scanner step; numbers remain buffered until a delimiter. -/

/-- False precisely when the scanner is waiting for an object key. Matches the R28
    `scanLexicalFuel_step_str_val` hypothesis. -/
def notExpectKey (scopes : List LexScope) : Prop :=
  match scopes with
  | LexScope.inObj _ true :: _ => false
  | _ => true

theorem notExpectKey_nil : notExpectKey [] := rfl

theorem notExpectKey_arr (cnt : Nat) (rest : List LexScope) :
    notExpectKey (LexScope.inArr cnt :: rest) := rfl

theorem notExpectKey_obj_val (keys : List String) (rest : List LexScope) :
    notExpectKey (LexScope.inObj keys false :: rest) := rfl

mutual
  /-- Outer scanner steps consumed by a canonical encoding (strings cost 1). -/
  def scanCost : TreeJson → Nat
    | .null => 4
    | .bool true => 4
    | .bool false => 5
    | .num n => (toString n).length
    | .str _ => 1
    | .arr xs => 2 + scanCostList xs
    | .obj kvs => 2 + scanCostObj kvs

  def scanCostList : List TreeJson → Nat
    | [] => 0
    | [x] => scanCost x
    | x :: xs => scanCost x + 1 + scanCostList xs

  def scanCostObj : List (String × TreeJson) → Nat
    | [] => 0
    | [(_, v)] => 2 + scanCost v
    | (_, v) :: kvs => 3 + scanCost v + scanCostObj kvs
end

def numBuf : TreeJson → List Char
  | .num n => (toString n).toList
  | _ => []

theorem encode_null_toList (rest : List Char) :
    (TreeJson.encode .null).toList ++ rest = 'n' :: 'u' :: 'l' :: 'l' :: rest := rfl

theorem encode_bool_true_toList (rest : List Char) :
    (TreeJson.encode (.bool true)).toList ++ rest = 't' :: 'r' :: 'u' :: 'e' :: rest := rfl

theorem encode_bool_false_toList (rest : List Char) :
    (TreeJson.encode (.bool false)).toList ++ rest =
      'f' :: 'a' :: 'l' :: 's' :: 'e' :: rest := rfl

theorem encodeList_nil_toList (rest : List Char) :
    (TreeJson.encodeList []).toList ++ rest = rest := rfl

theorem encodeList_singleton_toList (x : TreeJson) (rest : List Char) :
    (TreeJson.encodeList [x]).toList ++ rest = (TreeJson.encode x).toList ++ rest := by
  dsimp [TreeJson.encodeList]

/-- Consume a non-structural, non-numeric, non-whitespace character with an empty numeric buffer. -/
theorem scanLexicalFuel_other (fuel : Nat) (c : Char) (rest : List Char) (depth : Nat)
    (scopes : List LexScope)
    (h_quote : (c == '"') = false) (h_lbrace : (c == '{') = false)
    (h_rbrace : (c == '}') = false) (h_lbracket : (c == '[') = false)
    (h_rbracket : (c == ']') = false) (h_comma : (c == ',') = false)
    (h_colon : (c == ':') = false)
    (h_num : (((decide (c ≥ '0') && decide (c ≤ '9')) || (c == '-')) || (c == '.')) = false)
    (h_space : isSpace c = false) :
    scanLexicalFuel (fuel + 1) (c :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  rw [h_quote, h_lbrace, h_rbrace, h_lbracket, h_rbracket, h_comma, h_colon]
  simp only [Bool.false_eq_true, ↓reduceIte, Bool.true_and]
  rw [h_num]
  simp only [Bool.false_eq_true, ↓reduceIte]
  rw [h_space]
  simp only [Bool.false_eq_true, ↓reduceIte]

theorem scanLexicalFuel_n (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('n' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'n' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_u (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('u' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'u' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_l (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('l' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'l' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_t (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('t' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 't' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_r (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('r' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'r' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_e (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('e' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'e' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_f (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('f' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'f' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_a (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('a' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 'a' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_s (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('s' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false :=
  scanLexicalFuel_other fuel 's' rest depth scopes rfl rfl rfl rfl rfl rfl rfl rfl rfl

theorem scanLexicalFuel_null (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 4) ('n' :: 'u' :: 'l' :: 'l' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  have h₁ := scanLexicalFuel_n (fuel + 3) ('u' :: 'l' :: 'l' :: rest) depth scopes
  have h₂ := scanLexicalFuel_u (fuel + 2) ('l' :: 'l' :: rest) depth scopes
  have h₃ := scanLexicalFuel_l (fuel + 1) ('l' :: rest) depth scopes
  have h₄ := scanLexicalFuel_l fuel rest depth scopes
  simp only [Nat.add_assoc] at h₁
  rw [h₁, h₂, h₃, h₄]

theorem scanLexicalFuel_true (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 4) ('t' :: 'r' :: 'u' :: 'e' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  have h₁ := scanLexicalFuel_t (fuel + 3) ('r' :: 'u' :: 'e' :: rest) depth scopes
  have h₂ := scanLexicalFuel_r (fuel + 2) ('u' :: 'e' :: rest) depth scopes
  have h₃ := scanLexicalFuel_u (fuel + 1) ('e' :: rest) depth scopes
  have h₄ := scanLexicalFuel_e fuel rest depth scopes
  simp only [Nat.add_assoc] at h₁
  rw [h₁, h₂, h₃, h₄]

theorem scanLexicalFuel_false (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 5) ('f' :: 'a' :: 'l' :: 's' :: 'e' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  have h₁ := scanLexicalFuel_f (fuel + 4) ('a' :: 'l' :: 's' :: 'e' :: rest) depth scopes
  have h₂ := scanLexicalFuel_a (fuel + 3) ('l' :: 's' :: 'e' :: rest) depth scopes
  have h₃ := scanLexicalFuel_l (fuel + 2) ('s' :: 'e' :: rest) depth scopes
  have h₄ := scanLexicalFuel_s (fuel + 1) ('e' :: rest) depth scopes
  have h₅ := scanLexicalFuel_e fuel rest depth scopes
  simp only [Nat.add_assoc] at h₁
  rw [h₁, h₂, h₃, h₄, h₅]

theorem scanLexicalFuel_encode_null (fuel : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + scanCost .null) ((TreeJson.encode .null).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  dsimp [scanCost]
  rw [encode_null_toList]
  exact scanLexicalFuel_null fuel rest depth scopes

theorem scanLexicalFuel_encode_bool (fuel : Nat) (b : Bool) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + scanCost (.bool b))
        ((TreeJson.encode (.bool b)).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  cases b with
  | true =>
    dsimp [scanCost]
    rw [encode_bool_true_toList]
    exact scanLexicalFuel_true fuel rest depth scopes
  | false =>
    dsimp [scanCost]
    rw [encode_bool_false_toList]
    exact scanLexicalFuel_false fuel rest depth scopes

theorem scanLexicalFuel_str_value (fuel : Nat) (s : String) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h_not_key : notExpectKey scopes) :
    scanLexicalFuel (fuel + 1) ((escapeTreeString s).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  rw [escapeTreeString_eq]
  have h_app : ('"' :: (escapeChars s.toList ++ ['"'])) ++ rest =
      '"' :: (escapeChars s.toList ++ ('"' :: rest)) := by
    simp [List.append_assoc]
  rw [h_app]
  have h_lex := lexString_escapeJsonString s rest
  exact scanLexicalFuel_step_str_val fuel s (escapeChars s.toList ++ ('"' :: rest)) rest depth scopes
    h_not_key h_lex

theorem scanLexicalFuel_str_key (fuel : Nat) (s : String) (rest : List Char) (depth : Nat)
    (keys : List String) (restScopes : List LexScope)
    (h_nodup : keys.contains s = false) :
    scanLexicalFuel (fuel + 1) ((escapeTreeString s).toList ++ rest)
        depth (LexScope.inObj keys true :: restScopes) [] false =
      scanLexicalFuel fuel rest depth (LexScope.inObj (s :: keys) false :: restScopes) [] false := by
  rw [escapeTreeString_eq]
  have h_app : ('"' :: (escapeChars s.toList ++ ['"'])) ++ rest =
      '"' :: (escapeChars s.toList ++ ('"' :: rest)) := by
    simp [List.append_assoc]
  rw [h_app]
  have h_lex := lexString_escapeJsonString s rest
  exact scanLexicalFuel_step_key fuel s (escapeChars s.toList ++ ('"' :: rest)) rest depth keys restScopes
    h_lex h_nodup

theorem scanLexicalFuel_encode_str (fuel : Nat) (s : String) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h_not_key : notExpectKey scopes) :
    scanLexicalFuel (fuel + scanCost (.str s))
        ((TreeJson.encode (.str s)).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  dsimp [scanCost, TreeJson.encode]
  exact scanLexicalFuel_str_value fuel s rest depth scopes h_not_key

/-- Start a numeric buffer from an empty buffer on a digit or minus. -/
theorem scanLexicalFuel_num_start (fuel : Nat) (c : Char) (rest : List Char) (depth : Nat)
    (scopes : List LexScope)
    (h_start : ((decide (c ≥ '0') && decide (c ≤ '9')) || (c == '-') || (c == '.')) = true)
    (h_quote : (c == '"') = false) (h_lbrace : (c == '{') = false)
    (h_rbrace : (c == '}') = false) (h_lbracket : (c == '[') = false)
    (h_rbracket : (c == ']') = false) (h_comma : (c == ',') = false)
    (h_colon : (c == ':') = false) :
    scanLexicalFuel (fuel + 1) (c :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [c] false := by
  dsimp [scanLexicalFuel]
  rw [h_quote, h_lbrace, h_rbrace, h_lbracket, h_rbracket, h_comma, h_colon]
  simp only [Bool.false_eq_true, ↓reduceIte, Bool.true_and]
  rw [h_start]
  simp only [eq_self, ↓reduceIte]

/-- Continue a nonempty numeric buffer on a digit, sign, dot, or exponent character. -/
theorem scanLexicalFuel_num_cont (fuel : Nat) (c : Char) (buf : List Char) (rest : List Char)
    (depth : Nat) (scopes : List LexScope) (h_buf : buf ≠ [])
    (h_cont : ((decide (c ≥ '0') && decide (c ≤ '9')) || (c == '-') || (c == '+') ||
      (c == '.') || (c == 'e') || (c == 'E')) = true)
    (h_quote : (c == '"') = false) (h_lbrace : (c == '{') = false)
    (h_rbrace : (c == '}') = false) (h_lbracket : (c == '[') = false)
    (h_rbracket : (c == ']') = false) (h_comma : (c == ',') = false)
    (h_colon : (c == ':') = false) :
    scanLexicalFuel (fuel + 1) (c :: rest) depth scopes buf false =
      scanLexicalFuel fuel rest depth scopes (buf ++ [c]) false := by
  dsimp [scanLexicalFuel]
  rw [h_quote, h_lbrace, h_rbrace, h_lbracket, h_rbracket, h_comma, h_colon]
  have hne : buf.isEmpty = false := by
    cases buf with
    | nil => exact (h_buf rfl).elim
    | cons _ _ => rfl
  simp only [hne, Bool.false_eq_true, ↓reduceIte, Bool.not_false, Bool.false_and, Bool.true_and]
  rw [h_cont]
  simp only [eq_self, ↓reduceIte]

theorem digitChar_lt_10_isDigit (d : Nat) (h : d < 10) :
    ((decide (Nat.digitChar d ≥ '0') && decide (Nat.digitChar d ≤ '9'))) = true := by
  interval_cases d <;> simp [Nat.digitChar]

theorem isDigit_ge_le (c : Char) (h : c.isDigit = true) :
    (decide (c ≥ '0') && decide (c ≤ '9')) = true := by
  have hnat := Char.isDigit_iff_toNat.mp h
  have h0 : c ≥ '0' := by
    change '0'.val ≤ c.val
    rw [UInt32.le_iff_toNat_le, Char.toNat_val, Char.toNat_val]
    exact hnat.1
  have h9 : c ≤ '9' := by
    change c.val ≤ '9'.val
    rw [UInt32.le_iff_toNat_le, Char.toNat_val, Char.toNat_val]
    exact hnat.2
  simp [h0, h9]

theorem isDigit_num_start (c : Char) (h : c.isDigit = true) :
    ((decide (c ≥ '0') && decide (c ≤ '9')) || (c == '-') || (c == '.')) = true := by
  simp [isDigit_ge_le c h]

theorem isDigit_num_cont (c : Char) (h : c.isDigit = true) :
    ((decide (c ≥ '0') && decide (c ≤ '9')) || (c == '-') || (c == '+') ||
      (c == '.') || (c == 'e') || (c == 'E')) = true := by
  simp [isDigit_ge_le c h]

theorem isDigit_ne_nondigit (c d : Char) (hc : c.isDigit = true) (hd : d.isDigit = false) :
    (c == d) = false := by
  simp [beq_iff_eq]
  intro heq
  subst heq
  simp [hc] at hd

theorem isDigit_not_struct (c : Char) (h : c.isDigit = true) :
    (c == '"') = false ∧ (c == '{') = false ∧ (c == '}') = false ∧
    (c == '[') = false ∧ (c == ']') = false ∧ (c == ',') = false ∧
    (c == ':') = false := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    exact isDigit_ne_nondigit c _ h rfl

theorem minus_not_struct :
    (('-' == '"') = false) ∧ (('-' == '{') = false) ∧ (('-' == '}') = false) ∧
    (('-' == '[') = false) ∧ (('-' == ']') = false) ∧ (('-' == ',') = false) ∧
    (('-' == ':') = false) := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem minus_num_start :
    ((decide (('-' : Char) ≥ '0') && decide (('-' : Char) ≤ '9')) || ('-' == '-') ||
      ('-' == '.')) = true := rfl

theorem scanLexicalFuel_digit_start (fuel : Nat) (c : Char) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h : c.isDigit = true) :
    scanLexicalFuel (fuel + 1) (c :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [c] false := by
  have hs := isDigit_not_struct c h
  exact scanLexicalFuel_num_start fuel c rest depth scopes (isDigit_num_start c h)
    hs.1 hs.2.1 hs.2.2.1 hs.2.2.2.1 hs.2.2.2.2.1 hs.2.2.2.2.2.1 hs.2.2.2.2.2.2

theorem scanLexicalFuel_digit_cont (fuel : Nat) (c : Char) (buf rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h_buf : buf ≠ []) (h : c.isDigit = true) :
    scanLexicalFuel (fuel + 1) (c :: rest) depth scopes buf false =
      scanLexicalFuel fuel rest depth scopes (buf ++ [c]) false := by
  have hs := isDigit_not_struct c h
  exact scanLexicalFuel_num_cont fuel c buf rest depth scopes h_buf (isDigit_num_cont c h)
    hs.1 hs.2.1 hs.2.2.1 hs.2.2.2.1 hs.2.2.2.2.1 hs.2.2.2.2.2.1 hs.2.2.2.2.2.2

theorem scanLexicalFuel_digits_cont (fuel : Nat) (ds : List Char) (buf rest : List Char)
    (depth : Nat) (scopes : List LexScope) (h_buf : buf ≠ [])
    (h_dig : ∀ c ∈ ds, c.isDigit = true) :
    scanLexicalFuel (fuel + ds.length) (ds ++ rest) depth scopes buf false =
      scanLexicalFuel fuel rest depth scopes (buf ++ ds) false := by
  induction ds generalizing fuel buf with
  | nil =>
    simp
  | cons c ds ih =>
    have hc : c.isDigit = true := h_dig c (List.Mem.head _)
    have hds : ∀ x ∈ ds, x.isDigit = true := fun x hx => h_dig x (List.Mem.tail _ hx)
    have hstep := scanLexicalFuel_digit_cont (fuel + ds.length) c buf (ds ++ rest) depth scopes
      h_buf hc
    simp only [List.length_cons, Nat.add_comm ds.length, Nat.add_assoc] at hstep ⊢
    rw [List.cons_append, hstep]
    have hbuf' : buf ++ [c] ≠ [] := by
      cases buf <;> simp
    have hrest := ih fuel (buf ++ [c]) hbuf' hds
    simpa [List.append_assoc] using hrest

theorem scanLexicalFuel_nat (fuel : Nat) (n : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + (toString n).length)
        ((toString n).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (toString n).toList false := by
  have h_repr : (toString n).toList = Nat.toDigits 10 n := by
    change (Nat.repr n).toList = Nat.toDigits 10 n
    exact Nat.toList_repr
  rw [h_repr]
  rcases toDigits_nonempty n with ⟨c, tl, h_digits⟩
  rw [h_digits]
  have hl : ∀ x ∈ Nat.toDigits 10 n, x.isDigit = true := fun x hx =>
    Nat.isDigit_of_mem_toDigits (by decide) (by decide) hx
  have hc : c.isDigit = true := hl c (by simp [h_digits])
  have htl : ∀ x ∈ tl, x.isDigit = true := fun x hx =>
    hl x (by simp [h_digits, hx])
  have hlen : (toString n).length = (c :: tl).length := by
    rw [← String.length_toList, h_repr, h_digits]
  simp only [List.cons_append]
  have hstart := scanLexicalFuel_digit_start (fuel + tl.length) c (tl ++ rest) depth scopes hc
  have : fuel + (toString n).length = fuel + tl.length + 1 := by
    rw [hlen]
    simp [List.length_cons, Nat.add_assoc]
  rw [this, hstart]
  have hbuf : [c] ≠ [] := by simp
  have hcont := scanLexicalFuel_digits_cont fuel tl [c] rest depth scopes hbuf htl
  simpa [List.singleton_append] using hcont

theorem scanLexicalFuel_minus (fuel : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) ('-' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes ['-'] false := by
  have hs := minus_not_struct
  exact scanLexicalFuel_num_start fuel '-' rest depth scopes minus_num_start
    hs.1 hs.2.1 hs.2.2.1 hs.2.2.2.1 hs.2.2.2.2.1 hs.2.2.2.2.2.1 hs.2.2.2.2.2.2

theorem scanLexicalFuel_int (fuel : Nat) (i : Int) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + (toString i).length)
        ((toString i).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (toString i).toList false := by
  cases i with
  | ofNat n =>
    exact scanLexicalFuel_nat fuel n rest depth scopes
  | negSucc n =>
    have h_repr : (toString (Int.negSucc n)).toList = '-' :: (Nat.repr (n + 1)).toList := by
      change ("-" ++ Nat.repr (n + 1)).toList = '-' :: (Nat.repr (n + 1)).toList
      rw [String.toList_append]
      rfl
    have h_nat : (Nat.repr (n + 1)).toList = Nat.toDigits 10 (n + 1) := Nat.toList_repr
    have hlen : (toString (Int.negSucc n)).length = (Nat.repr (n + 1)).length + 1 := by
      rw [← String.length_toList, h_repr]
      simp only [List.length_cons]
      rw [String.length_toList]
    rw [h_repr]
    simp only [List.cons_append]
    have : fuel + (toString (Int.negSucc n)).length = fuel + (Nat.repr (n + 1)).length + 1 := by
      rw [hlen, Nat.add_assoc]
    rw [this]
    have hminus := scanLexicalFuel_minus (fuel + (Nat.repr (n + 1)).length)
      ((Nat.repr (n + 1)).toList ++ rest) depth scopes
    rw [hminus]
    have hbuf : ['-'] ≠ [] := by simp
    have hl : ∀ x ∈ Nat.toDigits 10 (n + 1), x.isDigit = true := fun x hx =>
      Nat.isDigit_of_mem_toDigits (by decide) (by decide) hx
    have htl : ∀ x ∈ (Nat.repr (n + 1)).toList, x.isDigit = true := by
      intro x hx
      rw [h_nat] at hx
      exact hl x hx
    have hcont := scanLexicalFuel_digits_cont fuel (Nat.repr (n + 1)).toList ['-'] rest
      depth scopes hbuf htl
    rw [← String.length_toList]
    simpa [List.singleton_append] using hcont

theorem scanLexicalFuel_encode_num (fuel : Nat) (n : Int) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) :
    scanLexicalFuel (fuel + scanCost (.num n))
        ((TreeJson.encode (.num n)).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (toString n).toList false := by
  dsimp [scanCost, TreeJson.encode, numBuf]
  exact scanLexicalFuel_int fuel n rest depth scopes

theorem ofList_contains_false_of_not_mem (cs : List Char) (c : Char) (h : c ∉ cs) :
    (String.ofList cs).contains c = false := by
  rw [String.contains_char_eq, String.toList_ofList]
  simp [h]

theorem toDigits_not_mem_dot_e (n : Nat) :
    ('.' ∉ Nat.toDigits 10 n) ∧ ('e' ∉ Nat.toDigits 10 n) ∧ ('E' ∉ Nat.toDigits 10 n) := by
  have hl : ∀ x ∈ Nat.toDigits 10 n, x.isDigit = true := fun x hx =>
    Nat.isDigit_of_mem_toDigits (by decide) (by decide) hx
  refine ⟨?_, ?_, ?_⟩ <;> intro hmem <;>
    have := hl _ hmem <;> simp at this

theorem scanLexicalCheckNum_nat (n : Nat) :
    scanLexicalCheckNum (toString n).toList = .ok () := by
  have h_repr : (toString n).toList = Nat.toDigits 10 n := by
    change (Nat.repr n).toList = Nat.toDigits 10 n
    exact Nat.toList_repr
  dsimp [scanLexicalCheckNum]
  have hne : ((toString n).toList).isEmpty = false := by
    have : 1 ≤ (toString n).toList.length := toString_nat_length_ge_one n
    cases hcs : (toString n).toList with
    | nil =>
      rw [hcs] at this
      simp at this
    | cons _ _ => rfl
  simp only [hne, Bool.not_false]
  have ⟨hd, he, hE⟩ := toDigits_not_mem_dot_e n
  have hdot : (String.ofList (toString n).toList).contains '.' = false := by
    rw [h_repr]; exact ofList_contains_false_of_not_mem _ _ hd
  have he' : (String.ofList (toString n).toList).contains 'e' = false := by
    rw [h_repr]; exact ofList_contains_false_of_not_mem _ _ he
  have hE' : (String.ofList (toString n).toList).contains 'E' = false := by
    rw [h_repr]; exact ofList_contains_false_of_not_mem _ _ hE
  rw [hdot, he', hE']
  simp

theorem scanLexicalCheckNum_int (i : Int) :
    scanLexicalCheckNum (toString i).toList = .ok () := by
  cases i with
  | ofNat n => exact scanLexicalCheckNum_nat n
  | negSucc n =>
    have h_repr : (toString (Int.negSucc n)).toList = '-' :: (Nat.repr (n + 1)).toList := by
      change ("-" ++ Nat.repr (n + 1)).toList = '-' :: (Nat.repr (n + 1)).toList
      rw [String.toList_append]
      rfl
    have h_nat : (Nat.repr (n + 1)).toList = Nat.toDigits 10 (n + 1) := Nat.toList_repr
    dsimp [scanLexicalCheckNum]
    have hne : ((toString (Int.negSucc n)).toList).isEmpty = false := by
      rw [h_repr]; rfl
    simp only [hne, Bool.not_false]
    have ⟨hd, he, hE⟩ := toDigits_not_mem_dot_e (n + 1)
    have hmem (c : Char) (hc : c ∈ (toString (Int.negSucc n)).toList) :
        c = '-' ∨ c ∈ Nat.toDigits 10 (n + 1) := by
      rw [h_repr, h_nat] at hc
      simpa using hc
    have hdot : (String.ofList (toString (Int.negSucc n)).toList).contains '.' = false := by
      apply ofList_contains_false_of_not_mem
      intro hmem'
      have := hmem '.' hmem'
      rcases this with h | h
      · cases h
      · exact hd h
    have he' : (String.ofList (toString (Int.negSucc n)).toList).contains 'e' = false := by
      apply ofList_contains_false_of_not_mem
      intro hmem'
      have := hmem 'e' hmem'
      rcases this with h | h
      · cases h
      · exact he h
    have hE' : (String.ofList (toString (Int.negSucc n)).toList).contains 'E' = false := by
      apply ofList_contains_false_of_not_mem
      intro hmem'
      have := hmem 'E' hmem'
      rcases this with h | h
      · cases h
      · exact hE h
    rw [hdot, he', hE']
    simp

theorem scanLexicalCheckNum_numBuf (t : TreeJson) :
    scanLexicalCheckNum (numBuf t) = .ok () := by
  cases t with
  | num n => exact scanLexicalCheckNum_int n
  | null | bool _ | str _ | arr _ | obj _ => simp [numBuf, scanLexicalCheckNum]

theorem scanLexicalFuel_comma_arr_flush (fuel : Nat) (rest : List Char) (depth : Nat)
    (cnt : Nat) (h_cnt : cnt + 1 ≤ 4096) (restScopes : List LexScope) (buf : List Char)
    (h_ok : scanLexicalCheckNum buf = .ok ()) :
    scanLexicalFuel (fuel + 1) (',' :: rest) depth (LexScope.inArr cnt :: restScopes) buf false =
      scanLexicalFuel fuel rest depth (LexScope.inArr (cnt + 1) :: restScopes) [] false := by
  dsimp [scanLexicalFuel]
  rw [h_ok]
  dsimp
  have : ¬ (cnt + 1 > 4096) := by omega
  rw [if_neg this]

theorem scanLexicalFuel_comma_obj_flush (fuel : Nat) (rest : List Char) (depth : Nat)
    (keys : List String) (restScopes : List LexScope) (buf : List Char)
    (h_ok : scanLexicalCheckNum buf = .ok ()) :
    scanLexicalFuel (fuel + 1) (',' :: rest) depth (LexScope.inObj keys false :: restScopes) buf false =
      scanLexicalFuel fuel rest depth (LexScope.inObj keys true :: restScopes) [] false := by
  dsimp [scanLexicalFuel]
  rw [h_ok]

theorem scanLexicalFuel_rbrace_flush (fuel : Nat) (rest : List Char) (depth : Nat)
    (sc : LexScope) (scopes : List LexScope) (buf : List Char)
    (h_depth : depth > 0) (h_ok : scanLexicalCheckNum buf = .ok ()) :
    scanLexicalFuel (fuel + 1) ('}' :: rest) depth (sc :: scopes) buf false =
      scanLexicalFuel fuel rest (depth - 1) scopes [] false := by
  dsimp [scanLexicalFuel]
  rw [h_ok]
  dsimp
  have : (if depth > 0 then depth - 1 else 0) = depth - 1 := if_pos h_depth
  rw [this]

theorem scanLexicalFuel_rbracket_flush (fuel : Nat) (rest : List Char) (depth : Nat)
    (sc : LexScope) (scopes : List LexScope) (buf : List Char)
    (h_depth : depth > 0) (h_ok : scanLexicalCheckNum buf = .ok ()) :
    scanLexicalFuel (fuel + 1) (']' :: rest) depth (sc :: scopes) buf false =
      scanLexicalFuel fuel rest (depth - 1) scopes [] false := by
  dsimp [scanLexicalFuel]
  rw [h_ok]
  dsimp
  have : (if depth > 0 then depth - 1 else 0) = depth - 1 := if_pos h_depth
  rw [this]

theorem contains_eq_false_of_not_mem (keys : List String) (s : String) (h : s ∉ keys) :
    keys.contains s = false := by
  simpa [List.contains_iff_mem] using h

theorem scanCost_arr_nil : scanCost (.arr []) = 2 := rfl
theorem scanCost_obj_nil : scanCost (.obj []) = 2 := rfl

theorem scanLexicalFuel_encode_arr_nil (fuel : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h_depth : depth + 1 ≤ 64) :
    scanLexicalFuel (fuel + scanCost (.arr []))
        ((TreeJson.encode (.arr [])).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  rw [scanCost_arr_nil, encode_arr_toList, encodeList_nil_toList]
  have hopen := scanLexicalFuel_lbracket (fuel + 1) (']' :: rest) depth scopes h_depth
  rw [hopen]
  exact scanLexicalFuel_rbracket_flush fuel rest (depth + 1) (LexScope.inArr 0) scopes []
    (by omega) scanLexicalCheckNum_nil

theorem scanLexicalFuel_encode_obj_nil (fuel : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope) (h_depth : depth + 1 ≤ 64) :
    scanLexicalFuel (fuel + scanCost (.obj []))
        ((TreeJson.encode (.obj [])).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := by
  rw [scanCost_obj_nil, encode_obj_toList]
  have hempty : (TreeJson.encodeObj []).toList ++ ('}' :: rest) = '}' :: rest := rfl
  rw [hempty]
  have hopen := scanLexicalFuel_lbrace (fuel + 1) ('}' :: rest) depth scopes h_depth
  rw [hopen]
  exact scanLexicalFuel_rbrace_flush fuel rest (depth + 1) (LexScope.inObj [] true) scopes []
    (by omega) scanLexicalCheckNum_nil

/-- Scalar and empty-container continuation: numbers remain buffered; other scalars clear. -/
theorem scanLexicalFuel_encode_scalar (t : TreeJson) (fuel : Nat) (rest : List Char)
    (depth : Nat) (scopes : List LexScope) (h_not_key : notExpectKey scopes)
    (h_depth : depth + t.depth ≤ 64)
    (h_scalar : match t with | .arr (_ :: _) | .obj (_ :: _) => False | _ => True) :
    scanLexicalFuel (fuel + scanCost t) ((TreeJson.encode t).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (numBuf t) false := by
  cases t with
  | null =>
    simpa [numBuf] using scanLexicalFuel_encode_null fuel rest depth scopes
  | bool b =>
    simpa [numBuf] using scanLexicalFuel_encode_bool fuel b rest depth scopes
  | num n =>
    simpa [numBuf] using scanLexicalFuel_encode_num fuel n rest depth scopes
  | str s =>
    simpa [numBuf] using scanLexicalFuel_encode_str fuel s rest depth scopes h_not_key
  | arr xs =>
    cases xs with
    | nil =>
      simpa [numBuf] using scanLexicalFuel_encode_arr_nil fuel rest depth scopes (by
        dsimp [TreeJson.depth] at h_depth; omega)
    | cons _ _ => exact h_scalar.elim
  | obj kvs =>
    cases kvs with
    | nil =>
      simpa [numBuf] using scanLexicalFuel_encode_obj_nil fuel rest depth scopes (by
        dsimp [TreeJson.depth] at h_depth; omega)
    | cons _ _ => exact h_scalar.elim

theorem scanCost_arr (xs : List TreeJson) : scanCost (.arr xs) = 2 + scanCostList xs := rfl
theorem scanCost_obj (kvs : List (String × TreeJson)) : scanCost (.obj kvs) = 2 + scanCostObj kvs := rfl
theorem scanCostList_nil : scanCostList [] = 0 := rfl
theorem scanCostList_singleton (x : TreeJson) : scanCostList [x] = scanCost x := rfl
theorem scanCostList_cons_cons (x y : TreeJson) (ys : List TreeJson) :
    scanCostList (x :: y :: ys) = scanCost x + 1 + scanCostList (y :: ys) := rfl
theorem scanCostObj_nil : scanCostObj [] = 0 := rfl
theorem scanCostObj_singleton (k : String) (v : TreeJson) :
    scanCostObj [(k, v)] = 2 + scanCost v := rfl
theorem scanCostObj_cons_cons (k : String) (v : TreeJson) (f2 : String × TreeJson)
    (kvs' : List (String × TreeJson)) :
    scanCostObj ((k, v) :: f2 :: kvs') = 3 + scanCost v + scanCostObj (f2 :: kvs') := rfl

/-- Numeric buffer left after scanning a canonical array-element encoding. -/
def lastNumBufList : List TreeJson → List Char
  | [] => []
  | [x] => numBuf x
  | _ :: xs => lastNumBufList xs

/-- Numeric buffer left after scanning a canonical object-field encoding. -/
def lastNumBufObj : List (String × TreeJson) → List Char
  | [] => []
  | [(_, v)] => numBuf v
  | _ :: kvs => lastNumBufObj kvs

theorem lastNumBufList_nil : lastNumBufList [] = [] := rfl
theorem lastNumBufList_singleton (x : TreeJson) : lastNumBufList [x] = numBuf x := rfl
theorem lastNumBufList_cons_cons (x y : TreeJson) (ys : List TreeJson) :
    lastNumBufList (x :: y :: ys) = lastNumBufList (y :: ys) := rfl
theorem lastNumBufObj_nil : lastNumBufObj [] = [] := rfl
theorem lastNumBufObj_singleton (k : String) (v : TreeJson) :
    lastNumBufObj [(k, v)] = numBuf v := rfl
theorem lastNumBufObj_cons_cons (k : String) (v : TreeJson) (f2 : String × TreeJson)
    (kvs' : List (String × TreeJson)) :
    lastNumBufObj ((k, v) :: f2 :: kvs') = lastNumBufObj (f2 :: kvs') := rfl

theorem scanLexicalCheckNum_lastNumBufList (xs : List TreeJson) :
    scanLexicalCheckNum (lastNumBufList xs) = .ok () := by
  induction xs with
  | nil => simp [lastNumBufList, scanLexicalCheckNum]
  | cons x xs ih =>
    cases xs with
    | nil => simpa [lastNumBufList] using scanLexicalCheckNum_numBuf x
    | cons y ys => simpa [lastNumBufList] using ih

theorem scanLexicalCheckNum_lastNumBufObj (kvs : List (String × TreeJson)) :
    scanLexicalCheckNum (lastNumBufObj kvs) = .ok () := by
  induction kvs with
  | nil => simp [lastNumBufObj, scanLexicalCheckNum]
  | cons f kvs ih =>
    rcases f with ⟨k, v⟩
    cases kvs with
    | nil => simpa [lastNumBufObj] using scanLexicalCheckNum_numBuf v
    | cons f2 kvs' => simpa [lastNumBufObj] using ih

theorem depth_le_depthList (x : TreeJson) (xs : List TreeJson) (hx : x ∈ xs) :
    TreeJson.depth x ≤ TreeJson.depthList xs := by
  induction xs with
  | nil => contradiction
  | cons y ys ih =>
    dsimp [TreeJson.depthList]
    cases hx with
    | head => omega
    | tail _ h =>
      have := ih h
      omega

theorem depth_le_depthObj (k : String) (v : TreeJson) (kvs : List (String × TreeJson))
    (h : (k, v) ∈ kvs) :
    TreeJson.depth v ≤ TreeJson.depthObj kvs := by
  induction kvs with
  | nil => contradiction
  | cons f fs ih =>
    rcases f with ⟨k', v'⟩
    dsimp [TreeJson.depthObj]
    cases h with
    | head => omega
    | tail _ h_in =>
      have := ih h_in
      omega

theorem depthList_tail_le (x : TreeJson) (xs : List TreeJson) :
    TreeJson.depthList xs ≤ TreeJson.depthList (x :: xs) := by
  dsimp [TreeJson.depthList]
  omega

theorem depthObj_tail_le (k : String) (v : TreeJson) (kvs : List (String × TreeJson)) :
    TreeJson.depthObj kvs ≤ TreeJson.depthObj ((k, v) :: kvs) := by
  dsimp [TreeJson.depthObj]
  omega

/-- Value-fragment continuation hypothesis used by array-element induction. -/
def ScanEncodeIH (xs : List TreeJson) : Prop :=
  ∀ x ∈ xs, ∀ (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope),
    notExpectKey scopes →
    depth + TreeJson.depth x ≤ 64 →
    TreeJson.Valid x →
    scanLexicalFuel (fuel + scanCost x) ((TreeJson.encode x).toList ++ rest)
        depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (numBuf x) false

/-- Value-fragment continuation hypothesis used by object-field induction. -/
def ScanEncodeObjIH (kvs : List (String × TreeJson)) : Prop :=
  ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs → ∀ (fuel : Nat) (rest : List Char) (depth : Nat)
    (scopes : List LexScope),
    notExpectKey scopes →
    depth + TreeJson.depth v ≤ 64 →
    TreeJson.Valid v →
    scanLexicalFuel (fuel + scanCost v) ((TreeJson.encode v).toList ++ rest)
        depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (numBuf v) false

theorem ScanEncodeIH_tail (x : TreeJson) (xs : List TreeJson) (h : ScanEncodeIH (x :: xs)) :
    ScanEncodeIH xs :=
  fun y hy => h y (List.Mem.tail x hy)

theorem ScanEncodeObjIH_tail (k : String) (v : TreeJson) (kvs : List (String × TreeJson))
    (h : ScanEncodeObjIH ((k, v) :: kvs)) :
    ScanEncodeObjIH kvs :=
  fun k' v' hy => h k' v' (List.Mem.tail (k, v) hy)

theorem key_not_mem_visited (kvs : List (String × TreeJson)) (visited : List String)
    (k : String) (v : TreeJson) (h_mem : (k, v) ∈ kvs)
    (h_disj : (kvs.map Prod.fst).Disjoint visited) :
    k ∉ visited :=
  fun hvis => h_disj (List.mem_map.mpr ⟨(k, v), h_mem, rfl⟩) hvis

theorem disjoint_tail_cons_visited (k : String) (v : TreeJson)
    (kvs : List (String × TreeJson)) (visited : List String)
    (h_nodup : (((k, v) :: kvs).map Prod.fst).Nodup)
    (h_disj : (((k, v) :: kvs).map Prod.fst).Disjoint visited) :
    (kvs.map Prod.fst).Disjoint (k :: visited) := by
  intro a ha hmem
  have ha_all : a ∈ ((k, v) :: kvs).map Prod.fst := by
    simp only [List.map_cons, List.mem_cons]
    exact Or.inr ha
  cases hmem with
  | head =>
    have h_keys : ((k, v) :: kvs).map Prod.fst = k :: kvs.map Prod.fst := rfl
    have hnod : (k :: kvs.map Prod.fst).Nodup := by
      rw [← h_keys]
      exact h_nodup
    exact (List.nodup_cons.mp hnod).1 ha
  | tail _ hvis =>
    exact h_disj ha_all hvis

theorem isSpace_lbrace : isSpace '{' = false := rfl
theorem not_isSpace_lbrace : (!isSpace '{') = true := rfl

theorem scanCostList_le_encodeList_length (xs : List TreeJson)
    (h_ih : ∀ x ∈ xs, scanCost x ≤ (TreeJson.encode x).toList.length) :
    scanCostList xs ≤ (TreeJson.encodeList xs).toList.length := by
  induction xs with
  | nil =>
    dsimp [scanCostList, TreeJson.encodeList]
    omega
  | cons x tl ih =>
    cases tl with
    | nil =>
      dsimp [scanCostList, TreeJson.encodeList]
      exact h_ih x (List.Mem.head [])
    | cons x2 xs' =>
      dsimp [scanCostList, TreeJson.encodeList]
      repeat rw [String.toList_append]
      rw [toList_comma]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have hx := h_ih x (List.Mem.head _)
      have htl := ih (fun y hy => h_ih y (List.Mem.tail x hy))
      omega

theorem scanCostObj_le_encodeObj_length (kvs : List (String × TreeJson))
    (h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs →
      scanCost v ≤ (TreeJson.encode v).toList.length) :
    scanCostObj kvs ≤ (TreeJson.encodeObj kvs).toList.length := by
  induction kvs with
  | nil =>
    dsimp [scanCostObj, TreeJson.encodeObj]
    omega
  | cons f tl ih =>
    rcases f with ⟨k, v⟩
    cases tl with
    | nil =>
      dsimp [scanCostObj, TreeJson.encodeObj]
      repeat rw [String.toList_append]
      rw [toList_colon]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have hv := h_ih k v (List.Mem.head [])
      have hk := escapeTreeString_length_ge_two k
      omega
    | cons f2 kvs' =>
      dsimp [scanCostObj, TreeJson.encodeObj]
      repeat rw [String.toList_append]
      rw [toList_colon, toList_comma]
      simp only [List.length_append, List.length_cons, List.length_nil]
      have hv := h_ih k v (List.Mem.head _)
      have hk := escapeTreeString_length_ge_two k
      have htl := ih (fun k' v' hy => h_ih k' v' (List.Mem.tail (k, v) hy))
      omega

theorem scanCost_le_encode_length (t : TreeJson) :
    scanCost t ≤ (TreeJson.encode t).toList.length := by
  match t with
  | .null =>
    dsimp [scanCost, TreeJson.encode]
    decide
  | .bool true =>
    dsimp [scanCost, TreeJson.encode]
    decide
  | .bool false =>
    dsimp [scanCost, TreeJson.encode]
    decide
  | .num n =>
    dsimp [scanCost, TreeJson.encode]
    exact Nat.le_of_eq String.length_toList.symm
  | .str s =>
    dsimp [scanCost, TreeJson.encode]
    have := escapeTreeString_length_ge_two s
    omega
  | .arr xs =>
    dsimp [scanCost, TreeJson.encode]
    repeat rw [String.toList_append]
    rw [toList_lbracket, toList_rbracket]
    simp only [List.length_append, List.length_cons, List.length_nil]
    have h_ih : ∀ x ∈ xs, scanCost x ≤ (TreeJson.encode x).toList.length := by
      intro x hx
      have : TreeJson.size x < TreeJson.size (.arr xs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeList x xs hx
        omega
      exact scanCost_le_encode_length x
    have h_list := scanCostList_le_encodeList_length xs h_ih
    omega
  | .obj kvs =>
    dsimp [scanCost, TreeJson.encode]
    repeat rw [String.toList_append]
    rw [toList_lbrace, toList_rbrace]
    simp only [List.length_append, List.length_cons, List.length_nil]
    have h_ih : ∀ (k : String) (v : TreeJson), (k, v) ∈ kvs →
        scanCost v ≤ (TreeJson.encode v).toList.length := by
      intro k v hv
      have : TreeJson.size v < TreeJson.size (.obj kvs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeObj k v kvs hv
        omega
      exact scanCost_le_encode_length v
    have h_obj := scanCostObj_le_encodeObj_length kvs h_ih
    omega
termination_by TreeJson.size t

/-- Continuation of `scanLexicalFuel` across a canonical array-element encoding.
    Array scope counts increment on commas; `cnt + xs.length ≤ 4096` covers every guard. -/
theorem scanLexicalFuel_encodeList (xs : List TreeJson)
    (h_ih : ScanEncodeIH xs)
    (fuel : Nat) (rest : List Char) (depth : Nat) (cnt : Nat)
    (restScopes : List LexScope)
    (h_depth : depth + TreeJson.depthList xs ≤ 64)
    (h_valid : TreeJson.ValidList xs)
    (h_cnt : cnt + xs.length ≤ 4096) :
    scanLexicalFuel (fuel + scanCostList xs)
        ((TreeJson.encodeList xs).toList ++ rest)
        depth (LexScope.inArr cnt :: restScopes) [] false =
      scanLexicalFuel fuel rest depth
        (LexScope.inArr (cnt + (xs.length - 1)) :: restScopes)
        (lastNumBufList xs) false := by
  induction xs generalizing fuel rest cnt with
  | nil =>
    simp [scanCostList, TreeJson.encodeList, lastNumBufList]
  | cons x tl ih =>
    cases tl with
    | nil =>
      dsimp [scanCostList, lastNumBufList]
      rw [encodeList_singleton_toList]
      have hx := h_ih x (List.Mem.head []) fuel rest depth
        (LexScope.inArr cnt :: restScopes) (notExpectKey_arr cnt restScopes)
        (by
          dsimp [TreeJson.depthList] at h_depth
          omega)
        (by
          dsimp [TreeJson.ValidList] at h_valid
          exact h_valid.1)
      simpa using hx
    | cons x2 xs' =>
      rw [encodeList_cons_cons_toList, scanCostList_cons_cons]
      have h_fuel : fuel + (scanCost x + 1 + scanCostList (x2 :: xs')) =
          (fuel + 1 + scanCostList (x2 :: xs')) + scanCost x := by omega
      rw [h_fuel]
      have hx := h_ih x (List.Mem.head _) (fuel + 1 + scanCostList (x2 :: xs'))
          (',' :: ((TreeJson.encodeList (x2 :: xs')).toList ++ rest))
          depth (LexScope.inArr cnt :: restScopes) (notExpectKey_arr cnt restScopes)
          (by
            dsimp [TreeJson.depthList] at h_depth
            omega)
          (by
            dsimp [TreeJson.ValidList] at h_valid
            exact h_valid.1)
      rw [hx]
      have h_assoc : fuel + 1 + scanCostList (x2 :: xs') =
          fuel + scanCostList (x2 :: xs') + 1 := by omega
      rw [h_assoc]
      have h_comma := scanLexicalFuel_comma_arr_flush (fuel + scanCostList (x2 :: xs'))
          ((TreeJson.encodeList (x2 :: xs')).toList ++ rest) depth cnt
          (by
            have : (x :: x2 :: xs').length = xs'.length + 2 := by simp
            omega)
          restScopes (numBuf x) (scanLexicalCheckNum_numBuf x)
      rw [h_comma]
      have hrest := ih (ScanEncodeIH_tail x (x2 :: xs') h_ih) fuel rest (cnt + 1)
          (by
            dsimp [TreeJson.depthList] at h_depth ⊢
            omega)
          (by
            dsimp [TreeJson.ValidList] at h_valid
            exact h_valid.2)
          (by
            have : (x :: x2 :: xs').length = (x2 :: xs').length + 1 := by simp
            omega)
      have hbuf : lastNumBufList (x :: x2 :: xs') = lastNumBufList (x2 :: xs') :=
        lastNumBufList_cons_cons x x2 xs'
      have hcntEq : cnt + ((x :: x2 :: xs').length - 1) =
          cnt + 1 + ((x2 :: xs').length - 1) := by
        simp [List.length_cons]
        omega
      rw [hbuf, hcntEq]
      exact hrest

/-- Object scope after scanning canonical fields: empty keeps `expectKey`; nonempty prepends keys. -/
def afterObj (kvs : List (String × TreeJson)) (visited : List String) : LexScope :=
  match kvs with
  | [] => LexScope.inObj visited true
  | _ => LexScope.inObj ((kvs.map Prod.fst).reverse ++ visited) false

theorem afterObj_nil (visited : List String) :
    afterObj [] visited = LexScope.inObj visited true := rfl

theorem afterObj_singleton (k : String) (v : TreeJson) (visited : List String) :
    afterObj [(k, v)] visited = LexScope.inObj (k :: visited) false := by
  simp [afterObj]

theorem afterObj_cons_cons (k : String) (v : TreeJson) (f2 : String × TreeJson)
    (kvs' : List (String × TreeJson)) (visited : List String) :
    afterObj ((k, v) :: f2 :: kvs') visited = afterObj (f2 :: kvs') (k :: visited) := by
  simp [afterObj, List.reverse_cons, List.append_assoc]

theorem encodeObj_nil_toList (rest : List Char) :
    (TreeJson.encodeObj []).toList ++ rest = rest := rfl

/-- Continuation of `scanLexicalFuel` across a canonical object-field encoding.
    Remaining keys stay disjoint from visited keys; `TreeJson.Valid` supplies `Nodup`. -/
theorem scanLexicalFuel_encodeObj (kvs : List (String × TreeJson))
    (h_ih : ScanEncodeObjIH kvs)
    (fuel : Nat) (rest : List Char) (depth : Nat)
    (visited : List String) (restScopes : List LexScope)
    (h_depth : depth + TreeJson.depthObj kvs ≤ 64)
    (h_valid : TreeJson.ValidObj kvs)
    (h_nodup : (kvs.map Prod.fst).Nodup)
    (h_disj : (kvs.map Prod.fst).Disjoint visited) :
    scanLexicalFuel (fuel + scanCostObj kvs)
        ((TreeJson.encodeObj kvs).toList ++ rest)
        depth (LexScope.inObj visited true :: restScopes) [] false =
      scanLexicalFuel fuel rest depth
        (afterObj kvs visited :: restScopes)
        (lastNumBufObj kvs) false := by
  induction kvs generalizing fuel rest visited with
  | nil =>
    simp [scanCostObj, TreeJson.encodeObj, lastNumBufObj, afterObj]
  | cons f tl ih =>
    rcases f with ⟨k, v⟩
    cases tl with
    | nil =>
      rw [encodeObj_singleton_toList, scanCostObj_singleton]
      have h_fuel : fuel + (2 + scanCost v) = (fuel + scanCost v + 1) + 1 := by omega
      rw [h_fuel]
      have hnod : visited.contains k = false :=
        contains_eq_false_of_not_mem visited k
          (key_not_mem_visited [(k, v)] visited k v (List.Mem.head []) h_disj)
      have hk := scanLexicalFuel_str_key (fuel + scanCost v + 1) k
          (':' :: ((TreeJson.encode v).toList ++ rest)) depth visited restScopes hnod
      rw [hk]
      have hcol := scanLexicalFuel_colon (fuel + scanCost v)
          ((TreeJson.encode v).toList ++ rest) depth
          (LexScope.inObj (k :: visited) false :: restScopes)
      rw [hcol]
      have hv := h_ih k v (List.Mem.head []) fuel rest depth
          (LexScope.inObj (k :: visited) false :: restScopes)
          (notExpectKey_obj_val (k :: visited) restScopes)
          (by
            dsimp [TreeJson.depthObj] at h_depth
            omega)
          (by
            dsimp [TreeJson.ValidObj] at h_valid
            exact h_valid.1)
      rw [hv]
      simp [afterObj, lastNumBufObj]
    | cons f2 kvs' =>
      rw [encodeObj_cons_cons_toList, scanCostObj_cons_cons]
      have h_fuel : fuel + (3 + scanCost v + scanCostObj (f2 :: kvs')) =
          ((fuel + scanCostObj (f2 :: kvs') + 1 + scanCost v) + 1) + 1 := by omega
      rw [h_fuel]
      have hnod : visited.contains k = false :=
        contains_eq_false_of_not_mem visited k
          (key_not_mem_visited ((k, v) :: f2 :: kvs') visited k v (List.Mem.head _) h_disj)
      have hk := scanLexicalFuel_str_key
          (fuel + scanCostObj (f2 :: kvs') + 1 + scanCost v + 1) k
          (':' :: ((TreeJson.encode v).toList ++
            (',' :: ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest))))
          depth visited restScopes hnod
      rw [hk]
      have hcol := scanLexicalFuel_colon
          (fuel + scanCostObj (f2 :: kvs') + 1 + scanCost v)
          ((TreeJson.encode v).toList ++
            (',' :: ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest)))
          depth (LexScope.inObj (k :: visited) false :: restScopes)
      rw [hcol]
      have hv := h_ih k v (List.Mem.head _) (fuel + scanCostObj (f2 :: kvs') + 1)
          (',' :: ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest))
          depth (LexScope.inObj (k :: visited) false :: restScopes)
          (notExpectKey_obj_val (k :: visited) restScopes)
          (by
            dsimp [TreeJson.depthObj] at h_depth
            omega)
          (by
            dsimp [TreeJson.ValidObj] at h_valid
            exact h_valid.1)
      rw [hv]
      have h_comma := scanLexicalFuel_comma_obj_flush (fuel + scanCostObj (f2 :: kvs'))
          ((TreeJson.encodeObj (f2 :: kvs')).toList ++ rest) depth (k :: visited) restScopes
          (numBuf v) (scanLexicalCheckNum_numBuf v)
      have h_fuel_comma : fuel + scanCostObj (f2 :: kvs') + 1 =
          (fuel + scanCostObj (f2 :: kvs')) + 1 := by omega
      rw [h_fuel_comma, h_comma]
      have hrest := ih (ScanEncodeObjIH_tail k v (f2 :: kvs') h_ih) fuel rest (k :: visited)
          (by
            dsimp [TreeJson.depthObj] at h_depth ⊢
            omega)
          (by
            dsimp [TreeJson.ValidObj] at h_valid
            exact h_valid.2)
          (by
            have h_keys : ((k, v) :: f2 :: kvs').map Prod.fst =
                k :: (f2 :: kvs').map Prod.fst := rfl
            rw [h_keys] at h_nodup
            exact (List.nodup_cons.mp h_nodup).2)
          (disjoint_tail_cons_visited k v (f2 :: kvs') visited h_nodup h_disj)
      have hbuf : lastNumBufObj ((k, v) :: f2 :: kvs') = lastNumBufObj (f2 :: kvs') :=
        lastNumBufObj_cons_cons k v f2 kvs'
      rw [hbuf, afterObj_cons_cons]
      exact hrest

/-- Universal continuation: scanning a canonical `TreeJson.encode` fragment returns to the
    caller with the numeric buffer of that fragment. Numbers stay buffered; other nodes clear. -/
theorem scanLexicalFuel_encode (t : TreeJson) (fuel : Nat) (rest : List Char)
    (depth : Nat) (scopes : List LexScope)
    (h_not_key : notExpectKey scopes)
    (h_depth : depth + TreeJson.depth t ≤ 64)
    (h_valid : TreeJson.Valid t) :
    scanLexicalFuel (fuel + scanCost t) ((TreeJson.encode t).toList ++ rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes (numBuf t) false := by
  match t with
  | .null =>
    simpa [numBuf] using scanLexicalFuel_encode_null fuel rest depth scopes
  | .bool b =>
    simpa [numBuf] using scanLexicalFuel_encode_bool fuel b rest depth scopes
  | .num n =>
    simpa [numBuf] using scanLexicalFuel_encode_num fuel n rest depth scopes
  | .str s =>
    simpa [numBuf] using scanLexicalFuel_encode_str fuel s rest depth scopes h_not_key
  | .arr xs =>
    rw [encode_arr_toList, scanCost_arr]
    have h_fuel : fuel + (2 + scanCostList xs) = (fuel + 1 + scanCostList xs) + 1 := by omega
    rw [h_fuel]
    have hopen := scanLexicalFuel_lbracket (fuel + 1 + scanCostList xs)
        ((TreeJson.encodeList xs).toList ++ (']' :: rest)) depth scopes
        (by
          dsimp [TreeJson.depth] at h_depth
          omega)
    rw [hopen]
    have h_ih : ScanEncodeIH xs := by
      intro x hx fuel' rest' depth' scopes' hnk hd hv
      have : TreeJson.size x < TreeJson.size (.arr xs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeList x xs hx
        omega
      exact scanLexicalFuel_encode x fuel' rest' depth' scopes' hnk hd hv
    have hlist := scanLexicalFuel_encodeList xs h_ih (fuel + 1) (']' :: rest) (depth + 1) 0 scopes
        (by
          dsimp [TreeJson.depth] at h_depth
          omega)
        (by
          dsimp [TreeJson.Valid] at h_valid
          exact h_valid.2)
        (by
          dsimp [TreeJson.Valid] at h_valid
          simpa using h_valid.1)
    rw [hlist]
    have hclose := scanLexicalFuel_rbracket_flush fuel rest (depth + 1)
        (LexScope.inArr (0 + (xs.length - 1))) scopes (lastNumBufList xs)
        (by omega) (scanLexicalCheckNum_lastNumBufList xs)
    simpa [numBuf] using hclose
  | .obj kvs =>
    rw [encode_obj_toList, scanCost_obj]
    have h_fuel : fuel + (2 + scanCostObj kvs) = (fuel + 1 + scanCostObj kvs) + 1 := by omega
    rw [h_fuel]
    have hopen := scanLexicalFuel_lbrace (fuel + 1 + scanCostObj kvs)
        ((TreeJson.encodeObj kvs).toList ++ ('}' :: rest)) depth scopes
        (by
          dsimp [TreeJson.depth] at h_depth
          omega)
    rw [hopen]
    have h_ih : ScanEncodeObjIH kvs := by
      intro k v hv fuel' rest' depth' scopes' hnk hd hval
      have : TreeJson.size v < TreeJson.size (.obj kvs) := by
        dsimp [TreeJson.size]
        have := TreeJson.mem_sizeObj k v kvs hv
        omega
      exact scanLexicalFuel_encode v fuel' rest' depth' scopes' hnk hd hval
    have hobj := scanLexicalFuel_encodeObj kvs h_ih (fuel + 1) ('}' :: rest) (depth + 1) [] scopes
        (by
          dsimp [TreeJson.depth] at h_depth
          omega)
        (by
          dsimp [TreeJson.Valid] at h_valid
          exact h_valid.2)
        (by
          dsimp [TreeJson.Valid] at h_valid
          exact h_valid.1)
        (List.disjoint_nil_right _)
    rw [hobj]
    have hclose := scanLexicalFuel_rbrace_flush fuel rest (depth + 1)
        (afterObj kvs []) scopes (lastNumBufObj kvs)
        (by omega) (scanLexicalCheckNum_lastNumBufObj kvs)
    simpa [numBuf] using hclose
termination_by TreeJson.size t

theorem numBuf_arr (xs : List TreeJson) : numBuf (.arr xs) = [] := rfl
theorem numBuf_obj (kvs : List (String × TreeJson)) : numBuf (.obj kvs) = [] := rfl

/-- Extra fuel after a non-numeric canonical encoding reaches the empty-document success case. -/
theorem scanLexicalFuel_encode_to_ok (t : TreeJson) (extra : Nat)
    (h_depth : TreeJson.depth t ≤ 64)
    (h_valid : TreeJson.Valid t)
    (h_clear : numBuf t = []) :
    scanLexicalFuel (extra + scanCost t + 1) (TreeJson.encode t).toList 0 [] [] false = .ok () := by
  have h_fuel : extra + scanCost t + 1 = extra + 1 + scanCost t := by omega
  rw [h_fuel]
  have h := scanLexicalFuel_encode t (extra + 1) [] 0 [] notExpectKey_nil
      (by omega) h_valid
  simp [List.append_nil] at h
  rw [h, h_clear]
  exact scanLexicalFuel_empty extra 0 []

theorem encode_obj_chars (kvs : List (String × TreeJson)) :
    (TreeJson.encode (.obj kvs)).toList =
      '{' :: ((TreeJson.encodeObj kvs).toList ++ ['}']) := by
  simpa using encode_obj_toList kvs []

theorem moduleToTreeJson_is_obj (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    ∃ kvs, moduleToTreeJson ir = .obj kvs := by
  rcases h_adm with ⟨h_sup, _⟩
  dsimp [SupportedIR] at h_sup
  rcases h_sup with ⟨_, _, _, h_ir⟩
  cases ir with
  | execution ex =>
    cases ex with
    | typed env p => exact ⟨_, rfl⟩
    | step env p => exact ⟨_, rfl⟩
    | run env p => exact ⟨_, rfl⟩
  | audit _ => contradiction
  | codec _ => contradiction

/-- Wrapper success for a canonical encoded object whose UTF-8 image is within 1 MiB. -/
theorem scanLexical_encode_tree_obj (kvs : List (String × TreeJson))
    (h_valid : TreeJson.Valid (.obj kvs))
    (h_depth : TreeJson.depth (.obj kvs) ≤ 64)
    (h_size : ((TreeJson.encode (.obj kvs)).toUTF8).size ≤ 1048576) :
    scanLexical (TreeJson.encode (.obj kvs)).toUTF8 = .ok () := by
  dsimp [scanLexical]
  have h_le : ¬ ((TreeJson.encode (.obj kvs)).toUTF8.size > 1048576) := by omega
  rw [if_neg h_le]
  rw [string_fromUTF8?_toUTF8]
  dsimp
  have h_chars := encode_obj_chars kvs
  have h_filter :
      List.filter (fun x => !isSpace x) (TreeJson.encode (.obj kvs)).toList =
        '{' :: List.filter (fun x => !isSpace x)
          ((TreeJson.encodeObj kvs).toList ++ ['}']) := by
    rw [h_chars]
    simp [isSpace, List.filter]
  have h_empty :
      (List.filter (fun x => !isSpace x) (TreeJson.encode (.obj kvs)).toList).isEmpty = false := by
    rw [h_filter]
    rfl
  rw [h_empty]
  simp only [Bool.false_eq_true, ↓reduceIte]
  have h_head :
      ((List.filter (fun x => !isSpace x)
          (TreeJson.encode (.obj kvs)).toList).head! != '{') = false := by
    rw [h_filter]
    rfl
  rw [h_head]
  simp only [Bool.false_eq_true, ↓reduceIte]
  have h_cost : scanCost (.obj kvs) ≤ (TreeJson.encode (.obj kvs)).toList.length :=
    scanCost_le_encode_length (.obj kvs)
  have h_eq : (TreeJson.encode (.obj kvs)).toList.length + 1 =
      ((TreeJson.encode (.obj kvs)).toList.length - scanCost (.obj kvs)) +
        scanCost (.obj kvs) + 1 := by omega
  rw [h_eq]
  exact scanLexicalFuel_encode_to_ok (.obj kvs)
    ((TreeJson.encode (.obj kvs)).toList.length - scanCost (.obj kvs))
    h_depth h_valid (numBuf_obj kvs)

/-- Universal lexical success on the production codec for every structurally admissible IR. -/
theorem scanLexical_encodeModule (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    scanLexical (encodeModule ir) = .ok () := by
  have h_tree := moduleToTreeJson_encode ir h_adm
  have h_valid := moduleToTreeJson_valid ir h_adm
  have h_depth := moduleToTreeJson_depth_le_64 ir h_adm
  have h_size : ((TreeJson.encode (moduleToTreeJson ir)).toUTF8).size ≤ 1048576 := by
    rw [h_tree, ← encodeModule_eq_toUTF8]
    exact h_adm.1.1
  rw [encodeModule_eq_toUTF8, ← h_tree]
  rcases moduleToTreeJson_is_obj ir h_adm with ⟨kvs, hkvs⟩
  rw [hkvs] at h_valid h_depth h_size ⊢
  exact scanLexical_encode_tree_obj kvs h_valid h_depth h_size

/-- Universal codec roundtrip: every structurally admissible IR re-decodes to itself. -/
theorem encode_decode_roundtrip : EncodeDecodeRoundtripStatement :=
  fun ir h_adm =>
    decodeBytes_encodeModule_of_lex ir h_adm (scanLexical_encodeModule ir h_adm)

/-- Checker correspondence: encoded admissible IR is checked as `checkIR` of that IR. -/
theorem checkBytes_encodeModule (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    checkBytes (encodeModule ir) = checkIR ir :=
  checkBytes_ok (encodeModule ir) ir (encode_decode_roundtrip ir h_adm)

theorem checkBytes_encodeModule_typed (env : EnvelopeEnc) (p : TypedExecutePayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.typed env p))) :
    checkBytes (encodeModule (.execution (.typed env p))) = .execution (checkTyped env p) := by
  rw [checkBytes_encodeModule _ h_adm]
  rfl

theorem checkBytes_encodeModule_step (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.step env p))) :
    checkBytes (encodeModule (.execution (.step env p))) = .execution (checkStep env p) := by
  rw [checkBytes_encodeModule _ h_adm]
  rfl

theorem checkBytes_encodeModule_run (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.run env p))) :
    checkBytes (encodeModule (.execution (.run env p))) = .execution (checkRun env p) := by
  rw [checkBytes_encodeModule _ h_adm]
  rfl

end DefiKernel.Certificates


