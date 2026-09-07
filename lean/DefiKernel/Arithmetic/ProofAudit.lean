import DefiKernel.Arithmetic.Word
import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
import DefiKernel.Arithmetic.Fees
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Arithmetic.Reference
import DefiKernel.Arithmetic.RuntimeAudit
import DefiKernel.AxiomAudit

/-! Enumerate imported arithmetic declarations by module provenance. This root has no helpers. -/
#audit_axioms DefiKernel.Arithmetic
