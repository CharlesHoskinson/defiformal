# P19 S13/S14 bounded evidence acceptance

**ACCEPT — S13 and S14 may be recorded satisfied for these scoped codec criteria, with the explicit S14 fixture-role correction.** Independent Astra review; no builds, reruns, source edits, or fixture changes in this review.

The governing addendum is `S14-CONTRACT-ADDENDUM.md`, SHA-256 `929ce05e100f55b3a1fc6ce5fc6a342216f46ed35c3c3525b2b00f01e9d2ee4b`, independently accepted in `S14-CONTRACT-REVIEW.md`. Original F13 remains rejected under the strict canonical decoder contract.

Evidence is in `p19-codec-bound-rerun/`. `positive-command.json` records the native-authored runner execution on 2026-09-19, 22:30:22–22:32:35 UTC, exit 0: exactly **3 selected controls**, C13-canonical, C13-permuted, and C28-canonical, all matched. The canonical/permuted C13 inputs have equal parsed JSON values; canonical succeeds and original/permuted fails with `noncanonicalWhitespace`. This discharges the bounded S13 pair.

`changed-ir-command.json` records 22:32:35–22:32:50 UTC, exit 1: exactly **1 selected comparator negative**, C13-changedIR. Lean decoding itself exits 0. The comparison fails specifically at `payload.request.parties[0]`: actual `bob`, independently supplied expected `vault`. The input bytes equal C13-canonical. The archived runner compares supplied structural expectations using `deep_compare_subset`; these expectations are not derived from actual output or replaced by its canonicality adjustment. Successful C13 actual IR contains all ten S14 envelope keys; independently checked against `envelope-key-check.json` and the actual result. Thus the source-bound rerun closes the remaining S14 evidence requirement under the accepted addendum.

Verified SHA-256 bindings:

- Archived runner: `d8dd206cda9f36fb425b458c75ef6fbcfffc0c6dd493056b33e590dc79868450`; helper: `58d6012a340960cf554fcadc2f3eda85706ddd7d69c0d783dec8738f2ff9a31b`.
- Archived companion file: `0aac0510c83ecaa686623347b77b52d080bdaf5158a73d3fccaa386a02450986`; all three archives match `source-input-hashes.json` (inventory SHA `0b4e21a7371403fad988afc6f8fab9ea647daeda7c02504ba77b417b0886d825`).
- C13 canonical/changedIR raw bytes: `9b8c2b4206e59de2f35c145024d3f25327c8660e4f43be66a729341ba01b66a9`; original F13/permuted: `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8`.
- `positive/fixture-results.json`: `e2b4995de710733b815a7e704bd43e6f3d9f809940a88bc660b99744a4358f05`; `changed-ir/fixture-results.json`: `1678dae3a028c020f45997d5476b2c1c58af828ebb136185d46d1b3d48bdd576`. Both stdout/stderr hashes match their command receipts.

Recorded codec source identities match integrated main for Decode, Schema, CanonicalJson, Lexical, depth helpers, Correspondence, Roundtrip and RunFixtures. Encode differs only in unrelated report `unsupported` rendering; its decode/encodeModule path is unchanged, as previously reviewed. Original fixture-file SHA remains `ad1857ecf7269920a2169ab7e644d28da3311cad91be60df09a737cf94fe7742`; historical inputs and expectations remain intact.

Limits: this accepts selected codec controls and specified structural subsets, not universal full-IR equality, runtime checker acceptance, host identity, the full 54-fixture campaign, or all P19/P20 gates. The stdout hardcoded `/54` denominator is not the executed denominator. Embedded host/audit success text supplies no additional acceptance. Historical R6 executions remain historical; this decision uses the newly dated, source-bound receipts.
