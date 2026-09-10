import DefiKernel.Certificates.Decode

open DefiKernel.Certificates

def summarize : Except DecodeFailure DecodedIR → String
  | .error e => "error:" ++ reprStr e
  | .ok (.codec d) =>
    "ok:codec raw.size=" ++ toString d.rawText.length ++ " env?=" ++ toString d.envelope.isSome
  | .ok (.audit a) =>
    "ok:audit mode=" ++ a.envelope.mode ++ " commands=" ++ toString a.commands.length ++
      " imported_theorems_min=" ++ toString a.imported_theorems_min
  | .ok (.execution (.typed env p)) =>
    "ok:typed mode=" ++ env.mode ++ " cells=" ++ toString p.state.cells.length
  | .ok (.execution (.step env p)) =>
    "ok:step mode=" ++ env.mode ++ " index=" ++ toString p.index
  | .ok (.execution (.run env p)) =>
    "ok:run mode=" ++ env.mode ++ " steps=" ++ toString p.steps.length

def showBytes (b : ByteArray) : String :=
  match String.fromUTF8? b with
  | some s => "utf8=" ++ s.quote ++ " size=" ++ toString b.size
  | none => "nonutf8 size=" ++ toString b.size

def emptyCodec : DecodedIR := .codec {}

def emptyTyped : DecodedIR :=
  .execution (.typed default default)

def emptyAudit : DecodedIR := .audit default

def emptyStep : DecodedIR :=
  .execution (.step default default)

def emptyRun : DecodedIR :=
  .execution (.run default default)

def auditJson : String :=
  "{\"schema_version\":1,\"mode\":\"audit\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[],\"assets\":[],\"domains\":[]},\"assumptions\":[],\"payload\":{}}"

def codecJson : String :=
  "{\"schema_version\":1,\"mode\":\"codec\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[],\"assets\":[],\"domains\":[]},\"assumptions\":[],\"payload\":{}}"

def typedJson : String :=
  "{\"schema_version\":1,\"mode\":\"typed-execute\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[],\"assets\":[],\"domains\":[]},\"assumptions\":[],\"payload\":{\"registry\":{\"entries\":[]},\"store\":{\"entries\":[]},\"ctx\":{\"principal\":\"alice\",\"domain\":\"main\"},\"env\":{\"entries\":[]},\"now\":0,\"request\":{\"operation\":0,\"parties\":[],\"arguments\":[],\"capabilityIds\":[]},\"state\":{\"cells\":[]}}}"

def wsCodecJson : String :=
  "{ \"schema_version\": 1, \"mode\": \"codec\", \"source_pin\": {\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"}, \"audit_roots\": [], \"types\": {\"parties\":[],\"assets\":[],\"domains\":[]}, \"assumptions\": [], \"payload\": {} }"

def reorderedRat : String :=
  "{\"schema_version\":1,\"mode\":\"typed-execute\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[\"alice\"],\"assets\":[\"usd\"],\"domains\":[\"main\"]},\"assumptions\":[],\"payload\":{\"registry\":{\"entries\":[]},\"store\":{\"entries\":[]},\"ctx\":{\"principal\":\"alice\",\"domain\":\"main\"},\"env\":{\"entries\":[]},\"now\":0,\"request\":{\"operation\":0,\"parties\":[],\"arguments\":[],\"capabilityIds\":[]},\"state\":{\"cells\":[{\"amount\":{\"den\":1,\"num\":0},\"domain\":\"main\",\"party\":\"alice\",\"asset\":\"usd\"}]}}}"

def afterEncode (ir : DecodedIR) : String :=
  let raw := encodeModule ir
  "encode:" ++ showBytes raw ++ "; decode:" ++ summarize (decodeBytes raw)

def encodeAfterRaw (rawS : String) : String :=
  match decodeBytes rawS.toUTF8 with
  | .error e => "error:" ++ reprStr e
  | .ok ir =>
    "equal=" ++ toString (decide (encodeModule ir == rawS.toUTF8)) ++ " " ++ afterEncode ir

#eval IO.println ("CASE emptyCodec " ++ afterEncode emptyCodec)
#eval IO.println ("CASE emptyTyped " ++ afterEncode emptyTyped)
#eval IO.println ("CASE emptyAudit " ++ afterEncode emptyAudit)
#eval IO.println ("CASE emptyStep " ++ afterEncode emptyStep)
#eval IO.println ("CASE emptyRun " ++ afterEncode emptyRun)
#eval IO.println ("CASE emptyBytes " ++ summarize (decodeBytes ByteArray.empty))
#eval IO.println ("CASE braces " ++ summarize (decodeBytes "{}".toUTF8))
#eval IO.println ("CASE auditJson.decode " ++ summarize (decodeBytes auditJson.toUTF8))
#eval IO.println ("CASE auditJson.encodeAfter " ++ encodeAfterRaw auditJson)
#eval IO.println ("CASE codecJson.decode " ++ summarize (decodeBytes codecJson.toUTF8))
#eval IO.println ("CASE codecJson.encodeAfter " ++ encodeAfterRaw codecJson)
#eval IO.println ("CASE typedJson.decode " ++ summarize (decodeBytes typedJson.toUTF8))
#eval IO.println ("CASE typedJson.encodeAfter " ++ encodeAfterRaw typedJson)
#eval IO.println ("CASE wsCodecJson.decode " ++ summarize (decodeBytes wsCodecJson.toUTF8))
#eval IO.println ("CASE wsCodecJson.encodeAfter " ++ encodeAfterRaw wsCodecJson)
#eval IO.println ("CASE reorderedRat.decode " ++ summarize (decodeBytes reorderedRat.toUTF8))
#eval IO.println ("CASE emptyCodec.neq " ++ toString (decide (decodeBytes (encodeModule emptyCodec) ≠ .ok emptyCodec)))
#eval IO.println ("CASE emptyTyped.neq " ++ toString (decide (decodeBytes (encodeModule emptyTyped) ≠ .ok emptyTyped)))
#eval IO.println ("CASE emptyAudit.neq " ++ toString (decide (decodeBytes (encodeModule emptyAudit) ≠ .ok emptyAudit)))
