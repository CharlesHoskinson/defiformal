# Token0 relation independent review

Verdict: ACCEPT_WITH_LIMITATIONS for the exact four-file r2 candidate. No unresolved blockers or required repairs.

Requested reviewer: `gpt-6-astra`, medium. No provider-returned model identity or attested reasoning setting is exposed; actual identity remains unreported. Review is advisory evidence, not a mathematical proof.

Baseline: `0694a5c36fc12e95ca0085a4ebae4ac418b7aefa`. Both original and repaired freezes are retained here. Every final file hash and size matched. Only `verify.py` and its exit-contract documentation changed for the repair; the differential manifest and refinement obligation retain their original hashes. All 101 historical pinned artifacts match baseline Git objects, independently of the manifest's own declarations. All 231 tracked Lean/configuration files in the isolated build copy match baseline. Four local Markdown links resolve.

## Scope and findings

The ABI relation is explicit: selector `6c84a8a2`, canonical 132-byte calldata, bounded uint160/uint128/uint256 values and Boolean, raw quantities and Q96 price. Success requires exactly 32 bytes encoding a bounded uint160 equal to the Lean result. A semantic revert relates only to a Lean error at the coarse refusal level. Empty revert bytes do not identify an error constructor. Missing/malformed evidence, infrastructure failures, timeout/cancellation and out-of-gas are excluded, rather than counted as source refusals.

The named model theorem is exact: `DefiKernel.ConcentratedLiquidity.SqrtPriceMath.add_result_le`, owned by `Token0Proofs`, proves successful add output at most the input price for arbitrary bounded words. The successful-output premise is disclosed; no unsupported total-success or positivity claim is made. The documented transfer to a recorded source success requires observed equality, not universal correspondence. The package adds no Lean theorem or axiom and does not alter historical proofs.

The manifest accurately separates 12 original archived author source invocations (8 successes, 4 semantic reverts) from 4 model-only invocations. All four source reverts have empty returndata, despite distinct model labels. I inspected all 12 raw source stdout/stderr pairs against their records and checked the compiler settings, source hashes, runtime-byte versus hex-text distinction, execution context and acceptance records. The checker also verifies archive-member bytes, calldata, model-binding output, stream receipts, timestamps, binary identities, runtime/genesis context and exact inventories. The later GPT-6 replay is separately pinned corroboration, not substituted for the original author runs and not added to the denominator. Historical pending-review fields remain historical bytes with separate acceptance authority.

The refinement document states the remaining universally quantified execution relation and names ABI, arithmetic/wrap/rounding/fallback, revert, compiler/source/runtime, fork/context and gas obligations. Deployed identity, pool state/settlement, authorization and fees are excluded. These are real remaining obligations; identifying them does not prove them.

## Repair and verification

R1 finding (resolved): the original CLI let absent/empty-input failures become uncaught exit 1, contrary to the repository's blocked-check convention. Source inspection established the empty-inventory path; an actual missing-artifact CLI run reproduced exit 1. The first reviewer fixture omitted an unrelated examples directory, so its intact/empty runs were not valid controls; that failed fixture is retained as `r1-incomplete-review-fixture.json` and is not credited. During correction the author's repaired source arrived; intermediate 0/3/3 observations are retained separately, not mislabeled as original-freeze runs.

R2 introduces a narrow blocked exception and CLI boundary, with documented 0/1/3 behavior. I reproduced all nine actual final CLI subprocess controls: intact passes; missing/empty manifest, missing artifact, empty required artifact and empty source inventory block with exit 3; changed expected bytes, wrong source class and wrong model output fail with exit 1 and specific diagnostics. `r2-cli-controls.json` binds the final checker hash. This closes R1. The original six in-process author controls are historical evidence, not a substitute for these subprocess results.

Independent isolated focused build, theorem/axiom disclosure and `leanchecker` replay of unchanged `Token0Proofs` all exited 0; exact commands and log hashes are in `execution.json`. `add_result_le` depends only on `propext`, `Classical.choice`, and `Quot.sound`. Lean is 4.33.0-rc2, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`, compiler SHA-256 `1b370cfcbf44e80d1b004ab1b1ab9a4c73951f9f7c242140bcff9bc577576554`. No whole-build rerun was needed for unchanged proof files. The existing P18 validator also exited 0 using `/private/tmp/defiformal-repro-python/bin/python` with its supplied jsonschema dependency. This review ran no fresh Solidity/EVM campaign.

## II.3 adjudication and limits

II.3's three-artifact requirement and relation scenario are met: the repository now holds an exact model-theorem artifact, a pinned differential observation record, and a written refinement obligation naming what remains unproved. This supports closure of II.3 after verified integration; it does not close the universal refinement obligation itself. No task checkbox was changed by this reviewer.

The checker validates the frozen package's selected byte and record relations; it is not a universal schema/prose validator, a new execution engine or a compiler proof. In particular, historical semantic classifications are accepted evidence with raw streams checked here, not newly produced EVM observations. The same Lean kernel and cached dependencies remain trusted. No outside-developer reproduction, adoption, authoring-effort reconstruction, full native/deployed refinement or other task completion follows. Sole-branch integration and delivery verification remain root responsibilities.

Final file SHA-256 identities:

- `docs/correspondence/token0/differential-observations.json`: `617c39231e48902ba8137df863e8c61ef456f7ade19bac6e2abb0bbebd7a59aa`
- `docs/correspondence/token0/model-theorem.md`: `3a34a587224b94facd4f53501d7511578846334ad75eddc79ea2899255ee6e86`
- `docs/correspondence/token0/refinement-obligation.md`: `b3d1a5970ea767237ee257d2ce0d47a9c11d2dd9110d8017f23f0e425839c30f`
- `docs/correspondence/token0/verify.py`: `9c08fbdfa39f0f701472363ec8c602176fcde896119d547b85bf2ed1aa44f001`
