import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Examples

/-!
Nontrivial Parallel.admit witnesses for P20 task 21.2.

Declared branch semantics: two catalog components with recomputed footprints,
connected to `checkCompatibility_ok_iff`. Caller footprint labels are not used.
-/
namespace DefiKernel.Certificates.CompatibilityExamples

open DefiKernel.Parallel
open DefiKernel.Parallel.Examples

/-- Explicit Examples-domain parameters. Unqualified `Party` inside
`DefiKernel.Certificates.*` is Schema.Party when modules are concatenated. -/
abbrev ExP := Typed.Examples.Party
abbrev ExA := Typed.Examples.Asset
abbrev ExD := Typed.Examples.Domain

/-- Disjoint success: usd transfer vs share transfer. -/
def disjointAdmit :
    Except (AdmissionFailure ExP ExA ExD)
      (Footprint ExP ExA ExD × Footprint ExP ExA ExD) :=
  admit (P := ExP) (A := ExA) (D := ExD) cfg boundaries [usd 3] [shares 1]

/-- Same usd transfer template on both components, so both write alice/bob USD. -/
def overlapCfg := config usdTransfer usdTransfer [bobUSD] [bobUSD]

/-- Conflict refusal: both branches write alice USD and bob USD. -/
def conflictAdmit :
    Except (AdmissionFailure ExP ExA ExD)
      (Footprint ExP ExA ExD × Footprint ExP ExA ExD) :=
  admit (P := ExP) (A := ExA) (D := ExD) overlapCfg boundaries [usd 3] [invoke 1 11 .usd 1]

def disjointSuccess : Bool :=
  match disjointAdmit with
  | Except.ok _ => true
  | Except.error _ => false

def conflictRefusal : Bool :=
  match conflictAdmit with
  | Except.ok _ => false
  | Except.error (.conflict _ _) => true
  | Except.error _ => true

end DefiKernel.Certificates.CompatibilityExamples
