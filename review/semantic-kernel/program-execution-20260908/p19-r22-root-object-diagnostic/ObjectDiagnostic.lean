import DefiKernel.Certificates.Correspondence
open Lean DefiKernel.Certificates
namespace RootObjectDiagnostic
-- This projection inspects representation only; it is not a production API.
def rootKey : Json → String
  | .obj o => match o.inner.inner with
    | .leaf => "<empty>"
    | .inner _ k _ _ _ => k
  | _ => "<nonobject>"
def encodedOrder : Json :=
  (TreeJson.obj [("theorem", .str "t"), ("module", .str "m")]).toJson
def mappedOrder : Json :=
  libraryRefToJson {theoremName := "t", moduleName := some "m"}
#eval rootKey encodedOrder
#eval rootKey mappedOrder
#eval encodedOrder == mappedOrder
-- A real counterexample to structural equality of this scratch representation.
theorem distinct_roots : rootKey encodedOrder ≠ rootKey mappedOrder := by decide
theorem distinct_json : encodedOrder ≠ mappedOrder := by
  intro h
  exact distinct_roots (congrArg rootKey h)
-- Unsupported raw tags are outside the admitted step grammar.
theorem unsupported_quote_mismatch :
    encodeStep (.unsupported "\"") ≠
      (TreeJson.obj [("tag", .str "\"")]).encode := by decide
#print axioms RootObjectDiagnostic.distinct_roots
#print axioms RootObjectDiagnostic.distinct_json
#print axioms RootObjectDiagnostic.unsupported_quote_mismatch
end RootObjectDiagnostic
