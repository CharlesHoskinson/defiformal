# P16 token0 planning acceptance

ACCEPT_WITH_LIMITATIONS for the exact token0 planning, source-readiness,
diagnostic-oracle and mutation-control-plan slice. Program tasks 17.1–17.3 are
accepted at that scope. This authorizes implementation of the accepted slice;
tasks 17.4–17.6 remain open. No Lean, Solidity execution, production mutation,
P17 platform reuse, or source-refinement result is accepted here.

The r3 archive SHA-256 is
`382975c628b5881e0352bd011fdf8242b6d4c088d1b4271c4e7bef30c3722a4f`.
The independent review manifest SHA-256 is
`31b6fa698dd2ea98f0516a9263d3dc60feaf0b10f4c8ef7cf30380713612adfc`.
See `p16-r3-planning-review/REVIEW.md` and its manifest for the exact acceptance.
All 144 candidate files are integrated unchanged. The 27 immutable current
inputs match; the historical workflow CURRENT is retained separately in
`p16-context-CURRENT-at-read.json`. `p16-planning-integration.json` binds both
contexts and the seven pinned source/configuration files.

The original defective overflow oracle and failed mutation plan remain evidence.
The corrected diagnostic uses the Solidity 0.7.6 wrapped-sum fallback. Public
branch contracts retain amount-zero identity, nonzero premises, ordered
FullMath/SafeCast failures and the zero-denominator and SafeCast witnesses.
The add cast remains the source bare cast: a bound used to replace it with a
checked representation must apply to the value before the cast. A bound only
on the truncated result is insufficient. Fallback positivity remains a local
proof obligation. No unused Signed declaration is authorized.

The six production mutants now specify actual Solidity edits and public
observations. T0-REQ-SKIP uses strict underflow with wrapped denominator
`2^256 - 2^96` and public result 1; equality remains a refusing control. The two
incorrect r2 decimal fields and their failing checks are preserved. M09 excludes
F28 and names F32 as a model-side unaffected sibling under the future Lean
SwapMath preguards. This is not an established Solidity control or compiled M09
result; that campaign belongs to P21.

Independent r3 review passed 15 stored-field binding checks and verified eight
actual child outcomes, including preserved bad input, separate denominator and
result corruptions, malformed input and empty input. Primary integration replay
passed strict OpenSpec and the repaired inputs, rejected preserved r2 with exit
1, and classified empty input as blocked exit 3. Exact logs and commands are in
`p16-primary-planning-validation/`. Earlier diagnostic counts remain historical
and are not recounted as fresh source or mutant execution.

The author suite's generic nonzero expectation is broader than a semantic
detection. Acceptance relies on the independently classified actual exit-1
mismatches, not generic parent success. The narrow diagnostic is not a general
input validator. Future production gates must distinguish failure, blocked setup,
and timeout rather than scoring arbitrary nonzero exits as detections.

Native Grok authored all three revisions. The r3 terminal reports
`grok-4.6-build`, session `01a08235-2429-7c73-87ac-8475ac799b85`, 20 turns,
process 0/end_turn. The earlier cancelled r2 attempt remains cancelled evidence.
Independent nonauthor GPT-6 was configured as `gpt-6-astra`; no separate provider
telemetry is available. No Foreman was used.

Next: run the pinned Arithmetic baseline, implement Types/FullMath/token0 and
the public branch proofs, acquire and bind solc/EVM/fork/bytecode, execute the
nonempty source partitions and six compiled mutants with unaffected controls,
then obtain independent implementation review. The private cache preparation
is administrative setup with no mathematical or execution credit.

Whole original liquidity task 1.2 remains open until the P21 residual planning
contribution is independently accepted. P16 does not wait for that work.
Signed/tick/fee, token1/delta, the wider library and full fixture/mutation campaign
remain P21; source/assembly refinement remains P30. Whole P16 and the complete
program remain unfinished.
