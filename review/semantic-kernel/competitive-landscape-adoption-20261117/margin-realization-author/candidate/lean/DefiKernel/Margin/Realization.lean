import DefiKernel.Margin.Funding

/-! Pool-funded NoSwap realization of an explicit computed close base-PnL observation. -/
namespace DefiKernel.Margin.Realization
open DefiKernel.Typed
inductive Side where | primary | secondary deriving Repr, DecidableEq
def Side.asset : Side → Asset | .primary => .primary | .secondary => .secondary
structure Price where
  max : ℕ
  positive : 0 < max
structure Receipt where
  basePnlUsd : ℤ
  side : Side
  paidTokens : ℕ
  floorDustUsd : ℕ
  deriving Repr, DecidableEq
def quote (basePnlUsd : ℤ) (side : Side) (price : Price) : Receipt :=
  ⟨basePnlUsd,side,basePnlUsd.toNat/price.max,basePnlUsd.toNat%price.max⟩
def realizeId : OperationId := ⟨2⟩
def template (basePnlUsd : ℤ) (side : Side) (price : Price) : Op :=
  let amount := (quote basePnlUsd side price).paidTokens
  {signature:=[],domain:=.margin,partyArity:=0,guard:=.lit true,
   deltas:=[⟨side.asset,ref side.asset .pool,.lit (-(amount:ℚ))⟩,
     ⟨side.asset,ref side.asset .output,.lit amount⟩],supplyDeltas:=[],
   stateReads:=[packedRef side.asset .pool,packedRef side.asset .output],envReads:=[],
   writes:=[packedRef side.asset .pool,packedRef side.asset .output]}
private def registry (basePnlUsd : ℤ) (side : Side) (price : Price) : Registry Party Asset Domain :=
  fun id => if id=realizeId then some (template basePnlUsd side price) else none
def request (ids : List CapabilityId) : Request Party Asset Domain :=
  ⟨realizeId,[],[],ids,some .owner⟩
def execute (basePnlUsd : ℤ) (side : Side) (price : Price) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) :
    Except Typed.Refusal World :=
  Typed.execute (registry basePnlUsd side price) store ctx (fun _=>none) 0 (request ids) pre
def run (before : Funding.State) (basePnlUsd : ℤ) (side : Side) (price : Price)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) :
    Except Typed.Refusal (Funding.State × Receipt) := do
  let after ← if 0 < basePnlUsd then
      execute basePnlUsd side price before.world.capabilities ctx ids before.world.state
    else pure before.world
  return (⟨after,before.position⟩,quote basePnlUsd side price)
def grants (side : Side) : List (Grant Party Asset Domain) :=
  [⟨.owner,.margin,realizeId,.invoke⟩,⟨.owner,.margin,realizeId,.debit (.margin,.pool,side.asset)⟩]
def fixtureStore (side : Side) : Store := ⟨(grants side).map (fun grant=>⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩]
def provisioned (basePnlUsd : ℤ) (side : Side) (price : Price) : Except AuthorityFailure Store :=
  (grants side).foldlM (fun store grant => do
    let (_,next) ← issueCapability (registryAuthorityConfig
      (registry basePnlUsd side price) (fun _=>.admin)) ⟨.admin,.margin⟩ store grant
    return next) .empty


/-- The returned dust is the actual floor remainder, not a rounded fee. -/
theorem quote_reconciliation (basePnlUsd : ℤ) (side : Side) (price : Price) :
    (quote basePnlUsd side price).paidTokens*price.max+
      (quote basePnlUsd side price).floorDustUsd=basePnlUsd.toNat ∧
    (quote basePnlUsd side price).floorDustUsd<price.max := by
  constructor
  · change basePnlUsd.toNat/price.max*price.max+basePnlUsd.toNat%price.max=basePnlUsd.toNat
    rw [Nat.mul_comm]
    exact Nat.div_add_mod _ _
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
    exact effect_outside _ _ _ _ outside.1 outside.2.1

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
