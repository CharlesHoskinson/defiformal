import DefiKernel.Arithmetic.Quantity
namespace ArithmeticTypingControl
inductive Asset | usd | alt
def needsUSD (_ : DefiKernel.Typed.Quantity Asset.usd) : Nat := 0
def useQuantity (q : DefiKernel.Arithmetic.Word 8) : Nat :=
  needsUSD (DefiKernel.Arithmetic.Quantity.toQuantity Asset.usd 1 (by decide) q)
end ArithmeticTypingControl
