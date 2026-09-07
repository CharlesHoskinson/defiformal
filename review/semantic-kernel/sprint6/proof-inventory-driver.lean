import DefiKernel.Parallel.Verify

open Lean Elab Command DefiKernel.AxiomAudit

elab "#parallel_proof_types" : command => do
  let env ← getEnv
  for (name, moduleName) in importedTheorems env `DefiKernel.Parallel do
    let some info := env.find? name | throwError "Missing discovered theorem {name}"
    let type ← liftTermElabM (Meta.ppExpr info.type)
    let axioms ← collectAxioms name
    let row := Json.mkObj [
      ("name", toJson name.toString),
      ("module", toJson moduleName.toString),
      ("statement", toJson type.pretty),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"PARALLEL_PROOF_JSON {row.compress}"

set_option pp.universes true in
set_option pp.explicit true in
#parallel_proof_types
