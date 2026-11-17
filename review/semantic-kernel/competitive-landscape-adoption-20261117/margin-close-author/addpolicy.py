from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
def Clear (steps : List Step) : Prop := ∀ step∈steps,step.payment.sourceRemainingCostUsd=0
def Policy (result : Result) : Prop := match result.kind with
  | .complete => Clear result.progress.executed
  | .exceptional stopped residual => ∃ earlier last,
      result.progress.executed=earlier++[last] ∧ Clear earlier ∧
      last.stage=stopped ∧ last.payment.sourceRemainingCostUsd=residual

theorem payOne_steps (cfg : Config) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (success : payOne cfg progress stage cost=.ok (next,payment)) :
    ∃ last,next.executed=progress.executed++[last] ∧ last.stage=stage ∧ last.payment=payment := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  exact ⟨⟨stage,cost,progress.buckets,progress.state,⟨post,progress.state.position⟩,payment⟩,rfl,rfl,rfl⟩

theorem payRest_policy (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (progress : Progress) (costs : List (Stage × ℕ)) (result : Result) (prior : Clear progress.executed)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) : Policy result := by
  induction costs generalizing progress with
  | nil =>
    rw [payRest] at success
    obtain rfl := Except.ok.inj success
    exact prior
  | cons head tail ih =>
    rcases head with ⟨stage,cost⟩
    rw [payRest] at success
    cases actual : payOne cfg progress stage cost with
    | error reason => simp [actual,bind,Except.bind] at success
    | ok pair =>
      rcases pair with ⟨next,payment⟩
      simp only [actual,bind,Except.bind] at success
      obtain ⟨last,entries,lastStage,lastPayment⟩ := payOne_steps _ _ _ _ _ _ actual
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
          exact ⟨progress.executed,last,entries,prior,lastStage,by rw [lastPayment]⟩
      · rw [if_neg residual] at success
        have zero : payment.sourceRemainingCostUsd=0 := by omega
        have clear : Clear next.executed := by
          intro step member
          rw [entries] at member
          rcases List.mem_append.mp member with old | lastMem
          · exact prior step old
          · have same := List.mem_singleton.mp lastMem
            subst step
            rw [lastPayment,zero]
        exact ih next clear success

/-- Complete results have no positive source residual; exceptional results stop at the first one. -/
theorem run_policy (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) : Policy result := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at finished
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at finished
    | true =>
      simp only [allowedEq,ite_true] at finished
      obtain rfl := Except.ok.inj finished
      refine ⟨[],⟨.funding,funding.funding.feePrimary*cfg.prices.primary,
        addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens,
        ⟨impactAfter.world,before.position⟩,funded,funding.payment⟩,rfl,?_,rfl,rfl⟩
      intro step member
      cases member
  · simp only [finish,if_neg residual] at finished
    have zero : funding.payment.sourceRemainingCostUsd=0 := by omega
    apply payRest_policy _ _ _ _ _ _ _ ?_ finished
    intro step member
    simp only [fundingProgress,List.mem_singleton] at member
    subst step
    exact zero
end DefiKernel.Margin.Close
''';p.write_text(s)
