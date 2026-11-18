import Model

set_option maxHeartbeats 400000

namespace RationalTransfer

theorem native_asset_roundtrip (asset : Asset) : nativeAsset asset.native = some asset := by
  cases asset <;> rfl

theorem transition_accounted (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) :
    DefiKernel.Accounted (transition actor source target asset amount) := by
  intro a
  cases asset <;> cases a <;>
    simp [transition, Asset.native, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
      Finset.sum_sub_distrib]

theorem transition_local (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) :
    DefiKernel.Local (transition actor source target asset amount) := by
  intro cell outside
  simp only [transition, Finset.mem_insert, Finset.mem_singleton, not_or] at outside
  simp [transition, DefiKernel.Examples.move, DefiKernel.Examples.pulse, outside.1, outside.2]

theorem native_valid (state : PublicState) (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) (domain : SuccessDomain state actor source asset amount) :
    DefiKernel.Valid (policy state) () (transition actor source target asset amount) state.ledger := by
  rcases domain with ⟨amount_nonnegative, authorized, funded⟩
  refine ⟨rfl, ?_, ?_, ?_, transition_accounted actor source target asset amount,
    transition_local actor source target asset amount⟩
  · intro cell negative
    have source_cell : cell = (source, asset.native) := by
      by_contra different
      simp only [transition, DefiKernel.Examples.move, DefiKernel.Examples.pulse,
        different, if_false, sub_zero] at negative
      split_ifs at negative <;> linarith
    subst cell
    simp [policy, transition, native_asset_roundtrip, authorized.2]
  · intro a changed
    exact False.elim (changed rfl)
  · intro cell
    have initial := state.ledger.nonneg cell
    simp only [transition, DefiKernel.Examples.move, DefiKernel.Examples.pulse]
    by_cases from_source : cell = (source, asset.native)
    · rw [← from_source] at funded
      simp only [if_pos from_source]
      split_ifs <;> linarith
    · simp only [if_neg from_source]
      split_ifs <;> linarith

theorem native_success (state : PublicState) (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) (domain : SuccessDomain state actor source asset amount) :
    ∃ ledger, DefiKernel.execute (policy state) () (transition actor source target asset amount)
      state.ledger = .ok ledger := by
  have valid := native_valid state actor source target asset amount domain
  exact ⟨DefiKernel.applyEffect state.ledger (transition actor source target asset amount) valid.2.2.2.1,
    (DefiKernel.execute_ok_iff _ _ _ _ _).mpr ⟨valid, rfl⟩⟩

theorem publish_claims (state : PublicState) (actor : Principal) (source target : Account)
    (asset : Asset) (amount : ℚ) (ledger : DefiKernel.State)
    (executed : DefiKernel.execute (policy state) () (transition actor source target asset amount)
      state.ledger = .ok ledger) :
    SuccessClaims state (publish state ledger actor source target asset amount)
      actor source target asset amount := by
  have balance : ∀ cell, ledger.balance cell = state.ledger.balance cell +
      (transition actor source target asset amount).effect cell := by
    obtain ⟨valid, rfl⟩ := (DefiKernel.execute_ok_iff _ _ _ _ _).mp executed
    intro cell
    rfl
  have supply : ∀ e, (publish state ledger actor source target asset amount).supply e = state.supply e := by
    intro e
    simpa [PublicState.supply, publish, transition] using
      DefiKernel.execute_accounting (policy state) () (transition actor source target asset amount)
        state.ledger ledger executed e.native
  have frame : ∀ cell, cell ≠ (source, asset.native) → cell ≠ (target, asset.native) →
      ledger.balance cell = state.ledger.balance cell := by
    intro cell from_source to_target
    exact DefiKernel.execute_locality (policy state) () (transition actor source target asset amount)
      state.ledger ledger executed cell (by simp [transition, from_source, to_target])
  refine ⟨executed, ?_, ledger.nonneg, supply, rfl, rfl, rfl, frame, ?_, ?_⟩
  · intro cell
    simp only [publish, balance, transition, DefiKernel.Examples.move, DefiKernel.Examples.pulse]
    split_ifs <;> simp
  · intro e
    simpa [event] using supply e
  · intro valid
    refine ⟨valid.1, ?_⟩
    intro account
    change ledger.balance (account, .debt) = 0
    rw [frame (account, .debt) (by cases asset <;> simp [Asset.native])
      (by cases asset <;> simp [Asset.native])]
    exact valid.2 account

theorem typed_canonical : TypedCanonical := by
  intro state actor source target asset amount
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro domain
    obtain ⟨ledger, executed⟩ := native_success state actor source target asset amount domain
    refine ⟨publish state ledger actor source target asset amount, ?_,
      publish_claims state actor source target asset amount ledger executed⟩
    simp [transfer, not_lt.mpr domain.1, domain.2.1, not_lt.mpr domain.2.2, executed]
  · intro negative
    simp [transfer, negative]
  · intro nonnegative unauthorized
    simp [transfer, not_lt.mpr nonnegative, unauthorized]
  · intro nonnegative authorized unfunded
    simp [transfer, not_lt.mpr nonnegative, authorized, unfunded]

theorem raw_canonical : RawCanonical := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro state tag
    rfl
  · intro state actor source target asset amount invalid
    rcases invalid with invalid | invalid | invalid | invalid
    all_goals simp [execute, invalid]
  · intro state actor source target asset p s t e bad hp hs ht he
    simp [execute, hp, hs, ht, he]
  · intro state actor source target asset p s t e q hp hs ht he
    simp [execute, hp, hs, ht, he]

theorem canonical : Canonical := ⟨typed_canonical, raw_canonical⟩

#print axioms canonical
#print axioms native_valid
#print axioms publish_claims

end RationalTransfer
