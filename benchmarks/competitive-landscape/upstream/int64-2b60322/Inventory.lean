import Lean
open Lean
partial def inspectCommands (env : Environment) (ctx : Parser.InputContext) (s : Parser.ModuleParserState) (msgs : MessageLog) : IO Unit := do
  let (stx,next,errors) := Parser.parseCommand ctx {env:=env,options:={}} s msgs
  if Parser.isTerminalCommand stx then
    IO.println s!"errors={errors.hasErrors}"
  else
    IO.println s!"{stx.getKind}\t{stx.getPos?}\t{stx.getTailPos?}"
    inspectCommands env ctx next errors
def main (args : List String) : IO Unit := do
  let env ← importModules #[{module:=`Model},{module:=`SequenceHelper}] {}
  for filename in args do
    IO.println s!"file={filename}"
    let ctx := Parser.mkInputContext (← IO.FS.readFile filename) filename
    let (_,s,msgs) ← Parser.parseHeader ctx
    inspectCommands env ctx s msgs
