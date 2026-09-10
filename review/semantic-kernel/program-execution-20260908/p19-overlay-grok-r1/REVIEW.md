# P19 R5 overlay and source_map report-policy review

**OVERLAY_AND_POLICY_REVIEW_ONLY_FULL_P19_OPEN**

Requested model: `grok-4.6` high. Independent auditor. Frozen R5 overlay only. Full P19 acceptance stays pending. Universal IR roundtrip and trusted host compiler boundary stay open with their original identities.

Frozen sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-overlay-grok-r1-sandbox`  
Claimed archive: `9aa8294dfa6765e8a70a08f9546f36e454fa3d7fd6bab41c4e4fd5af2476c2f0` (3406 files)  
Lean pin used: `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`  
Overlay: `review/semantic-kernel/certificates/p19/implementation/agy-r5/fixture-canonical-order-overlay.json` sha256 `c9bdc4abf5599901ee05706e51ae523229d8ad1e3c7e920634f4bc987c9990ca`  
Planning fixtures: `openspec/changes/serialized-kernel-certificates/fixtures.json` sha256 `ad1857ecf7269920a2169ab7e644d28da3311cad91be60df09a737cf94fe7742`

Private rebuild was offline under this review directory. Frozen sandbox bytes were not written. Start hashes still match at close.

## Verdict

R5's 36-entry overlay is **not** a blanket normative amendment.

**PARTIAL_CHANGES_REQUIRED.** Accept the F13/F28 canonical raw-byte reorder, the two original-byte refusal regressions, the Check.lean nonempty-`source_map` informational outstanding derivation, and the 33 outstanding-only expected patches plus the F43 identity copy. Do **not** accept F13 `expected.result.ir: null`. That entry deletes the required decoded-IR equality assertion. Root already forbade replacing the F13 alias with null or `decoded=true`.

This diagnostic does not accept R5 production implementation and does not prove a universal encode/decode theorem.

## What the 36 entries actually change

Field-level map: `overlay-delta-map.json`. Classes:

| Class | Count | Fixtures |
|---|---|---|
| Canonical serialization only (raw `source_map` key order) | 2 | F13, F28 |
| IR-equality expectation weakening | 1 | F13 (in addition to its canonical reorder) |
| Informational `source_map` outstanding only | 33 | F08–F10, F15–F27, F29–F30, F32–F33, F36–F42, F47–F51, F54 |
| Byte-identical copy | 1 | F43 |

No overlay entry adds or removes envelope/default fields beyond sorting. No overlay entry changes status, failure constructors, world, receipt, or unreached stages. F33/F38/F42 keep their original library/invariant outstanding names and append `sourceRefinement`.

18 planning fixtures are not overlaid (codec refusals, audit, observation-pair). Planning `fixtures.json` is unchanged. Counts remain 54/99/38/16.

## Finding P19-OV-01 — F13 `ir: null` removes required IR equality (high)

Planning F13 expected `result.ir` is the literal `"DecodedIR of F25 payload"`. That is an alias for whole-IR equality with F25's execution envelope, not a filename decoration. Root P19-EB-03: replace the alias with actual independently checked decoded-IR evidence; omitting the field or printing `decoded=true` does not meet it.

R5 overlay F13 rationale says `ir is null on decode ok`. `RunFixtures.lean:22-25` prints `ir: null` on every successful decode. Overlay expected matches that driver. Independent compare:

- overlay actual vs overlay expected: match (both null)
- overlay actual vs original ir label: fail
- original noncanonical bytes vs original `status=ok`: fail (`malformed` vs `ok`)

A private `ProbeIREq` on the same canonical bytes (after a preserved first compile failure) measured:

```
left=ok right=ok irEq=true enc1eq=true enc2eq=true
```

for F13 overlay vs F25 canonical compact. Original F13 raw and unsorted F25 compact both decode-error. The equality evidence exists; the overlay and fixture campaign do not require it. Author 54/54 therefore does not prove decoded-IR equality.

**Correction shape (no new claim):**

1. Keep overlay F13 `inputs.raw_utf8` and `expected.raw_utf8` as the canonical store-before-transfer bytes (`9b8c2b4206e59de2f35c145024d3f25327c8660e4f43be66a729341ba01b66a9`).
2. Keep `F13-raw-regression` on original bytes `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8`.
3. Change decode-ok output so `ir` is the actual decoded IR (encoded object), **or** add a sibling check whose independent expected is `irEq=true` between `decodeBytes(F13_canonical)` and `decodeBytes` of F25's canonical envelope. Both are the existing F13/F25 alias plus S14 envelope-ok.
4. Store that expected as an independent literal. `ir: null` and `decoded=true` remain insufficient.

F28 is different: planning F28 already had `ir: null`. Overlay F28 only reorders `source_map` and echoes those bytes. Do not invent an F28 IR claim in this overlay review.

## Finding P19-OV-02 — overlay apply does not bind original identity (medium)

`scripts/run_certificate_fixtures.py:251-263` overwrites `inputs`/`expected` when `fid in overlays`. It does not:

- check overlay original bytes against frozen `fixtures.json` hashes
- reject unknown overlay ids
- reject unapplied overlay ids
- pin regression raw to a recorded original hash (bytes do match; the harness does not check)
- enforce overlay schema keys

`make_altered_control` flips `status` only. It still "discriminates" when both actual and expected have `ir: null`.

This review's independent comparator **does** fail a wrong important value: refused vs accepted; empty outstanding vs `["sourceRefinement"]`; alice usd 8 vs 7; restored F13 ir label vs null. Enforce that contract in the overlay schema (`original_id` + `original_input_sha256` on each entry and regression). Do not add unrelated gates.

## Accepted with limitations

### Canonical F13/F28 raw positives and regressions

Original hashes match root inspection. Overlay bytes differ only by `"source_map":{"transfer":...,"store":...}` → `{"store":...,"transfer":...}` (length 9699, single-blob replace recovers). Values of those keys are unchanged. Grammar requires lexicographic UTF-8 order of dynamic `source_map` keys. Decode of original bytes is `malformed` / `noncanonicalWhitespace`. That constructor is the closed Schema admission refusal for both extra whitespace and noncanonical key order; there is no separate key-order ctor. Classification is correct for the closed set.

Object-valued F25/F27 still present `transfer` then `store`. They are not raw-byte specimens. Harness `canonicalize_json` sorts before Lean for all 34 unchanged object inputs. Unsorted compact F25 bytes equal original F13 raw and refuse. Sorted compact F25 bytes equal overlay F13 raw.

### source_map informational outstanding (PB04)

`Check.lean` checkTyped/checkStep/checkRun:

```
outstanding := ... ++ (if !cert.source_map.isEmpty then ["sourceRefinement"] else [])
```

`sourceRefinement` judgment stays `notApplicable`. Targeted execution:

| Case | status | failure | outstanding | alice usd |
|---|---|---|---|---|
| F25 / F43 / neutral / prefixF43 / F430 / f43_lower | accepted | null | `[sourceRefinement]` | 7 |
| F25 empty `source_map` | accepted | null | `[]` | 7 |
| F17 | refused | kernel.stateReadFootprint | `[sourceRefinement]` | — |
| F29 | refused | kernel.actorMismatch | `[sourceRefinement]` | — |
| F30 | refused | kernel.unknownOperation | `[sourceRefinement]` | — |
| F36 | refused | observationMismatch.claimedNextState | `[sourceRefinement]` | — |
| F41 | incomplete | incompleteObligation.environment-authenticity | `[sourceRefinement]` | — |
| F08 | refused | configuration | `[sourceRefinement]` | — |
| F49 | refused | kernel.insufficientFunds | `[sourceRefinement]` | — |
| F27 | accepted | null | `[sourceRefinement]` | — |
| F33 | accepted | null | `[libraryTheoremsInstantiated, sourceRefinement]` | — |

Identical F25/F43 bytes under seven filenames share stdout sha256 `d59d1c137956c9793477cac5c6c76066d7f87fa577c2792f07a302aa729c4111`. `RunFixtures.lean` has no `path.contains`. Filename oracle is gone. Informational outstanding does not flip accepted execution to incomplete.

Decode overlay named `F13_overlay.dat`, `neutral_overlay.dat`, and `xxF13yy.dat` is identical.

## Harness / overlay schema

Permitted top-level keys observed: `schema`, `rationale`, `overlays`, `regressions`. Each overlay entry: `inputs`, `expected`, `rationale`. Regressions: `id`, `name`, `kind`, `scenarios`, `inputs`, `expected`. No `original_sha256`. Provenance is reviewable by comparing overlay bytes to frozen fixtures, which this review did; the production harness does not.

Wrong expected values fail `deep_compare` against actual kernel output. Stale/unapplied/unknown overlay ids are not detected.

## Evidence classes

- **Static comparison:** overlay vs `fixtures.json` / grammar / judgment-contract / PB04 / result-algebra / scenario S13–S14 / root inspections.
- **Bounded execution:** private lake rebuild; decode/check/ProbeIREq on named files; independent expected literals; wrong-value negatives.
- **Kernel proofs in this review:** none. `irEq=true` is `DecidableEq` on two decoded values, not `EncodeDecodeRoundtripStatement`.
- **Open, not waived:** universal IR roundtrip; F13 IR equality until repaired; trusted host compiler boundary; stale top-level manifests and empty M02 mutation rerun.

First `ProbeIREq` nested-match compile failed (`unexpected identifier; expected '_'`). Preserved under `probes/failed/`.

## Proposal for root

Accept as normative overlay amendments: F28; F13 canonical input and raw echo only; both raw regressions; F43 identity; 33 outstanding-only expected lists; Check.lean source_map outstanding derivation; removal of filename oracles.

Require repair before treating the overlay as complete: F13 IR expected and decode driver (P19-OV-01); overlay original-identity binding (P19-OV-02).

Do not accept all 36 while F13 `ir: null` remains. Do not merge to main. Do not treat author 54/54 as full P19 acceptance.
