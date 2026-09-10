import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Correspondence

open DefiKernel.Certificates

def emptyCodec : DecodedIR := .codec {}

def emptyTyped : DecodedIR :=
  .execution (.typed default default)

def emptyAudit : DecodedIR := .audit default

def auditJson : String :=
  "{\"schema_version\":1,\"mode\":\"audit\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[],\"assets\":[],\"domains\":[]},\"assumptions\":[],\"payload\":{}}"

def typedJson : String :=
  "{\"schema_version\":1,\"mode\":\"typed-execute\",\"source_pin\":{\"git\":\"g\",\"lean_toolchain\":\"l\",\"mathlib_rev\":\"m\",\"checker_candidate\":\"c\"},\"audit_roots\":[],\"types\":{\"parties\":[],\"assets\":[],\"domains\":[]},\"assumptions\":[],\"payload\":{\"registry\":{\"entries\":[]},\"store\":{\"entries\":[]},\"ctx\":{\"principal\":\"alice\",\"domain\":\"main\"},\"env\":{\"entries\":[]},\"now\":0,\"request\":{\"operation\":0,\"parties\":[],\"arguments\":[],\"capabilityIds\":[]},\"state\":{\"cells\":[]}}}"

/-- Compiled witness: the declared roundtrip statement fails on empty codec IR. -/
def emptyCodecFalsifiesRoundtrip : Bool :=
  decide
    (SupportedIR emptyCodec ∧
     CanonicalIR emptyCodec ∧
     decodeBytes (encodeModule emptyCodec) ≠ .ok emptyCodec)

def emptyTypedFalsifiesRoundtrip : Bool :=
  decide
    (SupportedIR emptyTyped ∧
     CanonicalIR emptyTyped ∧
     decodeBytes (encodeModule emptyTyped) ≠ .ok emptyTyped)

def emptyAuditFalsifiesRoundtrip : Bool :=
  decide
    (SupportedIR emptyAudit ∧
     CanonicalIR emptyAudit ∧
     decodeBytes (encodeModule emptyAudit) ≠ .ok emptyAudit)

def auditJsonFalsifiesCanonicalBytes : Bool :=
  match decodeBytes auditJson.toUTF8 with
  | .error _ => false
  | .ok ir =>
    decide (CanonicalIR ir ∧ encodeModule ir ≠ auditJson.toUTF8)

def typedJsonFalsifiesCanonicalBytes : Bool :=
  match decodeBytes typedJson.toUTF8 with
  | .error _ => false
  | .ok ir =>
    decide (CanonicalIR ir ∧ encodeModule ir ≠ typedJson.toUTF8)

#eval IO.println ("emptyCodec.SupportedIR=" ++ toString (decide (SupportedIR emptyCodec)))
#eval IO.println ("emptyCodec.CanonicalIR=" ++ toString (decide (CanonicalIR emptyCodec)))
#eval IO.println ("emptyCodecFalsifiesRoundtrip=" ++ toString emptyCodecFalsifiesRoundtrip)
#eval IO.println ("emptyTyped.SupportedIR=" ++ toString (decide (SupportedIR emptyTyped)))
#eval IO.println ("emptyTyped.CanonicalIR=" ++ toString (decide (CanonicalIR emptyTyped)))
#eval IO.println ("emptyTypedFalsifiesRoundtrip=" ++ toString emptyTypedFalsifiesRoundtrip)
#eval IO.println ("emptyAudit.SupportedIR=" ++ toString (decide (SupportedIR emptyAudit)))
#eval IO.println ("emptyAudit.CanonicalIR=" ++ toString (decide (CanonicalIR emptyAudit)))
#eval IO.println ("emptyAuditFalsifiesRoundtrip=" ++ toString emptyAuditFalsifiesRoundtrip)
#eval IO.println ("auditJsonFalsifiesCanonicalBytes=" ++ toString auditJsonFalsifiesCanonicalBytes)
#eval IO.println ("typedJsonFalsifiesCanonicalBytes=" ++ toString typedJsonFalsifiesCanonicalBytes)
