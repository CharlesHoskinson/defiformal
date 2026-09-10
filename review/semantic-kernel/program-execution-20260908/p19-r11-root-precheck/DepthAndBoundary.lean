import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.Tests
open DefiKernel.Certificates

def wrapNowR11 : Nat → ExprEnc
  | 0 => .now
  | n+1 => .unary .not (wrapNowR11 n)

def guardIRR11 (n : Nat) : DecodedIR :=
  match canonicalWitnessIR with
  | .execution (.typed env p) =>
    .execution (.typed env { p with registry := ⟨[⟨0, {
      signature := [], domain := .main, partyArity := 0, guard := wrapNowR11 n,
      deltas := [], supplyDeltas := [], stateReads := [], envReads := [], writes := []
    }⟩]⟩ })
  | ir => ir

#eval IO.println ("primitive-depth=" ++ toString (jsonDepth (Lean.Json.bool true)))
#eval IO.println ("guard58-measured-depth=" ++ toString (jsonDepth (decodedIRToJson (guardIRR11 57))))
#eval IO.println ("guard58-bound=" ++ toString ((jsonDepth (decodedIRToJson (guardIRR11 57))).ble 64))
#eval IO.println (match decodeBytes (encodeModule (guardIRR11 57)) with
  | .ok ir => if ir == guardIRR11 57 then "guard58-decode=ok-eq" else "guard58-decode=ok-neq"
  | .error e => encodeDecodeFailure e)
#eval IO.println ("array-boundary=" ++ toString Tests.checkArrayLengthBoundaryRegression)
#eval IO.println ("depth-boundary=" ++ toString Tests.checkDepthBoundaryRegression)
