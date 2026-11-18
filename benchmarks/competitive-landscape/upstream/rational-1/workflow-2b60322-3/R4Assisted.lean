import WorkflowControlProofs

namespace RationalWorkflow

theorem r4_canonical : R4Canonical := by
  intro state calls valid length
  have spec := runRaw_spec state calls valid
  refine ⟨spec, ?_, ?_, ?_, rawSpec_history spec⟩
  · simpa [runRaw, length] using runWith_le rawExecute state calls
  · intro h
    simpa [runRaw, length] using runWith_complete rawExecute state calls h
  · intro reason index h
    simpa [runRaw, length] using runWith_failed rawExecute state calls reason index h

#print axioms r4_canonical
end RationalWorkflow
