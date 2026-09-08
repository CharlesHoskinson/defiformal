# Fixtures-r5 report (runtime label grammar)

Worker requested `grok-4.6`. Worker reported `grok-4.6`. Independent GPT-6 was not run by this worker. No Foreman, commit, plan edit, production mutation run, or self-acceptance. r1–r4 evidence, Examples, runner, harness, and all 16 SPECs were not edited.

HEAD at start: `bc002dd49fd531ab0aac757613c3051cd94a9bb6`. Only `lean/DefiKernel/Nary/Tests.lean` is modified and uncommitted. Audit and Examples bytes equal the r4 freeze.

This is a label-transport repair. The M01 control compiled and printed 310 true rows, then the frozen runner closed with `malformed observation` because 180 labels violate `CHECK_NAME = [a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*`. Control stdout SHA-256 `fdce80c3e766046a0ab1f6a54dd43ffec8ca28028b77e625c5fe824e27591201` equals accepted fixtures-r4 eval. No runtime property was false.

## Change

Emitted observation labels only. Check bodies, mutant arguments, order, and fixture scope are unchanged. `schedTag` still produces the numeric schedule identity used as data; `emitSchedTag` prefixes `s` only in the printed name. F09 `synth` still binds the same mutant values; only the concatenated field tag is snake_case.

| File | SHA256 |
|---|---|
| Examples.lean | `1f844aad7c8912148d3a0660a76c670f91b0c262dc1e847c558e3ea964b2b8a4` (unchanged) |
| Tests.lean before (r4 / bc002dd) | `d029f586694a96ed3cdc8accd4bddd90162e36ca6e028dd0ad628da851666512` |
| Tests.lean after | `b63713488d3997a0ce4c68198a2792caf389a6265c040e3072e72f219bd1d8ca` |
| Audit.lean | `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` (unchanged) |

Transform:

- camelCase segment → snake_case (`nextIndex` → `next_index`)
- digit-initial segment → prefix `s` (`0012` → `s0012`, `012` → `s012`)
- 130 already-valid IDs unchanged, including every SPEC required-false and protected name

Reversing only those emission edits restores Tests.lean byte-for-byte to the r4 source. Exact diff: `Tests.lean.diff`. Full 310-row old/new map: `label-bijection.json`.

## Runtime (fixture cache only)

```
cd /home/charl/.cache/defiformal-sprint11-builds/fixture
lake build DefiKernel.Nary.Tests
lake build DefiKernel.Nary.Audit
lake env lean DefiKernel/Nary/Audit.lean
```

All three exit 0. Proof and causal caches were not used. Repository `lean/.lake` was not built. `#eval main`: **310 true, 0 false, 310 unique**, all 310 match the frozen runner grammar. Simulated runner parse: 310 observations = 310 `^[A-Za-z0-9_.-]+:` candidates (the previous malformed-observation condition is gone). All 16 SPEC required-false and positive names remain present and exact. No `sorry` / custom `axiom` / `native_decide`.

New eval SHA-256: `4bf0c4ca9a8d15a421bfea40e1520e93ce037e271faba937188e33b39658f8f4`.

## Limitations

These 310 results are executable comparisons, not kernel proofs. Production M01–M16 were not re-run; the parent will rerun gates after a new candidate commit. This worker does not accept the implementation.
