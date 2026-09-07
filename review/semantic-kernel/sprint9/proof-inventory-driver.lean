import DefiKernel.Metatheory.Verify

open Lean Elab Command DefiKernel.AxiomAudit

elab "#metatheory_proof_types" : command => do
  let env ← getEnv
  let theorems := importedTheorems env `DefiKernel.Metatheory
  let supplemental := importedSupplemental env `DefiKernel.Metatheory
  if theorems.isEmpty || supplemental.isEmpty then
    throwError "Empty Metatheory imported inventory"
  for (name, moduleName) in theorems do
    let some info := env.find? name | throwError "Missing discovered theorem {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    unless (axioms.filter fun ax => !allowedAxioms.contains ax).isEmpty do
      throwError "Forbidden theorem dependency {name}: {axioms}"
    let row := Json.mkObj [
      ("name", toJson name.toString),
      ("user_name", toJson ((privateToUserName? name).getD name).toString),
      ("is_private_name", toJson (privateToUserName? name).isSome),
      ("module", toJson moduleName.toString),
      ("statement", toJson type.pretty), ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"METATHEORY_PROOF_JSON {row.compress}"
  for (name, moduleName, kind) in supplemental do
    let some info := env.find? name | throwError "Missing supplemental declaration {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    unless (axioms.filter fun ax => !allowedAxioms.contains ax).isEmpty do
      throwError "Forbidden supplemental dependency {name}: {axioms}"
    let row := Json.mkObj [
      ("name", toJson name.toString),
      ("user_name", toJson ((privateToUserName? name).getD name).toString),
      ("is_private_name", toJson (privateToUserName? name).isSome),
      ("module", toJson moduleName.toString),
      ("kind", toJson kind), ("statement", toJson type.pretty),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"METATHEORY_SUPPLEMENTAL_JSON {row.compress}"

set_option pp.maxSteps 1000000 in
set_option pp.universes true in
set_option pp.explicit true in
set_option pp.proofs true in
set_option pp.fullNames true in
#metatheory_proof_types
