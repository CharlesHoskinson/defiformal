import DefiHistorical.Convex.Data
import Lean

/-! Serialize the exact imported data and relation used by the instance proofs. -/
namespace DefiHistorical.Convex.DataExport

open Lean Data

def symbolJson (s : Symbol) : Json := Json.mkObj [
  ("id", toJson s.id), ("sym", toJson s.sym), ("name", toJson s.name),
  ("group", toJson s.group), ("stratum", toJson s.stratum),
  ("atom", toJson s.atom), ("status", toJson s.status)]

def mechanismJson (index : Nat) (name : String) : Json :=
  match encode name with
  | none => Json.null
  | some v => Json.mkObj [
      ("index", toJson index), ("name", toJson name),
      ("decode_name", toJson (decode v)), ("encode_index", toJson v.val)]

def termDecision (t : Data.Term) : String :=
  if t.external then "external" else if t.alts.length == 1 then "unary" else "non_unary"

def termOccurrences (law : Law) (t : Data.Term) : List Json :=
  if !t.external && t.alts.length == 1 then
    law.subjects.map fun subject ↦
      let target := t.alts.headD ""
      Json.mkObj [("subject", toJson subject), ("target", toJson target),
        ("self_loop", toJson (subject == target)), ("included", toJson (subject != target))]
  else []

def termJson (law : Law) (index : Nat) (t : Data.Term) : Json := Json.mkObj [
  ("index", toJson index), ("alts", toJson t.alts), ("prose", toJson t.prose),
  ("external", toJson t.external), ("mixed", toJson t.mixed),
  ("decision", toJson (termDecision t)), ("occurrences", toJson (termOccurrences law t))]

def lawJson (index : Nat) (law : Law) : Json := Json.mkObj [
  ("index", toJson index), ("id", toJson law.id), ("raw_rule", toJson law.rawRule),
  ("raw_subject", toJson law.rawSubject),
  ("source_row", Json.mkObj [("path", toJson law.sourcePath),
    ("line", toJson law.sourceLine), ("text", toJson law.sourceText)]),
  ("subject_decision", toJson law.subjectDecision), ("subjects", toJson law.subjects),
  ("terms", toJson (law.terms.zipIdx.map fun (t, index) ↦ termJson law index t))]

def occurrenceJson (i : Instance) : List Json :=
  (laws i).zipIdx.flatMap fun (law, rowIndex) ↦
    law.terms.zipIdx.flatMap fun (term, termIndex) ↦
      if !term.external && term.alts.length == 1 then
        law.subjects.zipIdx.filterMap fun (subject, subjectIndex) ↦
          let target := term.alts.headD ""
          if subject == target then none else some (Json.mkObj [
            ("row_index", toJson rowIndex), ("law_id", toJson law.id),
            ("term_index", toJson termIndex), ("subject_index", toJson subjectIndex),
            ("source", toJson subject), ("target", toJson target)])
      else []

def instanceJson (i : Instance) : Json := Json.mkObj [
  ("name", toJson (match i with | .lstar => "lstar" | .parsedNew => "parsedNew")),
  ("raw_laws", toJson ((laws i).zipIdx.map fun (law, index) ↦ lawJson index law)),
  ("edge_occurrences", toJson (occurrenceJson i)),
  ("relation_edges", toJson ((relationEdges i).map fun pair ↦ [pair.1, pair.2])),
  ("outside_subjects", toJson ([] : List String)),
  ("outside_alternatives", toJson ([] : List String))]

def payload : Json := Json.mkObj [
  ("schema_version", toJson (1 : Nat)), ("symbols", toJson (symbols.map symbolJson)),
  ("mechanisms", toJson (mechanismNames.zipIdx.map fun (name, index) ↦
    mechanismJson index name)),
  ("instances", toJson ([Instance.lstar, Instance.parsedNew].map instanceJson))]

/-- Empty outside-name arrays are emitted only after checking every raw parsed name. -/
def emit : IO Unit := do
  unless allNamesBound .lstar && allNamesBound .parsedNew do
    throw (IO.userError "A parsed subject or alternative lies outside the encoded vocabulary")
  unless mechanismNames.all (fun name ↦ (encode name).isSome) do
    throw (IO.userError "A mechanism name lacks an encoding")
  IO.println payload.compress

end DefiHistorical.Convex.DataExport

#eval DefiHistorical.Convex.DataExport.emit
