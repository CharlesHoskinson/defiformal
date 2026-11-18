import DefiKernel.Lending.Borrow
import DefiKernel.Lending.Repay
import DefiKernel.Lending.Accrue
import DefiKernel.Lending.DepositCollateral
import DefiKernel.Lending.WithdrawCollateral

/-! One finite coherence replay across five public APIs, not a general composition theorem. -/
namespace DefiKernel.Lending.LifecycleAudit
open DefiKernel.Typed
private def registry : Registry Party Asset Domain := fun id =>
  if id=borrowId then some (Borrow.template .alice)
  else if id=repayId then some (Repay.template .alice)
  else if id=accrueId then some (Accrue.template .alice)
  else if id=depositCollateralId then some (DepositCollateral.template .alice)
  else if id=withdrawCollateralId then some (WithdrawCollateral.template .alice)
  else none
private def grants : List (Grant Party Asset Domain) :=
  Borrow.grants .alice ++ Repay.grants .alice ++ Accrue.grants .alice ++
    DepositCollateral.grants .alice ++ WithdrawCollateral.grants .alice
private def issued := Support.provision registry grants
private def expected : Store := ⟨grants.map (fun grant => ⟨grant,true⟩)⟩
private def borrowIds : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩]
private def repayIds : List CapabilityId := [⟨3⟩,⟨4⟩,⟨5⟩,⟨6⟩]
private def accrueIds : List CapabilityId := [⟨7⟩,⟨8⟩]
private def depositIds : List CapabilityId := [⟨9⟩,⟨10⟩]
private def withdrawIds : List CapabilityId := [⟨11⟩,⟨12⟩]
theorem issued_exact : issued = .ok expected := by decide
theorem operation_ids_distinct :
    [borrowId,repayId,accrueId,depositCollateralId,withdrawCollateralId].Nodup := by decide
theorem capability_ids_distinct :
    (borrowIds ++ repayIds ++ accrueIds ++ depositIds ++ withdrawIds).Nodup := by decide
private def initial : Ledger where
  balance
    | (.lending,.alice,.cash) => 5
    | (.lending,.pool,.cash) => 100
    | (.lending,.alice,.collateral) => 10
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> decide
private def finalLedger : Ledger where
  balance
    | (.lending,.alice,.cash) => 7
    | (.lending,.pool,.cash) => 98
    | (.lending,.alice,.debt) => 3
    | (.lending,.alice,.collateral) => 5
    | (.lending,.aliceLocked,.collateral) => 5
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> decide
private def context := borrowerContext .alice
private def checked (actual : Except Typed.Refusal World) : Except String World :=
  actual.mapError (fun reason => s!"Typed refusal: {repr reason}")
private def replay : Except String (List World) := do
  let store ← issued.mapError (fun reason => s!"Authority refusal: {repr reason}")
  let deposited ← checked (DepositCollateral.run .alice store context depositIds 8 initial)
  let borrowed ← checked (Borrow.run .alice deposited.capabilities context borrowIds 4
    (Oracle.feed 2 98) 100 deposited.state)
  let accrued ← checked (Accrue.run .alice borrowed.capabilities context accrueIds (1/4) 1 borrowed.state)
  let repaid ← checked (Repay.run .alice accrued.capabilities context repayIds 2 accrued.state)
  let withdrawn ← checked (WithdrawCollateral.run .alice repaid.capabilities context withdrawIds 3
    (Oracle.feed 2 98) 100 repaid.state)
  return [deposited,borrowed,accrued,repaid,withdrawn]
private def balances (world : World) (cash pool debt free locked : ℚ) : Bool :=
  decide (world.state.balance (.lending,.alice,.cash)=cash ∧
    world.state.balance (.lending,.pool,.cash)=pool ∧
    world.state.balance (.lending,.alice,.debt)=debt ∧
    world.state.balance (.lending,.alice,.collateral)=free ∧
    world.state.balance (.lending,.aliceLocked,.collateral)=locked ∧
    world.capabilities=expected)
private def stages (index : Nat) (cash pool debt free locked : ℚ) : Bool :=
  match replay with
  | .error _ => false
  | .ok worlds => match worlds[index]? with
    | none => false
    | some world => balances world cash pool debt free locked
private def checks : List (String × Bool) := [
  ("actually_issued_13_noncolliding_operation_scoped_capabilities",
    decide (issued=.ok expected ∧ expected.entries.length=13 ∧
      (borrowIds ++ repayIds ++ accrueIds ++ depositIds ++ withdrawIds).Nodup)),
  ("deposit_stage",stages 0 5 100 0 2 8),
  ("borrow_stage",stages 1 9 96 4 2 8),
  ("accrual_stage",stages 2 9 96 5 2 8),
  ("repayment_stage",stages 3 7 98 3 2 8),
  ("withdrawal_final_exact_ledger",stages 4 7 98 3 5 5 && (match replay with
    | .error _ => false
    | .ok worlds => match worlds[4]? with
      | none => false
      | some world => decide (∀ cell, world.state.balance cell=finalLedger.balance cell))),
  ("final_asset_totals_debt_supply_reconciled",match replay with
    | .error _ => false
    | .ok worlds => match worlds[4]? with
      | none => false
      | some world => decide (total world.state .lending .cash=105 ∧
          total world.state .lending .collateral=10 ∧ total world.state .lending .debt=3)),
  ("borrow_ids_do_not_authorize_withdrawal",match replay with
    | .error _ => false
    | .ok worlds => match worlds[4]? with
      | none => false
      | some world => match WithdrawCollateral.run .alice world.capabilities context borrowIds 0
          (Oracle.feed 2 98) 100 world.state with
        | .ok _ => false
        | .error reason => decide (reason=Typed.Refusal.unauthorizedInvoke))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty lifecycle controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate lifecycle controls")
  match replay with
  | .error reason => IO.println s!"LIFECYCLE_OBSERVATION refused {reason}"
  | .ok worlds =>
    for world in worlds do
      IO.println s!"LIFECYCLE_OBSERVATION {world.state.balance (.lending,.alice,.cash)} {world.state.balance (.lending,.pool,.cash)} {world.state.balance (.lending,.alice,.debt)} {world.state.balance (.lending,.alice,.collateral)} {world.state.balance (.lending,.aliceLocked,.collateral)}"
  for (name,passed) in checks do IO.println s!"LIFECYCLE_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual lifecycle comparison")
  IO.println s!"LIFECYCLE_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.LifecycleAudit
