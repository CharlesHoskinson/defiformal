import DefiKernel.Margin.Close
open DefiKernel DefiKernel.Typed DefiKernel.Margin
private def pos : Funding.Position := ⟨Funding.precision,2,-1,⟨0,0,0⟩⟩
private def baseCfg : Close.Config :=
  ⟨⟨1,2,3⟩,⟨3,2,by decide,by decide⟩,⟨3,by decide⟩,.primary,
    Funding.precision,true,false,0,1,4,10,4,1,1,true⟩
private def ledger : Ledger where
  balance
    | (.margin,.position,.primary) => 5
    | (.margin,.pool,.primary) => 20
    | (.margin,.pool,.secondary) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
#eval do
  let cases := [("healthy_liquidation_refusal",false),
    ("healthy_liquidation_adl_does_not_bypass_guard",true)]
  if cases.isEmpty then throw (IO.userError "BLOCKED: empty native/source admission comparison")
  for (name,adl) in cases do
    let cfg := {baseCfg with secondaryAdl:=adl}
    let store ← match Close.provisioned cfg with
      | .error reason => throw (IO.userError s!"BLOCKED: joint issuance {repr reason}")
      | .ok issued => pure issued
    let funding := Funding.quote pos cfg.latest (by decide)
    IO.println s!"NATIVE_CLOSE_SOURCE_INPUT {name} 5 {cfg.prices.primary} {funding.feePrimary+cfg.healthOtherFeeTokens} {cfg.minCollateralUsd} {cfg.minLeverageUsd} {pos.pnlUsd} {pos.impactUsd} 1 {if adl then 1 else 0}"
    match Close.run ⟨⟨ledger,store⟩,pos⟩ cfg (by decide) ⟨0,5,0⟩ Close.realizationIds with
    | .error (.positionShouldNotBeLiquidated reason equity minCollateral minLeverage) =>
      IO.println s!"NATIVE_CLOSE_SOURCE_ERROR {name} {equity} {minCollateral} {minLeverage} {reason.utf8ByteSize}"
    | .error reason => throw (IO.userError s!"FAIL: unexpected native admission refusal {repr reason}")
    | .ok _ => throw (IO.userError "FAIL: native admission unexpectedly succeeded")
