# Competitive landscape adoption: delivery milestone

**Draft restructuring — 2026-11-18; pending owner review.** These edits are a
proposal for review, not an accepted completion transition. No commit, push,
archive or live evidence-state update is authorized by this draft.

The accepted original result remains **13/17** at revision
`cd2f8ef5409c7e79a47e069738922858b5947409`, recorded in
[FINAL-ACCEPTANCE.json](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/FINAL-ACCEPTANCE.json).
That record and all frozen reviews, accounting manifests, scenario inventories and
publication receipts retain their original criteria and byte identities.

The proposed milestone is the implemented, reviewed and published verification
library, with explicit scoped accounting and engineering replay. Prospective effort
measurement and actual outside reproduction belong to the linked
[validation plan](../competitive-landscape-validation/tasks.md).
Its tasks remain open; they are not evidence of completed validation.

## Obligation mapping

| Original obligation | Proposed delivery criterion | Remaining validation obligation |
| --- | --- | --- |
| I.3: counts, attribution and historical effort | Scoped counts/attribution, exact source boundaries and recorded effort availability; unknown historical effort stays `null` with reasons | Validation 2.1 establishes prospective component accounting; 2.2 collects a new separate-effort experiment. Original effort has not been recovered. |
| I.4: actual outside P18 run | Transferred in full; absent from the delivery checklist | Validation 3.1 retains actual outside person, outcome and setup time. |
| II.1: composition plus separate-effort reuse scenario | Accepted actual composition proof and scoped deposit/quote/shared line counts | Validation 2.2 measures prospective effort separately; historical workflow component times stay unknown. |
| III.1: compiled delivery plus outside recheck | Exact published package and successful engineering replay from fresh extraction | Validation 4.1 retains actual outside package-only replay. |
| 6.1: scenario reconciliation | Reconcile the amended scenarios and transfer map after amendment acceptance | Original 2026-11-17 reconciliation stays historical; follow-up closure requires its own evidence. |

The proposed checklist retains existing acceptance for unchanged implementation
criteria. II.1 and III.1 below recognise already accepted engineering evidence;
their transferred criteria remain unchecked in the validation plan. I.3, new
amendment gate 1.3 and revised reconciliation 6.1 remain open. Completion under
the amended contract requires all three gates. No conclusion about productivity,
outside usability or adoption follows from closing the delivery milestone.

## 1. Planning gate

- [x] 1.1 Obtain independent review of this exact `competitive-landscape-adoption` candidate under the reviewer bindings in `AGENTS.md`, record verdict, requested and reported model identity and input hashes, and verify no box in this file is ticked before acceptance.
- [x] 1.2 Include the IOG Suite 1.0 and rational-1 adapters in this change, as authorized on 2026-11-17. Import the required sources, proofs and helpers with pinned revision, file hashes, IOG attribution and replay instructions. Verify every dependent task (including II.2 and IV.1) stays blocked until its required pinned artifacts and dependencies are verified available; the contribution decision alone does not unblock it, and import alone is not fresh replay or proof on the kernel.
- [ ] 1.3 Obtain owner approval and independent planning acceptance of the exact 2026-11-18 restructuring and linked validation plan. Verify a new revision/hash-bound decision explicitly accepts the changed completion criteria and obligation transfer, preserves the original 13/17 result, and records requested/reported reviewer identity under applicable bindings. Preparing this uncommitted draft does not close this gate.

## 2. Phase I: operational

- [x] I.1 Add CI that runs the build and the axiom audit on every commit. [trusted by others; D5] Verify a passing run is visible at the current revision and the gate has been seen to fail on a deliberate break.
- [x] I.2 Cut a first tagged release, and add a contribution guide and a license file. [trusted by others; D5; 3.1] Verify a tagged release; both files in the repository.
- [ ] I.3 Publish a scoped accounting reconciliation for the selected vault-deposit adapter and token0 quote-register adapter. [better measurement; D1; 2.7] Verify exact source identities, exhaustive model/specification/guidance counts, attribution with provenance, supporting-code exclusions, and effort availability for each. Unknown historical or per-component effort must remain null with a reason; shared elapsed sessions and command runtimes must not become authoring/person-hours. Bind the accepted baseline and state that it is not a complete-component cost or productivity measurement. Preserve its legacy unmet-I.3 verdict; a new accepted reconciliation must identify this amended criterion. Prospective measurement remains validation 2.1/2.2.

## 3. Phase II: the first composed example

- [x] II.1 Deliver the sUSDS deposit-to-token0-quote workflow under one `ComponentContract` with a shared financial lemma and scoped line counts. [better product; D1] Verify a meaningful financial input/output relation, actual initialization/preservation with each local guarantee discharged, one shared lemma, units and refusal; report deposit, quote and shared counts separately. Accepted [workflow evidence](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/workflow-integration-decision.json) and [accounting](../../../benchmarks/component-accounting/vault-quote-workflow.json) support this fixed illustrative workflow, not pool settlement or full-domain composition. Prospective separate-effort measurement is validation 2.2; unknown original component effort and effort-saving claims receive no completion credit here.
- [x] II.2 Extend the deposit correspondence from the fixed WAD case to the full domain, using the native-correspondence helper of the benchmark adapter as the template for per-operation arithmetic contracts. [better product; D2; 2.7] Verify a theorem over all admissible assets and rates, not one literal. (Every benchmark result in the field is on a new model, 2.8.)
- [x] II.3 Write the simulation relation between the pinned token0 Solidity campaign and the Lean library, and state the remaining obligation. [better product; D3] Verify three artifacts exist: model theorem, differential observations, refinement obligation.

## 4. Phase III: ship the evidence

- [x] III.1 Ship compiled proof modules with checker/runtime identity, version, trusted-import list, coverage and checksums. [trusted by others; D5; 2.5, 2.8] Verify an exact published archive successfully replays selected modules from a fresh extraction using the bundled runtime, and that missing/empty/unreadable required evidence blocks while altered bytes fail. The [v0.16.0 publication](../../../docs/evidence/compiled-margin-close-macos-arm64/publication.json) and its independently reviewed package controls support engineering delivery. Actual outside package-only reproduction remains validation 4.1; it is not implied by this checked box.
- [x] III.2 Ship an evidence package with the composed example and with every later integration, and record adoption only when it is corroborated. [trusted by others; D5; 3.1] Verify each shipped integration carries its package; every recorded adoption is corroborated.

## 5. Phase IV: widen the financial scope

- [x] IV.1 Add an AMM swap operation with reserve accounting, specify it in both arithmetics with fees and refusal, and re-run R2 on the library instead of the benchmark model. [better product; D2; 1.1, 1.2, 2.2] Verify AMM conservation and no-arbitrage cells in 1.2 move from unknown; R2 is proved on the kernel.
- [x] IV.2 Run one small ordering scenario on the interleaving executor and state the invariant or gain bound it suggests. [better product; D4] Verify a replayed counterexample or a proven bound with declared assumptions.
- [x] IV.3 Model liquidation with solvency and correctness stated as separate theorems, when DeFiFormal sprint P27 opens. [better product; D4; 1.1, 1.2] Verify liquidation cells in 1.1 and 1.2 move from unknown.
- [x] IV.4 Extend lending beyond borrow: repay, interest accrual, collateral deposit and withdrawal. [better product; D2; 1.1] Verify the lending cell in 1.1 moves from partial to supported. (Lending is supported by 2 competitors.)

## 6. Review and remainders

- [ ] 6.1 After amendment acceptance, publish a new reconciliation of every revised delta-spec scenario and each transferred obligation to proof, finite, mutation, measurement, unknown or pending external evidence. Verify exact scenario/spec identities, preserve the original scenario inventory and final acceptance, name open validation task IDs, and obtain independent acceptance before changing live status or closing the amended milestone. No scenario is credited from a declaration or requirement transfer alone.
- [x] 6.2 Leave replay speed, deployed-code equivalence, a complete adversary model and corroborated adoption named as remainders, and verify none is claimed by this change.
