# DeFiFormal migration roadmap

Updated 2026-09-07 UTC after Sprint 5. Branch: `semantic-kernel-pivot`.
Sprint 5 source candidate: `28ba18c446f72084ff11b4d125dccf93bf8f4162`.

The remaining objective is conditional preservation of financial properties
under composition, backed by faithful protocol models. Sprints 1–5 delivered the
pilot, trusted operation contracts, provisional corpus reconstruction, typed
execution/capabilities, and conditional sequential preservation. Checked boxes
record accepted work; unchecked boxes remain open. Neither implies deployed fidelity.

Sources: [approved migration design](docs/superpowers/specs/2026-09-06-semantic-kernel-design.md),
[original supplied plan](docs/research/2026-09-06-defi-source-plan.md),
[progress ledger](docs/research/semantic-kernel-progress.md), and
[Sprint 4 adjudication](review/semantic-kernel/sprint4/ADJUDICATION.md).
Historical uppercase `ROADMAP.md` files retain their original evidence and scope.
This root roadmap is the current consolidated agenda.

## 1. Sprint 5: typed interfaces and sequential composition

Accepted with limitations: [OpenSpec change](openspec/changes/typed-interfaces-sequential-composition/proposal.md),
[design](openspec/changes/typed-interfaces-sequential-composition/design.md),
and [47 implementation tasks](openspec/changes/typed-interfaces-sequential-composition/tasks.md).
Sequential execution retains the successful prefix and stops at the first refusal.
The [adjudication](review/semantic-kernel/sprint5/ADJUDICATION.md),
[scenario coverage](review/semantic-kernel/sprint5/coverage.md), and
[proof inventory](review/semantic-kernel/sprint5/proof-inventory.json) record the
accepted scope: 93 runtime comparisons, 12 detected source mutants, and 70 named
theorems. Both required native Grok/Fable reviews accepted with limitations.

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

## 2. Remaining composition and metatheory

- [ ] Implement disjoint parallel composition.
- [ ] Implement shared-state interleaving with explicit interference conditions.
- [ ] Implement atomic synchronization, including failure and transient-settlement semantics.
- [ ] Generalize the useful results in `Interface.lean` and `Nary.lean` into the operational model.
- [ ] Prove behavioral associativity: regrouping compatible components preserves behavior.
- [ ] Prove assume-guarantee composition with initialization and causal or inductive premises, not circular assumptions.
- [ ] Define observational equivalence and prove conservative extension: unrelated additions preserve existing behavior.
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

## Acceptance process for each implementation sprint

GPT-6 implements through the stock Codex harness. Lean is the mathematical
authority. Use meaningful negative and mutation checks, independent native Grok
and Fable review, saved evidence bound to exact source/tool identities, and a
verified branch push. Do not use Foreman. Preserve prior proofs, negative results,
and corpus source identities. Keep proofs, bounded execution, measurements,
refutations, and unchecked assumptions distinct.
