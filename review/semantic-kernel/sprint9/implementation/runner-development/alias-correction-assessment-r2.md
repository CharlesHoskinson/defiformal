# Independent source assessment of the alias correction

The four designated routing observations now execute different programs against
separately constructed full expected cursors. The previously duplicated receipt
observation also now has a distinct supplemental companion. This is a bounded
read-only source assessment by `/root/sprint7_runner`, who did not author these
fixture changes. It excludes review of this agent's runner/spec implementation,
does not execute Lean, and grants no native or final evidence acceptance.

Exact before/after expressions, source hashes, review hashes and preserved
predecessor evidence bindings are in `alias-correction-assessment-r2.json`.
The current fixture hashes are Examples
`9474fefb56e4120ae8537d137a94a1bd6518612e654874794b27c1a8c770a8a9`
and Tests `60b1890c1858ca68e4da3c74f6261facee639ca5c230b522dbd0a6f241f1b730`.

| Designated observation | Actual program/input | Independent expected result |
|---|---|---|
| world-chain | Transfer 7 to Bob, then literal transfer 1 to Carol, starting at position 0 | Alice 2/Bob 7/Carol 1; events 0/1, snapshots 3/2, next index 2 |
| history-chain | Transfer 0 to Bob publishes Alice's snapshot 10; the next action consumes that qualified snapshot | Alice 0/Bob 0/Carol 10; events 0/1, snapshots 10/0, next index 2 |
| index-chain | Literal timed transfers 2 to Bob and 1 to Carol, starting at position 9 with trusted times 209/210 | Alice 7/Bob 2/Carol 1; events 9/10, snapshots 8/7, next index 11 |
| child-executed | Empty first child, then a funded transfer 2 to Bob | Alice 8/Bob 2/Carol 0; event 0, snapshot 8, next index 1 |

The expected data uses the existing independent `world`, `cursor`, `rawTransfer`
and `timedRaw` constructors. No new expected cursor is computed by `runGroup` or
the comparator under test. Existing full comparison retains raw before/result
worlds, current world/store, events, outputs, index and failure. The zero producer
is permitted by the existing transfer's nonnegative guard and preserves the
initial world while adding a snapshot. The timed case changes the index without
depending on a prior-output input. The empty-first case tests whether the second
child executes while giving the other propagation fields no changed intermediate
value to carry. These are differences in computations and data, beyond renaming
the old Boolean expressions.

`metatheory.observe.receipt-diff` still changes the evaluated transfer amount from
7 to 6 while preserving the invoked request. The supplemental
`metatheory.observe.event.evaluated` changes only `declaredStateReads` from `[]` to
`[collateralCell]`. Both are explicitly synthetic cursor pairs. The earlier proposal
to use a revoked receipt constructor for the designated check was not adopted;
the accepted evaluated-receipt requirement remains directly exercised.

Detection and fault identification remain different claims. A compiling exact
source intervention that produces its required false result and preserves the
positive controls is a detected mutation. Distinct fixture programs improve
oracle diversity, but they do not guarantee disjoint or reciprocal failure
patterns. In particular, the literal world-chain continuation can succeed after
history reset while its **complete cursor** still differs because the first
snapshot was lost. That explanation follows from source fields; it is not a
separately executed narrower oracle. The successor report must show the measured
world/history response matrix without weakening `fullCursorEq` to obtain a
diagonal matrix.

At predecessor `c880acf6`, all 14 interventions were detected, but world reset and
index reset produced identical 27-name false inventories. Those executed bytes,
reports and all 91 pairwise overlaps remain intact. The successor execution must
measure its own complete false inventories and overlaps rather than infer
isolation from textual diversity. Six observer mutations remain sensitivity tests
on synthetic, generally unreachable cursor pairs; they do not add six financial
execution detections to the eight routing interventions.

The static successor preflight passed 26 runtime modules, 148 unique comparison
IDs, two global positives, and exactly one occurrence of each of the 14 mutation
needles across the full projected source. Successor execution qualification is
recorded separately after the frozen runs finish.
