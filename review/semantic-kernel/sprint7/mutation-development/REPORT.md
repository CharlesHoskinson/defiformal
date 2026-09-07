# Sprint 7 production mutation specification development

All fourteen specified production edits compiled and were discriminated in a
private committed snapshot of the actual runtime source. The unchanged control
ran 116/116 true comparisons. Every mutant ran the same 116 comparisons, caused
its designated false comparison, and retained all nine protected positives.
This is **development evidence, not the final accepted frozen-candidate run**.

The [production specification](../mutation-spec.json) has SHA-256
`c3ad55915dc34be2bf7ad62d8ed34dde2862de4b7b29505cb761623960ec549b`. [Actual invocation](r1-invocation.json), [console](r1-cli.log),
[results](r1-results.json), [source manifest](r1-source-manifest.json), and
[per-mutation analysis](r1-analysis.json) preserve exact inputs and outcomes.
The [compressed evidence](r1-source-and-projection-evidence.tar.gz) contains every
captured input, projected Lean source, per-command log and original manifest.
No root Lean source or runner script was changed. No mutation needed a correction
after the initial specification was prepared.

The private snapshot commit is `ea925c8308a77619ebbe24cacfcedb1cc714d929`. It contains copied
production sources, not substitute computations. The actual audit combines the
24 schedule and 92 financial/observation checks. Its source closure contains
22 Lean modules plus three project configuration inputs; all 25 are bound to the
snapshot's Git objects. This snapshot precedes the root's final whitespace edits.
The parent must freeze and rerun the final root candidate before acceptance.

## Observed mutations

| Design number | Actual production mutation | Designated false comparison | Total false |
| --- | --- | --- | --- |
| 1 | `schedule-count-bypass` | `interleaving.schedule.missing-right` | 9 |
| 2 | `reintroduce-overlap-rejection` | `interleaving.schedule.overlap-admitted` | 13 |
| 3 | `stale-initial-world` | `interleaving.fixture.live.complete` | 42 |
| 4 | `isolated-branch-world` | `interleaving.fixture.replenish.funded` | 40 |
| 5 | `global-cancellation` | `interleaving.fixture.refusal.immediate` | 15 |
| 6 | `prefix-world-rollback` | `interleaving.fixture.refusal.middle` | 20 |
| 7 | `retry-halted-suffix` | `interleaving.fixture.replenish.halted` | 8 |
| 8 | `peer-history-leakage` | `interleaving.fixture.history.peer.only` | 1 |
| 9 | `snapshot-recomputation` | `interleaving.fixture.snapshot.own` | 2 |
| 10 | `global-boundary-position` | `interleaving.fixture.boundary.local` | 1 |
| 11 | `global-invocation-position` | `interleaving.fixture.disjoint.lrlr.complete` | 49 |
| 12 | `drop-peer-supply` | `interleaving.fixture.supply.aggregate` | 1 |
| 13 | `resurrect-revoked-capabilities` | `interleaving.fixture.capability.revoked` | 1 |
| 14 | `omit-canonical-failure` | `interleaving.observe.failure.reason` | 28 |

All mutation-site edits target `Interleaving.Schedule` or
`Interleaving.Execution`; no expected fixture is edited. An artifact cross-check
confirmed that each whole mutant projection equals its unchanged projection with
exactly its one prescribed replacement, and verified the source SHA-256/Git blob
bindings and all raw-log observation inventories.

The initial world is recovered from the first actual attempt's pre-world, with
the current world only before an attempt exists. The isolated-world variant
replays the own consumed prefix through actual `Parallel.runBranch`, then executes
against that isolated world and replaces the shared world through `Machine.accept`.
Snapshot recomputation resolves the stored qualified component/port in the trusted
catalog and reads its current shared ledger cell before actual input resolution.
Global-position mutants use the sum of both consumed counters, avoiding the
provably equal own consumed/next-index substitution. The failure omission edits
`LocalState.observe`, which is used by the real public comparisons.

The rollback mutant resets the complete global world on refusal while retaining
recorded events and failure; it does not claim to test a separately implemented
branch-only rollback. The halted-suffix mutant disables the actual own failure
guard, allowing the real later static slot after replenishment to execute.
The supply mutant drops actual right-branch attempts, including the independently
expected nonzero share-supply receipt. Refused attempts already contribute zero.

## Protected siblings and oracle dependence

The shared specification protects nine labels for every variant: a balanced
schedule; admitted disjoint branches; independently funded left/right invocations;
empty execution; one successful branch in either position; equal observations;
and equal located failures. The one-branch financial controls pass through the
mutated Interleaving execution code.

Per-mutation supplementary successful siblings are recorded and asserted in
[r1-analysis.json](r1-analysis.json). These include full disjoint successful
execution beside overlap rejection, funded replenishment beside halted-suffix
retry, literal/own history beside history bugs, complete supply receipts beside
wrong aggregation, live authority beside revoked authority, and an equal failure
pair beside failure omission. They supplement the nine globally enforced labels;
the v1 runner schema has no per-mutation positive list.

The stale-initial-world mutant has 42 false labels; isolated-branch-world has 40.
All 40 isolated-world false labels are also false for stale initial execution.
Only `interleaving.fixture.refusal.immediate` and
`interleaving.fixture.refusal.skips` distinguish them in this inventory. Their
separate designated labels both fail under both variants, so those labels are
not independent oracles for separating the two bugs. The exact overlap sets are
saved in the analysis. Conversely, peer-history leakage, global-boundary position,
dropped peer supply and capability resurrection each fail just their designated
single comparison in this development measurement; snapshot recomputation fails
the two own-snapshot comparisons.

## Tool and acceptance boundaries

The runner exited `0` between `2026-09-07T06:59:43.443731+00:00` and
`2026-09-07T07:03:58.125176+00:00`. The longest complete Lean projection took
18.100038 seconds, below its recorded 600-second command bound.
Lean identity: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`. Runner SHA-256:
`73033e6ee85a7d31255568489076c9ce044967022e40ce07cf8ecae7aa983c14`. Exact source/spec/driver bytes and input drift checks passed.

The root production source/spec/driver freeze, final fourteen-mutation replay,
full regressions, and native Grok/Fable acceptance reviews remain parent work.
This report closes specification development only; it does not mark task 7.5 or
any final implementation gate complete. All financial cases remain development
fixtures, not untouched holdouts or deployed-contract correspondence evidence.
