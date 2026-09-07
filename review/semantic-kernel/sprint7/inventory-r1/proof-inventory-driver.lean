import DefiKernel.Interleaving.Verify

open Lean Elab Command DefiKernel.AxiomAudit

elab "#interleaving_proof_types" : command => do
  let env ← getEnv
  let theorems := importedTheorems env `DefiKernel.Interleaving
  let supplemental := importedSupplemental env `DefiKernel.Interleaving
  if theorems.isEmpty || supplemental.isEmpty then
    throwError "Empty Interleaving imported inventory"
  for (name, moduleName) in theorems do
    let some info := env.find? name | throwError "Missing discovered theorem {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    unless (axioms.filter fun ax => !allowedAxioms.contains ax).isEmpty do
      throwError "Forbidden theorem dependency {name}: {axioms}"
    let row := Json.mkObj [
      ("name", toJson name.toString), ("module", toJson moduleName.toString),
      ("statement", toJson type.pretty), ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"INTERLEAVING_PROOF_JSON {row.compress}"
  for (name, moduleName, kind) in supplemental do
    let some info := env.find? name | throwError "Missing supplemental declaration {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    unless (axioms.filter fun ax => !allowedAxioms.contains ax).isEmpty do
      throwError "Forbidden supplemental dependency {name}: {axioms}"
    let row := Json.mkObj [
      ("name", toJson name.toString), ("module", toJson moduleName.toString),
      ("kind", toJson kind), ("statement", toJson type.pretty),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"INTERLEAVING_SUPPLEMENTAL_JSON {row.compress}"

set_option pp.universes true in
set_option pp.explicit true in
set_option pp.fullNames true in
#interleaving_proof_types
