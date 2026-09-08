import DefiKernel.ConcentratedLiquidity.SqrtPriceMath
open Lean
open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.SqrtPriceMath

def DiagnosticRhs (sqrtP : U160) (L : U128) (amount : U256) : Except Failure U160 :=
  match FullMath.mulDivRoundingUp (numerator1Word L) (widen160 sqrtP)
      (wrapWord (numerator1 L + product amount sqrtP)) with
  | .ok q => .ok (bareToUint160 q)
  | .error e => .error e

run_cmd do
  let env ← getEnv
  let names := [`DefiKernel.ConcentratedLiquidity.SqrtPriceMath.addPrimary.match_1, `DiagnosticRhs.match_1]
  for n in names do
    let ci := (env.find? n).get!
    Lean.Elab.Command.liftIO (IO.println s!"TYPE {n} {repr ci.type}")
    Lean.Elab.Command.liftIO (IO.println s!"VALUE {n} {repr ci.value!}")
