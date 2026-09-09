# FormalDeFi OpenSpec roadmap

The objective is a broadly reusable verification platform and financial libraries. This roadmap covers the entire remaining program, from proof recovery and evidence repairs through reusable interfaces, financial libraries, source fidelity, independent evaluation and publication.

**Roadmap status: complete planning coverage, implementation in progress.** The accepted program contains **37 sprints, 179 checklist tasks, 55 requirements, 102 scenarios and 339 original task mappings**. These are planning denominators, not completed-work counts.

This page is a navigation and execution-status overlay dated **2026-09-08 UTC**. The reviewed OpenSpec contract below retains its original bytes and unchecked boxes. Historical text saying “pending review” is superseded for acceptance status by the linked acceptance records; it must not be read as current implementation status.

## Authoritative plan and evidence

| Artifact | What it provides |
| --- | --- |
| [Sprint plan](changes/reusable-verification-platform-program/sprint-plan.md) | Every sprint’s outputs, claim limits, checks, stopping conditions and acceptance criteria |
| [179-task checklist](changes/reusable-verification-platform-program/tasks.md) | Executable work breakdown, including standing proof, mutation and delivery gates |
| [Machine-readable sprint index](changes/reusable-verification-platform-program/sprint-index.json) | All 37 IDs, hard and conditional dependencies, resource gates, entry/exit criteria and required terminals |
| [Dependency design](changes/reusable-verification-platform-program/design.md) | Dependency graph and architecture decisions |
| [Coverage](changes/reusable-verification-platform-program/coverage.md) | R01–R47 agenda coverage and package ownership |
| [Original task mapping](changes/reusable-verification-platform-program/legacy-task-disposition.json) | All 339 original task tuples, including split contributions and historical checked status |
| [Proof and environment matrix](changes/reusable-verification-platform-program/proof-obligation-dependency-matrix.json) | Financial properties, source-bound observations, negatives, certificate obligations, adapters and environments |
| [Reusable contracts](changes/reusable-verification-platform-program/contracts/README.md) | Kernel, arithmetic, adapter and evidence-packet boundaries |
| [Planning acceptance](../review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md) | Independent GPT-6 verdict and the two binding editorial interpretations |
| [Execution ledger](../review/semantic-kernel/program-execution-20260908/STATE.json) / [lane state](../review/semantic-kernel/strategy-audit-20260908/CURRENT.json) | Current accepted subsets, delivered commits, remaining findings and next actions |

## All 37 sprints

The dependency column lists hard predecessors. “Resource: P17” additionally requires substantive `P17.platform_reuse`; arithmetic-only reuse does not satisfy it. Conditional API dependencies remain explicit in the sprint index. “Open” is not a waiver, a completed task, or an unavailable-source disposition.

| Sprint and scope | Hard predecessors / resource gate | Dated execution status |
| --- | --- | --- |
| [P01 — M4 recovery r2 closeout](changes/reusable-verification-platform-program/sprint-plan.md#p01--m4-recovery-r2-closeout) | None | [Accepted and delivered](../review/semantic-kernel/program-execution-20260908/P01-ACCEPTANCE.md); bounded recovery only. Full M4 is P02. |
| [P02 — M4 remaining contracts, monitors, fixtures, mutations, integration](changes/reusable-verification-platform-program/sprint-plan.md#p02--remaining-m4-contracts-monitors-fixtures-mutations-integration) | P01 | Open: remaining M4 contracts, monitors, full fixtures and mutations. |
| [P03 — Official M5 active extension](changes/reusable-verification-platform-program/sprint-plan.md#p03--official-m5-active-extension) | P02 | Provisional planning only; official M5 waits for delivered M4. |
| [P04 — M6 atomic metatheory transfer](changes/reusable-verification-platform-program/sprint-plan.md#p04--m6-atomic-metatheory-transfer) | P02, P03 | Planned; M6 implementation waits for M4 and M5. |
| [P05 — Capability provenance and isolation](changes/reusable-verification-platform-program/sprint-plan.md#p05--capability-provenance-and-isolation) | None | [Foundation delivered](../review/semantic-kernel/program-execution-20260908/P05-FOUNDATION-ACCEPTANCE.md); isolation, full fixtures and mutants remain. |
| [P06 — Claims generic partial recovery](changes/reusable-verification-platform-program/sprint-plan.md#p06--claims-generic-partial-recovery) | None | Cancelled partial Claims work preserved; generic preservation recovery remains open. |
| [P07 — Claims full lifecycle, payment, non-erasure, fixtures, delivery](changes/reusable-verification-platform-program/sprint-plan.md#p07--claims-full-lifecycle) | P06 | Open; full Claims lifecycle and delivery follow accepted P06. |
| [P08 — Corpus classification and capture-derived-span repair](changes/reusable-verification-platform-program/sprint-plan.md#p08--corpus-captureclassificationspan-repair) | None | Open: classification and source-excerpt binding repairs. |
| [P09 — Corpus identities, 29 disputes, and development-manifest sub-delivery](changes/reusable-verification-platform-program/sprint-plan.md#p09--identities-29-disputes-development-manifest-sub-delivery) | P08 | Open: identities, 29 disputes and development-manifest delivery. |
| [P10 — Liquity challenge, dependencies, bounded collector, and whole-package 7.x/8.x join](changes/reusable-verification-platform-program/sprint-plan.md#p10--liquity-challenge-bounded-collector-whole-package-7x8x-join) | P08 | Open: challenge, collector and whole-package reconciliation. |
| [P11 — Historical H02/H12 scope links and like-for-like R versus R-intersect-W measurements](changes/reusable-verification-platform-program/sprint-plan.md#p11--h02h12-scope-and-like-for-like-measurements) | None | Open: H02/H12 claim-evidence links and comparable measurement scopes. |
| [P12 — Full historical occurrence and claim reconciliation](changes/reusable-verification-platform-program/sprint-plan.md#p12--full-occurrence-and-claim-reconciliation) | P11 | Open: full historical occurrence and claim reconciliation. |
| [P13 — Reporting candidate acceptance and malformed/schema/package/audit-root diagnostics](changes/reusable-verification-platform-program/sprint-plan.md#p13--reporting-candidate-and-diagnostics) | None | [Reporting candidate delivered](../review/semantic-kernel/program-execution-20260908/P13-CANDIDATE-ACCEPTANCE.md); R43/R44 diagnostics remain. |
| [P14 — Duplicate-capability theorem, isolated vault-liquidity regression, actor/effect/supply mutations, projection and wrong-world controls](changes/reusable-verification-platform-program/sprint-plan.md#p14--duplicate-capability-vault-liquidity-actoreffectsupply-projection-wrong-world) | None | Open: remaining operator, mutation and observation controls. |
| [P15 — Minimum reusable platform contracts](changes/reusable-verification-platform-program/sprint-plan.md#p15--minimum-reusable-contracts) | None | [Accepted and delivered](../review/semantic-kernel/program-execution-20260908/P15-ACCEPTANCE.md): minimum reusable contracts. |
| [P16 — Pinned Uniswap token0 execution, overflow-oracle repair, M09/F28 control-plan correction](changes/reusable-verification-platform-program/sprint-plan.md#p16--pinned-uniswap-token0-overflow-oracle-repair-m09f28-control-plan-correction) | P15 | [Planning](../review/semantic-kernel/program-execution-20260908/P16-PLANNING-ACCEPTANCE.md) and [proof/model/recorder subset](../review/semantic-kernel/program-execution-20260908/P16-PROOF-RECORDER-ACCEPTANCE.md) delivered; [source gate still requires focused R1/R2 repairs](../review/semantic-kernel/program-execution-20260908/p16-source-r4-review/REVIEW.md). Whole P16 is open. |
| [P17 — Contrasting vault source readiness and stateful reuse gate](changes/reusable-verification-platform-program/sprint-plan.md#p17--vault-source-readiness-and-reuse-gate) | P16 | [Immutable development source acquired](../review/semantic-kernel/program-execution-20260908/p17-source-acquisition/compile-source-closure.json) and [compilation smoke passed](../review/semantic-kernel/program-execution-20260908/p17-compiler-readiness/compile-smoke.json); [independent readiness check passed](../review/semantic-kernel/program-execution-20260908/p17-acquisition-readiness-review/REVIEW.md). Source-entry acceptance, model and platform reuse remain open. |
| [P18 — Bounded platform increment publication](changes/reusable-verification-platform-program/sprint-plan.md#p18--bounded-platform-increment-publication) | P16 | Open: early release requires accepted P16, independently reviewed packets and a versioned user example. |
| [P19 — Typed sequential certificates](changes/reusable-verification-platform-program/sprint-plan.md#p19--typed-sequential-certificates) | None | [Planning accepted and delivered](../review/semantic-kernel/program-execution-20260908/P19-PLANNING-ACCEPTANCE.md); certificate checker implementation remains open. |
| [P20 — Quantified representation correspondence and wider operator support](changes/reusable-verification-platform-program/sprint-plan.md#p20--quantified-representation-correspondence-and-wider-operators) | P19 | Open: quantified correspondence and wider operator support; required before qualified certificate delivery. |
| [P21 — Residual concentrated-liquidity library, token1/delta, TickMath, SwapMath, bitmap/factory, full fixtures/mutations, and tick traversal](changes/reusable-verification-platform-program/sprint-plan.md#p21--residual-concentrated-liquidity-library-and-tick-traversal) | P16; Resource: P17 | Open: residual planning gate, implementation and complete library campaigns; requires P17 platform reuse. |
| [P22 — Curve iteration, nonconvergence, and refusal](changes/reusable-verification-platform-program/sprint-plan.md#p22--curve-iteration-nonconvergence-refusal) | None; Resource: P17 | Planned: source-entry freeze, convergence/refusal model, controls and review. |
| [P23 — Liquity ordered redemption](changes/reusable-verification-platform-program/sprint-plan.md#p23--liquity-ordered-redemption) | None; Resource: P17 | Planned: pinned ordered redemption, financial property, controls and review. |
| [P24 — Morpho bad-debt loss allocation](changes/reusable-verification-platform-program/sprint-plan.md#p24--morpho-bad-debt-loss-allocation) | None; Resource: P17 | Planned: pinned bad-debt loss allocation, financial property, controls and review. |
| [P25 — Balancer vault, hooks, and transient accounting](changes/reusable-verification-platform-program/sprint-plan.md#p25--balancer-vault-hooks-transient-accounting) | None; Resource: P17 | Planned: pinned vault/hooks/transient accounting, controls and review. |
| [P26 — Async lifecycle, finality, replay, timeout, challenge, compensation](changes/reusable-verification-platform-program/sprint-plan.md#p26--async-lifecycle) | None; Resource: P17 | Planned: actual async lifecycle, finality, replay, timeout, challenge and compensation. |
| [P27 — Signed margin, funding, unsettled PnL, liquidation, bankruptcy](changes/reusable-verification-platform-program/sprint-plan.md#p27--signed-margin-funding-unsettled-pnl-liquidation-bankruptcy) | None; Resource: P17 | Planned: signed margin/funding/PnL/liquidation/bankruptcy and source-selected refusal. |
| [P28 — Conditional insurance and off-chain claims](changes/reusable-verification-platform-program/sprint-plan.md#p28--conditional-insurance-and-off-chain-claims) | None; Resource: P17 | Planned: authorized conditional claims and explicit oracle/custody/legal assumptions. |
| [P29 — Complete cross-domain workflow](changes/reusable-verification-platform-program/sprint-plan.md#p29--complete-cross-domain-workflow) | P26; Resource: P17 | Planned: complete cross-domain workflow with locked/in-flight/compensated accounting. |
| [P30 — Reusable pinned-source differential execution and selected source refinement](changes/reusable-verification-platform-program/sprint-plan.md#p30--differential-execution-and-selected-source-refinement) | P16 | Open: common differential execution and selected source-to-model refinement proofs. |
| [P31 — Runtime adapter contracts for Moriarty, Compact, ZKIR, and proof-carrying transactions](changes/reusable-verification-platform-program/sprint-plan.md#p31--moriarty-compact-zkir-pct-adapters) | P15 | Open: per-adapter readiness and implementation; unavailable interfaces stay blocked. |
| [P32 — Deployment and environment pins: EVM, Solana, Cosmos, Move/Sui, sovereign cross-chain, payment channels](changes/reusable-verification-platform-program/sprint-plan.md#p32--environment-pins-evm-solana-cosmos-movesui-sovereign-cross-chain-payment-channels) | None | Open: six environment records. P16 EVM evidence does not close the other environments. |
| [P33 — Freeze kernel, schema, and libraries; exposure-audited twelve-case replacement policy](changes/reusable-verification-platform-program/sprint-plan.md#p33--kernelschemalibrary-freeze-and-twelve-case-replacement-policy) | P18 | Planned: freeze evaluated identities and an exposure-audited replacement policy. |
| [P34 — Independent untouched evaluation and separated metrics](changes/reusable-verification-platform-program/sprint-plan.md#p34--independent-untouched-evaluation-and-separated-metrics) | P33, P32 | Planned: independent untouched evaluation after freeze; environment gaps keep it open. |
| [P35 — Atlas candidate acceptance and residual keyboard, search, badges, print, find, reduced motion, readability](changes/reusable-verification-platform-program/sprint-plan.md#p35--atlas-candidate-and-residual-interaction) | None | [Repair review](../review/semantic-kernel/program-execution-20260908/p35-repair-r2-review/REVIEW.md) resolves AR1–AR3; AR4 search geometry and AR5 direct 3D printing/restoration remain. Acceptance is open. |
| [P36 — Stable-schema scientific Atlas and repository graph](changes/reusable-verification-platform-program/sprint-plan.md#p36--scientific-atlas-and-graph-after-stable-schema) | P35 | Planned: accepted-schema scientific Atlas and updated graph after P35. |
| [P37 — Paper, reproducible external developer package, and verified delivery](changes/reusable-verification-platform-program/sprint-plan.md#p37--paper-external-developer-package-verified-delivery) | P04, P05, P07, P09, P10, P12, P13, P14, P17, P18, P20, P21, P22, P23, P24, P25, P27, P28, P29, P30, P31, P34, P36 | Open: final paper, reproducible developer package and verified full-program delivery. |

## Execution and release gates

Native Grok 4.6 authors substantive implementation; independent GPT-6 checks exact candidates. The standing schedule uses at most one substantive author and one checker. Root integrates accepted work and publishes to `semantic-kernel-pivot` with remote readback. Saved process handles do not establish current liveness.

The next implementation work is the Atlas repair batch and the two P16 source-consumer repairs. P16 source acceptance requires valid current invocation receipts, correct blocked outcomes, exact fixture coverage and actual Lean comparison truth. The accepted proof/model subset remains valid. An intact finite source run does not by itself repair a gate that can return false success.

The early release is **P18**, after accepted P16. It does not wait on the M4 remainder, certificates or runtime adapters. Its deliverables include evidence packets and a versioned external-user example; it must keep source refinement and whole-program completion open.

**P17 is the platform-reuse checkpoint before spending on wider financial families P21–P29.** It requires one engine executing token0 and a contrasting vault, a named shared financial contract or lemma, a named shared executor result used by both adapters, the token0 kernel bridge and measured case-two additions. Sharing arithmetic alone, or wrapping two separate engines, is insufficient.

Full M4 requires P02 after P01; official M5 follows delivered M4, and M6 follows M4/M5. P19 checker implementation is separate from P20 quantified representation correspondence and qualified certificate delivery. Codec correspondence does not establish deployed-source refinement.

Evaluation must freeze the evaluated kernel/schema/library identities and the replacement-case exposure policy before untouched scoring. A changed evaluated identity invalidates reuse of earlier untouched labels. Development cases remain development; no existing REPORT labels are silently treated as holdouts. EVM, Solana, Cosmos, Move/Sui, sovereign cross-chain and payment-channel execution obligations each require actual evidence or remain blocked.

## Full-program finish

P37 closes only when every terminal listed in `sprint-index.json` has `successful_exit`: `P04`, `P05`, `P07`, `P09`, `P10`, `P12`, `P13`, `P14`, `P17`, `P18`, `P20`, `P21`, `P22`, `P23`, `P24`, `P25`, `P27`, `P28`, `P29`, `P30`, `P31`, `P34`, `P36`. Their predecessor chains cover the remaining sprints. Rejected, missing, deferred and `blocked_unavailable` results are not successful exits.

The completed deliverable is a versioned verification platform with reusable financial libraries, an external-developer package that instantiates a library and executor interface, explicitly separated proof/execution/correspondence/refinement/assumption evidence, independent evaluation, a paper limited to demonstrated claims and verified GitHub delivery. P30 selected source refinement remains mandatory for full closure. A partial paper or the P18 early release does not close P37.

## Specification modules

- [certificates-adapters-evaluation-publication](changes/reusable-verification-platform-program/specs/certificates-adapters-evaluation-publication/spec.md)
- [corpus-historical-honest-reporting](changes/reusable-verification-platform-program/specs/corpus-historical-honest-reporting/spec.md)
- [minimum-reusable-contracts](changes/reusable-verification-platform-program/specs/minimum-reusable-contracts/spec.md)
- [remaining-metatheory-lifecycle](changes/reusable-verification-platform-program/specs/remaining-metatheory-lifecycle/spec.md)
- [reusable-platform-program](changes/reusable-verification-platform-program/specs/reusable-platform-program/spec.md)
- [source-bound-library-families](changes/reusable-verification-platform-program/specs/source-bound-library-families/spec.md)
