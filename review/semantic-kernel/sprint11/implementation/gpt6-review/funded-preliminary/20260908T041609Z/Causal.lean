import DefiKernel.Nary.CausalRuntime

/-! Generic causal prefix evidence over the actual monitored dispatcher. Replay constructors
require base `AdvanceSound` transitions and the exact appended attempt (none / error /
success). Erasure and fixed-parameter shared-prefix equalities reuse the core lemmas.
Joint-invariant obligations are named separately so a later funded witness can discharge
them independently. This module does not instantiate a concrete funded F10 proof, assume
future success, or conclude a whole run. Arbitrary `B` needs `DecidableEq` only; `Q` is an
arbitrary `Type`. Captured constants inside `update` are outside the shared-prefix equality. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]
variable {Q : Type}

/-- Actual monitor payload: selected participant, trusted current boundary, pre/post machines,
and the newly appended attempt option (`none` on skip). -/
def monitorPayload (boundaries : Boundaries B P A D) (pre : Machine B P A D) (b : B)
    (post : Machine B P A D) : MonitorInput B P A D :=
  { participant := b
    boundary := boundaries b (pre.locals b).nextIndex
    before := pre
    after := post
    attempt := post.attempts[pre.attempts.length]? }

def skippedToken (branches : Branches B P A D) (m : Machine B P A D) (b : B) : Prop :=
  (m.locals b).failure.isSome = true ∨
    ((m.locals b).failure = none ∧ (branches b)[(m.locals b).consumed]? = none)

abbrev JointInvariant (Q B P A D : Type) := Q → Machine B P A D → Prop
abbrev AssumptionFamily (B Q P A D : Type) := B → Q → Machine B P A D → Prop
abbrev ExternalFamily (B Q P A D : Type) := B → Q → Machine B P A D → Prop

/-- Current `K` implies every participant ledger invariant at the current world.
Predicate/relation binders use `State → Prop` directly so this module does not
redeclare Interference's `LedgerPredicate` / `LedgerRelation` names. -/
def InvariantDerivation (K : JointInvariant Q B P A D)
    (invariant : B → State P A D → Prop) : Prop :=
  ∀ q m, K q m → ∀ b, invariant b m.world.state

/-- Named present external premise, together with current `K`, yields the selected assumption.
The premise is current-pair data; it is not inferred from a desired future success. -/
def AssumptionDerivation (K : JointInvariant Q B P A D)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D) : Prop :=
  ∀ q m b, K q m → external b q m → assumption b q m

/-- If a present external premise is required at every prefix where `K` holds, it is stated
here. An instance may use `True` when no extra current fact is needed. -/
def PresentExternal (K : JointInvariant Q B P A D)
    (external : ExternalFamily B Q P A D) : Prop :=
  ∀ q m b, K q m → external b q m

/-- Selected actual-success local guarantee: own invariant and guarantee from the current
invariant, the derived assumption, and an actual `executeStep = .ok` equation. -/
def SelectedSuccessGuarantee (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (invariant : B → State P A D → Prop)
    (guarantee : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) : Prop :=
  ∀ (b : B) (q : Q) (m : Machine B P A D) (inv : Invocation P A D)
      (result : StepResult P A D),
    (m.locals b).failure = none →
    (branches b)[(m.locals b).consumed]? = some inv →
    executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result →
    invariant b m.world.state →
    assumption b q m →
    invariant b result.world.state ∧ guarantee b m.world.state result.world.state

def GuaranteeInclusion (guarantee rely : B → State P A D → State P A D → Prop) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def RelyStable (invariant : B → State P A D → Prop)
    (rely : B → State P A D → State P A D → Prop) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

/-- Skip (halted or exhausted) preserves `K` under the actual monitor update with `none`. -/
def SkipUpdateObligation (_cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (K : JointInvariant Q B P A D) : Prop :=
  ∀ (q : Q) (m : Machine B P A D) (b : B),
    skippedToken branches m b →
    K q m →
    K (update q {
        participant := b
        boundary := boundaries b (m.locals b).nextIndex
        before := m
        after := m.skip b
        attempt := none }) (m.skip b)

/-- Refusal preserves `K` under the actual monitor update with the appended error attempt.
World identity is part of `Machine.refuse`; no successful guarantee is invented. -/
def RefusalUpdateObligation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (K : JointInvariant Q B P A D) : Prop :=
  ∀ (q : Q) (m : Machine B P A D) (b : B) (inv : Invocation P A D)
      (reason : Composition.Failure),
    (m.locals b).failure = none →
    (branches b)[(m.locals b).consumed]? = some inv →
    executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .error reason →
    K q m →
    K (update q {
        participant := b
        boundary := boundaries b (m.locals b).nextIndex
        before := m
        after := m.refuse b inv reason
        attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩
      }) (m.refuse b inv reason)

/-- After an actual successful selected step, the monitor update reestablishes `K`. Premises
include the derived assumption, own guarantee, and all post-state invariants. The desired
final `K` is a conclusion of this obligation, not an input of the generic rule. -/
def SuccessUpdateObligation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) : Prop :=
  ∀ (q : Q) (m : Machine B P A D) (b : B) (inv : Invocation P A D)
      (result : StepResult P A D),
    (m.locals b).failure = none →
    (branches b)[(m.locals b).consumed]? = some inv →
    executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result →
    K q m →
    assumption b q m →
    guarantee b m.world.state result.world.state →
    (∀ own, invariant own result.world.state) →
    K (update q {
        participant := b
        boundary := boundaries b (m.locals b).nextIndex
        before := m
        after := m.accept b inv result
        attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩
      }) (m.accept b inv result)

/-- Inductive monitored replay. Each cons constructor requires the actual base transition
and the exact appended attempt supplied to `update`. -/
inductive Replay (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q) :
    Q × Machine B P A D → Schedule B → Q × Machine B P A D → Prop
  | done (entry : Q × Machine B P A D) :
      Replay cfg boundaries branches update entry [] entry
  | skip {q : Q} {m : Machine B P A D} {q' : Q} {rest : Schedule B}
      {final : Q × Machine B P A D} (b : B)
      (base : AdvanceSound cfg boundaries branches m b (m.skip b))
      (none_attempt : (m.skip b).attempts[m.attempts.length]? = none)
      (updated : q' = update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.skip b
          attempt := none })
      (tail : Replay cfg boundaries branches update (q', m.skip b) rest final) :
      Replay cfg boundaries branches update (q, m) (b :: rest) final
  | refuse {q : Q} {m : Machine B P A D} {q' : Q} {rest : Schedule B}
      {final : Q × Machine B P A D} (b : B) (inv : Invocation P A D)
      (reason : Composition.Failure)
      (base : AdvanceSound cfg boundaries branches m b (m.refuse b inv reason))
      (error_attempt : (m.refuse b inv reason).attempts[m.attempts.length]? =
        some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩)
      (updated : q' = update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.refuse b inv reason
          attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩ })
      (tail : Replay cfg boundaries branches update (q', m.refuse b inv reason) rest final) :
      Replay cfg boundaries branches update (q, m) (b :: rest) final
  | accept {q : Q} {m : Machine B P A D} {q' : Q} {rest : Schedule B}
      {final : Q × Machine B P A D} (b : B) (inv : Invocation P A D)
      (result : StepResult P A D)
      (base : AdvanceSound cfg boundaries branches m b (m.accept b inv result))
      (ok_attempt : (m.accept b inv result).attempts[m.attempts.length]? =
        some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩)
      (updated : q' = update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.accept b inv result
          attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩ })
      (tail : Replay cfg boundaries branches update (q', m.accept b inv result) rest final) :
      Replay cfg boundaries branches update (q, m) (b :: rest) final

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem monitorPayload_attempt (boundaries : Boundaries B P A D)
    (pre : Machine B P A D) (b : B) (post : Machine B P A D) :
    (monitorPayload boundaries pre b post).attempt = post.attempts[pre.attempts.length]? :=
  rfl

theorem advanceMonitored_spec (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (q : Q) (m : Machine B P A D) (b : B) :
    advanceMonitored cfg boundaries branches update (q, m) b =
      (update q (monitorPayload boundaries m b (advance cfg boundaries branches m b)),
        advance cfg boundaries branches m b) :=
  rfl

theorem advanceMonitored_spec_entry (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (b : B) :
    advanceMonitored cfg boundaries branches update entry b =
      (update entry.1
        (monitorPayload boundaries entry.2 b (advance cfg boundaries branches entry.2 b)),
        advance cfg boundaries branches entry.2 b) :=
  rfl

theorem advance_eq_skip_of_isSome (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B)
    (h : (m.locals b).failure.isSome = true) :
    advance cfg boundaries branches m b = m.skip b := by
  simp only [advance, h, ite_true]

theorem advance_eq_skip_of_absent (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B)
    (active : (m.locals b).failure = none)
    (absent : (branches b)[(m.locals b).consumed]? = none) :
    advance cfg boundaries branches m b = m.skip b := by
  have hnone : (m.locals b).failure.isSome = false := by simp [active]
  simp only [advance, hnone, absent, Bool.false_eq_true, ite_false]

theorem advance_eq_refuse (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B)
    (inv : Invocation P A D) (reason : Composition.Failure)
    (active : (m.locals b).failure = none)
    (selected : (branches b)[(m.locals b).consumed]? = some inv)
    (rejected : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .error reason) :
    advance cfg boundaries branches m b = m.refuse b inv reason := by
  have hnone : (m.locals b).failure.isSome = false := by simp [active]
  simp only [advance, hnone, selected, rejected, Bool.false_eq_true, ite_false]

theorem advance_eq_accept (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (b : B)
    (inv : Invocation P A D) (result : StepResult P A D)
    (active : (m.locals b).failure = none)
    (selected : (branches b)[(m.locals b).consumed]? = some inv)
    (executed : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result) :
    advance cfg boundaries branches m b = m.accept b inv result := by
  have hnone : (m.locals b).failure.isSome = false := by simp [active]
  simp only [advance, hnone, selected, executed, Bool.false_eq_true, ite_false]

theorem AdvanceSound.eq_advance {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) :
    post = advance cfg boundaries branches m b := by
  cases h with
  | halted failure failed =>
    exact (advance_eq_skip_of_isSome cfg boundaries branches m b (by simp [failed])).symm
  | exhausted active absent =>
    exact (advance_eq_skip_of_absent cfg boundaries branches m b active absent).symm
  | refused inv reason active selected rejected =>
    exact (advance_eq_refuse cfg boundaries branches m b inv reason active selected
      rejected).symm
  | accepted inv result active selected executed =>
    exact (advance_eq_accept cfg boundaries branches m b inv result active selected
      executed).symm

/-- Appended attempt is `none` on skip, an error attempt on refusal, or a successful attempt
on accept, matching the actual `advance` equations. -/
theorem AdvanceSound.appended_option {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) :
    (post = m.skip b ∧ post.attempts[m.attempts.length]? = none ∧
      post.attempts = m.attempts) ∨
    (∃ inv reason,
      (m.locals b).failure = none ∧
      (branches b)[(m.locals b).consumed]? = some inv ∧
      executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
        (m.locals b).outputs (.invoke inv) m.world = .error reason ∧
      post = m.refuse b inv reason ∧
      post.attempts[m.attempts.length]? =
        some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩) ∨
    (∃ inv result,
      (m.locals b).failure = none ∧
      (branches b)[(m.locals b).consumed]? = some inv ∧
      executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
        (m.locals b).outputs (.invoke inv) m.world = .ok result ∧
      post = m.accept b inv result ∧
      post.attempts[m.attempts.length]? =
        some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩) := by
  cases h with
  | halted =>
    exact Or.inl ⟨rfl, skip_appended_none m b, skip_attempts m b⟩
  | exhausted =>
    exact Or.inl ⟨rfl, skip_appended_none m b, skip_attempts m b⟩
  | refused inv reason active selected rejected =>
    exact Or.inr (Or.inl ⟨inv, reason, active, selected, rejected, rfl,
      refuse_appended m b inv reason⟩)
  | accepted inv result active selected executed =>
    exact Or.inr (Or.inr ⟨inv, result, active, selected, executed, rfl,
      accept_appended m b inv result⟩)

theorem advanceMonitored_skip (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (q : Q) (m : Machine B P A D) (b : B)
    (hadv : advance cfg boundaries branches m b = m.skip b) :
    advanceMonitored cfg boundaries branches update (q, m) b =
      (update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.skip b
          attempt := none }, m.skip b) := by
  rw [advanceMonitored_spec, hadv]
  simp only [monitorPayload, skip_appended_none]

theorem advanceMonitored_refuse (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (q : Q) (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure)
    (hadv : advance cfg boundaries branches m b = m.refuse b inv reason) :
    advanceMonitored cfg boundaries branches update (q, m) b =
      (update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.refuse b inv reason
          attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩ },
        m.refuse b inv reason) := by
  rw [advanceMonitored_spec, hadv]
  simp only [monitorPayload, refuse_appended]

theorem advanceMonitored_accept (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (q : Q) (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D)
    (hadv : advance cfg boundaries branches m b = m.accept b inv result) :
    advanceMonitored cfg boundaries branches update (q, m) b =
      (update q {
          participant := b
          boundary := boundaries b (m.locals b).nextIndex
          before := m
          after := m.accept b inv result
          attempt := some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩ },
        m.accept b inv result) := by
  rw [advanceMonitored_spec, hadv]
  simp only [monitorPayload, accept_appended]

theorem continueMonitored_replay (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (schedule : Schedule B) :
    Replay cfg boundaries branches update entry schedule
      (continueMonitored cfg boundaries branches update entry schedule) := by
  induction schedule generalizing entry with
  | nil =>
    rw [continueMonitored_nil]
    exact Replay.done entry
  | cons b rest ih =>
    rw [continueMonitored_cons]
    rcases entry with ⟨q, m⟩
    generalize hpost : advance cfg boundaries branches m b = post
    have step : AdvanceSound cfg boundaries branches m b post := by
      simpa [hpost] using advance_sound cfg boundaries branches m b
    cases step with
    | halted failure failed =>
      rw [advanceMonitored_skip cfg boundaries branches update q m b hpost]
      exact Replay.skip b (AdvanceSound.halted failure failed) (skip_appended_none m b) rfl
        (ih _)
    | exhausted active absent =>
      rw [advanceMonitored_skip cfg boundaries branches update q m b hpost]
      exact Replay.skip b (AdvanceSound.exhausted active absent) (skip_appended_none m b) rfl
        (ih _)
    | refused inv reason active selected rejected =>
      rw [advanceMonitored_refuse cfg boundaries branches update q m b inv reason hpost]
      exact Replay.refuse b inv reason
        (AdvanceSound.refused inv reason active selected rejected)
        (refuse_appended m b inv reason) rfl (ih _)
    | accepted inv result active selected executed =>
      rw [advanceMonitored_accept cfg boundaries branches update q m b inv result hpost]
      exact Replay.accept b inv result
        (AdvanceSound.accepted inv result active selected executed)
        (accept_appended m b inv result) rfl (ih _)

theorem Replay.eq_continueMonitored {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {update : Q → MonitorInput B P A D → Q}
    {entry : Q × Machine B P A D} {schedule : Schedule B}
    {result : Q × Machine B P A D}
    (h : Replay cfg boundaries branches update entry schedule result) :
    result = continueMonitored cfg boundaries branches update entry schedule := by
  induction h with
  | done entry =>
    rw [continueMonitored_nil]
  | @skip q m q' rest final b base none_attempt updated tail ih =>
    have hadv : advance cfg boundaries branches m b = m.skip b :=
      (AdvanceSound.eq_advance base).symm
    rw [continueMonitored_cons, advanceMonitored_skip cfg boundaries branches update q m b hadv,
      ← updated, ih]
  | @refuse q m q' rest final b inv reason base error_attempt updated tail ih =>
    have hadv : advance cfg boundaries branches m b = m.refuse b inv reason :=
      (AdvanceSound.eq_advance base).symm
    rw [continueMonitored_cons,
      advanceMonitored_refuse cfg boundaries branches update q m b inv reason hadv, ← updated, ih]
  | @accept q m q' rest final b inv result' base ok_attempt updated tail ih =>
    have hadv : advance cfg boundaries branches m b = m.accept b inv result' :=
      (AdvanceSound.eq_advance base).symm
    rw [continueMonitored_cons,
      advanceMonitored_accept cfg boundaries branches update q m b inv result' hadv, ← updated, ih]

theorem Replay.erase {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {update : Q → MonitorInput B P A D → Q}
    {entry : Q × Machine B P A D} {schedule : Schedule B}
    {result : Q × Machine B P A D}
    (h : Replay cfg boundaries branches update entry schedule result) :
    result.2 = continueRun cfg boundaries branches entry.2 schedule := by
  rw [h.eq_continueMonitored, continueMonitored_erase]

theorem continueMonitored_erase_start (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (q0 : Q) (initial : World P A D)
    (schedule : Schedule B) :
    (continueMonitored cfg boundaries branches update (q0, start initial) schedule).2 =
      runPrefix cfg boundaries initial branches schedule :=
  continueMonitored_erase cfg boundaries branches update (q0, start initial) schedule

/-- After exactly `preTokens.length` tokens of `preTokens ++ suffix`, the monitored pair
equals the continuation of `preTokens` alone. Captured constants inside `update` are
outside this equality. Changing `update` or supplying an externally prescient initial
monitor changes the premises. -/
theorem continueMonitored_fixed_parameter_shared_prefix (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (preTokens suffix₁ suffix₂ : Schedule B) :
    continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₁).take preTokens.length) =
      continueMonitored cfg boundaries branches update entry preTokens ∧
    continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₂).take preTokens.length) =
      continueMonitored cfg boundaries branches update entry preTokens ∧
    continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₁).take preTokens.length) =
      continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₂).take preTokens.length) :=
  ⟨continueMonitored_take_eq cfg boundaries branches update entry preTokens suffix₁,
    continueMonitored_take_eq cfg boundaries branches update entry preTokens suffix₂,
    continueMonitored_take_prefix cfg boundaries branches update entry preTokens
      suffix₁ suffix₂⟩

theorem continueMonitored_append_erase (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (s t : Schedule B) :
    (continueMonitored cfg boundaries branches update entry (s ++ t)).2 =
      continueRun cfg boundaries branches
        (continueMonitored cfg boundaries branches update entry s).2 t := by
  rw [continueMonitored_append, continueMonitored_erase, continueMonitored_erase]

private theorem skipped_of_halted {m : Machine B P A D} {b : B}
    {failure : LocatedFailure P A D} (failed : (m.locals b).failure = some failure)
    (branches : Branches B P A D) : skippedToken branches m b :=
  Or.inl (by simp [failed])

private theorem skipped_of_exhausted {branches : Branches B P A D}
    {m : Machine B P A D} {b : B}
    (active : (m.locals b).failure = none)
    (absent : (branches b)[(m.locals b).consumed]? = none) :
    skippedToken branches m b :=
  Or.inr ⟨active, absent⟩

theorem joint_advanceMonitored (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee rely : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D)
    (derivesInvariants : InvariantDerivation K invariant)
    (derivesAssumption : AssumptionDerivation K assumption external)
    (presentExternal : PresentExternal K external)
    (selectedSuccess : SelectedSuccessGuarantee (Q := Q) cfg boundaries branches
      invariant guarantee assumption)
    (guaranteeInclusion : GuaranteeInclusion guarantee rely)
    (relyStable : RelyStable invariant rely)
    (skipUpdate : SkipUpdateObligation cfg boundaries branches update K)
    (refusalUpdate : RefusalUpdateObligation cfg boundaries branches update K)
    (successUpdate : SuccessUpdateObligation (Q := Q) cfg boundaries branches update K
      invariant guarantee assumption)
    (entry : Q × Machine B P A D) (hk : K entry.1 entry.2) (b : B) :
    K (advanceMonitored cfg boundaries branches update entry b).1
      (advanceMonitored cfg boundaries branches update entry b).2 ∧
    ∀ own, invariant own
      (advanceMonitored cfg boundaries branches update entry b).2.world.state := by
  rcases entry with ⟨q, m⟩
  generalize hpost : advance cfg boundaries branches m b = post
  have step : AdvanceSound cfg boundaries branches m b post := by
    simpa [hpost] using advance_sound cfg boundaries branches m b
  cases step with
  | halted failure failed =>
    rw [advanceMonitored_skip cfg boundaries branches update q m b hpost]
    refine ⟨skipUpdate q m b (skipped_of_halted failed branches) hk, ?_⟩
    intro own
    simpa [skip_world] using derivesInvariants q m hk own
  | exhausted active absent =>
    rw [advanceMonitored_skip cfg boundaries branches update q m b hpost]
    refine ⟨skipUpdate q m b (skipped_of_exhausted (branches := branches) active absent) hk, ?_⟩
    intro own
    simpa [skip_world] using derivesInvariants q m hk own
  | refused inv reason active selected rejected =>
    rw [advanceMonitored_refuse cfg boundaries branches update q m b inv reason hpost]
    refine ⟨refusalUpdate q m b inv reason active selected rejected hk, ?_⟩
    intro own
    simpa [refuse_world] using derivesInvariants q m hk own
  | accepted inv result active selected executed =>
    rw [advanceMonitored_accept cfg boundaries branches update q m b inv result hpost]
    have Ipre := derivesInvariants q m hk
    have A := derivesAssumption q m b hk (presentExternal q m b hk)
    have own := selectedSuccess b q m inv result active selected executed (Ipre b) A
    have invs : ∀ other, invariant other result.world.state := by
      intro other
      by_cases same : b = other
      · subst other
        exact own.1
      · exact relyStable other _ _ (Ipre other)
          (guaranteeInclusion b other same _ _ own.2)
    refine ⟨successUpdate q m b inv result active selected executed hk A own.2 invs, ?_⟩
    intro other
    simpa [accept_world] using invs other

/-- Generic initialized finite-prefix rule. Premises are the named obligations, not an
opaque “every transition preserves `K`” fact and not a whole-run or future-success claim.
Enabledness/progress is a separate theorem when claimed. An arbitrary `update` need not
satisfy these obligations. -/
theorem continueMonitored_initialized (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee rely : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D)
    (initialized : K entry.1 entry.2)
    (derivesInvariants : InvariantDerivation K invariant)
    (derivesAssumption : AssumptionDerivation K assumption external)
    (presentExternal : PresentExternal K external)
    (selectedSuccess : SelectedSuccessGuarantee (Q := Q) cfg boundaries branches
      invariant guarantee assumption)
    (guaranteeInclusion : GuaranteeInclusion guarantee rely)
    (relyStable : RelyStable invariant rely)
    (skipUpdate : SkipUpdateObligation cfg boundaries branches update K)
    (refusalUpdate : RefusalUpdateObligation cfg boundaries branches update K)
    (successUpdate : SuccessUpdateObligation (Q := Q) cfg boundaries branches update K
      invariant guarantee assumption)
    (schedule : Schedule B) :
    K (continueMonitored cfg boundaries branches update entry schedule).1
      (continueMonitored cfg boundaries branches update entry schedule).2 ∧
    ∀ b, invariant b
      (continueMonitored cfg boundaries branches update entry schedule).2.world.state := by
  induction schedule generalizing entry with
  | nil =>
    exact ⟨initialized, derivesInvariants entry.1 entry.2 initialized⟩
  | cons b rest ih =>
    rw [continueMonitored_cons]
    exact ih (advanceMonitored cfg boundaries branches update entry b)
      (joint_advanceMonitored cfg boundaries branches update K invariant guarantee rely
        assumption external derivesInvariants derivesAssumption presentExternal
        selectedSuccess guaranteeInclusion relyStable skipUpdate refusalUpdate
        successUpdate entry initialized b).1

theorem continueMonitored_every_prefix (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee rely : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D)
    (initialized : K entry.1 entry.2)
    (derivesInvariants : InvariantDerivation K invariant)
    (derivesAssumption : AssumptionDerivation K assumption external)
    (presentExternal : PresentExternal K external)
    (selectedSuccess : SelectedSuccessGuarantee (Q := Q) cfg boundaries branches
      invariant guarantee assumption)
    (guaranteeInclusion : GuaranteeInclusion guarantee rely)
    (relyStable : RelyStable invariant rely)
    (skipUpdate : SkipUpdateObligation cfg boundaries branches update K)
    (refusalUpdate : RefusalUpdateObligation cfg boundaries branches update K)
    (successUpdate : SuccessUpdateObligation (Q := Q) cfg boundaries branches update K
      invariant guarantee assumption)
    (schedule : Schedule B) (length : Nat) :
    K (continueMonitored cfg boundaries branches update entry
        (schedule.take length)).1
      (continueMonitored cfg boundaries branches update entry
        (schedule.take length)).2 ∧
    ∀ b, invariant b
      (continueMonitored cfg boundaries branches update entry
        (schedule.take length)).2.world.state :=
  continueMonitored_initialized cfg boundaries branches update entry K invariant
    guarantee rely assumption external initialized derivesInvariants derivesAssumption
    presentExternal selectedSuccess guaranteeInclusion relyStable skipUpdate
    refusalUpdate successUpdate (schedule.take length)

theorem continueMonitored_start_initialized (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (q0 : Q) (initial : World P A D)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee rely : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D)
    (initialized : K q0 (start initial))
    (derivesInvariants : InvariantDerivation K invariant)
    (derivesAssumption : AssumptionDerivation K assumption external)
    (presentExternal : PresentExternal K external)
    (selectedSuccess : SelectedSuccessGuarantee (Q := Q) cfg boundaries branches
      invariant guarantee assumption)
    (guaranteeInclusion : GuaranteeInclusion guarantee rely)
    (relyStable : RelyStable invariant rely)
    (skipUpdate : SkipUpdateObligation cfg boundaries branches update K)
    (refusalUpdate : RefusalUpdateObligation cfg boundaries branches update K)
    (successUpdate : SuccessUpdateObligation (Q := Q) cfg boundaries branches update K
      invariant guarantee assumption)
    (schedule : Schedule B) :
    K (continueMonitored cfg boundaries branches update (q0, start initial)
        schedule).1
      (continueMonitored cfg boundaries branches update (q0, start initial)
        schedule).2 ∧
    ∀ b, invariant b
      (continueMonitored cfg boundaries branches update (q0, start initial)
        schedule).2.world.state :=
  continueMonitored_initialized cfg boundaries branches update (q0, start initial) K
    invariant guarantee rely assumption external initialized derivesInvariants
    derivesAssumption presentExternal selectedSuccess guaranteeInclusion relyStable
    skipUpdate refusalUpdate successUpdate schedule

/-- Derived one-step `K` preservation. This is a consequence of the named obligations,
not a permitted substitute for them as the only causal result. -/
theorem derived_monitor_step_preserves (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (K : JointInvariant Q B P A D) (invariant : B → State P A D → Prop)
    (guarantee rely : B → State P A D → State P A D → Prop)
    (assumption : AssumptionFamily B Q P A D) (external : ExternalFamily B Q P A D)
    (hk : K entry.1 entry.2)
    (derivesInvariants : InvariantDerivation K invariant)
    (derivesAssumption : AssumptionDerivation K assumption external)
    (presentExternal : PresentExternal K external)
    (selectedSuccess : SelectedSuccessGuarantee (Q := Q) cfg boundaries branches
      invariant guarantee assumption)
    (guaranteeInclusion : GuaranteeInclusion guarantee rely)
    (relyStable : RelyStable invariant rely)
    (skipUpdate : SkipUpdateObligation cfg boundaries branches update K)
    (refusalUpdate : RefusalUpdateObligation cfg boundaries branches update K)
    (successUpdate : SuccessUpdateObligation (Q := Q) cfg boundaries branches update K
      invariant guarantee assumption)
    (b : B) :
    K (advanceMonitored cfg boundaries branches update entry b).1
      (advanceMonitored cfg boundaries branches update entry b).2 :=
  (joint_advanceMonitored cfg boundaries branches update K invariant guarantee rely
    assumption external derivesInvariants derivesAssumption presentExternal
    selectedSuccess guaranteeInclusion relyStable skipUpdate refusalUpdate
    successUpdate entry hk b).1

end DefiKernel.Nary
