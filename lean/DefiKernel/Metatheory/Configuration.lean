import DefiKernel.Composition.Sequence
import DefiKernel.Parallel.Dependency.Adapter

/-! Explicit sufficient configuration premises for exact execution. Types and instances are shared
binders; support is a proposition, not a certificate checker. No execution equality is assumed. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

structure ReferenceSet where
  calls : Set (ComponentId × OperationId)
  operations : Set OperationId

def ReferenceSet.union (a b : ReferenceSet) : ReferenceSet :=
  ⟨a.calls ∪ b.calls, a.operations ∪ b.operations⟩

def SupportedStep {P A D : Type} (refs : ReferenceSet) : Step P A D → Prop
  | .invoke inv => (inv.component, inv.operation) ∈ refs.calls ∧ inv.operation ∈ refs.operations
  | .issue grant => grant.operation ∈ refs.operations
  | .revoke _ => True

def SupportedList {P A D : Type} (refs : ReferenceSet) (steps : List (Step P A D)) : Prop :=
  ∀ step ∈ steps, SupportedStep refs step

def SupportedBranch {P A D : Type} (refs : ReferenceSet) (branch : Branch P A D) : Prop :=
  ∀ inv ∈ branch, SupportedStep refs (.invoke inv)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

structure ConfigAgreement (old new : Config P A D) (refs : ReferenceSet) : Prop where
  old_valid : validateCatalog old.registry old.catalog = true
  new_valid : validateCatalog new.registry new.catalog = true
  registry : ∀ op ∈ refs.operations, old.registry op = new.registry op
  lookup : ∀ component op, (component, op) ∈ refs.calls →
    lookupOperation old.catalog component op = lookupOperation new.catalog component op
  domainAdmin : ∀ domain, old.domainAdmin domain = new.domainAdmin domain

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_nil (refs : ReferenceSet) :
    SupportedList (P := P) (A := A) (D := D) refs [] := by simp [SupportedList]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_cons (refs : ReferenceSet) (step : Step P A D) (steps) :
    SupportedList refs (step :: steps) ↔ SupportedStep refs step ∧ SupportedList refs steps := by
  simp [SupportedList]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_append (refs : ReferenceSet) (a b : List (Step P A D)) :
    SupportedList refs (a ++ b) ↔ SupportedList refs a ∧ SupportedList refs b := by
  simp [SupportedList, or_imp, forall_and]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_nil (refs : ReferenceSet) :
    SupportedBranch (P := P) (A := A) (D := D) refs [] := by simp [SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_cons (refs : ReferenceSet) (inv : Invocation P A D) (tail) :
    SupportedBranch refs (inv :: tail) ↔
      SupportedStep refs (.invoke inv) ∧ SupportedBranch refs tail := by
  simp [SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_map (refs : ReferenceSet) (branch : Branch P A D) :
    SupportedList refs (branch.map Step.invoke) ↔ SupportedBranch refs branch := by
  simp [SupportedList, SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedStep.union_left {refs other : ReferenceSet} {step : Step P A D}
    (h : SupportedStep refs step) : SupportedStep (refs.union other) step := by
  cases step with
  | invoke inv => exact ⟨Or.inl h.1, Or.inl h.2⟩
  | issue grant => exact Or.inl h
  | revoke id => trivial

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedStep.union_right {refs other : ReferenceSet} {step : Step P A D}
    (h : SupportedStep other step) : SupportedStep (refs.union other) step := by
  cases step with
  | invoke inv => exact ⟨Or.inr h.1, Or.inr h.2⟩
  | issue grant => exact Or.inr h
  | revoke id => trivial

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedList.union_left {refs other : ReferenceSet} {steps : List (Step P A D)}
    (h : SupportedList refs steps) : SupportedList (refs.union other) steps :=
  fun step hs ↦ (h step hs).union_left

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedList.union_right {refs other : ReferenceSet} {steps : List (Step P A D)}
    (h : SupportedList other steps) : SupportedList (refs.union other) steps :=
  fun step hs ↦ (h step hs).union_right

theorem ConfigAgreement.refl (cfg : Config P A D) (refs : ReferenceSet)
    (valid : validateCatalog cfg.registry cfg.catalog = true) : ConfigAgreement cfg cfg refs :=
  ⟨valid, valid, fun _ _ ↦ rfl, fun _ _ _ ↦ rfl, fun _ ↦ rfl⟩

theorem ConfigAgreement.symm {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) : ConfigAgreement new old refs :=
  ⟨h.new_valid, h.old_valid, fun op ho ↦ (h.registry op ho).symm,
    fun c op ho ↦ (h.lookup c op ho).symm, fun d ↦ (h.domainAdmin d).symm⟩

theorem ConfigAgreement.trans {a b c : Config P A D} {refs : ReferenceSet}
    (hab : ConfigAgreement a b refs) (hbc : ConfigAgreement b c refs) :
    ConfigAgreement a c refs :=
  ⟨hab.old_valid, hbc.new_valid, fun op ho ↦ (hab.registry op ho).trans (hbc.registry op ho),
    fun c op ho ↦ (hab.lookup c op ho).trans (hbc.lookup c op ho),
    fun d ↦ (hab.domainAdmin d).trans (hbc.domainAdmin d)⟩

theorem ConfigAgreement.union {old new : Config P A D} {a b : ReferenceSet}
    (ha : ConfigAgreement old new a) (hb : ConfigAgreement old new b) :
    ConfigAgreement old new (a.union b) := by
  refine ⟨ha.old_valid, ha.new_valid, ?_, ?_, ha.domainAdmin⟩
  · intro op ho
    exact ho.elim (ha.registry op) (hb.registry op)
  · intro c op ho
    exact ho.elim (ha.lookup c op) (hb.lookup c op)

theorem ConfigAgreement.restrict {old new : Config P A D} {a b : ReferenceSet}
    (h : ConfigAgreement old new b) (calls : a.calls ⊆ b.calls)
    (operations : a.operations ⊆ b.operations) : ConfigAgreement old new a :=
  ⟨h.old_valid, h.new_valid, fun op ho ↦ h.registry op (operations ho),
    fun c op ho ↦ h.lookup c op (calls ho), h.domainAdmin⟩

theorem prepareInvocation_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D)
    (supported : SupportedStep refs (.invoke inv)) :
    prepareInvocation old boundary index history inv =
      prepareInvocation new boundary index history inv := by
  unfold prepareInvocation
  rw [h.lookup inv.component inv.operation supported.1, h.registry inv.operation supported.2]

theorem issueCapability_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (ctx : InvocationContext P D)
    (store : CapabilityStore P A D) (grant : Grant P A D)
    (supported : SupportedStep refs (.issue grant)) :
    issueCapability old.authority ctx store grant =
      issueCapability new.authority ctx store grant := by
  simp only [issueCapability, isDomainAdmin, Config.authority, registryAuthorityConfig,
    h.domainAdmin, h.registry grant.operation supported]
  rfl

theorem revokeCapability_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (ctx : InvocationContext P D)
    (store : CapabilityStore P A D) (id : CapabilityId) :
    revokeCapability old.authority ctx store id = revokeCapability new.authority ctx store id := by
  simp only [revokeCapability, isDomainAdmin, Config.authority, registryAuthorityConfig,
    h.domainAdmin]
  rfl

variable [Fintype P] [Fintype A] [Fintype D]

theorem typed_execute_registry_eq (old new : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat) (request : Request P A D)
    (state : State P A D) (h : old request.operation = new request.operation) :
    Typed.execute old store ctx env now request state =
      Typed.execute new store ctx env now request state := by
  unfold Typed.execute
  rw [h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem extractReceipt_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D)
    (supported : request.operation ∈ refs.operations) :
    extractReceipt old boundary request pre = extractReceipt new boundary request pre := by
  unfold extractReceipt
  rw [h.registry request.operation supported]

/-- Equality follows every actual branch, including preparation, extraction and admin refusals. -/
theorem executeStep_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (supported : SupportedStep refs step) :
    executeStep old boundary index history step pre =
      executeStep new boundary index history step pre := by
  cases step with
  | invoke inv =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind]
    rw [prepareInvocation_config_eq h boundary index history inv supported]
    cases hp : prepareInvocation new boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      have hop :=
        (Parallel.prepareInvocation_shape new boundary index history inv iface request hp).1
      have hs : request.operation ∈ refs.operations := hop ▸ supported.2
      simp only []
      rw [typed_execute_registry_eq old.registry new.registry pre.capabilities boundary.ctx
        boundary.env boundary.now request pre.state (h.registry request.operation hs)]
      rw [extractReceipt_config_eq h boundary request pre hs]
  | issue grant =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind, issueCapability_config_eq h boundary.ctx pre.capabilities grant
        supported]
  | revoke id =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind, revokeCapability_config_eq h boundary.ctx pre.capabilities id]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem startCursor_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (world : World P A D) :
    startCursor old world = startCursor new world := by
  simp only [startCursor, h.old_valid, h.new_valid]

theorem advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (supported : SupportedStep refs step) :
    Composition.advance old boundaries cursor step =
      Composition.advance new boundaries cursor step := by
  unfold Composition.advance
  rw [executeStep_config_eq h (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
    step cursor.world supported]

theorem continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (supported : SupportedList refs steps) :
    Composition.continueRun old boundaries cursor steps =
      Composition.continueRun new boundaries cursor steps := by
  induction steps generalizing cursor with
  | nil => rfl
  | cons step steps ih =>
    obtain ⟨head, tail⟩ := (supportedList_cons refs step steps).mp supported
    simpa only [Composition.continueRun, List.foldl_cons,
      advance_config_eq h boundaries cursor step head] using
        ih (Composition.advance new boundaries cursor step) tail

theorem run_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (supported : SupportedList refs steps) :
    Composition.run old boundaries world steps = Composition.run new boundaries world steps := by
  unfold Composition.run
  rw [startCursor_config_eq h, continueRun_config_eq h boundaries _ steps supported]

end DefiKernel.Metatheory
