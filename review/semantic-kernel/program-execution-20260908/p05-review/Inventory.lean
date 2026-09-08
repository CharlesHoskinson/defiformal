import DefiKernel.CapabilityProvenance.FoundationChecks
import Lean.Elab.Command
import Lean.Util.CollectAxioms
open Lean Elab Command
set_option pp.universes true
set_option pp.explicit true
set_option pp.proofs true
set_option pp.maxSteps 1000000
set_option pp.fullNames true
set_option format.width 160
set_option maxRecDepth 10000
set_option maxHeartbeats 0
elab "#p05_inventory" : command => do
  let env ← getEnv
  let entries := (env.constants.fold (init := #[]) fun acc name info =>
    match env.getModuleIdxFor? name with
    | none => acc
    | some idx =>
      let modName := env.header.moduleNames[idx.toNat]!
      if (`DefiKernel).isPrefixOf modName then acc.push (name, modName, info) else acc)
    |>.qsort fun a b => Name.lt a.1 b.1
  if entries.isEmpty then throwError "BLOCKED empty inventory"
  let mut bad : Nat := 0
  for (name, modName, info) in entries do
    let kind := match info with
      | .thmInfo _ => "theorem"
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | .inductInfo _ => "inductive"
      | .ctorInfo _ => "constructor"
      | .recInfo _ => "recursor"
      | .quotInfo _ => "quotient"
    let axioms ← collectAxioms name
    let forbidden := axioms.filter fun ax => ![``propext, ``Classical.choice, ``Quot.sound].contains ax
    if !forbidden.isEmpty then bad := bad + 1
    let statement ← liftTermElabM <| Meta.ppExpr info.type
    let row := Json.mkObj [("name", toJson name.toString), ("module", toJson modName.toString),
      ("kind", toJson kind), ("statement", toJson statement.pretty),
      ("axioms", toJson (axioms.toList.map Name.toString)),
      ("forbidden", toJson (forbidden.toList.map Name.toString))]
    liftIO <| IO.println ("P05_INVENTORY " ++ row.compress)
  logInfo m!"P05 inventory total={entries.size}; forbidden={bad}"
  if bad > 0 then throwError "Forbidden axioms"
#p05_inventory
