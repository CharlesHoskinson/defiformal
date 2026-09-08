# Independent GPT-6 P16 planning r3 review

**ACCEPT_WITH_LIMITATIONS. R4 is resolved; no required repairs remain for this planning slice.** This accepts the exact repaired token0 planning/source-readiness package and its bounded diagnostic/control-plan evidence. It does not accept a Lean implementation or compiled source/mutation campaign.

Reviewed archive SHA-256: `382975c628b5881e0352bd011fdf8242b6d4c088d1b4271c4e7bef30c3722a4f`; base `de0e03ed45c1073c6d01f7213303530aafcb9e4f`. The root manifest binds 144 candidate files plus 28 read-only inputs. Independent nonauthor reviewer: GPT-6, stock Codex `/root/p15_contract_review`, configured `gpt-6-astra`; no separate provider telemetry exposed. Native author requested `grok-4.6`; root terminal telemetry reports `grok-4.6-build`, session `01a08235-2429-7c73-87ac-8475ac799b85`, 20 turns, process 0/end_turn. No Foreman.

## R4 resolution

The only changes to the prior 107 candidate files are one decimal replacement each in `openspec/changes/uniswap-token0-p16/fixtures.json:87` and `planned-mutations.json:80`. Both strict-underflow denominator fields now equal:

`115792089237316195423570985008687907853269984665561335876943319670319585689600`

That is `(2^96-2^97) mod 2^256 = 2^256-2^96`. Independently deriving this from the stored fixture inputs gives rounded result 1, matching both stored public-result fields. The designated false remains P16-REQ-STRICT, the equality baseline remains P16-REQ, and the ordinary positive remains P16-ADD. The preserved r2 inputs equal their r2 archive members exactly.

The new `grok-r3/bind_strict_underflow.py` reads the supplied JSON bytes, records their hashes, consumes stored inputs, computes wrapped subtraction and the rounded result, and compares both stored denominator/result fields. It also checks designated, equality and ordinary-control bindings. This directly closes the missing connection found in r2; it is not an ID-existence check or a positive count derived solely from hardcoded examples.

## Fresh checks

Eight direct child invocations used the unchanged binder with `--out` directed into this review and bytecode writes disabled. No original author log was overwritten.

| Input/control | Actual exit | Observed result |
| --- | --- | --- |
| Repaired frozen JSON | 0 | 15/15 binding checks pass |
| Preserved r2 JSON | 1 | 13/15; exactly both denominator fields fail |
| Fixture denominator corruption | 1 | Exactly fixture denominator fails |
| Mutation denominator corruption | 1 | Exactly mutation denominator fails |
| Fixture public-result corruption | 1 | Exactly fixture result fails |
| Mutation public-result corruption | 1 | Exactly mutation result fails |
| Malformed JSON | 1 | Explicit JSON decode failure |
| Empty corpus | 3 | BLOCKED, denominator 0 |

All eight expected outcomes held. Negative child exits remain failures or blocked outcomes; they are not relabelled as successful data validation. Fresh strict OpenSpec exits 0. Independent exact-delta and stored-input arithmetic checks also pass. Before and after review, all 144 candidate files, all 28 read-only inputs and the archive match their frozen hashes. Archive member bytes matched before review; tracked worktree diff is empty. All 89 r1/r2 evidence files and the other 16 plan files are unchanged. No setup failures occurred in this review.

The r2 review's 22 targeted checks, its R1–R3 assessment, and earlier source/oracle/M09 review remain historical exact-byte evidence. They were not repeated or counted as fresh passes. R2's two failures and the cancelled author-attempt provenance remain preserved. The new evidence adds the missing binding and demonstrates that the retained bad values still fail.

## Acceptance limits

The author suite records actual child exits, but its generic `nonzero` expectation would also count a blocked/crashed child as an expected negative. This review accepts the observed, individually verified exit-1 field mismatches and JSON-decode failure. It does not endorse generic nonzero as proof of diagnostic detection for future runs. The binder is a narrow regression diagnostic, not a general schema, range, duplicate-ID or certificate validator; its 15 passing checks establish only the displayed bindings on these exact inputs. Corruptions are diagnostic negatives, with zero production-mutation credit.

The prior substantive limits remain: all-representable token0 inputs include the required overflow partitions; future branch proofs must preserve identity and FullMath/SafeCast refusal order. The local add bound must justify the value before a checked representation replaces a source cast; fallback positivity/reachability remains a proof obligation. Model labels are not Solidity returndata. M09/F32 is a Lean/model control-plan correction, not an established unaffected Solidity control. No unused Signed API is authorized in P16.

Before source scoring, implementation must acquire and bind the actual compiler/EVM identities, fork, bytecode, ABI adapter and exceptional-failure observation. Compiled production mutants must discriminate public outcomes individually and retain unaffected controls. Lean/Arithmetic baseline checks, implementation proofs/audits and independent implementation review remain open. No Lean proof, source execution, compiled mutation, P17 platform reuse, deployment or source/assembly refinement credit is granted here.

This acceptance contributes only the P16 planning slice to original liquidity task 1.2. Whole original 1.2 remains open until P21 residual planning review is accepted. P21 signed/tick/fee and broader-library residuals and P30 source refinement remain open. Parent owns exact-byte integration and semantic-kernel-pivot-only delivery.
