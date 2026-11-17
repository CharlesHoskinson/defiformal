# Competitive landscape adoption tasks (after independent planning review)

All boxes stay unchecked in this planning freeze. Do not start Lean, CI configuration or adapter work until independent review accepts this slice. The 13 tasks follow section 4.2 of the report, with the project-specific prerequisites and acceptance conditions below. Each line carries the task, then in brackets its kind (better product, trusted by others, better measurement) and what it serves (gap D1 to D5 and report sections), and ends with its completion criterion as the verify clause.

Implementation transition (2026-11-17): task 1.1 accepted with limitations at revision `a163c10460ce61dd62a5001d6e7bd5b650cd8d75`, with all 17 boxes unchecked before acceptance. See [the review decision](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/DECISION.json) and its exact-input manifest. The planning freeze above remains historical; this checkbox update records the subsequent apply action. No implementation task is accepted.

Apply status (2026-11-17): tasks 1.1, 1.2, I.1 and I.2 are complete. The [partial accounting baseline](../../../benchmarks/component-accounting/README.md) records selected adapter counts and attribution, but I.3 stays open because separate historical authoring effort is unavailable. The owner confirms no outside reproduction record exists, so I.4 stays open. The owner subsequently authorized continued engineering with historical effort unknown; I.3 and I.4 remain open without blocking dependency-ready work. See [current apply status](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/APPLY-STATUS.json). II.1 now has an accepted fixed deposit-to-quote workflow; its separate-effort measurement scenario stays open. See [workflow acceptance](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/workflow-integration-decision.json). II.2 is complete with [quantified arithmetic-to-typed-model correspondence](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/computed-integration-decision.json); II.3 is complete with [the explicit token0 observation relation](../../../review/semantic-kernel/competitive-landscape-adoption-20261117/token0-integration-decision.json); universal source refinement remains unproved. Phase III and later implementation remain open.

## 1. Planning gate

- [x] 1.1 Obtain independent review of this exact `competitive-landscape-adoption` candidate under the reviewer bindings in `AGENTS.md`, record verdict, requested and reported model identity and input hashes, and verify no box in this file is ticked before acceptance.
- [x] 1.2 Include the IOG Suite 1.0 and rational-1 adapters in this change, as authorized on 2026-11-17. Import the required sources, proofs and helpers with pinned revision, file hashes, IOG attribution and replay instructions. Verify every dependent task (including II.2 and IV.1) stays blocked until its required pinned artifacts and dependencies are verified available; the contribution decision alone does not unblock it, and import alone is not fresh replay or proof on the kernel.

## 2. Phase I: operational

- [x] I.1 Add CI that runs the build and the axiom audit on every commit. [trusted by others; D5] Verify a passing run is visible at the current revision and the gate has been seen to fail on a deliberate break.
- [x] I.2 Cut a first tagged release, and add a contribution guide and a license file. [trusted by others; D5; 3.1] Verify a tagged release; both files in the repository.
- [ ] I.3 Start per-component accounting of model, specification and guidance lines, of authoring effort, and of attribution (AI-authored or human). [better measurement; D1; 2.7] Verify the vault deposit and the token0 register each report their counts and effort.
- [ ] I.4 Have an outside developer run the DeFiFormal sprint P18 token0 package from its README and record the outcome and setup time. [trusted by others; D5; 3.1] Verify a reproduction record by someone outside the project exists, pass or fail, with its setup time.

## 3. Phase II: the first composed example

- [ ] II.1 Compose the sUSDS deposit and the token0 quote register into one workflow under one `ComponentContract` that invokes one shared financial lemma; report the second instance's lines. [better product; D1] Verify a meaningful financial input/output relation, invariant initialization and preservation from actual execution with each step's local guarantees discharged, one shared lemma, units, refusal and counts. Without that relation, record only narrower reuse and leave composition open. (No tool has a supported unit-consistency or interface-compatibility cell, 1.2.)
- [x] II.2 Extend the deposit correspondence from the fixed WAD case to the full domain, using the native-correspondence helper of the benchmark adapter as the template for per-operation arithmetic contracts. [better product; D2; 2.7] Verify a theorem over all admissible assets and rates, not one literal. (Every benchmark result in the field is on a new model, 2.8.)
- [x] II.3 Write the simulation relation between the pinned token0 Solidity campaign and the Lean library, and state the remaining obligation. [better product; D3] Verify three artifacts exist: model theorem, differential observations, refinement obligation.

## 4. Phase III: ship the evidence

- [ ] III.1 Ship the compiled proof modules as the evidence package: checker name and version, trusted-import list, what each check covers and checksums. [trusted by others; D5; 2.5, 2.8] Verify a third party re-runs the leanchecker pass from the package alone.
- [ ] III.2 Ship an evidence package with the composed example and with every later integration, and record adoption only when it is corroborated. [trusted by others; D5; 3.1] Verify each shipped integration carries its package; every recorded adoption is corroborated.

## 5. Phase IV: widen the financial scope

- [ ] IV.1 Add an AMM swap operation with reserve accounting, specify it in both arithmetics with fees and refusal, and re-run R2 on the library instead of the benchmark model. [better product; D2; 1.1, 1.2, 2.2] Verify AMM conservation and no-arbitrage cells in 1.2 move from unknown; R2 is proved on the kernel.
- [ ] IV.2 Run one small ordering scenario on the interleaving executor and state the invariant or gain bound it suggests. [better product; D4] Verify a replayed counterexample or a proven bound with declared assumptions.
- [ ] IV.3 Model liquidation with solvency and correctness stated as separate theorems, when DeFiFormal sprint P27 opens. [better product; D4; 1.1, 1.2] Verify liquidation cells in 1.1 and 1.2 move from unknown.
- [ ] IV.4 Extend lending beyond borrow: repay, interest accrual, collateral deposit and withdrawal. [better product; D2; 1.1] Verify the lending cell in 1.1 moves from partial to supported. (Lending is supported by 2 competitors.)

## 6. Review and remainders

- [ ] 6.1 Reconcile every delta-spec scenario to proof, finite, mutation, measurement or assumption evidence, and verify no scenario is credited from a declaration alone.
- [ ] 6.2 Leave replay speed, deployed-code equivalence, a complete adversary model and corroborated adoption named as remainders, and verify none is claimed by this change.
