import DefiKernel.Metatheory.Audit
import DefiKernel.Metatheory.Contexts
import DefiKernel.Metatheory.Configuration
import DefiKernel.Metatheory.ConfigurationGroups
import DefiKernel.Metatheory.OperatorLifting
import DefiKernel.Metatheory.ConfigurationFixtures
import DefiKernel.AxiomAudit

/-! Audit all imported Metatheory declarations by module provenance. Generic laws, concrete
instances, and executable comparisons have distinct scopes in the evidence inventory. -/
#audit_axioms DefiKernel.Metatheory
