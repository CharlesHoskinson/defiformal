All18 production mutants compiled and were discriminated on `a52fb748272fdc08f07d4ad8d2e2a06805b92dd6`. Unchanged control135/135 true. Every mutant emitted the same135 unique names, made all designated comparisons false and preserved all six protected positives. Runner exit0.

Exact command, source closure, Git/blob and byte hashes, complete projections, logs, results and per-variant matrices are retained. Artifact crosscheck verifies whole-projection equality to exactly one specified replacement,19 complete inventories, all log hashes and frozen source/spec/driver/harness bytes. Imported Interleaving proofs remain in the projection; only Atomic proof suffixes are removed.

The prior88aa first production attempt is preserved under ../mutation-attempts/r1-audit-protocol and has zero accepted detections. Its Audit protocol mismatch was fixed before this fresh run. The separate65/65 actual CLI controls (52 retained+11 proof-tail+2 production#eval) are under ../implementation/runner-controls-r3 and are synthetic runner evidence.

| Mutation | Designated false | False count |
| --- | --- | --- |
| retain-prefix-on-abort | atomic.fixture.abort.middle.public | 19 |
| continue-after-first-failure | atomic.fixture.abort.first.stopped | 5 |
| publish-aborted-outputs | atomic.fixture.abort.outputs | 23 |
| count-aborted-supply | atomic.fixture.abort.supply | 7 |
| stale-entry-world | atomic.fixture.live.complete | 29 |
| peer-history-leakage | atomic.fixture.history.peer.only | 2 |
| global-boundary-index | atomic.fixture.boundary.local | 1 |
| erase-debt-without-receipt | atomic.fixture.settlement.noop | 11 |
| opposite-vault-effect-sign | atomic.fixture.settlement.under | 23 |
| global-settlement-sum | atomic.fixture.settlement.cross.principal | 3 |
| collapse-principal-keys | atomic.fixture.settlement.cross.principal | 17 |
| collapse-asset-domain-keys | atomic.fixture.settlement.cross.asset, atomic.fixture.settlement.cross.domain | 8 |
| omit-final-lane | atomic.fixture.settlement.last.lane | 8 |
| omit-final-participant | atomic.fixture.settlement.last.participant | 8 |
| accept-lane-supply | atomic.fixture.supply.lane.nonvault | 7 |
| resurrect-revoked-grants | atomic.fixture.capability.revoked | 1 |
| omit-abort-reason | atomic.observe.abort.reason | 1 |
| omit-residual-amount | atomic.observe.residual.amount | 1 |

Protected positives: atomic.fixture.empty, atomic.fixture.empty.batch, atomic.fixture.catalog, atomic.fixture.store, atomic.fixture.batch.single, atomic.observe.equal.

All pairwise false-oracle overlaps are recorded in summary.json, including any identical inventories. Multiple mutants can fail the same complete financial comparison; overlap is not independent semantic coverage. Exact mutated definitions and distinct replacement bytes remain the intervention evidence. Per-mutant successful settlement/batch siblings are supplemental measured values, with no new runner schema feature claimed. The globally protected batch.single executes a funded one-call success in empty-lane mode; it is not evidence of transient settlement.

Finite mutation execution is neither a generic Lean theorem nor deployed-protocol fidelity. The bounded lexical projection guard does not analyze arbitrary command macros defined before the proof boundary. Generic proof/axiom audit and native review remain separate artifacts; no final acceptance is inferred here.

Identical observed false inventories:
- `omit-final-lane` and `omit-final-participant`: 8 shared false comparisons. These checks detect both interventions but do not identify which fault occurred.
