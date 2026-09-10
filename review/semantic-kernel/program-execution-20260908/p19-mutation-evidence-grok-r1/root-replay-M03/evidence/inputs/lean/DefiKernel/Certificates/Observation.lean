import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Check

/-! Observation and equality functions for certificates, reports, and execution outcomes.
Includes needle M11 comparing failure constructor identity. -/
namespace DefiKernel.Certificates

/-- Execution report equality comparison with needle M11. -/
def reportEq (r other : Report) : Bool :=
  let failure := r.failure
  decide (
    r.status = other.status ∧
    failure = other.failure ∧
    r.judgments = other.judgments ∧
    r.world = other.world ∧
    r.receipt = other.receipt ∧
    r.outputs = other.outputs ∧
    r.events = other.events ∧
    r.nextIndex = other.nextIndex ∧
    r.cursorFailure = other.cursorFailure ∧
    r.assumptions = other.assumptions ∧
    r.outstanding = other.outstanding ∧
    r.source_pin = other.source_pin ∧
    r.audit_roots = other.audit_roots ∧
    r.unsupported = other.unsupported
  )

def codecEq (c other : CodecResult) : Bool :=
  decide (c = other)

def auditEq (a other : AuditResult) : Bool :=
  decide (a = other)

def worldEq (w other : WorldEnc) : Bool :=
  decide (w = other)

def outcomeEq (o other : Outcome) : Bool :=
  decide (o = other)

-- BEGIN PROOFS

theorem reportEq_refl (r : Report) : reportEq r r = true := by
  dsimp [reportEq]
  simp

theorem worldEq_refl (w : WorldEnc) : worldEq w w = true := by
  dsimp [worldEq]
  simp

end DefiKernel.Certificates
