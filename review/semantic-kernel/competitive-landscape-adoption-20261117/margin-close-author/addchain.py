from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
/-- Adjacency of the actual pre/post worlds recorded by the selected payment prefix. -/
def Chain (before after : Funding.State) : List Step → Prop
  | [] => before=after
  | step::tail => step.before=before ∧ Chain step.after after tail

theorem chain_append_step (start middle finish : Funding.State) (steps : List Step) (last : Step)
    (prior : Chain start middle steps) (beforeEq : last.before=middle) (afterEq : last.after=finish) :
    Chain start finish (steps++[last]) := by
  induction steps generalizing start with
  | nil =>
    change start=middle at prior
    subst start
    exact ⟨beforeEq,afterEq⟩
  | cons head tail ih => exact ⟨prior.1,ih head.after prior.2⟩

theorem payOne_chain (cfg : Config) (start : Funding.State) (progress next : Progress) (stage : Stage) (cost : ℕ)
    (payment : Payment.Result) (prior : Chain start progress.state progress.executed)
    (success : payOne cfg progress stage cost=.ok (next,payment)) : Chain start next.state next.executed := by
  obtain ⟨post,_,rfl⟩ := (payOne_ok_iff _ _ _ _ _ _).mp success
  exact chain_append_step _ _ _ _ _ prior rfl rfl

theorem payRest_chain (cfg : Config) (insolvencyAllowed : Bool) (base impact : Realization.Receipt)
    (start : Funding.State) (progress : Progress) (costs : List (Stage × ℕ)) (result : Result)
    (prior : Chain start progress.state progress.executed)
    (success : payRest cfg insolvencyAllowed base impact progress costs=.ok result) :
    Chain start result.progress.state result.progress.executed := by
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
      have step := payOne_chain _ _ _ _ _ _ _ prior actual
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
        exact ih next step success

theorem finish_chain (before : Funding.State) (cfg : Config) (base impact : Realization.Receipt)
    (prepared funded : Funding.State) (buckets : Funding.Buckets) (funding : Funding.Receipt)
    (result : Result) (success : finish before cfg base impact prepared funded buckets funding=.ok result) :
    Chain prepared result.progress.state result.progress.executed := by
  have initial : Chain prepared (fundingProgress cfg prepared funded buckets funding).state
      (fundingProgress cfg prepared funded buckets funding).executed := ⟨rfl,rfl⟩
  by_cases residual : 0<funding.payment.sourceRemainingCostUsd
  · simp only [finish,if_pos residual] at success
    cases allowedEq : allowed before cfg with
    | false => simp [allowedEq] at success
    | true =>
      simp only [allowedEq,ite_true] at success
      obtain rfl := Except.ok.inj success
      exact initial
  · simp only [finish,if_neg residual] at success
    exact payRest_chain _ _ _ _ _ _ _ _ initial success

/-- The chain's initial world is the actual two-cash-leg result, not an unrelated ledger. -/
theorem run_chain (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    ∃ baseAfter base impactAfter impact,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      Chain ⟨impactAfter.world,before.position⟩ result.progress.state result.progress.executed := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  exact ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,finish_chain _ _ _ _ _ _ _ _ _ finished⟩
end DefiKernel.Margin.Close
''';p.write_text(s)
