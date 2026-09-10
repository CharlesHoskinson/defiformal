# P19 R20 recursive token inverse independent review

- **Role**: Independent auditor. Fresh native Grok 4.6 high session. Sole reviewer. AGY R21 not inspected.
- **Requested alias**: `grok-4.6` high. **Returned model**: unknown until root terminal metadata is valid.
- **Candidate**: Frozen AGY R20 (`agy-r20-proof`), archive `068e57d0d389306887276a6cbd2193d60a30f6daf0508e7db223730c3edb5b6a`. Root stated 3601 frozen files.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-recursive-token-grok-r1-sandbox`
- **Output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-recursive-token-grok-r1`
- **Live AGY worktree / R21 / live author cache**: not inspected.
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. Layer-2 mathlib advisory (`repository_kind other-lean`, `intent.source default`). No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false. Author disposition `PARTIAL_PROOF_WORK` is accurate: R20 has a genuine general TreeJson token inverse and a genuine general Expr token inverse. Neither 418 nor 434 named counts close full P19.

## Lean4 Review Report

**Scope:** CanonicalJson.lean + Correspondence.lean (R20 changed files). Decode/Encode/Schema byte-equal to R19 and not rebuilt as new proof work.

**Resolved inputs:** `--scope=changed` on frozen R20 certificate sources; `--mode=batch`; Layer-2 advisory from `lean4-skills-project-context`.

## 1. Independent rebuild identity

Private Lean copy: `private-lean` (excluded from the manifest as growing cache). Packages are a symlink to the pinned mathlib tree. Build cache was copied from the R19 private tree, not from any live AGY cache. CanonicalJson, Correspondence, Encode, Decode, Check, Observation, Soundness, Tests, Verify, and Audit oleans were deleted and rebuilt as consumers.

```
cwd: .../p19-recursive-token-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T19:34:27.393226+00:00
end:   2026-09-10T19:39:10.755139+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
stdout sha256: d2ba6849b6df86bc41ec579d7f36a67c4c96dc2efda01bba98986b97138065a3
jobs: 932
Schema: Replayed (source byte-equal)
CanonicalJson: Built 7.2s
Encode: Built 1.8s (source bytes unchanged; rebuilt after CanonicalJson)
Decode: Built 2.9s (source bytes unchanged; rebuilt after CanonicalJson)
Check: Built 2.1s
Observation: Built 1.3s
Correspondence: Built 266s
```

| File | sha256 | vs R19 |
|---|---|---|
| CanonicalJson.lean | `67ae180613f04fb6ee652878b01634119fead96f92be2df36d3ee40226c5b0fb` | changed by addition |
| Correspondence.lean | `93a3a29e90a3c844b3d2309240d266b782b3fc7b137e671d12964a217d6ceaa9` | changed by addition |
| Decode.lean | `7561716fe3f2bdba355015de7c1b81e3c594f1d6a51df0009294be248c38a23d` | byte-equal |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | byte-equal |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | byte-equal |

Check/Tests/Verify/Observation/Soundness hashes match R19. Sorry-analyzer `--report-only` on CanonicalJson and Correspondence: 0 sorry statements, exit 0, stdout sha256 `ca6b5a162191465a7b9728a46f1914076d5d60aec74fe586f2af3f00a938b679`. `native_decide` / `sorry` occur only in comments (`logs/source-forbidden-scan.json`, Correspondence lines 24 and 1015). No custom `axiom` declarations.

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

`lean4-skills-check-axioms-inline --report-only` on CanonicalJson exited 1 (`Only 86 of 126 declarations resolved`). Zero credit. Axiom evidence is the successful `#print axioms` probe below, not that helper.

## 2. Exact 418 and 434 named sets

Independent `^theorem|^lemma` extraction, including dotted `TreeJson.*` names:

| Count | Value |
|---|---|
| CanonicalJson theorems | 106 |
| Correspondence theorems | 311 |
| Correspondence lemmas | `exprDepth_pos` |
| Named theorem/lemma total | **418** |
| Previous R19 named present | 343 / 343 |
| New theorem/lemma declarations | **75** |
| Extra defs | 16 (`IsValueContext` + 15 `*ToTreeJson` maps) |
| Author inventory | **434** |

`exprDepth_pos` predates R17. It is not new R20 work. R20 adds 75 theorems/lemmas, not 91 new theorems. The author's 91-item list mixes those 75 with the 16 defs.

Independent `#print axioms` command `probe-axioms434` against the **private rebuild** (not the author worktree):

```
exit: 0
stdout sha256: 5d88fb5793efa036740d7717240dc0fa5cdd888cdc41f7189bba6de8558e64c9
stderr: empty
NAMED_PLUS_DEFS=434
THEOREMS_LEMMAS=418
Lean error lines: none
418: 390 standard, 28 none
434: 391 standard, 43 none
forbidden: []
print order matches source: true
name/axiom map equals frozen author CMD-08: true
includes exprDepth_pos: true
includes TreeJson.size_pos: true
includes all 16 defs: true
```

The 15 `*ToTreeJson` maps print with no axioms. `IsValueContext` uses standard axioms, which is why 434 has 391 standard / 43 none while 418 has 390 standard / 28 none (28 + 15 = 43; 390 + 1 = 391).

Author `named_axioms_434.lean` print **order** is not source declaration order (first mismatch at index 68: author `jsonDepth_scalar`, source `parseStep_foldlM_tokens_null`). The name **set** and axiom **map** still match. Independent probe order matches source. Author CMD-08 stdout hash `5ef0c45ef3b3b3df38d8efed9bbd575e0599a66a6ce604181d692a162fa73883` is a different byte stream because of that order, not because of a different axiom map.

`EncodeDecodeRoundtripStatement` is a `def Prop` and is correctly absent from the 418 named declarations. Compiling 418 or 434 declarations is not whole-P19 acceptance.

Author REPORT section 4 claims 422 standard / 12 none. That is inconsistent with the actual 434 probe. General theorems use standard axioms, so "without axioms" is false.

## 3. Substantive new proofs

### 3.1 `parse_tokens_tree` / `parseTokens_tree_valid`

These are not finite examples. `parse_tokens_tree` is well-founded on `TreeJson.size`. For `.arr` / `.obj` it derives child validity from `valid_of_mem_validList` / `valid_of_mem_validObj` and child-size strict decrease from `mem_sizeList` / `mem_sizeObj`, then applies the inductive hypothesis in a value-expecting context.

`IsValueContext` is empty stack, `arr emptyOrVal` / `arr expectVal`, or `obj expectVal`. Key-expecting, colon-expecting, and comma-expecting states are excluded. That is a theorem hypothesis, not a new public IR domain.

Nested resource errors are not claimed to succeed. Scalar and completed-container steps prove `foldlM parseStep = feedValue`, then case on `feedValue`, so a parent that is already at array 4096, duplicate key, or depth 64 fails on both sides. Child folds themselves are admitted only under `Valid` (array length ≤ 4096, object key `Nodup`) and `stack.length + depth ≤ 64`.

Object accumulation is cons-front, then `parse_tokens_obj` uses `List.reverse_reverse` so `mkObj` sees declaration order. Array cardinality is `acc.size + xs.length ≤ 4096`. Key disjointness of a new field against `acc` is proved from `Nodup` of `kvs.map Prod.fst`.

`parseTokens_tree_valid` specialises that lemma to the empty stack. It inverts `TreeJson.tokens`, not `tokenize (TreeJson.encode t)`.

### 3.2 Production Expr correspondence and general token inverse

`escapeTreeString_eq_escapeJsonString`, `encode_arr_eq_jsonArr`, and `encode_obj_eq_jsonObj` connect `TreeJson.encode` to production `jsonArr` / `jsonObj` in `Encode.lean`. `jsonObj` is declaration-order intercalation, not a sort. Envelope bytes remain declaration order (`encodeEnvelope`). `encodeSourceMap` uses the sorted fast path. `Lean.Json.mkObj` remains the semantic sorted object constructor. No bytes=compress assumption was introduced.

`exprToTreeJson_toJson`, `exprToTreeJson_encode`, and `exprToTreeJson_valid` are induction over arbitrary `ExprEnc`. `exprToTreeJson_encode` is actual production `encodeExpr`, not an alternate codec.

`parseTokens_exprToTreeJson` and `expr_tokens_end_to_end` are genuine general token inverses. R19's `now` / `unary .not .now` / `binary .and .now .now` theorems remain historical finite `rfl` cases. They are not the R20 result.

Remaining premises on the general inverse:

- `TreeJson.Valid (exprToTreeJson e)` is proved for every `ExprEnc`.
- `TreeJson.depth (exprToTreeJson e) ≤ 64` is an extra hypothesis. `ExprCanonical` already contains `ExprEnc.depth ≤ 64`, but a `lit` mapping is a nested object of `TreeJson.depth` 2 while `ExprEnc.depth` is 1, so the tree-depth bound is not implied by `ExprCanonical` alone.
- `expr_tokens_end_to_end` still requires `ExprCanonical` and uses existing `decodeExpr_exprToJson`.
- The inverted stream is `TreeJson.tokens (exprToTreeJson e)`, not the lexer of `encodeExpr e`.

### 3.3 PackedValue and the "14 types" claim

Inspected, not accepted from the report. Thirteen of the listed maps have `toJson`, `encode`, and `valid`. `packedValueToTreeJson` has mapping and `packedValueToTreeJson_toJson` only. There is no `packedValueToTreeJson_encode` or `packedValueToTreeJson_valid`. The mapping is also not the production `encodePackedValue` object (`unit`/`value`); it is the inner bool/rat payload used by `exprToTreeJson` `.lit`.

## 4. Remaining scope (unchanged public domain)

`StructurallyAdmissibleIR` is unchanged. `TreeJson.Valid` and the depth-64 hypotheses are theorem premises. They are not an extra public domain restriction and they do not prove parser admission of `encodeModule` bytes.

Still open:

- `EncodeDecodeRoundtripStatement` remains a `def Prop`.
- `decodeBytes_encodeModule_of_lex_and_parse` still assumes `h_lex` and `h_parse`.
- General tokenization of `TreeJson.encode` is not proved.
- Full envelope/module TreeJson mapping and scanner admission are not proved.
- JSON bytes 1 MiB / depth 64 / array 4096 / full strings remain. Size 1048576 is a size-gate expression, not a successful decode.

## 5. Author nine-command raw streams

All nine frozen raw stdout/stderr hashes match `commands.json`. Probe hashes for CMD-05..08 match. Credit is hash equality, not re-execution.

| ID | Name | Exit | Notes |
|---|---|---|---|
| CMD-01 | preflight | 0 | empty stdout/stderr |
| CMD-02 | `lake build DefiKernel` | 0 | 0.784s, `Build completed successfully (1122 jobs)`. Named library target, cache replay, not unqualified full `lake build` |
| CMD-03 | Tests | 0 | not re-run; hash-bound |
| CMD-04 | Verify.lean | 0 | raw PASSED lines: Certificates **1659**/2686, Typed 420/677, Composition 287/408. Report 1658 is wrong |
| CMD-05 | mixed-error | 0 | stdout `0ec3c792…`, historical R15 |
| CMD-06 | unterminated | 0 | four **final** decoder outcomes match R15; no-whitespace scanner intermediate differs; C0 baseline is R16 |
| CMD-07 | C0 | 0 | stdout `6caac5c2…`, historical R16 |
| CMD-08 | named 434 | 0 | axiom **map** equals independent probe; print order differs at index 68 |
| CMD-09 | fixture runner | 0 | 7/7 not re-run; hash-bound |

Scanner controls were independently verified on R19 and author-replayed here. Decode/Encode/Schema are byte-equal, so 7/21/54/99/16 were not re-run.

R19 did not contain `parse_arr_tokensList_cons_cons` or `parse_obj_tokensObj_cons_cons`. Missing-`finalSt` repairs belong to R20.

## 6. Disposition

`CHANGES_REQUIRED`. Strongest actual R20 result: general bounded TreeJson token parser inversion plus actual `encodeExpr` tree representation equality and arbitrary recursive Expr token inverse. Whole-document byte tokenizer/scanner success and complete envelope/module correspondence remain open. The full authorized core objective stays active.
