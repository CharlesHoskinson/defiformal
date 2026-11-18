import WorkflowModel
set_option maxHeartbeats 2000000
namespace RationalWorkflow

theorem native_asset_roundtrip (e : Asset) : nativeAsset e.native = some e := by
  cases e <;> rfl

theorem effect_accounted (r : Vault → ℚ) (call : Call) :
    DefiKernel.Accounted (transition r call) := by
  intro a
  cases call with
  | transfer p s t e q => cases e <;> cases a <;>
      simp [transition, effect, issued, burned, nativeAsset, Asset.native,
        DefiKernel.Examples.move, DefiKernel.Examples.pulse, Finset.sum_sub_distrib]
  | deposit p u v q => cases v <;> cases a <;>
      simp [transition, effect, issued, burned, nativeAsset, Asset.native, shareAsset,
        DefiKernel.Examples.move, DefiKernel.Examples.pulse,
        Finset.sum_sub_distrib, Finset.sum_add_distrib]
  | withdraw p u v q => cases v <;> cases a <;>
      simp [transition, effect, issued, burned, nativeAsset, Asset.native, shareAsset,
        DefiKernel.Examples.move, DefiKernel.Examples.pulse, Finset.sum_sub_distrib]
  | grant p c => simp [transition, effect, issued, burned]; cases a <;> rfl
  | revoke p c => simp [transition, effect, issued, burned]; cases a <;> rfl

theorem effect_local (r : Vault → ℚ) (call : Call) :
    DefiKernel.Local (transition r call) := by
  intro c hc
  cases call <;>
    simp only [transition, writes, Finset.mem_insert, Finset.mem_singleton, not_or] at hc
  all_goals simp_all [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse]

theorem native_valid (s : PublicState) (call : Call) (valid : ValidState s)
    (domain : SuccessDomain s call) :
    DefiKernel.Valid (policy s.capabilities) () (transition s.rates call) s.ledger := by
  rcases domain with ⟨amount, auth, funds⟩
  refine ⟨rfl, ?_, ?_, ?_, effect_accounted _ _, effect_local _ _⟩
  · intro c neg
    cases call with
    | transfer p source target e q =>
      have positive : 0 ≤ q := amount
      have source_cell : c = (source, e.native) := by
        by_contra different
        simp only [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
          different, if_false, sub_zero] at neg
        split_ifs at neg <;> linarith
      subst c
      simpa [policy, transition, Call.actor, native_asset_roundtrip] using auth.2
    | deposit p u v q =>
      have hq : 0 ≤ q := amount
      have hdiv : 0 ≤ q / s.rates v := div_nonneg hq (le_of_lt (valid.1 v))
      rcases c with ⟨a,e⟩
      cases u <;> cases v <;> cases a <;> cases e <;>
        simp_all [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
          userAccount, vaultAccount, shareAsset, Asset.native, policy, nativeAsset,
          Call.actor, Authorized]
      all_goals linarith
    | withdraw p u v q =>
      have hq : 0 ≤ q := amount
      have hmul : 0 ≤ q * s.rates v := mul_nonneg hq (le_of_lt (valid.1 v))
      rcases c with ⟨a,e⟩
      cases u <;> cases v <;> cases a <;> cases e <;>
        simp_all [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
          userAccount, vaultAccount, shareAsset, Asset.native, policy, nativeAsset,
          Call.actor, Authorized]
      all_goals linarith
    | grant p cap => simp [transition, effect] at neg
    | revoke p cap => simp [transition, effect] at neg
  · intro a changed
    cases call with
    | transfer p source target e q => simp [transition, issued, burned] at changed; cases a <;> contradiction
    | deposit p u v q =>
      cases v <;> cases a <;>
        simp_all [transition, issued, burned, shareAsset, Asset.native, nativeAsset,
          policy, Call.actor, Authorized]
    | withdraw p u v q =>
      cases v <;> cases a <;>
        simp_all [transition, issued, burned, shareAsset, Asset.native, nativeAsset,
          policy, Call.actor, Authorized]
    | grant p c => cases a <;> simp [transition, issued, burned, nativeAsset] at changed
    | revoke p c => cases a <;> simp [transition, issued, burned, nativeAsset] at changed
  · intro c
    have initial := s.ledger.nonneg c
    cases call with
    | transfer p source target e q =>
      have hq : 0 ≤ q := amount
      change q ≤ s.ledger.balance (source, e.native) at funds
      simp only [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse]
      by_cases hs : c = (source, e.native)
      · rw [← hs] at funds
        simp only [if_pos hs]
        split_ifs <;> linarith
      · simp only [if_neg hs]
        split_ifs <;> linarith
    | deposit p u v q =>
      have hq : 0 ≤ q := amount
      have hdiv : 0 ≤ q / s.rates v := div_nonneg hq (le_of_lt (valid.1 v))
      rcases c with ⟨a,e⟩
      cases u <;> cases v <;> cases a <;> cases e <;>
        simp_all [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
          userAccount, vaultAccount, shareAsset, Asset.native, Funded]
      all_goals linarith
    | withdraw p u v q =>
      have hq : 0 ≤ q := amount
      have hmul : 0 ≤ q * s.rates v := mul_nonneg hq (le_of_lt (valid.1 v))
      rcases c with ⟨a,e⟩
      cases u <;> cases v <;> cases a <;> cases e <;>
        simp_all [transition, effect, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
          userAccount, vaultAccount, shareAsset, Asset.native, Funded]
      all_goals linarith
    | grant p cap => simpa [transition, effect] using initial
    | revoke p cap => simpa [transition, effect] using initial

theorem publish_claims (s : PublicState) (call : Call) (ledger : DefiKernel.State)
    (executed : DefiKernel.execute (policy s.capabilities) () (transition s.rates call) s.ledger = .ok ledger) :
    LocalClaims s (publish s ledger call) call := by
  have balance : ∀ c, ledger.balance c = s.ledger.balance c + effect s.rates call c := by
    obtain ⟨valid, rfl⟩ := (DefiKernel.execute_ok_iff _ _ _ _ _).mp executed
    intro c
    rfl
  have framed : ∀ c, c ∉ writes call → ledger.balance c = s.ledger.balance c := by
    intro c hc
    exact DefiKernel.execute_locality _ _ _ _ _ executed c hc
  refine ⟨executed, balance, ledger.nonneg, ?_, rfl, rfl, rfl, framed, ?_, ?_⟩
  · intro e
    have h := DefiKernel.execute_accounting _ _ _ _ _ executed e.native
    simpa [publish, PublicState.supply, transition, native_asset_roundtrip, add_sub_assoc] using h
  · intro valid
    refine ⟨valid.1, ?_⟩
    intro a
    change ledger.balance (a, .debt) = 0
    rw [framed (a,.debt) ?_]
    · exact valid.2 a
    · cases call with
      | transfer p source target e q => cases e <;> simp [writes, Asset.native]
      | deposit p u v q => cases v <;> simp [writes, shareAsset, Asset.native]
      | withdraw p u v q => cases v <;> simp [writes, shareAsset, Asset.native]
      | grant p c => simp [writes]
      | revoke p c => simp [writes]
  · intro amount rates e
    cases call with
    | deposit p u v q =>
      have hq : 0 ≤ q := amount
      simp only [issued, burned]
      split_ifs <;> simp_all [div_nonneg hq (le_of_lt (rates v))]
    | withdraw p u v q =>
      have hq : 0 ≤ q := amount
      simp only [issued, burned]
      split_ifs <;> simp_all
    | transfer p source target e q => simp [issued, burned]
    | grant p c => simp [issued, burned]
    | revoke p c => simp [issued, burned]

theorem execute_success (s : PublicState) (call : Call) (valid : ValidState s)
    (domain : SuccessDomain s call) :
    ∃ post, execute s call = .success post ∧ LocalClaims s post call := by
  have hv := native_valid s call valid domain
  let ledger := DefiKernel.applyEffect s.ledger (transition s.rates call) hv.2.2.2.1
  have he : DefiKernel.execute (policy s.capabilities) () (transition s.rates call) s.ledger = .ok ledger :=
    (DefiKernel.execute_ok_iff _ _ _ _ _).mpr ⟨hv, rfl⟩
  exact ⟨publish s ledger call, by simp [execute, domain.1, domain.2.1, domain.2.2, he],
    publish_claims s call ledger he⟩

theorem execute_success_domain {s post : PublicState} {call : Call}
    (h : execute s call = .success post) : SuccessDomain s call := by
  unfold execute at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  exact ⟨by tauto, by tauto, by tauto⟩

theorem execute_success_iff (s : PublicState) (call : Call) (valid : ValidState s) :
    (∃ post, execute s call = .success post) ↔ SuccessDomain s call := by
  constructor
  · rintro ⟨post,h⟩; exact execute_success_domain h
  · intro h; obtain ⟨post,he,_⟩ := execute_success s call valid h; exact ⟨post,he⟩

theorem execute_refused_unchanged {s post : PublicState} {call : Call} {reason : Reason}
    (h : execute s call = .refused reason post) : post = s := by
  unfold execute at h
  split at h <;> try {cases h; rfl}
  split at h <;> try {cases h; rfl}
  split at h <;> try {cases h; rfl}
  split at h <;> cases h <;> rfl

theorem execute_refusal (s : PublicState) (call : Call) :
    (¬ AmountValid call → execute s call = .refused .badAmount s) ∧
    (AmountValid call → ¬ Authorized s.capabilities call → execute s call = .refused .unauthorized s) ∧
    (AmountValid call → Authorized s.capabilities call → ¬ Funded s.ledger.balance s.rates call →
      execute s call = .refused .insufficientFunds s) := by
  constructor
  · intro h; simp [execute,h]
  constructor
  · intro h ha; simp [execute,h,ha]
  · intro h ha hf; simp [execute,h,ha,hf]

theorem execute_local {s post : PublicState} {call : Call}
    (h : execute s call = .success post) : LocalClaims s post call := by
  unfold execute at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  next ledger he =>
    cases h
    exact publish_claims s call ledger he

theorem withNumber_refused_unchanged {s post : PublicState} {make : ℚ → Call}
    {number : Number} {reason : Reason}
    (h : withNumber s make number = .refused reason post) : post = s := by
  cases number with
  | exact q => exact execute_refused_unchanged h
  | malformed bad => cases h; rfl

theorem rawExecute_refused_unchanged {s post : PublicState} {call : RawCall} {reason : Reason}
    (h : rawExecute s call = .refused reason post) : post = s := by
  cases call <;> simp only [rawExecute] at h
  all_goals first
    | (cases h; rfl)
    | (split at h
       · first | exact withNumber_refused_unchanged h | exact execute_refused_unchanged h
       · cases h; rfl)

theorem local_surplus {pre post : PublicState} {call : Call}
    (contract : LocalClaims pre post call) (v : Vault)
    (cancel : effect pre.rates call (vaultAccount v,.usd) =
      pre.rates v * (issued pre.rates call (shareAsset v) - burned pre.rates call (shareAsset v))) :
    surplus post v = surplus pre v := by
  unfold surplus
  rw [contract.balances, contract.rates, contract.accounting, cancel]
  ring

theorem deposit_surplus {pre post : PublicState} (p : Principal) (u : User) (v : Vault) (q : ℚ)
    (valid : ValidState pre) (contract : LocalClaims pre post (.deposit p u v q)) :
    surplus post v = surplus pre v := by
  apply local_surplus contract v
  have rate : pre.rates v ≠ 0 := ne_of_gt (valid.1 v)
  cases u <;> cases v <;>
    simp [effect,issued,burned,DefiKernel.Examples.move,DefiKernel.Examples.pulse,
      userAccount,vaultAccount,shareAsset,Asset.native]
  all_goals field_simp [rate]

theorem withdraw_surplus {pre post : PublicState} (p : Principal) (u : User) (v : Vault) (q : ℚ)
    (contract : LocalClaims pre post (.withdraw p u v q)) : surplus post v = surplus pre v := by
  apply local_surplus contract v
  cases u <;> cases v <;>
    simp [effect,issued,burned,DefiKernel.Examples.move,DefiKernel.Examples.pulse,
      userAccount,vaultAccount,shareAsset,Asset.native]
  all_goals ring

#print axioms execute_success
#print axioms publish_claims
end RationalWorkflow
