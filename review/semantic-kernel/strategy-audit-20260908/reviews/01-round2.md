# Soundness round 2: PLAN-v1

**Verdict: approve the strategic direction with limitations; make the three edits below before freezing the plan.** The user-selected objective is a broadly reusable verification platform and libraries. Two development cases are an early test of reuse, not the platform's completion condition. PLAN-v1 now respects that objective. No source edits, builds or later-candidate acceptance were performed by this review.

Inputs: PLAN-v1.md, reviews 02 and 03, and the existing remaining-financial-async and concentrated-liquidity source-readiness reports. This is local evidence inspection, not a new external source audit. Existing source pins and acceptance statuses retain their original evidence identities.

## 1. Separate representation correspondence from source refinement

Concrete problem: step 5 says “one quantified representation/refinement lemma.” That disjunction permits an encode/decode round trip or JSON-to-kernel equation to satisfy what the draft elsewhere calls the source-trust gate. Those are useful platform properties, but neither relates a pinned Solidity operation to its Lean model. Even a theorem comparing two independently authored Lean models does not close the source-to-model gap unless the source-side semantics is itself justified.

Exact replacement for step 5's quantified sentence:

> The first increment must include a quantified correspondence theorem for the supported certificate representation if that checker is delivered. For at least one selected financial operation, separately state a source-refinement obligation over its supported input domain, pre-state relation and full declared success/refusal observation. Discharge that obligation against a justified semantics of the pinned implementation, or publish the increment explicitly as model-verified with bounded source differential evidence and source refinement still open. Representation correspondence cannot discharge source refinement.

A quantified source theorem is essential **before claiming universally proved source fidelity**, but need not block publishing a useful bounded-evidence platform increment. The initial publication must expose that distinction in its API/report status, and the next resource gate must retain the outstanding source theorem rather than letting it disappear after green tests. Quantification over an enumerated fixture list remains bounded evidence; quantified input predicates must identify excluded behaviors and show ordinary successful inputs inhabit the domain. Input admissibility can be a legitimate external assumption; a premise asserting the desired output or the correspondence itself is not discharge.

A minimal semantic shape is: for all related admissible initial states and supported inputs, the pinned source operation and kernel/library execution produce related declared results, including refusals. Declare precisely whether observation includes error categories, returned values, relevant final state and external events. A pure-function target has no ledger history to preserve; do not require irrelevant history fields merely to make the interface look uniform. Compiler/EVM execution correctness, authentication and environment truth remain explicit trust boundaries if not proved.

## 2. Test shared interfaces without forbidding legitimate specialization

Concrete problem: “same core, proof contracts and harness” and the second-case no-rewrite rule can be interpreted as requiring identical adapters/proof bodies. Two contrasting operations should have different financial predicates and may need different source adapters. Conversely, sharing only a JSON envelope and runner executable is too weak to establish library reuse.

Exact addition to steps 4–5:

> Both cases use the same delivered kernel API, a shared amount/rounding/error contract where applicable, a common adapter observation/result interface, and one harness engine. Each case supplies explicit protocol-specific adapter code, fixtures and theorem instances. Name at least one substantive reused library lemma or financial contract and one reused executor/composition theorem. Record new definitions, discharged assumptions and interface changes; protocol-specific proofs are expected. No cloned kernel dispatcher or divergent harness engine is introduced without a justified boundary change.

Replace the falsification rule about repeating a full global proof with:

> If the second case cannot instantiate the shared executor/composition result and requires duplicating its global induction, inspect and revise the reusable boundary before adding a third family. New local financial/refinement proofs do not themselves falsify reuse.

This prevents both artificial sameness and superficial reuse credit. A pure swap arithmetic case should expose its library-to-Typed integration boundary if it is used as evidence for a kernel platform; otherwise label it arithmetic-library reuse only. M5 is not a prerequisite unless the selected statement actually needs active extension. Delivered Typed/sequential composition suffices for many bounded integrations; Claims is needed only if the chosen claim actually concerns liability lifecycle.

## 3. Make second-case source readiness a selection gate, not an assumed fact

Concrete problem: step 4 requires “two ... already-source-pinned operations,” but the inspected readiness evidence establishes the Uniswap historical pin, not an independently audited second contrasting protocol pin. The earlier financial readiness review explicitly left Curve/redemption source readiness open. The draft must not imply the missing source evidence already exists, or force two nearby SwapMath functions simply because they are available.

Exact replacement:

> Select two contrasting operations from already exposed development material. Verify or acquire the exact relevant source closure for each before implementation; preserve source and tool identities. Existing source readiness is a preference, not evidence inferred from a filename or historical prototype.

Preferred second case: a narrowly scoped stateful vault deposit/withdraw conversion with observable rounding and failure behavior, if a source-readiness check can bind an implementation and executable closure. It contrasts with a pure concentrated-liquidity step, exercises state and authority, and can reuse amount conversion/rounding plus Typed/sequential APIs without requiring M5. This is a selection recommendation, not a claim that a reviewed ERC-4626 source pin is already available. If no such source is ready, perform bounded source preparation rather than inventing fidelity; a pure fee/amount function from the same Uniswap closure can be an arithmetic rehearsal, but should not satisfy the two-behavior platform reuse gate by itself.

## Remaining draft questions and disposition

- **First coherent closeout:** inspect/review the existing M4 recovery candidate now, with the nonempty-write compatibility witness from review 02. Deliver only a coherent independently accepted scope. Whole M4 fixture closure need not become a barrier to an independent source-readiness experiment. Capability foundation or reporting repairs can close first if their exact acceptance is ready; mathematical correctness does not impose an arbitrary total order on independent closeouts.
- **Historical routing:** agree with review 03's additive index/routing approach. Protected old evidence should retain byte identity; put routing in current entrypoints when an in-file banner would invalidate a sealed historical artifact.
- **Cleanup and graph:** five incidental removals with byte backup and no source deletion do not change this soundness verdict. The new 633-source/567-edge graph, including ten M4 Tree files, improves navigation; it does not accept those modules or establish dead-code absence.

With these edits, approve the strategy for the reusable platform objective. The open financial source/refinement gate remains visible, later proof candidates retain their existing unaccepted status, and no blanket M5 dependency or whole-backlog completion barrier is introduced.
