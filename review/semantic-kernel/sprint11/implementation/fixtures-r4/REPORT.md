# Fixtures-r4 report (three-chunk middle refusal)

Worker requested `grok-4.6`. Worker reported `grok-4.6`. Independent GPT-6 was not run by this worker. No Foreman, commit, mutation runner, or self-acceptance. r1–r3 evidence were not overwritten.

Private compile cwd: `/home/charl/.cache/defiformal-sprint11-builds/proof`. Repository, fixture, and causal caches were not built. Owned worktree and private hashes matched. Private `.lake` was not copied back.

## Change

Only `lean/DefiKernel/Nary/Tests.lean` changed. Examples and Audit still equal the r2/r3 freeze.

| File | SHA256 |
|---|---|
| Examples.lean | `1f844aad7c8912148d3a0660a76c670f91b0c262dc1e847c558e3ea964b2b8a4` (unchanged) |
| Tests.lean before (r3) | `f4f2dcaba62b1048d79b71d9ccc21104eece5ae212588b9504bc3bb3541bfc08` |
| Tests.lean after | `d029f586694a96ed3cdc8accd4bddd90162e36ca6e028dd0ad628da851666512` |
| Audit.lean | `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` (unchanged) |

The accepted scenario **Three chunks with refusal** now has an explicit bounded witness on funded F07 literals. Chunks are all nonempty:

| Chunk | Tokens | Meaning |
|---|---|---|
| first | `[0]` | p0 withdraw1 success, vault 10→9 |
| middle | `[0]` | p0 transfer20 selected refusal, `kernel.guard`, world unchanged |
| last | `[0,1,2]` | failed skip (no attempt) then p1 deposit1 and p2 deposit2 |

Concatenated schedule is `[0,0,0,1,2]`, the funded F07 schedule. Independent expected machines (`f07FirstExpected`, `f07MiddleExpected`, Examples `f07Expected`) are assembled from existing F07 literals, not from `continueRun`/`runNary`. Actual runs compare full stored fields (`machineEq` and `fullMachineEq`) of:

- single concatenated continuation `start ▹ (c1 ++ c2 ++ c3)`
- left grouping `((start ▹ c1) ▹ c2) ▹ c3`
- right grouping `(start ▹ c1) ▹ (c2 ++ c3)`
- assoc grouping `(start ▹ (c1 ++ c2)) ▹ c3`

against `f07Expected`, and the four actual machines against each other.

Middle boundary inspects failure index 1, `inv13`/`kernel.guard` attempt on `f07After0`, vault 9, peers unconsumed, two attempts. Last-chunk peer progress: vault 12, p1/p2 consumed/nextIndex 1, four attempts. `countUpdate` monitor: 2 after middle, 4 after concat; skip does not increment; erasure equals the financial machine. Monitor state does not control finance.

All 298 prior IDs remain, including 17 F03 rows and 16 mutation labels. Twelve new `nary.f07.three-chunk.*` IDs were added. Tests does not import `BinaryCorrespondence`. No `sorry`, custom `axiom`, or `native_decide` in Examples/Tests/Audit.

## Runtime (bounded checks, not proofs)

```
cd /home/charl/.cache/defiformal-sprint11-builds/proof
lake build DefiKernel.Nary.Examples
lake build DefiKernel.Nary.Tests
lake build DefiKernel.Nary.Audit
lake env lean DefiKernel/Nary/Audit.lean
```

All four commands exit 0. `#eval main`: **310 true, 0 false**, 310 unique IDs (298 r3 + 12). First-pass `eval-Audit.stdout` is byte-identical to the post-resync eval. No compile or runtime failure in this pass. First-pass logs are kept under `logs/first-pass/`.

Worktree Lean source was rsynced into the exclusive proof cache excluding `.lake`. Owned Examples/Tests/Audit bytes did not change. Concurrent other-lane `FundedCausal.lean` / `InterfaceInstances.lean` worktree bytes were copied into that cache by the sync instruction; they are not in the Tests/Audit import chain and were not edited by this worker.

## Limitations

These 310 results are executable comparisons. They do not replace the generic `continueRun_three_chunk` / `continueRun_chunk_assoc` theorems. Mutation SPECs were not run. Root integrated `lake build` was not run. This worker does not accept the implementation.
