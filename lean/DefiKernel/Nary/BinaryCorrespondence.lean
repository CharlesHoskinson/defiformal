import DefiKernel.Nary.Observation

/-! Exact specialization of the finite n-ary dispatcher to ordered `[left, right]`.
Conversions and diagnostic projection are the Observation executables; this module
proves they simulate the existing binary operator. No participant-tree regrouping
or cross-schedule order equivalence is claimed. -/
namespace DefiKernel.Nary
open Typed Composition Parallel

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

omit [Fintype P] [Fintype A] [Fintype D] in
theorem binaryParticipants_order :
    (binaryParticipants : Roster BranchId).order = [.left, .right] :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem ofBinaryAttempt_toBinary (attempt : Attempt BranchId P A D) :
    ofBinaryAttempt (toBinaryAttempt attempt) = attempt := by
  cases attempt
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinaryAttempt_ofBinary (attempt : Interleaving.Attempt P A D) :
    toBinaryAttempt (ofBinaryAttempt attempt) = attempt := by
  cases attempt
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem ofBinaryAttempts_toBinary (attempts : List (Attempt BranchId P A D)) :
    ofBinaryAttempts (toBinaryAttempts attempts) = attempts := by
  simp only [ofBinaryAttempts, toBinaryAttempts]
  induction attempts with
  | nil => rfl
  | cons a as ih =>
    simp [ofBinaryAttempt_toBinary, ih]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinaryAttempts_ofBinary (attempts : List (Interleaving.Attempt P A D)) :
    toBinaryAttempts (ofBinaryAttempts attempts) = attempts := by
  simp only [ofBinaryAttempts, toBinaryAttempts]
  induction attempts with
  | nil => rfl
  | cons a as ih =>
    simp [toBinaryAttempt_ofBinary, ih]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem ofBinaryLocals_toBinary (locals : BranchId → Interleaving.LocalState P A D) :
    ofBinaryLocals (locals .left) (locals .right) = locals := by
  funext b
  cases b <;> rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem ofBinaryBranches_toBinary (branches : Branches BranchId P A D) :
    ofBinaryBranches (binaryLeft branches) (binaryRight branches) = branches := by
  funext b
  cases b <;> rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem ofBinaryMachine_toBinary (m : Machine BranchId P A D) :
    ofBinaryMachine (toBinaryMachine m) = m := by
  cases m
  simp [ofBinaryMachine, toBinaryMachine, ofBinaryLocals_toBinary, ofBinaryAttempts_toBinary]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinaryMachine_ofBinary (m : Interleaving.Machine P A D) :
    toBinaryMachine (ofBinaryMachine m) = m := by
  cases m
  simp [ofBinaryMachine, toBinaryMachine, ofBinaryLocals]
  exact toBinaryAttempts_ofBinary _

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_local (m : Machine BranchId P A D) (b : BranchId) :
    (toBinaryMachine m).local b = m.locals b := by
  cases b <;> rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_world (m : Machine BranchId P A D) :
    (toBinaryMachine m).world = m.world :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_attempts (m : Machine BranchId P A D) :
    (toBinaryMachine m).attempts = toBinaryAttempts m.attempts :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinaryBoundaries_id (boundaries : Boundaries BranchId P A D) :
    toBinaryBoundaries boundaries = boundaries :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem existingBinaryAdmit_eq (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    existingBinaryAdmit cfg boundaries branches schedule =
      Interleaving.admit cfg boundaries (branches .left) (branches .right) schedule :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem selectBranch_binary (branches : Branches BranchId P A D) (b : BranchId) :
    Interleaving.selectBranch (binaryLeft branches) (binaryRight branches) b =
      branches b := by
  cases b <;> rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_setLocal (m : Machine BranchId P A D) (b : BranchId)
    (localState : Interleaving.LocalState P A D) :
    toBinaryMachine (m.setLocal b localState) =
      (toBinaryMachine m).setLocal b localState := by
  cases b <;> simp [toBinaryMachine, Machine.setLocal, Interleaving.Machine.setLocal,
    toBinaryAttempts]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_with_attempts (m : Machine BranchId P A D)
    (attempts : List (Attempt BranchId P A D)) :
    toBinaryMachine { m with attempts := attempts } =
      { toBinaryMachine m with attempts := toBinaryAttempts attempts } :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_with_world_attempts (m : Machine BranchId P A D)
    (world : World P A D) (attempts : List (Attempt BranchId P A D)) :
    toBinaryMachine { m with world := world, attempts := attempts } =
      { toBinaryMachine m with world := world, attempts := toBinaryAttempts attempts } :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_skip (m : Machine BranchId P A D) (b : BranchId) :
    toBinaryMachine (m.skip b) = (toBinaryMachine m).skip b := by
  simp [Machine.skip, Interleaving.Machine.skip, toBinary_setLocal, toBinary_local]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_refuse (m : Machine BranchId P A D) (b : BranchId)
    (inv : Invocation P A D) (reason : Composition.Failure) :
    toBinaryMachine (m.refuse b inv reason) =
      (toBinaryMachine m).refuse b inv reason := by
  have hown : m.locals b = (toBinaryMachine m).local b := (toBinary_local m b).symm
  simp only [Machine.refuse, Interleaving.Machine.refuse]
  simp [hown, toBinary_with_attempts, toBinary_setLocal, toBinaryAttempts, toBinaryAttempt,
    List.map_append, toBinary_world, toBinary_attempts]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_accept (m : Machine BranchId P A D) (b : BranchId)
    (inv : Invocation P A D) (result : StepResult P A D) :
    toBinaryMachine (m.accept b inv result) =
      (toBinaryMachine m).accept b inv result := by
  have hown : m.locals b = (toBinaryMachine m).local b := (toBinary_local m b).symm
  have hr : { result with receipt := result.receipt } = result :=
    accept_stored_receipt result
  simp only [Machine.accept, Interleaving.Machine.accept]
  simp [hown, hr, toBinary_with_world_attempts, toBinary_setLocal, toBinaryAttempts,
    toBinaryAttempt, List.map_append, toBinary_world, toBinary_attempts]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem toBinary_start (initial : World P A D) :
    toBinaryMachine (start (B := BranchId) initial) = Interleaving.start initial := by
  simp [toBinaryMachine, start, Interleaving.start, toBinaryAttempts]

theorem toBinary_advance (cfg : Config P A D) (boundaries : Boundaries BranchId P A D)
    (branches : Branches BranchId P A D) (m : Machine BranchId P A D) (b : BranchId) :
    toBinaryMachine (advance cfg boundaries branches m b) =
      existingBinaryAdvance cfg boundaries branches (toBinaryMachine m) b := by
  simp only [existingBinaryAdvance, toBinaryBoundaries, binaryLeft, binaryRight]
  have hloc : (toBinaryMachine m).local b = m.locals b := toBinary_local m b
  have hselB :
      Interleaving.selectBranch (branches .left) (branches .right) b = branches b :=
    selectBranch_binary branches b
  unfold advance Interleaving.advance
  rw [hloc, hselB, toBinary_world]
  cases hf : (m.locals b).failure with
  | some _ =>
    simp [Option.isSome, hf, toBinary_skip]
  | none =>
    simp [Option.isSome, hf]
    cases hsel : (branches b)[(m.locals b).consumed]? with
    | none =>
      simp [hsel, toBinary_skip]
    | some inv =>
      simp [hsel]
      cases he : executeStep cfg (boundaries b (m.locals b).nextIndex)
          (m.locals b).nextIndex (m.locals b).outputs (.invoke inv) m.world with
      | error reason =>
        simp [he, toBinary_refuse]
      | ok result =>
        simp [he, toBinary_accept]

theorem toBinary_advance_failed (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (b : BranchId)
    (failure : LocatedFailure P A D)
    (h : (m.locals b).failure = some failure) :
    toBinaryMachine (advance cfg boundaries branches m b) =
      (toBinaryMachine m).skip b := by
  have hs : (m.locals b).failure.isSome = true := by simp [h]
  simp [advance, h, hs, toBinary_skip]

theorem toBinary_advance_exhausted (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (b : BranchId)
    (active : (m.locals b).failure = none)
    (absent : (branches b)[(m.locals b).consumed]? = none) :
    toBinaryMachine (advance cfg boundaries branches m b) =
      (toBinaryMachine m).skip b := by
  have hs : (m.locals b).failure.isSome = false := by simp [active]
  simp [advance, active, hs, absent, toBinary_skip]

theorem toBinary_advance_refused (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure)
    (active : (m.locals b).failure = none)
    (selected : (branches b)[(m.locals b).consumed]? = some inv)
    (rejected : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .error reason) :
    toBinaryMachine (advance cfg boundaries branches m b) =
      (toBinaryMachine m).refuse b inv reason := by
  have hs : (m.locals b).failure.isSome = false := by simp [active]
  simp [advance, active, hs, selected, rejected, toBinary_refuse]

theorem toBinary_advance_accepted (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D)
    (active : (m.locals b).failure = none)
    (selected : (branches b)[(m.locals b).consumed]? = some inv)
    (executed : executeStep cfg (boundaries b (m.locals b).nextIndex) (m.locals b).nextIndex
      (m.locals b).outputs (.invoke inv) m.world = .ok result) :
    toBinaryMachine (advance cfg boundaries branches m b) =
      (toBinaryMachine m).accept b inv result := by
  have hs : (m.locals b).failure.isSome = false := by simp [active]
  simp [advance, active, hs, selected, executed, toBinary_accept]

theorem continueRun_three_chunk (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (s t u : Schedule B) :
    continueRun cfg boundaries branches m (s ++ t ++ u) =
      continueRun cfg boundaries branches
        (continueRun cfg boundaries branches
          (continueRun cfg boundaries branches m s) t) u := by
  rw [continueRun_append, continueRun_append]

theorem continueRun_chunk_assoc (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : Machine B P A D) (s t u : Schedule B) :
    continueRun cfg boundaries branches
        (continueRun cfg boundaries branches m (s ++ t)) u =
      continueRun cfg boundaries branches
        (continueRun cfg boundaries branches m s) (t ++ u) := by
  rw [← continueRun_append, ← continueRun_append, List.append_assoc]

theorem existingBinaryContinue_cons (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Interleaving.Machine P A D) (b : BranchId) (rest : Schedule BranchId) :
    existingBinaryContinue cfg boundaries branches m (b :: rest) =
      existingBinaryContinue cfg boundaries branches
        (existingBinaryAdvance cfg boundaries branches m b) rest :=
  rfl

theorem toBinary_continueRun (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (schedule : Schedule BranchId) :
    toBinaryMachine (continueRun cfg boundaries branches m schedule) =
      existingBinaryContinue cfg boundaries branches (toBinaryMachine m) schedule := by
  induction schedule generalizing m with
  | nil =>
    simp [continueRun, existingBinaryContinue, Interleaving.continueRun]
  | cons b rest ih =>
    rw [continueRun_cons, existingBinaryContinue_cons, ← toBinary_advance, ih]

theorem toBinary_runPrefix (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    toBinaryMachine (runPrefix cfg boundaries initial branches schedule) =
      existingBinaryPrefix cfg boundaries initial branches schedule := by
  simp [runPrefix, existingBinaryPrefix, Interleaving.runPrefix, toBinary_continueRun,
    toBinary_start, existingBinaryContinue, toBinaryBoundaries, binaryLeft, binaryRight]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem Complete_binary (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    Complete branches schedule ↔
      Interleaving.Complete (binaryLeft branches) (binaryRight branches) schedule := by
  constructor
  · intro h
    exact ⟨h .left, h .right⟩
  · intro h b
    cases b with
    | left => exact h.1
    | right => exact h.2

omit [Fintype P] [Fintype A] [Fintype D] in
theorem checkCountsFrom_left_right (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    checkCountsFrom branches schedule [.left, .right] =
      if schedule.count .left = (branches .left).length then
        if schedule.count .right = (branches .right).length then
          .ok ⟨⟩
        else
          .error ⟨.right, (branches .right).length, schedule.count .right⟩
      else
        .error ⟨.left, (branches .left).length, schedule.count .left⟩ := by
  by_cases hl : schedule.count .left = (branches .left).length
  · by_cases hr : schedule.count .right = (branches .right).length
    · simp [checkCountsFrom, hl, hr]
    · simp [checkCountsFrom, hl, hr]
  · simp [checkCountsFrom, hl]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem projectScheduleMismatch_eq (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) (mismatch : ScheduleMismatch BranchId) :
    projectScheduleMismatch branches schedule mismatch =
      ⟨(branches .left).length, schedule.count .left,
        (branches .right).length, schedule.count .right⟩ :=
  rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem checkSchedule_ok_binary (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    checkSchedule binaryParticipants branches schedule = .ok ⟨⟩ ↔
      Interleaving.checkSchedule (branches .left).length (branches .right).length schedule =
        .ok ⟨⟩ := by
  simp only [checkSchedule, binaryParticipants, Interleaving.checkSchedule_ok_iff,
    checkCountsFrom_ok_iff]
  constructor
  · intro h
    exact ⟨h .left (by simp), h .right (by simp)⟩
  · intro h b hb
    simp at hb
    rcases hb with hL | hR
    · simp [hL, h.1]
    · simp [hR, h.2]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem checkSchedule_error_project (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) (mismatch : ScheduleMismatch BranchId)
    (h : checkSchedule binaryParticipants branches schedule = .error mismatch) :
    Interleaving.checkSchedule (branches .left).length (branches .right).length schedule =
      .error (projectScheduleMismatch branches schedule mismatch) := by
  have hok :
      ¬ (schedule.count .left = (branches .left).length ∧
        schedule.count .right = (branches .right).length) := by
    intro hall
    have hok' : checkSchedule binaryParticipants branches schedule = .ok ⟨⟩ :=
      (checkSchedule_ok_binary branches schedule).mpr
        ((Interleaving.checkSchedule_ok_iff _ _ _).mpr hall)
    cases h.symm.trans hok'
  rw [projectScheduleMismatch_eq]
  exact ((Interleaving.checkSchedule_error_iff _ _ _ _).mpr ⟨hok, rfl⟩)

omit [Fintype P] [Fintype A] [Fintype D] in
theorem checkSchedule_project (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    match checkSchedule binaryParticipants branches schedule with
    | .ok _ =>
      Interleaving.checkSchedule (branches .left).length (branches .right).length
        schedule = .ok ⟨⟩
    | .error mismatch =>
      Interleaving.checkSchedule (branches .left).length (branches .right).length
        schedule = .error (projectScheduleMismatch branches schedule mismatch) := by
  cases h : checkSchedule binaryParticipants branches schedule with
  | ok _ =>
    exact (checkSchedule_ok_binary branches schedule).mp h
  | error mismatch =>
    exact checkSchedule_error_project branches schedule mismatch h

theorem analyzeAll_cons_ok (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (b : B) (rest : List B) (fp : Parallel.Footprint P A D)
    (h : Parallel.analyzeBranch cfg (boundaries b) (branches b) = .ok fp) :
    analyzeAll cfg boundaries branches (b :: rest) =
      match analyzeAll cfg boundaries branches rest with
      | .error reason => .error reason
      | .ok footprints => .ok (⟨b, fp⟩ :: footprints) := by
  nth_rw 1 [analyzeAll]
  rw [h]
  simp [Except.mapError]
  cases analyzeAll cfg boundaries branches rest <;> rfl

theorem analyzeAll_binary (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D) :
    analyzeAll cfg boundaries branches binaryParticipants.order =
      match Parallel.analyzeBranch cfg (boundaries .left) (branches .left) with
      | .error failure => .error (.structural .left failure)
      | .ok lf =>
        match Parallel.analyzeBranch cfg (boundaries .right) (branches .right) with
        | .error failure => .error (.structural .right failure)
        | .ok rf => .ok [⟨.left, lf⟩, ⟨.right, rf⟩] := by
  simp only [binaryParticipants_order]
  cases hL : Parallel.analyzeBranch cfg (boundaries .left) (branches .left) with
  | error failure =>
    simp [analyzeAll_error_head cfg boundaries branches .left [.right] failure hL]
  | ok lf =>
    rw [analyzeAll_cons_ok cfg boundaries branches .left [.right] lf hL]
    cases hR : Parallel.analyzeBranch cfg (boundaries .right) (branches .right) with
    | error failure =>
      simp [analyzeAll, hR, Except.mapError]
    | ok rf =>
      simp [analyzeAll, hR, Except.mapError]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem projectAdmitSuccess_pair (lf rf : Parallel.Footprint P A D) :
    projectAdmitSuccess [⟨.left, lf⟩, ⟨.right, rf⟩] = some (lf, rf) :=
  rfl

theorem admit_invalid_catalog_binary (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    admit cfg binaryParticipants boundaries branches schedule = .error .configuration ∧
      existingBinaryAdmit cfg boundaries branches schedule = .error .configuration := by
  refine ⟨admit_invalid_catalog cfg binaryParticipants boundaries branches schedule h, ?_⟩
  simp [existingBinaryAdmit_eq]
  unfold Interleaving.admit
  simp only [bind, Except.bind, pure, Except.pure, h]
  split
  · simp [throw_error]
  · contradiction

theorem admit_correspondence (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    existingBinaryAdmit cfg boundaries branches schedule =
      match admit cfg binaryParticipants boundaries branches schedule with
      | .error reason => .error (projectAdmissionFailure branches schedule reason)
      | .ok fps =>
        match projectAdmitSuccess fps with
        | some pair => .ok pair
        | none => .error .configuration := by
  simp [existingBinaryAdmit_eq]
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · have hnf : (!validateCatalog cfg.registry cfg.catalog) = false := by simp [hv]
    unfold admit Interleaving.admit
    simp only [hnf, bind, Except.bind, pure, Except.pure]
    rw [analyzeAll_binary]
    cases hL : Parallel.analyzeBranch cfg (boundaries .left) (branches .left) with
    | error failure =>
      simp [hL, Except.mapError, projectAdmissionFailure]
    | ok lf =>
      simp [hL, Except.mapError]
      cases hR : Parallel.analyzeBranch cfg (boundaries .right) (branches .right) with
      | error failure =>
        simp [hR, Except.mapError, projectAdmissionFailure]
      | ok rf =>
        simp [hR, Except.mapError, projectAdmitSuccess]
        cases hs : checkSchedule binaryParticipants branches schedule with
        | error mismatch =>
          have hb := checkSchedule_error_project branches schedule mismatch hs
          simp [hs, hb, Except.mapError, projectAdmissionFailure]
        | ok token =>
          have hb := (checkSchedule_ok_binary branches schedule).mp hs
          simp [hs, hb, Except.mapError, projectAdmitSuccess]
  · have ⟨hn, hi⟩ :=
      admit_invalid_catalog_binary cfg boundaries branches schedule (by simp [hv])
    simp [existingBinaryAdmit_eq] at hi
    simp [hn, hi, projectAdmissionFailure]

theorem admit_ok_projected (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) (fps : List (BranchId × Parallel.Footprint P A D))
    (h : admit cfg binaryParticipants boundaries branches schedule = .ok fps) :
    ∃ pair, projectAdmitSuccess fps = some pair := by
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · have hnf : (!validateCatalog cfg.registry cfg.catalog) = false := by simp [hv]
    unfold admit at h
    simp [hnf, bind, Except.bind, pure, Except.pure] at h
    cases hA : analyzeAll cfg boundaries branches binaryParticipants.order with
    | error reason =>
      rw [hA] at h
      cases h
    | ok fps' =>
      rw [hA] at h
      cases hs : checkSchedule binaryParticipants branches schedule with
      | error mismatch =>
        rw [hs] at h
        simp [Except.mapError] at h
      | ok token =>
        rw [hs] at h
        simp [Except.mapError] at h
        cases h
        have ha := analyzeAll_binary cfg boundaries branches
        rw [ha] at hA
        cases hL : Parallel.analyzeBranch cfg (boundaries .left) (branches .left) with
        | error failure =>
          simp [hL] at hA
        | ok lf =>
          simp [hL] at hA
          cases hR : Parallel.analyzeBranch cfg (boundaries .right) (branches .right) with
          | error failure =>
            simp [hR] at hA
          | ok rf =>
            simp [hR] at hA
            cases hA
            exact ⟨(lf, rf), rfl⟩
  · have hfalse :=
      admit_invalid_catalog cfg binaryParticipants boundaries branches schedule
        (by simp [hv])
    simp [hfalse] at h

theorem existingBinaryRun_eq (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    existingBinaryRun cfg boundaries initial branches schedule =
      Interleaving.runInterleaving cfg boundaries initial
        (branches .left) (branches .right) schedule :=
  rfl

theorem existingBinaryPrefix_eq (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    existingBinaryPrefix cfg boundaries initial branches schedule =
      Interleaving.runPrefix cfg boundaries initial
        (branches .left) (branches .right) schedule :=
  rfl

theorem toBinary_runNary (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    toBinaryResult branches
        (runNary cfg binaryParticipants boundaries initial branches schedule) =
      existingBinaryRun cfg boundaries initial branches schedule := by
  rw [existingBinaryRun_eq]
  unfold runNary Interleaving.runInterleaving
  rw [← existingBinaryAdmit_eq, admit_correspondence]
  cases hn : admit cfg binaryParticipants boundaries branches schedule with
  | error reason =>
    simp [toBinaryResult]
  | ok footprints =>
    simp [toBinaryResult]
    cases hproj : projectAdmitSuccess footprints with
    | some pair =>
      simp [toBinary_runPrefix, existingBinaryPrefix_eq]
    | none =>
      obtain ⟨pair, hpair⟩ :=
        admit_ok_projected cfg boundaries branches schedule footprints hn
      simp [hpair] at hproj

theorem interleavingAttemptEq_iff (left right : Interleaving.Attempt P A D) :
    interleavingAttemptEq left right = true ↔ left = right := by
  simp [interleavingAttemptEq, attemptEq_iff]
  cases left
  cases right
  simp [ofBinaryAttempt, Interleaving.Attempt.mk.injEq]

theorem interleavingAttemptsEq_iff (left right : List (Interleaving.Attempt P A D)) :
    interleavingAttemptsEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [interleavingAttemptsEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [interleavingAttemptsEq]
    | cons other rest =>
      simp [interleavingAttemptsEq, interleavingAttemptEq_iff, ih]

theorem interleavingMachineEq_iff (left right : Interleaving.Machine P A D) :
    interleavingMachineEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [interleavingMachineEq, Bool.and_eq_true, worldEq_iff, localEq_iff,
    interleavingAttemptsEq_iff, Interleaving.Machine.mk.injEq, and_assoc]

theorem interleavingResultEq_iff (left right : Interleaving.Result P A D) :
    interleavingResultEq left right = true ↔ left = right := by
  cases left with
  | refused lr lw ls =>
    cases right with
    | refused rr rw rs =>
      simp [interleavingResultEq, Bool.and_eq_true, worldEq_iff,
        Interleaving.Result.refused.injEq, and_assoc]
    | executed _ _ => simp [interleavingResultEq]
  | executed ls lm =>
    cases right with
    | refused _ _ _ => simp [interleavingResultEq]
    | executed rs rm =>
      simp [interleavingResultEq, interleavingMachineEq_iff,
        Interleaving.Result.executed.injEq]

theorem binaryMachineAgrees_iff (nary : Machine BranchId P A D)
    (binary : Interleaving.Machine P A D) :
    binaryMachineAgrees nary binary = true ↔ toBinaryMachine nary = binary := by
  simp [binaryMachineAgrees, interleavingMachineEq_iff]

theorem binaryAdvanceAgrees_true (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (b : BranchId) :
    binaryAdvanceAgrees cfg boundaries branches m b = true := by
  simp [binaryAdvanceAgrees, binaryMachineAgrees_iff, toBinary_advance]

theorem binaryContinueAgrees_true (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (m : Machine BranchId P A D) (schedule : Schedule BranchId) :
    binaryContinueAgrees cfg boundaries branches m schedule = true := by
  simp [binaryContinueAgrees, binaryMachineAgrees_iff, toBinary_continueRun]

theorem binaryPrefixAgrees_true (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    binaryPrefixAgrees cfg boundaries initial branches schedule = true := by
  simp [binaryPrefixAgrees, binaryMachineAgrees_iff, toBinary_runPrefix]

theorem binaryRunAgrees_true (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (initial : World P A D)
    (branches : Branches BranchId P A D) (schedule : Schedule BranchId) :
    binaryRunAgrees cfg boundaries initial branches schedule = true := by
  simp [binaryRunAgrees, binaryResultAgrees, interleavingResultEq_iff, toBinary_runNary]

theorem binaryAdmitAgrees_true (cfg : Config P A D)
    (boundaries : Boundaries BranchId P A D) (branches : Branches BranchId P A D)
    (schedule : Schedule BranchId) :
    binaryAdmitAgrees cfg boundaries branches schedule = true := by
  unfold binaryAdmitAgrees
  rw [admit_correspondence]
  cases hn : admit cfg binaryParticipants boundaries branches schedule with
  | error reason =>
    simp
  | ok footprints =>
    cases hproj : projectAdmitSuccess footprints with
    | some pair =>
      simp [hproj]
    | none =>
      obtain ⟨pair, hpair⟩ :=
        admit_ok_projected cfg boundaries branches schedule footprints hn
      simp [hpair] at hproj

end DefiKernel.Nary
