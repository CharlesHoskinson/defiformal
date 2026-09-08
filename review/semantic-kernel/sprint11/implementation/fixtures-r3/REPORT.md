# Fixtures-r3 report (F03 binary integration)

Worker requested `grok-4.6`. Worker reported `grok-4.6`. Independent GPT-6 check was not run by this worker. No Foreman, commit, mutation runner, or self-acceptance. r1 and r2 evidence were not overwritten.

Private compile cwd: `/home/charl/.cache/defiformal-sprint11-builds/proof`. Repository, fixture, and causal caches were not built. Worktree and private hashes matched.

## Change

Only `lean/DefiKernel/Nary/Tests.lean` changed. Examples and Audit bytes equal the r2 freeze:

| File | SHA256 |
|---|---|
| Examples.lean | `1f844aad7c8912148d3a0660a76c670f91b0c262dc1e847c558e3ea964b2b8a4` (unchanged) |
| Tests.lean before | `27576cb692b8befe6451910b076f8f06f870d76594d28681f15e44d5fbd0a05d` |
| Tests.lean after | `f4f2dcaba62b1048d79b71d9ccc21104eece5ae212588b9504bc3bb3541bfc08` |
| Audit.lean | `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` (unchanged) |

F03 now uses Observation conversions (`projectScheduleMismatch`, `binaryAdmitAgrees`, `binaryPrefixAgrees`, `binaryRunAgrees`). Tests does not import `BinaryCorrespondence`. Independent LR/RL/count literals remain. Extra prefix expected machines are assembled from those literals, not from `runNary` or `runInterleaving`.

Ten added rows, all true:

| ID | Role |
|---|---|
| `nary.f03.both-count-projection` | independent both-count payload 1,0,1,0 |
| `nary.f03.both-count-direct` | supplementary admit agreement |
| `nary.f03.malformed-suffix` | independent structural unknownOperation before counts |
| `nary.f03.malformed-suffix-direct` | supplementary admit agreement |
| `nary.f03.failed-prefix` | independent skip-after-refusal machine |
| `nary.f03.failed-prefix-direct` | supplementary prefix agreement |
| `nary.f03.exhausted-prefix` | independent skip-after-success machine |
| `nary.f03.exhausted-prefix-direct` | supplementary prefix agreement |
| `nary.f03.lr-direct` | supplementary `runNary`/`runInterleaving` agreement |
| `nary.f03.rl-direct` | supplementary `runNary`/`runInterleaving` agreement |

Existing seven F03 rows remain true. All 16 mutation labels and protected positives remain true.

## Runtime (bounded checks, not proofs)

```
cd /home/charl/.cache/defiformal-sprint11-builds/proof
lake build DefiKernel.Nary.Examples   # exit 0
lake build DefiKernel.Nary.Tests      # exit 0
lake build DefiKernel.Nary.Audit      # exit 0
lake env lean DefiKernel/Nary/Audit.lean  # exit 0
```

`#eval main`: **298 true, 0 false**, 298 unique IDs (288 r2 + 10 F03). No compile or runtime failure occurred in this pass after the insertion. Prior r2 F07 failure logs remain under `fixtures-r2/`.

## Limitations

These 298 results are executable comparisons. They are not kernel proofs of binary simulation (those live in BinaryCorrespondence). Mutation SPECs were not run. Root integrated `lake build` was not run. This worker does not accept the implementation.
