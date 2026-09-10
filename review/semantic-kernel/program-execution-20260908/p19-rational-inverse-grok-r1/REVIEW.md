# P19 R17 rational-inverse independent review

- **Role**: Independent auditor. Requested alias `grok-4.6`. Native process identity is `unknown` (`process.json`; command metas record `unknown`). Root captures terminal telemetry.
- **Candidate**: Frozen AGY R17 (`agy-r17-proof`), archive `b9d2e0601c36d3d1c696a5379fba1239f200bded650679e7bff62281f8d86464`. Root stated 3494 frozen files verified.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-rational-inverse-grok-r1-sandbox`
- **Output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-rational-inverse-grok-r1`
- **Live AGY R18**: not inspected (worktree, drafts, and cache untouched).
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false. Author disposition `PARTIAL_PROOF_WORK` is accurate for the rational component and does not close whole P19.

## 1. Independent rebuild identity

Private Lean copy: `private-lean`. Packages are a symlink to the pinned mathlib tree. Build cache was copied from the R16 private tree; CanonicalJson and Correspondence oleans were deleted and rebuilt.

```
cwd: .../p19-rational-inverse-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T17:48:59.689470+00:00
end:   2026-09-10T17:51:34.375973+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
jobs: 932
CanonicalJson: 3.2s
Encode: 1.2s (source bytes unchanged; rebuilt after CanonicalJson)
Decode: 2.1s (source bytes unchanged; rebuilt after CanonicalJson)
Correspondence: 145s
```

Schema was not rebuilt (R16 cache reused; Schema bytes unchanged).

| File | sha256 | vs R16 |
|---|---|---|
| CanonicalJson.lean | `68335a6e8f7722041689602a782139fdc6c1c127d17544e531ef2e6a0616692c` | changed by addition |
| Correspondence.lean | `bc4c47b988d9952cc31c3ad36ba8ed831025a0e8db95122a10ae77ebe4ca31e4` | changed by addition |
| Decode.lean | `bd38b66b42f6b2a7fb312258ee0abfba0e24f316e085e3768eaa92d95fa1328d` | byte-equal |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | byte-equal |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | byte-equal |

Independent line check against the frozen R16 private-lean copy: 0 R16 lines absent from R17 CanonicalJson/Correspondence; R16 text is an ordered subsequence. Decode/Encode/Schema byte-equal. Check/Tests/Verify/Observation/Soundness hashes match R16.

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

Sorry-analyzer `--report-only` on CanonicalJson and Correspondence: 0 sorry statements, exit 0. `native_decide` occurs only in comments.

## 2. Exact 299-name axiom gate (successful)

Source extraction of `^theorem|^lemma` in `probes/axioms299/inventory.json`:

| Count | Value |
|---|---|
| CanonicalJson theorems | 62 |
| Correspondence theorems | 236 |
| Correspondence lemmas | `exprDepth_pos` |
| Named total | **299** |
| Previous R16 theorems present | 269 / 269 |
| New theorem declarations | 29 |

A theorem-only regex would report Correspondence 236 and miss `exprDepth_pos`. Root attempt1 failed that way. This inventory includes the lemma.

Independent `#print axioms` command `probe-axioms299` against the **private rebuild** (not the author worktree):

```
exit: 0
stdout sha256: a7d8e909d7997b67e6b9b8e2e05a83028034fc1d70603adb19ce07a01cf31df6
stderr: empty
NAMED=299 printed
Lean error lines: none
standard axiom records: 287
zero axiom records: 12
forbidden: []
print order matches source: true
name/axiom pairs match root author-import Axioms299.stdout: true
```

Zero-axiom names:

`lexDigits_step_eq`, `foldl_max_congr`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`, `distinct_of_pairwise_lt`, `standard32CellKeys_eraseDups_len`, `envelopeOrderedKeys_nodup`, `typedPayloadKeys_nodup`, `stepPayloadKeys_nodup`, `runPayloadKeys_nodup`.

`lexDigits_step_eq` is the new R17 zero-axiom theorem. The other eleven match the R16 root zero set. `EncodeDecodeRoundtripStatement` is a `def Prop` and is correctly absent from the 299 named declarations.

This review's stdout is not the root precheck stdout (root probe has no `PROBE_AXIOMS_START`/`NAMED=299` evals). The 299 name/axiom pairs are equal. Root's check used author-build imports; this check used the private rebuild.

## 3. Actual statements (universal byte roundtrip remains open)

`EncodeDecodeRoundtripStatement` remains `def Prop`:

```
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

No theorem proves that proposition.

`decodeBytes_encodeModule_of_lex_and_parse` still takes `h_lex : scanLexical (encodeModule ir) = .ok ()` and `h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)`. Object-decoder success is discharged. Lexical and parser success are not. Parse target is `decodedIRToJson ir`, not helper `.compress` byte equality. The declaration compiles with standard axioms; that does not prove the premises.

R17 adds a genuine general rational component:

- `lexDigits_of_all_digits`: all-digit lists reconstruct `Nat.ofDigitChars` given a non-digit or empty suffix.
- `tokenizeFuel_nat` / `tokenizeFuel_int`: arbitrary `Nat` and `Int` (including `negSucc`) with a non-digit suffix. The number token is inverted. The suffix remains `tokenizeFuel fuel rest` bind, discharged for `encodeRat` by delimiter steps (`','`, `'}'`).
- `parseTokens_rat`: `rfl` on the nine-token canonical rational sequence; no extra hypothesis.
- `parseCanonicalJson_encodeRat (r : RatEnc)`: `parseCanonicalJson (encodeRat r) = .ok (ratToJson r)` for all `r`, no scalar bound.
- `rat_end_to_end_universal`: that parser inverse plus `decodeRat_ratToJson`, requiring `r.den ≠ 0` and `Int.gcd r.num.natAbs r.den = 1`.

`tokenizeFuel_digit_step` takes `h_lex`; `tokenizeFuel_nat` discharges it. That is a support lemma, not a hidden success of the number.

Not closed: `parseCanonicalJson_of_tokenize_parseTokens` still assumes `h_tok`/`h_parse`. `parse_obj_field_step` and `parse_arr_feed_elem` still assume child `foldlM` success (`h_val` / `h_feed`). No theorem inverts arbitrary nested payload, list, object, or envelope encoder bytes.

## 4. Scanner mixed-error precedence (not replayed)

Decode bytes are unchanged from R16. Root already measured four mixed-error final-failure changes to `notJsonObject` after an earlier invalid escape (scientific, whitespace, later duplicate `b`, depth 65). Two order-control cases are unchanged. This is malformed-input precedence, not an admissible-domain roundtrip counterexample. AGY R18 has the repair brief. This audit did not replay those scanner controls.

Previous 32 C0 key collisions remain repaired in the unchanged Decode/lexString path. Canonical key identity domain is not shrunk in the inspected source.

## 5. encodeEnvelope / sourceMap / helper JSON

Source inspection of unchanged Encode (not a production-byte-equality claim):

- `jsonObj` concatenates the supplied field list.
- `encodeEnvelope` passes declaration order into `jsonObj`.
- `encodeSourceMap` sorts entries, with an already-sorted fast path, then calls `jsonObj`.
- `Lean.Json.mkObj` sorts internally. Parser equality to helper JSON is not raw `.compress` equality.

## 6. Author evidence flaws (historical reports unmodified)

Frozen author `commands.json` omits actual start/end timestamps and raw stdout/stderr hashes. CMD-03 claims Decode “strictly maintaining … error precedence”. Decode is byte-equal to R16, so that claim is false.

Author REPORT cites Verify 287/408. Frozen author `compiler-axiom-audit.log` sha256 `be93330d19ace1acd74f349fbadc17e32d98272a809f0fb4b767a667c901f328` (matches root scope check) has three `#audit_axioms` prefixes from `Verify.lean`:

| Prefix | theorems | supplemental |
|---|---|---|
| Certificates | 1486 | 2539 |
| Typed | 420 | 677 |
| Composition | 287 | 408 |

287/408 is Composition only. This review did not re-run `Verify.lean` or the 7/21 suites. Exact 299 and the three Verify prefixes are distinct scopes.

Author `new_theorems_in_r17` lists `exprDepth_pos` as new. It is the pre-existing R16 lemma. Actual new theorem declarations: 29.

## 7. Remaining obligations

1. Prove `EncodeDecodeRoundtripStatement` (still a `def Prop`).
2. Prove `h_lex` and `h_parse` of `decodeBytes_encodeModule_of_lex_and_parse` from `StructurallyAdmissibleIR`, then compose an unconditional byte roundtrip.
3. Recursive pushdown inversion for arbitrary nested objects/arrays/payloads/lists/envelopes, using induction hypotheses rather than assumed child `foldlM` success.
4. Restore mixed-error precedence while retaining escaped-key repair and true duplicate refusal (R18 production repair; Decode unchanged here).
5. Do not treat the general rational inverse as whole-document certification.

Whole P19 remains open. Full roadmap remains open. Root independently adjudicates.

## 8. lean4-skills review fallback

scripts_only+review_only. Layer-2 mathlib taxonomy is advisory (`repository_kind: other-lean`, contributing_upstream unknown). No vacuous-API theorem proving `True`; the open obligation is an unproved `def Prop`. No LSP. No statement edits.
