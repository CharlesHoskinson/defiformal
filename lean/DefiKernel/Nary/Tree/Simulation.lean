import DefiKernel.Nary.Tree.Observation
import DefiKernel.Nary.Causal

/-! Tree/flat correspondence. Flattening is observation, not dispatch.
Proofs use actual `advance`/`stepLeaf` equations. Well-formedness is required
for identity-complete simulation; malformed raw fallback is not a well-formed theorem. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false

theorem count_fork (left right : Tree B) (b : B) :
    Tree.count (left.fork right) b = Tree.count left b + Tree.count right b :=
  List.count_append

theorem count_leaf (x b : B) :
    Tree.count (Tree.leaf x) b = if x = b then 1 else 0 := by
  simp [Tree.count, Tree.leaves, List.count_cons, List.count_nil]

theorem count_empty (b : B) : Tree.count (Tree.empty : Tree B) b = 0 := by
  simp [Tree.count, Tree.leaves]

theorem mem_leaves_iff_count_pos (tree : Tree B) (b : B) :
    b ∈ Tree.leaves tree ↔ 0 < Tree.count tree b := by
  simp [Tree.count, List.count_pos_iff]

theorem shape_empty : (LocalTree.empty : LocalTree B P A D).shape = .empty := rfl

theorem shape_leaf (id : B) (own : Interleaving.LocalState P A D) :
    (LocalTree.leaf id own).shape = .leaf id := rfl

theorem shape_fork (left right : LocalTree B P A D) :
    (LocalTree.fork left right).shape = .fork left.shape right.shape := rfl

theorem emptyLocals_lookup_getD (tree : Tree B) (b : B) :
    (lookupLeaf (emptyLocals tree : LocalTree B P A D) b).getD {} = {} := by
  induction tree with
  | empty => rfl
  | leaf x =>
    simp [emptyLocals, lookupLeaf]
    split_ifs <;> rfl
  | fork left right ihL ihR =>
    simp [emptyLocals, lookupLeaf]
    cases h : lookupLeaf (emptyLocals left : LocalTree B P A D) b with
    | none => simpa [h] using ihR
    | some own =>
      have : own = {} := by
        have hL := ihL
        simp [h, Option.getD] at hL
        exact hL
      simp [h, this]

theorem flatten_start (roster : Roster B) (tree : Tree B) (initial : World P A D) :
    flattenMachine roster (startTree tree initial) = Nary.start initial := by
  have hl :
      (fun b => lookupCollected (collectLocals (emptyLocals tree : LocalTree B P A D)) b) =
        fun _ => {} :=
    funext fun b => by
      simpa [lookupCollected_eq_lookupLeaf, emptyLocal] using
        emptyLocals_lookup_getD (P := P) (A := A) (D := D) tree b
  simp [flattenMachine, startTree, Nary.start, hl]

theorem Rep_start (roster : Roster B) (tree : Tree B) (initial : World P A D) :
    Rep roster (startTree tree initial) (Nary.start initial) :=
  (Rep_iff roster _ _).mpr (flatten_start roster tree initial)

theorem count_zero_lookup_none (locals : LocalTree B P A D) (b : B)
    (h : Tree.count locals.shape b = 0) : lookupLeaf locals b = none := by
  induction locals with
  | empty => rfl
  | leaf id own =>
    simp [shape_leaf, count_leaf] at h
    simp [lookupLeaf]
    intro hid
    simp [hid] at h
  | fork left right ihL ihR =>
    simp [shape_fork, count_fork] at h
    have hL : Tree.count left.shape b = 0 := by omega
    have hR : Tree.count right.shape b = 0 := by omega
    simp [lookupLeaf, ihL hL, ihR hR]

theorem mem_shape_iff_lookup (locals : LocalTree B P A D) (b : B) :
    b ∈ locals.shape.leaves ↔ (lookupLeaf locals b).isSome = true := by
  induction locals with
  | empty => simp [shape_empty, Tree.leaves, lookupLeaf]
  | leaf id own =>
    simp [shape_leaf, Tree.leaves, lookupLeaf, List.mem_singleton]
    by_cases hid : id = b
    · simp [hid]
    · simp [hid, Ne.symm hid]
  | fork left right ihL ihR =>
    simp [shape_fork, Tree.leaves, lookupLeaf, ihL, ihR, Option.isSome]
    cases lookupLeaf left b <;> simp

theorem count_one_lookup_isSome (locals : LocalTree B P A D) (b : B)
    (h : Tree.count locals.shape b = 1) : (lookupLeaf locals b).isSome = true := by
  have : 0 < Tree.count locals.shape b := by omega
  exact (mem_shape_iff_lookup locals b).mp ((mem_leaves_iff_count_pos _ _).mpr this)

theorem stepLeaf_failure (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (own : Interleaving.LocalState P A D) (h : own.failure.isSome = true) :
    stepLeaf cfg boundaries branches m b own =
      (skipSelected own, m.world, m.attempts) := by
  simp [stepLeaf, h]

theorem stepLeaf_absent (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (own : Interleaving.LocalState P A D) (hfail : own.failure = none)
    (habs : (branches b)[own.consumed]? = none) :
    stepLeaf cfg boundaries branches m b own =
      (skipSelected own, m.world, m.attempts) := by
  have hs : own.failure.isSome = false := by simp [hfail]
  simp [stepLeaf, hs, habs]

theorem stepLeaf_refuse (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (own : Interleaving.LocalState P A D) (inv : Invocation P A D)
    (reason : Composition.Failure) (hfail : own.failure = none)
    (hsel : (branches b)[own.consumed]? = some inv)
    (hrej : executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
      (.invoke inv) m.world = .error reason) :
    stepLeaf cfg boundaries branches m b own =
      (refuseSelected own inv reason, m.world,
        m.attempts ++ [⟨b, own.nextIndex, inv, m.world, .error reason⟩]) := by
  have hs : own.failure.isSome = false := by simp [hfail]
  simp [stepLeaf, hs, hsel, hrej, leafHistory]

theorem stepLeaf_accept (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (own : Interleaving.LocalState P A D) (inv : Invocation P A D)
    (result : StepResult P A D) (hfail : own.failure = none)
    (hsel : (branches b)[own.consumed]? = some inv)
    (hok : executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
      (.invoke inv) m.world = .ok result) :
    stepLeaf cfg boundaries branches m b own =
      (acceptSelected own inv m.world result, result.world,
        m.attempts ++ [⟨b, own.nextIndex, inv, m.world, .ok result⟩]) := by
  have hs : own.failure.isSome = false := by simp [hfail]
  simp [stepLeaf, hs, hsel, hok, leafHistory, publishedWorld]

theorem advanceIn_empty_none (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B) :
    advanceIn cfg boundaries branches m b .empty = none := rfl

/-- Unique-count leaf update: `advanceIn` finds the unique `b` leaf and applies `stepLeaf`. -/
theorem advanceIn_of_count_one (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (locals : LocalTree B P A D) (hcount : Tree.count locals.shape b = 1) :
    ∃ locals' own own' world' attempts',
      lookupLeaf locals b = some own ∧
      stepLeaf cfg boundaries branches m b own = (own', world', attempts') ∧
      advanceIn cfg boundaries branches m b locals = some (locals', world', attempts') ∧
      locals'.shape = locals.shape ∧
      lookupLeaf locals' b = some own' ∧
      (∀ x, x ≠ b → lookupLeaf locals' x = lookupLeaf locals x) := by
  induction locals with
  | empty =>
    simp [shape_empty, count_empty] at hcount
  | leaf id own =>
    have hid : id = b := by
      simp [shape_leaf, count_leaf] at hcount
      by_cases h : id = b
      · exact h
      · simp [h] at hcount
    subst hid
    refine ⟨.leaf id (stepLeaf cfg boundaries branches m id own).1, own,
      (stepLeaf cfg boundaries branches m id own).1,
      (stepLeaf cfg boundaries branches m id own).2.1,
      (stepLeaf cfg boundaries branches m id own).2.2, ?_, rfl, ?_, rfl, ?_, ?_⟩
    · simp [lookupLeaf]
    · simp [advanceIn]
    · simp [lookupLeaf]
    · intro x hx
      have hne : id ≠ x := hx.symm
      simp [lookupLeaf, hne]
  | fork left right ihL ihR =>
    simp [shape_fork, count_fork] at hcount
    by_cases hmem : b ∈ Tree.leaves left.shape
    · have hL : Tree.count left.shape b = 1 := by
        have : 0 < Tree.count left.shape b := (mem_leaves_iff_count_pos _ _).mp hmem
        omega
      have _hR0 : Tree.count right.shape b = 0 := by omega
      obtain ⟨left', own, own', world', attempts', hown, hstep, hadv, hshape, hlook, haway⟩ :=
        ihL hL
      refine ⟨.fork left' right, own, own', world', attempts', ?_, hstep, ?_, ?_, ?_, ?_⟩
      · simp [lookupLeaf, hown]
      · simp [advanceIn, siblingFailureBlocks, selectedLeftMember, hmem, hadv, rebuildFork]
      · simp [shape_fork, hshape]
      · simp [lookupLeaf, hlook]
      · intro x hx
        simp [lookupLeaf, haway x hx]
    · have hL0 : Tree.count left.shape b = 0 := by
        have : ¬ 0 < Tree.count left.shape b := by
          intro hpos
          exact hmem ((mem_leaves_iff_count_pos _ _).mpr hpos)
        omega
      have hR : Tree.count right.shape b = 1 := by omega
      have hnoneL : lookupLeaf left b = none := count_zero_lookup_none left b hL0
      obtain ⟨right', own, own', world', attempts', hown, hstep, hadv, hshape, hlook, haway⟩ :=
        ihR hR
      refine ⟨.fork left right', own, own', world', attempts', ?_, hstep, ?_, ?_, ?_, ?_⟩
      · simp [lookupLeaf, hnoneL, hown]
      · simp [advanceIn, siblingFailureBlocks, selectedLeftMember, hmem, hadv, rebuildFork]
      · simp [shape_fork, hshape]
      · simp [lookupLeaf, hnoneL, hlook]
      · intro x hx
        simp [lookupLeaf, haway x hx]

theorem flatten_locals_lookup (roster : Roster B) (tm : TreeMachine B P A D) (x : B) :
    (flattenMachine roster tm).locals x = (lookupLeaf tm.locals x).getD emptyLocal :=
  lookupCollected_eq_lookupLeaf tm.locals x

theorem machine_mk_eq (w w' : World P A D)
    (l l' : B → Interleaving.LocalState P A D)
    (a a' : List (Nary.Attempt B P A D))
    (hw : w = w') (hl : l = l') (ha : a = a') :
    Nary.Machine.mk w l a = Nary.Machine.mk w' l' a' := by
  cases hw; cases hl; cases ha; rfl

theorem skipSelected_eta (own : Interleaving.LocalState P A D) :
    skipSelected own =
      { consumed := own.consumed + 1, events := own.events, outputs := own.outputs,
        nextIndex := own.nextIndex, failure := own.failure } :=
  rfl

theorem refuseSelected_eta (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (reason : Composition.Failure) :
    refuseSelected own inv reason =
      { consumed := own.consumed + 1, events := own.events, outputs := own.outputs,
        nextIndex := own.nextIndex,
        failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ } := by
  simp [refuseSelected, refusedConsumed]

theorem acceptSelected_eta (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (before : World P A D) (result : StepResult P A D) :
    acceptSelected own inv before result =
      ⟨own.consumed + 1,
        own.events ++ [⟨own.nextIndex, .invoke inv, before, result⟩],
        own.outputs ++ result.outputs, own.nextIndex + 1, none⟩ := by
  simp only [acceptSelected]

theorem flatten_skip_locals (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b x : B) (own : Interleaving.LocalState P A D)
    (hlook : lookupLeaf locals' b = some (skipSelected own))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own) :
    lookupCollected (collectLocals locals') x =
      ((flattenMachine roster tm).skip b).locals x := by
  have hownD : (flattenMachine roster tm).locals b = own := by
    simpa [flatten_locals_lookup, hown]
  by_cases hx : x = b
  · rw [hx, lookupCollected_eq_lookupLeaf, hlook, Option.getD_some, Nary.skip_selected,
      hownD, skipSelected_eta]
  · rw [lookupCollected_eq_lookupLeaf, haway x hx, Nary.skip_away (flattenMachine roster tm) b x hx,
      flatten_locals_lookup]

theorem flatten_refuse_locals (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b x : B) (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (reason : Composition.Failure)
    (hlook : lookupLeaf locals' b = some (refuseSelected own inv reason))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own) :
    lookupCollected (collectLocals locals') x =
      ((flattenMachine roster tm).refuse b inv reason).locals x := by
  have hownD : (flattenMachine roster tm).locals b = own := by
    simpa [flatten_locals_lookup, hown]
  by_cases hx : x = b
  · rw [hx, lookupCollected_eq_lookupLeaf, hlook, Option.getD_some]
    simp [Nary.Machine.refuse, Nary.setLocal_at, hownD, refuseSelected_eta]
  · rw [lookupCollected_eq_lookupLeaf, haway x hx,
      Nary.refuse_away (flattenMachine roster tm) b x inv reason hx, flatten_locals_lookup]

theorem flatten_accept_locals (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b x : B) (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (result : StepResult P A D)
    (hlook : lookupLeaf locals' b = some (acceptSelected own inv tm.world result))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own) :
    lookupCollected (collectLocals locals') x =
      ((flattenMachine roster tm).accept b inv result).locals x := by
  have hownD : (flattenMachine roster tm).locals b = own := by
    simpa [flatten_locals_lookup, hown]
  by_cases hx : x = b
  · rw [hx, lookupCollected_eq_lookupLeaf, hlook, Option.getD_some]
    simp [Nary.Machine.accept, Nary.setLocal_at, hownD, acceptSelected_eta,
      flattenMachine_world]
  · rw [lookupCollected_eq_lookupLeaf, haway x hx,
      Nary.accept_away (flattenMachine roster tm) b x inv result hx, flatten_locals_lookup]

theorem nary_machine_eta (m : Nary.Machine B P A D) :
    m = Nary.Machine.mk m.world m.locals m.attempts :=
  rfl

theorem flatten_updated_eq (roster : Roster B) (world : World P A D)
    (locals : LocalTree B P A D) (attempts : List (Nary.Attempt B P A D)) :
    flattenMachine roster ⟨world, locals, attempts⟩ =
      ⟨world, fun x => lookupCollected (collectLocals locals) x, attempts⟩ :=
  rfl

theorem flatten_eq_skip (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b : B) (own : Interleaving.LocalState P A D)
    (hlook : lookupLeaf locals' b = some (skipSelected own))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own) :
    Nary.Machine.mk tm.world (fun x => lookupCollected (collectLocals locals') x) tm.attempts =
      (flattenMachine roster tm).skip b := by
  rw [nary_machine_eta ((flattenMachine roster tm).skip b), Nary.skip_world, Nary.skip_attempts,
    flattenMachine_world, flattenMachine_attempts]
  congr 1
  funext x
  exact flatten_skip_locals roster tm locals' b x own hlook haway hown

theorem flatten_eq_refuse (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b : B) (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (reason : Composition.Failure)
    (hlook : lookupLeaf locals' b = some (refuseSelected own inv reason))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own)
    (hownD : (flattenMachine roster tm).locals b = own) :
    Nary.Machine.mk tm.world (fun x => lookupCollected (collectLocals locals') x)
      (tm.attempts ++ [⟨b, own.nextIndex, inv, tm.world, .error reason⟩]) =
      (flattenMachine roster tm).refuse b inv reason := by
  rw [nary_machine_eta ((flattenMachine roster tm).refuse b inv reason), Nary.refuse_world,
    Nary.refuse_attempts, flattenMachine_world, flattenMachine_attempts, hownD]
  congr 1
  funext x
  exact flatten_refuse_locals roster tm locals' b x own inv reason hlook haway hown

theorem flatten_eq_accept (roster : Roster B) (tm : TreeMachine B P A D)
    (locals' : LocalTree B P A D) (b : B) (own : Interleaving.LocalState P A D)
    (inv : Invocation P A D) (result : StepResult P A D)
    (hlook : lookupLeaf locals' b = some (acceptSelected own inv tm.world result))
    (haway : ∀ y, y ≠ b → lookupLeaf locals' y = lookupLeaf tm.locals y)
    (hown : lookupLeaf tm.locals b = some own)
    (hownD : (flattenMachine roster tm).locals b = own) :
    Nary.Machine.mk result.world (fun x => lookupCollected (collectLocals locals') x)
      (tm.attempts ++ [⟨b, own.nextIndex, inv, tm.world, .ok result⟩]) =
      (flattenMachine roster tm).accept b inv result := by
  rw [nary_machine_eta ((flattenMachine roster tm).accept b inv result), Nary.accept_world,
    Nary.accept_attempts, flattenMachine_world, flattenMachine_attempts, hownD]
  congr 1
  funext x
  exact flatten_accept_locals roster tm locals' b x own inv result hlook haway hown

theorem flatten_advanceTree (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B) (tm : TreeMachine B P A D)
    (b : B) (hcount : Tree.count tm.locals.shape b = 1) :
    flattenMachine roster (advanceTree cfg boundaries branches tm b) =
      Nary.advance cfg boundaries branches (flattenMachine roster tm) b := by
  obtain ⟨locals', own, own', world', attempts', hown, hstep, hadv, _, hlook, haway⟩ :=
    advanceIn_of_count_one cfg boundaries branches tm b tm.locals hcount
  have hadvT : advanceTree cfg boundaries branches tm b =
      { tm with locals := locals', world := world', attempts := attempts' } := by
    simp [advanceTree, hadv]
  rw [hadvT]
  have hownD : (flattenMachine roster tm).locals b = own := by
    simpa [flatten_locals_lookup, hown]
  by_cases hf : own.failure.isSome = true
  · have hs := stepLeaf_failure cfg boundaries branches tm b own hf
    rw [hs] at hstep
    obtain ⟨rfl, rfl, rfl⟩ := hstep
    have hadvN := Nary.advance_eq_skip_of_isSome cfg boundaries branches
      (flattenMachine roster tm) b (by simpa [hownD] using hf)
    rw [hadvN, flatten_updated_eq]
    exact flatten_eq_skip roster tm locals' b own hlook haway hown
  · have hnone : own.failure = none := by
      cases hfo : own.failure <;> simp_all
    cases hbr : (branches b)[own.consumed]? with
    | none =>
      have hs := stepLeaf_absent cfg boundaries branches tm b own hnone hbr
      rw [hs] at hstep
      obtain ⟨rfl, rfl, rfl⟩ := hstep
      have hadvN := Nary.advance_eq_skip_of_absent cfg boundaries branches
        (flattenMachine roster tm) b (by simpa [hownD] using hnone)
        (by simpa [hownD] using hbr)
      rw [hadvN, flatten_updated_eq]
      exact flatten_eq_skip roster tm locals' b own hlook haway hown
    | some inv =>
      cases hex : executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
          (.invoke inv) tm.world with
      | error reason =>
        have hs := stepLeaf_refuse cfg boundaries branches tm b own inv reason hnone hbr hex
        rw [hs] at hstep
        obtain ⟨rfl, rfl, rfl⟩ := hstep
        have hadvN := Nary.advance_eq_refuse cfg boundaries branches
          (flattenMachine roster tm) b inv reason
          (by simpa [hownD] using hnone) (by simpa [hownD] using hbr)
          (by simpa [hownD, flattenMachine_world] using hex)
        rw [hadvN, flatten_updated_eq]
        exact flatten_eq_refuse roster tm locals' b own inv reason hlook haway hown hownD
      | ok result =>
        have hs := stepLeaf_accept cfg boundaries branches tm b own inv result hnone hbr hex
        rw [hs] at hstep
        obtain ⟨rfl, rfl, rfl⟩ := hstep
        have hadvN := Nary.advance_eq_accept cfg boundaries branches
          (flattenMachine roster tm) b inv result
          (by simpa [hownD] using hnone) (by simpa [hownD] using hbr)
          (by simpa [hownD, flattenMachine_world] using hex)
        rw [hadvN, flatten_updated_eq]
        exact flatten_eq_accept roster tm locals' b own inv result hlook haway hown hownD

theorem flatten_advanceTree_of_wf (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B) (tm : TreeMachine B P A D)
    (b : B) (hwf : WellFormed roster tm.locals.shape) :
    flattenMachine roster (advanceTree cfg boundaries branches tm b) =
      Nary.advance cfg boundaries branches (flattenMachine roster tm) b :=
  flatten_advanceTree cfg boundaries branches roster tm b (wellFormed_count roster _ hwf b)

theorem one_token_simulation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (tm : TreeMachine B P A D) (m : Nary.Machine B P A D) (b : B)
    (hwf : WellFormed roster tm.locals.shape) (hrep : Rep roster tm m) :
    Rep roster (advanceTree cfg boundaries branches tm b)
      (Nary.advance cfg boundaries branches m b) := by
  have hflat := (Rep_iff roster tm m).mp hrep
  rw [Rep_iff, flatten_advanceTree_of_wf cfg boundaries branches roster tm b hwf, hflat]

theorem flatten_continueTree (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B) (tm : TreeMachine B P A D)
    (schedule : Schedule B) (hwf : WellFormed roster tm.locals.shape) :
    flattenMachine roster (continueTree cfg boundaries branches tm schedule) =
      Nary.continueRun cfg boundaries branches (flattenMachine roster tm) schedule := by
  induction schedule generalizing tm with
  | nil => simp [continueTree, Nary.continueRun_nil]
  | cons b rest ih =>
    have hshape : (advanceTree cfg boundaries branches tm b).locals.shape = tm.locals.shape := by
      obtain ⟨locals', _, _, _, _, _, _, hadv, hshape, _, _⟩ :=
        advanceIn_of_count_one cfg boundaries branches tm b tm.locals
          (wellFormed_count roster _ hwf b)
      simp [advanceTree, hadv, hshape]
    have hwf' : WellFormed roster (advanceTree cfg boundaries branches tm b).locals.shape := by
      simpa [hshape] using hwf
    simp [continueTree_cons, Nary.continueRun_cons]
    rw [ih _ hwf', flatten_advanceTree_of_wf cfg boundaries branches roster tm b hwf]

theorem arbitrary_entry_simulation (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (roster : Roster B)
    (tm : TreeMachine B P A D) (m : Nary.Machine B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster tm.locals.shape) (hrep : Rep roster tm m) :
    Rep roster (continueTree cfg boundaries branches tm schedule)
      (Nary.continueRun cfg boundaries branches m schedule) := by
  have hflat := (Rep_iff roster tm m).mp hrep
  rw [Rep_iff, flatten_continueTree cfg boundaries branches roster tm schedule hwf, hflat]

theorem flatten_runTreePrefix (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (roster : Roster B) (initial : World P A D) (tree : Tree B)
    (branches : Branches B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster tree) :
    flattenMachine roster (runTreePrefix cfg boundaries initial tree branches schedule) =
      Nary.runPrefix cfg boundaries initial branches schedule := by
  have hshape : (startTree tree initial).locals.shape = tree := startTree_shape tree initial
  have hwf' : WellFormed roster (startTree tree initial).locals.shape := by
    simpa [hshape] using hwf
  simp [runTreePrefix, Nary.runPrefix]
  rw [flatten_continueTree cfg boundaries branches roster _ schedule hwf', flatten_start]

theorem runPrefix_rep (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (roster : Roster B) (initial : World P A D) (tree : Tree B)
    (branches : Branches B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster tree) :
    Rep roster (runTreePrefix cfg boundaries initial tree branches schedule)
      (Nary.runPrefix cfg boundaries initial branches schedule) :=
  (Rep_iff _ _ _).mpr
    (flatten_runTreePrefix cfg boundaries roster initial tree branches schedule hwf)

theorem runTree_refused_base (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B)
    (reason : Nary.AdmissionFailure B P A D)
    (h : Nary.admit cfg roster boundaries branches schedule = .error reason) :
    runTree cfg roster boundaries branches initial tree schedule =
      .refused (.base reason) initial schedule := by
  simp [runTree, admitTree_base cfg roster boundaries branches schedule tree reason h]

theorem runTree_executed_of (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B)
    (fp : List (B × Parallel.Footprint P A D))
    (hAdmit : Nary.admit cfg roster boundaries branches schedule = .ok fp)
    (hwf : WellFormed roster tree) :
    runTree cfg roster boundaries branches initial tree schedule =
      .executed schedule (runTreePrefix cfg boundaries initial tree branches schedule) := by
  have hcheck : checkTree roster tree = .ok () := (wellFormed_iff_check roster tree).mp hwf
  simp [runTree, admitTree_ok cfg roster boundaries branches schedule tree fp hAdmit hcheck]

theorem result_projection (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B)
    (hwf : WellFormed roster tree) :
    match runTree cfg roster boundaries branches initial tree schedule,
          Nary.runNary cfg roster boundaries initial branches schedule with
    | .refused (.base r) w s, .refused r' w' s' => r = r' ∧ w = w' ∧ s = s'
    | .executed s tm, .executed s' m =>
        s = s' ∧ flattenMachine roster tm = m
    | _, _ => False := by
  cases hAdmit : Nary.admit cfg roster boundaries branches schedule with
  | error reason =>
    simp [runTree_refused_base cfg roster boundaries branches initial tree schedule reason hAdmit,
      Nary.runNary, hAdmit]
  | ok fp =>
    have hex := runTree_executed_of cfg roster boundaries branches initial tree schedule fp
      hAdmit hwf
    simp [hex, Nary.runNary, hAdmit,
      flatten_runTreePrefix cfg boundaries roster initial tree branches schedule hwf]

theorem fullMachineEq_of_flatten (roster : Roster B) (left right : TreeMachine B P A D)
    (h : flattenMachine roster left = flattenMachine roster right) :
    fullMachineEq roster left right = true :=
  (fullMachineEq_iff roster left right).mpr h

theorem regrouping (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (roster : Roster B) (initial : World P A D) (T T' : Tree B)
    (branches : Branches B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster T) (hwf' : WellFormed roster T') :
    fullMachineEq roster
      (runTreePrefix cfg boundaries initial T branches schedule)
      (runTreePrefix cfg boundaries initial T' branches schedule) = true := by
  apply fullMachineEq_of_flatten
  rw [flatten_runTreePrefix cfg boundaries roster initial T branches schedule hwf,
    flatten_runTreePrefix cfg boundaries roster initial T' branches schedule hwf']

theorem fork_assoc_wellFormed (roster : Roster B) (t1 t2 t3 : Tree B) :
    WellFormed roster ((t1.fork t2).fork t3) ↔ WellFormed roster (t1.fork (t2.fork t3)) := by
  constructor <;> intro h b hb <;>
    simpa [count_fork, Nat.add_assoc] using h b hb

theorem fork_assoc_regrouping (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (roster : Roster B) (initial : World P A D) (t1 t2 t3 : Tree B)
    (branches : Branches B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster ((t1.fork t2).fork t3)) :
    fullMachineEq roster
      (runTreePrefix cfg boundaries initial ((t1.fork t2).fork t3) branches schedule)
      (runTreePrefix cfg boundaries initial (t1.fork (t2.fork t3)) branches schedule) = true :=
  regrouping cfg boundaries roster initial _ _ branches schedule hwf
    ((fork_assoc_wellFormed roster t1 t2 t3).mp hwf)

theorem empty_unit_left (roster : Roster B) (t : Tree B) :
    WellFormed roster (Tree.empty.fork t) ↔ WellFormed roster t := by
  constructor <;> intro h b hb <;> simpa [count_fork, count_empty] using h b hb

theorem empty_unit_right (roster : Roster B) (t : Tree B) :
    WellFormed roster (t.fork Tree.empty) ↔ WellFormed roster t := by
  constructor <;> intro h b hb <;> simpa [count_fork, count_empty] using h b hb

theorem empty_unit_regrouping (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (roster : Roster B) (initial : World P A D) (t : Tree B)
    (branches : Branches B P A D) (schedule : Schedule B)
    (hwf : WellFormed roster t) :
    fullMachineEq roster
      (runTreePrefix cfg boundaries initial t branches schedule)
      (runTreePrefix cfg boundaries initial (Tree.empty.fork t) branches schedule) = true :=
  regrouping cfg boundaries roster initial t _ branches schedule hwf
    ((empty_unit_left roster t).mpr hwf)

theorem encode_leaf (b : B) : encodeOne (Tree.leaf b) b = [] := rfl

theorem resolve_encode_of_count (tree : Tree B) (b : B) (h : Tree.count tree b = 1) :
    resolve tree (encodeOne tree b) = .ok () ∧ leafOf tree (encodeOne tree b) = some b := by
  induction tree with
  | empty => simp [count_empty] at h
  | leaf x =>
    have hx : x = b := by
      simp [count_leaf] at h
      by_cases hx : x = b
      · exact hx
      · simp [hx] at h
    subst hx
    simp [encodeOne, resolve, leafOf]
  | fork left right ihL ihR =>
    simp [count_fork] at h
    by_cases hmem : b ∈ Tree.leaves left
    · have hL : Tree.count left b = 1 := by
        have : 0 < Tree.count left b := (mem_leaves_iff_count_pos _ _).mp hmem
        omega
      obtain ⟨hres, hleaf⟩ := ihL hL
      have hdec : decide (b ∈ Tree.leaves left) = true := decide_eq_true hmem
      constructor
      · simp [encodeOne, hdec, resolve, chooseChild, hres, Except.mapError]
      · simp [encodeOne, hdec, leafOf, chooseChild, hleaf]
    · have hL0 : Tree.count left b = 0 := by
        have : ¬ 0 < Tree.count left b := by
          intro hp; exact hmem ((mem_leaves_iff_count_pos _ _).mpr hp)
        omega
      have hR : Tree.count right b = 1 := by omega
      obtain ⟨hres, hleaf⟩ := ihR hR
      have hdec : decide (b ∈ Tree.leaves left) = false := decide_eq_false hmem
      constructor
      · simp [encodeOne, hdec, resolve, chooseChild, hres, Except.mapError]
      · simp [encodeOne, hdec, leafOf, chooseChild, hleaf]

theorem decodeFrom_ok_shift (tree : Tree B) (idx idx' : Nat) (paths : List Path)
    (good : List B) (h : decodeFrom tree idx paths = .ok good) :
    decodeFrom tree idx' paths = .ok good := by
  induction paths generalizing idx idx' good with
  | nil =>
    simpa [decodeFrom] using h
  | cons p ps ih =>
    simp [decodeFrom] at h ⊢
    cases hres : resolve tree p with
    | error e => simp [hres] at h
    | ok u =>
      cases hleaf : leafOf tree p with
      | none => simp [hres, hleaf] at h
      | some tok =>
        simp [hres, hleaf] at h ⊢
        cases hrest : decodeFrom tree (idx + 1) ps with
        | error e => simp [hrest] at h
        | ok decoded =>
          simp [hrest] at h
          cases h
          simp [ih (idx + 1) (idx' + 1) decoded hrest, consDecoded]

theorem decodeFrom_cons_ok (tree : Tree B) (idx : Nat) (path : Path) (rest : List Path)
    (tok : B) (decoded : List B)
    (hres : resolve tree path = .ok ())
    (hleaf : leafOf tree path = some tok)
    (hrest : decodeFrom tree (idx + 1) rest = .ok decoded) :
    decodeFrom tree idx (path :: rest) = .ok (tok :: decoded) := by
  simp [decodeFrom, hres, hleaf, hrest, consDecoded]

theorem decode_encode_cons (tree : Tree B) (b : B) (rest : Schedule B)
    (hb : Tree.count tree b = 1)
    (hrest : decodePaths tree (encodePaths tree rest) = .ok rest) :
    decodePaths tree (encodePaths tree (b :: rest)) = .ok (b :: rest) := by
  have ⟨hres, hleaf⟩ := resolve_encode_of_count tree b hb
  have hshift : decodeFrom tree 1 (encodePaths tree rest) = .ok rest :=
    decodeFrom_ok_shift tree 0 1 _ _ (by simpa [decodePaths] using hrest)
  simpa [encodePaths, decodePaths] using
    decodeFrom_cons_ok tree 0 (encodeOne tree b) (encodePaths tree rest) b rest
      hres hleaf hshift

theorem decode_encode (tree : Tree B) (roster : Roster B) (schedule : Schedule B)
    (hwf : WellFormed roster tree) :
    decodePaths tree (encodePaths tree schedule) = .ok schedule := by
  induction schedule with
  | nil => simp [encodePaths, decodePaths, decodeFrom]
  | cons b rest ih =>
    exact decode_encode_cons tree b rest (wellFormed_count roster tree hwf b) ih

theorem decode_append_error_offset (tree : Tree B) (idx : Nat) (prePaths suffix : List Path)
    (good : List B) (err : PathFailure)
    (hpre : decodeFrom tree idx prePaths = .ok good)
    (hsuf : decodeFrom tree (idx + prePaths.length) suffix = .error err) :
    decodeFrom tree idx (prePaths ++ suffix) = .error err := by
  induction prePaths generalizing idx good with
  | nil =>
    simp [decodeFrom] at hpre
    cases hpre
    simpa using hsuf
  | cons p ps ih =>
    simp [decodeFrom] at hpre ⊢
    cases hres : resolve tree p with
    | error e => simp [hres] at hpre
    | ok u =>
      cases hleaf : leafOf tree p with
      | none => simp [hres, hleaf] at hpre
      | some tok =>
        simp [hres, hleaf] at hpre ⊢
        cases hrest : decodeFrom tree (idx + 1) ps with
        | error e =>
          simp [hrest] at hpre
        | ok decoded =>
          simp [hrest] at hpre
          cases hpre
          have hsuf' : decodeFrom tree (idx + 1 + ps.length) suffix = .error err := by
            convert hsuf using 2
            simp [List.length_cons]
            ac_rfl
          have hih := ih (idx + 1) decoded hrest hsuf'
          simp [hih]

end DefiKernel.Nary.Tree
