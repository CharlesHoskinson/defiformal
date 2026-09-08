import DefiKernel.Nary.Execution

/-! Separate executable monitor over actual prefix dispatcher data. Monitor state never
controls admission, executeStep, scheduling or financial publication. Skip supplies none
and does not replay a prior attempt; the fold carries the entire accumulated pair. -/
namespace DefiKernel.Nary
open Typed Composition

structure MonitorInput (B P A D : Type) where
  participant : B
  boundary : Boundary P A D
  before : Machine B P A D
  after : Machine B P A D
  attempt : Option (Attempt B P A D)

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]
variable {Q : Type}

def advanceMonitored (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (b : B) : Q × Machine B P A D :=
  let pre := entry.2
  let post := advance cfg boundaries branches pre b
  let appended := post.attempts[pre.attempts.length]?
  (update entry.1
    { participant := b
      boundary := boundaries b (pre.locals b).nextIndex
      before := pre
      after := post
      attempt := appended }, post)

def continueMonitored (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (schedule : Schedule B) : Q × Machine B P A D :=
  schedule.foldl (fun current b ↦ advanceMonitored cfg boundaries branches update current b) entry

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem advanceMonitored_erase (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (b : B) :
    (advanceMonitored cfg boundaries branches update entry b).2 =
      advance cfg boundaries branches entry.2 b :=
  rfl

theorem continueMonitored_nil (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) :
    continueMonitored cfg boundaries branches update entry [] = entry :=
  rfl

theorem continueMonitored_cons (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (b : B) (rest : Schedule B) :
    continueMonitored cfg boundaries branches update entry (b :: rest) =
      continueMonitored cfg boundaries branches update
        (advanceMonitored cfg boundaries branches update entry b) rest :=
  rfl

theorem continueMonitored_append (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (s t : Schedule B) :
    continueMonitored cfg boundaries branches update entry (s ++ t) =
      continueMonitored cfg boundaries branches update
        (continueMonitored cfg boundaries branches update entry s) t :=
  List.foldl_append

theorem continueMonitored_erase (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (update : Q → MonitorInput B P A D → Q)
    (entry : Q × Machine B P A D) (schedule : Schedule B) :
    (continueMonitored cfg boundaries branches update entry schedule).2 =
      continueRun cfg boundaries branches entry.2 schedule := by
  induction schedule generalizing entry with
  | nil => rfl
  | cons b rest ih =>
    rw [continueMonitored_cons, continueRun_cons, ih, advanceMonitored_erase]

/-- Append decomposition helper. This is not the common-prefix observation equality. -/
theorem continueMonitored_common_prefix (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (preTokens suffix₁ suffix₂ : Schedule B) :
    continueMonitored cfg boundaries branches update
        (continueMonitored cfg boundaries branches update entry preTokens) suffix₁ =
      continueMonitored cfg boundaries branches update entry (preTokens ++ suffix₁) ∧
    continueMonitored cfg boundaries branches update
        (continueMonitored cfg boundaries branches update entry preTokens) suffix₂ =
      continueMonitored cfg boundaries branches update entry (preTokens ++ suffix₂) :=
  ⟨(continueMonitored_append cfg boundaries branches update entry preTokens suffix₁).symm,
    (continueMonitored_append cfg boundaries branches update entry preTokens suffix₂).symm⟩

theorem continueMonitored_take_eq (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (preTokens suffix : Schedule B) :
    continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix).take preTokens.length) =
      continueMonitored cfg boundaries branches update entry preTokens := by
  have htake : (preTokens ++ suffix).take preTokens.length = preTokens := by
    rw [List.take_append, List.take_length, Nat.sub_self, List.take_zero, List.append_nil]
  rw [htake]

/-- After exactly `preTokens.length` tokens of `preTokens ++ suffix`, the monitored pair
depends only on the fixed cfg, boundaries, branches, update and entry. Captured constants
inside `update` are outside this equality. Full replay/inductive-trace is a later deliverable. -/
theorem continueMonitored_take_prefix (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (update : Q → MonitorInput B P A D → Q) (entry : Q × Machine B P A D)
    (preTokens suffix₁ suffix₂ : Schedule B) :
    continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₁).take preTokens.length) =
      continueMonitored cfg boundaries branches update entry
        ((preTokens ++ suffix₂).take preTokens.length) := by
  rw [continueMonitored_take_eq, continueMonitored_take_eq]

theorem skip_appended_none (m : Machine B P A D) (b : B) :
    (m.skip b).attempts[m.attempts.length]? = none := by
  simp [skip_attempts]

theorem refuse_appended (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (reason : Composition.Failure) :
    (m.refuse b inv reason).attempts[m.attempts.length]? =
      some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩ := by
  simp [refuse_attempts]

theorem accept_appended (m : Machine B P A D) (b : B) (inv : Invocation P A D)
    (result : StepResult P A D) :
    (m.accept b inv result).attempts[m.attempts.length]? =
      some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩ := by
  simp [accept_attempts]

theorem AdvanceSound.appended_skip {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (_h : AdvanceSound cfg boundaries branches m b post)
    (skipped : post.attempts = m.attempts) :
    post.attempts[m.attempts.length]? = none := by
  simp [skipped]

theorem AdvanceSound.appended_refuse {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m : Machine B P A D} {b : B}
    (inv : Invocation P A D) (reason : Composition.Failure)
    (_active : (m.locals b).failure = none)
    (_selected : (branches b)[(m.locals b).consumed]? = some inv)
    (_rejected : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .error reason) :
    (m.refuse b inv reason).attempts[m.attempts.length]? =
      some ⟨b, (m.locals b).nextIndex, inv, m.world, .error reason⟩ :=
  refuse_appended m b inv reason

theorem AdvanceSound.appended_accept {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m : Machine B P A D} {b : B}
    (inv : Invocation P A D) (result : StepResult P A D)
    (_active : (m.locals b).failure = none)
    (_selected : (branches b)[(m.locals b).consumed]? = some inv)
    (_executed : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result) :
    (m.accept b inv result).attempts[m.attempts.length]? =
      some ⟨b, (m.locals b).nextIndex, inv, m.world, .ok result⟩ :=
  accept_appended m b inv result

end DefiKernel.Nary
