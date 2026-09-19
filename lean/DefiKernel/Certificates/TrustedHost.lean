import DefiKernel.Certificates.Schema

/-!
Trusted dependency records for certificate source identity.

Envelope `source_pin` / `audit_roots` strings are untrusted caller data.
These records are compiled into the checker from delivered path+sha256
bindings and MUST NOT be read back from the envelope.
-/
namespace DefiKernel.Certificates.TrustedHost

/-- Delivered source D. Distinct from any envelope string until compared. -/
def gitSha : String := "a12b7cac05a818cc8d35c2ca440b7170a2807e92"

def leanToolchain : String := "leanprover/lean4:v4.33.0-rc2"

def mathlibRev : String := "51e6992efd06126df61a496bebf8f49482a4e129"

/-- grammar.json SHA-256. Schema identity is this hash, not envelope schema_version alone. -/
def grammarSha256 : String :=
  "908ff747b2f3c3fba50dd4ae7a02486cea8204a4f471457c51ddea30802edfff"

def schemaSha256 : String :=
  "99c58c21022006faad3475bc01db3394d98c9f6237c1df3693594c77802e7000"

structure DependencyRecord where
  path : String
  sha256 : String
  deriving DecidableEq, Repr

/-- Path+sha256 identity of delivered Typed/Composition/pin files. -/
def deliveredDependencies : List DependencyRecord :=
  [ ⟨"lean/DefiKernel/Typed/Types.lean",
      "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"⟩
  , ⟨"lean/DefiKernel/Typed/Expr.lean",
      "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"⟩
  , ⟨"lean/DefiKernel/Typed/Authority.lean",
      "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"⟩
  , ⟨"lean/DefiKernel/Typed/Transition.lean",
      "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"⟩
  , ⟨"lean/DefiKernel/Composition/Interfaces.lean",
      "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe"⟩
  , ⟨"lean/DefiKernel/Composition/Execution.lean",
      "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602"⟩
  , ⟨"lean/DefiKernel/Composition/Contracts.lean",
      "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c"⟩
  , ⟨"lean/DefiKernel/Composition/Sequence.lean",
      "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729"⟩
  , ⟨"lean/lean-toolchain",
      "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"⟩
  , ⟨"lean/lakefile.toml",
      "cd72f6c9a5deb6f3724608b2ee074dfcc92e21b4956088b8596abbd6a6ddfaa8"⟩
  , ⟨"lean/lake-manifest.json",
      "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"⟩
  ]

/-- Encode a trusted record as `path:sha256`. This form is not an envelope git string. -/
def recordToken (r : DependencyRecord) : String := r.path ++ ":" ++ r.sha256

/-- Required nonempty source-identity inventory. Library records are additional. -/
def requiredDependencyPaths : List String :=
  deliveredDependencies.map (·.path)

/-- Compiler record that names the compiled Arithmetic add instantiation used by certificates. -/
def arithmeticAddCompilerRecord : String :=
  "lean/DefiKernel/Arithmetic/Operations.lean:" ++
    "081c4d29809a33b6377ab1746ae93f2f2a429f5fa307983331c4cb5fbc460485:" ++
    "DefiKernel.Arithmetic.Operations.add_ok_iff"

def compilerRecords : List String :=
  deliveredDependencies.map recordToken ++ [arithmeticAddCompilerRecord]

def auditRecords : List String :=
  [ "DefiKernel.Certificates:" ++ grammarSha256
  , "DefiKernel.Typed:" ++ "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"
  , "DefiKernel.Composition:" ++ "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe"
  ]

/-- Envelope compiler/audit strings must match a path+sha256 record, never git D. -/
def recordStringAdmissible (s : String) (allowed : List String) : Bool :=
  allowed.contains s && s ≠ gitSha

def recordsMatch (pin : SourcePinEnc) : Bool :=
  pin.lean_toolchain == leanToolchain &&
  pin.mathlib_rev == mathlibRev &&
  (match pin.compiler_record with
    | none => true
    | some s => recordStringAdmissible s compilerRecords) &&
  (match pin.audit_record with
    | none => true
    | some s => recordStringAdmissible s auditRecords)

/-- Git inequality is sufficient for staleSource.git; other pin fields are separate. -/
def gitMatches (pin : SourcePinEnc) : Bool :=
  pin.git == gitSha

end DefiKernel.Certificates.TrustedHost
