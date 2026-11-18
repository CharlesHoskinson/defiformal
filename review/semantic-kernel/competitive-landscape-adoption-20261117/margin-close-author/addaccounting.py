from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
/-- Actual preparation/funding/payment execution conserves both physical assets and leaves owner funding claims pending. -/
theorem run_accounting (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets)
    (ids : List CapabilityId) (result : Result)
    (success : run before cfg domain buckets ids=.ok result) :
    result.progress.state.position=before.position ∧
    result.progress.state.world.capabilities=before.world.capabilities ∧
    total result.progress.state.world.state .margin .primary=total before.world.state .margin .primary ∧
    total result.progress.state.world.state .margin .secondary=total before.world.state .margin .secondary ∧
    result.progress.state.world.state.balance (.margin,.owner,.claimPrimary)=
      before.world.state.balance (.margin,.owner,.claimPrimary) ∧
    result.progress.state.world.state.balance (.margin,.owner,.claimSecondary)=
      before.world.state.balance (.margin,.owner,.claimSecondary) := by
  obtain ⟨_,_,baseAfter,base,impactAfter,impact,funded,funding,baseCall,impactCall,fundingCall,finished⟩ :=
    run_execution _ _ _ _ _ _ success
  have baseInfo := Realization.actual_effects _ _ _ _ _ _ _ _ baseCall
  have impactInfo := Realization.actual_effects _ _ _ _ _ _ _ _ impactCall
  have fundingInfo := Funding.actual_effects _ _ _ _ _ _ _ _ _ _ _ fundingCall
  have final := finish_preserves _ _ _ _ _ _ _ _ _ finished
  have totals (asset : Asset) (notClaim : asset≠.claimSecondary) :
      total result.progress.state.world.state .margin asset=total before.world.state .margin asset := by
    calc
      _ = total funded.world.state .margin asset := final.2.2.1 asset
      _ = total impactAfter.world.state .margin asset := by
        simpa only [if_neg notClaim,add_zero] using Funding.actual_accounting _ _ _ _ _ _ _ _ _ _ _ fundingCall asset
      _ = total baseAfter.world.state .margin asset := Realization.actual_accounting _ _ _ _ _ _ _ _ impactCall asset
      _ = total before.world.state .margin asset := Realization.actual_accounting _ _ _ _ _ _ _ _ baseCall asset
  refine ⟨final.1.trans fundingInfo.1,
    final.2.1.trans (fundingInfo.2.1.trans (impactInfo.2.1.trans baseInfo.2.1)),
    totals .primary (by decide),totals .secondary (by decide),?_,?_⟩
  · have fundingOwner := (Funding.actual_owner_claims_and_holding _ _ _ _ _ _ _ _ _ _ _ fundingCall).1
    calc
      _ = funded.world.state.balance (.margin,.owner,.claimPrimary) :=
        final.2.2.2 _ (by simp [PaymentSettlement.affected])
      _ = impactAfter.world.state.balance (.margin,.owner,.claimPrimary) := fundingOwner
      _ = baseAfter.world.state.balance (.margin,.owner,.claimPrimary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ impactCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
      _ = before.world.state.balance (.margin,.owner,.claimPrimary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ baseCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
  · have fundingOwner := (Funding.actual_owner_claims_and_holding _ _ _ _ _ _ _ _ _ _ _ fundingCall).2.1
    calc
      _ = funded.world.state.balance (.margin,.owner,.claimSecondary) :=
        final.2.2.2 _ (by simp [PaymentSettlement.affected])
      _ = impactAfter.world.state.balance (.margin,.owner,.claimSecondary) := fundingOwner
      _ = baseAfter.world.state.balance (.margin,.owner,.claimSecondary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ impactCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
      _ = before.world.state.balance (.margin,.owner,.claimSecondary) :=
        Realization.actual_frame _ _ _ _ _ _ _ _ baseCall _ (by cases cfg.side <;> decide) (by cases cfg.side <;> decide)
end DefiKernel.Margin.Close
''';p.write_text(s)
