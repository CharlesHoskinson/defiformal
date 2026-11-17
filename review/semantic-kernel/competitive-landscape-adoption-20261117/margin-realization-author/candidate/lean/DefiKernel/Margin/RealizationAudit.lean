import DefiKernel.Margin.Realization
namespace DefiKernel.Margin.RealizationAudit
open DefiKernel.Typed
private def ledger (pool : Nat) : Ledger where
  balance
    | (.margin,.pool,.primary) => pool
    | (.margin,.pool,.secondary) => pool
    | (.margin,.output,.primary) => 1
    | (.margin,.output,.secondary) => 2
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def position : Funding.Position := ⟨10,100,-1,⟨1,2,3⟩⟩
private def price : Realization.Price := ⟨3,by decide⟩
private def before (pool : Nat) (side : Realization.Side) : Funding.State :=
  ⟨⟨ledger pool,Realization.fixtureStore side⟩,position⟩
private def run (pool : Nat) (pnl : Int) (side : Realization.Side) :=
  Realization.run (before pool side) pnl side price ownerContext Realization.ids
private def refused (actual : Except Typed.Refusal (Funding.State × Realization.Receipt))
    (expected : Typed.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def checks : List (String × Bool) := [
  ("real_administrative_provision",decide (Realization.provisioned 10 .primary price=
    .ok (Realization.fixtureStore .primary))),
  ("primary_pool_funded_floor_and_dust",match run 5 10 .primary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧ r.floorDustUsd=1 ∧
      after.world.state.balance (.margin,.pool,.primary)=2 ∧
      after.world.state.balance (.margin,.output,.primary)=4 ∧ after.position=position)),
  ("secondary_pool_funded_floor_and_dust",match run 5 10 .secondary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧ r.floorDustUsd=1 ∧
      after.world.state.balance (.margin,.pool,.secondary)=2 ∧
      after.world.state.balance (.margin,.output,.secondary)=5 ∧
      after.world.state.balance (.margin,.output,.primary)=1)),
  ("insufficient_actual_pool_refuses",match run 2 10 .primary with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.insufficientFunds)),
  ("negative_pnl_no_op_without_authority",match Realization.run
      ⟨⟨ledger 0,.empty⟩,position⟩ (-10) .primary price ownerContext [] with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧ r.floorDustUsd=0 ∧
      after.world.state.balance (.margin,.output,.primary)=1 ∧ after.world.capabilities=(CapabilityStore.empty : Store))),
  ("zero_pnl_no_op_without_authority",match Realization.run
      ⟨⟨ledger 0,.empty⟩,position⟩ 0 .primary price ownerContext [] with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧ r.floorDustUsd=0 ∧
      after.world.state.balance (.margin,.output,.primary)=1 ∧ after.world.capabilities=(CapabilityStore.empty : Store))),
  ("positive_pnl_requires_invoke",refused (Realization.run (before 5 .primary) 10 .primary price
    ownerContext [⟨1⟩]) .unauthorizedInvoke),
  ("positive_payment_requires_actual_pool_debit",refused (Realization.run (before 5 .primary) 10 .primary price
    ownerContext [⟨0⟩]) .unauthorizedDebit),
  ("actor_binding_before_pool_funding",refused (Realization.run (before 0 .primary) 10 .primary price
    ⟨.pool,.margin⟩ Realization.ids) .actorMismatch),
  ("wrong_token_authority_cannot_debit_other_pool",refused (Realization.run
    ⟨⟨ledger 5,Realization.fixtureStore .primary⟩,position⟩ 10 .secondary price ownerContext Realization.ids)
    .unauthorizedDebit),
  ("positive_subtoken_pnl_zero_transfer_invoke_only",match Realization.run (before 0 .primary) 1 .primary
      price ownerContext [⟨0⟩] with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧ r.floorDustUsd=1 ∧
      after.world.state.balance (.margin,.pool,.primary)=0 ∧
      after.world.state.balance (.margin,.output,.primary)=1)),
  ("positive_subtoken_pnl_still_requires_invoke",refused (Realization.run (before 0 .primary) 1 .primary
    price ownerContext []) .unauthorizedInvoke),
  ("actual_physical_and_claim_totals_conserve",match run 5 10 .primary with
    | .error _ => false | .ok (after,_) => decide (total after.world.state .margin .primary=6 ∧
      total after.world.state .margin .secondary=7 ∧ total after.world.state .margin .claimSecondary=16)),
  ("owner_claims_holding_claims_and_snapshots_frame",match run 5 10 .primary with
    | .error _ => false | .ok (after,_) => decide (after.position=position ∧
      after.world.state.balance (.margin,.owner,.claimSecondary)=11 ∧
      after.world.state.balance (.margin,.holding,.claimSecondary)=5 ∧
      after.world.state.balance (.margin,.pool,.secondary)=5 ∧
      after.world.state.balance (.margin,.output,.secondary)=2)),
  ("marked_pnl_is_distinct_from_close_base_observation",match run 5 10 .primary with
    | .error _ => false | .ok (after,r) => decide (after.position.pnlUsd=100 ∧
      r.basePnlUsd=10 ∧ r.paidTokens=3)),
  ("primary_floor_exact_multiple",match run 5 9 .primary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧ r.floorDustUsd=0 ∧
      after.world.state.balance (.margin,.pool,.primary)=2)),
  ("fully_depleted_pool_remains_nonnegative",match run 3 10 .secondary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧
      after.world.state.balance (.margin,.pool,.secondary)=0 ∧
      after.world.state.balance (.margin,.output,.secondary)=5)),
  ("negative_pnl_is_not_realized_as_positive_cash",match run 0 (-10) .secondary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧
      after.world.state.balance (.margin,.pool,.secondary)=0 ∧
      after.world.state.balance (.margin,.output,.secondary)=2))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first realization controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate realization controls")
  match run 5 10 .primary with
  | .error reason => IO.println s!"REALIZATION_OBSERVATION refused {repr reason}"
  | .ok (after,r) => IO.println s!"REALIZATION_OBSERVATION {after.world.state.balance (.margin,.pool,.primary)} {after.world.state.balance (.margin,.output,.primary)} {r.paidTokens} {r.floorDustUsd}"
  for (name,passed) in checks do IO.println s!"REALIZATION_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: first realization comparison")
  IO.println s!"REALIZATION_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Margin.RealizationAudit
