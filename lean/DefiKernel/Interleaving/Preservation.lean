import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Composition.Preservation
import DefiKernel.Parallel.Dependency.Adapter

/-! Accounting and locality telescope actual scheduled effects. Authority is checked at each
attempt's real pre-world, with a separate proof that every capability store is the initial one. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (d : D) (a : A) :
    total post.world.state d a - total m.world.state d a = post.supply d a - m.supply d a := by
  cases h with
  | halted => simp [skip_world, Machine.supply, skip_attempts]
  | exhausted => simp [skip_world, Machine.supply, skip_attempts]
  | refused =>
    simp [Machine.supply, Machine.refuse, Attempt.supply, setLocal_world]
  | accepted inv result active selected executed =>
    have he := (executeStep_sound _ _ _ _ _ _ _ executed).accounting d a
    simp only [Machine.supply, Machine.accept, List.map_append,
      List.map_singleton, List.sum_append, List.sum_singleton, Attempt.supply]
    linarith

theorem Reachable.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (d : D) (a : A) :
    total m.world.state d a = total initial.state d a + m.supply d a := by
  induction h with
  | start => simp [Interleaving.start, Machine.supply]
  | next b previous step ih =>
    have he := step.accounting d a
    linarith

theorem AdvanceSound.before_stores {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (store : m.world.capabilities = initial.capabilities)
    (previous : ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities) :
    ∀ attempt ∈ post.attempts, attempt.before.capabilities = initial.capabilities := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store
  | accepted =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store

theorem Reachable.before_stores {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.before_stores previous.store ih

theorem Reachable.authority {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt := by
  obtain ⟨history, executed⟩ := h.attempts attempt member
  rw [success] at executed
  exact (executeStep_sound _ _ _ _ _ _ _ executed).authorized

theorem Reachable.initial_store_authority {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized ⟨attempt.before.state, initial.capabilities⟩
      (boundaries attempt.branch attempt.index) result.receipt := by
  have authorized := h.authority attempt member result success
  have store := h.before_stores attempt member
  cases hr : result.receipt <;> simp_all [ReceiptAuthorized]

theorem AdvanceSound.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (c : Cell P A D)
    (untouched : c ∉ post.writes) :
    post.world.state.balance c = m.world.state.balance c ∧ c ∉ m.writes := by
  cases h with
  | halted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | exhausted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | refused =>
    simpa [Machine.writes, Machine.refuse, Attempt.writes, setLocal_world] using untouched
  | accepted inv result active selected executed =>
    simp only [Machine.writes, Machine.accept, List.flatMap_append,
      List.flatMap_singleton, Attempt.writes, List.mem_append, not_or] at untouched
    exact ⟨(executeStep_sound _ _ _ _ _ _ _ executed).locality c untouched.2, untouched.1⟩

theorem Reachable.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (c : Cell P A D)
    (untouched : c ∉ m.writes) : m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | next b previous step ih =>
    obtain ⟨same, old⟩ := step.locality c untouched
    exact same.trans (ih old)

theorem Reachable.frame {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (untouched : ∀ c ∈ region, c ∉ m.writes) : AgreeOn region initial.state m.world.state := by
  intro c member
  exact (h.locality c (untouched c member)).symm

theorem Reachable.predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    predicate initial.state ↔ predicate m.world.state :=
  supported_frame support (h.frame region untouched)

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzed_selected (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (b : BranchId) (n : Nat) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ fp, analyzeInvocation cfg (boundaries b n) inv = .ok fp ∧
      ∀ c ∈ fp.writes, c ∈ lf.writes ++ rf.writes := by
  cases b with
  | left =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .left)
      0 left lf hl n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_left _ (hw c hc)⟩
  | right =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .right)
      0 right rf hr n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_right _ (hw c hc)⟩

theorem Reachable.analyzed_locality {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
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
      obtain ⟨fp, hf, hw⟩ := analyzed_selected cfg boundaries left right lf rf hl hr
        b (pre.local b).consumed inv selected
      rw [← hi] at hf
      have framed := (executeStep_target_frame cfg (boundaries b (pre.local b).nextIndex)
        (pre.local b).nextIndex (pre.local b).outputs inv pre.world result fp hf executed).1
      exact (framed c (fun hc ↦ untouched (hw c hc))).trans ih

theorem Reachable.analyzed_predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate m.world.state := by
  apply supported_frame support
  intro c hc
  exact (h.analyzed_locality lf rf hl hr c (untouched c hc)).symm

theorem runPrefix_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total (runPrefix cfg boundaries initial left right schedule).world.state d a =
      total initial.state d a + (runPrefix cfg boundaries initial left right schedule).supply d a :=
  (runPrefix_reachable cfg boundaries initial left right schedule).accounting d a

theorem runPrefix_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    (runPrefix cfg boundaries initial left right schedule).world.capabilities =
      initial.capabilities :=
  (runPrefix_reachable cfg boundaries initial left right schedule).store

theorem runPrefix_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤ (runPrefix cfg boundaries initial left right schedule).world.state.balance c :=
  (runPrefix cfg boundaries initial left right schedule).world.state.nonneg c

theorem runPrefix_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region,
      c ∉ (runPrefix cfg boundaries initial left right schedule).writes) :
    predicate initial.state ↔
      predicate (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).predicate_frame
    region predicate support untouched

end DefiKernel.Interleaving
