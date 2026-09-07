import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
def rejected : E (.amount false) :=
  .binary (.add (.amount false)) (.lit 1)
    (.lit 2 : E (.amount true))
