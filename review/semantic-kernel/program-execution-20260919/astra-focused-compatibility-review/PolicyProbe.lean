import DefiKernel.Certificates.CompatibilityStatusRegression
import DefiKernel.Certificates.Observation
open DefiKernel.Certificates
open DefiKernel.Certificates.Tests
#eval encodeReport (Delivered.checkTyped { defaultEnvelope with require_invariant_discharge := true, invariants := ["I"] } defaultPayload)
#eval encodeReport (Delivered.checkTyped { defaultEnvelope with assumptions := SIX_ASSUMPTIONS.filter (· != "replay-prevention-outside-model") } defaultPayload)
