import DefiKernel.Certificates.Encode
import Lean.Data.Json.Parser
open DefiKernel.Certificates
#eval escapeJsonString "plain" == "\"plain\""
#eval escapeJsonString "\n" == "\"\\u000a\""
#eval escapeJsonString (String.singleton (Char.ofNat 0)) == "\"\\u0000\""
#eval match Lean.Json.parse (escapeJsonString (String.singleton (Char.ofNat 0))) with
  | .ok _ => true
  | .error _ => false
