# Sprint 5 execution adapter report

Scope: tasks 3.1–3.5, implemented by the GPT-6 stock harness worker. No commit was created by this worker. Parent owns integration and independent native review.

`Execution.lean` defines immutable configuration, separately supplied boundary context/environment/time, caller invocation data, administrative steps, actual evaluated receipts, and `executeStep`. Configuration and interface preparation precede delegated financial execution. Issuance configuration is derived from exactly the execution registry. Financial execution receives the current pre-world ledger and capability store.

The adapter re-evaluates the selected registered template and checked arguments against the same pre-world. `extractReceipt_total` derives total extraction from `Typed.execute_evaluated`; `extractReceipt_correspondence` links the extracted evaluation to actual application. No synthetic/default receipt or post-minus-pre supply definition is used. Error outcomes contain no committed world or successful outputs; the sequence layer retains the pre-world on error.

`StepSound` relates each successful invocation to preparation, registered execution, actual extraction/application, and exact selected post-state snapshots. Administrative constructors retain the exact issue/revoke API equations. `executeStep_sound` proves this relation for adapter successes. Generic delegated success/refusal theorems preserve delegated refusal reasons and show accepted financial calls cannot fail receipt extraction.

Step lemmas prove actual receipt accounting, checked-write locality, invocation capability preservation, administrative ledger preservation, administrator identity, effect debit/supply and invocation authority at the pre-store, and per-invocation changed-cell domain restriction. Nonnegative balances are intrinsic to the resulting `Typed.State`; existing kernel success establishes them when constructing the state.

Verification: `lake build DefiKernel.Composition.ExecutionTests` passed with 926 jobs and 11/11 named executable comparisons. Checks exercise exact transfer movement/evaluated writes/supply/snapshot; actor mismatch before missing invoke authority; kernel authority, membership, input-unit and configuration refusals; issue/revoke ledger and receipt behavior; administrative unauthorized/unknown-capability refusals. These are bounded runtime comparisons, not general theorems. Existing Typed.Transition linter warnings are unchanged. New line-width warnings were subsequently removed and a focused Lean compile was run.

The integrated runner, full imported axiom audit, source mutations, exact candidate commit and Grok/Fable review remain parent integration responsibilities. ReceiptAuthorized has True administrative branches because administrative authorization is separately stated by StepSound.issue_admin/revoke_admin; it does not assert grants for administration. Trust assumptions remain registry/admin/boundary authenticity and observation truth.

Source SHA-256 at worker handoff:

- `lean/DefiKernel/Composition/Execution.lean`: `ca91871df4657e65491fcc590a66278b0ecabb14db1afe46bf7cb0d18c95535f`
- `lean/DefiKernel/Composition/ExecutionTests.lean`: `68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5`
