# Independent GPT-6 review: fixtures r3 + r4

Verdict: **ACCEPT WITH LIMITATIONS**, for the frozen runtime fixture changes only. No blocking finding remains in this scope. This closes the runtime F03 limitation of the accepted r2 review and the missing concrete three-nonempty-chunk witness identified in scenario reconciliation. It does not accept Sprint11 as a whole.

Native Grok authored the changes. The checker only read feature sources and evidence, wrote review artifacts, and ran a read-only Lean stdin audit using the released private proof cache. No feature source, author evidence, or planning package was changed.

## Frozen source and baseline

| File | SHA-256 |
|---|---|
| Examples.lean | `1f844aad7c8912148d3a0660a76c670f91b0c262dc1e847c558e3ea964b2b8a4` |
| Tests.lean | `d029f586694a96ed3cdc8accd4bddd90162e36ca6e028dd0ad628da851666512` |
| Audit.lean | `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` |
| Shared Observation.lean | `154ac0b69fa1a45197a7e9f435ce3ea472280101dcc1d1880df20f266c7316f0` |

Examples and Audit remain byte-identical to accepted r2. The full Tests diff from r2 adds F03 definitions/checks and F07 chunk definitions/checks, plus their inventory insertion. Existing check bodies and identifiers are retained. The intermediate r3 Tests snapshot is `f4f2dcaba62b1048d79b71d9ccc21104eece5ae212588b9504bc3bb3541bfc08`.

## Semantic findings

**F03, Tests lines 136–166 and 323–345:** the new checks call the accepted `Interleaving.admit`, `runPrefix`, and `runInterleaving` through the shared executable Observation conversions. They do not import BinaryCorrespondence. Full comparison retains worlds including capability stores, both local states, all attempts, receipt/output payloads, raw event and attempt worlds, refusal reasons, and schedules. These helpers and their equality characterizations were independently accepted in binary-r1.

The independent existing LR/RL expectations remain. Two additional literal expected machines describe failed-participant and exhausted-participant suffix tokens: consumed advances while history, next index, world, and attempts stay fixed. Those machines are constructed from literal records, not either candidate runner. Separate direct binary comparisons supplement these expectations. Both-count projection checks all four independently expected values `(1,0,1,0)`. The malformed left suffix contains operation 999 at local index 1 and an empty schedule; the expected result is structural unknown-operation refusal before the count mismatch, followed by direct binary admission agreement. Ten new F03 identifiers preserve all seven earlier F03 rows.

**F07, Tests lines 182–222 and 402–438:** chunks `[0]`, `[0]`, and `[0,1,2]` are all nonempty. The first succeeds from vault 10 to 9. The middle contains an actual invocation-13 guard refusal, with failure index 1, two consumed slots, one successful event, next index 1, retained capability store, and two global attempts. The last includes the failed participant's skipped token and then both peers' successful deposits, ending at vault 12 with four attempts. Explicit first and middle expected machines complement the unchanged independent final F07 expected machine.

The concatenated, nested, suffix-grouped, and prefix-grouped executions each compare against that full final machine; cross-comparisons also check their agreement. `cmpMachine` combines the candidate comparator and independently implemented full-field comparator. Monitored middle count is 2; concatenated and nested final counts are 4. Full-machine erasure of the concatenated monitored result is checked against both unmonitored execution and the independent final literal. The nested monitor row checks its count; generic monitor erasure/chunk theorems remain the separate proof evidence for arbitrary chunking. Twelve new rows witness the concrete three-chunk case without replacing the accepted arbitrary-entry F09 checks.

**Preserved scope:** Examples is unchanged, so the accepted F05 parameterized producer and own-history literals, all 48 F10 independent rows, and F18/F19 accepted-M2 source bindings remain. The source-derived final inventory contains 124 literal identifiers, 84 independently separated synthetic comparator rows, 96 generated F10 rows, and six generated F18 rows: exactly 310 unique rows. All 288 r2 rows, including F09 arbitrary-entry/history and every-field negatives, are present and true. All 16 prescribed mutation required-false labels and their protected positives are present and true in the unmutated audit. All 16 literal source needles occur exactly once. This last check is not mutation execution.

## Evidence and independent execution

The r4 `final-artifacts.json` has exactly 39 distinct entries. They match the complete on-disk file set excluding the manifest itself, with every byte count and SHA-256 checked. Empty stderr files are correctly represented as zero bytes; source snapshots and runtime output are nonempty. All r3/r4 saved build and evaluation status files report exit 0. The r4 first-pass output equals the final replay output. Historical r2 evidence still records its three initial F07 failures and its corrected 288-true result; none was relabeled as fresh success.

The three final sources match live worktree, frozen snapshots, saved source manifests, and actual private-cache sources. Recursively resolved local runtime imports comprise 25 modules. Every local source matches the private cache; core Schedule/Execution/CausalRuntime match accepted core-r3 snapshots, and Observation matches accepted binary-r1. No Nary proof-only module enters the runtime closure. Inherited M2 dependencies are included in the manifest, not silently omitted.

The compressed r3/r4 native streams and decompressed raw bytes match their recorded hashes and lengths. Their direct terminal records identify session `01a07ed5-e45f-70e2-85f6-c621d2aef4f9`, normal end-turn completion, and actual modelUsage key `grok-4.6-build`. Parent transport identities record exit 0. The worker's in-process model claim alone is not used as model evidence.

Independent command, from `/home/charl/.cache/defiformal-sprint11-builds/proof`:

```text
lake env lean --stdin
```

Input imports Audit and evaluates `DefiKernel.Nary.Audit.main`. Exit 0, empty stderr, exactly **310 true / 0 false / 310 unique**. The complete output equals saved r4 output byte for byte, SHA-256 `fdce80c3e766046a0ab1f6a54dd43ffec8ca28028b77e625c5fe824e27591201`. Before/after checking found unchanged bytes and modification times for 253 inputs, including 125 local compiled artifacts. Three supplementary normative/prior-review inputs were also read and hashed without changes. Exact input hashes, inventory, commands, native terminal records, and probe corrections are in `fixtures-r4-inputs.json`; executable check and raw replay files accompany it.

## Limits

This replay uses the supplied compiled dependency artifacts; it does not independently rebuild them. Author compile logs and source bindings are supporting evidence, with final clean integrated compilation still required. These bounded comparisons do not establish generic semantic or financial theorems. Concrete Funded proofs, production mutation runs, full declaration/axiom and scenario inventory closure, final integration, and delivery remain separate open gates. Existing accepted planning identities and historical review verdicts remain unchanged.
