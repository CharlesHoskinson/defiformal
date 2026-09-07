import DefiKernel.Interleaving.Audit
import DefiKernel.Interleaving.Trace
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.InterferenceFixtures
import DefiKernel.Interleaving.Recovery
import DefiKernel.AxiomAudit

/-! Audit every imported Interleaving theorem and supplemental declaration by module provenance.
Runtime comparisons and generic proofs remain separate evidence classes. -/
#audit_axioms DefiKernel.Interleaving
