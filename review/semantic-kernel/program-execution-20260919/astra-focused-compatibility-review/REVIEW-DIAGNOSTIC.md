# Incremental diagnostic review

**ACCEPT for integration of this exact eight-file repair.** B1 is resolved; no remaining blocker in the reviewed scope.

Reviewer: independent Codex Astra medium (requested `gpt-6-astra`; configured identity supplied by parent). Exact source identity: `diagnostic-source-hashes.json`, base `44f2026d063403561bedfe2c22575edf0b60ddf0`. All eight hashes match after verification. Only `Delivered.lean` and `CompatibilityStatusRegression.lean` changed since the original review, confirmed against the full prior Lean-source hash inventory. Original source bytes and rejected verdict remain preserved.

The implementation adds `incompleteDischargeCtor` and changes only the failure constructor in the existing failed-discharge branch. It leaves status/acceptance conditions, observations, failure precedence and theorem statements unchanged. Typed library truth is recomputed by `familyBound` from the same instantiation check used by discharge; step/run library discharge remains unmet. Thus the selected diagnostic identifies the unmet requested family, including both-flags cases.

Independent verification, all exit 0:

- Affected build: `lake build DefiKernel.Certificates.KernelCorrespondence DefiKernel.Certificates.CompatibilityStatusRegression` (947 jobs, 5.82 seconds).
- Focused regression with `../overlap-run.json`: all ten checks true. The original six overlap/disjoint checks remain unchanged and pass. Invariant-only and both-with-library-satisfied report `proof.ComponentContract.invariant`; library-only and both-with-library-unmet report `libraryTheoremsInstantiated`.
- Original direct `PolicyProbe.lean`: invariant-only report is incomplete with the correct invariant constructor and a successful receipt.
- Original `Axioms.lean`: the four accepted-implies-no-false lemmas again disclose only standard axioms (`propext`, `Classical.choice`, `Quot.sound`; overlay uses only `propext`).

Commands/cwd/exits are in `diagnostic-*-command.json`; raw logs are `diagnostic-*.log`; exact change is `diagnostic-source.diff`. Reuse original passing actual CLI/raw equality and historical Correspondence/Roundtrip evidence: Check, codec, historical proof files and their dependencies are unchanged. No source edits were made by this reviewer.

Acceptance covers the compatibility-status repair and corrected discharge labels only. It does not qualify full P19/P20, resolve branch/host/library gates, export the default root or complete the broader program. The previously documented inherited assumption-label defect remains outside this repair.
