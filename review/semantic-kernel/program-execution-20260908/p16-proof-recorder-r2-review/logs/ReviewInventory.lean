import DefiKernel.ConcentratedLiquidity.Verify
import Lean.Util.CollectAxioms
open Lean Elab Command

def reviewKind (ci : ConstantInfo) : String :=
  match ci with
  | .thmInfo _ => "theorem"
  | .defnInfo _ => "definition"
  | .opaqueInfo _ => "opaque"
  | .axiomInfo _ => "axiom"
  | .ctorInfo _ => "constructor"
  | .inductInfo _ => "inductive"
  | .recInfo _ => "recursor"
  | .quotInfo _ => "quotient"

def reviewModule (env : Environment) (n : Name) : Name :=
  match env.getModuleIdxFor? n with
  | some i => env.header.moduleNames[i.toNat]!
  | none => .anonymous

run_cmd do
  let env ← getEnv
  let roots := (env.constants.fold (init := #[]) fun acc n _ =>
    if (`DefiKernel.ConcentratedLiquidity).isPrefixOf (reviewModule env n) then acc.push n else acc).qsort Name.lt
  let mut todo := roots
  let mut seen : NameSet := {}
  let mut project : Array Name := #[]
  while !todo.isEmpty do
    let n := todo.back!
    todo := todo.pop
    unless seen.contains n do
      seen := seen.insert n
      if (`DefiKernel).isPrefixOf (reviewModule env n) then
        project := project.push n
        if let some ci := env.find? n then
          for d in ci.type.getUsedConstants do todo := todo.push d
          if let some v := ci.value? true then
            for d in v.getUsedConstants do todo := todo.push d
  let mut rows : Array Json := #[]
  for n in project.qsort Name.lt do
    let ci := (env.find? n).get!
    let ty ← liftTermElabM do Meta.ppExpr ci.type
    let axioms ← collectAxioms n
    let ax := axioms.map (fun x => Json.str x.toString)
    let forbidden := axioms.filter (fun x => !([``propext, ``Classical.choice, ``Quot.sound].contains x))
    unless forbidden.isEmpty do throwError "forbidden {n}: {forbidden}"
    rows := rows.push (Json.mkObj [
      ("name", Json.str n.toString), ("module", Json.str (reviewModule env n).toString),
      ("kind", Json.str (reviewKind ci)), ("type", Json.str ty.pretty),
      ("type_expr", Json.str (reprStr ci.type)),
      ("root", Json.bool (roots.contains n)), ("axioms", Json.arr ax)])
  let result := Json.mkObj [("root_count", toJson roots.size), ("project_closure_count", toJson project.size), ("rows", Json.arr rows)]
  liftIO (IO.FS.writeFile "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-proof-recorder-r2-review/logs/elaborated-inventory.json" (result.pretty ++ "\n"))
  liftIO (IO.println s!"roots={roots.size} project_closure={project.size}")
