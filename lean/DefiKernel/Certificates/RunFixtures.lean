import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Encode
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Observation
import DefiKernel.Certificates.Delivered

open DefiKernel.Certificates
open Lean

def main (args : List String) : IO Unit := do
  if args.isEmpty then
    IO.println "Usage: RunFixtures <mode> <file1> [file2]"
    return
  let mode := args[0]!
  if mode == "decode" then
    if args.length < 2 then
      IO.println (jsonObj [("error", "\"missing file argument for decode\"")])
      return
    let path := args[1]!
    let bytes ← IO.FS.readBinFile path
    let rawStr := String.fromUTF8? bytes |>.getD ""
    match decodeBytes bytes with
    | .ok ir =>
      let irJson := String.fromUTF8? (encodeModule ir) |>.getD "null"
      let res := jsonObj [("status", "\"ok\""), ("failure", "null"), ("ir", irJson)]
      IO.println (jsonObj [("mode", "\"codec\""), ("result", res), ("raw_utf8", escapeJsonString rawStr)])
    | .error e =>
      let res := jsonObj [("status", "\"malformed\""), ("failure", encodeDecodeFailure e), ("ir", "null")]
      IO.println (jsonObj [("mode", "\"codec\""), ("result", res), ("raw_utf8", "\"\"")])

  else if mode == "check" then
    if args.length < 2 then
      IO.println (jsonObj [("error", "\"missing file argument for check\"")])
      return
    let path := args[1]!
    let bytes ← IO.FS.readBinFile path
    let outcome := Delivered.checkBytes bytes
    match outcome with
    | .execution rep => IO.println (encodeReport rep)
    | other => IO.println (encodeOutcome other)

  else if mode == "raw" then
    if args.length < 2 then
      IO.println (jsonObj [("error", "\"missing file argument for raw\"")])
      return
    let bytes ← IO.FS.readBinFile args[1]!
    match decodeBytes bytes with
    | .ok (.execution exec) =>
      let rawObs := rawExecute exec
      IO.println (encodeRawObservation rawObs)
    | .ok _ =>
      IO.println (jsonObj [("error", "\"not an execution IR\"")])
    | .error e =>
      IO.println (jsonObj [("error", "\"decode failure\""), ("failure", encodeDecodeFailure e)])

  else if mode == "observation-pair" then
    if args.length < 3 then
      IO.println (jsonObj [("error", "\"missing file arguments for observation-pair\"")])
      return
    let bytes1 ← IO.FS.readBinFile args[1]!
    let bytes2 ← IO.FS.readBinFile args[2]!
    let parseRep (bytes : ByteArray) : Except String Report := do
      match Delivered.checkBytes bytes with
      | .execution rep => .ok rep
      | _ =>
        match String.fromUTF8? bytes with
        | none => .error "invalid utf8"
        | some s =>
          match Json.parse s with
          | .error e => .error s!"json parse error: {e}"
          | .ok j =>
            match decodeReport j with
            | .ok rep => .ok rep
            | .error _ => .error "decodeReport failed"
    match parseRep bytes1, parseRep bytes2 with
    | .ok rep1, .ok rep2 =>
      let eq := reportEq rep1 rep2
      let bothFailures := rep1.failure.isSome && rep2.failure.isSome
      IO.println (jsonObj [
        ("reportEq", if eq then "true" else "false"),
        ("isSome_both_failures", if bothFailures then "true" else "false")
      ])
    | .error e1, _ =>
      IO.println (jsonObj [("error", escapeJsonString s!"rep1 parse error: {e1}")])
    | _, .error e2 =>
      IO.println (jsonObj [("error", escapeJsonString s!"rep2 parse error: {e2}")])

  else
    IO.println (jsonObj [("error", escapeJsonString s!"unknown mode: {mode}")])
