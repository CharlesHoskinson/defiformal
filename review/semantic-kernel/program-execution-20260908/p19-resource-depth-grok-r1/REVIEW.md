# P19 R9 resource-domain and component-proof review

**Mark:** `RESOURCE_DEPTH_AND_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: AGY R9 archive SHA256 `0bf9f1c7bd541da64e61b8ff1317d23e001ade9ef5c80536c0824d1eb862ecae` (3439 files). Author reports `PARTIAL_PROOF_WORK`. Root R9 precheck already required changes. Frozen CanonicalJson/Encode/Decode/Correspondence hashes in the sandbox match the R9 terminal manifest and root precheck.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17` via `lake env` in `private-lean/`. Host default elan was not used. `bin/lean` SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.

Private rebuild: `lake build +DefiKernel.Certificates.CanonicalJson +DefiKernel.Certificates.Encode +DefiKernel.Certificates.Decode +DefiKernel.Certificates.Correspondence`, exit 0, 932 jobs. Runtime and axiom probes import those private oleans.

R8 is historical. This review does not reassert R8 key-unescaped / 4096-character / estimator bugs as current defects. Those three encoder/domain repairs are present in R9 source. Remaining structural gaps are R9's.

## Answer

R9 does not close the whole-document resource-domain or general component-proof obligations.

1. Production `jsonObj` now applies `escapeJsonString` to keys. That is a real encoder repair relative to R8. Author `DynamicKeyProbe` / scratch-suite prose is not captured in the R9 evidence folder (8 files; `commands.json` has no key probe). Runtime credit is only the probe in this review.

2. `SerializedByteBound` is `(encodeModule ir).size ≤ 1048576`. That is a legitimate exact byte-length restriction, not the old estimator. `serialized_byte_bound_exceeded_not_supported` is the transport of that predicate, not a JSON-depth or nested-array proof.

3. `ExprDepthBounded = exprDepth e ≤ 55` is a guessed AST cap. `TemplateDepthBounded` checks only `t.guard` and omits `deltas.amount` and `supplyDeltas.amount`. Constructor-specific JSON objects mean source AST depth 55 is not a proof of whole-document JSON depth ≤ 64. Scanner `depth > 64` after increment and parser `stack.length ≥ 64` before push both refuse the 65th open container (max 64). They do **not** agree on arrays: scanner comma-count allows 4097 elements; parser `acc.size ≥ 4096` refuses the 4097th.

4. Catalog length ≤ 4096 does not bound component `privateCells` / `exports` / `imports` / `operations` or operation `inputs` / `outputs`. `EnvelopeLengthBounds` omits `claimed_next_state.capabilities.entries`. Exact missing sufficient-bound proofs are in Correspondence source.

5. The 24 new `*ToJson` lemmas invert Lean.Json helpers, not `encodeModule`. There is no `exprToJson_decode_lit`. Step lemmas are conditional IH forms, not a general recursive expression inversion. `EncodeDecodeRoundtripStatement` remains a `def Prop`. Helper progress is not the full IR theorem.

6. REPORT source hashes for Encode/Correspondence/CanonicalJson/`run_certificate_fixtures.py` disagree with the frozen files. `source-manifest.json` matches. Header auditor `grok-4.6-high` is not an observed review of R9. 54/54 fixture claims retain the known F13 null/overlay/host limitations.

## 1. Whole-document resource domain

Accepted grammar limits: 1 MiB, JSON depth 64, array length 4096.

**Byte bound.** `SerializedByteBound` measures actual `encodeModule`. This is the correct form of a resource restriction. It does not imply JSON depth ≤ 64 or nested array length ≤ 4096.

**AST vs JSON depth.** `exprDepth` / `ExprEnc.depth` count expression constructors (leaf = 1). Production `encodeExpr` wraps each constructor in an object and adds constructor-specific objects (`op`, `unit`, `value`/`{num,den}`, `ref`/`key`/`cell`). Envelope nesting for a typed-execute registry template is: envelope / payload / registry / entries / entry / template, then `guard` (JSON depth 7) or `deltas` array / delta / `amount` (JSON depth 9). `now` adds no extra objects; `observe`/`balance`/`lit` do.

`ExprCanonical` still allows `e.depth ≤ 64`. `ExprDepthBounded` uses 55. `TemplateCanonical` walks guard, deltas, and supplyDeltas; `TemplateDepthBounded` walks only guard. A template with guard `.now` and a deep delta amount is `TemplateDepthBounded` and can still be `SupportedIR` while its encoded JSON exceeds parser depth 64.

A shallow `now`-unary chain of AST depth 56–58 as **guard** is excluded by 55 and, from the JSON-shape count, remains ≤ 64 containers. That is domain shrinking: ordinary decoder-admitted expression excluded by a guessed cap. Do not shrink grammar to make the theorem true.

**Scanner vs parser depth.** `scanLexical`: increment then `if depth > 64`. `parseStep` on `{`/`[`: `if st.stack.length >= 64` before push. Both admit 64 open containers and refuse the 65th. They are not a proof that `exprDepth ≤ 55` implies document depth ≤ 64.

**Scanner vs parser arrays.** `scanLexical` increments a comma count and throws when `cnt + 1 > 4096`, so 4097 elements (4096 commas) pass the scanner. `feedValue` throws when `acc.size >= 4096` before the 4097th push. Grammar `max_array_length` is 4096. The scanner is strictly weaker.

Runtime for these polarities is in `probes/ProbeR9.lean` / `logs/probe-r9.stdout` after that command exits 0. Source membership of `SupportedIR` on the large catalog/delta witnesses is not kernel-proved here (`decide` on the full predicate is not claimed). Predicate-membership and runtime remain separate.

## 2. Nested arrays

`StepPayloadLengthBounds` / `RunPayloadLengthBounds` bound `config.catalog.length` and template/step/history/admin/capability **payload** arrays listed in Correspondence.lean:197–219. They do not quantify over `ComponentEnc.privateCells`, `exports`, `imports`, `operations`, or `OperationInterfaceEnc.inputs` / `outputs`. Schema and Encode emit those arrays. Decoder parses them as JSON arrays subject to the 4096 parser cap.

`EnvelopeLengthBounds` lists audit_roots, assumptions, invariants, libraries, source_map, claimed_judgments, and types enumerations. It does not mention `claimed_next_state`. `ClaimedNextStateCanonical` is 32-cell uniqueness plus `StoreCanonical` (Nodup), not `entries.length ≤ 4096`.

One concrete omitted-array family: a composition-step IR whose catalog has length 1 and whose single component has `privateCells` length 4097, encoded size well under 1 MiB. Parser should refuse `max_array_length`; the length predicates as written do not. Operation `inputs` length 4097 and `claimed_next_state.capabilities` length 4097 are the same gap on other fields. This review runs those three as runtime probes; it does not enumerate dozens of speculative cases.

Exact byte-length `SerializedByteBound` is not an old-cost defect.

## 3. New encoders and 113 declarations

Source theorem count: CanonicalJson 10 + Correspondence 103 = 113, matching `theorems.json` and author count. `string_fromUTF8?_toUTF8` retains the question mark in source and in `theorems.json`.

The 24 new lemmas (`decodeParty_partyToJson` … `exprToJson_decode_ite_step`) invert `*ToJson : _ → Lean.Json` through `decode*` / `decodeExprFuel`. They are not `encodeExpr` / `encodeModule` inversions. `packedValueToJson` for bool is `Lean.Json.bool`, not the production packed-value object `{unit,value}`. There is no `exprToJson_decode_lit`. Numeric/signed/fractional lit therefore is not in the new cluster (older `decodeExprFuel_lit_bool` / `decodeRat_mkObj` / `decodePackedValue_*_val` remain helper lemmas; `decodePackedValue_scalar_val` is `Nat`).

`exprToJson_decode_unary_step` / `_binary_step` / `_ite_step` assume `decodeExprFuel fuel (exprToJson child) = .ok child`. That is a legitimate inductive step, not a circular theorem, and not a general `∀ e, decodeExprFuel 64 (exprToJson e) = .ok e`. Production `decodeExpr` uses fuel 64, independent of `ExprDepthBounded` 55. No theorem connects fuel, AST depth, and JSON depth.

`EncodeDecodeRoundtripStatement` is still `def Prop`. `decode_encode_roundtrip_of_decode` and `decode_encode_canonical_bytes` assume prior `decodeBytes = .ok`. Do not credit helper or prior-decode lemmas as the universal IR theorem.

Axiom audit scope and standard-axiom set are recorded from `probes/ProbeAxioms.lean` after that command exits 0. Failed Lean invocations receive zero credit even if `#eval` printed.

## 4. Key/value regression and report identity

Focused production-codec cases: quote / backslash / C0 / non-ASCII / non-BMP on **keys and values**, plus unsorted source_map order, duplicate keys, and extra whitespace. Results are the ProbeR9 command, not REPORT prose.

R9 evidence folder contains exactly eight files: REPORT.md, commands.json, compiler-axiom-audit.log, fixture-results.json, results.json, scenario-results.json, source-manifest.json, theorems.json. `commands.json` records six lake/python commands; none is `DynamicKeyProbe`. REPORT's key-roundtrip table is uncaptured.

REPORT hashes:

| File | REPORT | actual frozen / source-manifest |
|---|---|---|
| Encode.lean | `611ba5b6…` (24660 B) | `66debd7d…` (24650 B) |
| Correspondence.lean | `15e4a4dd…` (71852 B) | `1eb36ba7…` (72029 B) |
| CanonicalJson.lean | `ecb58097…` | `a814687b…` |
| run_certificate_fixtures.py | `03f39a0f…` | `bd0eda3d…` |

Decode/Schema/Check/Soundness/Tests hashes in REPORT match. `source-manifest.json` matches every listed frozen file. Confirm by hash, not copied names.

54/54 fixtures and 16 mutants were not re-run here. Known F13 null/overlay/host defects remain separate. No P20 deferral of assigned P19 work.

## Required repairs

1. Replace guessed `exprDepth ≤ 55` and guard-only `TemplateDepthBounded` with a constructor-sensitive bound proved sufficient for actual serialized JSON depth ≤ 64, covering guard, deltas.amount, and supplyDeltas.amount. Do not exclude decoder-admitted AST depths that stay under JSON 64. Do not assume decode success to fix the theorem.

2. Bound every encoded JSON array that the parser limits, including nested component/operation arrays and `claimed_next_state.capabilities.entries`, or prove those arrays cannot exceed 4096 on `SupportedIR`. Align scanner comma-count with parser `acc.size ≥ 4096`.

3. Connect component/expression lemmas to production `encodeModule`/`encodeExpr`, add missing lit/signed/fractional/normal-form cases, and discharge a general recursive inversion or keep them labelled as helper progress. The universal IR statement remains assigned P19 work.

4. Repair REPORT identity: hashes, auditor model, and only cite command-captured probes.
