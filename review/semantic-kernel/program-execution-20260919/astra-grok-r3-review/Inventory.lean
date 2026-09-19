import DefiKernel.Certificates.Lexical
import Lean
open Lean Elab Command in
run_cmd do
  let env ← getEnv
  for (n, ci) in env.constants.toList do
    if let some idx := env.getModuleIdxFor? n then
      let mod := env.header.moduleNames[idx.toNat]!
      if mod == `DefiKernel.Certificates.Lexical then
        let kind := match ci with
          | .thmInfo _ => "theorem"
          | .defnInfo _ => "definition"
          | .axiomInfo _ => "axiom"
          | .opaqueInfo _ => "opaque"
          | _ => "other"
        logInfo m!"INVENTORY|{n}|{kind}"
