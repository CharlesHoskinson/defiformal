import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
def rejected : E (.amount false) :=
  .binary (.scale (.amount true)) (.lit 1) (.lit 2)
