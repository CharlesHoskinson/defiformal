# Coverage map

This program change is planning only. Original OpenSpec task IDs stay discoverable by path and are not relabelled delivered.

## Roadmap R01–R47

| ID | Roadmap text (abbrev.) | Sprint | Original contract |
| --- | --- | --- | --- |
| R01 | Generalize Interface/Nary; tree regrouping remains M4 | P01, P02 | `openspec/changes/operational-tree-regrouping/` tasks 4.1–7.5 |
| R02 | Behavioral associativity | P01, P02 | same, especially 3.4 and 4.3–4.5 |
| R03 | Capability provenance and isolation | P05 | `openspec/changes/capability-provenance-isolation/` 1.1–6.7 |
| R04 | Actual claims with parties, payoff, due, status | P06, P07 | `openspec/changes/claims-liability-lifecycle/` 2.1–2.5 |
| R05 | Creation, transfer, modification, discharge, default | P07 | claims 2.3–2.4, 3.2 |
| R06 | Liabilities cannot disappear without authorized transition | P06, P07 | claims 4.3–4.4 |
| R07 | Repayment semantics | P06, P07 | claims 3.3, 4.2, 4.5 |
| R08 | Async message lifecycle, finality, replay, timeout, challenge, compensation | P26 | this program; no accepted prior library change |
| R09 | Oracle, custody, legal, sequencing, finality assumptions | P26, P28 | this program |
| R10 | 75 identities from 72 rows | P09 | corpus 3.1 |
| R11 | 29 annotation disagreements | P09, P10 | corpus 5.1–5.3 (P09); 5.5 split (P09 29 facets, P10 separate challenge) |
| R12 | Liquity V1 liquidation source challenge | P10 | corpus 5.4 |
| R13 | Splits, pins, dependencies, ambiguity/residue | P08, P09, P10 | corpus 2.3, 3.2–3.3, 4.1 |
| R14 | Recover or replace unresolved proposal references | P10 | corpus 2.1–2.2 |
| R15 | Separate development and untouched-evaluation manifests | P09, P33 | corpus 6.1–6.3 |
| R16 | Serialized module/transition format | P19 | unaccepted `serialized-kernel-certificates` 2.1–2.6 |
| R17 | Recomputing certificate checker | P19 | certificates 3.1–4.4 |
| R18 | Typing, footprints, authority, accounting, composition, library instantiation, assumptions | P19, P20 | P19: certificates 3–4 typing/footprints/authority/accounting/sequential run. P20: compatibility and library instantiation. `roadmap_ids` means contribution; P19 does not authorize early R18 closure. |
| R19 | Representation correspondence, including Quint if introduced | P20 | certificates 2.4, 5.1–5.2 |
| R20 | Package manifests and audit roots | P13, P19 | honest-gate residuals; certificates 6.4, 8.2 |
| R21 | Mutation coverage beyond Sprint 5’s 12 | P14, P19 | R46/R47 plus certificate mutants |
| R22 | Uniswap concentrated-liquidity arithmetic and tick traversal | P16, P21 | unaccepted `concentrated-liquidity-library`; P16 narrow token0 plus required sum-overflow; P21 TickMath, SwapMath, token1/delta, bitmap/liquidity/factory, 45-fixture/M01–M12 campaigns, and traversal |
| R23 | Curve iteration and failure | P22 | this program; pin not established |
| R24 | Liquity ordered redemption | P23 | this program; separate from R12 |
| R25 | Morpho bad-debt loss allocation | P24 | this program; pin not established |
| R26 | Balancer shared vault, hooks, transient | P25 | this program; pin not established |
| R27 | Complete cross-domain workflow | P29 | this program |
| R28 | Margin, funding, unsettled profit, liquidation, bankruptcy | P27 | this program; pin not established |
| R29 | External conditional claims | P28 | this program; pin not established |
| R30 | Pin implementations, versions, deployments, environments | P16, P32 | Uniswap pin known; other environments readiness-gated |
| R31 | Identical sequences against implementations and models | P16, P30 | token0 matrix then reusable harness |
| R32 | Characteristic mutations | P16, P21, P30, P14 | P16 overflow mutants and M09/F28 control-plan correction; P21 compiled M09 with repaired per-mutant controls |
| R33 | Selected implementation-to-model refinements | P30 | required before P37 closure |
| R34 | Runtime adapters; Moriarty, Compact, ZKIR, PCT | P31 | readiness plus implementation or `blocked_unavailable` |
| R35 | Reconcile Q/Σ, four primitives, minimality, Delta, lattice, exhaustive scope | P11, P12 | `historical-claim-reconciliation` 2.3–2.6 |
| R36 | Structural theorems versus historical instances | P11, P12 | historical 3.1–3.7 |
| R37 | Freeze kernel before untouched cases | P33 | this program |
| R38 | Audit twelve evaluation candidates; replace contaminated | P33 | exposure ledger; do not read held payloads |
| R39 | Evaluate across planned execution environments | P32, P34 | EVM, Solana, Cosmos, Move/Sui, sovereign, payment-channel |
| R40 | Separated coverage, reuse, concepts, assumptions, effort | P34 | this program |
| R41 | Rewrite paper around demonstrated results | P37 | this program |
| R42 | Ontology visualization and repository graph | P35, P36 | `design-atlas-visualization` residuals plus scientific refresh |
| R43 | Malformed-input diagnostics, schema constraints, package inventory | P13 | new work after completed honest-gate baseline |
| R44 | Current-module-exclusion and broader audit-root fixtures | P13 | this program |
| R45 | Duplicate-capability-list theorem and isolated vault-liquidity regression | P14 | this program |
| R46 | Actor/effect/supply comparison mutations | P14 | older contract wrapper |
| R47 | Projection guards and wrong-world oracles | P14 | recorded Sprint 7 limits |

M5 and M6 have no dedicated unchecked R-id because active extension was annotated inside a checked Sprint 9 box. CURRENT.json still lists those lanes open, including M6. They are `P03` and `P04`. Do not remove M6.

Complete original-task coverage is `legacy-task-disposition.json` (339 rows). Split rows carry `contributions` and `whole_task_closure=all_contributions`. Named library proofs are `proof-obligation-dependency-matrix.json`. Hash bindings are copied from CURRENT.json `candidate.sha256` fields. This revision is pending independent GPT-6 review and does not set a review gate accepted.

## CURRENT.json lanes

| Lane | Phase at planning | Sprints |
| --- | --- | --- |
| M3 | delivered | historical Sprint 11 baseline |
| M4 | review_open | P01, P02 |
| M5 | provisional_only | P03 |
| M6 | planned_not_started | P04 |
| capability | review_open | P05 |
| claims | partial_cancelled | P06, P07 |
| corpus | repair_required | P08, P09, P10; 6.1 sub-delivery then 7.x/8.x join |
| historical | repair_required | P11, P12 |
| certificates | review_open, no official plan acceptance | P19, P20 |
| liquidity | repair_required, pin ready | P16, P21 |
| atlas | review_open | P35, P36 |
| reporting_gate | review_open | P13, P14 |
| async | future_open | P26, P29 |
| remaining_libraries | future_open | P17, P22, P23, P24, P25, P27, P28, P29 |
| fidelity_adapters | future_open | P15, P16, P17, P18, P30, P31, P32 |
| untouched_evaluation | future_open | P32, P33, P34 |
| publication | future_open | P18, P36, P37 |

## Spec requirement coverage

Counts are derived from `### Requirement:` and `#### Scenario:` headings in `specs/*/spec.md` after revision `planning-repair-r2-20260908`.

| Capability | Requirements | Scenarios |
| --- | --- | --- |
| reusable-platform-program | 12 | 19 |
| minimum-reusable-contracts | 7 | 12 |
| remaining-metatheory-lifecycle | 6 | 9 |
| corpus-historical-honest-reporting | 7 | 16 |
| source-bound-library-families | 13 | 23 |
| certificates-adapters-evaluation-publication | 10 | 23 |
| **total** | **55** | **102** |

Every sprint in `sprint-index.json` has `id`, `title`, `dependencies`, `legacy_mapping`, `change`, `path`, `entry`, and `exit`. Machine fields also distinguish `P17.platform_reuse` from `arithmetic_reuse`.

## Original task-ID discoverability

| Package | Path | How this program cites it |
| --- | --- | --- |
| operational-tree-regrouping | `openspec/changes/operational-tree-regrouping/tasks.md` | See `legacy-task-disposition.json`. P01 rebinds 1.1–1.4, carries foundation proofs for 2.x/3.x without closing them, reviews 4.1–4.4/4.6 and the 4.5 comparator. P02 owns F01–F20 before 2.x/3.x close, 4.5 ninety-schedule residual, and 5.1–7.5. |
| operational-active-extension | `openspec/changes/operational-active-extension/tasks.md` | P03 uses 1.1–5.7 after official refresh |
| atomic-metatheory-transfer | `openspec/changes/atomic-metatheory-transfer/tasks.md` | P04 uses 1.1–5.7 after M4/M5 |
| capability-provenance-isolation | `openspec/changes/capability-provenance-isolation/tasks.md` | P05 uses 1.1–6.7 |
| claims-liability-lifecycle | `openspec/changes/claims-liability-lifecycle/tasks.md` | P06 inspects 4.x partials; P07 uses 2.1–5.8 |
| corpus-provenance-adjudication | `openspec/changes/corpus-provenance-adjudication/tasks.md` | P08: 1.x rebind and 2.3 repair. P09: 3.1–3.2, 5.1–5.3, P09 5.5 facet contribution, 6.1–6.3 with 6.1 named sub-delivery. P10: 2.1–2.2, 2.4 (after P09 6.1, original bounded collector), 3.3, 4.1–4.3, 5.4, P10 5.5 challenge contribution. Original 5.5 and 7.1–8.3 are P09+P10 contributions; 7.x/8.x join on P10 without a P09 hard edge and hold complete 169-item accounting. |
| historical-claim-reconciliation | `openspec/changes/historical-claim-reconciliation/tasks.md` | P11 repairs; P12 uses 2.1–5.6 as `mixed_behavior` (proof 3.1–3.7 plus data/CLI 2.x/4.x/5.x) |
| honest-gate-failure | `openspec/changes/honest-gate-failure/tasks.md` | 1.1–7.4 remain completed; P13 is new candidate plus R43/R44 |
| design-atlas-visualization | `openspec/changes/design-atlas-visualization/tasks.md` | Historical checked boxes are not current acceptance. P35 rebinds 2.2/7.5/7.6/sync and completes 7.4/8.2/8.3/8.4 on Flat/3D depth/family layouts. |
| serialized-kernel-certificates | sibling worktree, unaccepted | P19/P20 planning input |
| concentrated-liquidity-library | sibling worktree, unaccepted | P16/P21 planning input. P16: token0 next-price plus required sum-overflow, token0 production mutants, and M09/F28 control-plan correction. P21: TickMath, SwapMath, token1/delta, bitmap/liquidity/factory, 45-fixture/M01–M12 including compiled M09 with repaired controls, traversal. Original 1.2 closes only after both accepted planning-slice reviews. Mixed 4.1/6.x/7.x close only with every contribution. |

## DAG consistency checks

- Acyclic: M4 chain, Claims, corpus, historical, certificates, token0→vault/increment/CL/refinement, async→cross-domain, freeze→eval, Atlas residual→scientific, increment+refinement+eval+Atlas→paper.
- Resource gates `P21`–`P29` are not extra hard edges except `P16→P21` and `P26→P29`. Those gates require `P17.platform_reuse`, not arithmetic-only reuse.
- Corpus 6.1 sub-delivery and 7.x/8.x join are conditional, not a `P09→P10` hard edge.
- `P05`, `P08`, `P11`, `P13`, `P14`, `P15`, `P19` have empty hard predecessors.
- `P37` cannot close without `P30` (selected refinement).
- No fabricated calendar or token estimates.

## Strategy rules encoded

- One coherent item can close first (`P01` default; reporting or capability may close if independently ready).
- Source readiness independent of M4 (`P08`, `P16` pin/oracle repair).
- No whole-backlog, full-M4, or certificate prerequisite to first library experiment.
- First actual pinned Uniswap operation, then contrasting stateful vault; no reviewed vault pin yet.
- Arithmetic-only reuse may be published from P16/P18 in `arithmetic_reuse`. `P17.platform_reuse` requires one common harness engine executing both cases, a named shared financial lemma/contract, a named shared executor result, the token0 kernel bridge, both adapters, and a measured case-two inventory. Composition integration, if claimed, requires a meaningful two-operation preservation instance; narrow noncomposing interface/library reuse remains valid. No P30 dependency. Local adapters allowed; no fabricated composition.
- Split original tasks record named contributions; whole-task closure requires every contribution. A partial MUST NOT mark the original ID done.
- Wider families resource-gated by measured reuse.
- M4→M5→M6 true dependencies.
- First increment may be model-proved with refinement open; `P30` still required before full-program closure.
- Codec cannot discharge source refinement.
- External authenticity/truth/runtime assumptions remain explicit.
- Blocked obligations cannot silently count completed.
