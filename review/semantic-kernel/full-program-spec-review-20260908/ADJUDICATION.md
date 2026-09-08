# Full-program specification review, 2026-09-08

**Current verdict: CHANGES REQUIRED.** Native Grok 4.6 and an independent GPT-6 reviewer both completed fresh reviews of the same 15-file frozen OpenSpec package. The architecture remains a supported direction. Three substantive planning defects need repair before the package is used as the complete execution contract: liquidity scope allocation, the measured reuse gate, and corpus collection/closeout ordering. Several smaller consistency defects should be repaired in that revision.

This review supersedes the earlier program-plan acceptance **for current routing**. The [earlier adjudication](../full-program-openspec-20260908/ADJUDICATION.md) remains historical evidence. The reviewed specs have not been changed. No implementation sprint, proof build, EVM execution, commit, push, or source deletion was performed by this review task. The existing implementation dispatch hold remains in force.

## Independent inputs and reviewers

- [Input manifest](input-manifest.json): all 15 live and frozen files matched throughout review. Repository HEAD was `a12b7cac05a818cc8d35c2ca440b7170a2807e92`; the per-file hashes identify the uncommitted candidate. Its existing archive SHA-256 is `e0652083884ad3f6d78d905714f7bdbb73953d8face4f1f0c2c39392c956c495`.
- [Grok review](grok-review.md): fresh native CLI session, requested `grok-4.6`; final telemetry reports **`grok-4.6-build`**, 20 turns, `end_turn`, process exit 0. [Receipt](grok-receipt.json) and [terminal event](grok-terminal.json) preserve the actual identity. The report's assertion that separate usage JSON was unavailable is corrected by that terminal event; the original report is preserved unchanged.
- [GPT-6 review](gpt6-review.md): independent stock-harness agent `/root/gpt6_specs_review`, requested `gpt-6-astra`. No separate native-provider identity is asserted. [Receipt](gpt6-receipt.json).
- Both first-pass reviewers were instructed to avoid the other's report and the previous full-program verdicts/findings. After both finished, GPT-6 supplied a narrowly scoped [convergence note](gpt6-convergence.md) on four disputed Grok findings. Root checked the original task contracts, source lines, counts, and explicit gate language.

These are advisory specification reviews, not theorem acceptance or proof of eventual source fidelity. Future source pins and verified interfaces remain entry obligations.

## Required substantive repairs

1. **Split liquidity ownership by actual outcome (high priority).** Both reviewers found that `legacy-task-disposition.json` assigns TickMath, SwapMath, bitmap/liquidity/factory work and the full 45-fixture campaign to P16, while P16 promises a narrow token0 next-price experiment. Following one document overloads the early experiment; following the other leaves obligations assigned to a completed sprint. Move the wider outcomes to P21 or an explicit intermediate unit. Split mixed original tasks into named contributions, with whole-task closure requiring every contribution. Preserve the original package bytes. See GPT finding 1 / Grok F6.

2. **Restore the full P17 reuse test (medium priority).** The strategy requires one harness engine for both cases, a named shared financial lemma/contract and executor result, and recorded case-two changes in definitions, assumptions, interfaces, and effort. The current five P17 tasks do not require that complete measurement. Add it before releasing P21–P29. If composition integration is claimed, require a meaningful two-operation preservation instance; narrower interface/library reuse remains legitimate when the operations do not compose. Do not impose all of P30 on this early experiment. See GPT finding 2. A distinct `P17.platform_reuse` predicate would also make the existing stronger-gate rule clearer to a machine consumer (Grok F1), but current prose already forbids arithmetic-only reuse from opening that gate.

3. **Make corpus collection and final acceptance schedulable (medium priority).** Original corpus task 2.4 is mapped to P10 but absent from its executable checklist and successful-exit description. P09 owns original final tooling/review/archive tasks 7.x/8.x even though they must validate P10's collection, source, deployment, dependency and challenge work. P10 collection consumes original 6.1's development manifest, not completion of all P09. Expose that intermediate artifact; include the actual bounded collector task; make final package acceptance join both workstreams. Preserve unresolved facts without treating unfinished required tooling as accepted. See GPT finding 3 / Grok F3–F4.

## Consistency repairs to include

| Item | Confirmed defect and bounded remedy | Review source |
| --- | --- | --- |
| R18 coverage | Add P20's required compatibility and library-instantiation contribution to the coverage table and index. `roadmap_ids` means contribution, so the existing P19 mapping does not itself authorize early closure. | Grok F5 |
| Adapter task references | Matrix IDs `32.5a`–`32.5d` do not exist. Actual implementation tasks are `32.5`–`32.8`. [Targeted check](adapter-task-reference-check.json) confirms four missing references. | GPT 4 / Grok F9 |
| Coverage counts | The coverage table is stale. Actual totals are **54 requirements and 89 scenarios** across six capabilities; [per-capability counts](actual-spec-counts.json) preserve the measurement. Derive or check the table against the headings. | Grok F8 |
| Curve outcome wording | P22's matrix `conditional_property` mandates refusal on bound exhaustion, while the spec and adjacent matrix fields permit the later source to select revert or successful residual. Align the property with the source-entry freeze. No current Curve source behavior is asserted here. | Grok F10 / root observation 2 |
| Solidity source locators | The exact-output cap is `SwapMath.sol:87–89`; the cited `89–92` misses the condition and overlaps exact-in fee handling. The SPL guard is `UniswapV3Pool.sol:608–613`; `603–613` includes SPL but is unnecessarily broad, also containing AS/LOK. Correct both ranges; the named cap/SPL semantics were already correct. | Grok F7 |
| P12 evidence class | P12 includes original Lean proof work but is labelled only `data_repair`. Use `mixed_behavior` with explicit proof and data obligations. Standing task 1.4 and P12's actual tasks already require the proofs; this is classification inconsistency, not permission to skip them. | Grok F12 |

## Dissent, severity corrections, and advisory hardening

Grok rated most findings Important. Root does not adopt those severities automatically. The concrete scope and task-ordering defects above block using this package as a coherent execution plan. Stale counts, IDs and locators are smaller, reproducible consistency repairs.

- **F1:** A named platform-reuse predicate is useful. The asserted automatic bypass is not established: the index defines `resource_gate` as measured reuse, P21's entry excludes arithmetic-only reuse, and the specs repeat that prohibition. A runner ignoring those rules would violate the contract. Retain the recommendation within the P17 repair.
- **F2:** Not accepted as a completion loophole. P31 explicitly says blocked adapters are not `successful_exit`; P34 explicitly keeps unavailable environments open; standing task 1.8 forbids recording blocked work as success. Removing blocked-status prose from success fields is editorial normalization, not restoration of a missing prohibition.
- **F5:** Accept the missing P20 contribution mapping. Reject the stronger claim that mapping alone permits R18 closure: the index labels these contribution IDs, and the certificate spec explicitly keeps R18 open until the P20 work succeeds.
- **F7:** Accept the incorrect cap locator and tighten SPL. The broader SPL range includes the correct named guard, so it is not evidence that a different refusal is required.
- **F10 related unpinned-family notes:** The matrix's global note already makes unpinned outcome classes planned expectations requiring source-entry binding. Do not claim a discovered Liquity/Balancer implementation defect. Preserve that entry rule; the contradictory Curve property still needs correction.
- **F11:** P36 already requires a stable accepted schema in its entry and normative spec. Naming the consumed schema artifact/hash as a conditional dependency improves scheduling; absence of a P33 hard edge does not prove that P33 is the correct dependency or that stability may be skipped.
- **F12:** Accept classification repair, reject proof-omission authorization, as above.
- **F13:** The later authorized Flat/3D and depth/family contract explicitly supersedes the old 3D ban. Legacy task 7.3's generic “confirm” note should name the replacement budget/conformance scope. This is useful traceability hardening, not a reason to restore the old ban. Tasks 1.1/4.1 already carry the current-layout warning.

The original reports retain all findings and dissent. No finding was silently deleted or counted as a proved source-code defect.

## Validation and next gate

Fresh OpenSpec strict validation and the existing structural checker pass: 37 sprint IDs, an acyclic hard DAG, all 47 roadmap IDs, all 17 lanes, and all 339 original task IDs/checkbox states are represented. [Validation receipt](validation.json). Those checks do **not** establish correct semantic ownership, complete task-level dependencies, valid adapter references, or matching summary counts. The findings above demonstrate those limits.

The next concrete work is one bounded native-Grok planning revision covering the three substantive repairs and the consistency table, followed by independent GPT-6 review of the changed scope. Recheck semantic task ownership and task-level closeout dependencies as well as structural validation. The current task completed the requested review; it did not revise or implement the 37-sprint program. The full program and its implementation acceptance remain open.
