import NetModel
import LocalContracts

set_option maxHeartbeats 400000

namespace RationalWorkflow.Net

theorem instruction_accounted (t : Instruction) (a : DefiKernel.Asset) :
    ∑ owner, t.delta (owner, a) = 0 := by
  rcases t with ⟨p, s, t, e, q⟩
  cases e <;> cases a <;>
    simp [Instruction.delta, Asset.native, DefiKernel.Examples.move,
      DefiKernel.Examples.pulse, Finset.sum_sub_distrib]

theorem aggregate_accounted (ts : List Instruction) :
    ∀ a : DefiKernel.Asset, ∑ owner, aggregate ts (owner, a) = 0 := by
  induction ts with
  | nil => simp [aggregate]
  | cons t ts ih =>
    intro a
    simp only [aggregate, Finset.sum_add_distrib, instruction_accounted, ih, add_zero]

theorem instruction_debt (t : Instruction) (a : Account) : t.delta (a, .debt) = 0 := by
  rcases t with ⟨p, s, t, e, q⟩
  cases e <;> simp [Instruction.delta, DefiKernel.Examples.move,
    DefiKernel.Examples.pulse, Asset.native]

theorem aggregate_debt (ts : List Instruction) (a : Account) : aggregate ts (a, .debt) = 0 := by
  induction ts with
  | nil => rfl
  | cons t ts ih => simp [aggregate, instruction_debt, ih]

theorem net_native_valid (s : PublicState) (actor : Principal) (ts : List Instruction)
    (authorized : NetAuthorized s actor ts) (funded : NetFunded s ts) :
    DefiKernel.Valid (policy s.capabilities) () (netTransition actor ts) s.ledger := by
  refine ⟨rfl, authorized.2, ?_, funded, aggregate_accounted ts, ?_⟩
  · intro a changed
    exact False.elim (changed rfl)
  · intro c outside
    exact False.elim (outside (Finset.mem_univ c))

theorem net_publish_claims (s : PublicState) (actor : Principal) (ts : List Instruction)
    (ledger : DefiKernel.State)
    (executed : DefiKernel.execute (policy s.capabilities) () (netTransition actor ts) s.ledger = .ok ledger) :
    NetClaims s (netPublish s ledger ts) actor ts := by
  have balances : ∀ c, ledger.balance c = s.ledger.balance c + aggregate ts c := by
    obtain ⟨valid, rfl⟩ := (DefiKernel.execute_ok_iff _ _ _ _ _).mp executed
    intro c
    rfl
  have supply : ∀ e, (netPublish s ledger ts).supply e = s.supply e := by
    intro e
    simpa [PublicState.supply, netPublish, netTransition] using
      DefiKernel.execute_accounting (policy s.capabilities) () (netTransition actor ts)
        s.ledger ledger executed e.native
  refine ⟨executed, balances, ledger.nonneg, supply, rfl, rfl, rfl, ?_, ?_, ?_⟩
  · intro c zero
    simpa [netPublish, zero] using balances c
  · intro e
    simpa [netEvent] using supply e
  · intro valid
    refine ⟨valid.1, ?_⟩
    intro a
    change ledger.balance (a, .debt) = 0
    rw [balances, aggregate_debt, add_zero]
    exact valid.2 a

theorem settlement_canonical : SettlementCanonical := by
  intro s actor ts
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨authorized, funded⟩
    have valid := net_native_valid s actor ts authorized funded
    let ledger := DefiKernel.applyEffect s.ledger (netTransition actor ts) valid.2.2.2.1
    have executed : DefiKernel.execute (policy s.capabilities) () (netTransition actor ts) s.ledger = .ok ledger :=
      (DefiKernel.execute_ok_iff _ _ _ _ _).mpr ⟨valid, rfl⟩
    exact ⟨netPublish s ledger ts, by simp [settle, authorized, funded, executed],
      net_publish_claims s actor ts ledger executed⟩
  · intro unauthorized
    simp [settle, unauthorized]
  · intro authorized unfunded
    simp [settle, authorized, unfunded]

theorem settle_success_iff (s : PublicState) (actor : Principal) (ts : List Instruction) :
    (∃ post, settle s actor ts = .success post) ↔ NetAuthorized s actor ts ∧ NetFunded s ts := by
  constructor
  · rintro ⟨post, success⟩
    by_cases authorized : NetAuthorized s actor ts
    · by_cases funded : NetFunded s ts
      · exact ⟨authorized, funded⟩
      · simp [settle, authorized, funded] at success
    · simp [settle, authorized] at success
  · intro domain
    obtain ⟨post, success, claims⟩ := (settlement_canonical s actor ts).1 domain
    exact ⟨post, success⟩

theorem net_authority_exact (s : PublicState) (actor : Principal) (ts : List Instruction) :
    NetAuthorized s actor ts ↔ .invoke actor .transfer ∈ s.capabilities ∧
      ∀ a e, aggregate ts (a, e.native) < 0 → .debit actor a e ∈ s.capabilities := by
  constructor
  · rintro ⟨invoke, debits⟩
    refine ⟨invoke, ?_⟩
    intro a e negative
    have h := debits (a, e.native) negative
    simpa [policy, netTransition, native_asset_roundtrip] using h
  · rintro ⟨invoke, debits⟩
    refine ⟨invoke, ?_⟩
    rintro ⟨a, e⟩ negative
    cases e with
    | usd => simpa [policy, nativeAsset, netTransition] using debits a .cash negative
    | share => simpa [policy, nativeAsset, netTransition] using debits a .shareA negative
    | collateral => simpa [policy, nativeAsset, netTransition] using debits a .shareB negative
    | debt => simpa [netTransition, aggregate_debt] using negative

theorem validateOne_valid (actor : Principal) (raw : RawCall) (t : Instruction)
    (h : validateOne actor raw = .ok t) : t.actor = actor ∧ 0 ≤ t.amount := by
  cases raw <;> simp only [validateOne] at h <;> try contradiction
  case transfer p s target e q =>
    cases hp : decodePrincipal p <;> cases hs : decodeAccount s <;>
      cases ht : decodeAccount target <;> cases he : decodeAsset e <;>
      simp only [hp, hs, ht, he] at h <;> try contradiction
    next p' s' t' e' =>
      by_cases same : p' = actor
      · simp only [same, ne_eq, not_true_eq_false, if_false] at h
        cases q with
        | malformed bad => contradiction
        | exact amount =>
          by_cases negative : amount < 0
          · simp [negative] at h
          · simp only [if_neg negative, Except.ok.injEq] at h
            subst t
            exact ⟨rfl, le_of_not_gt negative⟩
      · simp [same] at h

theorem validate_valid (actor : Principal) (raws : List RawCall) (ts : List Instruction)
    (h : validate actor raws = .ok ts) : RecordValid actor ts ∧ ts.length = raws.length := by
  induction raws generalizing ts with
  | nil =>
    simp only [validate, Except.ok.injEq] at h
    subst ts
    simp [RecordValid]
  | cons raw raws ih =>
    simp only [validate] at h
    split at h <;> try contradiction
    next t one =>
      split at h <;> try contradiction
      next rest accepted =>
        cases h
        obtain ⟨valid, length⟩ := ih rest accepted
        refine ⟨?_, by simp [length]⟩
        intro u member
        rcases List.mem_cons.mp member with rfl | member
        · exact validateOne_valid actor raw u one
        · exact valid u member

theorem validate_first (actor : Principal) (before : List RawCall) (checked : List Instruction)
    (raw : RawCall) (suffix : List RawCall) (reason : Reason)
    (valid : validate actor before = .ok checked) (bad : validateOne actor raw = .error reason) :
    validate actor (before ++ raw :: suffix) = .error (reason, before.length) := by
  induction before generalizing checked with
  | nil => simp [validate, bad]
  | cons first before ih =>
    simp only [validate] at valid
    split at valid <;> try contradiction
    next t one =>
      split at valid <;> try contradiction
      next rest accepted =>
        have tail := ih rest accepted
        simp only [List.cons_append, validate, one, tail, List.length_cons]

theorem validation_canonical : ValidationCanonical := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro s requestActor raws invalid
    simp [executeNet, invalid]
  · intro actor tag
    rfl
  · intro actor p s t e q bad
    rcases bad with bad | bad | bad | bad <;> simp [validateOne, bad]
  · intro actor p s t e p' s' t' e' q hp hs ht he different
    simp [validateOne, hp, hs, ht, he, different]
  · intro actor p s t e s' t' e' bad hp hs ht he
    simp [validateOne, hp, hs, ht, he]
  · intro actor p s t e s' t' e' q hp hs ht he negative
    simp [validateOne, hp, hs, ht, he, negative]
  · intro actor p s t e s' t' e' q hp hs ht he nonnegative
    simp [validateOne, hp, hs, ht, he, not_lt.mpr nonnegative]
  · intro s requestActor actor before checked raw suffix reason hp valid bad
    simp [executeNet, hp, validate_first actor before checked raw suffix reason valid bad]
  · intro s requestActor actor raws ts hp valid
    obtain ⟨records, length⟩ := validate_valid actor raws ts valid
    exact ⟨records, length, by simp [executeNet, hp, valid]⟩

theorem prefixBalances_eq (b : Cell → ℚ) (ts : List Instruction) (c : Cell) :
    prefixBalances b ts c = b c + aggregate ts c := by
  induction ts generalizing b with
  | nil => simp [prefixBalances, aggregate]
  | cons t ts ih => simp [prefixBalances, aggregate, ih, add_assoc]

theorem prefix_domain_split (b : Cell → ℚ) (caps : Finset Capability) (ts : List Instruction) :
    PrefixDomain b caps ts ↔
      (∀ t ∈ ts, 0 ≤ t.amount ∧ Authorized caps t.call) ∧ PrefixFunds b ts := by
  induction ts generalizing b with
  | nil => simp [PrefixDomain, PrefixFunds]
  | cons t ts ih =>
    simp only [PrefixDomain, PrefixFunds, ih, List.forall_mem_cons]
    tauto

theorem prefix_domain_explicit (b : Cell → ℚ) (caps : Finset Capability)
    (actor : Principal) (ts : List Instruction) (nonempty : ts ≠ []) (valid : RecordValid actor ts) :
    PrefixDomain b caps ts ↔ GrossAuthority caps actor ts ∧ PrefixFunds b ts := by
  rw [prefix_domain_split]
  constructor
  · rintro ⟨steps, funds⟩
    refine ⟨⟨?_, ?_⟩, funds⟩
    · cases ts with
      | nil => contradiction
      | cons t ts =>
        have ht := steps t (by simp)
        have actor_eq := (valid t (by simp)).1
        simpa [Authorized, Instruction.call, actor_eq] using ht.2.1
    · intro t member
      have ht := steps t member
      have actor_eq := (valid t member).1
      simpa [Authorized, Instruction.call, actor_eq] using ht.2.2
  · rintro ⟨⟨invoke, debits⟩, funds⟩
    refine ⟨?_, funds⟩
    intro t member
    have record := valid t member
    refine ⟨record.2, ?_⟩
    simpa [Authorized, Instruction.call, record.1] using And.intro invoke (debits t member)

theorem sequence_exact (ts : List Instruction) (s : PublicState) (valid : ValidState s)
    (domain : PrefixDomain s.ledger.balance s.capabilities ts) :
    (runCalls s (ts.map Instruction.call)).failure = none ∧
    (runCalls s (ts.map Instruction.call)).committed = ts.length ∧
    SequenceClaims s (runCalls s (ts.map Instruction.call)).state ts := by
  induction ts generalizing s with
  | nil =>
    refine ⟨rfl, rfl, ?_⟩
    exact ⟨by intro c; simp [runCalls, runWith, aggregate], by intro e; rfl,
      rfl, rfl, by simp [runCalls, runWith], valid⟩
  | cons t ts ih =>
    obtain ⟨nonnegative, authorized, funded, rest⟩ := domain
    have localDomain : SuccessDomain s t.call := ⟨nonnegative, authorized, funded⟩
    obtain ⟨post, stepped, contract⟩ := execute_success s t.call valid localDomain
    have balances : post.ledger.balance = fun c => s.ledger.balance c + t.delta c :=
      funext contract.balances
    have caps : post.capabilities = s.capabilities := by
      simpa [Instruction.call, nextCapabilities] using contract.capabilities
    have restDomain : PrefixDomain post.ledger.balance post.capabilities ts := by
      rw [balances, caps]
      exact rest
    obtain ⟨finished, count, tail⟩ := ih post (contract.valid valid) restDomain
    have run : runCalls s ((t :: ts).map Instruction.call) =
        (runCalls post (ts.map Instruction.call)).bump := by
      simp only [List.map_cons, runCalls, runWith, stepped]
    refine ⟨?_, ?_, ?_⟩
    · rw [run]
      simp [SequenceResult.bump, finished]
    · rw [run]
      simp [SequenceResult.bump, count]
    rw [run]
    change SequenceClaims s (runCalls post (ts.map Instruction.call)).state (t :: ts)
    refine ⟨?_, ?_, tail.rates.trans contract.rates, tail.capabilities.trans caps, ?_, tail.valid⟩
    · intro c
      rw [tail.balances, contract.balances]
      simp only [aggregate, Instruction.call, effect, Instruction.delta]
      exact add_assoc _ _ _
    · intro e
      rw [tail.supply, contract.accounting]
      simp [Instruction.call, issued, burned]
    · rw [tail.history, contract.history, contract.rates]
      simp [List.map_cons, List.append_assoc]

theorem sequence_success_iff (ts : List Instruction) (s : PublicState) (valid : ValidState s) :
    (runCalls s (ts.map Instruction.call)).failure = none ↔
      PrefixDomain s.ledger.balance s.capabilities ts := by
  constructor
  · intro successful
    induction ts generalizing s with
    | nil => trivial
    | cons t ts ih =>
      cases stepped : execute s t.call with
      | refused reason post =>
        simp only [List.map_cons, runCalls, runWith, stepped] at successful
        contradiction
      | success post =>
        have contract := execute_local stepped
        have localDomain := execute_success_domain stepped
        have balances : post.ledger.balance = fun c => s.ledger.balance c + t.delta c :=
          funext contract.balances
        have caps : post.capabilities = s.capabilities := by
          simpa [Instruction.call, nextCapabilities] using contract.capabilities
        have restSuccess : (runCalls post (ts.map Instruction.call)).failure = none := by
          simpa only [List.map_cons, runCalls, runWith, stepped, SequenceResult.bump,
            Option.map_eq_none_iff] using successful
        have tail := ih post (contract.valid valid) restSuccess
        rw [balances, caps] at tail
        exact ⟨localDomain.1, localDomain.2.1, localDomain.2.2, tail⟩
  · intro domain
    exact (sequence_exact ts s valid domain).1

theorem negative_instruction_source (t : Instruction) (c : Cell)
    (nonnegative : 0 ≤ t.amount) (negative : t.delta c < 0) :
    c = (t.source, t.asset.native) := by
  by_contra different
  simp only [Instruction.delta, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
    different, if_false, sub_zero] at negative
  split_ifs at negative <;> linarith

theorem gross_authority_implies_net (s : PublicState) (actor : Principal) (ts : List Instruction)
    (valid : RecordValid actor ts) (gross : GrossAuthority s.capabilities actor ts) :
    NetAuthorized s actor ts := by
  refine ⟨gross.1, ?_⟩
  intro c negative
  change aggregate ts c < 0 at negative
  change (policy s.capabilities).debit actor c = true
  have debits := gross.2
  induction ts with
  | nil => simp [aggregate] at negative
  | cons t ts ih =>
    have first := valid t (by simp)
    by_cases firstNegative : t.delta c < 0
    · rw [negative_instruction_source t c first.2 firstNegative]
      simp [policy, native_asset_roundtrip, debits t (by simp)]
    · have restNegative : aggregate ts c < 0 := by
        simp only [aggregate] at negative
        linarith
      have tailValid : RecordValid actor ts := fun u member => valid u (by simp [member])
      have tailDebits : ∀ u ∈ ts, .debit actor u.source u.asset ∈ s.capabilities :=
        fun u member => debits u (by simp [member])
      exact ih tailValid ⟨gross.1, tailDebits⟩ restNegative tailDebits

theorem sequential_canonical : SequentialCanonical := by
  intro s actor ts valid length records
  have nonempty : ts ≠ [] := by intro empty; simp [empty] at length
  have domain := prefix_domain_explicit s.ledger.balance s.capabilities actor ts nonempty records
  refine ⟨(sequence_success_iff ts s valid).trans domain, ?_⟩
  intro explicit
  obtain ⟨finished, count, sequential⟩ := sequence_exact ts s valid (domain.mpr explicit)
  have authority := gross_authority_implies_net s actor ts records explicit.1
  have funds : NetFunded s ts := by
    intro c
    rw [← sequential.balances]
    exact (runCalls s (ts.map Instruction.call)).state.ledger.nonneg c
  obtain ⟨post, success, net⟩ := (settlement_canonical s actor ts).1 ⟨authority, funds⟩
  refine ⟨count.trans length, sequential, post, success, net, ?_, ?_, ?_, ?_⟩
  · intro c
    rw [net.balances, sequential.balances]
  · intro e
    rw [net.supply, sequential.supply]
  · exact net.rates.trans sequential.rates.symm
  · exact net.capabilities.trans sequential.capabilities.symm

theorem validateOne_matches (actor : Principal) (raw : RawCall) (t : Instruction) :
    validateOne actor raw = .ok t ↔ RawMatches actor raw t := by
  constructor
  · intro h
    cases raw <;> simp only [validateOne] at h <;> try contradiction
    case transfer p s target e q =>
      cases hp : decodePrincipal p <;> cases hs : decodeAccount s <;>
        cases ht : decodeAccount target <;> cases he : decodeAsset e <;>
        simp only [hp, hs, ht, he] at h <;> try contradiction
      next p' s' t' e' =>
        by_cases same : p' = actor
        · subst p'
          simp only [ne_eq, not_true_eq_false, if_false] at h
          cases q with
          | malformed bad => contradiction
          | exact amount =>
            by_cases negative : amount < 0
            · simp [negative] at h
            · simp only [if_neg negative, Except.ok.injEq] at h
              subst t
              exact .exact p s target e s' t' e' amount hp hs ht he (le_of_not_gt negative)
        · simp [same] at h
  · intro h
    cases h with
    | exact p source target asset s t e q hp hs ht he hq =>
      simp [validateOne, hp, hs, ht, he, not_lt.mpr hq]

theorem validate_matches (actor : Principal) (raws : List RawCall) (ts : List Instruction) :
    validate actor raws = .ok ts ↔ List.Forall₂ (RawMatches actor) raws ts := by
  constructor
  · intro h
    induction raws generalizing ts with
    | nil =>
      simp only [validate, Except.ok.injEq] at h
      subst ts
      exact .nil
    | cons raw raws ih =>
      simp only [validate] at h
      split at h <;> try contradiction
      next t one =>
        split at h <;> try contradiction
        next rest accepted =>
          cases h
          exact .cons ((validateOne_matches actor raw t).mp one) (ih rest accepted)
  · intro h
    induction h with
    | nil => rfl
    | @cons raw t raws ts one rest ih =>
      simp [validate, (validateOne_matches actor raw t).mpr one, ih]

theorem raw_total_canonical : RawTotalCanonical := by
  constructor
  · intro s requestActor raws
    constructor
    · rintro ⟨post, success⟩
      unfold executeNet at success
      split at success <;> try contradiction
      next actor principal =>
        split at success <;> try contradiction
        next ts accepted =>
          obtain ⟨authority, funds⟩ := (settle_success_iff s actor ts).mp ⟨post, success⟩
          exact ⟨actor, ts, principal, (validate_matches actor raws ts).mp accepted, authority, funds⟩
    · rintro ⟨actor, ts, principal, records, authority, funds⟩
      have accepted := (validate_matches actor raws ts).mpr records
      obtain ⟨post, success⟩ := (settle_success_iff s actor ts).mpr ⟨authority, funds⟩
      exact ⟨post, by simpa [executeNet, principal, accepted] using success⟩
  · intro actor raw unsupported
    cases raw <;> try rfl
    next p s t e q => exact False.elim (unsupported p s t e q rfl)

theorem aggregate_canonical : AggregateCanonical := by
  intro ts c
  induction ts with
  | nil => simp [aggregate]
  | cons t ts ih =>
    simp only [aggregate, List.map_cons, List.sum_cons, ih]
    congr 1
    simp only [Instruction.delta, DefiKernel.Examples.move, DefiKernel.Examples.pulse]
    split_ifs <;> simp

theorem canonical : Canonical :=
  ⟨settlement_canonical, validation_canonical, raw_total_canonical, sequential_canonical,
    aggregate_canonical, net_authority_exact⟩

#print axioms canonical
#print axioms net_authority_exact

end RationalWorkflow.Net
