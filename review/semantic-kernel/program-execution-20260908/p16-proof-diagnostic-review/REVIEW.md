# P16 partial-proof diagnostic

**The frozen snapshot does not reproduce a timeout.** One isolated `lake build DefiKernel.ConcentratedLiquidity.Token0Proofs` exited 1 in **4.996 seconds**, with a concrete unsolved goal in `Token0Proofs.lean`. SqrtPriceMath built in 954 ms. This is diagnostic evidence only, not candidate or implementation acceptance.

Input archive SHA-256: `9c5538fb713c788db8d17d438d0d9768c74d71f6a5453144f83802cc4b47afcc`; 47 frozen files. Tracked Lean materialized using read-only `git archive` from W16 HEAD `de0e03ed45c1073c6d01f7213303530aafcb9e4f`, then overlaid with the snapshot. Sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox`. Cache independently copied from idle primary with `cp -a --reflink=auto`; no W16 cache access, shared inode or external cache symlink. Three preserved relative package documentation/benchmark symlinks resolve inside the sandbox. The first preservation audit wrongly rejected every symlink; that audit failure and correction are recorded.

## Finding and guidance

Frozen `lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean:10` applies `rw [ha, ...]` with `ha : a = W + (a-W)` globally. This also expands the right-hand occurrence of `a`. The exact residual is:

```lean
hsmall : a - W < W
⊢ (a - W) % W = W + (a - W) - W
```

Avoid the global self-expanding rewrite. Core `Nat.mod_eq_sub_mod hle` directly rewrites `a % W` to `(a-W) % W`; `Nat.mod_eq_of_lt hsmall` then supplies the desired value. Alternatively normalize the current residual using `hsmall` and `Nat.add_sub_cancel_left`. These are source-level corrective directions, not an authored/tested implementation patch. The named lemmas were checked in the pinned Lean core sources. No source edits, theorem changes, `sorry` probes or repeated builds were made.

The retained earlier logs report Sqrt timeouts of 300/90 seconds and Token0Proofs timeouts of 90/60 seconds, but do not include the earlier source bytes that caused them. Later retained logs already show Sqrt defs succeeding and minimal Token0Proofs failing quickly with this residual. Consequently the cause of the **older** timeouts cannot be established from this archive. The present result supports fixing the concrete local goal, not increasing timeout budgets or blaming cache/toolchain corruption. If a timeout recurs, freeze that exact source and its command before further edits and isolate/profile the relevant declaration.

## Exact execution and limits

The sole command had a 45-second process-group timeout and did not hit it. Lean was `4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; binary SHA-256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. Lake binary SHA-256 `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`. Target timings: Types 555 ms; FullMath 961 ms; SqrtPriceMath 954 ms; Token0Proofs 915 ms, exit 1. Exact command, source identities, stdout/stderr, timeout and preservation receipts are in `logs/`.

All 47 overlaid input files and the archive remain hash-identical. Author files and live cache were not inspected or changed. This partial snapshot does not support acceptance, a complete proof inventory, a final candidate verdict or attribution of historical timeouts to a particular old tactic. Native author continues independently; final complete frozen work requires separate review.

After reproduction, root reported the native author had compiled the wrap lemmas at turn 86. That live-author report was not independently rechecked here; the frozen finding is historical diagnosis, not an assertion of a current blocker.
