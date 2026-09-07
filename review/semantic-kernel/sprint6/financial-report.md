# Sprint 6 financial fixtures

`Examples.lean` and `Tests.lean` are new stock GPT-6 implementation sources. The Lean skill was
used. Targeted normal Lake build passed, and the standalone driver ran 59 unique, nonempty
financial comparisons: 59 true, zero failures. Neither imported source contains `#eval`.
No existing source, task checklist, or commit was changed by this subtask.

All fixture IDs have prefix `parallel.fixture.`. The exact inventory and results are in
[the runtime log](financial-evidence/runtime.log). Commands, exits, working directories and
versions are in [runs.json](financial-evidence/runs.json); full captured source hashes are in
[source-inputs.json](financial-evidence/source-inputs.json). The recorded Git head is execution
context, not the identity of these uncommitted source bytes.

`Examples.matchesExpected` compares all 32 domain/party/asset balances, the complete joined
capability store, both branch capability stores, and both exact `BranchObservation` values.
Expected observations include original invocation steps, resolved requests (parties, argument
values, capability IDs and actor), evaluated receipt lists and footprint inventories, ordered
typed snapshots, local next positions, and exact optional refusal indices/steps/reasons.
Expected records are written directly; neither template evaluation nor actual cursor output is
used to generate them. `balanceTable` fixes nonzero untouched vault USD20, pool USD1 and protected
collateral9 in addition to the four principal USD/share cells, with every remaining cell zero.
Actual serial LR and RL results are checked directly against the same independent expected
records for 14 principal scenarios; implementation-to-implementation equality is supplementary.

| Scenario family | Exact check IDs after prefix | Independent expected result |
| --- | --- | --- |
| Funded core and same-asset pairs | `basic.complete`, `same-asset.complete` | USD7/3 and shares16/4; same-asset peer vault USD16/pool USD5; all other cells/store fixed |
| Immediate/middle/dual refusal | `refusal.peer-runs`, `refusal.prefix-kept`, `refusal.dual` | Exact insufficient-funds indices0 or1; peer completes, each successful prefix remains |
| Financial refusal taxonomy | `refusal.guard`, `refusal.input-unit`, `refusal.missing-capability` | Exact guard/inputUnit/unauthorizedInvoke with independent funded right outcome |
| Empty identities | `empty.right`, `empty.left`, `empty.both` | Complete expected nonempty result or original ledger/store with empty observations |
| Qualified and local outputs | `routing.peer-only`, `routing.funded-literal`, `routing.own-history`, `routing.both-own-history` | Peer-only right key holds USD5 but left refuses at1; literal5 succeeds from left balance7; local snapshots3/6 and4/8 remain distinct and immutable |
| Shared qualified key | `routing.shared-qualified-key` | Same component/port/local-step read-only collateral9 appears in both fixed branch slots |
| Boundary principal/time | `boundary.local-identity` | Left principal Alice then Bob at times100/101; right vault at200/201; USD8/2 and shares14/6 |
| Capability store | `capability.revoked`, `capability.actual-revoke`, `capability.reusable-shared-grant` | Real revoke matches explicit right-invoke tombstone; right refuses while left succeeds; same reusable invoke grant authorizes disjoint same-operation branches |
| Supply changes | `supply.complete`, `supply.both-receipts`, `supply.prefix-refusal` | Explicit USD+2/share-3 receipts, joined balances12/17, correct full supply matrix; failed later burn preserves prior supply |
| Stateful prefixes | `stateful.prefix`, `stateful.supply` | USD effects5 then5/2 before guard refusal at2; share mints10 then15 from evolving balances20→30→45 |
| Cancelling undeclared target | `cancelling.admission`, `cancelling.funded` | +1/-1 target conflicts despite net0; independent underlying branch succeeds with original ledger and exact receipt |
| Admission refusal | `refusal.world-preserved`, `refusal.suffix-world-preserved` | Exact initial world and conflict/located unknown-operation reason; refused result has no cursor or execution artifacts |
| Raw context scope | `raw-context-differs` | Canonical agreement with LR while right raw event pre-worlds demonstrably differ |

Actual LR/RL independent comparisons append `.lr.complete` and `.rl.complete` to these prefixes:
`basic`, `prefix`, `routing`, `boundary`, `supply`, `stateful`, `revoked`, `same-asset`, `peer-runs`,
`dual`, `both-own-history`, `stateful-supply`, `shared-qualified-key`, and `supply-prefix`.

Designated mutation oracles coordinated with the mutation agent:

| Planned mutant | Named oracle |
| --- | --- |
| 1 write/write bypass | `parallel.compat.write-write-witness` |
| 2 hidden syntactic reads | `parallel.compat.hidden-inactive-guard` |
| 3 outputs omitted | `parallel.compat.output-dependency` |
| 4 zero delta target omitted | `parallel.compat.zero-target` |
| 5 reverse conflict omitted | `parallel.compat.reverse-read` |
| 6 peer cancellation | `parallel.fixture.refusal.peer-runs` |
| 7 prefix rollback | `parallel.fixture.refusal.prefix-kept` |
| 8 whole-world replacement | `parallel.fixture.basic.complete` |
| 9 doubled initial balances | `parallel.fixture.basic.complete` |
| 10 peer output leakage | `parallel.fixture.routing.peer-only` |
| 11 boundary position/identity | `parallel.fixture.boundary.local-identity` |
| 12 dropped right supply | `parallel.fixture.supply.both-receipts` (actual `Joined.supply`) |
| 13 stale/live capabilities | `parallel.fixture.capability.revoked` (right grant index2) |
| 14 stale intra-branch state | `parallel.fixture.stateful.prefix` |

These are bounded development comparisons, not preserved holdouts or generic proofs. New named
generic proof claims remain in the separate compatibility/dependency/commutation/preservation
modules. The initial ledger's nonnegativity proof is checked as part of its state construction.
Mutation detections, full import/axiom coverage, historical regression and native external review
are separate integration evidence, not implied by this focused test pass. Source is frozen for
mutation replay pending the coordinated integration handoff.

Owned source SHA-256 values:

- `lean/DefiKernel/Parallel/Examples.lean`: `d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd`
- `lean/DefiKernel/Parallel/Tests.lean`: `626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725`
