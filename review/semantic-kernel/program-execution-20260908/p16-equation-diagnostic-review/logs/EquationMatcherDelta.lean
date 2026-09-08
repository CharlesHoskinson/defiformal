import DefiKernel.ConcentratedLiquidity.SqrtPriceMath
open Lean
open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.SqrtPriceMath

def DiagnosticRhs (sqrtP : U160) (L : U128) (amount : U256) : Except Failure U160 :=
  match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
      (wrapWord (numerator1 L + product amount sqrtP)) with
  | .ok q => .ok (bareToUint160 q)
  | .error e => .error e

#print DefiKernel.ConcentratedLiquidity.SqrtPriceMath.addPrimary.match_1
#print DiagnosticRhs.match_1
example (p : U160) (L : U128) (a : U256) : addPrimary p L a = DiagnosticRhs p L a := by
  delta addPrimary DiagnosticRhs
  delta DefiKernel.ConcentratedLiquidity.SqrtPriceMath.addPrimary.match_1 DiagnosticRhs.match_1
  rfl
