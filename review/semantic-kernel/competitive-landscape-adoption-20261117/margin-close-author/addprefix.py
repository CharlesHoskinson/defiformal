from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
/-- The source health fee contains one negative funding contribution; this is not post-payment subtraction. -/
theorem equity_funding_contribution (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets) :
    equity before cfg buckets domain=
      (buckets.collateral*cfg.prices.primary:ℕ)+before.position.pnlUsd+before.position.impactUsd-
      (cfg.healthOtherFeeTokens*cfg.prices.primary:ℕ)-
      ((Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary:ℕ) := by
  simp only [equity,Nat.add_mul,Nat.cast_add]
  ring

def Step.entry (step : Step) : Stage × ℕ := (step.stage,step.costUsd)

theorem payOne_entries (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    next.executed.map Step.entry=progress.executed.map Step.entry++[(stage,cost)] := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  simp [nextProgress,Step.entry]

/-- Returned entries are an exact prefix of the quoted active costs; later costs are retained as skipped. -/
theorem payRest_prefix (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    ∃ done,costs=done++result.skipped ∧
      result.progress.executed.map Step.entry=progress.executed.map Step.entry++done ∧
      (match result.kind with
        | .complete => result.skipped=[]
        | .exceptional stage residual => insolvencyAllowed=true ∧ 0<residual ∧
            ∃ earlier cost,done=earlier++[(stage,cost)]) := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact ⟨[],rfl,by simp,rfl⟩
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have entries := payOne_entries _ _ _ _ _ _ actual
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
          exact ⟨[(stage,cost)],rfl,entries,rfl,residual,[],cost,rfl⟩
      · rw [if_neg residual] at success
        obtain ⟨done,partition,observed,shape⟩ := ih next success
        refine ⟨(stage,cost)::done,?_,?_,?_⟩
        · rw [partition]; rfl
        · rw [observed,entries,List.append_assoc]; rfl
        · cases kind : result.kind with
          | complete => simpa only [kind] using shape
          | exceptional stopped remaining =>
            rw [kind] at shape
            obtain ⟨allowed,positive,earlier,stoppedCost,last⟩ := shape
            exact ⟨allowed,positive,(stage,cost)::earlier,stoppedCost,by rw [last]; rfl⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
