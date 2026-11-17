from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
def Fees.pending (fees : Fees) : ℕ × ℕ × Funding.Factors :=
  (fees.pendingClaimPrimary,fees.pendingClaimSecondary,fees.latest)
theorem payOne_pending (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    next.fees.pending=progress.fees.pending := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  change (if stage=.fees && !(payment.sourceRemainingCostUsd=0 && payment.paidSecondary=0)
    then emptyFees progress.fees else progress.fees).pending=progress.fees.pending
  split <;> rfl

theorem payRest_pending (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    result.progress.fees.pending=progress.fees.pending := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    rfl
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      have step := payOne_pending _ _ _ _ _ _ actual
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
        exact (ih next success).trans step

/-- Zeroing fees never loses pending owner funding claims or their latest-factor receipt. -/
theorem run_pending (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    result.progress.fees.pending=
      ((Funding.quote before.position cfg.latest domain).pendingClaimPrimary,
       (Funding.quote before.position cfg.latest domain).pendingClaimSecondary,cfg.latest) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.2.1
  have projected : result.progress.fees.pending=(initialFees funding.funding cfg).pending := by
    by_cases residual : 0<funding.payment.sourceRemainingCostUsd
    · simp only [finish,if_pos residual] at finished
      cases allowedEq : allowed before cfg with
      | false => simp [allowedEq] at finished
      | true =>
        simp only [allowedEq,ite_true] at finished
        obtain rfl := Except.ok.inj finished
        rfl
    · simp only [finish,if_neg residual] at finished
      exact payRest_pending _ _ _ _ _ _ _ finished
  rw [projected,observation]
  rfl

/-- The returned trace is an exact active-cost prefix; exceptional success requires actual full-size eligibility. -/
theorem run_prefix (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∃ done,((Stage.funding,(Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary)::
      remainingCosts cfg)=done++result.skipped ∧ result.progress.executed.map Step.entry=done ∧
      (match result.kind with
        | .complete => result.skipped=[]
        | .exceptional stage residual => before.position.sizeUsd=cfg.sizeDeltaUsd ∧
            (cfg.liquidation=true ∨ cfg.secondaryAdl=true) ∧ 0<residual ∧
            ∃ earlier cost,done=earlier++[(stage,cost)]) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have observation := (Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.2.1
  let entry := (Stage.funding,funding.funding.feePrimary*cfg.prices.primary)
  have entryEq : entry=(Stage.funding,(Funding.quote before.position cfg.latest domain).feePrimary*cfg.prices.primary) := by
    rw [observation]; rfl
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      have eligible := (allowed_iff before cfg).mp allowedEq
      refine ⟨[entry],?_,?_,eligible.1,eligible.2,residual,[],entry.2,?_⟩
      · rw [entryEq]; rfl
      · rfl
      · rfl
  · simp only [finish,if_neg residual] at finished
    obtain ⟨done,partition,observed,shape⟩ := payRest_prefix _ _ _ _ _ _ _ finished
    refine ⟨entry::done,?_,?_,?_⟩
    · rw [← entryEq,partition]; rfl
    · simpa only [fundingProgress,List.map_cons,List.map_nil,Step.entry,List.cons_append,List.nil_append] using observed
    · cases kind : result.kind with
      | complete => simpa only [kind] using shape
      | exceptional stopped remaining =>
        rw [kind] at shape
        obtain ⟨eligible,positive,earlier,cost,last⟩ := shape
        have eligibility := (allowed_iff before cfg).mp eligible
        exact ⟨eligibility.1,eligibility.2,positive,entry::earlier,cost,by rw [last]; rfl⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
