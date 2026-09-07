## 1. Planning audit and preserved baseline

- [x] 1.1 Freeze proposal, design, four specs and this checklist in a concrete commit; record source-context hashes and a scenario/task map in `review/semantic-kernel/sprint6/`; verify strict OpenSpec validation and every local link before review.
- [ ] 1.2 Obtain independent Fable and GPT-6 planning audits of that same candidate; save prompts, raw results, requested/reported identities and verdicts; verify neither required review is unavailable or unresolved before any implementation.
- [ ] 1.3 Resolve blocking planning findings in a revised candidate and refresh affected audits; save `planning/ADJUDICATION.md` and verify both passing verdicts cover final planning bytes without waiving a requirement.
- [ ] 1.4 Capture the clean implementation starting revision, tools and baseline hashes; run the existing full Lean build and composition/typed/legacy runtime and axiom drivers below; verify all pass and preserved original proof/corpus manifests resolve to actual files before new modules are added.

## 2. Branch model and conservative admission

- [ ] 2.1 Create `lean/DefiKernel/Parallel/Compatibility.lean` with closed left/right identities, invocation-only `Branch`, fixed branch/local-index boundaries and a finite `Footprint`; compile a positive invocation branch and a separate expected type-error control showing issue/revoke cannot inhabit the public branch input.
- [ ] 2.2 Implement per-invocation footprint resolution from actual registered templates/operation interfaces, fixed parties and trusted caller; verify concrete expected lists contain declared writes, delta targets, both-arm guard/delta/supply reads, declared reads, output cells and balance dependencies, without evaluating numeric expressions.
- [ ] 2.3 Aggregate the whole branch and implement symmetric write/write and write/read disjointness; verify funded same-domain independent pairs and common-read siblings pass while both conflict directions, zero-effect targets and unreachable conflicting suffixes reject.
- [ ] 2.4 Implement catalog-first, left-before-right, local-order admission errors and deterministic first conflict witnesses; verify multiple simultaneous errors choose the documented reason and every refusal leaves initial world/output/receipt inventories unchanged.
- [ ] 2.5 Prove accepted-analysis membership facts for all required reads, output cells and delta targets, and compatibility disjointness lemmas in the new module; verify the proof statements are generic over the existing finite identity types and do not assume invocation success.

## 3. Full executor dependency proofs

- [ ] 3.1 Create `Dependency.lean`; derive analyzed-region expression congruence using existing `Expr.eval_congr_of_resolved` and discharge its agreement premises for identical non-state inputs; verify both conditional arms, balance reads, rational arithmetic, observation errors and zero division are covered for complete Except results.
- [ ] 3.2 Lift dependency congruence to actual `Template.evaluate`, including target/reference resolution, guards, effects, supplies and all evaluation errors; verify equal evaluated receipt data follows from analyzed-region agreement rather than an unchecked evaluator-framing premise.
- [ ] 3.3 Prove actual evaluated effects vanish outside resolved delta targets; verify the lemma does not assume declared writes or `writesOK`, and instantiate a malformed undeclared-target fixture to demonstrate why the distinction matters.
- [ ] 3.4 Prove equivalence of the global sufficient-funds checks from target-region balance agreement and proof-carrying nonnegativity elsewhere; verify an insufficient-balance sibling and a nonzero untouched-cell sibling establish the implicit dependency scope.
- [ ] 3.5 Prove registered execution congruence for exact refusal and, on success, identical receipt effects plus agreement on the dependency region and framing outside writes; verify the proof follows real check precedence and includes failed accounting/write-footprint and evaluation paths.
- [ ] 3.6 Lift the dependency result through `Composition.executeStep` for invocations and selected snapshots with fixed local history; verify snapshot equality uses analyzed output reads and neither proof assumes whole-world equality or already-proved commutation.

## 4. Parallel execution and complete observations

- [ ] 4.1 Create `Execution.lean` with admission refusal versus executed-pair result types; call existing `Composition.run` separately from the common initial world using stable local boundaries; verify empty/empty, one-empty, and funded two-branch results.
- [ ] 4.2 Implement region-selective merge and construct nonnegativity by cases, retaining initial capabilities; verify the USD/share fixture has Alice USD7/Bob USD3/vault shares16/Alice shares4 with every other cell and complete store unchanged.
- [ ] 4.3 Preserve each branch's own first refusal and successful prefix while always executing its peer; verify immediate, middle and dual refusals, with an independently funded peer and exact reasons/indices.
- [ ] 4.4 Expose branch-qualified output snapshots and keep local histories isolated; verify equal numeric port IDs from distinct components retain distinct values, a shared fully qualified read-only key retains both branch labels, peer-only step-0 output lookup at local index 1 refuses despite a correct-unit funded peer value (with an equivalent-literal or own-history successful sibling), and own snapshots remain stable after later writes.
- [ ] 4.5 Define canonical branch and parallel observations with complete financial fields from design section 4 and an extensional equivalence relation; verify controls distinguish changes to each refusal/index/output/receipt/final-ledger field while tolerating only completion order and raw foreign-world event context.
- [ ] 4.6 Implement LR and RL reference evaluators using fresh real sequential runs of the second branch on the first final world, with original local boundaries and no cross-branch history; verify neither reference caches receipts or globally cancels on first-branch refusal.

## 5. Commutation and lifted preservation

- [ ] 5.1 Create `Commutation.lean`; prove branch observation congruence and final-region agreement by induction over the existing runner with stable local histories/boundaries; verify the statement covers first/middle refusal and state-dependent prefix effects.
- [ ] 5.2 Prove every successful branch effect is confined to its analyzed writes and the entire branch frames its starting ledger elsewhere, with fixed capability store; verify this establishes the premise required for sound region merge.
- [ ] 5.3 Prove admitted parallel observation equals actual LR and RL observations for all well-typed initial worlds, discharging cross-branch dependency premises with compatibility; verify no supplied equality/commutation oracle or success-only premise replaces the required refused behavior.
- [ ] 5.4 Derive singleton invocation commutation and empty-branch laws with exact branch-qualified observations; verify raw full event worlds are not equated and no arbitrary nested associativity claim is added.
- [ ] 5.5 Create `Preservation.lean`; lift exact per-domain/asset accounting using both real receipt supply sums and prove invocation/debit/supply authority under the fixed store; verify independent mint/burn fixtures and successful prefixes ending in refusal instantiate the results.
- [ ] 5.6 Prove every branch prefix and joined ledger is nonnegative and establish union-write locality and supported-predicate framing; verify concrete protected collateral and counterexamples to omitting support/disjointness.
- [ ] 5.7 Prove composition of two initialized supported ledger invariants from explicit individual preservation and peer-disjoint support; verify an instantiated pair and record every remaining contract/environment premise without circular assumptions.

## 6. Financial examples and imported audit

- [ ] 6.1 Create `Examples.lean` and `Tests.lean` with independently specified complete worlds/stores/receipts for the USD/share fixture and same-asset disjoint-party pairs; verify both serial references and parallel observations against those independent expected values.
- [ ] 6.2 Add nontrivial multi-invocation branches, state-dependent guard/effect/supply examples, independent supply changes and both local output consumers; verify exact amounts, receipt order, output units and complete branch observations, not merely equality among three implementations.
- [ ] 6.3 Add funded/authorized conflict negatives for both directions, hidden/inactive-arm reads, target balances, shared outputs, malformed suffixes, and live/revoked capability siblings; verify each intended failure is discriminated from missing funds or unrelated authority.
- [ ] 6.4 Add boundary-sensitive local-index, qualified-port and peer-only-history fixtures, immediate/middle/dual refusal fixtures, and identity/frame controls; verify changing branch order preserves local principal/time binding without treating time as a price.
- [ ] 6.5 Add `Audit.lean` with a nonempty unique named runtime inventory and `Verify.lean` with imported theorem/supplemental axiom coverage; import the new verification root from `lean/DefiKernel.lean` and verify full compilation, runtime pass and zero forbidden dependencies.
- [ ] 6.6 Save named proof statements, quantification, premises and limits in `proof-inventory.json` and map all 47 planned scenarios to actual proof/check IDs; verify the inventory distinguishes generic results, reference instances, counterexamples, bounded comparisons and imported generated declarations.

## 7. Source mutation and runner evidence

- [ ] 7.1 Add `scripts/check_parallel_mutations.py` with explicit repo/spec/out inputs, fresh local source projection, exact manifests and nonempty complete inventory checks, reusing established machinery only with explicit Parallel scope; verify an unchanged execution control compiles and all comparisons pass in a new external scratch directory.
- [ ] 7.2 Add actual source mutants for write/write bypass, hidden-expression/output/target dependency omission, and reverse conflict direction in `review/semantic-kernel/sprint6/mutation-spec.json`; verify each compiles and triggers its designated independent oracle, documenting composite collector omissions for redundant declared reads/writes and using a zero/cancelling undeclared target for its successful underlying-kernel control.
- [ ] 7.3 Add peer cancellation, prefix rollback, whole-world replacement and doubled-initial-balance mutants; verify exact branch outcomes and complete-world expected fixtures detect each while unrelated positives remain true.
- [ ] 7.4 Add local-history leakage/port misqualification, boundary-position misuse, dropped-peer-supply, stale capability store and incorrect state-dependent evaluation mutants; verify every required mutant changes actual implementation source and fails its designated runtime comparison.
- [ ] 7.5 Add `scripts/test_parallel_mutation_runner.py` actual CLI controls for empty/duplicate/unknown/partial inventories, malformed evidence, absent/nonunique/no-op edits, compile-only failure, surviving mutants, failed positives and invalid output locations; verify each fails or blocks for its intended cause beside a valid accepted sibling.
- [ ] 7.6 Freeze mutation inputs and run all 14 required semantic mutants and runner controls; save full logs, generated sources, expected false labels, protected positives, tool versions and hashes; verify no source drift, masked survivor or noncompiled case is counted as a detection.

## 8. Integrated acceptance and native implementation review

- [ ] 8.1 Commit frozen source and run the full new and existing Lean/runtime/axiom commands below plus existing typed/composition mutations, compiler controls, runner controls, axiom controls and corpus tests; save actual commands, exits and full logs and verify required checks pass without changing preserved files.
- [ ] 8.2 Finish the scenario map and proof/source/tool manifests with actual outcomes; verify every scenario has nonvacuous evidence, each counted proof belongs to the fresh import closure, and executed bytes match Git objects of the reviewed source candidate.
- [ ] 8.3 Obtain independent native Grok/Fable review of substantive compatibility/dependency proofs, execution/commutation and regression/evidence scopes; retain raw requests/responses and verify exact requested/reported identities and candidate hashes.
- [ ] 8.4 Resolve blocking findings and refresh affected validation/review on the revised candidate; save implementation `ADJUDICATION.md`, preserved dissent and scope limits; verify no required review or normative obligation remains open.

## 9. Roadmap, delivery and archive

- [ ] 9.1 Update roadmap/progress/tasks from accepted evidence; verify shared-state interleaving, atomic synchronization, broader associativity, claims/provenance and deployed fidelity remain open.
- [ ] 9.2 Run strict OpenSpec validation and editorial whitespace/local-link checks; verify all current referenced evidence exists without rewriting hash-bound raw bundles/logs.
- [ ] 9.3 Commit/push source and evidence to `semantic-kernel-pivot`; verify remote head equals intended local head and save delivery metadata with actual commit/source identities and explained worktree state.
- [ ] 9.4 Archive only `disjoint-parallel-composition` through OpenSpec, validate all four synchronized main specs, update archive links and deliver metadata; verify final remote head, all task states and a clean worktree.

Verification commands below are instructions, not run evidence. Planning artifacts
can be written and audited before task 1.3 passes. New implementation is gated.

From the repository root:

```sh
openspec validate disjoint-parallel-composition --strict --json --no-interactive
openspec status --change disjoint-parallel-composition --json
git diff --check
```

From `lean/`, at baseline omit the not-yet-created Parallel drivers; at final run all:

```sh
lake build
lake env lean DefiKernel/Parallel/Audit.lean
lake env lean DefiKernel/Parallel/Verify.lean
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Composition/Verify.lean
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Typed/Verify.lean
lake env lean DefiKernel/Audit.lean
lake env lean DefiKernel/ContractAudit.lean
lake env lean DefiKernel/VerifyAxioms.lean
```

For Python regression invocations, reuse the actual saved Sprint 5 command arrays
in `review/semantic-kernel/sprint5/{regression-runs.json,typed-mutations-run.json}`
and runner/mutation manifests with fresh output paths and current source manifests;
inspect each existing driver's `--help` before invocation. New mutation runner:
`python3 scripts/check_parallel_mutations.py --repo . --spec review/semantic-kernel/sprint6/mutation-spec.json --out /tmp/UNIQUE-NEW-DIRECTORY`.
Allocate that output directory path freshly before the call; the runner owns its
creation. Copy full accepted artifacts into the sprint evidence directory afterward.

Dependencies: sections 2→3 and 2→4; section 5 needs 3 and 4; fixtures grow alongside
their features and section 6 completes coverage. Section 7 targets actual completed
behavior. Sections 8–9 are final integration/review/delivery gates. A compile error
from a missing yet-planned declaration is development feedback, never a financial
negative or a counted semantic mutant.
