# Sprint 6 dependency proof report

Implemented by the GPT-6 stock-harness dependency agent. Starting HEAD:
`2267e005d988f0e32d014f2d76d98a9410360187`. These checks ran with new,
uncommitted Sprint 6 sources and concurrent work in other new modules. They are
not evidence for a clean committed candidate or the complete Sprint 6 gate.
No historical source was edited by this agent. No commit or task checkbox was made.

## Verified scope

The three modules contain 38 named theorems: 20 generic core/adapter declarations,
17 concrete dependency fixtures, and one refusal-detector helper over the fixture
types. The named inventory includes exact theorem source statements and hashes:
`dependency-proof-inventory.json`.

| API | Quantification and premises | Verified conclusion |
| --- | --- | --- |
| `expression_congr_of_region` | Arbitrary closed typed expression; fixed environment, caller, parties, typed arguments and time; input states agree on a region containing every successfully resolved syntactic read | Entire `Except EvalFailure Value` equal, including errors and inactive-arm read dependencies |
| `evaluate_congr` | Arbitrary template; fixed non-ledger inputs; agreement at every resolved `requiredStateReads` reference | Entire actual `Template.evaluate` result equal, including complete evaluated effects, supplies, declared footprints and errors |
| `evaluated_targets`, `evaluated_effect_zero_outside` | Actual evaluation equals `ok e`; a region contains all successfully resolved delta targets | Every evaluated delta comes from a syntactic target; aggregate effect vanishes outside the region. No declared-write membership or `writesOK` premise |
| `funds_iff` | Two proof-carrying nonnegative input states; equal balances on a region; effect zero outside it | Global sufficient-funds propositions equivalent, including nonzero foreign balances |
| `execute_congr`, `execute_refusal_iff` | Arbitrary finite identity types; fixed registry, store, context, environment, time and request; agreement on a region; all selected-template reads agree and targets lie in it | Full executor results have the same exact refusal, or successful balances agree on the region and capability stores agree |
| `execute_success_congr` | Same premises and one actual successful execution | Matching successful execution on the other state, region agreement and both capability stores equal the fixed input store |
| `execute_target_frame` | Actual successful execution; selected-template targets contained in a chosen region | Every cell outside that region equals its own input balance |
| `analyzed_dependencies`, `analyzed_outputs` | Actual `analyzeInvocation = ok fp`, registry or selected interface lookup | Required reads and selected snapshot cells lie in analyzed reads; potential targets lie in analyzed writes; writes are also balance dependencies |
| `extractReceipt_congr` | Fixed configuration, boundary, request; selected-template resolved-read agreement | Entire receipt extraction result equal using each execution's own prestate |
| `executeStep_congr`, `executeStep_refusal_iff` | Actual admitted invocation footprint; fixed local index/history/boundary; arbitrary region containing analyzed reads; states agree there and input stores equal | Exact composition failure equal, or region balances, capability store, whole receipt and every selected output equal |
| `executeStep_target_frame` | Analyzed footprint and actual successful adapted invocation | Ledger frames its own input outside analyzed writes; capabilities unchanged |

`ExecutionAgrees` and `StepAgrees` are conclusions proved from the actual executors,
not caller-supplied outcome assumptions. Their success case deliberately does not
equate complete worlds when foreign input balances differ. Adapter snapshot
equality uses membership of each output cell from the selected catalog interface.

## Concrete proof fixtures

`Dependency/Fixtures.lean` reuses the existing eight-cell Boolean transition
reference fixture without editing it. Initial balances are 10 at every cell;
the foreign sibling changes only `(true,true,true)` to 99. A transfer moves 3
between the two `(false,_,false)` cells. The poor sibling has only 1 at its debit
target. Actual authority provisioning uses the existing trusted issuance fixture.

- `malformed_evaluates`, `malformed_targets`, `malformed_effect_outside` and
  `malformed_writes_fail`: the transfer has empty declared writes, actual effects
  of -3/+3 and no effects outside its syntactic targets.
- `funded_malformed_refusal`, `foreign_malformed_refusal`,
  `poor_malformed_refusal`: funded states reach exact `writeFootprint`; the poor
  target refuses earlier with exact `insufficientFunds`. The foreign refusal is
  derived by the generic exact-refusal theorem.
- `foreign_agrees`, `foreign_differs`, `foreign_funds_iff`,
  `target_balance_is_needed`, `foreign_success`: establish real foreign-state
  differences, funding equivalence, the necessary target balance dependency,
  and a valid transfer sibling.
- `accounting_refusal`: explicit mismatched supply reaches exact `accounting`.
- `division_evaluation`, `division_execution`: actual balance-based division by
  zero gives exact evaluation and registered-execution errors.
- `observation_error`: missing environmental observation gives its exact error.
- `inactive_evaluation_congr`: both syntactic conditional arms read state and
  their membership premises discharge the general evaluation theorem.

Closed decision fixtures use `decide +kernel` where needed for kernel reduction,
not `native_decide` or an external computation axiom.

## Check evidence and limits

Fresh targeted build: from `lean/`,
`lake build DefiKernel.Parallel.Dependency.Fixtures`, exit 0, 929 jobs.
Full output: `dependency-build.log`. Lean version:
`4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.
Targeted LSP diagnostics also reported zero errors during development.
Existing and new linter warnings remain advisory.

Fresh named axiom disclosure: from `lean/`,
`lake env lean ../review/semantic-kernel/sprint6/dependency-axioms.lean`, exit 0.
All 38 expected names matched the 38 actual disclosures exactly; their transitive
axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`.
Output: `dependency-axioms.log`; structured check record:
`dependency-verification.json`. This focused named audit does not replace the
planned automatic imported theorem and supplemental declaration audit.

The proofs establish dependency/locality and exact refusal preservation for
existing closed syntax and executors. They do not establish serial branch
correspondence, whole-sprint mutation sensitivity, protocol fidelity, environmental
truth, or initialized financial invariants. Those remain separate integration work.
The fixture module must be included in the final verification import closure.
Native Grok/Fable implementation reviews are owned by the parent acceptance task.

## Exact owned source hashes

| Source | SHA-256 |
| --- | --- |
| `lean/DefiKernel/Parallel/Dependency.lean` | `72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245` |
| `lean/DefiKernel/Parallel/Dependency/Adapter.lean` | `10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c` |
| `lean/DefiKernel/Parallel/Dependency/Fixtures.lean` | `14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45` |
