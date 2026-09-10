import DefiKernel.Certificates.Roundtrip
open DefiKernel.Certificates

def status {α : Type} : Except DecodeFailure α → String
  | .ok _ => "ok"
  | .error (.resourceLimit name) => "resource:" ++ name
  | .error _ => "other-error"

def nest : Nat → TreeJson
  | 0 => .null
  | n + 1 => .arr [nest n]

def observe (label : String) (tree : TreeJson) : IO Unit := do
  let text := TreeJson.encode tree
  IO.println (label ++ "|" ++ status (scanLexical text.toUTF8) ++ "|" ++ status (parseCanonicalJson text))

#eval do
  for n in [4096, 4097, 4098] do
    observe ("array-" ++ toString n) (.obj [("items", .arr (List.replicate n .null))])
  for n in [63, 64] do
    observe ("depth-" ++ toString (n + 1)) (.obj [("items", nest n)])
