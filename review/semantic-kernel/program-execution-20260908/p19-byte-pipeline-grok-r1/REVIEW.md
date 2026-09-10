# P19 R15 byte-pipeline independent review

- **Role**: Independent auditor. Native Grok 4.6 high was requested. Root records the actual returned model. This file does not treat `grok-4.6-high` as a completed native identity.
- **Candidate**: Frozen AGY R15 (`agy-r15-proof`), archive `e7483b6367d3871f97b59c1f095c489465c654e1dfb8838ddcd78685edd9e9c7`, 3482 files.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-byte-pipeline-grok-r1-sandbox`
- **Output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-byte-pipeline-grok-r1`
- **Live AGY R16**: not read.
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes.
- **Verdict**: `CHANGES_REQUIRED`. Full P19 acceptance is false.

## 1. Verdict

R15 adds 30 named theorems and an exact 247-name axiom inventory. Independent private rebuild and `#print axioms` confirm 37 CanonicalJson + 210 Correspondence theorems, 236 standard-axiom, 11 none, 0 forbidden, 0 `sorry` in those files.

That is component progress, not universal byte roundtrip.

`EncodeDecodeRoundtripStatement` remains a `def Prop`. `decodeBytes_encodeModule_of_lex_and_parse` still assumes unproved `h_lex` and `h_parse`. The lexical scanner falsely reports `duplicateKey au000a` on distinct keys `a`+newline and literal `au000a`, while `parseCanonicalJson` plus the object decoder succeed. Attempt1's `StructurallyAdmissibleIR` proof failed with `sorryAx` and has zero proof credit.

Author wording that R15 resolves all R14 findings and that the pipeline theorem has zero decoder assumptions overstates the remaining premises. Auditor identity in the author report is correctly pending.

## 2. Independent rebuild and 247-name audit

Private Lean copy under `private-lean/`. Packages are a read-only symlink to the pinned mathlib tree. Build cache was copied from the prior structural-admissibility private tree, then CanonicalJson and Correspondence were rebuilt.

```
cwd: .../p19-byte-pipeline-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
exit: 0
jobs: 932
CanonicalJson: 2.2s
Correspondence: 145s
```

Source hashes of the private copy match the frozen sandbox. Encode and Decode are unchanged from R14 (`66debd7d…`, `05f54987…`). CanonicalJson `17d98b20…` and Correspondence `69180020…` are the R15 files.

`probes/axioms247/Probe.lean` prints axioms for every `^theorem` name in those two files (not the extra lemma `exprDepth_pos`).

| Count | Value |
|---|---|
| Named theorems | 247 |
| CanonicalJson | 37 |
| Correspondence | 210 |
| Standard axioms only | 236 |
| Empty axiom list | 11 |
| Forbidden axioms | 0 |
| Child compiler exit | 0 |

Empty-axiom names: `foldl_max_congr`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`, `distinct_of_pairwise_lt`, `standard32CellKeys_eraseDups_len`, `envelopeOrderedKeys_nodup`, `typedPayloadKeys_nodup`, `stepPayloadKeys_nodup`, `runPayloadKeys_nodup`.

Sorry-analyzer `--report-only` on both files: 0 sorries. File comments that mention `sorry` / `native_decide` are not proofs. Accepted R15 kernel proofs use `decide`, not `native_decide`.

This 247 inventory is not the Verify.lean import-prefix totals.

## 3. Actual statements

`encodeModuleString` is the same `match` as `encodeModuleCanonical` before `.toUTF8`. `encodeModule_eq_toUTF8` is definitional. `string_fromUTF8_encodeModule` rewrites with `string_fromUTF8?_toUTF8`.

`decodeBytes_eq_of_steps` requires five success hypotheses, including `scanLexical`, UTF-8, `parseCanonicalJson`, `decodeDecodedIR`, and `encodeModule ir = bytes`.

`decodeBytes_encodeModule_of_lex_and_parse` keeps `StructurallyAdmissibleIR ir`, `h_lex`, and `h_parse`. It discharges the object decoder with `decodeDecodedIR_of_structurallyAdmissible`. It does not prove `h_lex` or `h_parse`. The parse target is `decodedIRToJson ir`, not `Json.compress` byte equality.

`parseStep_*` are context-general definitional equalities. `parse_arr_feed_elem` and `parse_obj_field_*` assume a successful child `foldlM`. They are step facts, not recursive induction over nested arrays and objects.

`parseCanonicalJson_encodeRat_witness` is only `⟨0, 1⟩`. `parseCanonicalJson_encodeCell_witness` is only `⟨.main, .alice, .usd⟩`. Those examples do not prove generic numeric or rational parser inversion. Party/asset/domain inverses are enumeration splits.

## 4. Escaped-key scanner diagnostic

Root attempt2 was copied and replayed against frozen R15.

Independent stdout (exit 0), sha256 `330523d46fe73c1cbcadd454611ac3bf415a6ef42c6ebc3e606913e13f1ad928`, identical to the root attempt2 log:

- encoded source map `{"a\u000a":"1","au000a":"2"}`
- `scanLexical` / `decodeBytes`: `duplicateKey au000a`
- parser + object decoder: ok
- bytes 3453, depth 6, max array 32, sorted true

`scanLexical` sets `escape := true` on `\` and then appends the next character without decoding `\uXXXX`. `lexString` decodes `\u000a` to newline. Extra probe:

- `lexString` on `\u000a` → ok newline
- `lexString` on `u000a` → ok `"u000a"`
- true duplicate key `same`: scanner and parser both `duplicateKey same`
- lone newline key and lone literal `au000a` each scan ok
- `jsonObj [("b","1"),("a","2")]` preserves list order: `{"b":1,"a":2}`

True duplicate refusal still works. The defect is false identity of an escaped control character with a literal spelling. Preserving the full canonical string domain requires scanner repair. Author R16 was not inspected.

Attempt1 independently failed: `decide` on `encodeModule` byte-size, compiler exit 1, `sorryAx` on `escapedKeyCollision_admissible`. Zero proof credit. Original root source/log remain under `probes/escaped-key/root-original/attempt1`. This replay's stdout hash differs only because Lean embeds the probe path in the error. That is not a kernel-proved admissible counterexample.

## 5. Report and compiler evidence

Author `Verify.lean` runs three `#audit_axioms` prefixes. The author log PASS lines are:

| Prefix | Theorems | Supplemental |
|---|---|---|
| `DefiKernel.Certificates` | 1392 | 2520 |
| `DefiKernel.Typed` | 420 | 677 |
| `DefiKernel.Composition` | 287 | 408 |

Cited 287/408 is the Composition scope line, not the 247 named theorems and not the Certificates prefix. This review did not re-run Verify.lean, the 7/21 suites, or 54/99/16.

Author `auditor_model` is pending. That is correct.

`jsonObj` preserves list order. `Lean.Json.mkObj` sorts. `encodeEnvelope` uses `jsonObj` in declaration order. `envelopeToJson` uses `mkObj`. Parse equality is the JSON value, not `.compress`.

Fixture-runner symlink tests refuse a live relative sibling symlink and keep the sentinel. There is no blanket parent-symlink requirement.

## 6. Remaining open

1. Universal `EncodeDecodeRoundtripStatement`.
2. Unproved `h_lex` and `h_parse`.
3. Recursive parser inverse.
4. Generic numeric/rational parser inverse.
5. Scanner escape decoding on the full canonical string domain.
6. Kernel-proved admissibility of the escaped-key witness.

Full P19 acceptance remains false. Root independently checks and adjudicates this review.
