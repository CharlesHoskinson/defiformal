import WorkflowControlProofs

namespace RationalWorkflow

theorem r6_canonical : R6Canonical := by
  intro state calls valid length
  have spec := runRaw_spec state calls valid
  have complete : (runRaw state calls).failure = none → (runRaw state calls).committed = 4 := by
    intro h
    simpa [runRaw, length] using runWith_complete rawExecute state calls h
  have events := rawSpec_history spec
  refine ⟨spec, ?_, ?_⟩
  · intro h
    refine ⟨by simp [atomicRaw, h], ?_, ?_⟩
    · simpa [atomicRaw, h] using complete h
    · obtain ⟨es, history, count⟩ := events
      refine ⟨es, ?_, ?_⟩
      · simpa [atomicRaw, h] using history
      · exact count.trans (complete h)
  · intro reason index h
    simp [atomicRaw, h]

#print axioms r6_canonical
end RationalWorkflow
