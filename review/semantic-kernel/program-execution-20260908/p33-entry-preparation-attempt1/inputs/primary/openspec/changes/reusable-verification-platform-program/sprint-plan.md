# Reusable verification platform — sprint plan

Planning only. Native Grok 4.6 author; independent GPT-6 checker. No Foreman. These files do not themselves execute sprints. Revision `planning-repair-r2-20260908` is pending independent GPT-6 review and does not set a review gate accepted. User authorization to execute after that acceptance is recorded separately at `review/semantic-kernel/program-execution-20260908/STATE.json`; do not re-ask. Frozen r1 archive `f4162b193aa0ad2b0884c93652cc6bb4507f443ee96318d96c687199f13f35a2` is not rewritten.

Canonical artifacts in this change: [design DAG](design.md), [tasks](tasks.md), [sprint-index](sprint-index.json), [coverage](coverage.md), [proof matrix](proof-obligation-dependency-matrix.json). Machine-readable fields live in `sprint-index.json`. Original OpenSpec task IDs remain the contracts for existing packages; `tasks.md` enumerates future work with `Pnn` in every task line.

## Historical completed baseline

Do not redo these. Reuse exact delivered APIs.

| Baseline | Title | Status | Identity |
| --- | --- | --- | --- |
| Sprints 1–4 | Pilot, trusted operation contracts, provisional corpus reconstruction, typed execution/capabilities | completed historical | roadmap grouping before archived OpenSpec sprints |
| Sprint 5 | Typed interfaces and sequential composition | accepted, delivered, archived | `openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/`; source/evidence `5fb0929` |
| Sprint 6 | Disjoint parallel composition | accepted, delivered, archived | source `fae07ca`; evidence `26bb17d` |
| Sprint 7 | Shared-state interleaving | accepted, delivered, archived | source `bea105ec` |
| Sprint 8 | Atomic synchronization | accepted, delivered, archived | evidence `2c038094`; archive `9501f0a4` |
| Sprint 9 | Sequential congruence and configuration preservation | accepted, delivered, archived | source `eec499d6`; evidence `ec9ed80`; archive `9908d9b5` |
| Sprint 10 | Operational interfaces and binding preservation | accepted, delivered, archived | source `b165bc58` |
| Sprint 11 / M3 | Finite-participant causal composition | accepted with limitations, delivered, archived | source `94f70e50`; evidence `3e736fb0`; archive `681362d8` |
| Checked integer arithmetic | Widths, overflow, rounding, fees | accepted, delivered, archived | source `ddf1ac0e`; archive `6d73e6dc` |

Honest-gate-failure tasks 1.1–7.4 and Atlas historically checked tasks remain historical checkbox bytes, not current package acceptance. `P13` rebinds the current reporting harness and owns R43/R44. `P35` rebinds actual DOM reading-order, reduced-motion, nine-field names, and per-element sync on the authorized Flat/3D depth/family layouts, and still completes 7.4/8.2/8.3/8.4. Do not revive the original 3D ban or 16×5 matrix.

## Hard dependencies versus recommended order

True hard edges are in `sprint-index.json` `dependencies` and the `design.md` DAG copied from that index. Recommended first wave is `P01`, `P08`, `P11`, `P13`, `P15`, and `P16` source-readiness. Wider families `P21`–`P29` are resource-gated by `P17.platform_reuse`, not arithmetic-only reuse. Certificates `P19` are not a prerequisite to `P16`. `P18` depends only on `P16`. `P37` successful_exit joins every required terminal in `p37_required_terminals`. CURRENT.json includes M6 (`P04`). Original mixed tasks close only when every contribution exists.

No calendar or token estimates follow from 37 units.

## Standing gates by evidence class

Apply `sprint-index.json` `evidence_class`. Proof-review sprints reuse exact-bound inventories. Implementation sprints need relevant proofs/executions/mutations. Record-integrity sprints need link/claim checks, not a new full Lean or mutation campaign. `P01` does not run the `P02` eighteen-mutant F01–F20 campaign. Rejection or blocked_unavailable is never successful_exit.

## P01 — M4 recovery r2 closeout

- **Dependencies:** none. Default first coherent item.
- **Legacy:** Sprint12/M4; recovery 4.1–4.4/4.6 plus 4.5 comparator; archive SHA-256 copied from CURRENT.json `M4.sha256`. Foundation 2.x/3.x wait on P02 F01–F20.
- **Outputs:** independent review of `lean/DefiKernel/Nary/Tree/{Compatibility,Recovery,RecoveryChecks}.lean`; evidence under proposed `review/semantic-kernel/m4-recovery/p01/`.
- **Claim boundary:** compatible isolated recovery and canonical complete-schedule equality. Not remaining fixtures/monitors.
- **Checks:** nonempty-write success and refusal; F15 opposite-order competition; canonical comparator witnesses. Exhaustive ninety schedules belong to `P02`.
- **Commands:** from `lean/`: `lake env lean DefiKernel/Nary/Tree/Compatibility.lean` and Recovery/RecoveryChecks. Missing artifacts are setup failure.
- **Stop:** missing assigned theorem, circular premise, empty inventory.
- **Successful exit:** bounded generic recovery independently accepted. Repair/rejection is not exit. No eighteen-mutant campaign here.

## P02 — Remaining M4 contracts, monitors, fixtures, mutations, integration

- **Dependencies:** P01.
- **Legacy:** 5.1–7.5, 4.5 ninety-schedule residual, F01–F20 before original 2.x/3.x close.
- **Outputs:** proposed `Contracts.lean`, `MonitorRuntime.lean`, `Fixtures.lean`, `Verify.lean`; twenty fixtures; ninety complete `(2,2,2)` schedules; eighteen compiled mutants; proposed `review/semantic-kernel/m4-remainder/p02/`.
- **Claim boundary:** transported M3/M2 contracts and causal monitors. Not nested transactions.
- **Checks:** F16 dropped-cross-edge; F17 paired-debit prefixes; F18 funded provenance; designated mutant false oracles with protected positives.
- **Stop:** whole-run equality as a premise; inherited controls dropped.
- **Acceptance/delivery:** independent review then `semantic-kernel-pivot`. Whole M4 delivered only after P02.

## P03 — Official M5 active extension

- **Dependencies:** P02 (delivered M4).
- **Legacy:** Sprint13/M5; `openspec/changes/operational-active-extension/tasks.md` 1.1–5.7. Provisional r2 is not official freeze.
- **Outputs:** proposed `lean/DefiKernel/Extension/`; refreshed `api-refresh.json` bindings; proposed `review/semantic-kernel/m5-active-extension/p03/`.
- **Claim boundary:** old observations under named projection. Not Atomic extension.
- **Checks:** mixed-ID restriction; omitted-cell negatives; sixteen compiled mutants; no peer-success premise.
- **Stop:** speculative names; configuration mutation during execution.
- **Acceptance/delivery:** new same-candidate planning reviews after API refresh, then implementation review.

## P04 — M6 atomic metatheory transfer

- **Dependencies:** P02 and P03.
- **Legacy:** Sprint14/M6; `openspec/changes/atomic-metatheory-transfer/tasks.md` 1.1–5.7.
- **Outputs:** proposed `lean/DefiKernel/AtomicNary/`; proposed `review/semantic-kernel/m6-atomic-transfer/p04/`.
- **Claim boundary:** one outer Atomic boundary and first-abort policy. Not new-lane settlement.
- **Checks:** rollback, residual, first-supply, publication, boundary-reassociation counterexamples; eighteen compiled mutants.
- **Stop:** flattened execution substitute; desired commit as a premise.
- **Acceptance/delivery:** independent review; remaining obligations named.

## P05 — Capability provenance and isolation

- **Dependencies:** none. Not a blanket M4 dependent.
- **Legacy:** `openspec/changes/capability-provenance-isolation/tasks.md` 1.1–6.7; archive `7fc31431a2b5d6f0198f8a182fcd31a35b90d323c076c1c0bc000c9a3b30c52a`.
- **Outputs:** proposed `lean/DefiKernel/CapabilityProvenance/`; proposed `review/semantic-kernel/capability-provenance/p05/`.
- **Claim boundary:** initialized sequential provenance and supported frames. Not general confidentiality.
- **Checks:** resolve CF1 revoked-ID and CF2 22-versus-23; F01–F20; fourteen query mutants; 65 inherited controls.
- **Stop:** final-state legitimacy premise; unresolved CF1/CF2.
- **Acceptance/delivery:** independent review of initialized proofs then whole package.

## P06 — Claims generic partial recovery

- **Dependencies:** none.
- **Legacy:** claims-liability-lifecycle tasks 4.2, 4.3, 4.7; cancelled archive `6fdca9817bc2a4bba52b5a58c6c605a16aacb7fb9c0b46100ff8b3bf26239ee3`.
- **Outputs:** inspection record of `PaymentSoundness`/`Conservative`/`Preservation`; one chosen bounded obligation or explicit residual; proposed `review/semantic-kernel/claims-partial/p06/`.
- **Claim boundary:** only the chosen recovered obligation.
- **Checks:** cancellation is not completion; preserve partial bytes.
- **Stop:** indiscriminate restart; rewriting World/Right.
- **Acceptance/delivery:** independent review of the chosen obligation.

## P07 — Claims full lifecycle

- **Dependencies:** P06.
- **Legacy:** claims-liability-lifecycle tasks 2.1–5.8.
- **Outputs:** proposed `lean/DefiKernel/Claims/`; `scripts/claims_gate.py`; `mutations/claims.json`; proposed `review/semantic-kernel/claims-lifecycle/p07/`.
- **Claim boundary:** fixed-principal lifecycle with repayment and non-erasure. Not indexed payoffs or legal fidelity.
- **Checks:** F01–F24 including overpayment refusal, paymentMismatch, paid-versus-forgiven; twenty compiled mutants.
- **Stop:** treating debt-erasure regression as repayment.
- **Acceptance/delivery:** independent review; parent-owned delivery.

## P08 — Corpus capture/classification/span repair

- **Dependencies:** none. Independent of M4.
- **Legacy:** corpus-provenance-adjudication task 2.3; Audit04 findings.
- **Outputs:** repaired overlay records for EigenCloud challenge classification and CoW derived-span binding; proposed `review/semantic-kernel/corpus-repair/p08/`.
- **Claim boundary:** repair of confirmed misleading bindings. Not all 169 work items.
- **Checks:** challenge/404 have zero semantic support; span → derived artifact → extraction → original successful response.
- **Stop:** using defective records for library fidelity.
- **Acceptance/delivery:** independent review of the two repairs.

## P09 — Identities, 29 disputes, development-manifest sub-delivery

- **Dependencies:** P08. No hard edge to P10.
- **Legacy:** corpus tasks 3.1–3.2, 5.1–5.3, P09 contribution of 5.5 (29 facet records), 6.1–6.3. Original 5.5 whole-task and 7.1–8.3 are P09+P10 contributions, not P09 successful_exit.
- **Outputs:** identity ledger, 29-facet overlay, development/evaluation manifests; named 6.1 sub-delivery for P10 collect 2.4; proposed `corpus/adjudicated/v1/generated/`.
- **Claim boundary:** development overlay identities, 29 facet disputes, and manifests. All 75 remain development. Not the original 5.5 separate-challenge record, not complete 169-item accounting, not whole-package 7.x/8.x closeout.
- **Checks:** silence is not refutation; promotion controls fail; 6.1 artifact exists before P10 2.4; 29 facet records do not close original 5.5.
- **Stop:** counting `review_pending` as complete; closing 7.x/8.x from identity work alone; claiming remaining 169-work dispositions; closing original 5.5 from 29 facet records alone.
- **Acceptance/delivery:** independent review; unresolved facts stay unresolved. 6.1 MAY be consumed early as partial_delivery.

## P10 — Liquity challenge, bounded collector, whole-package 7.x/8.x join

- **Dependencies:** P08 only. Conditional: 2.4 consumes P09 6.1; 7.x/8.x join consumes P09 successful_exit. No P09 hard edge, so no cycle.
- **Legacy:** corpus tasks 2.1–2.2, 2.4, 3.3, 4.1–4.3, 5.4; P10 contribution of 5.5 (separate challenge adjudication record); whole-package join 7.1–8.3.
- **Outputs:** liquidation-challenge decision and original-5.5 challenge adjudication record; bounded collector 2.4 with original three-slot/two-attempt/five-redirect/30-second local HTTP fixture; `inputs/dependencies.json`; residue records; original-reference recovery or replacement; joined 7.x/8.x tooling/acceptance/archive with complete 169-item accounting.
- **Claim boundary:** source adjudication including the original 5.5 challenge contribution, original bounded collect, and joined package closeout. Not P23 redemption library. Not a global barrier on P16.
- **Checks:** separate liquidation versus redemption; reconstructed replacement does not claim recovered original; 2.4 does not run before 6.1; 7.x/8.x do not close from one workstream; original 5.5 closes only after both contributions; 169-item accounting is at the join.
- **Stop:** invented collector runs; adding a P09 hard edge that cycles with the join; closing original 5.5 from the challenge record without the P09 29-facet contribution.
- **Acceptance/delivery:** independent review. Source work MAY be partial_delivery while 7.x/8.x wait for P09. Whole original 5.5 may close before 7.x/8.x once both contributions exist.

## P11 — H02/H12 scope and like-for-like measurements

- **Dependencies:** none.
- **Legacy:** historical-claim-reconciliation; archive `26ade3b9544924e782264e9fbcf37c93c88fb078cacbd7ab1098478e3ed4c0a6`.
- **Outputs:** repaired authority links; like-for-like table using `formal/v3/VERIFICATION.md` R∩W figures 50,223 / 50,611 / 50,276 and exhaustive 32,188,276 pairs / 396,437 failures where that universe applies.
- **Claim boundary:** scoped repair. Interface counterexample preserved.
- **Checks:** Convex review does not accept Independence/Interface; R-only 3,342 / 2,955 / 2,809 not advertised as R∩W.
- **Stop:** changing historical theorem statements.
- **Acceptance/delivery:** independent review.

## P12 — Full occurrence and claim reconciliation

- **Dependencies:** P11.
- **Legacy:** historical-claim-reconciliation tasks 2.1–5.6.
- **Outputs:** proposed `lean/DefiHistorical/Convex/`; `scripts/historical_claims.py`; claim/scenario map for 18 CLs.
- **Claim boundary:** selected historical claims and two unary instances. Not P37 paper rewrite. `mixed_behavior`: Lean proofs 3.1–3.7 plus data/CLI 2.x/4.x/5.x; classification does not skip proofs.
- **Checks:** 26 controls; bound-aware JS execution; empty checks blocked; complete proof inventories for 3.1–3.7.
- **Stop:** editing protected measurement environments.
- **Acceptance/delivery:** independent review; DefiHistorical stays out of kernel Verify closure.

## P13 — Reporting candidate and diagnostics

- **Dependencies:** none.
- **Legacy:** honest-gate-failure 1.1–7.4 are historical checkbox bytes, not current acceptance. CURRENT `reporting_gate.sha256`. P13 owns R43 and R44.
- **Outputs:** rebound current-harness evidence; delivered R43/R44 diagnostics. A rejected 210/0 archive is terminal disposition, not successful_exit.
- **Claim boundary:** honest reporting plus R43/R44. Those items are not optional.
- **Checks:** exit 0/1/3 discrimination; empty denominator blocked; positive and negative reporting polarities.
- **Stop:** author 210/0 as acceptance; merging blocked and false; leaving R43/R44 ownerless.

## P14 — Duplicate-capability, vault-liquidity, actor/effect/supply, projection, wrong-world

- **Dependencies:** none.
- **Legacy:** R21, R45, R46, R47.
- **Outputs:** proposed duplicate-capability-list theorem; isolated vault-liquidity regression; older-wrapper actor/effect/supply mutants; attributed/macro/notation/deriving projection guards; separated wrong-world oracles; proposed `review/semantic-kernel/residual-mutations/p14/`.
- **Claim boundary:** named residuals. Sprint 7 sources stay accepted until these discharge recorded limits.
- **Checks:** isolated regression is a dedicated nonempty comparison; designated mutant detected; unaffected sibling true.
- **Stop:** comment in a shared wrapper in place of the isolated regression.
- **Acceptance/delivery:** independent review.

## P15 — Minimum reusable contracts

- **Dependencies:** none. Not blocked on full M4 or certificates.
- **Outputs:** proposed `openspec/changes/reusable-verification-platform-program/contracts/` later realized in `lean/DefiKernel/Platform/` if implementation is authorized: kernel/operator boundary, amount/rounding/error, adapter I/O, evidence packet, obligation classes.
- **Claim boundary:** shared contracts only.
- **Checks:** pure function omits invented ledger history; machine-width and fallback explicit.
- **Stop:** invented undeclared operator fields.
- **Acceptance/delivery:** independent review of the contract freeze.

## P16 — Pinned Uniswap token0, overflow-oracle repair, M09/F28 control-plan correction

- **Dependencies:** P15 for implementation; source-readiness may start earlier.
- **Legacy:** unaccepted `concentrated-liquidity-library`; pin v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`; archive `e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77`. Original 1.2 is independent planning review of the exact repaired P16 token0 slice; the unaccepted freeze is preserved input, not accepted evidence.
- **Outputs:** proposed `lean/DefiKernel/ConcentratedLiquidity/` token0 slice; pinned solc/EVM run; repaired oracle and M09/F28 control plan; token0 production mutants; proposed `review/semantic-kernel/uniswap-token0/p16/`.
- **Claim boundary:** standalone token0 next-price arithmetic and bounded source comparison. Required overflow branch cannot be excluded. Not TickMath, SwapMath, token1/delta, bitmap/liquidity/factory, compiled M09 SwapMath execution, or the original 45-fixture/M01–M12 campaigns (P21). Not full traversal (P21). Not source refinement (P30). Python oracle is diagnostic only. A P16 contribution does not close mixed original IDs. P16 implementation does not wait on the P21 campaign.
- **Checks:** independent GPT-6 planning review of the exact repaired token0 slice with verdict/model/input hashes; ordinary add/remove; required sum-overflow; zero-amount identity `(2^96,1,0,*)=2^96`; planned add `(2^96,1,1,true)=2^95`; removal-denominator require `(2^96,1,1,false)`. No fee parameter. M09/F28 control-plan correction; token0 production mutants compiled.
- **Stop:** unexplained source/model difference; Python-only mutation credit; excluding the overflow branch to pass; compiled M09 claimed as P16; marking original 4.1/6.x/7.x or whole 1.2 done from the token0 contribution.
- **Acceptance/delivery:** independent review of the token0 slice; original 1.2 stays open until the P21 residual-slice planning review is also accepted; refinement remains open.

## P17 — Vault source readiness and reuse gate

- **Dependencies:** P16 for the reuse experiment. Source-readiness inspection may start earlier. No P30 dependency.
- **Outputs:** actual vault pin record or `blocked_missing_source`; if pinned, proposed `lean/DefiKernel/Vault/`; measured case-two inventory; proposed `review/semantic-kernel/vault-reuse/p17/`.
- **Claim boundary:** arithmetic-only reuse may be published in `arithmetic_reuse`. `P17.platform_reuse` requires one common harness engine executing both cases, a named shared financial lemma or contract, a named shared executor result, the token0 kernel bridge, both adapters, and the case-two inventory. Composition integration, if claimed, requires a meaningful two-operation preservation instance; otherwise narrow noncomposing interface/library reuse remains valid. No second AMM substitute. No fabricated composition.
- **Checks:** ordinary conversion; actual source-selected transfer guard; source-independent share-mint-without-credit negative; one harness executing both cases; recorded case-two additions/assumptions/interfaces/effort.
- **Stop:** invented pin; fake workflow; treating a vault-only theorem as the shared executor result; a wrapper around separate engines counted as one harness; treating arithmetic reuse as `P17.platform_reuse`.
- **Acceptance/delivery:** independent review; `P17.platform_reuse` stays open without the measured inventory. Blocked missing source is `terminal_disposition`, not `successful_exit`.

## P18 — Bounded platform increment publication

- **Dependencies:** P16. Arithmetic-only increment. Stronger platform reuse for later families requires `P17.platform_reuse`.
- **Outputs:** evidence packets; proposed `examples/platform-increment/`; proposed `review/semantic-kernel/platform-increment/p18/`; parent-owned `semantic-kernel-pivot` publish.
- **Claim boundary:** model-proved increment with bounded source evidence and refinement open. Not whole-program completion. Does not wait on M4 remainder, certificates, or adapters.
- **Checks:** changed modules plus affected consumers; transport/readback.
- **Stop:** codec cited as refinement; merge to main.
- **Acceptance/delivery:** independent review; no recursive administrative reviews.

## P19 — Typed sequential certificates

- **Dependencies:** none. Not a prerequisite to P16.
- **Legacy:** unaccepted `serialized-kernel-certificates`; archive `122118df438c8c05a09f48e5097fb6f6bfd3c19cedece4dee20aa32757c4bc13`.
- **Outputs:** proposed `lean/DefiKernel/Certificates/`; `scripts/run_certificate_mutations.py`; proposed `review/semantic-kernel/certificates/p19/`.
- **Claim boundary:** independently reviewed checker implementation candidate. Not qualified certificate delivery. Not an accepted semantic certificate checker until `P20`.
- **Checks:** F01–F54 as in the candidate plan once that plan is independently accepted; claimed tags do not skip `Args.check`; M01–M16 compiled mutants.
- **Stop:** implementing Tree/Claims as complete; accepting envelope hashes as proof.
- **Acceptance/delivery:** planning gate first, then implementation review.

## P20 — Quantified representation correspondence and wider operators

- **Dependencies:** P19.
- **Outputs:** proposed `Correspondence.lean`; per-extension correspondence or `unsupportedForm`; Quint correspondence if Quint is introduced.
- **Claim boundary:** representation correspondence. Codec does not close P30.
- **Checks:** universal correspondence; `Parallel.admit` or `checkCompatibility` on recomputed footprints plus `checkCompatibility_ok_iff`; Lean-checked library instantiation. `Parallel.Compatible` is a Prop, not the checker. R18 contribution: compatibility and library instantiation; P19 mapping does not close R18.
- **Stop:** fixtures treated as universal.
- **Acceptance/delivery:** independent review.

## P21 — Residual concentrated-liquidity library and tick traversal

- **Dependencies:** P16. Resource gate: `P17.platform_reuse`, not arithmetic-only reuse.
- **Outputs:** TickMath, SwapMath, residual token1/delta, bitmap/liquidity/factory, original 45-fixture and M01–M12 campaigns with repaired per-mutant controls, traversal modules under proposed `lean/DefiKernel/ConcentratedLiquidity/`; remainders `R-FULL-TRAVERSAL`, `G-FULLMATH-ASSEMBLY`, `G-NO-SOLC-DIFFERENTIAL` named until discharged.
- **Claim boundary:** residual library including token1/delta that P16 does not own, plus declared multi-word traversal. Not deployed pool security. Naming a remainder does not close R22. Mixed original IDs close only after P16 contributions also exist. Original 1.2 residual-slice planning review is not a P16 prerequisite.
- **Checks:** independent GPT-6 planning review of the exact repaired residual slice with verdict/model/input hashes; TickMath F10–F19; SwapMath and token1/delta; 45 fixtures; M01–M12 using the repaired per-mutant unaffected-control set (compiled M09 excludes or replaces F28; failed original plan preserved); two-tick success; exact-output cap as bounded success (`SwapMath.sol` 87–89); `SPL` pool admission refusal (`UniswapV3Pool.sol` 608–613); liquidity-delta-without-cross negative.
- **Stop:** one-word bitmap claimed as `Pool.swap`; excluding traversal to pass; dropping token1/delta; scoring compiled M09 against F28; marking original mixed IDs done from the P21 contribution alone; treating the unaccepted freeze as original 1.2 acceptance.

## P22 — Curve iteration, nonconvergence, refusal

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** pin record or `blocked_missing_source`; proposed `lean/DefiKernel/Curve/`; proposed `review/semantic-kernel/curve/p22/`.
- **Claim boundary:** iterative invariant within the pin. Pin is not established at planning time.
- **Checks:** ordinary success; bound-exhaustion classified from the later pin as residual success or actual revert, matching the matrix `conditional_property`; source-independent over-bound negative.
- **Stop:** inventing a current refusal or pin.
- **Acceptance/delivery:** independent review or recorded block.

## P23 — Liquity ordered redemption

- **Dependencies:** none hard. Resource gate: P17. Separate from P10.
- **Outputs:** pin record or block; proposed `lean/DefiKernel/Redemption/`.
- **Claim boundary:** ordered redemption library, not the liquidation-source overlay.
- **Checks:** order, partial fill, empty redeemable-set refusal.
- **Stop:** using P10 as a library pin.
- **Acceptance/delivery:** independent review or recorded block.

## P24 — Morpho bad-debt loss allocation

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** pin record or block; proposed `lean/DefiKernel/LossAllocation/`.
- **Claim boundary:** declared allocation rule, not generic solvency.
- **Checks:** reachable loss; no-bad-debt as successful control, not executor refusal; actual rejection gate selected from the later pin.
- **Stop:** marketing nonnegative balances as solvency.
- **Acceptance/delivery:** independent review or recorded block.

## P25 — Balancer vault, hooks, transient accounting

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** pin record or block; proposed `lean/DefiKernel/SharedVault/`.
- **Claim boundary:** pinned vault/hooks/transient. Not a silent P17 substitute unless the pin identity is the same.
- **Checks:** hook revert does not publish transient state; shared accounting fixtures.
- **Stop:** publishing transient state on revert.
- **Acceptance/delivery:** independent review or recorded block.

## P26 — Async lifecycle

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** proposed `lean/DefiKernel/Async/`; explicit oracle/custody/legal/sequencing/finality assumptions.
- **Claim boundary:** declared async workflow. Not P29 cross-domain completeness.
- **Checks:** finality, replay refusal, timeout, challenge, compensation.
- **Stop:** assuming synchronous rollback.
- **Acceptance/delivery:** independent review.

## P27 — Signed margin, funding, unsettled PnL, liquidation, bankruptcy

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** pin record or block; proposed `lean/DefiKernel/Margin/`.
- **Claim boundary:** pinned derivatives accounting. Unsettled PnL is not cash unless the source says so.
- **Checks:** funding success; allowed liquidation/bankruptcy as exceptional success; actual rejection gate selected from the later pin.
- **Stop:** inventing bankruptcy rules.
- **Acceptance/delivery:** independent review or recorded block.

## P28 — Conditional insurance and off-chain claims

- **Dependencies:** none hard. Resource gate: P17.
- **Outputs:** pin record or block; proposed `lean/DefiKernel/ConditionalClaims/`.
- **Claim boundary:** external conditional claims. Oracle truth remains an assumption where unproved.
- **Checks:** pay/refuse under attestation; explicit assumption class.
- **Stop:** treating oracle attestation as proved fact.
- **Acceptance/delivery:** independent review or recorded block.

## P29 — Complete cross-domain workflow

- **Dependencies:** P26. Resource gate: P17.
- **Outputs:** proposed `lean/DefiKernel/CrossDomain/`; one actual end-to-end workflow.
- **Claim boundary:** one supported workflow. No synchronous-rollback assumption. Not universal bridging.
- **Checks:** remote-finality success; timeout compensation as exceptional success, not executor refusal; actual rejection gate from the selected workflow source; no silent local rollback.
- **Stop:** single-chain stand-in counted as complete.
- **Acceptance/delivery:** independent review.

## P30 — Differential execution and selected source refinement

- **Dependencies:** P16. Required before P37 program closure.
- **Outputs:** proposed `scripts/differential_execution/`; selected refinement proofs; proposed `review/semantic-kernel/source-refinement/p30/`.
- **Claim boundary:** selected refinements over declared admissible states. Codec correspondence is not this obligation.
- **Checks:** identical sequences on implementation and model; refusals; characteristic mutants; refinement proof without desired-postcondition premises.
- **Stop:** citing P19/P20 as refinement discharge.
- **Acceptance/delivery:** independent review. Program remains open until this sprint accepts or is explicitly blocked.

## P31 — Moriarty, Compact, ZKIR, PCT adapters

- **Dependencies:** P15.
- **Outputs:** readiness records under proposed `review/semantic-kernel/adapters/readiness/p31/` for each of Moriarty, Compact, ZKIR, and proof-carrying transactions; implementation under proposed `lean/DefiKernel/Adapters/` only against verified pins; otherwise `blocked_unavailable`.
- **Claim boundary:** adapter boundary. Never invent semantics. Source-plan lines 1140–1142 are agenda input.
- **Checks:** named readiness task and named implementation task per system; blocked is not checked complete.
- **Stop:** kernel imports of imagined APIs; completion by deferral.
- **Acceptance/delivery:** independent review of readiness plus any actual integrations.

## P32 — Environment pins: EVM, Solana, Cosmos, Move/Sui, sovereign cross-chain, payment channels

- **Dependencies:** none. Evaluation of holdouts waits on P33; pins may start earlier.
- **Outputs:** per-environment readiness and pin or `blocked_unavailable` under proposed `review/semantic-kernel/environments/p32/`.
- **Claim boundary:** environment readiness. EVM token0 does not score other environments. Source-plan line 1116 is agenda input, not proof those toolchains exist here.
- **Checks:** six named environments each have a record; missing toolchain is blocked.
- **Stop:** inheriting EVM scores.
- **Acceptance/delivery:** independent review of the six records.

## P33 — Kernel/schema/library freeze and twelve-case replacement policy

- **Dependencies:** P18.
- **Outputs:** freeze manifest; replacement policy; development 75 remain development; proposed `review/semantic-kernel/evaluation/freeze/p33/`.
- **Claim boundary:** freeze and selection policy. Do not read held payloads. Prior twelve REPORT labels are exposure records with original IDs unknown.
- **Checks:** promotion controls fail; no 75+12 disjoint denominator.
- **Stop:** opening holdout payloads.
- **Acceptance/delivery:** independent review of freeze bytes.

## P34 — Independent untouched evaluation and separated metrics

- **Dependencies:** P33.
- **Outputs:** evaluator workflow; separated metrics (schema, behavioral, library reuse, new kernel concepts, new library templates, external assumptions, proof/checking effort); proposed `review/semantic-kernel/evaluation/untouched/p34/`.
- **Claim boundary:** untouched evaluation within freeze. Blocked environments are not scored.
- **Checks:** independent case selection; each metric has its own denominator.
- **Stop:** using development cases as holdouts.
- **Acceptance/delivery:** independent evaluator, not the author of the freeze.

## P35 — Atlas candidate and residual interaction

- **Dependencies:** none.
- **Legacy:** design-atlas-visualization tasks 7.4, 8.2, 8.3, 8.4; archive `56c3a1d532669f229e9c67f7e25f3253bedabd9baad5ae4942f306ef9c487db6`; CURRENT residuals search-list/badges/zoom/print/find.
- **Outputs:** independent verdict on the 238-check candidate; keyboard traversal; 200-percent zoom; reduced motion; readability; print/find.
- **Claim boundary:** current-layout accessibility. Historical checked boxes are not current acceptance. Original 7.3 150 KB / no-scene-graph budget is superseded by current-layout budget/conformance. Preserve Flat/3D and depth/family; do not revive 3D ban/matrix.
- **Checks:** actual DOM reading order, executed reduced motion, nine-field names, per-element sync, keyboard 7.4, screenshot 8.2.
- **Stop:** treating historical checkboxes as current acceptance.
- **Acceptance/delivery:** independent review.

## P36 — Scientific Atlas and graph after stable schema

- **Dependencies:** P35. Conditional: named accepted schema artifact/hash from accepted platform results; not a P33 hard edge; stability may not be skipped.
- **Outputs:** schema-aligned Atlas; repository graph update; mapping statements; missing-denominator marks; proposed `graphify-out/platform-program/`.
- **Claim boundary:** visualization of accepted schema. Not periodic-law implication. Not graph-orphan deletion.
- **Checks:** mapping statement on every layout; no "periodic table" chrome.
- **Stop:** implying predictive closure.
- **Acceptance/delivery:** independent review.

## P37 — Paper, external developer package, verified delivery

- **Dependencies:** `p37_required_terminals` in `sprint-index.json`.
- **Outputs:** paper rewrite; developer package; verified `semantic-kernel-pivot` delivery.
- **Claim boundary:** full-program successful_exit only when every required terminal is delivered. An earlier partial paper does not close P37. Blocked required work keeps P37 open.
- **Checks:** every required terminal has successful_exit; P30 refinement accepted; no merge to main.

## Cleanup policy

Applied only with exact consumer/root/build/CLI evidence. Preserve historical proofs, negative results, partials, unique unintegrated candidates, and dirty worktrees. Graph isolation is not deletion evidence. Originals remain recoverable. This is not a separate sprint; it is a standing constraint on every sprint that touches files.
