from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Realization.lean');s=p.read_text().replace('end DefiKernel.Margin.Realization','')
s+='''
/-- The returned dust is the actual floor remainder, not a rounded fee. -/
theorem quote_reconciliation (basePnlUsd : ℤ) (side : Side) (price : Price) :
    (quote basePnlUsd side price).paidTokens*price.max+
      (quote basePnlUsd side price).floorDustUsd=basePnlUsd.toNat ∧
    (quote basePnlUsd side price).floorDustUsd<price.max := by
  constructor
  · exact (Nat.div_add_mod basePnlUsd.toNat price.max).symm.trans (by omega)
  · exact Nat.mod_lt _ price.positive

theorem positive_floor (basePnlUsd : ℤ) (side : Side) (price : Price) (positive : 0 < basePnlUsd) :
    ((quote basePnlUsd side price).paidTokens:ℤ)*(price.max:ℤ) ≤ basePnlUsd ∧
    basePnlUsd < ((quote basePnlUsd side price).paidTokens+1:ℤ)*(price.max:ℤ) := by
  have reconciliation := quote_reconciliation basePnlUsd side price
  have down : (quote basePnlUsd side price).paidTokens*price.max ≤ basePnlUsd.toNat := by omega
  have up : basePnlUsd.toNat < ((quote basePnlUsd side price).paidTokens+1)*price.max := by
    rw [Nat.add_mul]; omega
  have cast : (basePnlUsd.toNat:ℤ)=basePnlUsd := Int.toNat_of_nonneg (le_of_lt positive)
  constructor
  · exact_mod_cast (show ((quote basePnlUsd side price).paidTokens:ℤ)*(price.max:ℤ) ≤
      (basePnlUsd.toNat:ℤ) from by exact_mod_cast down) |>.trans_eq cast
  · rw [← cast]
    exact_mod_cast up

def evaluated (basePnlUsd : ℤ) (side : Side) (price : Price) : Evaluated Party Asset Domain :=
  let amount := (quote basePnlUsd side price).paidTokens
  ⟨true,[((.margin,.pool,side.asset),-(amount:ℚ)),((.margin,.output,side.asset),(amount:ℚ))],[],[],[],
    [(.margin,.pool,side.asset),(.margin,.output,side.asset)],[],
    [(.margin,.pool,side.asset),(.margin,.output,side.asset)]⟩

theorem template_evaluate (basePnlUsd : ℤ) (side : Side) (price : Price) (pre : Ledger)
    (ctx : InvocationContext Party Domain) :
    (template basePnlUsd side price).evaluate ⟨pre,(fun _=>none),ctx.principal,[],Args.nil,0⟩ =
      .ok (evaluated basePnlUsd side price) := by
  simp [Template.evaluate,Template.requiredStateReads,Template.requiredEnvReads,
    template,ref,packedRef,Expr.eval,Expr.stateReads,Expr.envReads,
    resolveRefs,CellRef.resolve,PartyRef.resolve,evaluated,bind,Except.bind,pure,Except.pure]

theorem execute_ok_iff (basePnlUsd : ℤ) (side : Side) (price : Price) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) (post : World) :
    execute basePnlUsd side price store ctx ids pre=.ok post ↔
      ctx.principal=.owner ∧ hasAuthority store ids ctx realizeId .invoke=true ∧
      (evaluated basePnlUsd side price).Valid store ctx (request ids) pre ∧
      post.capabilities=store ∧ ∀ cell,post.state.balance cell=pre.balance cell+
        (evaluated basePnlUsd side price).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry basePnlUsd side price) store ctx (fun _=>none) 0
    (request ids) pre post
  constructor
  · intro success
    obtain ⟨selected,registered,actor,dom,arity,args,checked,invoke,e,observed,
      valid,capabilities,balances⟩ := correspondence.mp success
    have selectedEq : selected=template basePnlUsd side price := by
      simpa [registry,request] using registered.symm
    subst selected
    have argsEq : args=Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have same : e=evaluated basePnlUsd side price :=
      Except.ok.inj (observed.symm.trans (template_evaluate basePnlUsd side price pre ctx))
    subst e
    exact ⟨by simpa [request,eq_comm] using actor,invoke,valid,capabilities,balances⟩
  · rintro ⟨bound,invoke,valid,capabilities,balances⟩
    apply correspondence.mpr
    refine ⟨template basePnlUsd side price,?_,?_,?_,rfl,Args.nil,rfl,invoke,
      evaluated basePnlUsd side price,template_evaluate basePnlUsd side price pre ctx,
      valid,capabilities,balances⟩
    · simp [registry,request]
    · simp [request,bound]
    · cases ctx.domain; rfl

theorem pool_effect (basePnlUsd : ℤ) (side : Side) (price : Price) :
    (evaluated basePnlUsd side price).effect (.margin,.pool,side.asset)=
      -((quote basePnlUsd side price).paidTokens:ℚ) := by simp [evaluated,Evaluated.effect]
theorem output_effect (basePnlUsd : ℤ) (side : Side) (price : Price) :
    (evaluated basePnlUsd side price).effect (.margin,.output,side.asset)=
      ((quote basePnlUsd side price).paidTokens:ℚ) := by simp [evaluated,Evaluated.effect]
theorem effect_outside (basePnlUsd : ℤ) (side : Side) (price : Price)
    (cell : Cell Party Asset Domain) (notPool : cell≠(.margin,.pool,side.asset))
    (notOutput : cell≠(.margin,.output,side.asset)) :
    (evaluated basePnlUsd side price).effect cell=0 := by
  simp [evaluated,Evaluated.effect,Ne.symm notPool,Ne.symm notOutput]
theorem supply_zero (basePnlUsd : ℤ) (side : Side) (price : Price) (domain : Domain) (asset : Asset) :
    (evaluated basePnlUsd side price).supply domain asset=0 := by simp [evaluated,Evaluated.supply]

theorem evaluated_valid (basePnlUsd : ℤ) (side : Side) (price : Price) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger)
    (funded : ((quote basePnlUsd side price).paidTokens:ℚ) ≤ pre.balance (.margin,.pool,side.asset))
    (debit : hasAuthority store ids ctx realizeId (.debit (.margin,.pool,side.asset))=true) :
    (evaluated basePnlUsd side price).Valid store ctx (request ids) pre := by
  have balances : ∀ cell,0 ≤ pre.balance cell+(evaluated basePnlUsd side price).effect cell := by
    intro cell
    by_cases hp : cell=(.margin,.pool,side.asset)
    · subst cell; rw [pool_effect]
      simpa only [sub_eq_add_neg] using sub_nonneg.mpr funded
    · by_cases ho : cell=(.margin,.output,side.asset)
      · subst cell; rw [output_effect]
        exact add_nonneg (pre.nonneg _) (Nat.cast_nonneg _)
      · rw [effect_outside _ _ _ _ hp ho]; simpa using pre.nonneg cell
  refine ⟨rfl,?_,rfl,?_,?_,?_,balances,?_,?_⟩
  · simp [Evaluated.stateReadsOK,evaluated]
  · have domain : ctx.domain=.margin := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨by simp [evaluated],?_,?_⟩
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    by_cases hp : cell=(.margin,.pool,side.asset)
    · subst cell; exact debit
    · by_cases ho : cell=(.margin,.output,side.asset)
      · subst cell; rw [output_effect] at negative
        exact (not_lt_of_ge (Nat.cast_nonneg _) negative).elim
      · rw [effect_outside _ _ _ _ hp ho] at negative
        exact (lt_irrefl _ negative).elim
  · simp [Evaluated.suppliesOK,supply_zero]
  · simp only [Evaluated.accountingOK,decide_eq_true_eq]
    intro d a
    cases d; cases side <;> cases a <;>
      simp [evaluated,Evaluated.effect,Evaluated.supply,Side.asset,
        Finset.sum_add_distrib,PaymentSettlement.sum_if_party]
  · simp only [Evaluated.writesOK,decide_eq_true_eq]
    intro cell outside
    simp only [evaluated,List.mem_cons,List.mem_singleton,not_or] at outside
    exact effect_outside _ _ _ _ outside.1 outside.2

theorem execute_exists (basePnlUsd : ℤ) (side : Side) (price : Price) (store : Store)
    (ids : List CapabilityId) (pre : Ledger)
    (funded : ((quote basePnlUsd side price).paidTokens:ℚ) ≤ pre.balance (.margin,.pool,side.asset))
    (invoke : hasAuthority store ids ownerContext realizeId .invoke=true)
    (debit : hasAuthority store ids ownerContext realizeId (.debit (.margin,.pool,side.asset))=true) :
    ∃ post,execute basePnlUsd side price store ownerContext ids pre=.ok post := by
  have valid := evaluated_valid basePnlUsd side price store ownerContext ids pre funded debit
  have balances := valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell=>pre.balance cell+(evaluated basePnlUsd side price).effect cell,balances⟩,store⟩
  exact ⟨post,(execute_ok_iff _ _ _ _ _ _ _ _).mpr ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩⟩
end DefiKernel.Margin.Realization
''';p.write_text(s)
