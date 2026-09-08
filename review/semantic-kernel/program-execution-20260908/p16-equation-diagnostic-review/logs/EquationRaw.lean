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
  for n in [``addPrimary, `DefiKernel.ConcentratedLiquidity.SqrtPriceMath.addPrimary.eq_def,
      `DefiKernel.ConcentratedLiquidity.SqrtPriceMath.addPrimary.eq_1] do
    Lean.Elab.Command.liftIO (IO.println s!"present {n}: {env.contains n}")
  let orig := (env.find? ``addPrimary).get!.value!
  let rhs := (env.find? ``DiagnosticRhs).get!.value!
  Lean.Elab.Command.liftIO (IO.println s!"raw-body-equal {orig == rhs}")
  Lean.Elab.Command.liftIO (IO.println s!"ORIGINAL {repr orig}")
  Lean.Elab.Command.liftIO (IO.println s!"RHS {repr rhs}")
