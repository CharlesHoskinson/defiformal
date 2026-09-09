# P16 source repair r5 independent review

**CHANGES_REQUIRED — one narrow R1 remainder.** The decisive r4 R1/R2 failures are repaired. No further R2 repair is requested by this review. A missing cardinality check still permits duplicate empty EVM payload records to earn mutation credit. No accepted proof source, P17/P18/P21/P30 prerequisite or wider parser engine is requested.

## Completion, freeze and preservation

The freeze occurred after both genuine completion signals: root directly observed shell 12931 exit **0**, and the native stream ended normally with `end_turn`, session `01a084b6-21a6-7991-a372-936e42d44fd9`, 41 turns, actual reported model `grok-4.6-build`. The initial checker poll returned an inaccessible process handle; no success was inferred from it. Root's actual terminal receipt is bound separately.

The independently created archive is `p16-source-candidate-r5.tar.gz`, SHA-256 `235e9a0f0aaf18342bc3d99bcb1fa13723e6144dfcc47e8523fc11d8b0da4f7a`; manifest SHA-256 is `7f6b60f2dce093683414a10d5c91b36b9d5d25c6f34ea20b01a40f1c63c344c1`. It binds 6,833 files. Only `p16_common.py`, `p16_evm.py` and `source_campaign.py` changed from r4. All 3,924 other r4 baseline files, including all 197 accepted r2 files, retain their bytes. All 2,905 author-manifest rows verify. Raw native stream/stderr were compressed and checked against their original bytes.

Final hashes also preserve all 144 planning files and 179 prior tracked Lean-tree files; tracked status is clean. No production source or author evidence was edited. Source execution used the private reviewer Lean cache, with evidence only under this review directory. Prior proof/kernel review remains accepted and was not rebuilt as a broad campaign.

## Verified repairs and positives

The fresh intact campaign exits **0** with all twelve independent source observations, all six actual compiled one-edit mutants, complete RuntimeAudit output and twelve directly bound Lean comparisons. Independent checks match all seven baseline/mutant compilation identities, creation/runtime bytecode hashes, source edits, ABI selector/calldata, stored fixture values and Lean results. These agree with retained r4/r3 positives. Strict removal still produces mutant public 1, equality remains a refusal, identity-skip retains INVALID, and all required ordinary ADD controls are unchanged.

Fresh controls establish:

- Genuine Lean compile-error-after-valid-rows now blocks **3**, with actual child/wrapper **1**.
- Genuine malformed extra Lean protocol output now blocks **3**.
- A genuine generated Lean false comparison, with actual compiler child **0**, returns campaign **1**.
- Wrong receipt status, argv, cwd, exit type, hash, and receipt-bound unknown EVM error text each block **3** through the full campaign.
- CLI mismatch returns **1**; empty selection, missing compiler, malformed fixtures, omission, type error and extra fixture return **3**.
- Current Lean-text and recorder control suites pass. The recorder suite retains child 0/1/3, timeout cleanup and unaffected-process controls.

`invocation_is_successful` now separates ordinary completion from semantic eligibility; `score_lean_execution` requires it. Receipt classification consistency is enforced. The binding parser now rejects the previously ignored extra P16 row and checks summary/result metadata. The EVM grammar rejects unknown error text, duplicate ABI words, duplicate error lines and arbitrary extra text. The only requested remainder is the empty-payload count below.

## R1 remaining: duplicate empty payloads before a known error

Exact locations: `scripts/token0_p16/p16_evm.py:178` initializes `empty_hex`; line 186 appends each `0x` record; line 209 rejects a mixed ABI/empty payload; line 216 enters the error branch without bounding the number of empty payload records; line 231 synthesizes the selected empty payload.

The already-required duplicate-output rule is incomplete. The following is accepted as a semantic exception:

```text
0x
0x
error: invalid opcode: INVALID
```

The eight-case grammar boundary probe first exposed this. `grammar-faults/duplicate-empty-payload` then reproduced it through the **actual full campaign**, using the same explicit relay method as the sealed r4 controls: a genuine recorder/EVM invocation runs first, then the designated identity-skip output is replaced with these records and its receipt byte count/hash updated consistently. The relay source, actual argv, receipt, output and score are retained. This is a diagnostic input fault, not an additional production mutant or a claim about naturally emitted EVM output.

Actual result: campaign exit **0**, baseline **12/12**, mutants **6/6**, despite the duplicate payload records. Duplicate ABI words and error lines correctly block; only the empty-payload count is missing.

Required repair: enforce at most one explicit empty-payload record before classifying a known error, just as the parser already bounds ABI and error records. Duplicate `0x` records must block **3**, including before either recognized error. Preserve the genuine pinned runner's blank first returndata line and its recognized revert/INVALID forms; this does not require inventing a nonempty payload. Add a focused real consumer duplicate-empty control, retain the passing grammar/false/blocked controls, and produce one fresh authoritative intact score. No other source change is requested.

## Historical probe reconstruction

The author accidentally overwrote the first r4 diagnostic JSON with a post-repair rerun. The frozen `r4-before/parser-scorer-probe.json` explicitly identifies itself as a reconstruction. `logs/reconstruction-binding.json` and `recovered-r4-probe-original.stdout` bind all twelve reconstructed got/want pairs to original native tool stdout, SHA-256 `abe9e32b212e9e63f84fbd7effec862fd0f55fe1bd055d5fc1c951535c63e518`.

This is truthful preservation of those diagnostic pairs, **not** byte-identical restoration of the original JSON. Its manually populated UTC is not credited as an original execution timestamp. The post-repair output remains separate. Acceptance depends on fresh reviewer commands, not reconstructed metadata. Do not rerun that historical probe in place, since its output path targets historical evidence.

## Gate disposition

Source/operation acceptance and whole-P16 completion remain withheld solely for this R1 remainder. Accepted planning/proof scope and verified source positives remain available for a minimal targeted follow-up. The remaining token0 source tasks 4.1–4.4, 5.1/5.2/5.4 and 6.1–6.3, with the applicable program 17.5–17.6 contribution, need the final consumer repair and independent review; no wider implementation gate is added.

M09 remains model-side Lean SwapMath with the correct F28/F31/F32 distinctions. Original mixed liquidity/45-fixture work remains P21, Typed reuse remains P17, source refinement remains P30, and P18 publication follows accepted P16. Hardcoded replay paths retain their stated limitation. No deployment, universal refinement or broader library acceptance is granted.

All reviewer execution has ended. Checker and private cache are released. Exact rejected overlay and nonrecursive evidence manifests accompany this report.
