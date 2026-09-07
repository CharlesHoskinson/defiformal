# Sprint9 fresh Python baseline

All thirteen suites passed on actual execution candidate `99e2e2c61a1a3c5249026921efdc6cd41ac8f21d`. The fresh run used at most three concurrent suite processes, pinned Lean 4.33.0-rc2, 148 candidate-bound source inputs, and new temporary output `/tmp/defiformal-sprint9-baseline-8_6p3euj`. All inputs remained unchanged. This is new execution evidence, not reused Sprint8 output.

Saved raw evidence reconciles through 3,382 assertions:

- 82 semantic mutants: Typed 24, Composition 12, Parallel 14, Interleaving 14 and Atomic 18. Their unchanged controls and protected positives pass; designated comparisons fail through the exact runtime-error protocol.
- 215 actual runner-control cases: 17, 36, 45, 52 and 65 respectively.
- 99 axiom-audit behavioral assertions.
- One executed typing positive and three expected compiler type errors, which are not financial counterexamples.
- 20 corpus tests containing 76 CLI invocations.

`baseline-runs.json` preserves exact command arrays, UTC times, actual HEAD at both ends, tool executable hashes and all run exits. `source-binding.json` and its after snapshot preserve immutable candidate Git objects and hashes. `artifact-manifest.json` and per-suite copy-integrity files bind full copied outputs and five nested fixture Git metadata archives; no embedded repositories were added. `verified-outcomes.json` records every reconciliation assertion. Later metadata commits do not change the measured execution candidate.

The fresh Atomic summary records correct CLI log paths for both production-form cases. The verifier resolves each recorded log path relative to its actual suite output directory and checks those exact preserved bytes; no path fallback is used.

This baseline is bounded verification evidence and does not establish deployed financial fidelity or authorize Sprint9 implementation before its planning gates. The harness author also prepared this outcome reconciliation; it is not an independent review.
