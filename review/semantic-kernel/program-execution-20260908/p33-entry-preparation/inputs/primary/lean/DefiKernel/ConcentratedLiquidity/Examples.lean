import DefiKernel.ConcentratedLiquidity.SqrtPriceMath

/-! Independent P16 fixture literals. Expected tables are not function self-output. -/
namespace DefiKernel.ConcentratedLiquidity.Examples
open ConcentratedLiquidity
open SqrtPriceMath
open FullMath

def w128 (n : Nat) (h : n < 2 ^ 128 := by decide) : U128 := ⟨n, h⟩
def w160 (n : Nat) (h : n < 2 ^ 160 := by decide) : U160 := ⟨n, h⟩
def w256 (n : Nat) (h : n < 2 ^ 256 := by decide) : U256 := ⟨n, h⟩

def Q96w : U160 := w160 79228162514264337593543950336
def two95 : U160 := w160 39614081257132168796771975168
def addRound : U160 := w160 26409387504754779197847983446
def remOk : U160 := w160 158456325028528675187087900672
def prodOk : U160 := w160 4294967296
def wrapOk : U160 := w160 340269576638287423012608907232989748562
def maxSqrtMinus1 : U160 := w160 1461446703485210103287273052203988822378723970341
def safecastSqrt : U160 := w160 730750818665451459101842416358141509827966271488
def two160m1 : U256 := w256 (2 ^ 256 - 1)
def two128 : U256 := w256 (2 ^ 128)
def two255 : U256 := w256 (2 ^ 255)
def amountProd : U256 := w256 1461501637330902918203684832716283019655932542976
def amountWrap : U256 := w256 79231140577496994670249413376
def maxU128 : U128 := w128 340282366920938463463374607431768211455
def liqProd : U128 := w128 79228162514264337593543950336
def liqSafecast : U128 := w128 9223372036854775809

inductive Token0Observation
  | ok (value : Nat)
  | error (failure : Failure)
  deriving DecidableEq, Repr

def observeToken0 (sqrtP : U160) (L : U128) (amount : U256) (add : Bool) :
    Token0Observation :=
  match getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount add with
  | .ok q => .ok q.value
  | .error e => .error e

def observeMulDiv (a b d : U256) : Token0Observation :=
  match mulDiv a b d with
  | .ok q => .ok q.value
  | .error e => .error e

def observeMulDivUp (a b d : U256) : Token0Observation :=
  match mulDivRoundingUp a b d with
  | .ok q => .ok q.value
  | .error e => .error e

def actual : List (String × Token0Observation) :=
  [("cl.fullmath.f01", observeMulDiv (w256 10) (w256 20) (w256 3)),
    ("cl.fullmath.f02", observeMulDivUp (w256 10) (w256 20) (w256 3)),
    ("cl.fullmath.f03-down", observeMulDiv (w256 10) (w256 20) (w256 5)),
    ("cl.fullmath.f03-up", observeMulDivUp (w256 10) (w256 20) (w256 5)),
    ("cl.fullmath.f04", observeMulDiv two128 two128 two128),
    ("cl.fullmath.f05", observeMulDiv (w256 1) (w256 1) (w256 0)),
    ("cl.fullmath.f06", observeMulDiv two160m1 (w256 2) (w256 1)),
    ("cl.fullmath.f07", observeMulDivUp two160m1 (w256 1) (w256 1)),
    ("cl.fullmath.f08", observeMulDivUp two160m1 (w256 3) (w256 2)),
    ("cl.fullmath.f09", observeMulDiv (w256 0) two255 (w256 7)),
    ("P16-I-ADD", observeToken0 Q96w (w128 1) (w256 0) true),
    ("P16-I-REM", observeToken0 Q96w (w128 1) (w256 0) false),
    ("P16-I-ZERO-LIQ", observeToken0 Q96w (w128 0) (w256 0) false),
    ("P16-ADD", observeToken0 Q96w (w128 1) (w256 1) true),
    ("P16-ADD-ROUND", observeToken0 Q96w (w128 1) (w256 2) true),
    ("P16-REQ", observeToken0 Q96w (w128 1) (w256 1) false),
    ("P16-REQ-STRICT", observeToken0 Q96w (w128 1) (w256 2) false),
    ("P16-REM", observeToken0 Q96w (w128 2) (w256 1) false),
    ("P16-SAFECAST", observeToken0 safecastSqrt liqSafecast (w256 1) false),
    ("P16-ADD-DEN0", observeToken0 (w160 0) (w128 0) (w256 1) true),
    ("P16-PROD", observeToken0 Q96w liqProd amountProd true),
    ("P16-WRAP", observeToken0 maxSqrtMinus1 maxU128 amountWrap true)]

def expected : List (String × Token0Observation) :=
  [("cl.fullmath.f01", .ok 66),
    ("cl.fullmath.f02", .ok 67),
    ("cl.fullmath.f03-down", .ok 40),
    ("cl.fullmath.f03-up", .ok 40),
    ("cl.fullmath.f04", .ok 340282366920938463463374607431768211456),
    ("cl.fullmath.f05", .error .divisionByZero),
    ("cl.fullmath.f06", .error .quotientOverflow),
    ("cl.fullmath.f07", .ok 115792089237316195423570985008687907853269984665640564039457584007913129639935),
    ("cl.fullmath.f08", .error .quotientOverflow),
    ("cl.fullmath.f09", .ok 0),
    ("P16-I-ADD", .ok 79228162514264337593543950336),
    ("P16-I-REM", .ok 79228162514264337593543950336),
    ("P16-I-ZERO-LIQ", .ok 79228162514264337593543950336),
    ("P16-ADD", .ok 39614081257132168796771975168),
    ("P16-ADD-ROUND", .ok 26409387504754779197847983446),
    ("P16-REQ", .error .subUnderflow),
    ("P16-REQ-STRICT", .error .subUnderflow),
    ("P16-REM", .ok 158456325028528675187087900672),
    ("P16-SAFECAST", .error .uint160Overflow),
    ("P16-ADD-DEN0", .error .divisionByZero),
    ("P16-PROD", .ok 4294967296),
    ("P16-WRAP", .ok 340269576638287423012608907232989748562)]

end DefiKernel.ConcentratedLiquidity.Examples
