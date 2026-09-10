# P19 R19 TreeJson / unterminated-precedence independent review

- **Role**: Independent auditor. Same session `01a08c9c-62a2-7052-8cc8-735249226c6f`. This closeout is reporting-only completion after the original native run hit the 30-turn cap with the five reports missing. Evidence was already captured in the parent directory.
- **Requested alias**: `grok-4.6` high. **Returned model**: `grok-4.6-build` (root terminal telemetry). Original command metas recorded `unknown`. Original native exit 1 is `cancelled_at_max30_turns`, not a Lean failure (`../attempt1-terminal-seal.json`).
- **Candidate**: Frozen AGY R19 (`agy-r19-proof`), archive `41c9ee03c2de4a57b4b0662538eb30f85445bba4104de31496fe3a873f925724`. Root stated 3564 frozen files.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-treejson-inverse-grok-r1-sandbox`
- **Parent output (immutable)**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1`
- **This closeout**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1/closeout`
- **Path base**: relative `../logs` and `../probes` resolve from this closeout directory to the parent evidence tree.
- **Live AGY worktree / R20**: not inspected.
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. Layer-2 mathlib advisory (`repository_kind other-lean`, `intent.source default`). No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false. Author disposition `PARTIAL_PROOF_WORK` is accurate for the unterminated-whitespace repair and the 32 new scalar/empty/fixed-expression theorems and does not close whole P19.

## 1. Independent rebuild identity

Private Lean copy: `../private-lean` (excluded from this manifest as growing cache). Packages are a symlink to the pinned mathlib tree. Build cache was copied from the R18 private tree; CanonicalJson, Correspondence, and Decode oleans were deleted and rebuilt.

```
cwd: .../p19-treejson-inverse-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T18:43:11.481968+00:00
end:   2026-09-10T18:47:22.277556+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
stdout sha256: 638b12efeb6e7ae231862075b724627dd0416a135644760846f8115faee893c9
jobs: 932
Schema: Replayed (source byte-equal)
CanonicalJson: Built 3.6s
Encode: Built 1.4s (source bytes unchanged; rebuilt after CanonicalJson)
Decode: Built 2.4s (R19 skipStringChars none / foundWhitespace)
Check: Built 1.0s (Decode consumer; source byte-equal)
Observation: Built 978ms (source byte-equal)
Correspondence: Built 239s
```

| File | sha256 | vs R18 |
|---|---|---|
| CanonicalJson.lean | `abf8fb4d5ee4a5a814204f95e67586b29d7969a5d913ce2373655f7ddf81b120` | changed by addition |
| Correspondence.lean | `8797e9866c79c08a16d7fe0149faa2b86940dd34660480342ef3c1b3d333e28b` | changed by addition |
| Decode.lean | `7561716fe3f2bdba355015de7c1b81e3c594f1d6a51df0009294be248c38a23d` | skipStringChars none branches |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | byte-equal |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | byte-equal |

Check/Tests/Verify/Observation/Soundness hashes match R18. No `String.containsSubstr` in the changed sources. Sorry-analyzer `--report-only` on CanonicalJson, Correspondence, and Decode: 0 sorry statements, exit 0, stdout sha256 `8b6a3948323afb909fd189ecc2ffd36b0a391b94cdf77f8ee7f04ea79496d159`. `native_decide` / `sorry` occur only in comments (`../logs/source-forbidden-scan.json`).

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

## 2. Exact 343-name axiom gate (successful)

Source extraction of `^theorem|^lemma` in `../probes/axioms343/inventory.json`:

| Count | Value |
|---|---|
| CanonicalJson theorems | 81 |
| Correspondence theorems | 261 |
| Correspondence lemmas | `exprDepth_pos` |
| Named total | **343** |
| Previous R18 named present | 311 / 311 |
| New theorem declarations | 32 |

`exprDepth_pos` predates R17. It is not new R19 work. R17 added 29 theorems. R18 added 12. R19 adds 32 theorems. A theorem-only regex would report Correspondence 261 and miss the lemma. Root 81+262 counts the lemma inside Correspondence.

Independent `#print axioms` command `probe-axioms343` against the **private rebuild** (not the author worktree):

```
exit: 0
stdout sha256: 6ba5ea40762b3c09d47b537b81a5129cc4a1daa836e970791413aadbc184da9c
stderr: empty
NAMED=343 printed
Lean error lines: none
standard axiom records: 331
zero axiom records: 12
forbidden: []
print order matches source: true
name/axiom map equals frozen author CMD-08 and theorems.json: true
includes exprDepth_pos: true
```

Author `named_axioms_343.lean` print **order** is not source declaration order (first mismatch at index 68: author `jsonDepth_scalar`, source `parseStep_foldlM_tokens_null`). The name **set** and axiom **map** still match. Independent probe order matches source.

Zero-axiom names (same 12 as R17/R18; none of the 32 R19 theorems is zero-axiom):

`lexDigits_step_eq`, `foldl_max_congr`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`, `distinct_of_pairwise_lt`, `standard32CellKeys_eraseDups_len`, `envelopeOrderedKeys_nodup`, `typedPayloadKeys_nodup`, `stepPayloadKeys_nodup`, `runPayloadKeys_nodup`.

`EncodeDecodeRoundtripStatement` is a `def Prop` and is correctly absent from the 343 named declarations. Compiling 343 declarations is not whole-P19 acceptance.

## 3. Scanner controls: mixed-six, C0, unterminated

Exact root mixed-six probe (sha256 `2c717b1b9852034686d6946bcc28f414d99efd6880dd96713860f6c3e7ac6096`) replayed on the private rebuild:

```
exit: 0
stdout sha256: 0ec3c792debf9f40328a2f78e0cd97b21303911262542cf2939ab3ca21d25d02
```

Bit-for-bit R15 and author CMD-05. Six mixed-error cases restored.

Exact root C0 probe (sha256 `4bd7a9709d0e79a5ae0735db473e00dd48e70bbb701b41a92276964d43fa0daa`):

```
exit: 0
stdout sha256: 6caac5c24bbef54474ebc6635ba526341a58169148fd2c8470407aa78f90df6d
```

Bit-for-bit R16 and author CMD-07. All 32 C0 cells: `scan=ok;decode=ok;parserObject=ok`. True duplicate and equivalent escaped duplicate return `duplicateKey "a"`. Quote and backslash positives remain distinct (`scan=ok;parser=ok`).

Exact root unterminated-r19 probe (sha256 `2877ed50416845c7d9c17a6d8a8fc45e3deb095121f3b307c65bfc36433fd0a9`):

```
exit: 0
stdout sha256: a387ecb5df449818e65ceada809a223b96be47ad7eadcd621a559e7649f0b126
```

Matches frozen root R19 unterminated output. Author CMD-06 stdout hash `209e148c…` differs because the author probe pretty-prints a list; the four case results are the same tags.

`Decode.lean` `skipStringChars none` branches now check `foundWhitespace` (lines 94 and 103):

```
| none => if foundWhitespace then .error .noncanonicalWhitespace else .error .notJsonObject
```

| Case | R15 scan | R15 decode | R19 independent scan | R19 independent decode |
|---|---|---|---|---|
| `{"a": "unterminated` | `noncanonicalWhitespace` | `noncanonicalWhitespace` | `noncanonicalWhitespace` | `noncanonicalWhitespace` |
| `{"a":1, "unterminated` | `noncanonicalWhitespace` | `noncanonicalWhitespace` | `noncanonicalWhitespace` | `noncanonicalWhitespace` |
| `{"a":"unterminated` | `ok` | `notJsonObject` | `notJsonObject` | `notJsonObject` |
| `{"a":1,"unterminated` | `ok` | `notJsonObject` | `notJsonObject` | `notJsonObject` |

All four **final decoder** results match R15. No-whitespace **scanner intermediate** differs (R15 `ok`, R19 `notJsonObject`). Do not claim all intermediate bytes match. Malformed-input precedence is distinct from an admissible-domain inverse.

## 4. Runtime bound / checkBytes classification

Probe `runtime-acceptance` on the private rebuild, exit 0, stdout sha256 `e3aa510df032ffbe4606617c554a09842c4d46c51b8794d58d616e152d798d35`:

- Unterminated value/key **with whitespace**: `checkBytes` = `Outcome.codec (CodecResult.malformed DecodeFailure.noncanonicalWhitespace)`.
- Unterminated value/key **without whitespace**: `checkBytes` = `Outcome.codec (CodecResult.malformed DecodeFailure.notJsonObject)`.
- Size 1048577 (`Array.replicate 1048577 0x7b`): `scanLexical` = `resourceLimit "maxBytes"`; `checkBytes` = `Outcome.codec (CodecResult.blocked "maxBytes")`. Executed scanner/checker refusal.
- Size 1048576: size gate is `size_le` (`bytes.size > 1048576` is false). This probe tests the size **expression**, not a successful decoder.

The repaired whitespace cases are checker-visible as codec **malformed** `noncanonicalWhitespace`, not `blocked` and not kernel execution. Resource-limit blocked remains distinct. Domain 1 MiB / depth 64 / array 4096 / full canonical strings remain. C0 32 cells remain valid-domain successes.

These successful runtime probes are evidence of the scanner repair. They are not approval of `EncodeDecodeRoundtripStatement`.

## 5. Actual statements (universal byte roundtrip remains open)

`EncodeDecodeRoundtripStatement` remains `def Prop` at `Correspondence.lean:1061`:

```
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

No theorem proves that proposition.

`decodeBytes_encodeModule_of_lex_and_parse` (`Correspondence.lean:3594`) still takes `h_lex : scanLexical (encodeModule ir) = .ok ()` and `h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)`. Object-decoder success is discharged. Lexical and parser success are not.

R19 additions, exactly:

**CanonicalJson (13 new theorems)** — `TreeJson` ordered AST plus `toJson` / `tokens` / `encode`, and parser facts for scalars and **empty** containers:

- `parseStep_foldlM_tokens_null|bool|num` (any `ParserState`; these tokens always `feedValue`)
- `parseTokensList_nil`, `parseTokensObj_nil`
- `parseTokens_empty_tree_obj|arr` (require `st.stack = []` and `st.result = none` — top-empty context)
- `parseTokens_tree_null|bool|num|str|empty_arr|empty_obj`

No nonempty array/object induction. No `parseCanonicalJson (TreeJson.encode t) = .ok (TreeJson.toJson t)`. No relation from `TreeJson.encode` to production `encodeExpr` / `encodeModule`.

**Correspondence (19 new theorems)** — mostly `rfl` on fixed expressions:

- `now`, `lit` bool true/false
- `unary_not_now` fixes child to `now`
- `binary_and_now` / `ite_now` fix all children to `now`
- `balance_caller` fixes packed cell
- `timestamp` / `observe` fix id 0

These are not universal recursive constructor inverses. Hypotheses: none beyond the fixed constructors. Production connectivity: `encodeExpr` in `Encode.lean` is a separate recursive string encoder; it does not go through `TreeJson`.

**Grammar constraint for the next proof, not a claimed R19 theorem and not an invented restriction:** `parseStep` on `.str s` treats `ObjState.emptyOrKey` / `expectKey` as a **key** (`expectColon`), not `feedValue` of a string value (`CanonicalJson.lean:200-207`). A naive unrestricted `foldlM parseStep st (TreeJson.tokens (.str s)) = feedValue st (.str s)` is false in key-expecting states. Top-empty, array-value, and object-expectVal contexts, plus depth 64 / array 4096 / duplicate-key, all matter. The author correctly did not prove the unrestricted string foldlM. The required next proof is arbitrary recursive arrays/objects/Expr/envelope with those context-relative constraints and tokenizer/encoder correspondence.

No new concrete production-decoder correctness defect was found beyond the already-recorded no-whitespace scanner-intermediate difference from R15.

## 6. Author nine-command raw-stream bindings and scope

All nine frozen author commands have matching raw stdout/stderr hashes (and probe hashes where present). Original timestamps/argv/cwd/start/end/exit are in `../logs/author-command-bindings.json`. Credit is hash equality, not re-execution.

| ID | Actual scope |
|---|---|
| CMD-01 | `lean4-skills-preflight --codex`, exit 0, empty streams |
| CMD-02 | `lake build DefiKernel` **named library target**, not unqualified `lake build`. start `2026-09-10T18:22:28.240096+00:00`, end `2026-09-10T18:22:28.835987+00:00` (~0.60s). `Build completed successfully (1122 jobs).` Cache replay of that named target |
| CMD-03 | `lake build DefiKernel.Certificates.Tests`. Not re-run here |
| CMD-04 | `lake env lean DefiKernel/Certificates/Verify.lean`. Frozen log: Certificates **1552/2628**, Typed **420/677**, Composition **287/408**. Historical author execution scope, separate from this review's 343-name probe. Not re-run |
| CMD-05 | mixed-six; stdout hash equals this independent replay |
| CMD-06 | unterminated; semantic tags match; stdout bytes differ (list vs four `#eval` lines) |
| CMD-07 | C0 32 + duplicates/quote/backslash; stdout hash equals this independent replay |
| CMD-08 | author 343 `#print axioms`; name/axiom **map** equals this independent probe; print **order** does not match source |
| CMD-09 | `scripts/test_certificate_fixture_runner.py` (author 7/7). Not re-run |

No unrelated 7/21 or full 54/99/16 reruns. 54/99/16 remain deferred while the universal theorem is open.

## 7. What remains open

- `EncodeDecodeRoundtripStatement` is still a `def Prop`.
- `h_lex` and `h_parse` of `decodeBytes_encodeModule_of_lex_and_parse` are unproved success premises.
- No arbitrary nonempty array/object `TreeJson` induction; empty-container and scalar parser facts only.
- 19 new Expr theorems are fixed children/identifiers, not constructor inverses over arbitrary subexpressions.
- `TreeJson.encode` has no general relation to production `encodeExpr` / `encodeModule`.
- Nested object/array/Expr/envelope inverse, with context-relative depth/cardinality/duplicate-key and tokenizer/encoder correspondence, remains the required next proof.
- Full P19 and the full roadmap remain open. Root verifies and adjudicates.

This closeout did not re-run Lean. It reconstructs the five reports from the twelve recorded parent receipts and the already-parsed 343-name inventory.
