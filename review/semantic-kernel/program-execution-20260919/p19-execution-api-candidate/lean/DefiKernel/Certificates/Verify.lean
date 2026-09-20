import DefiKernel.Certificates.Audit
import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.Roundtrip
import DefiKernel.Certificates.IRDepth
import DefiKernel.Certificates.CompositionDepth
import DefiKernel.Certificates.Lexical
import DefiKernel.Certificates.Soundness
import DefiKernel.Certificates.Observation
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.TrustedHost
import DefiKernel.Certificates.LibraryInstantiation
import DefiKernel.Certificates.Delivered
import DefiKernel.Certificates.ExecutionAPI
import DefiKernel.Certificates.ExecutionAPIRegression
import DefiKernel.Certificates.KernelCorrespondence
import DefiKernel.Certificates.CompatibilityExamples
import DefiKernel.Certificates.Tests
import DefiKernel.AxiomAudit

/-! Nonempty axiom audits for Certificates, Typed, and Composition scopes. -/

#audit_axioms DefiKernel.Certificates
#audit_axioms DefiKernel.Typed
#audit_axioms DefiKernel.Composition
