import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
def accepted : E (.amount false) :=
  .binary (.convert true false) (.lit 3) (.lit 2)
#eval IO.println (if accepted.eval ⟨⟨fun _ => 0, by intro c; decide⟩,
  (fun _ => none), false, [], .nil, 0⟩ == .ok 6 then "typing_positive: true"
  else "typing_positive: false")
