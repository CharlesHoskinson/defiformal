# Sprint 4 Task 3 delivery

Implemented only repository files:
- lean/DefiKernel/Typed/Transition.lean
- lean/DefiKernel/Typed/TransitionTests.lean

No commits, no Foreman, no other repository edits. Implementation performed in stock GPT-6 agent harness. Independent native Grok/Fable review and full source-bound rebuild are parent acceptance work and are not claimed by this report.

## API

Namespace DefiKernel.Typed; type order Party Asset Domain.

CellDelta signature holds asset, matching target CellRef and amount Expr. SupplyDelta signature holds domain, asset and matching amount Expr.
Template fields: signature, domain, partyArity, guard, deltas, supplyDeltas, stateReads (List PackedCellRef), envReads (List EnvRead), writes (List PackedCellRef).
Registry := OperationId -> Option Template.
registryAuthorityConfig registry domainAdmin derives operationDomain by mapping Template.domain over registry lookup.
Request fields: operation, parties, arguments, capabilityIds, claimedActor (default none).
execute registry store ctx env now request state : Except Refusal ExecutionResult.
ExecutionResult fields: state, capabilities.

Evaluated is internal interpreter data with concrete delta/supply lists and resolved read/write sets. execute always computes it from the registry-selected template. Public request data cannot carry it. applyEvaluated is the lower-level checker; generic entry-point authorization theorems are stated for execute.

Repeated effects and supplies sum all matching entries; effect_cons and supply_cons prove the contribution rule. No last-write-wins behavior.

## Refusal order and scopes

Order: registry lookup; claimed-actor equality if present; context/template domain equality; party arity; numeric argument check; invoke right; reference/effect evaluation; guard; state-read declaration; environment-read declaration; domain locality; debit rights; supply rights; nonnegative update; accounting; writes.

Expression evaluation includes all delta and supply expressions before the guard Bool is checked, so an evaluation failure can precede false guard refusal. Syntactic read resolution includes inactive branches. Domain checks require required state reads and actual net balance/supply movement to stay in ctx.domain. Environment keys may refer to other domains as explicitly declared adapter-supplied observations. Extra declarations are conservative. Write checks concern aggregate net changes.

No executable definition depends on a theorem below -- BEGIN PROOFS. State is constructed directly from the checked nonnegative witness. All other validation branches are computational booleans, allowing parent mutation projections to bypass branches without importing proof certificates.

## Compiled proof endpoints

- applyEvaluated_ok_iff: all concrete checks iff success and exact balance update/capability preservation.
- execute_ok_iff: selected registered template, exact actor/domain/party boundary, checked typed args, live invoke right, actual template evaluation, all checks, exact balance update and capability preservation iff success.
- execute_evaluated: registry and evaluation witness whose applyEvaluated result is the executed post-state.
- execute_nonnegative.
- execute_preserves_capabilities.
- execute_invocation_authority, execute_debit_authority, execute_supply_authority: witnesses with supplied ID membership, stored capability, live bit, exact holder/domain/operation and exact right. Debit/supply theorems use actual decrease or total change in the returned post-state.
- execute_accounting_and_locality: evaluated registered-template witness, domain/asset accounting, unchanged balances outside resolved declared writes.
- execute_reads_and_domain: required reads declared; state reads domain-local; changed balances domain-local.
- Evaluated.effect_cons and Evaluated.supply_cons.

Administrative commands operate CapabilityStore only; no grant/revoke ledger-update theorem is invented. Authentication, trusted registry/admin configuration, observation truth, finite universe, rational formulas, replay permission and net-effect semantics remain stated boundaries.

## Validation performed

From /home/charl/defiformal/lean:

1. lake env lean -o .lake/build/lib/lean/DefiKernel/Typed/Transition.olean DefiKernel/Typed/Transition.lean
   Final exit 0, no warnings. Used frozen dependency .olean files to avoid concurrent source-build races.
2. lake env lean -o .lake/build/lib/lean/DefiKernel/Typed/TransitionTests.olean DefiKernel/Typed/TransitionTests.lean
   Final exit 0. 48 nonempty uniquely labeled runtime comparisons, all true.
3. lake env lean /tmp/defiformal-sprint4-task3-axioms.lean
   Exit 0. Audited execute_ok_iff, execute_nonnegative, execute_preserves_capabilities, execute_invocation_authority, execute_debit_authority, execute_supply_authority, execute_accounting_and_locality, execute_reads_and_domain. All report only propext, Classical.choice, Quot.sound. No custom axioms, sorry or native_decide.

TransitionTests.checks is exported for central Audit. Its standalone driver is below the proof marker and emits label: true/false, followed by exactly Typed runtime comparisons failed: N on failed comparisons. Empty checks refuse separately. Test namespace closes above marker so projections can strip the driver safely.

Tests include successful transfer exact balances and cap preservation, successful real registry-derived issuance, unknown operation, matching/mismatching claimed actor, wrong cap holder with claimedActor absent, domain/party/argument mismatch, invocation capability, guard false, declared and undeclared guard/effect/inactive/supply-only reads, observed effects and missing observation/declaration, foreign state reads and effects, net debit/supply authority, revoke-then-use with invoke preserved, insufficient funds, unbalanced effects, mismatched supply, wrong-asset accounting, missing writes, repeated effect/supply aggregation and duplicate capability IDs. Every checker refusal stage has a successful sibling. Detailed expression ingress and lifecycle coverage is supplied by Foundation/Authority and Task4 Acceptance.

No source mutation measurements are claimed here; parent owns that runner and evidence.

## Native Fable coverage followup

Parent relayed native Fable ACCEPT WITH LIMITATIONS and requested stronger executed pins. Added eight comparisons, yielding 45/45 true. Mint and repeated supply successes pin all eight finite cells, all four domain/asset totals and the complete capability store. Every positive template fixture now has a four-capability provisioning check. Revocation pins store length, exact revoked debit tombstone and unchanged/live invoke capability. Added positive clock reads plus separately omitted currentTime and timestamp-observation declarations, foreign supply-domain refusal, declared foreign-domain observation success and cancelling foreign-domain deltas success under the explicit net-effect policy. No executable kernel changes. Standalone #eval remains below the marker, so parent replay projections remove it and use the central Audit driver.

Proof inventory followup: review/semantic-kernel/sprint4/proof-inventory.json maps all 36 manually named core theorems and 11 Examples/Acceptance theorems (47 total). It separates concrete kernel-computed execution statements from general preservation/authority statements and explicitly excludes compiler-generated declarations from this hand inventory; parent automatic imported audit remains authoritative for the full environment. Exact source hashes bind all entries. No missing approved core semantic endpoint found; intrinsic type contracts and administrative ledger separation are identified as structural properties rather than invented named theorems. Examples/Acceptance final freeze is now confirmed and inventory regenerated against those final hashes; regenerate after any later source change.

## Final native Grok coverage followup and source freeze

Strengthened transferExact to pin all eight finite cells and the complete capability store. Added three combined-refusal checks proving the observed precedence: false guard plus division-by-zero effect yields evaluation refusal; underfunded and unbalanced effects yield insufficientFunds; false guard plus undeclared state read yields guard refusal. Final TransitionTests has 48/48 passing comparisons and warning-free compilation. The execute docstring now explicitly records Args.check before invoke checking, template evaluation before guard/footprint checking, and that successful read/domain conditions do not establish refused-path confidentiality. Executable kernel behavior and all theorem statements are unchanged.

The separate authorized proof-inventory followup wrote review/semantic-kernel/sprint4/proof-inventory.json. All 47 named declarations were source-extracted with namespace tracking and matched to explicit scoped meanings. Examples2 and Acceptance9 are frozen by their owner. Generated declarations remain the parent imported audit's responsibility.

Final source hashes:
- lean/DefiKernel/Typed/Transition.lean: 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2
- lean/DefiKernel/Typed/TransitionTests.lean: e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc
- review/semantic-kernel/sprint4/proof-inventory.json: 5d456db821bacc8742f52bbe9013d78a3be63a79fbb04bbc2c503e0876b5fb23
