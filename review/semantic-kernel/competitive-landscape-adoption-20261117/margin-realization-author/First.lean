import DefiKernel.Margin.Realization
open DefiKernel DefiKernel.Typed DefiKernel.Margin
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
      after.world.state.balance (.margin,.output,.primary)=1 ∧ after.world.capabilities=(CapabilityStore.empty : Store)))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty first realization controls")
  for (name,passed) in checks do IO.println s!"REALIZATION_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: first realization comparison")
