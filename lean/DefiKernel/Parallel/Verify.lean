import DefiKernel.Parallel.Audit
import DefiKernel.Parallel.Dependency.Fixtures
import DefiKernel.Parallel.PreservationFixtures
import DefiKernel.AxiomAudit

/-! Every imported Parallel theorem and supplemental declaration is checked by module provenance.
The runtime inventory is bounded evidence; this imported audit checks transitive proof axioms. -/
#audit_axioms DefiKernel.Parallel
