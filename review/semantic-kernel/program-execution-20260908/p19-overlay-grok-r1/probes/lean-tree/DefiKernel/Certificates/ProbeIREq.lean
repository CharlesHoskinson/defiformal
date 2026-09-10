import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Encode

open DefiKernel.Certificates

/-- Private reviewer probe. Not production evidence. First nested-match draft failed; this form avoids nested constructors. -/
def main (args : List String) : IO Unit := do
  if args.length < 2 then
    IO.println "usage: ProbeIREq <bytesA> <bytesB>"
    return
  let b1 ← IO.FS.readBinFile args[0]!
  let b2 ← IO.FS.readBinFile args[1]!
  match decodeBytes b1, decodeBytes b2 with
  | .ok ir1, .ok ir2 =>
    let irEq := decide (ir1 = ir2)
    let enc1 := decide (encodeModule ir1 = b1)
    let enc2 := decide (encodeModule ir2 = b2)
    IO.println s!"left=ok right=ok irEq={irEq} enc1eq={enc1} enc2eq={enc2}"
  | .ok _, .error _ =>
    IO.println "left=ok right=error"
  | .error _, .ok _ =>
    IO.println "left=error right=ok"
  | .error _, .error _ =>
    IO.println "left=error right=error"
