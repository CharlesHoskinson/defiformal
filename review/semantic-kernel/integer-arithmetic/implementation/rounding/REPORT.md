# Rounding implementation

Status: complete within the owned module; targeted author checks pass. Source is stable at SHA256 `0bd0c65af77bc809f4ff3b8cb5d98ab7eca5be0e0e7216e9e88263e4e02649f0`.

`Rounding.divideNat` rejects zero first, then computes natural floor or ceiling by quotient/remainder. `mulDiv` uses the full unbounded natural product and checks only its final quotient against Word width. The four accepted M03–M06 runtime anchors each occur exactly once before the proof marker; this is anchor reconciliation, not mutation execution.

The38 universal theorems include independent floor inequalities and ceiling leastness, exact success/refusal characterizations, divisionByZero precedence, quotientOverflow and exclusion of all other error constructors, existence, zero/width-zero behavior, divisibility exactness, ceiling/floor gap, rational directed errors in[0,1), and monotonicity in both checked operands with successful-result and positive-denominator premises. Fees consumes `divideNat_le` and the independent success specifications; no fee bound or desired financial result is assumed by the quotient proofs.

Final pinned Lean build passed817 jobs without warnings. All38 theorem axiom checks passed with only propext, Classical.choice and Quot.sound. Seven literal computations passed:21/4floor5 andceil6, zero-denominator refusal, full-product200*200/200, floor255fits versus ceiling256overflow, and width0. These are development probes; they are not the planned45-fixture runtime inventory,12productionmutants,65CLIcontrols or27968-case diagnostic. No sorry, custom axiom, native_decide or noncomputable declaration is present in the new source.

Exact commands, full stdout/stderr, UTC timing, tool executable hashes and before/after unchanged source bytes are in execution.json/checks.json. The observed HEAD was `b4705b074d7b2d205eb8ad1e2a9ded34ef4ca32f` at start and `b4705b074d7b2d205eb8ad1e2a9ded34ef4ca32f` at finish; new source was uncommitted. development-diagnostics.json preserves an explicitly labelled transcription of intermediate LSP errors and repairs; no failed diagnostic is represented as a semantic detection.

Only Arithmetic/Rounding.lean and this new evidence directory were written. Corpus r2 remains sealed; no root integration, historical source edit, native call, production mutation or commit was performed. Remaining integrated arithmetic evidence and independent acceptance are parent-owned. Requested implementation model: stock GPT-6; independent provider-build telemetry is unavailable.
