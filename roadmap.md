# DeFiFormal migration roadmap

Updated 2026-09-07 UTC: Sprint 7 delivered and archived; Sprint 8 delivered and archived; Sprint 9 source and evidence accepted; branch delivery and archival in progress. Sprint 10 OpenSpec preparation is complete.
Branch: `semantic-kernel-pivot`. Sprint 8 archive delivery: `9501f0a4`.

The remaining objective is conditional preservation of financial properties
under composition, backed by faithful protocol models. Sprints 1–6 delivered the
pilot, trusted operation contracts, provisional corpus reconstruction, typed
execution/capabilities, conditional sequential preservation and disjoint parallel
composition. Checked boxes
record accepted work; unchecked boxes remain open. Neither implies deployed fidelity.

Sources: [approved migration design](docs/superpowers/specs/2026-09-06-semantic-kernel-design.md),
[original supplied plan](docs/research/2026-09-06-defi-source-plan.md),
[progress ledger](docs/research/semantic-kernel-progress.md), and
[Sprint 4 adjudication](review/semantic-kernel/sprint4/ADJUDICATION.md).
Historical uppercase `ROADMAP.md` files retain their original evidence and scope.
This root roadmap is the current consolidated agenda.

## 1. Sprint 5: typed interfaces and sequential composition

Accepted with limitations: [OpenSpec change](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/proposal.md),
[design](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/design.md),
and [47 implementation tasks](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/tasks.md).
Sequential execution retains the successful prefix and stops at the first refusal.
The [adjudication](review/semantic-kernel/sprint5/ADJUDICATION.md),
[scenario coverage](review/semantic-kernel/sprint5/coverage.md), and
[proof inventory](review/semantic-kernel/sprint5/proof-inventory.json) record the
accepted scope: 93 runtime comparisons, 12 detected source mutants, and 70 named
theorems. Both required native Grok/Fable reviews accepted with limitations.
[Delivery verification](review/semantic-kernel/sprint5/delivery.json) records the
source/evidence push at `5fb0929`; the OpenSpec change is archived and its four main
specifications are synchronized.

- [x] Define component interfaces: typed ports, private/shared state, inputs, outputs, assumptions, and guarantees.
- [x] Define initialization, execution traces, and observable success/refusal behavior.
- [x] Implement sequential composition with explicit state and capability propagation.
- [x] Lift accounting, nonnegativity, authority, and locality results from individual transitions to sequences.
- [x] Prove a frame theorem for predicates that depend only on protected state.
- [x] Add composed reference workflows and mutations covering ordering, refusal propagation, unauthorized interference, and revoked capabilities.

The frame theorem concerns ledger predicates with explicit support and disjoint
writes. Component locality is conditional on denied write access; general private
noninterference is not claimed. Initialization and contract results retain explicit
local/boundary premises, and nonnegativity follows from proof-carrying states.

## 2. Sprint 6: disjoint parallel composition

The [OpenSpec plan](openspec/changes/archive/2026-09-07-disjoint-parallel-composition/design.md)
and [48-task checklist](openspec/changes/archive/2026-09-07-disjoint-parallel-composition/tasks.md)
are implemented and independently reviewed. Source candidate: `fae07ca`.
Both native Grok and Fable audits accepted the Lean implementation and final
evidence with limitations. [Adjudication and review identities](review/semantic-kernel/sprint6/implementation/ADJUDICATION.md)
record the exact reviewed inputs. The accepted source/evidence push
`26bb17d` is verified on `semantic-kernel-pivot`; all 17 requirements were
synchronized to four main specs and the approved change was archived.
[Delivery](review/semantic-kernel/sprint6/delivery.json) and
[archive action](review/semantic-kernel/sprint6/archive-action.json) preserve the records.

Acceptance passes 131 runtime comparisons, 388 imported theorem and 419
supplemental axiom checks with zero forbidden dependencies, all 14 Parallel
mutations, all 45 Parallel runner controls, and all seven historical Python
regression suites. The 126 explicit theorems comprise 88 generic results,
35 reference instances and three counterexamples; generated theorem counts
are separate. A clean repository-package rebuild and frozen administrative
compiler controls also pass. [Coverage](review/semantic-kernel/sprint6/coverage.md)
and [proof inventory](review/semantic-kernel/sprint6/proof-inventory.json) record
all 47 scenarios and their precise evidence classes.

- [x] Pass both planning audits on the same candidate.
- [x] Implement conservative concrete compatibility and independent branch execution.
- [x] Prove full executor dependency, exact refusal framing and both actual serial-order correspondences.
- [x] Prove joined accounting, authority, nonnegativity, supported frames and conditional initialized invariants.
- [x] Complete financial fixtures, real mutations, regressions and native Grok/Fable implementation review.
- [x] Deliver the accepted branch and archive the OpenSpec change.

## Sprint 7: shared-state interleaving

Accepted with limitations at source `bea105ec`: [OpenSpec proposal](openspec/changes/archive/2026-09-07-shared-state-interleaving/proposal.md),
[design](openspec/changes/archive/2026-09-07-shared-state-interleaving/design.md),
[37 tasks](openspec/changes/archive/2026-09-07-shared-state-interleaving/tasks.md), and
[wiki record](wiki-llm/sprint-7-shared-state-interleaving.md).
Both native Grok and Fable accepted the Lean implementation and final proof/evidence
supplement. [Adjudication](review/semantic-kernel/sprint7/implementation/ADJUDICATION.md)
records exact identities, adopted corollaries and remaining limits.

All 116 runtime comparisons,14 production mutations,52 runner controls, nine
historical Python suites and12 final Lean commands pass. Imported audit checks262
theorems and271 supplemental declarations with zero forbidden dependencies. The127
explicit theorems comprise107 generic results,15 instances, three counterexample
constructions and two counterexample corollaries;135 others are generated.
[Final coverage](review/semantic-kernel/sprint7/coverage-final.md) maps all 43 scenarios.
Delivery and archive are verified through checkpoint `80c56c48`.

- [x] Pass the frozen OpenSpec planning review gate and current baseline.
- [x] Implement shared execution, schedules and exact observations.
- [x] Prove prefix preservation, explicit interference composition and disjoint recovery.
- [x] Complete financial examples, production mutations and full regressions.
- [x] Obtain native Grok/Fable result audits, deliver the branch and archive OpenSpec.

## Sprint 8: atomic synchronization

The [OpenSpec proposal](openspec/changes/archive/2026-09-07-atomic-synchronization/proposal.md),
[design](openspec/changes/archive/2026-09-07-atomic-synchronization/design.md) and
[40 tasks](openspec/changes/archive/2026-09-07-atomic-synchronization/tasks.md) cover four capabilities,
16 requirements and49 scenarios. The [wiki decision record](wiki-llm/sprint-8-atomic-synchronization.md)
explains exact rollback, separate committed observations and receipt-derived typed
transient clearing. Strict plan validation and author consistency checks pass;
independent GPT-6 and native Fable planning reviews pass on `7a73b2d`. The accepted baseline and dependency delivery passed. Revised implementation candidate `a52fb748` passes135 financial comparisons,357 theorem/496 supplemental axiom checks with zero forbidden dependencies,18 compiling production mutants and65 actual CLI controls. The initial audit-report protocol defect is corrected with its failed attempt preserved. All11 legacy suites have verified relevant dependency equivalence to this revision. Both final native Grok and Opus source/evidence reviews accept with limitations at `99e2e2c`; final65 controls are r4 with the corrected log-path harness. All40 tasks and49 scenarios are complete. Source/evidence push `2c038094` and archive push `9501f0a4` are verified.

The user authorized continued execution of all remaining packages while AFK;
[the execution agenda](wiki-llm/autonomous-execution-agenda.md) preserves dependencies,
review gates and stock Codex execution. The harness goal last reported `usageLimited`; work resumed manually under the user’s authorization. Proposed future work is not accepted
merely because it is scheduled.

## Sprint 9: sequential congruence and configuration preservation

Native Grok and Fable5.1 medium accepted source `eec499d6` and its completed
evidence with limitations. [Adjudication](review/semantic-kernel/sprint9/ADJUDICATION.md)
and [evidence](review/semantic-kernel/sprint9/EVIDENCE.md) record148 runtime
comparisons,14 detected mutations,65 CLI controls and109 explicit theorems.
All16 fresh Lean integration commands passed;13 legacy suites retain their
actual c880 execution identity through checked dependency equivalence.
Delivery and archive records are attached separately when verified.

The equivalence/extension milestone covers fixed identity types, explicit
configuration agreement and fixed sequential contexts. Regrouping sequential
steps preserves the full cursor; this does not establish arbitrary parallel
regrouping, causal assume-guarantee rules or capability provenance. Those broader
items remain open below.

## Remaining composition and metatheory

- [x] Implement disjoint parallel composition.
- [x] Implement shared-state interleaving with explicit interference conditions.
- [x] Implement atomic synchronization, including failure and transient-settlement semantics.
- [ ] Generalize the useful results in `Interface.lean` and `Nary.lean` into the operational model.
- [ ] Prove behavioral associativity: regrouping compatible components preserves behavior.
- [ ] Prove assume-guarantee composition with initialization and causal or inductive premises, not circular assumptions.
- [x] Define observational equivalence and prove conservative extension: unrelated additions preserve existing behavior.
- [ ] Establish capability provenance and component isolation where required, beyond the current trusted-store assumption.

## 3. Claims, liabilities, and asynchronous behavior

- [ ] Implement actual claims with debtor, creditor, asset/payoff, conditions, due time, and status.
- [ ] Implement creation, transfer, modification, discharge, and default.
- [ ] Prove that liabilities cannot disappear without an authorized lifecycle transition.
- [ ] Add repayment semantics; the current debt-erasure regression only rejects an invalid borrowing proposal.
- [ ] Implement message lifecycles, finality conditions, replay protection, timeouts, challenges, and compensation for asynchronous workflows.
- [ ] Represent oracle, custody, legal, sequencing, and finality assumptions explicitly.

## 4. Corpus and provenance

- [ ] Complete organization → product → version → deployment identities for the 75 candidates reconstructed from 72 historical rows.
- [ ] Resolve the 29 annotation disagreements using rules applicable to future cases.
- [ ] Resolve the separate Liquity V1 liquidation source challenge.
- [ ] Complete remaining product splits, pinned source references, dependency relationships, and ambiguity/residue records.
- [ ] Recover or replace unresolved references from the supplied proposal.
- [ ] Establish separate development and untouched-evaluation manifests. The current 75 candidates remain development cases.

## 5. Certificates and verification infrastructure

- [ ] Define a serialized module/transition format with interfaces, assumptions, invariants, observations, and source mappings.
- [ ] Implement a real certificate checker that recomputes judgments rather than accepting supplied labels.
- [ ] Check typing, footprints, authority, accounting, composition compatibility, library proof instantiation, and outstanding assumptions.
- [ ] Establish correspondence between serialized/executable representations and Lean semantics; do the same for any Quint abstraction introduced.
- [ ] Extend audit coverage to explicit package manifests and declared audit roots.
- [ ] Expand mutation coverage beyond Sprint 5’s 12 sequential mutants: effect application, capability allocation, structural catalog checks, and future composition operators.

## 6. Financial libraries still to port

- [ ] Machine arithmetic: widths, overflow, rounding direction, and fees.
- [ ] Uniswap-style concentrated-liquidity arithmetic and tick traversal.
- [ ] Curve-style iterative invariant calculations and failure behavior.
- [ ] Liquity-style ordered redemption.
- [ ] Morpho-style bad-debt realization and loss allocation.
- [ ] Balancer-style shared vault accounting, hooks, and transient settlement.
- [ ] A complete cross-domain financial workflow.
- [ ] Margin, funding, unsettled profit, liquidation, and bankruptcy handling.
- [ ] External conditional claims, including insurance or tokenized off-chain obligations.

## 7. Protocol fidelity and runtime adapters

- [ ] Pin concrete implementations, versions, deployments, and relevant execution environments.
- [ ] Run identical generated sequences against implementations and models; compare successful and refused behavior.
- [ ] Detect characteristic mutations in rounding, fees, ordering, losses, authority, oracles, and delayed settlement.
- [ ] Prove selected concrete implementation-to-model refinements.
- [ ] Add chain/runtime adapters through verified interfaces. Moriarty, Compact, ZKIR, and proof-carrying transaction integration remain later adapter work.

## 8. Evaluation, research claims, and publication

- [ ] Reconcile remaining paper and ledger claims: Q/Σ, four primitives, semantic minimality, Delta terminology, lattice claims, and exhaustive-result scope.
- [ ] Audit the correspondence between general structural theorems and the concrete historical instances.
- [ ] Freeze the kernel before evaluating untouched cases.
- [ ] Audit the proposed twelve evaluation candidates for prior design use; replace contaminated cases where necessary.
- [ ] Evaluate across the planned execution environments.
- [ ] Report schema coverage, behavioral coverage, library reuse, new kernel concepts, external assumptions, and verification effort separately.
- [ ] Rewrite the paper around demonstrated results and their limits.
- [ ] Update the ontology visualization and repository graph after the schema stabilizes.

## 9. Lower-priority review follow-ups

- [ ] Improve malformed-input diagnostics, standalone schema constraints, and package directory inventory checks.
- [ ] Add explicit current-module-exclusion and broader audit-root fixtures.
- [ ] Add a general duplicate-capability-list theorem and an isolated vault-liquidity regression.
- [ ] Extend individual actor/effect/supply comparison mutations in the older contract wrapper.

- [ ] Strengthen mutation projection guards for attributed declarations/macros/notation/deriving and add separated wrong-world oracles; current concrete Sprint 7 sources are accepted with these recorded limits.

## Acceptance process for each implementation sprint

GPT-6 implements through the stock Codex harness. Lean is the mathematical
authority. Use meaningful negative and mutation checks, independent native Grok
and Fable review, saved evidence bound to exact source/tool identities, and a
verified branch push. Do not use Foreman. Preserve prior proofs, negative results,
and corpus source identities. Keep proofs, bounded execution, measurements,
refutations, and unchecked assumptions distinct.

Reviewer policy update (2026-09-07): the user replaced Fable with native Opus for
new reviews. Historical Fable verdicts retain their original identities. Future
OpenSpec gates use nonauthor GPT-6 plus Opus; implementation/evidence gates use
Grok plus Opus. See [working instructions](AGENTS.md).
