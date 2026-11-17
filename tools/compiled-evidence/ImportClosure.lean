import Lean
open Lean
unsafe def main (args : List String) : IO UInt32 := do
  if args.isEmpty then throw <| IO.userError "empty target set"
  initSearchPath (← findSysroot)
  let imports := args.toArray.map fun arg => ({module := arg.toName} : Import)
  Lean.withImportModules imports {} fun env => do
    for name in env.header.moduleNames do
      let path ← findOLean name
      let (data, _) ← readModuleData path
      IO.println <| Json.compress <| Json.mkObj [
        ("module", toJson name.toString), ("olean", toJson path.toString),
        ("imports", toJson <| data.imports.map fun i => i.module.toString)]
  return 0
