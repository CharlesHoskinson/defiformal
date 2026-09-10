import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.CanonicalJson
import DefiKernel.Certificates.Encode
import DefiKernel.Certificates.Decode
open DefiKernel.Certificates
open Lean

/-- Bounded R13 probe attempt 2: string inverse, nonempty source map, claimed-state, library shapes.
    Attempt 1 used `def main` without `#eval` and invalid Option field notation; that command has zero credit. -/

def showParse : Except DecodeFailure Json → String
  | .ok j => s!"ok:{j.compress}"
  | .error e => encodeDecodeFailure e

def showSM : Except DecodeFailure (List (String × String)) → String
  | .ok xs => s!"ok:{xs}"
  | .error e => encodeDecodeFailure e

def showCNS : Except DecodeFailure (Option WorldEnc) → String
  | .ok none => "ok:none"
  | .ok (some w) => s!"ok:some cells={w.state.cells.length}"
  | .error e => encodeDecodeFailure e

def showLR : Except DecodeFailure LibraryRefEnc → String
  | .ok lr =>
    let m := match lr.moduleName with | none => "none" | some s => s!"some:{s}"
    s!"ok thm={lr.theoremName} mod={m}"
  | .error e => encodeDecodeFailure e

def smallWorld : WorldEnc :=
  { state := { cells := [] }
    capabilities := { entries := [] } }

def nestArr : Nat → Json
  | 0 => Json.str "x"
  | n + 1 => Json.arr #[nestArr n]

def pin : SourcePinEnc :=
  { git := "g", lean_toolchain := "t", mathlib_rev := "m",
    checker_candidate := "c", compiler_record := none, audit_record := none }

def envTwo : EnvelopeEnc :=
  { schema_version := 1, mode := "codec", source_pin := pin,
    audit_roots := [], types := { parties := [], assets := [], domains := [] },
    assumptions := [], invariants := [], libraries := [],
    source_map := [("a", "1"), ("b", "2")], claimed_judgments := [],
    claimed_next_state := none,
    require_library_discharge := false, require_invariant_discharge := false }

def showCodec : Except DecodeFailure DecodedIR → String
  | .ok (.codec c) =>
    match c.envelope with
    | some e => s!"ok codec sm={e.source_map}"
    | none => "ok codec env=none"
  | .ok _ => "ok-other"
  | .error e => encodeDecodeFailure e

def showEnv : Except DecodeFailure EnvelopeEnc → String
  | .ok e => s!"ok sm={e.source_map}"
  | .error e => encodeDecodeFailure e

#eval (do
  IO.println s!"escape_quote={escapeJsonString "a\"b"}"
  IO.println s!"parse_escape_quote={showParse (parseCanonicalJson (escapeJsonString "a\"b"))}"
  IO.println s!"parse_escape_slash={showParse (parseCanonicalJson (escapeJsonString "x\\y"))}"
  IO.println s!"parse_escape_empty={showParse (parseCanonicalJson (escapeJsonString ""))}"
  IO.println s!"sm_nil={showSM (decodeSourceMap (Json.mkObj []))}"
  IO.println s!"sm_single={showSM (decodeSourceMap (Json.mkObj [("k", Json.str "v")]))}"
  let twoAB := Json.mkObj [("a", Json.str "1"), ("b", Json.str "2")]
  let twoBA := Json.mkObj [("b", Json.str "2"), ("a", Json.str "1")]
  IO.println s!"sm_two_ab={showSM (decodeSourceMap twoAB)}"
  IO.println s!"sm_two_ba_mkObj={showSM (decodeSourceMap twoBA)}"
  IO.println s!"two_ab_compress={twoAB.compress}"
  IO.println s!"two_ba_compress={twoBA.compress}"
  IO.println s!"cns_null={showCNS (decodeClaimedNextState Json.null)}"
  IO.println s!"cns_small_world={showCNS (decodeClaimedNextState (worldToJson smallWorld))}"
  let lrNone : LibraryRefEnc := { theoremName := "T", moduleName := none }
  let lrSome : LibraryRefEnc := { theoremName := "T", moduleName := some "M" }
  IO.println s!"helper_none={libraryRefToJson lrNone |>.compress}"
  IO.println s!"helper_some={libraryRefToJson lrSome |>.compress}"
  IO.println s!"prod_none={encodeLibraryRef lrNone}"
  IO.println s!"prod_some={encodeLibraryRef lrSome}"
  IO.println s!"decode_helper_none={showLR (decodeLibraryRef (libraryRefToJson lrNone))}"
  IO.println s!"decode_helper_some={showLR (decodeLibraryRef (libraryRefToJson lrSome))}"
  IO.println s!"depth_scalar={jsonDepth (Json.str "x")}"
  IO.println s!"depth64={jsonDepth (nestArr 64)} le64={decide (jsonDepth (nestArr 64) ≤ 64)} lt100={decide (jsonDepth (nestArr 64) < 100)}"
  IO.println s!"depth65={jsonDepth (nestArr 65)} le64={decide (jsonDepth (nestArr 65) ≤ 64)} lt100={decide (jsonDepth (nestArr 65) < 100)}"
  IO.println s!"fuel100_nest64={jsonDepthFuel 100 (nestArr 64)}"
  IO.println s!"fuel100_nest65={jsonDepthFuel 100 (nestArr 65)}"
  IO.println s!"fuel100_nest101={jsonDepthFuel 100 (nestArr 101)}"
  IO.println s!"decodeEnv_two_sm={showEnv (decodeEnvelope (envelopeSortedFields envTwo (Json.mkObj [])))}"
  IO.println s!"decodeDecodedIR_codec_two_sm={showCodec (decodeDecodedIR (envelopeToJson envTwo (Json.mkObj [])) "raw")}"
  pure ())
