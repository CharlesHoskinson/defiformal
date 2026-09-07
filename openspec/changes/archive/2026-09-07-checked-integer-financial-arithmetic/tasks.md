# Checked integer financial arithmetic implementation plan

> For agentic workers: use superpowers:executing-plans or the authorized stock-harness subagent workflow after the required planning gate.

**Goal:** Implement checked unsigned arithmetic, directed fees and a dimensioned reference accounting bridge.

**Architecture:** Pure bounded-word operations have independent mathematical specifications; fee quotes and scale conversion feed a registered existing-kernel reference template. Proof, finite execution, typing and mutation evidence remain separate.

**Tech stack:** Pinned Lean/mathlib, Python3 diagnostic/runner scripts, OpenSpec and native Grok/Fable reviews. Existing source/tool identities must be bound before implementation.

All new source paths are listed in design section5. Function signatures, numeric/error contracts and fixture inputs are fixed in the design and fixture-inventory.json. The companion inventories fix all proposed fixture, mutation, projection and literal65-control contracts. Actual source/execution identity remains a later freeze.

- [x] 1.1 Reconcile the complete fixture, mutation, projection and literal65-control inventories with current Typed/runner/toolchain bindings before official freeze.
  - Verification: Strict validation; all45 fixture IDs,12 exact proposed edits,65 cases and complete planned module/helper lists have explicit mappings and no symbolic result placeholders.
- [x] 1.2 Validate this OpenSpec candidate and obtain nonauthor GPT-6/native Fable5.1 medium planning verdicts on the identical complete bundle.
  - Verification: Retain identical-bundle GPT-6/Fable5.1 verdicts and adjudication; unavailable or tool-only output leaves gate open.
- [x] 1.3 Run the accepted current Lean and relevant runner baseline before implementation, saving actual commands and dependency bytes.
  - Verification: Actual baseline commands, raw logs, exits and all relevant source/tool hashes retained; no old evidence relabelled.
- [x] 2.1 Create Arithmetic/Word.lean and Operations.lean with ofNat/add/sub/mul; implement F01–F06/F30–F33 and universal exact success/refusal proofs.
  - Verification: Generic exact success/refusal/word-bound theorems compile for arbitrary w; designated literals compare exact values and errors.
- [x] 2.2 Create Rounding.lean with independent unbounded quotient specifications and full-product mulDiv; implement F07–F13/F34/F39/F44–F45 and prove zero-denominator precedence.
  - Verification: divideNat independent iff for all numerator/denominator plus mulDiv final bound; all specified literal outputs/errors match.
- [x] 2.3 Prove independent floor/ceiling inequalities, exactness, directed rational error bounds and qualified monotonicity, including final-word overflow.
  - Verification: Exported quantified types show d>0 and successful-result premises; check directed error signs and divisibility, not a four-bit proxy.
- [x] 2.4 Create Fees.lean with natural rate parameters and separate gross/on-top policies; implement F14–F20/F29/F35–F37 and prove charged=received+fee and qualified fit.
  - Verification: Universal valid-rate fee bound and quote conservation derived; literal wide rate, tiny amount, zero/unit and on-top overflow agree.
- [x] 2.5 Create Quantity.lean with toQuantity/fromRat; implement F21–F24/F38 and prove scale-aware round trips and exact conversion characterization.
  - Verification: Both round trips and exact natural-multiple iff compile; literal fractional/negative/scale-first/overflow outputs and asset-indexed typing match.
- [x] 3.1 Create Reference.lean with quote-derived registered templates over the actual accepted Typed API and explicit authority/scale/footprint premises.
  - Verification: Read the exported theorem: no assumed target execute equation or full Valid; constructed static checks and accounting are derived.
- [x] 3.2 Create independent full-result fixture worlds and capabilities for F25–F28/F40–F43; verify exact aggregate state, unchanged store and located refusal semantics without a replacement trusted executor.
  - Verification: Every actual result compares all16 cells and4 complete capabilities; refused input observations are explicitly retained inputs only.
- [x] 3.3 Prove reference effect accounting and actual-executor correspondence, including coincident targets and the current net-effect interpretation.
  - Verification: Universal aggregate formula handles all coincidences; F40/F41 succeed at net funding, F42 scale and F43 on-top expectations match.
- [x] 3.4 Add isolated wrong-asset compiler controls with a valid same-asset sibling; record compiler rejection separately from semantic mutations.
  - Verification: T01 fails only expected asset mismatch, T02 compiles; exact commands, logs, hashes and source preserved.
- [x] 4.1 Create Examples.lean/Tests.lean and evaluate every frozen named literal fixture; retain complete input/results and no self-generated expected observations.
  - Verification: Exactly45 unique named comparisons true with independently literal inputs/results; full inventory mandatory in every variant.
- [x] 4.2 Run the independently coded finite Python divmod diagnostic oracle against named Lean observations on its exact frozen domain; keep this separate from universal proof and chain fidelity.
  - Verification: Exact27968 unique tuples cover frozen Cartesian domain; Lean observations match independent Python divmod and all failure tags.
- [x] 4.3 Create Arithmetic/RuntimeAudit.lean, ProofAudit.lean and Verify.lean, with explicit package roots, dynamic theorem/supplemental inventories, full types and transitive axiom checks.
  - Verification: Runtime #eval numeric protocol works for true/false; dynamic imported declarations have full types, categories and zero forbidden dependencies.
- [x] 4.4 Implement the dedicated mutation projection and actual runtime edits M01–M12; require designated failures, F01/F03 global positives and separate sibling positives.
  - Verification: All12 actual source edits compile, designated false/global positives hold, and supplemental sibling/matrix reconciles; compile failures blocked.
- [x] 4.5 Implement literal runner controls for empty, missing, malformed, drifted and forged evidence, wrong-world observations, missing package members and audit-root errors; verify declared exits and positive siblings.
  - Verification: All65 actual CLI cases match10/5/50; T01/T02 and A01–A04 tracked separately with successful siblings; no arbitrary tamper claim.
- [x] 5.1 Run lake build DefiKernel.Arithmetic.Verify and lake env lean DefiKernel/Arithmetic/Verify.lean from lean/, plus the complete new runner/control suite.
  - Verification: Pinned cwd lean commands exit0; all actual new runtime/mutation/control evidence is nonempty, complete and source-bound.
- [x] 5.2 Run relevant prior regressions for imported/changed runner and kernel integration paths, binding actual source identities and preserving all prior evidence.
  - Verification: Relevant baseline closures matched or freshly rerun with justified differences; preserve original accepted evidence bytes.
- [x] 5.3 Reconcile every scenario to actual generic/instance/finite/compiler/mutation/assumption evidence and record failed development attempts without changing their bytes.
  - Verification: All36 scenarios map to their actual proof/finite/compiler/mutation/control/assumption evidence with hashes and honest limitations.
- [x] 5.4 Freeze final source and complete evidence; obtain substantive native Grok/Fable5.1 medium reviews and fix concrete findings before scoped acceptance.
  - Verification: Identical frozen actual source/evidence native Grok/Fable verdicts and remediation retained; no missing reviewer treated as approval.
- [x] 5.5 Deliver the accepted branch through parent-owned commit/push/readback, synchronize the four main specs and archive the OpenSpec change with remaining arithmetic/protocol limitations explicit.
  - Verification: Parent-owned push/readback and archive identities verified; four specs synced only for accepted scoped behavior.
