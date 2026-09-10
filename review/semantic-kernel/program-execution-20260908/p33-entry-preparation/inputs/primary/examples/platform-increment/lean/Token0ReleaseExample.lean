import DefiKernel.ConcentratedLiquidity.Examples

/-!
P18 public token0 library example.

This file calls the accepted P16 Lean helper. It is not a Python substitute,
not source execution, and not a refinement proof.
-/

open DefiKernel.ConcentratedLiquidity
open Examples

def formatFailure : Failure → String
  | .divisionByZero => "divisionByZero"
  | .quotientOverflow => "quotientOverflow"
  | .subUnderflow => "subUnderflow"
  | .addOverflow => "addOverflow"
  | .uint160Overflow => "uint160Overflow"

def formatObs : Token0Observation → String
  | .ok n => s!"ok:{n}"
  | .error e => s!"error:{formatFailure e}"

def showRow (name : String) (sqrtP : U160) (L : U128) (amount : U256) (add : Bool) :
    IO Bool := do
  let obs := observeToken0 sqrtP L amount add
  let matchOk :=
    match expected.lookup name with
    | some want => decide (obs = want)
    | none => false
  IO.println s!"{name} sqrtP={sqrtP.value} L={L.value} amount={amount.value} add={add} model={formatObs obs} match={matchOk}"
  pure matchOk

def main : IO Unit := do
  IO.println "p18.token0.example version=0.1.0"
  IO.println "entrypoint=DefiKernel.ConcentratedLiquidity.SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp"
  IO.println "kind=lean-library-execution-not-python-not-solidity"
  let rows : List (IO Bool) :=
    [showRow "P16-I-ADD" Q96w (w128 1) (w256 0) true,
     showRow "P16-I-REM" Q96w (w128 1) (w256 0) false,
     showRow "P16-I-ZERO-LIQ" Q96w (w128 0) (w256 0) false,
     showRow "P16-ADD" Q96w (w128 1) (w256 1) true,
     showRow "P16-ADD-ROUND" Q96w (w128 1) (w256 2) true,
     showRow "P16-REQ" Q96w (w128 1) (w256 1) false,
     showRow "P16-REQ-STRICT" Q96w (w128 1) (w256 2) false,
     showRow "P16-REM" Q96w (w128 2) (w256 1) false,
     showRow "P16-SAFECAST" safecastSqrt liqSafecast (w256 1) false,
     showRow "P16-ADD-DEN0" (w160 0) (w128 0) (w256 1) true,
     showRow "P16-PROD" Q96w liqProd amountProd true,
     showRow "P16-WRAP" maxSqrtMinus1 maxU128 amountWrap true]
  if rows.isEmpty then
    throw (IO.userError "P18 token0 example: empty observation list (blocked, not success)")
  let mut okCount : Nat := 0
  let mut failCount : Nat := 0
  for act in rows do
    let ok ← act
    if ok then
      okCount := okCount + 1
    else
      failCount := failCount + 1
  let denominator := rows.length
  IO.println s!"denominator={denominator}"
  IO.println s!"ok={okCount}"
  IO.println s!"fail={failCount}"
  if denominator = 0 then
    throw (IO.userError "P18 token0 example: denominator 0 is blocked, not success")
  if denominator ≠ 12 then
    throw (IO.userError s!"P18 token0 example: expected 12 rows, got {denominator}")
  if failCount ≠ 0 then
    throw (IO.userError s!"P18 token0 example: {failCount} mismatches")
  IO.println "status=ok"

#eval main
