from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Close.lean');s=p.read_text().replace('end DefiKernel.Margin.Close','')
s+='''
def primaryNeed (prices : Payment.Prices) (cost : ℕ) : ℕ := (cost+prices.primary-1)/prices.primary
def primaryBudget (cfg : Config) (costs : List (Stage × ℕ)) : ℕ :=
  (costs.map (fun entry=>primaryNeed cfg.prices entry.2)).sum
def preparationTokens (cfg : Config) : ℕ :=
  (Realization.quote cfg.closeBasePnlUsd cfg.side cfg.pnlPrice).paidTokens+
  (Realization.quote cfg.closeImpactUsd cfg.side cfg.pnlPrice).paidTokens
/-- Concrete arithmetic/custody premises. No successful execution or zero-residual certificate is assumed. -/
def SolventBudget (before : Funding.State) (cfg : Config)
    (domain : Funding.Admissible before.position cfg.latest) (buckets : Funding.Buckets) : Prop :=
  PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state ∧
  Admitted (equity before cfg buckets domain) cfg ∧
  (preparationTokens cfg:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset) ∧
  (Funding.quote before.position cfg.latest domain).feePrimary+primaryBudget cfg (remainingCosts cfg) ≤
    buckets.output+buckets.collateral+(match cfg.side with | .primary => preparationTokens cfg | .secondary => 0)
def ExecutionRights (store : Store) (side : Realization.Side) (ids : List CapabilityId) : Prop :=
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId .invoke=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.position,.primary))=true ∧
  hasAuthority store Funding.payIds ownerContext PaymentSettlement.payId (.debit (.margin,.output,.secondary))=true ∧
  hasAuthority store Funding.holdingIds ownerContext Funding.holdingId .invoke=true ∧
  hasAuthority store Funding.holdingIds ownerContext Funding.holdingId (.changeSupply .margin .claimSecondary)=true ∧
  hasAuthority store ids ownerContext Realization.realizeId .invoke=true ∧
  hasAuthority store ids ownerContext Realization.realizeId (.debit (.margin,.pool,side.asset))=true

theorem fixture_rights (side : Realization.Side) : ExecutionRights (fixtureStore side) side realizationIds := by
  cases side <;> decide

/-- The SUM pool budget constructs both cash legs in source order, using remaining actual custody. -/
theorem preparation_exists (before : Funding.State) (cfg : Config) (buckets : Funding.Buckets)
    (ids : List CapabilityId)
    (compatible : PaymentSettlement.Compatible ⟨0,buckets.output,buckets.collateral,buckets.secondary⟩ before.world.state)
    (poolBudget : (preparationTokens cfg:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset))
    (invoke : hasAuthority before.world.capabilities ids ownerContext Realization.realizeId .invoke=true)
    (debit : hasAuthority before.world.capabilities ids ownerContext Realization.realizeId
      (.debit (.margin,.pool,cfg.side.asset))=true) :
    ∃ baseAfter base impactAfter impact,
      Realization.run before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ownerContext ids=.ok (baseAfter,base) ∧
      Realization.run ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd cfg.side cfg.pnlPrice ownerContext ids=
        .ok (impactAfter,impact) ∧
      PaymentSettlement.Compatible ⟨0,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).output,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).collateral,
        (addPayout (addPayout buckets cfg.side base.paidTokens) cfg.side impact.paidTokens).secondary⟩
        impactAfter.world.state ∧ impactAfter.world.capabilities=before.world.capabilities ∧
      impactAfter.world.state.balance (.margin,.pool,cfg.side.asset)=
        before.world.state.balance (.margin,.pool,cfg.side.asset)-(preparationTokens cfg:ℚ) := by
  let baseQuote := Realization.quote cfg.closeBasePnlUsd cfg.side cfg.pnlPrice
  let impactQuote := Realization.quote cfg.closeImpactUsd cfg.side cfg.pnlPrice
  have sumBudget : (baseQuote.paidTokens:ℚ)+(impactQuote.paidTokens:ℚ) ≤
      before.world.state.balance (.margin,.pool,cfg.side.asset) := by
    simpa only [preparationTokens,Nat.cast_add] using poolBudget
  have baseFunded : (baseQuote.paidTokens:ℚ) ≤ before.world.state.balance (.margin,.pool,cfg.side.asset) :=
    le_trans (le_add_of_nonneg_right (Nat.cast_nonneg _)) sumBudget
  obtain ⟨baseAfter,base,baseCall⟩ := Realization.run_exists before cfg.closeBasePnlUsd cfg.side cfg.pnlPrice ids
    (fun _=>⟨baseFunded,invoke,debit⟩)
  have baseInfo := Realization.actual_effects _ _ _ _ _ _ _ _ baseCall
  have basePool := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ baseCall).1
  rw [baseInfo.2.2.1] at basePool
  have impactFunded : (impactQuote.paidTokens:ℚ) ≤ baseAfter.world.state.balance (.margin,.pool,cfg.side.asset) := by
    rw [basePool]
    exact (le_sub_iff_add_le).mpr (by simpa only [add_comm] using sumBudget)
  have invokeAfter : hasAuthority baseAfter.world.capabilities ids ownerContext Realization.realizeId .invoke=true := by
    rw [baseInfo.2.1]; exact invoke
  have debitAfter : hasAuthority baseAfter.world.capabilities ids ownerContext Realization.realizeId
      (.debit (.margin,.pool,cfg.side.asset))=true := by rw [baseInfo.2.1]; exact debit
  obtain ⟨impactAfter,impact,impactCall⟩ := Realization.run_exists ⟨baseAfter.world,before.position⟩ cfg.closeImpactUsd
    cfg.side cfg.pnlPrice ids (fun _=>⟨impactFunded,invokeAfter,debitAfter⟩)
  have impactInfo := Realization.actual_effects _ _ _ _ _ _ _ _ impactCall
  have impactPool := (Realization.actual_pool_and_output _ _ _ _ _ _ _ _ impactCall).1
  rw [impactInfo.2.2.1] at impactPool
  have baseCompatible := payout_compatible _ _ _ _ _ _ _ _ compatible baseCall
  have impactCompatible := payout_compatible ⟨baseAfter.world,before.position⟩ impactAfter cfg.closeImpactUsd cfg.side
    cfg.pnlPrice ids impact (addPayout buckets cfg.side base.paidTokens) baseCompatible impactCall
  refine ⟨baseAfter,base,impactAfter,impact,baseCall,impactCall,impactCompatible,
    impactInfo.2.1.trans baseInfo.2.1,?_⟩
  rw [impactPool,basePool]
  simp only [preparationTokens,Nat.cast_add]
  ring
end DefiKernel.Margin.Close
''';p.write_text(s)
