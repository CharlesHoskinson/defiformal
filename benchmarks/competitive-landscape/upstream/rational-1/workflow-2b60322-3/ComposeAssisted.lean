import ComposeModel
import LocalContracts
set_option maxHeartbeats 2000000
namespace RationalWorkflow

theorem algebra_domain_take (r : Vault → ℚ) (b : Cell → ℚ) (caps : Finset Capability)
    (calls : List Call) (domain : AlgebraDomain r b caps calls) (n : Nat) :
    AlgebraDomain r b caps (calls.take n) := by
  induction calls generalizing b caps n with
  | nil => simp [AlgebraDomain]
  | cons call rest ih =>
    cases n with
    | zero => trivial
    | succ n => exact ⟨domain.1,domain.2.1,domain.2.2.1,ih _ _ domain.2.2.2 n⟩

theorem compose_success (s : PublicState) (calls : List Call) (valid : ValidState s)
    (domain : AlgebraDomain s.rates s.ledger.balance s.capabilities calls) :
    ∃ post, CompositionClaims s calls post := by
  induction calls generalizing s with
  | nil =>
    refine ⟨s, ?_⟩
    refine ⟨rfl,LocalTrace.nil s,rfl,?_,rfl,rfl,?_,valid,?_⟩
    · intro e; simp [sumIssued,sumBurned]
    · simp
    · intro c _; rfl
  | cons call rest ih =>
    obtain ⟨middle,executed,contract⟩ := execute_success s call valid
      ⟨domain.1,domain.2.1,domain.2.2.1⟩
    have hb : middle.ledger.balance = algebraStep s.rates s.ledger.balance call :=
      funext contract.balances
    have tail_domain : AlgebraDomain middle.rates middle.ledger.balance middle.capabilities rest := by
      rw [contract.rates,contract.capabilities,hb]
      exact domain.2.2.2
    obtain ⟨post,tail⟩ := ih middle (contract.valid valid) tail_domain
    refine ⟨post, ?_⟩
    refine ⟨?_,LocalTrace.cons s middle post call rest executed contract tail.localContracts,
      ?_,?_,?_,?_,?_,tail.valid,?_⟩
    · change (match execute s call with
        | .refused reason _ => (⟨s,some (reason,0),0⟩ : SequenceResult)
        | .success post => (runCalls post rest).bump) = _
      simp only [executed]
      rw [tail.execution]
      rfl
    · rw [tail.balances,contract.rates,hb]
      rfl
    · intro e
      rw [tail.accounting,contract.accounting,contract.rates]
      simp only [sumIssued,sumBurned,List.map_cons,List.sum_cons]
      ring
    · exact tail.rates.trans contract.rates
    · rw [tail.capabilities,contract.capabilities]
      rfl
    · rw [tail.history,contract.history,contract.rates]
      simp
    · intro c outside
      rw [tail.frame c (by intro x hx; exact outside x (List.mem_cons_of_mem call hx))]
      exact contract.frame c (outside call (List.mem_cons_self))

theorem calls_spec (s : PublicState) (calls : List Call) (valid : ValidState s) :
    CallsExecutionSpec s calls (runCalls s calls) := by
  induction calls generalizing s with
  | nil => exact CallsExecutionSpec.done s
  | cons call rest ih =>
    by_cases amount : AmountValid call
    · by_cases auth : Authorized s.capabilities call
      · by_cases funds : Funded s.ledger.balance s.rates call
        · obtain ⟨post,executed,contract⟩ := execute_success s call valid ⟨amount,auth,funds⟩
          simpa only [runCalls,runWith,executed] using
            CallsExecutionSpec.success s post call rest (runCalls post rest)
              ⟨amount,auth,funds⟩ contract executed (ih post (contract.valid valid))
        · have he := (execute_refusal s call).2.2 amount auth funds
          simpa only [runCalls,runWith,he] using
            CallsExecutionSpec.refused s call rest .insufficientFunds
              (by simp [expectedRefusal,amount,auth,funds]) he
      · have he := (execute_refusal s call).2.1 amount auth
        simpa only [runCalls,runWith,he] using
          CallsExecutionSpec.refused s call rest .unauthorized
            (by simp [expectedRefusal,amount,auth]) he
    · have he := (execute_refusal s call).1 amount
      simpa only [runCalls,runWith,he] using
        CallsExecutionSpec.refused s call rest .badAmount (by simp [expectedRefusal,amount]) he

theorem compose_success_iff (s : PublicState) (calls : List Call) (valid : ValidState s) :
    (runCalls s calls).failure = none ↔ AlgebraDomain s.rates s.ledger.balance s.capabilities calls := by
  constructor
  · intro success
    induction calls generalizing s with
    | nil => trivial
    | cons call rest ih =>
      cases he : execute s call with
      | refused reason post => simp [runCalls,runWith,he] at success
      | success middle =>
        have contract := execute_local he
        have tail_success : (runCalls middle rest).failure = none := by
          simpa [runCalls,runWith,he,SequenceResult.bump] using success
        have tail := ih middle (contract.valid valid) tail_success
        have hb : middle.ledger.balance = algebraStep s.rates s.ledger.balance call := funext contract.balances
        rw [contract.rates,contract.capabilities,hb] at tail
        have domain := execute_success_domain he
        exact ⟨domain.1,domain.2.1,domain.2.2,tail⟩
  · intro domain
    obtain ⟨post,claim⟩ := compose_success s calls valid domain
    rw [claim.execution]

theorem workflow_member (p : Principal) (v : Vault) (n : Nat) (q : ℚ) :
    WorkflowMember v (workflowCall p v n q) := by
  unfold workflowCall
  split <;> simp [WorkflowMember]

theorem workflow_members (p : Principal) (v : Vault) (qs : List ℚ) :
    ∀ call ∈ workflowCalls p v qs, WorkflowMember v call := by
  intro call member
  simp only [workflowCalls,List.mem_mapIdx] at member
  obtain ⟨i,hi,rfl⟩ := member
  exact workflow_member p v i _

theorem workflow_capabilities (v : Vault) (caps : Finset Capability) (call : Call)
    (member : WorkflowMember v call) : nextCapabilities caps call = caps := by
  cases call <;> simp_all [nextCapabilities,WorkflowMember]

theorem workflow_effect (r : Vault → ℚ) (rates : ∀ v, 0 < r v)
    (v : Vault) (call : Call) (member : WorkflowMember v call) :
    effect r call (vaultAccount v,.usd) =
      r v * (issued r call (shareAsset v) - burned r call (shareAsset v)) ∧
    issued r call .cash = 0 ∧ burned r call .cash = 0 ∧
    issued r call (shareAsset (!v)) = 0 ∧ burned r call (shareAsset (!v)) = 0 ∧
    (∀ c, c ∉ workflowFootprint v → c ∉ writes call) := by
  cases call with
  | transfer p source target e q =>
    cases source <;> cases target <;> cases e <;> cases v <;>
      simp_all [WorkflowMember,effect,issued,burned,DefiKernel.Examples.move,
        DefiKernel.Examples.pulse,shareAsset,vaultAccount,Asset.native,writes,workflowFootprint]
  | deposit p u w q =>
    cases u <;> cases w <;> cases v <;>
      simp_all [WorkflowMember,effect,issued,burned,DefiKernel.Examples.move,
        DefiKernel.Examples.pulse,shareAsset,userAccount,vaultAccount,Asset.native,writes,workflowFootprint]
    all_goals field_simp [ne_of_gt rates.1,ne_of_gt rates.2]
  | withdraw p u w q =>
    cases u <;> cases w <;> cases v <;>
      simp_all [WorkflowMember,effect,issued,burned,DefiKernel.Examples.move,
        DefiKernel.Examples.pulse,shareAsset,userAccount,vaultAccount,Asset.native,writes,workflowFootprint]
    all_goals ring
  | grant p c => simp [WorkflowMember] at member
  | revoke p c => simp [WorkflowMember] at member

theorem workflow_trace_preserves (s post : PublicState) (calls : List Call)
    (trace : LocalTrace s calls post) (valid : ValidState s) (v : Vault)
    (members : ∀ call ∈ calls, WorkflowMember v call) :
    post.capabilities = s.capabilities ∧ post.supply .cash = s.supply .cash ∧
    surplus post v = surplus s v ∧ post.supply (shareAsset (!v)) = s.supply (shareAsset (!v)) := by
  induction trace with
  | nil => exact ⟨rfl,rfl,rfl,rfl⟩
  | cons pre middle final call rest executed contract trace ih =>
    have member := members call List.mem_cons_self
    have wf := workflow_effect pre.rates valid.1 v call member
    have tailmembers : ∀ call ∈ rest, WorkflowMember v call := by
      intro c hc; exact members c (List.mem_cons_of_mem _ hc)
    rcases ih (contract.valid valid) tailmembers with ⟨caps,cash,collateral,other⟩
    refine ⟨?_,?_,?_,?_⟩
    · rw [caps,contract.capabilities,workflow_capabilities v _ _ member]
    · rw [cash,contract.accounting,wf.2.1,wf.2.2.1]; ring
    · apply collateral.trans
      cases call with
      | deposit p u w q =>
        cases u with
        | false =>
          have hw : w = v := member
          subst w
          exact deposit_surplus p false v q valid contract
        | true => simp [WorkflowMember] at member
      | withdraw p u w q =>
        cases u with
        | true =>
          have hw : w = v := member
          subst w
          exact withdraw_surplus p true v q contract
        | false => simp [WorkflowMember] at member
      | transfer p source target e q => exact local_surplus contract v wf.1
      | grant p c => simp [WorkflowMember] at member
      | revoke p c => simp [WorkflowMember] at member
    · rw [other,contract.accounting,wf.2.2.2.1,wf.2.2.2.2.1]; ring

theorem workflow_issued (r : Vault → ℚ) (p : Principal) (v : Vault) (n : Nat) (q : ℚ) :
    issued r (workflowCall p v n q) (shareAsset v) = (if n % 4 = 0 then q / r v else 0) := by
  unfold workflowCall
  split <;> simp_all [issued]

theorem workflow_burned (r : Vault → ℚ) (p : Principal) (v : Vault) (n : Nat) (q : ℚ) :
    burned r (workflowCall p v n q) (shareAsset v) = (if n % 4 = 2 then q else 0) := by
  unfold workflowCall
  split <;> simp_all [burned]

theorem workflow_sums (r : Vault → ℚ) (p : Principal) (v : Vault) (qs : List ℚ) :
    sumIssued r (workflowCalls p v qs) (shareAsset v) = depositTotal (r v) qs ∧
    sumBurned r (workflowCalls p v qs) (shareAsset v) = withdrawTotal qs := by
  simp [sumIssued,sumBurned,workflowCalls,List.mapIdx_eq_zipIdx_map,List.map_map,
    Function.comp_def,workflow_issued,workflow_burned,depositTotal,withdrawTotal]

theorem workflow_success (s : PublicState) (p : Principal) (v : Vault) (amounts : List ℚ)
    (valid : ValidState s)
    (domain : AlgebraDomain s.rates s.ledger.balance s.capabilities (workflowCalls p v amounts)) :
    ∃ post, WorkflowClaims s p v amounts post := by
  obtain ⟨post,composition⟩ := compose_success s _ valid domain
  have members := workflow_members p v amounts
  rcases workflow_trace_preserves s post _ composition.localContracts valid v members with
    ⟨caps,cash,collateral,other⟩
  refine ⟨post,composition,caps,cash,?_,collateral,?_,?_,other,?_⟩
  · rw [composition.accounting,(workflow_sums s.rates p v amounts).1,
      (workflow_sums s.rates p v amounts).2]
  · intro h; rwa [collateral]
  · intro c outside
    apply composition.frame c
    intro call member
    exact (workflow_effect s.rates valid.1 v call (members call member)).2.2.2.2.2 c outside
  · intro j hj
    obtain ⟨preState,claims⟩ := compose_success s _ valid (algebra_domain_take _ _ _ _ domain j)
    exact ⟨preState,claims,preState.ledger.nonneg⟩

theorem generic_compose (v : Vault) (n : Nat) : ComposeCanonical v n := by
  intro s p amounts valid length
  exact ⟨workflow_success s p v amounts valid,
    calls_spec s _ valid,compose_success_iff s _ valid⟩

#print axioms generic_compose
#print axioms compose_success
end RationalWorkflow
