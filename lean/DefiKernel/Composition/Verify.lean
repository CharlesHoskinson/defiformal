import DefiKernel.Composition.Audit
import DefiKernel.AxiomAudit

/-! Imported composition declarations and transitive dependencies are audited separately
from the bounded runtime inventory. Declarations added after this command are not covered. -/
#audit_axioms DefiKernel.Composition
