# P19 R16 scanner-repair independent review (reporting closeout)

- **Role**: Independent auditor. Requested alias `grok-4.6`. Native process identity is `grok-4.6-build` (`process.json` reported_models; original command metas recorded `unknown`).
- **Session**: `01a08c3a-3869-7af0-99e5-d158d774830d`. Original 30-turn process exit 1 at cap (`cancelled_at_max30_turns`). This closeout is same-session reporting completion, not a new audit.
- **Candidate**: Frozen AGY R16 (`agy-r16-proof`), archive `dc2bdeace9918e879bf7c3bf4e5afab3f34f2c4b403ca6a2def172ee1e174864`. Root stated 3488 frozen files verified.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-scanner-repair-grok-r1-sandbox`
- **Original output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-scanner-repair-grok-r1`
- **This closeout**: writes only under `.../p19-scanner-repair-grok-r1/closeout`. Parent logs, probes, failed probes, tools, and private build are immutable.
- **Live AGY R17**: not inspected.
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false. No 54/99/16 campaign acceptance.

## 1. Credit correction (this review's own records)

Two recorded commands have `credit: true` in immutable `logs/*/meta.json` while `exit` is 1. Those flags are erroneous success credit. Original records are not rewritten. This closeout adjudicates:

| Command | Recorded exit | Recorded credit | Adjudicated credit | Reason |
|---|---|---|---|---|
| `probe-axioms269` | 1 | true | **false** | Invalid trailing `#eval` interpolation `s!"NAMED={len(theorems_cj) + len(theorems_co)}"`. Compiler error `expected '}'`. Printed axiom lines before that error do not make failed compilation a successful 269-name axiom gate. |
| `encode-sourcemap` | 1 | true | **false** | Doc-comments immediately before `#eval` (`unexpected token '#eval'; expected 'lemma'`). Also `String.containsSubstr` does not exist. Emitted `#eval` strings do not make failed compilation a successful encodeSourceMap gate. |

Failed original sources and outputs remain under `../failed-probes/axioms269-attempt1` and `../failed-probes/encode-sourcemap-attempt1`, and the live `../probes/*/Probe.lean` plus `../logs/*/stdout` copies. They were not overwritten for a green rerun.

`c0-replay` is distinct: exit 0, recorded credit true, adjudicated credit true.

`probes/limits/Probe.lean` exists. There is no `logs/limits` directory and no receipt. That probe is **unrun**. Resource-limit and malformed-input execution review is incomplete.

`../root-verification` was not present at closeout write time. If root later checks the 269-name inventory on the rebuilt imports and replays C0 there, that is a separate root verification, not this review's original successful command.

## 2. Independent rebuild identity

Private Lean copy: `../private-lean`. Packages are a symlink to the pinned mathlib tree. Build cache was copied from the R15 private tree, then R16-changed oleans were deleted and rebuilt.

```
cwd: .../p19-scanner-repair-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T17:00:49.737617+00:00
end:   2026-09-10T17:04:53.734796+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
jobs: 932
Schema: 7.7s
CanonicalJson: 2.4s
Encode: 1.5s
Decode: 2.9s
Correspondence: 225s
```

R16 changed CanonicalJson, Correspondence, Decode, Encode, Schema. Check/Tests/Verify/Observation/Soundness/Audit hashes match the R16 terminal manifest and are unchanged relative to that freeze.

| File | sha256 | bytes |
|---|---|---|
| CanonicalJson.lean | `9fa5516f6f9fc104ed6f849299e5572cae762a35bac8e4df397374d5682cec8b` | 27686 |
| Correspondence.lean | `acf96825e545a69057bef9e911141aad7d26a132aff989c5b549ebe9ecbdc998` | 176139 |
| Decode.lean | `bd38b66b42f6b2a7fb312258ee0abfba0e24f316e085e3768eaa92d95fa1328d` | 63497 |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | 24718 |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | 23421 |

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

Sorry-analyzer `--report-only` on CanonicalJson and Correspondence: 0 sorry statements, exit 0. File comments that mention sorry / native_decide are not proofs.

## 3. Named set versus failed axiom gate

Independent source extraction (`^theorem` / `^lemma`) in `../probes/axioms269/inventory.json`:

| Count | Value |
|---|---|
| CanonicalJson theorems | 48 |
| Correspondence theorems | 221 |
| Named theorems | 269 |
| Extra lemma, not in 269 | `exprDepth_pos` |

That extraction is source inspection. It is not a `#print axioms` success.

The exact-name `#print axioms` command `probe-axioms269` **failed** (exit 1). `probes/axioms269/parsed.json` is a diagnostic parse of that failed stdout (269 names, 258 standard, 11 none, 0 forbidden, names matching source order). It is **not** a successful compiler axiom gate. Root independently checking the 269-name inventory on the rebuilt imports is a separate verification if and when `../root-verification` exists.

Author REPORT lists a different 11-name zero-axiom set (`envelopeSortedFields_no_commands`, `ofList_toList_eq`, `compare_lt_of_lt`, `pairwise_lt_of_isSortedStrictAscending` among others). Author's own named-probe log in `agy-r16-proof/compiler-axiom-audit.log` prints `does not depend on any axioms` for the R15 eleven (`foldl_max_congr`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`, `distinct_of_pairwise_lt`, `standard32CellKeys_eraseDups_len`, `envelopeOrderedKeys_nodup`, `typedPayloadKeys_nodup`, `stepPayloadKeys_nodup`, `runPayloadKeys_nodup`) and prints standard axioms for the REPORT-listed replacements. That is an author-report mismatch. It is not closed by this review's failed axiom command.

`escapedKeyCollision_admissible` is a real `theorem` in Correspondence, proved `by decide` after `dsimp`/`refine`, compiled as part of the Correspondence rebuild. It is not a successful independent `#print axioms` gate from this review. Author log prints standard axioms `[propext, Classical.choice, Quot.sound]` for it. R15 attempt1 `sorryAx` failure is preserved under `../failed-probes/r15-escaped-key-attempt1` and has zero proof credit.

## 4. Actual statements (universal theorem remains open)

`EncodeDecodeRoundtripStatement` remains `def Prop`:

```
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

No theorem proves that proposition.

`decodeBytes_encodeModule_of_lex_and_parse` still takes `h_lex : scanLexical (encodeModule ir) = .ok ()` and `h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)`. It discharges object-decoder success via `decodeDecodedIR_of_structurallyAdmissible`. It does not prove lexical or parser success. Parse equality is to `decodedIRToJson ir`, not raw helper `.compress` bytes.

New CanonicalJson `parseStep_*` / `feedValue_*` facts are step equalities, several with success hypotheses (`h_len`, `h_not_dup`, `h_depth`, child `foldlM`). They do not close arbitrary recursive parser inversion.

New Correspondence scalar facts `parseCanonicalJson_encodeCell_all` (finite `CellEnc` case split), `parseCanonicalJson_encodeCellRef_caller`, seven fixed `parseCanonicalJson_encodeRat_*` values, and `parseCanonicalJson_encodeStateCell_zero` (32 coordinates, amount `0/1` only) do not close generic rational or nested-document inverse.

## 5. Scanner repair: successful C0 replay

Root C0 probe was copied and replayed against the private R16 rebuild.

```
id: c0-replay
exit: 0
stdout sha256: 6caac5c24bbef54474ebc6635ba526341a58169148fd2c8470407aa78f90df6d
matches root-original receipt stdout_sha256: true
```

32 control-character rows: `scan=ok;decode=ok;parserObject=ok`, size 3455, depth 6, maxArray 32, sorted true. True duplicate `{"a":"1","a":"2"}` and equivalent escape `{"a":"1","\u0061":"2"}` both `duplicateKey "a"` at scanner and parser. Quote and backslash positives scan and parse ok.

This is bounded runtime evidence that `scanLexical` now uses `lexString` for key meaning. It is not a universal `h_lex` proof and not whole-P19 acceptance.

`scanLexical` array counting increments on commas (`cnt + 1 > 4096`). Parser `feedValue` refuses `acc.size >= 4096`. Whole-document `jsonMaxArrayLength` is a third measure. Those stages were **not** executed: `probes/limits` has no receipt. Source inspection of the two counters is not a measured resource-limit result.

Author REPORT claims invalid escape yields `.error "invalid string escape in lexical scan"` and that `lexString` returns `none`. That string occurs only in the author REPORT. `lexString` returns `Except DecodeFailure` and uses `.error .notJsonObject` on malformed escapes. Malformed-string execution was not run (limits probe unrun).

`decodeBytes` remaps parser errors other than `resourceLimit` to `notJsonObject`. Scanner still runs first.

## 6. encodeSourceMap fast path, sort helper, encoder order

Source inspection of frozen Encode/Schema/Correspondence (not a successful encode probe):

- `isSortedStrictAscending` now lives in Schema and is used by `SourceMapSorted`.
- `encodeSourceMap` fast-paths already strictly ascending key lists, otherwise `qsort`.
- `jsonObj` concatenates the supplied field list. `encodeEnvelope` passes declaration order into `jsonObj`. `encodeSourceMap` sorts entries, then calls `jsonObj`.
- `Lean.Json.mkObj` sorts. `decodeSourceMap_sourceMapToJson` inverts `mkObj` of a sorted map, not raw `jsonObj` bytes. Parse equality to helper JSON is not raw `.compress` equality.
- Canonical domain was not observed to shrink in the source: `SourceMapSorted` is still strict ascending keys; the fast path is identity on that class.

The encode-sourcemap probe failed compilation. Side-printed strings in that failed log have **zero gate credit**.

R15 failed `decide`/`sorryAx` attempt1 is preserved separately and is not R16 admissibility evidence.

## 7. Verify 287/408 is one prefix

This review did not re-run `Verify.lean` or the 7/21 suites. Author `compiler-axiom-audit.log` (author-captured):

| Prefix | theorems | supplemental |
|---|---|---|
| Certificates | 1415 | 2533 |
| Typed | 420 | 677 |
| Composition | 287 | 408 |

Author REPORT cites 287/408 as the Verify result. That is the Composition `#audit_axioms` line in `Verify.lean`, not the named CanonicalJson+Correspondence 269 and not the Certificates prefix. exact269 and historical Verify outputs are distinct.

## 8. Remaining obligations

1. Prove `EncodeDecodeRoundtripStatement` (still a `def Prop`).
2. Prove `h_lex` and `h_parse` of `decodeBytes_encodeModule_of_lex_and_parse` from `StructurallyAdmissibleIR`, then compose an unconditional byte roundtrip.
3. Recursive pushdown inversion for arbitrary nested objects/arrays.
4. Generic numeric/rational parser inverse, not seven fixed rationals and finite CellEnc splits.
5. Independent successful `#print axioms` of the exact 269 names (this review's command failed). Root may supply that separately.
6. Execute byte/depth/array/malformed-string/error-precedence probes if those bounds are to be claimed as measured (limits probe unrun).
7. Author REPORT zero-axiom name list and invalid-escape wording.

Full P19 remains false while the universal theorem is open.
