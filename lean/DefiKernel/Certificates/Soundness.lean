import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Observation
import DefiKernel.Certificates.Correspondence
import DefiKernel.Composition.Sequence

namespace DefiKernel.Certificates

set_option linter.style.longLine false

open DefiKernel.Composition

/-! Soundness theorems and open remainder obligations for certificate verification.
In accordance with P19 specifications and P20 gates:
- Bounded finite fixture evidence is computationally checked.
- Universal quantified theorems (T-raw-typed-ok, T-raw-typed-error, T-raw-step-ok,
  T-raw-step-error, T-raw-run-cursor, T-checkIR-stale, T-checkIR-typed-ok, etc.)
  remain open obligations for P20.
- Strictly zero `sorry`, custom axioms, or `native_decide` are used in accepted kernel proofs. -/

def SourceIdentity (pin : SourcePinEnc) : Prop :=
  pin.git = "a12b7cac05a818cc8d35c2ca440b7170a2807e92" ∧
  pin.lean_toolchain = "leanprover/lean4:v4.33.0-rc2" ∧
  pin.mathlib_rev = "51e6992efd06126df61a496bebf8f49482a4e129"

/-- Statement of T-checkIR-stale (P20 open obligation). -/
def CheckIRStaleStatement : Prop :=
  ∀ (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc),
    env.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92" →
    (checkTyped env payload).status = .refused

/-- Stale source pin refusal theorem on checkTyped. -/
theorem checkTyped_stale_git (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h : env.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92") :
    (checkTyped env payload).status = .refused := by
  dsimp only [checkTyped]
  rcases computeAssumptions env with ⟨assList, missAss⟩
  dsimp only
  rw [if_pos (by simpa [TrustedHost.gitSha] using h)]

/-- Raw execution typed error theorem: returns preWorld and wrapped refusal reason. -/
theorem rawExecute_typed_error (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (r : Typed.Refusal)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .error r) :
    rawExecute (.typed env payload) =
      ⟨⟨payload.state, payload.store⟩, none, [], [], 0, none, some (refusalToLocatedFailure r).reason⟩ := by
  dsimp [rawExecute]
  rw [h_state]
  dsimp
  rw [h_exec]

/-- Raw execution typed ok theorem: returns postWorld and none failures. -/
theorem rawExecute_typed_ok (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
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
    (rawExecute (.typed env payload)).cursorFailure = none := by
  dsimp [rawExecute]
  rw [h_state]
  dsimp
  rw [h_exec]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Raw execution step error theorem: returns preWorld and wrapped step failure. -/
theorem rawExecute_step_error (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (f : Composition.Failure)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .error f) :
    rawExecute (.step env payload) =
      ⟨payload.pre, none, [], [], payload.index, none, some (failureToPath f)⟩ := by
  dsimp [rawExecute]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  rw [h_step]
  dsimp
  rw [h_exec]

/-- Raw execution step ok theorem: returns step outputs and none failures. -/
theorem rawExecute_step_ok (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (res : StepResult Party Asset Domain)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .ok res) :
    (rawExecute (.step env payload)).kernelFailure = none ∧
    (rawExecute (.step env payload)).events = [] ∧
    (rawExecute (.step env payload)).nextIndex = 0 ∧
    (rawExecute (.step env payload)).cursorFailure = none := by
  dsimp [rawExecute]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  rw [h_step]
  dsimp
  rw [h_exec]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl⟩

/-- Composition step invalid config theorem: returns configuration refusal. -/
theorem checkStep_invalid_config (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_cfg : configToTyped? payload.config = none) :
    (checkStep cert payload).status = .refused ∧
    (checkStep cert payload).failure = some ⟨.configuration, "configuration", none⟩ ∧
    (checkStep cert payload).world = payload.pre ∧
    (checkStep cert payload).receipt = none ∧
    (checkStep cert payload).outputs = [] := by
  dsimp [checkStep]
  rw [h_cfg]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- Composition step invalid prestate theorem: returns kernel stateNonneg refusal. -/
theorem checkStep_invalid_prestate (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (h_pre : payload.pre.toWorld? = none) :
    (checkStep cert payload).status = .refused ∧
    (checkStep cert payload).failure = some ⟨.kernel, "stateNonneg", none⟩ ∧
    (checkStep cert payload).world = payload.pre ∧
    (checkStep cert payload).receipt = none ∧
    (checkStep cert payload).outputs = [] := by
  dsimp [checkStep]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- Composition step error theorem: returns failure path and preWorld. -/
theorem checkStep_step_error (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (fail : Composition.Failure)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .error fail) :
    (checkStep cert payload).status = .refused ∧
    (checkStep cert payload).failure = some (failureToPath fail) ∧
    (checkStep cert payload).world = payload.pre ∧
    (checkStep cert payload).receipt = none ∧
    (checkStep cert payload).outputs = [] := by
  dsimp [checkStep]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  rw [h_step]
  dsimp
  rw [h_exec]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- Composition step success theorem: preserves outputs and nextIndex advances. -/
theorem checkStep_step_ok (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (res : StepResult Party Asset Domain)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .ok res) :
    (checkStep cert payload).outputs = res.outputs.map OutputObservationEnc.fromOutputObservation ∧
    (checkStep cert payload).nextIndex = payload.index := by
  dsimp [checkStep]
  rw [h_cfg]
  dsimp
  rw [h_pre]
  dsimp
  rw [h_step]
  dsimp
  rw [h_exec]
  dsimp
  refine ⟨rfl, rfl⟩

/-- Composition run correspondence theorem: cursor outputs and failures match rawExecute. -/
theorem rawExecute_run_cursor (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld) :
    let bList := payload.boundaries.map boundaryToTyped
    let defaultBoundary : Boundary Party Asset Domain :=
      ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
    let boundaries : Nat → Boundary Party Asset Domain :=
      fun idx ↦ match bList[idx]? with
      | some b => b
      | none => bList.head?.getD defaultBoundary
    let steps : List (Composition.Step Party Asset Domain) :=
      payload.steps.filterMap StepEnc.toStep?
    let cursor := Composition.run cfg boundaries initialWorld steps
    (rawExecute (.run env payload)).outputs = cursor.outputs.map OutputObservationEnc.fromOutputObservation ∧
    (rawExecute (.run env payload)).nextIndex = cursor.nextIndex ∧
    (rawExecute (.run env payload)).cursorFailure =
      cursor.failure.map fun cf ↦
        let stepEnc := cf.step.map StepEnc.fromStep
        ⟨cf.index, stepEnc, failureToPath cf.reason⟩ := by
  dsimp [rawExecute]
  rw [h_cfg]
  dsimp
  rw [h_world]
  dsimp
  refine ⟨rfl, rfl, rfl⟩

/-- CheckTyped error theorem: when Typed.execute returns error r, checkTyped returns refused status, preWorld, none receipt, and the failure reason. -/
theorem checkTyped_execute_error (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_git : rawCert.source_pin.git = "a12b7cac05a818cc8d35c2ca440b7170a2807e92")
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (r : Typed.Refusal)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .error r) :
    (checkTyped rawCert payload).status = ReportStatus.refused ∧
    (checkTyped rawCert payload).failure = some (refusalToLocatedFailure r).reason ∧
    (checkTyped rawCert payload).world = ⟨payload.state, payload.store⟩ ∧
    (checkTyped rawCert payload).receipt = none ∧
    (checkTyped rawCert payload).outputs = [] ∧
    (checkTyped rawCert payload).events = [] ∧
    (checkTyped rawCert payload).nextIndex = 0 := by
  have h_not : ¬ (rawCert.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92") := by
    intro h_contra
    exact h_contra h_git
  dsimp only [checkTyped]
  rcases computeAssumptions rawCert with ⟨assList, missAss⟩
  dsimp only
  rw [if_neg (by simpa [TrustedHost.gitSha] using h_not)]
  rw [h_state]
  dsimp
  have h_ex : (do
    let post ← Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
      payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state
    return post : Except Typed.Refusal (Typed.ExecutionResult Party Asset Domain)) = .error r := by
    rw [h_exec]
  rw [h_ex]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- CheckTyped success theorem: when Typed.execute returns ok post and assumptions hold, checkTyped returns accepted status and postWorld. -/
theorem checkTyped_execute_ok (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_git : rawCert.source_pin.git = "a12b7cac05a818cc8d35c2ca440b7170a2807e92")
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (post : Typed.ExecutionResult Party Asset Domain)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .ok post)
    (h_assump : (computeAssumptions rawCert).2 = none)
    (h_claimed : rawCert.claimed_next_state = none) :
    (checkTyped rawCert payload).status = ReportStatus.accepted ∧
    (checkTyped rawCert payload).failure = none ∧
    (checkTyped rawCert payload).world = executionResultToWorld post payload.state ∧
    (checkTyped rawCert payload).outputs = [] ∧
    (checkTyped rawCert payload).events = [] ∧
    (checkTyped rawCert payload).nextIndex = 0 := by
  have h_not : ¬ (rawCert.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92") := by
    intro h_contra
    exact h_contra h_git
  dsimp only [checkTyped]
  rcases h_ca : computeAssumptions rawCert with ⟨assList, missAss⟩
  have h_miss : missAss = none := by
    have h2 : (computeAssumptions rawCert).2 = missAss := by rw [h_ca]
    rw [← h2, h_assump]
  subst h_miss
  dsimp only
  rw [if_neg (by simpa [TrustedHost.gitSha] using h_not)]
  rw [h_state]
  dsimp
  have h_ex : (do
    let post ← Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
      payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state
    return post : Except Typed.Refusal (Typed.ExecutionResult Party Asset Domain)) = .ok post := by
    rw [h_exec]
  rw [h_ex]
  dsimp
  rw [h_claimed]
  dsimp
  refine ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- CheckIR preserves Typed execution checking. -/
theorem checkIR_execute_error (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc) :
    checkIR (.execution (.typed rawCert payload)) = .execution (checkTyped rawCert payload) := by
  dsimp [checkIR]

theorem checkIR_execute_ok (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc) :
    checkIR (.execution (.typed rawCert payload)) = .execution (checkTyped rawCert payload) := by
  dsimp [checkIR]

/-- CheckIR preserves Composition step checking. -/
theorem checkIR_executeStep_error (rawCert : EnvelopeEnc) (payload : CompositionStepPayloadEnc) :
    checkIR (.execution (.step rawCert payload)) = .execution (checkStep rawCert payload) := by
  dsimp [checkIR]

theorem checkIR_executeStep_ok (rawCert : EnvelopeEnc) (payload : CompositionStepPayloadEnc) :
    checkIR (.execution (.step rawCert payload)) = .execution (checkStep rawCert payload) := by
  dsimp [checkIR]

/-- CheckIR preserves Composition run checking. -/
theorem checkIR_run (rawCert : EnvelopeEnc) (payload : CompositionRunPayloadEnc) :
    checkIR (.execution (.run rawCert payload)) = .execution (checkRun rawCert payload) := by
  dsimp [checkIR]

/-- CheckBytes bridges to checkTyped. -/
theorem checkBytes_typed (raw : ByteArray) (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.typed rawCert payload))) :
    checkBytes raw = .execution (checkTyped rawCert payload) := by
  dsimp [checkBytes]
  rw [h_dec]
  dsimp [checkIR]

/-- CheckBytes bridges to checkStep. -/
theorem checkBytes_step (raw : ByteArray) (rawCert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.step rawCert payload))) :
    checkBytes raw = .execution (checkStep rawCert payload) := by
  dsimp [checkBytes]
  rw [h_dec]
  dsimp [checkIR]

/-- CheckBytes bridges to checkRun. -/
theorem checkBytes_run (raw : ByteArray) (rawCert : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.run rawCert payload))) :
    checkBytes raw = .execution (checkRun rawCert payload) := by
  dsimp [checkBytes]
  rw [h_dec]
  dsimp [checkIR]

/-- T-checkIR-stale: Source identity guard theorem. -/
theorem checkIR_stale : CheckIRStaleStatement := checkTyped_stale_git

/-- Soundness of checkBytes on stale git pin. -/
theorem checkBytes_stale_git (raw : ByteArray) (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.typed env payload)))
    (h_stale : env.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92") :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = .refused := by
  use checkTyped env payload
  refine ⟨checkBytes_typed raw env payload h_dec, checkTyped_stale_git env payload h_stale⟩

/-- Soundness of checkBytes on Typed execution refusal. -/
theorem checkBytes_typed_error (raw : ByteArray) (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.typed rawCert payload)))
    (h_git : rawCert.source_pin.git = "a12b7cac05a818cc8d35c2ca440b7170a2807e92")
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (r : Typed.Refusal)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .error r) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = .refused ∧ rep.failure = some (refusalToLocatedFailure r).reason := by
  use checkTyped rawCert payload
  have h_bt := checkBytes_typed raw rawCert payload h_dec
  have ⟨h_st, h_fail, _, _, _, _, _⟩ := checkTyped_execute_error rawCert payload h_git state h_state r h_exec
  exact ⟨h_bt, h_st, h_fail⟩

/-- Soundness of checkBytes on Typed execution success. -/
theorem checkBytes_typed_ok (raw : ByteArray) (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.typed rawCert payload)))
    (h_git : rawCert.source_pin.git = "a12b7cac05a818cc8d35c2ca440b7170a2807e92")
    (state : Typed.State Party Asset Domain)
    (h_state : stateToTyped? payload.state = some state)
    (post : Typed.ExecutionResult Party Asset Domain)
    (h_exec : Typed.execute (registryToTyped payload.registry) (storeToTyped payload.store)
        payload.ctx.toContext (envToTyped payload.env) payload.now payload.request.toRequest state = .ok post)
    (h_assump : (computeAssumptions rawCert).2 = none)
    (h_claimed : rawCert.claimed_next_state = none) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = .accepted ∧ rep.failure = none ∧ rep.world = executionResultToWorld post payload.state := by
  use checkTyped rawCert payload
  have h_bt := checkBytes_typed raw rawCert payload h_dec
  have ⟨h_st, h_fail, h_w, _, _, _⟩ := checkTyped_execute_ok rawCert payload h_git state h_state post h_exec h_assump h_claimed
  exact ⟨h_bt, h_st, h_fail, h_w⟩

/-- Soundness of checkBytes on Composition step execution refusal. -/
theorem checkBytes_step_error (raw : ByteArray) (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.step cert payload)))
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (fail : Composition.Failure)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .error fail) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = .refused ∧ rep.failure = some (failureToPath fail) := by
  use checkStep cert payload
  have h_bt := checkBytes_step raw cert payload h_dec
  have ⟨h_st, h_fail, _, _, _⟩ := checkStep_step_error cert payload cfg h_cfg pre h_pre step h_step fail h_exec
  exact ⟨h_bt, h_st, h_fail⟩

/-- Soundness of checkBytes on Composition step execution success. -/
theorem checkBytes_step_ok (raw : ByteArray) (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.step cert payload)))
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (pre : World Party Asset Domain)
    (h_pre : payload.pre.toWorld? = some pre)
    (step : Composition.Step Party Asset Domain)
    (h_step : payload.step.toStep? = some step)
    (res : StepResult Party Asset Domain)
    (h_exec : Composition.executeStep cfg (boundaryToTyped payload.boundary) payload.index
        (payload.history.map OutputObservationEnc.toOutputObservation) step pre = .ok res) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.outputs = res.outputs.map OutputObservationEnc.fromOutputObservation ∧ rep.nextIndex = payload.index := by
  use checkStep cert payload
  have h_bt := checkBytes_step raw cert payload h_dec
  have ⟨h_out, h_idx⟩ := checkStep_step_ok cert payload cfg h_cfg pre h_pre step h_step res h_exec
  exact ⟨h_bt, h_out, h_idx⟩

/-- CheckRun cursor failure theorem: when Composition.run cursor fails, checkRun reports refusal and the failure path. -/
theorem checkRun_cursor_fail (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld) :
    let bList := payload.boundaries.map boundaryToTyped
    let defaultBoundary : Composition.Boundary Party Asset Domain :=
      ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
    let boundaries : Nat → Composition.Boundary Party Asset Domain :=
      fun idx ↦ match bList[idx]? with
      | some b => b
      | none => bList.head?.getD defaultBoundary
    let steps : List (Composition.Step Party Asset Domain) :=
      payload.steps.filterMap StepEnc.toStep?
    let cursor := Composition.run cfg boundaries initialWorld steps
    ∀ (lf : LocatedFailure Party Asset Domain),
    cursor.failure = some lf →
    (checkRun cert payload).status = ReportStatus.refused ∧
    (checkRun cert payload).failure = some (failureToPath lf.reason) := by
  intro bList defaultBoundary boundaries steps cursor lf h_fail
  dsimp [checkRun]
  rw [h_cfg]
  dsimp
  rw [h_world]
  dsimp
  have h_cf : (Composition.run cfg (fun idx => match (List.map boundaryToTyped payload.boundaries)[idx]? with | some b => b | none => (List.map boundaryToTyped payload.boundaries).head?.getD { ctx := { principal := Party.alice, domain := Domain.main }, env := fun x => none, now := 100 }) initialWorld (List.filterMap StepEnc.toStep? payload.steps)).failure = some lf := h_fail
  generalize h_fail_expr : (Composition.run cfg (fun idx => match (List.map boundaryToTyped payload.boundaries)[idx]? with | some b => b | none => (List.map boundaryToTyped payload.boundaries).head?.getD { ctx := { principal := Party.alice, domain := Domain.main }, env := fun x => none, now := 100 }) initialWorld (List.filterMap StepEnc.toStep? payload.steps)).failure = f_opt
  rw [h_fail_expr] at h_cf
  cases f_opt with
  | none => contradiction
  | some lf2 =>
    injection h_cf with h_eq
    subst h_eq
    refine ⟨rfl, rfl⟩

/-- CheckRun cursor success theorem: when Composition.run cursor succeeds, checkRun reports acceptance, outputs, and nextIndex. -/
theorem checkRun_cursor_ok (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld) :
    let bList := payload.boundaries.map boundaryToTyped
    let defaultBoundary : Composition.Boundary Party Asset Domain :=
      ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
    let boundaries : Nat → Composition.Boundary Party Asset Domain :=
      fun idx ↦ match bList[idx]? with
      | some b => b
      | none => bList.head?.getD defaultBoundary
    let steps : List (Composition.Step Party Asset Domain) :=
      payload.steps.filterMap StepEnc.toStep?
    let cursor := Composition.run cfg boundaries initialWorld steps
    cursor.failure = none →
    (checkRun cert payload).status = ReportStatus.accepted ∧
    (checkRun cert payload).failure = none ∧
    (checkRun cert payload).outputs = cursor.outputs.map OutputObservationEnc.fromOutputObservation ∧
    (checkRun cert payload).nextIndex = cursor.nextIndex := by
  intro bList defaultBoundary boundaries steps cursor h_succ
  dsimp [checkRun]
  rw [h_cfg]
  dsimp
  rw [h_world]
  dsimp
  have h_cf : (Composition.run cfg (fun idx => match (List.map boundaryToTyped payload.boundaries)[idx]? with | some b => b | none => (List.map boundaryToTyped payload.boundaries).head?.getD { ctx := { principal := Party.alice, domain := Domain.main }, env := fun x => none, now := 100 }) initialWorld (List.filterMap StepEnc.toStep? payload.steps)).failure = none := h_succ
  generalize h_fail_expr : (Composition.run cfg (fun idx => match (List.map boundaryToTyped payload.boundaries)[idx]? with | some b => b | none => (List.map boundaryToTyped payload.boundaries).head?.getD { ctx := { principal := Party.alice, domain := Domain.main }, env := fun x => none, now := 100 }) initialWorld (List.filterMap StepEnc.toStep? payload.steps)).failure = f_opt
  rw [h_fail_expr] at h_cf
  cases f_opt with
  | some lf => contradiction
  | none =>
    dsimp
    refine ⟨rfl, rfl, rfl, ?_⟩
    dsimp [bList, defaultBoundary, boundaries, steps, cursor]
    rfl

/-- Soundness of checkBytes on Composition run failure. -/
theorem checkBytes_run_fail (raw : ByteArray) (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.run cert payload)))
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld)
    (lf : LocatedFailure Party Asset Domain)
    (h_fail : (Composition.run cfg (fun idx ↦ match (payload.boundaries.map boundaryToTyped)[idx]? with | some b => b | none => (payload.boundaries.map boundaryToTyped).head?.getD ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩) initialWorld (payload.steps.filterMap StepEnc.toStep?)).failure = some lf) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = ReportStatus.refused ∧ rep.failure = some (failureToPath lf.reason) := by
  use checkRun cert payload
  have h_bt := checkBytes_run raw cert payload h_dec
  have ⟨h_st, h_f⟩ := checkRun_cursor_fail cert payload cfg h_cfg initialWorld h_world lf h_fail
  exact ⟨h_bt, h_st, h_f⟩

/-- Soundness of checkBytes on Composition run success. -/
theorem checkBytes_run_ok (raw : ByteArray) (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_dec : decodeBytes raw = .ok (.execution (.run cert payload)))
    (cfg : Config Party Asset Domain)
    (h_cfg : configToTyped? payload.config = some cfg)
    (initialWorld : World Party Asset Domain)
    (h_world : payload.world.toWorld? = some initialWorld)
    (h_succ : (Composition.run cfg (fun idx ↦ match (payload.boundaries.map boundaryToTyped)[idx]? with | some b => b | none => (payload.boundaries.map boundaryToTyped).head?.getD ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩) initialWorld (payload.steps.filterMap StepEnc.toStep?)).failure = none) :
    ∃ rep, checkBytes raw = .execution rep ∧ rep.status = ReportStatus.accepted ∧ rep.failure = none ∧ rep.outputs = (Composition.run cfg (fun idx ↦ match (payload.boundaries.map boundaryToTyped)[idx]? with | some b => b | none => (payload.boundaries.map boundaryToTyped).head?.getD ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩) initialWorld (payload.steps.filterMap StepEnc.toStep?)).outputs.map OutputObservationEnc.fromOutputObservation := by
  use checkRun cert payload
  have h_bt := checkBytes_run raw cert payload h_dec
  have ⟨h_st, h_f, h_out, _⟩ := checkRun_cursor_ok cert payload cfg h_cfg initialWorld h_world h_succ
  exact ⟨h_bt, h_st, h_f, h_out⟩

end DefiKernel.Certificates
