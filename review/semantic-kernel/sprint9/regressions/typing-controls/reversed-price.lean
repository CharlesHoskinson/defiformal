import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
def rejected : E (.amount false) :=
  .binary (.convert true false) (.lit 3)
    (.lit 2 : E (.price false true))
