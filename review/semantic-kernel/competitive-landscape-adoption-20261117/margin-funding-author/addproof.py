from pathlib import Path
p=Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/Funding.lean')
s=p.read_text();s=s.replace('private def registry','private def holdingRegistry (quantity : ℕ) : Registry Party Asset Domain :=\n  fun id => if id=holdingId then some (holdingTemplate quantity) else none\ndef holdingExecute (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)\n    (ids : List CapabilityId) (pre : Ledger) : Except Typed.Refusal World :=\n  Typed.execute (holdingRegistry quantity) store ctx (fun _=>none) 0 (holdingRequestAux ids) pre\nprivate def registry') if False else s
# Insert holding request/registry helper before run.
pos=s.index('def run (before')
s=s[:pos]+'''private def holdingRegistry (quantity : ℕ) : Registry Party Asset Domain :=
  fun id => if id=holdingId then some (holdingTemplate quantity) else none
def holdingExecute (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (holdingRegistry quantity) store ctx (fun _=>none) 0 (holdingRequest ids) pre
'''+s[pos:]
s=s.replace('(Typed.execute (registry prices i) paid.capabilities ctx (fun _=>none) 0\n        (holdingRequest holdingIds) paid.state)', '(holdingExecute payment.paidSecondary paid.capabilities ctx holdingIds paid.state)')
s=s.replace('end DefiKernel.Margin.Funding','')
s+='''
/-- Both obligations are in raw token units: ceil for fees, floor for pending funding claims. -/
theorem fee_rounding (position : Position) (latest : Factors) (domain : Admissible position latest) :
    position.sizeUsd*(latest.fee-position.snapshots.fee) ≤
      (quote position latest domain).feePrimary*precision ∧
    (quote position latest domain).feePrimary*precision <
      position.sizeUsd*(latest.fee-position.snapshots.fee)+precision := by
  exact Payment.primary_rounding ⟨precision,1,by norm_num [precision],by decide⟩
    ⟨position.sizeUsd*(latest.fee-position.snapshots.fee),0,0,0⟩

theorem claim_rounding (size difference : ℕ) :
    (size*difference/precision)*precision ≤ size*difference ∧
    size*difference < (size*difference/precision+1)*precision := by
  have positive : 0 < precision := by norm_num [precision]
  have remainder := Nat.mod_lt (size*difference) positive
  have division := Nat.div_add_mod (size*difference) precision
  rw [Nat.mul_comm] at division
  constructor
  · omega
  · rw [Nat.add_mul]; omega

/-- Converting the already-rounded funding token fee to USD creates no further primary dust. -/
theorem required_exact (prices : Payment.Prices) (q : Quote) (b : Buckets) :
    (Payment.payCost prices (paymentInput prices q b)).primaryRequired=q.feePrimary := by
  have bounds := Payment.primary_rounding prices (paymentInput prices q b)
  change q.feePrimary*prices.primary ≤ _ ∧ _ < q.feePrimary*prices.primary+prices.primary at bounds
  have lower := (Nat.mul_le_mul_right prices.primary_pos).mp bounds.1
  have upper : (Payment.payCost prices (paymentInput prices q b)).primaryRequired < q.feePrimary+1 := by
    apply (Nat.mul_lt_mul_right prices.primary_pos).mp
    simpa only [Nat.add_mul,one_mul] using bounds.2
  omega

def holdingEvaluated (quantity : ℕ) : Evaluated Party Asset Domain :=
  ⟨true,[((.margin,.holding,.claimSecondary),(quantity:ℚ))],
    [((.margin,.claimSecondary),(quantity:ℚ))],[],[],[],[],[(.margin,.holding,.claimSecondary)]⟩
theorem holding_evaluate (quantity : ℕ) (pre : Ledger) (ctx : InvocationContext Party Domain) :
    (holdingTemplate quantity).evaluate ⟨pre,(fun _=>none),ctx.principal,[],Args.nil,0⟩ =
      .ok (holdingEvaluated quantity) := by
  simp [Template.evaluate,Template.requiredStateReads,Template.requiredEnvReads,
    holdingTemplate,ref,packedRef,Expr.eval,Expr.stateReads,Expr.envReads,
    resolveRefs,CellRef.resolve,PartyRef.resolve,holdingEvaluated,
    bind,Except.bind,pure,Except.pure]

theorem holding_ok_iff (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger) (post : World) :
    holdingExecute quantity store ctx ids pre = .ok post ↔
      ctx.principal=.owner ∧ hasAuthority store ids ctx holdingId .invoke=true ∧
      (holdingEvaluated quantity).Valid store ctx (holdingRequest ids) pre ∧
      post.capabilities=store ∧ ∀ cell,post.state.balance cell=pre.balance cell+
        (holdingEvaluated quantity).effect cell := by
  have correspondence := Typed.execute_ok_iff (holdingRegistry quantity) store ctx (fun _=>none) 0
    (holdingRequest ids) pre post
  constructor
  · intro success
    obtain ⟨selected,registered,actor,dom,arity,args,checked,invoke,e,observed,
      valid,capabilities,balances⟩ := correspondence.mp success
    have selectedEq : selected=holdingTemplate quantity := by
      simpa [holdingRegistry,holdingRequest] using registered.symm
    subst selected
    have argsEq : args=Args.nil := Except.ok.inj (checked.symm.trans (by rfl))
    subst args
    have same : e=holdingEvaluated quantity :=
      Except.ok.inj (observed.symm.trans (holding_evaluate quantity pre ctx))
    subst e
    exact ⟨by simpa [holdingRequest,eq_comm] using actor,invoke,valid,capabilities,balances⟩
  · rintro ⟨bound,invoke,valid,capabilities,balances⟩
    apply correspondence.mpr
    refine ⟨holdingTemplate quantity,?_,?_,?_,rfl,Args.nil,rfl,invoke,
      holdingEvaluated quantity,holding_evaluate quantity pre ctx,valid,capabilities,balances⟩
    · simp [holdingRegistry,holdingRequest]
    · simp [holdingRequest,bound]
    · cases ctx.domain; rfl

theorem holding_effect (quantity : ℕ) (cell : Cell Party Asset Domain) :
    (holdingEvaluated quantity).effect cell =
      if (.margin,.holding,.claimSecondary)=cell then (quantity:ℚ) else 0 := by
  simp [Evaluated.effect,holdingEvaluated]

theorem holding_valid (quantity : ℕ) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (pre : Ledger)
    (authority : hasAuthority store ids ctx holdingId (.changeSupply .margin .claimSecondary)=true) :
    (holdingEvaluated quantity).Valid store ctx (holdingRequest ids) pre := by
  refine ⟨rfl,?_,rfl,?_,?_,?_,?_,?_,?_⟩
  · simp [Evaluated.stateReadsOK,holdingEvaluated]
  · have domain : ctx.domain=.margin := by cases ctx.domain; rfl
    rw [domain]
    simp only [Evaluated.domainOK,decide_eq_true_eq]
    refine ⟨by simp [holdingEvaluated],?_,?_⟩
    · intro ⟨d,p,a⟩ _; cases d; rfl
    · intro d a _; cases d; rfl
  · simp only [Evaluated.debitsOK,decide_eq_true_eq]
    intro cell negative
    rw [holding_effect] at negative
    split at negative
    · exact (not_lt_of_ge (Nat.cast_nonneg _) negative).elim
    · exact (lt_irrefl _ negative).elim
  · simp only [Evaluated.suppliesOK,decide_eq_true_eq]
    intro d a nonzero
    cases d; cases a <;> simp_all [Evaluated.supply,holdingEvaluated,holdingRequest]
  · intro cell
    rw [holding_effect]
    exact add_nonneg (pre.nonneg cell) (by split <;> positivity)
  · simp only [Evaluated.accountingOK,decide_eq_true_eq]
    intro d a
    cases d; cases a <;> simp [Evaluated.effect,Evaluated.supply,holdingEvaluated,
      PaymentSettlement.sum_if_party]
  · simp only [Evaluated.writesOK,decide_eq_true_eq]
    intro cell outside
    simp only [holdingEvaluated,List.mem_singleton] at outside
    rw [holding_effect,if_neg outside]

theorem holding_exists (quantity : ℕ) (store : Store) (ids : List CapabilityId) (pre : Ledger)
    (invoke : hasAuthority store ids ownerContext holdingId .invoke=true)
    (authority : hasAuthority store ids ownerContext holdingId (.changeSupply .margin .claimSecondary)=true) :
    ∃ post,holdingExecute quantity store ownerContext ids pre=.ok post := by
  have valid := holding_valid quantity store ownerContext ids pre authority
  have balances := valid.2.2.2.2.2.2.1
  let post : World := ⟨⟨fun cell=>pre.balance cell+(holdingEvaluated quantity).effect cell,balances⟩,store⟩
  exact ⟨post,(holding_ok_iff quantity store ownerContext ids pre post).mpr
    ⟨rfl,invoke,valid,rfl,by intro cell; rfl⟩⟩
end DefiKernel.Margin.Funding
'''
p.write_text(s)
