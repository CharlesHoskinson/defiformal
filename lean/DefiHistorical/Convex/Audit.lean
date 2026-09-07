import DefiHistorical.Convex.Counterexamples
import DefiKernel.AxiomAudit
import Lean

/-! Dynamic imported declaration inventory. Full elaborated types, module provenance, kinds and
transitive axioms are emitted for every theorem and supplemental declaration in this library.
Current-module declarations are outside an imported audit, so Verify invokes this command. -/
namespace DefiHistorical.Convex.Audit
open Lean Elab Command

/-- Emit the complete elaborated statement rather than a name-only audit projection. -/
elab "#historical_inventory" : command => do
  let env ← getEnv
  let scopePrefix := `DefiHistorical
  let theorems := DefiKernel.AxiomAudit.importedTheorems env scopePrefix
  let supplemental := DefiKernel.AxiomAudit.importedSupplemental env scopePrefix
  if theorems.isEmpty then
    throwError "HISTORICAL INVENTORY BLOCKED: empty imported theorem scope"
  let entries := theorems.map (fun (name, mod) => (name, mod, "theorem")) ++ supplemental
  for (name, mod, kind) in entries do
    let some info := env.find? name | throwError "HISTORICAL INVENTORY missing declaration {name}"
    let statement ← liftTermElabM do
      withOptions (fun o => o.setBool `pp.explicit true |>.setBool `pp.universes true
          |>.setBool `pp.fullNames true |>.setBool `pp.proofs true
          |>.set `pp.width (120 : Nat) |>.set `pp.maxSteps (1000000 : Nat)) do
        return (← Meta.ppExpr info.type).pretty
    let axioms ← collectAxioms name
    let row := Json.mkObj [("name", toJson name.toString), ("module", toJson mod.toString),
      ("kind", toJson kind), ("statement", toJson statement),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"HISTORICAL INVENTORY {row.compress}"
  logInfo <| m!"HISTORICAL INVENTORY COMPLETE theorems={theorems.size}; " ++
    m!"supplemental={supplemental.size}"

end DefiHistorical.Convex.Audit
