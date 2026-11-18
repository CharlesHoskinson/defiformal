import WorkflowSequenceProofs
import LocalContracts

namespace RationalWorkflow

theorem rawExecute_decode (state : PublicState) (raw : RawCall) :
    rawExecute state raw = match decodeRaw raw with
      | .error reason => .refused reason state
      | .ok call => execute state call := by
  cases raw with
  | unsupported tag => rfl
  | transfer p s t e q =>
    cases hp : decodePrincipal p <;> cases hs : decodeAccount s <;>
      cases ht : decodeAccount t <;> cases he : decodeAsset e <;> cases q <;>
      simp [rawExecute, decodeRaw, withNumber, hp, hs, ht, he]
  | deposit p u v q =>
    cases hp : decodePrincipal p <;> cases hu : decodeUser u <;>
      cases hv : decodeVault v <;> cases q <;>
      simp [rawExecute, decodeRaw, withNumber, hp, hu, hv]
  | withdraw p u v q =>
    cases hp : decodePrincipal p <;> cases hu : decodeUser u <;>
      cases hv : decodeVault v <;> cases q <;>
      simp [rawExecute, decodeRaw, withNumber, hp, hu, hv]
  | grant p c =>
    cases hp : decodePrincipal p <;> cases hc : decodeCapability c <;>
      simp [rawExecute, decodeRaw, hp, hc]
  | revoke p c =>
    cases hp : decodePrincipal p <;> cases hc : decodeCapability c <;>
      simp [rawExecute, decodeRaw, hp, hc]

theorem typed_step_spec (state : PublicState) (call : Call) (valid : ValidState state) :
    match expectedRefusal state call with
    | some reason => execute state call = .refused reason state
    | none => ∃ post, execute state call = .success post ∧
        SuccessDomain state call ∧ LocalClaims state post call := by
  by_cases amount : AmountValid call
  · by_cases authority : Authorized state.capabilities call
    · by_cases funds : Funded state.ledger.balance state.rates call
      · obtain ⟨post, executed, claims⟩ := execute_success state call valid ⟨amount, authority, funds⟩
        simpa [expectedRefusal, amount, authority, funds] using
          (show ∃ post, execute state call = .success post ∧ SuccessDomain state call ∧
            LocalClaims state post call from ⟨post, executed, ⟨amount, authority, funds⟩, claims⟩)
      · simpa [expectedRefusal, amount, authority, funds] using
          (execute_refusal state call).2.2 amount authority funds
    · simpa [expectedRefusal, amount, authority] using
        (execute_refusal state call).2.1 amount authority
  · simpa [expectedRefusal, amount] using (execute_refusal state call).1 amount

theorem raw_step_spec (state : PublicState) (raw : RawCall) (valid : ValidState state) :
    RawStepSpec state raw (rawExecute state raw) := by
  rw [rawExecute_decode]
  cases hd : decodeRaw raw with
  | error reason => simp [RawStepSpec, hd]
  | ok call =>
    cases hr : expectedRefusal state call <;>
      simpa [RawStepSpec, hd, hr] using typed_step_spec state call valid

theorem raw_spec_success {state post : PublicState} {raw : RawCall}
    (h : RawStepSpec state raw (.success post)) :
    ∃ call, SuccessDomain state call ∧ LocalClaims state post call := by
  cases hd : decodeRaw raw with
  | error reason => simp [RawStepSpec, hd] at h
  | ok call =>
    cases hr : expectedRefusal state call with
    | some reason => simp [RawStepSpec, hd, hr] at h
    | none =>
      obtain ⟨post', hp, domain, claims⟩ := (by simpa [RawStepSpec, hd, hr] using h :
        ∃ post', Result.success post = .success post' ∧ SuccessDomain state call ∧ LocalClaims state post' call)
      cases hp
      exact ⟨call, domain, claims⟩

theorem raw_refused_same {state post : PublicState} {raw : RawCall} {reason : Reason}
    (h : rawExecute state raw = .refused reason post) : post = state := by
  rw [rawExecute_decode] at h
  cases hd : decodeRaw raw with
  | error why => simp only [hd] at h; cases h; rfl
  | ok call => simp only [hd] at h; exact execute_refused_unchanged h

theorem runRaw_spec (state : PublicState) (calls : List RawCall) (valid : ValidState state) :
    RawExecutionSpec state calls (runRaw state calls) := by
  induction calls generalizing state with
  | nil => exact .done state
  | cons raw calls ih =>
    have spec := raw_step_spec state raw valid
    cases he : rawExecute state raw with
    | refused reason post =>
      have same := raw_refused_same he
      subst post
      rw [he] at spec
      simpa [runRaw, runWith, he] using RawExecutionSpec.refused state raw calls reason spec
    | success post =>
      rw [he] at spec
      obtain ⟨call, _, claims⟩ := raw_spec_success spec
      have tail := ih post (claims.valid valid)
      simpa [runRaw, runWith, he] using RawExecutionSpec.success state post raw calls
        (runRaw post calls) spec tail

theorem rawSpec_history {state : PublicState} {calls : List RawCall} {result : SequenceResult}
    (h : RawExecutionSpec state calls result) :
    ∃ events, result.state.history = state.history ++ events ∧ events.length = result.committed := by
  induction h with
  | done state => exact ⟨[], by simp, rfl⟩
  | refused state raw calls reason step => exact ⟨[], by simp, rfl⟩
  | success state post raw calls result step rest ih =>
    obtain ⟨call, _, claims⟩ := raw_spec_success step
    obtain ⟨events, hevents, count⟩ := ih
    refine ⟨event state.rates call :: events, ?_, ?_⟩
    · simpa [SequenceResult.bump, claims.history, List.append_assoc] using hevents
    · simpa [SequenceResult.bump, count, Nat.add_comm]

end RationalWorkflow
