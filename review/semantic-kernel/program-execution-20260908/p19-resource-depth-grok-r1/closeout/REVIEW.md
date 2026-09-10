# P19 R9 resource-domain and component-proof review (closeout)

**Mark:** `RESOURCE_DEPTH_AND_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

This closeout continues session `01a08aa4-090a-7693-b4e0-e7e187956ca6`. It is not a fresh review. The first process stopped at 35 turns (`native_process_exit` 1, `cancelled_at_max35_turns`) after parent `REVIEW.md` / `verdict.json` / `findings.json` and before `commands.json` / `MANIFEST.json`. Root sealed that work as `attempt1-work.tar.gz` SHA256 `211358057f8020b5e18aa22595422ac0847fb6f95fbc8bcdc9be1b26bb84bd16`. Parent reports, probes, and logs are immutable; this directory only adds closeout artifacts.

Frozen candidate: AGY R9 archive SHA256 `0bf9f1c7bd541da64e61b8ff1317d23e001ade9ef5c80536c0824d1eb862ecae` (3439 files). Author reports `PARTIAL_PROOF_WORK`. Root R9 precheck already required changes. Frozen CanonicalJson/Encode/Decode/Correspondence hashes match the R9 terminal manifest and root precheck (`../probes/source-hash-check.json`).

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17` via `lake env` in `private-lean/`. Host default elan was not used. `bin/lean` SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.

Private rebuild: `lake build +DefiKernel.Certificates.CanonicalJson +DefiKernel.Certificates.Encode +DefiKernel.Certificates.Decode +DefiKernel.Certificates.Correspondence`. Child compiler and wrapper echo both 0. Lake printed `Build completed successfully (932 jobs).` Runtime and axiom probes import those private oleans.

R8 is historical. This review does not reassert R8 key-unescaped / 4096-character / estimator bugs as current defects. Those three encoder/domain repairs are present in R9 source. Remaining structural gaps are R9's.

Credit: only commands with `child_compiler_exit` 0 and no Lean `error:` line. Failed ProbeAxioms attempt 1 and ProbeR9 attempts 1–2 keep zero success credit even where `#eval` printed.

## Answer

R9 does not close the whole-document resource-domain or general component-proof obligations.

1. Production `jsonObj` now applies `escapeJsonString` to keys. ProbeR9 (`child_compiler_exit` 0) roundtrips quote/backslash/NUL/LF/tab/U+03BB/U+1F680 on source-map keys and checker_candidate values through `encodeModule`/`decodeBytes`. Author `DynamicKeyProbe` / scratch-suite prose is not in the R9 evidence folder (8 files; author `commands.json` has no key probe) and is not credited.

2. `SerializedByteBound` is `(encodeModule ir).size ≤ 1048576`. That is a legitimate exact byte-length restriction, not the old estimator. `serialized_byte_bound_exceeded_not_supported` transports that predicate. Witness encode size 3427. It is not a JSON-depth or nested-array proof.

3. `ExprDepthBounded = exprDepth e ≤ 55` is a guessed AST cap. `TemplateDepthBounded` checks only `t.guard` and omits `deltas.amount` and `supplyDeltas.amount`. Constructor-specific JSON objects mean source AST depth 55 is not a proof of whole-document JSON depth ≤ 64. ProbeR9 production outcomes: guard AST 56 nest 62 `decodeBytes` `ok-eq`; guard AST 58 nest 64 `ok-eq`; guard AST 59 nest 65 `resourceLimit maxDepth`; delta amount AST 64 with guard `.now` nest 72, scan/parse/decode `maxDepth`. `Nat.ble 55` is false for AST 56/58. No kernel `SupportedIR` membership proof; `Decidable (ExprDepthBounded _)` was not synthesised.

4. Catalog length ≤ 4096 does not bound component `privateCells` / `exports` / `imports` / `operations` or operation `inputs` / `outputs`. `EnvelopeLengthBounds` omits `claimed_next_state.capabilities.entries`. ProbeR9: catalog length 1 with 4097 `privateCells`, 200173 bytes; 4097 operation inputs, 130564 bytes; 4097 claimed capabilities, 369468 bytes. In each case `scanLexical` is `ok`, `parseCanonicalJson` is `resourceLimit max_array_length`, and public `decodeBytes` is `notJsonObject`. The whole decoder still refuses length 4097. Scanner comma-count allowing 4097 is a staged-check difference, not a public grammar acceptance. This review does not require a scanner refactor as an extra acceptance gate.

5. Source theorem count is CanonicalJson 10 + Correspondence 103 = 113. Corrected ProbeAxioms (`child_compiler_exit` 0) printed axioms on all 113 names; standard axioms only (`propext`, `Classical.choice`, `Quot.sound`); three theorems depend on none. The 24 new `*ToJson` lemmas invert Lean.Json helpers, not `encodeModule`. There is no `exprToJson_decode_lit`. `packedValueToJson` for bool is `Lean.Json.bool`, not the production `{unit,value}` object. Step lemmas are conditional IH forms. `EncodeDecodeRoundtripStatement` remains a `def Prop`. Helper progress is not the full IR theorem.

6. REPORT source hashes for Encode/Correspondence/CanonicalJson/`run_certificate_fixtures.py` disagree with the frozen files. `source-manifest.json` matches. Header auditor `grok-4.6-high` is not an observed review of R9. 54/54 fixture claims retain the known F13 null/overlay/host limitations. Fixtures and mutants were not re-run here.

## 1. Whole-document resource domain

Accepted grammar limits: 1 MiB, JSON depth 64, array length 4096.

**Byte bound.** `SerializedByteBound` measures actual `encodeModule`. This is the correct form of a resource restriction. It does not imply JSON depth ≤ 64 or nested array length ≤ 4096.

**AST vs JSON depth.** `exprDepth` / `ExprEnc.depth` count expression constructors (leaf = 1). Production `encodeExpr` wraps each constructor in an object and adds constructor-specific objects (`op`, `unit`, `value`/`{num,den}`, `ref`/`key`/`cell`). Envelope nesting for a typed-execute registry template is envelope / payload / registry / entries / entry / template, then `guard` (JSON depth 7) or `deltas` array / delta / `amount` (JSON depth 9). `now` adds no extra objects; `observe`/`balance`/`lit` do.

`ExprCanonical` still allows `e.depth ≤ 64`. `ExprDepthBounded` uses 55. `TemplateCanonical` walks guard, deltas, and supplyDeltas; `TemplateDepthBounded` walks only guard. From that predicate text, a template with guard `.now` and a deep delta amount satisfies `TemplateDepthBounded`. ProbeR9 encoded that shape to JSON nest 72 and the production decoder refused `maxDepth`. That is a source-level missing sufficient-bound argument plus a measured production refusal, not a kernel `SupportedIR` theorem.

A shallow `now`-unary chain of AST depth 56 and 58 as **guard** is excluded by 55 (`Nat.ble` false) and is production-admitted (`decodeBytes` `ok-eq`, nest 62 and 64). AST 59 nest 65 is refused. That is domain shrinking: ordinary decoder-admitted expressions excluded by a guessed cap. Do not shrink grammar or assume decoding success to fix the theorem.

**Scanner vs parser depth.** `scanLexical`: increment then `if depth > 64`. `parseStep` on `{`/`[`: `if st.stack.length >= 64` before push. Both admit 64 open containers and refuse the 65th. They are not a proof that `exprDepth ≤ 55` implies document depth ≤ 64.

## 2. Nested arrays

`StepPayloadLengthBounds` / `RunPayloadLengthBounds` bound `config.catalog.length` and the template/step/history/admin/capability payload arrays listed in Correspondence.lean:197–219. They do not quantify over `ComponentEnc.privateCells`, `exports`, `imports`, `operations`, or `OperationInterfaceEnc.inputs` / `outputs`. Schema and Encode emit those arrays.

`EnvelopeLengthBounds` lists audit_roots, assumptions, invariants, libraries, source_map, claimed_judgments, and types enumerations. It does not mention `claimed_next_state`. `ClaimedNextStateCanonical` is 32-cell uniqueness plus `StoreCanonical` (Nodup), not `entries.length ≤ 4096`.

**Public decoder vs stages.** Grammar `max_array_length` is 4096. `feedValue` refuses the 4097th element (`acc.size >= 4096`). `scanLexical` comma-count throws when `cnt + 1 > 4096`, so 4097 elements pass the scanner. ProbeR9 measured that split: scan `ok`, parse `resourceLimit max_array_length`. `decodeBytes` remaps every `parseCanonicalJson` error to `notJsonObject`, so the public entrypoint ctor is `notJsonObject` rather than `resourceLimit`. The document is still refused. The whole decoder therefore still enforces 4096. Existing decode precedence is preserved. A scanner/parser staged-check mismatch is not a demonstrated public acceptance of 4097 and is not an extra required repair.

The remaining collection defect is in the **proof domain**: the SupportedIR length predicates omit those nested arrays, so they do not supply a sufficient bound. Runtime of one omitted-array IR is not a kernel membership proof.

Exact byte-length `SerializedByteBound` is not an old-cost defect.

## 3. New encoders and 113 declarations

Source theorem names: CanonicalJson 10 including `string_fromUTF8?_toUTF8`; Correspondence 103; total 113. Corrected ProbeAxioms printed 113 axiom lines, 7 `#check` `Prop` definitions including `EncodeDecodeRoundtripStatement : Prop`, and no Lean `error:` line. `child_compiler_exit` 0. Standard axioms only. Attempt 1 of that probe is not credited.

The 24 new lemmas (`decodeParty_partyToJson` … `exprToJson_decode_ite_step`) invert `*ToJson : _ → Lean.Json` through `decode*` / `decodeExprFuel`. They are not `encodeExpr` / `encodeModule` inversions. `packedValueToJson` for bool is `Lean.Json.bool`, not the production packed-value object `{unit,value}`. There is no `exprToJson_decode_lit`. Numeric/signed/fractional lit is not in the new cluster (older `decodeExprFuel_lit_bool` / `decodeRat_mkObj` / `decodePackedValue_*_val` remain helper lemmas; `decodePackedValue_scalar_val` is `Nat`).

`exprToJson_decode_unary_step` / `_binary_step` / `_ite_step` assume `decodeExprFuel fuel (exprToJson child) = .ok child`. That is a legitimate inductive step, not a circular theorem, and not a general `∀ e, decodeExprFuel 64 (exprToJson e) = .ok e`. Production `decodeExpr` uses fuel 64, independent of `ExprDepthBounded` 55. No theorem connects fuel, AST depth, and JSON depth.

`EncodeDecodeRoundtripStatement` is still `def Prop`. `decode_encode_roundtrip_of_decode` and `decode_encode_canonical_bytes` assume prior `decodeBytes = .ok`. Do not credit helper or prior-decode lemmas as the universal IR theorem. P20 labelling does not move assigned P19 work.

## 4. Key/value regression and report identity

ProbeR9 production codec (`child_compiler_exit` 0):

| Case | Result |
|---|---|
| `jsonObj` key `a"b` | `{"a\"b":1}` |
| source-map keys quote, backslash, NUL, LF, tab, λ, U+1F680 | `ok-eq` |
| checker_candidate values of those characters | `ok-eq` |
| duplicate source-map keys | `duplicateKey` `a` |
| extra space after `"mode":` | `noncanonicalWhitespace` |
| in-memory unsorted keys `[("b","2"),("a","1")]` decode | `ok-neq` (encoder emits sorted `{"a":"1","b":"2"}`) |

Unsorted JSON bytes remain a canonical refusal, not normalised. Order/duplicate/whitespace refusals are unchanged. Author DynamicKeyProbe prose is not credited.

R9 evidence folder contains exactly eight files. Author `commands.json` records six lake/python commands; none is `DynamicKeyProbe`.

REPORT hashes:

| File | REPORT | actual frozen / source-manifest |
|---|---|---|
| Encode.lean | `611ba5b6…` (24660 B) | `66debd7d…` (24650 B) |
| Correspondence.lean | `15e4a4dd…` (71852 B) | `1eb36ba7…` (72029 B) |
| CanonicalJson.lean | `ecb58097…` | `a814687b…` |
| run_certificate_fixtures.py | `03f39a0f…` | `bd0eda3d…` |

Decode/Schema/Check/Soundness/Tests hashes in REPORT match. `source-manifest.json` matches every listed frozen file. Confirm by hash, not copied names.

Captured `fixture-results.json` records 54/54 plus 54 controls. This review did not rerun fixtures or 16 mutants. Known F13 null/overlay/host defects remain separate.

## Required repairs

1. Replace guessed `exprDepth ≤ 55` and guard-only `TemplateDepthBounded` with a constructor-sensitive bound proved sufficient for actual serialized JSON depth ≤ 64, covering guard, `deltas.amount`, and `supplyDeltas.amount`. Do not exclude decoder-admitted AST depths that stay under JSON 64. Do not assume decode success to fix the theorem.

2. Bound every encoded JSON array that the proof domain claims to respect, including nested component/operation arrays and `claimed_next_state.capabilities.entries`, or prove those arrays cannot exceed 4096 on `SupportedIR`. Do not treat scanner/parser staged-check equivalence as an extra gate: public `decodeBytes` already refuses length 4097.

3. Connect component/expression lemmas to production `encodeModule`/`encodeExpr`, add missing lit/signed/fractional/normal-form cases, and discharge a general recursive inversion or keep them labelled as helper progress. The universal IR statement remains assigned P19 work.

4. Repair REPORT identity: hashes, auditor model, and only cite command-captured probes.
