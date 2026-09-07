import DefiKernel.Atomic.Audit
import DefiKernel.Atomic.PolicyProofs
import DefiKernel.Atomic.Admission
import DefiKernel.Atomic.Soundness
import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Settlement
import DefiKernel.Atomic.Preservation
import DefiKernel.Atomic.Correspondence
import DefiKernel.Atomic.InvariantFixtures
import DefiKernel.AxiomAudit

/-! Enumerate every imported Atomic theorem and supplemental declaration by actual module
provenance. Runtime comparisons remain distinct from universal proofs and finite instances. -/
#audit_axioms DefiKernel.Atomic
