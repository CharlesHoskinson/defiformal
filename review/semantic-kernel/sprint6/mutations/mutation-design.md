This document records the intended mechanism and oracle for each actual source edit in
[the canonical manifest](../mutation-spec.json). It is a mutation design record, not
an execution verdict. Accepted production results require the complete runner artifacts.

| Plan class | Mutation | Source module | Required false comparisons |
| --- | --- | --- | --- |
| 1 | `bypass-write-write-composite` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.write-write-witness` |
| 2 | `omit-expression-reads-composite` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-supply` |
| 3 | `omit-output-dependency` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.output-dependency` |
| 4 | `omit-zero-delta-target` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.zero-target`, `parallel.compat.zero-target-exact` |
| 5 | `omit-reverse-conflict` | `DefiKernel.Parallel.Compatibility` | `parallel.compat.reverse-read` |
| 6 | `cancel-peer-after-refusal` | `DefiKernel.Parallel.Execution` | `parallel.fixture.refusal.peer-runs` |
| 7 | `rollback-refused-prefix-at-join` | `DefiKernel.Parallel.Execution` | `parallel.fixture.refusal.prefix-kept` |
| 8 | `replace-merge-with-left-world` | `DefiKernel.Parallel.Execution` | `parallel.fixture.basic.complete` |
| 9 | `double-initial-balances` | `DefiKernel.Parallel.Execution` | `parallel.fixture.basic.complete` |
| 10 | `leak-peer-output-history` | `DefiKernel.Parallel.Execution` | `parallel.fixture.routing.peer-only` |
| 11 | `reuse-left-trusted-boundary` | `DefiKernel.Parallel.Execution` | `parallel.fixture.boundary.local-identity` |
| 12 | `drop-peer-supply-receipts` | `DefiKernel.Parallel.Preservation` | `parallel.fixture.supply.both-receipts` |
| 13 | `reuse-live-capability-store` | `DefiKernel.Parallel.Execution` | `parallel.fixture.capability.revoked` |
| 14 | `stale-intra-branch-evaluation` | `DefiKernel.Parallel.Execution` | `parallel.fixture.stateful.prefix` |

All variants protect the following actual underlying-executor or catalog checks:

- `parallel.compat.catalog-positive`
- `parallel.compat.funded-left-complete`
- `parallel.compat.funded-right-complete`
- `parallel.compat.zero-target-funded`
- `parallel.compat.hidden-inactive-guard-funded`

1. Composite admission weakening: replace all three ordered conflict guards with acceptance. Writes are also reads, so deleting only the write/write guard would leave both cross-read guards. The oracle still names the required write/write witness; unrelated funded execution controls remain protected.

2. Composite read-collector omission: replace requiredStateReads plus declared stateReads with an empty resolved read list. The registered template retains valid declared reads and the old kernel still checks them; only new admission loses both redundant sources. Three independent negatives cover hidden guard, delta, and supply reads, with successful underlying-kernel siblings.

3. Remove selected output cells from admission reads. The output snapshot is an implicit dependency even when the financial expression does not read that cell. The underlying output-producing operation remains funded and authorized.

4. Remove delta targets from prospective writes, which also removes their contribution to target-balance reads through the shared writes list. The designated fixture has a literal zero delta at Alice USD and no declared writes or reads. Its underlying kernel execution succeeds; no malformed-footprint refusal is counted as the oracle.

5. Remove only the reverse-direction overlap test. The fixture has a left reader and right writer with disjoint writes, so neither prior ordered guard masks this error.

6. After a left branch refusal, replace the right invocation list with the empty branch. The independent oracle requires the peer to run and preserve its real outcome.

7. At join only, replace a refused left branch world with the initial world. The independent oracle requires a successful prefix to remain committed even when its following invocation refuses.

8. Replace the region-based merged world with the entire left world. The full finite-world oracle includes independent nonzero right-side effects.

9. Add the two entire nonnegative branch ledgers, retaining the initial store. Both ledgers include the common base, so the complete-world oracle detects doubled initial balances. The replacement includes an ordinary sum-nonnegativity proof and must compile before counting.

10. Execute the right branch first and seed the left branch cursor with right outputs while retaining left local positions and boundaries. The left consumer can now use the peer-only qualified key and complete a funded transfer instead of its required unavailable-output refusal. The peer-only-history fixture needs an absent own-history key; equal-valued shared keys alone cannot justify detection.

11. Execute the right branch with the left trusted boundary function. Admission remains unchanged; the independent fixture must distinguish branch principals/time at local positions.

12. Drop the right traceSupply term from the actual Joined.supply runtime aggregate. The designated oracle compares both asset-indexed supplies with independent expected amounts.

13. Run the right branch with the same capability entries and IDs but revive every live flag. This represents a stale live store before revocation; the designated right-revoked oracle must observe refusal using the actual initial store.

14. Change runBranch to advance each invocation against the original branch world, while retaining its accumulated cursor metadata. A second state-dependent step therefore evaluates stale balances rather than its successful prefix. The designated oracle is the independently expected intra-branch stateful result, not equality of cached serial executions.

The threat model is implementation mistakes in the new Parallel computation. Mutation
edits are applied only to captured scratch source; historical implementation and accepted
proof files remain unchanged. Proof suffixes are omitted from these executable probes,
so a detected mutant is bounded sensitivity evidence, not a proof of the mutated program
or the full serial correspondence law. Compile-only failures, missing edits, survivors,
incomplete inventories and failed protected positives cannot be counted as detections.
