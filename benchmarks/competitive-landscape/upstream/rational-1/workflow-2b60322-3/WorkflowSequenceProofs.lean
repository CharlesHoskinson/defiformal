import WorkflowControl

namespace RationalWorkflow

theorem runCalls_cons_success (state post : PublicState) (call : Call) (calls : List Call)
    (h : execute state call = .success post) :
    runCalls state (call :: calls) = (runCalls post calls).bump := by
  simp [runCalls, runWith, h]

theorem runCalls_cons_refused (state post : PublicState) (call : Call) (calls : List Call)
    (reason : Reason) (h : execute state call = .refused reason post) :
    runCalls state (call :: calls) = ⟨state, some (reason, 0), 0⟩ := by
  simp [runCalls, runWith, h]

theorem runWith_le {Instruction : Type} (step : PublicState → Instruction → Result)
    (state : PublicState) (calls : List Instruction) :
    (runWith step state calls).committed ≤ calls.length := by
  induction calls generalizing state with
  | nil => simp [runWith]
  | cons call calls ih =>
    cases h : step state call with
    | refused reason post => simp [runWith, h]
    | success post => simpa [runWith, h, SequenceResult.bump] using Nat.add_le_add_right (ih post) 1

theorem runWith_complete {Instruction : Type} (step : PublicState → Instruction → Result)
    (state : PublicState) (calls : List Instruction)
    (h : (runWith step state calls).failure = none) :
    (runWith step state calls).committed = calls.length := by
  induction calls generalizing state with
  | nil => rfl
  | cons call calls ih =>
    cases hs : step state call with
    | refused reason post => simp [runWith, hs] at h
    | success post =>
      have ht : (runWith step post calls).failure = none := by
        simpa [runWith, hs, SequenceResult.bump] using h
      simp [runWith, hs, SequenceResult.bump, ih post ht]

theorem runWith_failed {Instruction : Type} (step : PublicState → Instruction → Result)
    (state : PublicState) (calls : List Instruction) (reason : Reason) (index : Nat)
    (h : (runWith step state calls).failure = some (reason, index)) :
    (runWith step state calls).committed = index ∧ index < calls.length ∧
    ∀ suffix, runWith step state (calls ++ suffix) = runWith step state calls := by
  induction calls generalizing state reason index with
  | nil => simp [runWith] at h
  | cons call calls ih =>
    cases hs : step state call with
    | refused why post =>
      have he : why = reason ∧ 0 = index := by simpa [runWith, hs] using h
      rcases he with ⟨rfl, rfl⟩
      simp [runWith, hs]
    | success post =>
      cases ht : (runWith step post calls).failure with
      | none => simp [runWith, hs, SequenceResult.bump, ht] at h
      | some pair =>
        rcases pair with ⟨why, atIndex⟩
        have he : why = reason ∧ atIndex + 1 = index := by
          simpa [runWith, hs, SequenceResult.bump, ht] using h
        rcases he with ⟨rfl, rfl⟩
        obtain ⟨hc, hi, suffix⟩ := ih post why atIndex ht
        refine ⟨?_, ?_, ?_⟩
        · simp [runWith, hs, SequenceResult.bump, hc]
        · simpa using Nat.succ_lt_succ hi
        · intro tail
          simp only [List.cons_append, runWith, hs]
          exact congrArg SequenceResult.bump (suffix tail)

end RationalWorkflow
