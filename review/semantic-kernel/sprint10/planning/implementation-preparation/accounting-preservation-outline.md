# Read-only Regions / Accounting / Preservation handoff

Source context: accepted eec499d, frozen S10 planning candidate2b1957b8.
This is a proof decomposition and symbol map, not an implementation or verdict.
No Interface file or new proof exists. `source-bindings.json` records exact inputs
and unchanged hashes for all78 planning-bundle inputs.

## Runtime region API and finite sums

Keep `Regions.lean` dependent on Composition.Execution and the minimal Finset
big-operator imports. Runtime definitions: Region/WellFormed, balanceSum,
receiptCellEffect, receiptDelta, WritesWithin, NeutralOn and value-valued support.
The exact computational facade remains the ordered mapped sum of *all* evaluated
deltas matching the cell; administrative receipts return0. `Atomic.receiptEffect`
(Policy.lean:72) uses the existing evaluated effect; establish facade equality by
receipt cases and unfolding the existing effect, then use that bridge in proofs.

Correction after the nonauthor planning finding: pinned `Finset.toList` is
**noncomputable** (Data/Finset/Dedup.lean:163). It must not occur in runtime
Regions definitions or an accepted executable mutation. Define balanceSum and
receiptDelta directly with executable Finset.sum. The mathematically valid
`sum_map_toList` theorem does not confer executability on choice-based toList;
my original preparation note repeated that incorrect assumption and is retained
separately as superseded.

Recommended M01 replacement, pending root’s bounded constructibility probe and
completed planning reviews: replace sum with `region.cells.fold max 0 state.balance`.
Finset.fold is defined in Data/Finset/Fold.lean:38 using a commutative associative
operation. It needs no arbitrary enumeration. F01 gives sum10 versus maximum6;
the empty region remains0. These are predicted observations, not a runtime
result from this read-only task. Correct the F07 pseudo-code to
`SeqGroup.seq (.step (.invoke op102)) (.step (.invoke op102))` when root authorizes
the revised inputs, since op102 denotes an Invocation. No frozen plan is changed
here.

`Finset.sum_congr rfl` lifts pointwise
cell equalities; `Finset.sum_add_distrib` separates pre-balance and receipt sums.
`Finset.sum_subset` removes the complement when effects vanish there
(Basic.lean:195, additive form of prod_subset). The concrete subset is
`L.cells ∩ Q ⊆ L.cells`; outside the intersection but inside L, confinement
excludes receipt writes. Use the reversed subset-sum equality if its orientation
is intersection→whole. Finset membership remains set-valued; do not deduplicate
the ordered receipt delta list.

Local search did not index the generated additive Finset names. Their pinned
source annotations and existing `sum_congr`/`sum_add_distrib` uses were inspected;
no new elaboration was attempted during this read-only task.

## Exact successful-step accounting and supported totals

`Composition.executeStep_sound cfg boundary index history step pre result h`
(Execution.lean:201) consumes the actual `.ok result` equation.
`Atomic.step_receipt_balance sound cell` (Settlement.lean:29, LSP-confirmed)
returns `result.world.state.balance cell = pre.state.balance cell +
Atomic.receiptEffect result.receipt cell`, with shared DecidableEq/Fintype P/A/D.
It includes invocation, issue and revoke; no whole-asset neutrality premise.
Finite summation gives the planned actual region equation directly.

`Composition.StepSound.locality sound cell outside` (Execution.lean:261) returns
unchanged balance when `cell ∉ result.receipt.writes`. Combine it with the exact
cell equation to derive effect0 outside writes, then outside Q under WritesWithin.
NeutralOn plus the subset-sum equality gives unchanged region sum.
`Composition.AgreeOn S pre post` (Contracts.lean:31) is pointwise balance equality
on S. The existing Supports is Prop-valued; define the planned value-valued
ValueSupports separately. Excluding every actual receipt write from S gives
AgreeOn via locality, hence equal declared-total values. Initialize the region/
declared-total equality and compose these two equalities. Constant ghost totals
use the empty support set. Administration changes stores while retaining balances.

## Arbitrary-entry continuation, actual suffix and groups

`Composition.Cursor` (Sequence.lean:17) carries world/events/outputs/nextIndex/
failure. `advance` branches first on old failure, then actual executeStep:
old failure returns the same cursor; new refusal changes only failure; success
appends exactly one Event and result.outputs and increments the absolute index.
`continueRun` is the foldl of this actual advance. Existing
`continueRun_append` and `continueRun_failed` are at lines73/81.

Prove a strengthened continuation induction returning an existential **new event
suffix** with `final.events = entry.events ++ suffix` and
`balanceSum L final.world.state = balanceSum L entry.world.state +
(suffix.map (fun event ↦ receiptDelta L event.result.receipt)).sum`.
Generalize the complete entry cursor in the induction. At success, prepend the
actual event to the recursively obtained suffix and use the actual-step equation;
at failure, the recursive run is inert. This establishes the event append
relation before identifying the suffix with `final.events.drop entry.events.length`
using core `List.drop_append_length`. No old event is summed again.

For invariant preservation, use the same actual advance/continuation induction
with static Allowed membership and the plan's local obligation quantified over
arbitrary boundary/index/history/pre/result. The allowed step at the head is
available independently of whether it succeeds. Derive every-prefix corollaries
by applying the theorem to a taken list and its inherited membership proof.
Do not use TraceSound.nil/continueRun_trace_sound to manufacture arbitrary-entry
reachability; those cannot justify F16's old history and index2.

`Metatheory.runGroup_eq_continueRun cfg boundaries cursor group`
(SequentialGroups.lean:34) is unconditional full-cursor equality with continuation
on flatten. Rewrite with this existing theorem after proving continuation results.
F07 supplies initialized A=B group instances; F16 supplies arbitrary-entry total/
history instances. Neither changes the generic theorem's obligations.

## Actual binary attempts and binding integration

Use `Interleaving.Reachable` induction (Soundness.lean:30) and case-split its
`AdvanceSound` (line11). Halted/exhausted skip adds no attempt and preserves world;
refusal adds one `.error` attempt and preserves world; success appends the actual
`.ok result` attempt and replaces world with result.world. The accepted constructor
carries both selected invocation and exact executeStep equality. Define region
attempt contribution as0 for error and receiptDelta for success; telescope this
actual global list using map/sum append. The existing whole-asset proof
`AdvanceSound.accounting`/`Reachable.accounting` in Interleaving.Preservation is
an exact structural template, not itself a region theorem.

Direct Reachable induction also lifts arbitrary Allowed-based invariants: selected
getElem? equality implies membership in the selected static branch; instantiate
Allowed(.invoke inv), then apply the local success obligation. All four cases
remain explicit. `runPrefix_reachable` supplies every finite scheduled prefix;
complete admission or disjointness is unnecessary for this bounded prefix law.
Existing Interference.LocalObligation consumes StepSound rather than the plan's
executeStep equation; direct induction avoids assuming an unproved converse from
StepSound to execution or adding an artificial catalog premise.

Expected module dependency: runtime Bindings imports Regions; Accounting imports
Regions plus the accepted Atomic receipt bridge; binding paired-effect helpers
can import Accounting proof-side; Preservation imports those helpers and the
actual sequence/interleaving/group APIs. Root's binding helpers should expose
resolved-edge preservation from initialized equality and equal *actual* endpoint
effects, and a global-edge membership lifting lemma. No finished-run equality,
future peer result, cut-local replacement edge set or commutation premise enters.
