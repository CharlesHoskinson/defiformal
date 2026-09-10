# P19 R4 checker/evidence-boundary diagnostic

**EVIDENCE_BOUNDARY_DIAGNOSTIC_ONLY_NO_ACCEPTANCE**

Requested model: `grok-4.6` high. Independent auditor. Frozen R4 only. Full candidate acceptance stays pending. Canonical codec and universal-proof defects are out of scope because root already sealed them for R5.

Frozen sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-evidence-boundary-grok-r1-sandbox`  
Claimed archive: `327dfcfb1440dbf9471a58d6be040e6800f5f0a328f601ce789d46ed30c4982e` (2669 files)  
Lean pin used: `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`  
Mathlib: `51e6992efd06126df61a496bebf8f49482a4e129`

This run rebuilt `Check` / `Verify` / codec dependencies offline in a private tree under this review directory. Frozen sandbox sources were not written. Start hashes still match at close.

## Verdict

R4’s 54/54 fixture campaign is not valid checker evidence for S57, S13 IR equality, or S58 per-certificate axiom audit.

The shared payload `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8` is F13 raw, F25 compact, and F43 compact. `checkBytes` / `rawExecute` treat those bytes as one transfer-three success. `RunFixtures.lean` then changes the printed report when the path contains `F13` or `F43`. Python has no semantic filename branch. It only names temp files `{id}_in.json`, which is enough.

`checkAudit` grants `passed` from the decoded envelope. F44 never compiles a candidate. The global `Verify.lean` scan is a real campaign control and is not coupled to those envelopes.

## Finding P19-EB-01 — filename oracle on outstanding (high)

`RunFixtures.lean` 38–41 overwrites `outstanding` with `["sourceRefinement"]` when `path.contains "F43"`.

Identical bytes, `lake env lean --run ... check <file>`, exit 0:

| filename | outstanding | stdout sha256 |
|---|---|---|
| `neutral_in.json` | `[]` | `6400cc8ac12f1bf255c2084a949be55d8431b032ee70b16f8907c751621c34db` |
| `F25_in.json` | `[]` | `6400cc8a...` same |
| `F43_in.json` | `["sourceRefinement"]` | `d59d1c137956c9793477cac5c6c76066d7f87fa577c2792f07a302aa729c4111` |
| `prefixF43suffix.json` | `["sourceRefinement"]` | `d59d1c13...` same |
| `F430.json` | `["sourceRefinement"]` | `d59d1c13...` same |
| `f43_lower.json` | `[]` | case-sensitive |
| `not_the_fixture.json` | `[]` | |

`raw` mode on `F43_in.json` matches raw on the neutral name. `Check.lean` never writes `sourceRefinement` into outstanding. `source_map` is unread. The `sourceRefinement` judgment is tautologically `notApplicable`.

**Repair:** delete lines 38–41. Print `checkBytes` unchanged. Do not restore S57 by path substring.

## Finding P19-EB-02 — identical F25/F43 inputs, conflicting expected reports (high)

This is a planning/input-context defect plus the checker bug above.

F25 expected outstanding is `[]`. F43 expected outstanding is `["sourceRefinement"]`. Objects and compact bytes are identical. Both already carry `source_map.transfer = lean/DefiKernel/Typed/Examples.lean:transfer`.

`deep_compare` matches each actual to its own expected and rejects the cross. Neutral filename matches F25 expected, not F43 expected. The 14-field comparator is therefore confirming the oracle, not an independent observation.

Do not keep the oracle. Do not delete S57. Do not silently rewrite frozen original bytes.

**Recommended overlay:** derive outstanding `sourceRefinement` from nonempty `source_map` in `checkIR`. Identical bytes then yield identical reports. Overlay F25 expected outstanding to `["sourceRefinement"]`. Keep F43 expected. F25 still witnesses transfer-three success (accepted, alice 7, bob 3). S57 remains, because PB04 is about that pin.

**Alternative overlay:** add an explicit reviewed envelope flag on new F43 bytes only. Keep original identical bytes as historical duplicates. New F43 must differ by that field, not by filename.

The recommended option is the one that matches PB04. F25 already has the pin. Treating the pin as not-outstanding on F25 and outstanding on F43 is the contradiction the oracle hid.

## Finding P19-EB-03 — F13 IR label is not whole-IR equality (medium)

`RunFixtures.lean` 22–26 discards the decoded IR on success. It prints the literal `"DecodedIR of F25 payload"` iff the path contains `F13`, else JSON `null`.

Same bytes:

- `F13_in.dat` / `prefixF13suffix.dat` / `xxF13yy.dat` → `status=ok`, `ir="DecodedIR of F25 payload"`
- `neutral_in.dat` / `F25_in.dat` / `F43_in.dat` → `status=ok`, `ir=null` (stdout sha `919624459a6a43709feb04b499689d4ee32a6226c58562075593bb1f031ac270`)

`encodeCodecResult` would emit `ir: {}` on ok. It never emits that label.

Decode success and the raw_utf8 echo can still support S14 envelope-keys-present. They do not support whole-IR equality. Root’s canonical-order conflict on these bytes (`transfer` before `store`) remains the sealed R4 codec item. This run does not rediscover it.

**Repair:** delete the `F13` branch. Omit `ir`, emit `decoded=true`, or encode the actual IR.

## Finding P19-EB-04 — F44 passed without compiler evidence (high)

Accepted planning interpretation 1: recorded compiler-discharge needs matching candidate/compiler/audit records, path/hash identity, successful compile, and nonempty inventory. Caller metadata does not discharge.

`checkAudit` (`Check.lean` 745–760) does none of that:

1. `imported_theorems == 0` → `blocked emptyScope`
2. nonempty `forbidden_claimed_roots` → `passed` with `claimed_covered=false`
3. else extract prefix strings from `commands` / `auditPrefix` / default `"DefiKernel"` and return `passed`

`imported_theorems_min` is decoded and unused. `checkCertificateBytes` is `checkBytes`. No IO.

Measured F44 envelope (`commands` plus `imported_theorems_min: 1`): `status=passed`, prefixes Certificates/Typed/Composition, `compiler_invoked=false`. Rename does not change it. A forged envelope with `#audit_axioms DefiKernel.Nary` etc. also passes and reports those prefixes. `imported_theorems: 999` and `imported_theorems: 1` both pass. Feeding F44 checker stdout to the Python axiom-log parser fails: `found 0` theorem matches.

`lake env lean DefiKernel/Certificates/Verify.lean` on this pin exited 0. The Python parser accepted three nonempty scopes (996 / 420 / 287 theorems). That is a real **campaign** control. It is not an argument to `checkAudit`. R4 still marks F44 passed from the JSON match.

Do not demand that pure Lean open the filesystem. Demand that the **driver** bind external facts before `passed`.

**Repair:** keep `checkAudit` as an untrusted summary. For S58, bind exact-candidate compile + three `#audit_axioms` + compiler identity + nonempty actual scopes to that certificate. Do not grant `passed` from supplied counts, command strings, or `compiler_record` objects.

## Finding P19-EB-05 — F45/F46 evidence class (medium)

S59 is list inspection of this increment’s audit-root list. F45’s input is only `forbidden_claimed_roots`. `checkAudit` then attests `claimed_covered=false`. That is not a compiler observation that Nary was unimported. It can remain if the host also checks the candidate’s actual claimed roots against that list.

S60 requires an audit command that would observe zero imported theorems. F46 blocks because the document says `imported_theorems: 0`. A document that says `1` or `999` passes without compile. The Python empty-scope control rejects `0/0` in `Verify.lean` logs. That is the global scan, not F46.

## Finding P19-EB-06 — comparator, parser controls, theorem map (medium)

These artifacts do not prove the reported 99-verified scope.

- Status counts are 87 `verified_by_fixture`, 11 `verified_by_fixture_and_theorem`, 1 `bounded_fixture_verified`. The headline 99 counts any status containing `verified`, so the open P20 row is included.
- S03 (`F05` zero denominator) is credited `reportEq_refl`. S04 (`F04` float) is credited `worldEq_refl`. Both theorems are reflexivity. Unrelated.
- S82 (“kernel success is not Report.accepted”) is credited `checkTyped_execute_ok`, which concludes `status=accepted`.
- S57 is credited F43, which is P19-EB-01.
- S58–S60 are credited F44–F46, which are P19-EB-04/05.
- `deep_compare` walks expected keys only. Extra actual keys still match. Altered-value controls prove the comparator is not always-true. They do not prove the actual came from `checkBytes`.
- Five audit-parser controls are synthetic strings. They discriminate the log parser. They do not authenticate F44–F46.

Supporting theorems that can remain supporting, if stated honestly: S40 `decode_error_no_kernel`, S41 accepted-path correspondence, S48 stale git.

## What is still real

`rawExecute` on the shared payload is a filename-independent kernel observation: invoked receipt, alice −3 USD, bob +3 USD. That is production checker output for the execution payload. It does not discharge S57.

The private rebuild of `Verify.lean` produced the three-scope axiom audit and exit 0 on the pinned compiler. Treat it as global host evidence, not per-envelope evidence.

Python has no F13/F43 semantic branches besides the temp filenames.

## Failed probe preserved

`observation-pair` on the F25 vs F43 reports returned `decodeReport failed`. Outstanding-field comparison and stdout hashes still discriminate those reports. This run does not promote that parse failure to a separate defect.

## Out of scope

Entire 54-fixture campaign, 65 mutation controls, Encode/Decode canonical counterexamples, `EncodeDecodeRoundtripStatement`, and domain strengthening. Root already rejected completeness on those items.

## Smallest R5 repair order

1. Delete both `path.contains` branches in `RunFixtures.lean`.
2. Apply the reviewed F25/F43 outstanding overlay (recommended: nonempty `source_map` → outstanding `sourceRefinement`, plus F25 expected overlay).
3. Stop treating F13 `ir` as IR equality.
4. Bind host compiler evidence before any audit `passed` used for S58. Reclassify F45/F46.
5. Fix scenario counts and S03/S04/S82 mapping.

Root adjudicates. Fixes belong at the next AGY preserved boundary.
