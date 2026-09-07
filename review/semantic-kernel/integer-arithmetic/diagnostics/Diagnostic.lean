import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Fees

/-! Finite diagnostic execution only. The independent oracle is Python divmod. -/
namespace ArithmeticDiagnostic
open DefiKernel.Arithmetic

def inputWord (n : Nat) : Word 4 := ⟨n % 16, Nat.mod_lt _ (by decide)⟩

def wordResult (result : Except Failure (Word 4)) : String :=
  match result with
  | .ok q => s!"ok,{q.value}"
  | .error failure => s!"error,{reprStr failure}"

def quoteResult (result : Except Failure (Fees.FeeQuote 4)) : String :=
  match result with
  | .ok q => s!"ok,{q.principal.value},{q.fee.value},{q.charged.value},{q.received.value}"
  | .error failure => s!"error,{reprStr failure}"

def modeName (mode : Rounding) : String :=
  match mode with | .down => "down" | .up => "up"

def main : IO Unit := do
  for a in List.range 16 do
    for b in List.range 16 do
      let aw := inputWord a
      let bw := inputWord b
      IO.println s!"DIAG,basic,add,{a},{b},{wordResult (Operations.add aw bw)}"
      IO.println s!"DIAG,basic,sub,{a},{b},{wordResult (Operations.sub aw bw)}"
      IO.println s!"DIAG,basic,mul,{a},{b},{wordResult (Operations.mul aw bw)}"
      for denominator in List.range 17 do
        for mode in [Rounding.down, Rounding.up] do
          IO.println s!"DIAG,division,{modeName mode},{a},{b},{denominator},{wordResult (Rounding.mulDiv mode aw bw denominator)}"
  for amount in List.range 16 do
    for numerator in List.range 17 do
      for denominator in List.range 17 do
        for mode in [Rounding.down, Rounding.up] do
          let q := inputWord amount
          IO.println s!"DIAG,fee,gross,{modeName mode},{amount},{numerator},{denominator},{quoteResult (Fees.feeFromGross mode q numerator denominator)}"
          IO.println s!"DIAG,fee,top,{modeName mode},{amount},{numerator},{denominator},{quoteResult (Fees.feeOnTop mode q numerator denominator)}"

#eval main

end ArithmeticDiagnostic
