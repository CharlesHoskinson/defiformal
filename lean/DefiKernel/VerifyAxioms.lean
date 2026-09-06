import DefiKernel.Audit
import DefiKernel.ContractAudit
import DefiKernel.AxiomAudit

/-!
Fresh automatic axiom audit of theorem declarations from the imported pilot modules.
The module-prefix scope includes imported helpers and generated theorem constants;
it does not scan the filesystem or audit declarations added after this command.
-/

#audit_axioms DefiKernel
