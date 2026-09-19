import DefiKernel.Certificates.Lexical
open DefiKernel.Certificates
example : DefiKernel.Certificates.EncodeDecodeRoundtripStatement := DefiKernel.Certificates.encode_decode_roundtrip
example (ir : DecodedIR) (h : StructurallyAdmissibleIR ir) : decodeBytes (encodeModule ir) = .ok ir := encode_decode_roundtrip ir h
example (ir : DecodedIR) (h : StructurallyAdmissibleIR ir) : scanLexical (encodeModule ir) = .ok () := scanLexical_encodeModule ir h
example (ir : DecodedIR) (h : StructurallyAdmissibleIR ir) : checkBytes (encodeModule ir) = checkIR ir := checkBytes_encodeModule ir h
example (env : EnvelopeEnc) (p : TypedExecutePayloadEnc) (h : StructurallyAdmissibleIR (.execution (.typed env p))) : checkBytes (encodeModule (.execution (.typed env p))) = .execution (checkTyped env p) := checkBytes_encodeModule_typed env p h
example (env : EnvelopeEnc) (p : CompositionStepPayloadEnc) (h : StructurallyAdmissibleIR (.execution (.step env p))) : checkBytes (encodeModule (.execution (.step env p))) = .execution (checkStep env p) := checkBytes_encodeModule_step env p h
example (env : EnvelopeEnc) (p : CompositionRunPayloadEnc) (h : StructurallyAdmissibleIR (.execution (.run env p))) : checkBytes (encodeModule (.execution (.run env p))) = .execution (checkRun env p) := checkBytes_encodeModule_run env p h
#print DefiKernel.Certificates.EncodeDecodeRoundtripStatement
#print DefiKernel.Certificates.encode_decode_roundtrip
#print DefiKernel.Certificates.scanLexical_encodeModule
#print DefiKernel.Certificates.checkBytes_encodeModule
