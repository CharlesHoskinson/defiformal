# Independent GPT-6 P16 planning r2 re-review

**CHANGES_REQUIRED — one remaining literal-binding repair.** R1's mutation design, R2's public branch contract and R3's scope correction are otherwise adequate for this planning slice. Two stored denominator values remain wrong, and the author diagnostic does not compare them to its correct calculation. No new compiler, EVM, Lean or broad campaign is requested.

Exact candidate archive SHA-256: `baaf21f02b8d2e78293763d1c2c41e8b65d3f1e1bbeb56f14d06d276da57aae5`; base `de0e03ed45c1073c6d01f7213303530aafcb9e4f`. Root manifest binds 107 files (18 plan, 65 unchanged r1 evidence, 24 r2 evidence), plus 28 unchanged read-only inputs. Independent nonauthor reviewer: GPT-6, stock Codex `/root/p15_contract_review`, configured `gpt-6-astra`; no separate provider telemetry exposed. Native author requested `grok-4.6`, root telemetry reports `grok-4.6-build`, session `01a08235-2429-7c73-87ac-8475ac799b85`. The first r2 attempt was capped at 25 turns, process 1/cancelled; its provenance is preserved. The five-turn evidence-only closeout ended normally, process 0/end_turn. It does not retroactively make the cancelled attempt successful. No Foreman.

## Required repair R4 — bind the stored strict-underflow literals

`openspec/changes/uniswap-token0-p16/fixtures.json:87`, JSON location `fixtures[id=P16-REQ-STRICT].t0_req_skip_mutant.wrapped_denominator`, and `planned-mutations.json:80`, location `token0_production_mutants[id=T0-REQ-SKIP].mutant_public_strict.wrapped_denominator`, currently contain decimal **2^256**:

`115792089237316195423570985008687907853269984665640564039457584007913129639936`

For the frozen inputs `(2^96,1,2,false)`, native wrapped subtraction is `(2^96-2^97) mod 2^256 = 2^256-2^96`. Replace both literals with:

`115792089237316195423570985008687907853269984665561335876943319670319585689600`

The source-shaped mutant result **1** and the symbolic prose are already correct. Keep the equality refusal baseline and ordinary add positive unchanged.

Add a small new diagnostic binding that reads the stored fixture inputs and both stored mutant denominator/result fields, independently derives the wrapped subtraction and rounded result, and compares those actual stored values. It must fail on the preserved r2 literals. Do not manufacture another positive count from hardcoded inputs/expected values or fixture-ID existence alone. Preserve all r1/r2 scripts, outputs, this failed review and candidate archives; put the fix and its fresh nonempty/empty check receipts in new repair evidence. No generic checker engine is required.

The current `grok-r2/diagnose_r2.py:321–338` computes from a separate hardcoded case list. Lines 354–356 correctly compare its mutant computation to `U256-Q96`, while line 406 only checks the fixture ID exists. Thus its 37/37 outcome does not validate the two stored values. The new binding should cover the actual stored result as well as the denominator so this precise gap is closed.

## Resolved scope and substantive checks

- **R1:** Six concrete Solidity edits are now named and each applies to one inspected source anchor. The strict-underflow witness changes public refusal to success 1; equality still fails FullMath denominator zero and earns no detection credit. Wrap-skip keeps native wrapping and the bare uint160 cast; product-skip retains the product assignment. Their declared numeric outcomes and the floor fixture are correct. Checked-add uses the actual LowGasSafeMath source edit. Identity deletion reaches high-level division by zero; Python/Lean identity deletion is explicitly different. Actual exceptional outcome classification remains a later compiler/EVM obligation.
- **R2:** Removal refusal and nonidentity equations now include amount nonzero and refer to the public helper. FullMath precedes SafeCast; the guard-passing SafeCast witness, zero-liquidity identity and primary-add denominator-zero witness are correct. The plan names future local add-range and fallback-positivity obligations without excluding the overflow partitions or inventing a source add-cast refusal. To justify a checked representation, implementation must establish the relevant bound on the value before the source cast; a bound solely on a truncated returned word would not establish cast equivalence. This is the named future obligation, not a proof delivered now.
- **R3:** The unused Signed permission is removed; signed/tick/fee/F45 portions of original mixed 2.1 remain P21.
- M09 is explicitly the future Lean/model direction mutation. F32 is supported as its model-side unaffected control with the preguards; no unaffected Solidity-M09 claim is accepted. Compiled M09 remains P21.

## Fresh checks and preservation

Fresh strict OpenSpec exits 0. Counts independently confirm 5 capabilities, 24 requirements, 30 scenarios, 20 unchecked implementation tasks. Exact-byte r2 replay exits 0 with **37 checks, 37 pass, 4 new witnesses**. Its nested exact-byte r1 replay exits 0 with **44 checks, 8 cases, 0 failures**. Actual r2 `--empty-corpus` through the script's `__main__` entry exits **3**, prints denominator 0 and a blocked message.

Fresh independent targeted checks: **22 checks, 20 pass, 2 fail**. The two failures are exactly the stored denominator fields above. Remaining checks cover four new witnesses, strict-underflow result, equality nondetection, wrap/product/floor/checked-add feasibility, the shared ordinary positive, six actual source anchors, identity source-path inspection and inventory counts. These finite arithmetic/source-inspection checks are not compiled mutation runs. The first fail-fast checker failure is preserved under `logs/independent-targeted-attempt1.*`; it is a real candidate mismatch, not a setup failure. The subsequent collection pass records both failures in `logs/independent-targeted.json`.

Replay uses unchanged r2/r1 script bytes with bytecode writes disabled. A review wrapper redirects only the two r2 JSON output paths and maps reads/existence checks for those same fresh outputs. Other `Path.write_text` writes are denied. Original stdout still prints original paths; `logs/replay-receipts.json` records the adaptation. Author r1 and r2 evidence remains unchanged.

Before/after checks match the archive, all 107 candidate and all 28 read-only input hashes; archive member bytes also matched before review. All 37 entries in the author's internal manifest match byte/hash claims. Tracked worktree diff is empty. The prior review's 28 assertions and four mutation-supplement checks remain prior exact-byte evidence, not newly rerun checks or added fresh passes.

## Verdict limits

Whole planning acceptance remains false pending the single repair and an exact-byte targeted re-review. Original whole liquidity task 1.2 remains open until the P21 residual planning review is accepted. No Lean proof, source execution, production mutation, P17 platform reuse or universal source refinement credit is granted. Compiler binary acquisition, exact EVM identity/fork, bytecode/ABI observation binding, exception classification, branch proofs and individually discriminating compiled mutants with unaffected controls remain future implementation gates. The current success/revert shorthand must not erase the explicitly required exceptional-failure observation when that adapter is implemented. No new campaign is required for this planning repair.
