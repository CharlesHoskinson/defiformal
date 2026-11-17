from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text();a=s.index('def payRest');b=s.index('\ndef run (before',a)
s=s[:a]+'''def payOne (cfg : Config) (progress : Progress) (stage : Stage) (cost : ℕ) :
    Except Refusal (Progress × Payment.Result) := do
  let input : Payment.Inputs := ⟨cost,progress.buckets.output,progress.buckets.collateral,
    progress.buckets.secondary⟩
  let (post,payment) ← (PaymentSettlement.run cfg.prices input progress.state.world.capabilities
    ownerContext Funding.payIds progress.state.world.state).mapError Refusal.typed
  let after : Funding.State := ⟨post,progress.state.position⟩
  let fees := if stage=.fees && !(payment.sourceRemainingCostUsd=0 && payment.paidSecondary=0)
    then emptyFees progress.fees else progress.fees
  return (⟨after,afterBuckets payment,fees,
    progress.executed++[⟨stage,cost,progress.buckets,progress.state,after,payment⟩]⟩,payment)

def payRest (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) : List (Stage × ℕ) → Except Refusal Result
  | [] => .ok ⟨progress,.complete,[],base,impact⟩
  | (stage,cost)::tail => do
    let (next,payment) ← payOne cfg progress stage cost
    if 0<payment.sourceRemainingCostUsd then
      if insolvencyAllowed then return ⟨{next with fees:=emptyFees next.fees},
        .exceptional stage payment.sourceRemainingCostUsd,tail,base,impact⟩
      else throw (Refusal.insufficientFundsToPayForCosts payment.sourceRemainingCostUsd stage.label)
    else payRest cfg insolvencyAllowed base impact next tail
'''+s[b:]
s=s.replace('end DefiKernel.Margin.Close','')
s+='''
def preserves (before after : Funding.State) : Prop :=
  after.position=before.position ∧ after.world.capabilities=before.world.capabilities ∧
    ∀ asset,total after.world.state .margin asset=total before.world.state .margin asset

theorem preserves_trans (a b c : Funding.State) (ab : preserves a b) (bc : preserves b c) :
    preserves a c :=
  ⟨bc.1.trans ab.1,bc.2.1.trans ab.2.1,fun asset=>(bc.2.2 asset).trans (ab.2.2 asset)⟩

theorem payOne_ok_iff (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) :
    payOne cfg progress stage cost=.ok (next,payment) ↔
      ∃ post,PaymentSettlement.run cfg.prices
        ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
        progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state=
          .ok (post,payment) ∧
        next=⟨⟨post,progress.state.position⟩,afterBuckets payment,
          if stage=.fees && !(payment.sourceRemainingCostUsd=0 && payment.paidSecondary=0)
            then emptyFees progress.fees else progress.fees,
          progress.executed++[⟨stage,cost,progress.buckets,progress.state,
            ⟨post,progress.state.position⟩,payment⟩]⟩ := by
  cases actual : PaymentSettlement.run cfg.prices
    ⟨cost,progress.buckets.output,progress.buckets.collateral,progress.buckets.secondary⟩
    progress.state.world.capabilities ownerContext Funding.payIds progress.state.world.state with
  | error reason => simp [payOne,actual,Except.mapError,bind,Except.bind]
  | ok pair =>
    rcases pair with ⟨post,q⟩
    simp [payOne,actual,Except.mapError,bind,Except.bind,pure,Except.pure,eq_comm,and_comm]

theorem payOne_preserves (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    preserves progress.state next.state := by
  obtain ⟨post,paid,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  obtain ⟨executed,_⟩ := (PaymentSettlement.run_ok_iff _ _ _ _ _ _ _ _).mp paid
  have caps := ((PaymentSettlement.execute_ok_iff _ _ _ _ _ _ _).mp executed).2.2.2.1
  exact ⟨rfl,caps,PaymentSettlement.actual_accounting _ _ _ _ _ _ _ executed⟩

theorem payRest_preserves (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    preserves progress.state result.progress.state := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact ⟨rfl,rfl,fun _=>rfl⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have step := payOne_preserves cfg progress next stage cost payment actual
      by_cases residual : 0<payment.sourceRemainingCostUsd
      · rw [if_pos residual] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact step
      · rw [if_neg residual] at success
        exact preserves_trans _ _ _ step (ih next success)
end DefiKernel.Margin.Close
''';p.write_text(s)
