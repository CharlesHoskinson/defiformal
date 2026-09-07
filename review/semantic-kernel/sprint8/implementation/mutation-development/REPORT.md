# Atomic production mutation preparation

Status: **18 exact source edits prepared; no production mutation compiled or
executed**. Parent owns the final source freeze. This is static applicability and
oracle planning, not accepted production mutation evidence.

`review/semantic-kernel/sprint8/mutation-spec.json` uses runner schema 1 and roots
Policy, Execution, Observation, Examples, Tests and Audit under `DefiKernel.Atomic`.
Each current runtime-prefix needle occurs exactly once and has a distinct
replacement. All designated labels exist in the current financial Tests module.
The runner captures the entire local import closure automatically; no Interleaving
source is mutated or proof-stripped. Settlement's attempt fold is proof context
unless a runtime root imports it; it is not a mutation target.

| Mutation | Actual production site | Designated false comparison |
| --- | --- | --- |
| `retain-prefix-on-abort` | DefiKernel.Atomic.Execution.Result.publicWorld aborted branch | `atomic.fixture.abort.middle.public` |
| `continue-after-first-failure` | DefiKernel.Atomic.Execution.advance abort dispatch | `atomic.fixture.abort.first.stopped` |
| `publish-aborted-outputs` | DefiKernel.Atomic.Execution.committedHistory aborted branch | `atomic.fixture.abort.outputs` |
| `count-aborted-supply` | DefiKernel.Atomic.Execution.committedSupply aborted branch | `atomic.fixture.abort.supply` |
| `stale-entry-world` | DefiKernel.Atomic.Execution.Interleaving.advance world argument | `atomic.fixture.live.complete` |
| `peer-history-leakage` | DefiKernel.Atomic.Execution.Interleaving.advance own-output argument via setLocal | `atomic.fixture.history.peer.only` |
| `global-boundary-index` | DefiKernel.Atomic.Execution.Interleaving.advance boundary argument | `atomic.fixture.boundary.local` |
| `erase-debt-without-receipt` | DefiKernel.Atomic.Policy.updateOutstanding zero-effect branch | `atomic.fixture.settlement.noop` |
| `opposite-vault-effect-sign` | DefiKernel.Atomic.Policy.updateOutstanding effect sign | `atomic.fixture.settlement.under` |
| `global-settlement-sum` | DefiKernel.Atomic.Policy.residuals scalar total acceptance | `atomic.fixture.settlement.cross.principal` |
| `collapse-principal-keys` | DefiKernel.Atomic.Policy.updateOutstanding principal condition | `atomic.fixture.settlement.cross.principal` |
| `collapse-asset-domain-keys` | DefiKernel.Atomic.Policy.updateOutstanding effect summed across lane keys | `atomic.fixture.settlement.cross.asset`, `atomic.fixture.settlement.cross.domain` |
| `omit-final-lane` | DefiKernel.Atomic.Policy.residuals lane enumeration | `atomic.fixture.settlement.last.lane` |
| `omit-final-participant` | DefiKernel.Atomic.Policy.residuals participant enumeration | `atomic.fixture.settlement.last.participant` |
| `accept-lane-supply` | DefiKernel.Atomic.Execution.advance successful-receipt checkSupply dispatch | `atomic.fixture.supply.lane.nonvault` |
| `resurrect-revoked-grants` | DefiKernel.Atomic.Execution.Interleaving.advance capability-store argument | `atomic.fixture.capability.revoked` |
| `omit-abort-reason` | DefiKernel.Atomic.Observation.observationEq kernel reason comparison | `atomic.observe.abort.reason` |
| `omit-residual-amount` | DefiKernel.Atomic.Observation.observationEq residual amount comparison | `atomic.observe.residual.amount` |

The global-sum mutant ignores equal-and-opposite qualified obligations. The
principal-collapse mutant updates every principal; the asset/domain-collapse
mutant sums actual effects over all configured lane cells and applies that amount
to each lane key. Both are real receipt-driven table changes. Last-lane and
last-participant mutants truncate actual enumerations; their fixtures have at
least two entries and their only residual on the later key. The zero-effect
mutant erases existing debt after a successful no-op, rather than fabricating a
repayment receipt. Wrong-sign detection compares the signed under-return residual.

The first-failure mutant permits another actual Interleaving.advance despite the
recorded Atomic abort. Its designated diagnostic checks attempt count and global
position; public rollback alone would not discriminate it. Aborted history and
supply edits change production accessors used by observe. Stale world, peer
history, boundary and grant edits rewrite arguments at the existing Atomic call,
leaving imported Interleaving definitions/proofs unchanged.

The abort omission normalizes only the nested kernel refusal reason to
configuration while retaining branch, local index, global position and invocation.
The residual omission normalizes only amounts to zero, retaining lane, principal
and order. Both modify the actual observationEq comparator; the independent
negative comparison pairs differ only in the omitted field.

Protected positives are `atomic.fixture.empty`, `atomic.fixture.empty.batch`,
`atomic.fixture.catalog`, `atomic.fixture.store`, `atomic.fixture.batch.single`
and `atomic.observe.equal`. The batch.single fixture compares one actual funded
call with a complete independent expected world/store/event. Its policy has no
clearing lanes, so it is a financial execution sibling, not transient-debt evidence.
It was selected to remain meaningful across the stale-world and settlement
mutants. Per-mutant richer funded siblings can be reported supplementally after
actual results; do not claim their survival before execution.

No measured overlap claim is available yet. Global-sum/principal-collapse and
asset/domain-collapse are expected to share some settlement oracles; observation
omissions can weaken other comparisons. The frozen run must record the full
false-label matrix and distinguish overlapping detections from independent
oracles, while requiring every designated false and all six protected positives.

Next: parent freezes actual runtime, Tests/Audit, spec and drivers; recheck exact
Git/SHA bindings and compile/run the unchanged control plus all 18 mutants in a
fresh external directory. Compilation/setup failure is blocked, never detection.
All counts remain source-bound and complete. The 63 CLI controls are separate
synthetic runner evidence copied under implementation/runner-controls.
