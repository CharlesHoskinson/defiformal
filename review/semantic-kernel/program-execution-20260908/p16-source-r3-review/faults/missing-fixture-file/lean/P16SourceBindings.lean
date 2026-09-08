import DefiKernel.ConcentratedLiquidity.SqrtPriceMath

/-!
Ephemeral P16 source-campaign model export. Imports frozen library bytes.
Independent expected values are literals, not helper self-output.
-/
open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.SqrtPriceMath

def w128 (n : Nat) (h : n < 2 ^ 128 := by decide) : U128 := ⟨n, h⟩
def w160 (n : Nat) (h : n < 2 ^ 160 := by decide) : U160 := ⟨n, h⟩
def w256 (n : Nat) (h : n < 2 ^ 256 := by decide) : U256 := ⟨n, h⟩

structure Row where
  id : String
  sqrtP : U160
  L : U128
  amount : U256
  add : Bool
  expectedOk : Option Nat
  expectedErr : Option Failure

def showF : Failure → String
  | .divisionByZero => "divisionByZero"
  | .quotientOverflow => "quotientOverflow"
  | .subUnderflow => "subUnderflow"
  | .addOverflow => "addOverflow"
  | .uint160Overflow => "uint160Overflow"

def runRow (r : Row) : IO Bool := do
  let got := getNextSqrtPriceFromAmount0RoundingUp r.sqrtP r.L r.amount r.add
  let actual :=
    match got with
    | .ok q => s!"ok:{q.value}"
    | .error e => s!"error:{showF e}"
  let agrees :=
    match got, r.expectedOk, r.expectedErr with
    | .ok q, some n, none => decide (q.value = n)
    | .error e, none, some f => decide (e = f)
    | _, _, _ => false
  IO.println s!"{r.id} sqrtP={r.sqrtP.value} L={r.L.value} amount={r.amount.value} add={r.add} model={actual} match={agrees}"
  pure agrees

def rows : List Row :=
  [ { id := "P16-I-ADD"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 0
      add := true
      expectedOk := some 79228162514264337593543950336
      expectedErr := none }
  , { id := "P16-I-REM"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 0
      add := false
      expectedOk := some 79228162514264337593543950336
      expectedErr := none }
  , { id := "P16-I-ZERO-LIQ"
      sqrtP := w160 79228162514264337593543950336
      L := w128 0
      amount := w256 0
      add := false
      expectedOk := some 79228162514264337593543950336
      expectedErr := none }
  , { id := "P16-ADD"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 1
      add := true
      expectedOk := some 39614081257132168796771975168
      expectedErr := none }
  , { id := "P16-ADD-ROUND"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 2
      add := true
      expectedOk := some 26409387504754779197847983446
      expectedErr := none }
  , { id := "P16-REQ"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 1
      add := false
      expectedOk := none
      expectedErr := some .subUnderflow }
  , { id := "P16-REQ-STRICT"
      sqrtP := w160 79228162514264337593543950336
      L := w128 1
      amount := w256 2
      add := false
      expectedOk := none
      expectedErr := some .subUnderflow }
  , { id := "P16-REM"
      sqrtP := w160 79228162514264337593543950336
      L := w128 2
      amount := w256 1
      add := false
      expectedOk := some 158456325028528675187087900672
      expectedErr := none }
  , { id := "P16-SAFECAST"
      sqrtP := w160 730750818665451459101842416358141509827966271488
      L := w128 9223372036854775809
      amount := w256 1
      add := false
      expectedOk := none
      expectedErr := some .uint160Overflow }
  , { id := "P16-ADD-DEN0"
      sqrtP := w160 0
      L := w128 0
      amount := w256 1
      add := true
      expectedOk := none
      expectedErr := some .divisionByZero }
  , { id := "P16-PROD"
      sqrtP := w160 79228162514264337593543950336
      L := w128 79228162514264337593543950336
      amount := w256 1461501637330902918203684832716283019655932542976
      add := true
      expectedOk := some 4294967296
      expectedErr := none }
  , { id := "P16-WRAP"
      sqrtP := w160 1461446703485210103287273052203988822378723970341
      L := w128 340282366920938463463374607431768211455
      amount := w256 79231140577496994670249413376
      add := true
      expectedOk := some 340269576638287423012608907232989748562
      expectedErr := none }
  ]

def main : IO UInt32 := do
  if rows.isEmpty then
    IO.eprintln "P16 source-binding rows empty"
    return 3
  let ids := rows.map (·.id)
  if !ids.Nodup then
    IO.eprintln "P16 source-binding ids duplicated"
    return 3
  let mut all := true
  for r in rows do
    let m ← runRow r
    all := all && m
  if all then
    IO.println s!"P16 source-binding comparisons: {rows.length} of {rows.length}"
    return 0
  IO.eprintln "P16 source-binding comparison failed"
  return 1

#eval main
