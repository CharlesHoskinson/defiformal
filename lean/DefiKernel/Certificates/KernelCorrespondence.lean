import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.Soundness
import DefiKernel.Certificates.LibraryInstantiation
import DefiKernel.Parallel.Compatibility

/-!
Quantified checker-to-Lean correspondence for the delivered production entry.

Historical `checkIR_execute_ok` / `_error` remain definitional dispatch on the
legacy checker and are preserved in `Soundness`. This module maps
`correspondence-theorems.json` names onto statements about `rawExecute` and
`Delivered.checkTyped` / `checkStep` / `checkRun`. Finite F25/F27/F28 tests
do not discharge these.
-/
namespace DefiKernel.Certificates.Delivered

set_option linter.style.longLine false

open DefiKernel.Certificates
open DefiKernel.Typed
open DefiKernel.Composition
open DefiKernel.Parallel

/-- Inventory map: T-raw-typed-ok. Kernel observation, not a Report. -/
theorem rawExecute_typed_ok_complete (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (post : Typed.ExecutionResult Party Asset Domain)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .ok post) :
    (rawExecute (.typed env payload)).world = executionResultToWorld post payload.state ∧
    (rawExecute (.typed env payload)).kernelFailure = none ∧
    (rawExecute (.typed env payload)).outputs = [] ∧
    (rawExecute (.typed env payload)).events = [] ∧
    (rawExecute (.typed env payload)).nextIndex = 0 ∧
    (rawExecute (.typed env payload)).cursorFailure = none :=
  rawExecute_typed_ok env payload state h_state post h_exec

/-- Inventory map: T-raw-typed-error. -/
theorem rawExecute_typed_error_complete (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (r : Typed.Refusal)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .error r) :
    rawExecute (.typed env payload) =
      ⟨⟨payload.state, payload.store⟩, none, [], [], 0, none, some (refusalToLocatedFailure r).reason⟩ :=
  rawExecute_typed_error env payload state h_state r h_exec

/-- Typed rawExecute always uses empty sequential fields. -/
theorem rawExecute_typed_sequential_fields (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc) :
    (rawExecute (.typed env payload)).outputs = [] ∧
    (rawExecute (.typed env payload)).events = [] ∧
    (rawExecute (.typed env payload)).nextIndex = 0 ∧
    (rawExecute (.typed env payload)).cursorFailure = none := by
  dsimp [rawExecute]
  split
  · exact ⟨rfl, rfl, rfl, rfl⟩
  · split <;> exact ⟨rfl, rfl, rfl, rfl⟩

/-- Overlay keeps kernel fields from the raw observation. -/
theorem overlayPolicy_kernel_fields (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String)
    (h_ok : raw.kernelFailure = none) :
    (overlayPolicy env base raw disc cursor miss).world = raw.world ∧
    (overlayPolicy env base raw disc cursor miss).receipt = raw.receipt ∧
    (overlayPolicy env base raw disc cursor miss).outputs = raw.outputs ∧
    (overlayPolicy env base raw disc cursor miss).events = raw.events ∧
    (overlayPolicy env base raw disc cursor miss).nextIndex = raw.nextIndex ∧
    (overlayPolicy env base raw disc cursor miss).cursorFailure = cursor := by
  unfold overlayPolicy
  cases hkf : raw.kernelFailure with
  | some _ =>
    rw [hkf] at h_ok
    cases h_ok
  | none =>
    split_ifs <;> simp

/-- Overlay refuses claimed-world mismatch while retaining the successful invoke observation. -/
theorem overlayPolicy_claimed_mismatch (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String)
    (h_ok : raw.kernelFailure = none)
    (h_mis : claimedMismatch? env raw.world = true) :
    (overlayPolicy env base raw disc cursor miss).status = .refused ∧
    (overlayPolicy env base raw disc cursor miss).failure =
      some ⟨.observationMismatch, "claimedNextState", none⟩ ∧
    (overlayPolicy env base raw disc cursor miss).world = raw.world ∧
    (overlayPolicy env base raw disc cursor miss).receipt = raw.receipt := by
  unfold overlayPolicy
  cases hkf : raw.kernelFailure with
  | some _ =>
    rw [hkf] at h_ok
    cases h_ok
  | none =>
    simp [h_mis]

/-- Overlay refuses a false required family; kernel fields stay the raw observation. -/
theorem overlayPolicy_false_family (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc)
    (h_ok : raw.kernelFailure = none)
    (h_mis : claimedMismatch? env raw.world = false)
    (h_six : (none : Option String) = none)
    (h_disc : disc = true)
    (h_fam : requiredReachedFamiliesTrue base.judgments = false) :
    (overlayPolicy env base raw disc cursor none).status = .refused ∧
    (overlayPolicy env base raw disc cursor none).failure =
      some ⟨.configuration, firstFalseFamily base.judgments, none⟩ ∧
    (overlayPolicy env base raw disc cursor none).world = raw.world ∧
    (overlayPolicy env base raw disc cursor none).receipt = raw.receipt := by
  unfold overlayPolicy
  cases hkf : raw.kernelFailure with
  | some _ =>
    rw [hkf] at h_ok
    cases h_ok
  | none =>
    simp [h_mis, h_disc, h_fam]

/-- Overlay accepts only when every policy conjunct holds. -/
theorem overlayPolicy_accepted (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (cursor : Option LocatedFailureEnc)
    (h_ok : raw.kernelFailure = none)
    (h_mis : claimedMismatch? env raw.world = false)
    (h_disc : true = true)
    (h_fam : requiredReachedFamiliesTrue base.judgments = true) :
    (overlayPolicy env base raw true cursor none).status = .accepted ∧
    (overlayPolicy env base raw true cursor none).failure = none ∧
    (overlayPolicy env base raw true cursor none).world = raw.world := by
  unfold overlayPolicy
  cases hkf : raw.kernelFailure with
  | some _ =>
    rw [hkf] at h_ok
    cases h_ok
  | none =>
    simp [h_mis, h_fam]

/-- Overlay copies the supplied judgment list on every branch. -/
theorem overlayPolicy_judgments_eq (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String) :
    (overlayPolicy env base raw disc cursor miss).judgments = base.judgments := by
  unfold overlayPolicy
  cases raw.kernelFailure <;> split_ifs <;> rfl

/-- A false required family is never an accepted overlay. -/
theorem overlayPolicy_false_family_not_accepted
    (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String)
    (h_fam : requiredReachedFamiliesTrue base.judgments = false) :
    (overlayPolicy env base raw disc cursor miss).status ≠ .accepted := by
  unfold overlayPolicy
  cases raw.kernelFailure
  · simp [h_fam]; split_ifs <;> simp
  · simp

/-- Accepted overlay implies no false required family. -/
theorem overlayPolicy_accepted_implies_no_false_required
    (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String)
    (h : (overlayPolicy env base raw disc cursor miss).status = .accepted) :
    requiredReachedFamiliesTrue base.judgments = true := by
  cases hfam : requiredReachedFamiliesTrue base.judgments
  · exact (overlayPolicy_false_family_not_accepted env base raw disc cursor miss hfam h).elim
  · rfl

/-- Accepted overlay implies the kernel observation succeeded. -/
theorem overlayPolicy_accepted_implies_kernel_ok
    (env : EnvelopeEnc) (base : Report) (raw : RawObservation)
    (disc : Bool) (cursor : Option LocatedFailureEnc) (miss : Option String)
    (h : (overlayPolicy env base raw disc cursor miss).status = .accepted) :
    raw.kernelFailure = none := by
  unfold overlayPolicy at h
  cases hkf : raw.kernelFailure with
  | none => rfl
  | some _ => simp [hkf] at h

/-- Inventory map: T-checkIR-stale. Git mismatch refuses without using rawExecute fields. -/
theorem checkTyped_source_identity_git_guard (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h : env.source_pin.git ≠ TrustedHost.gitSha) :
    (checkTyped env payload).status = .refused ∧
    (checkTyped env payload).failure = some ⟨.staleSource, "git", some env.source_pin.git⟩ ∧
    (checkTyped env payload).world = ⟨payload.state, payload.store⟩ ∧
    (checkTyped env payload).receipt = none ∧
    (checkTyped env payload).outputs = [] ∧
    (checkTyped env payload).events = [] ∧
    (checkTyped env payload).nextIndex = 0 ∧
    (checkTyped env payload).cursorFailure = none := by
  have h_id : sourceIdentity env.source_pin = false := by
    simp [sourceIdentity, h]
  dsimp only [checkTyped]
  rcases computeAssumptions env with ⟨assList, missAss⟩
  dsimp only
  simp [h_id, sourceIdentityFailure, h]

/-- Inventory map: T-checkIR-typed-ok. Source identity then kernel fields equal rawExecute.
Does not imply Report.accepted. -/
theorem checkTyped_from_raw_typed_ok (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.typed env payload)).kernelFailure = none) :
    (checkTyped env payload).world = (rawExecute (.typed env payload)).world ∧
    (checkTyped env payload).receipt = (rawExecute (.typed env payload)).receipt ∧
    (checkTyped env payload).outputs = (rawExecute (.typed env payload)).outputs ∧
    (checkTyped env payload).events = (rawExecute (.typed env payload)).events ∧
    (checkTyped env payload).nextIndex = (rawExecute (.typed env payload)).nextIndex ∧
    (checkTyped env payload).cursorFailure = (rawExecute (.typed env payload)).cursorFailure := by
  unfold checkTyped
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  exact overlayPolicy_kernel_fields env _ (rawExecute (.typed env payload)) _ _ missAss h_ok

/-- Inventory map: T-checkIR-typed-error. -/
theorem checkTyped_from_raw_typed_error (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (kf : FailurePath)
    (h_err : (rawExecute (.typed env payload)).kernelFailure = some kf) :
    (checkTyped env payload).status = .refused ∧
    (checkTyped env payload).failure = some kf ∧
    (checkTyped env payload).world = (rawExecute (.typed env payload)).world ∧
    (checkTyped env payload).receipt = (rawExecute (.typed env payload)).receipt := by
  unfold checkTyped
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  unfold overlayPolicy
  simp [h_err]

/-- Inventory map: T-observation-mismatch. Status refused, receipt retained. -/
theorem checkTyped_claimed_next_state_mismatch (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.typed env payload)).kernelFailure = none)
    (claimed : WorldEnc)
    (h_cl : env.claimed_next_state = some claimed)
    (h_ne : claimed ≠ (rawExecute (.typed env payload)).world) :
    (checkTyped env payload).status = .refused ∧
    (checkTyped env payload).failure = some ⟨.observationMismatch, "claimedNextState", none⟩ ∧
    (checkTyped env payload).world = (rawExecute (.typed env payload)).world ∧
    (checkTyped env payload).receipt = (rawExecute (.typed env payload)).receipt := by
  have h_mis : claimedMismatch? env (rawExecute (.typed env payload)).world = true := by
    simp [claimedMismatch?, h_cl, h_ne]
  unfold checkTyped
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  exact overlayPolicy_claimed_mismatch env _ (rawExecute (.typed env payload)) _ _ missAss h_ok h_mis

/-- Inventory map: T-report-policy-accepted. Each conjunct is an explicit premise. -/
theorem checkTyped_report_accepted_from_raw_and_policy
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.typed env payload)).kernelFailure = none)
    (h_six : (computeAssumptions env).2 = none)
    (h_claim : claimedMismatch? env (rawExecute (.typed env payload)).world = false)
    (h_disc : requestedDischargeOk env payload
      (env.claimed_next_state.getD (rawExecute (.typed env payload)).world) = true)
    (h_fam : requiredReachedFamiliesTrue
      (replaceFamily (_root_.DefiKernel.Certificates.checkTyped env payload)
        "libraryTheoremsInstantiated"
        (LibraryInstantiation.familyBound env.libraries env.source_pin payload
          (env.claimed_next_state.getD (rawExecute (.typed env payload)).world))).judgments = true) :
    (checkTyped env payload).status = .accepted ∧
    (checkTyped env payload).failure = none ∧
    (checkTyped env payload).world = (rawExecute (.typed env payload)).world := by
  unfold checkTyped
  rcases hAss : computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  have h_miss : missAss = none := by
    have : (computeAssumptions env).2 = none := h_six
    simpa [hAss] using this
  subst h_miss
  unfold overlayPolicy
  simp [h_ok, h_claim, h_disc, h_fam]

/-- Inventory map: T-checkIR-step-ok (delivered). -/
theorem checkStep_from_raw_ok (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.step env payload)).kernelFailure = none) :
    (checkStep env payload).world = (rawExecute (.step env payload)).world ∧
    (checkStep env payload).receipt = (rawExecute (.step env payload)).receipt ∧
    (checkStep env payload).outputs = (rawExecute (.step env payload)).outputs := by
  unfold checkStep
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  have h := overlayPolicy_kernel_fields env
    (_root_.DefiKernel.Certificates.checkStep env payload)
    (rawExecute (.step env payload))
    (requestedDischargeOkEnvelope env (rawExecute (.step env payload)).world none)
    (_root_.DefiKernel.Certificates.checkStep env payload).cursorFailure
    missAss h_ok
  exact ⟨h.1, h.2.1, h.2.2.1⟩

/-- Inventory map: T-checkIR-run-cursor (delivered kernel fields including receipt). -/
theorem checkRun_from_raw_cursor (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.run env payload)).kernelFailure = none) :
    (checkRun env payload).world = (rawExecute (.run env payload)).world ∧
    (checkRun env payload).receipt = (rawExecute (.run env payload)).receipt ∧
    (checkRun env payload).outputs = (rawExecute (.run env payload)).outputs ∧
    (checkRun env payload).events = (rawExecute (.run env payload)).events ∧
    (checkRun env payload).nextIndex = (rawExecute (.run env payload)).nextIndex ∧
    (checkRun env payload).cursorFailure = (rawExecute (.run env payload)).cursorFailure := by
  unfold checkRun
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  exact overlayPolicy_kernel_fields env _ (rawExecute (.run env payload)) _ _ missAss h_ok

/-- Delivered checkRun never accepts a false required family. -/
theorem checkRun_accepted_implies_no_false_required
    (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h : (checkRun env payload).status = .accepted) :
    requiredReachedFamiliesTrue (checkRun env payload).judgments = true := by
  unfold checkRun at h ⊢
  cases hsi : sourceIdentity env.source_pin
  · simp [hsi] at h
  · simp [hsi] at h ⊢
    have hfam := overlayPolicy_accepted_implies_no_false_required env
      (_root_.DefiKernel.Certificates.checkRun env payload)
      (rawExecute (.run env payload))
      (requestedDischargeOkEnvelope env (rawExecute (.run env payload)).world none)
      (rawExecute (.run env payload)).cursorFailure
      (computeAssumptions env).2 h
    simpa [overlayPolicy_judgments_eq] using hfam

/-- Delivered checkTyped never accepts a false required family. -/
theorem checkTyped_accepted_implies_no_false_required
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h : (checkTyped env payload).status = .accepted) :
    requiredReachedFamiliesTrue (checkTyped env payload).judgments = true := by
  unfold checkTyped at h ⊢
  cases hsi : sourceIdentity env.source_pin
  · simp [hsi] at h
  · simp [hsi] at h ⊢
    have hfam := overlayPolicy_accepted_implies_no_false_required env
      (replaceFamily (_root_.DefiKernel.Certificates.checkTyped env payload)
        "libraryTheoremsInstantiated"
        (LibraryInstantiation.familyBound env.libraries env.source_pin payload
          (env.claimed_next_state.getD (rawExecute (.typed env payload)).world)))
      (rawExecute (.typed env payload))
      (requestedDischargeOk env payload
        (env.claimed_next_state.getD (rawExecute (.typed env payload)).world))
      (rawExecute (.typed env payload)).cursorFailure
      (computeAssumptions env).2 h
    simpa [overlayPolicy_judgments_eq] using hfam

/-- Delivered checkStep never accepts a false required family. -/
theorem checkStep_accepted_implies_no_false_required
    (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h : (checkStep env payload).status = .accepted) :
    requiredReachedFamiliesTrue (checkStep env payload).judgments = true := by
  unfold checkStep at h ⊢
  cases hsi : sourceIdentity env.source_pin
  · simp [hsi] at h
  · simp [hsi] at h ⊢
    have hfam := overlayPolicy_accepted_implies_no_false_required env
      (_root_.DefiKernel.Certificates.checkStep env payload)
      (rawExecute (.step env payload))
      (requestedDischargeOkEnvelope env (rawExecute (.step env payload)).world none)
      (_root_.DefiKernel.Certificates.checkStep env payload).cursorFailure
      (computeAssumptions env).2 h
    simpa [overlayPolicy_judgments_eq] using hfam

/-- Delivered checkIR routes to delivered checkers, not the legacy ones. -/
theorem checkIR_typed (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc) :
    checkIR (.execution (.typed env payload)) = .execution (checkTyped env payload) := rfl

theorem checkIR_step (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc) :
    checkIR (.execution (.step env payload)) = .execution (checkStep env payload) := rfl

theorem checkIR_run (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc) :
    checkIR (.execution (.run env payload)) = .execution (checkRun env payload) := rfl

theorem checkBytes_of_decode_typed (raw : ByteArray) (env : EnvelopeEnc)
    (payload : TypedExecutePayloadEnc)
    (h : decodeBytes raw = .ok (.execution (.typed env payload))) :
    checkBytes raw = .execution (checkTyped env payload) := by
  unfold checkBytes
  rw [h]
  rfl

/-- Inventory map: T-raw-typed-ok receipt. Invoked request+evaluated, not a Report. -/
theorem rawExecute_typed_ok_receipt
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (post : Typed.ExecutionResult Party Asset Domain)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .ok post)
    (tmpl : Typed.Template Party Asset Domain)
    (h_tmpl : registryToTyped payload.registry payload.request.toRequest.operation = some tmpl)
    (checkedArgs : Typed.Args tmpl.signature)
    (h_args : Typed.Args.check tmpl.signature payload.request.toRequest.arguments = .ok checkedArgs)
    (e : Typed.Evaluated Party Asset Domain)
    (h_eval : tmpl.evaluate
        ⟨state, envToTyped payload.env, payload.ctx.toContext.principal,
         payload.request.toRequest.parties, checkedArgs, payload.now⟩ = .ok e) :
    (rawExecute (.typed env payload)).receipt = some (evaluatedToEnc e payload.request.toRequest) ∧
    (rawExecute (.typed env payload)).world = executionResultToWorld post payload.state ∧
    (rawExecute (.typed env payload)).kernelFailure = none := by
  dsimp [rawExecute]
  rw [h_state]
  dsimp
  rw [h_exec]
  dsimp
  rw [h_tmpl]
  dsimp
  rw [h_args]
  dsimp
  rw [h_eval]
  exact ⟨rfl, rfl, rfl⟩

/-- Inventory map: T-raw-step-ok complete world/receipt/outputs. -/
theorem rawExecute_step_ok_complete
    (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (res : StepResult Party Asset Domain)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .ok res) :
    (rawExecute (.step env payload)).world =
      ⟨⟨payload.pre.state.cells.map (fun row ↦
          let b := res.world.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩,
        storeToEnc res.world.capabilities⟩ ∧
    (rawExecute (.step env payload)).receipt = some
      (match res.receipt with
       | .invoked req e => evaluatedToEnc e req
       | .issued id => .issued id.value
       | .revoked id => .revoked id.value) ∧
    (rawExecute (.step env payload)).outputs = res.outputs.map OutputObservationEnc.fromOutputObservation ∧
    (rawExecute (.step env payload)).events = [] ∧
    (rawExecute (.step env payload)).nextIndex = 0 ∧
    (rawExecute (.step env payload)).cursorFailure = none ∧
    (rawExecute (.step env payload)).kernelFailure = none := by
  dsimp [rawExecute]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  rw [h_step]
  dsimp
  rw [h_exec]
  dsimp
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Inventory map: T-raw-run-cursor including world and last-prefix receipt. -/
theorem rawExecute_run_cursor_complete
    (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld) :
    let bList := payload.boundaries.map boundaryToTyped
    let defaultBoundary : Boundary Party Asset Domain := ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
    let boundaries : Nat → Boundary Party Asset Domain :=
      fun idx ↦ match bList[idx]? with | some b => b | none => bList.head?.getD defaultBoundary
    let steps := payload.steps.filterMap StepEnc.toStep?
    let cursor := Composition.run cfg boundaries initialWorld steps
    (rawExecute (.run env payload)).world =
      ⟨⟨payload.world.state.cells.map (fun row ↦
          let b := cursor.world.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩,
        storeToEnc cursor.world.capabilities⟩ ∧
    (rawExecute (.run env payload)).receipt =
      cursor.events.getLast?.map (fun ev ↦
        match ev.result.receipt with
        | .invoked req e => evaluatedToEnc e req
        | .issued id => .issued id.value
        | .revoked id => .revoked id.value) ∧
    (rawExecute (.run env payload)).outputs = cursor.outputs.map OutputObservationEnc.fromOutputObservation ∧
    (rawExecute (.run env payload)).nextIndex = cursor.nextIndex ∧
    (rawExecute (.run env payload)).cursorFailure =
      cursor.failure.map (fun cf ↦ ⟨cf.index, cf.step.map StepEnc.fromStep, failureToPath cf.reason⟩) ∧
    (rawExecute (.run env payload)).kernelFailure = cursor.failure.map (fun cf ↦ failureToPath cf.reason) := by
  intro bList defaultBoundary boundaries steps cursor
  dsimp [rawExecute]
  rw [h_cfg]
  dsimp
  rw [h_world]
  dsimp
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Full source-identity: toolchain mismatch refuses without kernel fields. -/
theorem checkTyped_source_identity_toolchain_guard
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_git : env.source_pin.git = TrustedHost.gitSha)
    (h : env.source_pin.lean_toolchain ≠ TrustedHost.leanToolchain) :
    (checkTyped env payload).status = .refused ∧
    (checkTyped env payload).failure =
      some ⟨.staleSource, "lean_toolchain", some env.source_pin.lean_toolchain⟩ ∧
    (checkTyped env payload).world = ⟨payload.state, payload.store⟩ ∧
    (checkTyped env payload).receipt = none := by
  have h_id : sourceIdentity env.source_pin = false := by
    simp [sourceIdentity, h_git, h]
  dsimp only [checkTyped]
  rcases computeAssumptions env with ⟨assList, missAss⟩
  dsimp only
  simp [h_id, sourceIdentityFailure, h_git, h]

/-- Full source-identity: mathlib_rev mismatch. -/
theorem checkTyped_source_identity_mathlib_guard
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_git : env.source_pin.git = TrustedHost.gitSha)
    (h_tc : env.source_pin.lean_toolchain = TrustedHost.leanToolchain)
    (h : env.source_pin.mathlib_rev ≠ TrustedHost.mathlibRev) :
    (checkTyped env payload).status = .refused ∧
    (checkTyped env payload).failure =
      some ⟨.staleSource, "mathlib_rev", some env.source_pin.mathlib_rev⟩ ∧
    (checkTyped env payload).receipt = none := by
  have h_id : sourceIdentity env.source_pin = false := by
    simp [sourceIdentity, h_git, h_tc, h]
  dsimp only [checkTyped]
  rcases computeAssumptions env with ⟨assList, missAss⟩
  dsimp only
  simp [h_id, sourceIdentityFailure, h_git, h_tc, h]

/-- Step-mode source identity uses the same pin guard. -/
theorem checkStep_source_identity_git_guard (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h : env.source_pin.git ≠ TrustedHost.gitSha) :
    (checkStep env payload).status = .refused ∧
    (checkStep env payload).failure = some ⟨.staleSource, "git", some env.source_pin.git⟩ ∧
    (checkStep env payload).world = payload.pre ∧
    (checkStep env payload).receipt = none := by
  have h_id : sourceIdentity env.source_pin = false := by
    simp [sourceIdentity, h]
  unfold checkStep
  simp [h_id, sourceIdentityFailure, h]

/-- Run-mode source identity uses the same pin guard. -/
theorem checkRun_source_identity_git_guard (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h : env.source_pin.git ≠ TrustedHost.gitSha) :
    (checkRun env payload).status = .refused ∧
    (checkRun env payload).failure = some ⟨.staleSource, "git", some env.source_pin.git⟩ ∧
    (checkRun env payload).world = payload.world ∧
    (checkRun env payload).receipt = none := by
  have h_id : sourceIdentity env.source_pin = false := by
    simp [sourceIdentity, h]
  unfold checkRun
  simp [h_id, sourceIdentityFailure, h]

/-- Inventory map: T-checkIR-step-error. Without source identity this is not drawn. -/
theorem checkStep_from_raw_error (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (kf : FailurePath)
    (h_err : (rawExecute (.step env payload)).kernelFailure = some kf) :
    (checkStep env payload).status = .refused ∧
    (checkStep env payload).failure = some kf ∧
    (checkStep env payload).world = (rawExecute (.step env payload)).world ∧
    (checkStep env payload).receipt = (rawExecute (.step env payload)).receipt ∧
    (checkStep env payload).outputs = (rawExecute (.step env payload)).outputs := by
  unfold checkStep
  rcases computeAssumptions env with ⟨assList, missAss⟩
  simp [h_id]
  unfold overlayPolicy
  simp [h_err]

/-- Delivered checkIR step-error routing. -/
theorem checkIR_from_raw_step_error (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (kf : FailurePath)
    (h_err : (rawExecute (.step env payload)).kernelFailure = some kf) :
    checkIR (.execution (.step env payload)) = .execution (checkStep env payload) ∧
    (checkStep env payload).failure = some kf ∧
    (checkStep env payload).world = (rawExecute (.step env payload)).world := by
  have h := checkStep_from_raw_error env payload h_id kf h_err
  exact ⟨checkIR_step env payload, h.2.1, h.2.2.1⟩

theorem checkBytes_of_decode_step (raw : ByteArray) (env : EnvelopeEnc)
    (payload : CompositionStepPayloadEnc)
    (h : decodeBytes raw = .ok (.execution (.step env payload))) :
    checkBytes raw = .execution (checkStep env payload) := by
  unfold checkBytes
  rw [h]
  rfl

theorem checkBytes_of_decode_run (raw : ByteArray) (env : EnvelopeEnc)
    (payload : CompositionRunPayloadEnc)
    (h : decodeBytes raw = .ok (.execution (.run env payload))) :
    checkBytes raw = .execution (checkRun env payload) := by
  unfold checkBytes
  rw [h]
  rfl

theorem checkIR_from_raw_typed_ok
    (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_id : sourceIdentity env.source_pin = true)
    (h_ok : (rawExecute (.typed env payload)).kernelFailure = none) :
    checkIR (.execution (.typed env payload)) = .execution (checkTyped env payload) ∧
    (checkTyped env payload).world = (rawExecute (.typed env payload)).world ∧
    (checkTyped env payload).receipt = (rawExecute (.typed env payload)).receipt := by
  have h := checkTyped_from_raw_typed_ok env payload h_id h_ok
  exact ⟨checkIR_typed env payload, h.1, h.2.1⟩

/-- Inventory map: T-malformed-no-kernel for the delivered entry. -/
theorem decode_error_no_execute (raw : ByteArray) (e : DecodeFailure)
    (h : decodeBytes raw = .error e) (h_not : ∀ lim, e ≠ .resourceLimit lim) :
    checkBytes raw = .codec (.malformed e) := by
  unfold checkBytes
  rw [h]
  cases e with
  | resourceLimit lim =>
    exfalso
    exact h_not lim rfl
  | emptyDocument => rfl
  | lexicalScientificOrFloat => rfl
  | notJsonObject => rfl
  | duplicateKey _ => rfl
  | noncanonicalWhitespace => rfl
  | schemaVersion => rfl
  | missingField _ => rfl
  | jsonType _ => rfl
  | unknownIdentifier _ => rfl
  | uniqueness _ => rfl
  | illegalRational _ => rfl
  | stateNonneg => rfl
  | unknownExecutableField _ => rfl
  | unsupportedForm _ => rfl

end DefiKernel.Certificates.Delivered
