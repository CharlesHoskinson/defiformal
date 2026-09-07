import DefiKernel.Typed.Audit
import DefiKernel.AxiomAudit

/-! Audit the actual imported Typed closure: theorem declarations and supplemental
definitions, opaque constants and axioms. This is distinct from bounded runtime
checks and does not cover declarations added after this command. -/
#audit_axioms DefiKernel.Typed
