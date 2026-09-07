# Sprint 6 preservation proof report

GPT-6 stock-harness implementation. Observed HEAD at final evidence recording:
`2267e005d988f0e32d014f2d76d98a9410360187`, with new uncommitted Sprint 6 source.
The exact source bytes, rather than a clean-commit claim, bind this evidence.
No historical files, commits, or task checkboxes were changed by this agent.

## Verified APIs

`Preservation.lean` contains 25 named generic theorems. `PreservationFixtures.lean`
contains 20 concrete reference theorems. Exact statements and file hashes are in
`preservation-proof-inventory.json`.

- `Joined.supply` is executable before the proof marker. It sums
  `traceSupply joined.left.events` and `traceSupply joined.right.events`.
  `runParallel_executed_accounting` proves, for every domain/asset, that the actual
  public executed result's total is its initial total plus this supply. The proof
  uses actual branch receipt accounting, admitted write disjointness, and proved
  branch locality to justify the region merge. It does not assume final totals.
- `runBranch_events_invoke` derives invocation-only event membership from the
  existing runner's ordered-prefix theorem. `trace_invoke_stores` proves every
  event's pre/post capability store equals the initial store. Consequently
  `runParallel_executed_authority` establishes invocation, debit and supply rights
  from that fixed initial store at each successful event's own local boundary.
  Failed suffixes do not discard earlier point-of-use authority evidence.
- `runBranch_prefix_nonnegative` and `runParallel_executed_nonnegative` expose
  the nonnegativity witnesses already carried by each state. They are not claims
  of automatic invariant discovery; the executed-result premise in the latter
  serves API scope and is not needed to recover a state's existing witness.
- `runParallel_executed_frame` proves all cells outside both analyzed write lists
  unchanged and the capability store unchanged. `runParallel_executed_supported_frame`
  lifts this to predicates with explicit support avoiding both regions.
- `mergeWorld_two_invariants` transports the separate branch predicates to the
  joined state using their support and the peer's disjoint write region.
  `runParallel_executed_two_invariants` first obtains each branch predicate by
  initialized induction. Its `LocalPreservation` premise requires preservation
  at actual `StepSound` transitions from a state satisfying the predicate; this
  remains an explicit local proof obligation, not a circular peer assumption.
- `evaluated_supplies_empty`, `extractReceipt_supplies_empty`, `step_no_supply`
  and `local_total_preservation` provide a concrete route from registered
  supply-free templates to total conservation. `supports_total` proves the
  exact domain/asset ledger support needed for that predicate.

All generic financial statements quantify over the existing finite identity
types, exact rational ledger and actual composition executor. Lower-level merge
lemmas state explicit locality/disjointness premises; public execution theorems
derive them from accepted analysis. Environment truth and boundary/store
authenticity remain external trust assumptions of the existing kernel.

## Concrete instances and counterexamples

The transfer fixture reuses the new compatibility development catalog and its
independently specified initial ledger: Alice USD 10, vault shares 20, other cells
zero. One branch transfers 3 USD; the other transfers 4 shares.

- `initialized_two_invariants` proves joined USD total 10 and share total 20 from
  initialization, separately proved local conservation, exact predicate supports,
  and discharged peer-write disjointness. It is not a bare computation of totals.
- `protected_collateral` instantiates the public supported-frame theorem at the
  untouched Alice collateral cell. `joined_authority` and `joined_nonnegative`
  instantiate the authority and state-witness results for the actual run.
- `unsupported_counterexample` exhibits empty-region agreement while Alice's USD
  predicate changes from 10 to 7. `unsupported_is_not_supported` proves that the
  proposed empty support is false. `written_support_counterexample` supplies a
  correct singleton support and shows why touching that support still prevents
  unconditional framing.
- Independent mint/burn templates have explicit supply effects: +2 USD at Alice
  and -4 shares at the vault. Exact supply capabilities are added to the fixture
  store. `supply_receipts` proves both real event lists have length one and the
  aggregate supplies are +2/-4. `supply_totals` derives actual totals 12/16 from
  the generic public accounting theorem and those explicit receipt amounts.
- `prefix_refusal_receipts` proves that mint succeeds before an exact local-index-1
  `unauthorizedInvoke` refusal caused by an empty capability selection. The peer
  burn succeeds independently. The retained supplies remain +2/-4.
  `prefix_authority` and `prefix_accounting` instantiate the generic authority
  and accounting theorems on that refused-prefix execution.

Closed finite comparisons use Lean kernel reduction (`decide +kernel`), not
`native_decide`. These are development fixtures, not deployed-protocol evidence.

## Verification and source identity

From `lean/`, `lake build DefiKernel.Parallel.PreservationFixtures` passed with
exit 0, 937 jobs. Full log: `preservation-build.log`.
The final `Preservation.lean` LSP diagnostics also reported zero errors.
Linter warnings remain advisory; no source cleanup was performed after the
parent froze the mutation runner's imported source closure.

From `lean/`,
`lake env lean ../review/semantic-kernel/sprint6/preservation-axioms.lean`
passed with exit 0. All 45 expected named declarations matched the 45 actual
disclosures exactly. Each transitive axiom set is a subset of
`propext`, `Classical.choice`, `Quot.sound`. Full log: `preservation-axioms.log`.
Tool: Lean `4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.

`preservation-verification.json` records the commands, outcomes, owned source
hashes, artifact hashes and hashes of all 20 local Lean source files in this
import closure. This named disclosure check does not replace the parent's full
imported theorem/supplemental axiom audit, integrated tests or native review.

| Source | SHA-256 |
| --- | --- |
| `lean/DefiKernel/Parallel/Preservation.lean` | `faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10` |
| `lean/DefiKernel/Parallel/PreservationFixtures.lean` | `0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7` |

Both files are final and frozen for parent integration. The parent verification
root imports `PreservationFixtures`. Native implementation review and remaining
Sprint 6 acceptance/delivery work are owned by the parent task.
