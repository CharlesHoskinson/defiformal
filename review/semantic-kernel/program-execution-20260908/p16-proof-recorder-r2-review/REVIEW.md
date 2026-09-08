# P16 r2 independent proof/model/recorder review

Verdict: **ACCEPT_WITH_LIMITATIONS** for frozen P16 tasks 2.1–3.3 and 5.3 only. No required repairs remain in this reviewed subset. This provides proof/audit evidence toward program 17.4; it does not complete P16 or confer operation credit.

The accepted input is `p16-proof-recorder-candidate-r2.tar.gz`, SHA-256 `62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8`, with all 197 files bound by the root freeze manifest. Independent GPT-6 reviewed native Grok's completed guided r2 session; the reported actual model is `grok-4.6-build`, with 46 turns and normal process 0/end_turn. Earlier cancellation and failed-resume evidence remain historical failures, not normal completion.

## Fresh verification and preservation

The exact nine Lean sources and five scripts were reviewed in the existing private sandbox, using its independently copied cache. No worktree/primary source or shared cache was changed. `lake build DefiKernel.ConcentratedLiquidity.Verify` exited 0 in 8.053 seconds under a 45-second bound, elaborating the current proofs and running RuntimeAudit/ProofAudit. Runtime output contains 22 distinct passing comparisons: ten FullMath comparisons for F01–F09 (two directions for F03), and twelve token0 fixtures. The expected literals are independently stored fixtures, not a comparison of the function with itself. This is finite Lean execution, not compiled Solidity agreement.

Before/after checks bind the archive and all 197 candidate files. Final checks also match all 179 prior tracked Lean-tree files, all 144 accepted planning files, all 77 retained r1 evidence files, and all 104 rows of the author's internal manifest. The author's tracked worktree status is clean. Concurrent new r3 additions are outside this byte-bound scope. Tool identities and command receipts are in `logs/`; the actual Lean 4.33.0-rc2 binary SHA-256 is `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. The invoked elan proxy and actual toolchain binaries are identified separately.

## Semantic assessment

`Types.lean` keeps the token0-only widths, failures and Q96 without the deferred Signed API. `FullMath.lean` wraps the existing width-256 Arithmetic rounding API. Its exported success/refusal theorems expose the floor/ceiling specifications and width refusals; they are not assembly-refinement claims.

`SqrtPriceMath.lean:91` proves `numerator1_comm`, preserving the mathematical numerator while orienting multiplication to avoid the previously diagnosed symbolic normalization. The temporary result/wrapper detours are absent from the frozen Lean files; fresh Verify proves their consumers remain valid.

`Token0Proofs.lean:51` onward gives actual Bool/Prop guard bridges, including the product-fit premise needed for the wrap bridge. Public equations preserve zero-amount identity, require amount nonzero on nonidentity branches, distinguish wrapped primary addition from checked fallback addition, and preserve FullMath failure before SafeCast failure on removal. `remove_require` does not incorrectly override zero-amount identity. The proof statements describe the public helper's selected result rather than only arbitrary helper equalities.

The bounds are substantive pre-cast statements. `primary_add_precast_le` at line 217 bounds the successful width-256 FullMath quotient by the input price using rounding leastness. `wrap_fallback_sqrtP_pos` and `prod_fallback_sqrtP_pos` derive price positivity from reachable overflow branches. `fallback_inner_pos` at line 279 obtains positive inner denominator from nonzero amount and successful checked addition. `fallback_precast_le` at line 295 bounds the natural rounded quotient before the bare uint160 cast, using the floor/remainder identity and ceiling bound. `add_result_le` at line 340 connects these results to the public helper for every representable input whose add call succeeds, including zero-amount identity and both overflow partitions. It does not assume its conclusion or use only the post-cast width bound. Internal division-at-zero totalization is not accepted as standalone source equivalence; reachable fallback positivity supplies the needed restriction.

## Complete elaborated inventory

The independent `ReviewInventory.lean` enumerates every declaration kind by imported module provenance and traverses project references in both types and bodies. `logs/elaborated-inventory.json` records names, exact expression representations, printed types, module identity and transitive axioms for 257 root declarations and their 314-declaration project closure. Source hashes for all ten used project modules are in `logs/closure-summary.json`; Verify/ProofAudit also remain bound as candidate source files.

The author's 138 theorem rows and 108 supplemental definition rows are disjoint categories and match the independently enumerated sets exactly. Seven constructors, two inductives and two recursors account for the remaining eleven roots. There are 62 source-written theorem statements; the 138 includes generated theorems. These are not 138 independent mathematical properties. Every closure declaration is checked with Lean's transitive axiom collector; only `propext`, `Classical.choice` and `Quot.sound` occur. No `sorry`, custom axiom or `native_decide` occurs in the candidate sources. This is a used project closure inventory, not a claim to enumerate every unused Mathlib declaration.

The first reviewer inventory attempt had a quotation/parenthesis syntax error; its source and exit-1 logs are retained beside the successful corrected review helper. A later attempt to read planning tasks from the execution sandbox failed because those documents were not materialized there; the verified worktree copy supplied them. Neither setup failure is counted as a production semantic failure.

## Recorder controls and required consumer behavior

Fresh replay of the unchanged author test code, with only its evidence destination redirected, passed all five control groups: actual child 0/1/3 propagation, empty-command exit 3, and timeout exit 3 with `timeout_blocked`, unknown child exit, owned descendant cleanup and an unaffected outside process. Additional actual invocations confirm child signal death yields wrapper 3/classification `crash`, and SIGTERM cancellation yields wrapper 3/classification `cancelled`, unknown child exit, removed descendant and surviving outside process. These establish the tested owned-process-group behavior; they do not claim containment of arbitrary children that deliberately escape the group.

A missing executable raises `FileNotFoundError`: this recorder actually exits 1 and produces **no receipt**. It does not itself normalize that setup case to exit 3. R3 consumers must reject missing or malformed receipts as setup-blocked, expose actual missing-tool/setup-blocked exit 3 at their runner boundary, and never count ordinary child exit 1, compiler failure, crash, cancellation or timeout alone as mutation detection. Semantic detection requires valid, nonempty observation evidence. These are explicit mandatory consumer conditions for the next source review, not repairs to silently apply to the frozen r2 inputs.

## Remaining acceptance limits

No pinned compiler/EVM execution, source agreement, compiled production mutant, unaffected mutant control, complete operation acceptance, P17 source reuse/refinement, or P30 assembly refinement is accepted here. The frozen Solidity probe is only a prototype in this review. All six planned compiled token0 mutants and the source campaign remain mandatory. M09 remains the later Lean SwapMath control-plan handoff, with no Solidity F32-control inference. Original whole-liquidity 1.2, the mixed signed/tick/fee residual, full original 45-fixture campaign and P21 remain open. Accepted planning requirements are unchanged.

The manifest binds this report, verdict, exact accepted overlay, all review evidence, candidate files, and used project source hashes. The checker and private sandbox are released after sealing; no reviewer-owned child process remains running.
