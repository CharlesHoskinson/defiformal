import DefiKernel.Interface.Audit
import DefiKernel.Interface.Accounting
import DefiKernel.Interface.AccountingInterleaving
import DefiKernel.Interface.Preservation
import DefiKernel.Interface.TypedPreservation
import DefiKernel.Interface.BindingTransport
import DefiKernel.Interface.BindingPreservation
import DefiKernel.Interface.BindingResolution
import DefiKernel.Interface.Fixtures
import DefiKernel.AxiomAudit

/-! Audit every imported Interface declaration by module provenance. Generic proofs,
concrete instances, counterexamples and executable comparisons have distinct scopes. -/
#audit_axioms DefiKernel.Interface
