# Six proof drafts: preliminary semantic audit

Status: PRELIMINARY; NO IMPLEMENTATION OR PROOF VERDICT. GPT-6 inspected the six source drafts read-only while native Grok compiles and repairs in its private cache. No Lean, Lake, LSP, build, mutation or financial execution was run by this checker. This review addresses theorem scope and premises, not transient elaboration errors. The parent's reported earlier compiled core does not confer acceptance on these drafts. Aborted/tmp-space attempts remain separate preserved evidence.

The six hashes were measured before reading, after reading and at report creation; the recorded bytes remained identical across this inspection. Future author edits need focused reconciliation. The existing accepted plan, role contract and earlier acceptance-checklist remain unchanged.

## Required coverage to close before accepting these as complete proof evidence

### P1. Aggregate supply accounting does not yet state full signed cell effects

Preservation.lean:15–21 defines successful attempt supply from `result.receipt.supply`; errors contribute0. `AdvanceSound.accounting` (line94), `Reachable.accounting` (line110) and `runPrefix_accounting` (line261) establish total balance over an asset/domain against the sum of these supply values. The equations are useful and retain signed supply; they do not claim the wrong result. But for an ordinary transfer the supply contribution is0, so they alone cannot establish which account lost/gained the transfer amount. They are weaker than the full signed receipt accounting requested in execution/spec.md and design D2/tasks3.6.

Add a generic actual-execution cell equation: each final cell balance equals its entry balance plus the sum of signed effects of actual successful receipts at that cell. Refusal/skip contribute0; duplicate signed deltas must sum correctly. The accepted bridge `Interface.step_receipt_cell` (Interface/Accounting.lean:19) already gives an actual executeStep-success equation to the corresponding cell effect; alternatively use its accepted Atomic bridge directly. Telescope from AdvanceSound/Reachable and expose a runPrefix corollary. Do not put Interface accounting/preservation proof imports into runtime roots.

If claiming an arbitrary-entry continuation form, compare the newly appended successful receipts (or a difference of accumulated effect sums) and retain the entry world and preexisting attempts. Do not count preentry receipts again against the entry world. This strengthening may live in a later proof module if ownership requires; the six currently inspected files do not yet supply it. The existing total/supply theorem should remain separately credited, rather than being relabeled as cellwise transfer accounting.

### P2. Exact own-history and stored-index trace coverage remains incomplete

Soundness.lean:13 defines `AttemptSound` as existence of some history under which executeStep yields the stored outcome. `Reachable.attempts` derives this from actual dispatcher cases. Trace proves an ordered successful-event projection of actual attempts (`branch_projection`, line75), concatenation of local outputs from local events (`local_history`, line111), the nextIndex/event-length identity (`local_event_index`, line140), and ordered invocation steps from the branch prefix (`local_order`, line169). These statements are soundly scoped but do not expose which prior own history was supplied to a particular stored attempt, or assert that each stored event.index equals its actual local sequence position. `nextIndex = events.length` is not a statement about those individual stored indices.

Before these are the sole evidence for the planned exact history/order/provenance claims, add a theorem tying a position in the global attempt list to the actual earlier machine/prefix with that attempt's before-world, selected invocation/index/boundary and the selected stream's then-current outputs. Equivalently characterize its executeStep history by filtering prior successful attempts for that participant and flattening their outputs, with a proper position/prefix relation. Prove the stored local event-index sequence is `List.range events.length` (or an equivalent indexed formulation) and retain the branch-step prefix result. An event membership statement with merely some successful history does not establish own-history provenance.

The underlying Reachable/AdvanceSound constructors do retain actual selection and execution equations, so this is an explicit derived-theorem/coverage gap, not evidence that the dispatcher or induction relation is circular. Avoid replacing the desired equations with new assumed trace-equality premises. If a separate later trace module supplies the stronger result, map it explicitly and close this item there.

## Generic interference: aligned statements and noncircular proof structure

Interference.lean quantifies arbitrary B with DecidableEq B; it neither hard-codes Fin3 nor introduces Fintype B. The theorem is meaningful for the finite roster supplied by the runtime and in fact does not need roster enumeration in its induction. Empty participants do not become a nonempty financial instance by this generality.

`LocalObligation` fixes each participant's invariant and guarantee, selects the branch invocation at the successful index, quantifies arbitrary own history/current world/result, and requires the actual executeStep-success equation. Its conclusion is the selected participant's invariant and guarantee. It does not assume every peer postcondition or a whole-run conclusion.

`CrossInclusion` requires the selected guarantee to imply each other participant's rely relation; `Stable` separately transports that peer's initialized invariant. In `AdvanceSound.preserves_invariants`, active-index order and selected membership derive nextIndex=consumed, so the local obligation applies to the same invocation/boundary/history that actually executed. Peers follow by cross-inclusion and stability. Refusal/exhaustion/halted cases use unchanged financial world and introduce no success guarantee.

`Reachable.invariants`, `runPrefix_invariants` and `every_prefix_invariants` retain all initial invariants and derive simultaneous preservation by actual prefix induction. The induction hypothesis is legitimately obtained from the prior reachable prefix, not supplied as an assumed desired final theorem. There is no hidden enabledness, future success, disjointness, shared-write commutation or authorization-only reserve implication.

`continueRun_invariants` explicitly requires Reachable from an initialized genesis world. It is therefore a reachable-entry continuation theorem. It does not claim an arbitrary synthetic entry is covered merely because current balances satisfy invariants. Broader arbitrary-entry invariant preservation would need explicit entry local-order/history hypotheses and their preservation; that stronger variant is not inferred here.

No substantive circularity or quantifier defect was found in these generic interference statements. This is a source review, not a statement that draft proofs elaborate. Concrete M2/causal/funded instances must still independently discharge their nonempty local/cross/stability/initialization obligations.

## Actual trace, completion, authority and frames

- Soundness extends the existing Execution.AdvanceSound/Reachable, rather than redefining them. Appended-outcome statements carry the actual selected invocation and executeStep equation. The casewise proof derives them from success/error/skip constructors. The existential-history AttemptSound has the limitation in P2, but it is not an assumed final trace.
- Trace.AttemptChain captures world sequencing and exact append order; it deliberately has no configuration/history premise. Use its Reachable derivation together with actual attempt soundness, not the bare chain predicate alone as authentication of arbitrary synthetic results. Its success and refusal constructors preserve exact before-world and outcome ordering. The branch projection excludes errors while retaining participant order and raw event data.
- LocalOrder derives active nextIndex=min(consumed,branch.length), using actual selected membership to obtain nextIndex=consumed. Exhausted selections can raise consumed without inventing success. Completion combines this with complete token counts to establish active exhaustion, or retains a failure whose index equals nextIndex. These are genesis runPrefix laws with explicit Complete premises, not enabledness claims.
- `AdvanceSound.refusal_stable` and `continueRun_refusal_stable` retain the exact existing first failure, events, outputs and nextIndex for arbitrary entry machines, while allowing consumed to increase and peer effects to update the world. They do not wrongly freeze the global world after a local refusal.
- Preservation authority uses a stored attempt's actual pre-world, current participant/index boundary, actual successful receipt and accepted executeStep soundness. `before_stores` and initial-store authority separately derive fixed capability store identity. They do not infer validity of arbitrary receipts from a catalog name or initial authorization alone.
- Actual-write locality/frame theorems require untouched cells/support explicitly. Analyzed frame theorems derive the selected invocation's analysis from a successful analyzeAll result, complete order coverage and accepted analyzeBranchFrom membership, then transport the actual executeStep target-frame result. They do not assume the desired final frame as a premise or use an arbitrary default footprint.
- `analyzed_locality` needs genesis Reachable to align consumed with successful index; it retains that premise. `covered : ∀ b, b ∈ order` is explicit, and the roster corollary supplies it from roster.complete. There is no left/right specialization or silent omitted-participant case.
- `runPrefix_nonnegative` simply projects the State.nonneg proof field. Credit it as inherited proof-carrying nonnegativity, not as discovered reserve/solvency or independently enabled success.

## Inspection and handoff

All six files were read in bounded chunks. rg searches confirmed that the accounting surface contains supply/total equations and no cell-effect telescope in these drafts; accepted Interface/Accounting.lean:19–37 was inspected to identify the existing actual-success cell bridge. No custom author code or tests were added by GPT-6. The sole review artifact is this report.

The substantive next steps are P1's full cellwise accounting and P2's exact stored history/index theorem coverage, plus normal author compilation/freeze and independent concrete financial proof review. No standalone final verdict is issued for mutable drafts.

Inspected hashes:

```json
{
  "Soundness": "8c1969b069ae893a350679963c48f24fac9bf3325645c2a5327317c1360baa23",
  "LocalOrder": "6006dd4610e25603606b86c46ab00fc626680d02fd4604a65af91b9a848111ed",
  "Trace": "3df168aed616fc0941a0128a52c124587aba747dd9c77f1f8f46f2e7a6589bff",
  "Completion": "3563dbb15ae4af53a434cdf2080118b29e65dc3a148c78e4cb2e7336c0649847",
  "Preservation": "17e05d29194138343d678d7de76f8539ba36f548b3c418f8de26c9d6cff96b12",
  "Interference": "82a0cf1ad4ba38d8c0be3b0c84b92ec54388e582407c510839ad85c7914a93fe"
}
```
