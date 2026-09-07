# Checked integer financial arithmetic implementation plan

> For agentic workers: use superpowers:executing-plans or the authorized stock-harness subagent workflow after the required planning gate.

**Goal:** Implement checked unsigned arithmetic, directed fees and a dimensioned reference accounting bridge.

**Architecture:** Pure bounded-word operations have independent mathematical specifications; fee quotes and scale conversion feed a registered existing-kernel reference template. Proof, finite execution, typing and mutation evidence remain separate.

**Tech stack:** Pinned Lean/mathlib, Python3 diagnostic/runner scripts, OpenSpec and native Grok/Fable reviews. Existing source/tool identities must be bound before implementation.

All new source paths are listed in design section5. Function signatures, numeric/error contracts and fixture inputs are fixed in the design and fixture-inventory.json. This author draft is not the final runner-control freeze.

- [ ] 1.1 Finish exact fixture environments, quoted mutation edits, projection inventory and literal runner controls; bind current Typed/runner/toolchain inputs before official freeze.
- [ ] 1.2 Validate this OpenSpec candidate and obtain nonauthor GPT-6/native Fable5.1 medium planning verdicts on the identical complete bundle.
- [ ] 1.3 Run the accepted current Lean and relevant runner baseline before implementation, saving actual commands and dependency bytes.
- [ ] 2.1 Create Arithmetic/Word.lean and Operations.lean with ofNat/add/sub/mul; implement F01–F06/F30–F31 and universal exact success/refusal proofs.
- [ ] 2.2 Create Rounding.lean with independent unbounded quotient specifications and full-product mulDiv; implement F07–F13 and prove zero-denominator precedence.
- [ ] 2.3 Prove independent floor/ceiling inequalities, exactness, directed rational error bounds and qualified monotonicity, including final-word overflow.
- [ ] 2.4 Create Fees.lean with natural rate parameters and separate gross/on-top policies; implement F14–F20/F29 and prove charged=received+fee and qualified fit.
- [ ] 2.5 Create Quantity.lean with toQuantity/fromRat; implement F21–F24 and prove scale-aware round trips and exact conversion characterization.
- [ ] 3.1 Create Reference.lean with quote-derived registered templates over the actual accepted Typed API and explicit authority/scale/footprint premises.
- [ ] 3.2 Create independent full-result fixture worlds and capabilities for F25–F28; verify exact aggregate state, unchanged store and located refusal semantics without a replacement trusted executor.
- [ ] 3.3 Prove reference effect accounting and actual-executor correspondence, including coincident targets and the current net-effect interpretation.
- [ ] 3.4 Add isolated wrong-asset compiler controls with a valid same-asset sibling; record compiler rejection separately from semantic mutations.
- [ ] 4.1 Create Examples.lean/Tests.lean and evaluate every frozen named literal fixture; retain complete input/results and no self-generated expected observations.
- [ ] 4.2 Run the independently coded finite Python divmod diagnostic oracle against named Lean observations on its exact frozen domain; keep this separate from universal proof and chain fidelity.
- [ ] 4.3 Create Arithmetic/Audit.lean and Verify.lean, with explicit package roots, dynamic theorem/supplemental inventories, full types and transitive axiom checks.
- [ ] 4.4 Implement the dedicated mutation projection and actual runtime edits M01–M12; require designated failures, F01/F03 global positives and separate sibling positives.
- [ ] 4.5 Implement literal runner controls for empty, missing, malformed, drifted and forged evidence, wrong-world observations, missing package members and audit-root errors; verify declared exits and positive siblings.
- [ ] 5.1 Run lake build DefiKernel.Arithmetic.Verify and lake env lean DefiKernel/Arithmetic/Verify.lean from lean/, plus the complete new runner/control suite.
- [ ] 5.2 Run relevant prior regressions for imported/changed runner and kernel integration paths, binding actual source identities and preserving all prior evidence.
- [ ] 5.3 Reconcile every scenario to actual generic/instance/finite/compiler/mutation/assumption evidence and record failed development attempts without changing their bytes.
- [ ] 5.4 Freeze final source and complete evidence; obtain substantive native Grok/Fable5.1 medium reviews and fix concrete findings before scoped acceptance.
- [ ] 5.5 Deliver the accepted branch through parent-owned commit/push/readback, synchronize the four main specs and archive the OpenSpec change with remaining arithmetic/protocol limitations explicit.
