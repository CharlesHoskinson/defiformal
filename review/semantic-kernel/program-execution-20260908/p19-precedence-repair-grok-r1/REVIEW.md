# P19 R18 scanner-precedence independent review

- **Role**: Independent auditor. Requested alias `grok-4.6`. Native process identity is `unknown` (command metas record `unknown`). Root captures terminal telemetry.
- **Candidate**: Frozen AGY R18 (`agy-r18-proof`), archive `6ad92fc54c1e7c7d3a83fc7704a5b0ae1d35342d7914adaeaff444e29dd39788`. Root stated 3527 frozen files verified.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-precedence-repair-grok-r1-sandbox`
- **Output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-precedence-repair-grok-r1`
- **Live AGY worktree / R19**: not inspected (worktree, drafts, cache, and R19 author tree untouched).
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false. Author disposition `PARTIAL_PROOF_WORK` is accurate for mixed-error restoration and component inverses and does not close whole P19.

## 1. Independent rebuild identity

Private Lean copy: `private-lean`. Packages are a symlink to the pinned mathlib tree. Build cache was copied from the R17 private tree; CanonicalJson, Correspondence, and Decode oleans were deleted and rebuilt.

```
cwd: .../p19-precedence-repair-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T18:25:16.930568+00:00
end:   2026-09-10T18:27:50.165835+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
jobs: 932
CanonicalJson: 2.0s
Encode: 1.1s (source bytes unchanged; rebuilt after CanonicalJson)
Decode: 1.9s (R18 skipStringChars)
Check: 1.5s (Decode consumer)
Correspondence: 144s
```

| File | sha256 | vs R17 |
|---|---|---|
| CanonicalJson.lean | `0bde21f2e0c2ad00f1c9d6f3ad45f710bca9741a86528a511fa697b2e7de34d1` | changed by addition |
| Correspondence.lean | `f6b8bd3638cb1d56864c41fa9383741967dd385e0130178d3c744e331d33788d` | changed by addition |
| Decode.lean | `92c8f8ed2bb02afd15d0180b65a25ed26b762cb36d94d61431b89eac13a08257` | skipStringChars fallback |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | byte-equal |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | byte-equal |

Check/Tests/Verify/Observation/Soundness hashes match R17. Terminal-manifest hashes for the three changed files match this review's independent hashes.

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

Sorry-analyzer `--report-only` on CanonicalJson, Correspondence, and Decode: 0 sorry statements, exit 0. `native_decide` occurs only in comments.

## 2. Exact 311-name axiom gate (successful)

Source extraction of `^theorem|^lemma` in `probes/axioms311/inventory.json`:

| Count | Value |
|---|---|
| CanonicalJson theorems | 68 |
| Correspondence theorems | 242 |
| Correspondence lemmas | `exprDepth_pos` |
| Named total | **311** |
| Previous R17 named present | 299 / 299 |
| New theorem declarations | 12 |

`exprDepth_pos` predates R17. It is not new R18 work. R17 added 29 theorems. R18 adds 12 theorems. A theorem-only regex would report Correspondence 242 and miss the lemma.

Independent `#print axioms` command `probe-axioms311` against the **private rebuild** (not the author worktree):

```
exit: 0
stdout sha256: ed005fa048efa1ae6ce50e5353ea7dff6265fe07241bdb1275328647e481807a
stderr: empty
NAMED=311 printed
Lean error lines: none
standard axiom records: 299
zero axiom records: 12
forbidden: []
print order matches source: true
name/axiom map equals frozen author CMD-07: true
includes exprDepth_pos: true
```

Zero-axiom names (same 12 as R17; none of the 12 R18 theorems is zero-axiom):

`lexDigits_step_eq`, `foldl_max_congr`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`, `distinct_of_pairwise_lt`, `standard32CellKeys_eraseDups_len`, `envelopeOrderedKeys_nodup`, `typedPayloadKeys_nodup`, `stepPayloadKeys_nodup`, `runPayloadKeys_nodup`.

`EncodeDecodeRoundtripStatement` is a `def Prop` and is correctly absent from the 311 named declarations. Compiling 311 declarations is not whole-P19 acceptance.

## 3. Mixed-error restoration and remaining unterminated defect

Exact root mixed-six probe (sha256 `2c717b1b9852034686d6946bcc28f414d99efd6880dd96713860f6c3e7ac6096`) replayed on the private rebuild:

```
exit: 0
stdout sha256: 0ec3c792debf9f40328a2f78e0cd97b21303911262542cf2939ab3ca21d25d02
```

Bit-for-bit R15. The four repaired cases return `lexicalScientificOrFloat`, `noncanonicalWhitespace`, `duplicateKey "b"`, `resourceLimit "maxDepth"`. The two unchanged controls remain `lexicalScientificOrFloat` and `duplicateKey "b"`.

Exact root C0 probe (sha256 `4bd7a9709d0e79a5ae0735db473e00dd48e70bbb701b41a92276964d43fa0daa`):

```
exit: 0
stdout sha256: 6caac5c24bbef54474ebc6635ba526341a58169148fd2c8470407aa78f90df6d
```

Bit-for-bit R16. All 32 C0 cells: `scan=ok;decode=ok;parserObject=ok`. True duplicate `{"a":"1","a":"2"}` and equivalent escaped duplicate `{"a":"1","\u0061":"2"}` return `duplicateKey "a"`. Quote `{"q\"":"1","q":"2"}` and backslash `{"b\\":"1","b":"2"}` remain distinct (`scan=ok;parser=ok`).

Exact root unterminated diagnostic (sha256 `2877ed50416845c7d9c17a6d8a8fc45e3deb095121f3b307c65bfc36433fd0a9`):

```
exit: 0
stdout sha256: d82c224e3af9f1588a52eed59bb40c23ed7db206ef5151d89e81f1ec5019ae22
```

Matches frozen R18 root output. `skipStringChars none` returns `notJsonObject` before the existing `foundWhitespace` EOF branch.

| Case | R15 final | R18 independent final |
|---|---|---|
| `{"a": "unterminated` | `noncanonicalWhitespace` | `notJsonObject` |
| `{"a":1, "unterminated` | `noncanonicalWhitespace` | `notJsonObject` |
| `{"a":"unterminated` | `notJsonObject` | `notJsonObject` |
| `{"a":1,"unterminated` | `notJsonObject` | `notJsonObject` |

No-whitespace controls remain `notJsonObject`. This is malformed-input error precedence, not an admissible-domain roundtrip counterexample. R19 author has both repairs; this review did not inspect R19.

## 4. Runtime bound / acceptance (new concern, not a valid-domain counterexample)

Probe `runtime-acceptance` on the private rebuild, exit 0:

- Unterminated value/key, with or without whitespace: `checkBytes` = `Outcome.codec (CodecResult.malformed DecodeFailure.notJsonObject)`.
- Size 1048577 (`Array.replicate 1048577 0x7b`): `scanLexical` = `resourceLimit "maxBytes"`; `checkBytes` = `Outcome.codec (CodecResult.blocked "maxBytes")`.
- Size 1048576: size gate is `size_le` (`bytes.size > 1048576` is false). Existing 1 MiB exclusive-greater bound.

The remaining unterminated-whitespace defect changes the `DecodeFailure` tag and therefore the malformed payload. It does not move the outcome into `blocked` or into kernel execution. Resource-limit blocked remains distinct. Domain 1 MiB / depth 64 / array 4096 / full canonical strings are preserved as stated bounds. C0 32 cells remain valid-domain successes.

## 5. Actual statements (universal byte roundtrip remains open)

`EncodeDecodeRoundtripStatement` remains `def Prop`:

```
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

No theorem proves that proposition.

`decodeBytes_encodeModule_of_lex_and_parse` still takes `h_lex : scanLexical (encodeModule ir) = .ok ()` and `h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)`. Object-decoder success is discharged. Lexical and parser success are not. Parse target is `decodedIRToJson ir`, not helper `.compress` byte equality.

Strongest actual general results after R18:

- R17 `parseCanonicalJson_encodeRat` / `rat_end_to_end_universal` (den ≠ 0, gcd = 1).
- R18 enum/base inverses with no extra hypotheses: `parseCanonicalJson_encodeNumericUnit`, `parseCanonicalJson_encodeUnit`, `parseCanonicalJson_encodeUnaryOp`, and the three matching `*_end_to_end_universal` theorems.
- R18 first-field / scalar parser facts: `parse_obj_first_field_step`, `parse_obj_first_field_comma`, `parse_field_str_val`, `parse_field_num_val`, `parse_field_bool_val`, `parse_field_null_val`. `parse_obj_first_field_step` / `parse_obj_first_field_comma` still assume child `foldlM` success (`h_val`). Prior `parse_obj_field_step` / `parse_arr_feed_elem` still assume `h_val` / `h_feed`.

Exact remaining recursive obligation: derive `h_lex` and `h_parse` for arbitrary nested objects/arrays, `ExprEnc.unary` / `.binary` / `.ite` and their argument lists, and the 14-field envelope token stream. Source-map is sorted entries with a sorted fast path. Envelope production bytes are `jsonObj` in declaration order. Helper `envelopeToJson` uses `Lean.Json.mkObj`, which sorts internally. Do not assert production bytes equal helper `.compress`.

## 6. Author eight-command raw-stream bindings and scope

All eight frozen author commands have matching raw stdout/stderr hashes (and probe hashes where present). Original timestamps/argv/cwd/start/end/exit are preserved in `logs/author-command-bindings.json`.

| ID | Actual scope |
|---|---|
| CMD-01 | `lean4-skills-preflight --codex`, exit 0, empty streams |
| CMD-02 | `lake build DefiKernel` **named library target**, not unqualified `lake build`. start `17:57:48.362102`, end `17:57:48.955950` (~0.59s). Cache replay of that named target, not a cold full-tree build |
| CMD-03 | `lake build DefiKernel.Certificates.Tests` (author 21/21). Not re-run here |
| CMD-04 | `lake env lean DefiKernel/Certificates/Verify.lean`. Frozen log: Certificates 1498/2545, Typed 420/677, Composition 287/408. Historical author execution scope, separate from this review's 311-name probe. Not re-run |
| CMD-05 | mixed-six; stdout hash equals this independent replay |
| CMD-06 | C0 32 + duplicates/quote/backslash; stdout hash equals this independent replay |
| CMD-07 | author 311 `#print axioms`; name/axiom map equals this independent probe |
| CMD-08 | `scripts/test_certificate_fixture_runner.py` (author 7/7). Not re-run |

No unrelated 7/21 or full 54/99/16 reruns. 54/99/16 remain deferred while the universal theorem is open.

## 7. What remains open

- `EncodeDecodeRoundtripStatement` is still a `def Prop`.
- `h_lex` and `h_parse` of `decodeBytes_encodeModule_of_lex_and_parse` are unproved success premises.
- Nested object/array/Expr/envelope inverse remains open; child `foldlM` success is still assumed in support facts.
- Two remaining final precedence defects: unterminated value/key after whitespace return `notJsonObject` (R15 `noncanonicalWhitespace`).
- Full P19 and the full roadmap remain open. Root verifies and adjudicates.
