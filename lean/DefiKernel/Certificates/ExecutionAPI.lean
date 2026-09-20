import DefiKernel.Certificates.Delivered

/-!
Designated P19 SF10/S97 public execution-only checker.

`checkIR` consumes `DecodedExecution` and returns a `Report`. Historical
`Check.checkIR` and `Delivered.checkIR` remain `DecodedIR → Outcome` compatibility
dispatchers; their statements are unchanged. `checkBytes` decodes first, routes
only `.execution` values through this `checkIR`, and keeps audit/codec outcomes
as separate constructors, including resourceLimit blocked and malformed decode.
-/
namespace DefiKernel.Certificates.Delivered.Execution

open DefiKernel.Certificates

/-- Public execution-only checker. Typed, step and run dispatch to Delivered methods. -/
def checkIR (ir : DecodedExecution) : Report :=
  match ir with
  | .typed env payload => checkTyped env payload
  | .step env payload => checkStep env payload
  | .run env payload => checkRun env payload

/-- Decode then route. Execution IR is the only input to `checkIR`. -/
def checkBytes (bytes : ByteArray) : Outcome :=
  match decodeBytes bytes with
  | .error (.resourceLimit limit) => .codec (.blocked limit)
  | .error e => .codec (.malformed e)
  | .ok (.execution exec) => .execution (checkIR exec)
  | .ok (.audit a) => .audit (checkAudit a)
  | .ok (.codec doc) => .codec (.ok (.codec doc))

end DefiKernel.Certificates.Delivered.Execution
