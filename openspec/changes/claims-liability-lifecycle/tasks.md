# Claims liability lifecycle implementation plan

Author draft only. Use `superpowers:executing-plans` after the same-candidate independent planning gate. Every implementation task remains unchecked; this document authorizes no kernel edit by itself.

**Goal:** Actual fixed-principal claim lifecycle with atomic ledger-backed funding and repayment.
**Architecture:** Separate augmented state and checked command executor; actual Composition invocation results feed exact payment checks before one publication; generic reachability proves lifecycle invariants.
**Tech stack:** Accepted pinned Lean/mathlib, Python3 production evidence tooling, OpenSpec. All Lean commands run from `lean/` with its pinned toolchain. Preserve legacy World/Right/modules/statements and runtime import discipline. No Foreman, sorry, custom axiom or native_decide.

## 1. Freeze and baseline

- [ ] 1.1 Refresh the actual accepted Typed/Composition/Atomic source identities and inherited runner CLI catalog; bind all normative inputs, fixture/mutant expectations and explicit unresolved external assumptions before official planning freeze.
- [ ] 1.2 Obtain nonauthor GPT-6 and native Fable5.1 medium verdicts on the same candidate; preserve actual models, findings, unavailable attempts and hash checks. This author cannot provide the independent vote.
- [ ] 1.3 Run the fresh accepted Lean/runner baseline with exact commands, executable hashes and nonempty counts; record an initial missing Claims feature as development scaffolding, not a semantic negative.

## 2. Runtime state and metadata lifecycle

- [ ] 2.1 Add Claims/Types.lean records, positional ClaimId store, raw rational validated amounts, status/default/revision and clock validation; execute F01/F23 and prove empty validation plus first-invalid-row precedence under CS01–CS03.
- [ ] 2.2 Add Claims/Lifecycle.lean lookup/revision/domain/current-role checks with the design's exact failure order; execute F09/F10/F21, including broad cash/admin permissions that do not confer lifecycle ownership.
- [ ] 2.3 Implement transfer and active due-only extension; execute F04/F05/F22 with exact unchanged fields and rejected self/debtor transfer or defaulted extension under CL02.
- [ ] 2.4 Implement explicit creditor forgiveness and default; execute F06/F07/F08/F22, including now=due refusal, defaultAt retention and paid-versus-waived separation under CL03/CL04.
- [ ] 2.5 Implement nondecreasing lifecycle time and stale revision behavior without strengthening legacy time semantics; execute F19/F21 and paired-invalid precedence under CL05.

## 3. Actual money execution and publication

- [ ] 3.1 Add Claims/Payment.lean exact all-cell effect and all-domain/asset supply checks over the actual invoked receipt; retain source/destination/amount identities and finite executable comparisons, with valid zero-effect/wrong-source/asset/supply inner calls in F12–F16.
- [ ] 3.2 Add Claims/Execution.lean funded createLoan through actual Composition.executeStep; append only after checks and execute F01/F24 with positive principal, distinct parties, due bound and fresh IDs under CP01.
- [ ] 3.3 Implement positive bounded partial/full repayment to current creditor through actual execution; execute F02/F03/F04/F11/F17, including fractional amounts and overpayment with sufficient cash, under CP02/CP03.
- [ ] 3.4 Implement one publication point, exact underlying failure and tentative-result paymentMismatch; execute F12/F13/F24 with no claim/cash/output/event publication on refusal under CP04.
- [ ] 3.5 Implement exact legacy Step lifting and mixed successful event/output/index handling; execute F19/F20 with actual indexed snapshots and metadata commands consuming positions under CT01.
- [ ] 3.6 Implement start/advance/continueRun and sticky failed suffix; execute F18/F20/F21 and independent refusal siblings without restarting a failed cursor implicitly.

## 4. Proofs and observations

- [ ] 4.1 Add Claims/Observation.lean full state/event/receipt/failure comparator, including every claim field and tentative diagnostics; verify reflexive/actual equality consequences and finite reference comparator coverage.
- [ ] 4.2 Add Claims/PaymentSoundness.lean actual-success characterization and exact ledger equations from executeStep_sound, retaining kernel permissions and zero supply; do not premise a fabricated receipt or desired world equality.
- [ ] 4.3 Add Claims/Preservation.lean reachability from actual equations and initialized store validity; prove decomposition, statuses, immutable fields, other-row framing, clock bounds and revisions for every actual command under CT02.
- [ ] 4.4 Prove positional no-disappearance, permanent terminal rows, fresh append IDs and rejected reactivation; instantiate paid and forgiven F18 siblings.
- [ ] 4.5 Prove every remaining reduction has an actual debtor-payment or creditor-forgiveness witness, default/transfer/extension preserve amounts, and the cumulative paid/waived equation; retain per-event creditor after transfers.
- [ ] 4.6 Prove every created row in an empty-origin trace has its actual funding-event witness; separately state that imported valid initial obligations need no historical funding proof.
- [ ] 4.7 Add Claims/Conservative.lean local payment/world projection, metadata stutter and refusal entry identity, then exact legacy-only continuation from arbitrary embedded Composition cursors under CT03.
- [ ] 4.8 Prove empty/append/failed-suffix and initialization corollaries without assuming success, omitting histories, or claiming arbitrary mixed-trace erasure.

## 5. Financial and evidence gates

- [ ] 5.1 Implement Claims/Examples.lean and Tests.lean for all24 frozen fixture IDs with complete literal expected finite cells, capabilities, claim fields, events, outputs and failures; proof-only concrete witnesses go in Claims/Fixtures.lean outside the runtime closure.
- [ ] 5.2 Add Claims/Audit.lean unique nonempty production results and Claims/Verify.lean proof roots; coordinate parent import/build registration, then run `lake build DefiKernel.Claims.Verify` and `lake env lean DefiKernel/Claims/Verify.lean` from lean/.
- [ ] 5.3 Freeze exact20 actual source mutations in mutations/claims.json and implement scripts/claims_gate.py; execute each compiled mutant against its independent false oracle, recording blocked anchors/compilation/timeouts separately from semantic detection.
- [ ] 5.4 Implement scripts/test_claims_gate.py using the refreshed actual CLI catalog and complete namespace/import/root/proof-tail/fixture/diagnostic mapping; exercise false production results, IO.userError, malformed/empty/duplicate records, source/path/time failures and successful siblings.
- [ ] 5.5 Run fresh integrated Lean, actual runtime/mutations and relevant legacy regressions on a frozen candidate; capture full stdout/stderr, commands, environment, UTC/duration, tool/source before-after hashes and artifact manifests under CE01/CE02.
- [ ] 5.6 Dynamically enumerate all actual imported theorem and supplemental declarations, full statements, premise/provenance/axioms and generic-versus-instance/counterexample roles; reconcile every scenario to exact actual evidence.
- [ ] 5.7 Obtain native Grok and Fable5.1 medium complete source/evidence reviews on the identical candidate; preserve all attempts and close concrete findings without substituting author validation for external approval.
- [ ] 5.8 Parent delivers accepted source/evidence via commit/push/readback/archive and records remaining conditional/indexed, async, integer, provenance and deployed/legal obligations; no broader roadmap completion follows.
