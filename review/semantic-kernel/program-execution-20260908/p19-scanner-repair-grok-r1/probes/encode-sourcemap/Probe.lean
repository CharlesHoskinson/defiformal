import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000

/-- Fast-path already-sorted vs qsort of reversed unique keys. Byte identity expected. -/
#eval
  let sorted := [("a", "1"), ("b", "2")]
  let reversed := [("b", "2"), ("a", "1")]
  let e1 := encodeSourceMap sorted
  let e2 := encodeSourceMap reversed
  s!"sortedKeys={isSortedStrictAscending (sorted.map Prod.fst)};reversedKeys={isSortedStrictAscending (reversed.map Prod.fst)};e1={e1};e2={e2};eq={e1 == e2}"

/-- Collision keys are strictly ascending; encodeSourceMap must emit escaped newline, not au000a. -/
#eval
  let sm := [("a\n", "1"), ("au000a", "2")]
  s!"collisionSorted={isSortedStrictAscending (sm.map Prod.fst)};encoded={encodeSourceMap sm}"

/-- Reverse collision keys still sort to the same bytes. -/
#eval
  let sm := [("au000a", "2"), ("a\n", "1")]
  s!"revSorted={isSortedStrictAscending (sm.map Prod.fst)};encoded={encodeSourceMap sm}"

/-- Whole-module bytes of collisionIR vs reversed source-map IR. -/
#eval
  let ir1 := withSourceMap [("a\n", "1"), ("au000a", "2")]
  let ir2 := withSourceMap [("au000a", "2"), ("a\n", "1")]
  let b1 := encodeModule ir1
  let b2 := encodeModule ir2
  let s1 := (String.fromUTF8? b1).getD ""
  let scan1 := match scanLexical b1 with | .ok _ => "ok" | .error e => reprStr e
  let dec1 := match decodeBytes b1 with | .ok _ => "ok" | .error e => reprStr e
  let scan2 := match scanLexical b2 with | .ok _ => "ok" | .error e => reprStr e
  let dec2 := match decodeBytes b2 with | .ok _ => "ok" | .error e => reprStr e
  s!"size1={b1.size};size2={b2.size};bytesEq={b1 == b2};scan1={scan1};dec1={dec1};scan2={scan2};dec2={dec2};containsEscaped={s1.containsSubstr "a\\u000a"}"

/-- jsonObj preserves input order; Lean.Json.mkObj sorts. Parse equality is not compress equality. -/
#eval
  let raw := jsonObj [("b", "1"), ("a", "2")]
  let helper := (Lean.Json.mkObj [("b", Lean.Json.num 1), ("a", Lean.Json.num 2)]).compress
  let parsed := match parseCanonicalJson raw with | .ok j => j.compress | .error e => reprStr e
  s!"jsonObj={raw};mkObj.compress={helper};parsed.compress={parsed};rawEqCompress={raw == helper}"

/-- encodeEnvelope declaration order vs sourceMap sorting. -/
#eval
  let ir := collisionIR
  let s := encodeModuleString ir
  let parsed := match parseCanonicalJson s with | .ok j => "ok" | .error e => reprStr e
  s!"collisionAdmissibleDecideNotHere;size={s.toUTF8.size};parse={parsed};scan={match scanLexical s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e}"

end DefiKernel.Certificates
