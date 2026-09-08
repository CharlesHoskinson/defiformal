import DefiKernel.Nary.Verify

open Lean Elab Command DefiKernel.AxiomAudit

/-!
External evidence driver. It loads the parent-owned `DefiKernel.Nary.Verify` import
closure and pretty-prints every imported Nary theorem and supplemental declaration.
Discovery uses `importedTheorems` / `importedSupplemental` by module provenance.
`privateToUserName?` is the private-name map. This file is not a Nary source module.
-/

elab "#nary_proof_types" : command => do
  let env ← getEnv
  let theorems := importedTheorems env `DefiKernel.Nary
  let supplemental := importedSupplemental env `DefiKernel.Nary
  if theorems.isEmpty || supplemental.isEmpty then
    throwError "Empty Nary imported inventory"
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
    logInfo m!"NARY_PROOF_JSON {row.compress}"
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
    logInfo m!"NARY_SUPPLEMENTAL_JSON {row.compress}"

set_option pp.maxSteps 1000000 in
set_option pp.universes true in
set_option pp.explicit true in
set_option pp.proofs true in
set_option pp.fullNames true in
set_option pp.funBinderTypes true in
set_option pp.piBinderTypes true in
#nary_proof_types
