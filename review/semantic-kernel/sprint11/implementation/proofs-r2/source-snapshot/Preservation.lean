import DefiKernel.Nary.Soundness
import DefiKernel.Nary.LocalOrder
import DefiKernel.Composition.Preservation
import DefiKernel.Parallel.Dependency.Adapter

/-! Accounting and locality telescope actual scheduled effects. Authority is checked at each
attempt's real pre-world, with a separate proof that every capability store is the initial one.
Analyzed frames use the ordered `analyzeAll` footprints, not a fixed left/right split. -/
namespace DefiKernel.Nary
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def Attempt.supply (attempt : Attempt B P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

def Machine.supply (m : Machine B P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt B P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine B P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def analyzedWrites (fps : List (B × Parallel.Footprint P A D)) : List (Cell P A D) :=
  fps.flatMap (fun pair ↦ pair.2.writes)

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzeAll_lookup (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) :
    ∀ order fps, analyzeAll cfg boundaries branches order = .ok fps →
      ∀ b ∈ order, ∃ fp, (b, fp) ∈ fps ∧
        Parallel.analyzeBranch cfg (boundaries b) (branches b) = .ok fp := by
  intro order
  induction order with
  | nil =>
    intro fps _ b hb
    cases hb
  | cons x rest ih =>
    intro fps h b hb
    cases hx : (Parallel.analyzeBranch cfg (boundaries x) (branches x)).mapError
        (AdmissionFailure.structural x) with
    | error reason =>
      have herr : analyzeAll cfg boundaries branches (x :: rest) = .error reason := by
        simp [analyzeAll, hx]
      rw [herr] at h
      cases h
    | ok fp =>
      have hxok : Parallel.analyzeBranch cfg (boundaries x) (branches x) = .ok fp :=
        (mapError_ok _ _ _).mp hx
      cases hr : analyzeAll cfg boundaries branches rest with
      | error reason =>
        have herr : analyzeAll cfg boundaries branches (x :: rest) = .error reason := by
          simp [analyzeAll, hx, hr]
        rw [herr] at h
        cases h
      | ok tail =>
        have hok : analyzeAll cfg boundaries branches (x :: rest) = .ok ((x, fp) :: tail) := by
          simp [analyzeAll, hx, hr]
        rw [hok] at h
        obtain rfl := Except.ok.inj h
        have hxok := hxok
        simp only [List.mem_cons] at hb
        rcases hb with hbx | hbrest
        · subst hbx
          exact ⟨fp, List.mem_cons.mpr (Or.inl rfl), hxok⟩
        · obtain ⟨fp', hmem, hbr⟩ := ih tail hr b hbrest
          exact ⟨fp', List.mem_cons.mpr (Or.inr hmem), hbr⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mem_analyzedWrites {fps : List (B × Parallel.Footprint P A D)} {b : B}
    {fp : Parallel.Footprint P A D} {c : Cell P A D}
    (h : (b, fp) ∈ fps) (hc : c ∈ fp.writes) :
    c ∈ analyzedWrites fps :=
  (List.mem_flatMap.mpr ⟨(b, fp), h, hc⟩)

theorem analyzed_selected (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (order : List B)
    (fps : List (B × Parallel.Footprint P A D))
    (ha : analyzeAll cfg boundaries branches order = .ok fps) (b : B)
    (hb : b ∈ order) (n : Nat) (inv : Invocation P A D)
    (selected : (branches b)[n]? = some inv) :
    ∃ fp part, (b, fp) ∈ fps ∧
      Parallel.analyzeInvocation cfg (boundaries b n) inv = .ok part ∧
      ∀ c ∈ part.writes, c ∈ analyzedWrites fps := by
  obtain ⟨fp, hmem, hbranch⟩ := analyzeAll_lookup cfg boundaries branches order fps ha b hb
  obtain ⟨part, hf, _, hw⟩ := Parallel.analyzeBranchFrom_member cfg (boundaries b) 0
    (branches b) fp hbranch n inv selected
  refine ⟨fp, part, hmem, by simpa using hf, ?_⟩
  intro c hc
  exact mem_analyzedWrites hmem (hw c hc)

theorem AdvanceSound.accounting {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) (d : D) (a : A) :
    total post.world.state d a - total m.world.state d a = post.supply d a - m.supply d a := by
  cases h with
  | halted => simp [skip_world, Machine.supply, skip_attempts]
  | exhausted => simp [skip_world, Machine.supply, skip_attempts]
  | refused =>
    simp [Machine.supply, refuse_world, refuse_attempts, List.map_append, List.map_singleton,
      List.sum_append, List.sum_singleton, Attempt.supply]
  | accepted inv result active selected executed =>
    have he := (executeStep_sound _ _ _ _ _ _ _ executed).accounting d a
    simp only [Machine.supply, accept_world, accept_attempts, List.map_append,
      List.map_singleton, List.sum_append, List.sum_singleton, Attempt.supply]
    linarith

theorem Reachable.accounting {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (d : D) (a : A) :
    total m.world.state d a = total initial.state d a + m.supply d a := by
  induction h with
  | start => simp [start_world, start_attempts, Machine.supply]
  | next b previous step ih =>
    have he := step.accounting d a
    linarith

theorem AdvanceSound.before_stores {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post)
    (store : m.world.capabilities = initial.capabilities)
    (previous : ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities) :
    ∀ attempt ∈ post.attempts, attempt.before.capabilities = initial.capabilities := by
  cases h with
  | halted =>
    intro attempt member
    exact previous attempt (by simpa [skip_attempts] using member)
  | exhausted =>
    intro attempt member
    exact previous attempt (by simpa [skip_attempts] using member)
  | refused =>
    intro attempt member
    simp only [refuse_attempts, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store
  | accepted =>
    intro attempt member
    simp only [accept_attempts, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store

theorem Reachable.before_stores {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) :
    ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities := by
  induction h with
  | start =>
    intro attempt member
    cases member
  | next b previous step ih => exact step.before_stores previous.store ih

theorem Reachable.authority {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (attempt : Attempt B P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.participant attempt.index)
      result.receipt := by
  obtain ⟨history, executed⟩ := h.attempts attempt member
  rw [success] at executed
  exact (executeStep_sound _ _ _ _ _ _ _ executed).authorized

theorem Reachable.initial_store_authority {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (attempt : Attempt B P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized ⟨attempt.before.state, initial.capabilities⟩
      (boundaries attempt.participant attempt.index) result.receipt := by
  have authorized := h.authority attempt member result success
  have store := h.before_stores attempt member
  cases hr : result.receipt <;> simp_all [ReceiptAuthorized]

theorem AdvanceSound.locality {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {m post : Machine B P A D} {b : B}
    (h : AdvanceSound cfg boundaries branches m b post) (c : Cell P A D)
    (untouched : c ∉ post.writes) :
    post.world.state.balance c = m.world.state.balance c ∧ c ∉ m.writes := by
  cases h with
  | halted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | exhausted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | refused =>
    simpa [Machine.writes, refuse_world, refuse_attempts, Attempt.writes] using untouched
  | accepted inv result active selected executed =>
    simp only [Machine.writes, accept_attempts, List.flatMap_append, List.flatMap_singleton,
      Attempt.writes, List.mem_append, not_or] at untouched
    exact ⟨(executeStep_sound _ _ _ _ _ _ _ executed).locality c untouched.2, untouched.1⟩

theorem Reachable.locality {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (c : Cell P A D)
    (untouched : c ∉ m.writes) : m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | next b previous step ih =>
    obtain ⟨same, old⟩ := step.locality c untouched
    exact same.trans (ih old)

theorem Reachable.frame {cfg : Config P A D} {boundaries : Boundaries B P A D}
    {branches : Branches B P A D} {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (region : Set (Cell P A D))
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    AgreeOn region initial.state m.world.state := by
  intro c member
  exact (h.locality c (untouched c member)).symm

theorem Reachable.predicate_frame {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    predicate initial.state ↔ predicate m.world.state :=
  supported_frame support (h.frame region untouched)

theorem Reachable.analyzed_locality {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (order : List B)
    (fps : List (B × Parallel.Footprint P A D)) (covered : ∀ b, b ∈ order)
    (ha : analyzeAll cfg boundaries branches order = .ok fps) (c : Cell P A D)
    (untouched : c ∉ analyzedWrites fps) :
    m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | @next pre post b previous step ih =>
    cases step with
    | halted => simpa [skip_world] using ih
    | exhausted => simpa [skip_world] using ih
    | refused => simpa [refuse_world] using ih
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      obtain ⟨fp, part, _, hf, hw⟩ := analyzed_selected cfg boundaries branches order fps ha
        b (covered b) (pre.locals b).consumed inv selected
      rw [← hi] at hf
      have framed := (Parallel.executeStep_target_frame cfg
        (boundaries b (pre.locals b).nextIndex) (pre.locals b).nextIndex
        (pre.locals b).outputs inv pre.world result part hf executed).1
      exact (framed c (fun hc ↦ untouched (hw c hc))).trans ih

theorem Reachable.analyzed_predicate_frame {cfg : Config P A D}
    {boundaries : Boundaries B P A D} {branches : Branches B P A D}
    {initial : World P A D} {m : Machine B P A D}
    (h : Reachable cfg boundaries branches initial m) (order : List B)
    (fps : List (B × Parallel.Footprint P A D)) (covered : ∀ b, b ∈ order)
    (ha : analyzeAll cfg boundaries branches order = .ok fps)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ analyzedWrites fps) :
    predicate initial.state ↔ predicate m.world.state := by
  apply supported_frame support
  intro c hc
  exact (h.analyzed_locality order fps covered ha c (untouched c hc)).symm

theorem runPrefix_accounting (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (d : D) (a : A) :
    total (runPrefix cfg boundaries initial branches schedule).world.state d a =
      total initial.state d a +
        (runPrefix cfg boundaries initial branches schedule).supply d a :=
  (runPrefix_reachable cfg boundaries initial branches schedule).accounting d a

theorem runPrefix_store (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B) :
    (runPrefix cfg boundaries initial branches schedule).world.capabilities =
      initial.capabilities :=
  (runPrefix_reachable cfg boundaries initial branches schedule).store

theorem runPrefix_nonnegative (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (c : Cell P A D) :
    0 ≤ (runPrefix cfg boundaries initial branches schedule).world.state.balance c :=
  (runPrefix cfg boundaries initial branches schedule).world.state.nonneg c

theorem runPrefix_frame (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region,
      c ∉ (runPrefix cfg boundaries initial branches schedule).writes) :
    predicate initial.state ↔
      predicate (runPrefix cfg boundaries initial branches schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial branches schedule).predicate_frame
    region predicate support untouched

theorem runPrefix_analyzed_locality (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (schedule : Schedule B)
    (order : List B) (fps : List (B × Parallel.Footprint P A D))
    (covered : ∀ b, b ∈ order)
    (ha : analyzeAll cfg boundaries branches order = .ok fps) (c : Cell P A D)
    (untouched : c ∉ analyzedWrites fps) :
    (runPrefix cfg boundaries initial branches schedule).world.state.balance c =
      initial.state.balance c :=
  (runPrefix_reachable cfg boundaries initial branches schedule).analyzed_locality
    order fps covered ha c untouched

theorem runPrefix_analyzed_locality_roster (cfg : Config P A D)
    (roster : Roster B) (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (schedule : Schedule B)
    (fps : List (B × Parallel.Footprint P A D))
    (ha : analyzeAll cfg boundaries branches roster.order = .ok fps) (c : Cell P A D)
    (untouched : c ∉ analyzedWrites fps) :
    (runPrefix cfg boundaries initial branches schedule).world.state.balance c =
      initial.state.balance c :=
  runPrefix_analyzed_locality cfg boundaries initial branches schedule roster.order fps
    roster.complete ha c untouched

end DefiKernel.Nary
