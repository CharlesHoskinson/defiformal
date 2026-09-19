import DefiKernel.Certificates.TrustedHost

/-!
Minimal identity export for the P19 host validator.

Evaluated by `lake env lean --run`. Prints the *imported* TrustedHost
constants, not a regex view of source text. Comments in TrustedHost.lean
cannot change this output.
-/
open DefiKernel.Certificates.TrustedHost

set_option linter.style.longLine false

/-- Reviewed sha256 of lean/DefiKernel/Certificates/TrustedHost.lean. -/
def trustedHostSourceSha256 : String :=
  "d2227d592f22878e1ab4a6b58b1dfadcbe35bcd346464756f2eb721f0d7f501d"

def jsonString (s : String) : String :=
  "\"" ++ (s.replace "\\" "\\\\" |>.replace "\"" "\\\"") ++ "\""

def depPair (r : DependencyRecord) : String :=
  jsonString r.path ++ ":" ++ jsonString r.sha256

def depsObject : String :=
  "{" ++ String.intercalate "," (deliveredDependencies.map depPair) ++ "}"

def identityJson : String :=
  "{" ++
    String.intercalate "," [
      "\"git\":" ++ jsonString gitSha,
      "\"lean_toolchain\":" ++ jsonString leanToolchain,
      "\"mathlib_rev\":" ++ jsonString mathlibRev,
      "\"grammar_sha256\":" ++ jsonString grammarSha256,
      "\"schema_sha256\":" ++ jsonString schemaSha256,
      "\"arithmetic_token\":" ++ jsonString arithmeticAddCompilerRecord,
      "\"trusted_host_source_sha256\":" ++ jsonString trustedHostSourceSha256,
      "\"dependencies\":" ++ depsObject
    ] ++ "}"

def main : IO Unit := do
  IO.println "DEFIFORMAL_HOST_IDENTITY_V1"
  IO.println identityJson
