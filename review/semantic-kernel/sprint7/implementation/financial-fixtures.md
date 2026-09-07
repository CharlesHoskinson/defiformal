# Financial fixture implementation handoff

Implemented by the stock GPT-6 harness agent `/root/sprint7_financial` in
`lean/DefiKernel/Interleaving/Examples.lean` and `Tests.lean`.
No Foreman or independent reviewer was invoked by this worker. Parent integration
owns native Grok/Fable review and the full build/audit gates.

The focused runtime executes 92 unique named comparisons, all true, with Lean
4.33.0-rc2. `financial-verification.json` records exact commands, UTC times, source
hashes, Lean identity and labels. `financial-runtime.log` is the complete output;
`financial-runtime-driver.lean` preserves the exact temporary driver bytes.
Both new modules compiled independently against the built Schedule/Execution
imports. No full build ran in this worker. Initial missing-import, path and Lean
elaboration errors were development failures; none is semantic negative evidence.

The seven fixture families cover:

1. Shared vault USD10, left7 to Alice and right6 to Bob, LR/RL exact results and
   unequal observations. The LR attempt oracle independently specifies full
   pre/post ledgers, store, receipts, output values and exact refusal.
2. Deposit7 before withdrawals6 and1 succeeds. Reversal refuses the first
   withdrawal, then deposits7, then skips a later static withdrawal slot. The
   exact two-attempt oracle detects a retry or extra failed attempt.
3. A live balance read sees peer replenishment: Alice10 becomes5, then9, then9/2;
   Bob becomes5 then19/2. Direct evaluated receipts specify the read lists.
4. Real identical qualified keys carry distinct branch snapshots. The bilateral
   case consumes2 and3 from own histories after intervening peer changes. A
   peer-only USD producer refuses beside funded USD literal and own-history
   controls. Unit mismatch is checked with an actual adapter refusal.
5. Immediate/middle/dual refusal, successful peer continuation, retained prefix,
   exact skipped-attempt counts, all empty cases, malformed schedule and malformed
   unreachable suffix.
6. Both branches have nonzero supply, with a refused/skipped suffix. The production
   `Machine.supply` result is checked for every domain/asset. Protected collateral,
   local principal/time binding, unauthorized invoke/debit, revoked and live grants
   have complete financial oracles.
7. All six disjoint 2+2 schedules have independent complete expectations and
   comparisons to actual `runParallel`; the same six include a refused prefix.

The expected comparator checks every finite ledger cell, the complete capability
store, both complete canonical branch observations and both static consumed
counts. Expected ledger/receipt constructors are reused from Parallel.Examples,
where they are direct data definitions. No expected value is extracted from an
interleaving result. Public `observationsEqual` is separately exercised against
changed final ledger/store, exact failure fields, local next index, history,
events, event index/step, every output field, every receipt/evaluation field and
all request fields. Equal controls include retained failures. A positive control
checks deliberately omitted raw foreign worlds, schedule and consumed count.

All results are finite developer-fixture execution evidence, not generic proofs,
protocol fidelity or untouched holdouts. No new named financial theorem is claimed
by these two files. The proof-carrying initial states use ordinary Lean proofs.
No `sorry`, custom axiom or `native_decide` is introduced.

Suggested designated mutation oracles (prefix `interleaving.`):

- stale/isolated world or overlap rejection: `fixture.shared.lr`;
- global cancellation: `fixture.refusal.immediate`;
- prefix rollback: `fixture.refusal.middle`;
- halted retry: `fixture.replenish.halted` and `fixture.replenish.attempts`;
- peer-history leakage: `fixture.history.peer.only`;
- snapshot recomputation: `fixture.snapshot.own` / `fixture.snapshot.both.own`;
- global boundary index: `fixture.boundary.local`;
- wrong invocation index: `fixture.disjoint.lrlr.complete`;
- dropped peer supply: `fixture.supply.aggregate`;
- revoked grant resurrection: `fixture.capability.revoked`;
- omitted failure observation: `observe.failure` beside `observe.failure.equal`.

The stale-world and isolated-world oracles overlap. These are proposed mutation
bindings; this worker does not claim source-mutant execution results.
