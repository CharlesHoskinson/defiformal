# Frozen Interleaving production mutation evidence

**All fourteen production mutants compiled and were discriminated** on
`6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`. The unchanged control ran 116/116 true comparisons.
Each mutant ran the same 116-name inventory, made its designated comparison false,
and preserved all nine protected positives. The runner exited zero. No compile-only
failure, empty check, missing comparison, no-op edit or survivor was counted.

The separate [frozen CLI control suite](../runner-controls/REPORT.md) passed 52/52
actual controls. These production mutations and those synthetic runner controls
remain distinct evidence types.

## Exact source and tool binding

[Final manifest](final-manifest.json), [raw runner source manifest](source-manifest.json),
[driver/spec Git bindings](driver-spec-git-bindings.json), [invocation](invocation.json),
[console](cli.log), [results](results.json), [runtime inventory](runtime-inventory.json),
and [per-variant summary](summary.json), and [artifact cross-check](artifact-crosscheck.json)
retain the exact evidence. Every captured
input and complete projected source is also saved in this directory.

The 22-module local source closure and three project configuration files equal
25 objects at the frozen Git revision. The production specification, runner and
control harness separately equal their frozen Git objects. Source/specification/
driver bytes and HEAD were unchanged after every variant and at completion;
post-run artifact checks reconfirmed those bindings. The source manifest's scoped
input status was clean. No nested Git directory is included.

Runner SHA-256: `73033e6ee85a7d31255568489076c9ce044967022e40ce07cf8ecae7aa983c14`.
Specification SHA-256: `c3ad55915dc34be2bf7ad62d8ed34dde2862de4b7b29505cb761623960ec549b`.
Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`; executable SHA-256
`e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. The actual invocation ran from
`2026-09-07T07:08:09.840144+00:00` to `2026-09-07T07:16:07.801460+00:00`.
The longest projection took 47.111190 seconds under concurrent
build/regression load, within the recorded 600-second per-command timeout.

## Actual mutation outcomes

The disjoint column counts schedules for which both the independent complete
financial expectation and comparison with existing Parallel execution stayed true.
It is supplementary measured coverage, not the globally protected control list.

| Design | Production edit | Designated false comparison | All false | Disjoint successful siblings |
| --- | --- | --- | --- | --- |
| 1 | `schedule-count-bypass` | `interleaving.schedule.missing-right` | 9 | 6/6 |
| 2 | `reintroduce-overlap-rejection` | `interleaving.schedule.overlap-admitted` | 13 | 6/6 |
| 3 | `stale-initial-world` | `interleaving.fixture.live.complete` | 42 | 0/6 |
| 4 | `isolated-branch-world` | `interleaving.fixture.replenish.funded` | 40 | 0/6 |
| 5 | `global-cancellation` | `interleaving.fixture.refusal.immediate` | 15 | 6/6 |
| 6 | `prefix-world-rollback` | `interleaving.fixture.refusal.middle` | 20 | 6/6 |
| 7 | `retry-halted-suffix` | `interleaving.fixture.replenish.halted` | 8 | 6/6 |
| 8 | `peer-history-leakage` | `interleaving.fixture.history.peer.only` | 1 | 6/6 |
| 9 | `snapshot-recomputation` | `interleaving.fixture.snapshot.own` | 2 | 6/6 |
| 10 | `global-boundary-position` | `interleaving.fixture.boundary.local` | 1 | 6/6 |
| 11 | `global-invocation-position` | `interleaving.fixture.disjoint.lrlr.complete` | 49 | 0/6 |
| 12 | `drop-peer-supply` | `interleaving.fixture.supply.aggregate` | 1 | 6/6 |
| 13 | `resurrect-revoked-capabilities` | `interleaving.fixture.capability.revoked` | 1 | 6/6 |
| 14 | `omit-canonical-failure` | `interleaving.observe.failure.reason` | 28 | 6/6 |

An artifact cross-check verified each entire mutant projection equals the unchanged
projection with exactly its prescribed one replacement. Every raw mutant Lean log has the
same 116 unique labels as the control and exactly the expected runtime-comparison
error; recorded compiler exits are one. It also checked source/Git blob identities,
all fixture and log hashes, every designated false and all protected true values.

## Protected positives and oracle overlap

Every mutant preserves nine globally enforced labels: balanced schedule, admitted
disjoint branches, independently funded left/right invocations, empty execution,
a successful one-branch execution in either position, equal observations, and equal
located failures. The one-branch financial siblings execute the mutated production
Interleaving code. The summary names all nine explicitly for every variant.

The full six-schedule disjoint successes survive eleven mutants, including overlap
rejection. They fail under stale initial worlds, isolated branch world replacement
and global invocation selection; the table preserves those zeroes. Per-mutant
supplementary successful siblings are also asserted in the summary, including funded
replenishment, literal/own history, complete supply receipts, live capabilities and
an equal failure pair as appropriate. No per-mutant positive-list feature is
claimed for the runner's v1 specification.

Stale initial execution has 42 false comparisons; isolated branch execution has 40.
All 40 isolated-world failures overlap the stale-world failures. Only
`interleaving.fixture.refusal.immediate` and
`interleaving.fixture.refusal.skips` are stale-only failures. Their distinct
chosen designated labels both fail under both mutants and are not independent
oracles separating those two faults. Exact overlap sets are saved in the summary.

Peer-history leakage fails only its peer-only history check. Snapshot recomputation
fails the two own-snapshot checks. Global boundary position, dropped peer supply
and revoked-capability resurrection each fail only their designated comparison.
The failure-omission mutation changes actual `LocalState.observe`, reaching both
public comparison and production financial expectations; its equal-failure
positive remains true.

## Scope

These are actual semantic source edits to Schedule/Execution, not changes to test
expectations or unused helpers. The initial world comes from the first actual
attempt's pre-world; the isolated mutant replays the own consumed prefix through
real `Parallel.runBranch`. Snapshot mutation resolves the qualified component/port
cell in the catalog before rereading the current shared ledger. Position mutants
use the global consumed count rather than exchanging equal own counters.
Rollback restores the global world on refusal while retaining recorded prefix
and failure. The halted-suffix mutation reaches a real later slot after replenishment.

New Interleaving theorem tails are excluded from temporary execution copies only;
all runtime definitions and local dependency proofs remain. This is finite runtime
sensitivity evidence with a bounded source-format projection, not mathematical
proof of mutant correctness or general mutation completeness. External tool/package
trust, development-fixture status and lack of deployed-contract correspondence
remain unchanged. Native Grok/Fable reviews and the wider proof/integration gates
are managed separately by the parent.
