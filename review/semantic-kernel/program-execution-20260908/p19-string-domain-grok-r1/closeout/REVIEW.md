# P19 R8 string-codec and resource-domain review

**Mark:** `STRING_CODEC_AND_DOMAIN_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: AGY R8 archive SHA256 `84d4ef8bafab998d6b4f171e7078e8e493251628f380052f17936c32c782b3d7` (3431 files). Author reports partial; root precheck already required changes. Frozen sources in the sandbox matched the R8 terminal manifest for CanonicalJson/Encode/Decode/Correspondence (hashes in `closeout` commands).

Attempt 1 of this review (`01a08a88-a983-7e51-b748-0e06fec02ee9`) reached the 30-turn cap, exit 1, with no report. Root sealed that work as `attempt1-work.tar.gz` / `attempt1-native.jsonl.gz` / `attempt1-terminal-seal.json`. Those bytes are not overwritten. This closeout uses the same private Lean rebuild cache and new probe files only.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17` via `lake env` in `private-lean/`. Host default elan was not used. `bin/lean` SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.

Private rebuild (attempt 1, reused): `lake build +DefiKernel.Certificates.CanonicalJson +DefiKernel.Certificates.Encode +DefiKernel.Certificates.Decode +DefiKernel.Certificates.Correspondence`, exit 0, 932 jobs. Fresh CanonicalJson and Correspondence oleans differ in size and hash from the oleans stored in the frozen sandbox tree. Runtime probes imported the private oleans.

## Answer

R8 does not close the string-codec or supported-domain obligations.

1. Production **values** now emit lowercase `\u00xx` for all 32 C0 characters and roundtrip quote/backslash/NUL/LF in `checker_candidate`. That is a real encoder repair for values.
2. Production **object keys** are still raw-interpolated. `jsonObj` is `"\"" ++ k ++ "\":" ++ v`. `encodeSourceMap` escapes values only. A source-map key `a"b` encodes as invalid JSON `{..."a"b":...}` and `decodeBytes` returns `notJsonObject`. Plain keys roundtrip. This is the R7 quoted-key defect on the R8 encoder.
3. The 10 CanonicalJson lemmas invert **helper** `escapeChars`/`lexString` and Lean `String.toUTF8`, not `encodeModule`. `string_roundtrip` is that helper conjunction. `EncodeDecodeRoundtripStatement` remains an unproved `def Prop`. `decode_encode_roundtrip_of_decode` assumes prior `decodeBytes = .ok`.
4. New 4096-character and `10^18` caps are not accepted grammar limits. A 4097-`x` `checker_candidate` encodes to 7524 bytes (`< 1048576`) and `decodeBytes` returns `ok-eq`. Author lemma `large_string_not_in_envelope_string_bounds` excludes any pin with `checker_candidate.length > 4096`. That is domain shrinking, not a resource-domain repair.
5. The structural cost function omits libraries, `compiler_record`/`audit_record`, `claimed_next_state`, and uses constants 8192/16384 for whole step/run payloads. Runtime: adding a 4097-character library or compiler record leaves `irStructuralByteCost` equal to the witness cost 6454 while encoded size grows. No theorem relates `encodeModule ir |>.size` to `maxBytes`. `structural_byte_cost_exceeded_not_supported` only transports the estimator predicate.

REPORT's "all six findings thoroughly resolved" and P20 deferral of the universal IR theorem are false against this source. Lexer failures are `.notJsonObject`, not the claimed `jsonType "invalidEscapeChar"` / `"unescapedControlChar"` (those strings are absent from CanonicalJson.lean). Fixture 54/54 was not re-run; it still carries the known F13 null/overlay/host limitations.

## 1. String encoding and lexing

**Source (Encode.lean:15–16, 277–280).** `jsonObj` interpolates keys without `escapeJsonString`. `encodeSourceMap` sorts keys, escapes values, then calls `jsonObj`. Canonical key order is preserved; escaping is not applied to keys.

**Source (CanonicalJson.lean:46–82).** `escapeChar` maps `"` → `\"`, `\` → `\\`, `c.toNat < 32` → `\u00xx` lowercase hex, else the raw character (including non-ASCII / non-BMP). `lexString` decodes `\uXXXX` with hex and scalar checks, accepts `\" \\ \/ \b \f \n \r \t`, rejects other/truncated/literal-control cases with `.notJsonObject`. It does **not** use `.jsonType`.

**Successful runtime (`closeout/probes/ProbeFocus2.lean`, exit 0).**

| Case | Result |
|---|---|
| all 32 C0 `escapeChar` spellings | `c0-canonical=true` (`\u0000`…`\u001f`) |
| `lexString` unknown `\q`, truncated `\u001`, literal LF, literal NUL | `notJsonObject` |
| helper `\n` and uppercase `\u000A` | `ok` (noncanonical spellings accepted by the helper) |
| `jsonObj [("a\"b", "1")]` | `{"a"b":1}` |
| source-map key `a"b` JSON.parse / `decodeBytes` | false / `notJsonObject` |
| source-map key `plain` | `ok-eq` |
| source-map keys NUL and LF | `notJsonObject` |
| source-map key `a\b` | JSON.parse true, `decodeBytes` `noncanonicalWhitespace` (raw backslash is a JSON escape) |
| values NUL, LF, quote, backslash in `checker_candidate` | all `ok-eq` |

Failed attempt-1 probes (`ProbeCodec`, `ProbeCodecR2`, `ProbeUnicode`) and closeout `ProbeFocus.lean` (exit 1, `ToString Prop`) receive **zero runtime credit**, including booleans they printed before the compiler error.

R8-domain **membership** of a quoted source-map key was not kernel-proved here. `decide` failed to synthesise `Decidable (StructurallyAdmissibleIR _)`. The R7 `withSourceMapKey_admissible` proof is not reused: R8 added `EnvelopeStringBounds` / `StructuralByteBound`. From source, those new conjuncts constrain **length ≤ 4096**, not character set, so a length-3 quoted key is not excluded by the cap text. That is source inspection, not an R8 membership theorem.

Do not treat helper acceptance of `\n` / `\u000A` / `\u0041` as grammar acceptance. Production `decodeBytes` re-encodes and refuses byte inequality as `noncanonicalWhitespace`. Canonical encoder spelling for C0 is `\u00xx`. Quote and reverse solidus use `\"` and `\\`, matching the implemented encoder; this review does not invent `\u0022` as required.

## 2. Proof statements, axioms, rebuild

**Declaration counts in frozen source:** CanonicalJson 10 theorems; Correspondence 80 theorems (author 90 combined). This review **did not** `#print axioms` all 90. Successful `ProbeTheorems.lean` (exit 0) audited these names only:

Helper string/UTF8 (CanonicalJson, connected by Correspondence `string_roundtrip`):

- `hexVal_hexDigit`, `lexString_escapeChars`, `lexString_escapeJsonString`, `string_fromUTF8?_toUTF8`
- `string_roundtrip (s) (rest) : fromUTF8? s.toUTF8 = some s ∧ lexString [] (escapeChars s.toList ++ '"' :: rest) = .ok (s, rest)`

Standard axioms on the string cluster: `propext`, `Quot.sound`; `Classical.choice` on `lexString_escapeJsonString`, `string_fromUTF8?_toUTF8`, `string_roundtrip`. No `sorry` / custom axiom / `native_decide` in those statements.

Production-adjacent Correspondence (not the universal IR theorem):

- `decodeBytes_encode_canonical` / `decode_encode_canonical_bytes`: `decodeBytes raw = .ok ir → encodeModule ir = raw` (the extra `StructurallyAdmissibleIR` hypothesis on the Statement is unused). This is the decoder's post-parse re-encode gate, not parser inversion of arbitrary IR.
- `decode_encode_roundtrip_of_decode`: same prior-decode hypothesis.
- `decodeRat_mkObj`, `decodePackedValue_scalar_val`, `decodePackedValue_amount_val`: Lean.Json object helpers, not `encodeModule`.
- `decodeSourcePin_roundtrip`: four required strings, **always** `compiler_record = none` and `audit_record = none`.
- `structurallyAdmissible_nonempty`, `large_string_not_in_envelope_string_bounds`, `structural_byte_cost_exceeded_not_supported`

`#check EncodeDecodeRoundtripStatement` / `DecodeEncodeCanonicalBytesStatement` : both `Prop`. The former is a `def`, not a theorem.

**Do not credit helper inversion or prior-decode lemmas as the universal byte/IR theorem.**

Rebuild: private CanonicalJson.olean 1784456 bytes SHA256 `c17687f7…`; sandbox copy 837936 bytes `96ac2f3a…` (not the same object). Correspondence private `d37159cc…` vs sandbox `be4713b1…`. Decode oleans matched. Stale sandbox objects were not imported.

## 3. Supported-domain fidelity

Accepted grammar resource limits: whole document 1 MiB, JSON depth 64, array length 4096. There is no per-string character cap and no `10^18` rational cap.

**Character cap (runtime + author lemma).** `SourcePinStringBounds` / `EnvelopeStringBounds` require every listed string `≤ 4096` characters, including source-map keys and values. ProbeFocus2: `checker_candidate` of 4097 `x` has length 4097, `encodeModule` size 7524, `decodeBytes` `ok-eq`. Author `large_string_not_in_envelope_string_bounds` proves any such pin is outside `SourcePinStringBounds`, hence outside `SupportedIR`. That IR is ordinary canonical decoder-admitted JSON below 1 MiB. Excluding it is shrinking, not a repair of the R7 oversized-string counterexample family.

**Rational cap (source only).** `StateCellsBounded` requires `num.natAbs ≤ 10^18` and `den ≤ 10^18`. Grammar numbers are canonical JSON integers in `{num,den}`. No runtime numeral probe was executed; the predicate text is enough to identify the extra exclusion.

**Estimator (source + runtime).** `envelopeByteCost` omits `libraries` and `claimed_next_state`. `sourcePinByteCost` omits `compiler_record` and `audit_record` (constant `+ 128`). Step/run costs are `envelope + 8192` / `+ 16384` regardless of catalog, history, or nested templates. `typedPayloadByteCost` uses fixed per-entry constants; template/expression payloads are not measured. ProbeFocus2: one 4097-character library leaves cost equal to the witness (6454) while encoded size is 7538; a 4097-character `compiler_record` likewise keeps cost 6454 at 7522 bytes.

**Missing sufficient-bound proof.** There is no theorem `StructurallyAdmissibleIR ir → (encodeModule ir).size ≤ 1048576`. `structural_byte_cost_exceeded_not_supported` is `irStructuralByteCost ir > 1048576 → ¬ SupportedIR ir`, which only bounds the estimator. A supported-domain IR whose **actual** encoding exceeds 1 MiB was not constructed in this closeout (libraries of length 4096 × hundreds would be the obvious omitted-mass candidate from source). Absence of that counterexample does not make the estimator sufficient.

**Depth and nested collections (source).** `parseStep` / `scanLexical` refuse JSON depth ≥ 64. `ExprCanonical` allows `e.depth ≤ 64` **inside** envelope/payload/registry/template/guard, so a legal expression tree can exceed whole-document JSON depth. `StepPayloadLengthBounds` / `RunPayloadLengthBounds` do not bound `config.catalog` or nested operation arrays. No runtime depth/catalog counterexample was executed.

R8 `CanonicalIR` does add source-map order, claimed-next-state world shape, packed-value inactive fields, and template/expression canonicality. Those are separate from the new caps and the unsound estimator. They do not restore full nested rational/identifier/universe completeness from earlier domain diagnostics; this slice does not re-litigate that catalogue.

## 4. Faithful resource-domain correction

Keep decoder admission equal to the accepted grammar (1 MiB / depth 64 / array 4096, plus canonical bytes). Do **not** add 4096-character or `10^18` exclusions to make an oversized-string witness drop out of `SupportedIR`.

A legitimate resource restriction is a proved inequality on **actual** `encodeModule ir |>.size` (or an equivalent structural cost **proved sufficient** for that size) for every IR in the proof domain. That bound is a blocked `resourceLimit`, not a reason to shrink the IR universe and not a substitute for `decodeBytes (encodeModule ir) = .ok ir`.

Do not define admissibility as “image of `decodeBytes`” or “equals the target roundtrip conclusion”. Do not add an extra unrelated gate.

The universal quantified parser/constructor/IR theorem remains assigned P19 work. Labelling it P20 does not move it. Helper `lexString_escapeChars` and prior-decode re-encode lemmas stay useful lemmas, not that theorem.

Repair `jsonObj` (and any other dynamic-key site, including `encodeAssumptions` on reports) with the same canonical string escaping as values, without dropping quote/backslash/control/Unicode keys from the domain and without disturbing lexicographic source-map order.

## 5. Report and evidence claims

- REPORT source hashes for CanonicalJson (`ecb58097…`) and Encode (`6b9aa451…`) do not match the frozen files (`a814687b…`, `9e4bc3b8…`). `source-manifest.json` matches the files.
- REPORT attributes `escapeChar` to Encode.lean; the definition is in CanonicalJson.lean. Encode has `escapeJsonString`.
- REPORT describes `jsonType "unescapedControlChar"` / `"invalidEscapeChar"`; CanonicalJson contains no `jsonType`.
- REPORT says all six R7 findings resolved and designates the universal proof as P20. Root keeps it in full P19/R8 scope. Author disposition `PARTIAL_PROOF_WORK` is the accurate self-report; the executive “thoroughly resolved” sentence is not.
- Fixture 54/54 and 16 mutants were not re-run. Known F13 decoded-IR/overlay weakness and unvalidated host compiler boundary remain open boundary obligations, as R7 recorded.

## Required repairs (actionable)

1. Escape dynamic JSON keys with the canonical string codec; re-prove key order; do not exclude special characters from otherwise supported keys.
2. Delete the 4096-character and `10^18` caps as IR-admission predicates. If a bound is needed, prove `(encodeModule ir).size ≤ 1048576` (or a sufficient structural cost) on the full grammar domain.
3. Include omitted fields in any cost function used as a bound: libraries, optional source-pin records, `claimed_next_state`, catalog/nested collections, variable step/run payloads. Account for whole-document JSON depth, not only `ExprEnc.depth`.
4. Prove `EncodeDecodeRoundtripStatement` over that unretracted domain, connecting **production** `encodeModule`/`decodeBytes`/`parseCanonicalJson`, not only `escapeChars` helpers. Keep prior-decode lemmas labelled as such.
5. Correct REPORT hashes, error constructors, theorem-scope claims, and P20 deferral language. Rebuild oleans before axiom audit.

No proof waiver. No source-fidelity claim. No full P19 acceptance.
