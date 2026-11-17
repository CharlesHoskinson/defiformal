from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
def Stage.rank : Stage → ℕ | .funding => 0 | .pnl => 1 | .fees => 2 | .impact => 3 | .diff => 4
/-- Fixed source order, independently of the observed cost magnitudes. -/
theorem remaining_ordered (cfg : Config) :
    ((remainingCosts cfg).map (fun entry=>entry.1.rank)).Pairwise (·<·) := by
  by_cases pnl : cfg.closeBasePnlUsd<0 <;> by_cases impact : cfg.closeImpactUsd<0 <;>
    by_cases diff : 0<cfg.impactDiffUsd <;> simp [remainingCosts,pnl,impact,diff,Stage.rank]

theorem payRest_refusal (cfg : Config) (base impact : Realization.Receipt) (progress next : Progress)
    (stage : Stage) (cost : ℕ) (tail : List (Stage × ℕ)) (payment : Payment.Result)
    (paid : payOne cfg progress stage cost=.ok (next,payment))
    (shortfall : 0<payment.sourceRemainingCostUsd) :
    payRest cfg false base impact progress ((stage,cost)::tail)=
      .error (.insufficientFundsToPayForCosts payment.sourceRemainingCostUsd stage.label) := by
  rw [payRest,paid]
  simp only [bind,Except.bind,if_pos shortfall,Bool.false_eq_true,ite_false]
  rfl

theorem payRest_exception_fees (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result) (stage : Stage) (residual : ℕ)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result)
    (exceptional : result.kind=.exceptional stage residual) :
    result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0 := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    cases exceptional
  | cons head tail ih =>
    rcases head with ⟨current,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress current cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      by_cases positive : 0<payment.sourceRemainingCostUsd
      · rw [if_pos positive] at success
        cases allowedEq : insolvencyAllowed with
        | false =>
          rw [allowedEq] at success
          change Except.error _=Except.ok result at success
          cases success
        | true =>
          rw [allowedEq] at success
          change Except.ok _=Except.ok result at success
          obtain rfl := Except.ok.inj success
          exact ⟨rfl,rfl⟩
      · rw [if_neg positive] at success
        exact ih next success

theorem run_exception_fees (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result) (stage : Stage) (residual : ℕ)
    (success : run before cfg domain buckets ids=.ok result) (exceptional : result.kind=.exceptional stage residual) :
    result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0 := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  by_cases positive : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos positive] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      exact ⟨rfl,rfl⟩
  · simp only [finish,if_neg positive] at finished
    exact payRest_exception_fees _ _ _ _ _ _ _ _ _ finished exceptional

/-- Selected prefix correctness; economic coverage is the separate constructive_solvency theorem. -/
theorem liquidation_correct (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    Admitted (equity before cfg buckets domain) cfg ∧ Policy result ∧
    (∀ step∈result.progress.executed,Step.Financial cfg.prices step) ∧
    result.progress.fees.pending=
      ((Funding.quote before.position cfg.latest domain).pendingClaimPrimary,
       (Funding.quote before.position cfg.latest domain).pendingClaimSecondary,cfg.latest) ∧
    (∀ stage residual,result.kind=.exceptional stage residual →
      before.position.sizeUsd=cfg.sizeDeltaUsd ∧ (cfg.liquidation=true ∨ cfg.secondaryAdl=true) ∧
      0<residual ∧ result.progress.fees.fundingFee=0 ∧ result.progress.fees.nonFundingFee=0) := by
  refine ⟨(run_execution _ _ _ _ _ _ success).2.1,run_policy _ _ _ _ _ _ success,
    run_financial _ _ _ _ _ _ success,run_pending _ _ _ _ _ _ success,?_⟩
  intro stage residual exceptional
  obtain ⟨done,_,_,shape⟩ := run_prefix _ _ _ _ _ _ success
  rw [exceptional] at shape
  have fees := run_exception_fees _ _ _ _ _ _ _ _ success exceptional
  exact ⟨shape.1,shape.2.1,shape.2.2.1,fees⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
