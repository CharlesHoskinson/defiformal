from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Realization.lean');s=p.read_text().replace('end DefiKernel.Margin.Realization','')
s+='''
theorem nonpositive_quote (basePnlUsd : ℤ) (side : Side) (price : Price) (nonpositive : basePnlUsd≤0) :
    (quote basePnlUsd side price).paidTokens=0 ∧ (quote basePnlUsd side price).floorDustUsd=0 := by
  simp [quote,Int.toNat_of_nonpos nonpositive]

theorem run_ok_iff (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt) :
    run before basePnlUsd side price ctx ids=.ok (after,observed) ↔
      after.position=before.position ∧ observed=quote basePnlUsd side price ∧
      if 0 < basePnlUsd then
        execute basePnlUsd side price before.world.capabilities ctx ids before.world.state=.ok after.world
      else after.world=before.world := by
  by_cases positive : 0 < basePnlUsd
  · cases executed : execute basePnlUsd side price before.world.capabilities ctx ids before.world.state with
    | error reason => simp [run,positive,executed,bind,Except.bind]
    | ok post =>
      cases after
      simp [run,positive,executed,bind,Except.bind,pure,Except.pure,eq_comm,and_comm,and_left_comm,and_assoc]
  · cases after
    simp [run,positive,bind,Except.bind,pure,Except.pure,eq_comm,and_comm,and_left_comm,and_assoc]

theorem actual_effects (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt)
    (success : run before basePnlUsd side price ctx ids=.ok (after,observed)) :
    after.position=before.position ∧ after.world.capabilities=before.world.capabilities ∧
      observed=quote basePnlUsd side price ∧ ∀ cell,after.world.state.balance cell=
        before.world.state.balance cell+(evaluated basePnlUsd side price).effect cell := by
  obtain ⟨position,observation,execution⟩ := (run_ok_iff _ _ _ _ _ _ _ _).mp success
  by_cases positive : 0 < basePnlUsd
  · rw [if_pos positive] at execution
    obtain ⟨_,_,_,caps,balances⟩ := (execute_ok_iff _ _ _ _ _ _ _ _).mp execution
    exact ⟨position,caps,observation,balances⟩
  · rw [if_neg positive] at execution
    have zero := (nonpositive_quote basePnlUsd side price (le_of_not_gt positive)).1
    refine ⟨position,by rw [execution],observation,?_⟩
    intro cell
    rw [execution]
    simp [evaluated,Evaluated.effect,zero]

/-- Actual payout is a transfer from the selected pool, not a mint justified by marked PnL. -/
theorem actual_pool_and_output (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt)
    (success : run before basePnlUsd side price ctx ids=.ok (after,observed)) :
    after.world.state.balance (.margin,.pool,side.asset)=
      before.world.state.balance (.margin,.pool,side.asset)-(observed.paidTokens:ℚ) ∧
    after.world.state.balance (.margin,.output,side.asset)=
      before.world.state.balance (.margin,.output,side.asset)+(observed.paidTokens:ℚ) := by
  have info := actual_effects _ _ _ _ _ _ _ _ success
  constructor
  · rw [info.2.2.2 _,pool_effect,info.2.2.1,sub_eq_add_neg]
  · rw [info.2.2.2 _,output_effect,info.2.2.1]

theorem actual_frame (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt)
    (success : run before basePnlUsd side price ctx ids=.ok (after,observed))
    (cell : Cell Party Asset Domain) (notPool : cell≠(.margin,.pool,side.asset))
    (notOutput : cell≠(.margin,.output,side.asset)) :
    after.world.state.balance cell=before.world.state.balance cell := by
  rw [(actual_effects _ _ _ _ _ _ _ _ success).2.2.2 cell,
    effect_outside _ _ _ _ notPool notOutput,add_zero]

theorem actual_accounting (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt)
    (success : run before basePnlUsd side price ctx ids=.ok (after,observed)) (asset : Asset) :
    total after.world.state .margin asset=total before.world.state .margin asset := by
  have effects := (actual_effects _ _ _ _ _ _ _ _ success).2.2.2
  unfold total
  simp_rw [effects]
  rw [Finset.sum_add_distrib]
  have zero : ∑ p : Party,(evaluated basePnlUsd side price).effect (.margin,p,asset)=0 := by
    cases side <;> cases asset <;> simp [Evaluated.effect,evaluated,Side.asset,
      Finset.sum_add_distrib,PaymentSettlement.sum_if_party]
  rw [zero,add_zero]

/-- Floor-value correspondence uses the actual executed output gain and the explicit close observation. -/
theorem actual_floor_value (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId)
    (after : Funding.State) (observed : Receipt)
    (success : run before basePnlUsd side price ctx ids=.ok (after,observed)) :
    (after.world.state.balance (.margin,.output,side.asset)-
      before.world.state.balance (.margin,.output,side.asset))*(price.max:ℚ)+
      (observed.floorDustUsd:ℚ)=(basePnlUsd.toNat:ℚ) ∧ observed.floorDustUsd<price.max := by
  have observation := (actual_effects _ _ _ _ _ _ _ _ success).2.2.1
  have output := (actual_pool_and_output _ _ _ _ _ _ _ _ success).2
  rw [output,observation]
  have quoteBound := quote_reconciliation basePnlUsd side price
  constructor
  · simp only [add_sub_cancel_left]
    exact_mod_cast quoteBound.1
  · exact quoteBound.2

/-- Sufficient actual pool liquidity constructs payout; no assumed successful execution is used. -/
theorem run_exists (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ids : List CapabilityId)
    (conditions : 0 < basePnlUsd →
      ((quote basePnlUsd side price).paidTokens:ℚ) ≤ before.world.state.balance (.margin,.pool,side.asset) ∧
      hasAuthority before.world.capabilities ids ownerContext realizeId .invoke=true ∧
      hasAuthority before.world.capabilities ids ownerContext realizeId (.debit (.margin,.pool,side.asset))=true) :
    ∃ after observed,run before basePnlUsd side price ownerContext ids=.ok (after,observed) := by
  by_cases positive : 0 < basePnlUsd
  · obtain ⟨funded,invoke,debit⟩ := conditions positive
    obtain ⟨post,success⟩ := execute_exists basePnlUsd side price before.world.capabilities ids
      before.world.state funded invoke debit
    exact ⟨⟨post,before.position⟩,quote basePnlUsd side price,
      (run_ok_iff _ _ _ _ _ _ _ _).mpr ⟨rfl,rfl,by rw [if_pos positive]; exact success⟩⟩
  · exact ⟨before,quote basePnlUsd side price,
      (run_ok_iff _ _ _ _ _ _ _ _).mpr ⟨rfl,rfl,by rw [if_neg positive]⟩⟩

theorem provisioned_exact (basePnlUsd : ℤ) (side : Side) (price : Price) :
    provisioned basePnlUsd side price=.ok (fixtureStore side) := by cases side <;> rfl

theorem fixture_rights (side : Side) :
    hasAuthority (fixtureStore side) ids ownerContext realizeId .invoke=true ∧
    hasAuthority (fixtureStore side) ids ownerContext realizeId (.debit (.margin,.pool,side.asset))=true := by
  cases side <;> decide
end DefiKernel.Margin.Realization
''';p.write_text(s)
